# Kate Editor Setup for DevOps & Systems Development (Fedora Linux)

Automated bootstrap script (`setup-kate-fedora.sh`) to configure **Kate** on Fedora Linux with Language Server Protocol (LSP) support, inline linting, 2-space YAML indentation, and Git gutter markers.

## Supported Languages & Tools

| Language / Format | LSP Server | Linter / Formatter | File Triggers |
| :--- | :--- | :--- | :--- |
| **Ansible** | `ansible-language-server` | `ansible-lint`, `yamllint` | `playbook.yml`, `site.yml`, `main.yml`, `*.ansible.yml` |
| **Jinja2** | `efm-langserver` | `j2lint` | `*.j2` |
| **Docker & Podman** | `docker-langserver` | built-in | `Dockerfile*`, `Containerfile`, `*.containerfile` |
| **Kubernetes & YAML** | `yaml-language-server` | `yamllint` | `*.yaml`, `*.yml` (K8s schema on `*.k8s.yml`, `k8s/`, `manifests/`) |
| **Terraform & OpenTofu** | `terraform-ls` | built-in | `*.tf`, `*.tfvars`, `*.hcl` |
| **Python** | `pylsp` | `ruff` | `*.py` |
| **Bash & Zsh** | `bash-language-server` | `ShellCheck` | `*.sh`, `*.bash`, `*.zsh` |
| **C / C++** | `clangd` | `clang-tidy` | `*.c`, `*.cpp`, `*.h`, `*.hpp` |

## What the Script Configures

1. **System Packages (`dnf`)**: Installs `kate` (RPM), `kf6-kconfig`, `clangd`, `pylsp`, `pipx`, `yamllint`, `ShellCheck`, `nodejs-npm`, `golang`, `ruff`, and HashiCorp's `terraform-ls`.
2. **Python Linters (`pipx`)**: Installs `ansible-lint` and `j2lint` in isolated environments.
3. **Node.js LSPs (`npm -g`)**: Installs `bash-language-server`, `dockerfile-language-server-nodejs`, `yaml-language-server`, and `@ansible/ansible-language-server`.
4. **EFM Language Server (`go`)**: Builds `efm-langserver` and maps `j2lint` for inline `.j2` diagnostics.
5. **Kate Plugins & UI (`katerc`)**:
   * Enables **LSP Client**, **Project Plugin** (Git sidebar & branch switcher), **Git Blame**, and **Documents**.
   * Enables line numbers and **Git line modification gutter markers** (changed/uncommitted lines).
6. **Filetypes & Indentation (`katemoderc`)**:
   * Sets **2-space indentation** (`space-indent true`) for `YAML` and `Ansible`.
   * Creates a custom **Ansible** syntax mode (priority `10`) so Ansible files launch `ansible-language-server` instead of generic YAML.
   * Extends `Dockerfile` mode to recognize Podman `Containerfile` and `*.containerfile`.

## Prerequisites

* Fedora Linux (with `sudo` privileges)
* **Close all Kate windows** before running the script so Kate does not overwrite `~/.config/katerc` or `~/.config/katemoderc` on exit.

## Usage

```bash
chmod +x setup-kate-fedora.sh
./setup-kate-fedora.sh
```

Ensure `$HOME/.local/bin` and `$HOME/go/bin` are in your shell's `PATH` (handled automatically on new terminal sessions after `pipx ensurepath`).

## Post-Install Notes & Tips

* **Non-standard Ansible filenames**: If an Ansible file does not match `playbook.yml`, `site.yml`, `main.yml`, or `*.ansible.yml`, click **YAML** in Kate's bottom-right status bar and switch it to **Configuration → Ansible**.
* **Git integration**: Open any project folder (**File → Open Folder**) inside a Git repository to view uncommitted line markers in the gutter and stage/commit from the **Git** sidebar tab.
* **Syncing to other machines**: Back up or copy these four files to replicate your configuration:
  * `~/.config/katerc`
  * `~/.config/katemoderc`
  * `~/.config/kate/lspclient/settings.json`
  * `~/.config/efm-langserver/config.yaml`

  
## Custom Keyboard Shortcuts (Matching Sublime Text)

Custom shortcuts are stored in `~/.local/share/kxmlgui5/` (**Settings → Configure Keyboard Shortcuts**) so Kate matches Sublime Text keybindings.

| Category | Shortcut | Kate Action |
| :--- | :--- | :--- |
| **LSP Navigation** | `F12` | Go to Definition |
| | `Shift+F12` | Find References |
| | `Ctrl+K`, `Ctrl+I` | Show Hover Info |
| **LSP Linting** | `F8` / `Shift+F8` | Next / Previous Diagnostic |
| **LSP Editing** | `F2` | Rename Symbol |
| | `Ctrl+.` | Quick Fix / Code Action |
| | `Ctrl+Alt+L` | Format Document |
| **Git** | `Ctrl+Alt+G` | Toggle **Git** Sidebar Toolview |
| | `Ctrl+Alt+B` | Toggle Inline Git Blame |
| | `Alt+Down` / `Alt+Up` | Move to Next / Previous Modified Line |
