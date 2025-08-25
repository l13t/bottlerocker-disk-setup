# Bottlerocket Disk Setup

Automatically discovers, formats, and mounts unformatted disks on Bottlerocket nodes.

## What it does

- Finds unformatted disks (excludes root/boot disks)
- Formats them with XFS filesystem
- Generates meaningful labels (`nvme-2`, `disk-b`, etc.)
- Mounts at `/mnt/<label>` paths

## Usage

### As Bottlerocket Host Container

```bash
apiclient set --json '{"host-containers": {"disk-setup": {"enabled": true,"superpowered": true,"source": "ghcr.io/l13t/bottlerocker-disk-setup:latest"}}}'
```

### Manual Docker Run

```bash
docker run --rm --privileged \
  -v /dev:/dev \
  -v /mnt:/mnt \
  ghcr.io/l13t/bottlerocker-disk-setup:latest
```

## Example Output

```text
Found unformatted disk: /dev/nvme2n1
=== Processing /dev/nvme2n1 ===
Generated label: nvme-2
Formatting /dev/nvme2n1 with XFS and label 'nvme-2'...
Mounting /dev/nvme2n1 at /mnt/nvme-2...
Successfully formatted and mounted /dev/nvme2n1 with label 'nvme-2' at /mnt/nvme-2
```

## Safety Features

- Excludes root disks (`nvme0n1`, `sda`, etc.)
- Only processes unformatted disks
- Continues if individual disks fail
- Detailed logging for troubleshooting

⚠️ **WARNING**: This tool formats disks. Test in non-production first.
