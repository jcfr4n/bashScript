#!/bin/bash

#Colours #####################

greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m" 

#Global vars #####################

main_url="https://htbmachines.github.io/bundle.js"

# Functions #####################

function ctrl_c(){
	echo -e "\n\n[!] Saliendo...\n\n"
	tput cnorm && exit 1
}

trap ctrl_c INT

function helpPanel(){
	echo -e "\n$greenColour[+]$endColour ${grayColour}Uso:$endColour"
	echo -e "\t$purpleColour-u$endColour ${grayColour}Descargar o actualizar archivos$endColour"
	echo -e "\t$purpleColour-m$endColour ${grayColour}Buscar por nombre de máquina$endColour"
	echo -e "\t$purpleColour-i$endColour ${grayColour}Buscar por IP$endColour"
	echo -e "\t$purpleColour-y$endColour ${grayColour}Buscar link de youtube con solución$endColour"
	echo -e "\t$purpleColour-d$endColour ${grayColour}Buscar por dificultad$endColour"
	echo -e "\t$purpleColour-o$endColour ${grayColour}Buscar por sistema operativo$endColour"
	echo -e "\t$purpleColour-s$endColour ${grayColour}Buscar por skill$endColour"
	echo -e "\t$purpleColour-h$endColour ${grayColour}Mostrar este panel de ayuda$endColour\n"
}

function updateFiles(){
    echo -e "\n\n$purpleColour[+]${endColour} ${grayColour}Comenzando con la actualización${endColour}\n\n"
	tput civis
	if [ ! -f bundle.js ]; then
    	echo -e "\n\n$purpleColour[+]${endColour} ${grayColour}Descargando los archivos necesarios...${endColour}\n\n"
		curl -s $main_url >bundle.js
		js-beautify bundle.js | sponge bundle.js 
    	echo -e "\n\n$purpleColour[+]${endColour} ${grayColour}Todos los archivos descargados...${endColour}\n\n"
		sleep 1 
	else
		curl -s $main_url >bundle_temp.js
		js-beautify bundle_temp.js | sponge bundle_temp.js
		md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}')
		md5_original_value=$(md5sum bundle.js | awk '{print $1}')
		sleep 1
		if [ "$md5_temp_value" == "$md5_original_value" ]; then
			echo -e "\n\n$purpleColour[+]$endColour ${grayColour}No hay actualizaciones...\n\n${endColour}"
			rm bundle_temp.js
		else
			echo -e "\n\n$purpleColour[+]$endColour ${grayColour}Actualizaciones listas...\n\n${endColour}"
			rm bundle.js && mv bundle_temp.js bundle.js
		fi
	fi

	tput cnorm
}

function searchIp(){
    ipAddress="$1"
    machineName="$(cat bundle.js | grep "ip: \"${ipAddress}\"" -B 3 | grep 'name: ' | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')"

	if [ "$machineName" ]; then
		echo -e "\n\n${purpleColour}[+] ${endColour} ${grayColour}La máquina con la Ip:${endColour} ${blueColour}${ipAddress}${endColour} ${grayColour}es${endColour} ${purpleColour}${machineName}${endColour}\n\n"
		searchMachine $machineName
	else
		echo -e "\n\n${purpleColour}[!] ${endColour} ${grayColour}La Ip:${endColour} ${blueColour}    ${ipAddress}${endColour} ${grayColour} no existe en mi base de datos${endColour} ${purpleColour}${endColour}\n\n"
	fi

}

