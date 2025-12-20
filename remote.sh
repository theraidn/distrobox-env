#!/bin/bash

# Deletion script for distrobox environments

set -e

# --- Colors for output ---
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m' # Added RED for error messages
NC='\033[0m' # No Color

if [[ -f "$(dirname "$0")/config/$1.env" ]]; then

    source "$(dirname "$0")/config/$1.env"

    # Configuration
    # BOX_NAME and DIR_NAME are sourced from the .env file

    echo -e "${YELLOW}Starting distrobox deletion for '$BOX_NAME'...${NC}"

    # Check if distrobox is installed
    if ! command -v distrobox &> /dev/null; then
        echo -e "${RED}Error: distrobox is not installed${NC}"
        exit 1
    fi

    # Remove distrobox container
    if distrobox list | grep -q " $BOX_NAME "; then
        echo -e "${YELLOW}Removing distrobox container '$BOX_NAME'...${NC}"
        distrobox rm -f "$BOX_NAME"
        echo -e "${GREEN}Distrobox container '$BOX_NAME' removed.${NC}"
    else
        echo -e "${YELLOW}Distrobox container '$BOX_NAME' does not exist. Skipping removal.${NC}"
    fi

    # Remove alias from ~/.bashrc
    local bashrc_file="$HOME/.bashrc"
    local alias_line="alias $DIR_NAME='distrobox enter $BOX_NAME'"
    local alias_comment="# Alias to enter the '${BOX_NAME}' distrobox"

    if [ -f "$bashrc_file" ]; then
        if grep -q "$alias_line" "$bashrc_file"; then
            echo -e "${YELLOW}Removing alias '$DIR_NAME' from $bashrc_file...${NC}"
            # Remove the alias line and the preceding comment line
            sed -i "/$alias_line/d" "$bashrc_file"
            sed -i "/$alias_comment/d" "$bashrc_file"
            echo -e "${GREEN}Alias '$DIR_NAME' removed from $bashrc_file.${NC}"
            echo -e "${YELLOW}Please run 'source $bashrc_file' or restart your terminal to apply changes.${NC}"
        else
            echo -e "${YELLOW}Alias '$DIR_NAME' not found in $bashrc_file. Skipping alias removal.${NC}"
        fi
    else
        echo -e "${YELLOW}$bashrc_file does not exist. Skipping alias removal.${NC}"
    fi

    echo -e "${GREEN}Deletion process complete!${NC}"

else
    echo "Error: Configuration file for box '$1' not found at 'config/$1.env'."
    echo "Please provide a valid box name as an argument (e.g., 'dev')."
    exit 1
fi
