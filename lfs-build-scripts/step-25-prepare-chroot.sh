#!/usr/bin/env bash
set -e

echo "LFS: Preparing Chroot Environment (Chapters 7.2 – 7.3)"

# Safety checks
if [ "$(whoami)" != "lfs" ]; then
    echo "ERROR: This script must be run as user 'lfs'."
    exit 1
fi

if [ -z "$LFS" ]; then
    echo "ERROR: \$LFS is not set."
    exit 1
fi

echo "Changing ownership of LFS directories (Chapter 7.2)..."
sudo chown --from lfs -R root:root $LFS/{usr,var,etc,tools}

case "$(uname -m)" in
  x86_64)
    sudo chown -R root:root $LFS/lib64
  ;;
esac

echo "Cleaning stale mount points..."

# Unmount if mounted
for mp in dev/pts dev proc sys run; do
    if mountpoint -q "$LFS/$mp"; then
        echo "Unmounting stale $LFS/$mp..."
        sudo umount -l "$LFS/$mp"
    fi
done

echo "Removing old mount directories..."
sudo rm -rf $LFS/dev $LFS/proc $LFS/sys $LFS/run

echo "Recreating fresh mount directories..."
sudo mkdir -pv $LFS/{dev,proc,sys,run}

echo "Mounting /dev..."
sudo mountpoint -q $LFS/dev || sudo mount -v --bind /dev $LFS/dev

echo "Mounting devpts..."
sudo mountpoint -q $LFS/dev/pts || \
sudo mount -vt devpts devpts -o gid=5,mode=0620 $LFS/dev/pts

echo "Mounting proc..."
sudo mountpoint -q $LFS/proc || sudo mount -vt proc proc $LFS/proc

echo "Mounting sysfs..."
sudo mountpoint -q $LFS/sys || sudo mount -vt sysfs sysfs $LFS/sys

echo "Mounting tmpfs on /run..."
sudo mountpoint -q $LFS/run || sudo mount -vt tmpfs tmpfs $LFS/run

echo "Handling /dev/shm..."
if [ -h $LFS/dev/shm ]; then
    sudo install -v -d -m 1777 $LFS$(realpath /dev/shm)
else
    sudo mountpoint -q $LFS/dev/shm || \
    sudo mount -vt tmpfs -o nosuid,nodev tmpfs $LFS/dev/shm
fi

echo "Verifying mounts..."
mount | grep "$LFS"

echo "Chroot mount environment ready."
