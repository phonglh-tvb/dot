function pkg-scan-docker --description "Deep sandbox scan using Docker isolation (no side effects on host)"
    if test (count $argv) -eq 0
        echo "Usage: pkg-scan-docker <package[@version]> [...]"
        echo ""
        echo "Runs full scan pipeline inside an isolated Docker container."
        echo "Set INSTALL_MODE=1 to also run npm install inside the container."
        return 1
    end

    # Build image if not present
    if not docker image inspect $PKG_SCANNER_IMAGE >/dev/null 2>&1
        echo "==> Building $PKG_SCANNER_IMAGE ..."
        docker build -t $PKG_SCANNER_IMAGE $PKG_SCANNER_DOCKER_DIR
        or begin
            echo "ERROR: Docker build failed."
            return 1
        end
    end

    docker run --rm \
        --platform linux/arm64 \
        -e INSTALL_MODE=$INSTALL_MODE \
        $PKG_SCANNER_IMAGE $argv
end
