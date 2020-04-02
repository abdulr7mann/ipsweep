#!/bin/bash
RED='\e[1;91m'
GREEN='\e[32m'
BOLD='\e[1m'
resetStyle='\e[0m'
scriptName=$(basename "$0")
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
			echo "${i}.${ip}" >> ipSweepOutput.txt
			echo -e "${BOLD}$1.${ip}${resetStyle} is ${RED}Linux${resetStyle} & ${GREEN}live${resetStyle}"
		elif [ "${os}" = "ttl=128" ]
		then
			echo "${i}.${ip}" >> ipSweepOutput.txt
			echo "${BOLD}$1.${ip}${resetStyle} is ${BLUE}Window${resetStyle} & ${GREEN}live${resetStyle}"
		fi
	fi
done
if [ -f ipSweepOutput.txt ]
then
	echo 'Output -> ipSweepOutput.txt'
fi