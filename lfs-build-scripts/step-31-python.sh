#!/usr/bin/env bash
set -e

echo "LFS Ch.7: Python - Chapter 7.10"

# Must be root inside chroot
if [ "$(id -u)" != "0" ]; then
    echo "ERROR: This script must be run as root inside chroot."
    exit 1
fi

SRC_DIR="/sources"
PKG="Python-3.13.7"
TARBALL="$SRC_DIR/$PKG.tar.xz"

if [ ! -f "$TARBALL" ]; then
    echo "ERROR: Missing tarball: $TARBALL"
    exit 1
fi

cd "$SRC_DIR"

echo "Cleaning previous $PKG build..."
rm -rf "$PKG"

echo "Extracting $PKG..."
tar xf "$TARBALL"
cd "$PKG"

echo "Configuring Python..."
./configure --prefix=/usr       \
            --enable-shared     \
            --without-ensurepip \
            --without-static-libpython

echo "Building Python..."
make

echo "Installing Python..."
make install

echo "Cleaning up..."
cd "$SRC_DIR"
rm -rf "$PKG"

echo "Python Installed Successfully"
