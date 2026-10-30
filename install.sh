#!/bin/bash
# Dựng máy mới từ dotfiles này. Chạy lại bao nhiêu lần cũng được.
#
#   ./install.sh               chạy tất cả các bước theo thứ tự
#   ./install.sh link nvim     chỉ chạy các bước nêu tên
#   ./install.sh --list        liệt kê các bước
#   DOT_PROFILES="devops" ./install.sh brew    chọn nhóm Brewfile (mặc định "devops apps"; rỗng = chỉ lõi)
#
# Các bước:
#   brew   Homebrew + Brewfile (lõi), rồi Brewfile.<nhóm> theo DOT_PROFILES
#   link   symlink config/ vào ~ (scripts/link.sh; đồ có sẵn được backup, không bị xoá)
#   hooks  bật hook gitleaks (.githooks) cho repo dotfiles này: chặn commit / push chứa secret
#   mise   runtime (go, java, node, python...) theo config/mise/config.toml
#   rust   rustup + toolchain stable, chỉ khi chưa có ~/.cargo/bin/rustup
#   nvim   plugin Neovim (vim.pack), công cụ Mason (LSP, formatter, debugger), parser treesitter

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STEPS="brew link hooks mise rust nvim"

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

  # Brewfile là phần lõi; Brewfile.<nhóm> cài thêm theo DOT_PROFILES (đặt rỗng để chỉ cài lõi)
  local profile
  for profile in ${DOT_PROFILES-devops apps}; do
    [ -f "$DIR/Brewfile.$profile" ] || die "không có nhóm '$profile' (có: $(find "$DIR" -maxdepth 1 -name 'Brewfile.*' | sed 's#.*/Brewfile\.##' | sort | tr '\n' ' '))"
  done

  # formula + cask, tự giải quyết phụ thuộc
  brew bundle install --file="$DIR/Brewfile"
  for profile in ${DOT_PROFILES-devops apps}; do
    brew bundle install --file="$DIR/Brewfile.$profile"
  done
}

step_link() {
  "$DIR/scripts/link.sh" apply
}

step_hooks() {
  git -C "$DIR" config core.hooksPath .githooks
  have gitleaks || echo "chưa có gitleaks (brew install gitleaks): hook chỉ cảnh báo, chưa kiểm tra secret"
}

step_mise() {
  have mise || die "chưa có mise; chạy './install.sh brew link' trước"
  [ -e "${XDG_CONFIG_HOME:-$HOME/.config}/mise/config.toml" ] || die "chưa có ~/.config/mise; chạy './install.sh link' trước"

  mise install
}

step_rust() {
  if [ -x "$HOME/.cargo/bin/rustup" ]; then
    echo "rustup đã có"
    return
  fi

  # --no-modify-path: PATH do config/fish/conf.d/rustup.fish và config/.zshenv lo
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
}

step_nvim() {
  have nvim || die "chưa có nvim; chạy './install.sh brew' trước"
  [ -e "${XDG_CONFIG_HOME:-$HOME/.config}/nvim/init.lua" ] || die "chưa có ~/.config/nvim; chạy './install.sh link' trước"

  # Thứ tự quan trọng: plugin -> công cụ Mason (có tree-sitter-cli) -> parser treesitter.
  # vim.pack cài đúng commit trong nvim-pack-lock.json (tái lập được, không làm bẩn repo);
  # muốn lên bản mới thì chạy tay ":lua vim.pack.update()" trong nvim.
  echo "plugin..."
  # vim.pack có thể hết thời gian khi mạng chậm; chạy lại sẽ cài nốt phần còn thiếu.
  # Exit code của nvim luôn là 0 kể cả khi init lỗi, nên kiểm tra thực tế: thư mục plugin có file.
  local attempt
  for attempt in 1 2 3; do
    nvim --headless "+qa" || true
    nvim --headless '+lua for _, p in ipairs(vim.pack.get(nil, { info = false })) do if vim.fn.isdirectory(p.path) == 0 or #vim.fn.readdir(p.path) <= 1 then vim.cmd "cq" end end' +qa && break
    [ "$attempt" -lt 3 ] || die "cài plugin Neovim chưa đủ sau 3 lần; kiểm tra mạng rồi chạy lại './install.sh nvim'"
    echo "chưa đủ plugin, thử lại ($attempt/3)..."
  done
  echo "công cụ Mason..."
  nvim --headless "+MasonToolsInstallSync" +qa
  echo "parser treesitter..."
  nvim --headless "+lua require('configs.treesitter').install():wait(600000)" +qa
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
  sed -n '2,16p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
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
