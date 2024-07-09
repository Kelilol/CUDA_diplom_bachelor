#include <glew.h>
#include <gl/gl.h>
#include <GLFW/glfw3.h>
#include "imgui.h"
#include "imgui_impl_glfw.h"
#include "imgui_impl_opengl3.h"
#include "Full_Header.cuh"
#include <cuda_gl_interop.h>

#include <iostream>
#include <string>
#include <sstream>
#pragma comment(lib, "opengl32.lib")
#define STB_IMAGE_IMPLEMENTATION
#include "stb-master/stb_image.h"
#include <Windows.h>
#include <chrono>
using namespace std::chrono;
//extern "C" void CUFFTTEST(uchar4 * bufferIMG, unsigned char* dev_a, int width_A);
int drawBufferObj = 0;
// Переменные для хранения введенных строк
std::string minStr = "0.0";
std::string maxStr = "0.0";
// Массивы char для ввода текста
char minInput[64] = "0.0";
char maxInput[64] = "0.0";
double minVal = 0.0;
double maxVal = 0.0;
cudaGraphicsResource* resource;
GLuint bufferObj;
CHAR szFile[MAX_PATH];
int texWidth_Gal, texHeight_Gal, texChannels_Gal;
unsigned char* pixels_Gal;
cufftDoubleComplex
* fftmass;
void framebuffer_size_callback(GLFWwindow* window, int width, int height) {
    glViewport(0, 0, width, height);
}
void drawImGuiInterface() {
    ImGui::Begin("Controls");
    if (ImGui::Button("path")) {
    
        //cufftExecZ2Z(plan, fftarray, fftarray, CUFFT_FORWARD);
        cudaDeviceSynchronize();

        //cudaDeviceSynchronize();

        // Для миллисекунд
     
        OPENFILENAME ofn;
        WCHAR wszFile[MAX_PATH]; // Буфер для хранения пути к файлу в формате Unicode

        ZeroMemory(&ofn, sizeof(ofn));
        ofn.lStructSize = sizeof(ofn);
        ofn.hwndOwner = NULL;
        ofn.lpstrFile = wszFile;
        ofn.lpstrFile[0] = '\0'; // Начальное значение пустой строки
        ofn.nMaxFile = MAX_PATH;
        ofn.lpstrFilter = L"Image Files (*.png;*.jpg;*.bmp)\0*.png;*.jpg;*.bmp\0All Files (*.*)\0*.*\0";
        ofn.nFilterIndex = 1;
        ofn.lpstrFileTitle = NULL;
        ofn.nMaxFileTitle = 0;
        ofn.lpstrInitialDir = NULL;
        ofn.Flags = OFN_PATHMUSTEXIST | OFN_FILEMUSTEXIST;

        // Открытие диалогового окна
        if (GetSaveFileName(&ofn) == TRUE) {
            // Вывод выбранного пути к файлу
            WideCharToMultiByte(CP_UTF8, 0, wszFile, -1, szFile, MAX_PATH, NULL, NULL);
            printf("Selected file: %ls\n", wszFile);
            printf("Selected file: %s\n", szFile);
        }
        static char filepath1[MAX_PATH];
        memset(filepath1, 0, sizeof(filepath1));
        for (int i = 0, j = 0; szFile[i]; i++) {
            filepath1[i] = szFile[i];
            if (szFile[i] == '\\') {
                filepath1[i] = '/';
            }
        }
        printf("Selected file: %s\n", filepath1);

        if (pixels_Gal) {
            stbi_image_free(pixels_Gal);
            pixels_Gal = nullptr; // Установка указателя в nullptr после освобождения памяти
        }
        system_clock::time_point start = system_clock::now();
        pixels_Gal = stbi_load(filepath1, &texWidth_Gal, &texHeight_Gal, &texChannels_Gal, 1);
        system_clock::time_point end = system_clock::now();
        std::chrono::duration<double, std::milli> duration = end - start;
        printf("cufft %5f millisec\n", duration.count());
        uchar4* devPtr;
        size_t size;
        // Map resources for CUDA access
        (cudaGraphicsMapResources(1, &(resource), NULL));

        // Get a device pointer to the mapped resource
        (cudaGraphicsResourceGetMappedPointer((void**)&devPtr, &size, resource));

        drawloadimg(devPtr, pixels_Gal, texWidth_Gal);
        // Unmap resources after CUDA access
        (cudaGraphicsUnmapResources(1, &(resource), NULL));

    }
    //if (ImGui::Button("IMG draw path")) {
    //
    //    OPENFILENAME ofn;
    //    WCHAR wszFile[MAX_PATH]; // Буфер для хранения пути к файлу в формате Unicode
    //
    //    ZeroMemory(&ofn, sizeof(ofn));
    //    ofn.lStructSize = sizeof(ofn);
    //    ofn.hwndOwner = NULL;
    //    ofn.lpstrFile = wszFile;
    //    ofn.lpstrFile[0] = '\0'; // Начальное значение пустой строки
    //    ofn.nMaxFile = MAX_PATH;
    //    ofn.lpstrFilter = L"Image Files (*.png;*.jpg;*.bmp)\0*.png;*.jpg;*.bmp\0All Files (*.*)\0*.*\0";
    //    ofn.nFilterIndex = 1;
    //    ofn.lpstrFileTitle = NULL;
    //    ofn.nMaxFileTitle = 0;
    //    ofn.lpstrInitialDir = NULL;
    //    ofn.Flags = OFN_PATHMUSTEXIST | OFN_FILEMUSTEXIST;
    //
    //    // Открытие диалогового окна
    //    if (GetSaveFileName(&ofn) == TRUE) {
    //        // Вывод выбранного пути к файлу
    //        WideCharToMultiByte(CP_UTF8, 0, wszFile, -1, szFile, MAX_PATH, NULL, NULL);
    //        printf("Selected file: %ls\n", wszFile);
    //        printf("Selected file: %s\n", szFile);
    //    }
    //    static char filepath1[MAX_PATH];
    //    memset(filepath1, 0, sizeof(filepath1));
    //    for (int i = 0, j = 0; szFile[i]; i++) {
    //        filepath1[i] = szFile[i];
    //        if (szFile[i] == '\\') {
    //            filepath1[i] = '/';
    //        }
    //    }
    //    printf("Selected file: %s\n", filepath1);
    //    
    //    if (pixels_Gal) {
    //        stbi_image_free(pixels_Gal);
    //        pixels_Gal = nullptr; // Установка указателя в nullptr после освобождения памяти
    //    }
    //    pixels_Gal = stbi_load(filepath1, &texWidth_Gal, &texHeight_Gal, &texChannels_Gal, 1);
    //
    //    uchar4* devPtr;
    //    size_t size;
    //    // Map resources for CUDA access
    //    (cudaGraphicsMapResources(1, &(resource), NULL));
    //
    //    // Get a device pointer to the mapped resource
    //    (cudaGraphicsResourceGetMappedPointer((void**)&devPtr, &size, resource));
    //
    //    drawloadimg(devPtr, pixels_Gal, texWidth_Gal);
    //    // Unmap resources after CUDA access
    //    (cudaGraphicsUnmapResources(1, &(resource), NULL));
    //  
    //}
    //if (ImGui::Button("Calculate CUDA")) {
    //    uchar4* devPtr;
    //    size_t size;
    //    // Map resources for CUDA access
    //    (cudaGraphicsMapResources(1, &(resource), NULL));
    //
    //    // Get a device pointer to the mapped resource
    //    (cudaGraphicsResourceGetMappedPointer((void**)&devPtr, &size, resource));
    //
    //    cudaAdd(devPtr, 1024);
    //    // Unmap resources after CUDA access
    //    (cudaGraphicsUnmapResources(1, &(resource), NULL));
    //   // int a = 3, b = 5, c;
    //    //cudaAdd(bufferObj,1024);
    //    //std::cout << a << " + " << b << " = " << c << std::endl;
    //}
    //if (ImGui::Button("Calculate CUDA1")) {
    //    uchar4* devPtr;
    //    size_t size;
    //    // Map resources for CUDA access
    //    (cudaGraphicsMapResources(1, &(resource), NULL));
    //
    //    // Get a device pointer to the mapped resource
    //    (cudaGraphicsResourceGetMappedPointer((void**)&devPtr, &size, resource));
    //
    //    cudaAdd1(devPtr, 1024);
    //    // Unmap resources after CUDA access
    //    (cudaGraphicsUnmapResources(1, &(resource), NULL));
    //    // int a = 3, b = 5, c;
    //     //cudaAdd(bufferObj,1024);
    //     //std::cout << a << " + " << b << " = " << c << std::endl;
    //}

    // Окна для ввода текста

    // Кнопка для считывания числовых значений
    if (ImGui::Button("CuFFT")) {

    }
    if (ImGui::Button("BPF MY"))
    {
        if (fftmass !=0 ) {
            cudaFree(fftmass);
        }
        cudaMalloc((void**)&fftmass, texWidth_Gal* texWidth_Gal * sizeof(cufftDoubleComplex));
        FFT_MY(fftmass, pixels_Gal, texWidth_Gal);
       

    }
    ImGui::InputText("Min Value", minInput, IM_ARRAYSIZE(minInput));
    ImGui::InputText("Max Value", maxInput, IM_ARRAYSIZE(maxInput));

    if (ImGui::Button("Set Min/Max Values")) {
        // Преобразование строк в числа
        try {
            minVal = std::stod(minInput);
            maxVal = std::stod(maxInput);
            std::cout << "Min Value: " << minVal << ", Max Value: " << maxVal << std::endl;
        }
        catch (const std::invalid_argument& e) {
            std::cerr << "Invalid input: " << e.what() << std::endl;
        }
        catch (const std::out_of_range& e) {
            std::cerr << "Input out of range: " << e.what() << std::endl;
        }
    }
    if (ImGui::Button("Real")) 
    {

    }
    if (ImGui::Button("Im"))
    {

    }
    if (ImGui::Button("Amplitude"))
    {

    }
    if (ImGui::Button("Phase"))
    {

    }
    if (ImGui::Button("Range")) {
       
    }
    if (ImGui::Button("Shift")) {

    }
    if (ImGui::Button("Test my BPF CUDA")) {
       // pixels_Gal = stbi_load("4096.jpg", &texWidth_Gal, &texHeight_Gal, &texChannels_Gal, 1);
        uchar4* devPtr;
        size_t size;
        // Map resources for CUDA access
        (cudaGraphicsMapResources(1, &(resource), NULL));

        // Get a device pointer to the mapped resource
        (cudaGraphicsResourceGetMappedPointer((void**)&devPtr, &size, resource));
        Test_My_BPF(devPtr, pixels_Gal, texWidth_Gal);
        //cudaAdd1(devPtr, 1024);
        // Unmap resources after CUDA access
        (cudaGraphicsUnmapResources(1, &(resource), NULL));
        // int a = 3, b = 5, c;
         //cudaAdd(bufferObj,1024);
         //std::cout << a << " + " << b << " = " << c << std::endl;
        //stbi_image_free(pixels_Gal);
        //pixels_Gal = nullptr; // Установка указателя в nullptr после освобождения памяти
    }
    if (ImGui::Button("Test BPF cufft")) {
        //pixels_Gal = stbi_load("4096.jpg", &texWidth_Gal, &texHeight_Gal, &texChannels_Gal, 1);
        uchar4* devPtr;
        size_t size;
        // Map resources for CUDA access
        (cudaGraphicsMapResources(1, &(resource), NULL));

        // Get a device pointer to the mapped resource
        (cudaGraphicsResourceGetMappedPointer((void**)&devPtr, &size, resource));
        CUFFTTEST(devPtr, pixels_Gal, texWidth_Gal);
        //cudaAdd1(devPtr, 1024);
        // Unmap resources after CUDA access
        (cudaGraphicsUnmapResources(1, &(resource), NULL));
        // int a = 3, b = 5, c;
         //cudaAdd(bufferObj,1024);
         //std::cout << a << " + " << b << " = " << c << std::endl;
        //stbi_image_free(pixels_Gal);
        //pixels_Gal = nullptr; // Установка указателя в nullptr после освобождения памяти



    }
    
    if (ImGui::Button("Flag draw")) {
        drawBufferObj = true;
    }
    ImGui::End();
}

