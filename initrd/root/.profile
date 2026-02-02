#!/bin/sh
# LAMP OS - Enhanced Shell Profile

# Set environment variables
export PATH="/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin:/opt/lamp-gui:$PATH"
export SHELL=/bin/sh
export USER=root
export HOME=/root
export LOGNAME=root

# Create HOME directory if needed
mkdir -p $HOME

# Set PS1 prompt with colors
export PS1='🪔 lamp-os:\W \$ '

# Create useful aliases
alias ls='ls --color=auto'
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias mkdir='mkdir -p'
alias grep='grep --color=auto'
alias clear='clear'
alias reboot='sync && reboot'
alias halt='sync && halt'

# Useful functions
# Memory usage
alias meminfo='cat /proc/meminfo'

# CPU usage
alias cpuinfo='cat /proc/cpuinfo'

# Disk usage
alias diskfree='df -h'
alias diskused='du -h --max-depth=1'

# Network
alias netinfo='ip addr show'
alias netstat='ss -tuln'

# System uptime
alias uptime='uptime -p'

# Show PATH nicely
alias path='echo $PATH | tr ":" "\n"'

# System
alias update-proc='mount -t proc proc /proc'
alias update-sys='mount -t sysfs sysfs /sys'

# LAMP OS specific commands
alias lamp-menu='/usr/local/bin/lamp-menu'
alias lamp-network='/usr/local/bin/lamp-network'
alias lamp-system='/usr/local/bin/lamp-system'
alias lamp-help='cat /usr/local/share/doc/lamp-os/help.txt'

# Check if we should auto-launch menu
if [ -z "$LAMP_INTERACTIVE" ]; then
    # Show welcome message
    echo ""
    echo "╔════════════════════════════════════════╗"
    echo "║  Welcome to LAMP OS Shell              ║"
    echo "║  Version 1.0 - Boot $(date +%H:%M:%S)           ║"
    echo "╚════════════════════════════════════════╝"
    echo ""
    echo "Available commands:"
    echo "  lamp-menu     - System menu"
    echo "  lamp-network  - Network configuration"
    echo "  lamp-system   - System utilities"
    echo "  lamp-help     - Show help"
    echo ""
    echo "Type 'lamp-menu' to start the interactive menu"
    echo ""
fi
