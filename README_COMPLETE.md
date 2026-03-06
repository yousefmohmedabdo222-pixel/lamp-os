# 🔥 LAMP OS v2.0 - Complete Operating System

**Version:** 2.0 Premium Edition  
**Release Date:** February 2026  
**Creator:** yousef mohmed  
**License:** Open Source

---

## 🎯 What is LAMP OS?

LAMP OS is a lightweight, modern operating system built from scratch with:

- ✅ **Custom Linux Kernel** (6.6.0-lamp) - optimized for speed
- ✅ **BusyBox Integration** - 100+ system utilities in one binary
- ✅ **Windows 7-like Modern GUI** - beautiful and intuitive interface
- ✅ **Animated Screens** - professional boot sequences and transitions
- ✅ **Sound Effects** - system feedback and notifications
- ✅ **Interactive Installer** - easy installation to real hardware (USB/Disk)
- ✅ **Post-Install Setup Wizard** - automatic user profile creation
- ✅ **Display Auto-Scaling** - adapts to any screen resolution
- ✅ **Full UEFI + BIOS Support** - boots on any computer
- ✅ **Professional Branding** - designer name on all screens

---

## 🚀 Quick Start

### Option 1: Try from Live USB (No Installation)

```bash
# 1. Write ISO to USB (see Installation Guide)
# 2. Boot from USB
# 3. Select "Install LAMP OS to Disk" or explore with System Utilities
```

### Option 2: Install to Hard Disk

```bash
# See INSTALLATION_GUIDE.md for detailed step-by-step instructions
# Supports both UEFI and BIOS boot
# Full partitioning and user setup included
```

---

## 📦 What's Included

### Core System
- **Linux Kernel 6.6.0-lamp** (12MB) - custom compiled
- **BusyBox 1.1** (1.1MB) - 100+ Unix utilities
- **GRUB2 Bootloader** - industry standard boot manager
- **initramfs** (2.1MB) - complete root filesystem

### GUI & Interface
- **Desktop Menu** - 9-option interactive menu
- **File Manager** - browse and manage files
- **Text Editor** - edit configuration files
- **System Monitor** - CPU, memory, disk statistics
- **Settings Manager** - configure system options
- **Terminal** - powerful command-line access

### Pre-Installed Tools
```
File Operations:  cp, mv, rm, ls, find, tar, zip, unzip
Text Processing: grep, sed, awk, cut, sort, uniq, wc
System Admin:    sudo, useradd, userdel, chmod, chown
Network:         ping, netstat, ifconfig, ssh, scp, wget
Development:     bash, sh, make, git, compiler tools
Media:           convert, resize, ffmpeg basics
```

### Boot Screens
- **Animated Splash Screen** - 3-second intro with loading bars
- **Boot Sequence Screen** - system initialization display
- **Login Screen** - user authentication interface
- **Partition Selection Screen** - installation target selector
- **Shutdown Screen** - graceful system shutdown animation
- **LAMP Logo Screen** - system branding display

### Sound System
- Boot startup sound (ascending tone)
- Login success chime
- Notification beep
- Error alert tone
- Shutdown farewell sound

---

## 🎨 System Features

### Display Scaling
- Auto-detects monitor resolution
- Supports 1366x768 to 4K (3840x2160)
- Automatic framebuffer configuration
- Per-user display preferences

### User Management
- Create multiple user profiles
- Individual configuration storage
- Profile picture assignment
- Optional password protection
- Automatic login option

### File System
- **Root Filesystem:** ext4 (Linux standard)
- **Boot Partition:** ext4 (512MB minimum)
- **EFI Partition:** FAT32 (512MB, UEFI systems)
- **Journal:** Enabled for crash recovery

### Boot Options
- **UEFI:** Full SecureBoot-ready structure
- **BIOS/Legacy:** MBR support with fallback
- **Dual Boot:** Works alongside other OSes
- **Boot Parameters:** Customizable via GRUB

---

