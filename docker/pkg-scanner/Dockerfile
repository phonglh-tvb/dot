FROM node:lts-alpine

ARG TARGETARCH=arm64

RUN apk add --no-cache curl wget bash ca-certificates

# Install Trivy
RUN TRIVY_VERSION=$(wget -qO- "https://api.github.com/repos/aquasecurity/trivy/releases/latest" \
        | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/') && \
    ARCH=$([ "$TARGETARCH" = "amd64" ] && echo "64bit" || echo "ARM64") && \
    wget -qO /tmp/trivy.tar.gz \
        "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-${ARCH}.tar.gz" && \
    tar xzf /tmp/trivy.tar.gz -C /usr/local/bin trivy && \
    rm /tmp/trivy.tar.gz

# Install OSV Scanner
RUN OSV_VERSION=$(wget -qO- "https://api.github.com/repos/google/osv-scanner/releases/latest" \
        | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/') && \
    ARCH=$([ "$TARGETARCH" = "amd64" ] && echo "amd64" || echo "arm64") && \
    wget -qO /usr/local/bin/osv-scanner \
        "https://github.com/google/osv-scanner/releases/download/v${OSV_VERSION}/osv-scanner_linux_${ARCH}" && \
    chmod +x /usr/local/bin/osv-scanner

# Install socket CLI
RUN npm install -g socket --quiet \
    || npm install -g socket --quiet \
    || npm install -g socket --quiet

WORKDIR /scan

COPY entrypoint.sh /usr/local/bin/scan
RUN chmod +x /usr/local/bin/scan

ENTRYPOINT ["/usr/local/bin/scan"]
