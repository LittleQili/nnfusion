from roller.arch import *
from roller.config import *
from roller.op import *
from roller.codegen.op_impl import codegenR
from tvm import te
import time
from roller.policy import *
import os
from roller.utils import *
from roller.utils.cu_helper import helper_text
from db import save_to_db
from test_config import *
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('--reproduce', action='store_true')
args = parser.parse_args()

def main_template(backend, source, op, grids, blocks, times, config):
    input_tensors = op.GetInputTensors(config["schedule_fuse"])
    input_tensors_name = ['input' + str(i) for i in range(len(input_tensors))]
    output_tensors = op.GetOutputTensors()
    output_tensors_name = ['output' + str(i) for i in range(len(output_tensors))]
    all_tensors_name = input_tensors_name + output_tensors_name
    tensor_type_size = op.TensorTypeSize(config["schedule_fuse"])
    tensor_dim = op.TensorDim(config["schedule_fuse"])
    s_size, s_hmalloc, s_dmalloc, s_feed, s_memcpyh2d = '', '', '', '', ''
    s_htensor = '    float ' + ', '.join(['*' + n + 'h' for n in all_tensors_name]) + ';\n'
    s_dtensor = '    float ' + ', '.join(['*' + n + 'd' for n in all_tensors_name]) + ';\n'
    # hot fix for conv_bias fused kernel, where tvm generate wrong arg order
    for i in range(len(input_tensors)):
        if input_tensors[i].name == 'bias':
            all_tensors_name.append(all_tensors_name[i])
            all_tensors_name.remove(all_tensors_name[i])
    s_parameters = ', '.join(['(float*)' + n + 'd' for n in all_tensors_name])

    for i in range(len(input_tensors_name)):
        name = input_tensors_name[i]
        dim = tensor_dim[0][i]
        type_size = tensor_type_size[0][i]
        size = 1
        for d in dim:
            size *= d
        byte = size * type_size
        s_size += '    int input_size' + str(i) + ' = ' + str(size) + ';\n'
        s_hmalloc += '    ' + name + 'h = (float*)malloc(' + str(byte) +');\n'
        s_dmalloc += '    cudaMalloc((void **)&' + name + 'd, ' + str(byte) + ');\n'
        s_feed += '    for (int i = 0; i < input_size' +str(i) + '; ++ i)\n' + '        ' + name + 'h[i] = 1;\n'
        s_memcpyh2d += '    cudaMemcpy('+ name + 'd, ' + name + 'h, ' + str(byte) + ', cudaMemcpyHostToDevice);\n'

    for i in range(len(output_tensors_name)):
        name = output_tensors_name[i]
        dim = tensor_dim[1][i]
        type_size = tensor_type_size[1][i]
        size = 1
        for d in dim:
            size *= d
        byte = size * type_size
        s_size += '    int output_size' + str(i) + ' = ' + str(size) + ';\n'
        # s_hmalloc += '    ' + name + 'h = (float*)malloc(' + str(byte) +');\n'
        s_dmalloc += '    cudaMalloc((void **)&' + name + 'd, ' + str(byte) + ');\n'
        
    if backend == "antares":
        kernel_name = 'template_op_kernel0'
    if backend == "tvm":
        kernel_name = 'default_function_kernel0'

    return helper_text + '\n' \
    '//full_dimensions: {}' \
    '\n' \
    '{}' \
    '\n' \
    'int main(int argc, char *argv[])\n' \
    '{{\n' \
    '    std::string path;\n' \
    '{}' \
    '\n' \
    '    checkCudaErrors(cuInit(0));\n' \
    '    CUdevice device;\n' \
    '    checkCudaErrors(cuDeviceGet(&device, 0));\n' \
    '    CUcontext context;\n' \
    '    checkCudaErrors(cuCtxCreate(&context, CU_CTX_SCHED_AUTO/*CU_CTX_SCHED_YIELD*/ | CU_CTX_MAP_HOST, device));\n' \
    '\n' \
    '{}' \
    '{}' \
    '{}' \
    '\n' \
    '{}' \
    '\n' \
    '    srand(1);\n' \
    '{}' \
    '\n' \
    '{}' \
    '\n' \
    '    dim3 grid{};\n' \
    '    dim3 block{};\n' \
    '\n' \
    '    for (int i = 0; i < {}; ++i)\n' \
    '    {{\n' \
	'        {}<<<grid, block>>>({});\n' \
    '        cudaDeviceSynchronize();\n' \
    '    }}\n' \
    '}}\n'.format(
        op.Dimensions(), 
        source, 
        s_size, 
        s_htensor, 
        s_dtensor, 
        s_hmalloc, 
        s_dmalloc, 
        s_feed, 
        s_memcpyh2d, 
        grids, 
        blocks, 
        times, 
        kernel_name,
        s_parameters,
        )


