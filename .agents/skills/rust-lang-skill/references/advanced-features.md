# Rust Advanced Features

Source: https://doc.rust-lang.org/book/ch20-00-advanced-features.html

## Unsafe Rust

Unsafe Rust bypasses compile-time safety checks. Use only when necessary.

### Five Unsafe Superpowers

1. Dereference raw pointers
2. Call unsafe functions or methods
3. Access or modify mutable static variables
4. Implement unsafe traits
5. Access fields of unions

```rust
// Raw pointers
let mut num = 5;
let r1 = &num as *const i32;   // raw immutable pointer
let r2 = &mut num as *mut i32;  // raw mutable pointer

unsafe {
    println!("{}", *r1);  // dereference raw pointer
    *r2 = 10;
    println!("{}", *r2);
}

// Unsafe function
unsafe fn dangerous() {
    // body can do unsafe operations
}
unsafe { dangerous(); }  // must call in unsafe block

// Safe abstraction over unsafe code
fn split_at_mut(values: &mut [i32], mid: usize) -> (&mut [i32], &mut [i32]) {
    let len = values.len();
    let ptr = values.as_mut_ptr();
    assert!(mid <= len);
    unsafe {
        (
            std::slice::from_raw_parts_mut(ptr, mid),
            std::slice::from_raw_parts_mut(ptr.add(mid), len - mid),
        )
    }
}

// External functions (FFI)
extern "C" {
    fn abs(input: i32) -> i32;
}
unsafe { println!("{}", abs(-3)); }

// Calling Rust from C
#[no_mangle]
pub extern "C" fn call_from_c() {
    println!("called from C!");
}
```

## Advanced Traits

### Associated Types
```rust
trait Iterator {
    type Item; // caller doesn't specify type parameters
    fn next(&mut self) -> Option<Self::Item>;
}

// vs generic: trait Iterator<T> - would require specifying T every use
struct Counter { count: u32 }
impl Iterator for Counter {
    type Item = u32;
    fn next(&mut self) -> Option<u32> { /* ... */ None }
}
```

### Default Generic Type Parameters and Operator Overloading

```rust
use std::ops::Add;

#[derive(Debug, PartialEq)]
struct Point { x: f64, y: f64 }

impl Add for Point { // Add<Rhs = Self> -- Rhs defaults to Self
    type Output = Point;
    fn add(self, other: Point) -> Point {
        Point { x: self.x + other.x, y: self.y + other.y }
    }
}

// Custom Rhs type
impl Add<f64> for Point {
    type Output = Point;
    fn add(self, scalar: f64) -> Point {
        Point { x: self.x + scalar, y: self.y + scalar }
    }
}
```

### Fully Qualified Syntax

When a method name conflicts between traits or the inherent impl:
```rust
trait Pilot { fn fly(&self); }
trait Wizard { fn fly(&self); }
struct Human;
impl Pilot for Human { fn fly(&self) { println!("flying as pilot"); } }
impl Wizard for Human { fn fly(&self) { println!("flying as wizard"); } }
impl Human { fn fly(&self) { println!("human flying"); } }

let person = Human;
person.fly();            // calls inherent impl
Pilot::fly(&person);     // calls Pilot trait
Wizard::fly(&person);    // calls Wizard trait

// For associated functions (no self)
trait Animal { fn name() -> String; }
struct Dog;
impl Animal for Dog { fn name() -> String { "dog".to_string() } }
<Dog as Animal>::name(); // fully qualified syntax
```

### Supertraits

```rust
use std::fmt;
trait OutlinePrint: fmt::Display { // must impl Display first
    fn outline_print(&self) {
        let output = self.to_string(); // can use Display
        println!("* {} *", output);
    }
}
```

## Advanced Types

### Newtype Pattern

```rust
// Wrapper around a type for type safety or trait impl
struct Meters(f64);
struct Kilograms(f64);

let m = Meters(5.0);
let k = Kilograms(3.0);
// Cannot accidentally add meters to kilograms

// Implementing external traits on external types via newtype
use std::fmt;
struct Wrapper(Vec<String>);
impl fmt::Display for Wrapper {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "[{}]", self.0.join(", "))
    }
}
```

