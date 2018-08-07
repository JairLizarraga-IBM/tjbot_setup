#!/bin/bash
BOOT_WPA="/boot/mi_red_wifi.txt"
WPA_SUPPLICANT="/etc/wpa_supplicant/wpa_supplicant.conf"
IP=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | sed -r 's/\./ punto /g')

### Voice parameters ###
VOLUME=30
SPEED=200
PINCH=50
PAUSA=15
ENFASIS=30
LENGUAJE=es+m5

# Busca si existe una nueva red agregada manualmente por el usuario
NEWSSID="$(grep 'ssid' /boot/mi_red_wifi.txt)"
if [ ${#NEWSSID} -gt 15 ];
then
	cat $BOOT_WPA >> $WPA_SUPPLICANT
	cp /boot/mi_red_wifi.default.txt /boot/mi_red_wifi.txt
        espeak "Nueva configuración wai fai detectada. Reiniciando." -k $ENFASIS -a $VOLUME  -p $PINCH -g $PAUSA -v $LENGUAJE -s $SPEED
	sudo reboot
fi

# Se vacia la direccion IP en archivo, para modificar su texto y poder hablarlo
if [ ! -z "$IP" ];
then
	if [[ $(cat /sys/class/net/eth0/operstate) = "up" ]];
	then
		 espeak "Iniciando con conexion alambrica" -k $ENFASIS -a $VOLUME  -p $PINCH -g $PAUSA -v $LENGUAJE -s $SPEED
	else
        	espeak "Conexion wai fai a la red $(iwgetid -r)" -k $ENFASIS -a $VOLUME  -p $PINCH -g $PAUSA -v $LENGUAJE -s $SPEED
	fi
	espeak "Tu direccion I PE es... $IP, tu direccion I PE es... $IP" -k $ENFASIS -a $VOLUME  -p $PINCH -g $PAUSA -v $LENGUAJE -s $SPEED
	ping www.google.com -c 1
	if [ "$?" -gt 0 ];
	then
		espeak "Conexiòn a internet fallida" -k $ENFASIS -a $VOLUME  -p $PINCH -g $PAUSA -v $LENGUAJE -s $SPEED
	else
		espeak "Conexiòn a internet establecida" -k $ENFASIS -a $VOLUME  -p $PINCH -g $PAUSA -v $LENGUAJE -s $SPEED
		nc -z -v -w5 127.0.0.1 1880
		if [ "$?" -eq 0 ];
		then
        		espeak "Servidor iniciado" -k $ENFASIS -a $VOLUME  -p $PINCH -g $PAUSA -v $LENGUAJE -s $SPEED
		fi
	fi
else
	espeak "Error en la conexiòn a internet" -k $ENFASIS -a $VOLUME  -p $PINCH -g $PAUSA -v $LENGUAJE -s $SPEED
fi