int main() {
    if (!glfwInit()) {
        std::cerr << "Failed to initialize GLFW" << std::endl;
        return -1;
    }

    GLFWwindow* window = glfwCreateWindow(1200, 1024, "Program Complex", nullptr, nullptr);
    if (!window) {
        std::cerr << "Failed to create GLFW window" << std::endl;
        glfwTerminate();
        return -1;
    }

    glfwMakeContextCurrent(window);
    glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);

    if (glewInit() != GLEW_OK) {
        std::cerr << "Failed to initialize GLEW" << std::endl;
        return -1;
    }

    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGui_ImplGlfw_InitForOpenGL(window, true);
    ImGui_ImplOpenGL3_Init("#version 130");


    glGenBuffers(1, &bufferObj);
    glBindBuffer(GL_PIXEL_UNPACK_BUFFER_ARB, bufferObj);
    glBufferData(GL_PIXEL_UNPACK_BUFFER_ARB, 1024 * 1024 * 4, NULL, GL_DYNAMIC_DRAW_ARB);
    cudaGraphicsGLRegisterBuffer(&resource, bufferObj, cudaGraphicsMapFlagsWriteDiscard);

    while (!glfwWindowShouldClose(window)) {
        glfwPollEvents();

        ImGui_ImplOpenGL3_NewFrame();
        ImGui_ImplGlfw_NewFrame();
        ImGui::NewFrame();

        drawImGuiInterface();

        ImGui::Render();
        int display_w, display_h;
        glfwGetFramebufferSize(window, &display_w, &display_h);
        glViewport(0, 0, display_w, display_h);
        glClearColor(0.45f, 0.55f, 0.60f, 1.00f);
        glClear(GL_COLOR_BUFFER_BIT);

        if (drawBufferObj) {
            glBindBuffer(GL_PIXEL_UNPACK_BUFFER, bufferObj); // Привязываем буферный объект
            //glRasterPos2i(-1, 1); // Установка позиции вывода в левый верхний угол
            glDrawPixels(1024, 1024, GL_RGBA, GL_UNSIGNED_BYTE, 0);
            glBindBuffer(GL_PIXEL_UNPACK_BUFFER, 0); // Отвязываем буферный объект
            drawBufferObj = true;
        }
        ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());


        glfwSwapBuffers(window);
    }

    ImGui_ImplOpenGL3_Shutdown();
    ImGui_ImplGlfw_Shutdown();
    ImGui::DestroyContext();

    glfwDestroyWindow(window);
    glfwTerminate();

    return 0;
}