#include "Full_header.cuh"
#include <stdio.h>
#include <math.h>
#include <chrono>
using namespace std::chrono;
#define DIM 1024
static unsigned char* dev_Main_Window_picture;
cufftDoubleComplex* fftarray;
static double Min = 0, Max = 664000.000000;

__global__ void drawloadbuff(uchar4* bufferIMG,int width_A)
{
    int x = threadIdx.x + blockIdx.x * blockDim.x;
    int y = threadIdx.y + blockIdx.y * blockDim.y;
    int offset = x + y * blockDim.x * gridDim.x;
    if (offset < DIM * DIM)
    {


        bufferIMG[DIM * DIM - 1 - offset].x = 70;
        bufferIMG[DIM * DIM - 1 - offset].y = 255;
        bufferIMG[DIM * DIM - 1 - offset].z = 255;
        bufferIMG[DIM * DIM - 1 - offset].w = 255;
    }
}
__global__ void cudaAddd(int a, int b, int* c) {
    *c = a + b;
}
extern "C" void cudaAdd(uchar4 * bufferIMG, int width_A) {
    int* k;
    cudaMalloc((void**)&k, 100);
    
    dim3    grids1((width_A) / 16, (width_A) / 16);
    dim3    threads1(16, 16);
    drawloadbuff << <grids1, threads1 >> > (bufferIMG, width_A);

    cudaFree (k);

  
}
__global__ void drawloadbufff(uchar4* bufferIMG, int width_A)
{
    
    int x = threadIdx.x + blockIdx.x * blockDim.x;
    int y = threadIdx.y + blockIdx.y * blockDim.y;
    int offset = x + y * blockDim.x * gridDim.x;
    if (offset < DIM * DIM)
    {


        bufferIMG[DIM * DIM - 1 - offset].x = 0;
        bufferIMG[DIM * DIM - 1 - offset].y = 0;
        bufferIMG[DIM * DIM - 1 - offset].z = 255;
        bufferIMG[DIM * DIM - 1 - offset].w = 255;
    }
}

extern "C" void cudaAdd1(uchar4 * bufferIMG, int width_A) {
    int* s;
    cudaMalloc((void**)&s, 1000);


    dim3    grids1((width_A) / 16, (width_A) / 16);
    dim3    threads1(16, 16);
    drawloadbufff << <grids1, threads1 >> > (bufferIMG, width_A);



    cudaFree(s);


}
__global__ void Draw(uchar4* bufferIMG, unsigned char* zarray, int width_A)
{
    int l = width_A / (DIM);
    int x = threadIdx.x + blockIdx.x * blockDim.x;
    int y = threadIdx.y + blockIdx.y * blockDim.y;
    int x1 = (DIM - x-1) * l;
    int y1 = y * l;
    int offset1 = x1 + y1 * width_A;
    int offset = x + y * blockDim.x * gridDim.x;
    int MAG = 0;
    if (offset < DIM * DIM)
    {
        for (int i = 0; i < l; i++)
        {
            for (int j = 0; j < l; j++)
            {
                MAG += zarray[x1 + j + (y1 + i) * width_A];
            }
        }
        MAG = MAG / (l * l);
        unsigned char mag;
        if (MAG > 255)
        {
            mag = 255;
        }else mag = (unsigned char)MAG;
        bufferIMG[1048575- offset].x = mag;
        bufferIMG[1048575 - offset].y = mag;
        bufferIMG[1048575 - offset].z = mag;
        bufferIMG[1048575 - offset].w = 255;
    }
}

extern "C" void drawloadimg (uchar4* bufferIMG, unsigned char* zarray, int width_A) {
    cudaError_t cudaStatus;
    unsigned char* dev_Main_Window_picture1;
    printf("s ");
    cudaMalloc((void**)&dev_Main_Window_picture1, width_A * width_A * sizeof(unsigned char) * 1);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMalloc failed!");
        //goto Error1;

    }
    cudaMemcpy(dev_Main_Window_picture1, zarray, width_A * width_A * sizeof(unsigned char) * 1, cudaMemcpyHostToDevice);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMalloc failed!");
        // goto Error1;
    }
    int powerthreadMax = log2(1024);
    int girdthreadmax = pow(2.0, powerthreadMax / 2);
    int powertexWidth = log2(4096);
    int girdtexWidth = pow(2.0, powertexWidth / 2);
    int thread;
    if (girdthreadmax < girdtexWidth)
    {
        thread = girdthreadmax;
    }
    else
    {
        thread = girdtexWidth;
    }
    dim3    grids((1024 + thread - 1) / thread, (1024 + thread - 1) / thread);
    dim3    threads(thread, thread);


 
    Draw << <grids, threads >> > (bufferIMG, dev_Main_Window_picture1, width_A);
    cudaFree(dev_Main_Window_picture1);
}





