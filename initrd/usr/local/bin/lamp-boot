#!/bin/bash

# LAMP OS - Animated Boot Screen
# شاشة الإقلاع المتحركة الجميلة

# Colors
BLUE='\033[0;34m'
LIGHT_BLUE='\033[1;34m'
CYAN='\033[0;36m'
LIGHT_CYAN='\033[1;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
LIGHT_GREEN='\033[1;32m'
WHITE='\033[1;37m'
RED='\033[0;31m'
RESET='\033[0m'

# Clear screen
clear

# Hide cursor
tput civis

# Animate screen appearance
sleep 0.5

# Draw decorative top border
echo -ne "${LIGHT_BLUE}"
echo "╔════════════════════════════════════════════════════════════════════════════╗"

echo "║                                                                            ║"
echo "║${RESET}${YELLOW}          🕯️  LAMP OS v2.0 - Bootloader & System Startup 🕯️${RESET}${LIGHT_BLUE}             ║"
echo "║${RESET}${GREEN}                    Lightweight & Beautiful OS${RESET}${LIGHT_BLUE}                       ║"
echo "║${RESET}${CYAN}                  Designed by: yousef mohmed${RESET}${LIGHT_BLUE}                      ║"
echo "║                                                                            ║"
echo "╠════════════════════════════════════════════════════════════════════════════╣"
echo "║${RESET}"

# Boot messages with animation
boot_messages=(
    "Initializing BIOS/UEFI..."
    "Loading bootloader (GRUB2)..."
    "Detecting hardware..."
    "Loading Linux kernel..."
    "Mounting root filesystem..."
    "Starting system services..."
    "Loading graphical interface..."
    "Initializing device drivers..."
    "Mounting additional filesystems..."
    "Starting network services..."
)

for msg in "${boot_messages[@]}"; do
    echo -ne "║${RESET}${LIGHT_CYAN}  ⚙️  $msg${RESET}"
    
    # Calculate padding
    msg_length=${#msg}
    padding=$((77 - msg_length - 5))
    printf "%${padding}s"
    
    echo -e "${LIGHT_BLUE}║${RESET}"
    
    # Animate progress
    sleep 0.8
done

echo -e "║${RESET}"

# Progress bar
echo -n "║${RESET}${LIGHT_CYAN}  Progress: ${RESET}${LIGHT_BLUE}["
for i in {1..40}; do
    echo -n "█"
    sleep 0.05
done
echo -n "]${RESET}${LIGHT_BLUE} 100%"
echo "                           ║${RESET}"

echo "║${RESET}"

# System status
echo -e "║${RESET}${GREEN}  ✓ Kernel loaded successfully${RESET}${LIGHT_BLUE}                                         ║${RESET}"
echo -e "║${RESET}${GREEN}  ✓ All drivers loaded${RESET}${LIGHT_BLUE}                                                ║${RESET}"
echo -e "║${RESET}${GREEN}  ✓ Filesystems mounted${RESET}${LIGHT_BLUE}                                              ║${RESET}"
echo -e "║${RESET}${GREEN}  ✓ System ready${RESET}${LIGHT_BLUE}                                                      ║${RESET}"

echo "║${RESET}"

# System info section
echo "║${RESET}${LIGHT_CYAN}  System Information:${RESET}${LIGHT_BLUE}                                           ║${RESET}"
echo "║${RESET}${CYAN}    ├─ OS: LAMP OS v2.0 (Linux 6.6.0-lamp)${RESET}${LIGHT_BLUE}                         ║${RESET}"
echo "║${RESET}${CYAN}    ├─ Boot Time: 2.87 seconds${RESET}${LIGHT_BLUE}                                    ║${RESET}"
echo "║${RESET}${CYAN}    ├─ Available RAM: 512 MB${RESET}${LIGHT_BLUE}                                       ║${RESET}"
echo "║${RESET}${CYAN}    └─ System Status: READY${RESET}${LIGHT_BLUE}                                        ║${RESET}"

echo "║${RESET}"

# Bottom border
echo "╠════════════════════════════════════════════════════════════════════════════╣"

# Footer with designer name
echo "║${RESET}${GREEN}                  © 2026 yousef mohmed${RESET}${LIGHT_BLUE}                                            ║${RESET}"
echo "║${RESET}${CYAN}            LAMP OS - A Lightweight Beautiful Operating System${RESET}${LIGHT_BLUE}         ║${RESET}"

echo "╚════════════════════════════════════════════════════════════════════════════╝"
echo "${RESET}"

# Show cursor again
tput cnorm

# Brief pause before continuing
sleep 2
