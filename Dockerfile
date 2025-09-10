ARG RUST_VERSION=1.89-trixie

FROM --platform=$BUILDPLATFORM debian:stable-slim AS internal-getter
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

FROM --platform=$BUILDPLATFORM rust:${RUST_VERSION} AS builder_base

COPY --from=internal-getter /opt/zig /opt/zig
COPY --from=internal-getter /opt/cargo-zigbuild /usr/local/bin/cargo-zigbuild
ENV PATH="/opt/zig:${PATH}"

RUN rustup target add \
    x86_64-unknown-linux-gnu \
    x86_64-unknown-linux-musl \
    aarch64-unknown-linux-gnu \
    aarch64-unknown-linux-musl

FROM --platform=$BUILDPLATFORM builder_base AS builder
WORKDIR /usr/src/builder

# build your own project
ARG TARGETARCH
ARG FLAVOUR=musl
# COPY . .
# RUN ARCH=$(echo ${TARGETARCH} | sed -e 's/amd64/x86_64/' -e 's/arm64/aarch64/') && \
#    cargo zigbuild --release --locked --target $ARCH-unknown-linux-$FLAVOUR && \
#    cp target/$ARCH-unknown-linux-$FLAVOUR/release/app /bin/app


FROM debian:trixie-slim AS runner

# if you intend to deploy on AWS Lambda, add Lambda Web Adapter
# COPY --from=public.ecr.aws/awsguru/aws-lambda-adapter:0.9.1 /lambda-adapter /opt/extensions/lambda-adapter

# Copy the built binary from the builder stage
#COPY --from=builder /bin/app /usr/local/bin/app
#CMD ["/usr/local/bin/app"]