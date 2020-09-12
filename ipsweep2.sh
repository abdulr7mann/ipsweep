#!/bin/bash
RED='\e[1;91m'
GREEN='\e[32m'
resetStyle='\e[0m'
for ip in {1..254}
do
	results=$(ping -c 1 $1.$ip|grep ttl)
	live=$(echo $results |cut -d' ' -f1)
	os=$(echo $results |grep -oP 'ttl=\K[^ ]+')
	if [ ! -z "$live" ] && ( [ "$os" = "30" ] || [ "$os" = "60" ] || [ "$os" = "64" ] )
	then
		echo -e "${BOLD}${1}.${ip}${resetStyle} ${GREEN}live${resetStyle} ${RED}Linux${resetStyle}"
	elif [ ! -z "$live" ] && ( [ "$os" = "128" ] || [ "$os" = "127" ] )
	then
		echo -e "${BOLD}${1}.${ip}${resetStyle} ${GREEN}live${resetStyle} ${RED}Windows${resetStyle}"
	elif [ ! -z "$live" ] && ( [ "${os}" = "256" ] || [ "${os}" = "255" ] || [ "${os}" = "254" ] )
	then
	      echo -e "${BOLD}${1}.${ip}${resetStyle} ${GREEN}live${resetStyle} ${RED}OpenBSD/Cisco/Oracle${resetStyle}"
	elif [ ! -z "$live" ]
	then
		echo -e "${BOLD}${1}.${ip}${resetStyle} ${GREEN}live${resetStyle} Unknown"
	fi
done
# Abdulrahman
