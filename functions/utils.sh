#!/bin/bash

# This script provides utility functions for other setup scripts.

# --- Colors for output ---
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m' # Added RED for error messages
NC='\033[0m' # No Color

#
# Creates a distrobox alias in ~/.bashrc if it doesn't already exist.
#
# Usage: manage_distrobox_alias <alias_name> <box_name>
#   - alias_name: The desired alias to create (e.g., 'dev').
#   - box_name: The name of the distrobox container to enter (e.g., 'dev-container').
#
manage_distrobox_alias() {
    local alias_name=$1
    local box_name=$2
    local bashrc_file="$HOME/.bashrc"

    if [ -z "$alias_name" ] || [ -z "$box_name" ]; then
        echo "Usage: manage_distrobox_alias <alias_name> <box_name>"
        return 1
    fi

    echo -e "${YELLOW}Managing alias for '$alias_name'...${NC}"
    
    # Ensure .bashrc exists
    if [ ! -f "$bashrc_file" ]; then
        echo -e "${YELLOW}File $bashrc_file does not exist, creating it.${NC}"
        touch "$bashrc_file"
    fi

    # Check if alias exists and add it if it does not
    if grep -q "alias ${alias_name}='distrobox enter ${box_name}'" "$bashrc_file"; then
        echo -e "${GREEN}Alias '${alias_name}' is already correctly configured in $bashrc_file${NC}"
    elif grep -q "alias ${alias_name}=" "$bashrc_file"; then
        echo -e "${YELLOW}Alias '${alias_name}' already exists in $bashrc_file but with a different command. It will not be modified.${NC}"
    else
        echo "" >> "$bashrc_file"
        echo "# Alias to enter the '${box_name}' distrobox" >> "$bashrc_file"
        echo "alias ${alias_name}='distrobox enter ${box_name}'" >> "$bashrc_file"
        echo -e "${GREEN}Added alias '${alias_name}' to $bashrc_file. Please run 'source $bashrc_file' or restart your terminal to use it.${NC}"
    fi
}

#
# Sets up a distrobox environment, including creation, provisioning, and alias management.
#
# Usage: setup_distrobox_environment <box_name> <image> <script_dir_for_bind_mount> <provision_script_path_in_container>
#   - box_name: The name of the distrobox container (e.g., 'dev').
#   - image: The container image to use (e.g., 'alpine:latest').
#   - script_dir_for_bind_mount: The host path to the directory containing setup scripts (e.g., SCRIPT_DIR from calling script).
#   - provision_script_path_in_container: The path to the provisioning script *inside* the container (e.g., '/usr/bin/provision-dev.sh').
#
setup_distrobox_environment() {
    local box_name=$1
    local image=$2
    local script_dir_for_bind_mount=$3
    local provision_script_path_in_container=$4

    if [ -z "$box_name" ] || [ -z "$image" ] || [ -z "$script_dir_for_bind_mount" ] || [ -z "$provision_script_path_in_container" ]; then
        echo -e "${RED}Error: Missing arguments for setup_distrobox_environment.${NC}"
        echo "Usage: setup_distrobox_environment <box_name> <image> <script_dir_for_bind_mount> <provision_script_path_in_container>"
        return 1
    fi

    echo -e "${YELLOW}Starting distrobox setup for '$box_name'...${NC}"

    # Check if distrobox is installed
    if ! command -v distrobox &> /dev/null; then
        echo -e "${RED}Error: distrobox is not installed${NC}"
        exit 1
    fi

    # Create distrobox using the shared latest tag
    if distrobox list | grep -q " $box_name "; then
        echo -e "${GREEN}Distrobox container '$box_name' already exists. Skipping creation.${NC}"
    else
        echo -e "${YELLOW}Creating distrobox '$box_name' with image '${image}'...${NC}"
        distrobox create --name "$box_name" --image "${image}"
    fi

    # Enter distrobox and install packages
    echo -e "${YELLOW}Installing development packages in '$box_name'...${NC}"
    distrobox enter "$box_name" -- "$script_dir_for_bind_mount/$provision_script_path_in_container"

    echo -e "${GREEN}Distrobox '$box_name' setup process finished!${NC}"

    # Create a convenient alias for the user
    manage_distrobox_alias "$box_name" "$box_name"

    echo -e "${GREEN}Setup complete!${NC}"
    echo -e "${YELLOW}To use the environment, run: ${NC}$box_name"
    echo -e "${YELLOW}Or directly: ${NC}distrobox enter $box_name"
}