#!/usr/bin/env bash
set -e

echo "LFS: Coreutils - Temporary System (Chapter 6.5)"

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
PKG="coreutils-9.7"
TARBALL="$SRC_DIR/$PKG.tar.xz"

# Verify tarball
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

echo "Configuring Coreutils..."

./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) \
            --enable-install-program=hostname \
            --enable-no-install-program=kill,uptime

echo "Building Coreutils..."
make

echo "Installing Coreutils into \$LFS..."
make DESTDIR=$LFS install

echo "Moving 'chroot' into /usr/sbin..."
mv -v $LFS/usr/bin/chroot $LFS/usr/sbin

echo "Fixing chroot manpage section..."
mkdir -pv $LFS/usr/share/man/man8
mv -v $LFS/usr/share/man/man1/chroot.1 $LFS/usr/share/man/man8/chroot.8
sed -i 's/"1"/"8"/' $LFS/usr/share/man/man8/chroot.8

echo "Cleaning up..."

cd "$SRC_DIR"
rm -rf "$PKG"

echo "Coreutils Temporary Install Completed Successfully"
