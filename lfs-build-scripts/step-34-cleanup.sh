#!/usr/bin/env bash
set -e

echo "LFS Ch.7: Cleaning Temporary System - Chapter 7.13.1"

# Must be root inside chroot
if [ "$(id -u)" != "0" ]; then
    echo "ERROR: This script must be run as root inside chroot."
    exit 1
fi

echo "Removing temporary documentation..."
rm -rf /usr/share/{info,man,doc}/*

echo "Removing libtool .la files..."
find /usr/{lib,libexec} -name "*.la" -delete

echo "Removing /tools directory..."
rm -rf /tools

echo "Temporary system cleaned successfully."
echo "Exiting chroot environment now..."

exit
