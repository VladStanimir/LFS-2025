#!/usr/bin/env bash
set -e

echo "LFS: Bash - Temporary System (Chapter 6.4)"

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
PKG="bash-5.3"
TARBALL="$SRC_DIR/$PKG.tar.gz"

# Check source exists
if [ ! -f "$TARBALL" ]; then
    echo "ERROR: Missing tarball: $TARBALL"
    exit 1
fi

cd "$SRC_DIR"

# Cleanup old extraction
echo "Cleaning previous $PKG build..."
rm -rf "$PKG"

echo "Extracting $PKG..."
tar xf "$TARBALL"
cd "$PKG"

echo "Configuring Bash..."

./configure --prefix=/usr                      \
            --build=$(sh support/config.guess) \
            --host=$LFS_TGT                    \
            --without-bash-malloc

echo "Building Bash..."
make

echo "Installing Bash..."
make DESTDIR=$LFS install

echo "Creating /bin/sh symlink..."
ln -sv bash $LFS/bin/sh

echo "Cleaning up..."

cd "$SRC_DIR"
rm -rf "$PKG"

echo "Bash Temporary Install Completed Successfully"
