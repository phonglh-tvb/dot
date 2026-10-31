#!/bin/bash
# Quản lý secret trên máy local. Hai cách dùng song song, repo này không bao giờ chứa giá trị secret:
#   1Password (op)  nguồn chính; file cấu hình chỉ chứa tham chiếu op://...   (xem docs/secrets.md)
#   sops + age      file secret mã hoá, giải mã khi cần
#
#   scripts/secrets.sh check               kiểm tra công cụ, quyền file, cấu hình ký commit
#   scripts/secrets.sh age-init            tạo khoá age (nếu chưa có), in khoá công khai
#   scripts/secrets.sh init [thư mục]      tạo kho secret mã hoá (mặc định ~/.secrets) có .sops.yaml
#   scripts/secrets.sh edit <file.enc.*>   sửa file mã hoá bằng $EDITOR (sops)
#   scripts/secrets.sh encrypt <file.dec.*>  mã hoá thành file.enc.* (file gốc giữ nguyên, bạn tự xoá)
#   scripts/secrets.sh decrypt <file.enc.*>  giải mã ra stdout
#   scripts/secrets.sh exec <file.enc.*> -- <lệnh...>  chạy lệnh với secret trong biến môi trường
#   scripts/secrets.sh hooks [repo]        cài hook gitleaks (pre-commit, pre-push) cho một repo khác
#   scripts/secrets.sh scan [đường dẫn]    quét secret trong file và lịch sử git

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# sops mặc định đọc khoá ở thư mục khác nhau tuỳ hệ điều hành; cố định để mọi máy giống nhau
export SOPS_AGE_KEY_FILE="${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}"
KEY_FILE="$SOPS_AGE_KEY_FILE"

have() { command -v "$1" >/dev/null 2>&1; }

die() {
  echo "lỗi: $*" >&2
  exit 1
}

need() { # $1=lệnh $2=gói brew
  have "$1" || die "thiếu '$1' (brew install $2)"
}

perm_of() { # Linux dùng stat -c; macOS không có -c nên rơi sang stat -f (thử -f trước thì GNU in rác ra stdout)
  stat -c '%a' "$1" 2>/dev/null || stat -f '%Lp' "$1"
}

usage() {
  sed -n '2,16p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

cmd_check() {
  local problems=0 t p f socket
  # shellcheck disable=SC2088 # chỉ để hiển thị, không cần mở rộng
  local ssh_dir='~/.ssh'

  row() { printf '  %-30s %s\n' "$1" "$2"; }

  echo "Công cụ"
  for t in op age sops gitleaks direnv; do
    if have "$t"; then row "$t" "có"; else row "$t" "chưa cài"; fi
  done
  if have op; then
    if op whoami >/dev/null 2>&1; then row "op đăng nhập" "rồi"; else row "op đăng nhập" "chưa (mở app 1Password > Settings > Developer > tích hợp CLI)"; fi
  fi

  echo "Khoá age (sops)"
  if [ -f "$KEY_FILE" ]; then
    p="$(perm_of "$KEY_FILE")"
    if [ "$p" = 600 ]; then row "$KEY_FILE" "quyền 600"; else
      row "$KEY_FILE" "quyền $p, phải là 600: chmod 600"
      problems=$((problems + 1))
    fi
  else
    row "$KEY_FILE" "chưa có (scripts/secrets.sh age-init)"
  fi

  echo "SSH"
  if [ -d "$HOME/.ssh" ]; then
    p="$(perm_of "$HOME/.ssh")"
    if [ "$p" = 700 ]; then row "$ssh_dir" "quyền 700"; else
      row "$ssh_dir" "quyền $p, phải là 700"
      problems=$((problems + 1))
    fi
    for f in "$HOME"/.ssh/id_*; do
      [ -f "$f" ] || continue
      case "$f" in *.pub) continue ;; esac
      p="$(perm_of "$f")"
      if [ "$p" = 600 ]; then row "$ssh_dir/$(basename "$f")" "quyền 600"; else
        row "$ssh_dir/$(basename "$f")" "quyền $p, phải là 600"
        problems=$((problems + 1))
      fi
    done
  fi
  for socket in "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock" "$HOME/.1password/agent.sock"; do
    [ -S "$socket" ] && row "1Password SSH agent" "đang chạy"
  done

  echo "Ký commit"
  row "gpg.format" "$(git config --global gpg.format || echo '-')"
  row "commit.gpgsign" "$(git config --global commit.gpgsign || echo '-')"
  case "$(git config --global user.signingkey || true)" in
    ssh-* | key::*) row "user.signingkey" "khoá công khai (kiểu 1Password)" ;;
    "") row "user.signingkey" "-" ;;
    *) row "user.signingkey" "đường dẫn tới khoá riêng trên đĩa" ;;
  esac

  echo "Repo dotfiles"
  row "core.hooksPath" "$(git -C "$REPO" config core.hooksPath || echo 'chưa đặt (./install.sh hooks)')"

  [ "$problems" = 0 ] || {
    echo "$problems vấn đề về quyền file ở trên"
    return 1
  }
}

