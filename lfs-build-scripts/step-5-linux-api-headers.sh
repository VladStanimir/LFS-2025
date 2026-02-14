#!/usr/bin/env bash

set -e

echo "LFS: Linux API Headers (5.4)"

# Safety checks
if [ "$(whoami)" != "lfs" ]; then
    echo "ERROR: This script must be run as user 'lfs'."
    exit 1
fi

if [ -z "$LFS" ]; then
    echo "ERROR: \$LFS is not set."
    exit 1
fi

SRC_DIR="$LFS/sources"
PKG="linux-6.16.1"
TARBALL="$SRC_DIR/$PKG.tar.xz"

echo "Cleaning up..."
cd "$SRC_DIR"
rm -rf "$PKG"

# Check tarball exists
if [ ! -f "$TARBALL" ]; then
    echo "ERROR: Missing tarball: $TARBALL"
    exit 1
fi

cd "$SRC_DIR"

echo "Extracting $PKG..."
rm -rf "$PKG"
tar xf "$TARBALL"
cd "$PKG"

echo "Running 'make mrproper'..."
make mrproper

echo "Building sanitized Linux API headers..."
make headers

echo "Removing non-header files..."
find usr/include -type f ! -name '*.h' -delete

echo "Installing headers to $LFS/usr/include ..."
cp -rv usr/include "$LFS/usr"

echo "Cleaning up..."
cd "$SRC_DIR"
rm -rf "$PKG"

echo "Linux API Headers Completed Successfully"
