#!/bin/bash
set -euo pipefail

DISK=/.bottlerocket/rootfs/dev/nvme2n1
BASE_MOUNT_POINT=/.bottlerocket/rootfs/mnt/data

if blkid "$DISK" >/dev/null 2>&1; then
  echo "$DISK already formatted, skipping mkfs."
else
  echo "Formatting $DISK with XFS..."
  mkfs.xfs -b size=4096 -s size=4096 -m crc=0 -L DATA -f "$DISK"
fi

mkdir -p "$BASE_MOUNT_POINT"
echo "Mounting $DISK at $BASE_MOUNT_POINT..."
mount -o discard,noatime,noquota,logbufs=8,logbsize=64k "$DISK" "$BASE_MOUNT_POINT"
