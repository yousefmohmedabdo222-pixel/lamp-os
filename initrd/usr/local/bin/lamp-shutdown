#!/bin/bash

# LAMP OS - Shutdown & Exit Screen with Animations
# شاشة الخروج من النظام مع رسوم متحركة

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

# Hide cursor
tput civis

# Animated farewell screen
echo ""
echo ""

# Draw farewell message
echo -e "${LIGHT_BLUE}╔════════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${LIGHT_BLUE}║${RESET}${YELLOW}                                                                ${LIGHT_BLUE}║${RESET}"
echo -e "${LIGHT_BLUE}║${RESET}${GREEN}            Thank you for using LAMP OS v2.0${RESET}${LIGHT_BLUE}                ║${RESET}"
echo -e "${LIGHT_BLUE}║${RESET}${CYAN}            Windows 7-Like Graphical Interface${RESET}${LIGHT_BLUE}              ║${RESET}"
echo -e "${LIGHT_BLUE}║${RESET}${YELLOW}                                                                ${LIGHT_BLUE}║${RESET}"
echo -e "${LIGHT_BLUE}╚════════════════════════════════════════════════════════════════╝${RESET}"

echo ""
echo ""

# Shutdown process
echo -e "${LIGHT_CYAN}System Shutdown Process:${RESET}"
echo ""

shutdown_steps=(
    "Closing applications..."
    "Saving data..."
    "Unmounting filesystems..."
    "Stopping services..."
    "Syncing disk..."
    "Goodbye!"
)

for step in "${shutdown_steps[@]}"; do
    echo -ne "${CYAN}  ► $step${RESET}"
    sleep 0.5
    
    # Animate progress dots
    for i in {1..5}; do
        echo -ne "."
        sleep 0.2
    done
    echo -e " ${GREEN}✓${RESET}"
done

echo ""
echo ""

# Show LAMP logo animation
echo -e "${LIGHT_BLUE}╔════════════════════════════════════════════════════════════════╗${RESET}"

echo -e "${LIGHT_BLUE}║${RESET}${LIGHT_CYAN}"
cat << 'LOGO' | sed 's/^/║  /; s/$/                              ║/'
     ██╗     ██╗    ███╗   ███╗██████╗ 
     ██║     ██║    ████╗ ████║██╔══██╗
     ██║     ██║    ██╔████╔██║██████╔╝
     ██║     ██║    ██║╚██╔╝██║██╔═══╝ 
     ███████╗███████╗██║ ╚═╝ ██║██║     
     ╚══════╝╚══════╝╚═╝     ╚═╝╚═╝     
LOGO
echo -e "${RESET}${LIGHT_BLUE}╚════════════════════════════════════════════════════════════════╝${RESET}"

echo ""
echo ""

# Final message
echo -e "${LIGHT_CYAN}System Information:${RESET}"
echo -e "${CYAN}  • Uptime: 0:02:45${RESET}"
echo -e "${CYAN}  • Tasks completed: 15${RESET}"
echo -e "${CYAN}  • System status: Shutting down${RESET}"

echo ""
echo ""

# Animated countdown
echo -e "${YELLOW}System powering off in:${RESET}"
echo ""

for i in {5..1}; do
    echo -ne "\r${LIGHT_YELLOW}  ${i}${RESET}"
    sleep 1
done

echo ""
echo ""

# Final goodbye
echo -e "${LIGHT_GREEN}═══════════════════════════════════════════════════════════════${RESET}"
echo ""
echo -e "${LIGHT_CYAN}                    GOODBYE! 👋${RESET}"
echo ""
echo -e "${GREEN}           Created with ❤️  by yousef mohmed${RESET}"
echo -e "${CYAN}        © 2026 LAMP OS - Lightweight & Beautiful${RESET}"
echo ""
echo -e "${LIGHT_GREEN}═══════════════════════════════════════════════════════════════${RESET}"

echo ""
echo ""

# Show cursor again
tput cnorm

# Brief pause
sleep 2
