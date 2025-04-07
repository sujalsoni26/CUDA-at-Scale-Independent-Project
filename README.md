# CUDA Grayscale Image Processor

This project uses CUDA to process a large number of small images (e.g., MNIST digits) by converting them from RGB to grayscale in parallel.

## How to Run
1. Ensure you have CUDA installed and `nvcc` available.
2. Place input PPM images.
3. Run `make` to compile the program.
4. Execute `./run.sh` to process up to 100 images` and save them.

## Requirements
- CUDA-enabled GPU
- Input images in PPM (P6) format

## Project Details
- **Purpose**: Convert RGB images to grayscale using CUDA.
- **Algorithm**: Uses a 2D grid kernel with the standard grayscale formula (0.299R + 0.587G + 0.114B).
- **Lessons Learned**: Efficient memory management and kernel launches are critical for performance.
