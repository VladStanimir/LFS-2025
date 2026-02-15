#!/usr/bin/env bash
set -e

echo "LFS: Xz - Temporary System (Chapter 6.16)"

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
PKG="xz-5.8.1"
TARBALL="$SRC_DIR/$PKG.tar.xz"

# Verify tarball exists
if [ ! -f "$TARBALL" ]; then
    echo "ERROR: Missing tarball: $TARBALL"
    exit 1
fi

cd "$SRC_DIR"

# Clean previous source dir
echo "Cleaning previous $PKG build..."
rm -rf "$PKG"

echo "Extracting $PKG..."
tar xf "$TARBALL"
cd "$PKG"

echo "Configuring Xz..."

./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) \
            --disable-static                  \
            --docdir=/usr/share/doc/xz-5.8.1

echo "Building Xz..."
make

echo "Installing Xz..."
make DESTDIR=$LFS install

echo "Removing harmful .la file..."
rm -v $LFS/usr/lib/liblzma.la

echo "Cleaning up..."

cd "$SRC_DIR"
rm -rf "$PKG"

echo "Xz Temporary Install Completed Successfully"
