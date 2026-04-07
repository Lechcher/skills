# Rocket FAQ — v0.5

## About Rocket

### Is Rocket monolithic like Rails, or minimal like Flask?

Neither! Rocket's core is small but complete with respect to security and correctness. It includes:
- Guard traits: `FromRequest`, `FromData`, `FromParam`, `FromForm`, `FromSegments`
- Derive macros for all common traits
- Attribute macros for routing
- Compile and launch-time checking
- Zero-copy parsers for multipart, SSE, etc.
- Optional features: TLS, secrets, JSON, msgpack

Functionality like templating, sessions, and ORMs is provided by companion crates (`rocket_dyn_templates`, `rocket_db_pools`) outside of Rocket's core.

### Can I use Rocket in production?

Yes! Recommended caveats:
1. Run Rocket behind a **reverse proxy** (HAProxy, Nginx) to handle DDoS/DoS
2. Always check for new Rocket **security advisories** before releasing
3. Use a **reverse proxy** for TLS termination (Nginx/Caddy) or Rocket's built-in TLS

### What about performance?

Rocket uses **Tokio** async runtime and **Hyper** HTTP library — production-grade performance. It is intentionally not optimized for raw benchmark numbers, prioritizing correctness and security instead. The compile-time overhead is higher than some frameworks, but runtime overhead is minimal.

## How To

### WebSockets

Use the official `rocket_ws` crate:
```toml
[dependencies]
rocket_ws = "0.1"
```
```rust
use rocket_ws as ws;

#[get("/echo")]
fn echo_socket(ws: ws::WebSocket) -> ws::Stream!['static] {
    ws.stream(|io| io)
}
```

### Server-Sent Events (SSE)

Built into Rocket via `EventStream`:
```rust
use rocket::response::stream::{EventStream, Event};

#[get("/events")]
fn events() -> EventStream![] {
    EventStream! {
        loop {
            yield Event::data("tick");
            rocket::tokio::time::sleep(Duration::from_secs(1)).await;
        }
    }
}
```

### Global State

Don't use `lazy_static!` or `once_cell`. Use Rocket's managed state instead:
```rust
// DON'T:
// static MY_STATE: Lazy<Mutex<Data>> = Lazy::new(|| Mutex::new(Data::new()));

// DO:
rocket::build().manage(MyState::new())
```

### File Uploads

Use `Form<TempFile>` as a data guard:
```rust
use rocket::fs::TempFile;
use rocket::form::Form;

#[derive(FromForm)]
struct Upload<'r> {
    file: TempFile<'r>,
}

#[post("/upload", data = "<form>")]
async fn upload(mut form: Form<Upload<'_>>) -> String {
    form.file.persist_to("/storage/uploads/file.pdf").await.unwrap();
    "Uploaded!".into()
}
```

### `&Request` in a Handler

You don't need it directly. Rocket's guard system handles request validation. Use:
- `FromParam` for path segments
- `FromSegments` for multi-segment paths  
- `FromData` for body data
- `FromForm` for form data
- `FromRequest` for arbitrary request validation

### Response Headers

Add headers via a custom `Responder`:
```rust
use rocket::response::{self, Response, Responder};
use rocket::http::{Header, Status};

struct CachedResponse<T>(T);

impl<'r, 'o: 'r, T: Responder<'r, 'o>> Responder<'r, 'o> for CachedResponse<T> {
    fn respond_to(self, req: &'r rocket::Request<'_>) -> response::Result<'o> {
        Response::build_from(self.0.respond_to(req)?)
            .header(Header::new("Cache-Control", "max-age=3600"))
            .ok()
    }
}
```

Or via a fairing (for all responses):
```rust
AdHoc::on_response("Add Header", |_, res| Box::pin(async move {
    res.set_header(Header::new("X-Custom", "value"));
}))
```

### CORS

Use a response fairing - Rocket does not include CORS out of the box:
```rust
AdHoc::on_response("CORS", |req, res| Box::pin(async move {
    res.set_header(Header::new("Access-Control-Allow-Origin", "*"));
    res.set_header(Header::new("Access-Control-Allow-Methods", "GET, POST, OPTIONS"));
    res.set_header(Header::new("Access-Control-Allow-Headers", "Content-Type, Authorization"));
}))
```

For a full CORS implementation, consider the `rocket_cors` crate.

### Authentication / Authorization

Use request guards:
```rust
struct AuthenticatedUser { id: u64 }

#[rocket::async_trait]
impl<'r> FromRequest<'r> for AuthenticatedUser {
    type Error = AuthError;

    async fn from_request(req: &'r Request<'_>) -> Outcome<Self, Self::Error> {
        let token = req.headers().get_one("Authorization")
            .and_then(|h| h.strip_prefix("Bearer "));
        
        match token {
            Some(t) => match verify_jwt(t) {
                Ok(id) => Outcome::Success(AuthenticatedUser { id }),
                Err(_) => Outcome::Error((Status::Unauthorized, AuthError::Invalid)),
            },
            None => Outcome::Error((Status::Unauthorized, AuthError::Missing)),
        }
    }
}
```

### Rate Limiting

Use request-local state + managed state:
```rust
use std::time::{Duration, Instant};
use std::collections::HashMap;
use std::sync::Mutex;

struct RateLimiter(Mutex<HashMap<IpAddr, (u32, Instant)>>);

#[rocket::async_trait]
impl<'r> FromRequest<'r> for RateLimitPassed {
    type Error = ();

    async fn from_request(req: &'r Request<'_>) -> Outcome<Self, ()> {
        let limiter = req.guard::<&State<RateLimiter>>().await.unwrap();
        let ip = req.client_ip().unwrap_or(IpAddr::from([0;4]));
        let mut map = limiter.0.lock().unwrap();
        
        let entry = map.entry(ip).or_insert((0, Instant::now()));
        if entry.1.elapsed() > Duration::from_secs(60) {
            *entry = (0, Instant::now()); // reset window
        }
        entry.0 += 1;
        
        if entry.0 > 100 { // 100 reqs/min
            Outcome::Error((Status::TooManyRequests, ()))
        } else {
            Outcome::Success(RateLimitPassed)
        }
    }
}
```

## Debugging

### Enable Debug Logging

```bash
ROCKET_LOG_LEVEL=debug cargo run
```

### Codegen Debug

```bash
ROCKET_CODEGEN_DEBUG=1 cargo build 2>&1 | head -100
```

### Common Issues

**"secret_key is not configured"**
Add to `Rocket.toml`:
```toml
[default]
secret_key = "hPrYyЭRiMyµ5sBB1π+CMæ1køFsåqKvBiQJxBVHQk="
```
Generate with: `openssl rand -base64 32`

**"Data limit exceeded"**
Increase limits in `Rocket.toml`:
```toml
[default.limits]
json = "10 MiB"
file = "50 MiB"
```

**Route not matching**
- Check method matches (`#[get]` vs `#[post]`)
- Check format parameter matches `Content-Type` header
- Check guard failures (guards forward to next route if they fail)
- Use `rank` attribute for route priority
