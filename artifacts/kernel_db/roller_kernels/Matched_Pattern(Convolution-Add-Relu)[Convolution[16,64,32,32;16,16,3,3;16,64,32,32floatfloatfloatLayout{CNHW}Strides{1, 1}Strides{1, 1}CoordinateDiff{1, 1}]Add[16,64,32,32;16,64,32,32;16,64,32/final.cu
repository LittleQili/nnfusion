
#ifdef _WIN32
  using uint = unsigned int;
  using uchar = unsigned char;
  using ushort = unsigned short;
  using int64_t = long long;
  using uint64_t = unsigned long long;
#else
  #define uint unsigned int
  #define uchar unsigned char
  #define ushort unsigned short
  #define int64_t long long
  #define uint64_t unsigned long long
#endif
extern "C" __global__ void __launch_bounds__(512) default_function_kernel0(float* __restrict__ data, float* __restrict__ kernel, float* __restrict__ bias, float* __restrict__ conv_unpad) {
  float conv_local[2];
  __shared__ float data_pad_shared[8192];
  __shared__ float kernel_pad_shared[2048];
  float data_pad_shared_local[2];
  float kernel_pad_shared_local[1];
  conv_local[(0)] = 0.000000e+00f;
  conv_local[(1)] = 0.000000e+00f;
  for (int ra_fused0_outer = 0; ra_fused0_outer < 2; ++ra_fused0_outer) {
    __syncthreads();
    data_pad_shared[(((int)threadIdx.x))] = (((((0 < (((((((int)blockIdx.x) * 64) + (((int)threadIdx.x) & 63)) & 1023) >> 5) + ((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) % 9) / 3))) && ((((((((int)blockIdx.x) * 64) + (((int)threadIdx.x) & 63)) & 1023) >> 5) + ((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) % 9) / 3)) < 33)) && (0 < ((((int)threadIdx.x) & 31) + (((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) % 3)))) && (((((int)threadIdx.x) & 31) + (((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) % 3)) < 33)) ? data[((((((((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) / 9) * 65536) + (((int)blockIdx.x) * 64)) + (((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) % 9) / 3) * 32)) + (((int)threadIdx.x) & 63)) + (((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) % 3)) - 33))] : 0.000000e+00f);
    data_pad_shared[((((int)threadIdx.x) + 512))] = (((((0 < (((((((int)blockIdx.x) * 64) + (((int)threadIdx.x) & 63)) & 1023) >> 5) + (((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 8) % 9) / 3))) && ((((((((int)blockIdx.x) * 64) + (((int)threadIdx.x) & 63)) & 1023) >> 5) + (((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 8) % 9) / 3)) < 33)) && (0 < ((((int)threadIdx.x) & 31) + ((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 2) % 3)))) && (((((int)threadIdx.x) & 31) + ((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 2) % 3)) < 33)) ? data[(((((((((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 8) / 9) * 65536) + (((int)blockIdx.x) * 64)) + ((((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 8) % 9) / 3) * 32)) + (((int)threadIdx.x) & 63)) + ((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 2) % 3)) - 33))] : 0.000000e+00f);
    data_pad_shared[((((int)threadIdx.x) + 1024))] = ((((((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) < 128) && (0 < (((((((int)blockIdx.x) * 64) + (((int)threadIdx.x) & 63)) & 1023) >> 5) + (((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 7) % 9) / 3)))) && ((((((((int)blockIdx.x) * 64) + (((int)threadIdx.x) & 63)) & 1023) >> 5) + (((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 7) % 9) / 3)) < 33)) && (0 < ((((int)threadIdx.x) & 31) + ((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 1) % 3)))) && (((((int)threadIdx.x) & 31) + ((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 1) % 3)) < 33)) ? data[(((((((((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 16) / 9) * 65536) + (((int)blockIdx.x) * 64)) + ((((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 7) % 9) / 3) * 32)) + (((int)threadIdx.x) & 63)) + ((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 1) % 3)) - 33))] : 0.000000e+00f);
    data_pad_shared[((((int)threadIdx.x) + 1536))] = ((((((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) < 120) && (0 < (((((((int)blockIdx.x) * 64) + (((int)threadIdx.x) & 63)) & 1023) >> 5) + (((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 6) % 9) / 3)))) && ((((((((int)blockIdx.x) * 64) + (((int)threadIdx.x) & 63)) & 1023) >> 5) + (((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 6) % 9) / 3)) < 33)) && (0 < ((((int)threadIdx.x) & 31) + (((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) % 3)))) && (((((int)threadIdx.x) & 31) + (((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) % 3)) < 33)) ? data[(((((((((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 24) / 9) * 65536) + (((int)blockIdx.x) * 64)) + ((((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 6) % 9) / 3) * 32)) + (((int)threadIdx.x) & 63)) + (((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) % 3)) - 33))] : 0.000000e+00f);
    data_pad_shared[((((int)threadIdx.x) + 2048))] = ((((((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) < 112) && (0 < (((((((int)blockIdx.x) * 64) + (((int)threadIdx.x) & 63)) & 1023) >> 5) + (((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 5) % 9) / 3)))) && ((((((((int)blockIdx.x) * 64) + (((int)threadIdx.x) & 63)) & 1023) >> 5) + (((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 5) % 9) / 3)) < 33)) && (0 < ((((int)threadIdx.x) & 31) + ((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 2) % 3)))) && (((((int)threadIdx.x) & 31) + ((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 2) % 3)) < 33)) ? data[(((((((((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 32) / 9) * 65536) + (((int)blockIdx.x) * 64)) + ((((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 5) % 9) / 3) * 32)) + (((int)threadIdx.x) & 63)) + ((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 2) % 3)) - 33))] : 0.000000e+00f);
    data_pad_shared[((((int)threadIdx.x) + 2560))] = ((((((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) < 104) && (0 < (((((((int)blockIdx.x) * 64) + (((int)threadIdx.x) & 63)) & 1023) >> 5) + (((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 4) % 9) / 3)))) && ((((((((int)blockIdx.x) * 64) + (((int)threadIdx.x) & 63)) & 1023) >> 5) + (((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 4) % 9) / 3)) < 33)) && (0 < ((((int)threadIdx.x) & 31) + ((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 1) % 3)))) && (((((int)threadIdx.x) & 31) + ((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 1) % 3)) < 33)) ? data[(((((((((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 40) / 9) * 65536) + (((int)blockIdx.x) * 64)) + ((((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 4) % 9) / 3) * 32)) + (((int)threadIdx.x) & 63)) + ((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 1) % 3)) - 33))] : 0.000000e+00f);
    data_pad_shared[((((int)threadIdx.x) + 3072))] = ((((((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) < 96) && (0 < (((((((int)blockIdx.x) * 64) + (((int)threadIdx.x) & 63)) & 1023) >> 5) + (((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 3) % 9) / 3)))) && ((((((((int)blockIdx.x) * 64) + (((int)threadIdx.x) & 63)) & 1023) >> 5) + (((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 3) % 9) / 3)) < 33)) && (0 < ((((int)threadIdx.x) & 31) + (((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) % 3)))) && (((((int)threadIdx.x) & 31) + (((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) % 3)) < 33)) ? data[(((((((((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 48) / 9) * 65536) + (((int)blockIdx.x) * 64)) + ((((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 3) % 9) / 3) * 32)) + (((int)threadIdx.x) & 63)) + (((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) % 3)) - 33))] : 0.000000e+00f);
    data_pad_shared[((((int)threadIdx.x) + 3584))] = ((((((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) < 88) && (0 < (((((((int)blockIdx.x) * 64) + (((int)threadIdx.x) & 63)) & 1023) >> 5) + (((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 2) % 9) / 3)))) && ((((((((int)blockIdx.x) * 64) + (((int)threadIdx.x) & 63)) & 1023) >> 5) + (((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 2) % 9) / 3)) < 33)) && (0 < ((((int)threadIdx.x) & 31) + ((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 2) % 3)))) && (((((int)threadIdx.x) & 31) + ((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 2) % 3)) < 33)) ? data[(((((((((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 56) / 9) * 65536) + (((int)blockIdx.x) * 64)) + ((((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 2) % 9) / 3) * 32)) + (((int)threadIdx.x) & 63)) + ((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 2) % 3)) - 33))] : 0.000000e+00f);
    data_pad_shared[((((int)threadIdx.x) + 4096))] = ((((((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) < 80) && (0 < (((((((int)blockIdx.x) * 64) + (((int)threadIdx.x) & 63)) & 1023) >> 5) + (((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 1) % 9) / 3)))) && ((((((((int)blockIdx.x) * 64) + (((int)threadIdx.x) & 63)) & 1023) >> 5) + (((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 1) % 9) / 3)) < 33)) && (0 < ((((int)threadIdx.x) & 31) + ((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 1) % 3)))) && (((((int)threadIdx.x) & 31) + ((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 1) % 3)) < 33)) ? data[(((((((((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 64) / 9) * 65536) + (((int)blockIdx.x) * 64)) + ((((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 1) % 9) / 3) * 32)) + (((int)threadIdx.x) & 63)) + ((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 1) % 3)) - 33))] : 0.000000e+00f);
    data_pad_shared[((((int)threadIdx.x) + 4608))] = ((((((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) < 72) && (0 < (((((((int)blockIdx.x) * 64) + (((int)threadIdx.x) & 63)) & 1023) >> 5) + ((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) % 9) / 3)))) && ((((((((int)blockIdx.x) * 64) + (((int)threadIdx.x) & 63)) & 1023) >> 5) + ((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) % 9) / 3)) < 33)) && (0 < ((((int)threadIdx.x) & 31) + (((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) % 3)))) && (((((int)threadIdx.x) & 31) + (((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) % 3)) < 33)) ? data[((((((((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) / 9) * 65536) + (((int)blockIdx.x) * 64)) + (((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) % 9) / 3) * 32)) + (((int)threadIdx.x) & 63)) + (((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) % 3)) + 524255))] : 0.000000e+00f);
    data_pad_shared[((((int)threadIdx.x) + 5120))] = ((((((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) < 64) && (0 < (((((((int)blockIdx.x) * 64) + (((int)threadIdx.x) & 63)) & 1023) >> 5) + (((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 8) % 9) / 3)))) && ((((((((int)blockIdx.x) * 64) + (((int)threadIdx.x) & 63)) & 1023) >> 5) + (((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 8) % 9) / 3)) < 33)) && (0 < ((((int)threadIdx.x) & 31) + ((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 2) % 3)))) && (((((int)threadIdx.x) & 31) + ((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 2) % 3)) < 33)) ? data[(((((((((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 80) / 9) * 65536) + (((int)blockIdx.x) * 64)) + ((((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 8) % 9) / 3) * 32)) + (((int)threadIdx.x) & 63)) + ((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 2) % 3)) - 33))] : 0.000000e+00f);
    data_pad_shared[((((int)threadIdx.x) + 5632))] = ((((((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) < 56) && (0 < (((((((int)blockIdx.x) * 64) + (((int)threadIdx.x) & 63)) & 1023) >> 5) + (((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 7) % 9) / 3)))) && ((((((((int)blockIdx.x) * 64) + (((int)threadIdx.x) & 63)) & 1023) >> 5) + (((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 7) % 9) / 3)) < 33)) && (0 < ((((int)threadIdx.x) & 31) + ((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 1) % 3)))) && (((((int)threadIdx.x) & 31) + ((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 1) % 3)) < 33)) ? data[(((((((((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 88) / 9) * 65536) + (((int)blockIdx.x) * 64)) + ((((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 7) % 9) / 3) * 32)) + (((int)threadIdx.x) & 63)) + ((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 1) % 3)) - 33))] : 0.000000e+00f);
    data_pad_shared[((((int)threadIdx.x) + 6144))] = ((((((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) < 48) && (0 < (((((((int)blockIdx.x) * 64) + (((int)threadIdx.x) & 63)) & 1023) >> 5) + (((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 6) % 9) / 3)))) && ((((((((int)blockIdx.x) * 64) + (((int)threadIdx.x) & 63)) & 1023) >> 5) + (((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 6) % 9) / 3)) < 33)) && (0 < ((((int)threadIdx.x) & 31) + (((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) % 3)))) && (((((int)threadIdx.x) & 31) + (((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) % 3)) < 33)) ? data[(((((((((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 96) / 9) * 65536) + (((int)blockIdx.x) * 64)) + ((((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 6) % 9) / 3) * 32)) + (((int)threadIdx.x) & 63)) + (((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) % 3)) - 33))] : 0.000000e+00f);
    data_pad_shared[((((int)threadIdx.x) + 6656))] = ((((((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) < 40) && (0 < (((((((int)blockIdx.x) * 64) + (((int)threadIdx.x) & 63)) & 1023) >> 5) + (((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 5) % 9) / 3)))) && ((((((((int)blockIdx.x) * 64) + (((int)threadIdx.x) & 63)) & 1023) >> 5) + (((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 5) % 9) / 3)) < 33)) && (0 < ((((int)threadIdx.x) & 31) + ((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 2) % 3)))) && (((((int)threadIdx.x) & 31) + ((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 2) % 3)) < 33)) ? data[(((((((((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 104) / 9) * 65536) + (((int)blockIdx.x) * 64)) + ((((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 5) % 9) / 3) * 32)) + (((int)threadIdx.x) & 63)) + ((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 2) % 3)) - 33))] : 0.000000e+00f);
    data_pad_shared[((((int)threadIdx.x) + 7168))] = ((((((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) < 32) && (0 < (((((((int)blockIdx.x) * 64) + (((int)threadIdx.x) & 63)) & 1023) >> 5) + (((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 4) % 9) / 3)))) && ((((((((int)blockIdx.x) * 64) + (((int)threadIdx.x) & 63)) & 1023) >> 5) + (((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 4) % 9) / 3)) < 33)) && (0 < ((((int)threadIdx.x) & 31) + ((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 1) % 3)))) && (((((int)threadIdx.x) & 31) + ((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 1) % 3)) < 33)) ? data[(((((((((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 112) / 9) * 65536) + (((int)blockIdx.x) * 64)) + ((((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 4) % 9) / 3) * 32)) + (((int)threadIdx.x) & 63)) + ((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 1) % 3)) - 33))] : 0.000000e+00f);
    data_pad_shared[((((int)threadIdx.x) + 7680))] = ((((((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) < 24) && (0 < (((((((int)blockIdx.x) * 64) + (((int)threadIdx.x) & 63)) & 1023) >> 5) + (((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 3) % 9) / 3)))) && ((((((((int)blockIdx.x) * 64) + (((int)threadIdx.x) & 63)) & 1023) >> 5) + (((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 3) % 9) / 3)) < 33)) && (0 < ((((int)threadIdx.x) & 31) + (((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) % 3)))) && (((((int)threadIdx.x) & 31) + (((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) % 3)) < 33)) ? data[(((((((((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 120) / 9) * 65536) + (((int)blockIdx.x) * 64)) + ((((((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) + 3) % 9) / 3) * 32)) + (((int)threadIdx.x) & 63)) + (((ra_fused0_outer * 128) + (((int)threadIdx.x) >> 6)) % 3)) - 33))] : 0.000000e+00f);
    kernel_pad_shared[(((int)threadIdx.x))] = ((((ra_fused0_outer * 128) + (((int)threadIdx.x) & 127)) < 144) ? kernel[(((((((int)threadIdx.x) >> 7) * 144) + (ra_fused0_outer * 128)) + (((int)threadIdx.x) & 127)))] : 0.000000e+00f);
    kernel_pad_shared[((((int)threadIdx.x) + 512))] = ((((ra_fused0_outer * 128) + (((int)threadIdx.x) & 127)) < 144) ? kernel[((((((((int)threadIdx.x) >> 7) * 144) + (ra_fused0_outer * 128)) + (((int)threadIdx.x) & 127)) + 576))] : 0.000000e+00f);
    kernel_pad_shared[((((int)threadIdx.x) + 1024))] = ((((ra_fused0_outer * 128) + (((int)threadIdx.x) & 127)) < 144) ? kernel[((((((((int)threadIdx.x) >> 7) * 144) + (ra_fused0_outer * 128)) + (((int)threadIdx.x) & 127)) + 1152))] : 0.000000e+00f);
    kernel_pad_shared[((((int)threadIdx.x) + 1536))] = ((((ra_fused0_outer * 128) + (((int)threadIdx.x) & 127)) < 144) ? kernel[((((((((int)threadIdx.x) >> 7) * 144) + (ra_fused0_outer * 128)) + (((int)threadIdx.x) & 127)) + 1728))] : 0.000000e+00f);
    __syncthreads();
    for (int ra_fused0_inner_outer = 0; ra_fused0_inner_outer < 128; ++ra_fused0_inner_outer) {
      data_pad_shared_local[(0)] = data_pad_shared[(((ra_fused0_inner_outer * 64) + (((int)threadIdx.x) & 31)))];
      data_pad_shared_local[(1)] = data_pad_shared[((((ra_fused0_inner_outer * 64) + (((int)threadIdx.x) & 31)) + 32))];
      kernel_pad_shared_local[(0)] = kernel_pad_shared[((((((int)threadIdx.x) >> 5) * 128) + ra_fused0_inner_outer))];
      if (((ra_fused0_outer * 128) + ra_fused0_inner_outer) < 144) {
        conv_local[(0)] = (conv_local[(0)] + (data_pad_shared_local[(0)] * kernel_pad_shared_local[(0)]));
        conv_local[(1)] = (conv_local[(1)] + (data_pad_shared_local[(1)] * kernel_pad_shared_local[(0)]));
      }
    }
  }
  conv_unpad[(((((((int)threadIdx.x) >> 5) * 65536) + (((int)blockIdx.x) * 64)) + (((int)threadIdx.x) & 31)))] = max((conv_local[(0)] + bias[((((int)threadIdx.x) >> 5))]), 0.000000e+00f);
  conv_unpad[((((((((int)threadIdx.x) >> 5) * 65536) + (((int)blockIdx.x) * 64)) + (((int)threadIdx.x) & 31)) + 32))] = max((conv_local[(1)] + bias[((((int)threadIdx.x) >> 5))]), 0.000000e+00f);
}

dim3 grid(1024, 1, 1);
dim3 block(512, 1, 1);