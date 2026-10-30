# Zsh tối thiểu. Shell tương tác chính là fish (config/fish); zsh chủ yếu để công cụ và IDE chạy,
# nên ở đây chỉ có những gì cần cho tương tác thật sự. Không dùng oh-my-zsh.

typeset -U path PATH
path=("$HOME/.local/bin" $path)

# file cache của completion nằm trong ~/.cache, không rải vào $HOME
zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
mkdir -p "${zcompdump:h}"
autoload -Uz compinit && compinit -d "$zcompdump"
unset zcompdump

HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE SHARE_HISTORY

have() { command -v "$1" >/dev/null 2>&1; }

have starship && eval "$(starship init zsh)"
have atuin && eval "$(atuin init zsh)"
have zoxide && eval "$(zoxide init zsh)"
have direnv && eval "$(direnv hook zsh)"
have fzf && source <(fzf --zsh)

alias c='clear'
alias vi='nvim'
if have eza; then
  alias ls='eza'
  alias ll='eza -lah'
  alias la='eza -a'
fi

[[ "$TERM_PROGRAM" == "kiro" ]] && have kiro && . "$(kiro --locate-shell-integration-path zsh)"
