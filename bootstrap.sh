#!/bin/sh

apt-get update
apt-get install espeak

read -p "Would you like to change your RaspberryPI password? [Y/n] " choice </dev/tty
case "$choice" in
    "y" | "Y")
        passwd
        ;;
    *) ;;
esac
passwd