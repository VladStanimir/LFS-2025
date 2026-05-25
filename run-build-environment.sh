#!/usr/bin/env bash

IMAGE_NAME="lfs-build-env"
CONTAINER_NAME="lfs"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/build"
export CHECK_SCRIPT="$SCRIPT_DIR/scripts/check-lfs-sources.sh"
export DOWNLOAD_SCRIPT="$SCRIPT_DIR/scripts/download-lfs-packages.sh"

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

# Check if required volume exists; if not, auto-create it
if ! "$ENGINE" volume inspect lfs-sources >/dev/null 2>&1; then
    echo "Volume 'lfs-sources' not found."
    echo "Running $SCRIPT_DIR/sources-image/run-build-sources.sh to create it..."
    
    "$SCRIPT_DIR/sources-image/run-build-sources.sh"

    # Verify the volume now exists
    if ! "$ENGINE" volume inspect lfs-sources >/dev/null 2>&1; then
        echo "ERROR: Failed to create volume 'lfs-sources'."
        exit 1
    fi

    echo "Volume 'lfs-sources' created successfully."
fi


# Ensure build directory exists
if [ ! -d "$BUILD_DIR" ]; then
    echo "Creating build directory at $BUILD_DIR..."
    mkdir -p "$BUILD_DIR"
fi

# Build the image
echo "Building image $IMAGE_NAME..."
"$ENGINE" build -t "$IMAGE_NAME" "$SCRIPT_DIR"

echo "Cleaning unused intermediate images..."
"$ENGINE" image prune -f --filter "dangling=true"

# Remove existing container if it exists
if "$ENGINE" container inspect "$CONTAINER_NAME" >/dev/null 2>&1; then
    echo "Removing existing container: $CONTAINER_NAME..."
    "$ENGINE" rm -f "$CONTAINER_NAME"
fi

# Run the container with the mounted directory
echo "Starting container..."
exec "$ENGINE" run -it --cap-add=SYS_ADMIN --name "$CONTAINER_NAME" \

    -v "$BUILD_DIR:/mnt/lfs" \
    -v lfs-sources:/mnt/lfs/sources \
    "$IMAGE_NAME" bash -c "
        echo 'Fixing permissions on /mnt/lfs...' ;
        sudo chown -R lfs:lfs /mnt/lfs ;
        sudo chmod a+wt /mnt/lfs/sources ;
        exec /bin/bash --login
    "
