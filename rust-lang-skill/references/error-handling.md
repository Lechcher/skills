# Rust Error Handling

Source: https://doc.rust-lang.org/book/ch09-00-error-handling.html

## Two Types of Errors

### 1. Unrecoverable Errors: `panic!`

```rust
// Explicit panic
panic!("something went terribly wrong");

// Automatic panic on invalid access
let v = vec![1, 2, 3];
v[99]; // panics: index out of bounds

// RUST_BACKTRACE=1 cargo run — for detailed stack trace
```

**When to use panic:**
- Tests (via `assert!`, `assert_eq!`, `unwrap()`)
- Prototyping
- When invariant violations are programming errors (not user errors)
- When recovery is impossible

### 2. Recoverable Errors: `Result<T, E>`

```rust
use std::fs::File;
use std::io::{self, Read};

// Basic Result handling
match File::open("hello.txt") {
    Ok(file) => println!("File opened"),
    Err(e) => println!("Error: {e}"),
}

// Matching on specific error kinds
use std::io::ErrorKind;
let f = match File::open("hello.txt") {
    Ok(file) => file,
    Err(e) => match e.kind() {
        ErrorKind::NotFound => match File::create("hello.txt") {
            Ok(fc) => fc,
            Err(e) => panic!("couldn't create: {e}"),
        },
        other => panic!("couldn't open: {other:?}"),
    },
};
```

## The `?` Operator

The most ergonomic way to propagate errors:

```rust
fn read_username() -> Result<String, io::Error> {
    let mut f = File::open("hello.txt")?; // ? = early return Err if Err
    let mut s = String::new();
    f.read_to_string(&mut s)?;
    Ok(s)
}

// Even more concise with method chaining
fn read_username() -> Result<String, io::Error> {
    let mut s = String::new();
    File::open("hello.txt")?.read_to_string(&mut s)?;
    Ok(s)
}

// Or just use std::fs helper
fn read_username() -> Result<String, io::Error> {
    std::fs::read_to_string("hello.txt")
}
```

**`?` with `Option`:**
```rust
fn last_char(s: &str) -> Option<char> {
    s.lines().next()?.chars().last()
}
```

**`?` can only be used in functions that return `Result` or `Option`** (or types implementing `FromResidual`).

## Custom Error Types

```rust
use std::fmt;

#[derive(Debug)]
enum AppError {
    IoError(std::io::Error),
    ParseError(std::num::ParseIntError),
    InvalidInput(String),
}

// Implement Display for human-readable messages
impl fmt::Display for AppError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            AppError::IoError(e) => write!(f, "IO error: {e}"),
            AppError::ParseError(e) => write!(f, "Parse error: {e}"),
            AppError::InvalidInput(msg) => write!(f, "Invalid input: {msg}"),
        }
    }
}

// Implement std::error::Error trait
impl std::error::Error for AppError {
    fn source(&self) -> Option<&(dyn std::error::Error + 'static)> {
        match self {
            AppError::IoError(e) => Some(e),
            AppError::ParseError(e) => Some(e),
            AppError::InvalidInput(_) => None,
        }
    }
}

// Implement From for automatic conversion with ?
impl From<std::io::Error> for AppError {
    fn from(e: std::io::Error) -> AppError {
        AppError::IoError(e)
    }
}

impl From<std::num::ParseIntError> for AppError {
    fn from(e: std::num::ParseIntError) -> AppError {
        AppError::ParseError(e)
    }
}

// Now ? automatically converts io::Error into AppError
fn process() -> Result<i32, AppError> {
    let content = std::fs::read_to_string("data.txt")?; // io::Error → AppError
    let n: i32 = content.trim().parse()?;                // ParseIntError → AppError
    if n < 0 { return Err(AppError::InvalidInput("must be positive".into())); }
    Ok(n * 2)
}
```

## Using `thiserror` for Custom Errors (Crate)

```toml
[dependencies]
thiserror = "1"
```

```rust
use thiserror::Error;

#[derive(Error, Debug)]
enum AppError {
    #[error("IO error: {0}")]
    Io(#[from] std::io::Error),
    
    #[error("Parse error: {0}")]
    Parse(#[from] std::num::ParseIntError),
    
    #[error("Invalid input: {message}")]
    InvalidInput { message: String },
}
```

## Using `anyhow` for Application Errors (Crate)

Best for applications (not libraries) where you don't need fine-grained error types:

```toml
[dependencies]
anyhow = "1"
```

```rust
use anyhow::{Context, Result};

fn main() -> Result<()> {
    let content = std::fs::read_to_string("file.txt")
        .context("failed to read file.txt")?;
    let n: i32 = content.trim().parse()
        .context("file didn't contain an integer")?;
    println!("Got: {n}");
    Ok(())
}
```

## Result Methods Cheatsheet

```rust
let r: Result<i32, String> = Ok(42);

// Extracting values
r.unwrap()               // panics if Err
r.expect("msg")          // panics with message if Err
r.unwrap_or(0)           // default value if Err
r.unwrap_or_else(|e| 0)  // compute default if Err
r.ok()                   // convert to Option<T>

// Transforming
r.map(|v| v * 2)         // apply fn to Ok value
r.map_err(|e| e.len())   // apply fn to Err value
r.and_then(|v| Ok(v + 1))  // chain operations that return Result
r.or_else(|e| Ok(0))     // fallback if Err

// Checking
r.is_ok()                // true if Ok
r.is_err()               // true if Err
```

## When to `panic!` vs Return `Result`

| Situation | Use |
|-----------|-----|
| The error is a programming bug | `panic!` |
| The caller can reasonably handle the error | `Result` |
| Invalid state that cannot be continued | `panic!` |
| External resource failure (IO, network) | `Result` |
| Tests | `panic!` (via `assert!`) |
| Prototype code | `unwrap()` or `expect()` |
| Library code | `Result` (don't panic on user input) |
| Application code | Either, with preference for `Result` |
