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
| `hooks` | bật hook gitleaks cho repo này ([docs/secrets.md](docs/secrets.md)) |
| `mise` | runtime (go, java, node, python, ruby, dotnet) theo `config/mise/config.toml` |
| `nvim` | plugin Neovim (đúng commit trong `nvim-pack-lock.json`), công cụ Mason, parser treesitter. Lần đầu tải vài GB nên khá lâu |

Còn vài việc phải làm tay vì cần mật khẩu / đăng nhập (script nhắc lại ở cuối): đặt fish làm shell mặc định (`chsh`), `gh auth login`, khoá SSH để ký commit, `~/.gitconfig-personal`.

## Bố cục

```
config/            mọi cấu hình, link vào máy theo quy ước bên dưới
  nvim/            Neovim 0.12 thuần (vim.pack) + giao diện NvChad: LSP, format, debug, viết tài liệu
  fish/ tmux/ ghostty/ wezterm/ alacritty/ ...
  .gitconfig       -> ~/.gitconfig
  .gitignore_global
  .zshenv .zprofile .zshrc   -> ~/   zsh tối thiểu (xem dưới)
scripts/link.sh    symlink an toàn (xem dưới)
scripts/secrets.sh kiểm tra / quản lý secret (1Password, sops + age)
.githooks/         hook gitleaks chặn commit / push chứa secret
docs/secrets.md    cách giữ secret ngoài repo
AGENTS.md          hướng dẫn cho AI agent: phân tích yêu cầu, nhánh, kiểm chứng, PR (CLAUDE.md trỏ tới đây)
.github/           mẫu mô tả PR
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

## Shell

Shell tương tác chính là fish (`config/fish`). Zsh vẫn có cấu hình tối thiểu vì công cụ và IDE hay chạy zsh: `.zprofile` nạp Homebrew và `mise` (shims, nên `node`, `go`... đúng bản ở mọi nơi), `.zshrc` chỉ có prompt starship, atuin, zoxide, direnv, fzf và vài alias. Không dùng oh-my-zsh.

Trong cấu hình fish, tmux và git, những chỗ gắn với macOS (`open -a`, `pbcopy`, đường dẫn `/opt/homebrew/bin/gh`) đã có nhánh cho Linux hoặc lấy theo PATH. `install.sh` thì vẫn chỉ chạy trên macOS.

## Neovim

Cấu hình thuần Neovim 0.12, không dùng NvChad (bản distribution) hay lazy.nvim. Những gì Neovim đã có sẵn thì dùng bản gốc: `vim.pack` (quản lý plugin), `vim.lsp.config` / `vim.lsp.enable`, completion và snippet LSP (`vim.lsp.completion`, `vim.snippet`), `gc` để comment, treesitter highlight. Giao diện (statusline, tabufline, nvdash, đổi theme) vẫn là plugin `nvchad/ui` + `nvchad/base46`, chạy độc lập.

```
init.lua                 vào cấu hình
lua/plugins.lua          danh sách plugin (vim.pack) + hook build
lua/options.lua          tuỳ chọn (gồm mặc định NvChad đã chép lại)
lua/mappings.lua         phím tắt (giữ nguyên bộ phím NvChad)
lua/autocmds.lua         indent theo ngôn ngữ, viết tài liệu, Java
lua/configs/             lspconfig, conform, dap, jdtls, rust, tools (danh sách Mason), ui, writing
nvim-pack-lock.json      commit của từng plugin (đưa vào git)
```

- Plugin ghim bằng `nvim-pack-lock.json`: máy mới mở nvim (hoặc `./install.sh nvim`) là cài đúng commit.
- Cập nhật plugin: `:lua vim.pack.update()`, xem thay đổi, `:write` để chấp nhận, rồi commit lockfile. Hoàn lại: `git checkout HEAD -- nvim-pack-lock.json` rồi `:restart`.
- Công cụ (LSP, formatter, debug adapter) khai báo một chỗ trong `lua/configs/tools.lua`; `mason-tool-installer` tự cài những gói còn thiếu. Cài lại bằng tay: `:MasonToolsInstall`.
- Cài plugin bị ngắt giữa chừng: khởi động sau sẽ tự xoá thư mục hỏng và cài lại.

## Secret

Repo public, nên không chứa giá trị secret, chỉ có công cụ và tham chiếu: 1Password (`op`) là nguồn chính, sops + age cho file mã hoá, gitleaks chặn lỡ tay. Xem [docs/secrets.md](docs/secrets.md); `scripts/secrets.sh check` cho biết máy đang ở đâu.

## Ansible (tuỳ chọn)

`ansible/install` cài ansible bằng pipx rồi chạy role `dot` (chỉ gọi `scripts/link.sh`) và `pkg-security`. Dựng máy thì `./install.sh` là đủ.

## Không nằm trong repo

Cấu hình riêng của từng máy, không commit: `~/.gitconfig-personal` (danh tính cho `~/workspace/personal/`), `~/.gitalias`, `config/fish/fish_variables`, `.claude/settings.local.json`.
