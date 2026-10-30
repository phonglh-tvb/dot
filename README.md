# dotfiles

Cấu hình máy macOS (Apple Silicon): shell, terminal, editor, công cụ dev. Dựng máy mới bằng một lệnh; chạy lại bao nhiêu lần cũng được.

## Cài mới

```sh
git clone git@github.com:phonglh-tvb/dot.git ~/workspace/work/dot   # đặt ở đâu cũng được
cd ~/workspace/work/dot
./install.sh
```

`./install.sh` chạy lần lượt các bước dưới đây; muốn chạy riêng thì nêu tên, ví dụ `./install.sh link nvim`.

| Bước | Làm gì |
|---|---|
| `brew` | cài Homebrew nếu chưa có, rồi mọi thứ trong `Brewfile` |
| `link` | symlink `config/` vào máy ([scripts/link.sh](scripts/link.sh)) |
| `mise` | runtime (go, java, node, python, ruby, dotnet) theo `config/mise/config.toml` |
| `nvim` | plugin Neovim (đúng commit trong `lazy-lock.json`), công cụ Mason, parser treesitter. Lần đầu tải vài GB nên khá lâu |

Còn vài việc phải làm tay vì cần mật khẩu / đăng nhập (script nhắc lại ở cuối): đặt fish làm shell mặc định (`chsh`), `gh auth login`, khoá SSH để ký commit, `~/.gitconfig-personal`.

## Bố cục

```
config/            mọi cấu hình, link vào máy theo quy ước bên dưới
  nvim/            Neovim (NvChad v2.5): LSP, format, debug, viết tài liệu
  fish/ tmux/ ghostty/ wezterm/ alacritty/ ...
  .gitconfig       -> ~/.gitconfig
  .gitignore_global
scripts/link.sh    symlink an toàn (xem dưới)
install.sh         dựng máy mới theo từng bước
dump.sh            ghi lại Brewfile từ những gì đang cài
Brewfile           formula + cask
ansible/           role `dot` (gọi scripts/link.sh) và `pkg-security` (trivy, osv-scanner, socket)
docker/            database dev (Postgres, Mongo, MySQL) và pkg-scanner
```

Quy ước link: mục trong `config/` bắt đầu bằng `.` thì link vào `~/<tên>`, còn lại link vào `~/.config/<tên>`. Vì là symlink nên sửa `~/.config/nvim/...` chính là sửa file trong repo; chỉ việc `git commit`.

## Việc thường làm

```sh
scripts/link.sh status     # xem link nào đúng / thiếu, không đổi gì
scripts/link.sh            # tạo / sửa link
scripts/link.sh unlink     # gỡ các link của repo này
./dump.sh                  # cập nhật Brewfile (xem `git diff Brewfile` trước khi commit)
```

Thêm cấu hình mới: tạo `config/<tên>` rồi chạy `scripts/link.sh`.

`link.sh` không bao giờ xoá đồ của bạn: file hay thư mục đang chiếm chỗ được chuyển vào `~/.dotfiles-backup/<thời gian>/` trước khi tạo link. Đích đã đúng thì bỏ qua nên chạy lại vô hại.

## Neovim

- Công cụ (LSP, formatter, debug adapter) khai báo một chỗ trong `config/nvim/lua/configs/tools.lua`; `mason-tool-installer` tự cài những gói còn thiếu.
- `lazy-lock.json` ghim phiên bản plugin. Cập nhật: `:Lazy update` rồi commit lockfile.
- Cài lại công cụ bằng tay: `:MasonToolsInstall`.

## Ansible (tuỳ chọn)

`ansible/install` cài ansible bằng pipx rồi chạy role `dot` (chỉ gọi `scripts/link.sh`) và `pkg-security`. Dựng máy thì `./install.sh` là đủ.

## Không nằm trong repo

Cấu hình riêng của từng máy, không commit: `~/.gitconfig-personal` (danh tính cho `~/workspace/personal/`), `~/.gitalias`, `config/fish/fish_variables`, `.claude/settings.local.json`.
