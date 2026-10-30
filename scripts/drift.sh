#!/bin/bash
# So máy này với những gì repo khai báo. Chỉ đọc, không đổi gì.
#
#   scripts/drift.sh       in phần đã cài mà chưa khai báo, và phần khai báo mà chưa cài
#   scripts/drift.sh -q    như trên nhưng im lặng khi không lệch; thoát mã 1 nếu có lệch
#
# Kiểm: Homebrew (formula, cask) so với Brewfile*; runtime mise so với config/mise/config.toml.
# Thêm gói mới vào đúng file Brewfile* rồi chạy lại, thay vì ghi đè Brewfile từ máy.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
quiet=0
drift=0

case "${1:-}" in
  -q) quiet=1 ;;
  -h | --help)
    sed -n '2,9p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
    exit 0
    ;;
  "") ;;
  *)
    echo "lỗi: không hiểu '$1' (-q hoặc -h)" >&2
    exit 2
    ;;
esac

have() { command -v "$1" >/dev/null 2>&1; }

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# in một mục nếu danh sách ($2) không rỗng; $3 là gợi ý cách xử lý
report() {
  [ -s "$2" ] || return 0
  drift=$((drift + 1))
  printf '%s\n' "$1"
  sed 's/^/  /' "$2"
  [ -z "${3:-}" ] || printf '  -> %s\n' "$3"
  echo
}

# tên ngắn (bỏ tiền tố tap) của mọi mục kiểu $1 (brew|cask) trong Brewfile*
declared() {
  find "$REPO" -maxdepth 1 -name 'Brewfile*' -exec cat {} + |
    sed -nE "s/^$1 \"([^\"]+)\".*/\1/p" | sed 's#.*/##' | sort -u
}

check_brew() {
  have brew || return 0

  declared brew >"$tmp/f_decl"
  brew leaves --installed-on-request | sed 's#.*/##' | sort -u >"$tmp/f_req"
  brew list --formula | sed 's#.*/##' | sort -u >"$tmp/f_all"
  comm -23 "$tmp/f_req" "$tmp/f_decl" >"$tmp/f_undeclared"
  comm -13 "$tmp/f_all" "$tmp/f_decl" >"$tmp/f_missing"

  declared cask >"$tmp/c_decl"
  brew list --cask | sort -u >"$tmp/c_all"
  comm -23 "$tmp/c_all" "$tmp/c_decl" >"$tmp/c_undeclared"
  comm -13 "$tmp/c_all" "$tmp/c_decl" >"$tmp/c_missing"

  report "Formula đã cài mà chưa khai báo" "$tmp/f_undeclared" 'thêm vào Brewfile (lõi) hoặc Brewfile.devops'
  report "Cask đã cài mà chưa khai báo" "$tmp/c_undeclared" 'thêm vào Brewfile.apps (hoặc Brewfile.devops)'
  report "Formula khai báo mà chưa cài" "$tmp/f_missing" 'brew bundle install --file=<Brewfile.*> hoặc bỏ khỏi khai báo'
  report "Cask khai báo mà chưa cài" "$tmp/c_missing" 'brew bundle install --file=<Brewfile.*> hoặc bỏ khỏi khai báo'
}

check_mise() {
  have mise && have jq || return 0
  local json
  json="$(mise ls --json 2>/dev/null)" || return 0

  # công cụ đã cài mà không có trong config nào
  printf '%s' "$json" | jq -r 'to_entries[] | select(all(.value[]; .source == null)) | .key' | sort >"$tmp/m_undeclared"
  # bản cũ: đã cài nhưng không phải bản config đang chọn (công cụ chưa khai báo ở trên thì bỏ qua)
  printf '%s' "$json" | jq -r 'to_entries[] | select(any(.value[]; .source != null)) | .key as $t | .value[] | select(.source == null) | "\($t) \(.version)"' |
    sort >"$tmp/m_old"

  report "Runtime mise đã cài mà chưa khai báo" "$tmp/m_undeclared" 'thêm vào config/mise/config.toml'
  report "Bản cũ của mise (config không còn chọn)" "$tmp/m_old" 'giữ làm đường lui; mise prune khi chắc chắn không cần'
}

check_brew
check_mise

if [ "$drift" -eq 0 ]; then
  [ "$quiet" = 1 ] || echo "Máy khớp khai báo."
  exit 0
fi
[ "$quiet" = 1 ] || echo "$drift mục lệch."
exit 1
