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

# Project root (used for referencing assets)
PROJECT_ROOT="$(pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
INITRD_DIR="initrd"
# Allow cross-arch initrd build
TARGET_ARCH="${TARGET_ARCH:-x86_64}"
CROSS_COMPILE="${CROSS_COMPILE:-}"
BUSYBOX_VERSION="1.35.0"
# For non-x86_64 targets we will build BusyBox from source (using build_busybox.sh)
# Prebuilt binaries are used only for x86_64 as a fast-path
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

# Run a command as root (using sudo when needed)
run_privileged() {
    if [ "$(id -u)" -ne 0 ] && command -v sudo >/dev/null 2>&1; then
        sudo "$@"
    else
        "$@"
    fi
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
    lib lib/${TARGET_ARCH}-linux-musl \
    etc etc/init.d \
    dev proc sys root tmp \
    opt/lamp-gui \
    installer \
    boot \
    home/user \
    usr/bin usr/sbin usr/lib \
    var/log var/run \
    doc

chmod 1777 tmp
status "Filesystem structure created"

# Step 2: Download and install BusyBox
echo -e "\n${BLUE}Step 2: Setting up BusyBox...${NC}"

if [ -f "bin/busybox" ]; then
    status "BusyBox already exists, skipping"
else
    if [ "$TARGET_ARCH" = "x86_64" ]; then
        echo "Attempting to download prebuilt BusyBox for x86_64 ${BUSYBOX_VERSION}..."
        if wget -q --show-progress "$BUSYBOX_URL" -O bin/busybox 2>/dev/null; then
            chmod +x bin/busybox
            status "BusyBox downloaded and installed (x86_64 prebuilt)"
        else
            warning "Failed to download prebuilt BusyBox. Falling back to build from source."
            TARGET_ARCH=${TARGET_ARCH} CROSS_COMPILE=${CROSS_COMPILE} DESTDIR="${INITRD_DIR}" ./build_busybox.sh
        fi
    else
        echo "Building BusyBox from source for ARCH=${TARGET_ARCH}..."
        TARGET_ARCH=${TARGET_ARCH} CROSS_COMPILE=${CROSS_COMPILE} DESTDIR="${INITRD_DIR}" ./build_busybox.sh
        status "BusyBox built and installed into ${INITRD_DIR}"
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

# Step 5: Include installer and boot assets
# (allows the Live USB to run the disk installer and install to HDD/SSD)
echo -e "\n${BLUE}Step 5: Including installer and boot assets...${NC}"

# Copy installer scripts from the repository into the initrd
if [ -d "../installer" ]; then
    cp -a ../installer/* installer/ 2>/dev/null || true
    status "Installer scripts copied into initrd"
fi

# Copy the built kernel into initrd so installer can install it to disk
KERNEL_SRC="../iso/boot/vmlinuz-${TARGET_ARCH}"
if [ -f "$KERNEL_SRC" ]; then
    mkdir -p boot
    cp -v "$KERNEL_SRC" boot/vmlinuz 2>/dev/null || true
    status "Kernel copied into initrd (boot/vmlinuz)"
fi

# Include partitioning and bootloader tools (if present on the build host)
# This lets the installer run in the live environment without needing external tools.
if command -v grub-install >/dev/null 2>&1; then
    mkdir -p usr/sbin
    cp -v "$(command -v grub-install)" usr/sbin/ 2>/dev/null || true
    status "grub-install included"

    # Copy GRUB module files so grub-install can function inside initrd
    if [ -d "/usr/lib/grub" ]; then
        mkdir -p usr/lib
        cp -a /usr/lib/grub usr/lib/ 2>/dev/null || true
        status "GRUB modules copied"
    fi

    # Copy required shared libraries
    for lib in $(ldd "$(command -v grub-install)" | awk '/=>/ {print $3}' | sort -u); do
        if [ -f "$lib" ]; then
            dest_dir="./$(dirname "$lib")"
            mkdir -p "$dest_dir"
            cp -v "$lib" "$dest_dir/" 2>/dev/null || true
        fi
    done
fi

if command -v parted >/dev/null 2>&1; then
    mkdir -p usr/sbin
    cp -v "$(command -v parted)" usr/sbin/ 2>/dev/null || true
    status "parted included"
    for lib in $(ldd "$(command -v parted)" | awk '/=>/ {print $3}' | sort -u); do
        if [ -f "$lib" ]; then
            dest_dir="./$(dirname "$lib")"
            mkdir -p "$dest_dir"
            cp -v "$lib" "$dest_dir/" 2>/dev/null || true
        fi
    done
fi

# Continue with config file creation

# Step 6: Create essential config files
echo -e "\n${BLUE}Step 6: Creating configuration files...${NC}"

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

# Try to find and copy suitable libc/ld and other shared libraries
status "Scanning host for compatible libraries (best-effort)"
COPIED_LIBS=0
for libdir in /lib /lib64 /usr/lib /usr/lib64 /lib/${TARGET_ARCH}-linux-gnu /usr/${TARGET_ARCH}-linux-gnu/lib; do
    if [ -d "$libdir" ]; then
        # Copy common shared libs (libc, ld, ld-musl, libm, libpthread, etc.)
        cp -a "$libdir"/*.so* lib/ 2>/dev/null || true
        if [ $? -eq 0 ]; then
            status "Copied libraries from $libdir"
            COPIED_LIBS=1
            break
        fi
    fi
done
if [ $COPIED_LIBS -eq 0 ]; then
    warning "No suitable shared libraries auto-copied; initrd may require static BusyBox or manual copy of libc/ld for ${TARGET_ARCH}."
fi

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

# Step 7c: Install KDE Plasma root filesystem into initrd (optional)
echo -e "\n${BLUE}Step 7c: Installing KDE Plasma into initrd (this may take a while)...${NC}"
KDE_ROOT="opt/kde-rootfs"
if [ -f "$KDE_ROOT/.kde_installed" ]; then
    status "KDE rootfs already prepared, skipping"
else
    if ! command -v debootstrap >/dev/null 2>&1; then
        warning "debootstrap not available; skipping KDE integration"
    else
        mkdir -p "$KDE_ROOT"
        echo "Bootstrapping Ubuntu rootfs (this can take several minutes)..."
        TEMP_ROOT=$(mktemp -d /tmp/lamp-kde-rootfs-XXXX)
        # debootstrap may fail on noexec filesystems; create rootfs in /tmp and copy in
        # Run debootstrap in a temporary directory to avoid noexec mount issues.
        set +e
        run_privileged debootstrap --variant=minbase --components=main,universe --include=apt,dbus,dbus-user-session,dbus-x11,plasma-desktop,kwin-wayland,xwayland,sddm,network-manager,pipewire,pipewire-pulse,pipewire-audio,wireplumber,alsa-utils,mesa-utils,nano noble "$TEMP_ROOT" http://archive.ubuntu.com/ubuntu/
        DEBOOTSTRAP_STATUS=$?
        set -e

        if [ $DEBOOTSTRAP_STATUS -ne 0 ]; then
            warning "KDE rootfs bootstrap failed (exit $DEBOOTSTRAP_STATUS). Continuing without KDE integration."
            warning "Check /tmp/lamp-kde-rootfs-* and their debootstrap/debootstrap.log for details."
            run_privileged rm -rf "$TEMP_ROOT"
        else
            # Copy resulting rootfs into initrd tree
            rm -rf "$KDE_ROOT" && mkdir -p "$KDE_ROOT"
            cp -a "$TEMP_ROOT"/* "$KDE_ROOT"/ 2>/dev/null || rsync -a "$TEMP_ROOT"/ "$KDE_ROOT"/
            run_privileged rm -rf "$TEMP_ROOT"
            cat > "$KDE_ROOT/root/start-kde.sh" << 'EOF'
#!/bin/sh
# Simple launcher for KDE Plasma in initrd
export XDG_RUNTIME_DIR=/run/user/0
mkdir -p "$XDG_RUNTIME_DIR"
export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"
if command -v startplasma-wayland >/dev/null 2>&1; then
  exec dbus-launch --exit-with-session startplasma-wayland
elif command -v startplasma-x11 >/dev/null 2>&1; then
  exec dbus-launch --exit-with-session startplasma-x11
else
  echo "KDE Plasma launchers not found."
  exec /bin/sh -i -l
fi
EOF
            chmod +x "$KDE_ROOT/root/start-kde.sh"
            touch "$KDE_ROOT/.kde_installed"
            status "KDE Plasma rootfs installed at $KDE_ROOT"
        fi
    fi
fi

# Step 7d: Generating system sounds...
echo -e "\n${BLUE}Step 7d: Generating system sounds...${NC}"
SOUNDS_DIR="opt/sounds"
if [ ! -d "$SOUNDS_DIR" ] || [ -z "$(ls -A $SOUNDS_DIR 2>/dev/null)" ]; then
    # Try to generate sounds using embedded Python script
    if command -v python3 >/dev/null 2>&1 && [ -f "../scripts/generate_sounds.py" ]; then
        python3 ../scripts/generate_sounds.py "$SOUNDS_DIR"
        status "Generated system sounds"
    else
        warning "Python3 or sound generator not available; skipping sounds"
    fi
else
    status "System sounds already present"
fi

# Copy sounds into initrd structure
if [ -d "$SOUNDS_DIR" ]; then
    mkdir -p usr/share/sounds/lamp
    cp -a $SOUNDS_DIR/* usr/share/sounds/lamp/ 2>/dev/null || true
    status "Installed system sounds to usr/share/sounds/lamp" 
    # also preserve any logo images for UI scripts
    mkdir -p usr/share/lamp/logos
    cp -a $SOUNDS_DIR/logo*.jp* usr/share/lamp/logos/ 2>/dev/null || true
    status "Installed logo images to usr/share/lamp/logos"
    # copy backgrounds if available
    if [ -d "$PROJECT_ROOT/opt/backgrounds" ]; then
        mkdir -p usr/share/lamp/backgrounds
        cp -a "$PROJECT_ROOT/opt/backgrounds"/* usr/share/lamp/backgrounds/ 2>/dev/null || true
        status "Installed desktop backgrounds to usr/share/lamp/backgrounds"
    fi

    # If a squashfs rootfs exists, bundle it into the initrd
    if [ -f "$PROJECT_ROOT/opt/rootfs.squashfs" ]; then
        mkdir -p opt
        cp -v "$PROJECT_ROOT/opt/rootfs.squashfs" opt/ 2>/dev/null || true
        status "Bundled squashfs rootfs into initrd (opt/rootfs.squashfs)"
    fi
fi

# ensure default wallpaper config
mkdir -p etc/lamp
if [ -f usr/share/lamp/backgrounds/image_1772741586376.jpeg ]; then
    echo "/usr/share/lamp/backgrounds/image_1772741586376.jpeg" > etc/lamp/wallpaper
fi

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
if [ -d "../iso/boot" ]; then
    echo "Creating initrd.img from CPIO (no top-level prefix)..."
    (find . -print0 | cpio -0oH newc 2>/dev/null) | gzip -9 > ../iso/boot/initrd.img
    initrd_size=$(ls -lh ../iso/boot/initrd.img | awk '{print $5}')
    status "CPIO archive created: $initrd_size"
else
    warning "../iso/boot directory not found. Skipping CPIO creation."
    warning "Run this after creating the ISO directory structure (or run from project root with iso/boot present)."
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
echo "  1. Ensure your Linux kernel is built for ARCH=${TARGET_ARCH} (check arch/${TARGET_ARCH}/boot/*)"
echo "  2. Copy kernel: cp kernel/linux-6.6/arch/${TARGET_ARCH}/boot/<kernel-image> iso/boot/vmlinuz-${TARGET_ARCH} && ln -sf vmlinuz-${TARGET_ARCH} iso/boot/vmlinuz"
echo "  3. Run: ./create_iso.sh (or set TARGET_ARCH and CROSS_COMPILE as needed)"
echo "  4. Test with QEMU (example):"
echo "     - x86_64: qemu-system-x86_64 -cdrom lamp-os.iso -m 512"
echo "     - aarch64: qemu-system-aarch64 -machine virt -cpu cortex-a57 -nographic -kernel iso/boot/vmlinuz-aarch64 -initrd iso/boot/initrd.img -append 'console=ttyAMA0'"
echo ""
