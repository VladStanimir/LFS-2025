#!/usr/bin/env bash
set -e

echo "LFS Ch.7: Util-linux - Chapter 7.12"

# Must be root inside chroot
if [ "$(id -u)" != "0" ]; then
    echo "ERROR: This script must be run as root inside chroot."
    exit 1
fi

SRC_DIR="/sources"
PKG="util-linux-2.41.1"
TARBALL="$SRC_DIR/$PKG.tar.xz"

if [ ! -f "$TARBALL" ]; then
    echo "ERROR: Missing tarball: $TARBALL"
    exit 1
fi

# FHS-compliant hwclock directory
echo "Creating /var/lib/hwclock..."
mkdir -pv /var/lib/hwclock

cd "$SRC_DIR"

echo "Cleaning previous $PKG build..."
rm -rf "$PKG"

echo "Extracting $PKG..."
tar xf "$TARBALL"
cd "$PKG"

echo "Configuring Util-linux..."
./configure --libdir=/usr/lib     \
            --runstatedir=/run    \
            --disable-chfn-chsh   \
            --disable-login       \
            --disable-nologin     \
            --disable-su          \
            --disable-setpriv     \
            --disable-runuser     \
            --disable-pylibmount  \
            --disable-static      \
            --disable-liblastlog2 \
            --without-python      \
            ADJTIME_PATH=/var/lib/hwclock/adjtime \
            --docdir=/usr/share/doc/util-linux-2.41.1

echo "Building Util-linux..."
make

echo "Installing Util-linux..."
make install

echo "Cleaning up..."
cd "$SRC_DIR"
rm -rf "$PKG"

echo "Util-linux Installed Successfully"
