#!/bin/bash

# Setup script for development distrobox with Fedora
# This script creates and configures a distrobox named 'dev' with Python, Java, and Node.js dev tools

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Directory name (used for alias, e.g. 'dev' -> alias dev='distrobox enter dev')
DIR_NAME="$(basename "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Starting distrobox setup for 'dev'...${NC}"

# Check if distrobox is installed
if ! command -v distrobox &> /dev/null; then
    echo -e "${RED}Error: distrobox is not installed${NC}"
    exit 1
fi

# Use the single 'latest' image reference so both distroboxes share the same image.
# This avoids storing duplicate Fedora images with different tags.
FEDORA_IMAGE="registry.fedoraproject.org/fedora:latest"

# Create distrobox using the shared latest tag
echo -e "${YELLOW}Creating distrobox 'dev' with Fedora (latest)...${NC}"
distrobox create --name dev --image "${FEDORA_IMAGE}"

# Enter distrobox and install packages
echo -e "${YELLOW}Installing development packages...${NC}"
distrobox enter dev -- bash << 'EOF'
set -e

# Detect if sudo can be used non-interactively. If sudo would prompt for a password,
# `sudo -n true` returns non-zero and we exit with guidance to avoid hanging.
if ! sudo -n true 2>/dev/null; then
        cat <<'MSG'
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
sudo dnf update -y

echo "Installing development packages..."
sudo dnf install -y --skip-unavailable \
    python3 \
    python3-devel \
    python3-pip \
    java-latest-openjdk \
    java-latest-openjdk-devel \
    java-latest-openjdk-headless \
    maven \
    gradle \
    nodejs \
    npm \
    yarn \
    git \
    gcc \
    gcc-c++ \
    make \
    curl \
    wget \
    vim \
    nano \
    jq \
    openssl \
    ca-certificates \
    ansible \
    sshpass

echo "Verifying installations..."
python3 --version
java -version
node --version
npm --version

echo "Installing kubectl (Kubernetes CLI)..."
curl -fsSL https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl -o /tmp/kubectl
sudo install -o root -g root -m 0755 /tmp/kubectl /usr/local/bin/kubectl
rm -f /tmp/kubectl

echo "Installing Helm (Kubernetes package manager)..."
if [ "${VERIFY_CHECKSUM:-}" = "false" ]; then
    echo "VERIFY_CHECKSUM=false set — installing Helm without checksum verification"
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | VERIFY_CHECKSUM=false bash
else
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

echo "Installing k9s (Kubernetes TUI)..."
K9S_LATEST=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep -oP '"tag_name": "\K[^"]*')
curl -fsSL https://github.com/derailed/k9s/releases/download/${K9S_LATEST}/k9s_Linux_amd64.tar.gz | tar xz -C /tmp
sudo install -o root -g root -m 0755 /tmp/k9s /usr/local/bin/k9s
rm -f /tmp/k9s

echo "Installing etcdctl (etcd CLI)..."
ETCD_VER=v3.5.10
DOWNLOAD_URL="https://github.com/etcd-io/etcd/releases/download/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz"
curl -fsSL "${DOWNLOAD_URL}" | tar xz -C /tmp
sudo install -o root -g root -m 0755 /tmp/etcd-${ETCD_VER}-linux-amd64/etcdctl /usr/local/bin/etcdctl
rm -rf /tmp/etcd-${ETCD_VER}-linux-amd64

echo "Installing Ansible Galaxy collections (community.kubernetes, community.docker)..."
ansible-galaxy collection install community.kubernetes community.docker || true

echo "Attempting to install Docker CLI (docker-ce)."
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo || true
sudo dnf install -y --skip-unavailable docker-ce-cli

# Do NOT enable or start any Docker engine inside the distrobox.
# The script installs only the Docker CLI (`docker-ce-cli`). To use a Docker daemon,
# connect the CLI to an external VM (e.g. via `DOCKER_HOST=tcp://host:2375`) or
# bind-mount a remote docker socket into the container. Starting services inside
# the distrobox is intentionally avoided to keep the container lightweight and
# to ensure the Docker engine is not installed or run here.

echo "Verifying installations..."
kubectl version --client
helm version
k9s version
etcdctl version

echo "Development environment setup complete!"
EOF

echo -e "${GREEN}Distrobox 'dev' created successfully!${NC}"
echo -e "${YELLOW}Setting up ~/.bashrc alias...${NC}"

# Check if alias exists for the script directory name and add if necessary
if grep -q "alias ${DIR_NAME}=" ~/.bashrc; then
    echo -e "${GREEN}Alias '${DIR_NAME}' already exists in ~/.bashrc${NC}"
else
    echo "alias ${DIR_NAME}='distrobox enter ${DIR_NAME}'" >> ~/.bashrc
    echo -e "${GREEN}Added alias '${DIR_NAME}' to ~/.bashrc${NC}"
fi

echo -e "${GREEN}Setup complete!${NC}"
echo -e "${YELLOW}To use the dev environment, run: ${NC}dev"
echo -e "${YELLOW}Or directly: ${NC}distrobox enter dev"
