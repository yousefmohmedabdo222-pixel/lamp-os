#!/bin/bash

# LAMP OS - Partition Selection Screen
# شاشة اختيار البارتيشن مع التصميم الجميل

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

# Draw top border with animation
echo -ne "${LIGHT_BLUE}"
for i in {1..80}; do
    echo -ne "═"
    sleep 0.01
done
echo "${RESET}"

# Title
echo -e "${LIGHT_BLUE}║${RESET} ${YELLOW}🕯️  LAMP OS v2.0 - Partition Selection Screen${RESET} $(echo -e "${LIGHT_BLUE}║${RESET}")"

# Draw separator
echo -ne "${LIGHT_BLUE}"
for i in {1..80}; do
    echo -ne "─"
    sleep 0.01
done
echo "${RESET}"

echo ""

# Information section
echo -e "${LIGHT_CYAN}📌 Available Partitions:${RESET}\n"

# Animated partition list
partitions=(
    "sda1 - Primary (50 GB) - Linux"
    "sda2 - Secondary (30 GB) - Linux"
    "sda3 - Backup (20 GB) - Reserved"
)

for i in "${!partitions[@]}"; do
    echo -ne "${CYAN}   "
    ((num = i + 1))
    echo -ne "[$num] ${partitions[$i]}"
    echo -e "${RESET}"
    sleep 0.3
done

echo ""
echo -e "${LIGHT_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""

# Installation type selection
echo -e "${LIGHT_BLUE}⚙️  Installation Type:${RESET}\n"

installation_types=(
    "Fresh Installation"
    "Upgrade Existing System"
    "Dual Boot Setup"
    "Custom Installation"
)

for i in "${!installation_types[@]}"; do
    echo -ne "${CYAN}   "
    ((num = i + 1))
    echo -ne "[$num] ${installation_types[$i]}"
    echo -e "${RESET}"
    sleep 0.2
done

echo ""
echo -e "${LIGHT_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""

# System configuration section
echo -e "${LIGHT_BLUE}🔧 System Configuration:${RESET}\n"

echo -e "${CYAN}  Bootloader: GRUB2${RESET}"
echo -e "${CYAN}  File System: ext4${RESET}"
echo -e "${CYAN}  Boot Mode: UEFI / BIOS${RESET}"
echo -e "${CYAN}  Swap Space: 2 GB${RESET}"

echo ""
echo -e "${LIGHT_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""

# Progress bar animation
echo -e "${LIGHT_BLUE}📊 Installation Progress:${RESET}\n"

progress_bar() {
    local width=50
    local percentage=$1
    local filled=$((percentage * width / 100))
    
    echo -ne "${LIGHT_CYAN}  ["
    for ((i=0; i<filled; i++)); do
        echo -ne "█"
    done
    for ((i=filled; i<width; i++)); do
        echo -ne "░"
    done
    printf "] %3d%%\r" "$percentage"
}

# Animate progress
for i in {0..100..10}; do
    progress_bar $i
    sleep 0.2
done

echo ""
echo ""

# Bottom section with name
echo -e "${LIGHT_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""

# Draw bottom border
echo -ne "${LIGHT_BLUE}"
for i in {1..80}; do
    echo -ne "═"
    sleep 0.005
done
echo "${RESET}"

# Footer with name - positioned to the right from bottom
echo -e "${LIGHT_BLUE}║${RESET}" | head -c 1
echo -ne "$(printf '%*s' $((78 - ${#USER} - 20)) '')"  # Space calculation
echo -e "${GREEN}© 2026 Created by: yousef mohmed${RESET}  ${LIGHT_BLUE}║${RESET}"

# Draw final border
echo -ne "${LIGHT_BLUE}"
for i in {1..80}; do
    echo -ne "═"
    sleep 0.005
done
echo "${RESET}"

echo ""

# Show cursor again
tput cnorm

sleep 2
