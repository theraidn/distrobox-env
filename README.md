# Distrobox Development Environment Manager

A comprehensive shell script framework for creating, managing, and provisioning isolated development environments using [Distrobox](https://github.com/89luca89/distrobox). This project simplifies the setup of containerized development environments with pre-configured tools and automatic alias management.

## Overview

Distrobox allows you to create containerized Linux distributions while maintaining seamless integration with your host system. This repository provides:

- **Easy environment creation** - Simple one-command setup for development containers
- **Configurable environments** - Per-environment configuration files for customization
- **Automated provisioning** - Scripts to install and configure development tools inside containers
- **Bash alias management** - Automatic creation of convenient aliases for entering containers
- **Cleanup utilities** - Easy removal of containers and associated aliases

## Prerequisites

- **Distrobox** - Install from [https://github.com/89luca89/distrobox](https://github.com/89luca89/distrobox)
- **Docker** or **Podman** - Container runtime required by Distrobox
- **Bash** - POSIX-compliant shell
- Linux system with container support

## Project Structure

```
.
├── README.md                    # This file
├── create.sh                    # Main script to create/setup development environments
├── remote.sh                    # Script to remove/delete development environments
├── config/
│   └── dev.env                  # Configuration for the 'dev' environment
├── functions/
│   └── utils.sh                 # Shared utility functions
└── setup/
    └── dev/
        └── provisioning.sh      # Development environment provisioning script
```

## Quick Start

### Create a Development Environment

```bash
./create.sh dev
```

This will:
1. Create a new Distrobox container named 'dev' using Alpine Linux
2. Install development tools (Python, Java, Node.js, Git, Docker CLI, Kubernetes tools, etc.)
3. Create a bash alias `dev` to quickly enter the environment
4. Verify all installations

### Enter the Development Environment

```bash
dev
```

Or explicitly:
```bash
distrobox enter dev
```

### Exit the Environment

```bash
exit
```

### Remove the Environment

```bash
./remote.sh dev
```

This will:
1. Stop and remove the Distrobox container
2. Remove the bash alias from `~/.bashrc`
3. Clean up all associated resources

## Configuration

### Environment Configuration Files

Each development environment has a corresponding `.env` file in the `config/` directory.

**Example: `config/dev.env`**

```dotenv
BOX_NAME="dev"              # Name of the distrobox container
IMAGE="alpine:latest"       # Base container image
PROVISION_SCRIPT="setup/dev/provisioning.sh"  # Path to provisioning script
DIR_NAME="dev"              # Alias name for entering the box
```

### Customizing Environments

1. Create a new environment configuration file in `config/` (e.g., `config/custom.env`)
2. Create a provisioning script in `setup/custom/provisioning.sh`
3. Run `./create.sh custom`

## Development Environment Details

### Pre-installed Packages (Dev Environment)

The 'dev' environment includes:

- **Languages & Runtimes**: Python 3.12, OpenJDK 17 & 21, Node.js 24, Gradle, Maven
- **Build Tools**: GCC, G++, Make, OpenSSL
- **Container & Orchestration**: Docker CLI, Kubectl, Helm, K9s, etcdctl
- **DevOps**: Ansible with community collections
- **Utilities**: Git, Vim, Nano, jq, sshpass, yarn

### Provisioning Process

The provisioning script (`setup/dev/provisioning.sh`):

1. Checks for passwordless sudo (required for automated setup)
2. Updates system package repositories
3. Installs all development packages
4. Verifies critical tool installations
5. Installs Docker CLI inside the container

### Sudo Configuration

For automated provisioning to work, the container may need passwordless sudo. You can enable this:

```bash
distrobox enter dev
sudo sh -c "echo '$(whoami) ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/90-distrobox && chmod 0440 /etc/sudoers.d/90-distrobox"
```

## Usage Examples

### Check Available Tools

```bash
dev
node --version
python3 --version
java -version
docker --version
kubectl version --client
exit
```

### Install Additional Packages Inside Environment

```bash
dev
apk add <package-name>
exit
```

### Access Host Files from Environment

Files in your home directory are automatically accessible inside the distrobox:

```bash
dev
ls ~/ENTW/code  # Access host files from container
exit
```

## Utility Functions

The `functions/utils.sh` script provides:

### `manage_distrobox_alias()`

Creates and manages bash aliases for distrobox entry:

```bash
manage_distrobox_alias <alias_name> <box_name>
```

### `setup_distrobox_environment()`

Main setup function that orchestrates container creation, provisioning, and alias management.

## Troubleshooting

### Permission Denied Error with Ansible

If you see: `PermissionError: [Errno 13] Permission denied: b'/dev/.ansible'`

This typically occurs on the first run and can usually be ignored - the setup script continues and completes successfully.

### Distrobox Command Not Found

Ensure Distrobox is installed and in your PATH:
```bash
which distrobox
```

If not installed, follow the [Distrobox installation guide](https://github.com/89luca89/distrobox#installation).

### Container Already Exists

If you run `./create.sh dev` and the container already exists, the script will skip container creation and only run provisioning.

To completely recreate an environment:
```bash
./remote.sh dev
./create.sh dev
```

## Advanced Usage

### Creating Multiple Environments

You can create multiple specialized environments by:

1. Copying `config/dev.env` to `config/other.env` and editing as needed
2. Creating `setup/other/provisioning.sh` with custom package installations
3. Running `./create.sh other`

### Mounting Additional Host Directories

Distrobox automatically mounts your home directory. To mount additional directories, edit the distrobox container configuration or use distrobox commands:

```bash
distrobox enter dev -- distrobox-host-exec mount <host-path> <container-path>
```

### Running Commands Without Entering

Execute commands in a distrobox without interactively entering it:

```bash
distrobox enter dev -- python3 --version
dev python3 --version  # If alias is configured
```

## Contributing

When adding new environments or modifying provisioning scripts:

1. Follow the existing structure and naming conventions
2. Add appropriate error handling and validation
3. Update configuration files with meaningful comments
4. Test the provisioning script thoroughly
5. Update this README with any new features or changes

## License

[Add your license information here if applicable]

## Related Links

- [Distrobox GitHub](https://github.com/89luca89/distrobox)
- [Alpine Linux](https://alpinelinux.org/)
- [Docker](https://www.docker.com/)
- [Podman](https://podman.io/)

---

**Last Updated:** December 2025

For questions or issues, please refer to the individual script files which contain detailed comments and error messages.
