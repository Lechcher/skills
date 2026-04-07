# Idiomatic Rust Patterns

## Builder Pattern

```rust
#[derive(Debug, Default)]
struct RequestBuilder {
    url: String,
    method: String,
    headers: std::collections::HashMap<String, String>,
    body: Option<String>,
    timeout_secs: u64,
}

impl RequestBuilder {
    fn new(url: impl Into<String>) -> Self {
        Self {
            url: url.into(),
            method: "GET".to_string(),
            timeout_secs: 30,
            ..Default::default()
        }
    }
    fn method(mut self, method: impl Into<String>) -> Self {
        self.method = method.into(); self
    }
    fn header(mut self, key: impl Into<String>, val: impl Into<String>) -> Self {
        self.headers.insert(key.into(), val.into()); self
    }
    fn body(mut self, body: impl Into<String>) -> Self {
        self.body = Some(body.into()); self
    }
    fn timeout(mut self, secs: u64) -> Self {
        self.timeout_secs = secs; self
    }
    fn build(self) -> Request { Request(self) }
}

struct Request(RequestBuilder);

// Usage: fluent, readable
let req = RequestBuilder::new("https://api.example.com/data")
    .method("POST")
    .header("Content-Type", "application/json")
    .body(r#"{"key": "value"}"#)
    .timeout(60)
    .build();
```

## State Machine Pattern (Typestate)

```rust
// States as zero-sized types
struct Draft;
struct Published;

struct Post<State> {
    content: String,
    _state: std::marker::PhantomData<State>,
}

impl Post<Draft> {
    fn new(content: String) -> Self {
        Self { content, _state: std::marker::PhantomData }
    }
    fn add_content(&mut self, text: &str) { self.content.push_str(text); }
    fn publish(self) -> Post<Published> {
        Post { content: self.content, _state: std::marker::PhantomData }
    }
}

impl Post<Published> {
    fn content(&self) -> &str { &self.content }
    // Cannot call add_content on a published post — compile error
}
```

## Extension Traits

```rust
trait StringExt {
    fn to_title_case(&self) -> String;
    fn truncate_at(&self, len: usize) -> &str;
}

impl StringExt for str {
    fn to_title_case(&self) -> String {
        self.split_whitespace()
            .map(|word| {
                let mut chars = word.chars();
                match chars.next() {
                    None => String::new(),
                    Some(first) => {
                        first.to_uppercase().to_string() + chars.as_str()
                    }
                }
            })
            .collect::<Vec<_>>()
            .join(" ")
    }
    fn truncate_at(&self, len: usize) -> &str {
        if self.len() <= len { self }
        else { &self[..len] }
    }
}

let title = "hello world foo".to_title_case(); // "Hello World Foo"
```

## Iterator Adapters Pattern

```rust
// Create a custom iterator adapter
struct Chunks<I: Iterator> {
    iter: I,
    size: usize,
}

impl<I: Iterator> Iterator for Chunks<I> {
    type Item = Vec<I::Item>;
    fn next(&mut self) -> Option<Self::Item> {
        let mut chunk = Vec::with_capacity(self.size);
        for _ in 0..self.size {
            match self.iter.next() {
                Some(item) => chunk.push(item),
                None => break,
            }
        }
        if chunk.is_empty() { None } else { Some(chunk) }
    }
}

trait ChunksExt: Iterator + Sized {
    fn chunks(self, size: usize) -> Chunks<Self> {
        Chunks { iter: self, size }
    }
}
impl<I: Iterator> ChunksExt for I {}

// Usage
let chunked: Vec<Vec<i32>> = (1..=10).chunks(3).collect();
// [[1,2,3],[4,5,6],[7,8,9],[10]]
```

## Error Handling Patterns

```rust
// Returning multiple error types with Box<dyn Error>
fn flexible() -> Result<(), Box<dyn std::error::Error>> {
    let _f = std::fs::File::open("file")?;        // io::Error
    let _n: i32 = "x".parse()?;                   // ParseIntError
    Ok(())
}

// anyhow for application code
use anyhow::{anyhow, bail, Context, Result};

fn validated(input: &str) -> Result<i32> {
    let n: i32 = input.parse().context("input was not a number")?;
    if n < 0 { bail!("number must be positive, got {n}"); }
    Ok(n)
}

// Custom error with context
fn with_context() -> anyhow::Result<String> {
    std::fs::read_to_string("file.txt")
        .with_context(|| format!("Failed to read file.txt"))
}
```

## Avoiding Common Anti-Patterns

```rust
// ❌ Anti-pattern: unnecessary clones
let names: Vec<&str> = vec!["Alice", "Bob"];
for name in names.clone() { println!("{name}"); } // clone not needed

// ✅ Idiomatic: use reference
for name in &names { println!("{name}"); }

// ❌ Anti-pattern: unwrap in library code
fn get_value(map: &HashMap<&str, i32>, key: &str) -> i32 {
    *map.get(key).unwrap() // panics if missing — bad!
}

// ✅ Idiomatic: return Option or Result
fn get_value(map: &HashMap<&str, i32>, key: &str) -> Option<i32> {
    map.get(key).copied()
}

// ❌ Anti-pattern: collect then iterate
let sums: Vec<i32> = data.iter().map(|x| x * 2).collect();
let total: i32 = sums.iter().sum();

// ✅ Idiomatic: chain iterators
let total: i32 = data.iter().map(|x| x * 2).sum();

// ❌ Anti-pattern: manual index loops
for i in 0..v.len() { println!("{}", v[i]); }

// ✅ Idiomatic: for-in or iterators
for item in &v { println!("{item}"); }

// ❌ Anti-pattern: string concatenation in loop
let mut result = String::new();
for s in &strings { result = result + s; } // allocates every iteration

// ✅ Idiomatic: join or collect
let result = strings.join("");
let result: String = strings.iter().flat_map(|s| s.chars()).collect();
```

## Common Crates Reference

| Category | Crate | Use Case |
|----------|-------|----------|
| Error handling | `anyhow` | Application errors |
| Error handling | `thiserror` | Library error types |
| Serialization | `serde` | JSON, TOML, etc. |
| Async runtime | `tokio` | Async I/O |
| HTTP client | `reqwest` | HTTP requests |
| HTTP server | `axum`, `actix-web` | Web APIs |
| CLI | `clap` | Command-line argument parsing |
| Logging | `tracing` | Structured logging |
| Database | `sqlx` | SQL databases (async) |
| Date/time | `chrono`, `time` | Date and time handling |
| UUID | `uuid` | UUID generation |
| Rand | `rand` | Random number generation |
| Regex | `regex` | Regular expressions |
| JSON | `serde_json` | JSON parsing/serialization |
| TOML | `toml` | TOML parsing |
| Parallel | `rayon` | Data parallelism |
| Testing | `mockall` | Mock objects |
| Testing | `proptest` | Property-based testing |
| Testing | `insta` | Snapshot testing |
