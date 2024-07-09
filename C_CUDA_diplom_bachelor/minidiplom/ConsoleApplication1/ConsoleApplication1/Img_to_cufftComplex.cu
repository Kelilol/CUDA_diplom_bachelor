#include "Full_header.cuh"
__global__ void Img_to_cufftComplex(cufftDoubleComplex* zarray, unsigned char* dev_Main_Window_picture, int width_A)
{
    int x = threadIdx.x + blockIdx.x * blockDim.x;
    int y = threadIdx.y + blockIdx.y * blockDim.y;
    int offset = x + y * blockDim.x * gridDim.x;
    if (offset < width_A * width_A)
    {
        zarray[offset].x = (double)dev_Main_Window_picture[(x + y * width_A) * 1];
        zarray[offset].y = 0.0;
    }
}