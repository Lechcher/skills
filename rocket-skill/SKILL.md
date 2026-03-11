---
name: rocket-skill
description: >-
  Expert Rocket web framework skill for Rust backend development. Activates when
  users ask about Rocket, Rust web servers, Rust REST APIs, Rust HTTP servers,
  building web applications in Rust, Rocket routes, Rocket handlers, Rocket
  request guards, Rocket fairings, Rocket state management, Rocket databases,
  Rocket configuration, Rocket deployment, Rocket testing, Rocket forms,
  Rocket JSON, Rocket templates, Rocket middleware, async Rust web, tokio web
  server, Rust web framework. Triggers on phrases like build Rocket app, create
  Rocket route, add Rocket middleware, Rocket error handler, connect database
  Rocket, deploy Rocket application, test Rocket endpoint, Rocket CORS, Rocket
  authentication, Rocket file upload.
license: MIT
metadata:
  author: Antigravity (crawled from rocket.rs/guide/v0.5)
  version: 1.0.0
  created: 2026-03-12
  last_reviewed: 2026-03-12
  review_interval_days: 90
  dependencies:
    - url: https://rocket.rs/guide/v0.5/
      name: Rocket Programming Guide v0.5
      type: documentation
    - url: https://api.rocket.rs/v0.5/rocket/
      name: Rocket API Documentation v0.5
      type: api
---
# /rocket-skill — Rocket Web Framework Expert for Rust

You are an expert in the **Rocket** web framework for Rust (v0.5). Your job is to help developers design, build, debug, and deploy web applications using Rocket — efficiently and with best practices.

## Trigger

User invokes `/rocket-skill` followed by their input:

```
/rocket-skill Create a REST API with CRUD operations
/rocket-skill Add JWT authentication to my Rocket app
/rocket-skill How do I handle file uploads?
/rocket-skill Connect my Rocket app to a PostgreSQL database
/rocket-skill Write tests for my routes
/rocket-skill Deploy my Rocket app to production
/rocket-skill Add CORS headers to all responses
```

The skill also activates naturally when users ask about Rocket, Rust web APIs, or any phrase matching the description keywords.

## Core Concepts Reference

### 1. Hello World

```rust
#[macro_use] extern crate rocket;

#[get("/")]
fn index() -> &'static str {
    "Hello, world!"
}

#[launch]
fn rocket() -> _ {
    rocket::build().mount("/", routes![index])
}
```

**Cargo.toml dependency:**
```toml
[dependencies]
rocket = "0.5.1"
```

### 2. Request Lifecycle

```
Routing → Validation → Processing → Response
```

1. **Routing**: Match URL + method to a handler via route attributes
2. **Validation**: Type-check params, run guards (`FromParam`, `FromRequest`, `FromData`)
3. **Processing**: Execute handler with validated arguments
4. **Response**: Generate and return HTTP response

### 3. Route Attributes

```rust
#[get("/path")]
#[post("/path", format = "json", data = "<body>")]
#[put("/path/<id>")]
#[delete("/path/<id>")]
#[patch("/path")]
#[head("/path")]
#[options("/path")]
#[catch(404)]  // error catcher
```

### 4. Dynamic Paths & Segments

```rust
// Single segment
#[get("/hello/<name>")]
fn hello(name: &str) -> String { format!("Hello, {}!", name) }

// Multiple segments
#[get("/hello/<name>/<age>/<cool>")]
fn hello(name: &str, age: u8, cool: bool) -> String { /* .. */ }

// Multi-segment wildcard
#[get("/static/<path..>")]
fn files(path: PathBuf) -> Option<NamedFile> { /* .. */ }
```

### 5. Request Guards

Implement `FromRequest` for custom validation before the handler is called:

```rust
use rocket::request::{self, Request, FromRequest};

struct ApiKey(String);

#[rocket::async_trait]
impl<'r> FromRequest<'r> for ApiKey {
    type Error = ApiKeyError;

    async fn from_request(req: &'r Request<'_>) -> request::Outcome<Self, Self::Error> {
        match req.headers().get_one("X-API-Key") {
            Some(key) => Outcome::Success(ApiKey(key.to_string())),
            None => Outcome::Error((Status::Unauthorized, ApiKeyError::Missing)),
        }
    }
}

#[get("/secure")]
fn secure(_key: ApiKey) -> &'static str { "authorized" }
```

### 6. Forms & Data

```rust
use rocket::form::Form;

#[derive(FromForm)]
struct Task<'r> {
    complete: bool,
    description: &'r str,
}

#[post("/todo", data = "<task>")]
fn new(task: Form<Task<'_>>) { /* .. */ }
```

**JSON:**
```rust
use rocket::serde::{json::Json, Deserialize, Serialize};

#[derive(Serialize, Deserialize)]
struct User { name: String, age: u8 }

#[post("/user", format = "json", data = "<user>")]
fn create_user(user: Json<User>) -> Json<User> { user }
```

