#!/usr/bin/env bash

# 🪔 Lamp OS - Rootfs -> SquashFS
#
# Usage:
#   sudo ./scripts/make_rootfs_squash.sh <ROOTFS_DIR> <OUTPUT_SQUASH>
#
# Example:
#   sudo ./scripts/make_rootfs_squash.sh /tmp/lamp-kde-rootfs /opt/rootfs.squashfs

set -e

ROOTFS="${1:-}"
OUT="${2:-}"

if [ -z "$ROOTFS" ] || [ -z "$OUT" ]; then
  echo "Usage: $0 <ROOTFS_DIR> <OUTPUT_SQUASH>"
  exit 1
fi

if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root (or with sudo)."
  exit 1
fi

if [ ! -d "$ROOTFS" ]; then
  echo "Rootfs directory not found: $ROOTFS"
  exit 1
fi

if ! command -v mksquashfs >/dev/null 2>&1; then
  echo "mksquashfs not found. Install squashfs-tools (e.g. apt install squashfs-tools)."
  exit 1
fi

# Ensure output directory exists
mkdir -p "$(dirname "$OUT")"

echo "[+] Creating squashfs: $OUT"
mksquashfs "$ROOTFS" "$OUT" -comp xz -b 1048576 -noappend

echo "[+] Squashfs created: $OUT"
