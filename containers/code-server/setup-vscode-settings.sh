#!/bin/bash
set -e

SETTINGS_DIR="$HOME/.local/share/code-server/User"
SETTINGS_FILE="$SETTINGS_DIR/settings.json"

read -r -d '' DEFAULTS <<'JSONEOF' || true
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
        "**/.npm": true
    }
}
JSONEOF

mkdir -p "$SETTINGS_DIR"

if [ -f "$SETTINGS_FILE" ]; then
	jq -s '.[0] * .[1]' <(echo "$DEFAULTS") "$SETTINGS_FILE" >"$SETTINGS_FILE.tmp"
	mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
	echo "✓ vscode settings merged"
else
	echo "$DEFAULTS" >"$SETTINGS_FILE"
	echo "✓ vscode settings created"
fi
