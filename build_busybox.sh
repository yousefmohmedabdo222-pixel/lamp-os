#!/bin/bash

# Multi-architecture BusyBox builder
# Usage: TARGET_ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- DESTDIR=initrd ./build_busybox.sh

set -e

TARGET_ARCH=${TARGET_ARCH:-x86_64}
CROSS_COMPILE=${CROSS_COMPILE:-}
BUSYBOX_VERSION=${BUSYBOX_VERSION:-1_36_1}
BUSYBOX_SRC_URL=${BUSYBOX_SRC_URL:-"https://busybox.net/downloads/busybox-${BUSYBOX_VERSION}.tar.bz2"}
DESTDIR=${DESTDIR:-initrd}
JOBS=${JOBS:-$(nproc)}

echo "Building BusyBox for ARCH=$TARGET_ARCH CROSS_COMPILE=${CROSS_COMPILE:-<native>}"

TMPDIR="/tmp/lamp-busybox-build-$$"
mkdir -p "$TMPDIR"
pushd "$TMPDIR" >/dev/null

if [ ! -f "busybox-${BUSYBOX_VERSION}.tar.bz2" ]; then
    echo "Downloading BusyBox ${BUSYBOX_VERSION}..."
    curl -fsSLO "$BUSYBOX_SRC_URL"
fi

if [ ! -d "busybox-${BUSYBOX_VERSION}" ]; then
    tar xf "busybox-${BUSYBOX_VERSION}.tar.bz2"
fi

pushd "busybox-${BUSYBOX_VERSION}" >/dev/null

# Create a minimal config
if [ -f ".config" ]; then
    echo "Using existing BusyBox config"
else
    make defconfig
    # Enable static build by default for portability
    sed -i 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/' .config || true
fi

if [ -n "$CROSS_COMPILE" ]; then
    export CROSS_COMPILE=$CROSS_COMPILE
fi

make -j${JOBS}
make CONFIG_PREFIX="$(pwd)/_install" install

# Copy installed files to DESTDIR
mkdir -p "${DESTDIR}/bin" "${DESTDIR}/sbin"
cp -a _install/bin/* "${DESTDIR}/bin/" 2>/dev/null || true
cp -a _install/sbin/* "${DESTDIR}/sbin/" 2>/dev/null || true

# Ensure busybox exists
if [ ! -f "${DESTDIR}/bin/busybox" ]; then
    echo "BusyBox build failed or binary not found"
    popd >/dev/null
    popd >/dev/null
    rm -rf "$TMPDIR"
    exit 1
fi

# Install simple symlinks
pushd "${DESTDIR}/bin" >/dev/null
./busybox --install -s . || true
popd >/dev/null

popd >/dev/null
popd >/dev/null

rm -rf "$TMPDIR"

echo "BusyBox installed into ${DESTDIR}"
