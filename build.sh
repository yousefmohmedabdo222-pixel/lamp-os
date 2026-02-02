#!/bin/bash

###############################################################################
#                   🪔 Lamp OS - Master Build Script
#
# This is the main build orchestrator for Lamp OS.
# It coordinates all build stages in the correct order.
#
# Usage: ./build.sh [stage] [options]
#        ./build.sh                    # Full build (interactive)
#        ./build.sh quick              # Fast build (kernel + initrd + ISO)
#        ./build.sh kernel             # Build kernel only
#        ./build.sh initrd             # Build initrd only
#        ./build.sh iso                # Create ISO only
#        ./build.sh clean              # Clean build artifacts
#        ./build.sh help               # Show help
###############################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Configuration
PROJECT_NAME="Lamp OS"
PROJECT_VERSION="0.1.0"
START_TIME=$(date +%s)

# Helper functions
print_header() {
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════════════════════╗"
    echo "║${NC} $1 ${BLUE}║"
    echo "╚════════════════════════════════════════════════════════╝${NC}"
}

print_step() {
    echo -e "\n${MAGENTA}┌─ Step: $1${NC}"
}

status() {
    echo -e "${GREEN}✓${NC} $1"
}

error() {
    echo -e "${RED}✗${NC} $1"
    exit 1
}

warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

info() {
    echo -e "${CYAN}ℹ${NC} $1"
}

success() {
    echo -e "${GREEN}${MAGENTA}✨${NC} $1"
}

# Show help
show_help() {
    cat << 'EOF'
🪔 Lamp OS Master Build Script

USAGE:
    ./build.sh [COMMAND] [OPTIONS]

COMMANDS:
    (none)          Interactive build menu
    quick           Build everything fast (kernel + initrd + ISO)
    kernel          Build Linux kernel only
    initrd          Build initrd only  
    iso             Create ISO image only
    clean           Clean build artifacts
    distclean       Full clean (remove everything)
    status          Show build status
    help            Show this help

EXAMPLES:
    ./build.sh                  # Start interactive menu
    ./build.sh quick            # Full automated build
    ./build.sh kernel           # Just build kernel
    ./build.sh clean            # Clean up

REQUIREMENTS:
    - build-essential (gcc, make, binutils)
    - linux source headers
    - xorriso or grub-mkrescue
    - wget (for downloading)
    - bc (for calculations)

For detailed documentation:
    - README.md              - Project overview
    - GETTING_STARTED.md     - Step-by-step guide
    - ARCHITECTURE.md        - Technical details

EOF
}

# Show status
show_status() {
    echo -e "\n${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║             🪔 Lamp OS - Build Status                 ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
    
    echo ""
    echo -e "${CYAN}Kernel:${NC}"
    if [ -f "kernel/linux-6.6/arch/x86_64/boot/bzImage" ]; then
        size=$(ls -lh kernel/linux-6.6/arch/x86_64/boot/bzImage | awk '{print $5}')
        echo "  ✓ Built ($size)"
    else
        echo "  ✗ Not built"
    fi
    
    echo ""
    echo -e "${CYAN}Initrd:${NC}"
    if [ -f "iso/boot/initrd.img" ]; then
        size=$(ls -lh iso/boot/initrd.img | awk '{print $5}')
        echo "  ✓ Built ($size)"
    else
        echo "  ✗ Not built"
    fi
    
    echo ""
    echo -e "${CYAN}ISO:${NC}"
    if [ -f "lamp-os.iso" ]; then
        size=$(ls -lh lamp-os.iso | awk '{print $5}')
        echo "  ✓ Created ($size)"
    else
        echo "  ✗ Not created"
    fi
    
    echo ""
    echo -e "${CYAN}Documentation:${NC}"
    doc_files=0
    [ -f "README.md" ] && ((doc_files++))
    [ -f "VISION.md" ] && ((doc_files++))
    [ -f "ARCHITECTURE.md" ] && ((doc_files++))
    [ -f "GETTING_STARTED.md" ] && ((doc_files++))
    echo "  ✓ $doc_files files"
    
    echo ""
}

# Check prerequisites
check_prerequisites() {
    print_step "Checking Prerequisites"
    
    echo "Checking required tools..."
    
    local missing=0
    
    local required_tools=("gcc" "make" "wget" "bc")
    for tool in "${required_tools[@]}"; do
        if command -v $tool &> /dev/null; then
            status "$tool installed"
        else
            error "$tool not found! Install it first."
            ((missing++))
        fi
    done
    
    # Optional tools
    echo ""
    echo "Checking optional tools..."
    if command -v grub-mkrescue &> /dev/null; then
        status "grub-mkrescue available"
    else
        warning "grub-mkrescue not found"
    fi
    
    if command -v xorriso &> /dev/null; then
        status "xorriso available"
    else
        warning "xorriso not found"
    fi
    
    if [ $missing -gt 0 ]; then
        error "Missing required tools! Please install them first."
    fi
    
    info "All prerequisites satisfied!"
}

# Create directory structure
setup_directories() {
    print_step "Setting Up Directories"
    
    mkdir -p kernel gui initrd src
    mkdir -p iso/{boot/grub,live}
    
    status "Directory structure created"
}

# Build kernel
build_kernel() {
    print_step "Building Linux Kernel"
    
    if [ -f "./build_kernel.sh" ]; then
        info "Running kernel builder..."
        ./build_kernel.sh
        
        if [ -f "kernel/linux-6.6/arch/x86_64/boot/bzImage" ]; then
            success "Kernel build successful!"
        else
            error "Kernel build failed!"
        fi
    else
        error "build_kernel.sh not found!"
    fi
}

