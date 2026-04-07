# Rust Collections

Source: https://doc.rust-lang.org/book/ch08-00-common-collections.html

## Vectors (`Vec<T>`)

```rust
// Creating
let mut v: Vec<i32> = Vec::new();
let v = vec![1, 2, 3]; // vec! macro

// Adding elements
v.push(4);
v.extend([5, 6, 7]);

// Accessing elements
let third = &v[2];          // panics if out of bounds
let third = v.get(2);       // returns Option<&T>

// Iterating
for n in &v { println!("{n}"); }      // immutable
for n in &mut v { *n += 10; }         // mutable
for n in v { println!("{n}"); }        // consuming (moves v)

// Common methods
v.len()                 // number of elements
v.is_empty()            // true if empty
v.contains(&3)          // true if contains 3
v.sort()                // sort in place
v.sort_by(|a, b| b.cmp(a))  // sort descending
v.dedup()               // remove consecutive duplicates (sort first)
v.retain(|&x| x > 0)   // keep only elements matching predicate
v.drain(1..3)           // remove and return range
v.pop()                 // remove and return last element -> Option<T>
v.remove(0)             // remove and return element at index
v.insert(0, 99)         // insert at index

// Slices
let slice: &[i32] = &v[1..3];

// Storing multiple types with enum
#[derive(Debug)]
enum Cell { Int(i32), Float(f64), Text(String) }
let row = vec![
    Cell::Int(3),
    Cell::Float(1.5),
    Cell::Text("hello".to_string()),
];
```

## Strings

Two important string types:
- `String`: owned, heap-allocated, UTF-8
- `&str`: borrowed slice of UTF-8 data (string literal or slice of String)

```rust
// Creating
let s = String::new();
let s = String::from("hello");
let s = "hello".to_string();
let s = "hello".to_owned();

// Growing a String
let mut s = String::from("hello");
s.push_str(" world");  // append &str
s.push('!');           // append single char

// Concatenation
let s1 = String::from("Hello, ");
let s2 = String::from("world!");
let s3 = s1 + &s2;  // s1 is moved here! s2 is borrowed

// format! macro (doesn't take ownership)
let s = format!("{s2}-{s2}");

// String length and indexing
let s = String::from("hello");
s.len()          // number of BYTES (not chars!)
s.chars().count()  // number of Unicode chars
// s[0]          // ERROR: cannot index String
let slice = &s[0..3]; // OK: byte slice (must be valid char boundary)

// Iterating
for c in "hello".chars() { println!("{c}"); }  // char-by-char
for b in "hello".bytes() { println!("{b}"); }  // byte-by-byte

// Common string methods
let s = String::from("  hello world  ");
s.trim()              // "hello world" (remove whitespace at ends)
s.to_lowercase()      // "  hello world  "
s.to_uppercase()      // "  HELLO WORLD  "
s.contains("world")   // true
s.starts_with("  h")  // true
s.replace("hello", "hi")    // "  hi world  "
s.split_whitespace()  // iterator over whitespace-delimited words
s.split(',')          // iterator over comma-delimited parts
s.lines()             // iterator over lines

// Parse string to other type
let n: i32 = "42".parse().unwrap();
let n: i32 = "42".parse::<i32>().unwrap();
```

## Hash Maps (`HashMap<K, V>`)

```rust
use std::collections::HashMap;

// Creating
let mut scores: HashMap<String, i32> = HashMap::new();

// From iterators
let teams = vec!["Blue", "Red"];
let scores_list = vec![10, 50];
let scores: HashMap<&str, i32> = teams.into_iter().zip(scores_list).collect();

// Inserting
scores.insert("Blue".to_string(), 25);
scores.insert("Red".to_string(), 50);

// Accessing
let blue_score = scores.get("Blue"); // Option<&i32>
let blue_score = scores["Blue"];     // panics if missing
let blue_score = scores.get("Blue").copied().unwrap_or(0); // with default

// Iterating
for (key, value) in &scores {
    println!("{key}: {value}");
}

// Ownership: String keys are moved into the map; &str borrows must outlive map

// Entry API (idiomatic insert-or-update)
scores.entry("Yellow".to_string()).or_insert(50);  // insert if missing
scores.entry("Blue".to_string()).or_insert(0);     // no-op if exists

// Update based on old value
let text = "hello world wonderful world";
let mut word_count: HashMap<&str, i32> = HashMap::new();
for word in text.split_whitespace() {
    let count = word_count.entry(word).or_insert(0);
    *count += 1;
}

// Common methods
scores.contains_key("Blue")       // true
scores.remove("Blue")             // removes and returns Option<V>
scores.len()                      // number of entries
scores.is_empty()
scores.keys()                     // iterator over keys
scores.values()                   // iterator over values
scores.values_mut()               // mutable iterator over values
```

## BTreeMap (Sorted HashMap)

```rust
use std::collections::BTreeMap;
// Same API as HashMap, but iterates in sorted key order
let mut map = BTreeMap::new();
map.insert("b", 2);
map.insert("a", 1);
for (k, v) in &map { println!("{k}: {v}"); } // prints a:1, b:2
```

## HashSet and BTreeSet

```rust
use std::collections::HashSet;

let mut set: HashSet<i32> = HashSet::new();
set.insert(1); set.insert(2); set.insert(3);
set.insert(2); // duplicates ignored

// Set operations
let a: HashSet<i32> = [1, 2, 3].into();
let b: HashSet<i32> = [2, 3, 4].into();
let union: HashSet<&i32> = a.union(&b).collect();
let intersection: HashSet<&i32> = a.intersection(&b).collect();
let difference: HashSet<&i32> = a.difference(&b).collect();
let symmetric_diff: HashSet<&i32> = a.symmetric_difference(&b).collect();
```

## VecDeque (Double-Ended Queue)

```rust
use std::collections::VecDeque;
let mut deque: VecDeque<i32> = VecDeque::new();
deque.push_front(1); // add to front
deque.push_back(2);  // add to back
deque.pop_front();   // remove from front
deque.pop_back();    // remove from back
```

## Ranges and Slices

```rust
// Range types
let r: std::ops::Range<i32> = 1..5; // [1, 2, 3, 4]
let r: std::ops::RangeInclusive<i32> = 1..=5; // [1, 2, 3, 4, 5]
for i in 1..=5 { print!("{i} "); }

// Array and slice
let arr: [i32; 5] = [1, 2, 3, 4, 5];
let slice: &[i32] = &arr[1..4]; // [2, 3, 4]
let zeros = [0; 10]; // [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
```
