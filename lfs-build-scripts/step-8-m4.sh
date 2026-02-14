#!/usr/bin/env bash

set -e

echo "LFS: M4 - Temporary System (Chapter 6.2)"

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
PKG="m4-1.4.20"
TARBALL="$SRC_DIR/$PKG.tar.xz"

echo "Cleaning up build directory..."
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

echo "Configuring M4..."
./configure --prefix=/usr \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

echo "Building M4..."
make

echo "Installing M4 into \$LFS..."
make DESTDIR=$LFS install

echo "Cleaning up..."
cd "$SRC_DIR"
rm -rf "$PKG"

echo "M4 Temporary Install Completed Successfully"
