#!/bin/bash
# LAMP OS Post-Installation Setup Wizard
# User profile creation, password setup, display configuration

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
    echo -ne "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}\n"
    echo -ne "${BLUE}║${WHITE}    LAMP OS - First Boot User Setup Wizard                   ${BLUE}║${NC}\n"
    echo -ne "${BLUE}║${WHITE}       © 2026 Created by: yousef mohmed                        ${BLUE}║${NC}\n"
    echo -ne "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}\n"
    echo ""
}

draw_box() {
    local title="$1"
    echo -ne "${CYAN}┌──────────────────────────────────────────────────────────────┐${NC}\n"
    printf "${CYAN}│${WHITE} %-59s ${CYAN}│${NC}\n" "$title"
    echo -ne "${CYAN}└──────────────────────────────────────────────────────────────┘${NC}\n"
}

get_display_resolution() {
    # Try to detect screen resolution
    if command -v xrandr &> /dev/null; then
        xrandr | grep "connected" | grep -oP '\d+x\d+' | head -1
    elif [ -f "/sys/class/graphics/fb0/virtual_size" ]; then
        cat /sys/class/graphics/fb0/virtual_size | tr ',' 'x'
    else
        echo "1920x1080"  # Default fallback
    fi
}

set_display_resolution() {
    clear_screen
    draw_box "Step 1: Display Configuration"
    echo ""
    
    local detected=$(get_display_resolution)
    echo -ne "${YELLOW}Detected resolution:${NC} $detected\n"
    echo ""
    
    echo -ne "${CYAN}Common resolutions:${NC}\n"
    echo -ne "${GREEN}[1]${NC} 1920x1080 (Full HD)\n"
    echo -ne "${GREEN}[2]${NC} 1366x768  (HD)\n"
    echo -ne "${GREEN}[3]${NC} 1600x900\n"
    echo -ne "${GREEN}[4]${NC} 2560x1440 (2K)\n"
    echo -ne "${GREEN}[5]${NC} 3840x2160 (4K)\n"
    echo -ne "${GREEN}[6]${NC} Keep detected\n"
    echo ""
    read -p "Select resolution [1-6]: " res_choice
    
    case "$res_choice" in
        1) RESOLUTION="1920x1080" ;;
        2) RESOLUTION="1366x768" ;;
        3) RESOLUTION="1600x900" ;;
        4) RESOLUTION="2560x1440" ;;
        5) RESOLUTION="3840x2160" ;;
        6) RESOLUTION="$detected" ;;
        *) RESOLUTION="1920x1080" ;;
    esac
    
    echo -ne "${GREEN}✓ Resolution set to: $RESOLUTION${NC}\n"
    sleep 2
}

