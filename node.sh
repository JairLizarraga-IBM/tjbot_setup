 curl -sL https://raw.githubusercontent.com/JairLizarragaV/TJBot/master/bootstrap.sh | sudo sh -

1.-
	bash <(curl -sL https://raw.githubusercontent.com/node-red/raspbian-deb-package/master/resources/update-nodejs-and-nodered)
	reiniciar

2.-
	Change password to ibmtjbot
	sudo apt-get update
	sudo apt-get install espeak

	node-red-stop
	cd .node-red
	mkdir nodes
	cd nodes
	git clone https://github.com/jeancarl/node-red-contrib-tjbot
	cd node-red-contrib-tjbot
	npm install

	sudo nano /lib/systemd/system/nodered.service
	User=pi -> User=root
	ctrl+x 
	y
	sudo systemctl daemon-reload
	node-red-start

3.-
	cerrar ventana y abrir otra
	node-red-stop
	sudo nano /root/.node-red/settings.js
	replace 
		//userDir: ‘/home/nol/.node-red/nodes’ ,   userDir: ‘/home/pi/.node-red/’ , 
		//nodesDir: ‘/home/nol/.node-red/nodes’ ,  nodesDir:‘home/pi/.node-red/nodes’ , 

	 sed -i -e "s/\/\/userDir: ‘\/home\/nol\/.node-red\/nodes’ ,/userDir: ‘\/home\/pi\/.node-red\/’ ,/g" /root/.node-red/settings.js
	 sudo sed -i -e "s/\/\/nodesDir: ‘\/home\/nol\/.node-red\/nodes’ ,/nodesDir: ‘\/home\/pi\/.node-red\/nodes’ ,/g" /root/.node-red/settings.js

	 sed -i -e "s/start_x=0/start_x=1/g" /boot/config.txt

	ctrl+x
	y
	node-red-start
	ACCEDER A NODERED

4.-
	sudo raspi-config
	quinta opcion habilitar camara
	septima opcion y auto 0
	reiniciar

