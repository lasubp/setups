#!/usr/bin/env bash
set -euo pipefail

echo "=== 1. Checking if Sublime Text is running ==="
if pgrep -x "sublime_text" > /dev/null; then
    echo "Please close Sublime Text before running this script."
    exit 1
fi

echo "=== 2. Adding Sublime Text & HashiCorp Repos and Installing Packages ==="
sudo rpm -v --import https://sublimetext.com
sudo dnf config-manager addrepo --from-repofile=https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo --overwrite

if [ ! -f /etc/yum.repos.d/hashicorp.repo ]; then
    sudo dnf config-manager addrepo --from-repofile=https://hashicorp.com
fi

sudo dnf install -y \
    sublime-text \
    terraform-ls \
    clang-tools-extra \
    python3-lsp-server \
    pipx \
    yamllint \
    ShellCheck \
    nodejs-npm \
    golang \
    ruff

echo "=== 3. Installing Python Linters via pipx ==="
pipx ensurepath
pipx install --force ansible-lint
pipx install --force j2lint

echo "=== 4. Installing Node.js LSP Servers ==="
sudo npm install -g \
    bash-language-server \
    dockerfile-language-server-nodejs \
    yaml-language-server \
    @ansible/ansible-language-server

echo "=== 5. Installing efm-langserver (Go) for Jinja2 Linting ==="
go install ://github.com
sudo ln -sf "$HOME/go/bin/efm-langserver" /usr/local/bin/efm-langserver

mkdir -p "$HOME/.config/efm-langserver"
cat << 'EOF' > "$HOME/.config/efm-langserver/config.yaml"
version: 2
tools:
  j2lint: &j2lint
    lint-command: 'j2lint --stdin'
    lint-stdin: true
    lint-formats:
      - '%f:%l:%c: %m'
      - '%f:%l: %m'

languages:
  jinja:
    - <<: *j2lint
EOF

echo "=== 6. Installing Package Control & Declaring Sublime Packages ==="
ST_CONFIG="$HOME/.config/sublime-text"
INSTALLED_PKGS="$ST_CONFIG/Installed Packages"
USER_PKGS="$ST_CONFIG/Packages/User"

mkdir -p "$INSTALLED_PKGS" "$USER_PKGS"

# Download Package Control 4 directly so no GUI bootstrap is needed
curl -fsSL "https://download.sublimetext.com/Package%20Control.sublime-package" \
    -o "$INSTALLED_PKGS/Package Control.sublime-package"

# Package Control automatically installs everything listed in installed_packages on first launch
cat << 'EOF' > "$USER_PKGS/Package Control.sublime-settings"
{
    "bootstrapped": true,
    "in_process_packages": [],
    "installed_packages": [
        "Package Control",
        "LSP",
        "LSP-yaml",
        "LSP-dockerfile",
        "LSP-bash",
        "LSP-terraform",
        "LSP-pylsp",
        "LSP-clangd",
        "LSP-json",
        "Ansible",
        "Terraform",
        "Dockerfile Syntax Highlighting",
        "Jinja2",
        "GitSavvy"
    ]
}
EOF

echo "=== 7. Configuring Base Sublime Settings (Git Gutter Markers & General Preferences) ==="
cat << 'EOF' > "$USER_PKGS/Preferences.sublime-settings"
{
    "mini_diff": true,
    "show_git_status": true,
    "tab_size": 4,
    "translate_tabs_to_spaces": true,
    "trim_trailing_white_space_on_save": "not_on_caret",
    "ensure_newline_at_eof_on_save": true
}
EOF

echo "=== 8. Configuring 2-Space Indentation for YAML, Ansible, Jinja2 & Terraform ==="
cat << 'EOF' > "$USER_PKGS/YAML.sublime-settings"
{
    "tab_size": 2,
    "indent_size": 2,
    "translate_tabs_to_spaces": true
}
EOF

cp "$USER_PKGS/YAML.sublime-settings" "$USER_PKGS/Ansible.sublime-settings"
cp "$USER_PKGS/YAML.sublime-settings" "$USER_PKGS/Jinja2.sublime-settings"
cp "$USER_PKGS/YAML.sublime-settings" "$USER_PKGS/Terraform.sublime-settings"

