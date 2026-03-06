#!/usr/bin/env bash

# 🪔 Lamp OS - Rootfs Builder (KDE + system)
#
# This script builds a full Ubuntu rootfs (noble) with KDE Plasma and
# optional services, then prepares it for inclusion in the Lamp OS ISO.
#
# Usage:
#   sudo ./scripts/build_rootfs.sh [DESTDIR]
#
# Example:
#   sudo ./scripts/build_rootfs.sh /tmp/lamp-kde-rootfs
#
# After building, you can create a squashfs file with:
#   sudo ./scripts/make_rootfs_squash.sh /tmp/lamp-kde-rootfs /opt/rootfs.squashfs

set -e

DEST="${1:-/tmp/lamp-kde-rootfs}"
RELEASE="noble"
MIRROR="http://archive.ubuntu.com/ubuntu/"

if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root (or with sudo)."
  exit 1
fi

# debootstrap / dpkg are designed for Debian/Ubuntu systems.
# Running this on Alpine or other distros often fails due to incompatible libc/ld paths.
if [ -f /etc/os-release ]; then
  if ! grep -qiE 'debian|ubuntu' /etc/os-release; then
    if [ "${FORCE_BUILD_ROOTFS:-0}" != "1" ]; then
      cat <<'EOF'
ERROR: build_rootfs.sh is intended to run on Debian/Ubuntu.
Your current OS does not appear to be Debian-based.

To proceed, either:
  1) Run this script inside a Debian/Ubuntu environment (recommended).
  2) Set FORCE_BUILD_ROOTFS=1 to continue at your own risk.

Example:
  sudo FORCE_BUILD_ROOTFS=1 ./scripts/build_rootfs.sh /tmp/lamp-kde-rootfs
EOF
      exit 1
    fi
  fi
fi

echo "[+] Building rootfs in: $DEST"

if [ -d "$DEST" ]; then
  echo "[!] Existing rootfs found at $DEST. Removing..."
  rm -rf "$DEST"
fi

mkdir -p "$DEST"

echo "[+] Bootstrapping base Ubuntu ($RELEASE) with KDE packages..."

debootstrap --variant=minbase --components=main,universe \
  --include=systemd-sysv,plasma-desktop,sddm,kwin-wayland,kde-cli-tools,network-manager,plasma-discover,pipewire,pipewire-pulse,wireplumber,alsa-utils,xorg,xinit,dbus-x11,dbus,dbus-user-session,apt,ca-certificates,ssh,nano,less \
  $RELEASE "$DEST" "$MIRROR"

# Minimal post-setup tweaks
# Set a default root password (root/root) for convenience (not secure)
if [ -f "$DEST/etc/shadow" ]; then
  sed -i 's|^root:[^:]*:|root::|' "$DEST/etc/shadow" || true
fi

# Enable sudo without password for sudo group
if [ -f "$DEST/etc/sudoers" ]; then
  grep -q "^%sudo" "$DEST/etc/sudoers" || echo "%sudo   ALL=(ALL) NOPASSWD:ALL" >> "$DEST/etc/sudoers"
fi

# Create a default user if it doesn't exist
if ! grep -q "^lamp:" "$DEST/etc/passwd" 2>/dev/null; then
  echo "lamp:x:1000:1000:Lamp User:/home/lamp:/bin/bash" >> "$DEST/etc/passwd"
  echo "lamp:x:1000:" >> "$DEST/etc/group"
  mkdir -p "$DEST/home/lamp"
  chown 1000:1000 "$DEST/home/lamp" || true
fi

# Create a basic /etc/issue and /etc/hosts
cat > "$DEST/etc/issue" <<'EOF'

╔════════════════════════════════════════════════════════╗
║                                                        ║
║              🪔 Welcome to Lamp OS v1.0               ║
║                                                        ║
║  A lightweight Linux OS built with GRUB, Linux 6.6   ║
║  and BusyBox for embedded and education purposes     ║
║                                                        ║
╚════════════════════════════════════════════════════════╝

EOF

cat > "$DEST/etc/hosts" <<'EOF'
127.0.0.1   localhost lamp-os
::1         localhost
EOF

echo "[+] Rootfs built: $DEST"

echo "Next step: create squashfs with ./scripts/make_rootfs_squash.sh $DEST /opt/rootfs.squashfs"
