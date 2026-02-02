#!/bin/bash

# LAMP OS - Animated Login Screen
# شاشة تسجيل الدخول المتحركة

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

clear

# Hide cursor initially
tput civis

# Animated background
echo -e "${LIGHT_BLUE}"

# Draw frame
for i in {1..85}; do
    echo -ne "═"
    sleep 0.005
done
echo "${RESET}"

echo ""
echo ""

# Animate LAMP OS logo
echo -e "${LIGHT_CYAN}"
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

# Welcome message
echo -e "${LIGHT_BLUE}╔════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${LIGHT_BLUE}║${RESET}${YELLOW}      🕯️  Welcome to LAMP OS v2.0 🕯️${RESET}${LIGHT_BLUE}                      ║${RESET}"
echo -e "${LIGHT_BLUE}║${RESET}${CYAN}      Windows 7-Like Graphical Interface${RESET}${LIGHT_BLUE}                  ║${RESET}"
echo -e "${LIGHT_BLUE}╚════════════════════════════════════════════════════════════╝${RESET}"

echo ""

# Decorative separator with animation
echo -ne "${LIGHT_CYAN}"
for i in {1..60}; do
    echo -ne "─"
    sleep 0.01
done
echo -e "${RESET}"

echo ""

# System status messages
statuses=(
    "Initializing system..."
    "Loading configuration..."
    "Preparing graphical interface..."
    "Ready for login"
)

for status in "${statuses[@]}"; do
    echo -ne "${CYAN}  ⚙️  $status${RESET}"
    sleep 0.3
    for i in {1..3}; do
        echo -ne "."
        sleep 0.2
    done
    echo -e " ${GREEN}✓${RESET}"
done

echo ""

# Login information
echo -e "${LIGHT_BLUE}╔════════════════════════════════════════════════════════════╗${RESET}"

# Username prompt with animation
echo -ne "${LIGHT_BLUE}║${RESET} ${LIGHT_CYAN}Username:${RESET} "
for i in {1..20}; do
    echo -ne "█"
    sleep 0.05
done
echo -e "${LIGHT_BLUE}  │${RESET}"

echo -ne "${LIGHT_BLUE}║${RESET}"
echo -e "$(printf '%*s' 59 '')" "${LIGHT_BLUE}│${RESET}"

# Password prompt
echo -ne "${LIGHT_BLUE}║${RESET} ${LIGHT_CYAN}Password:${RESET}  "
for i in {1..20}; do
    echo -ne "●"
    sleep 0.05
done
echo -e "${LIGHT_BLUE}  │${RESET}"

echo -e "${LIGHT_BLUE}╠════════════════════════════════════════════════════════════╣${RESET}"

# Login options
echo -e "${LIGHT_BLUE}║${RESET}${CYAN}                                                         ${LIGHT_BLUE}║${RESET}"
echo -e "${LIGHT_BLUE}║${RESET}${YELLOW}  [ENTER]${RESET}${CYAN} - Login    ${YELLOW}[F1]${RESET}${CYAN} - Help    ${YELLOW}[F2]${RESET}${CYAN} - Settings  ${LIGHT_BLUE}║${RESET}"
echo -e "${LIGHT_BLUE}║${RESET}${CYAN}                                                         ${LIGHT_BLUE}║${RESET}"

echo -e "${LIGHT_BLUE}╚════════════════════════════════════════════════════════════╝${RESET}"

echo ""

# Bottom section
echo -e "${LIGHT_CYAN}─────────────────────────────────────────────────────────${RESET}"
echo ""
echo -e "${LIGHT_GREEN}System Status:${RESET}${GREEN} ✓ All systems operational${RESET}"
echo ""
echo -e "${LIGHT_CYAN}─────────────────────────────────────────────────────────${RESET}"

echo ""
echo -e "${CYAN}                 Designed by: yousef mohmed${RESET}"
echo -e "${CYAN}            © 2026 LAMP OS - All Rights Reserved${RESET}"

echo ""

# Show cursor again
tput cnorm

# Allow time to see the screen
sleep 3
