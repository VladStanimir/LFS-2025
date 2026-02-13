#!/usr/bin/env bash

set -e

echo "LFS: Libstdc++ - Temporary Pass (5.6)"

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
PKG="gcc-15.2.0"
TARBALL="$SRC_DIR/$PKG.tar.xz"

# Check tarball
if [ ! -f "$TARBALL" ]; then
    echo "ERROR: Missing GCC tarball: $TARBALL"
    exit 1
fi

cd "$SRC_DIR"

echo "Extracting GCC sources..."
rm -rf "$PKG"
tar xf "$TARBALL"
cd "$PKG"

echo "Entering libstdc++ directory..."

mkdir -v build
cd build

echo "Configuring Libstdc++ (Pass 1)..."
../libstdc++-v3/configure \
    --host=$LFS_TGT \
    --build=$(../config.guess) \
    --prefix=/usr \
    --disable-multilib \
    --disable-nls \
    --disable-libstdcxx-pch \
    --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/15.2.0

echo "Building Libstdc++..."
make

echo "Installing Libstdc++..."
make DESTDIR=$LFS install

echo "Removing libtool .la files..."
rm -v $LFS/usr/lib/lib{stdc++{,exp,fs},supc++}.la

echo "Cleaning up sources..."
cd "$SRC_DIR"
rm -rf "$PKG"

echo "Libstdc++ Pass 1 Completed Successfully"
