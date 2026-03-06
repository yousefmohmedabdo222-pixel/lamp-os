#!/bin/bash
# partition selection simulation

clear
# installation logo / background
if [ -f "gui/icons/logo2.jpeg" ]; then
    echo "[Install Logo] gui/icons/logo2.jpeg"
elif [ -f "/usr/share/lamp/logos/logo2.jpeg" ]; then
    echo "[Install Logo] /usr/share/lamp/logos/logo2.jpeg"
fi
if [ -f "opt/backgrounds/Installation screen background.jpeg" ]; then
    echo "[Install Background] opt/backgrounds/Installation screen background.jpeg"
elif [ -f "/usr/share/lamp/backgrounds/Installation screen background.jpeg" ]; then
    echo "[Install Background] /usr/share/lamp/backgrounds/Installation screen background.jpeg"
fi
echo "=== Partition Selector ==="
echo "1) /dev/sda1  (root)"
echo "2) /dev/sda2  (home)"
echo "3) /dev/sdb1  (data)"
echo
echo "Designer: yousef mohmed"  # عرض الاسم كما هو مطلوب
echo
deadline=""
read -p "Select partition [1-3]: " choice
echo "You chose option $choice"
sleep 1
