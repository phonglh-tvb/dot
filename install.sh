#!/bin/bash
# Dựng máy mới từ dotfiles này (macOS, hoặc Debian / Ubuntu / Pop!_OS). Chạy lại bao nhiêu lần cũng được.
#
#   ./install.sh               chạy tất cả các bước theo thứ tự
#   ./install.sh link nvim     chỉ chạy các bước nêu tên
#   ./install.sh --list        liệt kê các bước (khác nhau giữa macOS và Linux)
#   DOT_PROFILES="devops" ./install.sh brew    chọn nhóm Brewfile (mặc định macOS "devops apps", Linux "devops"; rỗng = chỉ lõi)
#
# Các bước:
#   apt    (chỉ Linux) gói hệ thống trong Aptfile: bộ build, công cụ Homebrew cần, clipboard
#   brew   Homebrew + Brewfile (lõi), rồi Brewfile.<nhóm> theo DOT_PROFILES
#   lima   VM Lima "dev" chạy Docker (lima/dev.yaml) + docker context; VM đã có thì giữ nguyên
#   link   symlink config/ vào ~ (scripts/link.sh; đồ có sẵn được backup, không bị xoá)
#   hooks  bật hook gitleaks (.githooks) cho repo dotfiles này: chặn commit / push chứa secret
#   fonts  (chỉ Linux) Nerd Font vào ~/.local/share/fonts (scripts/fonts.sh); macOS cài font bằng cask
#   mise   runtime (go, java, node, python...) theo config/mise/config.toml
#   rust   rustup + toolchain stable, chỉ khi chưa có ~/.cargo/bin/rustup
#   nvim   plugin Neovim (vim.pack), công cụ Mason (LSP, formatter, debugger), parser treesitter
#   odoo   OdooLS (language server của Odoo) cho Neovim: binary + typeshed (scripts/odoo-ls.sh); bản cũ được giữ lại

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS="$(uname -s)"
case "$OS" in
  Darwin)
    STEPS="brew lima link hooks mise rust nvim odoo"
    DEFAULT_PROFILES="devops apps"
    ;;
  Linux)
    STEPS="apt brew link hooks fonts mise rust nvim odoo"
    DEFAULT_PROFILES="devops" # Brewfile.apps toàn cask, chỉ có trên macOS
    ;;
  *)
    STEPS=""
    DEFAULT_PROFILES=""
    ;;
esac

have() {
  command -v "$1" &>/dev/null
}

die() {
  echo "lỗi: $*" >&2
  exit 1
}

as_root() {
  if [ "$(id -u)" -eq 0 ]; then "$@"; else sudo "$@"; fi
}

# Đưa brew vào PATH của phiên này; brew nằm ở đâu tuỳ máy (Apple Silicon, Intel, Linuxbrew)
brew_shellenv() {
  local brew_bin
  for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew "$HOME/.linuxbrew/bin/brew"; do
    if [ -x "$brew_bin" ]; then
      eval "$("$brew_bin" shellenv)"
      return 0
    fi
  done
  return 1
}

step_apt() {
  [ "$OS" = Linux ] || die "bước apt chỉ dành cho Linux"
  have apt-get || die "bước apt cần apt-get (Debian, Ubuntu, Pop!_OS); distro khác thì tự cài các gói trong Aptfile rồi chạy các bước còn lại"

  local pkgs=() pkg
  while IFS= read -r pkg; do
    pkgs+=("$pkg")
  done < <(sed -e 's/#.*//' -e 's/[[:space:]]*$//' -e '/^$/d' "$DIR/Aptfile")

  as_root apt-get update
  as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y "${pkgs[@]}"
}

