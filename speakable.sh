#!/bin/sh

# speakable.sh es un script que habilitará el habla de la dirección IP cada que 
# la raspberry pi se reinicie. De esta manera, se podrá hacer conexión remota sin
# necesidad de una pantalla, mouse ni teclado.

apt-get update
apt-get install espeak -y
apt-get install speech-dispatcher -y

#Enable speakable ip address on startup
mv rc.local /etc/rc.local

# Completando actualizaciones de IBM Watson debidas a la autenticación
cp config.js /home/pi/.node-red/nodes/node-red-contrib-tjbot/tjbot/config.js
cp config.html /home/pi/.node-red/nodes/node-red-contrib-tjbot/tjbot/config.html
cp tjbot.js /home/pi/.node-red/nodes/node-red-contrib-tjbot/node_modules/tjbot/lib/tjbot.js


#Enable Wi-Fi bootable configuration
cp mi_red_wifi.default.txt /boot/
cp mi_red_wifi.txt /boot/
cp wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.default.conf

reboot now
