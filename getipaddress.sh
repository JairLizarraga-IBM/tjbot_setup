#!/bin/bash
ROUTE="/home/pi/ipaddress.txt"
BOOT_WPA="/boot/mi_red_wifi.txt"
WPA_SUPPLICANT="/etc/wpa_supplicant/wpa_supplicant.conf"
IP="$(ifconfig wlan0 | grep 'inet ' | cut -d: -f2 | awk '{print $2}')"
MESSAGE="Tu direcciòn I PE es"
VOLUME=30
SPEED=175
PINCH=35
PAUSA=10
ENFASIS=20
LENGUAJE=es-la+f3

# Busca si existe una nueva red agregada manualmente por el usuario
NEWSSID="$(grep 'ssid' /boot/mi_red_wifi.txt)"
if [ ${#NEWSSID} -gt 15 ]
then
	cat $BOOT_WPA >> $WPA_SUPPLICANT
	cp /boot/mi_red_wifi.default.txt /boot/mi_red_wifi.txt
        espeak "Nueva configuración wai fai detectada. Reiniciando." -k $ENFASIS -a $VOLUME  -p $PINCH -g $PAUSA -v $LENGUAJE
	sudo reboot
fi

# Se vacia la direccion IP en archivo, para modificar su texto y poder hablarlo
> $ROUTE
echo $IP > $ROUTE
sed -i 's/\./ punto /g' $ROUTE
if [ ${#IP} -gt 0 ]
then
        SSID="$(iwgetid -r)"
        espeak "Te has conectado a $SSID" -k $ENFASIS -a $VOLUME  -p $PINCH -g $PAUSA -v $LENGUAJE
	espeak "$MESSAGE" -k $ENFASIS -a $VOLUME  -p $PINCH -g $PAUSA -v $LENGUAJE
        espeak -f $ROUTE  -k $ENFASIS -a $VOLUME  -p $PINCH -g $PAUSA -v $LENGUAJE
	ping www.google.com -c 1
	if [ "$?" -gt 0 ]
	then
		espeak "Conexiòn a internet fallida" -k $ENFASIS -a $VOLUME  -p $PINCH -g $PAUSA -v $LENGUAJE
	else
		espeak "Conexiòn a internet establecida" -k $ENFASIS -a $VOLUME  -p $PINCH -g $PAUSA -v $LENGUAJE
		nc -z -v -w5 127.0.0.1 1880
		if [ "$?" -eq 0 ]
		then
        		espeak "Servidor iniciado" -k $ENFASIS -a $VOLUME  -p $PINCH -g $PAUSA -v $LENGUAJE
		fi
	fi
else
	espeak "Error en la conexiòn a internet" -k $ENFASIS -a $VOLUME  -p $PINCH -g $PAUSA -v $LENGUAJE
fi
