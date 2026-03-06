#!/usr/bin/env bash

# Build a full Lamp OS ISO including KDE (requires a Debian/Ubuntu build environment).
# This script uses Docker (if available) to create a clean Debian environment and
# build the full rootfs + ISO without relying on the host base system.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DOCKER_IMAGE="debian:bookworm"
ROOTFS_DIR="/workspace/tmp/lamp-kde-rootfs"
SQUASH_PATH="/workspace/opt/rootfs.squashfs"

if ! command -v docker >/dev/null 2>&1; then
  cat <<'EOF'
ERROR: Docker is not installed or not available.

This script builds the full KDE-enabled rootfs inside a Debian container,
because building it directly in Alpine (or non-Debian) environments is unreliable.

To proceed, install Docker and re-run this script.

Alternatively, run the build directly on a Debian/Ubuntu machine without Docker.
EOF
  exit 1
fi

cat <<'EOF'
🛠️  Starting KDE-enabled ISO build using Docker (Debian bookworm)...
EOF

docker run --rm -it \
  -v "$REPO_ROOT":/workspace \
  -w /workspace \
  --hostname lamp-build \
  $DOCKER_IMAGE \
  bash -lc '
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends \
  build-essential debootstrap squashfs-tools xorriso \
  grub-pc-bin grub-efi-amd64-bin \
  qemu-user-static ca-certificates wget curl gnupg \
  python3 \
  && apt-get clean

# Build the rootfs (KDE + system)
./scripts/build_rootfs.sh "$ROOTFS_DIR"

# Create squashfs from the rootfs
./scripts/make_rootfs_squash.sh "$ROOTFS_DIR" "$SQUASH_PATH"

# Build the full ISO
./build.sh quick
'

cat <<'EOF'
✅ Build complete. The ISO is available at:
   $REPO_ROOT/lamp-os-x86_64.iso

If you want a smaller build (no KDE), run the regular build scripts.
EOF
