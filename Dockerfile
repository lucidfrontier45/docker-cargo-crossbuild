ARG RUST_VERSION=1.89-trixie

FROM --platform=$BUILDPLATFORM rust:${RUST_VERSION} AS builder_base
RUN apt update
RUN apt install -y \
    build-essential \
    crossbuild-essential-amd64 \
    crossbuild-essential-arm64 \
    musl-tools

RUN rustup target add \
    x86_64-unknown-linux-gnu \
    x86_64-unknown-linux-musl \
    aarch64-unknown-linux-gnu \
    aarch64-unknown-linux-musl


FROM --platform=$BUILDPLATFORM builder_base AS builder
WORKDIR /usr/src/builder

# build your own project
# COPY . .
#RUN ARCH=$(uname -m) && \
#    cargo build --release --locked --target $ARCH-unknown-linux-musl && \
#    cp target/$ARCH-unknown-linux-musl/release/app /bin/app


FROM debian:trixie-slim AS runner
COPY --from=public.ecr.aws/awsguru/aws-lambda-adapter:0.9.1 /lambda-adapter /opt/extensions/lambda-adapter

# Copy the built binary from the builder stage
#COPY --from=builder /bin/app /usr/local/bin/app
#CMD ["/usr/local/bin/app"]