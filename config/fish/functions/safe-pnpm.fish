function safe-pnpm --description "pnpm wrapper with security scanning (enable: set PKG_SECURITY_ENABLED 1)"
    if test "$PKG_SECURITY_ENABLED" != "1"
        command pnpm $argv
        return
    end

    set -l subcmd $argv[1]

    if not contains -- $subcmd add install i
        command pnpm $argv
        return
    end

    if test "$subcmd" = "add"
        # pnpm add <pkg> — extract explicit package names
        set -l packages
        for arg in $argv[2..]
            if not string match -q -- "-*" $arg
                set -a packages $arg
            end
        end

        if test (count $packages) -gt 0
            echo "==> safe-pnpm: scanning $packages before add..."
            pkg-scan $packages
            or begin
                echo ""
                echo "Add aborted. To bypass: command pnpm $argv"
                return 1
            end
            echo ""
            echo "Scans passed. Running pnpm $argv..."
        end
    else
        # pnpm install from lockfile
        if test -f pnpm-lock.yaml
            echo "==> safe-pnpm: scanning pnpm-lock.yaml..."
            if command -q trivy
                trivy fs --exit-code 1 --severity HIGH,CRITICAL --scanners vuln --quiet .
                or begin
                    echo "Trivy found issues. Use 'command pnpm $argv' to bypass."
                    return 1
                end
            end
            if command -q osv-scanner
                osv-scanner --lockfile pnpm-lock.yaml
                or begin
                    echo "OSV found issues. Use 'command pnpm $argv' to bypass."
                    return 1
                end
            end
            echo "Scans passed. Running pnpm $argv..."
        end
    end

    command pnpm $argv
end
