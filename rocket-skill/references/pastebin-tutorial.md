# Pastebin Tutorial — Rocket v0.5

A complete step-by-step example of building a pastebin service with Rocket. The live version is at [paste.rs](https://paste.rs).

## Design

Three routes:
- `GET /` — Returns usage instructions
- `POST /` — Accepts raw data, stores it, returns a URL
- `GET /<id>` — Retrieves stored paste by ID

## Setup

```bash
cargo new --bin rocket-pastebin
cd rocket-pastebin
```

```toml
# Cargo.toml
[dependencies]
rocket = "0.5.1"
```

## Skeleton

```rust
// src/main.rs
#[macro_use] extern crate rocket;

#[launch]
fn rocket() -> _ {
    rocket::build()
}
```

## Route 1: Index

```rust
#[get("/")]
fn index() -> &'static str {
    "
    USAGE
      POST /
          accepts raw data in the body and responds with a URL
          of a page containing the body's content

      GET /<id>
          retrieves the content for the paste with id `<id>`
    "
}
```

## Route 2: Retrieve Paste

The challenge: IDs should only accept alphanumeric characters. Use a custom `FromParam` type:

```rust
use std::fmt;
use std::path::{Path, PathBuf};
use rocket::request::FromParam;

/// A _potentially_ valid paste ID.
pub struct PasteId<'a>(std::borrow::Cow<'a, str>);

impl<'a> PasteId<'a> {
    /// Returns the path to the paste in `upload/` given the paste id.
    pub fn file_path(&self) -> PathBuf {
        Path::new("upload").join(self.0.as_ref())
    }
}

impl<'a> fmt::Display for PasteId<'a> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.0)
    }
}

impl<'a> FromParam<'a> for PasteId<'a> {
    type Error = &'a str;

    fn from_param(param: &'a str) -> Result<Self, Self::Error> {
        // Only allow alphanumeric characters
        let valid = param.chars().all(|c| c.is_ascii_alphanumeric());
        if valid { Ok(PasteId(param.into())) } else { Err(param) }
    }
}
```

```rust
use rocket::fs::NamedFile;

#[get("/<id>")]
async fn retrieve(id: PasteId<'_>) -> Option<NamedFile> {
    NamedFile::open(id.file_path()).await.ok()
}
```

## Route 3: Upload

Generate a random ID with a helper:

```rust
use rand::{self, Rng};

const ID_LENGTH: usize = 8;
const BASE62: &[u8] = b"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";

fn new_id() -> String {
    let mut id = String::with_capacity(ID_LENGTH);
    let mut rng = rand::thread_rng();
    for _ in 0..ID_LENGTH {
        id.push(BASE62[rng.gen::<usize>() % 62] as char);
    }
    id
}
```

Add `rand` to `Cargo.toml`:
```toml
[dependencies]
rand = "0.8"
```

```rust
use std::io;
use rocket::data::{Data, ToByteUnit};
use rocket::http::uri::Absolute;
use rocket::response::Debug;

// 128 KiB limit
const LIMIT: u64 = 128;

#[post("/", data = "<paste>")]
async fn upload(paste: Data<'_>, host: &rocket::http::uri::Host<'_>)
    -> Result<String, Debug<io::Error>>
{
    let id = PasteId::new(new_id());
    paste.open(LIMIT.kibibytes())
        .into_file(id.file_path()).await?;
    
    let url = format!("http://{}/{}\n", host, id);
    Ok(url)
}
```

## Final main.rs

```rust
#[macro_use] extern crate rocket;

use rocket::data::{Data, ToByteUnit};
use rocket::fs::NamedFile;
use rocket::http::uri::Host;
use rocket::response::Debug;
use std::io;

mod paste_id; // in src/paste_id.rs
use paste_id::PasteId;

const LIMIT: u64 = 128;
const UPLOAD_DIR: &str = "upload";

#[get("/")]
fn index() -> &'static str {
    "USAGE\n  POST /  — upload paste\n  GET /<id> — retrieve paste\n"
}

#[get("/<id>")]
async fn retrieve(id: PasteId<'_>) -> Option<NamedFile> {
    NamedFile::open(id.file_path(UPLOAD_DIR)).await.ok()
}

#[post("/", data = "<paste>")]
async fn upload(paste: Data<'_>, host: &Host<'_>) -> Result<String, Debug<io::Error>> {
    let id_str = generate_id(8);
    let id = PasteId::new(id_str);
    paste.open(LIMIT.kibibytes()).into_file(id.file_path(UPLOAD_DIR)).await?;
    Ok(format!("http://{}/{}\n", host, id))
}

#[launch]
fn rocket() -> _ {
    std::fs::create_dir_all(UPLOAD_DIR).unwrap();
    rocket::build().mount("/", routes![index, retrieve, upload])
}
```

## Testing

```bash
# Run the server
cargo run

# Upload a paste
curl --data-binary @Cargo.toml http://localhost:8000/

# Retrieve the paste
curl http://localhost:8000/<returned-id>
```

## Key Takeaways

1. **Custom `FromParam`** validates and converts path segments before the handler runs
2. **`Data` guard** streams raw body data — use `.open(limit)` to prevent DoS
3. **`NamedFile`** automatically sets Content-Type from file extension
4. **`Host` guard** retrieves the request host for building URLs
5. **`Debug<E>`** wraps errors to implement `Responder` (returns 500)
6. Always create directories before use (`std::fs::create_dir_all`)
