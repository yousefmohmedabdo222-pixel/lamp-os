ملاحظات سريعة لإعادة بناء `initrd` واختبار الطرفية التسلسلية

إعادة بناء `initrd` وISO:
```bash
cd /workspaces/lamp-os/initrd
# تأكد أن /bin/init و busybox و inittab موجودين
find . -print0 | cpio -0oH newc 2>/dev/null | gzip -9 > ../iso/boot/initrd.img

cd /workspaces/lamp-os
grub-mkrescue -o lamp-os.iso iso/
```

تشغيل QEMU تفاعليًا عبر الطرفية التسلسلية:
```bash
cd /workspaces/lamp-os
# Example tests for different architectures
# x86_64
qemu-system-x86_64 -cdrom lamp-os.iso -m 1024 -smp 2 -serial stdio -display none -accel tcg

# aarch64 (boot kernel + initrd directly)
qemu-system-aarch64 -machine virt -cpu cortex-a57 -nographic \
    -kernel iso/boot/vmlinuz-aarch64 -initrd iso/boot/initrd.img -append 'console=ttyAMA0'

# riscv64
qemu-system-riscv64 -machine virt -nographic -kernel iso/boot/vmlinuz-riscv64 -initrd iso/boot/initrd.img -append 'console=ttyS0'
```
إذا أردت تسجيل الخرج بدلاً من الجلسة التفاعلية:
```bash
qemu-system-x86_64 -cdrom lamp-os.iso -m 1024 -smp 2 -serial file:/tmp/boot.log -display none -accel tcg -no-reboot
tail -f /tmp/boot.log
```

ملف `initrd/etc/inittab` الحالي يقوم بإنشاء الأجهزة الأساسية ويشغّل `getty` على `ttyS0` و shell على `console`.

إذا لم يظهر موجه شل على الطرفية التسلسلية:
- تأكد أن `inittab` يحتوي `ttyS0::respawn:/bin/getty -L ttyS0 115200 vt100`
- تأكد أن `/dev/ttyS0` و`/dev/console` موجودان (يمكن إنشاءهما بواسطة `mknod` أو `mdev -s`).

ملفات مهمة:
- `initrd/etc/inittab`
- `initrd/bin/busybox`
- `iso/boot/initrd.img`
- `lamp-os.iso`
