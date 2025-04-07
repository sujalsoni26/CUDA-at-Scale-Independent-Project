#include "image_processing.h"
#include <cuda_runtime.h>
#include <stdio.h>
#include <dirent.h>
#include <string.h>

// CUDA kernel to convert RGB to grayscale
__global__ void grayscaleKernel(unsigned char *d_in, unsigned char *d_out, int width, int height) {
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;

    if (x < width && y < height) {
        int idx = (y * width + x) * 3; // RGB input
        int out_idx = y * width + x;    // Grayscale output
        unsigned char r = d_in[idx];
        unsigned char g = d_in[idx + 1];
        unsigned char b = d_in[idx + 2];
        d_out[out_idx] = (unsigned char)(0.299f * r + 0.587f * g + 0.114f * b);
    }
}

// Load a PPM image (P6 format)
Image* loadPPM(const char* filename) {
    FILE *fp = fopen(filename, "rb");
    if (!fp) return nullptr;

    char buffer[16];
    fscanf(fp, "%s\n", buffer); // P6
    int width, height, maxval;
    fscanf(fp, "%d %d\n%d\n", &width, &height, &maxval);

    Image* img = (Image*)malloc(sizeof(Image));
    img->width = width;
    img->height = height;
    img->data = (unsigned char*)malloc(width * height * 3);
    fread(img->data, 1, width * height * 3, fp);
    fclose(fp);
    return img;
}

// Save a PPM image (grayscale as RGB for simplicity)
void savePPM(const char* filename, Image* img) {
    FILE *fp = fopen(filename, "wb");
    fprintf(fp, "P6\n%d %d\n255\n", img->width, img->height);
    fwrite(img->data, 1, img->width * img->height * 3, fp);
    fclose(fp);
}

void freeImage(Image* img) {
    free(img->data);
    free(img);
}

void processImages(const char* inputDir, const char* outputDir, int numImages) {
    DIR *dir = opendir(inputDir);
    if (!dir) {
        printf("Error opening input directory\n");
        return;
    }

    struct dirent *entry;
    int processed = 0;
    while ((entry = readdir(dir)) != nullptr && processed < numImages) {
        if (strstr(entry->d_name, ".ppm") == nullptr) continue;

        char inputPath[256], outputPath[256];
        snprintf(inputPath, sizeof(inputPath), "%s/%s", inputDir, entry->d_name);
        snprintf(outputPath, sizeof(outputPath), "%s/%s", outputDir, entry->d_name);

        Image* img = loadPPM(inputPath);
        if (!img) continue;

        // Allocate device memory
        unsigned char *d_in, *d_out;
        size_t rgbSize = img->width * img->height * 3;
        size_t graySize = img->width * img->height;
        cudaMalloc(&d_in, rgbSize);
        cudaMalloc(&d_out, graySize);

        // Copy input to device
        cudaMemcpy(d_in, img->data, rgbSize, cudaMemcpyHostToDevice);

        // Launch kernel
        dim3 block(16, 16);
        dim3 grid((img->width + block.x - 1) / block.x, (img->height + block.y - 1) / block.y);
        grayscaleKernel<<<grid, block>>>(d_in, d_out, img->width, img->height);

        // Copy result back and convert to RGB for PPM
        unsigned char *h_out = (unsigned char*)malloc(graySize);
        cudaMemcpy(h_out, d_out, graySize, cudaMemcpyDeviceToHost);
        for (int i = 0; i < img->width * img->height; i++) {
            img->data[i * 3] = h_out[i];
            img->data[i * 3 + 1] = h_out[i];
            img->data[i * 3 + 2] = h_out[i];
        }
        free(h_out);

        // Save output
        savePPM(outputPath, img);

        // Cleanup
        cudaFree(d_in);
        cudaFree(d_out);
        freeImage(img);
        processed++;
        printf("Processed: %s\n", entry->d_name);
    }
    closedir(dir);
}
