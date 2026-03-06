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

# If we reached here, no kernel image was found. We WILL NOT download the kernel automatically.
# Prefer included kernel images; if missing, attempt a local build only if kernel sources are present.
BUILD_SCRIPT="$PROJECT_ROOT/build_kernel.sh"
if [ -d "$PROJECT_ROOT/kernel/linux-6.6" ]; then
    if ! command -v make >/dev/null 2>&1 || ! command -v gcc >/dev/null 2>&1; then
        echo "Kernel sources exist but build tools are absent (make/gcc). Please build the kernel on a development machine and copy the resulting vmlinuz into $ISO_BOOT." >&2
        exit 1
    fi
    if [ ! -x "$BUILD_SCRIPT" ]; then
        echo "Build helper not found: $BUILD_SCRIPT" >&2
        exit 1
    fi
    echo "Building kernel from local sources (no network will be used)..."
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
else
    echo "No kernel image and no local kernel sources present. To install offline, place a kernel image (vmlinuz) into $ISO_BOOT or provide kernel sources at kernel/linux-6.6 and re-run the installer." >&2
    exit 1
fi