create_user_profile() {
    clear_screen
    draw_box "Step 2: Create User Profile"
    echo ""
    
    echo -ne "${CYAN}Profile Information:${NC}\n"
    echo ""
    
    # Get username
    while true; do
        read -p "Enter username: " username
        if [ -z "$username" ]; then
            echo -ne "${RED}✗ Username cannot be empty${NC}\n"
            continue
        fi
        if id "$username" &>/dev/null 2>&1; then
            echo -ne "${RED}✗ User already exists${NC}\n"
            continue
        fi
        break
    done
    
    echo -ne "${GREEN}✓ Username: $username${NC}\n"
    echo ""
    
    # Set password
    echo -ne "${CYAN}Password Configuration:${NC}\n"
    echo -ne "${YELLOW}Leave empty to skip password setup${NC}\n"
    echo ""
    
    while true; do
        read -s -p "Enter password (or press Enter to skip): " password
        echo ""
        
        if [ -z "$password" ]; then
            echo -ne "${YELLOW}⚠ No password set (login without password)${NC}\n"
            password_hash=""
            break
        fi
        
        if [ ${#password} -lt 4 ]; then
            echo -ne "${RED}✗ Password too short (minimum 4 characters)${NC}\n"
            continue
        fi
        
        read -s -p "Confirm password: " password_confirm
        echo ""
        
        if [ "$password" != "$password_confirm" ]; then
            echo -ne "${RED}✗ Passwords don't match${NC}\n"
            continue
        fi
        
        echo -ne "${GREEN}✓ Password confirmed${NC}\n"
        break
    done
    
    sleep 1
}

select_profile_picture() {
    clear_screen
    draw_box "Step 3: Select Profile Picture"
    echo ""
    
    local pictures_dir="$HOME/.config/lamp-os/pictures"
    
    echo -ne "${CYAN}Available profile pictures:${NC}\n"
    echo ""
    
    # Check if pictures exist, create sample if not
    mkdir -p "$pictures_dir"
    
    if [ ! -f "$pictures_dir/default-avatar.txt" ]; then
        cat > "$pictures_dir/default-avatar.txt" << 'EOF'
┏━━━━━━━━━━━━━━┓
┃   LAMP OS    ┃
┃   User       ┃
┃   Profile    ┃
┗━━━━━━━━━━━━━━┛
EOF
    fi
    
    # List available pictures
    local pic_num=1
    local -a pictures
    
    for pic in "$pictures_dir"/*.txt "$pictures_dir"/*.jpg "$pictures_dir"/*.png; do
        if [ -f "$pic" ]; then
            pictures+=("$pic")
            echo -ne "${GREEN}[$pic_num]${NC} $(basename "$pic")\n"
            ((pic_num++))
        fi
    done
    
    if [ ${#pictures[@]} -eq 0 ]; then
        echo -ne "${YELLOW}No pictures found, using default${NC}\n"
        profile_picture="$pictures_dir/default-avatar.txt"
    else
        echo ""
        read -p "Select picture [1-${#pictures[@]}] (or press Enter for default): " pic_choice
        
        if [ -z "$pic_choice" ]; then
            profile_picture="$pictures_dir/default-avatar.txt"
        elif [[ "$pic_choice" =~ ^[0-9]+$ ]] && [ "$pic_choice" -ge 1 ] && [ "$pic_choice" -le ${#pictures[@]} ]; then
            profile_picture="${pictures[$((pic_choice-1))]}"
        else
            profile_picture="$pictures_dir/default-avatar.txt"
        fi
    fi
    
    echo -ne "${GREEN}✓ Picture selected: $(basename "$profile_picture")${NC}\n"
    sleep 2
}

save_user_config() {
    clear_screen
    draw_box "Saving Configuration..."
    echo ""
    
    local config_dir="/home/$username/.config/lamp-os"
    
    echo "Step 1/4: Creating user account..."
    if [ -z "$password_hash" ]; then
        # Create user without password (login as $username directly)
        sudo useradd -m -s /bin/bash "$username" 2>/dev/null || true
        echo -ne "${GREEN}✓ User created (no password)${NC}\n"
    else
        # Create user with password
        sudo useradd -m -s /bin/bash "$username" 2>/dev/null || true
        echo "$username:$password" | sudo chpasswd
        echo -ne "${GREEN}✓ User created with password${NC}\n"
    fi
    
    sleep 1
    
    echo "Step 2/4: Creating configuration directory..."
    sudo mkdir -p "$config_dir"
    sudo chown "$username:$username" "$config_dir"
    echo -ne "${GREEN}✓ Config directory created${NC}\n"
    
    sleep 1
    
    echo "Step 3/4: Saving user profile..."
    cat | sudo tee "$config_dir/profile.conf" > /dev/null <<EOF
# LAMP OS User Profile Configuration
USERNAME=$username
PROFILE_PICTURE=$profile_picture
DISPLAY_RESOLUTION=$RESOLUTION
DISPLAY_WIDTH=${RESOLUTION%x*}
DISPLAY_HEIGHT=${RESOLUTION#*x}
CREATED_DATE=$(date)
SYSTEM_NAME=LAMP OS v2.0
CREATOR=yousef mohmed
EOF
    sudo chown "$username:$username" "$config_dir/profile.conf"
    echo -ne "${GREEN}✓ Profile saved${NC}\n"
    
    sleep 1
    
    echo "Step 4/4: Configuring desktop environment..."
    
    # Create .bashrc with custom greeting
    cat | sudo tee "/home/$username/.bashrc" > /dev/null <<'EOF'
# LAMP OS Bash Configuration

export LANG=en_US.UTF-8
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Custom prompt
PS1="${CYAN}[LAMP]${NC} \u@\h: \w\$ "

# Aliases
alias ls='ls --color=auto'
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'

# Load profile picture on login
if [ -f "$HOME/.config/lamp-os/profile.conf" ]; then
    source "$HOME/.config/lamp-os/profile.conf"
    echo -ne "\n${GREEN}Welcome to LAMP OS ${CYAN}$SYSTEM_NAME${GREEN}!${NC}\n"
    echo -ne "${CYAN}User:${NC} $USERNAME\n\n"
fi
EOF
    sudo chown "$username:$username" "/home/$username/.bashrc"
    echo -ne "${GREEN}✓ Desktop configured${NC}\n"
    
    sleep 2
}

configure_display() {
    clear_screen
    draw_box "Applying Display Settings..."
    echo ""
    
    echo "Configuring display resolution..."
    
    # Set framebuffer resolution if possible
    if [ -f "/sys/class/graphics/fb0/virtual_size" ]; then
        IFS='x' read -r width height <<< "$RESOLUTION"
        echo "${width},${height}" | sudo tee /sys/class/graphics/fb0/virtual_size > /dev/null 2>&1 || true
    fi
    
    # Store resolution for future boots
    echo "DISPLAY_RESOLUTION=$RESOLUTION" | sudo tee /etc/default/lamp-display > /dev/null
    
    echo -ne "${GREEN}✓ Display resolution applied${NC}\n"
    sleep 2
}

show_completion() {
    clear_screen
    draw_box "Setup Complete!"
    echo ""
    echo -ne "${GREEN}✓ User Account:${NC}       $username\n"
    echo -ne "${GREEN}✓ Display:${NC}            $RESOLUTION\n"
    echo -ne "${GREEN}✓ Profile Picture:${NC}    $(basename "$profile_picture")\n"
    echo -ne "${GREEN}✓ Password:${NC}           $([ -z "$password_hash" ] && echo "None (skip login)" || echo "Set")\n"
    echo ""
    echo -ne "${CYAN}System is ready to use!${NC}\n"
    echo ""
    echo -ne "${YELLOW}Available commands:${NC}\n"
    echo -ne "${GREEN}  • lamp-desktop${NC}   - Start desktop environment\n"
    echo -ne "${GREEN}  • lamp-menu${NC}      - Open application menu\n"
    echo -ne "${GREEN}  • help${NC}           - Show system help\n"
    echo ""
    sleep 3
}

launch_desktop() {
    clear_screen
    echo -ne "${GREEN}Launching desktop environment...${NC}\n"
    sleep 1
    
    # Switch to user and start desktop
    if command -v lamp-desktop &> /dev/null; then
        sudo -u "$username" lamp-desktop
    elif command -v lamp-desktop-menu &> /dev/null; then
        sudo -u "$username" lamp-desktop-menu
    else
        exec sudo -u "$username" bash
    fi
}

# Main execution
main() {
    set_display_resolution
    create_user_profile
    select_profile_picture
    save_user_config
    configure_display
    show_completion
    launch_desktop
}

main
