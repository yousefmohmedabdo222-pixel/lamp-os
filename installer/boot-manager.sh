#!/bin/bash
# LAMP OS Boot Manager
# Detects if running from Live ISO or installed system
# Routes to appropriate interface

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

clear_screen() {
    clear
}

detect_boot_mode() {
    # Check if running from live ISO or installed system
    if [ -f "/proc/cmdline" ]; then
        if grep -q "boot=live\|toram\|rd.live" /proc/cmdline 2>/dev/null; then
            echo "live"
            return 0
        fi
    fi
    
    # Check if root filesystem is read-only (typical of ISO)
    if [ -r /proc/mounts ]; then
        if grep -q "/ .* ro" /proc/mounts 2>/dev/null; then
            echo "live"
            return 0
        fi
    fi
    
    echo "installed"
    return 0
}

show_live_menu() {
    clear_screen
    echo -ne "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}\n"
    echo -ne "${BLUE}║${WHITE}        LAMP OS v2.0 - Live Installation Medium              ${BLUE}║${NC}\n"
    echo -ne "${BLUE}║${WHITE}           © 2026 Created by: yousef mohmed                  ${BLUE}║${NC}\n"
    echo -ne "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}\n"
    echo ""
    echo -ne "${CYAN}Live System Menu:${NC}\n"
    echo -ne "${GREEN}[1]${NC} Install LAMP OS to Disk\n"
    echo -ne "${GREEN}[2]${NC} System Utilities\n"
    echo -ne "${GREEN}[3]${NC} Shell Prompt\n"
    echo -ne "${GREEN}[4]${NC} Reboot\n"
    echo -ne "${GREEN}[5]${NC} Shutdown\n"
    echo ""
    read -p "Select option [1-5]: " choice
    
    case "$choice" in
        1)
            if [ -f "/usr/local/bin/lamp-setup-wizard" ]; then
                sudo /usr/local/bin/lamp-setup-wizard
            else
                echo -ne "${RED}✗ Installer not found${NC}\n"
                sleep 2
                show_live_menu
            fi
            ;;
        2)
            show_utilities_menu
            ;;
        3)
            exec bash
            ;;
        4)
            sudo reboot
            ;;
        5)
            sudo shutdown -h now
            ;;
        *)
            show_live_menu
            ;;
    esac
}

show_utilities_menu() {
    clear_screen
    echo -ne "${BLUE}System Utilities:${NC}\n"
    echo ""
    echo -ne "${GREEN}[1]${NC} Disk Management (parted)\n"
    echo -ne "${GREEN}[2]${NC} Network Configuration\n"
    echo -ne "${GREEN}[3]${NC} File Manager\n"
    echo -ne "${GREEN}[4]${NC} System Information\n"
    echo -ne "${GREEN}[5]${NC} Back\n"
    echo ""
    read -p "Select option [1-5]: " choice
    
    case "$choice" in
        1)
            echo -ne "${CYAN}Available disks:${NC}\n"
            lsblk -d -o NAME,SIZE,TYPE
            read -p "Enter disk name to manage (e.g. sda): " disk
            if [ -n "$disk" ]; then
                sudo parted "/dev/$disk"
            fi
            show_utilities_menu
            ;;
        2)
            echo -ne "${CYAN}Network interfaces:${NC}\n"
            ip link show
            echo ""
            read -p "Enter interface name: " iface
            if [ -n "$iface" ]; then
                sudo ip link set "$iface" up
                sudo dhclient "$iface" || true
                ip addr show "$iface"
            fi
            show_utilities_menu
            ;;
        3)
            clear_screen
            echo -ne "${CYAN}Current directory: $(pwd)${NC}\n"
            ls -la
            show_utilities_menu
            ;;
        4)
            clear_screen
            echo -ne "${CYAN}System Information:${NC}\n"
            echo "Hostname: $(hostname)"
            echo "Kernel: $(uname -r)"
            echo "Uptime: $(uptime)"
            echo "Memory: $(free -h)"
            echo "CPU: $(nproc) cores"
            echo "Disks:"
            lsblk
            echo ""
            read -p "Press Enter to continue..."
            show_utilities_menu
            ;;
        5)
            show_live_menu
            ;;
        *)
            show_utilities_menu
            ;;
    esac
}

show_installed_menu() {
    clear_screen
    echo -ne "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}\n"
    echo -ne "${BLUE}║${WHITE}              LAMP OS v2.0 - System Booted                    ${BLUE}║${NC}\n"
    echo -ne "${BLUE}║${WHITE}           © 2026 Created by: yousef mohmed                  ${BLUE}║${NC}\n"
    echo -ne "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}\n"
    echo ""
    echo -ne "${GREEN}✓ System Ready${NC}\n"
    echo ""
    echo -ne "${CYAN}Options:${NC}\n"
    echo -ne "${GREEN}[1]${NC} Start Desktop Environment\n"
    echo -ne "${GREEN}[2]${NC} System Utilities\n"
    echo -ne "${GREEN}[3]${NC} Shell Prompt\n"
    echo ""
    read -p "Select option [1-3]: " choice
    
    case "$choice" in
        1)
            if command -v lamp-desktop-menu &>/dev/null; then
                lamp-desktop-menu
            else
                exec bash
            fi
            ;;
        2)
            show_utilities_menu
            ;;
        3)
            exec bash
            ;;
        *)
            show_installed_menu
            ;;
    esac
}

# Main execution
BOOT_MODE=$(detect_boot_mode)

case "$BOOT_MODE" in
    live)
        show_live_menu
        ;;
    installed)
        show_installed_menu
        ;;
    *)
        bash
        ;;
esac
