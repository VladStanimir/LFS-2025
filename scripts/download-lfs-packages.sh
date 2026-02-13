#!/usr/bin/env bash

set -e

# Directory on host where sources will be downloaded
HOST_SRC_DIR="./sources-image/sources"
WGET_LIST="$HOST_SRC_DIR/../source-archive-links.txt"

echo "Creating host source directory at: $HOST_SRC_DIR"
mkdir -pv "$HOST_SRC_DIR"
chmod -v a+wt "$HOST_SRC_DIR"

echo "Starting downloads..."
wget --continue --input-file="$WGET_LIST" --directory-prefix="$HOST_SRC_DIR"

echo "All downloads complete."
echo "Files stored in: $HOST_SRC_DIR"
