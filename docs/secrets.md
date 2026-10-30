# Secret trên máy local

Repo này là **public**. Nguyên tắc: repo chỉ chứa công cụ và *tham chiếu* tới secret, không bao giờ chứa giá trị secret.

| Loại | Lưu ở đâu | Dùng thế nào |
|---|---|---|
| Token, API key, mật khẩu | 1Password | `op run` / `op read` (cách 1) |
| File secret cần mang theo máy khác | `~/.secrets` mã hoá bằng sops + age, repo **private** | `secrets.sh exec` (cách 2) |
| Khoá riêng age | file `~/.config/sops/age/keys.txt` + bản sao lưu trong 1Password | gốc tin cậy của cách 2 |
| Khoá SSH | trên đĩa (hiện tại) hoặc trong 1Password SSH agent (tuỳ chọn) | xem bên dưới |

`scripts/secrets.sh check` cho biết máy đang ở đâu: công cụ nào đã cài, quyền file, cách ký commit.

## Cách 1: 1Password

`1password` và `1password-cli` đã có trong Brewfile. Bật tích hợp CLI trong app: Settings > Developer > *Integrate with 1Password CLI*.

```sh
# file tham chiếu chỉ chứa op://..., không chứa giá trị; đặt tên env.tpl vì .env.* bị gitignore toàn cục
echo 'DATABASE_URL=op://Dev/myapp-db/url' > env.tpl
op run --env-file=env.tpl -- npm run dev      # secret chỉ tồn tại trong tiến trình con

# trong .envrc (đã nằm trong .gitignore_global) cùng direnv
export STRIPE_KEY="$(op read 'op://Dev/stripe/credential')"
```

### Khoá SSH và ký commit bằng 1Password (tuỳ chọn, chưa bật)

Hiện `commit.gpgsign = true` ký bằng `~/.ssh/id_ed25519` trên đĩa. Chuyển sang 1Password để khoá riêng không còn nằm trên đĩa:

1. Import khoá vào 1Password (hoặc tạo khoá mới), Settings > Developer > *Use the SSH agent*.
2. Copy đúng đoạn cấu hình mà app hiển thị vào `~/.ssh/config` (dòng `IdentityAgent ...`).
3. Trong `~/.gitconfig-personal` hoặc `config/.gitconfig` đổi:
   ```
   [user]
       signingKey = ssh-ed25519 AAAA...        # khoá công khai, copy từ 1Password
   [gpg "ssh"]
       program = /Applications/1Password.app/Contents/MacOS/op-ssh-sign
   ```
4. Thử `git commit --allow-empty -m test` ở một repo nháp trước. Chưa chắc chắn thì đừng đổi `config/.gitconfig`, vì commit sẽ lỗi ký.

## Cách 2: sops + age

```sh
scripts/secrets.sh age-init               # tạo khoá age; sao lưu NGAY vào 1Password (lệnh gợi ý được in ra)
scripts/secrets.sh init                   # tạo ~/.secrets có .sops.yaml; đẩy lên repo PRIVATE nếu muốn đồng bộ
scripts/secrets.sh edit ~/.secrets/app.enc.yaml
scripts/secrets.sh exec ~/.secrets/app.enc.yaml -- ./run.sh   # secret là biến môi trường của lệnh, không lộ ra shell
```

Đừng commit file `*.enc.*` vào repo public này: bản mã hoá vẫn nằm lại mãi trên mạng và sẽ đọc được nếu khoá age lộ sau này.

Hai cách bổ trợ nhau: khoá age là gốc của cách 2 và được cất trong 1Password (cách 1).

## Lưới an toàn

- **Hook gitleaks** chặn commit / push chứa secret: `./install.sh hooks` bật cho repo này, `scripts/secrets.sh hooks <repo>` cài cho repo khác. Bỏ qua có chủ đích bằng `SKIP_GITLEAKS=1`. `scripts/secrets.sh scan` quét cả thư mục lẫn lịch sử.
- **`.gitignore_global`** chặn `.env*` (trừ `.env.example`), `*.pem`, `*.key`, `id_*` (trừ `.pub`), `*.dec.*`...
- **atuin** bỏ khỏi lịch sử lệnh những dòng chứa khoá AWS, token GitHub, Stripe... (`secrets_filter`), lịch sử chỉ ở máy vì chưa đăng nhập sync.
- fish: đừng `set -Ux` một secret, nó ghi plain text vào `fish_variables`.

## Lỡ commit secret

1. **Thu hồi và tạo khoá mới ngay.** Xoá khỏi lịch sử không cứu được khoá đã lên repo public, vì có thể đã bị quét.
2. Rồi mới dọn lịch sử (`git filter-repo`) và force-push.
