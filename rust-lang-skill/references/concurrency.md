# Rust Concurrency

Source: https://doc.rust-lang.org/book/ch16-00-concurrency.html

## Threads

```rust
use std::thread;
use std::time::Duration;

// Spawn a thread
let handle = thread::spawn(|| {
    for i in 1..10 {
        println!("hi {i} from spawned thread");
        thread::sleep(Duration::from_millis(1));
    }
});

// Do work in main thread
for i in 1..5 {
    println!("hi {i} from main thread");
    thread::sleep(Duration::from_millis(1));
}

// Wait for thread to finish
handle.join().unwrap();
```

### Moving Ownership into Threads

```rust
let v = vec![1, 2, 3];
let handle = thread::spawn(move || {
    // `move` transfers ownership of `v` into the closure
    println!("Here's a vector: {v:?}");
});
handle.join().unwrap();
```

## Message Passing (Channels)

Channels transfer data between threads. Like Go's philosophy: "communicate by sharing memory, not share memory by communicating."

```rust
use std::sync::mpsc; // multiple producer, single consumer
use std::thread;

let (tx, rx) = mpsc::channel();

// Sender in spawned thread
thread::spawn(move || {
    tx.send("hello from thread".to_string()).unwrap();
});

// Receiver in main thread (blocks until message)
let received = rx.recv().unwrap();
println!("Got: {received}");

// try_recv() — non-blocking version
match rx.try_recv() {
    Ok(msg) => println!("Got: {msg}"),
    Err(_) => println!("No message yet"),
}
```

### Sending Multiple Values

```rust
let (tx, rx) = mpsc::channel();
thread::spawn(move || {
    let msgs = vec!["hi", "from", "the", "thread"];
    for msg in msgs {
        tx.send(msg).unwrap();
        thread::sleep(Duration::from_millis(100));
    }
});

// rx can be iterated (blocks until channel closes)
for received in rx {
    println!("Got: {received}");
}
```

### Multiple Producers

```rust
let (tx, rx) = mpsc::channel();
let tx2 = tx.clone(); // clone the sender

thread::spawn(move || { tx.send("tx: hello").unwrap(); });
thread::spawn(move || { tx2.send("tx2: hello").unwrap(); });

for _ in 0..2 {
    println!("{}", rx.recv().unwrap());
}
```

## Shared State — `Mutex<T>` and `Arc<T>`

```rust
use std::sync::{Arc, Mutex};
use std::thread;

// Arc: atomic reference count (thread-safe Rc)
// Mutex: ensures only one thread accesses data at a time
let counter = Arc::new(Mutex::new(0));
let mut handles = vec![];

for _ in 0..10 {
    let counter = Arc::clone(&counter);
    let h = thread::spawn(move || {
        let mut num = counter.lock().unwrap(); // acquire lock, blocks if held
        *num += 1;
        // MutexGuard drops here, releasing the lock
    });
    handles.push(h);
}

for h in handles { h.join().unwrap(); }
println!("Result: {}", *counter.lock().unwrap()); // 10
```

**Deadlock prevention**: Never hold two locks simultaneously. Design your locking order carefully.

## `Send` and `Sync` Traits

These marker traits (auto-implemented) control thread safety:

- **`Send`**: Type can be transferred between threads (ownership moved across thread boundary)
- **`Sync`**: Type can be referenced from multiple threads (`&T` is Send if T is Sync)

| Type | Send | Sync |
|------|------|------|
| `i32`, `bool`, `char` | ✅ | ✅ |
| `String`, `Vec<T>` | ✅ | ✅ |
| `Rc<T>` | ❌ | ❌ |
| `Arc<T>` | ✅ | ✅ (if T: Sync) |
| `Mutex<T>` | ✅ | ✅ (if T: Send) |
| `RefCell<T>` | ✅ | ❌ |
| `*mut T` (raw pointer) | ❌ | ❌ |

```rust
// Implementing Send/Sync manually (rare, usually unsafe)
unsafe impl Send for MyType {}
unsafe impl Sync for MyType {}
```

## Atomic Types

For simple shared counters without Mutex overhead:

```rust
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::Arc;

let counter = Arc::new(AtomicUsize::new(0));
let c = Arc::clone(&counter);
thread::spawn(move || {
    c.fetch_add(1, Ordering::SeqCst);
});
println!("{}", counter.load(Ordering::SeqCst));
```

## Thread Pool Pattern

```rust
use std::sync::{Arc, Mutex};
use std::thread;
use std::sync::mpsc;

// Basic thread pool (use `rayon` crate for production)
type Job = Box<dyn FnOnce() + Send + 'static>;

struct ThreadPool {
    workers: Vec<thread::JoinHandle<()>>,
    sender: mpsc::Sender<Job>,
}

impl ThreadPool {
    fn new(size: usize) -> Self {
        let (sender, receiver) = mpsc::channel::<Job>();
        let receiver = Arc::new(Mutex::new(receiver));
        let workers = (0..size)
            .map(|_| {
                let rx = Arc::clone(&receiver);
                thread::spawn(move || loop {
                    match rx.lock().unwrap().recv() {
                        Ok(job) => job(),
                        Err(_) => break, // channel closed
                    }
                })
            })
            .collect();
        ThreadPool { workers, sender }
    }
    
    fn execute<F: FnOnce() + Send + 'static>(&self, f: F) {
        self.sender.send(Box::new(f)).unwrap();
    }
}
```

## Common Patterns

### Read-Heavy Data: `RwLock`
```rust
use std::sync::RwLock;
let data = RwLock::new(vec![1, 2, 3]);
// Multiple readers concurrently
let r1 = data.read().unwrap();
let r2 = data.read().unwrap();
drop(r1); drop(r2);
// One writer at a time
let mut w = data.write().unwrap();
w.push(4);
```

### One-Time Initialization: `OnceLock`
```rust
use std::sync::OnceLock;
static CONFIG: OnceLock<String> = OnceLock::new();
CONFIG.get_or_init(|| "config_value".to_string());
println!("{}", CONFIG.get().unwrap());
```
