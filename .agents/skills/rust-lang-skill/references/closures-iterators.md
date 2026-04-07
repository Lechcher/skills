# Rust Closures & Iterators

Source: https://doc.rust-lang.org/book/ch13-00-functional-features.html

## Closures

Closures are anonymous functions that capture their environment.

```rust
// Basic closure syntax
let add = |x, y| x + y;
println!("{}", add(3, 4)); // 7

// With type annotations
let double: fn(i32) -> i32 = |x| x * 2;

// Multi-line closure
let complex = |x: i32| {
    let doubled = x * 2;
    doubled + 1
};
```

### Capturing Variables

```rust
let threshold = 5;

// Borrows threshold immutably (Fn trait)
let is_big = |x| x > threshold;
println!("{threshold}"); // threshold still accessible

// Borrows threshold mutably (FnMut trait)
let mut count = 0;
let mut increment = || { count += 1; count };
increment();

// Takes ownership of captured variables (FnOnce trait)
let name = String::from("Alice");
let greet = move || println!("Hello, {name}");
// name is moved into greet; cannot use name here
greet();
```

### The Three Fn Traits

| Trait | Description | Can be called |
|-------|-------------|---------------|
| `FnOnce` | Takes ownership of captured vars | Once |
| `FnMut` | Mutably borrows captured vars | Multiple times (mut required) |
| `Fn` | Immutably borrows captured vars | Multiple times |

Every closure implements at least `FnOnce`. `FnMut` implies `FnOnce`. `Fn` implies `FnMut` and `FnOnce`.

```rust
// Accepting closures as parameters
fn apply<F: Fn(i32) -> i32>(f: F, x: i32) -> i32 {
    f(x)
}

// Returning closures (must use Box<dyn Fn> or impl Fn)
fn make_adder(x: i32) -> impl Fn(i32) -> i32 {
    move |y| x + y
}
let add5 = make_adder(5);
println!("{}", add5(3)); // 8
```

## Iterators

Iterators produce a sequence of values lazily (no computation until consumed).

```rust
// Creating iterators from collections
let v = vec![1, 2, 3];
let iter = v.iter();         // &T - borrows elements
let iter = v.iter_mut();     // &mut T - mutable borrows
let iter = v.into_iter();    // T - consumes v, yields owned values
```

### The `Iterator` Trait

```rust
pub trait Iterator {
    type Item;
    fn next(&mut self) -> Option<Self::Item>;
    // Many default methods...
}

// Custom iterator
struct Countdown { count: u32 }
impl Iterator for Countdown {
    type Item = u32;
    fn next(&mut self) -> Option<u32> {
        if self.count == 0 { None }
        else { self.count -= 1; Some(self.count + 1) }
    }
}
let cd = Countdown { count: 3 };
let collected: Vec<u32> = cd.collect(); // [3, 2, 1]
```

### Iterator Adapters (Lazy Transformations)

```rust
let v = vec![1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

// map: transform each element
let doubled: Vec<i32> = v.iter().map(|&x| x * 2).collect();

// filter: keep matching elements
let evens: Vec<&i32> = v.iter().filter(|&&x| x % 2 == 0).collect();

// filter_map: filter and transform in one step
let parsed: Vec<i32> = ["1", "two", "3"]
    .iter()
    .filter_map(|s| s.parse().ok())
    .collect(); // [1, 3]

// flat_map: map then flatten
let words = ["hello world", "foo bar"];
let chars: Vec<&str> = words.iter()
    .flat_map(|s| s.split_whitespace())
    .collect(); // ["hello", "world", "foo", "bar"]

// take and skip
let first_three: Vec<&i32> = v.iter().take(3).collect();  // [1, 2, 3]
let skip_two: Vec<&i32> = v.iter().skip(2).collect();    // [3, 4, 5, ...]

// zip: combine two iterators
let names = ["Alice", "Bob"];
let scores = [95, 87];
let pairs: Vec<_> = names.iter().zip(scores.iter()).collect();

// chain: concatenate two iterators
let a = [1, 2];
let b = [3, 4];
let combined: Vec<_> = a.iter().chain(b.iter()).collect(); // [1, 2, 3, 4]

// enumerate: add index
for (i, val) in v.iter().enumerate() {
    println!("{i}: {val}");
}

// peekable: look at next element without consuming
let mut iter = v.iter().peekable();
if iter.peek() == Some(&&1) { iter.next(); } // consume conditionally
```

### Consumer Methods (Terminate the Iterator)

```rust
let v = vec![1, 2, 3, 4, 5];

// Collect into various types
let collected: Vec<i32> = v.iter().copied().collect();
let set: std::collections::HashSet<i32> = v.iter().copied().collect();
let map: std::collections::HashMap<_, _> = [(1, "a"), (2, "b")].into_iter().collect();

// Aggregation
let sum: i32 = v.iter().sum();                  // 15
let product: i32 = v.iter().product();          // 120
let count = v.iter().count();                   // 5
let max = v.iter().max();                       // Some(&5)
let min = v.iter().min();                       // Some(&1)

// fold / reduce (custom aggregation)
let sum = v.iter().fold(0, |acc, &x| acc + x); // 15
let factorial = (1..=5).reduce(|acc, x| acc * x); // Some(120)

// Searching
let found = v.iter().find(|&&x| x > 3);         // Some(&4)
let pos = v.iter().position(|&x| x == 3);       // Some(2)

// Checking
let any_even = v.iter().any(|&x| x % 2 == 0);  // true
let all_pos = v.iter().all(|&x| x > 0);        // true

// Sorting and collecting
let mut sorted = v.clone();
sorted.sort();
let sorted: Vec<i32> = sorted;

// Building string from iterator
let s: String = ['h','e','l','l','o'].iter().collect();
let s: String = vec!["hello", " ", "world"].concat();
let s = vec!["a", "b", "c"].join(", "); // "a, b, c"

// for_each (consume without collecting)
v.iter().for_each(|x| println!("{x}"));
```

### Iterator Performance

Rust's iterators are zero-cost abstractions — they compile to the same machine code as manual loops (often with SIMD auto-vectorization):

```rust
// These are equivalent in performance:
let sum: i32 = v.iter().filter(|&&x| x % 2 == 0).map(|&x| x * x).sum();

let mut sum = 0;
for &x in &v {
    if x % 2 == 0 { sum += x * x; }
}
```
