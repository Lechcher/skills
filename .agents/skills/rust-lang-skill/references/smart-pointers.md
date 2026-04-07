# Rust Smart Pointers

Source: https://doc.rust-lang.org/book/ch15-00-smart-pointers.html

## Overview

Smart pointers are data structures that act like pointers but have additional metadata and capabilities. Unlike references, smart pointers usually *own* the data they point to.

| Smart Pointer | Purpose |
|---------------|---------|
| `Box<T>` | Heap allocation, fixed-size interface for unsized types |
| `Rc<T>` | Multiple ownership in single-threaded code |
| `Arc<T>` | Multiple ownership in multi-threaded code |
| `RefCell<T>` | Interior mutability at runtime (single-threaded) |
| `Mutex<T>` | Interior mutability with thread safety |
| `RwLock<T>` | Multiple readers or one writer, thread-safe |
| `Cell<T>` | Interior mutability for Copy types |
| `Weak<T>` | Non-owning reference to break `Rc`/`Arc` cycles |

## `Box<T>`

Stores data on the heap. The `Box` itself is on the stack.

```rust
// Basic heap allocation
let b = Box::new(5);
println!("b = {b}");
// Box is automatically freed when it goes out of scope

// Recursive types (size must be known at compile time)
enum List {
    Cons(i32, Box<List>),  // Box breaks the infinite size
    Nil,
}
let list = List::Cons(1, Box::new(List::Cons(2, Box::new(List::Nil))));

// Large data: avoid stack overflow
let large_data = Box::new([0u8; 1_000_000]);

// Deref coercion: Box<T> automatically derefs to T
let x = 5;
let y = Box::new(x);
assert_eq!(5, *y); // deref coercion
```

## `Rc<T>` — Reference Counted (Single-Threaded)

Enables multiple ownership with reference counting:

```rust
use std::rc::Rc;

let a = Rc::new(String::from("hello"));
let b = Rc::clone(&a); // clone the pointer, not the data
let c = Rc::clone(&a);

println!("count = {}", Rc::strong_count(&a)); // 3
println!("{a}"); // still valid

// When all Rc clones go out of scope, the data is freed
drop(b);
println!("count after drop = {}", Rc::strong_count(&a)); // 2
```

**Note**: `Rc<T>` is NOT thread-safe. Use `Arc<T>` for multi-threaded code.

## `RefCell<T>` — Interior Mutability

Allows mutating data even when there are immutable references, enforcing borrow rules at **runtime** instead of compile time:

```rust
use std::cell::RefCell;

let data = RefCell::new(vec![1, 2, 3]);

// Immutable borrow
{
    let borrowed = data.borrow(); // returns Ref<Vec<i32>>
    println!("{:?}", *borrowed);
}

// Mutable borrow
{
    let mut borrowed = data.borrow_mut(); // returns RefMut<Vec<i32>>
    borrowed.push(4);
}

// Panics at runtime if borrow rules are violated
// data.borrow_mut(); // panic: already mutably borrowed
```

## `Rc<RefCell<T>>` — Multiple Mutable Owners (Single-Threaded)

The most common combination for shared mutable state in single-threaded programs:

```rust
use std::rc::Rc;
use std::cell::RefCell;

let shared = Rc::new(RefCell::new(vec![1, 2, 3]));

let owner_a = Rc::clone(&shared);
let owner_b = Rc::clone(&shared);

owner_a.borrow_mut().push(4);
owner_b.borrow_mut().push(5);

println!("{:?}", shared.borrow()); // [1, 2, 3, 4, 5]
```

## `Arc<T>` — Atomic Reference Counted (Multi-Threaded)

Like `Rc<T>` but uses atomic operations for thread safety:

```rust
use std::sync::Arc;
use std::thread;

let data = Arc::new(vec![1, 2, 3]);

let data_clone = Arc::clone(&data);
let handle = thread::spawn(move || {
    println!("{:?}", data_clone);
});
handle.join().unwrap();
println!("{:?}", data); // still valid in main thread
```

## `Mutex<T>` — Thread-Safe Interior Mutability

```rust
use std::sync::{Arc, Mutex};
use std::thread;

let counter = Arc::new(Mutex::new(0));
let mut handles = vec![];

for _ in 0..10 {
    let c = Arc::clone(&counter);
    let h = thread::spawn(move || {
        let mut num = c.lock().unwrap(); // blocks until lock acquired
        *num += 1;
        // MutexGuard is dropped here, lock released
    });
    handles.push(h);
}

for h in handles { h.join().unwrap(); }
println!("Result: {}", *counter.lock().unwrap()); // 10
```

## `RwLock<T>` — Read-Write Lock

Allows multiple simultaneous readers OR one writer:

```rust
use std::sync::RwLock;

let lock = RwLock::new(5);

// Multiple readers simultaneously
{
    let r1 = lock.read().unwrap();
    let r2 = lock.read().unwrap();
    println!("{r1} {r2}");
}

// One writer (exclusive)
{
    let mut w = lock.write().unwrap();
    *w += 1;
}
```

## `Cell<T>` — Interior Mutability for Copy Types

Simpler than `RefCell`, but only for `Copy` types:

```rust
use std::cell::Cell;

let x = Cell::new(5);
let y = &x;    // immutable reference
y.set(10);     // but we can still mutate!
println!("{}", x.get()); // 10
```

## `Weak<T>` — Breaking Reference Cycles

`Rc::clone` creates strong references that prevent deallocation. `Weak` references don't:

```rust
use std::rc::{Rc, Weak};
use std::cell::RefCell;

struct Node {
    value: i32,
    parent: RefCell<Weak<Node>>, // Weak to avoid cycles
    children: RefCell<Vec<Rc<Node>>>,
}

let leaf = Rc::new(Node {
    value: 3,
    parent: RefCell::new(Weak::new()),
    children: RefCell::new(vec![]),
});

let branch = Rc::new(Node {
    value: 5,
    parent: RefCell::new(Weak::new()),
    children: RefCell::new(vec![Rc::clone(&leaf)]),
});

*leaf.parent.borrow_mut() = Rc::downgrade(&branch); // create Weak reference

// Upgrading Weak to Rc: returns Option<Rc<T>>
if let Some(parent) = leaf.parent.borrow().upgrade() {
    println!("Parent value: {}", parent.value);
}
```

## Implementing Smart Pointer Traits

```rust
use std::ops::{Deref, DerefMut};

struct MyBox<T>(T);

impl<T> MyBox<T> {
    fn new(x: T) -> MyBox<T> { MyBox(x) }
}

impl<T> Deref for MyBox<T> {
    type Target = T;
    fn deref(&self) -> &T { &self.0 }
}

// Deref coercions (automatic when needed):
// &MyBox<String> -> &String -> &str
fn hello(name: &str) { println!("Hello, {name}!"); }
let m = MyBox::new(String::from("Rust"));
hello(&m); // &MyBox<String> auto-derefs to &str
```
