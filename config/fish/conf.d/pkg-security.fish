# Opt-in: set PKG_SECURITY_ENABLED 1 để kích hoạt safe-npm / safe-pnpm
set -gx PKG_SECURITY_ENABLED 0
set -gx PKG_SCANNER_DOCKER_DIR "$HOME/workspace/dot/docker/pkg-scanner"
set -gx PKG_SCANNER_IMAGE "pkg-scanner:latest"
