ARG RUST_VERSION=1.89-trixie

FROM debian:stable-slim AS internal-getter
WORKDIR /var/task

RUN apt-get update && apt-get install -y curl xz-utils gzip

# Download zig based on uname -m
ARG ZIG_VERSION=0.15.1
RUN ARCH=$(uname -m) && \
    FILE_NAME=zig-${ARCH}-linux-${ZIG_VERSION}.tar.xz && \
    curl -LO https://github.com/lucidfrontier45/zig-releases/releases/download/${ZIG_VERSION}/${FILE_NAME} && \
    tar xf ${FILE_NAME} && \
    mv zig-${ARCH}-linux-${ZIG_VERSION} /opt/zig 

# Download cargo-zigbuild
ARG CARGO_ZIGBUILD_VERSION=v0.20.1
RUN ARCH=$(uname -m) && \
    FILE_NAME=cargo-zigbuild-${CARGO_ZIGBUILD_VERSION}.${ARCH}-unknown-linux-musl.tar.gz && \
    curl -LO https://github.com/rust-cross/cargo-zigbuild/releases/download/${CARGO_ZIGBUILD_VERSION}/${FILE_NAME} && \
    tar xf ${FILE_NAME} && \
    mv cargo-zigbuild /opt/cargo-zigbuild

FROM rust:${RUST_VERSION} AS builder
WORKDIR /var/task

COPY --from=internal-getter /opt/zig /opt/zig
COPY --from=internal-getter /opt/cargo-zigbuild /usr/local/bin/cargo-zigbuild

ENV PATH="/opt/zig:${PATH}"