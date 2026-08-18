function safe-npm --description "npm wrapper with security scanning (enable: set PKG_SECURITY_ENABLED 1)"
    # Pass through if opt-in flag not set
    if test "$PKG_SECURITY_ENABLED" != "1"
        command npm $argv
        return
    end

    set -l subcmd $argv[1]

    # Only intercept install/add subcommands
    if not contains -- $subcmd install i add
        command npm $argv
        return
    end

    # Extract package names (skip flags and the subcommand itself)
    set -l packages
    for arg in $argv[2..]
        if not string match -q -- "-*" $arg
            set -a packages $arg
        end
    end

    if test (count $packages) -eq 0
        # No explicit packages: installing from existing package.json — scan lockfile
        echo "==> safe-npm: scanning existing project lockfile..."
        set -l scanned 0

        if command -q trivy; and test -f package-lock.json -o -f yarn.lock -o -f pnpm-lock.yaml
            trivy fs --exit-code 1 --severity HIGH,CRITICAL --scanners vuln --quiet .
            or begin
                echo "Trivy found issues. Use 'command npm $argv' to bypass."
                return 1
            end
            set scanned 1
        end

        if command -q osv-scanner
            set -l lockfile ""
            if test -f package-lock.json; set lockfile package-lock.json
            else if test -f yarn.lock; set lockfile yarn.lock
            else if test -f pnpm-lock.yaml; set lockfile pnpm-lock.yaml
            end
            if test -n "$lockfile"
                osv-scanner --lockfile $lockfile
                or begin
                    echo "OSV found issues. Use 'command npm $argv' to bypass."
                    return 1
                end
                set scanned 1
            end
        end

        if test $scanned -eq 0
            echo "  No lockfile found — skipping lockfile scan."
        end

        command npm $argv
        return
    end

    # Explicit packages listed — run pkg-scan first
    echo "==> safe-npm: scanning $packages before install..."
    pkg-scan $packages
    or begin
        echo ""
        echo "Install aborted. To bypass: command npm $argv"
        return 1
    end

    echo ""
    echo "Scans passed. Running npm $argv..."
    command npm $argv
end
