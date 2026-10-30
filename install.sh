#!/bin/bash
# Dựng máy mới từ dotfiles này. Chạy lại bao nhiêu lần cũng được.
#
#   ./install.sh               chạy tất cả các bước theo thứ tự
#   ./install.sh link nvim     chỉ chạy các bước nêu tên
#   ./install.sh --list        liệt kê các bước
#
# Các bước:
#   brew   Homebrew + mọi thứ trong Brewfile
#   link   symlink config/ vào ~ (scripts/link.sh; đồ có sẵn được backup, không bị xoá)
#   mise   runtime (go, java, node, python...) theo config/mise/config.toml
#   nvim   plugin Neovim, công cụ Mason (LSP, formatter, debugger), parser treesitter

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STEPS="brew link mise nvim"

have() {
  command -v "$1" &>/dev/null
}

die() {
  echo "lỗi: $*" >&2
  exit 1
}

step_brew() {
  # Homebrew nếu chưa có
  have brew || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Đưa brew vào PATH của phiên này (Apple Silicon mặc định)
  have brew || eval "$(/opt/homebrew/bin/brew shellenv)"

  # Cài mọi thứ trong Brewfile (formula + cask, tự giải quyết phụ thuộc)
  brew bundle install --file="$DIR/Brewfile"
}

step_link() {
  "$DIR/scripts/link.sh" apply
}

step_mise() {
  have mise || die "chưa có mise; chạy './install.sh brew link' trước"
  [ -e "${XDG_CONFIG_HOME:-$HOME/.config}/mise/config.toml" ] || die "chưa có ~/.config/mise; chạy './install.sh link' trước"

  mise install
}

step_nvim() {
  have nvim || die "chưa có nvim; chạy './install.sh brew' trước"
  [ -e "${XDG_CONFIG_HOME:-$HOME/.config}/nvim/init.lua" ] || die "chưa có ~/.config/nvim; chạy './install.sh link' trước"

  # Thứ tự quan trọng: plugin -> công cụ Mason (có tree-sitter-cli) -> parser treesitter.
  # "restore" cài đúng commit trong lazy-lock.json (tái lập được, không làm bẩn repo);
  # muốn lên bản mới thì chạy tay ":Lazy update" trong nvim.
  echo "plugin..."
  nvim --headless "+Lazy! restore" +qa
  echo "công cụ Mason..."
  nvim --headless "+MasonToolsInstallSync" +qa
  echo "parser treesitter..."
  nvim --headless "+lua require('nvim-treesitter').install(require('lazy.core.config').plugins['nvim-treesitter'].opts.ensure_installed):wait(600000)" +qa
}

next_steps() {
  cat <<'EOF'

Xong. Việc còn lại phải làm tay (cần mật khẩu / đăng nhập):
  - fish làm shell mặc định:  echo "$(command -v fish)" | sudo tee -a /etc/shells && chsh -s "$(command -v fish)"
  - GitHub:                   gh auth login
  - ký commit bằng SSH:       ~/.ssh/id_ed25519 và ~/.ssh/allowed_signers (xem config/.gitconfig)
  - danh tính riêng:          ~/.gitconfig-personal cho ~/workspace/personal/ (includeIf trong config/.gitconfig)
EOF
}

usage() {
  sed -n '2,13p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

main() {
  case "${1:-}" in
    -h | --help)
      usage
      return
      ;;
    --list)
      echo "$STEPS" | tr ' ' '\n'
      return
      ;;
  esac

  [ "$(uname -s)" = Darwin ] || die "chỉ hỗ trợ macOS"

  local requested="${*:-$STEPS}" step
  for step in $requested; do
    case " $STEPS " in
      *" $step "*) ;;
      *) die "bước không có: $step (có: $STEPS)" ;;
    esac
  done

  for step in $requested; do
    printf '\n==> %s\n' "$step"
    "step_$step"
  done

  # Chỉ nhắc khi chạy trọn bộ
  [ $# -gt 0 ] || next_steps
}

main "$@"
