#ifndef IMAGE_PROCESSING_H
#define IMAGE_PROCESSING_H

struct Image {
    int width;
    int height;
    unsigned char *data; // RGB data (3 bytes per pixel)
};

Image* loadPPM(const char* filename);
void savePPM(const char* filename, Image* img);
void freeImage(Image* img);
void processImages(const char* inputDir, const char* outputDir, int numImages);

#endif
