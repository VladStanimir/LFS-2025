#!/usr/bin/env bash
set -e

echo "LFS Ch.7: Bison - Chapter 7.8"

# Must run as root inside chroot
if [ "$(id -u)" != "0" ]; then
    echo "ERROR: This script must be run as root inside chroot."
    exit 1
fi

SRC_DIR="/sources"
PKG="bison-3.8.2"
TARBALL="$SRC_DIR/$PKG.tar.xz"

if [ ! -f "$TARBALL" ]; then
    echo "ERROR: Missing tarball: $TARBALL"
    exit 1
fi

cd "$SRC_DIR"

# Cleanup
echo "Cleaning previous $PKG build..."
rm -rf "$PKG"

echo "Extracting $PKG..."
tar xf "$TARBALL"
cd "$PKG"

echo "Configuring Bison..."
./configure --prefix=/usr \
            --docdir=/usr/share/doc/bison-3.8.2

echo "Building Bison..."
make

echo "Installing Bison..."
make install

echo "Cleaning up..."
cd "$SRC_DIR"
rm -rf "$PKG"

echo "Bison Installed Successfully"
