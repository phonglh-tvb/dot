# Phần lõi: công cụ dòng lệnh dùng hằng ngày. Cài kèm Brewfile.devops và Brewfile.apps (xem install.sh).
# Trong mỗi nhóm giữ thứ tự theo tên ngắn. Kiểm máy có lệch khai báo không: scripts/drift.sh
# Brewfile là Ruby: gói chỉ có trên macOS thì thêm `if OS.mac?` ở cuối dòng (Linuxbrew sẽ bỏ qua).

# Homebrew 7 từ chối tải formula của tap bên thứ ba chưa được tin (máy mới chưa chạy `brew trust`).
# Chỉ tin đúng từng formula bên dưới (`trusted: true`), không tin cả tap.
tap "xo/xo"

# shell, editor, git
brew "actionlint"
brew "age"
brew "atuin"
brew "bat"
brew "btop"
brew "direnv"
brew "eza"
brew "fd"
brew "fish"
brew "fzf"
brew "gh"
brew "git"
brew "git-delta"
brew "gitleaks"
brew "gnupg"
brew "jq"
brew "lazygit"
brew "mole" if OS.mac?
brew "neovim"
brew "ripgrep"
brew "shellcheck"
brew "shfmt"
brew "sops"
brew "ssh-copy-id"
brew "starship"
brew "stylua"
brew "tlrc"
brew "tmux"
brew "tree"
brew "yq"
brew "zoxide"

# runtime và công cụ ngôn ngữ (phiên bản chính do mise quản lý, xem config/mise)
brew "bun"
brew "buf"
brew "deno"
brew "lua"
brew "luarocks"
brew "mise"
brew "pipx"
brew "protobuf"
brew "typst"
brew "uv"

# container: trên macOS Lima chạy docker (không dùng Docker Desktop); trên Linux docker chạy thẳng, brew chỉ cài CLI
brew "docker"
brew "docker-buildx"
brew "docker-compose"
brew "lima" if OS.mac?
brew "podman-compose"

# cơ sở dữ liệu và gọi API
brew "duckdb"
brew "ffmpeg"
brew "grpcurl"
brew "hurl"
brew "mycli"
brew "pgcli"
brew "xo/xo/usql", trusted: true
brew "websocat"
brew "xh"

# quét lỗ hổng
brew "osv-scanner"
brew "trivy"

# thư viện build: python-ldap của Odoo cần openldap + cyrus-sasl; Rust cần lld + lldb
brew "cyrus-sasl"
brew "lld"
brew "lldb"
brew "openldap"
brew "pkgconf"
