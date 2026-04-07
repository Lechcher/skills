# zig-lang-skill

An agent skill providing expert Zig programming language assistance, crawled from the [Zig Language Reference (master)](https://ziglang.org/documentation/master/).

## What This Skill Does

Activates when you ask about Zig programming. Provides help with:
- **Language features**: types, control flow, error handling, optionals, comptime
- **Memory management**: allocators, defer/errdefer, lifetime management
- **Generics**: comptime-based generic types and functions
- **C interop**: `@cImport`, `translate-c`, exporting C libraries
- **WebAssembly**: freestanding and WASI targets
- **Build system**: `build.zig` configuration
- **Builtins**: all `@builtin` functions
- **Debugging**: understanding Zig errors and illegal behaviors

## Installation

### Auto-detect Platform
```bash
./install.sh
```

### Specific Platform
```bash
./install.sh --platform gemini      # Gemini CLI
./install.sh --platform claude      # Claude Code
./install.sh --platform cursor      # Cursor
./install.sh --platform copilot     # GitHub Copilot
./install.sh --platform windsurf    # Windsurf
./install.sh --platform universal   # Universal (~/.agents/skills/)
```

### Manual (git clone)
```bash
# Gemini CLI
git clone <repo-url> ~/.gemini/skills/zig-lang-skill

# Claude Code
git clone <repo-url> ~/.claude/skills/zig-lang-skill

# Cursor
git clone <repo-url> .cursor/rules/zig-lang-skill

# GitHub Copilot
git clone <repo-url> .github/skills/zig-lang-skill

# Universal
git clone <repo-url> ~/.agents/skills/zig-lang-skill
```

## Usage

After installation, open a new session and type:

```
/zig-lang Write a generic stack data structure
/zig-lang How do I handle errors in Zig?
/zig-lang Explain comptime and generics
/zig-lang How do I call C code from Zig?
/zig-lang Write a build.zig for my project
/zig-lang Target WebAssembly with WASI
/zig-lang What allocator should I use?
```

## File Structure

```
zig-lang-skill/
├── SKILL.md              # Skill definition and activation
├── references/
│   └── zig-reference.md  # Complete Zig language reference
├── install.sh            # Cross-platform installer
└── README.md             # This file
```

## Reference Coverage

The `references/zig-reference.md` covers:
- Introduction and Hello World
- Primitive types (integers, floats, bool, void, noreturn)
- Strings, arrays, slices, vectors, pointers
- Structs, enums, unions, opaque types
- Control flow (if, while, for, switch, defer, unreachable)
- Functions, closures, inline functions
- Error handling (error sets, error unions, try, catch, errdefer)
- Optionals and null safety
- Type casting and coercion
- comptime and metaprogramming
- All builtin functions reference
- Memory management and allocators
- C interoperability
- WebAssembly targets
- Build system (build.zig)
- Style guide and best practices
- Keyword reference
- Grammar appendix and Zen

## Source

Documentation crawled from:
- https://ziglang.org/documentation/master/

## License

MIT
