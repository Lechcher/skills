# Fairings & Testing — Rocket v0.5

## Fairings (Middleware)

Fairings are Rocket's structured middleware. They hook into the request lifecycle without being able to terminate or directly respond to requests (unlike request guards).

### When to Use Fairings (vs. Request Guards)

| Use Fairings For | Use Request Guards For |
|-----------------|----------------------|
| Global logging | Per-route auth |
| Global CORS headers | Per-route rate limiting |
| Request timing/metrics | Per-route validation |
| Application-wide security policies | Data extraction |

### Fairing Callbacks

| Callback | When Called | Use For |
|----------|------------|---------|
| `on_ignite` | App startup | Config parsing, state initialization |
| `on_liftoff` | After server launched | Spawning background tasks |
| `on_request` | Every incoming request | Request logging, modification |
| `on_response` | Before response sent | Add headers, rewrite responses |
| `on_shutdown` | Shutdown triggered | Cleanup, flush buffers |

### Ad-hoc Fairings (Simple)

```rust
use rocket::fairing::AdHoc;
use rocket::http::Header;

rocket::build()
    // on_ignite: parse config at startup
    .attach(AdHoc::on_ignite("Config Parser", |rocket| async {
        let config = rocket.figment().extract::<AppConfig>().unwrap();
        Ok(rocket.manage(config))
    }))
    // on_liftoff: print server info
    .attach(AdHoc::on_liftoff("Banner", |rocket| Box::pin(async move {
        let addr = rocket.config().address;
        let port = rocket.config().port;
        println!("🚀 Server running at http://{}:{}", addr, port);
    })))
    // on_request: logging
    .attach(AdHoc::on_request("Logger", |req, _| Box::pin(async move {
        println!("[REQ] {} {}", req.method(), req.uri());
    })))
    // on_response: add CORS headers
    .attach(AdHoc::on_response("CORS", |_, res| Box::pin(async move {
        res.set_header(Header::new("Access-Control-Allow-Origin", "*"));
        res.set_header(Header::new("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS"));
        res.set_header(Header::new("Access-Control-Allow-Headers", "Content-Type, Authorization"));
    })))
    // on_shutdown: cleanup
    .attach(AdHoc::on_shutdown("Cleanup", |_| Box::pin(async move {
        println!("Shutting down gracefully...");
    })))
```

### Custom Fairing (Full Implementation)

```rust
use std::sync::atomic::{AtomicUsize, Ordering};
use rocket::{Request, Data, Response};
use rocket::fairing::{Fairing, Info, Kind};
use rocket::http::{Method, ContentType, Status};
use std::io::Cursor;

pub struct Counter {
    pub get: AtomicUsize,
    pub post: AtomicUsize,
}

#[rocket::async_trait]
impl Fairing for Counter {
    fn info(&self) -> Info {
        Info {
            name: "Request Counter",
            kind: Kind::Request | Kind::Response,
        }
    }

    async fn on_request(&self, request: &mut Request<'_>, _: &mut Data<'_>) {
        match request.method() {
            Method::Get  => { self.get.fetch_add(1, Ordering::Relaxed); }
            Method::Post => { self.post.fetch_add(1, Ordering::Relaxed); }
            _ => {}
        }
    }

    async fn on_response<'r>(&self, request: &'r Request<'_>, response: &mut Response<'r>) {
        // Serve /counts even if not routed
        if response.status() == Status::NotFound
            && request.method() == Method::Get
            && request.uri().path() == "/counts"
        {
            let body = format!(
                "GET: {}\nPOST: {}",
                self.get.load(Ordering::Relaxed),
                self.post.load(Ordering::Relaxed)
            );
            response.set_status(Status::Ok);
            response.set_header(ContentType::Plain);
            response.set_sized_body(body.len(), Cursor::new(body));
        }
    }
}

// Attach to rocket:
rocket::build()
    .attach(Counter { get: AtomicUsize::new(0), post: AtomicUsize::new(0) })
```

### Common Fairing Patterns

