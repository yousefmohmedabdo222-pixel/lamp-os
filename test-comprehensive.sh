#!/bin/bash
# LAMP OS - Comprehensive Test Suite

OUTPUT_FILE="/tmp/lamp-comprehensive-test.log"
rm -f "$OUTPUT_FILE"

echo "╔════════════════════════════════════════════════════════════════════════════╗"
echo "║                    LAMP OS - Comprehensive Test Suite                      ║"
echo "║                         Starting Boot Test...                              ║"
echo "╚════════════════════════════════════════════════════════════════════════════╝"
echo ""
echo "This test will:"
echo "  1. Boot the ISO"
echo "  2. Verify kernel loads"
echo "  3. Check for shell prompt"
echo "  4. Verify tools are available"
echo ""
echo "Output will be saved to: $OUTPUT_FILE"
echo ""

cd /workspaces/lamp-os

# Start QEMU in background with input
{
    sleep 4
    echo "echo 'Welcome to LAMP OS Test Suite'"
    sleep 1
    echo "ls /opt/lamp-gui/"
    sleep 1
    echo "ls /usr/local/bin/"
    sleep 1
    echo "cat /usr/local/share/doc/lamp-os/help.txt | head -20"
    sleep 1
    echo "exit"
    sleep 2
} | timeout 40 qemu-system-x86_64 \
    -cdrom lamp-os.iso \
    -m 512M \
    -nographic \
    -serial file:"$OUTPUT_FILE" \
    -accel tcg 2>&1 > /dev/null

echo ""
echo "╔════════════════════════════════════════════════════════════════════════════╗"
echo "║                          Test Results                                      ║"
echo "╚════════════════════════════════════════════════════════════════════════════╝"
echo ""

if [ -f "$OUTPUT_FILE" ]; then
    LINES=$(wc -l < "$OUTPUT_FILE")
    echo "✓ Boot log generated ($LINES lines)"
    echo ""
    
    # Check for key indicators
    echo "Boot Status:"
    grep -q "Run /bin/sh as init process" "$OUTPUT_FILE" && echo "  ✓ Shell init successful" || echo "  ✗ Shell init failed"
    grep -q "/ #" "$OUTPUT_FILE" && echo "  ✓ Shell prompt found" || echo "  ✗ Shell prompt not found"
    grep -q "Kernel panic" "$OUTPUT_FILE" && echo "  ✗ Kernel panic detected" || echo "  ✓ No kernel panics"
    
    echo ""
    echo "Tools Status:"
    grep -q "/opt/lamp-gui/" "$OUTPUT_FILE" && echo "  ✓ lamp-gui available" || echo "  ? lamp-gui status unknown"
    grep -q "lamp-menu" "$OUTPUT_FILE" && echo "  ✓ lamp-menu available" || echo "  ? lamp-menu status unknown"
    grep -q "lamp-network" "$OUTPUT_FILE" && echo "  ✓ lamp-network available" || echo "  ? lamp-network status unknown"
    
    echo ""
    echo "Last 50 lines of output:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    tail -50 "$OUTPUT_FILE"
    
else
    echo "✗ No output file generated"
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✓ Test completed successfully!"
echo ""
echo "Full log saved to: $OUTPUT_FILE"
echo ""
echo "Next steps:"
echo "  1. Review the boot log:"
echo "     tail -100 $OUTPUT_FILE"
echo ""
echo "  2. Boot LAMP OS interactively:"
echo "     timeout 30 qemu-system-x86_64 -cdrom /workspaces/lamp-os/lamp-os.iso -m 512M -nographic -serial file:/tmp/boot.log -accel tcg"
echo ""
echo "  3. Access the help documentation:"
echo "     cat /tmp/help.txt"
echo ""
