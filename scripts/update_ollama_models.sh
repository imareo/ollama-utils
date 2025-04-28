#!/bin/bash

# This script updates all models listed by the `ollama list` command.
#
# 1. Ensure you have the `ollama` installed and configured.
# 2. The script will list all models using `ollama list` and update each model using `ollama pull`.
#
# Example usage:
# ./update_ollama_models.sh

GREEN=$(tput setaf 2)
RESET=$(tput sgr0)

ollama list | tail -n +2 | awk '{print $1}' | while read -r model; do
  echo "${GREEN}Updating model: $model${RESET}"
  ollama pull "$model"
done