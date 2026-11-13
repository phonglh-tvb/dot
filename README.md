# dotfiles

Cấu hình máy macOS (Apple Silicon) hoặc Linux (Debian, Ubuntu, Pop!_OS): shell, terminal, editor, công cụ dev. Dựng máy mới bằng một lệnh; chạy lại bao nhiêu lần cũng được.

## Cài mới

```sh
git clone git@github.com:phonglh-tvb/dot.git ~/workspace/work/dot   # đặt ở đâu cũng được
cd ~/workspace/work/dot
./install.sh
```

`./install.sh` chạy lần lượt các bước dưới đây; muốn chạy riêng thì nêu tên, ví dụ `./install.sh link nvim`. `./install.sh --list` cho biết danh sách bước trên máy này (Linux có thêm `apt` và `fonts`).

| Bước | Làm gì |
|---|---|
| `apt` | (chỉ Linux) gói hệ thống trong [Aptfile](Aptfile): bộ build, thứ Homebrew cần, clipboard. Cần `sudo` |
| `brew` | cài Homebrew (Linuxbrew trên Linux) nếu chưa có, rồi `Brewfile` (lõi) và các nhóm `Brewfile.devops`, `Brewfile.apps`. Chọn nhóm bằng `DOT_PROFILES`, ví dụ `DOT_PROFILES="devops" ./install.sh brew`; để rỗng thì chỉ cài lõi. Mặc định macOS cài cả `devops` và `apps`, Linux chỉ `devops` (`apps` toàn cask, chỉ có trên macOS) |
| `lima` | (chỉ macOS) VM Lima `dev` chạy Docker (thay Docker Desktop) theo [lima/dev.yaml](lima/dev.yaml), rồi docker context `dev`. VM hoặc context đã có thì giữ nguyên, không khởi động lại gì ([docs/docker.md](docs/docker.md)) |
| `link` | symlink `config/` vào máy ([scripts/link.sh](scripts/link.sh)) |
| `hooks` | bật hook gitleaks cho repo này ([docs/secrets.md](docs/secrets.md)) |
| `fonts` | (chỉ Linux) JetBrainsMono và MartianMono Nerd Font vào `~/.local/share/fonts`, bản ghim kèm checksum ([scripts/fonts.sh](scripts/fonts.sh)); macOS dùng cask |
| `mise` | runtime (go, java, node, python, ruby, dotnet) và công cụ C# cho nvim (roslyn-language-server, netcoredbg, dotnet-aspnet-codegenerator) theo `config/mise/config.toml` |
| `rust` | rustup + toolchain stable, chỉ khi chưa có `~/.cargo/bin/rustup` |
| `nvim` | plugin Neovim (đúng commit trong `nvim-pack-lock.json`), công cụ Mason, parser treesitter. Lần đầu tải vài GB nên khá lâu |
| `odoo` | OdooLS (language server của Odoo) và typeshed vào `~/.local/share/nvim/odoo/`, bản ghim kèm checksum ([scripts/odoo-ls.sh](scripts/odoo-ls.sh)); bản đang có được giữ lại bên cạnh |

Còn vài việc phải làm tay vì cần mật khẩu / đăng nhập (script nhắc lại ở cuối): đặt fish làm shell mặc định (`chsh`), `gh auth login`, khoá SSH để ký commit, `~/.gitconfig-personal`.

## Tài liệu

| File | Nội dung |
|---|---|
| [docs/neovim.md](docs/neovim.md) | Neovim được dựng thế nào: plugin, công cụ, C#, Odoo. Cách dùng hằng ngày (phím tắt) ở [config/nvim/README.md](config/nvim/README.md) |
| [docs/docker.md](docs/docker.md) | Docker trong VM Lima, database dev, dọn Docker |
| [docs/shell.md](docs/shell.md) | fish, zsh tối thiểu, SSH |
| [docs/linux.md](docs/linux.md) | cài trên Debian, Ubuntu, Pop!_OS khác macOS ở đâu |
| [docs/secrets.md](docs/secrets.md) | giữ secret ngoài repo: 1Password, sops + age, gitleaks |
| [docs/specs/](docs/specs/README.md) | spec: thiết kế viết trước khi làm việc lớn, và vì sao chọn hướng đó |
| [CHANGELOG.md](CHANGELOG.md) | repo đã đổi gì, theo ngày |
| [AGENTS.md](AGENTS.md) | cách làm việc trong repo: nhánh, kiểm chứng, PR (cho cả người và AI agent) |

## Bố cục

