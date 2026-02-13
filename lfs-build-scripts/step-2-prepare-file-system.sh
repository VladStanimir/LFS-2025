#!/usr/bin/env bash

set -e

# Ensure LFS is set
if [ -z "$LFS" ]; then
    echo "ERROR: \$LFS is not set! Run: export LFS=/mnt/lfs"
    exit 1
fi

echo "Preparing LFS Chapter 4 environment..."
echo "Using LFS directory: $LFS"

echo "Creating limited directory layout in \$LFS..."

sudo mkdir -pv $LFS/{etc,var} $LFS/usr/{bin,lib,sbin}

for i in bin lib sbin; do
  sudo ln -svf usr/$i $LFS/$i
done

case $(uname -m) in
  x86_64) 
    sudo mkdir -pv $LFS/lib64
    ;;
esac

sudo mkdir -pv $LFS/tools

echo "Ensuring ownership for lfs user..."

sudo chown -v lfs $LFS/{usr{,/*},var,etc,tools}
case $(uname -m) in
  x86_64) sudo chown -v lfs $LFS/lib64 ;;
esac

echo "Chapter 4 preparation complete."
