#!/bin/bash

# Color codes for colored output
RED='\e[1;91m'
GREEN='\e[32m'
BOLD='\e[1m'
RESET='\e[0m'

# Validates the IP prefix
validate_ip_prefix() {
    if [[ ! $1 =~ ^[0-9]{1,3}(\.[0-9]{1,3}){2}$ ]]; then
        echo -e "${RED}Invalid IP prefix.${RESET}"
        echo "Usage: $0 [IP_PREFIX]"
        echo "Example: $0 192.168.1"
        exit 1
    fi
}

# Main function to perform the ping and output results
ping_hosts() {
    local ip_prefix=$1

    for ip in $(seq 1 254); do
        local result=$(ping -c 1 ${ip_prefix}.${ip} 2>/dev/null | grep ttl)
        
        if [ -n "$result" ]; then
            local ttl=$(echo $result | grep -oP 'ttl=\K[^ ]+')
            local os

            case $ttl in
                30|60|64) os="${RED}Linux${RESET}" ;;
                127|128) os="${RED}Windows${RESET}" ;;
                254|255|256) os="${RED}OpenBSD/Cisco/Oracle${RESET}" ;;
                *) os="Unknown" ;;
            esac

            echo -e "${BOLD}${ip_prefix}.${ip}${RESET} ${GREEN}live${RESET} $os"
        fi
    done
}

# Entry point of the script
main() {
    if [ -z "$1" ]; then
        echo -e "${RED}IP prefix is required.${RESET}"
        echo "Usage: $0 [IP_PREFIX]"
        echo "Example: $0 192.168.1"
        exit 1
    fi

    validate_ip_prefix "$1"
    ping_hosts "$1"
}

# Execute the main function with all arguments passed
main "$@"
