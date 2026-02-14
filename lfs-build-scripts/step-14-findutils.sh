#!/usr/bin/env bash
set -e

echo "LFS: Findutils - Temporary System (Chapter 6.8)"

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
PKG="findutils-4.10.0"
TARBALL="$SRC_DIR/$PKG.tar.xz"

# Check source exists
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

echo "Configuring Findutils..."

./configure --prefix=/usr                   \
            --localstatedir=/var/lib/locate \
            --host=$LFS_TGT                 \
            --build=$(build-aux/config.guess)

echo "Building Findutils..."
make

echo "Installing Findutils..."
make DESTDIR=$LFS install

echo "Cleaning up..."

cd "$SRC_DIR"
rm -rf "$PKG"

echo "Findutils Temporary Install Completed Successfully"

