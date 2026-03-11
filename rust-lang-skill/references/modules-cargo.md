# Rust Modules, Packages & Cargo

Source: https://doc.rust-lang.org/book/ch07-00-managing-growing-projects-with-packages-crates-and-modules.html
         https://doc.rust-lang.org/book/ch14-00-more-about-cargo.html

## Packages and Crates

- **Package**: One or more crates, contains a `Cargo.toml`
- **Crate**: A tree of modules that produce a library or executable
  - **Binary crate**: has a `main()` function, compiled to executable
  - **Library crate**: no `main()`, provides functions for others to use
- **Module**: Organizes code within a crate

**File layout conventions:**
```
my-package/
├── Cargo.toml
├── src/
│   ├── main.rs          # binary crate root
│   ├── lib.rs           # library crate root (optional)
│   ├── bin/
│   │   └── other.rs     # additional binary
│   └── utils/
│       ├── mod.rs       # or utils.rs at parent level
│       └── helpers.rs
└── tests/               # integration tests
    └── integration_test.rs
```

## Module System

```rust
// In src/lib.rs or src/main.rs
mod garden {
    pub mod vegetables {
        pub struct Asparagus { pub name: String }
        
        pub fn plant() -> String {
            "planted asparagus".to_string()
        }
    }
    
    mod private_stuff {
        fn internal() {} // not pub, not accessible outside garden
    }
}

// Absolute path
use crate::garden::vegetables::Asparagus;

// Relative path
use self::garden::vegetables::plant;

// External crates
use std::collections::HashMap;

// Nested use
use std::{cmp::Ordering, io};

// Glob import (use sparingly)
use std::collections::*;

// Re-exporting
pub use crate::garden::vegetables::Asparagus;
```

## Modules in Separate Files

```rust
// src/main.rs
mod utils; // Rust looks for src/utils.rs or src/utils/mod.rs
use utils::helper;

// src/utils.rs (or src/utils/mod.rs)
pub mod helper {
    pub fn greet(name: &str) -> String {
        format!("Hello, {name}!")
    }
}
```

## Visibility (`pub`)

```rust
pub struct User {         // public struct
    pub username: String, // public field
    email: String,        // private field (accessible only within module)
}

pub enum Color { Red, Green, Blue } // enum variants are pub by default

pub(crate) fn internal_fn() {}  // pub only within this crate
pub(super) fn parent_fn() {}    // pub only to parent module

// Struct fields not marked pub cannot be accessed outside
// So constructors are needed to create instances
impl User {
    pub fn new(username: String, email: String) -> Self {
        Self { username, email }
    }
    pub fn email(&self) -> &str {
        &self.email
    }
}
```

## Cargo.toml Configuration

```toml
[package]
name = "my-project"
version = "0.1.0"
edition = "2024"        # Rust edition
description = "My project"
license = "MIT"
repository = "https://github.com/user/repo"
readme = "README.md"
keywords = ["cli", "tool"]
categories = ["command-line-utilities"]

[dependencies]
serde = { version = "1", features = ["derive"] }
tokio = { version = "1", features = ["full"] }
reqwest = { version = "0.11", features = ["json"] }

[dev-dependencies]      # only for tests and examples
assert_cmd = "2"
tempfile = "3"

[build-dependencies]    # only for build scripts
cc = "1"

[features]
default = ["std"]
std = []
async = ["tokio"]

[profile.release]
opt-level = 3
lto = true

[profile.dev]
opt-level = 0
debug = true
```

## Common Cargo Commands

```bash
# Project management
cargo new project-name          # binary project
cargo new --lib library-name    # library project
cargo init                      # in existing directory

# Building
cargo build                     # debug build
cargo build --release           # optimized release build
cargo check                     # check without building (fast!)

# Running
cargo run                       # build and run
cargo run --bin other-bin       # run a specific binary

# Testing
cargo test                      # run all tests
cargo test test_name            # run tests matching name
cargo test -- --nocapture       # show stdout in tests
cargo test -- --test-threads=1  # run tests single-threaded

# Documentation
cargo doc                       # generate docs
cargo doc --open                # generate and open in browser
cargo doc --no-deps             # only document our crate

# Dependencies
cargo add serde                 # add dependency
cargo add serde --features derive
cargo remove serde              # remove dependency
cargo update                    # update dependencies
cargo tree                      # show dependency tree

# Publishing
cargo login                     # login to crates.io
cargo publish                   # publish to crates.io
cargo publish --dry-run         # check without publishing

# Other
cargo fmt                       # format code
cargo clippy                    # run linter
cargo clean                     # remove target directory
cargo bench                     # run benchmarks
```

## Workspaces (Multiple Crates)

```toml
# workspace/Cargo.toml
[workspace]
members = [
    "adder",
    "add_one",
]
resolver = "2"

# Dependencies shared across workspace
[workspace.dependencies]
serde = { version = "1", features = ["derive"] }
```

```bash
cargo build                     # builds all workspace members
cargo test -p add_one           # test specific workspace member
```

## Publishing to Crates.io

```rust
//! # My Library
//! 
//! `my_library` is a collection of utilities.
//!
//! ## Examples
//! 
//! ```
//! let result = my_library::add(2, 2);
//! assert_eq!(result, 4);
//! ```

/// Adds two numbers together.
///
/// # Examples
/// ```
/// let result = my_library::add(2, 2);
/// assert_eq!(result, 4);
/// ```
pub fn add(a: i32, b: i32) -> i32 {
    a + b
}
```

## Release Profiles

```toml
[profile.dev]
opt-level = 0    # no optimization (fast compile)

[profile.release]
opt-level = 3    # maximum optimization (slow compile, fast runtime)
lto = true       # link-time optimization
codegen-units = 1 # better optimization but slower compile
strip = true     # strip debug symbols
```
