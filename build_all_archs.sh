#!/bin/bash

# Attempt to build kernel, initrd and ISO for a set of architectures (best-effort)
# This script won't force-install toolchains; it will detect available cross-compilers

set -e

ARCHS=(x86_64 aarch64 arm riscv64 powerpc mips loongarch)

for A in "${ARCHS[@]}"; do
    echo "\n========================"
    echo "Building for: $A"
    echo "========================\n"

    export TARGET_ARCH=$A

    # Detect cross-compiler prefix heuristically
    CC_PREFIX=""
    case "$A" in
        x86_64) CC_PREFIX="" ;; # native
        aarch64) CC_PREFIX="aarch64-linux-gnu-";;
        arm) CC_PREFIX="arm-linux-gnueabi-";;
        riscv64) CC_PREFIX="riscv64-unknown-elf-";;
        powerpc) CC_PREFIX="powerpc64le-linux-gnu-";;
        mips) CC_PREFIX="mips-linux-gnu-";;
        loongarch) CC_PREFIX="loongarch64-linux-gnu-";;
        *) CC_PREFIX="";;
    esac

    if [ -n "$CC_PREFIX" ]; then
        if command -v ${CC_PREFIX}gcc >/dev/null 2>&1; then
            export CROSS_COMPILE=$CC_PREFIX
            echo "Found cross-compiler prefix: $CROSS_COMPILE"
        else
            echo "Cross-compiler ${CC_PREFIX}gcc not found in PATH; trying to build natively (may fail)"
            unset CROSS_COMPILE
        fi
    fi

    # Build kernel (best-effort)
    if ./build_kernel.sh; then
        echo "Kernel build OK for $A"
    else
        echo "Kernel build failed for $A (continuing)"
    fi

    # Build initrd (ensure busybox exists for target)
    if TARGET_ARCH=$A CROSS_COMPILE=${CROSS_COMPILE:-} ./build_initrd.sh; then
        echo "Initrd build OK for $A"
    else
        echo "Initrd build failed for $A (continuing)"
    fi

    # Create iso
    if TARGET_ARCH=$A ./create_iso.sh; then
        echo "ISO created for $A"
    else
        echo "ISO creation failed for $A"
    fi

done

echo "\nAll attempts finished. Check logs above for errors."