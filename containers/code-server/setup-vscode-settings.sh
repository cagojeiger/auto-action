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
    "terminal.integrated.defaultProfile.linux": "zsh"
}
EOF

echo "✓ vscode settings configured"
