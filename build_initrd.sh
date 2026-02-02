#!/bin/bash

###############################################################################
#                   🪔 Lamp OS - Initrd Builder Script
#                   
# This script creates a complete initrd system with:
# - Basic filesystem structure
# - BusyBox integration
# - Essential utilities
# - Init process
#
# Usage: ./build_initrd.sh
###############################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
INITRD_DIR="initrd"
BUSYBOX_VERSION="1.35.0"
BUSYBOX_URL="https://busybox.net/downloads/binaries/${BUSYBOX_VERSION}-x86_64-linux-musl/busybox"

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         🪔 Lamp OS - Initrd Builder v1.0              ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"

# Function to print status
status() {
    echo -e "${GREEN}✓${NC} $1"
}

error() {
    echo -e "${RED}✗${NC} $1"
    exit 1
}

warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Step 1: Create filesystem structure
echo -e "\n${BLUE}Step 1: Creating filesystem structure...${NC}"
cd "$INITRD_DIR" 2>/dev/null || error "Initrd directory not found! Create it first with: mkdir -p initrd"

# Remove old structure if exists
if [ -d ".git" ]; then
    warning "Git directory detected, preserving..."
else
    rm -rf * 2>/dev/null || true
fi

# Create essential directories
mkdir -p \
    bin sbin \
    lib lib/x86_64-linux-musl \
    etc etc/init.d \
    dev proc sys root tmp \
    opt/lamp-gui \
    home/user \
    usr/bin usr/sbin usr/lib \
    var/log var/run \
    doc

chmod 1777 tmp
status "Filesystem structure created"

# Step 2: Download and install BusyBox
echo -e "\n${BLUE}Step 2: Setting up BusyBox...${NC}"

if [ -f "bin/busybox" ]; then
    status "BusyBox already exists, skipping download"
else
    echo "Downloading BusyBox ${BUSYBOX_VERSION}..."
    if wget -q --show-progress "$BUSYBOX_URL" -O bin/busybox 2>/dev/null; then
        chmod +x bin/busybox
        status "BusyBox downloaded and installed"
    else
        error "Failed to download BusyBox. Check internet connection."
    fi
fi

# Step 3: Create BusyBox symlinks
echo -e "\n${BLUE}Step 3: Creating BusyBox symlinks...${NC}"

cd bin

# Use BusyBox's built-in installer to create symlinks reliably
if ./busybox --install -s . >/dev/null 2>&1; then
    status "BusyBox applets installed via --install"
else
    # Fallback: try basic sh/init links if --install not supported
    warning "BusyBox --install failed; falling back to manual links"
    ln -sf busybox sh || true
    ln -sf busybox init || true
    status "Created fallback BusyBox links"
fi

# Ensure essential commands exist at top-level paths
cd ..
ln -sf busybox bin/sh || true
ln -sf busybox bin/init || true

# Step 4: Create init script
echo -e "\n${BLUE}Step 4: Creating init process...${NC}"

cat > init << 'INIT_EOF'
#!/bin/sh

# 🪔 Lamp OS - Init Process

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║                                                        ║"
echo "║          🪔 Welcome to Lamp OS Initialization          ║"
echo "║                                                        ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Set up environment
export PATH=/bin:/sbin:/usr/bin:/usr/sbin
export LD_LIBRARY_PATH=/lib:/usr/lib
export HOME=/root
export TERM=linux

echo "[*] Mounting filesystems..."

# Mount essential filesystems
mount -t devtmpfs -o size=10M,nr_inodes=248418,mode=755 none /dev 2>/dev/null || \
mount -t tmpfs -o size=10M,mode=755 none /dev
mkdir -p /dev/pts /dev/mqueue /dev/shm

mount -t devpts -o gid=4,mode=620 none /dev/pts 2>/dev/null || true
mount -t proc none /proc 2>/dev/null || true
mount -t sysfs none /sys 2>/dev/null || true
mount -t tmpfs -o mode=1777 none /dev/shm 2>/dev/null || true
mount -t tmpfs -o mode=1777 none /tmp 2>/dev/null || true
mount -t tmpfs -o mode=755 none /run 2>/dev/null || true

echo "[✓] Filesystems mounted"

# Set hostname
echo "lamp-os" > /proc/sys/kernel/hostname 2>/dev/null || true
echo "[✓] Hostname set to: lamp-os"

# Initialize devices
echo "[*] Creating device nodes..."
if [ ! -e /dev/console ]; then
    mknod /dev/console c 5 1 2>/dev/null || true
fi
if [ ! -e /dev/null ]; then
    mknod /dev/null c 1 3 2>/dev/null || true
