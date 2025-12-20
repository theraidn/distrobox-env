#!/bin/bash

# Setup script for distrobox environments

set -e

if [[ -f "$(dirname "$0")/config/$1.env" ]]; then

    source "$(dirname "$0")/config/$1.env"
    source "$(dirname "$0")/functions/utils.sh"

    # Configuration
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    source "$(dirname "$0")/config/$BOX_NAME.env"

    # Use the generic setup function from utils.sh
    setup_distrobox_environment \
        "$BOX_NAME" \
        "$IMAGE" \
        "$SCRIPT_DIR" \
        "$PROVISION_SCRIPT"
else
    echo "Error: Configuration file for box '$1' not found at 'config/$1.env'."
    echo "Please provide a valid box name as an argument."
    exit 1
fi
