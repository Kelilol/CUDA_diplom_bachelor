#include "Full_header.cuh"
__global__ void BPFur_collum(cufftDoubleComplex* zarrayPhur, int width, int powerOfTwo, double invers)
{
    int i;
    int  j, ip, l;

    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    int power_SH = powerOfTwo;
    int width_SH = width;


    //int offset = ((idx)*width_SH);

    if (idx < width_SH) {
        cufftDoubleComplex w, u, t;


        for (l = 1; l <= power_SH; l++)//l значение равное k означающее номер итерации
        {

            int ll = 1 << l/*2^k */, ll1 = ll >> 1;//(k-1) сокращается двойка возле pi в формуле
            u.x = (1.0);
            u.y = (0.0);
            int mh = 1 << (l - 1);

            w = make_cuDoubleComplex(cos(3.1415926535897932384626433832795 / mh), invers * sin(3.1415926535897932384626433832795 / mh));//выводр нужно экспоненты по значению итерации l=k



            for (j = 1; j <= ll1; j++)//j <= 2^(k-1)
            {
                for (i = j - 1; i < width_SH; i = i + ll)
                {

                    ip = (ll1 + i) * 4096 + idx;

                    t = cuCmul(zarrayPhur[ip], u);
                    zarrayPhur[ip] = cuCsub(zarrayPhur[(i * 4096) + idx], t);
                    zarrayPhur[(i) * 4096 + idx] = cuCadd(zarrayPhur[(i) * 4096 + idx], t);

                }

                u = cuCmul(u, w); //стпень экспоенты с кружочком p

            }

        }
    }

}