#!/bin/bash

##################################
##### Colors Output ##############

RESET="\e[0m"
GRAY="\e[1;30m"
RED="\e[1;31m"
GREEN="\e[1;32m"
YELLOW="\e[1;33m"
BLUE="\e[1;34m"
PURPLE="\e[1;35m"
CYAN="\e[1;36m"
WHITE="\r[1;37m"

#################################### Functions ########################

banner () {
echo -e "${RED} _   _ _   _ _   _ _____ _____ ____  ${RESET}"
echo -e "${RED}| | | | | | | \ | |_   _| ____|  _ \ ${RESET}"
echo -e "${RED}| |_| | | | |  \| | | | |  _| | |_) |${RESET}"
echo -e "${RED}|  _  | |_| | |\  | | | | |___|  _ < ${RESET}"
echo -e "${RED}|_| |_|\___/|_| \_| |_| |_____|_| \_\ ${RESET}"
echo -e "${GREEN}	Created by: Dxz ${RESET}"
}

divider () {
	echo
	echo -e "${PURPLE}================================${RESET}"
	echo
}

help () {
	clear
	banner
	echo -e "USAGE:$0 [DOMAIN...] [OPTIONS...]"
	echo -e "\t-h, --help		Help menu "
	echo -e "\t-hx, --httpx		Get live domains"
	echo -e "\t-u, --urls		Get all the urls"
	echo -e "\t-p, --parameter		Get parameters"
	echo -e "\t-w, --wayback		Get wayback data"
	echo -e "\t--whois			Get Whoisdata"
	echo -e "\t-ps, --portscan"
	echo
}

############################### Variables ###############################

# Variable para el dominio que ingresaremos
DOMAIN=$1

# Si el usuario no ingresa nada ejecutamos el help y salimos
if [ $# -eq 0 ] || [ $# -eq 1 ]
then
	help
	exit 1
fi

# Si la carpeta con el nombre del dominio no se encuentra creada, la creamos
if ! [ -d "$DOMAIN" ]
then
	mkdir $DOMAIN
	cd $DOMAIN
else
	echo -e "${RED}Directory already exists....Exiting....${RESET}"
	exit 2
fi


############################## Script ###################################
# Imprimimos banner
banner
# Imprimimos el divisor
divider
# Comenzamos el escaneo con las herramientas subfinder y assetfinder
echo -e "[-] Gathering sub-domains form internet...."
subfinder -silent -d $DOMAIN >> sub_domains.txt
assetfinder $DOMAIN >> sub_domains.txt

# Quitamos los subdominios duplicados
VALID_DOMAINS=`cat sub_domains.txt | sort -u`


# Almacenamos los dominios validos en un nuevo archivo sub-domains.txt y borramos los anteriores
echo
echo $VALID_DOMAINS | tr ' ' '\n' | grep $DOMAIN | tee sub-domains.txt
echo
echo -e "[+]Subdomain gathering completed..."
rm sub_domains.txt


################################ Case ##################################

while [ $# -gt 0 ]
do
	case "$2" in
		"-h" | --help )
			help
			exit 4
			;;

		"-hx" | "--httpx" )
			echo -e "${BLUE}[-]Runnin httpx...${RESET}"
			cat sub-domains.txt | httpx | tee live_domain.txt
			echo -e "${GREEN}[+]Live sub-domains gathered...${RESET}"
			divider
			shift
			shift 
			;;

		"-u" | "--url")
			echo -e "${BLUE}[-]Gathering url from gau...${RESET}"
			gau $DOMAIN | tee urls.txt
			echo -e "${GREEN}[+]URLS gatherd...${RESET}"
			divider
			shift
			shift
			;;

		"-p" | "-prameter" )
			echo -e "${BLUE}[-]Gathering parameters uding paramspider...${RESET}"
			paramspider -d $DOMAIN | tee parameter.txt
			echo -e "${GREEN}[+]Parameters gathered...${RESET}"

			shift

			shift
			;;

		"-w" | "--wayback" )
			echo -e "${BLUE}[-]Gathering waybackurl data${RESET}"
			waybackurls $DOMAIN | tee waybackurl.txt
			echo -e "${GREEN}[+]Waybackurls gathered...${RESET}"

			shift
			shift
			;;

		"--whois" )
			echo -e "${BLUE}[-]Gathering whois from whois.com...${RESET}"

			curl -s https://www.whois.com/whois/$DOMAIN | grep -A 70 "Registry Domain ID:" | tee whois.txt
			echo -e "${GREEN}[+]Whoisdata gathered...${RESET}"

			shift
			;;

		"-ps" | "--portscan" )
			echo -e "${BLUE}[-]Scanning for open ports...${RESET}"
			naabu -silent -host $DOMAIN | tee openport.txt
			echo -e "${GREEN}[+]Scanning completed...${RESET}"

			shift
			shift
			;;
		"*" )
			help
			;;
	esac
done

#########################################################################
divider
echo -e "${BLUE}RECON COMPLETED ...${RESET}"
divider
































