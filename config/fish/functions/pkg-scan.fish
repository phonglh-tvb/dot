function pkg-scan --description "Scan npm packages for vulnerabilities and malicious behavior before installing"
    if test (count $argv) -eq 0
        echo "Usage: pkg-scan <package[@version]> [package2 ...]"
        echo ""
        echo "Runs: socket.dev supply-chain scan, Trivy CVE scan, OSV database scan, npm audit"
        return 1
    end

    set -l packages $argv
    set -l tmpdir (mktemp -d)
    set -l exit_code 0

    echo "==> pkg-scan: $packages"
    echo ""

    # Generate lockfile without actually installing (no download, no install scripts)
    echo '{"name":"__pkg-scan-tmp","version":"0.0.0","private":true}' > $tmpdir/package.json
    echo "[1/4] Resolving dependency graph (lockfile only)..."
    if not npm install --package-lock-only --prefix $tmpdir $packages 2>/dev/null
        echo "ERROR: Cannot resolve $packages — package may not exist on npm registry."
        rm -rf $tmpdir
        return 1
    end

    # socket.dev: supply-chain, malware, typosquatting, protestware
    echo ""
    echo "[2/4] socket.dev supply-chain analysis..."
    if not command -q socket
        echo "  SKIP: socket not installed — run: npm install -g socket"
    else if socket --help 2>&1 | grep -q "token: (not set)"
        echo "  SKIP: socket not logged in — run: socket login"
    else
        for pkg in $packages
            # socket pkg score expects npm/<name>[@version] e.g. npm/axios@1.7.0
            socket pkg score npm/$pkg; or set exit_code 1
        end
    end

    # Trivy: CVE scan via lockfile
    echo ""
    echo "[3/4] Trivy vulnerability scan (HIGH/CRITICAL)..."
    if command -q trivy
        trivy fs --exit-code 1 --severity HIGH,CRITICAL --scanners vuln --quiet $tmpdir/package-lock.json
        or set exit_code 1
    else
        echo "  SKIP: trivy not installed — run: brew install trivy"
    end

    # OSV Scanner: Google OSV database
    echo ""
    echo "[4/4] OSV database scan..."
    if command -q osv-scanner
        osv-scanner --lockfile $tmpdir/package-lock.json
        or set exit_code 1
    else
        echo "  SKIP: osv-scanner not installed — run: brew install osv-scanner"
    end

    # npm audit: baseline, always available
    echo ""
    echo "[+] npm audit (baseline)..."
    npm audit --prefix $tmpdir --audit-level high 2>/dev/null
    or set exit_code 1

    rm -rf $tmpdir

    echo ""
    if test $exit_code -eq 0
        echo "✓ All scans passed: $packages"
    else
        echo "✗ Security issues detected: $packages"
        echo "  Review output above. To bypass: command npm install $packages"
    end

    return $exit_code
end
