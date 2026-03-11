# 🦀 rust-lang-skill

An expert Rust programming language assistant skill based on *The Rust Programming Language* book (the official "Rust Book"). Covers the entire Rust language from basics to advanced topics.

## What This Skill Does

When activated with `/rust-lang-skill`, this skill acts as a world-class Rust expert that can:

- **Explain** ownership, borrowing, lifetimes, and the borrow checker
- **Write** idiomatic, production-quality Rust code
- **Debug** borrow checker errors and explain how to fix them
- **Implement** common patterns: builder, state machine, error handling, iterators
- **Guide** through async/await, concurrency, smart pointers, macros
- **Assist** with Cargo configuration, publishing crates, and workspace setup

## Topics Covered

From *The Rust Programming Language* (all 21 chapters + Appendices):

| Area | Topics |
|------|--------|
| Basics | Variables, data types, functions, control flow, Cargo |
| Ownership | Ownership rules, moves, clones, stack vs heap |
| References | Borrowing, mutable refs, slices, lifetime annotations |
| Types | Structs, enums, Option, Result, pattern matching |
| Generics | Generic functions, structs, trait bounds, associated types |
| Traits | Defining, implementing, default implementations, trait objects |
| Error Handling | panic!, Result, ?, custom error types, anyhow, thiserror |
| Collections | Vec, String, HashMap, HashSet, BTreeMap |
| Closures | Fn/FnMut/FnOnce traits, capturing, move closures |
| Iterators | Adapters, consumers, custom iterators |
| Smart Pointers | Box, Rc, Arc, RefCell, Mutex, RwLock, Weak |
| Concurrency | Threads, channels, shared state, Send/Sync |
| Async/Await | Futures, tokio runtime, tasks, streams, channels |
| OOP Features | Trait objects, dynamic dispatch, design patterns |
| Patterns | All pattern syntax, destructuring, guards, @ bindings |
| Advanced | Unsafe, raw pointers, FFI, macros, advanced traits/types |
| Modules | Package system, crates, visibility, use keyword |
| Cargo | Profiles, workspaces, publishing, features |

## Installation

### Clone and Install (Recommended)

```bash
git clone <repo-url> rust-lang-skill
cd rust-lang-skill
chmod +x install.sh
./install.sh
```

### Manual Installation

**Claude Code:**
```bash
cp -R ./rust-lang-skill ~/.claude/skills/rust-lang-skill
```

**Cursor:**
```bash
cp -R ./rust-lang-skill ~/.cursor/rules/rust-lang-skill
```

**GitHub Copilot:**
```bash
cp -R ./rust-lang-skill .github/skills/rust-lang-skill
```

**Windsurf:**
```bash
cp -R ./rust-lang-skill ~/.codeium/windsurf/skills/rust-lang-skill
```

**Gemini CLI:**
```bash
cp -R ./rust-lang-skill ~/.gemini/skills/rust-lang-skill
```

**Universal (.agents):**
```bash
cp -R ./rust-lang-skill ~/.agents/skills/rust-lang-skill
```

### Auto-install to all detected platforms

```bash
./install.sh --all
```

### Dry run (preview without installing)

```bash
./install.sh --dry-run
```

## Usage

After installing, open a new agent session and type:

```
/rust-lang-skill Explain ownership and borrowing in Rust

/rust-lang-skill Write a function that reads a CSV file and returns a Vec of structs

/rust-lang-skill Why is the borrow checker rejecting my code?

/rust-lang-skill How do I implement an async HTTP server with Axum?

/rust-lang-skill Show me how to use Rc<RefCell<T>> for shared mutable state

/rust-lang-skill Convert this Python class to idiomatic Rust

/rust-lang-skill How do I write tests in Rust?
```

## Reference Files

| File | Contents |
|------|----------|
| `references/ownership-borrowing.md` | Ownership rules, moves, borrows, lifetimes |
| `references/types-and-traits.md` | Structs, enums, traits, generics, derive macros |
| `references/error-handling.md` | Result, Option, ?, panic!, custom errors |
| `references/collections.md` | Vec, String, HashMap, HashSet, slices |
| `references/closures-iterators.md` | Closures, Fn traits, iterator adapters/consumers |
| `references/smart-pointers.md` | Box, Rc, Arc, RefCell, Mutex, Weak |
| `references/concurrency.md` | Threads, channels, Arc/Mutex, Send/Sync |
| `references/async-await.md` | Futures, async/await, Tokio, streams |
| `references/modules-cargo.md` | Package system, visibility, Cargo commands |
| `references/advanced-features.md` | Unsafe, macros, advanced types/traits |
| `references/common-patterns.md` | Idiomatic patterns, anti-patterns, popular crates |

## Source

Based on *The Rust Programming Language* by Steve Klabnik, Carol Nichols, and Chris Krycho.
Available online: https://doc.rust-lang.org/book/
Rust version: 1.90.0+, Edition 2024

## License

MIT
