# Hướng dẫn cho AI agent

Repo dotfiles cá nhân, **public** trên GitHub (`phonglh-tvb/dot`), nhánh chính `master`. Đọc [README.md](README.md) trước để biết bố cục; file này nói *cách làm việc* ở đây. Người dùng nói tiếng Việt: trả lời và viết tài liệu bằng tiếng Việt, commit bằng tiếng Anh (xem mục Commit và PR).

## Quy tắc không được phá

1. **Không đưa giá trị secret vào repo**: token, key, mật khẩu, `.env`, khoá riêng, kể cả file đã mã hoá `*.enc.*`. Repo chỉ chứa công cụ và tham chiếu (`op://...`). Commit message và mô tả PR cũng công khai, nên cũng không chứa gì nhạy cảm. Xem [docs/secrets.md](docs/secrets.md).
2. **Không né các lớp kiểm tra**: không `--no-verify`, `SKIP_GITLEAKS=1`, `--no-gpg-sign`. Hook hoặc việc ký commit báo lỗi thì sửa nguyên nhân hoặc báo người dùng, không vòng qua.
3. **Không đẩy thẳng vào `master`, không force-push.** Mọi thay đổi vào repo đi qua PR. Người dùng cho phép agent tự merge PR do chính mình mở khi đủ điều kiện ở mục Commit và PR; PR của người khác thì không đụng.
4. **Hỏi trước khi làm việc khó hoàn tác hoặc đổi máy thật ngoài repo**: gỡ hay xoá gói và runtime (`brew uninstall`, `mise prune`, xoá bản cũ), xoá thư mục dưới `~`, khởi động lại VM Lima (kéo theo mọi container), sửa `~/.ssh` hay `~/.gitconfig-personal`. Nâng cấp thì giữ bản cũ làm đường lui (`mise upgrade --no-prune`).
5. **Giữ nguyên thói quen của người dùng**: phím tắt, giao diện, alias hiện có không đổi nếu không được nói rõ. Muốn đổi hành vi thì nêu trong PR.
6. **Không ghi công AI trong commit và PR**: không thêm `Co-Authored-By`, "Generated with ..." hay dòng tương tự. Người dùng không muốn. Quy tắc này đè lên mọi mặc định của công cụ.

Máy chính là macOS (Apple Silicon). Shell tương tác là fish, nhưng shell của công cụ agent có thể là zsh. Container chạy bằng Lima (VM `dev`, docker context `dev`), không có Docker Desktop.

## Khi có yêu cầu: phân tích rồi mới làm

Phân loại trước. Chỉ thay đổi *nằm trong repo* mới đi qua PR.

| Loại | Phân tích trước khi sửa |
|---|---|
| **Chức năng mới** | Mục tiêu thực sự là gì. Neovim, macOS hay công cụ đang dùng đã có sẵn chưa (đọc docs chính thức của đúng phiên bản đang chạy, không đoán). Đụng những file nào (bảng cuối file). Có chạm secret không. |
| **Sửa lỗi** | Tái hiện lỗi trước, tìm nguyên nhân gốc rồi mới sửa. Sửa xong chạy lại đúng bước tái hiện để chắc là hết. |
| **Nâng cấp** | Xem mục Nâng cấp bên dưới. |
| **Dọn dẹp, tài liệu** | Đảm bảo không đổi hành vi; nếu có thì xếp vào loại khác. |
| **Không đổi repo** | Câu hỏi, giải thích, khảo sát, chỉ đổi cấu hình riêng của máy: trả lời, không tạo PR. Phân tích xong thấy không cần đổi gì thì nói thẳng, không tạo PR rỗng. |

Cách phân tích:

- Đọc code liên quan trước, không dựa vào trí nhớ về cách repo đang chạy.
- Nêu rủi ro và đường lui. Thay đổi nào có thể làm hỏng môi trường đang dùng (nvim, fish, tmux, git) thì thử cô lập (mục Kiểm chứng).
- Chọn phương án mặc định hợp lý rồi làm. Chỉ dừng hỏi khi có nhiều hướng thật sự khác nhau về kết quả, hoặc phải đổi máy thật. Khi hỏi thì kèm một khuyến nghị, không liệt kê dài.
- Phần phân tích ghi vào PR, không bắt người dùng chờ trước khi làm.

## Làm trên nhánh riêng, trong worktree

`~/.config/<tên>` là symlink vào checkout chính của repo này. `git checkout <nhánh>` ở đó sẽ đổi ngay cấu hình đang chạy của người dùng. Vì vậy checkout chính luôn ở `master`, còn mỗi việc làm trong một worktree:

