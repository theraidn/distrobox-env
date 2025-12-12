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

echo "Updating system packages..."
sudo dnf update -y

echo "Installing Python development packages..."
sudo dnf install -y --skip-unavailable \
    python3 \
    python3-devel \
    python3-pip

echo "Installing Java development packages..."
sudo dnf install -y --skip-unavailable \
    java-latest-openjdk \
    java-latest-openjdk-devel \
    java-latest-openjdk-headless \
    maven \
    gradle

echo "Installing Node.js development packages..."
sudo dnf install -y --skip-unavailable \
    nodejs \
    npm \
    yarn

echo "Installing additional useful development tools..."
sudo dnf install -y --skip-unavailable \
    git \
    gcc \
    gcc-c++ \
    make \
    curl \
    wget \
    vim \
    nano

echo "Verifying installations..."
python3 --version
java -version
node --version
npm --version

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