# Build initrd
build_initrd() {
    print_step "Building Initrd"
    
    if [ -f "./build_initrd.sh" ]; then
        info "Running initrd builder..."
        ./build_initrd.sh
        
        if [ -f "iso/boot/initrd.img" ]; then
            success "Initrd build successful!"
        else
            error "Initrd build failed!"
        fi
    else
        error "build_initrd.sh not found!"
    fi
}

# Create ISO
create_iso() {
    print_step "Creating ISO"
    
    if [ -f "./create_iso.sh" ]; then
        info "Running ISO creator..."
        ./create_iso.sh
        
        if [ -f "lamp-os.iso" ]; then
            success "ISO creation successful!"
        else
            error "ISO creation failed!"
        fi
    else
        error "create_iso.sh not found!"
    fi
}

# Quick build (everything)
quick_build() {
    print_header "🪔 Lamp OS - Quick Build Mode"
    
    check_prerequisites
    setup_directories
    build_kernel
    build_initrd
    create_iso
    
    # Show final status
    show_build_summary
}

# Show build summary
show_build_summary() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║               ✓ Build Complete!                       ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
    
    END_TIME=$(date +%s)
    BUILD_TIME=$((END_TIME - START_TIME))
    
    echo ""
    echo -e "${GREEN}Build Summary:${NC}"
    echo "  Total time: $((BUILD_TIME / 60)) minutes $((BUILD_TIME % 60)) seconds"
    echo ""
    
    # Check what was built
    if [ -f "lamp-os.iso" ]; then
        iso_size=$(ls -lh lamp-os.iso | awk '{print $5}')
        echo "  ISO: lamp-os.iso ($iso_size)"
    fi
    
    if [ -f "kernel/linux-6.6/arch/x86_64/boot/bzImage" ]; then
        kernel_size=$(ls -lh kernel/linux-6.6/arch/x86_64/boot/bzImage | awk '{print $5}')
        echo "  Kernel: $kernel_size"
    fi
    
    echo ""
    echo -e "${GREEN}Test the system:${NC}"
    if [ -f "lamp-os.iso" ]; then
        echo "  qemu-system-x86_64 -cdrom lamp-os.iso -m 512 -smp 2"
    fi
    
    echo ""
    echo -e "${CYAN}Documentation:${NC}"
    echo "  - README.md: Project overview"
    echo "  - GETTING_STARTED.md: Detailed guide"
    echo "  - ARCHITECTURE.md: Technical details"
    echo ""
}

# Clean build artifacts
clean_build() {
    print_step "Cleaning Build Artifacts"
    
    warning "Removing build files..."
    
    rm -rf iso/boot/vmlinuz 2>/dev/null || true
    rm -rf iso/boot/initrd.img 2>/dev/null || true
    
    status "Build artifacts cleaned"
}

# Full clean (distclean)
distclean() {
    print_step "Full Cleanup"
    
    warning "This will remove ALL build directories!"
    read -p "Are you sure? (yes/no): " confirm
    
    if [ "$confirm" = "yes" ]; then
        rm -rf kernel gui initrd src iso
        rm -f lamp-os*.iso *.sha256
        status "Full cleanup complete"
    else
        info "Cleanup cancelled"
    fi
}

# Interactive menu
interactive_menu() {
    clear
    echo -e "${MAGENTA}"
    cat << 'EOF'
╔════════════════════════════════════════════════════════╗
║                                                        ║
║          🪔 Lamp OS - Master Build Script             ║
║                                                        ║
║          "Build a beautiful OS from scratch"          ║
║                                                        ║
╚════════════════════════════════════════════════════════╝

EOF
    
    echo -e "${CYAN}Choose an option:${NC}"
    echo ""
    echo "  1) Full Build (Quick) - Everything"
    echo "  2) Build Kernel only"
    echo "  3) Build Initrd only"
    echo "  4) Create ISO only"
    echo "  5) Show Build Status"
    echo "  6) Clean Build Artifacts"
    echo "  7) Full Cleanup (distclean)"
    echo "  8) Show Help"
    echo "  9) Exit"
    echo ""
    
    read -p "Enter choice (1-9): " choice
    
    case $choice in
        1) quick_build ;;
        2) check_prerequisites; setup_directories; build_kernel ;;
        3) check_prerequisites; setup_directories; build_initrd ;;
        4) check_prerequisites; create_iso ;;
        5) show_status ;;
        6) clean_build ;;
        7) distclean ;;
        8) show_help ;;
        9) echo "Goodbye! 👋"; exit 0 ;;
        *) echo "Invalid choice!" ;;
    esac
}

# Main script logic
main() {
    # Print header
    print_header "🪔 $PROJECT_NAME v$PROJECT_VERSION"
    
    # Process arguments
    case "${1:-menu}" in
        quick)
            quick_build
            ;;
        kernel)
            check_prerequisites
            setup_directories
            build_kernel
            ;;
        initrd)
            check_prerequisites
            setup_directories
            build_initrd
            ;;
        iso)
            check_prerequisites
            create_iso
            ;;
        clean)
            clean_build
            ;;
        distclean)
            distclean
            ;;
        status)
            show_status
            ;;
        help)
            show_help
            ;;
        menu)
            interactive_menu
            ;;
        *)
            echo -e "${RED}Unknown command: $1${NC}"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Run main
main "$@"
