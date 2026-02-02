# 🚀 دليل البدء السريع - Lamp OS

## المتطلبات الأساسية

### نظام التشغيل:
- **Ubuntu 20.04+** أو **Debian 11+**
- **CPU**: معالج x86_64
- **RAM**: 4GB على الأقل
- **مساحة تخزين**: 20GB على الأقل

### البرامج المطلوبة:
```bash
# تحديث النظام أولاً
sudo apt update && sudo apt upgrade -y

# تثبيت المتطلبات الأساسية
sudo apt install -y \
    build-essential \
    gcc g++ \
    make cmake \
    git \
    wget curl \
    libssl-dev \
    libncurses-dev \
    flex bison \
    dosfstools \
    grub-pc-bin \
    grub-efi-amd64-bin \
    xorriso \
    qemu-system-x86

# تثبيت Rust (للأدوات الآمنة)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"
```

---

## خطوات التثبيت الأولى

### 1️⃣ استنساخ المشروع:
```bash
cd ~/projects
git clone https://github.com/yourusername/lamp-os.git
cd lamp-os
```

### 2️⃣ إنشاء بنية المجلدات:
```bash
mkdir -p {kernel,gui,initrd,iso/{boot/grub,live},src}
chmod +x *.sh
```

### 3️⃣ اختبار البيئة:
```bash
# تحقق من إصدارات الأدوات
gcc --version
g++ --version
rustc --version
make --version
```

---

## بناء نواة Linux مخصصة

### الخطوة 1: تحميل مصادر النواة
```bash
cd kernel
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.6.tar.xz
tar -xf linux-6.6.tar.xz
cd linux-6.6
```

### الخطوة 2: التكوين الأساسي
```bash
# نسخ التكوين الافتراضي
make defconfig

# (اختياري) تخصيص التكوين بالكامل
make menuconfig
```

### الخطوة 3: التحسينات المطلوبة
```bash
# أضف هذه الخطوط إلى .config
cat >> .config << 'EOF'
CONFIG_LOCALVERSION="-lamp"
CONFIG_64BIT=y
CONFIG_FB=y
CONFIG_FRAMEBUFFER_CONSOLE=y
CONFIG_DRM=y
CONFIG_DRM_FBDEV_EMULATION=y
CONFIG_INPUT_KEYBOARD=y
CONFIG_INPUT_MOUSE=y
CONFIG_HID=y
CONFIG_USB=y
CONFIG_SLAB_FREELIST_HARDENED=y
CONFIG_SND=n
CONFIG_WIRELESS=n
EOF

# أعد البناء مع التكوين الجديد
make oldconfig
```

### الخطوة 4: البناء
```bash
# بناء بنسخ متوازية (استبدل N برقم أنويتك)
make -j$(nproc)

# يستغرق هذا حوالي 10-30 دقيقة حسب جهازك
# ستجد النتيجة في: arch/x86_64/boot/bzImage
```

### التحقق من النجاح:
```bash
ls -lh arch/x86_64/boot/bzImage
# يجب أن يكون حوالي 10MB
```

---

## بناء نظام Initrd

### الخطوة 1: إنشاء البنية الأساسية
```bash
cd ../../initrd

# إنشاء المجلدات الأساسية
mkdir -p bin sbin lib etc dev proc sys root tmp home
chmod 1777 tmp
```

### الخطوة 2: استخدام BusyBox
```bash
# تحميل BusyBox
wget https://busybox.net/downloads/binaries/1.35.0-x86_64-linux-musl/busybox
chmod +x busybox

# نسخ BusyBox إلى bin/sh
cp busybox bin/sh

# إنشاء الروابط الرمزية للأوامر الأخرى
./busybox | grep "^\t" | sed 's/^[[:space:]]*//;s/[,[:space:]]*$//' | while read cmd; do
    ln -sf ../bin/sh bin/$cmd
done
```

### الخطوة 3: نسخ المكتبات المطلوبة
```bash
# نسخ مكتبات musl
cp /lib/x86_64-linux-musl/libc.so.1 lib/ 2>/dev/null || \
cp /lib64/ld-linux-x86-64.so.2 lib/

# نسخ مكتبات أخرى إذا لزم الحال
```

