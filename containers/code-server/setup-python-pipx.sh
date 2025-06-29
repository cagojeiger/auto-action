#!/bin/bash
set -e

# .bashrc가 없으면 생성
if [ ! -f ~/.bashrc ]; then
    touch ~/.bashrc
fi

# pipx PATH 설정 (이미 .bashrc가 있으므로 안전하게 실행됨)
pipx ensurepath --force

# bash-completion이 .bashrc에 없으면 추가
if ! grep -q "bash_completion" ~/.bashrc; then
    echo '' >> ~/.bashrc
    echo '# Enable bash completion' >> ~/.bashrc
    echo 'if [ -f /etc/bash_completion ] && ! shopt -oq posix; then' >> ~/.bashrc
    echo '    . /etc/bash_completion' >> ~/.bashrc
    echo 'fi' >> ~/.bashrc
fi

# fzf 키 바인딩 설정 추가
if [ -f /usr/share/doc/fzf/examples/key-bindings.bash ] && ! grep -q "fzf/examples/key-bindings.bash" ~/.bashrc; then
    echo '' >> ~/.bashrc
    echo '# fzf key bindings' >> ~/.bashrc
    echo 'source /usr/share/doc/fzf/examples/key-bindings.bash' >> ~/.bashrc
fi

# .bashrc 소싱
source ~/.bashrc

echo "✓ pipx PATH configured and bash completion enabled"