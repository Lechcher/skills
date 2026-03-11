# Rust Ownership, Borrowing & Lifetimes

Source: https://doc.rust-lang.org/book/ch04-00-understanding-ownership.html

## Ownership Rules

1. Each value in Rust has an **owner**
2. There can only be **one owner** at a time
3. When the owner goes out of scope, the value is **dropped**

## Stack vs Heap

- **Stack**: Fixed-size data, LIFO, fast; integers, floats, booleans, chars, tuples of stack types
- **Heap**: Variable-size or unknown-at-compile-time data; allocated with `Box`, `String`, `Vec`, etc.

## Move Semantics

```rust
// Copy types (stack-allocated): value is copied
let x = 5;
let y = x;      // x is still valid (i32 implements Copy)

// Move types (heap-allocated): value is moved
let s1 = String::from("hello");
let s2 = s1;    // s1 is moved into s2; s1 is now invalid
// println!("{s1}"); // ERROR: use of moved value

// Explicit clone to deep-copy
let s1 = String::from("hello");
let s2 = s1.clone(); // both s1 and s2 are valid
```

**Types that implement `Copy`**: all integer types (`u8`, `i32`, etc.), `bool`, `f32`, `f64`, `char`, tuples of Copy types

## References & Borrowing

References let you refer to a value without owning it:

```rust
fn main() {
    let s1 = String::from("hello");
    let len = calculate_length(&s1); // pass a reference
    println!("'{s1}' has length {len}"); // s1 still valid
}

fn calculate_length(s: &String) -> usize { // s is a reference
    s.len()
} // s goes out of scope, but since it doesn't own the value, nothing is dropped
```

### Borrowing Rules (enforced at compile time)
- ✅ Any number of **immutable references** (`&T`)
- ✅ Exactly **one mutable reference** (`&mut T`) — no other references allowed simultaneously
- ✅ References must always be **valid** (no dangling references)

```rust
let mut s = String::from("hello");

// Multiple immutable borrows: OK
let r1 = &s;
let r2 = &s;
println!("{r1} and {r2}"); // r1 and r2 no longer used after this point

// Now we can create a mutable reference
let r3 = &mut s;
r3.push_str(" world");
```

### Mutable References

```rust
fn change(s: &mut String) {
    s.push_str(", world");
}

let mut s = String::from("hello");
change(&mut s);
```

**Restriction**: Cannot have a mutable reference while an immutable reference exists:
```rust
let r1 = &s; // immutable borrow begins
let r2 = &mut s; // ERROR: cannot borrow as mutable because also borrowed as immutable
println!("{r1}"); // immutable borrow used here
```

## The Slice Type

Slices reference a contiguous sequence of elements, without ownership:

```rust
// String slice
let s = String::from("hello world");
let hello: &str = &s[0..5];   // "hello"
let world: &str = &s[6..11];  // "world"

// String literals are slices
let s = "Hello, world!"; // &str — a slice pointing to binary data

// Slice of an array
let a = [1, 2, 3, 4, 5];
let slice: &[i32] = &a[1..3]; // [2, 3]
```

## Lifetimes

Lifetimes ensure all references are valid. Most of the time, lifetimes are inferred. Annotations are required when the compiler can't determine which reference a return value relates to.

### Lifetime Annotation Syntax

```rust
&i32        // a reference
&'a i32     // a reference with an explicit lifetime
&'a mut i32 // a mutable reference with an explicit lifetime
```

### Lifetime in Function Signatures

```rust
// 'a = "the lifetime of both x and y, and the return value"
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
    if x.len() > y.len() { x } else { y }
}
```

The annotation means: the returned reference will be valid for as long as *both* `x` and `y` are valid (the shorter of the two).

### Lifetime in Struct Definitions

When a struct holds a reference, the reference must live at least as long as the struct:

```rust
struct Important<'a> {
    part: &'a str, // this struct cannot outlive the reference in `part`
}
```

### Lifetime Elision Rules

The compiler applies three rules to infer lifetimes. If all output lifetimes can be determined after applying these rules, no annotation is needed:

1. Each reference parameter gets its own lifetime parameter
2. If there is exactly one input lifetime parameter, it is assigned to all output lifetime parameters
3. If one of the inputs is `&self` or `&mut self`, its lifetime is assigned to all output lifetime parameters

### The `'static` Lifetime

```rust
// String literals have 'static lifetime (stored in binary)
let s: &'static str = "I have a static lifetime.";
```

Use `'static` only when the reference truly lives for the entire program. Usually seen as a constraint in trait bounds when needed.

## Common Ownership Patterns

### Return Ownership
```rust
fn gives_ownership() -> String {
    let s = String::from("yours");
    s // returned, ownership moves to caller
}
```

### Clone When You Need Two Owners
```rust
let s1 = String::from("hello");
let s2 = s1.clone(); // explicit deep copy
println!("{s1} {s2}"); // both are valid
```

### Use `Cow<'a, str>` for Flexible Borrowed/Owned
```rust
use std::borrow::Cow;
fn process(s: Cow<str>) {
    // can accept either &str or String efficiently
}
process(Cow::Borrowed("hello")); // no allocation
process(Cow::Owned(String::from("hello"))); // owned
```

## The Drop Trait

When a value goes out of scope, Rust automatically calls `drop()`. You can customize cleanup:

```rust
struct MyResource;
impl Drop for MyResource {
    fn drop(&mut self) {
        println!("Dropping MyResource!");
    }
}
// Called automatically; manual call via std::mem::drop(value)
```
