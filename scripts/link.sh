#!/bin/bash
# Symlink các file trong config/ vào máy.
#
#   scripts/link.sh [apply]    tạo / sửa symlink (mặc định)
#   scripts/link.sh status     chỉ báo trạng thái, không đổi gì
#   scripts/link.sh unlink     gỡ các symlink đang trỏ vào repo này
#   -n, --dry-run              in việc sẽ làm mà không làm
#
# Mỗi mục trong config/ được link như sau:
#   tên bắt đầu bằng "."  (vd .gitconfig)  ->  ~/<tên>
#   còn lại                                 ->  ${XDG_CONFIG_HOME:-~/.config}/<tên>
#
# Đích đã có mà không phải symlink đúng chỗ thì được chuyển vào
# ~/.dotfiles-backup/<thời gian>/ trước khi link; không bao giờ bị xoá.
# Chạy lại bao nhiêu lần cũng được: link đã đúng thì bỏ qua.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$REPO/config"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

mode=apply
dry_run=0
changed=0

usage() {
  sed -n '2,16p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

while [ $# -gt 0 ]; do
  case "$1" in
    apply | status | unlink) mode="$1" ;;
    -n | --dry-run) dry_run=1 ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
  shift
done
[ "$mode" = status ] && dry_run=1

if [ -t 1 ]; then
  GREEN=$'\033[32m'
  YELLOW=$'\033[33m'
  DIM=$'\033[2m'
  RESET=$'\033[0m'
else
  GREEN="" YELLOW="" DIM="" RESET=""
fi

TILDE='~' # dùng biến: bash 3.2 giữ dấu \ nếu viết "${x//$HOME/\~}"

say() { # $1=nhãn $2=màu $3=đường dẫn (rút gọn $HOME thành ~)
  printf '  %s%-9s%s %s\n' "$2" "$1" "$RESET" "${3//$HOME/$TILDE}"
}

run() {
  [ "$dry_run" = 1 ] || "$@"
}

# Đường dẫn thật sau khi theo mọi symlink (readlink -f không có trên macOS cũ).
resolve() {
  local p="$1" t dir
  while [ -L "$p" ]; do
    t="$(readlink "$p")"
    case "$t" in
      /*) p="$t" ;;
      *) p="$(dirname "$p")/$t" ;;
    esac
  done
  dir="$(cd -P "$(dirname "$p")" 2>/dev/null && pwd)" || return 1
  printf '%s/%s\n' "$dir" "$(basename "$p")"
}

dest_for() {
  case "$1" in
    .*) printf '%s/%s\n' "$HOME" "$1" ;;
    *) printf '%s/%s\n' "$CONFIG_HOME" "$1" ;;
  esac
}

# Link đã đúng khi nó (qua mọi tầng symlink) kết thúc ở đúng file trong repo.
points_to_repo() { # $1=đích $2=nguồn
  [ -L "$1" ] && [ "$(resolve "$1")" = "$(resolve "$2")" ]
}

link_one() {
  local name="$1" src dest
  src="$SRC/$name"
  dest="$(dest_for "$name")"

  if points_to_repo "$dest" "$src"; then
    say ok "$GREEN" "$dest"
    return
  fi

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    say backup "$YELLOW" "$dest ${DIM}-> ${BACKUP_DIR/#$HOME/~}/$RESET"
    run mkdir -p "$BACKUP_DIR"
    run mv "$dest" "$BACKUP_DIR/$(basename "$dest")"
    changed=$((changed + 1))
  fi

  say link "$GREEN" "$dest ${DIM}-> ${src/#$HOME/~}${RESET}"
  run mkdir -p "$(dirname "$dest")"
  run ln -s "$src" "$dest"
  changed=$((changed + 1))
}

unlink_one() {
  local name="$1" src dest
  src="$SRC/$name"
  dest="$(dest_for "$name")"

  if points_to_repo "$dest" "$src"; then
    say unlink "$YELLOW" "$dest"
    run rm "$dest"
    changed=$((changed + 1))
  else
    say skip "$DIM" "$dest (không phải link của repo này)"
  fi
}

[ -d "$SRC" ] || {
  echo "không thấy $SRC" >&2
  exit 1
}

[ "$dry_run" = 1 ] && echo "(dry-run: không có gì bị thay đổi)"

# Glob cả file ẩn (.gitconfig...); mẫu không khớp thì [ -e ] bên dưới bỏ qua.
for path in "$SRC"/* "$SRC"/.[!.]*; do
  [ -e "$path" ] || [ -L "$path" ] || continue
  name="$(basename "$path")"
  [ "$name" = ".DS_Store" ] && continue

  if [ "$mode" = unlink ]; then
    unlink_one "$name"
  else
    link_one "$name"
  fi
done

echo "changed=$changed"
