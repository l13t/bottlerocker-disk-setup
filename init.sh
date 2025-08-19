#!/bin/bash
set -euo pipefail

# Find non-root NVMe disks (ignore nvme0n1 since it's root)
DISKS=$(lsblk -ndo NAME,TYPE | awk '$2=="disk"{print "/dev/"$1}' | grep -ve "nvme[01]n1")

for _DISK in $DISKS; do
  DISK=$($_DISK | sed "s|/dev/|/.bottlerocket/rootfs/dev/|")
  echo "Processing $DISK..."

  # Skip if already has a filesystem
  if blkid "$DISK" >/dev/null 2>&1; then
    echo "$DISK already formatted, skipping mkfs."
  else
    echo "Formatting $DISK with XFS..."
    mkfs.xfs -b size=4096 -s size=4096 -m crc=0 -L DATA -f "$DISK"
  fi

  MOUNTPOINT="/local/data-$(basename "$DISK")"
  mkdir -p "$MOUNTPOINT"

  echo "Mounting $DISK at $MOUNTPOINT..."
  mount -o discard,noatime,noquota,logbufs=8,logbsize=64k "$DISK" "$MOUNTPOINT"
done

echo "All disks processed."
