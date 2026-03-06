#!/bin/bash
# Multi-arch ISO creator
# Usage: TARGET_ARCH=x86_64 ./create_iso.sh
set -e
TARGET_ARCH="${TARGET_ARCH:-x86_64}"
OUTNAME="lamp-os-${TARGET_ARCH}.iso"

echo "Creating ISO for ARCH=$TARGET_ARCH -> $OUTNAME"

# Ensure boot files are in iso_build
mkdir -p iso_build/boot
cp -a iso/boot/vmlinuz* iso_build/boot/ 2>/dev/null || true
cp -a iso/boot/initrd.img iso_build/boot/ 2>/dev/null || true

# Ensure live/ has the vmlinuz + initrd for the GRUB menu entries
mkdir -p iso_build/live
cp -a iso/boot/vmlinuz iso_build/live/vmlinuz 2>/dev/null || true
cp -a iso/boot/initrd.img iso_build/live/initrd.img 2>/dev/null || true

if [ "$TARGET_ARCH" = "x86_64" ]; then
    if command -v grub-mkrescue >/dev/null 2>&1; then
        echo "Using grub-mkrescue to create hybrid BIOS+UEFI ISO"
        grub-mkrescue -o "$OUTNAME" iso_build/ || {
            echo "grub-mkrescue failed, falling back to xorriso"
        }
    fi
    if [ ! -f "$OUTNAME" ]; then
        echo "Using xorriso fallback (BIOS El Torito)"
        xorriso -as mkisofs \
            -b boot/grub/i386-pc/eltorito.img \
            -no-emul-boot \
            -boot-load-size 4 \
            -boot-info-table \
            -o "$OUTNAME" \
            iso_build/
    fi
    echo "ISO created: $OUTNAME"
    ln -sf "$OUTNAME" lamp-os.iso
    echo "(Also linked to lamp-os.iso for convenience)"
    echo "Tip: Test with qemu: qemu-system-x86_64 -cdrom $OUTNAME -m 512 -smp 2"
else
    echo "Non-x86_64 ISO creation: creating simple ISO filesystem (UEFI/arch-specific steps may be required)"
    xorriso -as mkisofs -o "$OUTNAME" iso_build/
    echo "ISO created: $OUTNAME"
    echo "Note: For aarch64/arm you may need to use UEFI images, or boot kernel/initrd directly with QEMU."
    echo "Example QEMU boot for aarch64:"
    echo "  qemu-system-aarch64 -machine virt -cpu cortex-a57 -nographic -kernel iso/boot/vmlinuz-$TARGET_ARCH -initrd iso/boot/initrd.img -append 'console=ttyAMA0'"
fi
