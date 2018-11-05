#!/bin/sh

# Bootstrap es un script que habilita para su primer uso con TJBot la tarjeta Raspberry pi.
# Tareas:
# * Actualiza las librerías
# * Instala un teclado virtual para su uso con mouse
# * Habilita las conexiones ssh
# * Habilita la camara
# * La salida de audio se asigna en automático
# * El volumen se ajusta a 50%
# * Instalará los nodos de TJBot en Node-Red
# * Se modifican los permisos de nodered para el usuario actual.
# * Finalmente, se reinicia.

#Update dependences and install text to speech app
apt-get install matchbox-keyboard -y
cp keyboard.sh /home/pi/Desktop/

#Enable ssh to start at boot
systemctl enable ssh
systemctl start ssh

#Habilitar camara
echo "start_x=1" | tee -a /boot/config.txt
#Set audio output to automatic
amixer cset numid=3 0
#Set USB Audio as default
cp sound.blacklist.conf /etc/modprobe.d/sound.blacklist.conf
#Set volume to 90%
amixer sset 'PCM' 90%
#This file is if we have problems with sound cards in the most recent RPI 3B+ devices, put in /etc/modprobe.d/alsa-base.conf if needed
mv /home/pi/tjbot_setup/alsa-base.conf /home/pi/Desktop/alsa-base.conf


# Node red update/install
node-red-stop
cd /home/pi/.node-red
mkdir /home/pi/.node-red/nodes
cd /home/pi/.node-red/nodes

git clone https://github.com/jeancarl/node-red-contrib-tjbot
# git clone https://github.com/JairLizarraga-IBM/node-red-contrib-tjbot
cd /home/pi/.node-red/nodes/node-red-contrib-tjbot
npm install --unsafe-perm


# Node red service configuration
sed -i -e 's/User=pi/User=root/g' /lib/systemd/system/nodered.service
systemctl daemon-reload
systemctl enable nodered.service
node-red-start &
echo "Iniciando servidor"
sleep 10
node-red-stop
echo "Deteniendo servidor"
sleep 5

# Renombrar usuario en javascript
sed -i -e "s/\/\/userDir: '\/home\/nol\/.node-red\/'/userDir: '\/home\/pi\/.node-red\/'/g" /root/.node-red/settings.js
sed -i -e "s/\/\/nodesDir: '\/home\/nol\/.node-red\/nodes',/nodesDir: '\/home\/pi\/.node-red\/nodes',/g" /root/.node-red/settings.js
reboot now