function searchMachine(){
	machineName="$1"

	resultChecker=$(cat bundle.js | awk "/name: \"${machineName}\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//')

	if [ "$resultChecker" ]; then
		echo -e "\n\n${purpleColour}[+] ${endColour} ${grayColour}Mostrando la máquina: ${endColour}\n\n${machineName}"
		cat bundle.js | awk "/name: \"${machineName}\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//'

	else
		echo -e "\n\n${purpleColour}[!] ${endColour} ${grayColour}La máquina: ${endColour}${machineName} ${grayColour} no existe en mi base de datos ${endColour}"

	fi

}

function searchYoutube(){
	machineName="$1"

	echo -e "\n\n${purpleColour}[+] ${endColour} ${grayColour}Mostrando el link para la solución de la máquina: ${endColour} ${machineName}\n\n"
	searchMachine $machineName | grep "youtube: " | awk 'NF{print $NF}'
}

function searchDifficulty(){
	difficulty="$1"

	echo -e "\n\n${purpleColour}[+] ${endColour} ${grayColour}Listado de máquinas con dificultad: $difficulty ${endColour}\n\n"
	cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep "name" | tr -d '"' | tr -d "," | awk 'NF{print$NF}' | column
}

function searchByOS(){
	os="$1"

	echo -e "\n\n${purpleColour}[+] ${endColour} ${grayColour}Listado de máquinas con Sistema Operativo: $os  ${endColour}\n\n"
	cat bundle.js | grep "so: \"$os\"" -B 4 | grep "name" | tr -d '"' | tr -d "," | awk 'NF{print$NF}' | column
}

function searchByOsDifficulty(){
	os="$1"
	difficulty="$2"
	validateData=$(cat bundle.js | grep "dificultad: \"${difficulty}\"" -B 5 | grep "so: \"${os}\"" -B 4 | grep "name:" | tr -d "\"" | tr -d "," | awk 'NF{print$NF}')
	if [ "$validateData" ]; then
		echo -e "\n\n${purpleColour}[+] ${endColour} ${grayColour}Listado de máquinas con Sistema Operativo: $os y Dificultad: ${difficulty} ${endColour}\n\n"
		cat bundle.js | grep "dificultad: \"${difficulty}\"" -B 5 | grep "so: \"${os}\"" -B 4 | grep "name:" | tr -d "\"" | tr -d "," | awk 'NF{print$NF}'
	else
		echo -e "\n\n${purpleColour}[+] ${endColour} ${grayColour}No existen máquinas con Sistema Operativo: $os y Dificultad: ${difficulty} ${endColour}\n\n"
	fi
}

function searchBySkills(){
    skills="$1"
    validateSkill=$(cat bundle.js | grep "skills:" -B 6 | grep "${skills}" -i -B 6 | grep "name: " | awk 'NF{print$NF}' | tr -d "\"" | tr -d "," | column)
    if [ "$validateSkill" ]; then
		echo -e "\n\n${purpleColour}[+] ${endColour} ${grayColour}Listado de máquinas con estas habilidades: ${skills}\n\n"
    	cat bundle.js | grep "skills:" -B 6 | grep "${skills}" -i -B 6 | grep "name: " | awk 'NF{print$NF}' | tr -d "\"" | tr -d "," | column
	else
		echo -e "\n\n${purpleColour}[+] ${endColour} ${grayColour}No se han encontrado máquinas con estas habilidades\n\n"
	fi
    
}

# Indicadores #####################

declare -i parameter_counter=0
declare -i chivatoDifficulty=0
declare -i chivatoOs=0

# echo "^l"

while getopts "m:uhi:y:d:o:s:" arg; do
	case $arg in
		m) machineName=$OPTARG; let parameter_counter+=1;;
		u) let parameter_counter+=2;; 
		i) ipAddress=$OPTARG; let parameter_counter+=3;;
		y) machineName=$OPTARG; let parameter_counter+=4;;
		d) difficulty=$OPTARG; let chivatoDifficulty+=1; let parameter_counter+=5;;
		o) os=$OPTARG; let chivatoOs+=1; let parameter_counter+=6;;
		s) skills="$OPTARG"; let parameter_counter+=7;;
		h) ;;
	esac
done

if [ $parameter_counter -eq 1 ]; then
	searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
	updateFiles
elif [ $parameter_counter -eq 3 ]; then
	searchIp $ipAddress
elif [ $parameter_counter -eq 4 ]; then
	searchYoutube $machineName
elif [ $parameter_counter -eq 5 ]; then
	searchDifficulty $difficulty
elif [ $parameter_counter -eq 6 ]; then
	searchByOS $os
elif [ $parameter_counter -eq 7 ]; then
	searchBySkills "$skills"
elif [ $chivatoDifficulty -eq 1 ] && [ $chivatoOs -eq 1 ]; then
	echo -e "hola $chivatoDifficulty y $chivatoOs $parameter_counter"
	#searchByOsDifficulty $os $difficulty
else
	helpPanel
fi
