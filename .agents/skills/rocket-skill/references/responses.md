# Responses — Rocket v0.5

## Responder Trait

Any type that implements `Responder` can be returned from a handler. A `Response` includes status code, headers, and body (fixed-size or streaming).

```rust
// String — Content-Type: text/plain; charset=utf-8
#[get("/")]
fn index() -> &'static str { "Hello!" }

// Option<T> — 200 if Some, 404 if None
#[get("/optional")]
fn maybe() -> Option<String> { Some("value".into()) }

// Result<T, E> — 200 if Ok, 500 if Err (both implement Responder)
#[get("/result")]
fn result() -> Result<String, String> { Ok("ok".into()) }
```

## Status & Wrapping Responders

```rust
use rocket::http::Status;
use rocket::response::status;

// Explicit status code
#[get("/created")]
fn created() -> status::Created<String> {
    status::Created::new("http://example.com/resource")
        .body("Resource Created")
}

// Custom status
#[get("/custom")]
fn custom() -> (Status, String) {
    (Status::Accepted, "Processing...".into())
}
```

## Custom Responders (derive)

```rust
use rocket::response::Responder;

#[derive(Responder)]
#[response(status = 200, content_type = "json")]
struct ApiResponse {
    body: String,
    #[response(ignore)]
    debug_info: String,
}
```

## Built-in Rocket Responders

### NamedFile (Static Files)

```rust
use rocket::fs::NamedFile;
use std::path::{Path, PathBuf};

#[get("/static/<file..>")]
async fn files(file: PathBuf) -> Option<NamedFile> {
    NamedFile::open(Path::new("static/").join(file)).await.ok()
}

// Built-in FileServer fairing
use rocket::fs::FileServer;
rocket::build().mount("/static", FileServer::from("static/"))
```

### Redirect

```rust
use rocket::response::Redirect;

#[get("/old-page")]
fn old_page() -> Redirect {
    Redirect::to(uri!(new_page))
}

#[get("/new-page")]
fn new_page() -> &'static str { "New page!" }

// Redirect types
Redirect::to(uri)           // 303 See Other
Redirect::permanent(uri)    // 301 Moved Permanently
Redirect::temporary(uri)    // 307 Temporary Redirect
```

### JSON

Requires `features = ["json"]` in Cargo.toml:

```rust
use rocket::serde::{json::Json, Serialize, Deserialize};

#[derive(Serialize, Deserialize)]
#[serde(crate = "rocket::serde")]
struct Task {
    id: usize,
    title: String,
    complete: bool,
}

#[get("/tasks")]
fn get_tasks() -> Json<Vec<Task>> {
    Json(vec![
        Task { id: 1, title: "Buy milk".into(), complete: false }
    ])
}

#[post("/tasks", format = "json", data = "<task>")]
fn create_task(task: Json<Task>) -> Json<Task> {
    Json(task.into_inner())
}
```

### MessagePack

Requires `features = ["msgpack"]`:

```rust
use rocket::serde::msgpack::MsgPack;

#[post("/items", data = "<item>")]
fn create(item: MsgPack<Item>) -> MsgPack<Item> { item }
```

### Flash Messages

```rust
use rocket::response::Flash;
use rocket::http::CookieJar;

#[post("/login", data = "<form>")]
fn login(form: Form<Login<'_>>, cookies: &CookieJar<'_>) 
    -> Result<Redirect, Flash<Redirect>> 
{
    if valid(&form) {
        cookies.add_private(Cookie::new("user", form.username.to_string()));
        Ok(Redirect::to(uri!(dashboard)))
    } else {
        Err(Flash::error(Redirect::to(uri!(login_page)), "Invalid credentials."))
    }
}

#[get("/login")]
fn login_page(flash: Option<FlashMessage<'_>>) -> String {
    flash.map(|f| format!("{}: {}", f.kind(), f.message()))
         .unwrap_or_default()
}
```

### Async Streams (SSE)

```rust
use rocket::response::stream::{EventStream, Event};
use rocket::tokio::time::{self, Duration};

#[get("/events")]
fn events() -> EventStream![] {
    EventStream! {
        let mut interval = time::interval(Duration::from_secs(1));
        loop {
            yield Event::data(format!("tick {}", chrono::Utc::now()));
            interval.tick().await;
        }
    }
}
```

### WebSockets

Requires the `rocket_ws` crate:

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

## Templates

Requires `rocket_dyn_templates` crate:

```toml
[dependencies]
rocket_dyn_templates = { version = "0.2", features = ["tera"] }
# or features = ["handlebars"]
```

```rust
use rocket_dyn_templates::{Template, context};

#[get("/")]
fn index() -> Template {
    Template::render("index", context! {
        title: "My App",
        user: "Alice",
    })
}

#[launch]
fn rocket() -> _ {
    rocket::build()
        .mount("/", routes![index])
        .attach(Template::fairing())
}
```

Templates are discovered in the `templates/` directory (configurable via `template_dir`).

- `.html.tera` → Tera engine
- `.html.hbs` → Handlebars engine

Template name does **not** include the extension: `Template::render("index", ...)` for `templates/index.html.tera`.

### Live Reloading (debug only)

```rust
.attach(Template::custom(|engines| {
    engines.tera.autoescape_on(vec!["html"]);
}))
```

## Typed URIs

Type-safe, compile-time checked URI generation via `uri!` macro:

```rust
#[get("/<id>/profile?<name>")]
fn profile(id: usize, name: &str) { /* .. */ }

// Generate URI
let uri = uri!(profile(id = 42, name = "Alice"));
// => "/42/profile?name=Alice"

// Use with Redirect
Redirect::to(uri!(profile(id = 1, name = "Bob")))

// With mount point
let uri = uri!("/api", profile(id = 1, name = "Test"));
// => "/api/1/profile?name=Test"
```

Compile-time errors on parameter mismatches or type errors.

### UriDisplay — Custom Types in URIs

```rust
use rocket::http::uri::fmt::{UriDisplay, Path, Query};

#[derive(UriDisplayPath)]
struct UserId(usize);

#[derive(UriDisplayQuery)]
struct Filter { page: usize, limit: usize }
```

## Content Types

```rust
use rocket::response::content;

#[get("/")]
fn html_page() -> content::RawHtml<String> {
    content::RawHtml("<h1>Hello!</h1>".into())
}

#[get("/data")]
fn json_data() -> content::RawJson<&'static str> {
    content::RawJson(r#"{"key": "value"}"#)
}
```
