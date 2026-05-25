#!/usr/bin/env bash
set -e

echo "LFS Ch.7: Restore Temporary System - Chapter 7.13.3"

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

# Confirm backup archive exists
BACKUP="$LFS/sources/lfs-temp-tools-12.4.tar.xz"

if [ ! -f "$BACKUP" ]; then
    echo "ERROR: Backup archive not found: $BACKUP"
    exit 1
fi

# Delete existing LFS tree safely
echo "Deleting existing LFS tree at $LFS (excluding sources)..."
cd "$LFS"

# Only delete inside $LFS, never outside
find "$LFS" -mindepth 1 -maxdepth 1 ! -name sources -exec rm -rf {} +


# Extract backup archive (overwrite allowed)
echo "Restoring from backup archive..."
tar -xpf "$BACKUP" -C "$LFS"

echo "Restore completed successfully."
echo "Your LFS temporary system has been restored."

exit