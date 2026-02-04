#!/usr/bin/env bash
set -euo pipefail

# Ensure a kernel image exists in iso/boot. If missing, attempt to download and build it.
# Usage: ./scripts/ensure_kernel.sh [TARGET_ARCH]

TARGET_ARCH=${1:-}
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ISO_BOOT="$PROJECT_ROOT/iso/boot"

# map uname to our TARGET_ARCH if not provided
if [ -z "$TARGET_ARCH" ]; then
    UNAME_M="$(uname -m)"
    case "$UNAME_M" in
        x86_64|amd64) TARGET_ARCH="x86_64" ;;
        aarch64) TARGET_ARCH="aarch64" ;;
        armv7l|armv6l) TARGET_ARCH="arm" ;;
        riscv64) TARGET_ARCH="riscv64" ;;
        ppc64le|ppc64) TARGET_ARCH="powerpc" ;;
        loongarch64) TARGET_ARCH="loongarch" ;;
        *) TARGET_ARCH="$UNAME_M" ;;
    esac
fi

echo "Ensuring kernel image for arch: $TARGET_ARCH"

KERNEL_CANDIDATES=("$ISO_BOOT/vmlinuz" "$ISO_BOOT/vmlinuz-$TARGET_ARCH")
for f in "${KERNEL_CANDIDATES[@]}"; do
    if [ -f "$f" ]; then
        echo "Found kernel image: $f"
        exit 0
    fi
done

# If we reached here, no kernel image was found. Attempt to build one.
# Check for toolchain
if ! command -v make >/dev/null 2>&1 || ! command -v gcc >/dev/null 2>&1; then
    echo "Cannot build kernel: 'make' and 'gcc' are required but not available in PATH." >&2
    echo "Either install build tools on this machine or build the kernel on a build host and place the kernel image into $ISO_BOOT." >&2
    exit 1
fi

# Attempt to call build_kernel.sh (it will download sources if necessary)
BUILD_SCRIPT="$PROJECT_ROOT/build_kernel.sh"
if [ ! -x "$BUILD_SCRIPT" ]; then
    echo "Build helper not found: $BUILD_SCRIPT" >&2
    exit 1
fi

echo "No kernel found in $ISO_BOOT. Starting build (this may take a long time)..."
(cd "$PROJECT_ROOT" && TARGET_ARCH="$TARGET_ARCH" "$BUILD_SCRIPT")

# Re-check
for f in "${KERNEL_CANDIDATES[@]}"; do
    if [ -f "$f" ]; then
        echo "Kernel built and available: $f"
        exit 0
    fi
done

echo "Build completed but kernel image still missing. Check build logs and ensure kernel image was produced under $ISO_BOOT." >&2
exit 1