echo "=== 9. Configuring Custom LSP Servers (Ansible, Kubernetes, Podman, Zsh, Jinja2) ==="
cat << 'EOF' > "$USER_PKGS/LSP.sublime-settings"
{
    "show_diagnostics_panel_on_save": 0,
    "show_diagnostics_in_view_status": true,
    "clients": {
        "ansible": {
            "enabled": true,
            "command": ["ansible-language-server", "--stdio"],
            "selector": "source.ansible | source.yaml.ansible"
        },
        "efm-jinja": {
            "enabled": true,
            "command": ["efm-langserver"],
            "selector": "text.html.jinja | source.jinja"
        }
    }
}
EOF

# Configure LSP-yaml for Kubernetes schemas
cat << 'EOF' > "$USER_PKGS/LSP-yaml.sublime-settings"
{
    "settings": {
        "yaml.schemas": {
            "kubernetes": ["/*.k8s.yaml", "/*.k8s.yml", "/k8s/*.yaml", "/manifests/*.yaml"]
        }
    }
}
EOF

# Extend LSP-bash to cover Zsh as well
cat << 'EOF' > "$USER_PKGS/LSP-bash.sublime-settings"
{
    "selector": "source.shell.bash | source.shell.zsh"
}
EOF

echo "=== 10. Configuring Custom Keybindings (LSP & GitSavvy) ==="
cat << 'EOF' > "$USER_PKGS/Default (Linux).sublime-keymap"
[
    // --- LSP: Navigation & Documentation ---
    {
        "keys": ["f12"],
        "command": "lsp_symbol_definition",
        "context": [{ "key": "lsp.session_with_capability", "operator": "equal", "operand": "definitionProvider" }]
    },
    {
        "keys": ["shift+f12"],
        "command": "lsp_symbol_references",
        "context": [{ "key": "lsp.session_with_capability", "operator": "equal", "operand": "referencesProvider" }]
    },
    {
        "keys": ["ctrl+k", "ctrl+i"],
        "command": "lsp_hover",
        "context": [{ "key": "lsp.session_with_capability", "operator": "equal", "operand": "hoverProvider" }]
    },

    // --- LSP: Diagnostics (Lint Errors & Warnings) ---
    {
        "keys": ["f8"],
        "command": "lsp_next_diagnostic"
    },
    {
        "keys": ["shift+f8"],
        "command": "lsp_prev_diagnostic"
    },
    {
        "keys": ["ctrl+shift+m"],
        "command": "lsp_show_diagnostics_panel"
    },

    // --- LSP: Refactoring & Formatting ---
    {
        "keys": ["f2"],
        "command": "lsp_symbol_rename",
        "context": [{ "key": "lsp.session_with_capability", "operator": "equal", "operand": "renameProvider" }]
    },
    {
        "keys": ["ctrl+."],
        "command": "lsp_code_actions",
        "context": [{ "key": "lsp.session_with_capability", "operator": "equal", "operand": "codeActionProvider" }]
    },
    {
        "keys": ["ctrl+alt+l"],
        "command": "lsp_format_document",
        "context": [{ "key": "lsp.session_with_capability", "operator": "equal", "operand": "documentFormattingProvider" }]
    },

    // --- GitSavvy & Native Git Gutter ---
    {
        "keys": ["ctrl+alt+g"],
        "command": "gs_show_status"
    },
    {
        "keys": ["ctrl+alt+d"],
        "command": "gs_diff"
    },
    {
        "keys": ["ctrl+alt+b"],
        "command": "gs_blame"
    },
    {
        "keys": ["alt+down"],
        "command": "next_modification"
    },
    {
        "keys": ["alt+up"],
        "command": "prev_modification"
    },
    {
        "keys": ["ctrl+k", "ctrl+z"],
        "command": "revert_modification"
    }
]
EOF

echo "=== Done! Launch Sublime Text and wait ~15 seconds for Package Control to finish installing packages. ==="
