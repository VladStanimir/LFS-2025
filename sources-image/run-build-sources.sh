#!/usr/bin/env bash

set -e

IMAGE_NAME="lfs-sources-image"
VOLUME_NAME="lfs-sources"
SOURCE_DIR_HOST="./sources-image"

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

# Run the check script
if ! $CHECK_SCRIPT; then
    echo "Some source files were missing. Running download script..."

    $DOWNLOAD_SCRIPT

    echo "Re-checking source files..."
    if ! $CHECK_SCRIPT; then
        echo "ERROR: Files are still missing after download."
        exit 1
    fi
else
    echo "All source files are present."
fi

# Check if sources-image folder exists
if [ ! -d "$SOURCE_DIR_HOST" ]; then
    echo "ERROR: Directory $SOURCE_DIR_HOST does not exist."
    echo "Expected layout:"
    echo "  sources-image/"
    echo "    Dockerfile"
    echo "    sources/"
    exit 1
fi

echo "Building the tarball sources image..."
$ENGINE build -t $IMAGE_NAME $SOURCE_DIR_HOST

echo "Creating volume $VOLUME_NAME (if not exists)..."
$ENGINE volume create $VOLUME_NAME >/dev/null 2>&1 || true

echo "Populating volume with tarballs..."
$ENGINE run --rm \
    -v $VOLUME_NAME:/data \
    $IMAGE_NAME \
    cp -r /sources/. /data/

echo "All tarballs successfully copied into volume $VOLUME_NAME."
echo "You can now mount this volume in your build container:"
echo "  -v $VOLUME_NAME:/mnt/lfs/sources"
