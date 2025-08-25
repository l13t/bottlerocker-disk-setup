FROM alpine:3.22

COPY setup-ephemeral-disks ./
RUN apk add lsblk blkid xfsprogs e2fsprogs bash parted && \
	chmod +x ./setup-ephemeral-disks

ENTRYPOINT ["bash", "setup-ephemeral-disks"]
