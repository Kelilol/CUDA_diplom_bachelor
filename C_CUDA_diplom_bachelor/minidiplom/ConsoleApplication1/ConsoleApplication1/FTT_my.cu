#include "Full_header.cuh"
#include <chrono>
using namespace std::chrono;
#define DIM 1024
static unsigned char* dev_Main_Window_picture;
static cufftDoubleComplex* fftarr;
static double Min = 0, Max = 664000.000000;
int T1(int l)                                     // Определение степени l = 2**t
{
    int m = 1;
    int nn = 2;
    for (int i = 1; ; i++) { nn = nn * 2; if (nn > l) { m = i; break; } }
    return m;
}
void MY_BPF( int texWidth_Gal) {
    system_clock::time_point start = system_clock::now();
    double invers = 1.0;
    if (invers == 1.0)
    {
        invers = -1.0;
    }
    // else invers=1.0;
    cufftDoubleComplex* d_data_buf;
    cudaMalloc((void**)&d_data_buf, texWidth_Gal * texWidth_Gal * sizeof(cufftDoubleComplex));
    cudaDeviceSynchronize();

    int N = texWidth_Gal;
    int t = T1(N);

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
    invers_zarray_str << < grids1, threads1 >> > (fftarr, d_data_buf, dev_Invers, N);
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
        BPFur_str << <(numBlocks / numstreams), blockSize, 0, streams[i] >> > (
            (d_data_buf + (i * N * blockSize * numBlocks / numstreams)), N, t, invers);
        cudaDeviceSynchronize();
    }
    // Синхронизация каждого потока
    for (int i = 0; i < numstreams; ++i) {
        cudaStreamSynchronize(streams[i]);
    }
    invers_zarray_collum << < grids1, threads1 >> > (d_data_buf, fftarr, dev_Invers, N);
    for (int i = 0; i < 1; i++)
    {
        BPFur_collum << <numBlocks /*/ numstreams*/, blockSize/*, 0, streams[i]*/ >> > (fftarr/* + (i * N * blockSize * numBlocks / numstreams))*/, N, t, invers);
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

extern "C" void FFT_MY(cufftDoubleComplex * FFT, unsigned char* dev_a, int width_A)
{
    fftarr = FFT;
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
    Img_to_cufftComplex << <grids, threads >> > (fftarr, dev_Main_Window_picture, width_A);
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&milliseconds_2, start, stop);
    printf("create\load to complex : %.5f millisec\n", milliseconds_2);

    //cudaEventRecord(start);
    MY_BPF(width_A);

    //cudaEventRecord(stop);
    //cudaEventSynchronize(stop);
    //cudaEventElapsedTime(&milliseconds_3, start, stop);
    //printf("BPF : %.5f millisec\n", milliseconds_3);

    //cudaEventRecord(start);
    ///*   stbi_image_free(pixels_Gal);*/
    //dim3 grids1(DIM / 16, DIM / 16);
    //dim3 threads1(16, 16);
    ////kernel << <grids1, threads1 >> > (pixels, ticks, texWidth_A, texHeight_A, texWidth_B, texHeight_B, dev_a, dev_b);


    //DrawPicABSAfterBPFRange << <grids1, threads1 >> > (bufferIMG, fftarray, width_A, Min, Max);
    //cudaEventRecord(stop);
    //cudaEventSynchronize(stop);
    //cudaEventElapsedTime(&milliseconds_4, start, stop);
    //printf("Pan/crop/scaling : %.5f millisec\n", milliseconds_4);
    //printf("full time without draw : %.5f millisec\n", milliseconds_4 + milliseconds_3 + milliseconds_2 + milliseconds_1);
    //Error1:
   // stbi_image_free(dev_a);
    //cudaFree(fftarr);
    cudaFree(dev_Main_Window_picture);

}