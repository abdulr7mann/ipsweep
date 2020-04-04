#!/bin/bash
BLUE='\e[1;34m'
RED='\e[1;91m'
GREEN='\e[32m'
BOLD='\e[1m'
resetStyle='\e[0m'
scriptName=$(basename "$0")
function valid_ip()
{
    local  ips=$1
    local  stat=1

    if [[ ${ips} =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ips=(${ips})
        IFS=$OIFS
        [[ ${ips[0]} -le 255 && ${ips[1]} -le 255 \
            && ${ips[2]} -le 255 && ${ips[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}
if [ "${1}" != "" ]
then
    if valid_ip ${1}
    then
        stat='good'
    else
        echo -e "Invalid IP: ${1} \nusage: run without an argument or with first three octets.\n./${scriptName} 10.10.10\n./${scriptName} 192.168.1"
        exit
    fi
fi
if [ -f iplist.txt ]
then
	rm iplist.txt >/dev/null
fi
if [ "$EUID" -ne 0 ]
then
	echo -e "Please run as root\nsudo ./${scriptName} 10.10.10"
	exit
fi
i="$(hostname -I|cut -d'.' -f1-3)"
interface="$(ifconfig | grep -v 'lo' | grep ': '|sed 'q1' |cut -d':' -f1)"
for ip in {1..254}
do
	if [ "${1}" = "" ]
	then
		ping -c 1 $i.${ip} > ping${ip}.txt && cat ping${ip}.txt|grep -oP 'ttl=\K[^ ]+' >> os.txt && cat ping${ip}.txt|grep "64 bytes" | cut -d " " -f 4 | tr -d ":" >> ip.txt &
		arping -I ${interface} -c 1 $i.${ip} |grep -oP 'y from \K[^ ]+' >> arping.txt &
	elif [ "${1}" != "" ]
	then
		ping -c 1 $1.${ip} > ping${ip}.txt && cat ping${ip}.txt|grep -oP 'ttl=\K[^ ]+' >> os.txt && cat ping${ip}.txt|grep "64 bytes" | cut -d " " -f 4 | tr -d ":" >> ip.txt &
		arping -I ${interface} -c 1 $i.${ip} |grep -oP 'y from \K[^ ]+' >> arping.txt &
	fi
done
wait
while read os <&4 && read ip <&3
do
	if [ "${1}" = "" ]
	then
		if [ "${os}" = "64" ]
		then
			echo "${ip}" >> iplist.txt
			echo -e "${BOLD}${ip}${resetStyle} ${GREEN}live${resetStyle} ${RED}Linux${resetStyle}"
		elif [ "${os}" = "128" ]
		then
			echo "${ip}" >> iplist.txt
			echo -e "${BOLD}${ip}${resetStyle} ${GREEN}live${resetStyle} ${BLUE}Window${resetStyle}"
		fi
	elif [ "${1}" != "" ]
	then
		if [ "${os}" = "64" ]
		then
			echo "${ip}" >> iplist.txt
			echo -e "${BOLD}${ip}${resetStyle} ${GREEN}live${resetStyle} ${RED}Linux${resetStyle}"
		elif [ "${os}" = "128" ]
		then
			echo "${ip}" >> iplist.txt
			echo -e "${BOLD}${ip}${resetStyle} ${GREEN}live${resetStyle} ${BLUE}Window${resetStyle}"
		elif [ "${os}" = "256" ] || [ "${os}" = "255" ] || [ "${os}" = "254" ]
		then
			echo "${ip}" >> iplist.txt
			echo -e "${BOLD}${ip}${resetStyle} ${GREEN}live${resetStyle} ${RED}OpenBSD/Cisco/Oracle${resetStyle}"
		fi
	fi
done 4<os.txt 3<ip.txt
grep -vf iplist.txt arping.txt > a.txt
while read arp
do
	echo "${arp}" >> iplist.txt
	echo -e "${BOLD}${arp}${resetStyle} ${GREEN}alive${resetStyle}"
done <a.txt
chmod 666 iplist.txt
echo 'Output -> iplist.txt'
rm os.txt >/dev/null
rm ping*.txt >/dev/null
rm arping*.txt >/dev/null
rm ip.txt >/dev/null
rm a.txt >/dev/null
