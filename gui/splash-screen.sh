#!/bin/bash
# splash animation for premium edition

clear
echo "================================="
echo "       Welcome to LAMP OS        "
echo "================================="
sleep 1
for i in {1..5}; do
  printf "\rLoading%s" "$(printf '.%.0s' $(seq 1 $i))"
  sleep 0.5
done
echo
sleep 1
