# Lamp OS Documentation

## Quick Start

Welcome to Lamp OS! This is a minimal Linux distribution built from source.

### System Information

- **Kernel**: Linux 6.6 (built from kernel.org sources)
- **Init System**: Custom shell script (BusyBox init)
- **Filesystem**: BusyBox-based initrd (RAM disk)
- **Bootloader**: GRUB 2.12

### Available Commands

All standard Unix utilities are available via BusyBox:

- File operations: ls, cd, mkdir, rm, cp, mv, cat, grep, find
- System: ps, top, free, uname, dmesg, mount, umount
- Networking: ping, ifconfig, wget, curl, nc, netstat
- Text processing: sed, awk, cut, tr, sort, uniq
- Archiving: tar, gzip, zip, unzip
- Shell scripting: sh, ash, bash (symlinked to busybox)

### Common Tasks

#### View system information
```
uname -a
cat /proc/cpuinfo
free -h
```

#### List available BusyBox applets
```
busybox --list-all
```

#### Mount filesystems
```
mount -t proc none /proc
mount -t sysfs none /sys
```

#### Test networking
```
ping 8.8.8.8
ifconfig eth0
```

### Directory Structure

- /bin         - Essential executables and BusyBox
- /etc         - Configuration files
- /dev         - Device files
- /proc        - Kernel filesystem
- /sys         - System filesystem
- /opt         - Optional applications (GUI, etc.)
- /doc         - Documentation

### For More Information

- BusyBox: https://busybox.net
- Linux: https://kernel.org
- GRUB: https://www.gnu.org/software/grub/

Built with ❤️ by Lamp OS Community
