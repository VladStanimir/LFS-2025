#!/usr/bin/env bash
set -e

echo "LFS: Binutils - Pass 2 (Chapter 6.17)"

# Safety checks
if [ "$(whoami)" != "lfs" ]
then
    echo "ERROR: This script must be run as user 'lfs'."
    exit 1
fi

if [ -z "$LFS" ]
then
    echo "ERROR: \$LFS is not set."
    exit 1
fi

SRC_DIR="$LFS/sources"
PKG="binutils-2.45"
TARBALL="$SRC_DIR/$PKG.tar.xz"

# Ensure tarball exists
if [ ! -f "$TARBALL" ]
then
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

# Required Binutils Pass 2 fix
echo "Applying build system fix (ltmain.sh)..."
sed '6031s/$add_dir//' -i ltmain.sh

echo "Creating build directory..."
mkdir -v build
cd build

echo "Configuring Binutils (Pass 2)..."

../configure \
    --prefix=/usr              \
    --build=$(../config.guess) \
    --host=$LFS_TGT            \
    --disable-nls              \
    --enable-shared            \
    --enable-gprofng=no        \
    --disable-werror           \
    --enable-new-dtags         \
    --enable-64-bit-bfd        \
    --enable-default-hash-style=gnu

echo "Building Binutils Pass 2..."
make

echo "Installing Binutils..."
make DESTDIR=$LFS install

echo "Removing harmful .la files and static libraries..."
rm -v $LFS/usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes,sframe}.{a,la}

echo "Cleaning up..."

cd "$SRC_DIR"
rm -rf "$PKG"

echo "Binutils Pass 2 Completed Successfully"
