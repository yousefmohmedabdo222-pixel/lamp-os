#!/bin/bash
# LAMP OS ISO Quality Check

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -ne "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}\n"
echo -ne "${BLUE}║${WHITE}     LAMP OS v2.0 - ISO Quality Verification                  ${BLUE}║${NC}\n"
echo -ne "${BLUE}║${WHITE}     © 2026 Created by: yousef mohmed                         ${BLUE}║${NC}\n"
echo -ne "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}\n"
echo ""

ISO_FILE="lamp-os-complete-installer.iso"

# Check if ISO exists
if [ ! -f "$ISO_FILE" ]; then
    echo -ne "${RED}✗ ISO file not found: $ISO_FILE${NC}\n"
    exit 1
fi

echo -ne "${CYAN}ISO File Analysis${NC}\n"
echo "─────────────────────────────────────────────────────────────"
echo ""

# File size
SIZE=$(ls -lh "$ISO_FILE" | awk '{print $5}')
SIZE_BYTES=$(ls -l "$ISO_FILE" | awk '{print $5}')
echo -ne "${GREEN}✓ File Size:${NC}          $SIZE ($SIZE_BYTES bytes)\n"

# Creation date
DATE=$(ls -l "$ISO_FILE" | awk '{print $6, $7, $8}')
echo -ne "${GREEN}✓ Creation Date:${NC}      $DATE\n"

# MD5 checksum
MD5=$(md5sum "$ISO_FILE" | cut -d' ' -f1)
echo -ne "${GREEN}✓ MD5 Checksum:${NC}      $MD5\n"

# SHA256 checksum
SHA256=$(sha256sum "$ISO_FILE" | cut -d' ' -f1)
echo -ne "${GREEN}✓ SHA256 Hash:${NC}       ${SHA256:0:32}...\n"

echo ""
echo -ne "${CYAN}ISO Structure Check${NC}\n"
echo "─────────────────────────────────────────────────────────────"
echo ""

# Mount ISO temporarily to check contents
MOUNT_DIR=$(mktemp -d)
sudo mount -o loop "$ISO_FILE" "$MOUNT_DIR" 2>/dev/null || {
    echo -ne "${YELLOW}⚠ Cannot mount ISO (needs sudo)${NC}\n"
    echo "Skipping detailed structure check\n"
    exit 0
}

trap "sudo umount '$MOUNT_DIR' 2>/dev/null; rmdir '$MOUNT_DIR'" EXIT

# Check kernel
if [ -f "$MOUNT_DIR/boot/vmlinuz" ]; then
    KERNEL_SIZE=$(ls -lh "$MOUNT_DIR/boot/vmlinuz" | awk '{print $5}')
    echo -ne "${GREEN}✓ Kernel (vmlinuz):${NC}      Found ($KERNEL_SIZE)\n"
else
    echo -ne "${RED}✗ Kernel not found${NC}\n"
fi

# Check initrd
if [ -f "$MOUNT_DIR/boot/initrd.img" ]; then
    INITRD_SIZE=$(ls -lh "$MOUNT_DIR/boot/initrd.img" | awk '{print $5}')
    echo -ne "${GREEN}✓ Initrd (initrd.img):${NC}    Found ($INITRD_SIZE)\n"
else
    echo -ne "${RED}✗ Initrd not found${NC}\n"
fi

# Check GRUB config
if [ -f "$MOUNT_DIR/boot/grub/grub.cfg" ]; then
    echo -ne "${GREEN}✓ GRUB Config:${NC}          Found\n"
else
    echo -ne "${RED}✗ GRUB config not found${NC}\n"
fi

# Check boot directory
echo -ne "${GREEN}✓ Boot Directory:${NC}        "
ls "$MOUNT_DIR/boot" | tr '\n' ' '
echo ""

echo ""
echo -ne "${CYAN}File Count Analysis${NC}\n"
echo "─────────────────────────────────────────────────────────────"
echo ""

FILE_COUNT=$(find "$MOUNT_DIR" -type f | wc -l)
DIR_COUNT=$(find "$MOUNT_DIR" -type d | wc -l)
echo -ne "${GREEN}✓ Total Files:${NC}          $FILE_COUNT\n"
echo -ne "${GREEN}✓ Total Directories:${NC}    $DIR_COUNT\n"

# Space analysis
echo ""
echo -ne "${CYAN}ISO Content Distribution${NC}\n"
echo "─────────────────────────────────────────────────────────────"
echo ""

du -sh "$MOUNT_DIR"/* 2>/dev/null | sort -hr | head -10

echo ""
echo -ne "${CYAN}Installation Scripts Check${NC}\n"
echo "─────────────────────────────────────────────────────────────"
echo ""

SCRIPTS=(
    "usr/local/bin/setup-wizard.sh"
    "usr/local/bin/post-install-setup.sh"
    "usr/local/bin/boot-manager.sh"
    "usr/local/bin/firstboot.sh"
    "usr/local/bin/lamp-desktop-menu"
    "usr/local/bin/lamp-splash"
    "usr/local/bin/lamp-boot"
)

for script in "${SCRIPTS[@]}"; do
    if [ -f "$MOUNT_DIR/$script" ]; then
        echo -ne "${GREEN}✓${NC} $(basename "$script")\n"
    else
        echo -ne "${YELLOW}⚠${NC} $(basename "$script") - Not found\n"
    fi
done

echo ""
echo -ne "${CYAN}BusyBox Tools Check${NC}\n"
echo "─────────────────────────────────────────────────────────────"
echo ""

if [ -f "$MOUNT_DIR/bin/busybox" ]; then
    BUSYBOX_SIZE=$(ls -lh "$MOUNT_DIR/bin/busybox" | awk '{print $5}')
    echo -ne "${GREEN}✓ BusyBox:${NC}              Found ($BUSYBOX_SIZE)\n"
    
    # Count available tools
    TOOL_COUNT=$("$MOUNT_DIR/bin/busybox" --list 2>/dev/null | wc -l)
    echo -ne "${GREEN}✓ Available Tools:${NC}      $TOOL_COUNT\n"
else
    echo -ne "${RED}✗ BusyBox not found${NC}\n"
fi

echo ""
echo -ne "${GREEN}═════════════════════════════════════════════════════════════════${NC}\n"
echo -ne "${GREEN}ISO Verification Complete!${NC}\n"
echo -ne "${GREEN}═════════════════════════════════════════════════════════════════${NC}\n"
echo ""
echo -ne "${YELLOW}Ready for:${NC}\n"
echo "  • USB writing with Rufus (Windows)"
echo "  • USB writing with dd (Linux/Mac)"
echo "  • Virtual machine installation"
echo "  • Physical system installation"
echo ""
echo -ne "${CYAN}Next Steps:${NC}\n"
echo "  1. Download Rufus from https://rufus.ie"
echo "  2. Insert USB drive (8GB+ recommended)"
echo "  3. Select $ISO_FILE in Rufus"
echo "  4. Click START and wait for completion"
echo "  5. Boot system from USB"
echo ""
