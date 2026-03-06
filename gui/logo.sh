#!/bin/bash
# Display Lamp OS ASCII logo or show image path if available

# if an actual image file exists, mention it
if [ -f "gui/icons/logo.jpeg" ]; then
    echo "[logo image at gui/icons/logo.jpeg]"
elif [ -f "/usr/share/lamp/logos/logo.jpeg" ]; then
    echo "[logo image at /usr/share/lamp/logos/logo.jpeg]"
else
    cat <<'EOF'
    ██╗     ██╗    ███╗   ███╗██████╗ 
    ██║     ██║    ████╗ ████║██╔══██╗
    ██║     ██║    ██╔████╔██║██████╔╝
    ██║     ██║    ██║╚██╔╝██║██╔═══╝ 
    ███████╗███████╗██║ ╚═╝ ██║██║     
    ╚══════╝╚══════╝╚═╝     ╚═╝╚═╝     
        🕯️  LAMP OS v2.0 🕯️
EOF
fi
