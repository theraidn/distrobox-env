# Distrobox Environment Manager

This repository contains scripts to automate the setup of pre-configured development environments using [distrobox](https://github.com/89luca89/distrobox). These scripts create and provision containerized environments with all the necessary tools for specific development workflows.

## Prerequisites

Before using these scripts, you must have `distrobox` installed on your system. Please follow the [official installation instructions](https://github.com/89luca89/distrobox/blob/main/docs/installation.md) for your distribution.

## Available Environments

### `dev` Environment

This is a comprehensive development environment that includes tools for general-purpose programming and Kubernetes development.

**To set up the `dev` environment, run:**
```bash
./env/dev/setup-dev-distrobox.sh
```

The script will:
1.  Create a Fedora-based distrobox named `dev`.
2.  Install a wide range of development tools, including:
    -   **Languages:** Python, Java (OpenJDK), Node.js
    -   **Build Tools:** Maven, Gradle, npm, yarn
    -   **Kubernetes:** `kubectl`, `helm`, `k9s`, `etcdctl`
    -   **CI/CD & Infra:** Ansible, Docker CLI (`docker-ce-cli`)
    -   **Utilities:** `git`, `curl`, `wget`, `jq`, `vim`, and more.
3.  Add a convenient alias (`dev`) to your `~/.bashrc` file. You can enter the distrobox simply by typing `dev` in your terminal.

**To enter the environment after setup, run:**
```bash
distrobox enter dev
```
Or use the created alias:
```bash
dev
```

## How It Works

The setup scripts use a base Fedora image for the distroboxes. When a script is executed, it performs the following steps:
- Checks if `distrobox` is installed.
- Creates a new distrobox container with a specified name.
- Enters the new container and executes a setup script via a `heredoc`.
- The internal script updates the system, installs all specified packages and tools from `dnf` or via `curl`, and verifies the installations.
- An alias is added to the host's `~/.bashrc` to provide a shortcut for entering the distrobox.

## Customization

You can easily customize the environments by modifying the respective setup scripts. Simply add or remove packages in the `dnf install` list or add new installation steps for any other tools you require.