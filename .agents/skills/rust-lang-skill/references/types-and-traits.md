# Rust Types, Traits & Generics

Source: https://doc.rust-lang.org/book/ch05-00-structs.html
         https://doc.rust-lang.org/book/ch06-00-enums.html
         https://doc.rust-lang.org/book/ch10-00-generics.html

## Structs

```rust
// Named fields struct
struct User {
    active: bool,
    username: String,
    email: String,
    sign_in_count: u64,
}

// Create instance
let user = User {
    active: true,
    username: String::from("alice"),
    email: String::from("alice@example.com"),
    sign_in_count: 1,
};

// Field init shorthand (when param names match field names)
fn build_user(email: String, username: String) -> User {
    User { active: true, username, email, sign_in_count: 1 }
}

// Struct update syntax
let user2 = User {
    email: String::from("bob@example.com"),
    ..user // remaining fields from user (moves ownership of String fields)
};

// Tuple struct
struct Point(f64, f64, f64);
let p = Point(0.0, 1.0, 2.0);
println!("{}", p.0); // access by index

// Unit-like struct (useful for trait implementations)
struct AlwaysEqual;
```

## Methods

```rust
#[derive(Debug)]
struct Rectangle { width: f64, height: f64 }

impl Rectangle {
    // Associated function (constructor pattern)
    fn new(width: f64, height: f64) -> Self {
        Self { width, height }
    }
    fn square(size: f64) -> Self {
        Self { width: size, height: size }
    }
    
    // Methods take &self (immutable), &mut self (mutable), or self (consuming)
    fn area(&self) -> f64 {
        self.width * self.height
    }
    fn can_hold(&self, other: &Rectangle) -> bool {
        self.width > other.width && self.height > other.height
    }
    fn scale(&mut self, factor: f64) {
        self.width *= factor;
        self.height *= factor;
    }
}

// Multiple impl blocks allowed
impl Rectangle {
    fn perimeter(&self) -> f64 {
        2.0 * (self.width + self.height)
    }
}

let r = Rectangle::new(10.0, 5.0); // associated function call
println!("Area: {}", r.area());     // method call
```

## Enums

```rust
// Simple enum
enum Direction { North, South, East, West }

// Enum with data
enum Shape {
    Circle(f64),               // tuple variant
    Rectangle { w: f64, h: f64 }, // struct variant
    Triangle(f64, f64, f64),   // tuple variant
}

impl Shape {
    fn area(&self) -> f64 {
        match self {
            Shape::Circle(r) => std::f64::consts::PI * r * r,
            Shape::Rectangle { w, h } => w * h,
            Shape::Triangle(a, b, c) => {
                let s = (a + b + c) / 2.0;
                (s * (s - a) * (s - b) * (s - c)).sqrt()
            }
        }
    }
}
```

## The Option Enum

```rust
// Definition in std
enum Option<T> {
    None,
    Some(T),
}

// Usage
let some_number: Option<i32> = Some(5);
let no_number: Option<i32> = None;

// Working with Option
let x: Option<i32> = Some(42);

// pattern match
match x {
    Some(n) => println!("Got {n}"),
    None => println!("Nothing"),
}

// if let (concise single-arm match)
if let Some(n) = x { println!("Got {n}") }

// Methods
let doubled = x.map(|n| n * 2);          // Some(84) or None
let value = x.unwrap_or(0);              // 42 or 0 if None
let value = x.unwrap_or_else(|| 0);      // lazy default
let value = x.expect("must have value"); // panic with message if None
let is_some = x.is_some();              // true
```

## The Result Enum

```rust
// Definition in std
enum Result<T, E> {
    Ok(T),
    Err(E),
}

// Methods mirror Option
let r: Result<i32, String> = Ok(42);
let v = r.unwrap_or(0);
let v = r.unwrap_or_else(|e| { eprintln!("{e}"); 0 });
let v = r.map(|n| n * 2);
let v = r.map_err(|e| format!("Error: {e}"));

// ? operator — return Err early
fn process() -> Result<String, std::io::Error> {
    let content = std::fs::read_to_string("file.txt")?; // ? short-circuits
    Ok(content.to_uppercase())
}
```

