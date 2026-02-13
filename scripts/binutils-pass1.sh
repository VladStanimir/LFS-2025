#!/usr/bin/env bash

set -e

echo "LFS: Binutils Pass 1"

# Safety: make sure we are the lfs user
if [ "$(whoami)" != "lfs" ]; then
    echo "ERROR: This script must be run as user 'lfs'."
    exit 1
fi

# Safety: make sure LFS is set
if [ -z "$LFS" ]; then
    echo "ERROR: \$LFS is not set."
    exit 1
fi

SRC_DIR="$LFS/sources"
PKG="binutils-2.45"
TARBALL="$SRC_DIR/$PKG.tar.xz"

# Check tarball
if [ ! -f "$TARBALL" ]; then
    echo "ERROR: Tarball not found: $TARBALL"
    exit 1
fi

cd "$SRC_DIR"

echo "Extracting $PKG..."
rm -rf "$PKG"
tar xf "$TARBALL"
cd "$PKG"

echo "Creating build directory..."
mkdir -v build
cd build

echo "Configuring Binutils Pass 1..."
../configure --prefix=$LFS/tools \
             --with-sysroot=$LFS \
             --target=$LFS_TGT   \
             --disable-nls       \
             --enable-gprofng=no \
             --disable-werror    \
             --enable-new-dtags  \
             --enable-default-hash-style=gnu

echo "Building Binutils..."
make

echo "Installing Binutils..."
make install

echo "Cleaning up sources..."
cd "$SRC_DIR"
rm -rf "$PKG"

echo "Binutils Pass 1 Completed Successfully"
