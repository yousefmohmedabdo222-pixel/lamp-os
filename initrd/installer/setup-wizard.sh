#!/bin/bash
# LAMP OS Interactive Installation Wizard
# Main TUI menu for disk partitioning and installation

set -e

# Wrapper so the script works when run as root or in environments without sudo
sudo() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    elif command -v sudo >/dev/null 2>&1; then
        command sudo "$@"
    else
        "$@"
    fi
}

# Colors for TUI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Styles
BOLD='\033[1m'
NORMAL='\033[0m'

clear_screen() {
    clear
    echo -ne "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}\n"
    echo -ne "${BLUE}║${WHITE}          LAMP OS Installation Wizard v2.0                    ${BLUE}║${NC}\n"
    echo -ne "${BLUE}║${WHITE}       © 2026 Created by: yousef mohmed                        ${BLUE}║${NC}\n"
    echo -ne "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}\n"
    echo ""
}

draw_menu_box() {
    local title="$1"
    echo -ne "${CYAN}┌──────────────────────────────────────────────────────────────┐${NC}\n"
    printf "${CYAN}│${WHITE} %-59s ${CYAN}│${NC}\n" "$title"
    echo -ne "${CYAN}└──────────────────────────────────────────────────────────────┘${NC}\n"
}

detect_disks() {
    lsblk -nd -o NAME,SIZE,TYPE | grep "disk" | awk '{print "/dev/"$1" ("$2")"}'
}

show_disk_selection() {
    clear_screen
    draw_menu_box "Step 1: Select Destination Disk"
    echo ""
    
    # Get list of disks
    local disks=()
    local i=1
    
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            disks+=("$line")
            echo -ne "${GREEN}[$i]${NC} $line\n"
            ((i++))
        fi
    done < <(detect_disks)
    
    if [ ${#disks[@]} -eq 0 ]; then
        echo -ne "${RED}✗ No disks found!${NC}\n"
        read -p "Press Enter to exit..."
        exit 1
    fi
    
    echo ""
    echo -ne "${YELLOW}Warning:${NC} All data on selected disk will be erased!\n"
    echo ""
    read -p "Select disk number [1-${#disks[@]}]: " choice
    
    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt ${#disks[@]} ]; then
        echo -ne "${RED}✗ Invalid selection${NC}\n"
        sleep 2
        show_disk_selection
        return
    fi
    
    SELECTED_DISK=$(echo "${disks[$((choice-1))]}" | awk '{print $1}')
    echo -ne "${GREEN}✓ Selected: $SELECTED_DISK${NC}\n"
}

show_partition_menu() {
    clear_screen
    draw_menu_box "Step 2: Partition Configuration"
    echo ""
    echo "Current Partitions on $SELECTED_DISK:"
    echo ""
    
    # Show current partitions
    if sudo fdisk -l "$SELECTED_DISK" 2>/dev/null | grep -q "Device"; then
        sudo fdisk -l "$SELECTED_DISK" 2>/dev/null | grep "$SELECTED_DISK" | head -20
    else
        echo "No partitions found"
    fi
    
    echo ""
    echo -ne "${CYAN}Options:${NC}\n"
    echo -ne "${GREEN}[1]${NC} Use Entire Disk (Format)\n"
    echo -ne "${GREEN}[2]${NC} Manual Partitioning\n"
    echo -ne "${GREEN}[3]${NC} Back\n"
    echo ""
    read -p "Select option: " opt
    
    case "$opt" in
        1)
            confirm_format
            auto_partition
            ;;
        2)
            manual_partition
            ;;
        3)
            show_disk_selection
            show_partition_menu
            ;;
        *)
            show_partition_menu
            ;;
    esac
}

confirm_format() {
    clear_screen
    draw_menu_box "⚠ WARNING: Format Confirmation"
    echo ""
    echo -ne "${RED}This will PERMANENTLY DELETE all data on $SELECTED_DISK${NC}\n"
    echo ""
    read -p "Type 'YES' to continue: " confirm
    
    if [ "$confirm" != "YES" ]; then
        show_partition_menu
        return 1
    fi
    return 0
}

