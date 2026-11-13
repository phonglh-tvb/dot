# Linux

Hỗ trợ Debian, Ubuntu và Pop!_OS (desktop). `./install.sh` chạy `apt` (gói hệ thống), `brew` (Linuxbrew, cùng danh sách công cụ như macOS), `link`, `hooks`, `fonts`, `mise`, `rust`, `nvim`, `odoo`. Khác macOS:

- Gói chỉ có trên macOS khai báo bằng `if OS.mac?` cuối dòng trong Brewfile (Brewfile là Ruby): `mole`, `lima`, và ba cask trong `Brewfile.devops`. `scripts/drift.sh` hiểu điều này và không đòi các gói đó trên Linux.
- Docker: brew chỉ cài CLI. Daemon cài tay (`sudo apt-get install docker.io`) và thêm vào nhóm `docker` nếu muốn dùng không cần `sudo`; nhóm này tương đương quyền root nên script không tự làm.
- Ứng dụng đồ hoạ (`Brewfile.apps`), Ghostty, Tailscale, gcloud, Cloudflare WARP: cài theo hướng dẫn của từng hãng.
- OdooLS (`odoo_ls_server`) cài bằng bước `odoo` (có bản cho macOS và Linux, x86_64 và arm64); nvim chỉ bật nó khi project có `odools.toml`.

Trong cấu hình fish, tmux và git, những chỗ gắn với macOS (`open -a`, `pbcopy`, đường dẫn `/opt/homebrew/bin/gh`) đã có nhánh cho Linux hoặc lấy theo PATH. `config/fish/conf.d/brew.fish` đưa Homebrew vào PATH khi shell chưa thấy `brew` (máy Linux mới); máy đã có `brew` trong PATH thì không đổi gì.

CI kiểm nhánh Linux trên Ubuntu: job `install-linux` cài thật apt, Linuxbrew và font rồi đối chiếu bằng `scripts/drift.sh`.
