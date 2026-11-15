# lazygit không theo XDG trên macOS: mặc định nó đọc ~/Library/Application Support/lazygit, nên cấu hình
# trong repo (link tới ~/.config/lazygit/config.yml) sẽ bị bỏ qua. LG_CONFIG_FILE trỏ thẳng vào file đó,
# dùng chung được cho cả macOS và Linux. Trạng thái của lazygit (state.yml, github_pull_requests.json)
# vẫn nằm ở thư mục mặc định của hệ, không vào repo.
set -l lg_dir "$HOME/.config/lazygit"
test -n "$XDG_CONFIG_HOME"; and set lg_dir "$XDG_CONFIG_HOME/lazygit"
test -f "$lg_dir/config.yml"; and set -gx LG_CONFIG_FILE "$lg_dir/config.yml"
