#!/usr/bin/env bash
set -euo pipefail

# LAMP OS - Installer
# Usage: sudo ./install-to-disk.sh /dev/sdX [--mbr]
# This script will DESTROY data on the target disk. Use carefully.

TARGET_DEVICE=""
USE_MBR=0

if [ "$#" -lt 1 ]; then
  echo "Usage: sudo $0 /dev/sdX [--mbr]"
  exit 1
fi

TARGET_DEVICE="$1"
if [ "${2:-}" = "--mbr" ]; then
  USE_MBR=1
fi

if [ "$EUID" -ne 0 ]; then
  echo "This installer must be run as root (sudo)." >&2
  exit 1
fi

if [ ! -b "$TARGET_DEVICE" ]; then
  echo "Target device $TARGET_DEVICE not found or not a block device." >&2
  exit 1
fi

read -p "WARNING: All data on $TARGET_DEVICE will be lost. Type YES to continue: " CONFIRM
if [ "$CONFIRM" != "YES" ]; then
  echo "Aborted."; exit 1
fi

# Check required tools
for cmd in parted mkfs.vfat mkfs.ext4 mount umount grub-install grub-mkconfig; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Required command not found: $cmd" >&2
    echo "Install grub, parted, dosfstools, e2fsprogs before running." >&2
    exit 1
  fi
done

echo "Preparing $TARGET_DEVICE (MBR mode: $USE_MBR)"

# Unmount any mounted partitions
umount ${TARGET_DEVICE}?* 2>/dev/null || true

if [ "$USE_MBR" -eq 1 ]; then
  echo "Creating MBR (msdos) partition table and single root partition..."
  parted -s "$TARGET_DEVICE" mklabel msdos
  parted -s "$TARGET_DEVICE" mkpart primary ext4 1MiB 100%
  PART_ROOT=${TARGET_DEVICE}1
else
  echo "Creating GPT with EFI and root partitions (plus bios_grub)"
  parted -s "$TARGET_DEVICE" mklabel gpt
  # 1) bios_grub (1MiB) for legacy GRUB on GPT
  parted -s "$TARGET_DEVICE" mkpart primary 1MiB 2MiB
  parted -s "$TARGET_DEVICE" set 1 bios_grub on
  # 2) EFI partition 512MiB
  parted -s "$TARGET_DEVICE" mkpart ESP fat32 2MiB 514MiB
  parted -s "$TARGET_DEVICE" set 2 boot on
  # 3) root rest
  parted -s "$TARGET_DEVICE" mkpart primary ext4 514MiB 100%
  PART_EFI=${TARGET_DEVICE}2
  PART_ROOT=${TARGET_DEVICE}3
fi

echo "Formatting partitions..."
if [ "$USE_MBR" -eq 1 ]; then
  mkfs.ext4 -F "$PART_ROOT"
else
  mkfs.vfat -F32 "$PART_EFI"
  mkfs.ext4 -F "$PART_ROOT"
fi

MNT=/mnt/lamp-install
rm -rf "$MNT"
mkdir -p "$MNT"
mount "$PART_ROOT" "$MNT"
mkdir -p "$MNT/boot"

if [ "$USE_MBR" -eq 0 ]; then
  mkdir -p "$MNT/boot/efi"
  mount "$PART_EFI" "$MNT/boot/efi"
fi

echo "Copying system files..."
# Copy kernel and initrd from repo iso/boot
cp -a /workspaces/lamp-os/iso/boot/vmlinuz "$MNT/boot/vmlinuz" || true
cp -a /workspaces/lamp-os/iso/boot/initrd.img "$MNT/boot/initrd.img" || true

# Extract initrd contents into target root (so disk root matches live initrd)
if [ -f /workspaces/lamp-os/iso/boot/initrd.img ]; then
  echo "Extracting initrd into $MNT (this will provide /bin, /sbin, /etc, /usr etc)..."
  gzip -dc /workspaces/lamp-os/iso/boot/initrd.img | (cd "$MNT" && cpio -id --no-absolute-filenames 2>/dev/null) || true
fi

# Ensure minimal system files
mkdir -p "$MNT/etc"
mkdir -p "$MNT/boot/grub"

# Create basic hostname
echo "lamp-os" > "$MNT/etc/hostname"

# Create a simple fstab using UUIDs
PART_ROOT_DEV="$PART_ROOT"
if command -v blkid &>/dev/null; then
  UUID_ROOT=$(blkid -s UUID -o value "$PART_ROOT_DEV" 2>/dev/null || true)
fi
if [ -n "${UUID_ROOT:-}" ]; then
  echo "UUID=${UUID_ROOT} / ext4 defaults 0 1" > "$MNT/etc/fstab"
else
  echo "${PART_ROOT_DEV} / ext4 defaults 0 1" > "$MNT/etc/fstab"
fi

# If EFI partition exists, add it to fstab
if [ -n "${PART_EFI:-}" ] && [ -b "$PART_EFI" ]; then
  if command -v blkid &>/dev/null; then
    UUID_EFI=$(blkid -s UUID -o value "$PART_EFI" 2>/dev/null || true)
  fi
  if [ -n "${UUID_EFI:-}" ]; then
    echo "UUID=${UUID_EFI} /boot/efi vfat umask=0077 0 2" >> "$MNT/etc/fstab"
  else
    echo "${PART_EFI} /boot/efi vfat umask=0077 0 2" >> "$MNT/etc/fstab"
  fi
fi

# Copy grub files (use existing grub.cfg if present)
mkdir -p "$MNT/boot/grub"
if [ -f /workspaces/lamp-os/iso/boot/grub/grub.cfg ]; then
  cp -a /workspaces/lamp-os/iso/boot/grub/* "$MNT/boot/grub/"
else
  cat > "$MNT/boot/grub/grub.cfg" <<'CFG'
set timeout=5
menuentry "LAMP OS" {
  linux /boot/vmlinuz
  initrd /boot/initrd.img
}
CFG
fi

echo "Installing GRUB..."
if [ "$USE_MBR" -eq 1 ]; then
  # Install legacy grub to MBR
  grub-install --target=i386-pc --boot-directory="$MNT/boot" "$TARGET_DEVICE" || true
else
  # EFI install (install both efi and fallback)
  grub-install --target=x86_64-efi --efi-directory="$MNT/boot/efi" --boot-directory="$MNT/boot" --removable --recheck || true
  # Also install legacy in case
  grub-install --target=i386-pc --boot-directory="$MNT/boot" "$TARGET_DEVICE" || true
fi

echo "Generating grub config (in chroot not required since grub.cfg copied)"
# Optionally generate grub.cfg
chroot "$MNT" grub-mkconfig -o /boot/grub/grub.cfg || true

echo "Syncing and unmounting..."
sync
umount "$MNT/boot/efi" 2>/dev/null || true
umount "$MNT/boot" 2>/dev/null || true
umount "$MNT" 2>/dev/null || true

echo "Installation to $TARGET_DEVICE complete. Remove USB/hard disk and boot the machine." 

exit 0
