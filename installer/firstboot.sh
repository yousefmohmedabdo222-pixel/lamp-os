#!/bin/bash
# LAMP OS First Boot Handler
# Auto-detects if system is freshly installed and runs post-install wizard

FIRSTBOOT_MARKER="/etc/lamp-firstboot-done"

# Check if this is first boot
if [ ! -f "$FIRSTBOOT_MARKER" ]; then
    clear
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║          LAMP OS - First Boot Initialization                   ║"
    echo "║           © 2026 Created by: yousef mohmed                     ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Welcome to LAMP OS!"
    echo ""
    echo "Setting up your system for first use..."
    sleep 2
    
    # Run post-install setup wizard
    if [ -f "/usr/local/bin/lamp-post-install-setup" ]; then
        /usr/local/bin/lamp-post-install-setup
    elif [ -f "/opt/lamp-os/post-install-setup.sh" ]; then
        bash /opt/lamp-os/post-install-setup.sh
    else
        echo "Post-install script not found"
        bash
    fi
    
    # Mark first boot as complete
    sudo touch "$FIRSTBOOT_MARKER"
else
    # System already initialized, show desktop menu
    if command -v lamp-desktop-menu &> /dev/null; then
        lamp-desktop-menu
    else
        bash
    fi
fi
