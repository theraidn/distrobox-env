#!/bin/bash
set -e

# This script is executed inside the 'dev' distrobox to install and configure software.

# Detect if sudo can be used non-interactively. If sudo would prompt for a password,
# `sudo -n true` returns non-zero and we exit with guidance to avoid hanging.
if ! sudo -n true 2>/dev/null; then
        cat <<'MSG' >&2
Error: inside the distrobox `sudo` requires a password and the script is non-interactive.
To avoid the installer hanging you have three options:

    1) Enable passwordless sudo in the distrobox for your user (recommended for automation):
             distrobox enter media
             sudo sh -c "echo '$(whoami) ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/90-distrobox && chmod 0440 /etc/sudoers.d/90-distrobox"

    2) Run the setup commands interactively by entering the distrobox and running the script steps manually:
             distrobox enter media
             # then run the commands from the script interactively

    3) Recreate the distrobox to use a root user for provisioning (advanced).

Exiting to avoid hanging waiting for a sudo password.
MSG
        exit 1
fi

echo "Updating system packages..."
sudo apk update

echo "Installing packages..."
sudo apk add --no-cache \
imagemagick \
    imagemagick-heic \
    libheif \
    exiftool \
    bash \
    git \
    curl \
    wget \
    nano

echo "Media environment setup complete!"