auto_partition() {
    clear_screen
    draw_menu_box "Creating Partitions..."
    echo ""
    
    echo "Step 1/3: Creating GPT partition table..."
    sudo parted -s "$SELECTED_DISK" mklabel gpt
    echo -ne "${GREEN}✓ GPT created${NC}\n"
    
    echo "Step 2/3: Creating EFI partition (512MB)..."
    sudo parted -s "$SELECTED_DISK" mkpart primary fat32 1MB 513MB
    sudo parted -s "$SELECTED_DISK" set 1 esp on
    echo -ne "${GREEN}✓ EFI partition created${NC}\n"
    
    echo "Step 3/3: Creating root partition..."
    sudo parted -s "$SELECTED_DISK" mkpart primary ext4 513MB 100%
    echo -ne "${GREEN}✓ Root partition created${NC}\n"
    
    sleep 2
    
    # Detect partition devices
    if [[ "$SELECTED_DISK" == *"nvme"* ]]; then
        PART_EFI="${SELECTED_DISK}p1"
        PART_ROOT="${SELECTED_DISK}p2"
    else
        PART_EFI="${SELECTED_DISK}1"
        PART_ROOT="${SELECTED_DISK}2"
    fi
    
    echo "Step 4/3: Formatting partitions..."
    sudo mkfs.vfat -F 32 "$PART_EFI" > /dev/null 2>&1
    echo -ne "${GREEN}✓ EFI formatted${NC}\n"
    
    sudo mkfs.ext4 -F "$PART_ROOT" > /dev/null 2>&1
    echo -ne "${GREEN}✓ Root formatted${NC}\n"
    
    sleep 2
    show_installation_menu
}

manual_partition() {
    clear_screen
    draw_menu_box "Manual Partitioning"
    echo ""
    echo -ne "${YELLOW}Using fdisk for manual partitioning...${NC}\n"
    echo ""
    sudo fdisk "$SELECTED_DISK"
    
    # Ask user to select partitions
    clear_screen
    draw_menu_box "Select Partitions"
    echo ""
    echo "Available partitions:"
    sudo fdisk -l "$SELECTED_DISK" 2>/dev/null | grep "$SELECTED_DISK"
    
    echo ""
    read -p "Select EFI partition (e.g. ${SELECTED_DISK}1): " PART_EFI
    read -p "Select Root partition (e.g. ${SELECTED_DISK}2): " PART_ROOT
    
    echo "Step 1/2: Formatting EFI partition..."
    sudo mkfs.vfat -F 32 "$PART_EFI" > /dev/null 2>&1
    echo -ne "${GREEN}✓ EFI formatted${NC}\n"
    
    echo "Step 2/2: Formatting Root partition..."
    sudo mkfs.ext4 -F "$PART_ROOT" > /dev/null 2>&1
    echo -ne "${GREEN}✓ Root formatted${NC}\n"
    
    sleep 2
    show_installation_menu
}

show_installation_menu() {
    clear_screen
    draw_menu_box "Step 3: Installation Options"
    echo ""
    echo "Partitions to install:"
    echo -ne "${GREEN}EFI:${NC}  $PART_EFI\n"
    echo -ne "${GREEN}ROOT:${NC} $PART_ROOT\n"
    echo ""
    echo -ne "${CYAN}Options:${NC}\n"
    echo -ne "${GREEN}[1]${NC} Start Installation\n"
    echo -ne "${GREEN}[2]${NC} Cancel\n"
    echo ""
    read -p "Select option: " opt
    
    case "$opt" in
        1)
            start_installation
            ;;
        2)
            show_partition_menu
            ;;
        *)
            show_installation_menu
            ;;
    esac
}

