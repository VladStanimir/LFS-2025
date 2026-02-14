#!/usr/bin/env bash
set -e

echo "LFS: Ncurses - Temporary System (Chapter 6.3)"

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
PKG="ncurses-6.5-20250809"
TARBALL="$SRC_DIR/$PKG.tgz"

# Required source check
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

echo "Building host tic (required for cross-build)"

mkdir -pv build
pushd build

../configure --prefix=$LFS/tools AWK=gawk
make -C include
make -C progs tic

install progs/tic $LFS/tools/bin

popd

echo "Configuring Ncurses for temporary system..."

./configure --prefix=/usr                \
            --host=$LFS_TGT              \
            --build=$(./config.guess)    \
            --mandir=/usr/share/man      \
            --with-manpage-format=normal \
            --with-shared                \
            --without-normal             \
            --with-cxx-shared            \
            --without-debug              \
            --without-ada                \
            --disable-stripping          \
            AWK=gawk

echo "Building Ncurses..."
make

echo "Installing Ncurses..."
make DESTDIR=$LFS install

echo "Creating libncurses.so symlink..."
ln -sv libncursesw.so $LFS/usr/lib/libncurses.so

echo "Fixing curses.h XOPEN macro..."
sed -e 's/^#if.*XOPEN.*$/#if 1/' \
    -i $LFS/usr/include/curses.h

echo "Cleaning up..."
cd "$SRC_DIR"
rm -rf "$PKG"

echo "Ncurses Temporary Install Completed Successfully"
