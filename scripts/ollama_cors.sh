#!/bin/bash

# This script sets the OLLAMA environment variable for the ollama service
#
# 1. WARNING! Define the OLLAMA_ORIGINS variable with the appropriate value.
# 2. Ensure you have root privileges. The script will prompt you to run as root if necessary.
# 3. The script will remove OLLAMA environment variables are already set in the ollama.service file.
# 4. The script will then add environment variables under the [Service] section.
# 5. The script will then reload the systemd daemon and restart the ollama service.
#
# Example usage:
# ./set_ollama_origins.sh

if [ "$EUID" -ne 0 ]; then
    echo "Run as root"
    sudo "$0"
    exit 0
fi

# For example:
#    OLLAMA_ORIGINS="*"
#    OLLAMA_ORIGINS="http://192.168.1.*"
#    OLLAMA_ORIGINS="http://192.168.1.100"
#    OLLAMA_ORIGINS="http://192.168.1.100, http://192.168.1.101"
OLLAMA_ORIGINS="http://192.168.88.*"
OLLAMA_HOST="http://0.0.0.0:11434"

env_vars=(
    "Environment=\"OLLAMA_ORIGINS=$OLLAMA_ORIGINS\""
    "Environment=\"OLLAMA_HOST=$OLLAMA_HOST\""
)

cd /etc/systemd/system || { echo "Error: Failed to change directory"; exit 1; }

if [ ! -f ollama.service ]; then
    echo "Error: ollama.service not found."
    exit 1
fi

# remove environment variables
sed -i '/Environment="OLLAMA_ORIGINS=/d' ollama.service
sed -i '/Environment="OLLAMA_HOST=/d' ollama.service

# add environment variables
for env_var in "${env_vars[@]}"; do
    echo "$env_var added"
    sudo sed -i "/\[Service\]/a\\$env_var" ollama.service
done

sudo systemctl daemon-reload && sudo systemctl restart ollama.service
echo "Ollama service restarted"
