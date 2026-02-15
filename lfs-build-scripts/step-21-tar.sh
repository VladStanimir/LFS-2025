#!/usr/bin/env bash
set -e

echo "LFS: Tar - Temporary System (Chapter 6.15)"

# Safety checks
if [ "$(whoami)" != "lfs" ]; then
    echo "ERROR: This script must be run as user 'lfs'."
    exit 1
fi

if [ -z "$LFS" ]; then
    echo "ERROR: $LFS is not set."
    exit 1
fi

SRC_DIR="$LFS/sources"
PKG="tar-1.35"
TARBALL="$SRC_DIR/$PKG.tar.xz"

# Ensure source exists
if [ ! -f "$TARBALL" ]; then
    echo "ERROR: Missing tarball: $TARBALL"
    exit 1
fi

cd "$SRC_DIR"

# Cleanup old extraction
echo "Cleaning previous $PKG build..."
rm -rf "$PKG"

echo "Extracting $PKG..."
tar xf "$TARBALL"
cd "$PKG"

echo "Configuring Tar..."

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

echo "Building Tar..."
make

echo "Installing Tar..."
make DESTDIR=$LFS install

echo "Cleaning up..."

cd "$SRC_DIR"
rm -rf "$PKG"

echo "Tar Temporary Install Completed Successfully"
