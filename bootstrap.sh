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

#Habilitar camara
sed -i -e "s/start_x=0/start_x=1/g" /boot/config.txt
#Set audio output to automatic
amixer cset numid=3 0
#Set volume to 50%
amixer sset 'PCM' 50%


# Node red update/install
node-red-stop
cd .node-red
mkdir nodes
cd nodes
git clone https://github.com/jeancarl/node-red-contrib-tjbot
cd node-red-contrib-tjbot
npm install --unsafe-perm

# Node red service configuration
sudo sed -i -e 's/User=pi/User=root/g' ex.service
sudo systemctl daemon-reload

node-red-start

node-red-stop
# Renombrar usuario en javascript
sed -i -e "s/\/\/userDir: ‘\/home\/nol\/.node-red\/nodes’ ,/userDir: ‘\/home\/pi\/.node-red\/’ ,/g" ex.js
sed -i -e "s/\/\/nodesDir: ‘\/home\/nol\/.node-red\/nodes’ ,/nodesDir: ‘\/home\/pi\/.node-red\/nodes’ ,/g" ex.js
node-red-start