### الخطوة 4: إنشاء ملفات الإعدادات الأساسية
```bash
# إنشاء فئة الأجهزة
sudo mknod dev/console c 5 1
sudo mknod dev/null c 1 3
sudo mknod dev/zero c 1 5
sudo mknod dev/tty c 5 0

# إنشاء ملفات الإعدادات
cat > etc/hostname << EOF
lamp-os
EOF

cat > etc/hosts << EOF
127.0.0.1   localhost lamp-os
::1         localhost
EOF

# ملف كلمات المرور (بسيط للاختبار)
cat > etc/passwd << EOF
root:x:0:0:root:/root:/bin/sh
EOF
```

### الخطوة 5: إنشاء برنامج التشغيل
```bash
cat > init << 'EOF'
#!/bin/sh

echo "=========================================="
echo "       🪔 Lamp OS - Initializing"
echo "=========================================="

# تركيب نقاط التثبيت
mount -t devtmpfs none /dev
mount -t proc proc /proc
mount -t sysfs sys /sys

echo "✓ Filesystems mounted"

# بدء الخدمات الأساسية
export PATH=/bin:/sbin:/usr/bin:/usr/sbin
export LD_LIBRARY_PATH=/lib:/usr/lib

echo "✓ Environment initialized"

# تشغيل البوصة أو الواجهة الرسومية
if [ -f /opt/lamp-gui/lamp-gui ]; then
    echo "🚀 Starting Lamp OS GUI..."
    exec /opt/lamp-gui/lamp-gui
else
    echo "Starting interactive shell..."
    exec /bin/sh
fi
EOF

chmod +x init
```

### الخطوة 6: إنشاء ملف Initrd النهائي
```bash
# العودة إلى مجلد initrd وضغط المحتويات
cd /workspaces/lamp-os/initrd

# إنشاء ملف CPIO
find . -print0 | cpio -0oH newc | gzip -9 > ../iso/boot/initrd.img

# التحقق من الحجم
ls -lh ../iso/boot/initrd.img
```

---

## بناء الواجهة الرسومية الأساسية

### إنشاء مشروع C++ بسيط:
```bash
cd ../gui

cat > CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.10)
project(LampGUI)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O2 -Wall")

# مصادر المشروع
set(SOURCES
    src/main.cpp
    src/graphics.cpp
    src/window_manager.cpp
)

add_executable(lamp-gui ${SOURCES})

# المكتبات المطلوبة
target_link_libraries(lamp-gui
    m  # مكتبة الرياضيات
)
EOF
```

### إنشاء الملفات الأساسية:
```bash
mkdir -p src

# main.cpp
cat > src/main.cpp << 'EOF'
#include <iostream>
#include <cstring>

extern "C" {
    int fb_init(const char* device);
    void fb_clear(uint32_t color);
    void fb_draw_pixel(int x, int y, uint32_t color);
    void fb_flush();
    void fb_close();
}

int main() {
    std::cout << "🪔 Initializing Lamp OS GUI..." << std::endl;
    
    // تهيئة Framebuffer
    if (fb_init("/dev/fb0") != 0) {
        std::cerr << "Error: Could not initialize framebuffer" << std::endl;
        return 1;
    }
    
    // رسم خلفية زرقاء
    fb_clear(0x0078D4);
    
    // رسم نص ترحيبي (مبسط)
    for (int i = 0; i < 100; i++) {
        fb_draw_pixel(100 + i, 100, 0xFFFFFF);
    }
    
    fb_flush();
    
    // انتظر 3 ثوان
    sleep(3);
    
    fb_close();
    std::cout << "✓ Lamp OS GUI initialized successfully" << std::endl;
    
    return 0;
}
EOF

# graphics.cpp
cat > src/graphics.cpp << 'EOF'
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>
#include <cstring>

static int fb_fd = -1;
static uint32_t* fb_mem = nullptr;
static int fb_width = 1024;
static int fb_height = 768;

extern "C" {

int fb_init(const char* device) {
    fb_fd = open(device, O_RDWR);
    if (fb_fd < 0) return -1;
    
    fb_mem = (uint32_t*)mmap(nullptr, 
        fb_width * fb_height * 4,
        PROT_READ | PROT_WRITE,
        MAP_SHARED,
        fb_fd, 0);
    
    return (fb_mem == MAP_FAILED) ? -1 : 0;
}

void fb_clear(uint32_t color) {
    if (!fb_mem) return;
    for (int i = 0; i < fb_width * fb_height; i++) {
        fb_mem[i] = color;
    }
}

void fb_draw_pixel(int x, int y, uint32_t color) {
    if (!fb_mem || x < 0 || y < 0 || x >= fb_width || y >= fb_height)
        return;
    fb_mem[y * fb_width + x] = color;
}

void fb_flush() {
    // تفريغ الذاكرة المخزنة مؤقتاً
    __asm__ volatile ("" : : : "memory");
}

void fb_close() {
    if (fb_mem) {
        munmap(fb_mem, fb_width * fb_height * 4);
        fb_mem = nullptr;
    }
    if (fb_fd >= 0) {
        close(fb_fd);
        fb_fd = -1;
    }
}

}
EOF
```