Add to Cargo.toml: `rocket = { version = "0.5.1", features = ["json"] }`

### 7. Managed State

```rust
use std::sync::atomic::{AtomicUsize, Ordering};
use rocket::State;

struct HitCount(AtomicUsize);

#[get("/")]
fn index(count: &State<HitCount>) -> String {
    count.0.fetch_add(1, Ordering::Relaxed);
    format!("Count: {}", count.0.load(Ordering::Relaxed))
}

#[launch]
fn rocket() -> _ {
    rocket::build()
        .manage(HitCount(AtomicUsize::new(0)))
        .mount("/", routes![index])
}
```

### 8. Databases (rocket_db_pools)

```toml
# Cargo.toml
[dependencies.rocket_db_pools]
version = "0.2.0"
features = ["sqlx_sqlite"]  # or sqlx_postgres, sqlx_mysql, etc.
```

```toml
# Rocket.toml
[default.databases.my_db]
url = "sqlite:///path/to/db.sqlite"
```

```rust
use rocket_db_pools::{Database, Connection};
use rocket_db_pools::sqlx::{self, Row};

#[derive(Database)]
#[database("my_db")]
struct Db(sqlx::SqlitePool);

#[get("/items")]
async fn list(mut db: Connection<Db>) -> Result<String, String> {
    let rows = sqlx::query("SELECT id FROM items")
        .fetch_all(&mut **db).await
        .map_err(|e| e.to_string())?;
    Ok(format!("{} items", rows.len()))
}

#[launch]
fn rocket() -> _ {
    rocket::build()
        .attach(Db::init())
        .mount("/", routes![list])
}
```

### 9. Fairings (Middleware)

```rust
use rocket::fairing::AdHoc;

rocket::build()
    .attach(AdHoc::on_request("Logger", |req, _| Box::pin(async move {
        println!("Request: {} {}", req.method(), req.uri());
    })))
    .attach(AdHoc::on_response("CORS", |_, res| Box::pin(async move {
        res.set_header(rocket::http::Header::new("Access-Control-Allow-Origin", "*"));
    })));
```

### 10. Error Catchers

```rust
use rocket::Request;

#[catch(404)]
fn not_found(req: &Request) -> String {
    format!("'{}' was not found.", req.uri())
}

#[catch(500)]
fn server_error() -> &'static str { "Internal server error." }

#[launch]
fn rocket() -> _ {
    rocket::build()
        .register("/", catchers![not_found, server_error])
}
```

### 11. Configuration

`Rocket.toml`:
```toml
[default]
address = "0.0.0.0"
port = 8000
workers = 4
log_level = "normal"

[release]
port = 80
secret_key = "<generated_key>"

[default.limits]
json = "10 MiB"
form = "64 kB"
```

Environment variables: `ROCKET_ADDRESS`, `ROCKET_PORT`, `ROCKET_LOG_LEVEL`, etc.

### 12. Testing

```rust
#[cfg(test)]
mod tests {
    use super::rocket;
    use rocket::local::blocking::Client;
    use rocket::http::Status;

    #[test]
    fn test_index() {
        let client = Client::tracked(rocket()).expect("valid rocket");
        let response = client.get(uri!(super::index)).dispatch();
        assert_eq!(response.status(), Status::Ok);
        assert_eq!(response.into_string().unwrap(), "Hello, world!");
    }
}
```

### 13. Typed URIs

```rust
#[get("/<id>/profile")]
fn profile(id: usize) { /* .. */ }

// Type-safe URI generation (compile-time checked)
let uri = uri!(profile(id = 42));
// => "/42/profile"
```

## Workflow

When asked to build a feature or app:

1. **Understand** — Clarify the use case, data model, and auth requirements
2. **Design routes** — Define HTTP methods, paths, input/output types
3. **Implement guards** — For auth, rate limiting, headers, etc.
4. **Implement handlers** — One function per route, async where needed
5. **Add state/DB** — Use managed state or `rocket_db_pools`
6. **Add fairings** — For CORS, logging, request ID, etc.
7. **Configure** — `Rocket.toml` for all environments
8. **Test** — Unit tests with `local::blocking::Client`
9. **Deploy** — Compile for target, bundle assets, containerize

## References

- `references/requests.md` — Full requests chapter (routing, guards, forms, cookies, query strings)
- `references/responses.md` — Responses, responders, templates, typed URIs
- `references/state-databases.md` — State management, request-local state, databases
- `references/fairings-testing.md` — Fairings, testing patterns
- `references/configuration-deployment.md` — Configuration, deployment, containerization
- `references/pastebin-tutorial.md` — Complete step-by-step tutorial
- `references/faq.md` — Frequently asked questions
