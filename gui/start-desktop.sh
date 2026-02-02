#!/bin/bash
# LAMP OS - Desktop Environment Startup Script
# Windows 7-like Graphical Interface

export DISPLAY=:0
export LANG=en_US.UTF-8

# Create X11 socket directory
mkdir -p /tmp/.X11-unix
chmod 1777 /tmp/.X11-unix

# Start X server with framebuffer
echo "[*] Starting X11 Display Server..."
Xvfb :0 -screen 0 1024x768x24 -ac &
XVFB_PID=$!
sleep 2

# Set up environment
export DISPLAY=:0
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# Start window manager (IceWM - lightweight)
echo "[*] Starting Window Manager (IceWM)..."
icewm &
ICEWM_PID=$!

# Create application menu
echo "[*] Setting up Desktop..."

# Wait a bit for WM to initialize
sleep 1

# Start desktop background
feh --bg-scale /root/.wallpaper.png 2>/dev/null || true

# Start taskbar/panel
echo "[*] Starting Desktop Panel..."

# Launch LAMP OS desktop menu
cat > /root/.xinitrc << 'XINITRC'
#!/bin/sh
exec icewm-session
XINITRC

chmod +x /root/.xinitrc

# Main desktop loop
echo "[*] Desktop Environment Ready"
echo "[*] Display: $DISPLAY"
echo ""
echo "╔════════════════════════════════════╗"
echo "║   LAMP OS - Desktop Environment    ║"
echo "║      Windows 7-like Theme          ║"
echo "╚════════════════════════════════════╝"
echo ""
echo "Available Applications:"
echo "  • File Manager (pcmanfm)"
echo "  • Text Editor (gedit)"
echo "  • Terminal (xterm)"
echo "  • Settings (lamp-system)"
echo "  • Application Menu (Start)"
echo ""

# Keep running
wait $XVFB_PID
