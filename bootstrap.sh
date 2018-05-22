#!/bin/sh

#Update dependences and install text to speech app
apt-get update
apt-get install espeak

#Enable speakable ip address
mkdir -p /home/pi/scripts
cp getipaddress.sh /home/pi/scripts/
sed -i -e "s/exit 0/sleep 15; \/home\/pi\/scripts\/getipaddress.sh || exit 1; exit 0;/g" /etc/rc.local

#Enable Wi-Fi bootable configuration
cp mi_red_wifi.default.txt /boot/
cp mi_red_wifi.txt /boot/

#Enable ssh to start at boot
systemctl enable ssh
systemctl start ssh

#Habilitar camara
echo "start_x=1" | tee -a /boot/config.txt
#Set audio output to automatic
amixer cset numid=3 0
#Set volume to 50%
amixer sset 'PCM' 50%

# Node red update/install
node-red-stop
cd /home/pi/.node-red
mkdir /home/pi/.node-red/nodes
cd /home/pi/.node-red/nodes
git clone https://github.com/jeancarl/node-red-contrib-tjbot
cd /home/pi/.node-red/nodes/node-red-contrib-tjbot
npm install --unsafe-perm

# Node red service configuration
sed -i -e 's/User=pi/User=root/g' /lib/systemd/system/nodered.service
systemctl daemon-reload
systemctl enable nodered.service
node-red-start &
echo "Iniciando servidor"
sleep 10
echo "Deteniendo servidor"
sleep 5

# Renombrar usuario en javascript
sed -i -e "s/\/\/userDir: '\/home\/nol\/.node-red\/'/userDir: '\/home\/pi\/.node-red\/'/g" /root/.node-red/settings.js
sed -i -e "s/\/\/nodesDir: '\/home\/nol\/.node-red\/nodes',/nodesDir: '\/home\/pi\/.node-red\/nodes',/g" /root/.node-red/settings.js
reboot now
