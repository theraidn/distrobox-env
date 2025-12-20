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
             distrobox enter dev
             sudo sh -c "echo '$(whoami) ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/90-distrobox && chmod 0440 /etc/sudoers.d/90-distrobox"

    2) Run the setup commands interactively by entering the distrobox and running the script steps manually:
             distrobox enter dev
             # then run the commands from the script interactively

    3) Recreate the distrobox to use a root user for provisioning (advanced).

Exiting to avoid hanging waiting for a sudo password.
MSG
        exit 1
fi

echo "Updating system packages..."
sudo apk update

echo "Installing development packages..."
sudo apk add --no-cache \
    python3 \
    python3-dev \
    py3-pip \
    openjdk17 \
    maven \
    gradle \
    nodejs \
    npm \
    yarn \
    git \
    gcc \
    g++ \
    make \
    curl \
    wget \
    vim \
    nano \
    jq \
    openssl \
    ca-certificates \
    ansible \
    sshpass \
    libc6-compat \
    kubectl \
    helm \
    k9s \
    etcd-ctl

echo "Verifying installations..."
python3 --version
java -version
node --version
npm --version

echo "Installing Ansible Galaxy collections (community.kubernetes, community.docker)..."
ansible-galaxy collection install community.kubernetes community.docker || true

echo "Attempting to install Docker CLI."
sudo apk add --no-cache docker-cli

echo "Verifying installations..."
command -v kubectl
command -v helm
command -v k9s
command -v etcdctl

echo "Development environment setup complete!"
