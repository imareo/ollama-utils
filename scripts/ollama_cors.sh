#!/bin/bash

# This script sets the OLLAMA_ORIGINS environment variable for the ollama service
# AFTER INSTALL OR UPDATE OLLAMA.
#
# 1. Define the OLLAMA_ORIGINS variable with the appropriate value.
# 2. Ensure you have root privileges. The script will prompt you to run as root if necessary.
# 3. The script will check if the environment variables are already set in the ollama.service file.
# 4. If the variables are not set, the script will add them under the [Service] section.
# 5. The script will then reload the systemd daemon and restart the ollama service.
#
# Example usage:
# ./set_ollama_origins.sh

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    sudo "$0"
    exit 0
fi

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
RESET=$(tput sgr0)

# For example:
#    OLLAMA_ORIGINS="*"
#    OLLAMA_ORIGINS="http://192.168.1.*"
#    OLLAMA_ORIGINS="http://192.168.1.100"
#    OLLAMA_ORIGINS="http://192.168.1.100, http://192.168.1.101"
OLLAMA_ORIGINS="http://192.168.1.*"
OLLAMA_HOST="http://0.0.0.0:11434"

cd /etc/systemd/system || { echo "Failed to change directory"; exit 1; }

if grep -q "OLLAMA_ORIGINS" ollama.service; then
    echo "${RED}Environment variables already exist${RESET}"
    exit 0
else
    env_vars=(
        "Environment=\"OLLAMA_ORIGINS=$OLLAMA_ORIGINS\""
        "Environment=\"OLLAMA_HOST=$OLLAMA_HOST\""
    )

    for env_var in "${env_vars[@]}"; do
        echo "$env_var added"
        sudo sed -i "/\[Service\]/a\\$env_var" ollama.service
    done

    sudo systemctl daemon-reload && sudo systemctl restart ollama.service
    echo "${GREEN}Ollama service restarted${RESET}"
fi
