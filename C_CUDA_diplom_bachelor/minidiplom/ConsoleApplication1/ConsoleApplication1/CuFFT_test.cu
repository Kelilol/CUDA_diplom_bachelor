#include "Full_header.cuh"
#include <chrono>
using namespace std::chrono;
static double Min = 0, Max = 664000.000000;
extern "C" void CUFFTTEST (uchar4 * bufferIMG, unsigned char* dev_a, int width_A) {
    int DIM = 1024;
    static cufftDoubleComplex *fftarray;
    static unsigned char *dev_Main_Window_picture;
    cudaMalloc((void**)&fftarray, width_A * width_A * sizeof(cufftDoubleComplex));
    cudaMalloc((void**)&dev_Main_Window_picture, width_A * width_A * sizeof(unsigned char) * 1);
    cudaMemcpy(dev_Main_Window_picture, dev_a, width_A * width_A * sizeof(unsigned char) * 1, cudaMemcpyHostToDevice);
    dim3    grids((width_A + 32 - 1) / 32, (width_A + 32 - 1) / 32);
    dim3    threads(32, 32);
    Img_to_cufftComplex << <grids, threads >> > (fftarray, dev_Main_Window_picture, width_A);
    cufftHandle plan;
    int n[2] = { width_A, width_A };
    cufftPlanMany(&plan, 2, n, NULL, 1, 0, NULL, 1, 0, CUFFT_Z2Z, 1);
  /*  cudaEvent_t start, stop;*/
    float gpuTime = 0.0f;
 /*   cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaEventRecord(start, 0);*/
    system_clock::time_point start = system_clock::now();
    cufftExecZ2Z(plan, fftarray, fftarray, CUFFT_FORWARD);
    cudaDeviceSynchronize();
    system_clock::time_point end = system_clock::now();
    //cudaDeviceSynchronize();
   
    // Для миллисекунд
    std::chrono::duration<double, std::milli> duration = end - start;
    printf("cufft %5f millisec\n", duration.count());
    //cudaDeviceSynchronize();
    //cudaEventRecord(stop, 0);
    //cudaEventSynchronize(stop);//конец измерения

    //cudaEventElapsedTime(&gpuTime, start, stop);//вычисление измерения

    //printf("CUfFt : %.5f millisec\n", gpuTime);

    dim3 grids1(DIM / 16, DIM / 16);
    dim3 threads1(16, 16);
    //kernel << <grids1, threads1 >> > (pixels, ticks, texWidth_A, texHeight_A, texWidth_B, texHeight_B, dev_a, dev_b);


    DrawPicABSAfterBPFRange << <grids1, threads1 >> > (bufferIMG, fftarray, width_A, Min, Max);
    cufftDestroy(plan);
    //cudaEventDestroy(start);
    //cudaEventDestroy(stop);
    cudaFree(fftarray);
}