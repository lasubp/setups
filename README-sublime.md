# Sublime Text 4 Setup for DevOps & Systems Development (Fedora Linux)

Automated bootstrap script (`setup-sublime-fedora.sh`) to install **Sublime Text 4** on Fedora Linux and configure Language Server Protocol (LSP) support, inline linting, 2-space indentation, and Git integration.

## Supported Languages & Tools

| Language / Format | Sublime Package | Backend LSP / Linter |
| :--- | :--- | :--- |
| **Ansible** | `LSP`, `Ansible` | `ansible-language-server`, `ansible-lint`, `yamllint` |
| **Jinja2** | `LSP`, `Jinja2` | `efm-langserver` + `j2lint` |
| **Docker & Podman** | `LSP-dockerfile`, `Dockerfile Syntax Highlighting` | `docker-langserver` |
| **Kubernetes & YAML** | `LSP-yaml` | `yaml-language-server`, `yamllint` (with K8s schemas) |
| **Terraform & OpenTofu** | `LSP-terraform`, `Terraform` | `terraform-ls` |
| **Python** | `LSP-pylsp` | `pylsp`, `ruff` |
| **Bash & Zsh** | `LSP-bash` | `bash-language-server`, `ShellCheck` |
| **C / C++** | `LSP-clangd` | `clangd` |
| **Git** | Built-in (`mini_diff`) + `GitSavvy` | `git` |

## What the Script Configures

1. **Repositories & Packages (`dnf`)**: Adds the official Sublime Text and HashiCorp RPM repositories and installs `sublime-text`, `terraform-ls`, `clang-tools-extra`, `python3-lsp-server`, `pipx`, `yamllint`, `ShellCheck`, `nodejs-npm`, `golang`, and `ruff`.
2. **Python Linters (`pipx`)**: Installs `ansible-lint` and `j2lint` in isolated environments.
3. **Node.js LSPs (`npm -g`)**: Installs `bash-language-server`, `dockerfile-language-server-nodejs`, `yaml-language-server`, and `@ansible/ansible-language-server`.
4. **EFM Language Server (`go`)**: Builds `efm-langserver` and configures `j2lint` for inline `.j2` template linting.
5. **Declarative Package Control**: Pre-installs Package Control 4 and writes `Package Control.sublime-settings` so all LSP helpers, syntax definitions, and `GitSavvy` install automatically on first launch.
6. **Editor & Language Settings (`Packages/User/`)**:
   * Enables native Git gutter markers (`"mini_diff": true`) and sidebar file Git status (`"show_git_status": true`).
   * Configures **2-space indentation** for `YAML`, `Ansible`, `Jinja2`, and `Terraform`.
   * Maps Kubernetes YAML schemas (`*.k8s.yml`, `k8s/*.yaml`, `manifests/*.yaml`).
   * Extends `LSP-dockerfile` to cover `Containerfile` and `LSP-bash` to cover `Zsh`.

## Prerequisites

* Fedora Linux (with `sudo` privileges)
* **Close Sublime Text** before running the script.

## Usage

```bash
chmod +x setup-sublime-fedora.sh
./setup-sublime-fedora.sh
```

## First Launch Steps

1. Open **Sublime Text** and wait ~15–20 seconds while **Package Control** automatically downloads and installs the declared packages (watch the bottom-left status bar for progress).
2. **Restart Sublime Text once** after installation finishes so all syntax scopes and LSP clients initialize cleanly.
3. **Associate Podman `Containerfile`**: Open a `Containerfile`, click the syntax name in the bottom-right status bar, and select **Open all with current extension as... → Dockerfile**.

## Syncing Across Machines

All user settings and package declarations live inside:
* `~/.config/sublime-text/Packages/User/`
* `~/.config/efm-langserver/config.yaml`

Copying those two directories to a new machine (or re-running `setup-sublime-fedora.sh`) reproduces the complete environment.
