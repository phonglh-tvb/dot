# Opt-in: set PKG_SECURITY_ENABLED 1 để kích hoạt safe-npm / safe-pnpm
set -gx PKG_SECURITY_ENABLED 0
# ~/.config/fish là symlink vào repo (nằm đâu cũng được), nên đi từ chính file này lên thư mục gốc của repo
set -l conf_d (path resolve (status dirname))
set -gx PKG_SCANNER_DOCKER_DIR (path normalize $conf_d/../../../docker/pkg-scanner)
set -gx PKG_SCANNER_IMAGE "pkg-scanner:latest"
