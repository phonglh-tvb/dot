#!/bin/bash
# Dọn Docker. Mặc định chỉ liệt kê cái thu hồi được, không xoá gì.
#
#   scripts/docker-clean.sh            liệt kê
#   scripts/docker-clean.sh --apply    xoá container đã dừng, image không tên, build cache quá 7 ngày, volume ẩn danh
#   scripts/docker-clean.sh --apply --yes    như trên, không hỏi xác nhận (cho chỗ không có terminal)
#
# Volume có tên (docker_pgdata...) chứa dữ liệu nên không bao giờ bị xoá tự động: xem danh sách ở phần
# liệt kê rồi tự `docker volume rm <tên>` khi chắc chắn. Script dọn trên docker context đang dùng (in ở đầu).

set -euo pipefail

apply=0
yes=0
for arg in "$@"; do
  case "$arg" in
    --apply) apply=1 ;;
    --yes) yes=1 ;;
    -h | --help)
      sed -n '2,9p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      echo "lỗi: không hiểu '$arg' (--apply, --yes, -h)" >&2
      exit 2
      ;;
  esac
done

command -v docker >/dev/null 2>&1 || {
  echo "lỗi: chưa có docker" >&2
  exit 1
}
docker info >/dev/null 2>&1 || {
  echo "lỗi: docker không trả lời (context '$(docker context show)'); VM Lima đang chạy chưa? limactl list" >&2
  exit 1
}

server="$(docker version --format '{{.Server.Version}}')"
echo "Docker context: $(docker context show) (server $server)"

# volume không container nào dùng: "tên kích-thước" mỗi dòng
unused_volumes() {
  docker system df -v 2>/dev/null | awk '
    /^Local Volumes space usage:/ { on = 1; next }
    /^Build cache usage:/ { on = 0 }
    on && NF == 3 && $2 == 0 && $1 != "VOLUME" { print $1, $3 }'
}

# volume ẩn danh có tên là chuỗi hex 64 ký tự
is_anonymous() {
  [[ "$1" =~ ^[0-9a-f]{64}$ ]]
}

section() {
  printf '\n== %s ==\n' "$1"
}

section "Dung lượng"
docker system df

section "Container đã dừng (--apply xoá)"
docker ps -a --filter status=exited --filter status=created --format '{{.Names}}  {{.Image}}  {{.Status}}' | sed 's/^/  /'

section "Image không tên (--apply xoá)"
docker images --filter dangling=true --format '{{.ID}}  {{.Size}}  {{.CreatedSince}}' | sed 's/^/  /'

anon=0
named_lines=""
while read -r name size; do
  [ -n "$name" ] || continue
  if is_anonymous "$name"; then
    anon=$((anon + 1))
  else
    named_lines="$named_lines  $name  $size
"
  fi
done < <(unused_volumes)

section "Volume ẩn danh không dùng (--apply xoá)"
echo "  $anon volume"

section "Volume có tên, không container nào đang dùng (KHÔNG tự xoá, có thể là dữ liệu)"
if [ -n "$named_lines" ]; then
  printf '%s' "$named_lines"
else
  echo "  không có"
fi

section "Build cache (--apply xoá phần quá 7 ngày)"
docker system df | awk '/^Build Cache/ { print "  " $0 }'

[ "$apply" = 1 ] || {
  printf '\nChỉ liệt kê. Muốn dọn: scripts/docker-clean.sh --apply\n'
  exit 0
}

if [ "$yes" != 1 ]; then
  [ -t 0 ] || {
    echo "lỗi: không có terminal để xác nhận; thêm --yes nếu chắc chắn" >&2
    exit 1
  }
  read -r -p "Xoá các mục trên ở context '$(docker context show)'? [y/N] " answer
  [ "$answer" = y ] || {
    echo "Bỏ qua, không xoá gì."
    exit 0
  }
fi

docker container prune -f
docker image prune -f
docker builder prune -f --filter until=168h
# Từ Docker 23, `volume prune` không kèm --all chỉ xoá volume ẩn danh; bản cũ hơn thì xoá cả volume có tên nên bỏ qua
if [ "${server%%.*}" -ge 23 ]; then
  docker volume prune -f
else
  echo "Docker $server cũ hơn 23: bỏ qua dọn volume (sẽ xoá cả volume có tên)."
fi
