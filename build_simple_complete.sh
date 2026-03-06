#!/bin/bash
echo "🔨 Building Simple Complete Lamp OS"
echo "==================================="

# تنظيف
rm -rf kernel gui iso initrd lamp-os-*.iso 2>/dev/null

# إنشاء هيكل
mkdir -p kernel gui iso/{boot/grub,live} initrd

# 1. استخدام نواة بسيطة بدلاً من بناء لينكس
echo "📦 Using simple kernel..."
cd kernel
cat > minimal_kernel.asm << 'KERNEL'
[bits 32]
global _start
_start:
    mov edi, 0xB8000
    mov esi, msg
print:
    lodsb
    test al, al
    jz hang
    mov ah, 0x0F
    stosw
    jmp print
hang:
    hlt
    jmp hang
msg db 'Lamp OS Kernel v1.0 Running!', 0
KERNEL

nasm -f elf32 minimal_kernel.asm -o kernel.o
ld -m elf_i386 -Ttext 0x100000 -o kernel.bin kernel.o
cp kernel.bin ../iso/live/vmlinuz
cd ..
echo "✅ Simple kernel created"

# 2. بناء GUI مبسط
echo "🎨 Building simple GUI..."
cd gui
cat > simple_gui.cpp << 'GUICODE'
#include <iostream>
using namespace std;

int main() {
    cout << "========================================" << endl;
    cout << "       🪔 Lamp OS Simple GUI" << endl;
    cout << "========================================" << endl;
    cout << endl;
    cout << "Welcome to Lamp OS!" << endl;
    cout << "This is a simple GUI application." << endl;
    cout << endl;
    cout << "Features:" << endl;
    cout << "1. Clean design" << endl;
    cout << "2. Easy to use" << endl;
    cout << "3. Built with C++" << endl;
    cout << endl;
    cout << "Press Enter to continue...";
    cin.get();
    return 0;
}
GUICODE

g++ -o lamp-gui simple_gui.cpp
cd ..
echo "✅ Simple GUI built"

# 3. إنشاء initrd متقدم
echo "📁 Creating advanced initrd..."
cd initrd
mkdir -p bin dev etc lib proc sys opt/lamp-gui

# نسخ GUI
cp ../gui/lamp-gui opt/lamp-gui/

# إنشاء init script متقدم
cat > init << 'INIT'
#!/bin/sh

# إعداد النظام
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev

# تنظيف الشاشة
clear

# شعار Lamp OS
echo "╔════════════════════════════════════════════════════╗"
echo "║               🪔 LAMP OS v1.0                      ║"
echo "╚════════════════════════════════════════════════════╝"
echo ""
echo "Initializing system..."
echo ""

# بدء GUI
if [ -f /opt/lamp-gui/lamp-gui ]; then
    echo "Starting Lamp OS GUI..."
    /opt/lamp-gui/lamp-gui
else
    echo "GUI not found. Starting console..."
fi

# افتح shell بعد انتهاء GUI
echo ""
echo "Starting Lamp OS shell..."
echo "Type 'help' for available commands"
export PS1='lamp-os> '
exec /bin/sh
INIT

chmod +x init

# إنشاء أوامر أساسية
cat > bin/sh << 'SH'
#!/bin/bash
echo "Lamp OS Shell"
echo "Available commands: help, about, gui, reboot"
while true; do
    echo -n "lamp-os> "
    read cmd
    case $cmd in
        help) echo "Commands: help, about, gui, reboot, exit" ;;
        about) echo "Lamp OS v1.0 - A beautiful, simple OS" ;;
        gui) /opt/lamp-gui/lamp-gui ;;
        reboot) echo "Rebooting..." && sleep 2 && exit 0 ;;
        exit) break ;;
        *) echo "Unknown command. Type 'help' for help." ;;
    esac
done
SH
chmod +x bin/sh

# تجميع initrd
echo "Creating initrd image..."
find . | cpio -o -H newc 2>/dev/null | gzip -9 > ../iso/live/initrd.img
cd ..

echo "✅ Initrd created: $(du -h iso/live/initrd.img | cut -f1)"

# 4. تكوين GRUB
echo "🔧 Configuring GRUB..."
cat > iso/boot/grub/grub.cfg << 'GRUB'
set timeout=10
set default=0

menuentry "Lamp OS" {
    echo "Loading Lamp OS..."
    linux /live/vmlinuz
    initrd /live/initrd.img
}

menuentry "Lamp OS (Text Mode)" {
    linux /live/vmlinuz
    initrd /live/initrd.img
    boot
}
GRUB

# 5. بناء ISO
echo "📀 Creating ISO..."
grub-mkrescue -o lamp-os-complete.iso iso/ 2>/dev/null

if [ -f "lamp-os-complete.iso" ]; then
    echo ""
    echo "🎉 BUILD SUCCESSFUL!"
    echo "==================="
    echo "ISO: lamp-os-complete.iso"
    echo "Size: $(du -h lamp-os-complete.iso | cut -f1)"
    echo ""
    echo "🚀 Test with:"
    echo "   qemu-system-x86_64 -cdrom lamp-os-complete.iso -m 1G"
else
    echo "❌ ISO creation failed"
    exit 1
fi
