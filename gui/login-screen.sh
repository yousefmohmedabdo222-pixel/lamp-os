#!/bin/bash
# login screen simulation

clear
echo "===================="
echo "   LAMP OS Login   "
echo "===================="
echo -n "Username: "
read user
echo -n "Password: "
read -s pass
echo
echo "Authenticating..."
sleep 1
echo "Welcome, $user!"
sleep 1