cmd_age_init() {
  need age-keygen age

  if [ -f "$KEY_FILE" ]; then
    echo "đã có khoá: $KEY_FILE"
  else
    mkdir -p "$(dirname "$KEY_FILE")"
    chmod 700 "$(dirname "$KEY_FILE")"
    (umask 077 && age-keygen -o "$KEY_FILE" 2>/dev/null)
    echo "đã tạo $KEY_FILE"
  fi

  echo "khoá công khai: $(age-keygen -y "$KEY_FILE")"
  cat <<EOF

Mất file khoá là mất mọi file đã mã hoá. Sao lưu ngay vào 1Password, ví dụ:
  op document create "$KEY_FILE" --title "age key \$(hostname -s)" --vault Private
EOF
}

cmd_init() {
  local dir="${1:-$HOME/.secrets}" pub
  need age-keygen age
  need sops sops

  [ -f "$KEY_FILE" ] || cmd_age_init
  pub="$(age-keygen -y "$KEY_FILE")"

  mkdir -p "$dir"
  chmod 700 "$dir"

  if [ -f "$dir/.sops.yaml" ]; then
    echo "đã có $dir/.sops.yaml, giữ nguyên"
  else
    cat >"$dir/.sops.yaml" <<EOF
creation_rules:
  - path_regex: '\.enc\.(ya?ml|json|env|ini|txt)\$'
    age: $pub
EOF
    printf '%s\n' '*.dec.*' >"$dir/.gitignore"
    echo "đã tạo $dir/.sops.yaml (người nhận: khoá age của máy này)"
  fi

  if ! git -C "$dir" rev-parse --git-dir >/dev/null 2>&1; then
    git -C "$dir" init -q
    echo "đã git init $dir. Nếu muốn đồng bộ, hãy đẩy lên repo PRIVATE, đừng dùng repo public"
  fi
  cmd_hooks "$dir"
}

# sops chỉ tìm .sops.yaml từ thư mục hiện tại đi lên, nên chạy từ chỗ khác thì báo "config file not found".
# In đường dẫn .sops.yaml gần nhất tính từ thư mục chứa file $1.
sops_config_for() {
  local dir
  dir="$(cd "$(dirname "$1")" 2>/dev/null && pwd)" || return 1
  while [ ! -f "$dir/.sops.yaml" ]; do
    [ "$dir" != / ] || return 1
    dir="$(dirname "$dir")"
  done
  echo "$dir/.sops.yaml"
}

