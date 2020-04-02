#!/bin/bash
# By @abdulr7man
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
        echo -e "Invalid IP: ${1} \nusage: run without an argument or with first three octets.\n${scriptName} 10.10.10\n${scriptName} 192.168.1"
        exit
    fi
fi
if [ -f ipSweepOutput.txt ]
then
	rm ipSweepOutput.txt >/dev/null
fi
for ip in {1..254}
do
	if [ "${1}" = "" ]
	then
		i="$(ifconfig | grep "inet "|sed 'q1'|cut -d' ' -f10|cut -d'.' -f1-3)"
		os="$(ping -c 1 ${i}.${ip} | grep -e 'ttl=64'|cut -d ' ' -f6)"
		if [ "${os}" = "ttl=64" ]
		then
			echo "${i}.${ip}" >> ipSweepOutput.txt
			echo -e "${BOLD}${i}.${ip}${resetStyle} is ${RED}Linux${resetStyle} & ${GREEN}live${resetStyle}"
		elif [ "${os}" = "ttl=128" ]
		then
			echo "${i}.${ip}" >> ipSweepOutput.txt
			echo "${BOLD}${i}.${ip}${resetStyle} is ${BLUE}Window${resetStyle} & ${GREEN}live${resetStyle}"
		fi
	elif [ "${1}" != "" ]
	then
		os="$(ping -c 1 $1.${ip} | grep -e 'ttl=64'|cut -d ' ' -f6)"
		if [ "${os}" = "ttl=64" ]
		then
			echo "${1}.${ip}" >> ipSweepOutput.txt
			echo -e "${BOLD}$1.${ip}${resetStyle} is ${RED}Linux${resetStyle} & ${GREEN}live${resetStyle}"
		elif [ "${os}" = "ttl=128" ]
		then
			echo "${1}.${ip}" >> ipSweepOutput.txt
			echo "${BOLD}$1.${ip}${resetStyle} is ${BLUE}Window${resetStyle} & ${GREEN}live${resetStyle}"
		fi
	fi
done
if [ -f ipSweepOutput.txt ]
then
	echo 'Output -> ipSweepOutput.txt'
fi
