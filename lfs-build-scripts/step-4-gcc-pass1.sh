#!/usr/bin/env bash

set -e

echo "LFS: GCC Pass 1 (5.3)"

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
PKG="gcc-15.2.0"
TARBALL="$SRC_DIR/$PKG.tar.xz"

# Required dependencies
MPFR="$SRC_DIR/mpfr-4.2.2.tar.xz"
GMP="$SRC_DIR/gmp-6.3.0.tar.xz"
MPC="$SRC_DIR/mpc-1.3.1.tar.gz"

# Check tarballs
for f in "$TARBALL" "$MPFR" "$GMP" "$MPC"; do
    if [ ! -f "$f" ]; then
        echo "ERROR: Missing tarball: $f"
        exit 1
    fi
done

cd "$SRC_DIR"

echo "Extracting $PKG..."
rm -rf "$PKG"
tar xf "$TARBALL"
cd "$PKG"

echo "Extracting MPFR..."
tar xf "$MPFR"
mv -v mpfr-* mpfr

echo "Extracting GMP..."
tar xf "$GMP"
mv -v gmp-* gmp

echo "Extracting MPC..."
tar xf "$MPC"
mv -v mpc-* mpc

# x86_64 lib64 → lib fix
case $(uname -m) in
    x86_64)
        sed -e '/m64=/s/lib64/lib/' \
            -i.orig gcc/config/i386/t-linux64
        ;;
esac

echo "Creating build directory..."
mkdir -v build
cd build

echo "Configuring GCC Pass 1..."
../configure \
    --target=$LFS_TGT \
    --prefix=$LFS/tools \
    --with-glibc-version=2.42 \
    --with-sysroot=$LFS \
    --with-newlib \
    --without-headers \
    --enable-default-pie \
    --enable-default-ssp \
    --disable-nls \
    --disable-shared \
    --disable-multilib \
    --disable-threads \
    --disable-libatomic \
    --disable-libgomp \
    --disable-libquadmath \
    --disable-libssp \
    --disable-libvtv \
    --disable-libstdcxx \
    --enable-languages=c,c++

echo "Building GCC Pass 1..."
make

echo "Installing GCC Pass 1..."
make install

echo "Cleaning up..."
cd "$SRC_DIR"
rm -rf "$PKG"

echo "GCC Pass 1 Completed Successfully"
