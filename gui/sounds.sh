#!/bin/bash

# LAMP OS - System Sound Effects
# تأثيرات صوتية للنظام

# Note: هذه تحتاج speaker-test أو speaker-test بـ beep

# Function to play boot sound
play_boot_sound() {
    # Play a series of beeps to simulate boot sound
    if command -v speaker-test &> /dev/null; then
        speaker-test -t sine -f 1000 -l 1 2>/dev/null
    elif command -v beep &> /dev/null; then
        beep -f 1000 -l 200
        sleep 0.1
        beep -f 1200 -l 200
        sleep 0.1
        beep -f 1500 -l 300
    fi
}

# Function to play login sound
play_login_sound() {
    # Windows 7-like login chime
    if command -v beep &> /dev/null; then
        beep -f 800 -l 100
        sleep 0.05
        beep -f 1200 -l 200
    fi
}

# Function to play error sound
play_error_sound() {
    if command -v beep &> /dev/null; then
        beep -f 400 -l 100
        sleep 0.05
        beep -f 400 -l 100
        sleep 0.05
        beep -f 400 -l 100
    fi
}

# Function to play success sound
play_success_sound() {
    if command -v beep &> /dev/null; then
        beep -f 1000 -l 100
        sleep 0.05
        beep -f 1500 -l 200
    fi
}

# Function to play shutdown sound
play_shutdown_sound() {
    if command -v beep &> /dev/null; then
        beep -f 1500 -l 300
        sleep 0.1
        beep -f 1200 -l 300
        sleep 0.1
        beep -f 1000 -l 400
    fi
}

# Export functions for use
export -f play_boot_sound
export -f play_login_sound
export -f play_error_sound
export -f play_success_sound
export -f play_shutdown_sound

# Main execution based on argument
case "$1" in
    boot)
        play_boot_sound
        ;;
    login)
        play_login_sound
        ;;
    error)
        play_error_sound
        ;;
    success)
        play_success_sound
        ;;
    shutdown)
        play_shutdown_sound
        ;;
    *)
        echo "Usage: $0 {boot|login|error|success|shutdown}"
        ;;
esac