## Pattern Matching

```rust
// match is exhaustive — must cover all cases
let number = 7;
match number {
    1 => println!("one"),
    2 | 3 | 5 | 7 | 11 => println!("prime"),
    13..=19 => println!("teen"),
    _ => println!("other"),
}

// Destructuring
let point = (3, -5);
match point {
    (0, 0) => println!("origin"),
    (x, 0) | (0, x) => println!("on axis at {x}"),
    (x, y) => println!("({x}, {y})"),
}

// Match guards
let pair = (2, -2);
match pair {
    (x, y) if x == y => println!("equal"),
    (x, y) if x + y == 0 => println!("opposites"),
    _ => println!("other"),
}

// @ bindings
match number {
    n @ 1..=10 => println!("1-10, got {n}"),
    n @ 11..=20 => println!("11-20, got {n}"),
    _ => println!("out of range"),
}

// Destructuring structs
let p = Point { x: 0, y: 7 };
let Point { x, y } = p;
```

## Generics

```rust
// Generic function
fn largest<T: PartialOrd>(list: &[T]) -> &T {
    let mut largest = &list[0];
    for item in list { if item > largest { largest = item; } }
    largest
}

// Generic struct
struct Pair<T> {
    first: T,
    second: T,
}

impl<T: Display + PartialOrd> Pair<T> {
    fn cmp_display(&self) {
        if self.first >= self.second {
            println!("first is larger: {}", self.first);
        } else {
            println!("second is larger: {}", self.second);
        }
    }
}
```

## Traits (Shared Behaviour)

```rust
use std::fmt;

// Define a trait
trait Animal: fmt::Display { // supertrait: must also impl Display
    fn name(&self) -> &str;
    fn sound(&self) -> String;
    
    // Default implementation
    fn describe(&self) -> String {
        format!("{} says {}", self.name(), self.sound())
    }
}

struct Dog { name: String }
impl Animal for Dog {
    fn name(&self) -> &str { &self.name }
    fn sound(&self) -> String { "woof".to_string() }
}
impl fmt::Display for Dog {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "Dog({})", self.name)
    }
}

// Trait as parameter (impl Trait syntax)
fn make_noise(animal: &impl Animal) {
    println!("{}", animal.describe());
}

// Trait bound syntax (equivalent, more expressive)
fn make_noise<A: Animal>(animal: &A) {
    println!("{}", animal.describe());
}

// Where clause (cleaner for complex bounds)
fn complicated<T, U>(t: &T, u: &U)
where
    T: Clone + fmt::Debug,
    U: fmt::Display + fmt::Debug,
{
    println!("{t:?} and {u}");
}

// Return impl Trait (static dispatch)
fn make_animal() -> impl Animal {
    Dog { name: "Rex".to_string() }
}

// Trait objects for dynamic dispatch
fn process_animals(animals: &[Box<dyn Animal>]) {
    for a in animals { println!("{}", a.describe()); }
}
```

## Derive Macros for Common Traits

```rust
#[derive(Debug, Clone, PartialEq, Eq, Hash, PartialOrd, Ord)]
struct Point { x: i32, y: i32 }

// Debug: {:?} / {:#?} formatting
// Clone: .clone() method
// PartialEq: == and != operators
// Eq: strict equality (requires PartialEq)
// Hash: use as HashMap key (requires Eq)
// PartialOrd: <, >, <=, >= operators
// Ord: total ordering, sort (requires PartialOrd + Eq)
```

## Associated Types

```rust
trait Container {
    type Item; // associated type
    fn first(&self) -> Option<&Self::Item>;
    fn last(&self) -> Option<&Self::Item>;
}

struct Stack<T> { data: Vec<T> }
impl<T> Container for Stack<T> {
    type Item = T;
    fn first(&self) -> Option<&T> { self.data.first() }
    fn last(&self) -> Option<&T> { self.data.last() }
}
```
