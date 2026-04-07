# Rust Async/Await

Source: https://doc.rust-lang.org/book/ch17-00-async-await.html

## What is Async?

Asynchronous programming in Rust is built around:
- **Futures**: values representing async computations (lazy — do nothing until polled)
- **async/await syntax**: write async code that reads like synchronous code
- **Runtimes**: libraries that drive futures to completion (Tokio, async-std)

## Key Dependency: Tokio

```toml
[dependencies]
tokio = { version = "1", features = ["full"] }
```

## Basic Async Functions

```rust
use std::time::Duration;

// async fn returns an impl Future<Output = T>
async fn say_hello() {
    println!("hello from async!");
}

async fn add(a: i32, b: i32) -> i32 {
    a + b
}

#[tokio::main] // macro to set up async runtime for main
async fn main() {
    say_hello().await; // .await drives the future to completion
    let sum = add(3, 4).await;
    println!("Sum: {sum}");
}
```

## Concurrency with Async

```rust
use tokio::time::sleep;

// Sequential: total 2 seconds
async fn sequential() {
    sleep(Duration::from_secs(1)).await;
    sleep(Duration::from_secs(1)).await;
}

// Concurrent: total ~1 second
async fn concurrent() {
    let f1 = sleep(Duration::from_secs(1));
    let f2 = sleep(Duration::from_secs(1));
    tokio::join!(f1, f2); // run both concurrently
}

// tokio::join! waits for ALL futures
// tokio::select! waits for FIRST future to complete
async fn race() {
    tokio::select! {
        _ = sleep(Duration::from_millis(100)) => println!("fast won"),
        _ = sleep(Duration::from_secs(10)) => println!("slow won"),
    }
}
```

## Spawning Tasks

```rust
use tokio::task;

#[tokio::main]
async fn main() {
    // Spawn a concurrent task (like a lightweight thread)
    let handle = task::spawn(async {
        println!("running in separate task");
        42 // returned value
    });
    
    let result = handle.await.unwrap(); // JoinHandle<T> -> Result<T, JoinError>
    println!("task returned: {result}");
}
```

## Channels in Async

```rust
use tokio::sync::mpsc;

#[tokio::main]
async fn main() {
    let (tx, mut rx) = mpsc::channel(100); // buffered channel
    
    tokio::spawn(async move {
        for i in 0..5 {
            tx.send(i).await.unwrap();
        }
    });
    
    while let Some(value) = rx.recv().await {
        println!("Received: {value}");
    }
}
```

### Async Channel Types (tokio::sync)

| Channel | Description |
|---------|-------------|
| `mpsc` | Multi-producer, single-consumer (async) |
| `oneshot` | Single value sent once |
| `broadcast` | Multiple receivers, same message |
| `watch` | Always the latest value |

```rust
// oneshot: send a single response
use tokio::sync::oneshot;
let (tx, rx) = oneshot::channel();
tokio::spawn(async move { tx.send(42).unwrap(); });
let result = rx.await.unwrap();
```

## Streams

A stream is an async iterator — multiple values over time:

```rust
use tokio_stream::{self as stream, StreamExt};

#[tokio::main]
async fn main() {
    let mut stream = stream::iter(vec![1, 2, 3]);
    while let Some(value) = stream.next().await {
        println!("{value}");
    }
}
```

## Async Traits

```rust
// As of Rust 1.75+, async fn in traits is stable
trait Fetcher {
    async fn fetch(&self, url: &str) -> String;
}

// For older Rust, use the `async-trait` crate:
use async_trait::async_trait;

#[async_trait]
trait Fetcher {
    async fn fetch(&self, url: &str) -> String;
}
```

## Error Handling in Async

```rust
use anyhow::Result;

async fn fetch_url(url: &str) -> Result<String> {
    let response = reqwest::get(url).await?;
    let text = response.text().await?;
    Ok(text)
}

#[tokio::main]
async fn main() -> Result<()> {
    let content = fetch_url("https://example.com").await?;
    println!("{content}");
    Ok(())
}
```

## Common Async Patterns

### Timeout
```rust
use tokio::time::{timeout, Duration};

let result = timeout(Duration::from_secs(5), fetch_url("url")).await;
match result {
    Ok(Ok(content)) => println!("{content}"),
    Ok(Err(e)) => eprintln!("fetch error: {e}"),
    Err(_timeout) => eprintln!("timed out"),
}
```

### Retry with Backoff
```rust
async fn with_retry<F, T, E, Fut>(f: F, max_retries: u32) -> Result<T, E>
where
    F: Fn() -> Fut,
    Fut: std::future::Future<Output = Result<T, E>>,
{
    for attempt in 0..max_retries {
        match f().await {
            Ok(v) => return Ok(v),
            Err(e) if attempt < max_retries - 1 => {
                let delay = Duration::from_millis(100 * 2u64.pow(attempt));
                tokio::time::sleep(delay).await;
            }
            Err(e) => return Err(e),
        }
    }
    unreachable!()
}
```

### Semaphore (Limit Concurrent Operations)
```rust
use tokio::sync::Semaphore;
use std::sync::Arc;

let semaphore = Arc::new(Semaphore::new(10)); // max 10 concurrent
let mut handles = vec![];

for i in 0..100 {
    let permit = semaphore.clone().acquire_owned().await.unwrap();
    handles.push(tokio::spawn(async move {
        // Only 10 of these run at once
        do_work(i).await;
        drop(permit); // release slot
    }));
}
```

## Async vs Threads

| | Threads | Async |
|--|---------|-------|
| Use case | CPU-bound work | I/O-bound work |
| Switching cost | OS context switch (expensive) | Cooperative yield (cheap) |
| Memory per unit | ~8MB stack | ~few KB |
| Parallelism | True parallelism | Concurrent (not parallel by default) |
| Rust library | `std::thread` | `tokio`, `async-std` |

**Rule of thumb**: Use async for I/O-bound code (web requests, file I/O, database queries). Use threads (or `rayon`) for CPU-bound code.
