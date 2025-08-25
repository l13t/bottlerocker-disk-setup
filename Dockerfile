FROM alpine:3.22

COPY setup-ephemeral-disks ./
RUN apk add xfsprogs e2fsprogs bash parted && \
	chmod +x ./setup-ephemeral-disks

ENTRYPOINT ["bash", "setup-ephemeral-disks"]
