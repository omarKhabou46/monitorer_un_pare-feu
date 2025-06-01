#!/bin/bash

# Source colors
source lib/colors.sh

log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date +"%Y-%m-%d-%H-%M-%S")
    echo "${timestamp} : ${USERNAME} : ${level} : ${message}" >> "${HISTORY_LOG}"
    if [ "$level" = "INFOS" ]; then
        echo -e "${GREEN}${timestamp} : ${USERNAME} : ${level} : ${message}${NC}"
    else
        echo -e "${RED}${timestamp} : ${USERNAME} : ${level} : ${message}${NC}"
    fi
}