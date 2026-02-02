#!/bin/bash
echo "🚀 Lamp OS Quick Builder for Fresh Codespace"
echo "============================================="

# إنشاء مجلدات
mkdir -p kernel gui iso/{boot/grub,live} initrd

# 1. تنزيل وبناء نواة بسيطة
cd kernel
echo "📦 Downloading small kernel..."
wget -q https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.15.138.tar.xz
tar -xf linux-5.15.138.tar.xz
cd linux-5.15.138

echo "🔧 Building kernel..."
make defconfig
make -j$(nproc) bzImage

if [ -f "arch/x86/boot/bzImage" ]; then
    cp arch/x86/boot/bzImage ../../iso/live/vmlinuz
    echo "✅ Kernel built"
else
    echo "❌ Kernel build failed, using minimal stub..."
    # إنشاء kernel بديل بسيط
    cd ../..
    cat > kernel.asm << 'KERNEL'
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
msg db 'Lamp OS Kernel Running!', 0
KERNEL
    nasm -f elf32 kernel.asm -o kernel.o
    ld -m elf_i386 -Ttext 0x100000 -o kernel.bin kernel.o
    dd if=/dev/zero of=iso/live/vmlinuz bs=1k count=100
    dd if=kernel.bin of=iso/live/vmlinuz conv=notrunc
fi

cd ../..

# 2. إنشاء initrd بسيط
cd initrd
echo "📁 Creating initrd..."
mkdir -p bin dev etc lib proc sys

cat > init << 'INIT'
#!/bin/sh
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev

echo "========================================"
echo "       🪔 Lamp OS v1.0 Minimal"
echo "========================================"
echo ""
echo "Welcome to Lamp OS!"
echo "This is a minimal bootable system."
echo ""
echo "System information:"
echo "Kernel: $(uname -r)"
echo "Memory: $(free -h | grep Mem | awk '{print $2}')"
echo ""
echo "Type 'help' for available commands"

# أوامر بسيطة
alias help='echo "Available: ls, cat, echo, ps, df, free"'
alias reboot='echo "Rebooting..." && sleep 2 && exec /init'

exec /bin/sh
INIT

chmod +x init

# نسخ busybox إذا موجود، أو إنشاء shell بديل
if command -v busybox &> /dev/null; then
    cp $(which busybox) bin/
    cd bin
    for cmd in sh ls cat echo ps df free; do
        ln -s busybox $cmd
    done
    cd ..
else
    # shell بديل بسيط
    cat > bin/sh << 'SHELL'
#!/bin/bash
while true; do
    echo -n "lamp-os> "
    read cmd
    case $cmd in
        ls) ls / ;;
        ps) ps ;;
        df) df -h ;;
        free) free -h ;;
        cat*) cat ${cmd:4} ;;
        echo*) echo ${cmd:5} ;;
        help) echo "Commands: ls, ps, df, free, cat, echo, help" ;;
        exit) break ;;
        *) echo "Unknown command: $cmd" ;;
    esac
done
SHELL
    chmod +x bin/sh
fi

# تجميع initrd
find . | cpio -o -H newc | gzip -9 > ../iso/live/initrd.img
cd ..

echo "✅ Initrd created: $(du -h iso/live/initrd.img | cut -f1)"

# 3. تكوين GRUB
echo "🔧 Configuring GRUB..."
cat > iso/boot/grub/grub.cfg << 'GRUB'
set timeout=10
set default=0

menuentry "Lamp OS" {
    linux /live/vmlinuz quiet
    initrd /live/initrd.img
}

menuentry "Lamp OS (Text Mode)" {
    linux /live/vmlinuz 3
    initrd /live/initrd.img
}
GRUB

# 4. بناء ISO
echo "📀 Creating ISO..."
grub-mkrescue -o lamp-os-quick.iso iso/ 2>/dev/null

echo ""
echo "🎉 BUILD COMPLETE!"
echo "=================="
echo "ISO: lamp-os-quick.iso ($(du -h lamp-os-quick.iso | cut -f1))"
echo ""
echo "🚀 Test with:"
echo "   qemu-system-x86_64 -cdrom lamp-os-quick.iso -m 512M"
echo ""
echo "💾 To save to GitHub:"
echo "   git add . && git commit -m 'Lamp OS quick build' && git push"