step_brew() {
  # Homebrew nếu chưa có (đã cài mà chưa vào PATH, như Linuxbrew trong phiên mới, thì chỉ cần nạp shellenv)
  have brew || brew_shellenv || true
  if ! have brew; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew_shellenv || die "cài Homebrew xong mà không thấy brew ở các vị trí quen thuộc"
  fi

  # Brewfile là phần lõi; Brewfile.<nhóm> cài thêm theo DOT_PROFILES (đặt rỗng để chỉ cài lõi)
  local profiles="${DOT_PROFILES-$DEFAULT_PROFILES}" profile
  for profile in $profiles; do
    [ -f "$DIR/Brewfile.$profile" ] || die "không có nhóm '$profile' (có: $(find "$DIR" -maxdepth 1 -name 'Brewfile.*' | sed 's#.*/Brewfile\.##' | sort | tr '\n' ' '))"
  done

  # formula (+ cask trên macOS), tự giải quyết phụ thuộc
  brew bundle install --file="$DIR/Brewfile"
  for profile in $profiles; do
    if [ "$profile" = apps ] && [ "$OS" != Darwin ]; then
      echo "bỏ qua nhóm apps: toàn cask, chỉ có trên macOS"
      continue
    fi
    brew bundle install --file="$DIR/Brewfile.$profile"
  done
}

step_lima() {
  have limactl || die "chưa có limactl; chạy './install.sh brew' trước"
  have docker || die "chưa có docker (CLI); chạy './install.sh brew' trước"

  # VM đã có thì không đụng tới: tạo lại hay khởi động lại VM kéo theo mọi container
  if limactl list --quiet | grep -qx dev; then
    echo "VM dev đã có, giữ nguyên ($(limactl list dev --format '{{.Status}}')); đổi cấu hình thì sửa lima/dev.yaml rồi limactl edit dev"
  else
    limactl start --name=dev --tty=false "$DIR/lima/dev.yaml"
  fi

  # Chỉ tạo và chuyển sang context khi chưa có; máy đã có context dev thì giữ nguyên
  if ! docker context inspect dev &>/dev/null; then
    docker context create dev --docker "host=unix://$(limactl list dev --format '{{.Dir}}')/sock/docker.sock"
    docker context use dev
  fi
}

step_link() {
  "$DIR/scripts/link.sh" apply
}

step_hooks() {
  git -C "$DIR" config core.hooksPath .githooks
  have gitleaks || echo "chưa có gitleaks (brew install gitleaks): hook chỉ cảnh báo, chưa kiểm tra secret"
}

step_fonts() {
  [ "$OS" = Linux ] || die "bước fonts chỉ dành cho Linux (macOS cài font bằng cask trong Brewfile.apps)"
  "$DIR/scripts/fonts.sh"
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

step_odoo() {
  "$DIR/scripts/odoo-ls.sh"
}

next_steps() {
  cat <<'EOF'

Xong. Việc còn lại phải làm tay (cần mật khẩu / đăng nhập):
  - fish làm shell mặc định:  echo "$(command -v fish)" | sudo tee -a /etc/shells && chsh -s "$(command -v fish)"
  - GitHub:                   gh auth login
  - ký commit bằng SSH:       ~/.ssh/id_ed25519 và ~/.ssh/allowed_signers (xem config/.gitconfig)
  - danh tính riêng:          ~/.gitconfig-personal cho ~/workspace/personal/ (includeIf trong config/.gitconfig)
EOF
  if [ "$OS" = Linux ]; then
    cat <<'EOF'
  - Docker (daemon):          sudo apt-get install docker.io rồi sudo usermod -aG docker "$USER" (nhóm docker
                              tương đương quyền root, tự cân nhắc); brew chỉ cài phần CLI
  - terminal:                 chọn font "JetBrainsMono Nerd Font" (đã cài vào ~/.local/share/fonts); Ghostty
                              và các terminal khác tự cài, cấu hình mẫu ở config/ghostty
EOF
  fi
}

usage() {
  sed -n '2,19p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
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

  [ -n "$STEPS" ] || die "chỉ hỗ trợ macOS và Linux (Debian, Ubuntu, Pop!_OS); máy này là $OS"

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
