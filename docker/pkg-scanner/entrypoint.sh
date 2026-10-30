#!/bin/bash
set -e

PACKAGES="$*"
if [ -z "$PACKAGES" ]; then
  echo "Usage: docker run pkg-scanner <package[@version]> [...]"
  exit 1
fi

WORKDIR=$(mktemp -d)
cd "$WORKDIR"
EXIT_CODE=0

echo "==> pkg-scanner (Docker sandbox): $PACKAGES"
echo "    Container: $(hostname)"
echo ""

# Resolve dependency graph — no download, no install scripts
echo '{"name":"__scan-tmp","version":"0.0.0","private":true}' >package.json
echo "[1/4] Resolving dependency graph (lockfile only)..."
# shellcheck disable=SC2086 # tách từ có chủ đích: $PACKAGES là danh sách gói cách nhau bằng dấu cách
if ! npm install --package-lock-only $PACKAGES 2>&1; then
  echo "ERROR: Cannot resolve $PACKAGES"
  rm -rf "$WORKDIR"
  exit 1
fi

# socket.dev supply-chain scan
echo ""
echo "[2/4] socket.dev supply-chain analysis..."
for pkg in $PACKAGES; do
  socket pkg score "npm/$pkg" || EXIT_CODE=1
done

# Trivy CVE scan via lockfile
echo ""
echo "[3/4] Trivy vulnerability scan (HIGH/CRITICAL)..."
trivy fs --exit-code 1 --severity HIGH,CRITICAL --scanners vuln --quiet package-lock.json || EXIT_CODE=1

# OSV Scanner
echo ""
echo "[4/4] OSV database scan..."
osv-scanner --lockfile package-lock.json || EXIT_CODE=1

# Optional: actually install inside sandbox to observe install script behavior
if [ "${INSTALL_MODE:-0}" = "1" ]; then
  echo ""
  echo "[sandbox] Running npm install in isolated container..."
  # shellcheck disable=SC2086 # như trên: tách từ có chủ đích
  npm install $PACKAGES 2>&1
  echo "[sandbox] Install complete. Files stay inside container (not copied to host)."
fi

rm -rf "$WORKDIR"

echo ""
if [ $EXIT_CODE -eq 0 ]; then
  echo "✓ All scans passed: $PACKAGES"
else
  echo "✗ Security issues detected: $PACKAGES"
  echo "  Review output above before installing on host."
fi

exit $EXIT_CODE
