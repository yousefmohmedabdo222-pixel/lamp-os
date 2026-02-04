#!/bin/bash

# Multi-architecture kernel build helper
# Usage: TARGET_ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- ./build_kernel.sh

set -e

TARGET_ARCH=${TARGET_ARCH:-x86_64}
CROSS_COMPILE=${CROSS_COMPILE:-}
KERNEL_DIR="kernel/linux-6.6"
JOBS=${JOBS:-$(nproc)}

echo "Building kernel for ARCH=$TARGET_ARCH CROSS_COMPILE=${CROSS_COMPILE:-<native>}"

if [ ! -d "$KERNEL_DIR" ]; then
    echo "Kernel source not found at $KERNEL_DIR. Attempting to download linux-6.6..."
    KERNEL_TAR="${KERNEL_TAR:-$HOME/.cache/lamp-os/linux-6.6.tar.xz}"
    mkdir -p "$(dirname "$KERNEL_TAR")"
    if [ -f "$KERNEL_TAR" ]; then
        echo "Using cached tarball $KERNEL_TAR"
    else
        echo "Downloading linux-6.6.tar.xz to $KERNEL_TAR..."
        curl -L --fail -o "$KERNEL_TAR" https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.6.tar.xz
    fi
    echo "Extracting $KERNEL_TAR to kernel/..."
    mkdir -p kernel
    tar -C kernel -xf "$KERNEL_TAR"
    if [ ! -d "$KERNEL_DIR" ]; then
        echo "Failed to extract kernel source to $KERNEL_DIR"
        exit 1
    fi
fi

pushd "$KERNEL_DIR" >/dev/null

# Map some common ARCH names to kernel ARCH variables
case "$TARGET_ARCH" in
    x86_64|x86)
        KERN_ARCH=x86
        ;;
    aarch64|arm64)
        KERN_ARCH=arm64
        ;;
    arm)
        KERN_ARCH=arm
        ;;
    mips)
        KERN_ARCH=mips
        ;;
    ppc|powerpc)
        KERN_ARCH=powerpc
        ;;
    riscv|riscv64)
        KERN_ARCH=riscv
        ;;
    loongarch)
        KERN_ARCH=loongarch
        ;;
    s390)
        KERN_ARCH=s390
        ;;
    *)
        echo "Unknown TARGET_ARCH: $TARGET_ARCH. Using as-is."
        KERN_ARCH=$TARGET_ARCH
        ;;
esac

export ARCH=$KERN_ARCH
if [ -n "$CROSS_COMPILE" ]; then
    export CROSS_COMPILE=$CROSS_COMPILE
fi

# Try to use a reasonable defconfig
echo "Using ARCH=$ARCH"
if [ -f "arch/$ARCH/configs/${ARCH}_defconfig" ]; then
    echo "Found ${ARCH}_defconfig, using it"
    make ${ARCH}_defconfig
else
    echo "Falling back to defconfig"
    make defconfig
fi

# Build
make -j${JOBS} bzImage vmlinuz || true

# Detect output kernel image
KERNEL_IMAGE=""
if [ -f "arch/$ARCH/boot/bzImage" ]; then
    KERNEL_IMAGE="arch/$ARCH/boot/bzImage"
elif [ -f "arch/$ARCH/boot/vmlinuz" ]; then
    KERNEL_IMAGE="arch/$ARCH/boot/vmlinuz"
elif [ -f "arch/$ARCH/boot/Image" ]; then
    KERNEL_IMAGE="arch/$ARCH/boot/Image"
elif [ -f "vmlinux" ]; then
    KERNEL_IMAGE="vmlinux"
fi

if [ -n "$KERNEL_IMAGE" ]; then
    echo "Kernel built: $KERNEL_IMAGE"
    # Copy to project iso/boot with a generic name
    mkdir -p ../../iso/boot
    cp -v "$KERNEL_IMAGE" ../../iso/boot/vmlinuz-${TARGET_ARCH} || true
    # Also make a symlink as vmlinuz
    ln -sf vmlinuz-${TARGET_ARCH} ../../iso/boot/vmlinuz || true
    popd >/dev/null
    exit 0
else
    echo "Kernel build completed but no kernel image found. Check build logs."
    popd >/dev/null
    exit 1
fi
