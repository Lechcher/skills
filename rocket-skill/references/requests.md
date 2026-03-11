# Requests — Rocket v0.5

## Methods

Route attributes correspond to HTTP methods:

```rust
#[get("/")]    // GET
#[post("/")]   // POST
#[put("/")]    // PUT
#[delete("/")]  // DELETE
#[patch("/")]  // PATCH
#[head("/")]   // HEAD
#[options("/")]// OPTIONS
```

### HEAD Requests
Rocket handles HEAD requests automatically for GET routes — it strips the body from the response.

### Method Reinterpreting
HTML forms only support GET and POST. To use PUT, DELETE, etc., add a hidden `_method` field:

```html
<form method="post" action="/item">
  <input type="hidden" name="_method" value="delete" />
  <button type="submit">Delete</button>
</form>
```

## Dynamic Paths

```rust
// Single dynamic segment
#[get("/hello/<name>")]
fn hello(name: &str) -> String { format!("Hello, {}!", name) }

// Multiple segments
#[get("/hello/<name>/<age>/<cool>")]
fn hello(name: &str, age: u8, cool: bool) -> String {
    if cool { format!("You're a cool {} year old, {}!", age, name) }
    else { format!("{}, talk about coolness.", name) }
}

// Multi-segment wildcard (PathBuf)
#[get("/files/<file..>")]
fn files(file: PathBuf) -> Option<NamedFile> {
    NamedFile::open(Path::new("static/").join(file)).await.ok()
}

// Ignored segments
#[get("/foo/<_>/bar")]
fn foo_bar() -> &'static str { "Foo bar!" }
```

### FromParam Implementations
Built-in: `String`, `&str`, `&RawStr`, `f32`, `f64`, `isize`, `i8`–`i128`, `usize`, `u8`–`u128`, `bool`, `IpAddr`, `Ipv4Addr`, `Ipv6Addr`, `SocketAddr`, `SocketAddrV4`, `SocketAddrV6`.

Custom implementation:
```rust
use rocket::request::FromParam;

struct MyId(String);

impl<'a> FromParam<'a> for MyId {
    type Error = &'a str;

    fn from_param(param: &'a str) -> Result<Self, Self::Error> {
        if param.starts_with("id_") {
            Ok(MyId(param.to_string()))
        } else {
            Err(param)
        }
    }
}
```

## Forwarding

When a guard fails with `Outcome::Forward`, Rocket tries the next matching route:

```rust
#[get("/user/<id>", rank = 1)]
fn user(id: usize) -> &'static str { "usize user" }

#[get("/user/<id>", rank = 2)]
fn user_int(id: isize) -> &'static str { "isize user" }

#[get("/user/<id>", rank = 3)]
fn user_str(id: &str) -> &'static str { "str user" }
```

**Default Rank**: Rocket assigns a rank based on how specific the route is. More specific = lower rank (higher priority).

## Request Guards

Implement `FromRequest` for custom types used as handler arguments (not named in route attribute):

```rust
use rocket::request::{self, FromRequest, Outcome};
use rocket::http::Status;

struct User { name: String }

#[derive(Debug)]
enum UserError { Missing, Invalid }

#[rocket::async_trait]
impl<'r> FromRequest<'r> for User {
    type Error = UserError;

    async fn from_request(req: &'r rocket::Request<'_>) -> Outcome<Self, Self::Error> {
        match req.headers().get_one("X-User") {
            Some(name) => Outcome::Success(User { name: name.to_string() }),
            None => Outcome::Error((Status::Unauthorized, UserError::Missing)),
        }
    }
}

#[get("/profile")]
fn profile(user: User) -> String { format!("Hello {}", user.name) }
```

### Forwarding Guards

Return `Outcome::Forward` to pass to the next matching route.

### Fallible Guards (Option/Result)

```rust
#[get("/sensitive")]
fn sensitive(key: Option<ApiKey>, data: Result<Data, DataError>) -> String { /* .. */ }
```

## Cookies

Built-in request guard `&CookieJar<'_>`:

```rust
use rocket::http::CookieJar;

#[get("/")]
fn index(cookies: &CookieJar<'_>) -> Option<String> {
    cookies.get("message").map(|c| format!("Message: {}", c.value()))
}

#[get("/set")]
fn set(cookies: &CookieJar<'_>) {
    cookies.add(Cookie::new("message", "hello"));
}

#[get("/remove")]
fn remove(cookies: &CookieJar<'_>) {
    cookies.remove(Cookie::named("message"));
}
```

