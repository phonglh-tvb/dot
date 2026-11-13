# Changelog

Những thay đổi đáng kể của repo, mới nhất ở trên. Repo không đánh số phiên bản nên nhóm theo ngày merge; trong mỗi ngày chia **Thêm / Đổi / Sửa / Bỏ** theo tinh thần [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). `#số` là PR; mã 7 ký tự là commit từ trước khi repo dùng PR. Thiết kế của các việc lớn ở [docs/specs/](docs/specs/README.md).

Cách ghi một dòng mới: mục Commit và PR trong [AGENTS.md](AGENTS.md).

## 2026-11-13

### Thêm

- `CHANGELOG.md` (file này) và `docs/specs/` để viết spec trước khi làm việc lớn; spec đầu tiên là [SQL Server trên VM Lima](docs/specs/0001-lima-mssql.md). [#22]

### Đổi

- README gọn lại: phần Neovim, Docker và Lima, Linux, Shell và SSH chuyển sang `docs/`. [#22]
- Ghostty mở cửa sổ phóng to sẵn, font JetBrains Mono NL 14, padding theo màu viền, Option trái làm Alt, copy khi chọn, khôi phục cửa sổ, quick terminal bằng Option+`` ` ``. [#21]

### Bỏ

- Ghostty: `TERM=xterm-256color` và keybind backspace; `xterm-ghostty` đã khớp phím và có truecolor. [#21]

## 2026-11-08

### Thêm

- `config/nvim/README.md`: cách dùng Neovim hằng ngày (phím tắt cho file, LSP, terminal, debug; quy trình C#), thay bản mẫu của NvChad. [#20]

## 2026-11-05

### Thêm

- C# trong Neovim: LSP `roslyn.nvim` (có Razor), debug bằng `netcoredbg`, lệnh `:Scaffold` sinh controller, view, Razor Pages, Blazor, Minimal API từ model đang đứng. Công cụ cài bằng mise. [#19]

## 2026-10-31

### Thêm

- fish nạp khoá SSH từ Keychain một lần cho mỗi agent (macOS), để ký commit không hỏi lại passphrase sau khi khởi động máy. [#18]
- `navi` cho phím `prefix C-g` của tmux. [#14]
- Bước `./install.sh odoo`: OdooLS và typeshed ghim bản kèm sha256, bản cũ giữ lại bên cạnh. [#9]
- `lima/dev.yaml` và bước `./install.sh lima`; `scripts/docker-clean.sh`; hadolint trong CI; `dive`, `lazydocker`, `oha`; mặc định SSH dùng chung `config/ssh/defaults.conf` (tự bật bằng tay). [#7]
- Theo dõi cấu hình `gh`, `zed`, `karabiner`, `.gitalias`; file `.link-each` để chỉ link từng file trong thư mục; `fastfetch`. [#8]
- Hỗ trợ Debian, Ubuntu, Pop!_OS: bước `apt` và `fonts`, `Aptfile`, `scripts/fonts.sh`, job CI `install-linux`. [#6]
- CI: shellcheck, shfmt, stylua, actionlint, gitleaks; dựng cấu hình trong HOME giả trên Ubuntu và macOS. [#5]
- `scripts/drift.sh` so máy với khai báo; bước `rust`; pnpm trong mise. [#3]
- Cấu hình zsh tối thiểu (`.zshenv`, `.zprofile`, `.zshrc`). [#2]
- `AGENTS.md` (CLAUDE.md trỏ tới) và mẫu mô tả PR. [68ad9d8]
- Secret: hook gitleaks, `scripts/secrets.sh` (1Password, sops + age), `docs/secrets.md`. [0b65058]
- `install.sh` chạy theo bước; `scripts/link.sh` symlink an toàn, đồ đang chiếm chỗ được chuyển vào `~/.dotfiles-backup/` thay vì xoá. [8577490]

### Đổi

- tmux: thanh trạng thái và viền pane theo Rose Pine, cùng bảng màu với Ghostty và Neovim. [#17]
- Agent được tự merge PR của mình khi đủ bốn điều kiện. [#4]
- Brewfile tách thành lõi, `devops`, `apps`; chọn nhóm bằng `DOT_PROFILES`. [#3]
- Cập nhật plugin Neovim. [#10] [4d6e2ed]
- Neovim thuần 0.12: `vim.pack` thay lazy.nvim, completion và snippet có sẵn thay nvim-cmp và LuaSnip; bỏ bản phân phối NvChad nhưng giữ giao diện và bộ phím. [cc6a6b8]
- mise chọn Java theo major (`temurin-21`, `temurin-25`) để `mise upgrade` tự lên bản vá. [ed2912c]
- Ansible role `dot` gọi `scripts/link.sh` thay vì xoá file đang chiếm chỗ. [8577490]

### Sửa

- `secrets.sh encrypt` / `edit` tìm `.sops.yaml` cạnh file và không để lại file `.enc` rỗng khi lỗi. [#16]
- `pkg-scan-docker` tìm thư mục `pkg-scanner` theo vị trí repo. [#15]
- `secrets.sh check` nhận đúng 1Password CLI đã đăng nhập qua app. [#13]
- clangd cài bằng Mason, máy mới có LSP C/C++. [#11]
- fish chỉ nạp tích hợp Kiro khi đang ở trong Kiro; `secrets.sh` đọc quyền file đúng trên Linux. [#6]
- Đường dẫn khả chuyển trong fish, git, tmux; zsh hết báo `fnm: command not found`. [#2]

### Bỏ

- tmux-powerline (ghi đè thanh trạng thái). [#17]
- Plugin tmux `atppuccin/tmux` (gõ sai tên, chưa bao giờ cài được). [#14]
- `ghostty` và `openkey` khỏi `Brewfile.apps`. [#12]
- Cấu hình WezTerm và Alacritty. [#8]
- `dump.sh` (thay bằng `drift.sh`). [#3]
- oh-my-zsh và fnm. [#2]

## 2026-10-30

### Thêm

- Neovim cho web, Odoo, Rust, Go, Python, Java và viết tài liệu: LSP, formatter (conform), debug (nvim-dap). [2a72f8f]
- `typst`, `mactex`, `skim` để viết Typst / LaTeX. [9231e6f]
- git: difftool `nvimdiff`, danh tính riêng cho `~/workspace/personal/`, thêm mẫu ignore toàn cục. [5e8f978]
- fish: alias `eza`, tích hợp shell của Kiro. [189c44e]
- mise: dotnet. [a2b5cfa]

## 2026-08-19

### Đổi

- Thêm và cập nhật plugin Neovim. [86b5493]

## 2026-08-18

### Thêm

- Cấu hình đầu tiên: Neovim (lazy.nvim), tmux, WezTerm, Docker Compose (Postgres, MongoDB, MySQL, Kafka, pkg-scanner), Brewfile. [332c1a0]

### Đổi

- Tên người dùng git. [1434707]

[#22]: https://github.com/phonglh-tvb/dot/pull/22
[#21]: https://github.com/phonglh-tvb/dot/pull/21
[#20]: https://github.com/phonglh-tvb/dot/pull/20
[#19]: https://github.com/phonglh-tvb/dot/pull/19
[#18]: https://github.com/phonglh-tvb/dot/pull/18
[#17]: https://github.com/phonglh-tvb/dot/pull/17
[#16]: https://github.com/phonglh-tvb/dot/pull/16
[#15]: https://github.com/phonglh-tvb/dot/pull/15
[#14]: https://github.com/phonglh-tvb/dot/pull/14
[#13]: https://github.com/phonglh-tvb/dot/pull/13
[#12]: https://github.com/phonglh-tvb/dot/pull/12
[#11]: https://github.com/phonglh-tvb/dot/pull/11
[#10]: https://github.com/phonglh-tvb/dot/pull/10
[#9]: https://github.com/phonglh-tvb/dot/pull/9
[#8]: https://github.com/phonglh-tvb/dot/pull/8
[#7]: https://github.com/phonglh-tvb/dot/pull/7
[#6]: https://github.com/phonglh-tvb/dot/pull/6
[#5]: https://github.com/phonglh-tvb/dot/pull/5
[#4]: https://github.com/phonglh-tvb/dot/pull/4
[#3]: https://github.com/phonglh-tvb/dot/pull/3
[#2]: https://github.com/phonglh-tvb/dot/pull/2
[68ad9d8]: https://github.com/phonglh-tvb/dot/commit/68ad9d8
[0b65058]: https://github.com/phonglh-tvb/dot/commit/0b65058
[8577490]: https://github.com/phonglh-tvb/dot/commit/8577490
[4d6e2ed]: https://github.com/phonglh-tvb/dot/commit/4d6e2ed
[cc6a6b8]: https://github.com/phonglh-tvb/dot/commit/cc6a6b8
[ed2912c]: https://github.com/phonglh-tvb/dot/commit/ed2912c
[2a72f8f]: https://github.com/phonglh-tvb/dot/commit/2a72f8f
[9231e6f]: https://github.com/phonglh-tvb/dot/commit/9231e6f
[5e8f978]: https://github.com/phonglh-tvb/dot/commit/5e8f978
[189c44e]: https://github.com/phonglh-tvb/dot/commit/189c44e
[a2b5cfa]: https://github.com/phonglh-tvb/dot/commit/a2b5cfa
[86b5493]: https://github.com/phonglh-tvb/dot/commit/86b5493
[332c1a0]: https://github.com/phonglh-tvb/dot/commit/332c1a0
[1434707]: https://github.com/phonglh-tvb/dot/commit/1434707
