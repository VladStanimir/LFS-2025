#!/usr/bin/env bash
set -e

echo "LFS: Gawk - Temporary System (Chapter 6.9)"

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
PKG="gawk-5.3.2"
TARBALL="$SRC_DIR/$PKG.tar.xz"

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

echo "Removing unneeded scripts from build..."
sed -i 's/extras//' Makefile.in

echo "Configuring Gawk..."

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

echo "Building Gawk..."
make

echo "Installing Gawk..."
make DESTDIR=$LFS install

echo "Cleaning up..."

cd "$SRC_DIR"
rm -rf "$PKG"

echo "Gawk Temporary Install Completed Successfully"
