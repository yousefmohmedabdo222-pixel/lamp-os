#!/bin/bash
# wrapper script for system sounds (premium edition)

if [ $# -lt 1 ]; then
    echo "Usage: $0 {boot|login|success|error|shutdown}"
    exit 1
fi

# locate the lamp-sounds helper
if command -v lamp-sounds >/dev/null 2>&1; then
    LAMP_SOUNDS="$(command -v lamp-sounds)"
else
    # try relative bin directory next to project root
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    LAMP_SOUNDS="$SCRIPT_DIR/../bin/lamp-sounds"
    if [ ! -x "$LAMP_SOUNDS" ]; then
        echo "lamp-sounds utility not found (searched PATH and $LAMP_SOUNDS)"
        exit 1
    fi
fi

"$LAMP_SOUNDS" "$1"
