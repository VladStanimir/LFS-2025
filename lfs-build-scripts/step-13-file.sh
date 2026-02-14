#!/usr/bin/env bash
set -e

echo "LFS: File - Temporary System (Chapter 6.7)"

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
PKG="file-5.46"
TARBALL="$SRC_DIR/$PKG.tar.gz"

# Verify source tarball exists
if [ ! -f "$TARBALL" ]; then
    echo "ERROR: Missing tarball: $TARBALL"
    exit 1
fi

cd "$SRC_DIR"

# Cleanup previous extraction
echo "Cleaning previous $PKG build..."
rm -rf "$PKG"

echo "Extracting $PKG..."
tar xf "$TARBALL"
cd "$PKG"

echo "Building temporary host file utility"

mkdir -v build
pushd build

../configure --disable-bzlib      \
             --disable-libseccomp \
             --disable-xzlib      \
             --disable-zlib

make

popd

echo "Configuring target File build"

./configure --prefix=/usr            \
            --host=$LFS_TGT          \
            --build=$(./config.guess)

echo "Building File..."
make FILE_COMPILE=$(pwd)/build/src/file

echo "Installing File..."
make DESTDIR=$LFS install

echo "Removing harmful .la file..."
rm -v $LFS/usr/lib/libmagic.la

echo "Cleaning up..."

cd "$SRC_DIR"
rm -rf "$PKG"

echo "File Temporary Install Completed Successfully"
