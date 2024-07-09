#include "Full_header.cuh"
__global__ void invers_zarray_collum(cufftDoubleComplex* zarray, cufftDoubleComplex* zarray_buf, int* dev_invers, int width)
{
    int x = threadIdx.x + blockIdx.x * blockDim.x;
    int y = threadIdx.y + blockIdx.y * blockDim.y;
    //uint32_t i = threadIdx.x + blockIdx.x * blockDim.x;
    //uint32_t rev = reverse_bits_gpu(i * 2);
    //rev = rev >> (32 - 12);
    //uint32_t rev1 = reverse_bits_gpu(i * 2 + 1);
    //rev1 = rev1 >> (32 - 12);
    //cufftDoubleComplex ip, ip2;
    if ((x < width) && (y < width))
    {

        //ip = zarray[x + y * width];
        //ip2= zarray[dev_invers[x] + y * width];
        //zarray[dev_invers[x] + y * width] = ip;
        zarray_buf[x + y * width] = zarray[x + dev_invers[y] * width];
        if (x < width / 2) {
            //                       if (dev_invers[x * 2] != rev || dev_invers[x * 2 + 1] != rev1)
            //                       {
            ///*                           printf("x= %d dev_invers[x]= %d  %d\n", x * 2, dev_invers[x * 2], rev);
            //                           printf("x= %d dev_invers[x]= %d  %d\n", x * 2 + 1, dev_invers[x * 2 + 1], rev1);*/
            //                       }
        }
    }
}