### Type Aliases

```rust
type Kilometers = i32; // alias, not a new type
type Result<T> = std::result::Result<T, std::io::Error>; // common in std
type Thunk = Box<dyn Fn() + Send + 'static>;
```

### The Never Type `!`

```rust
// ! means "never returns" (diverging function)
fn diverge() -> ! {
    panic!("This never returns!");
}

// Used in match arms that never produce a value
let x: i32 = match some_option {
    Some(n) => n,
    None => panic!("failed!"), // panic! has type !
};

// continue, break, loop (infinite) also have type !
```

### Dynamically Sized Types (DST)

```rust
// str and [T] are DSTs — size unknown at compile time
// Must always be behind a reference
let s: &str = "hello";          // works
let slice: &[i32] = &[1, 2, 3]; // works
// let s: str = ...; // ERROR: can't size str

// Sized trait: automatically implemented for fixed-size types
fn generic_fixed<T: Sized>(t: T) {}    // default
fn generic_flexible<T: ?Sized>(t: &T) {} // T may or may not be Sized
```

## Macros

### Declarative Macros (`macro_rules!`)

```rust
// Define
macro_rules! vec_of {
    // Pattern: zero or more comma-separated expressions
    ($($x:expr),* $(,)?) => {
        {
            let mut v = Vec::new();
            $(v.push($x);)*
            v
        }
    };
}

// Use
let v = vec_of![1, 2, 3];

// Common macro patterns
macro_rules! log {
    ($msg:expr) => { println!("[LOG] {}", $msg); };
    ($fmt:expr, $($arg:expr),*) => { println!(concat!("[LOG] ", $fmt), $($arg),*); };
}
```

### Procedural Macros

```rust
// Custom derive
#[proc_macro_derive(HelloMacro)]
pub fn hello_macro_derive(input: TokenStream) -> TokenStream;

// Usage
#[derive(HelloMacro)]
struct Pancakes;

// Attribute-like macro
#[route(GET, "/")]
fn index() {}

// Function-like macro
let sql = sql!(SELECT * FROM users WHERE id = 1);
```

## Advanced Patterns

```rust
// Destructuring with ..
struct Point { x: i32, y: i32, z: i32 }
let p = Point { x: 1, y: 2, z: 3 };
let Point { x, .. } = p; // ignore y and z
let (a, .., z) = (1, 2, 3, 4, 5); // a=1, z=5

// Guards in destructuring
let pair = (2, -3);
if let (x, y) = pair if x > 0 && y < 0 {
    println!("first is positive, second is negative");
}

// or-patterns
let x = 5;
match x {
    1 | 2 | 3 => println!("one two or three"),
    4..=10 => println!("four through ten"),
    _ => println!("other"),
}
```

## Using Miri for Unsafe Code

```bash
# Install Miri
rustup component add miri

# Run with Miri (detects undefined behavior)
cargo miri test
cargo miri run
```

## The Type State Pattern

Create compile-time state machines:

```rust
struct Locked;
struct Unlocked;

struct Safe<State> {
    contents: String,
    _state: std::marker::PhantomData<State>,
}

impl Safe<Locked> {
    fn new(contents: String) -> Self {
        Safe { contents, _state: std::marker::PhantomData }
    }
    fn unlock(self, password: &str) -> Result<Safe<Unlocked>, Safe<Locked>> {
        if password == "1234" {
            Ok(Safe { contents: self.contents, _state: std::marker::PhantomData })
        } else {
            Err(self)
        }
    }
}

impl Safe<Unlocked> {
    fn get_contents(&self) -> &str { &self.contents }
    fn lock(self) -> Safe<Locked> {
        Safe { contents: self.contents, _state: std::marker::PhantomData }
    }
}

// Cannot call get_contents on a locked safe — compile error!
```
