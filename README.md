# MegaCLI Docker Image

Docker image for monitoring and managing LSI/AVAGO MegaRAID controllers on Linux systems.

## Supported Controllers

- LSI MegaRAID SAS (all models)
- AVAGO MegaRAID (3108, 3008, etc.)
- Dell PERC H700/H710/H730/H740/H750
- Any controller supported by MegaCLI 8.07.14

## Available Tags

- `matthijsdiemel/megacli:latest` - Direct MegaCLI commands (management & monitoring)
- `matthijsdiemel/megacli:status` - Formatted status view (monitoring only)

## Quick Start

### Status Monitoring

```bash
docker pull matthijsdiemel/megacli:status
docker run --rm -it --privileged matthijsdiemel/megacli:status
```

### Direct MegaCLI Commands

```bash
docker pull matthijsdiemel/megacli:latest
docker run --rm -it --privileged matthijsdiemel/megacli:latest -AdpAllInfo -aALL
```

## Common Commands

### Adapter Information

```bash
# Show all adapter info
docker run --rm -it --privileged matthijsdiemel/megacli:latest -AdpAllInfo -aALL

# Count adapters
docker run --rm -it --privileged matthijsdiemel/megacli:latest -adpCount

# Show adapter properties
docker run --rm -it --privileged matthijsdiemel/megacli:latest -AdpGetProp -BatWarnDsbl -aALL
```

### Physical Drive Information

```bash
# List all physical drives
docker run --rm -it --privileged matthijsdiemel/megacli:latest -PDList -aALL

# Show drive details for specific drive
docker run --rm -it --privileged matthijsdiemel/megacli:latest -PDInfo -PhysDrv [E:S] -aALL

# Locate drive (blink LED)
docker run --rm -it --privileged matthijsdiemel/megacli:latest -PdLocate -start -PhysDrv [0:8] -a0

# Stop locating drive
docker run --rm -it --privileged matthijsdiemel/megacli:latest -PdLocate -stop -PhysDrv [0:8] -a0
```

### Logical Drive Information

```bash
# List all logical drives
docker run --rm -it --privileged matthijsdiemel/megacli:latest -LDInfo -Lall -aALL

# Show virtual drive info
docker run --rm -it --privileged matthijsdiemel/megacli:latest -LDGetProp -DskCache -L0 -a0
```

### Battery Backup Unit (BBU)

```bash
# Show BBU status
docker run --rm -it --privileged matthijsdiemel/megacli:latest -AdpBbuCmd -aALL

# Get BBU design info
docker run --rm -it --privileged matthijsdiemel/megacli:latest -AdpBbuCmd -GetBbuDesignInfo -aALL
```

### Configuration Display

```bash
# Show full RAID configuration
docker run --rm -it --privileged matthijsdiemel/megacli:latest -CfgDsply -aALL

# Show enclosure information
docker run --rm -it --privileged matthijsdiemel/megacli:latest -EncInfo -aALL
```

### Rebuild Operations

```bash
# Show rebuild progress
docker run --rm -it --privileged matthijsdiemel/megacli:latest -PDRbld -ShowProg -PhysDrv [E:S] -aALL

# Start manual rebuild
docker run --rm -it --privileged matthijsdiemel/megacli:latest -PDRbld -Start -PhysDrv [E:S] -aALL

# Stop rebuild
docker run --rm -it --privileged matthijsdiemel/megacli:latest -PDRbld -Stop -PhysDrv [E:S] -aALL
```

## Use Cases

### Daily Monitoring

Use the `:status` tag for quick health checks:

```bash
# Add to cron or monitoring script
docker run --rm --privileged matthijsdiemel/megacli:status
```

### Troubleshooting Failed Drives

```bash
# 1. Check which drive failed
docker run --rm -it --privileged matthijsdiemel/megacli:latest -PDList -aALL | grep -i failed

# 2. Locate the physical drive (blinks LED)
docker run --rm -it --privileged matthijsdiemel/megacli:latest -PdLocate -start -PhysDrv [E:S] -a0

# 3. Get detailed drive info
docker run --rm -it --privileged matthijsdiemel/megacli:latest -PDInfo -PhysDrv [E:S] -aALL
```

### Checking Rebuild Progress

```bash
# Monitor rebuild status
docker run --rm -it --privileged matthijsdiemel/megacli:latest -PDRbld -ShowProg -PhysDrv [E:S] -aALL

# Watch continuously (requires watch command on host)
watch -n 5 'docker run --rm --privileged matthijsdiemel/megacli:latest -PDRbld -ShowProg -PhysDrv [E:S] -aALL'
```

### Identifying Hardware

```bash
# Get controller model and firmware version
docker run --rm -it --privileged matthijsdiemel/megacli:latest -AdpAllInfo -aALL | grep -i "product name\|firmware"

# Check serial numbers
docker run --rm -it --privileged matthijsdiemel/megacli:latest -AdpAllInfo -aALL | grep -i serial
```

## Interactive Shell

For multiple commands or exploration:

```bash
docker run --rm -it --privileged matthijsdiemel/megacli:latest bash

# Inside container:
megacli -help
megacli -AdpAllInfo -aALL
megacli -PDList -aALL
megaclisas-status
```

## Command Format

MegaCLI uses the format: `[E:S]` where:
- `E` = Enclosure ID (usually 0)
- `S` = Slot number (0-based)

Example: `[0:5]` means Enclosure 0, Slot 5

## Requirements

- Docker installed on host
- `--privileged` flag required for hardware access
- Root/sudo access on host system

## Building from Source

```dockerfile
FROM debian:bullseye-slim

RUN apt-get -qq update \
    && apt-get -qq install -y --no-install-recommends \
        ca-certificates \
        gnupg \
        wget \
    && wget https://hwraid.le-vert.net/debian/hwraid.le-vert.net.gpg.key \
    && apt-key add hwraid.le-vert.net.gpg.key \
    && echo "deb http://hwraid.le-vert.net/debian bullseye main" \
        >> /etc/apt/sources.list \
    && rm -rf hwraid.le-vert.net.gpg.key

RUN apt-get -qq update \
    && apt-get -qq install -y --no-install-recommends \
        megaclisas-status \
    && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/usr/sbin/megacli"]
CMD ["-help"]
```

## Version Information

- **Base OS**: Debian Bullseye
- **MegaCLI Version**: 8.07.14
- **megaclisas-status**: 0.18

## License

This image packages open-source tools:
- MegaCLI: LSI Corporation
- megaclisas-status: GPL (hwraid.le-vert.net)

## Support

For issues with:
- **Docker image**: Open an issue on GitHub
- **MegaCLI tool**: Refer to LSI/AVAGO documentation
- **Hardware issues**: Contact your hardware vendor

## Related Images

- `matthijsdiemel/smartmontools:latest` - For non-RAID controllers (AHCI, Marvell, NVMe)
