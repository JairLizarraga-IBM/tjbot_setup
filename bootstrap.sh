#!/bin/sh
# Script that enables TJBot project in a new recent Raspbian OS installation.

#Update dependences and install text to speech app
installResources(){
	apt-get install espeak -y
	apt-get install speech-dispatcher -y
	apt-get install matchbox-keyboard -y
	cp ./config_files/keyboard.sh /home/pi/Desktop/
}

# Enable ssh to start at boot
enableSSH(){
	systemctl enable ssh
	systemctl start ssh
}

configureHardware(){
	echo "start_x=1" | tee -a /boot/config.txt # Activating camera
	amixer cset numid=3 0 # #Set audio output to automatic
	cp ./config_files/sound.blacklist.conf /etc/modprobe.d/sound.blacklist.conf # Set USB Audio as default
	amixer sset 'PCM' 100% # Set volume to 100%
}

# Update nodejs and node-red
updateNode(){
	git clone https://github.com/node-red/raspbian-deb-package.git ./config_files/node-red
	cd ./config_files/node-red/resources/
	su pi -c " ./update-nodejs-and-nodered" # Executing with user pi
	echo "Finalizando actualizacíon nodejs y nodered"
	sleep 5
}

# Installing TJBot nodes
installTJNodes(){
	node-red-stop
	mkdir ~/.node-red/nodes
	git clone https://github.com/JairLizarraga/nodes-tjbot-latam ~/.node-red/nodes
	cd ~/.node-red/nodes/nodes-tjbot-latam
	npm install --unsafe-perm
}


# Node red service configuration
configureNodeRedService(){
	sed -i -e 's/User=pi/User=root/g' /lib/systemd/system/nodered.service
	systemctl daemon-reload
	systemctl enable nodered.service
	node-red-start &
	echo "Iniciando servidor"
	sleep 10
	node-red-stop
	echo "Deteniendo servidor"
	sleep 5
	# Renaming user at node-red service
	sed -i -e "s/\/\/userDir: '\/home\/nol\/.node-red\/'/userDir: '\/home\/pi\/.node-red\/'/g" /root/.node-red/settings.js
	sed -i -e "s/\/\/nodesDir: '\/home\/nol\/.node-red\/nodes',/nodesDir: '\/home\/pi\/.node-red\/nodes',/g" /root/.node-red/settings.js
}


#Enable Wi-Fi bootable configuration
enableAddWiFiFromBoot(){
	cp ~/tjbot_setup/config_files/mi_red_wifi.default.txt /boot/
	cp ~/tjbot_setup/config_files/mi_red_wifi.txt /boot/
	cp ~/tjbot_setup/config_files/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.default.conf
}

installResources
enableSSH
configureHardware
updateNode
installTJNodes
configureNodeRedService
enableAddWiFiFromBoot
# Enable to speak IP address using crontab using pi user
su pi -c "(crontab -l 2>/dev/null; echo '@reboot ~/tjbot_setup/config_files/getipaddress.sh') | crontab -"

reboot now
