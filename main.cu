#include "image_processing.h"
#include <stdio.h>

int main(int argc, char *argv[]) {
    if (argc != 4) {
        printf("Usage: %s <input_dir> <output_dir> <num_images>\n", argv[0]);
        return 1;
    }

    const char* inputDir = argv[1];
    const char* outputDir = argv[2];
    int numImages = atoi(argv[3]);

    processImages(inputDir, outputDir, numImages);
    return 0;
}