```
config/            mọi cấu hình, link vào máy theo quy ước bên dưới
  nvim/            Neovim 0.12 thuần (vim.pack) + giao diện NvChad: LSP, format, debug, viết tài liệu
  fish/ tmux/ ghostty/ karabiner/ ...
  gh/ zed/         chỉ link từng file (config.yml, settings.json), xem Quy ước link
  .gitconfig       -> ~/.gitconfig
  .gitignore_global
  .zshenv .zprofile .zshrc   -> ~/   zsh tối thiểu (docs/shell.md)
install.sh         dựng máy mới theo từng bước
scripts/link.sh    symlink an toàn (xem dưới)
scripts/secrets.sh kiểm tra / quản lý secret (1Password, sops + age)
scripts/drift.sh   so máy với khai báo: cài mà chưa khai báo, khai báo mà chưa cài (chỉ đọc)
scripts/docker-clean.sh   liệt kê (và với --apply, dọn) Docker; không bao giờ tự xoá volume có tên
scripts/fonts.sh   Nerd Font cho Linux
scripts/odoo-ls.sh   OdooLS cho Neovim (Odoo), bản ghim kèm checksum
Brewfile           phần lõi: công cụ dòng lệnh
Brewfile.devops    cloud, Kubernetes, Terraform, giám sát
Brewfile.apps      ứng dụng đồ hoạ và font (macOS)
Aptfile            gói hệ thống cho Linux (bước apt)
lima/dev.yaml      cấu hình VM Lima chạy Docker (macOS)
docker/            database dev (Postgres, Valkey, Mongo, MySQL, SQL Server, Kafka) và pkg-scanner
ansible/           role `dot` (gọi scripts/link.sh) và `pkg-security` (trivy, osv-scanner, socket)
.githooks/         hook gitleaks chặn commit / push chứa secret
.github/           mẫu mô tả PR và CI (workflows/ci.yml)
docs/              tài liệu theo mảng (bảng trên); docs/specs/ chứa spec
CHANGELOG.md       thay đổi theo ngày, mới nhất ở trên
AGENTS.md          cách làm việc: phân tích yêu cầu, nhánh, kiểm chứng, PR (CLAUDE.md trỏ tới đây)
```

Quy ước link: mục trong `config/` bắt đầu bằng `.` thì link vào `~/<tên>`, còn lại link vào `~/.config/<tên>`. Thư mục có file `.link-each` thì chỉ link từng file bên trong, phần còn lại của thư mục đích giữ nguyên: `gh/config.yml` được theo dõi còn `gh/hosts.yml` (đăng nhập) thì không bao giờ vào repo; `zed/settings.json` được link còn `prompts/` (cơ sở dữ liệu của Zed) ở yên. Karabiner thì link nguyên thư mục vì tài liệu của nó yêu cầu thế (link riêng `karabiner.json` làm nó không nhận ra thay đổi); `automatic_backups/` nó tự ghi vào đó đã có trong `.gitignore`. Link của repo mà mục trong `config/` đã bị xoá (vd. `wezterm`, `alacritty`) thì lần `link.sh` sau tự gỡ. Vì là symlink nên sửa `~/.config/nvim/...` chính là sửa file trong repo; chỉ việc `git commit`.

## Việc thường làm

```sh
scripts/link.sh status     # xem link nào đúng / thiếu, không đổi gì
scripts/link.sh            # tạo / sửa link
scripts/link.sh unlink     # gỡ các link của repo này
scripts/drift.sh           # máy đang lệch khai báo ở đâu (Homebrew, mise), không đổi gì
scripts/docker-clean.sh    # Docker đang chiếm gì, cái nào dọn được (chỉ liệt kê; thêm --apply để dọn)
```

Thêm cấu hình mới: tạo `config/<tên>` rồi chạy `scripts/link.sh`.

Thêm gói: sửa tay đúng file `Brewfile*` (giữ thứ tự theo tên ngắn trong từng nhóm), rồi `scripts/drift.sh` để chắc máy và khai báo đã khớp. Không còn lệnh ghi đè Brewfile từ máy, vì một máy cụ thể không nên quyết định cả danh sách.

`link.sh` không bao giờ xoá đồ của bạn: file hay thư mục đang chiếm chỗ được chuyển vào `~/.dotfiles-backup/<thời gian>/` trước khi tạo link. Đích đã đúng thì bỏ qua nên chạy lại vô hại.

## Secret

Repo public, nên không chứa giá trị secret, chỉ có công cụ và tham chiếu: 1Password (`op`) là nguồn chính, sops + age cho file mã hoá, gitleaks chặn lỡ tay. Xem [docs/secrets.md](docs/secrets.md); `scripts/secrets.sh check` cho biết máy đang ở đâu.

## CI

Mỗi PR và mỗi lần đẩy lên `master` chạy [.github/workflows/ci.yml](.github/workflows/ci.yml): `shellcheck`, `shfmt`, `stylua --check`, `actionlint`, gitleaks (file và lịch sử); `hadolint` cho Dockerfile; rồi trên cả Ubuntu và macOS dựng cấu hình trong HOME giả (`link.sh` chạy hai lần phải không đổi gì), kiểm cú pháp zsh / fish, kiểm tmux chọn đúng lệnh clipboard; thêm job `install-linux` cài thật apt + Linuxbrew + font trên Ubuntu rồi đối chiếu bằng `drift.sh`. Chạy cùng các lệnh đó trên máy trước khi đẩy; công cụ có sẵn trong Brewfile.

## Ansible (tuỳ chọn)

`ansible/install` cài ansible bằng pipx rồi chạy role `dot` (chỉ gọi `scripts/link.sh`) và `pkg-security`. Dựng máy thì `./install.sh` là đủ.

## Không nằm trong repo

Cấu hình riêng của từng máy, không commit: `~/.gitconfig-personal` (danh tính cho `~/workspace/personal/`), `config/fish/fish_variables`, `.claude/settings.local.json`, `docker/.env`, và mọi thứ chứa đăng nhập như `~/.config/gh/hosts.yml`.
