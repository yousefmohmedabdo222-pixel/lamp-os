#!/bin/bash
set -e

echo "🔨 Building WORKING Lamp OS"
echo "============================"

# تنظيف
rm -rf iso_build
mkdir -p iso_build/{boot/grub,live}

# 1. إنشاء نواة بسيطة جدًا تعمل في Real Mode
echo "📦 Creating simple kernel..."
cat > kernel.asm << 'KERNEL'
[bits 16]
[org 0x7c00]
start:
    ; تنظيف الشاشة
    mov ax, 0x0003
    int 0x10
    
    ; إعداد موضع النص
    mov dh, 5
    mov dl, 20
    call move_cursor
    
    ; رسم شعار
    mov si, banner_top
    call print_string
    
    mov dh, 6
    mov dl, 25
    call move_cursor
    mov si, title
    call print_string
    
    mov dh, 7
    mov dl, 20
    call move_cursor
    mov si, banner_bottom
    call print_string
    
    ; معلومات النظام
    mov dh, 9
    mov dl, 22
    call move_cursor
    mov si, message1
    call print_string
    
    mov dh, 10
    mov dl, 22
    call move_cursor
    mov si, message2
    call print_string
    
    mov dh, 11
    mov dl, 22
    call move_cursor
    mov si, message3
    call print_string
    
    ; انتظار ثم إعادة التشغيل
    mov dh, 13
    mov dl, 22
    call move_cursor
    mov si, press_key
    call print_string
    
    mov ah, 0x00
    int 0x16
    int 0x19  ; إعادة التشغيل

move_cursor:
    mov ah, 0x02
    mov bh, 0
    int 0x10
    ret

print_string:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp print_string
.done:
    ret

banner_top   db '=============================', 0x0D, 0x0A, 0
title        db '      🪔 LAMP OS v1.0      ', 0x0D, 0x0A, 0
banner_bottom db '=============================', 0x0D, 0x0A, 0x0D, 0x0A, 0
message1     db 'Boot successful!', 0x0D, 0x0A, 0
message2     db 'Kernel loaded at 0x7C00', 0x0D, 0x0A, 0
message3     db 'System ready', 0x0D, 0x0A, 0
press_key    db 'Press any key to restart...', 0

times 510-($-$$) db 0
dw 0xAA55
KERNEL

# تجميع النواة
nasm -f bin kernel.asm -o iso_build/live/vmlinuz
echo "✅ Kernel created: $(stat -c%s iso_build/live/vmlinuz) bytes"

# 2. تكوين GRUB بشكل صحيح
echo "🔧 Configuring GRUB..."
cat > iso_build/boot/grub/grub.cfg << 'GRUB'
set timeout=3
set default=0

menuentry "Lamp OS" {
    echo "Loading Lamp OS..."
    multiboot /live/vmlinuz
    boot
}

menuentry "Lamp OS (Direct Boot)" {
    set root=(cd0)
    chainloader +1
    boot
}
GRUB

# 3. بناء ISO مباشرة
echo "📀 Creating ISO directly..."
cat > create_iso.sh << 'ISO'
#!/bin/bash
# طريقة أبسط لإنشاء ISO
xorriso -as mkisofs \
    -b boot/grub/i386-pc/eltorito.img \
    -no-emul-boot \
    -boot-load-size 4 \
    -boot-info-table \
    -o lamp-os-working.iso \
    iso_build/
ISO

chmod +x create_iso.sh

# 4. استخدام grub-mkrescue
echo "Building ISO with GRUB..."
grub-mkrescue -o lamp-os-working.iso iso_build/ 2>&1 | grep -v "warning"

if [ -f "lamp-os-working.iso" ]; then
    echo ""
    echo "🎉 SUCCESS! ISO created: lamp-os-working.iso"
    echo "Size: $(du -h lamp-os-working.iso | cut -f1)"
    echo ""
    echo "🚀 Test with:"
    echo "   qemu-system-x86_64 -cdrom lamp-os-working.iso"
else
    echo "❌ ISO creation failed, trying alternative method..."
    # طريقة بديلة
    xorriso -as mkisofs -b iso_build/live/vmlinuz -o lamp-os-alt.iso iso_build/
    if [ -f "lamp-os-alt.iso" ]; then
        echo "✅ Alternative ISO created: lamp-os-alt.iso"
    fi
fi
