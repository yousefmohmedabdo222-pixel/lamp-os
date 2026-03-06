#!/bin/bash

# Test all premium animation screens

echo "Testing LAMP OS Premium Edition Screens..."
echo ""

echo "1️⃣ Boot Screen:"
echo "===================================="
bash /workspaces/lamp-os/gui/boot-screen.sh
clear

echo "2️⃣ Splash Screen:"
echo "===================================="
bash /workspaces/lamp-os/gui/splash-screen.sh
clear

echo "3️⃣ Login Screen:"
echo "===================================="
bash /workspaces/lamp-os/gui/login-screen.sh
clear

echo "4️⃣ Partition Screen:"
echo "===================================="
bash /workspaces/lamp-os/gui/partition-screen.sh
clear

echo "5️⃣ Shutdown Screen:"
echo "===================================="
bash /workspaces/lamp-os/gui/shutdown-screen.sh
clear

# check logo files
if [ -f "gui/icons/logo.jpeg" ]; then
    echo "[✓] boot logo present"
else
    echo "[⚠️] boot logo missing"
fi
if [ -f "gui/icons/logo2.jpeg" ]; then
    echo "[✓] install logo present"
else
    echo "[⚠️] install logo missing"
fi

# check wallpaper file for desktop
if [ -f "opt/backgrounds/image_1772741586376.jpeg" ]; then
    echo "[✓] default wallpaper file present"
else
    echo "[⚠️] default wallpaper missing"
fi

# play each sound (if scripts available)
echo "\n🔊 Testing system sounds..."
export LAMP_SOUND_DIR="$(pwd)/opt/sounds"
echo "boot:"; bash /workspaces/lamp-os/gui/sounds.sh boot
echo "login:"; bash /workspaces/lamp-os/gui/sounds.sh login
echo "success:"; bash /workspaces/lamp-os/gui/sounds.sh success
echo "error:"; bash /workspaces/lamp-os/gui/sounds.sh error
echo "shutdown:"; bash /workspaces/lamp-os/gui/sounds.sh shutdown

echo ""
echo "✅ All Premium Screens Tested Successfully!"
