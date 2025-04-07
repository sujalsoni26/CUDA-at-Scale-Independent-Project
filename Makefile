CC = nvcc
CFLAGS = -O2

all: grayscale

grayscale: src/main.cu src/image_processing.cu
	$(CC) $(CFLAGS) -o grayscale src/main.cu src/image_processing.cu

clean:
	rm -f grayscale