start_installation() {
    clear_screen
    draw_menu_box "Installing LAMP OS..."
    echo ""
    
    # Mount partitions
    echo "Preparing filesystem..."
    MNT="/mnt/lamp-install"
    sudo mkdir -p "$MNT"
    sudo mount "$PART_ROOT" "$MNT"
    sudo mkdir -p "$MNT/boot/efi"
    sudo mount "$PART_EFI" "$MNT/boot/efi"
    echo -ne "${GREEN}✓ Partitions mounted${NC}\n"
    
    # Copy system files (root filesystem) to the target disk
    echo "Copying system files..."
    # Exclude pseudo-filesystems and the target mount point
    (cd / && find . \
        -path ./proc -prune -o \
        -path ./sys -prune -o \
        -path ./dev -prune -o \
        -path ./run -prune -o \
        -path ./tmp -prune -o \
        -path ./mnt -prune -o \
        -path ./media -prune -o \
        -path ./lost+found -prune -o \
        -print) | cpio -pdm "$MNT" 2>/dev/null
    echo -ne "${GREEN}✓ System files copied${NC}\n"

    # Copy kernel to installed system (if available)
    echo "Copying kernel..."
    VMLINUZ_PATH="/boot/vmlinuz"
    if [ ! -f "$VMLINUZ_PATH" ]; then
        VMLINUZ_PATH="/vmlinuz"
    fi
    if [ ! -f "$VMLINUZ_PATH" ] && [ -f "/cdrom/boot/vmlinuz" ]; then
        VMLINUZ_PATH="/cdrom/boot/vmlinuz"
    fi

    if [ -f "$VMLINUZ_PATH" ]; then
        cp "$VMLINUZ_PATH" "$MNT/boot/" 2>/dev/null || true
        echo -ne "${GREEN}✓ Kernel copied${NC}\n"
    else
        echo -ne "${YELLOW}⚠ Kernel not found; boot may not work without it${NC}\n"
    fi
    
    # Create fstab with UUIDs
    echo "Creating filesystem configuration..."
    UUID_ROOT=$(sudo blkid -s UUID -o value "$PART_ROOT")
    UUID_EFI=$(sudo blkid -s UUID -o value "$PART_EFI")
    
    sudo tee "$MNT/etc/fstab" > /dev/null <<EOF
UUID=$UUID_ROOT / ext4 defaults 0 1
UUID=$UUID_EFI /boot/efi vfat defaults 0 2
EOF
    echo -ne "${GREEN}✓ Filesystem config created${NC}\n"
    
    # Copy GRUB config
    echo "Installing bootloader..."
    sudo mkdir -p "$MNT/boot/grub"
    sudo cp /cdrom/boot/grub/grub.cfg "$MNT/boot/grub/" 2>/dev/null || true
    
    # Install GRUB for UEFI
    sudo grub-install --target=x86_64-efi \
        --efi-directory="$MNT/boot/efi" \
        --bootloader-id="LAMP OS" \
        --root-directory="$MNT" \
        --no-nvram 2>/dev/null || true
    
    # Install GRUB for BIOS
    sudo grub-install --target=i386-pc \
        --root-directory="$MNT" \
        "$SELECTED_DISK" 2>/dev/null || true
    
    echo -ne "${GREEN}✓ Bootloader installed${NC}\n"
    
    # Store partition info for post-install
    echo "$SELECTED_DISK" | sudo tee "$MNT/root/.install_disk" > /dev/null
    echo "$PART_ROOT" | sudo tee "$MNT/root/.install_root" > /dev/null
    echo "$PART_EFI" | sudo tee "$MNT/root/.install_efi" > /dev/null
    
    # Cleanup
    echo "Finalizing installation..."
    sudo sync
    sudo umount "$MNT/boot/efi"
    sudo umount "$MNT"
    echo -ne "${GREEN}✓ Installation complete!${NC}\n"
    
    sleep 2
    show_completion_menu
}

show_completion_menu() {
    clear_screen
    draw_menu_box "Installation Successful!"
    echo ""
    echo -ne "${GREEN}✓ LAMP OS has been installed to $SELECTED_DISK${NC}\n"
    echo ""
    echo -ne "${CYAN}Next steps:${NC}\n"
    echo -ne "${GREEN}[1]${NC} Reboot System\n"
    echo -ne "${GREEN}[2]${NC} Exit to Shell\n"
    echo ""
    read -p "Select option: " opt
    
    case "$opt" in
        1)
            echo "System will reboot in 10 seconds..."
            sleep 10
            sudo reboot
            ;;
        2)
            clear
            exit 0
            ;;
        *)
            show_completion_menu
            ;;
    esac
}

# Main execution
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -ne "${RED}✗ This script must be run as root${NC}\n"
        echo "Run: sudo bash $0"
        exit 1
    fi
}

main() {
    check_root
    show_disk_selection
    show_partition_menu
}

main
