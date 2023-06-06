#include "nnfusion_rt.h"
#include <cuda_profiler_api.h>
#include <limits>
#include <stdexcept>
#include <fstream>
#include <sstream>
#include <stdio.h>
#include <stdlib.h>
#define CUDA_SAFE_CALL(x)                                                                          \
    do                                                                                             \
    {                                                                                              \
        cudaError_t result = (x);                                                                  \
        if (result != cudaSuccess)                                                                 \
        {                                                                                          \
            const char* msg = cudaGetErrorString(result);                                          \
            std::stringstream safe_call_ss;                                                        \
            safe_call_ss << "\nerror: " #x " failed with error"                                    \
                         << "\nfile: " << __FILE__ << "\nline: " << __LINE__ << "\nmsg: " << msg;  \
            throw std::runtime_error(safe_call_ss.str());                                          \
        }                                                                                          \
    } while (0)

int main(int argc, char *argv[]){

    cuda_init();

    //input argument
    float* Parameter_0_0_host, *Parameter_0_0;
    CUDA_SAFE_CALL(cudaMallocHost((void**)&Parameter_0_0_host, sizeof(float)* 3145728));
    CUDA_SAFE_CALL(cudaMalloc((void**)&Parameter_0_0, sizeof(float) * 3145728));
    //input argument
    float* Parameter_1_0_host, *Parameter_1_0;
    CUDA_SAFE_CALL(cudaMallocHost((void**)&Parameter_1_0_host, sizeof(float)* 3145728));
    CUDA_SAFE_CALL(cudaMalloc((void**)&Parameter_1_0, sizeof(float) * 3145728));

    //output arguments
    int64_t* Result_12_0_host, *Result_12_0;
    CUDA_SAFE_CALL(cudaMallocHost((void**)&Result_12_0_host, sizeof(int64_t) * 1));
    CUDA_SAFE_CALL(cudaMalloc((void**)&Result_12_0, sizeof(int64_t) * 1));
    float* Result_13_0_host, *Result_13_0;
    CUDA_SAFE_CALL(cudaMallocHost((void**)&Result_13_0_host, sizeof(float) * 3145728));
    CUDA_SAFE_CALL(cudaMalloc((void**)&Result_13_0, sizeof(float) * 3145728));
    float* Result_14_0_host, *Result_14_0;
    CUDA_SAFE_CALL(cudaMallocHost((void**)&Result_14_0_host, sizeof(float) * 3145728));
    CUDA_SAFE_CALL(cudaMalloc((void**)&Result_14_0, sizeof(float) * 3145728));

    // fill input values
    for (int i = 0; i < 3145728; ++i) Parameter_0_0_host[i] = 1.0f;
    for (int i = 0; i < 3145728; ++i) Parameter_1_0_host[i] = 1.0f;


    //warm up for 5 iters:
    for(int i_=0; i_< 100; i_++)
    {
        CUDA_SAFE_CALL(cudaMemcpy(Parameter_0_0, Parameter_0_0_host, sizeof(float) * 3145728, cudaMemcpyHostToDevice));
        CUDA_SAFE_CALL(cudaMemcpy(Parameter_1_0, Parameter_1_0_host, sizeof(float) * 3145728, cudaMemcpyHostToDevice));
        kernel_entry(Parameter_0_0, Parameter_1_0, Result_12_0, Result_13_0, Result_14_0);
        CUDA_SAFE_CALL(cudaMemcpy(Result_12_0_host, Result_12_0,  sizeof(int64_t) * 1, cudaMemcpyDeviceToHost));
        CUDA_SAFE_CALL(cudaMemcpy(Result_13_0_host, Result_13_0,  sizeof(float) * 3145728, cudaMemcpyDeviceToHost));
        CUDA_SAFE_CALL(cudaMemcpy(Result_14_0_host, Result_14_0,  sizeof(float) * 3145728, cudaMemcpyDeviceToHost));
        CUDA_SAFE_CALL(cudaDeviceSynchronize());
        printf("%s \n", "Result_12_0:");
        for (int i = 0; i < 1; ++i) printf("%e ", (float)Result_12_0_host[i]); 
        printf(" .. (size = 1, ends with %e);\n", (float)Result_12_0_host[0]);
        printf("%s \n", "Result_13_0:");
        for (int i = 0; i < 10; ++i) printf("%e ", (float)Result_13_0_host[i]); 
        printf(" .. (size = 3145728, ends with %e);\n", (float)Result_13_0_host[3145727]);
        printf("%s \n", "Result_14_0:");
        for (int i = 0; i < 10; ++i) printf("%e ", (float)Result_14_0_host[i]); 
        printf(" .. (size = 3145728, ends with %e);\n", (float)Result_14_0_host[3145727]);
    }

    //GPU time measurement
    float ms_max = std::numeric_limits<float>::min();
    float ms_min = std::numeric_limits<float>::max();
    float ms_total, ms_i;
    cudaEvent_t start_i, stop_i;
    cudaEventCreate(&start_i);
    cudaEventCreate(&stop_i);

    //time measurement
    ms_total = 0;

    //kernel call
    int steps = 100;
    cudaProfilerStart();
    for (int i_=0; i_<steps; i_++)
    {
        CUDA_SAFE_CALL(cudaMemcpy(Parameter_0_0, Parameter_0_0_host, sizeof(float) * 3145728, cudaMemcpyHostToDevice));
        CUDA_SAFE_CALL(cudaMemcpy(Parameter_1_0, Parameter_1_0_host, sizeof(float) * 3145728, cudaMemcpyHostToDevice));
        cudaEventRecord(start_i, 0);
        kernel_entry(Parameter_0_0, Parameter_1_0, Result_12_0, Result_13_0, Result_14_0);
        cudaEventRecord(stop_i, 0);
        cudaEventSynchronize(stop_i);
        cudaEventElapsedTime(&ms_i, start_i, stop_i);
        printf("Iteration time %f ms\n", ms_i);
        ms_total += ms_i;
        if (ms_i > ms_max)  ms_max = ms_i;
        if (ms_i < ms_min) ms_min = ms_i;
    }
    cudaProfilerStop();

    //time measurement
    printf("Summary: [min, max, mean] = [%f, %f, %f] ms\n",  ms_min, ms_max, ms_total / steps);

    //free context
    CUDA_SAFE_CALL(cudaFree(Parameter_0_0));
    CUDA_SAFE_CALL(cudaFree(Parameter_1_0));
    CUDA_SAFE_CALL(cudaFree(Result_12_0));
    CUDA_SAFE_CALL(cudaFree(Result_13_0));
    CUDA_SAFE_CALL(cudaFree(Result_14_0));
    cuda_free();

    cudaFreeHost(Parameter_0_0_host);
    cudaFreeHost(Parameter_1_0_host);
    cudaFreeHost(Result_12_0_host);
    cudaFreeHost(Result_13_0_host);
    cudaFreeHost(Result_14_0_host);
    return 0;
}
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