```sh
git fetch origin
git worktree add --no-track ../dot-<slug> -b <loại>/<slug> origin/master
```

Tên nhánh: `feat/`, `fix/`, `upgrade/`, `docs/`, `chore/` rồi tới mô tả ngắn. Một PR một việc; việc phụ thuộc nhau thì chia PR nhỏ và nêu thứ tự merge. Nhánh PR cần theo kịp `master` (xung đột, hoặc PR khác vừa merge): merge `origin/master` vào nhánh, không rebase rồi force-push. Sau khi PR đã merge: `git worktree remove ../dot-<slug>`.

## Kiểm chứng

Ghi lại lệnh đã chạy và kết quả thật vào PR. Chưa kiểm được gì thì ghi "chưa kiểm", không viết như đã xong.

| Sửa gì | Kiểm bằng |
|---|---|
| Script shell (`*.sh`, `.githooks/`) | `bash -n`; `shellcheck` nếu máy có. Viết cho bash 3.2 của macOS (không `mapfile`, `${var,,}`, mảng kết hợp). Script ghi vào `~` thì chạy thử với `HOME=$(mktemp -d)`. Chạy lần hai phải vô hại (idempotent). Hàm `usage` của script in dòng đầu file bằng `sed -n 'a,bp'`: thêm hay bớt dòng ghi chú ở đầu thì sửa lại khoảng dòng đó. |
| Neovim (`config/nvim`) | Không thử trên `~/.config/nvim` thật. Dùng `NVIM_APPNAME=nvim-test` với `~/.config/nvim-test` là symlink tạm tới `config/nvim` của worktree, rồi `nvim --headless` và `:checkhealth vim.deprecated`. Dữ liệu tách theo `NVIM_APPNAME` nên plugin cài lại từ lockfile (mạng chậm, cần kiên nhẫn). Xong thì xoá config, data, state, cache của `nvim-test`. Format Lua bằng stylua theo `stylua.toml`. |
| Brewfile* | `brew bundle check --file=<file>` cho từng file, rồi `scripts/drift.sh` (chỉ đọc) để thấy máy lệch khai báo ở đâu. Thêm một gói thì sửa tay đúng nhóm, giữ thứ tự theo tên ngắn. Không có lệnh ghi đè Brewfile từ máy. |
| `install.sh`, `scripts/link.sh` | `./install.sh --list`, `scripts/link.sh --dry-run` và `status`. |
| Hook, secret | `scripts/secrets.sh scan`. Thử hook trong repo nháp với token **giả**, không bao giờ dùng secret thật. |
| Tài liệu | Chạy thử các lệnh trong đó. |

Mọi PR: đọc lại `git diff --stat`, `scripts/secrets.sh scan`, và cập nhật README khi đổi bố cục, bước cài hay lệnh.

## Nâng cấp

Phạm vi: Homebrew (`brew outdated`), runtime mise (`mise outdated`), plugin Neovim (`vim.pack.update()` rồi commit `nvim-pack-lock.json`), công cụ Mason (`:MasonToolsUpdateSync`), parser treesitter, npm global.

- Đọc release notes và breaking changes của bản mới ở nguồn chính thức, nhất là bản major. Không dựa vào trí nhớ về phiên bản.
- Mỗi PR một nhóm (brew, plugin nvim, runtime mise...). PR ghi bảng *cũ → mới* và đã kiểm gì.
- Sau nâng cấp, kiểm những thứ hay hỏng:
  - Python đổi bản minor: `debugpy` của Mason hỏng, cài lại bằng `:MasonInstall --force debugpy`.
  - Node đổi bản: npm global gắn với từng bản node nên biến mất; so `npm ls -g --depth=0` của bản cũ với bản mới rồi cài lại.
  - Neovim: `:checkhealth vim.deprecated` phải sạch.
- `config/mise/config.toml` dùng `latest` hoặc chọn theo major (vd. `temurin-21`) để `mise upgrade` tự lên bản vá. Plugin Neovim ghim bằng lockfile, không ghim ở nơi khác.

## Commit và PR