## 📊 System Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| **Processor** | 1GHz single-core | 2GHz dual-core or better |
| **RAM** | 256MB | 1GB or more |
| **Disk** | 5GB | 20GB or more |
| **Boot** | BIOS or UEFI | Both supported |
| **Graphics** | VGA | HDMI/DisplayPort recommended |
| **Network** | Optional | Ethernet or WiFi for updates |

---

## 🔧 Installation Methods

### 1. USB Installation (Recommended)
```bash
# Write ISO to USB using Rufus (Windows) or dd (Linux/Mac)
sudo dd if=lamp-os-complete-installer.iso of=/dev/sdX bs=4M
# Boot from USB, follow interactive installer
```

### 2. Virtual Machine
```bash
# QEMU/VirtualBox
# Create 20GB virtual disk
# Attach ISO
# Boot and follow installer
```

### 3. Dual Boot
```bash
# Create free space on existing system
# Boot from USB
# Choose manual partitioning
# Select unallocated space
```

### 4. Network Installation
```bash
# For PXE/network boot environments
# Copy ISO contents to boot server
# Configure DHCP/TFTP
# PXE-boot target system
```

---

## 📖 File Structure

```
/
├── boot/               # Kernel and bootloader
│   ├── vmlinuz        # Linux kernel
│   ├── initrd.img     # Initial RAM disk
│   └── grub/          # GRUB configuration
├── bin/               # Essential binaries (busybox)
├── sbin/              # System binaries
├── usr/               # User programs
│   ├── bin/
│   ├── local/         # Custom scripts
│   └── share/
├── etc/               # Configuration files
│   ├── inittab        # Init system config
│   ├── hostname
│   ├── fstab          # Filesystem mount config
│   └── network/
├── dev/               # Device files
├── proc/              # Process information
├── sys/               # System information
├── home/              # User home directories
├── root/              # Root user home
├── tmp/               # Temporary files
└── opt/               # Optional packages
```

---

## 🎮 Using LAMP OS

### First Boot
1. System automatically launches **Display Setup Wizard**
2. Select monitor resolution
3. Create user profile
4. Set optional password
5. Choose profile picture
6. Desktop menu appears

### Desktop Menu
```
[1] File Manager       [5] Settings
[2] Text Editor        [6] Network Manager
[3] System Monitor     [7] Terminal
[4] About LAMP OS      [8] Restart
[9] Exit to Shell      [0] Shutdown
```

### File Management
```bash
# List files
ls -la

# Navigate directories
cd /home/yousef
pwd

# Copy/Move files
cp source.txt destination.txt
mv old.txt new.txt

# Create directories
mkdir new_folder

# View file contents
cat filename.txt
more largefile.txt
```

### Text Editing
```bash
# Edit files with nano
nano /etc/hostname

# Or use vim
vi /etc/config

# Create new file
cat > newfile.txt
# Type content, Ctrl+D to save
```

### System Administration
```bash
# Check disk usage
df -h

# Check RAM usage
free -h

# View system information
uname -a

# List running processes
ps aux

# View system logs
dmesg

# Reboot system
sudo reboot

# Shutdown system
sudo shutdown -h now
```

### Network
```bash
# Check network interfaces
ip link show

# Assign IP address
sudo ip addr add 192.168.1.100/24 dev eth0

# Enable interface
sudo ip link set eth0 up

# Test connectivity
ping 8.8.8.8

# Download files
wget https://example.com/file.txt

# Secure shell
ssh user@remote.server
```

---

## 🔒 Security

### Default Security
- No default password (customize during setup)
- Non-root user creation recommended
- File permissions enforced (rwx)
- Secure boot-ready structure (UEFI)

### Best Practices
- Change default passwords immediately
- Use strong passwords (8+ characters, mixed case, numbers, symbols)
- Enable filesystem encryption for sensitive data
- Regular backups of important files
- Update system regularly

### Sudo Access
```bash
# Run command as root
sudo /root/maintenance.sh

# Switch to root user
sudo su

# Grant sudo access to user
sudo usermod -aG sudo username
```

---

## 🛠️ Development & Customization

### Build Your Own Kernel
```bash
# Located at /usr/src/kernel/
# Requires build tools installed
cd /usr/src/kernel
make menuconfig
make -j$(nproc)
make install
```

