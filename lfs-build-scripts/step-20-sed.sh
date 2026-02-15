#!/usr/bin/env bash
set -e

echo "LFS: Sed - Temporary System (Chapter 6.14)"

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
PKG="sed-4.9"
TARBALL="$SRC_DIR/$PKG.tar.xz"

# Ensure tarball exists
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

echo "Configuring Sed..."

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(./build-aux/config.guess)

echo "Building Sed..."
make

echo "Installing Sed into \$LFS..."
make DESTDIR=$LFS install

echo "Cleaning up..."

cd "$SRC_DIR"
rm -rf "$PKG"

echo "Sed Temporary Install Completed Successfully"
