# Configuration & Deployment — Rocket v0.5

## Configuration System

Rocket uses [Figment](https://docs.rs/figment) for configuration. Configuration is profile-based (debug, release, custom).

### Default Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `address` | `IpAddr` | `127.0.0.1` | Bind address |
| `port` | `u16` | `8000` | Bind port |
| `workers` | `usize` | CPU count × 2 | Async worker threads |
| `max_blocking` | `usize` | `512` | Blocking thread pool size |
| `keep_alive` | `u32` (secs) | `5` | HTTP keep-alive timeout |
| `log_level` | `LogLevel` | `normal` | Logging verbosity |
| `cli_colors` | `bool` | `true` | Colored console output |
| `secret_key` | `SecretKey` | `None` | For private cookies (256-bit base64) |
| `tls` | `TlsConfig` | `None` | TLS certificate/key paths |
| `limits` | `Limits` | defaults | Data size limits |
| `ident` | `string/false` | `"Rocket"` | `Server` response header |
| `ip_header` | `string/false` | `"X-Real-IP"` | Real IP header |
| `temp_dir` | `path` | `/tmp` | Temp file directory |

### Rocket.toml

```toml
## Applies to ALL profiles
[default]
address = "0.0.0.0"
port = 8000
workers = 4
keep_alive = 5
log_level = "normal"
temp_dir = "/tmp"

[default.limits]
form = "64 kB"
json = "10 MiB"
"file/jpg" = "5 MiB"
"file/pdf" = "10 MiB"

## Debug profile (cargo build / cargo run)
[debug]
port = 8000
log_level = "debug"

## Release profile (cargo build --release)
[release]
address = "0.0.0.0"
port = 8080
log_level = "critical"
secret_key = "hPrYyЭRiMyµ5sBB1π+CMæ1køFsåqKvBiQJxBVHQk="

## Custom profile
[staging]
address = "0.0.0.0"
port = 8443
```

### Environment Variables

All `ROCKET_*` variables override `Rocket.toml`:

```bash
ROCKET_ADDRESS=0.0.0.0
ROCKET_PORT=8080
ROCKET_WORKERS=8
ROCKET_LOG_LEVEL=normal
ROCKET_SECRET_KEY="base64encodedkey=="
ROCKET_TLS='{certs="cert.pem",key="key.pem"}'
ROCKET_LIMITS='{json="10MiB",form="64kB"}'
ROCKET_DATABASES='{my_db={url="sqlite:///data/db.sqlite"}}'

# Select profile
ROCKET_PROFILE=staging cargo run
```

### Selecting Profile

```bash
# Run with release profile
ROCKET_PROFILE=release cargo run --release

# Or in Figment code
rocket::custom(rocket::Config::figment().select("staging"))
```

### TLS Configuration

```toml
[default.tls]
certs = "path/to/cert-chain.pem"
key = "path/to/key.pem"
```

Requires the `tls` feature:
```toml
rocket = { version = "0.5.1", features = ["tls"] }
```

### Mutual TLS

```toml
[default.tls]
certs = "certs/ca.pem"
key = "certs/server.key.pem"
mutual.ca_certs = "certs/ca.cert.pem"
mutual.mandatory = true
```

### Generating a Secret Key

```bash
openssl rand -base64 32
```

Or use Rocket's CLI tool.

### Extracting Config Values

```rust
use rocket::serde::Deserialize;

#[derive(Deserialize)]
#[serde(crate = "rocket::serde")]
struct AppConfig {
    api_key: String,
    max_results: usize,
}

#[launch]
fn rocket() -> _ {
    let figment = rocket::Config::figment()
        .merge(("api_key", "secret123"))
        .merge(("max_results", 50usize));
    
    rocket::custom(figment)
        .attach(AdHoc::config::<AppConfig>())
        .mount("/", routes![index])
}
```

### Custom Config Provider

```rust
use rocket::figment::{Figment, Profile, providers::{Env, Format, Toml}};

let figment = Figment::from(rocket::Config::default())
    .merge(Toml::file("Rocket.toml").nested())
    .merge(Env::prefixed("APP_").global())
    .select(Profile::from_env_or("APP_PROFILE", "default"));

rocket::custom(figment)
```

## Deployment

### General Preparation

1. **Set address**: `ROCKET_ADDRESS=0.0.0.0` (listen on all interfaces)
2. **Set port**: Typically `80`, `443`, or `8080`
3. **Set log level**: `critical` for production
4. **Set secret key**: Required for private cookies, JWT
5. **Bundle assets**: Include `templates/`, `static/` directories

### Self-Managed — Direct Binary

```bash
# Cross-compile script (deploy.sh)
PKG="my_app"                                    # cargo package name
TARGET="x86_64-unknown-linux-gnu"              # remote target
ASSETS=("Rocket.toml" "static" "templates")   # assets to bundle
BUILD_DIR="target/${TARGET}/release"

# Install target toolchain
rustup target add "${TARGET}"

# Build with cargo-zigbuild (for cross-compilation)
cargo install cargo-zigbuild
cargo zigbuild --release --target "${TARGET}"

# Bundle
mkdir -p "${PKG}-bundle"
cp "${BUILD_DIR}/${PKG}" "${PKG}-bundle/"
for asset in "${ASSETS[@]}"; do
    cp -r "${asset}" "${PKG}-bundle/" 2>/dev/null || true
done
tar -czf "${PKG}.tar.gz" "${PKG}-bundle"
echo "Bundle ready: ${PKG}.tar.gz"
```

### Containerization (Docker)

```dockerfile
# Build stage
FROM rust:1.75 as builder

WORKDIR /usr/src/app
COPY Cargo.toml Cargo.lock ./
RUN mkdir src && echo "fn main() {}" > src/main.rs
RUN cargo build --release
RUN rm src/main.rs

COPY src ./src
RUN touch src/main.rs && cargo build --release

# Runtime stage
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=builder /usr/src/app/target/release/my_app .
COPY Rocket.toml .
COPY static ./static
COPY templates ./templates

ENV ROCKET_ADDRESS=0.0.0.0
ENV ROCKET_PORT=8080
EXPOSE 8080

CMD ["./my_app"]
```

```dockerfile
# Minimalist Docker with Alpine
FROM rust:1.75-alpine as builder
RUN apk add --no-cache musl-dev
WORKDIR /app
COPY . .
RUN cargo build --release --target x86_64-unknown-linux-musl

FROM scratch
COPY --from=builder /app/target/x86_64-unknown-linux-musl/release/my_app /
CMD ["/my_app"]
```

### docker-compose.yml

```yaml
version: '3.8'
services:
  api:
    build: .
    ports:
      - "8080:8080"
    environment:
      - ROCKET_ADDRESS=0.0.0.0
      - ROCKET_PORT=8080
      - ROCKET_LOG_LEVEL=normal
      - ROCKET_SECRET_KEY=${SECRET_KEY}
      - ROCKET_DATABASES__my_db__url=postgres://user:pass@db/mydb
    depends_on:
      - db
    restart: unless-stopped

  db:
    image: postgres:15
    environment:
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=pass
      - POSTGRES_DB=mydb
    volumes:
      - pg_data:/var/lib/postgresql/data

volumes:
  pg_data:
```

### Fully Managed (PaaS)

**Railway / Render / Fly.io — Procfile:**
```
web: ./target/release/my_app
```

**fly.toml:**
```toml
[build]
  [build.args]
    RUST_VERSION = "1.75"

[[services]]
  http_checks = []
  internal_port = 8080
  protocol = "tcp"

  [[services.ports]]
    force_https = true
    handlers = ["http"]
    port = 80

  [[services.ports]]
    handlers = ["tls", "http"]
    port = 443
```

### Reverse Proxy (Nginx)

```nginx
server {
    listen 80;
    server_name example.com;
    
    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Configure Rocket to read the real IP:
```toml
[release]
ip_header = "X-Real-IP"
```

### Systemd Service

```ini
[Unit]
Description=My Rocket Application
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/opt/my_app
ExecStart=/opt/my_app/my_app
Restart=on-failure
Environment=ROCKET_ENV=release
Environment=ROCKET_ADDRESS=127.0.0.1
Environment=ROCKET_PORT=8000

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl enable my_app
sudo systemctl start my_app
```

### Graceful Shutdown

Rocket handles `SIGTERM` and `Ctrl+C` gracefully by default:

```toml
[default.shutdown]
ctrlc = true      # Ctrl+C triggers graceful shutdown
grace = 5         # seconds to wait for existing requests to finish
mercy = 5         # additional seconds before force-kill
signals = ["term", "hup"]  # Unix signals that trigger shutdown
force = false     # If true, force kill after mercy period
```
