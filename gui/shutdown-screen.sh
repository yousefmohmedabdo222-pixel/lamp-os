#!/bin/bash
# shutdown animation

clear
echo "Goodbye from LAMP OS"
for i in {5..1}; do
  printf "\rShutting down in %d..." $i
  sleep 1
done
echo
echo "Powering off."
