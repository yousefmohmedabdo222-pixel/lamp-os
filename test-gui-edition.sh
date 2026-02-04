#!/bin/bash

# LAMP OS GUI Edition - Comprehensive Test Suite
# اختبار شامل لنسخة واجهة المستخدم الرسومية

echo "╔════════════════════════════════════════════════════════════╗"
echo "║     LAMP OS GUI Edition - Test & Build Suite v2.0         ║"
echo "║          نظام الاختبار والبناء الشامل لنسخة GUI          ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

# Counters
PASS=0
FAIL=0

# Test functions
test_check() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓${RESET} $2"
        ((PASS++))
    else
        echo -e "${RED}✗${RESET} $2"
        ((FAIL++))
    fi
}

# Start tests
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${YELLOW}Build Components Check${RESET}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

# Check kernel
if [ -f "iso/boot/vmlinuz" ]; then
    SIZE=$(ls -lh iso/boot/vmlinuz | awk '{print $5}')
    echo -e "${GREEN}✓${RESET} Kernel found (${SIZE})"
    ((PASS++))
else
    echo -e "${RED}✗${RESET} Kernel not found"
    ((FAIL++))
fi

# Check initrd
if [ -f "iso/boot/initrd.img" ]; then
    SIZE=$(ls -lh iso/boot/initrd.img | awk '{print $5}')
    echo -e "${GREEN}✓${RESET} Initrd found (${SIZE})"
    ((PASS++))
else
    echo -e "${RED}✗${RESET} Initrd not found"
    ((FAIL++))
fi

# Check GRUB
if [ -f "iso/boot/grub/grub.cfg" ]; then
    echo -e "${GREEN}✓${RESET} GRUB configuration found"
    ((PASS++))
else
    echo -e "${RED}✗${RESET} GRUB configuration not found"
    ((FAIL++))
fi

# Check ISO
if [ -f "lamp-os-gui.iso" ]; then
    SIZE=$(ls -lh lamp-os-gui.iso | awk '{print $5}')
    echo -e "${GREEN}✓${RESET} ISO image found (${SIZE})"
    ((PASS++))
else
    echo -e "${RED}✗${RESET} ISO image not found"
    ((FAIL++))
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${YELLOW}GUI Components Check${RESET}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

# Check desktop menu
if [ -x "initrd/usr/local/bin/lamp-desktop-menu" ]; then
    echo -e "${GREEN}✓${RESET} Desktop menu executable found"
    ((PASS++))
else
    echo -e "${RED}✗${RESET} Desktop menu not found"
    ((FAIL++))
fi

# Check start-desktop
if [ -f "initrd/root/start-desktop.sh" ]; then
    echo -e "${GREEN}✓${RESET} Desktop startup script found"
    ((PASS++))
else
    echo -e "${RED}✗${RESET} Desktop startup script not found"
    ((FAIL++))
fi

# Check other tools
for tool in lamp-menu lamp-network lamp-system; do
    if [ -x "initrd/usr/local/bin/$tool" ]; then
        echo -e "${GREEN}✓${RESET} System tool '$tool' found"
        ((PASS++))
    else
        echo -e "${RED}✗${RESET} System tool '$tool' not found"
        ((FAIL++))
    fi
done

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${YELLOW}System Boot Test${RESET}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

echo "🚀 Starting QEMU test (30 seconds)..."
timeout 30 qemu-system-x86_64 -cdrom lamp-os-gui.iso -m 512M \
    -nographic -serial file:/tmp/test-gui.log -accel tcg >/dev/null 2>&1

# Check boot success
if grep -q "Run /bin/sh as init process" /tmp/test-gui.log; then
    echo -e "${GREEN}✓${RESET} Kernel boot successful"
    ((PASS++))
else
    echo -e "${RED}✗${RESET} Kernel boot failed"
    ((FAIL++))
fi

# Check shell prompt
if grep -q "/ #" /tmp/test-gui.log; then
    echo -e "${GREEN}✓${RESET} Shell prompt appeared"
    ((PASS++))
else
    echo -e "${RED}✗${RESET} Shell prompt not found"
    ((FAIL++))
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${YELLOW}Documentation Check${RESET}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

docs=("README.md" "QUICKSTART.md" "GUI_EDITION.md" "DOCUMENTATION_INDEX.md" "PROJECT_COMPLETION.md")
for doc in "${docs[@]}"; do
    if [ -f "$doc" ]; then
        SIZE=$(wc -l < "$doc")
        echo -e "${GREEN}✓${RESET} Documentation '$doc' found (${SIZE} lines)"
        ((PASS++))
    else
        echo -e "${RED}✗${RESET} Documentation '$doc' not found"
        ((FAIL++))
    fi
done

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${YELLOW}Final Report${RESET}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

TOTAL=$((PASS + FAIL))
PERCENT=$((PASS * 100 / TOTAL))

echo ""
echo "Test Results:"
echo "  ✓ Passed: ${GREEN}${PASS}${RESET}"
echo "  ✗ Failed: ${RED}${FAIL}${RESET}"
echo "  Total:  ${TOTAL}"
echo "  Rate:   ${PERCENT}%"
echo ""

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${GREEN}✅ All tests PASSED! System is ready!${RESET}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
else
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${RED}❌ Some tests FAILED. Please check the errors.${RESET}"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
fi

echo ""
echo "📋 Boot Log: /tmp/test-gui.log"
echo ""
echo "🚀 Next steps:"
echo "   1. Review boot log: tail /tmp/test-gui.log"
echo "   2. Read GUI_EDITION.md for interface details"
echo "   3. Start system: timeout 30 qemu-system-x86_64 -cdrom lamp-os-gui.iso -m 512M -nographic -serial file:/tmp/boot.log -accel tcg"
echo ""

exit $FAIL
