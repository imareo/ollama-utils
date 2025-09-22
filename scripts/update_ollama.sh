#!/bin/bash
#
# # This script update the OLLAMA and run setting environment script.
#
# 1. WARNING! Before first run define the OLLAMA_BIN and CORS_SCRIPT
#    variable with the appropriate value.
# 2. WARNING! Ensure you have root privileges!
# 3. Place the script in /opt/
# 4. Use crontab -e to add the following cron job:
#    30 1 * * * export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin && /opt/update_ollama.sh


LOG_FILE="/tmp/ollama_update.log"
OLLAMA_BIN="/usr/local/bin/ollama"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

get_latest_ollama_version() {
    LATEST_VERSION=$(curl -s "https://api.github.com/repos/ollama/ollama/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v?([^"]+)".*/\1/')
    if [ -z "$LATEST_VERSION" ]; then
        log "Error: Failed to fetch the latest Ollama version from GitHub."
        exit 1
    fi
    echo "$LATEST_VERSION"
}

get_installed_ollama_version() {
    if [ -x "$OLLAMA_BIN" ]; then
        INSTALLED_VERSION=$("$OLLAMA_BIN" -v 2>/dev/null | awk '{print $4}')
        echo "$INSTALLED_VERSION"
    else
        echo "Ollama is not installed"
    fi
}

set_ollama_cors(){
    CORS_SCRIPT="/opt/ollama_cors.sh"

    if [ -f "$CORS_SCRIPT" ]; then
        log "Setting CORS configuration..."
        if bash "$CORS_SCRIPT"; then
            log "CORS settings set successfully."
        else
            log "Error: Failed to set CORS settings."
        fi
    else
        log "Error: Failed to set CORS settings. File ollama_cors.sh not found."
    fi
}

install_ollama() {
    log "Installing the latest version of Ollama..."
    if curl -fsSL https://ollama.com/install.sh | sh; then
        log "Ollama has been successfully installed."
        set_ollama_cors
    else
        log "Error: Failed to install Ollama."
        exit 1
    fi
}

log "Starting Ollama version check."
LATEST_VERSION=$(get_latest_ollama_version)
INSTALLED_VERSION=$(get_installed_ollama_version)

log "Latest Ollama version on GitHub: $LATEST_VERSION"
log "Installed Ollama version: $INSTALLED_VERSION"

if [ "$INSTALLED_VERSION" != "$LATEST_VERSION" ] && [ "$INSTALLED_VERSION" != "Ollama is not installed" ]; then
    log "A new version of Ollama has been detected. Starting installation..."
    install_ollama
elif [ "$INSTALLED_VERSION" == "Ollama is not installed" ]; then
    log "Ollama is not installed. Starting installation..."
    install_ollama
else
    log "You already have the latest version of Ollama installed."
fi