//__device__ uint32_t reverse_bits_gpu(uint32_t x)
//{
//    x = ((x & 0xaaaaaaaa) >> 1) | ((x & 0x55555555) << 1);
//    x = ((x & 0xcccccccc) >> 2) | ((x & 0x33333333) << 2);
//    x = ((x & 0xf0f0f0f0) >> 4) | ((x & 0x0f0f0f0f) << 4);
//    x = ((x & 0xff00ff00) >> 8) | ((x & 0x00ff00ff) << 8);
//    return (x >> 16) | (x << 16);
//}






__global__ void DrawPicABSAfterBPFRange(uchar4* bufferIMG, cufftDoubleComplex* zarray, int width_A, double min, double max)
{
    int l = width_A / (DIM);
    int x = threadIdx.x + blockIdx.x * blockDim.x;
    int y = threadIdx.y + blockIdx.y * blockDim.y;
    int x1 = (DIM - x-1) * l;
    int y1 = y * l;
    int offset1 = x1 + y1 * width_A;
    int offset = x + y * blockDim.x * gridDim.x;
    double MAG = 0;
    if (offset < DIM * DIM)
    {
        for (int i = 0; i < l; i++)
        {
            for (int j = 0; j < l; j++)
            {
                MAG += cuCabs(zarray[x1 + j + (y1 + i) * width_A]);
            }
        }
        MAG = MAG / (l * l);
        unsigned char mag = 0;
        if (MAG > max) { mag = 255; }
        else {
            mag = (MAG - min) / (max - min) * 255;
        }
        bufferIMG[DIM * DIM - 1 - offset].x = mag;
        bufferIMG[DIM * DIM - 1 - offset].y = mag;
        bufferIMG[DIM * DIM - 1 - offset].z = mag;
        bufferIMG[DIM * DIM - 1 - offset].w = mag;

    }
}
__global__ void Draw(unsigned char* bufferIMG, unsigned char* zarray, int width_A)
{
    int l = width_A / (DIM);
    int x = threadIdx.x + blockIdx.x * blockDim.x;
    int y = threadIdx.y + blockIdx.y * blockDim.y;
    int x1 = (DIM - x) * l;
    int y1 = y * l;
    int offset1 = x1 + y1 * width_A;
    int offset = x + y * blockDim.x * gridDim.x;
    int MAG = 0;
    if (offset < DIM * DIM)
    {
        for (int i = 0; i < l; i++)
        {
            for (int j = 0; j < l; j++)
            {
                MAG += zarray[x1 + j + (y1 + i) * width_A];
            }
        }
        MAG = MAG / (l * l);
        unsigned char mag = (unsigned char)MAG;
        bufferIMG[DIM * DIM - 1 - offset] = mag;
    }
}
__global__ void drawloadbuff(uchar4* bufferIMG, unsigned char* zarray, int width_A)
{
    int x = threadIdx.x + blockIdx.x * blockDim.x;
    int y = threadIdx.y + blockIdx.y * blockDim.y;
    int offset = x + y * blockDim.x * gridDim.x;
    if (offset < DIM * DIM)
    {


        bufferIMG[DIM * DIM - 1 - offset].x = zarray[offset];
        bufferIMG[DIM * DIM - 1 - offset].y = zarray[offset];
        bufferIMG[DIM * DIM - 1 - offset].z = zarray[offset];
        bufferIMG[DIM * DIM - 1 - offset].w = 255;
    }
}
int T(int l)                                     // Определение степени l = 2**t
{
    int m = 1;
    int nn = 2;
    for (int i = 1; ; i++) { nn = nn * 2; if (nn > l) { m = i; break; } }
    return m;
}
void MYBPF(uchar4* bufferIMG,  int texWidth_Gal) {
    system_clock::time_point start = system_clock::now();
    double invers= 1.0;
    if (invers == 1.0)
    {
        invers = -1.0;
    }
    // else invers=1.0;
    cufftDoubleComplex* d_data_buf;
    cudaMalloc((void**)&d_data_buf, texWidth_Gal * texWidth_Gal * sizeof(cufftDoubleComplex));
    cudaDeviceSynchronize();

    int N = texWidth_Gal;
    int t = T(N);

    int* dev_Invers;
    cudaMalloc((void**)&dev_Invers, N * sizeof(int));
    cudaDeviceSynchronize();
    int size = 1024;
    if (size > texWidth_Gal)
    {
        size = texWidth_Gal;

    }
    dim3    grids3((N) / size, 1);
    dim3    threads3(size, 1);
    invers_array_kernel << <grids3, threads3 >> > (dev_Invers, N, t);

    cudaDeviceSynchronize();

    dim3    grids1((N) / 16, (N) / 16);
    dim3    threads1(16, 16);
    invers_zarray_str << < grids1, threads1 >> > (fftarray, d_data_buf, dev_Invers, N);
    cudaDeviceSynchronize();
    dim3    grids2(N / N, (N) / 16);
    dim3    threads2(1, 16);
    //dim3 grids2= ((N) / 16, (N) / 16);
    int blockSize = 16;
    int numBlocks = (N + blockSize - 1) / blockSize;
    int numstreams = 1;
    cudaStream_t streams[32];
    for (int i = 0; i < numstreams; ++i) {
        cudaStreamCreate(&streams[i]);
    }
    for (int i = 0; i < numstreams; i++)
    {
        BPFur_str << <(numBlocks / numstreams), blockSize, 0, streams[i] >> > ((d_data_buf + (i * N * blockSize * numBlocks / numstreams)), N, t, invers);
        cudaDeviceSynchronize();
    }
    // Синхронизация каждого потока
    for (int i = 0; i < numstreams; ++i) {
        cudaStreamSynchronize(streams[i]);
    }
    invers_zarray_collum << < grids1, threads1 >> > (d_data_buf, fftarray, dev_Invers, N);
    for (int i = 0; i < 1; i++)
    {
        BPFur_collum << <numBlocks /*/ numstreams*/, blockSize/*, 0, streams[i]*/ >> > (fftarray/* + (i * N * blockSize * numBlocks / numstreams))*/, N, t, invers);
        cudaDeviceSynchronize();
    }
    //  Синхронизация каждого потока
    for (int i = 0; i < numstreams; ++i) {
        cudaStreamSynchronize(streams[i]);
    }
    // Уничтожение каждого потока
    for (int i = 0; i < numstreams; ++i) {
        cudaStreamDestroy(streams[i]);
    }
    system_clock::time_point end = system_clock::now();
    cudaFree(d_data_buf);
    cudaFree(dev_Invers);
    std::chrono::duration<double, std::milli> duration = end - start;
    printf("cufft %5f millisec\n", duration.count());
}

