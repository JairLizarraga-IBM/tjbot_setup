#!/bin/sh

#Update dependences and install text to speech app
apt-get update
apt-get install espeak

#Enable speakable ip address
mkdir -p /home/pi/scripts
cp getipaddress.sh /home/pi/scripts/
sed -i -e "s/exit 0;/sleep 15; \/home\/pi\/scripts\/getipaddress.sh || exit 1; exit 0;/g" /etc/rc.local

#Enable Wi-Fi bootable configuration
cp mi_red_wifi.default.txt /boot/
cp mi_red_wifi.txt /boot/

#Enable ssh to start at boot
sudo systemctl enable ssh
sudo systemctl start ssh

read -p "Would you like to change your RaspberryPI password? [Y/n] " choice </dev/tty
case "$choice" in
    "y" | "Y")
        passwd
        ;;
    *) ;;
esac

#Habilitar camara
sed -i -e "s/start_x=0/start_x=1/g" /boot/config.txt
#Set audio output to automatic
amixer cset numid=3 0
#Set volume to 50%
amixer sset 'PCM' 50%

# Node red update/install
node-red-stop
cd /home/pi/.node-red #!!!
mkdir /home/pi/.node-red/nodes
cd /home/pi/.node-red/nodes
git clone https://github.com/jeancarl/node-red-contrib-tjbot
cd /home/pi/.node-red/nodes/node-red-contrib-tjbot
npm install --unsafe-perm

# Node red service configuration
sudo sed -i -e 's/User=pi/User=root/g' /lib/systemd/system/nodered.service
sudo systemctl daemon-reload
sudo systemctl enable nodered.service
# Cerrar ventana y abrir otra
node-red-start

node-red-stop
# Renombrar usuario en javascript
sed -i -e "s/\/\/userDir: ‘\/home\/nol\/.node-red\/nodes’ ,/userDir: ‘\/home\/pi\/.node-red\/’ ,/g" /root/.node-red/settings.js
sed -i -e "s/\/\/nodesDir: ‘\/home\/nol\/.node-red\/nodes’ ,/nodesDir: ‘\/home\/pi\/.node-red\/nodes’ ,/g" /root/.node-red/settings.js
node-red-start