cmd_edit() {
  need sops sops
  [ $# -ge 1 ] || die "usage: secrets.sh edit <file.enc.*>"
  # file mới chưa có metadata sops nên cần luật tạo trong .sops.yaml
  local cfg
  if [ $# -eq 1 ] && cfg="$(sops_config_for "$1")"; then
    sops --config "$cfg" "$1"
  else
    sops "$@"
  fi
}

cmd_encrypt() {
  need sops sops
  [ $# -eq 1 ] || die "usage: secrets.sh encrypt <file.dec.*>"
  case "$1" in *.dec.*) ;; *) die "tên file phải có '.dec.', ví dụ app.dec.yaml" ;; esac

  local out="${1/.dec./.enc.}" cfg tmp
  [ ! -e "$out" ] || die "$out đã tồn tại, không ghi đè"
  cfg="$(sops_config_for "$1")" || die "không thấy .sops.yaml ở thư mục của $1 hay thư mục cha (chạy 'secrets.sh init' trước)"
  # ghi ra file tạm: mã hoá lỗi thì không để lại $out rỗng, vì nó sẽ chặn lần chạy sau
  tmp="$(mktemp "$out.XXXXXX")"
  if ! sops --config "$cfg" encrypt --filename-override "$out" "$1" >"$tmp"; then
    rm -f "$tmp"
    die "mã hoá $1 thất bại, không tạo $out"
  fi
  mv "$tmp" "$out"
  echo "đã mã hoá -> $out"
  echo "file gốc $1 vẫn còn, hãy xoá sau khi kiểm tra: rm \"$1\""
}

cmd_decrypt() {
  need sops sops
  [ $# -eq 1 ] || die "usage: secrets.sh decrypt <file.enc.*>"
  sops decrypt "$1"
}

cmd_exec() {
  need sops sops
  [ $# -ge 2 ] || die "usage: secrets.sh exec <file.enc.*> -- <lệnh...>"
  local file="$1"
  shift
  [ "$1" = "--" ] && shift
  [ $# -ge 1 ] || die "thiếu lệnh sau --"

  # sops exec-env nhận một chuỗi lệnh; %q giữ nguyên dấu cách / nháy trong từng tham số
  local cmd
  cmd="$(printf '%q ' "$@")"
  sops exec-env "$file" "$cmd"
}

cmd_hooks() {
  local repo="${1:-$PWD}" gitdir h dest
  git -C "$repo" rev-parse --git-dir >/dev/null 2>&1 || die "$repo không phải repo git"
  gitdir="$(git -C "$repo" rev-parse --absolute-git-dir)"

  if [ -n "$(git -C "$repo" config core.hooksPath || true)" ]; then
    echo "cảnh báo: $repo đặt core.hooksPath riêng, hook trong .git/hooks sẽ không chạy" >&2
  fi

  mkdir -p "$gitdir/hooks"
  for h in pre-commit pre-push; do
    dest="$gitdir/hooks/$h"
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
      echo "đã có hook $h ở $repo, giữ nguyên (tự gộp lệnh gitleaks vào): $dest"
      continue
    fi
    ln -sf "$REPO/.githooks/$h" "$dest"
    echo "đã cài $h cho $repo"
  done
}

cmd_scan() {
  need gitleaks gitleaks
  local path="${1:-.}"
  gitleaks dir --redact --no-banner "$path"
  if git -C "$path" rev-parse --git-dir >/dev/null 2>&1; then
    gitleaks git --redact --no-banner "$path"
  fi
}

main() {
  local sub="${1:-}"
  [ $# -eq 0 ] || shift

  case "$sub" in
    check) cmd_check "$@" ;;
    age-init) cmd_age_init "$@" ;;
    init) cmd_init "$@" ;;
    edit) cmd_edit "$@" ;;
    encrypt) cmd_encrypt "$@" ;;
    decrypt) cmd_decrypt "$@" ;;
    exec) cmd_exec "$@" ;;
    hooks) cmd_hooks "$@" ;;
    scan) cmd_scan "$@" ;;
    "" | -h | --help) usage ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
}

main "$@"