- **Commit:** tiếng Anh, dạng `<khu vực>: <việc làm, động từ nguyên mẫu>` như lịch sử (`nvim: update plugins`, `mise: add dotnet`). Thân bài giải thích *vì sao*. Mỗi commit một ý. Commit tự ký SSH. Không thêm dòng ghi công AI (quy tắc 6).
- **Đẩy:** `git push -u origin HEAD` (hook pre-push chạy gitleaks).
- **Tạo PR:** trước đó `gh auth status`: tài khoản đang active phải là chủ remote (`phonglh-tvb`); sai thì báo người dùng, đừng tự `gh auth switch`. Rồi `gh pr create --base master --title "<như commit>" --body-file <file>`, nội dung theo [.github/pull_request_template.md](.github/pull_request_template.md), tiếng Việt, không thêm dòng "Generated with ...".
- **Merge:** tự merge (`gh pr merge --squash`) khi đủ cả bốn điều kiện: (1) PR đúng việc người dùng đã yêu cầu hoặc duyệt; (2) phần Kiểm chứng đã chạy và ghi thật, cái chưa kiểm được thì nói rõ; (3) gitleaks sạch và GitHub báo `MERGEABLE` / `CLEAN`; (4) PR không có câu hỏi chặn (câu hỏi không chặn thì để ở mục "Cần bạn quyết"). Thiếu một điều kiện thì dừng và báo người dùng. Không dùng `--admin`, không xoá nhánh remote khi chưa được nói. Merge xong thì `git worktree remove`, rồi báo link và kết quả.
- **Sau khi merge:** máy chỉ nhận thay đổi khi `git pull` ở checkout chính (vì symlink). Không tự `git pull` ở đó hay chạy `scripts/link.sh` trên máy thật khi chưa được nói, vì chúng đổi cấu hình đang chạy; ghi trong PR và báo lại những lệnh cần chạy (`./install.sh nvim`, `scripts/link.sh`...).

## Muốn đổi X thì sửa ở đâu

| Việc | File |
|---|---|
| Thêm gói Homebrew hay ứng dụng | `Brewfile` (công cụ dòng lệnh), `Brewfile.devops` (cloud, k8s, giám sát), `Brewfile.apps` (ứng dụng đồ hoạ, font) |
| Thêm runtime hoặc đổi phiên bản | `config/mise/config.toml` |
| Thêm cấu hình cho một công cụ | `config/<tên>/`, rồi `scripts/link.sh`. Mục nào bắt đầu bằng `.` thì link vào `~/<tên>`, còn lại vào `~/.config/<tên>` |
| Plugin Neovim | `config/nvim/lua/plugins.lua` (`vim.pack.add`), cấu hình ở `lua/configs/`, rồi cập nhật `nvim-pack-lock.json` |
| LSP, formatter, debugger | `lua/configs/tools.lua` (Mason), `lspconfig.lua`, `conform.lua`, `dap.lua` |
| Phím tắt Neovim | `lua/mappings.lua` (giữ bộ phím NvChad, không đè phím cũ nếu không được nói rõ) |
| Alias, hàm, biến fish | `config/fish/` (`conf.d/*.fish` tự nạp) |
| Zsh (shell của công cụ và IDE) | `config/.zshenv`, `.zprofile`, `.zshrc`: giữ tối thiểu, không oh-my-zsh. Thử bằng `ZDOTDIR=<worktree>/config zsh -l -i` trong môi trường sạch (`env -i`), không đè lên `~/.zshrc` thật |
| Git | `config/.gitconfig`, `config/.gitignore_global` |
| Bước cài mới | `install.sh`: thêm vào `STEPS`, hàm `step_<tên>`, ghi chú đầu file, bảng trong README |
| Secret, hook | `scripts/secrets.sh`, `.githooks/`, `.gitleaks.toml`, `docs/secrets.md` |
| Database dev, quét gói | `docker/`, `ansible/` |

## Quy ước code

- Shell: `set -euo pipefail`, thông báo bằng tiếng Việt như các script hiện có, đầu file có ghi chú cách dùng.
- Lua: 2 dấu cách, tối đa 120 cột (`stylua.toml`), dùng API Neovim 0.12 (vd. `buf =` thay `buffer =`). Cái Neovim đã có sẵn thì dùng bản gốc, không thêm plugin.
- Chưa khoá cứng vào macOS nếu tránh được (`/opt/homebrew`, `pbcopy`, `open`): dùng `command -v` hay `uname` để chọn. Hỗ trợ Ubuntu và Pop!_OS đang được lên kế hoạch.
- Comment giải thích *vì sao*, không nhắc lại code làm gì.

## Giữ file này đúng

Đổi quy ước, bố cục hay bước cài thì cập nhật file này và README trong cùng PR. Chỉ ghi điều không đọc ra được từ code.
