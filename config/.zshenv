# Mọi zsh đọc file này, kể cả không tương tác (script, IDE): chỉ để PATH và biến môi trường tối thiểu.
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# lazygit trên macOS đọc ~/Library/Application Support/lazygit, nên cấu hình trong repo phải trỏ bằng biến
# (chi tiết ở config/fish/conf.d/lazygit.fish). Đặt ở .zshenv để cả zsh không tương tác cũng thấy.
lg_config="${XDG_CONFIG_HOME:-$HOME/.config}/lazygit/config.yml"
[ -f "$lg_config" ] && export LG_CONFIG_FILE="$lg_config"
unset lg_config
