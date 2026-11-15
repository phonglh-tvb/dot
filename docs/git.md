# Git

Cấu hình git của repo này nằm ở ba file, link vào `~` bằng [scripts/link.sh](../scripts/link.sh):

| File trong repo | Link tới | Chứa gì |
|---|---|---|
| `config/.gitconfig` | `~/.gitconfig` | danh tính, ký commit, `delta` làm pager, difftool `nvimdiff`, `[include]` ba file dưới |
| `config/.gitalias` | `~/.gitalias` | chỉ `[alias]`, tách riêng cho dễ đọc (bảng bên dưới) |
| `config/.gitignore_global` | `~/.gitignore_global` | thứ không bao giờ muốn commit ở bất kỳ repo nào |

Hai file **không** nằm trong repo vì chứa thông tin riêng:

- `~/.gitconfig-personal` — danh tính cho `~/workspace/personal/`, được `[includeIf "gitdir:~/workspace/personal/"]` nạp.
- `~/.ssh/allowed_signers` — khoá công khai dùng để xác minh commit đã ký. Xem [secrets.md](secrets.md).

## Alias

| Alias | Lệnh thật | Ghi chú |
|---|---|---|
| `git st` | `status` | |
| `git co` | `checkout` | |
| `git br` | `branch` | |
| `git ba` | `branch -a` | kể cả nhánh remote |
| `git bm` / `git bn` | `branch --merged` / `--no-merged` | nhánh đã / chưa merge vào HEAD, dùng khi dọn nhánh cũ |
| `git ci` / `git cm` | `commit` | `ci` trước đây trỏ vào `checkin` (không phải lệnh git) nên luôn lỗi |
| `git df` | `diff` | |
| `git cp` | `cherry-pick` | |
| `git lg` | `log --graph` một dòng mỗi commit | chỉ nhánh hiện tại |
| `git hist` | như `lg` nhưng `--all`, ngày tương đối | xem nhánh nào đang ở đâu so với `master` |
| `git open` | `gh browse` | mở repo trên GitHub; `git open -n` chỉ in URL, `git open <file>` mở đúng file |
| `git unmerged` | liệt kê file đang xung đột | |
| `git edit-unmerged` | mở các file đó bằng `$EDITOR` (mặc định `nvim`) | không có file nào thì chỉ in thông báo, không mở editor rỗng |
| `git add-unmerged` | `git add` các file đó | chạy sau khi đã sửa hết xung đột |

Cần alias mới thì sửa `config/.gitalias` rồi cập nhật bảng này. Alias dạng `!...` chạy bằng `sh`, nên viết cho shell POSIX (không dùng cú pháp riêng của fish hay bash).

## Commit message

Repo này và các repo đi theo quy ước [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/), soạn bằng `cz c` (commitizen). Quy ước đầy đủ — loại nào dùng khi nào, khu vực đặt tên thế nào — ở mục Commit và PR trong [AGENTS.md](../AGENTS.md); cấu hình các câu hỏi ở [.cz.toml](../.cz.toml).

```sh
cz c                       # hỏi loại, khu vực, mô tả rồi tạo commit
cz c --body-length-limit 72   # gập thân bài ở 72 cột
cz check -m "<message>"    # message gõ tay có đúng quy ước không
cz example                 # xem một message mẫu
```

## Diff và merge

`delta` là pager cho mọi lệnh git (`core.pager`), có số dòng và `navigate = true` (dùng `n` / `N` để nhảy giữa các file trong diff).

```sh
git difftool            # mở diff trong nvim (-d), không hỏi xác nhận (difftool.prompt = false)
```

`merge.conflictstyle = diff3` nên khối xung đột hiện cả phiên bản gốc, không chỉ hai bên — sửa trực tiếp
trong file rồi `git add-unmerged` là xong.

`merge.tool` **chưa được đặt**, nên `git mergetool` sẽ dùng công cụ mặc định của hệ (trên macOS là
`opendiff`), không phải nvim. Muốn nvim thì thêm `[merge] tool = nvimdiff` và `[mergetool "nvimdiff"]`
vào `config/.gitconfig`.