### Private Cookies

Requires the `secrets` feature. Cookies are encrypted and signed:

```toml
rocket = { version = "0.5.1", features = ["secrets"] }
```

```rust
cookies.add_private(Cookie::new("session_id", "abc123"));
let session = cookies.get_private("session_id");
```

Requires `secret_key` in `Rocket.toml`.

## Format

Restrict routes by Content-Type (POST/PUT/PATCH/DELETE) or Accept (GET):

```rust
// Only matches if Content-Type: application/json
#[post("/user", format = "json", data = "<user>")]
fn new_user(user: Json<User>) -> Json<User> { user }

// Only matches if Accept: application/json
#[get("/user/<id>", format = "json")]
fn get_user(id: usize) -> Json<User> { /* .. */ }
```

Shorthand formats: `"json"`, `"html"`, `"plain"`, `"msgpack"`, `"form"`, etc.

## Body Data

Use `data = "<param>"` and a type implementing `FromData`:

```rust
// JSON bodies
#[post("/create", data = "<item>", format = "json")]
async fn create(item: Json<NewItem>) -> Created<Json<Item>> { /* .. */ }

// Raw bytes/string
#[post("/upload", data = "<body>")]
async fn upload(body: Data<'_>) -> Result<String, std::io::Error> {
    let string = body.open(2.mebibytes()).into_string().await?;
    Ok(string.value)
}

// Temporary file
use rocket::fs::TempFile;

#[post("/upload", data = "<file>")]
async fn upload(mut file: TempFile<'_>) -> Result<(), std::io::Error> {
    file.persist_to("/storage/uploads/file").await
}
```

## Forms

Full support for multipart and URL-encoded forms:

```rust
use rocket::form::Form;

#[derive(FromForm)]
struct Submit<'r> {
    username: &'r str,
    password: &'r str,
    #[field(name = "remember-me")]
    remember: bool,
}

#[post("/login", data = "<form>")]
fn login(form: Form<Submit<'_>>) -> String {
    format!("Hello, {}", form.username)
}
```

### Multipart / File Upload

```rust
#[derive(FromForm)]
struct Upload<'r> {
    save: bool,
    file: TempFile<'r>,
}

#[post("/upload", data = "<form>")]
async fn upload(mut form: Form<Upload<'_>>) -> String {
    if form.save {
        form.file.persist_to("/data/uploads").await.unwrap();
    }
    format!("Got: {:?}", form.file.name())
}
```

### Ad-hoc Validation

```rust
#[derive(FromForm)]
struct Login<'r> {
    #[field(validate = len(1..))]
    username: &'r str,
    #[field(validate = len(8..))]
    password: &'r str,
}
```

### Form Context (for re-displaying with errors)

```rust
use rocket::form::Context;

#[post("/submit", data = "<form>")]
fn submit(form: Form<Contextual<'_, Submit<'_>>>) -> /* Template */ { /* .. */ }
```

## Query Strings

Query parameters use the same `FromForm` trait as form fields:

```rust
#[get("/search?<q>&<page>")]
fn search(q: &str, page: Option<usize>) -> String {
    format!("Searching '{}' on page {}", q, page.unwrap_or(1))
}
```

### Trailing Query Parameter

```rust
#[get("/items?<filter..>")]
fn items(filter: HashMap<&str, &str>) -> String { /* .. */ }
```

## Error Catchers

```rust
use rocket::Request;

#[catch(404)]
fn not_found(req: &Request) -> String {
    format!("'{}' was not found.", req.uri())
}

#[catch(422)]
fn unprocessable(req: &Request) -> String {
    format!("Unprocessable entity for '{}'", req.uri())
}

#[catch(default)]
fn default_catcher(status: Status, req: &Request) -> String {
    format!("{} for '{}'", status, req.uri())
}

// Register
rocket::build().register("/", catchers![not_found, unprocessable, default_catcher])
```

### Scoping

Catchers can be scoped to path prefixes:
```rust
rocket::build()
    .register("/api", catchers![api_404])
    .register("/", catchers![global_404])
```
