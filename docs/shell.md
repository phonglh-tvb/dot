# Shell, tmux và SSH

## Shell

Shell tương tác chính là fish (`config/fish`). Zsh vẫn có cấu hình tối thiểu vì công cụ và IDE hay chạy zsh: `.zprofile` nạp Homebrew và `mise` (shims, nên `node`, `go`... đúng bản ở mọi nơi), `.zshrc` chỉ có prompt starship, atuin, zoxide, direnv, fzf và vài alias. Không dùng oh-my-zsh.

Những chỗ gắn với macOS trong fish, tmux và git đã có nhánh cho Linux, xem [linux.md](linux.md).

## tmux

Prefix là `C-f`; `C-f C-f` gửi `C-f` thật xuống ứng dụng. Cấu hình ở
[config/tmux/tmux.conf](../config/tmux/tmux.conf), màu Rose Pine cùng bảng với Ghostty và Neovim.

| Phím | Làm gì |
|---|---|
| `prefix r` | nạp lại `tmux.conf` |
| `prefix Enter` | vào copy mode (vi: `v` chọn, `y` chép) |
| `prefix \` / `prefix -` | chia dọc / ngang, pane mới giữ thư mục hiện tại |
| `prefix t` | cửa sổ mới, giữ thư mục hiện tại |
| `prefix w` | đóng pane |
| `prefix e` | đóng mọi pane khác trong cửa sổ (hỏi lại trước) |
| `prefix h` / `prefix l` | cửa sổ trước / sau, giữ phím được |
| `prefix G` | lazygit trong popup 90% màn hình, mở ở thư mục của pane ([git.md](git.md)) |
| `prefix O` | mở thư mục của pane bằng Finder (macOS) hoặc `xdg-open` (Linux) |
| `prefix C-g` | navi: chọn một lệnh rồi dán vào pane vừa rời |
| `C-h` `C-j` `C-k` `C-l` | nhảy pane không cần prefix; đang ở trong nvim thì phím được gửi cho nvim |
| `M-,` / `M-.` | đổi chỗ pane với pane kế |

Phím của plugin: `prefix I` / `U` / `M-u` (tpm cài / cập nhật / dọn plugin), `prefix C-s` / `C-r`
(tmux-resurrect lưu / khôi phục session), `prefix j` (tmux-jump), `prefix y` / `Y` (tmux-yank),
`prefix g` (mở bảng phím `move` của tmux-tilish).

`tmux-tilish` mang bố cục kiểu i3 và chiếm toàn bộ phím `Alt`: `M-1`…`M-0` chuyển cửa sổ,
`M-h/j/k/l` chọn pane, `M-H/J/K/L` đổi chỗ pane, `M-s` / `M-v` / `M-t` đổi layout, `M-z` phóng to,
`M-Enter` pane mới, `M-Q` đóng pane, `M-n` đổi tên cửa sổ, `M-E` detach.

> Vì `run '~/.config/tmux/plugins/tpm/tpm'` nằm ở **cuối** `tmux.conf`, plugin gán phím sau repo. Hai
> dòng `bind -n 'M-h'`…`'M-l'` (resize pane) trong `tmux.conf` vì thế **không có tác dụng** — tilish gán
> lại đúng bốn phím đó thành chọn pane. Kiểm bằng `tmux list-keys -T root | grep 'M-h'`.

Lệnh chép vào clipboard chọn theo máy (`pbcopy`, `wl-copy`, `xclip`), xem [linux.md](linux.md).

## SSH

Repo chỉ giữ phần mặc định dùng chung ([config/ssh/defaults.conf](../config/ssh/defaults.conf): `AddKeysToAgent`, `UseKeychain` có `IgnoreUnknown` nên chạy được cả trên Linux, `ServerAliveInterval`); host, IP, user và khoá của từng máy ở `~/.ssh` và không bao giờ commit. `link.sh` không đụng `~/.ssh`. Muốn dùng thì tự thêm hai dòng vào **cuối** `~/.ssh/config` (xem chú thích trong file; `Match all` cần thiết để Include không bị gắn vào khối `Host` phía trên, và đặt ở cuối để host cụ thể thắng mặc định).

Khoá có passphrase thì lưu vào Keychain một lần: `/usr/bin/ssh-add --apple-use-keychain ~/.ssh/<khoá>` (dùng bản của macOS, bản Homebrew không có cờ này). Agent trống sau mỗi lần khởi động máy và `git commit` ký bằng khoá đó sẽ hỏi lại passphrase, nên [config/fish/conf.d/ssh-agent.fish](../config/fish/conf.d/ssh-agent.fish) nạp các khoá đã lưu khi mở shell fish đầu tiên sau khi agent khởi động (macOS, ~0,5 giây, một lần).

Ký commit bằng khoá trong 1Password thay vì khoá trên đĩa: xem mục khoá SSH trong [secrets.md](secrets.md).
