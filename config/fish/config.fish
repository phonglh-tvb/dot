if status is-interactive
end

function fish_prompt
    echo (set_color 87d7af)(date +%H:%M:%S) (set_color 87d7ff)(prompt_pwd) (set_color ffafff)(fish_git_prompt) (set_color ffafff)'→ '
end
fish_add_path ~/.local/bin

alias c "clear"
alias vi "nvim"
alias prv "fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'"

alias cs "open $argv -a 'Cursor'"
alias vs "open $argv -a 'Visual Studio Code'"

# starship init fish | source
atuin init fish | source
zoxide init fish --cmd cd | source

# Added by Antigravity IDE
fish_add_path /Users/phnglh/.antigravity-ide/antigravity-ide/bin
