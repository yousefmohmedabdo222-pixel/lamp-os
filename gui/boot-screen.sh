#!/bin/bash
# simple boot animation for premium edition

clear
# show logo if available
if [ -f "gui/icons/logo.jpeg" ]; then
    echo "[Logo] gui/icons/logo.jpeg"
elif [ -f "/usr/share/lamp/logos/logo.jpeg" ]; then
    echo "[Logo] /usr/share/lamp/logos/logo.jpeg"
fi
echo "=== LAMP OS Boot Screen ==="
for i in {1..20}; do
  printf "\rBooting [%3d%%]" $((i*5))
  sleep 0.1
done

echo
echo "Initialization complete."
sleep 1