### البناء:
```bash
mkdir build
cd build
cmake ..
make -j$(nproc)

# النتيجة في: ./lamp-gui
```

---

## إعداد GRUB والـ ISO

### ملف GRUB Configuration:
```bash
mkdir -p iso/boot/grub

cat > iso/boot/grub/grub.cfg << 'EOF'
set default=0
set timeout=5

menuentry "Lamp OS" {
    insmod gzio
    insmod part_msdos
    insmod ext2
    
    set root='hd0,msdos1'
    
    echo "Loading Lamp OS..."
    
    linux /vmlinuz root=/dev/ram0 quiet splash
    initrd /initrd.img
}

menuentry "Lamp OS (Debug)" {
    insmod gzio
    insmod part_msdos
    insmod ext2
    
    set root='hd0,msdos1'
    
    echo "Loading Lamp OS (Debug)..."
    
    linux /vmlinuz root=/dev/ram0
    initrd /initrd.img
}
EOF
```

### إنشاء ISO:
```bash
# نسخ النواة إلى مجلد التشغيل
cp kernel/linux-6.6/arch/x86_64/boot/bzImage iso/boot/vmlinuz

# إنشاء ملف ISO
grub-mkrescue -o lamp-os.iso iso/

# أو استخدام xorriso مباشرة
xorriso -as mkisofs \
    -R -J \
    -b boot/grub/i386-pc/eltorito.img \
    -no-emul-boot \
    -boot-load-size 4 \
    -boot-info-table \
    -o lamp-os.iso \
    iso/

echo "✓ ISO created: lamp-os.iso"
ls -lh lamp-os.iso
```

---

## الاختبار مع QEMU

### تشغيل النظام:
```bash
# اختبار بسيط
qemu-system-x86_64 \
    -cdrom lamp-os.iso \
    -m 512 \
    -smp 2 \
    -enable-kvm

# مع إخراج إلى ملف
qemu-system-x86_64 \
    -cdrom lamp-os.iso \
    -m 1024 \
    -smp 4 \
    -enable-kvm \
    -serial file:qemu.log
```

### التصحيح:
```bash
# تشغيل مع رسالة Boot مفصلة
qemu-system-x86_64 \
    -cdrom lamp-os.iso \
    -m 512 \
    -serial stdio \
    -d guest_errors
```

---

## الخطوات التالية

✅ **أكملت:**
- [ ] إعداد بيئة التطوير
- [ ] بناء نواة Linux
- [ ] إنشاء Initrd
- [ ] تطوير GUI أساسي
- [ ] إنشاء ISO

📋 **التالي:**
1. تحسين الواجهة الرسومية
2. إضافة تطبيقات (File Manager, etc.)
3. بناء أدوات Rust
4. اختبار شامل على الأجهزة الحقيقية

---

## الأوامر المفيدة

```bash
# عرض معلومات الملف ISO
file lamp-os.iso

# اختبار صحة ISO
sha256sum lamp-os.iso

# كتابة ISO على USB
sudo dd if=lamp-os.iso of=/dev/sdX bs=4M status=progress

# مراقبة أخطاء البناء
grep -i error build.log

# تنظيف البناء القديم
make clean
rm -rf build iso/
```

---

📚 **مراجع مفيدة:**
- [Linux Kernel Documentation](https://www.kernel.org/doc/)
- [BusyBox Documentation](https://busybox.net/downloads/busybox-1.35.0.tar.bz2)
- [QEMU Documentation](https://wiki.qemu.org/)
- [Framebuffer Documentation](https://www.kernel.org/doc/html/latest/fb/)

---

🎯 **بعد إكمال هذه الخطوات، ستكون لديك:**
- ✨ نواة Linux مخصصة وخفيفة
- 🎨 واجهة رسومية أساسية
- 🚀 نظام تشغيل قابل للتمهيد

**مرحباً بك في عالم تطوير Lamp OS! 🪔**
