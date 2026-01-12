# Change to `goreleaser-pro` to use the pro version
ARG GORELEASER_DISTRIBUTION=goreleaser
# Change to a specific version to pin the version
ARG GORELEASER_VERSION=nightly

FROM ghcr.io/goreleaser/$GORELEASER_DISTRIBUTION:$GORELEASER_VERSION AS goreleaser

FROM ghcr.io/sigstore/cosign/cosign:v3.0.4 AS cosign-bin

FROM rust:1.92.0-bookworm AS final

# Install cargo-binstall
RUN curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash

# Install cargo-zigbuild and cargo-xwin
RUN cargo binstall -y cargo-zigbuild cargo-xwin

# Install Zig
ARG ZIG_VERSION=0.10.1
RUN curl -L "https://ziglang.org/download/${ZIG_VERSION}/zig-linux-$(uname -m)-${ZIG_VERSION}.tar.xz" | tar -J -x -C /usr/local && \
    ln -s "/usr/local/zig-linux-$(uname -m)-${ZIG_VERSION}/zig" /usr/local/bin/zig

# Install macOS SDKs
RUN curl -L "https://github.com/phracker/MacOSX-SDKs/releases/download/11.3/MacOSX11.3.sdk.tar.xz" | tar -J -x -C /opt
ENV SDKROOT=/opt/MacOSX11.3.sdk

RUN set -eux; \
    # The way the debian package works requires that we add x86 support, even
    # though we are only going be running x86_64 executables. We could also
    # build from source, but that is out of scope.
    dpkg --add-architecture i386; \
    mkdir -pm755 /etc/apt/keyrings; \
    # wine
    wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key; \
    wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources; \
    # docker
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc; \
    chmod a+r /etc/apt/keyrings/docker.asc; \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian bookworm stable" > /etc/apt/sources.list.d/docker.list; \
    # enable backports for upx-ucl
    echo "deb http://deb.debian.org/debian bookworm-backports main" > /etc/apt/sources.list.d/backports.list; \
    apt-get update; \
    apt-get install --no-install-recommends -y clang winehq-staging cmake ninja-build \
        docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
        upx-ucl genisoimage tini git mercurial ca-certificates gnupg2 openssh-client make; \
    apt-get clean; \
    apt-get autoremove -y; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*;

# Install Rust targets
RUN rustup target add \
    x86_64-unknown-linux-gnu \
    x86_64-unknown-linux-musl \
    aarch64-unknown-linux-gnu \
    aarch64-unknown-linux-musl \
    arm-unknown-linux-gnueabihf \
    arm-unknown-linux-musleabihf \
    x86_64-apple-darwin \
    aarch64-apple-darwin \
    x86_64-pc-windows-gnu \
    aarch64-pc-windows-gnullvm \
    x86_64-pc-windows-msvc \
    aarch64-pc-windows-msvc \
    && rustup component add llvm-tools-preview

RUN cd $(mktemp -d) && \
    cargo new temp && \
    cd temp && \
    cargo xwin build --target x86_64-pc-windows-msvc && \
    cd / && rm -rf /tmp/*

# Install syft
RUN curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin

COPY --from=cosign-bin /ko-app/cosign /usr/local/bin/cosign

COPY --from=goreleaser /usr/bin/goreleaser /usr/bin/goreleaser

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/usr/bin/tini", "--", "/entrypoint.sh"]
