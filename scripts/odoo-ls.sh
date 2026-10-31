#!/bin/bash
# Cài OdooLS (language server của Odoo) cho Neovim: binary và typeshed vào <dữ liệu nvim>/odoo.
#
#   scripts/odoo-ls.sh       cài (hoặc bỏ qua nếu đã đúng bản)
#
# config/nvim/lua/configs/lspconfig.lua tìm odoo_ls_server ở stdpath("data")/odoo, cùng chỗ với odoo/odoo-neovim.
# Bản và sha256 ghim bên dưới, lấy từ trường "digest" của từng asset ở trang release của odoo/odoo-ls.
# Nâng bản: đổi VERSION và các sha256 theo trang release, đọc ghi chú phát hành (nhất là khoá mới hay đổi của
# odools.toml, xem config_schema.json cùng release), rồi chạy lại.
# Bản cũ không bị xoá: binary thành odoo_ls_server.<bản cũ>, typeshed thành typeshed.<bản cũ>. Quay lại thì mv ngược.

set -euo pipefail

VERSION="1.6.1"
TYPESHED_SHA="c6624253966ab66551d908e48fceae4f1d36b6e9f54a2631a9e55ffd1028af03"

case "$(uname -s)-$(uname -m)" in
  Darwin-arm64)
    PLATFORM="darwin-aarch64"
    SHA="56391cb362d12c7e9b8f7a0518826e94e651b4a8cea92bac542ae0ae16f2e324"
    ;;
  Darwin-x86_64)
    PLATFORM="darwin-x86_64"
    SHA="3f9bcd363344c3689b62245a23ddce31564aabd0de6a26b69139819d2c4fed74"
    ;;
  Linux-aarch64 | Linux-arm64)
    PLATFORM="linux-aarch64"
    SHA="c3c50ba37e4513806a95147c31761979a956171b961ded807b01145a13282055"
    ;;
  Linux-x86_64)
    PLATFORM="linux-x86_64"
    SHA="c271fc098a114e3b64a6f66aa2d48d879724ca0d629d47536c323d710eef8969"
    ;;
  *)
    echo "lỗi: chưa có bản OdooLS cho $(uname -s) $(uname -m)" >&2
    exit 1
    ;;
esac

BASE="https://github.com/odoo/odoo-ls/releases/download/$VERSION"
DEST="${XDG_DATA_HOME:-$HOME/.local/share}/${NVIM_APPNAME:-nvim}/odoo"
STAMP="$DEST/.typeshed-version"

have() { command -v "$1" &>/dev/null; }

die() {
  echo "lỗi: $*" >&2
  exit 1
}

sha256_of() {
  if have sha256sum; then sha256sum "$1" | cut -d' ' -f1; else shasum -a 256 "$1" | cut -d' ' -f1; fi
}

# Tải về và kiểm checksum trước khi đụng vào bản đang dùng
fetch() {
  local name="$1" expected="$2"
  echo "tải $name ($VERSION)..."
  curl -fsSL -o "$tmp/$name" "$BASE/$name"
  [ "$(sha256_of "$tmp/$name")" = "$expected" ] || die "$name sai checksum, không cài"
}

# Dời bản đang có sang một bên, không xoá: <đường dẫn>.<hậu tố>, thêm giờ nếu tên đó đã có
aside() {
  local path="$1" suffix="$2" target
  [ -e "$path" ] || return 0
  target="$path.$suffix"
  [ -e "$target" ] && target="$target.$(date +%Y%m%d%H%M%S)"
  mv "$path" "$target"
  echo "giữ bản cũ: $target"
}

have curl || die "thiếu curl"
have tar || die "thiếu tar"
have unzip || die "thiếu unzip"

installed=""
if [ -x "$DEST/odoo_ls_server" ]; then
  installed="$("$DEST/odoo_ls_server" --version 2>/dev/null | awk '{ print $NF }' || true)"
fi

if [ "$installed" = "$VERSION" ] && [ "$(cat "$STAMP" 2>/dev/null || true)" = "$VERSION" ] && [ -d "$DEST/typeshed/stdlib" ]; then
  echo "OdooLS $VERSION đã có ($DEST)"
  echo "odoo-ls: changed=0"
  exit 0
fi

mkdir -p "$DEST"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

archive="odoo-$PLATFORM-$VERSION.tar.gz"
fetch "$archive" "$SHA"
fetch typeshed.zip "$TYPESHED_SHA"

mkdir "$tmp/bin" "$tmp/typeshed"
tar -xzf "$tmp/$archive" -C "$tmp/bin"
unzip -q "$tmp/typeshed.zip" -d "$tmp/typeshed"
[ -x "$tmp/bin/odoo_ls_server" ] || die "$archive không có odoo_ls_server"
[ -d "$tmp/typeshed/stdlib" ] || die "typeshed.zip không có thư mục stdlib"
[ "$("$tmp/bin/odoo_ls_server" --version | awk '{ print $NF }')" = "$VERSION" ] || die "odoo_ls_server vừa tải không báo bản $VERSION"

# Đã kiểm xong mới thay; đổi tên trong cùng thư mục để việc thay là một bước mv
old="${installed:-old}"
aside "$DEST/odoo_ls_server" "$old"
aside "$DEST/typeshed" "$old"
cp "$tmp/bin/odoo_ls_server" "$DEST/.odoo_ls_server.new"
chmod +x "$DEST/.odoo_ls_server.new"
mv "$DEST/.odoo_ls_server.new" "$DEST/odoo_ls_server"
mv "$tmp/typeshed" "$DEST/typeshed"
printf '%s\n' "$VERSION" >"$STAMP"

echo "odoo_ls_server $VERSION -> $DEST"
echo "odoo-ls: changed=1"
