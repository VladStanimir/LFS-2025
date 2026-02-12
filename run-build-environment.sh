#!/usr/bin/env bash

IMAGE_NAME="lfs-build-env"
CONTAINER_NAME="lfs"
BUILD_DIR="./build"

# Detect container engine
if command -v podman >/dev/null 2>&1; then
    ENGINE="podman"
elif command -v docker >/dev/null 2>&1; then
    ENGINE="docker"
else
    echo "Error: Neither podman nor docker was found on this system."
    exit 1
fi

echo "Using container engine: $ENGINE"

# Ensure build directory exists
if [ ! -d "$BUILD_DIR" ]; then
    echo "Creating build directory at $BUILD_DIR..."
    mkdir -p "$BUILD_DIR"
fi

# Build the image
echo "Building image $IMAGE_NAME..."
$ENGINE build -t $IMAGE_NAME .

# Remove existing container if it exists
if $ENGINE container inspect $CONTAINER_NAME >/dev/null 2>&1; then
    echo "Removing existing container: $CONTAINER_NAME..."
    $ENGINE rm -f $CONTAINER_NAME
fi

# Run the container with the mounted directory
echo "Starting container..."
$ENGINE run -it --name $CONTAINER_NAME \
    -v "$(pwd)/build:/mnt/lfs" \
    $IMAGE_NAME
