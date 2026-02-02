#!/bin/bash

# LAMP OS v2.0 - Animated Splash Screen
# شاشة البداية مع رسوم متحركة

clear

# Colors
BLUE='\033[0;34m'
LIGHT_BLUE='\033[1;34m'
CYAN='\033[0;36m'
LIGHT_CYAN='\033[1;36m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
RESET='\033[0m'
BOLD='\033[1m'

# Clear screen and hide cursor
tput civis  # Hide cursor

# Function to clear and draw
animate_loading() {
    local frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    local i=0
    while [ $i -lt 20 ]; do
        echo -ne "\r${LIGHT_BLUE}${frames[$((i % 10))]} Loading LAMP OS...${RESET}"
        sleep 0.1
        ((i++))
    done
    echo ""
}

# Clear screen
clear

# Animate the welcome screen
echo -ne "\n\n"

# Draw animated border (top)
for i in {1..70}; do
    echo -ne "${LIGHT_BLUE}═${RESET}"
    sleep 0.02
done
echo ""

echo -ne "${LIGHT_BLUE}║${RESET}"
for i in {1..68}; do
    echo -ne " "
done
echo -e "${LIGHT_BLUE}║${RESET}"

# Logo animation
echo -ne "${LIGHT_BLUE}║${RESET} "
sleep 0.2
echo -ne "${YELLOW}🕯️  LAMP OS v2.0 - Windows 7 GUI Edition 🕯️${RESET}"
sleep 0.2
echo -e " ${LIGHT_BLUE}║${RESET}"

echo -ne "${LIGHT_BLUE}║${RESET}"
for i in {1..68}; do
    echo -ne " "
done
echo -e "${LIGHT_BLUE}║${RESET}"

# System Designer Name
echo -ne "${LIGHT_BLUE}║${RESET} "
sleep 0.1
echo -ne "${CYAN}     Designed & Created by: yousef mohmed${RESET}"
sleep 0.1
echo -e " ${LIGHT_BLUE}║${RESET}"

echo -ne "${LIGHT_BLUE}║${RESET}"
for i in {1..68}; do
    echo -ne " "
done
echo -e "${LIGHT_BLUE}║${RESET}"

# Draw animated border (bottom)
for i in {1..70}; do
    echo -ne "${LIGHT_BLUE}═${RESET}"
    sleep 0.02
done
echo ""

echo ""

# Animated ASCII Art
echo -e "${LIGHT_BLUE}"
cat << 'LOGO'
    ██╗     ██╗    ███╗   ███╗██████╗ 
    ██║     ██║    ████╗ ████║██╔══██╗
    ██║     ██║    ██╔████╔██║██████╔╝
    ██║     ██║    ██║╚██╔╝██║██╔═══╝ 
    ███████╗███████╗██║ ╚═╝ ██║██║     
    ╚══════╝╚══════╝╚═╝     ╚═╝╚═╝     
LOGO
echo -e "${RESET}"

echo ""
echo -e "${LIGHT_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""

# Animate loading text
echo -ne "${LIGHT_BLUE}  ⚡ Initializing System Components${RESET}"
sleep 1
for i in {1..3}; do
    echo -ne "."
    sleep 0.3
done
echo -e " ${YELLOW}✓${RESET}\n"

echo -ne "${LIGHT_BLUE}  🔧 Loading Device Drivers${RESET}"
sleep 1
for i in {1..3}; do
    echo -ne "."
    sleep 0.3
done
echo -e " ${YELLOW}✓${RESET}\n"

echo -ne "${LIGHT_BLUE}  💾 Mounting Filesystems${RESET}"
sleep 1
for i in {1..3}; do
    echo -ne "."
    sleep 0.3
done
echo -e " ${YELLOW}✓${RESET}\n"

echo -ne "${LIGHT_BLUE}  🎨 Loading GUI Components${RESET}"
sleep 1
for i in {1..3}; do
    echo -ne "."
    sleep 0.3
done
echo -e " ${YELLOW}✓${RESET}\n"

echo ""
echo -e "${LIGHT_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""

# Welcome message with animation
echo -e "${LIGHT_BLUE}✨ Welcome to LAMP OS v2.0${RESET}"
echo ""
echo -e "${CYAN}A lightweight, beautiful operating system${RESET}"
echo -e "${CYAN}with Windows 7-like interface${RESET}"
echo ""

# Show loading animation
echo -ne "${YELLOW}  System ready in: ${RESET}"
for i in {3..1}; do
    echo -ne "${LIGHT_BLUE}${i}${RESET} "
    sleep 1
done
echo ""

echo ""
echo -e "${LIGHT_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""

# Show cursor again
tput cnorm

# Small delay before exiting
sleep 1
