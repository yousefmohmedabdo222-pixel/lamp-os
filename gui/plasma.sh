#!/bin/bash
# helper script to launch KDE Plasma if available

if command -v startplasma-x11 >/dev/null 2>&1; then
    echo "Starting KDE Plasma desktop..."
    exec startplasma-x11
else
    echo "KDE Plasma not installed. Please install plasma packages first."
    exit 1
fi