fi
if [ ! -e /dev/zero ]; then
    mknod /dev/zero c 1 5 2>/dev/null || true
fi
if [ ! -e /dev/tty ]; then
    mknod /dev/tty c 5 0 2>/dev/null || true
fi
if [ ! -e /dev/random ]; then
    mknod /dev/random c 1 8 2>/dev/null || true
fi
if [ ! -e /dev/urandom ]; then
    mknod /dev/urandom c 1 9 2>/dev/null || true
fi

echo "[✓] Device nodes created"

# Display system info
echo "[*] System Information:"
echo "    Kernel: $(uname -r 2>/dev/null || echo 'Unknown')"
echo "    CPU Cores: $(grep -c '^processor' /proc/cpuinfo 2>/dev/null || echo '?')"
echo "    Memory: $(free -h 2>/dev/null | grep Mem | awk '{print $2}' || echo '?')"

echo ""
echo "════════════════════════════════════════════════════════"
echo "[✓] Lamp OS boot complete!"
echo "════════════════════════════════════════════════════════"
echo ""

# Check if GUI is available
if [ -f /opt/lamp-gui/lamp-gui ]; then
    echo "[*] Starting Lamp OS GUI..."
    exec /opt/lamp-gui/lamp-gui 2>/dev/null || \
    exec /bin/sh -i -l
else
    echo "[*] GUI not found. Starting interactive shell..."
    echo ""
    echo "Available commands:"
    /bin/busybox --list-all 2>/dev/null | head -20
    echo "... and more (type 'busybox --list-all' for full list)"
    echo ""
    exec /bin/sh -i -l
fi
INIT_EOF

chmod +x init
status "Init process created"

# Step 5: Create essential config files
echo -e "\n${BLUE}Step 5: Creating configuration files...${NC}"

# Create passwd file
cat > etc/passwd << 'EOF'
root:x:0:0:root:/root:/bin/sh
nobody:x:65534:65534:nobody:/nonexistent:/bin/false
EOF

# Create group file
cat > etc/group << 'EOF'
root:x:0:
nogroup:x:65534:
EOF

# Create hostname
echo "lamp-os" > etc/hostname

# Create hosts
cat > etc/hosts << 'EOF'
127.0.0.1   localhost lamp-os
::1         localhost
EOF

# Create issue (login banner)
cat > etc/issue << 'EOF'

╔════════════════════════════════════════════════════════╗
║                                                        ║
║              🪔 Welcome to Lamp OS v1.0               ║
║                                                        ║
║  A lightweight Linux OS built with GRUB, Linux 6.6   ║
║  and BusyBox for embedded and education purposes     ║
║                                                        ║
║  Homepage: https://github.com/lamp-os               ║
║  Docs:     See /doc directory                        ║
║                                                        ║
╚════════════════════════════════════════════════════════╝

EOF

# Create fstab
cat > etc/fstab << 'EOF'
# <file system>  <mount point>  <type>  <options>  <dump>  <pass>
devtmpfs         /dev           devtmpfs defaults  0       0
proc             /proc          proc    defaults  0       0
sysfs            /sys           sysfs   defaults  0       0
tmpfs            /tmp           tmpfs   defaults  0       0
tmpfs            /run           tmpfs   defaults  0       0
EOF

# Create inittab
cat > etc/inittab << 'EOF'
::sysinit:/etc/init.d/rcS
::respawn:/sbin/getty 38400 tty1
EOF

status "Configuration files created"

# Step 6: Create init.d scripts
echo -e "\n${BLUE}Step 6: Creating init.d startup scripts...${NC}"

cat > etc/init.d/rcS << 'EOF'
#!/bin/sh
# Startup script

echo "Running startup scripts..."

# Optional: Add more startup logic here
# Example: mount additional filesystems, start services, etc.

exit 0
EOF

chmod +x etc/init.d/rcS
status "Startup scripts created"

# Step 7: Copy libraries (if available)

# Create documentation
cat > doc/README.md << 'EOF'
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
EOF

status "Documentation created"
echo -e "\n${BLUE}Step 7: Copying essential libraries...${NC}"

# Function to copy library
copy_lib() {
    local lib=$1
    if [ -f "$lib" ]; then
        cp "$lib" lib/ 2>/dev/null && return 0
    fi
    return 1
}

# Try to find and copy musl libc
for musl_path in /lib/x86_64-linux-musl /lib64 /lib /usr/lib; do
    if [ -f "$musl_path/libc.so" ] || [ -f "$musl_path/ld-musl-x86_64.so.1" ]; then
        cp "$musl_path/"*.so* lib/ 2>/dev/null || true
        status "Copied libraries from $musl_path"
        break
    fi
