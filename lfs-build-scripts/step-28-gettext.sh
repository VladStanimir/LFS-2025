#!/usr/bin/env bash
set -e

echo "LFS Ch.7: Gettext - Minimal Programs (Chapter 7.7)"

# Must run as root inside chroot
if [ "$(id -u)" != "0" ]; then
    echo "ERROR: This script must be run as root inside chroot."
    exit 1
fi

SRC_DIR="/sources"
PKG="gettext-0.26"
TARBALL="$SRC_DIR/$PKG.tar.xz"

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

# Configuring examples brakes the build
rm -rf ./gettext-tools/examples/*
echo -e "all:\n\t@true" > ./gettext-tools/examples/Makefile

echo "Configuring Gettext (minimal build)..."
./configure --disable-shared

echo "Building Gettext..."
make

echo "Installing msgfmt, msgmerge, xgettext..."
cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin

echo "Cleaning up..."
cd "$SRC_DIR"
rm -rf "$PKG"

echo "Gettext (minimal) Installed Successfully"
