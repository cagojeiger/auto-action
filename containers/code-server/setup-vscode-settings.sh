#!/bin/bash
set -e

SETTINGS_DIR="$HOME/.local/share/code-server/User"
SETTINGS_FILE="$SETTINGS_DIR/settings.json"

if [ -f "$SETTINGS_FILE" ]; then
	exit 0
fi

mkdir -p "$SETTINGS_DIR"

cat >"$SETTINGS_FILE" <<'EOF'
{
    "workbench.colorTheme": "Default Dark Modern",
    "terminal.integrated.fontFamily": "'MesloLGS NF', monospace",
    "terminal.integrated.defaultProfile.linux": "zsh",
    "files.exclude": {
        "**/.bash_logout": true,
        "**/.bashrc": true,
        "**/.profile": true,
        "**/.zshrc": true,
        "**/.p10k.zsh": true,
        "**/.cache": true,
        "**/.config": true,
        "**/.local": true,
        "**/.npm": true
    }
}
EOF

echo "✓ vscode settings configured"
