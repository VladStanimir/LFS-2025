#!/usr/bin/env bash

set -e

echo "LFS: Glibc - Temporary C Library (5.5)"

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
PKG="glibc-2.42"
TARBALL="$SRC_DIR/$PKG.tar.xz"
PATCH="$SRC_DIR/glibc-2.42-fhs-1.patch"

# Verify required files exist
for f in "$TARBALL" "$PATCH"; do
    if [ ! -f "$f" ]; then
        echo "ERROR: Missing required file: $f"
        exit 1
    fi
done

cd "$SRC_DIR"

echo "Extracting $PKG..."
rm -rf "$PKG"
tar xf "$TARBALL"
cd "$PKG"

echo "Applying FHS patch..."
patch -Np1 -i "$PATCH"

echo "Creating required dynamic loader symlinks..."
case $(uname -m) in
    i?86)
        ln -sfv ld-linux.so.2 $LFS/lib/ld-lsb.so.3
        ;;
    x86_64)
        ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64
        ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3
        ;;
esac

echo "Creating build directory..."
mkdir -v build
cd build

echo "Creating configparms (rootsbindir)..."
echo "rootsbindir=/usr/sbin" > configparms

echo "Configuring Glibc..."
../configure \
    --prefix=/usr \
    --host=$LFS_TGT \
    --build=$(../scripts/config.guess) \
    --disable-nscd \
    libc_cv_slibdir=/usr/lib \
    --enable-kernel=5.4

echo "Building Glibc..."
make

echo "Installing Glibc into $LFS..."
make DESTDIR=$LFS install

echo "Fixing hardcoded path in ldd..."
sed '/RTLDLIST=/s@/usr@@g' -i $LFS/usr/bin/ldd

echo "Performing toolchain sanity checks..."

echo 'int main(){}' > dummy.c

$LFS_TGT-gcc dummy.c -Wl,--verbose &> dummy.log

echo "Checking interpreter..."
if ! readelf -l a.out | grep -q ": /lib"; then
    echo "ERROR: dynamic linker path incorrect!"
    exit 1
fi

echo "Checking startfiles..."
grep -E -o "$LFS/lib.*/S?crt[1in].*succeeded" dummy.log

echo "Checking correct header paths..."
grep -B3 "^ $LFS/usr/include" dummy.log

echo "Checking correct library search paths..."
grep 'SEARCH.*/usr/lib' dummy.log | sed 's|; |\n|g'

echo "Checking correct libc selection..."
grep "/lib.*/libc.so.6 " dummy.log

echo "Checking dynamic linker..."
grep found dummy.log

echo "Cleaning up test files..."
rm -v dummy.c a.out dummy.log

echo "Cleaning up build directory..."
cd "$SRC_DIR"
rm -rf "$PKG"

echo "Glibc Temporary Install Completed Successfully"
