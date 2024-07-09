#include "Full_header.cuh"
__global__ void invers_array_kernel(int* dev_invers, int n, int t)
{

    int ii = blockIdx.x * blockDim.x + threadIdx.x;
    if (ii < n) {
        int k = 1;
        int k1 = k << (t - 1);
        int b1 = 0;
        for (int i = 1; i <= t / 2 + 1; i++)
        {
            if ((ii & k) != 0) b1 = b1 | k1;
            if ((ii & k1) != 0) b1 = b1 | k;
            k = k << 1;
            k1 = k1 >> 1;
        }
        dev_invers[ii] = b1;
    }
}