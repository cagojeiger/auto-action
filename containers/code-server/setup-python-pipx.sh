#!/bin/bash
set -e

# pipx PATH 설정
pipx ensurepath --force

# bash-completion이 .bashrc에 없으면 추가
if ! grep -q "bash_completion" ~/.bashrc; then
    echo '' >> ~/.bashrc
    echo '# Enable bash completion' >> ~/.bashrc
    echo 'if [ -f /etc/bash_completion ] && ! shopt -oq posix; then' >> ~/.bashrc
    echo '    . /etc/bash_completion' >> ~/.bashrc
    echo 'fi' >> ~/.bashrc
fi

# .bashrc 소싱
source ~/.bashrc

echo "✓ pipx PATH configured and bash completion enabled"