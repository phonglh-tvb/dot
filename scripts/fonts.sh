#!/bin/bash
# Cài Nerd Font vào ~/.local/share/fonts (Linux). Trên macOS font đi theo cask trong Brewfile.apps.
#
#   scripts/fonts.sh       cài (hoặc bỏ qua nếu đã đúng bản)
#
# Giao diện nvim, starship, tmux cần Nerd Font để hiện biểu tượng. Bản và checksum được ghim bên dưới;
# nâng bản: đổi VERSION và SUMS theo SHA-256.txt của release rồi kiểm lại bằng chạy script.

set -euo pipefail

VERSION="v3.5.1"
FONTS="JetBrainsMono MartianMono"
SUMS="04d5e8f903693f9dd13e16f867e994834e681eb3c72c0d337a770dcda09010cf  JetBrainsMono.tar.xz
804a5a458856725d45a03d96a778349e8c3c9a4a45f5df023f294e196fbe88f2  MartianMono.tar.xz"

DEST="${XDG_DATA_HOME:-$HOME/.local/share}/fonts/NerdFonts"

have() { command -v "$1" &>/dev/null; }

die() {
  echo "lỗi: $*" >&2
  exit 1
}

sha256_of() {
  if have sha256sum; then sha256sum "$1" | cut -d' ' -f1; else shasum -a 256 "$1" | cut -d' ' -f1; fi
}

have curl || die "thiếu curl"
have tar || die "thiếu tar"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

changed=0
for name in $FONTS; do
  dir="$DEST/$name"
  if [ "$(cat "$dir/.version" 2>/dev/null || true)" = "$VERSION" ]; then
    echo "$name $VERSION đã có"
    continue
  fi

  archive="$name.tar.xz"
  expected="$(printf '%s\n' "$SUMS" | awk -v f="$archive" '$2 == f { print $1 }')"
  [ -n "$expected" ] || die "chưa ghim checksum cho $archive"

  echo "tải $archive ($VERSION)..."
  curl -fsSL -o "$tmp/$archive" "https://github.com/ryanoasis/nerd-fonts/releases/download/$VERSION/$archive"
  [ "$(sha256_of "$tmp/$archive")" = "$expected" ] || die "$archive sai checksum, không cài"

  rm -rf "$dir"
  mkdir -p "$dir"
  tar -xJf "$tmp/$archive" -C "$dir"
  printf '%s\n' "$VERSION" >"$dir/.version"
  changed=$((changed + 1))
done

if [ "$changed" -gt 0 ] && have fc-cache; then
  fc-cache -f "$DEST"
fi
echo "fonts: changed=$changed"