### Add Custom Applications
```bash
# Copy to application directory
sudo cp myapp /usr/local/bin/

# Make executable
sudo chmod +x /usr/local/bin/myapp

# Create menu shortcut
sudo nano /etc/lamp-os/menu.conf
```

### System Customization
```bash
# Modify desktop menu
nano /usr/local/bin/lamp-desktop-menu

# Customize boot splash
nano /usr/local/bin/lamp-splash

# Edit boot animation
nano /usr/local/bin/lamp-boot
```

---

## 🐛 Troubleshooting

### System Won't Boot
1. Check BIOS boot order (USB/disk first)
2. Enable UEFI or Legacy mode as needed
3. Verify ISO integrity (checksum)
4. Try different USB port
5. Boot from USB and use recovery utilities

### Cannot Log In
1. Verify username/password (case-sensitive)
2. If no password set, just press Enter
3. Use recovery shell (Ctrl+Alt+F2)
4. Reset password: `sudo passwd username`

### Low Disk Space
```bash
# Check disk usage
df -h

# Find large files
du -sh /*

# Clean temporary files
rm -rf /tmp/*

# Expand root filesystem
sudo parted /dev/sda resizepart 2 100%
sudo resize2fs /dev/sda2
```

### Keyboard/Mouse Not Working
1. Check USB connection
2. Disable USB power saving: `echo -1 > /sys/module/usbcore/parameters/autosuspend`
3. Try different USB port
4. Update system firmware if available

### Network Not Working
```bash
# Check interface
ip link show

# Bring up interface
sudo ip link set eth0 up

# Request DHCP address
sudo dhclient eth0

# Set static IP
sudo ip addr add 192.168.1.100/24 dev eth0

# Check DNS
cat /etc/resolv.conf
```

---

## 📚 Documentation

- **INSTALLATION_GUIDE.md** - Complete installation instructions
- **BUILDING.md** - How to build LAMP OS from source
- **/usr/share/doc/lamp-os/** - System documentation
- **/usr/share/man/** - Manual pages

---

## 🔄 Updates & Maintenance

### Check for Updates
```bash
lamp-check-updates

# Or manually
sudo apt update
```

### Update System
```bash
# Update all packages
sudo apt upgrade

# Update kernel
lamp-kernel-update
```

### Backup System
```bash
# Full system backup
tar czf lamp-os-backup.tar.gz /home /etc /opt

# Or using rsync
rsync -av / /mnt/backup/

# Restore from backup
tar xzf lamp-os-backup.tar.gz -C /
```

---

## 🤝 Contributing

Want to improve LAMP OS?

1. Report bugs: [yousef.mohmed@lamp-os.dev]
2. Suggest features: Submit ideas
3. Contribute code: Fork and submit pull requests
4. Document issues: Help improve documentation
5. Test on hardware: Report compatibility

---

## 📞 Support & Contact

- **Email:** yousef.mohmed@lamp-os.dev
- **Documentation:** /usr/share/doc/lamp-os/
- **System Help:** `help` command in terminal
- **About Screen:** Select [4] in desktop menu

---

## 📜 License

LAMP OS is open source and free to use.

See LICENSE file for full details.

---

## 🎉 Credits

**LAMP OS v2.0**

Created with ❤️ by **yousef mohmed**

- Linux Kernel Team
- BusyBox Project
- GRUB Development Team
- Open Source Community

---

## 🌟 Version History

### v2.0 - Premium Edition (February 2026)
- ✨ Interactive installation wizard with TUI
- ✨ Animated boot screens (6 total)
- ✨ Sound effects system
- ✨ Post-install setup wizard
- ✨ User profile management
- ✨ Display auto-scaling
- ✨ Professional designer branding
- ✨ Full UEFI + BIOS support

### v1.0 - Initial Release (January 2026)
- Linux kernel and BusyBox integration
- Basic shell interface
- System utilities
- Manual installation

---

**Enjoy LAMP OS! 🚀**

*Built for simplicity. Designed for performance. Made with passion.*

---

For the latest information, visit: https://lamp-os.dev

**LAMP OS © 2026** - Created by yousef mohmed
