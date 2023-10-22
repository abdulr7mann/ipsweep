#!/bin/bash

# Color codes for colored output
BLUE='\e[1;34m'
RED='\e[1;91m'
GREEN='\e[32m'
BOLD='\e[1m'
RESET='\e[0m'

# Validates if the provided IP is valid
valid_ip() {
    local ip=$1
    local stat=1

    # Check if the IP format is correct
    if [[ $ip =~ ^[0-9]{1,3}(\.[0-9]{1,3}){2}$ ]]; then
        # Split IP into an array and check if each octet is less than or equal to 255
        IFS='.' read -r -a ip_segments <<< "$ip"
        [[ ${ip_segments[0]} -le 255 && ${ip_segments[1]} -le 255 && ${ip_segments[2]} -le 255 ]]
        stat=$?
    fi

    return $stat
}

# Main function to execute the script
main() {
    local script_name=$(basename "$0")

    # Check if the script is run as root
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}Please run as root.${RESET}\nExample: sudo ./${script_name} 10.10.10"
        exit 1
    fi

    # If an IP is provided, validate it
    if [ "$1" ]; then
        if ! valid_ip "$1"; then
            echo -e "${RED}Invalid IP: $1${RESET}\nUsage: ./${script_name} [first three octets of IP]\nExample: ./${script_name} 192.168.1"
            exit 1
        fi
    fi

    local base_ip=${1:-$(hostname -I | cut -d'.' -f1-3)}
    local interface=$(ifconfig | grep -v 'lo' | cut -d':' -f1 | head -n1)
    
    > iplist.txt

    for ip in $(seq 1 254); do
        (
            if ping -c 1 ${base_ip}.${ip} &> /dev/null; then
                ttl=$(ping -c 1 ${base_ip}.${ip} | grep 'ttl=' | grep -oP 'ttl=\K[^ ]+')
                
                case $ttl in
                    64) os="Linux" ;;
                    128) os="Windows" ;;
                    255|256|254) os="OpenBSD/Cisco/Oracle" ;;
                    *) os="Unknown OS" ;;
                esac

                echo "${base_ip}.${ip} ${os}" >> iplist.txt
            fi
        ) &
    done
    
    wait

    # Print out the results in a cleaner format
    cat iplist.txt | while read -r ip os; do
        case $os in
            Linux) echo -e "${BOLD}${ip}${RESET} ${GREEN}live${RESET} ${RED}Linux${RESET}" ;;
            Windows) echo -e "${BOLD}${ip}${RESET} ${GREEN}live${RESET} ${BLUE}Windows${RESET}" ;;
            OpenBSD/Cisco/Oracle) echo -e "${BOLD}${ip}${RESET} ${GREEN}live${RESET} ${RED}OpenBSD/Cisco/Oracle${RESET}" ;;
            *) echo -e "${BOLD}${ip}${RESET} ${GREEN}live${RESET} ${BLUE}Unknown OS${RESET}" ;;
        esac
    done

    echo 'Output -> iplist.txt'
}

# Execute the main function with all arguments passed
main "$@"
