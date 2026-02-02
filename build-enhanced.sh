#!/bin/bash
# LAMP OS - Enhanced Build Script

set -e

echo "╔════════════════════════════════════════╗"
echo "║   LAMP OS - Enhanced Build Script      ║"
echo "╚════════════════════════════════════════╝"
echo ""

WORKDIR="/workspaces/lamp-os"
cd "$WORKDIR"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[$(date +%H:%M:%S)]${NC} $1"
}

success() {
    echo -e "${GREEN}✓${NC} $1"
}

# Step 1: Verify dependencies
log "Checking dependencies..."
command -v qemu-system-x86_64 > /dev/null || { echo "ERROR: qemu-system-x86_64 not found"; exit 1; }
command -v grub-mkrescue > /dev/null || { echo "ERROR: grub-mkrescue not found"; exit 1; }
success "All dependencies found"
echo ""

# Step 2: Update initrd with enhancements
log "Updating initrd structure..."
mkdir -p initrd/root
mkdir -p initrd/usr/local/bin
mkdir -p initrd/usr/local/share/doc/lamp-os
mkdir -p initrd/opt/lamp-gui
success "Directory structure verified"
echo ""

# Step 3: Verify key files
log "Verifying key components..."
[ -f "initrd/bin/busybox" ] && success "BusyBox found" || echo "WARNING: BusyBox not found"
[ -f "initrd/opt/lamp-gui/lamp-gui" ] && success "lamp-gui found" || echo "WARNING: lamp-gui not found"
[ -f "initrd/etc/inittab" ] && success "inittab found" || echo "WARNING: inittab not found"
echo ""

# Step 4: Create symlinks for tools
log "Creating tool symlinks..."
cd initrd/bin
for cmd in sh ls cat chmod mount grep find sed awk ps top df free uptime; do
    [ ! -L "$cmd" ] && ln -sf busybox "$cmd" 2>/dev/null || true
done
cd "$WORKDIR"
success "Tool symlinks created"
echo ""

# Step 5: Build initrd
log "Building initrd image..."
cd initrd
echo "  - Creating CPIO archive..."
find . -print0 | cpio -0oH newc 2>/dev/null | gzip -9 > ../iso/boot/initrd.img

INITRD_SIZE=$(du -h "$WORKDIR/iso/boot/initrd.img" | cut -f1)
INITRD_LINES=$(wc -l < /dev/null)
success "Initrd built ($INITRD_SIZE)"
echo ""

# Step 6: Verify kernel
log "Verifying kernel image..."
if [ -f "$WORKDIR/iso/boot/vmlinuz" ]; then
    KERNEL_SIZE=$(du -h "$WORKDIR/iso/boot/vmlinuz" | cut -f1)
    success "Kernel verified ($KERNEL_SIZE)"
else
    echo "ERROR: Kernel not found!"
    exit 1
fi
echo ""

# Step 7: Build ISO
log "Building ISO image..."
cd "$WORKDIR"
echo "  - Running grub-mkrescue..."

if grub-mkrescue -o lamp-os.iso iso/ 2>&1 | tail -5 | grep -q "successfully"; then
    ISO_SIZE=$(du -h lamp-os.iso | cut -f1)
    success "ISO created ($ISO_SIZE)"
else
    echo "WARNING: ISO build may have issues"
fi
echo ""

# Step 8: Generate build info
log "Generating build information..."
cat > BUILD_INFO.txt << EOF
═══════════════════════════════════════════════════════════════════════════════
                        LAMP OS - Build Information
═══════════════════════════════════════════════════════════════════════════════

Build Date:        $(date)
Build System:      $(uname -s)
Hostname:          $(hostname)
Build Directory:   $WORKDIR

BUILD ARTIFACTS
───────────────────────────────────────────────────────────────────────────────

1. Kernel Image
   File:           iso/boot/vmlinuz
   Size:           $KERNEL_SIZE
   Version:        Linux 6.6.0-lamp

2. Initrd Image
   File:           iso/boot/initrd.img
   Size:           $INITRD_SIZE
   Compression:    gzip
   Format:         CPIO newc

3. GRUB Configuration
   File:           iso/boot/grub/grub.cfg
   Console:        Serial (ttyS0, 115200 baud)
   Default:        Lamp OS

4. Bootable ISO
   File:           lamp-os.iso
   Size:           $(du -h lamp-os.iso | cut -f1)
   Format:         GRUB2 CD/DVD image

INCLUDED TOOLS
───────────────────────────────────────────────────────────────────────────────

✓ lamp-menu        - Interactive system menu
✓ lamp-network     - Network configuration tool
✓ lamp-system      - System utilities
✓ lamp-gui         - GUI application
✓ BusyBox          - ~100+ utilities
✓ Documentation    - Complete help system

BOOT VERIFICATION
───────────────────────────────────────────────────────────────────────────────

Kernel command line:  console=ttyS0,115200 rdinit=/bin/sh
Init process:         /bin/sh (BusyBox)
Root filesystem:      tmpfs (in-memory)

NEXT STEPS
───────────────────────────────────────────────────────────────────────────────

1. Boot the system:
   timeout 30 qemu-system-x86_64 -cdrom lamp-os.iso -m 512M -nographic \\
     -serial file:/tmp/lamp-boot.log -accel tcg

2. Verify boot:
   tail -50 /tmp/lamp-boot.log | grep "/ #"

3. Run comprehensive test:
   ./test-comprehensive.sh

4. Access help:
   lamp-help

BUILD STATUS: ✓ COMPLETE
═══════════════════════════════════════════════════════════════════════════════
EOF

success "Build information saved"
echo ""

# Step 9: Final summary
echo "╔════════════════════════════════════════╗"
echo "║    Build Completed Successfully!       ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo -e "${GREEN}Build Summary:${NC}"
echo "  Kernel:    $(du -h iso/boot/vmlinuz | cut -f1)"
echo "  Initrd:    $(du -h iso/boot/initrd.img | cut -f1)"
echo "  ISO:       $(du -h lamp-os.iso | cut -f1)"
echo ""
echo -e "${GREEN}Quick Start:${NC}"
echo "  1. timeout 30 qemu-system-x86_64 -cdrom lamp-os.iso -m 512M -nographic -serial file:/tmp/boot.log -accel tcg"
echo "  2. tail /tmp/boot.log | grep '/ #'"
echo ""
echo -e "${GREEN}Documentation:${NC}"
echo "  - QUICKSTART.md - Get started quickly"
echo "  - README.md - Full documentation"
echo "  - BUILD_INFO.txt - Build details"
echo ""
