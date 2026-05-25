#!/usr/bin/env bash
set -e

echo "LFS Ch.7: Backup Temporary System - Chapter 7.13.2"

# Auto-escalate to root if needed
if [ "$(id -u)" != "0" ]; then
    echo "Re-running script as root..."
    exec sudo LFS="$LFS" bash "$0" "$@"
fi

# Auto-set LFS if missing
if [ -z "$LFS" ]; then
    echo "LFS variable not set. Defaulting to /mnt/lfs"
    export LFS=/mnt/lfs
fi

# Safety checks
# Must not run inside chroot
if readlink /proc/1/root | grep -q "$LFS"; then
    echo "ERROR: This script must NOT be run inside the LFS chroot."
    exit 1
fi

# LFS must not be /
if [ "$LFS" = "/" ]; then
    echo "ERROR: LFS is '/', refusing to continue."
    exit 1
fi

# LFS must exist
if [ ! -d "$LFS" ]; then
    echo "ERROR: LFS directory does not exist: $LFS"
    exit 1
fi

# Unmount virtual filesystems
echo "Unmounting virtual filesystems if mounted..."

mountpoint -q $LFS/dev/shm && umount $LFS/dev/shm || true
mountpoint -q $LFS/dev/pts && umount $LFS/dev/pts || true
mountpoint -q $LFS/dev     && umount $LFS/dev     || true
mountpoint -q $LFS/proc    && umount $LFS/proc    || true
mountpoint -q $LFS/sys     && umount $LFS/sys     || true
mountpoint -q $LFS/run     && umount $LFS/run     || true

# Ensure enough free space
echo "Checking free disk space..."
FREE_MB=$(df -Pm "$LFS/sources" | awk 'NR==2 {print $4}')

if [ "$FREE_MB" -lt 1200 ]; then
    echo "ERROR: Not enough free space in $$LFS/sources (need at least 1200 MB)."
    exit 1
fi

# Create backup archive (overwrite allowed)
BACKUP="$LFS/sources/lfs-temp-tools-12.4.tar.xz"

echo "Creating backup archive at: $BACKUP"
echo "Existing file will be overwritten if present."

cd "$LFS"

rm -f "$BACKUP"

tar -cJpf "$BACKUP" --exclude=./sources .

echo "Backup completed successfully."
echo "Archive stored at: $BACKUP"

exit