def get_pad(rprog, out_tensor):
    smem_tile_shape = rprog.GetTile(0).Dimensions()
    shape = rprog.op.Dimensions()
    saxis_name, raxis_name = get_axis_names(out_tensor)
    all_axis_name = saxis_name + raxis_name
    assert len(smem_tile_shape) == len(shape) == len(all_axis_name)
    pad = {}
    for d in range(len(shape)):
        s = shape[d]
        t = smem_tile_shape[d]
        aligned_s = ((s - 1) // t + 1) * t
        assert aligned_s >= 0
        pad[all_axis_name[d]] = aligned_s - s
    return pad

def get_tvm_source(rprog, arch, shape, policy, dtype, config):
    expr = rprog.Expression()
    # shape = rprog.Dimensions()
    expr_out = expr(shape, dtype, False)
    in_tensors, out_tensors = expr_out[0], expr_out[1]
    out_tensor = out_tensors[0]
    if config["schedule_fuse"]:
        pad = get_pad(rprog, out_tensor)
        expr_out = expr(shape, dtype, False, pad)
        in_tensors, out_tensors = expr_out[0], expr_out[1]
        ori_in = []
        pad_in = []
        for ins in in_tensors:
            if '_pad' in ins.name:
                pad_in.append(ins)
            else:
                ori_in.append(ins)
        out_tensor = out_tensors[0]
        write_tensor = out_tensors[-1]
        s = te.create_schedule(write_tensor.op)
        align_info = policy.get_align_info_fuse(rprog, arch, config["smem_tiling"], config["reg_tiling"], target_stage=out_tensor.name, write_stage=write_tensor.name, st_align=config["st_align"])
        cgen = codegenR.CodeGeneratorR()
        cgen.rewrite_schedule_fuse(s, rprog, config["smem_tiling"], config["reg_tiling"], pad_in, out_tensors[:-1], write_tensor, target_stage=out_tensor.name, write_stage=write_tensor.name, align_info=align_info, bank_size=arch.smem_bank_size)
        func = tvm.build(s, ori_in + out_tensors, "cuda")        
    else:
        s = te.create_schedule(out_tensor.op)
        align_info = policy.get_align_info(rprog, arch, config["smem_tiling"], config["reg_tiling"], target_stage=out_tensor.name, st_align=config["st_align"])
        cgen = codegenR.CodeGeneratorR()
        cgen.rewrite_schedule(s, rprog, config["smem_tiling"], config["reg_tiling"], target_stage=out_tensor.name, align_info=align_info, bank_size=arch.smem_bank_size)
        func = tvm.build(s, in_tensors + out_tensors, 'cuda')
    return func.imported_modules[0].get_source()


def compile_and_run_kernel(rprog, op, shape, data_type, arch, policy, device_id, idx, prefix, config):
    block_size = rprog.GetParallelism(1) * (32 if config["use_tc"] else 1)
    grid_size = rprog.GetParallelism(0)
    blocks = (block_size, 1, 1)
    grids = (grid_size, 1, 1)
    
    times = 10
    if not config["use_tc"]:
        source = get_tvm_source(rprog, arch, shape, policy, data_type, config)
        if "float* __restrict__ data, float* __restrict__ kernel, float* __restrict__ conv_unpad, float* __restrict__ bias" in source:
            source = source.replace(
                "float* __restrict__ data, float* __restrict__ kernel, float* __restrict__ conv_unpad, float* __restrict__ bias",
                "float* __restrict__ data, float* __restrict__ kernel, float* __restrict__ bias, float* __restrict__ conv_unpad"
            )
        main_source = main_template("tvm", source, op, grids, blocks, times, config)
    else:
        source = get_tc_mm_source(
            op.GetInputTensors()[0],
            op.GetInputTensors()[1],
            op.GetOutputTensors()[0],
            rprog
        )
        M, N, K = shape
        block_x, block_y, block_z = get_tc_block_size(rprog.GetTile(0), rprog.GetTile(1))
        grid_x, grid_y = get_tc_grid_size(M, N, rprog.GetTile(0))
        main_source = tc_mm_main_template(source, M, K, N, grid_x, grid_y, block_x, block_y, block_z, 10)
        blocks = (block_x, block_y, block_z)
        grids = (grid_x, grid_y, 1)

    file_name = '{}_{}_{}_{}'.format(
        device_id,
        idx,
        '_'.join([str(d) for d in grids]),
        '_'.join([str(d) for d in blocks])
    )
    os.chdir(prefix)
    log_name = file_name + ".log"
    with open('{}.cu'.format(file_name), 'w') as ouf:
        ouf.write(main_source)
    cmd = "nvcc '{}.cu' -lcuda -gencode=arch=compute_70,code=compute_70 -o '{}' && " \
        "export CUDA_VISIBLE_DEVICES={} && "\
        "nvprof './{}' > {} 2>&1".format(file_name, file_name, device_id, file_name, log_name)
    print(cmd)
    os.system(cmd)

    exec_time = get_time_from_nvprof_file(log_name)
    os.system("rm {}".format(log_name))
    return exec_time, source, blocks, grids


def eval_thread(rprogs, rprog_idx, device_id, op, shape, data_type, arch, policy, prefix, config):
    best_time = 1e100
    best_idx = 0
    top1_time = -1
    best_source = None
    best_blocks = None
    best_grids = None
    for idx in range(rprog_idx[device_id], rprog_idx[device_id + 1]):
        rprog = rprogs[idx]
        exec_time, source, blocks, grids = compile_and_run_kernel(rprog, op, shape, data_type, arch, policy, device_id, idx, prefix, config)
        if exec_time < best_time:
            best_idx = idx
            best_time = exec_time
            best_source = source
            best_blocks = blocks
            best_grids = grids
        if idx == 0 and device_id == 0:
            top1_time = exec_time
    return best_time, best_idx, top1_time, best_source, best_blocks, best_grids

def run(identifier, arch, tmp_dir=None, fix_block_size=None):
    if tmp_dir is None: tmp_dir = f"{os.path.realpath(os.path.dirname(__file__))}/roller_kernels/{identifier[:240]}"
    prefix = tmp_dir
    os.makedirs(prefix, exist_ok=True)
    print("Identifier", identifier)
    print("arch", arch)
    if args.reproduce:
        with open(os.path.join(prefix, "final.cu")) as f:
            final = f.readlines()
            # cut until a line with '}'
            best_source = "".join(final[:final.index("}\n") + 1])+"\n"
            best_grid_size = None
            best_block_size = None
            for line in final:
                if line.startswith("dim3 grid"):
                    assert best_grid_size is None
                    best_grid_size = line[len("dim3 grid"):].strip()
                    best_grid_size = best_grid_size.replace("(", "").replace(");", "").split(", ")
                    best_grid_size = tuple([int(x) for x in best_grid_size])
                if line.startswith("dim3 block"):
                    assert best_block_size is None
                    best_block_size = line[len("dim3 block"):].strip()
                    best_block_size = best_block_size.replace("(", "").replace(");", "").split(", ")
                    best_block_size = tuple([int(x) for x in best_block_size])
            assert best_grid_size is not None
            assert best_block_size is not None
        save_to_db(identifier, best_source, best_grid_size, best_block_size)
        return

    arch = globals()[arch]()
    func_name, shape, config = get_func(identifier)
    expr = globals()[func_name]
    op = Op(expr, shape, config["data_type"], use_tc=False)
    start_time = time.time()
    if op.IODependent():
        policy = ConstructionPolicyRT(op, arch, smem_tiling=config["smem_tiling"], reg_tiling=config["reg_tiling"], st_align=config["st_align"], padding_threshold_cap=config["padding_threshold_cap"], shrink_tiny=config["shrink_tiny"], fix_block_size=fix_block_size)
    else:
        policy = ConstructionPolicyPlainRT(op, arch, smem_tiling=config["smem_tiling"], reg_tiling=config["reg_tiling"], st_align=config["st_align"], padding_threshold_cap=config["padding_threshold_cap"], shrink_tiny=False, fix_block_size=fix_block_size)
    emit_time = time.time() - start_time

    rprogs = policy.emit_config_without_trails(config["topk"])
    print("evaluating top {} configs".format(len(rprogs)))
    for rprog in rprogs:
        print(rprog.Dump())
    # TODO: use multi-thread version
    rprog_idx = alloc_configs_for_subprocess(config["num_threads"], len(rprogs))
    threads = []
    for device_id in range(config["num_threads"]):
        thread = MyThread(func=eval_thread, args=(rprogs, rprog_idx, device_id, 
                               op, shape, config["data_type"], arch, policy, prefix, config))
        threads.append(thread)
        thread.start()
    
    best_time = 1e100
    for thread in threads:
        thread.join()
        local_best_time, local_best_idx, this_top1_time, \
            local_best_source, local_best_blocks, local_best_grids = thread.get_result()
        if local_best_time < best_time:
            best_time = local_best_time
            best_idx = local_best_idx
            best_source = local_best_source
            best_block_size = local_best_blocks
            best_grid_size = local_best_grids
        if this_top1_time > -1:
            top1_time = this_top1_time
    
    eval_time = time.time() - start_time

    print("top1 time: {} ms".format(top1_time))
    print("top10 time: {} ms".format(best_time))
    print("best idx: {}".format(best_idx))
    print("best config: {}".format(rprogs[best_idx].Dump()))
    print("top1 compile time: {} s".format(emit_time))
    print("top10 compile time: {} s".format(eval_time))

    with open(os.path.join(prefix, "final.cu"), "w") as f:
        f.write(best_source)
        f.write("dim3 grid{};\n".format(best_grid_size))
        f.write("dim3 block{};\n".format(best_block_size))
        f.write(f"best_idx {best_idx}")

    # print("best_source", best_source)
    print("best_block_size", best_block_size)
    print("best_grid_size", best_grid_size)
    save_to_db(identifier, best_source, best_grid_size, best_block_size)

if __name__ == '__main__':
    cur_dir = os.getcwd()
    with open('roller.id', 'r') as f:
        for line in f:
            identifier, arch = line.strip().split(":::")
            tmp_dir = f"{cur_dir}/roller_kernels/{identifier[:240]}"
            print("tmp_dir", tmp_dir)
            run(identifier, "V100", tmp_dir)
    run("BatchMatMul[64,12,1,64;12,64,64;64,12,1,64floatfloatfloat]", "V100", fix_block_size=128)