# Shell đăng nhập: Homebrew rồi runtime do mise quản lý.
# Công cụ và IDE chạy zsh, nên mise dùng shims để lệnh `node`, `go`... đúng bản ở mọi nơi.
for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
  if [ -x "$brew_bin" ]; then
    eval "$("$brew_bin" shellenv)"
    break
  fi
done
unset brew_bin

command -v mise >/dev/null 2>&1 && eval "$(mise activate zsh --shims)"