done

# Try copying ld-linux
for ld_path in /lib64 /lib /usr/lib; do
    if [ -f "$ld_path/ld-linux-x86-64.so.2" ]; then
        cp "$ld_path/ld-linux-x86-64.so.2" lib/ 2>/dev/null || true
    fi
done

# Step 7b: Add additional utilities
echo -e "\n${BLUE}Step 7b: Adding additional utilities...${NC}"

# Try to add common utilities if available
for cmd in wget curl nc netcat ping dhcpcd ntpd; do
    if command -v "$cmd" >/dev/null 2>&1; then
        cp "$(command -v $cmd)" bin/ 2>/dev/null || ln -sf busybox "bin/$cmd" 2>/dev/null || true
        status "Added utility: $cmd"
    fi
done

# Create common aliases
ln -sf busybox bin/wget 2>/dev/null || true
ln -sf busybox bin/curl 2>/dev/null || true
ln -sf busybox bin/nc 2>/dev/null || true
status "Created utility symlinks"

# Step 8: Create manifest
echo -e "\n${BLUE}Step 8: Creating manifest...${NC}"

cat > MANIFEST.txt << 'EOF'
Lamp OS - Initrd System Manifest
=================================

Structure:
- bin/        : Essential executables (busybox, sh, etc.)
- sbin/       : System binaries
- lib/        : System libraries
- etc/        : Configuration files
- dev/        : Device files (created at boot)
- proc/       : Kernel filesystem (mounted at boot)
- sys/        : System filesystem (mounted at boot)
- opt/        : Optional applications
- root/       : Root user home
- home/       : User home directories
- tmp/        : Temporary files

Init Process:
- Mounts filesystems (dev, proc, sys, tmp)
- Creates essential device nodes
- Displays system information
- Starts GUI or interactive shell

BusyBox Utilities:
- All standard Unix utilities via busybox symlinks
- Shell (sh) for scripting
- Basic system administration tools

EOF

status "Manifest created"

# Step 9: Generate statistics
echo -e "\n${BLUE}Step 9: Generating statistics...${NC}"

total_size=$(du -sh . | awk '{print $1}')
file_count=$(find . -type f | wc -l)
dir_count=$(find . -type d | wc -l)
symlink_count=$(find . -type l | wc -l)

cat > STATISTICS.txt << EOF
Lamp OS Initrd Statistics
==========================
Generated: $(date)

Filesystem:
- Total size: $total_size
- Regular files: $file_count
- Directories: $dir_count
- Symlinks: $symlink_count

Structure:
- Init executable: $([ -f init ] && echo "✓" || echo "✗")
- BusyBox: $([ -f bin/busybox ] && echo "✓" || echo "✗")
- Config files: $([ -f etc/passwd ] && echo "✓" || echo "✗")
- Device nodes: $([ -e dev/console ] && echo "✓" || echo "✗")

Ready to build ISO: $([ -f init ] && [ -f bin/busybox ] && echo "YES ✓" || echo "NO ✗")
EOF

status "Statistics generated"

# Step 10: Create CPIO archive
echo -e "\n${BLUE}Step 10: Creating CPIO archive...${NC}"

# Create CPIO archive without a top-level 'initrd' directory prefix
if [ -d "iso/boot" ]; then
    echo "Creating initrd.img from CPIO (no top-level prefix)..."
    (cd initrd && find . -print0 | cpio -0oH newc 2>/dev/null) | gzip -9 > iso/boot/initrd.img
    initrd_size=$(ls -lh iso/boot/initrd.img | awk '{print $5}')
    status "CPIO archive created: $initrd_size"
else
    warning "iso/boot directory not found. Skipping CPIO creation."
    warning "Run this after creating the ISO directory structure."
fi

# Final summary
echo -e "\n${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║               ✓ Initrd Build Complete!                 ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"

echo ""
echo -e "${GREEN}Initrd Statistics:${NC}"
echo "  Total size: $total_size"
echo "  Files: $file_count"
echo "  Directories: $dir_count"
echo "  Symlinks: $symlink_count"
echo ""
echo -e "${GREEN}Next steps:${NC}"
echo "  1. Ensure your Linux kernel is built (arch/x86_64/boot/bzImage)"
echo "  2. Copy kernel: cp kernel/linux-6.6/arch/x86_64/boot/bzImage iso/boot/vmlinuz"
echo "  3. Run: ./create_iso.sh"
echo "  4. Test: qemu-system-x86_64 -cdrom lamp-os.iso -m 512"
echo ""
