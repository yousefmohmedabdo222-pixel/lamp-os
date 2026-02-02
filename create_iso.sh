#!/bin/bash
# طريقة أبسط لإنشاء ISO
xorriso -as mkisofs \
    -b boot/grub/i386-pc/eltorito.img \
    -no-emul-boot \
    -boot-load-size 4 \
    -boot-info-table \
    -o lamp-os-working.iso \
    iso_build/
