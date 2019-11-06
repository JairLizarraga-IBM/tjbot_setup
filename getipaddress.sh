#!/bin/bash
MI_RED_WIFI="/boot/mi_red_wifi.txt"
WPA_SUPPLICANT="/etc/wpa_supplicant/wpa_supplicant.conf"

# Parametros para voz espeak
VOLUME=200 # -a
SPEED=160 # -s
PITCH=60 # -p
PAUSA=10 # -g
ENFASIS=20 # -k
LENGUAJE=es+m3 # -v
 
TIEMPO_DE_COMPROBACION=5
# Estatus de la conexion actual: Se pone en cero para definir que no hay conexion inicial
CONEXION_ACTIVA=0

# Busca si existe una nueva red agregada manualmente por el usuario
check_is_new_network_added(){
	NEWSSID="$(grep 'ssid' $MI_RED_WIFI)"
	if [ ${#NEWSSID} -gt 15 ]
	then
	    sudo bash -c "cat /boot/mi_red_wifi.txt >> /etc/wpa_supplicant/wpa_supplicant.conf"
	    sudo cp /boot/mi_red_wifi.default.txt /boot/mi_red_wifi.txt
	    espeak "Guardando red, reiniciando. Guardando red, reiniciando." -k $ENFASIS -a $VOLUME  -p $PITCH -g $PAUSA -v $LENGUAJE -s $SPEED
		sudo reboot

	# Si el usuario ha introducido mal una red y a causa de eso se ha perdido conectividad remota, el usuario
	# debera escribir en el archivo /boot/mi_red_wifi.txt la palabra restart, sin espacios y en el primer renglon.
	# Esto limpiara las redes recordadas, y podra volver a agregar redes por medio de la tarjeta SD.
	elif [ "$(head -n 1 $MI_RED_WIFI)" = "restart" ]; then
		espeak "Reiniciando redes. Reiniciando redes." -k $ENFASIS -a $VOLUME  -p $PITCH -g $PAUSA -v $LENGUAJE -s $SPEED
		cp /etc/wpa_supplicant/wpa_supplicant.default.conf /etc/wpa_supplicant/wpa_supplicant.conf
		cp /boot/mi_red_wifi.default.txt /boot/mi_red_wifi.txt
		sudo reboot
	fi
}

# Comprobacion de tipo de conexion: Alambrica o Inalambrica
check_connection_type(){
	# Si la red ethernet esta arriba, anunciar red
	if [[ $(cat /sys/class/net/eth0/operstate) = "up" ]];
	then
		RESULTADO=$RESULTADO"Conexion alambrica"
	else
		RESULTADO=$RESULTADO"Red $(sudo iwgetid -r)"
	fi
}

# Ping a google.com para comprobar conectividad a internet.
check_connectivity(){
	RESULTADO=$RESULTADO". Direccion I PE, $IP, direccion I PE, $IP"
	ping www.google.com -c 1
	if [ "$?" -gt 0 ];
	then
		RESULTADO=$RESULTADO". Error conectando a internet."
		CONEXION_ACTIVA=0
	else
		RESULTADO=$RESULTADO". Conexion a internet establecida."
		CONEXION_ACTIVA=1
	fi
}

# Comprobacion si el puerto de Node-RED esta funcionando
check_server(){
	nc -z -v -w5 127.0.0.1 1880
	if [ "$?" -eq 0 ];
	then
		RESULTADO=$RESULTADO". Servidor iniciado."
		CONEXION_ACTIVA=1
	else
		RESULTADO=$RESULTADO". Error de servidor node red."
		CONEXION_ACTIVA=0
	fi

}

# Loop que comprueba cada
network_status_loop(){
	while true; do
		IP=$(hostname -I | sed -r 's/\./ punto /g')
		RESULTADO=""

		#Si la conexion no esta activa, comprobar conectividad
		if [ $CONEXION_ACTIVA -eq 0 ]; then
			# Si tenemos IP, anunciar
			if [ ! -z "$IP" ]; then 
					check_connection_type
					check_connectivity	
					check_server
			else
			# Si no tenemos IP, error
				RESULTADO=$RESULTADO". Buscando red."
				CONEXION_ACTIVA=0
			fi
			# Anunciar resultados
			echo "$RESULTADO"
			espeak "$RESULTADO" -k $ENFASIS -a $VOLUME  -p $PITCH -g $PAUSA -v $LENGUAJE -s $SPEED
		fi
		check_connectivity
		sleep $TIEMPO_DE_COMPROBACION
	done
}


check_is_new_network_added
network_status_loop
