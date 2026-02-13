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

echo "Preparing LFS user's shell environment..."

# Create .bash_profile
cat > ~/.bash_profile << "EOF"
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
EOF

# Create .bashrc
cat > ~/.bashrc << "EOF"
set +h
umask 022
LFS=/mnt/lfs
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
PATH=$LFS/tools/bin:$PATH
CONFIG_SITE=$LFS/usr/share/config.site
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE
EOF

echo "Setting MAKEFLAGS for parallel builds..."

cat >> ~/.bashrc << "EOF"
export MAKEFLAGS=-j$(nproc)
EOF

echo "Checking for /etc/bash.bashrc (must be disabled)..."

if [ -e /etc/bash.bashrc ]; then
    echo "Disabling /etc/bash.bashrc ..."
    sudo mv -v /etc/bash.bashrc /etc/bash.bashrc.NOUSE
else
    echo "/etc/bash.bashrc not present. OK."
fi

echo "Reloading your environment..."

source ~/.bash_profile

echo "Chapter 4 preparation complete."
echo "You are now ready to begin Chapter 5 (Binutils pass 1)."
