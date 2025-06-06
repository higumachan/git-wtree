# Build stage
FROM rust:alpine AS builder

RUN apk add --no-cache musl-dev git pkgconfig openssl-dev

WORKDIR /app

# Copy dependency files first for better caching
COPY Cargo.toml ./

# Create dummy main.rs to build dependencies
RUN mkdir src && \
    echo "fn main() {}" > src/main.rs && \
    cargo build --release && \
    rm -rf src

# Copy source code and build
COPY src ./src
RUN cargo build --release

# Runtime stage
FROM alpine:3.19

# Install runtime dependencies
RUN apk add --no-cache \
    git \
    fish \
    bash \
    ca-certificates

# Copy the built binary
COPY --from=builder /app/target/release/git-wtree /usr/local/bin/

# Create non-root user for running tests
RUN adduser -D testuser
USER testuser
WORKDIR /home/testuser

# Set git config for testing
RUN git config --global user.email "test@example.com" && \
    git config --global user.name "Test User"

ENTRYPOINT ["fish"]