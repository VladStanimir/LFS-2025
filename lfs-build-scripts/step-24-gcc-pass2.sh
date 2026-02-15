#!/usr/bin/env bash
set -e

echo "LFS: GCC - Pass 2 (Chapter 6.18)"

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

GMP="$SRC_DIR/gmp-6.3.0.tar.xz"
MPFR="$SRC_DIR/mpfr-4.2.2.tar.xz"
MPC="$SRC_DIR/mpc-1.3.1.tar.gz"

# Ensure all tarballs exist
for f in "$TARBALL" "$GMP" "$MPFR" "$MPC"; do
    if [ ! -f "$f" ]; then
        echo "ERROR: Missing required source: $f"
        exit 1
    fi
done

cd "$SRC_DIR"

# Cleanup previous extraction
echo "Cleaning previous $PKG build..."
rm -rf "$PKG"

echo "Extracting $PKG..."
tar xf "$TARBALL"
cd "$PKG"

echo "Extracting and embedding MPFR..."
tar xf "$MPFR"
mv -v mpfr-* mpfr

echo "Extracting and embedding GMP..."
tar xf "$GMP"
mv -v gmp-* gmp

echo "Extracting and embedding MPC..."
tar xf "$MPC"
mv -v mpc-* mpc

echo "Applying threading header fix for Pass 2..."
sed '/thread_header =/s/@.*@/gthr-posix.h/' \
    -i libgcc/Makefile.in libstdc++-v3/include/Makefile.in

echo "Fixing 64-bit library directory naming (x86_64 only)..."
case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64
  ;;
esac

echo "Creating build directory..."
mkdir -v build
cd build

echo "Configuring GCC Pass 2..."

../configure                   \
    --build=$(../config.guess) \
    --host=$LFS_TGT            \
    --target=$LFS_TGT          \
    --prefix=/usr              \
    --with-build-sysroot=$LFS  \
    --enable-default-pie       \
    --enable-default-ssp       \
    --disable-nls              \
    --disable-multilib         \
    --disable-libatomic        \
    --disable-libgomp          \
    --disable-libquadmath      \
    --disable-libsanitizer     \
    --disable-libssp           \
    --disable-libvtv           \
    --enable-languages=c,c++   \
    LDFLAGS_FOR_TARGET=-L$PWD/$LFS_TGT/libgcc

echo "Building GCC Pass 2..."
make

echo "Installing GCC Pass 2..."
make DESTDIR=$LFS install

echo "Creating 'cc' symlink..."
ln -sv gcc $LFS/usr/bin/cc

echo "Cleaning up..."

cd "$SRC_DIR"
rm -rf "$PKG"

echo "GCC Pass 2 Completed Successfully"
