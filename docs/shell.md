# Shell và SSH

## Shell

Shell tương tác chính là fish (`config/fish`). Zsh vẫn có cấu hình tối thiểu vì công cụ và IDE hay chạy zsh: `.zprofile` nạp Homebrew và `mise` (shims, nên `node`, `go`... đúng bản ở mọi nơi), `.zshrc` chỉ có prompt starship, atuin, zoxide, direnv, fzf và vài alias. Không dùng oh-my-zsh.

Những chỗ gắn với macOS trong fish, tmux và git đã có nhánh cho Linux, xem [linux.md](linux.md).

## SSH

Repo chỉ giữ phần mặc định dùng chung ([config/ssh/defaults.conf](../config/ssh/defaults.conf): `AddKeysToAgent`, `UseKeychain` có `IgnoreUnknown` nên chạy được cả trên Linux, `ServerAliveInterval`); host, IP, user và khoá của từng máy ở `~/.ssh` và không bao giờ commit. `link.sh` không đụng `~/.ssh`. Muốn dùng thì tự thêm hai dòng vào **cuối** `~/.ssh/config` (xem chú thích trong file; `Match all` cần thiết để Include không bị gắn vào khối `Host` phía trên, và đặt ở cuối để host cụ thể thắng mặc định).

Khoá có passphrase thì lưu vào Keychain một lần: `/usr/bin/ssh-add --apple-use-keychain ~/.ssh/<khoá>` (dùng bản của macOS, bản Homebrew không có cờ này). Agent trống sau mỗi lần khởi động máy và `git commit` ký bằng khoá đó sẽ hỏi lại passphrase, nên [config/fish/conf.d/ssh-agent.fish](../config/fish/conf.d/ssh-agent.fish) nạp các khoá đã lưu khi mở shell fish đầu tiên sau khi agent khởi động (macOS, ~0,5 giây, một lần).

Ký commit bằng khoá trong 1Password thay vì khoá trên đĩa: xem mục khoá SSH trong [secrets.md](secrets.md).
