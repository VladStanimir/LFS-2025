#!/usr/bin/env bash
set -e

echo "LFS Ch.7: Perl - Chapter 7.9"

# Must be root inside chroot
if [ "$(id -u)" != "0" ]; then
    echo "ERROR: This script must be run as root inside chroot."
    exit 1
fi

SRC_DIR="/sources"
PKG="perl-5.42.0"
TARBALL="$SRC_DIR/$PKG.tar.xz"

if [ ! -f "$TARBALL" ]; then
    echo "ERROR: Missing tarball: $TARBALL"
    exit 1
fi

cd "$SRC_DIR"

# Cleanup old source
echo "Cleaning previous $PKG build..."
rm -rf "$PKG"

echo "Extracting $PKG..."
tar xf "$TARBALL"
cd "$PKG"

echo "Configuring Perl..."
sh Configure -des                                         \
             -D prefix=/usr                               \
             -D vendorprefix=/usr                         \
             -D useshrplib                                \
             -D privlib=/usr/lib/perl5/5.42/core_perl     \
             -D archlib=/usr/lib/perl5/5.42/core_perl     \
             -D sitelib=/usr/lib/perl5/5.42/site_perl     \
             -D sitearch=/usr/lib/perl5/5.42/site_perl    \
             -D vendorlib=/usr/lib/perl5/5.42/vendor_perl \
             -D vendorarch=/usr/lib/perl5/5.42/vendor_perl

echo "Building Perl..."
make

echo "Installing Perl..."
make install

echo "Cleaning up..."
cd "$SRC_DIR"
rm -rf "$PKG"

echo "Perl Installed Successfully"
