#!/bin/bash
set -e

DEFAULTS="/etc/zsh/defaults.zsh"
SOURCE_LINE="source $DEFAULTS"

mkdir -p "$HOME/.cache/oh-my-zsh"

if [ ! -f "$HOME/.zshrc" ]; then
	cat >"$HOME/.zshrc" <<EOF
$SOURCE_LINE

# Add your customizations below
EOF
	echo "✓ zshrc created"
elif ! grep -qF "$DEFAULTS" "$HOME/.zshrc"; then
	sed -i "1i\\$SOURCE_LINE\\n" "$HOME/.zshrc"
	echo "✓ zshrc updated (source line added)"
fi

if [ ! -f "$HOME/.p10k.zsh" ] && [ -f /etc/entrypoint.d/p10k.zsh ]; then
	cp /etc/entrypoint.d/p10k.zsh "$HOME/.p10k.zsh"
fi
