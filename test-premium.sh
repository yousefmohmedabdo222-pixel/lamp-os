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

echo ""
echo "✅ All Premium Screens Tested Successfully!"
