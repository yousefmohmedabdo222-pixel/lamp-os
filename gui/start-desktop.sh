#!/bin/sh
# generic helper to start a graphical desktop on Lamp OS
# by default it will try to start the built-in Lamp Desktop application
# if KDE Plasma is installed it can launch that instead.

# look for a custom environment variable override
if [ -n "$LAMP_DESKTOP_CMD" ]; then
    exec $LAMP_DESKTOP_CMD
fi

# if Wayland plasma launcher exists, use it (user requested Plasma Wayland)
if command -v startplasma-wayland >/dev/null 2>&1; then
    exec startplasma-wayland
fi
# legacy: also check generic plasma command
if command -v startplasma >/dev/null 2>&1; then
    exec startplasma --wayland
fi

# fall back to lamp-desktop if available
if command -v lamp-desktop >/dev/null 2>&1; then
    exec lamp-desktop
fi

# otherwise open a simple xterm
if command -v xterm >/dev/null 2>&1; then
    exec xterm
fi

# nothing available
echo "No graphical desktop installed."
