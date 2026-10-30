if status is-interactive
end

function fish_prompt
    echo (set_color 87d7af)(date +%H:%M:%S) (set_color 87d7ff)(prompt_pwd) (set_color ffafff)(fish_git_prompt) (set_color ffafff)'→ '
end
fish_add_path ~/.local/bin

alias c "clear"
alias vi "nvim"
alias prv "fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'"

switch (uname)
    case Darwin
        alias cs "open -a 'Cursor'"
        alias vs "open -a 'Visual Studio Code'"
    case '*'
        alias cs cursor
        alias vs code
end

alias ls='eza'
alias ll='eza -lah'
alias la='eza -a'

atuin init fish | source
zoxide init fish --cmd cd | source

# Antigravity IDE (chỉ khi đã cài)
test -d ~/.antigravity-ide/antigravity-ide/bin; and fish_add_path ~/.antigravity-ide/antigravity-ide/bin

string match -q "$TERM_PROGRAM" "kiro" and . (kiro --locate-shell-integration-path fish)