#### Request ID Fairing
```rust
use uuid::Uuid;

.attach(AdHoc::on_request("Request ID", |req, _| Box::pin(async move {
    let id = Uuid::new_v4().to_string();
    req.local_cache(|| RequestId(id));
})))
```

#### Rate Limiting (via on_response 429)
```rust
.attach(AdHoc::on_response("Rate Limit Check", |req, res| Box::pin(async move {
    // integrate with a rate limiter here
})))
```

#### Security Headers
```rust
.attach(AdHoc::on_response("Security Headers", |_, res| Box::pin(async move {
    res.set_header(Header::new("X-Frame-Options", "DENY"));
    res.set_header(Header::new("X-Content-Type-Options", "nosniff"));
    res.set_header(Header::new("Referrer-Policy", "no-referrer"));
    res.set_header(Header::new("Strict-Transport-Security", "max-age=31536000; includeSubDomains"));
})))
```

## Testing

Rocket provides a built-in testing library in `rocket::local`.

### Synchronous Tests

```rust
use rocket::local::blocking::Client;
use rocket::http::{Status, ContentType};

#[test]
fn test_index() {
    let client = Client::tracked(rocket()).expect("valid rocket");
    let response = client.get("/").dispatch();
    
    assert_eq!(response.status(), Status::Ok);
    assert_eq!(response.content_type(), Some(ContentType::Plain));
    assert_eq!(response.into_string().unwrap(), "Hello, world!");
}
```

### Asynchronous Tests

```rust
use rocket::local::asynchronous::Client;

#[rocket::async_test]
async fn test_async() {
    let client = Client::tracked(rocket()).await.expect("valid rocket");
    let response = client.get("/").dispatch().await;
    assert_eq!(response.status(), Status::Ok);
}
```

### Testing POST/JSON

```rust
use rocket::local::blocking::Client;
use rocket::http::{Status, ContentType};

#[test]
fn test_create_user() {
    let client = Client::tracked(rocket()).unwrap();
    let body = r#"{"name": "Alice", "age": 30}"#;
    
    let response = client
        .post("/users")
        .header(ContentType::JSON)
        .body(body)
        .dispatch();
    
    assert_eq!(response.status(), Status::Created);
    let body: serde_json::Value = serde_json::from_str(
        &response.into_string().unwrap()
    ).unwrap();
    assert_eq!(body["name"], "Alice");
}
```

### Testing with Cookies

```rust
#[test]
fn test_login_session() {
    let client = Client::tracked(rocket()).unwrap();
    
    // Login
    let login_response = client
        .post("/login")
        .header(ContentType::Form)
        .body("username=admin&password=secret")
        .dispatch();
    assert_eq!(login_response.status(), Status::SeeOther);
    
    // Cookie persists automatically in tracked client
    let protected = client.get("/dashboard").dispatch();
    assert_eq!(protected.status(), Status::Ok);
}
```

### Testing Helpers

```rust
// Reusable test client fixture
fn test_client() -> Client {
    Client::tracked(rocket()).expect("valid rocket instance")
}

// Test a route returns a specific JSON structure
fn assert_json_body<T: for<'de> serde::Deserialize<'de>>(
    response: rocket::local::blocking::LocalResponse<'_>
) -> T {
    serde_json::from_str(&response.into_string().unwrap()).unwrap()
}
```

### Test Module Structure

```rust
#[cfg(test)]
mod tests {
    use super::*;
    use rocket::local::blocking::Client;
    use rocket::http::{Status, ContentType};

    fn client() -> Client {
        Client::tracked(super::rocket()).expect("valid rocket")
    }

    #[test]
    fn index_returns_200() {
        assert_eq!(client().get("/").dispatch().status(), Status::Ok);
    }

    #[test]
    fn not_found_returns_404() {
        assert_eq!(client().get("/nonexistent").dispatch().status(), Status::NotFound);
    }
}
```

### Codegen Debug

To inspect generated code for debugging:

```rust
// See the generated code for a route
#[get("/")]
fn index() -> &'static str { "Hi" }

// Set ROCKET_CODEGEN_DEBUG=1 env var to print generated code
```
