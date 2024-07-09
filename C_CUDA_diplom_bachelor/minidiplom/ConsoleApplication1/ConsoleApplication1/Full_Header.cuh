
#include <cuda_runtime.h>
#include <cufft.h>
#include <iostream>
extern "C" void cudaAdd(uchar4 * bufferIMG, int width_A);
extern "C" void cudaAdd1(uchar4 * bufferIMG, int width_A);
extern "C" void drawloadimg(uchar4 * bufferIMG, unsigned char* zarray, int width_A);
extern "C" void Test_My_BPF(uchar4 * bufferIMG, unsigned char* dev_a, int width_A);
extern "C" void CUFFTTEST(uchar4 * bufferIMG, unsigned char* dev_a, int width_A);
extern "C" void FFT_MY(cufftDoubleComplex * FFT, unsigned char* dev_a, int width_A);
extern "C" void Range(cufftDoubleComplex * zarrayPhur, int width, uchar4 * bufferIMG, double min, double max);
extern "C" void Shift(cufftDoubleComplex * zarrayPhur, int width);
__global__ void Img_to_cufftComplex(cufftDoubleComplex * zarray, unsigned char* dev_Main_Window_picture, int width_A);
__global__ void DrawPicABSAfterBPFRange(uchar4 * bufferIMG, cufftDoubleComplex * zarray, int width_A, double min, double max);
__global__ void Draw(unsigned char* bufferIMG, unsigned char* zarray, int width_A);
__global__ void drawloadbuff(uchar4* bufferIMG, unsigned char* zarray, int width_A);
__global__ void cudaAddd(int a, int b, int* c);
__global__ void Img_to_cufftComplex(cufftDoubleComplex* zarray, unsigned char* dev_Main_Window_picture, int width_A);
__global__ void invers_array_kernel(int* dev_invers, int n, int t);
__global__ void invers_zarray_str(cufftDoubleComplex* zarray, cufftDoubleComplex* zarray_buf, int* dev_invers, int width);
__global__ void invers_zarray_collum(cufftDoubleComplex* zarray, cufftDoubleComplex* zarray_buf, int* dev_invers, int width);
__global__ void BPFur_str(cufftDoubleComplex* zarrayPhur, int width, int powerOfTwo, double invers);
__global__ void BPFur_collum(cufftDoubleComplex* zarrayPhur, int width, int powerOfTwo, double invers);
__global__ void Re(uchar4* bufferIMG, cufftDoubleComplex* zarray, int width_A, double min, double max);
__global__ void Im(uchar4* bufferIMG, cufftDoubleComplex* zarray, int width_A, double min, double max);
__global__ void Phase(uchar4* bufferIMG, cufftDoubleComplex* zarray, int width_A, double min, double max);
__global__ void DrawPicABSAfterBPFRange(uchar4* bufferIMG, cufftDoubleComplex* zarray, int width_A, double min, double max);
__global__ void Draw(unsigned char* bufferIMG, unsigned char* zarray, int width_A);
__global__ void drawloadbuff(uchar4* bufferIMG, unsigned char* zarray, int width_A);
__global__ void shift(cufftDoubleComplex* zarrayPhur, int width);
