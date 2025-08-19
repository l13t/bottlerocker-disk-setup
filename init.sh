#!/usr/bin/env bash
set -ex

DISK=/.bottlerocket/rootfs/dev/nvme2n1
PARTITIONS_CREATED=/.bottlerocket/bootstrap-containers/current/created
BASE_MOUNT_POINT=/.bottlerocket/rootfs/mnt

# If the disk hasn't been partitioned, create the partitions and format them
if [ ! -f $PARTITIONS_CREATED ]; then
  parted -s $DISK mklabel gpt 1>/dev/null
  parted -s $DISK mkpart primary ext4 0% 100% 1>/dev/null
  mkfs.ext4 -F ${DISK}p1
  touch $PARTITIONS_CREATED
fi

mkdir -p $BASE_MOUNT_POINT/data

mount ${DISK}p1 $BASE_MOUNT_POINT/data
