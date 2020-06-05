#! /bin/bash

#Variables
####################################################################################################

#Escribe en estas variables tu ID y TOKEN de Telegram...
TOKEN="1111111111:AAAAAAAAAAAAAA-AAA_AAAAAAAAAAAAAAAA"
ID="111111111"

#Especifica el límite de uso y temperatura para recibir tu alarma:
	
	#Especifica el porcentaje límite de uso de la CPU:
	CPU_USO_LIMITE=85
	
	#Especifica la temperatura límite de CPU (Celsius):
	CPU_TEMP_LIMITE=55
	
	#Especifica el porcentaje límite de uso de la RAM:
	RAM_USO_LIMITE=85

#Obtiene porcentaje de uso de nuestra CPU
	CPU_USO=$(top -bn1 | awk '/Cpu/ { cpu =  100 - $8  }; END { print cpu }')

#Obtiene temperatura de nuestra CPU
	CPU_TEMP=$(vcgencmd measure_temp|cut -c 6-7)
	CPU_TEMP_COMPLETA=$(vcgencmd measure_temp|cut -c 6-11)

#Obtiene porcentaje de uso de la  RAM
	RAM_USO=$(free | grep Mem | awk '{print $3/$2 * 100.0}' | cut -c 1)

#Obtiene las IP de los equipos que tienen una conexión mediante SSH
	#SSH_CONEXIONES=$(ss | grep ssh | wc -l)
	SSH_IP_CONEXION=$(pinky | sed -e 's/\s/#/g' | cut -d"#" -f42 | sed '/^ *$/d')


#Condiciones y envío de alarma
####################################################################################################

if [ $CPU_USO -ge $CPU_USO_LIMITE -o $CPU_TEMP -ge $CPU_TEMP_LIMITE -o $RAM_USO -ge $RAM_USO_LIMITE -o -n "${SSH_IP_CONEXION[@]}"  ] 
then
echo "Enviando alarma ..."
MENSAJE=""
MENSAJE+="RASPBERRY NOTIFICACIÓN!!: %0A %0A"

	if [ $CPU_TEMP -ge $CPU_TEMP_LIMITE ]
	then
	MENSAJE+="- Temperatura de la CPU: $CPU_TEMP_COMPLETA %0A"
	fi

	if [ $CPU_USO -ge $CPU_USO_LIMITE ]
	then
	MENSAJE+="- Uso de CPU: $CPU_USO% %0A"
	fi

	if [ $RAM_USO -ge $RAM_USO_LIMITE ]
	then
	MENSAJE+="- Uso de la RAM: $RAM_USO% %0A"
	fi

	if [ -n "${SSH_IP_CONEXION[@]}" ]
	then
		MENSAJE+="- Conexion SSH abierta vía: %0A"

		for IP in ${SSH_IP_CONEXION[@]}
		do
			MENSAJE+="    $IP %0A" 
		done
	fi

	#Enviar alarma
	URL="https://api.telegram.org/bot$TOKEN/sendMessage"
	curl -s -X POST $URL -d chat_id=$ID -d text="${MENSAJE}"
fi