extern "C" void Test_My_BPF(uchar4* bufferIMG, unsigned char* dev_a, int width_A)
{
    //unsigned char* dev_Main_Window_picture;
    //unsigned char* fftarray;
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    float milliseconds_1 = 0, milliseconds_2 = 0, milliseconds_3 = 0, milliseconds_4 = 0;

    cudaEventRecord(start);
    cudaError_t cudaStatus;
    static int k = 0;
    static char filepath[256];
  
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&milliseconds_1, start, stop);
    printf("\n/////////\nload img to aplication : %.5f millisec\n", milliseconds_1);

   
    cudaEventRecord(start);
    cudaStatus = cudaMalloc((void**)&dev_Main_Window_picture, width_A * width_A * sizeof(unsigned char) * 1);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMalloc failed!");
        //goto Error1;

    }
    cudaStatus = cudaMemcpy(dev_Main_Window_picture, dev_a, width_A * width_A * sizeof(unsigned char) * 1, cudaMemcpyHostToDevice);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMalloc failed!");
        // goto Error1;
    }
    cudaStatus = cudaMalloc((void**)&fftarray, width_A * width_A * sizeof(cufftDoubleComplex));
    if (cudaStatus != cudaSuccess) {
        //goto Error;
        // MessageBox(NULL, "zarray : cudaMalloc failed!", "CudaError", NULL);
      //  goto Error1;
    }
    int thread = 0;
    if (width_A < 1024)
    {
        thread = width_A;
    }
    else
    {
        thread = 1024;
    }

    dim3    grids((width_A + 32 - 1) / 32, (width_A + 32 - 1) / 32);
    dim3    threads(32, 32);

    /*Img_to_Complex << <grids, threads >> > (zarray, dev_Main_Window_picture, texWidth);*/
    Img_to_cufftComplex << <grids, threads >> > (fftarray, dev_Main_Window_picture, width_A);
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&milliseconds_2, start, stop);
    printf("create\load to complex : %.5f millisec\n", milliseconds_2);

    //cudaEventRecord(start);
    MYBPF(bufferIMG, width_A);

    //cudaEventRecord(stop);
    //cudaEventSynchronize(stop);
    //cudaEventElapsedTime(&milliseconds_3, start, stop);
    //printf("BPF : %.5f millisec\n", milliseconds_3);

    cudaEventRecord(start);
    /*   stbi_image_free(pixels_Gal);*/
    dim3 grids1(DIM / 16, DIM / 16);
    dim3 threads1(16, 16);
    //kernel << <grids1, threads1 >> > (pixels, ticks, texWidth_A, texHeight_A, texWidth_B, texHeight_B, dev_a, dev_b);
  
    
    DrawPicABSAfterBPFRange << <grids1, threads1 >> > (bufferIMG, fftarray, width_A, Min, Max);
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&milliseconds_4, start, stop);
    printf("Pan/crop/scaling : %.5f millisec\n", milliseconds_4);
    printf("full time without draw : %.5f millisec\n", milliseconds_4 + milliseconds_3 + milliseconds_2 + milliseconds_1);
    //Error1:
   // stbi_image_free(dev_a);
    cudaFree(fftarray);
    cudaFree(dev_Main_Window_picture);

}



