#!/usr/bin/env bash
set -e

echo "LFS: Entering the Chroot Environment (Chapters 7.4)"

# Safety checks
if [ "$(whoami)" != "lfs" ]; then
    echo "ERROR: This script must be run as user 'lfs'."
    exit 1
fi

if [ -z "$LFS" ]; then
    echo "ERROR: \$LFS is not set."
    exit 1
fi

echo "Binding build scripts into chroot..."
sudo mkdir -pv $LFS/root/lfs-build-scripts
sudo mount --bind /home/lfs/lfs-build-scripts $LFS/root/lfs-build-scripts

echo "Entering chroot (Chapter 7.4)..."

exec sudo chroot "$LFS" /usr/bin/env -i \
  HOME=/root \
  TERM="$TERM" \
  PATH=/usr/bin:/usr/sbin \
  MAKEFLAGS="-j$(nproc)" \
  TESTSUITEFLAGS="-j$(nproc)" \
  /bin/bash --login -c '
    export PS1="(lfs chroot) \u:\w\$ "
    export MAKEFLAGS TESTSUITEFLAGS TERM PATH HOME
    cd /root
    exec /bin/bash --login
'
