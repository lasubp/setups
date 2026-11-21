#!/usr/bin/env bash
set -euo pipefail

echo "=== 1. Checking if Kate is running ==="
if pgrep -x "kate" > /dev/null; then
    echo "Please close Kate before running this script so settings are not overwritten."
    exit 1
fi

echo "=== 2. Installing Fedora DNF packages ==="
sudo dnf install -y \
    kate \
    kf6-kconfig \
    clang-tools-extra \
    python3-lsp-server \
    pipx \
    yamllint \
    ShellCheck \
    nodejs-npm \
    golang \
    ruff

echo "=== 3. Installing HashiCorp repo & terraform-ls ==="
if [ ! -f /etc/yum.repos.d/hashicorp.repo ]; then
    sudo dnf config-manager addrepo --from-repofile=https://hashicorp.com
fi
sudo dnf install -y terraform-ls

echo "=== 4. Installing Python linters via pipx ==="
pipx ensurepath
pipx install --force ansible-lint
pipx install --force j2lint

echo "=== 5. Installing Node.js LSP servers ==="
sudo npm install -g \
    bash-language-server \
    dockerfile-language-server-nodejs \
    yaml-language-server \
    @ansible/ansible-language-server

echo "=== 6. Installing efm-langserver (Go) for Jinja2 linting ==="
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

echo "=== 7. Configuring Kate LSP User Server Settings ==="
mkdir -p "$HOME/.config/kate/lspclient"
cat << 'EOF' > "$HOME/.config/kate/lspclient/settings.json"
{
    "servers": {
        "dockerfile": {
            "command": ["docker-langserver", "--stdio"],
            "highlightingModeRegex": "^(Dockerfile|Containerfile)$"
        },
        "bash": {
            "command": ["bash-language-server", "start"],
            "highlightingModeRegex": "^(Bash|Zsh)$"
        },
        "terraform": {
            "command": ["terraform-ls", "serve"],
            "rootIndicationFileNames": [".terraform", ".git"],
            "highlightingModeRegex": "^(Terraform|HCL)$"
        },
        "yaml": {
            "command": ["yaml-language-server", "--stdio"],
            "highlightingModeRegex": "^YAML$",
            "settings": {
                "yaml": {
                    "schemas": {
                        "kubernetes": ["/*.k8s.yaml", "/*.k8s.yml", "/k8s/*.yaml", "/manifests/*.yaml"]
                    }
                }
            }
        },
        "ansible": {
            "command": ["ansible-language-server", "--stdio"],
            "rootIndicationFileNames": ["ansible.cfg", "playbook.yml", "site.yml"],
            "highlightingModeRegex": "^Ansible$"
        },
        "jinja": {
            "command": ["efm-langserver"],
            "highlightingModeRegex": "^Jinja$"
        }
    }
}
EOF

echo "=== 8. Configuring Kate Modes, Filetypes & 2-Space YAML Indentation ==="
# Note: Kate stores custom/overridden filetype modes in ~/.config/katemoderc
kwriteconfig6 --file katemoderc --group "Other/Dockerfile" --key "Wildcards" "Dockerfile*;Containerfile;*.containerfile"
kwriteconfig6 --file katemoderc --group "Markup/YAML" --key "Variables" "kate: space-indent true; tab-width 2; indent-width 2; replace-tabs true;"

kwriteconfig6 --file katemoderc --group "Configuration/Ansible" --key "Section" "Configuration"
kwriteconfig6 --file katemoderc --group "Configuration/Ansible" --key "Highlighting" "YAML"
kwriteconfig6 --file katemoderc --group "Configuration/Ansible" --key "IndentMode" "normal"
kwriteconfig6 --file katemoderc --group "Configuration/Ansible" --key "Wildcards" "*.ansible.yml;*.ansible.yaml;playbook.yml;site.yml;main.yml"
kwriteconfig6 --file katemoderc --group "Configuration/Ansible" --key "Priority" "10"
kwriteconfig6 --file katemoderc --group "Configuration/Ansible" --key "Variables" "kate: space-indent true; tab-width 2; indent-width 2; replace-tabs true;"

echo "=== 9. Enabling Kate Plugins & Git Gutter Markers ==="
# Enable LSP Client, Project Plugin (Git), Git Blame, and Documents
kwriteconfig6 --file katerc --group "KTextEditor::Plugin::lspclient" --key "Enabled" "true"
kwriteconfig6 --file katerc --group "Kate::Plugin::kateprojectplugin" --key "Enabled" "true"
kwriteconfig6 --file katerc --group "Kate::Plugin::kategitblameplugin" --key "Enabled" "true"
kwriteconfig6 --file katerc --group "Kate::Plugin::katefiletreeplugin" --key "Enabled" "true"

# Show line numbers and Git/modification gutter markers
kwriteconfig6 --file katerc --group "KTextEditor View" --key "Line Numbers" "true"
kwriteconfig6 --file katerc --group "KTextEditor View" --key "Line Modification" "true"

echo "=== Done! Open Kate to verify your setup. ==="
