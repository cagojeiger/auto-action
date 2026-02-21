if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="/usr/share/oh-my-zsh"
export ZSH_CACHE_DIR="$HOME/.cache/oh-my-zsh"
export ZSH_COMPDUMP="$ZSH_CACHE_DIR/.zcompdump"
export HISTFILE="$ZSH_CACHE_DIR/.zsh_history"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source "$ZSH/oh-my-zsh.sh"

export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"
export GO111MODULE=on
export NPM_CONFIG_PREFIX="$HOME/.npm-global"
export PIPX_HOME="$HOME/.local/pipx"
export PIPX_BIN_DIR="$HOME/.local/bin"
export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"

export PATH="/usr/local/go/bin:$GOBIN:$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"

if command -v direnv &>/dev/null; then
  eval "$(direnv hook zsh)"
fi

[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh
[ -f /usr/share/doc/fzf/examples/completion.zsh ] && source /usr/share/doc/fzf/examples/completion.zsh

alias k='kubectl'
alias kns='kubectl config set-context --current --namespace'
alias kctx='kubectl config use-context'
alias dc='docker compose'
alias ll='ls -alFh'
alias la='ls -A'

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
