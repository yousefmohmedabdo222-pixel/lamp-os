# 🚀 LAMP OS - Quick Start Guide

## 📥 Prerequisites

You need:
- QEMU installed (`qemu-system-x86_64`)
- 512MB RAM available
- Linux/Unix environment (or WSL on Windows)

## ⚡ Quick Boot

### Method 1: Simple Boot with Output Logging

```bash
cd /workspaces/lamp-os

# Boot and log to file
timeout 30 qemu-system-x86_64 \
  -cdrom lamp-os.iso \
  -m 512M \
  -nographic \
  -serial file:/tmp/lamp-boot.log \
  -accel tcg

# View the log
cat /tmp/lamp-boot.log | tail -50
```

### Method 2: Interactive Boot

```bash
cd /workspaces/lamp-os

# Boot and interact via QEMU monitor
qemu-system-x86_64 \
  -cdrom lamp-os.iso \
  -m 512M \
  -monitor stdio \
  -serial file:/tmp/lamp-boot.log \
  -accel tcg
```

## 🔍 Verifying Success

Look for these lines in the output:

✅ **Successful Boot Indicators:**
```
Run /bin/sh as init process
/bin/sh: can't access tty; job control turned off
/ # 
```

The `/ #` is your shell prompt - the system is ready!

## 🎯 What You Can Do

### Available Commands

After the system boots, you have access to:

**File Operations:**
```bash
ls -lah           # List files with details
cp file1 file2    # Copy file
rm file           # Remove file
mkdir newdir      # Create directory
cat file          # View file contents
```

**System Information:**
```bash
uname -a          # System info
uptime            # How long system is running
ps aux            # List processes
df -h             # Disk usage
free -h           # Memory usage
```

**Networking:**
```bash
ip addr show      # Show IP addresses
ping 8.8.8.8      # Test network
hostname          # Show hostname
```

### LAMP OS Tools

**Main Menu System:**
```bash
lamp-menu
```

Options:
- Launch GUI
- Interactive Shell
- System Information
- Monitoring
- Testing

**Network Configuration:**
```bash
lamp-network
```

Options:
- View network info
- Configure interfaces
- Test connectivity
- Set DNS

**System Utilities:**
```bash
lamp-system
```

Options:
- Disk info
- Process monitoring
- CPU/Memory info
- System backup
- Diagnosis

**GUI Application:**
```bash
/opt/lamp-gui/lamp-gui
# or
lamp-gui
```

## 📊 File Structure

```
/workspaces/lamp-os/
├── lamp-os.iso          # Bootable ISO image
├── iso/                 # ISO contents
│   ├── boot/
│   │   ├── vmlinuz      # Linux kernel
│   │   ├── initrd.img   # Initial RAM disk
│   │   └── grub/
│   │       └── grub.cfg # Boot configuration
│   └── ...
├── initrd/              # Initramfs source
│   ├── bin/             # Executables (busybox)
│   ├── opt/lamp-gui/    # GUI application
│   ├── usr/local/bin/   # LAMP OS tools
│   ├── etc/
│   │   └── inittab      # Init configuration
│   └── ...
└── ...
```

## 🔧 Building from Source

### Rebuild Initrd

```bash
cd /workspaces/lamp-os/initrd

# Create new initrd image
find . -print0 | cpio -0oH newc 2>/dev/null | gzip -9 > ../iso/boot/initrd.img
```

### Rebuild ISO

```bash
cd /workspaces/lamp-os

# Create new ISO
grub-mkrescue -o lamp-os.iso iso/

# Verify
ls -lh lamp-os.iso
```

### Complete Build

```bash
cd /workspaces/lamp-os

# Rebuild both
./build_quick.sh
# or
./build_complete.sh
```

## 🧪 Testing

### Run Comprehensive Test

```bash
./test-comprehensive.sh
```

This will:
- Boot the system
- Test key features
- Verify tools work
- Generate a report

### Manual Testing

```bash
# Boot with 40 second timeout
timeout 40 qemu-system-x86_64 \
  -cdrom lamp-os.iso \
  -m 512M \
  -nographic \
  -serial file:/tmp/test.log \
  -accel tcg

# Check results
tail /tmp/test.log
```

## 📝 Common Tasks

### Access Help

```bash
lamp-help
# or
cat /usr/local/share/doc/lamp-os/help.txt
```

### View System Status

```bash
lamp-system
# Then select option 7 for full diagnosis
```

### Configure Network

```bash
lamp-network
# Select option to configure interface
```

### Launch GUI

```bash
lamp-menu
# Select option 1, or directly:
/opt/lamp-gui/lamp-gui
```

## 🐛 Troubleshooting

### System doesn't boot

**Check:**
1. ISO file exists: `ls -lh lamp-os.iso`
2. QEMU installed: `which qemu-system-x86_64`
3. Enough memory: 512MB minimum

**Solution:**
```bash
# Rebuild ISO
cd /workspaces/lamp-os/initrd
find . -print0 | cpio -0oH newc 2>/dev/null | gzip -9 > ../iso/boot/initrd.img
cd /workspaces/lamp-os
grub-mkrescue -o lamp-os.iso iso/
```

### No shell prompt appears

**Check boot log:**
```bash
tail /tmp/lamp-boot.log | grep "Run /bin/sh"
```

**If kernel panics:**
- Check `/tmp/lamp-boot.log` for errors
- Verify initrd.img size: `ls -lh iso/boot/initrd.img`
- Rebuild: `./build_quick.sh`

### Tools not available

**Verify they exist:**
```bash
ls -lh /usr/local/bin/lamp-*
```

**Rebuild initrd and ISO:**
```bash
cd /workspaces/lamp-os
./build_complete.sh
```

## 📚 Documentation

- `README.md` - Project overview
- `FINAL_SUCCESS.md` - Boot success details
- `BOOT_SUCCESS.md` - Boot configuration
- `help.txt` - System help documentation
- `BOOT_REPORT.sh` - Generate boot report

## 🚀 Next Steps

1. **Boot the system:**
   ```bash
   timeout 30 qemu-system-x86_64 -cdrom lamp-os.iso -m 512M -nographic -serial file:/tmp/boot.log -accel tcg
   ```

2. **Check the output:**
   ```bash
   tail /tmp/boot.log | grep "/ #"
   ```

3. **Customize the system:**
   - Add more tools to `/initrd/usr/local/bin/`
   - Modify scripts
   - Rebuild ISO

4. **Create your own version:**
   - Fork the repository
   - Make changes
   - Build and test

## 📞 Support

For issues and questions:
- GitHub Issues: https://github.com/yousefmohmedabdo222-pixel/lamp-os/issues
- Documentation: See README.md and other .md files

## ⭐ Quick Reference

```bash
# Boot
timeout 30 qemu-system-x86_64 -cdrom lamp-os.iso -m 512M -nographic -serial file:/tmp/boot.log -accel tcg

# View log
tail -50 /tmp/boot.log

# Rebuild
cd /workspaces/lamp-os/initrd && find . -print0 | cpio -0oH newc 2>/dev/null | gzip -9 > ../iso/boot/initrd.img
cd /workspaces/lamp-os && grub-mkrescue -o lamp-os.iso iso/

# Test
./test-comprehensive.sh

# Help
lamp-help
```

---

**Happy booting! 🚀**

For detailed information, see the full documentation in the repository.
