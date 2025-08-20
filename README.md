# Bottlerocket Disk Setup

A containerized tool for automatically discovering, formatting, and mounting NVMe disks on Bottlerocket nodes. This tool is designed to work with Amazon EC2 instances that have additional NVMe storage devices attached.

## Overview

This tool automatically:

- Discovers all NVMe disks (excluding the root disk `nvme0n1`)
- Formats discovered disks with XFS filesystem (if not already formatted)
- Mounts disks with optimized settings for performance
- Creates mount points under `/local/data-<disk-name>`

## Features

- **Safe operation**: Skips disks that are already formatted to prevent data loss
- **Performance optimized**: Uses XFS with specific block sizes and mount options
- **Bottlerocket compatible**: Designed specifically for Bottlerocket OS
- **Containerized**: Runs as a Docker container with necessary privileges

## Prerequisites

- Bottlerocket OS
- Docker runtime
- Root privileges (required for disk operations)
- Additional NVMe storage devices attached to the instance

## Quick Start

### Option 1: Run directly with Docker

```bash
# Build the container
docker build -t bottlerocket-disk-setup .

# Run with required privileges
docker run --rm --privileged \
  -v /dev:/dev \
  -v /local:/local \
  bottlerocket-disk-setup
```

### Option 2: Run as Kubernetes DaemonSet

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: disk-setup
  namespace: kube-system
spec:
  selector:
    matchLabels:
      app: disk-setup
  template:
    metadata:
      labels:
        app: disk-setup
    spec:
      hostNetwork: true
      hostPID: true
      containers:
      - name: disk-setup
        image: bottlerocket-disk-setup:latest
        securityContext:
          privileged: true
        volumeMounts:
        - name: dev
          mountPath: /dev
        - name: local
          mountPath: /local
      volumes:
      - name: dev
        hostPath:
          path: /dev
      - name: local
        hostPath:
          path: /local
      restartPolicy: Never
```

## Configuration

### XFS Format Settings

The tool formats disks with the following XFS parameters:

- **Block size**: 4096 bytes
- **Sector size**: 4096 bytes  
- **CRC**: Disabled (`-m crc=0`)
- **Label**: DATA
- **Force**: Yes (overwrites existing data)

### Mount Options

Disks are mounted with these optimized options:

- `discard`: Enables TRIM support for SSDs
- `noatime`: Improves performance by not updating access times
- `noquota`: Disables quota checking
- `logbufs=8`: Sets 8 log buffers for better performance
- `logbsize=64k`: Sets 64KB log buffer size

## Output

The tool provides detailed output for each operation:

```text
Processing /dev/nvme1n1...
Formatting /dev/nvme1n1 with XFS...
Mounting /dev/nvme1n1 at /local/data-nvme1n1...
Processing /dev/nvme2n1...
/dev/nvme2n1 already formatted, skipping mkfs.
Mounting /dev/nvme2n1 at /local/data-nvme2n1...
All disks processed.
```

## Safety Features

- **Root disk protection**: Automatically excludes `nvme0n1` (typically the root disk)
- **Format detection**: Skips formatting if a filesystem is already detected
- **Error handling**: Stops execution on any error (`set -euo pipefail`)

## Troubleshooting

### Common Issues

**No disks found**:

- Verify additional NVMe devices are attached to the instance
- Check that devices appear in `lsblk` output

**Permission denied**:

- Ensure the container runs with `--privileged` flag
- Verify `/dev` and `/local` volumes are mounted correctly

**Mount failures**:

- Check if mount points already exist and are in use
- Verify the XFS filesystem was created successfully

### Manual Verification

To verify the setup worked correctly:

```bash
# Check mounted filesystems
mount | grep /local/data

# Check disk usage
df -h /local/data-*

# List discovered disks
lsblk | grep nvme
```

## Development

### Building

```bash
docker build -t bottlerocket-disk-setup .
```

### Testing

Test on a development instance with additional NVMe storage:

```bash
# Dry run (add echo before commands in init.sh for testing)
docker run --rm --privileged \
  -v /dev:/dev \
  -v /local:/local \
  bottlerocket-disk-setup
```

## License

This project is provided as-is for use with Bottlerocket OS environments.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly on a non-production instance
5. Submit a pull request

## Security Considerations

⚠️ **WARNING**: This tool requires privileged access and can format disks. Use with caution.

- Only run on intended target instances
- Verify disk selection logic before deployment
- Test in non-production environments first
- Review the script before running in production

## Force API call to run disk-setup container

```bash
apiclient set --json '{"host-containers": {"disk-setup": {"enabled": true,"superpowered": true,"source": "ghcr.io/l13t/bottlerocker-disk-setup:latest"}}}'
```
