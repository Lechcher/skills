# Zig Language Reference
> Source: https://ziglang.org/documentation/master/
> Version: master (nightly)

## Introduction

Zig is a general-purpose programming language and toolchain for maintaining **robust**, **optimal**, and **reusable** software.

- **Robust**: Behavior is correct even for edge cases such as out of memory.
- **Optimal**: Write programs the best way they can behave and perform.
- **Reusable**: The same code works in many environments with different constraints.
- **Maintainable**: Precisely communicate intent to the compiler and other programmers.

The code samples in Zig documentation are compiled and tested as part of the main test suite.

---

## Hello World

```zig
const std = @import("std");

pub fn main() void {
    std.debug.print("Hello, {s}!\n", .{"World"});
}
```

Build and run:
```
$ zig build-exe hello.zig
$ ./hello
Hello, World!
```

Writing to stdout with error handling:
```zig
const std = @import("std");
pub fn main(init: std.process.Init) !void {
    try std.Io.File.stdout().writeStreamingAll(init.io, "Hello, World!\n");
}
```

---

## Comments

- **Normal comments**: `//` — rest of the line
- **Doc comments**: `///` — documents the following item
- **Top-level doc comments**: `//!` — documents the current module

```zig
//! This is a top-level doc comment for the module.

/// This is a doc comment for `foo`.
fn foo() void {}
```

---

## Identifiers

Must start with an alphabetic character or underscore, followed by alphanumeric characters or underscores.

Keywords cannot be used as identifiers. Use `@"..."` syntax to use any string as an identifier:

```zig
const @"an identifier with spaces in it" = 10;
const @"identifier_with_unicode_αβγ" = 1;
```

---

## Values and Primitive Types

### Integer Types

| Zig Type | C Equivalent | Description |
|----------|-------------|-------------|
| `i8`     | `int8_t`    | 8-bit signed |
| `u8`     | `uint8_t`   | 8-bit unsigned |
| `i16`    | `int16_t`   | 16-bit signed |
| `u16`    | `uint16_t`  | 16-bit unsigned |
| `i32`    | `int32_t`   | 32-bit signed |
| `u32`    | `uint32_t`  | 32-bit unsigned |
| `i64`    | `int64_t`   | 64-bit signed |
| `u64`    | `uint64_t`  | 64-bit unsigned |
| `i128`   | `__int128`  | 128-bit signed |
| `u128`   | `unsigned __int128` | 128-bit unsigned |
| `isize`  | `intptr_t`  | Pointer-sized signed |
| `usize`  | `uintptr_t`/`size_t` | Pointer-sized unsigned |
| `c_char` | `char`      | For C ABI |
| `c_short`| `short`     | For C ABI |
| `c_ushort`| `unsigned short` | For C ABI |
| `c_int`  | `int`       | For C ABI |
| `c_uint` | `unsigned int` | For C ABI |
| `c_long` | `long`      | For C ABI |
| `c_ulong`| `unsigned long` | For C ABI |
| `c_longlong` | `long long` | For C ABI |
| `c_ulonglong` | `unsigned long long` | For C ABI |
| `c_longdouble` | `long double` | For C ABI |

Arbitrary bit-width integers: `i7` (signed 7-bit), `u3` (unsigned 3-bit). Max bit-width: 65535.

### Float Types

| Zig Type | C Equivalent |
|----------|-------------|
| `f16`    | `_Float16`  |
| `f32`    | `float`     |
| `f64`    | `double`    |
| `f80`    | `long double` (80-bit) |
| `f128`   | `_Float128` |

### Other Primitive Types

| Type | Description |
|------|-------------|
| `bool` | `true` or `false` |
| `anyopaque` | Equivalent to C's `void` |
| `void` | Zero-bit type, only value is `void{}` |
| `noreturn` | Type of `break`, `continue`, `return`, `unreachable`, infinite loops |
| `type` | The type of types themselves |
| `anyerror` | Error union encompassing all error codes |
| `comptime_int` | Integer known at compile time, arbitrary precision |
| `comptime_float` | Float known at compile time, f128 precision |

### Primitive Values
- `true`, `false` — boolean literals
- `null` — null literal for optionals
- `undefined` — unspecified value, can coerce to any type

### String Literals

Strings are `[]const u8` (slice of bytes):
```zig
const bytes = "hello";
// bytes has type []const u8
```

Unicode code point literals (single character):
```zig
const char = '⚡'; // type: comptime_int (or u21)
```

#### Escape Sequences
| Sequence | Meaning |
|----------|---------|
| `\n` | Newline |
| `\r` | Carriage return |
| `\t` | Tab |
| `\\` | Backslash |
| `\'` | Single quote |
| `\"` | Double quote |
| `\xNN` | Hex byte (NN is hex digits) |
| `\u{NNNNNN}` | Unicode codepoint |

#### Multiline String Literals
```zig
const text =
    \\line 1
    \\line 2
    \\line 3
;
// text has type []const u8, no trailing newline needed
```

---

## Assignment

```zig
const constant: i32 = 5;   // comptime-known, cannot change
var variable: i32 = 5;     // can be modified

variable = variable + 1;
```

Use `undefined` to leave a value uninitialized (e.g., to be set later):
```zig
var x: i32 = undefined;
x = 5;
```

### Destructuring

```zig
const tuple = .{ 1, 2 };
const a, const b = tuple;
// a == 1, b == 2

var a2: i32 = undefined;
var b2: i32 = undefined;
a2, b2 = .{ 10, 20 };
```

---

## Zig Test

```zig
const std = @import("std");

test "basic addition" {
    const x: i32 = 1;
    const y: i32 = 2;
    try std.testing.expect(x + y == 3);
}
```

Run tests:
```
$ zig test myfile.zig
```

### Test Features
- **Skip tests**: `return error.SkipZigTest;` inside a test
- **Memory leak detection**: use `std.testing.allocator`
- **Detect test build**: `@import("builtin").is_test`
- **Doctests**: code examples in `///` comments can be tested

### Testing Namespace Functions
- `std.testing.expect(bool)` — assert condition
- `std.testing.expectEqual(expected, actual)` — assert equality
- `std.testing.expectError(error, error_union)` — assert error
- `std.testing.allocator` — general purpose allocator for tests

---

## Variables

### Container Level Variables
Declared at file/struct level, not inside functions. Accessed via `@import`:
```zig
const std = @import("std");
var gpa = std.heap.GeneralPurposeAllocator(.{}){};

pub fn main() void {
    // use gpa
}
```

### Static Local Variables
Use a struct with a `var` field inside a function:
```zig
fn foo() u32 {
    const S = struct { var count: u32 = 0; };
    S.count += 1;
    return S.count;
}
```

### Thread Local Variables
```zig
threadlocal var x: i32 = 0;
```

---

## Integers

### Integer Literals
```zig
const decimal = 98222;
const hex = 0xff;
const octal = 0o755;
const binary = 0b11110000;
// Underscores allowed for readability:
const big = 1_000_000;
```

### Integer Operations

Wrapping arithmetic (no overflow check):
```zig
x +% y   // wrapping add
x -% y   // wrapping sub
x *% y   // wrapping multiply
x <<% y  // wrapping shift left
```

Saturating arithmetic:
```zig
x +| y   // saturating add
x -| y   // saturating sub
x *| y   // saturating multiply
x <<| y  // saturating shift left
```

Overflow-checked arithmetic (returns struct with result and overflow bit):
```zig
@addWithOverflow(a, b)   // returns .{result, overflow_bit}
@subWithOverflow(a, b)
@mulWithOverflow(a, b)
@shlWithOverflow(a, b)
```

---

## Floats

### Float Literals
```zig
const float = 123.0e+77;
const hex_float = 0x103.70p-5;
const nan = std.math.nan(f32);
const inf = std.math.inf(f64);
```

### Float Modes
Use `@setFloatMode(.optimized)` for relaxed floating point (may break IEEE754 compliance for speed).

---

## Operators

### Arithmetic
| Operator | Description |
|----------|-------------|
| `a + b`  | Add |
| `a +% b` | Wrapping add |
| `a +\| b` | Saturating add |
| `a - b`  | Subtract |
| `a -% b` | Wrapping subtract |
| `a -\| b` | Saturating subtract |
| `-a`     | Negation |
| `-%a`    | Wrapping negation |
| `a * b`  | Multiply |
| `a *% b` | Wrapping multiply |
| `a *\| b` | Saturating multiply |
| `a / b`  | Divide |
| `a % b`  | Remainder |

### Bitwise
| Operator | Description |
|----------|-------------|
| `a & b`  | Bitwise AND |
| `a \| b` | Bitwise OR |
| `a ^ b`  | Bitwise XOR |
| `~a`     | Bitwise NOT |
| `a << b` | Left shift |
| `a <<% b`| Wrapping left shift |
| `a <<\| b`| Saturating left shift |
| `a >> b` | Right shift |

### Logic and Comparison
| Operator | Description |
|----------|-------------|
| `a and b` | Short-circuit AND |
| `a or b`  | Short-circuit OR |
| `!a`      | Boolean NOT |
| `a == b`  | Equal |
| `a != b`  | Not equal |
| `a > b`   | Greater than |
| `a >= b`  | Greater or equal |
| `a < b`   | Less than |
| `a <= b`  | Less or equal |

### Pointer/Misc
| Operator | Description |
|----------|-------------|
| `a.*`    | Pointer dereference |
| `&a`     | Address of |
| `a orelse b` | Unwrap optional or use `b` |
| `a.?`    | Unwrap optional (panic if null) |
| `a catch b` | Unwrap error union or use `b` |
| `a ++ b` | Array concatenation (comptime) |
| `a ** n` | Array repeat (comptime) |

---

## Arrays

```zig
const msg = [5]u8{ 'h', 'e', 'l', 'l', 'o' };
// Access:
const first = msg[0]; // 'h'
// Length:
const len = msg.len; // 5
```

Inferred length with `_`:
```zig
const arr = [_]i32{ 1, 2, 3 };
```

### Array Operations
```zig
// Concatenation (comptime only):
const arr1 = [_]u8{ 1, 2 };
const arr2 = [_]u8{ 3, 4 };
const combined = arr1 ++ arr2; // [1, 2, 3, 4]

// Repeat (comptime only):
const repeated = [_]u8{ 1, 2 } ** 3; // [1, 2, 1, 2, 1, 2]
```

### Multidimensional Arrays
```zig
const matrix: [3][3]f32 = .{
    .{ 1.0, 0.0, 0.0 },
    .{ 0.0, 1.0, 0.0 },
    .{ 0.0, 0.0, 1.0 },
};
```

### Sentinel-Terminated Arrays
```zig
const msg: [5:0]u8 = .{ 'h', 'e', 'l', 'l', 'o' };
// msg[5] == 0 (sentinel accessible)
```

### Destructuring Arrays
```zig
const a, const b, const c = [_]u8{ 1, 2, 3 };
```

---

## Vectors

SIMD vectors using `@Vector`:
```zig
const v1: @Vector(4, f32) = .{ 1, 2, 3, 4 };
const v2: @Vector(4, f32) = .{ 5, 6, 7, 8 };
const result = v1 + v2; // element-wise: .{6, 8, 10, 12}
```

Vectors support element-wise arithmetic operators. Use `@reduce` for horizontal operations:
```zig
const sum = @reduce(.Add, v1); // 10.0
```

---

## Pointers

Two categories:
- **Single item pointer**: `*T` — points to exactly one item
- **Many item pointer**: `[*]T` — points to unknown number of items (like C pointer)

```zig
var x: i32 = 5;
const ptr: *i32 = &x;
ptr.* = 10; // dereference

// Many-item pointer and indexing:
const arr = [_]i32{ 1, 2, 3 };
const many: [*]const i32 = &arr;
const val = many[0]; // 1
```

### Pointer Attributes
- `*const T` — pointer to a constant value
- `*volatile T` — pointer for memory-mapped I/O (prevents optimization)
- `*align(8) T` — pointer with alignment guarantee
- `*allowzero T` — allows zero address (for embedded systems)

### Sentinel-Terminated Pointers
```zig
const str: [*:0]const u8 = "hello"; // null-terminated C string
```

### Optional Pointers
```zig
const maybe: ?*i32 = null;
// if (maybe) |ptr| { ... }
```

Optional pointers are represented as nullable pointers (same size as raw pointer).

---

## Slices

A slice is a pointer + length: `[]T`

```zig
const arr = [_]i32{ 1, 2, 3, 4, 5 };
const slice = arr[1..4]; // [2, 3, 4], type: []const i32
const len = slice.len;   // 3
const ptr = slice.ptr;   // pointer to first element
```

Slice operations:
```zig
// From array:
const all: []const i32 = arr[0..];
// From pointer (must know length):
const s: []const i32 = arr[0..3];
```

### Sentinel-Terminated Slices
```zig
const str: [:0]const u8 = "hello"; // Length 5, sentinel 0 at index 5
```

---

## struct

```zig
const Point = struct {
    x: f32,
    y: f32,
};

const p = Point{ .x = 1.0, .y = 2.0 };
```

### Methods
Structs can have functions acting as methods:
```zig
const Vec3 = struct {
    x: f32,
    y: f32,
    z: f32,

    pub fn dot(self: Vec3, other: Vec3) f32 {
        return self.x * other.x + self.y * other.y + self.z * other.z;
    }
};

const a = Vec3{ .x = 1, .y = 0, .z = 0 };
const b = Vec3{ .x = 0, .y = 1, .z = 0 };
const d = a.dot(b); // 0
```

### Default Field Values
```zig
const Config = struct {
    debug: bool = false,
    verbose: bool = false,
    threshold: f32 = 0.5,
};
const c = Config{}; // uses all defaults
const c2 = Config{ .debug = true }; // override one
```

### extern struct
For C ABI compatibility (fields laid out as C would):
```zig
const CStruct = extern struct {
    a: i32,
    b: i32,
};
```

### packed struct
For bit-precise layout:
```zig
const Flags = packed struct {
    a: bool,
    b: bool,
    c: bool,
    _padding: u5 = 0,
};
// sizeof(Flags) == 1 byte
```

### Anonymous Struct Literals
```zig
const p: Point = .{ .x = 1.0, .y = 2.0 }; // type inferred from context
```

### Tuples
Anonymous structs with numeric field names:
```zig
const tup = .{ 1, "hello", true };
// Access: tup[0] == 1, tup[1] == "hello"
// Or destructure:
const a, const b, const c = tup;
```

### Struct Naming
Structs are often named by assignment:
```zig
const Foo = struct {};
// @typeName(Foo) == "Foo"

// Anonymous in some contexts:
const anon = struct {};
// @typeName(anon) == "anon" or similar
```

---

## enum

```zig
const Color = enum { red, green, blue };
const c = Color.red;

// Optionally with integer backing type:
const Direction = enum(u8) {
    north = 0,
    south = 1,
    east = 2,
    west = 3,
};
```

### Enum Methods
```zig
const Suit = enum {
    clubs,
    spades,
    hearts,
    diamonds,

    pub fn isRed(self: Suit) bool {
        return self == .hearts or self == .diamonds;
    }
};
```

### Enum Literals
Enum values can be specified without the type when it can be inferred:
```zig
const c: Color = .red; // same as Color.red
```

### Non-exhaustive enum
Adding `_` field makes enum non-exhaustive (allows unknown values):
```zig
const Open = enum(u8) {
    a = 1,
    b = 2,
    _,
};
const x = Open.a;
const y: Open = @enumFromInt(255); // valid even without named field
```

---

## union

A union holds one of several possible types at a time:
```zig
const Payload = union {
    int: i64,
    float: f64,
    boolean: bool,
};
var p = Payload{ .int = 42 };
// Accessing wrong field is safety-checked illegal behavior
```

### Tagged union
Tag + value stored together, can be switched on:
```zig
const Tag = enum { int, float, boolean };
const Value = union(Tag) {
    int: i64,
    float: f64,
    boolean: bool,
};
// Or infer enum:
const Value2 = union(enum) {
    int: i64,
    float: f64,
};

const v = Value{ .int = 10 };
switch (v) {
    .int => |i| std.debug.print("{d}\n", .{i}),
    .float => |f| std.debug.print("{f}\n", .{f}),
    .boolean => |b| std.debug.print("{}\n", .{b}),
}
```

### extern union / packed union
- `extern union`: C ABI compatible layout
- `packed union`: Bit-precise layout, all fields share the same bits

---

## opaque

For types with unknown size/alignment (e.g., C opaque types):
```zig
const Foo = opaque {};
extern fn doSomething(foo: *Foo) void;
```

---

## Blocks

Blocks are expressions that return a value. Use labeled blocks with `break`:
```zig
const x = blk: {
    var tmp: i32 = 1;
    tmp += 5;
    break :blk tmp;
};
// x == 6
```

### Shadowing
Inner scopes can have identifiers with the same name as outer scopes (this is NOT allowed at the same scope):
```zig
const x: i32 = 1;
{
    // This shadows outer x:
    const x: i32 = 2;
    _ = x; // 2
}
// x is still 1 here
```

---

## switch

```zig
const x: u8 = 5;
const result = switch (x) {
    1 => "one",
    2, 3 => "two or three",
    4...7 => "four to seven",
    else => "other",
};
```

### Switch with enum
```zig
const Color = enum { red, green, blue };
const c = Color.red;
switch (c) {
    .red => std.debug.print("red\n", .{}),
    .green => std.debug.print("green\n", .{}),
    .blue => std.debug.print("blue\n", .{}),
}
```

### Capture in switch
```zig
const val = union(enum) { a: i32, b: f32 }{ .a = 5 };
switch (val) {
    .a => |x| std.debug.print("a: {d}\n", .{x}),
    .b => |x| std.debug.print("b: {f}\n", .{x}),
}
```

### Labeled switch
Switch can be labeled for use with `break`:
```zig
outer: switch (x) {
    0 => break :outer,
    else => { ... },
}
```

### Inline Switch Prongs
Force compile-time specialization of each case:
```zig
switch (x) {
    inline else => |val| comptime_fn(val),
}
```

---

## while

```zig
var i: u32 = 0;
while (i < 10) : (i += 1) {
    std.debug.print("{d}\n", .{i});
}
```

- `while (cond) { }` — simple while loop
- `while (cond) : (post_expr) { }` — with continue expression
- `break` — exit loop
- `continue` — skip to next iteration (runs post_expr)

### Labeled while
```zig
outer: while (true) {
    inner: while (true) {
        break :outer;
    }
}
```

### while with Optionals
```zig
var opt: ?i32 = 5;
while (opt) |val| {
    std.debug.print("{d}\n", .{val});
    opt = null;
}
```

### while with Error Unions
```zig
var maybe_err: anyerror!i32 = 5;
while (maybe_err) |val| {
    _ = val;
} else |err| {
    _ = err;
}
```

### inline while
Unrolls at compile time (requires comptime-known bounds):
```zig
comptime var i = 0;
inline while (i < 3) : (i += 1) {
    // unrolled 3 times
}
```

---

## for

```zig
const items = [_]i32{ 1, 2, 3, 4, 5 };
for (items) |item| {
    std.debug.print("{d}\n", .{item});
}

// With index:
for (items, 0..) |item, i| {
    std.debug.print("[{d}] = {d}\n", .{ i, item });
}

// Over a range:
for (0..10) |i| {
    std.debug.print("{d}\n", .{i});
}

// Multiple sequences (must be same length):
for (items, other_items) |a, b| { ... }
```

### Labeled for
```zig
outer: for (items) |item| {
    for (other) |other_item| {
        if (item == other_item) break :outer;
    }
}
```

### for else
```zig
for (items) |item| {
    if (item == target) break;
} else {
    // no break occurred
}
```

### inline for
Unrolls at compile time:
```zig
const types = .{ i32, f32, bool };
inline for (types) |T| {
    const x: T = undefined;
    _ = x;
}
```

---

## if

```zig
const x: i32 = 5;
if (x < 0) {
    // negative
} else if (x == 0) {
    // zero
} else {
    // positive
}

// As expression:
const abs = if (x < 0) -x else x;
```

### if with Optionals
```zig
const maybe: ?i32 = 5;
if (maybe) |val| {
    std.debug.print("value: {d}\n", .{val});
} else {
    std.debug.print("null\n", .{});
}
```

### if with Error Unions
```zig
const result: anyerror!i32 = getValue();
if (result) |val| {
    // use val
} else |err| {
    // handle err
}
```

---

## defer

Executes expression when the enclosing block exits (LIFO order, multiple defers):
```zig
fn myFn() void {
    defer std.debug.print("cleanup\n", .{});
    defer std.debug.print("cleanup2\n", .{}); // runs first (LIFO)
    
    // ... do work ...
}
```

---

## errdefer

Like `defer` but only executes if the block exits with an error:
```zig
fn init() !*Resource {
    const resource = try allocate();
    errdefer resource.deinit(); // only runs if error occurs
    
    try resource.setup(); // if this fails, errdefer runs
    return resource;
}
```

---

## unreachable

Asserts control flow never reaches this point. In safe modes (Debug, ReleaseSafe), triggers a panic:
```zig
const x: u32 = 5;
switch (x) {
    1...10 => {},
    else => unreachable,
}
```

---

## noreturn

The type of expressions that never return: `unreachable`, `return`, `break`, `continue`, infinite loops, and functions like `std.process.exit()`.

```zig
fn fail() noreturn {
    std.process.exit(1);
}
```

---

## Functions

```zig
fn add(a: i32, b: i32) i32 {
    return a + b;
}

// With error return:
fn divide(a: f32, b: f32) !f32 {
    if (b == 0) return error.DivisionByZero;
    return a / b;
}
```

- Parameters are immutable (`const`) by default
- `pub fn` — exported from the file/namespace
- `fn` — private/internal

### Generic Functions (anytype)
```zig
fn max(a: anytype, b: anytype) @TypeOf(a) {
    return if (a > b) a else b;
}
const m = max(1, 2); // i32: 2
```

### Comptime Parameters
```zig
fn identity(comptime T: type, val: T) T {
    return val;
}
const x = identity(i32, 5);
```

### inline fn
Forces function to be inlined at call site:
```zig
inline fn square(x: i32) i32 {
    return x * x;
}
```

### Function Reflection
```zig
const info = @typeInfo(@TypeOf(add));
// info.Fn.params, info.Fn.return_type, etc.
```

---

## Errors

### Error Set Type
```zig
const FileError = error{
    NotFound,
    PermissionDenied,
    UnexpectedEof,
};
```

### Error Union Type
`ErrorSet!ReturnType` means the function can return an error or a value:
```zig
fn readFile(path: []const u8) FileError![]u8 {
    // ...
}
```

### try
Shorthand for propagating errors up:
```zig
const data = try readFile("file.txt");
// equivalent to:
const data = readFile("file.txt") catch |err| return err;
```

### catch
Handle errors inline:
```zig
const val = riskyOp() catch 0;           // default value
const val2 = riskyOp() catch |err| blk: { // handle error
    std.debug.print("Error: {}\n", .{err});
    break :blk 0;
};
```

### anyerror
Global error set — can hold any error value:
```zig
fn myFn() anyerror!void { ... }
```

### Merging Error Sets
```zig
const Full = FileError || NetworkError;
```

### Inferred Error Sets
Use `!` without explicit error set to have Zig infer it:
```zig
fn myFn() !void { ... }
// Zig infers the full error set from all `return error.X` in the function
```

### Error Return Traces
In Debug/ReleaseSafe modes, error return traces show the path errors took through the call stack.

---

## Optionals

A type that can be null: `?T`

```zig
var maybe: ?i32 = null;
maybe = 5;

// Unwrap with orelse:
const val = maybe orelse 0; // 0 if null, otherwise the value

// Unwrap with .? (panics if null):
const val2 = maybe.?;

// if/while capture:
if (maybe) |v| {
    std.debug.print("{d}\n", .{v});
}
```

Optional pointers have the same size as non-optional pointers (uses null address as sentinel).

---

## Casting

### Type Coercion (Implicit)
Zig implicitly coerces when safe:
- Wider integer types accept narrower integers (e.g., `i32` from `i8`)
- Const pointers from non-const
- Optional from non-optional value
- Error unions from non-error value

### Explicit Casts
| Builtin | Description |
|---------|-------------|
| `@as(T, val)` | Safe cast, must be representable |
| `@intCast(val)` | Integer cast (safety checked) |
| `@floatCast(val)` | Float narrowing (safety checked) |
| `@intFromFloat(val)` | Float to int (truncates, safety checked) |
| `@floatFromInt(val)` | Int to float |
| `@ptrCast(ptr)` | Pointer type cast |
| `@alignCast(ptr)` | Assert stronger alignment |
| `@constCast(ptr)` | Remove const |
| `@volatileCast(ptr)` | Remove volatile |
| `@bitCast(val)` | Reinterpret bits |
| `@truncate(val)` | Truncate integer to smaller type |
| `@enumFromInt(val)` | Integer to enum |
| `@intFromEnum(val)` | Enum to integer |
| `@errorFromInt(val)` | Integer to error |
| `@intFromError(val)` | Error to integer |

---

## comptime

Zig uses `comptime` instead of macros or templates. Code marked `comptime` executes at compile time.

```zig
fn fibonacci(comptime n: u32) u32 {
    if (n <= 1) return n;
    return fibonacci(n - 1) + fibonacci(n - 2);
}

const result = fibonacci(10); // computed at compile time
```

### comptime Variables
```zig
comptime var x: i32 = 0;
x += 1; // executed at compile time
```

### comptime Blocks
```zig
const TypeList = comptime blk: {
    var list: [3]type = undefined;
    list[0] = i32;
    list[1] = f32;
    list[2] = bool;
    break :blk list;
};
```

### Generic Data Structures
Implement generics using functions returning types:
```zig
fn Stack(comptime T: type) type {
    return struct {
        items: []T,
        head: usize = 0,

        const Self = @This();

        pub fn push(self: *Self, item: T) void { ... }
        pub fn pop(self: *Self) ?T { ... }
    };
}

const IntStack = Stack(i32);
var stack = IntStack{ .items = &[_]i32{} };
```

### Type Reflection at comptime
```zig
fn printTypeInfo(comptime T: type) void {
    const info = @typeInfo(T);
    switch (info) {
        .Struct => |s| {
            inline for (s.fields) |field| {
                std.debug.print("Field: {s}\n", .{field.name});
            }
        },
        else => {},
    }
}
```

### Case Study: print in Zig
`std.debug.print` is implemented using comptime:
```zig
pub fn print(comptime fmt: []const u8, args: anytype) void {
    // At compile time: parse fmt string and check arg types
    // At runtime: format and print
}
```

---

## Assembly

Inline assembly:
```zig
fn rdtsc() u64 {
    return asm volatile ("rdtsc"
        : [ret] "={eax}" (-> u32),
        :
        : "edx"
    );
}
```

Global assembly (outside any function):
```zig
comptime {
    asm (
        \\.globl my_asm_fn
        \\.type my_asm_fn, @function
        \\my_asm_fn:
        \\  ret
    );
}
```

---

## Atomics

```zig
const std = @import("std");
const AtomicOrder = std.builtin.AtomicOrder;

var atomic_val: i32 = 0;

// Load
const v = @atomicLoad(i32, &atomic_val, .SeqCst);
// Store
@atomicStore(i32, &atomic_val, 1, .SeqCst);
// RMW (read-modify-write)
const old = @atomicRmw(i32, &atomic_val, .Add, 1, .SeqCst);
// CAS
const success = @cmpxchgStrong(i32, &atomic_val, expected, new_val, .SeqCst, .SeqCst);
```

Atomic memory orders: `.Unordered`, `.Monotonic`, `.Acquire`, `.Release`, `.AcqRel`, `.SeqCst`

---

## Builtin Functions Reference

All builtins start with `@`. Key builtins:

### Type Builtins
| Builtin | Description |
|---------|-------------|
| `@TypeOf(expr)` | Get type of expression |
| `@typeInfo(T)` | Get `std.builtin.Type` union with type info |
| `@typeName(T)` | Get name of type as `[]const u8` |
| `@hasDecl(T, "name")` | Check if type has a declaration |
| `@hasField(T, "name")` | Check if type has a field |
| `@field(obj, "name")` | Access field by name string |
| `@fieldParentPtr("field", ptr)` | Get parent struct from field pointer |
| `@FieldType(T, "field")` | Get type of a struct field |
| `@This()` | Reference to the innermost struct/enum/union |
| `@import("path")` | Import a file or package |
| `@sizeOf(T)` | Size of type in bytes |
| `@bitSizeOf(T)` | Size of type in bits |
| `@alignOf(T)` | Alignment of type in bytes |
| `@offsetOf(T, "field")` | Byte offset of struct field |
| `@bitOffsetOf(T, "field")` | Bit offset of struct field |

### Cast Builtins
| Builtin | Description |
|---------|-------------|
| `@as(T, val)` | Type-assert cast |
| `@intCast(val)` | Checked integer narrowing |
| `@floatCast(val)` | Checked float narrowing |
| `@truncate(val)` | Truncate integer bits |
| `@bitCast(val)` | Reinterpret bits |
| `@ptrCast(ptr)` | Pointer type change |
| `@alignCast(ptr)` | Assert stronger alignment |
| `@constCast(ptr)` | Remove const qualifier |
| `@intFromFloat(val)` | Float to int |
| `@floatFromInt(val)` | Int to float |
| `@intFromPtr(ptr)` | Pointer to integer |
| `@ptrFromInt(val)` | Integer to pointer |
| `@intFromBool(b)` | Bool to integer (0 or 1) |
| `@intFromEnum(e)` | Enum to integer |
| `@enumFromInt(val)` | Integer to enum |
| `@intFromError(e)` | Error to integer |
| `@errorFromInt(val)` | Integer to error |
| `@errorCast(err)` | Cast error to narrower error set |
| `@addrSpaceCast(ptr)` | Change address space of pointer |

### Math Builtins
| Builtin | Description |
|---------|-------------|
| `@abs(val)` | Absolute value |
| `@min(a, b)` | Minimum of two values |
| `@max(a, b)` | Maximum of two values |
| `@sqrt(val)` | Square root |
| `@sin(val)` | Sine |
| `@cos(val)` | Cosine |
| `@tan(val)` | Tangent |
| `@exp(val)` | e^x |
| `@exp2(val)` | 2^x |
| `@log(val)` | Natural log |
| `@log2(val)` | Log base 2 |
| `@log10(val)` | Log base 10 |
| `@floor(val)` | Round down |
| `@ceil(val)` | Round up |
| `@trunc(val)` | Truncate toward zero |
| `@round(val)` | Round to nearest |
| `@mulAdd(T, a, b, c)` | Fused multiply-add |

### Overflow-Checked Arithmetic
| Builtin | Description |
|---------|-------------|
| `@addWithOverflow(a, b)` | Returns `{result, overflow_bit}` |
| `@subWithOverflow(a, b)` | Returns `{result, overflow_bit}` |
| `@mulWithOverflow(a, b)` | Returns `{result, overflow_bit}` |
| `@shlWithOverflow(a, b)` | Returns `{result, overflow_bit}` |

### Exact Arithmetic (panics on overflow)
| Builtin | Description |
|---------|-------------|
| `@divExact(a, b)` | Divide, panic if remainder |
| `@divFloor(a, b)` | Floor division |
| `@divTrunc(a, b)` | Truncating division |
| `@mod(a, b)` | Modulo (sign follows divisor) |
| `@rem(a, b)` | Remainder (sign follows dividend) |
| `@shlExact(a, b)` | Shift left, panic if bits lost |
| `@shrExact(a, b)` | Shift right, panic if bits lost |

### Bit Manipulation
| Builtin | Description |
|---------|-------------|
| `@clz(val)` | Count leading zeros |
| `@ctz(val)` | Count trailing zeros |
| `@popCount(val)` | Count set bits |
| `@byteSwap(val)` | Reverse bytes |
| `@bitReverse(val)` | Reverse bits |

### Vector Builtins
| Builtin | Description |
|---------|-------------|
| `@Vector(len, T)` | Create vector type |
| `@splat(val)` | Broadcast scalar to vector |
| `@shuffle(T, a, b, mask)` | Permute/blend two vectors |
| `@select(T, pred, a, b)` | Element-wise conditional select |
| `@reduce(.Op, vec)` | Horizontal reduction |

### C Interop Builtins
| Builtin | Description |
|---------|-------------|
| `@cImport(block)` | Import C headers |
| `@cInclude("header.h")` | Include C header (inside `@cImport`) |
| `@cDefine("name", "value")` | Define C macro |
| `@cUndef("name")` | Undef C macro |
| `@cVaStart()` | Start variadic args |
| `@cVaArg(va, T)` | Get next variadic arg |
| `@cVaCopy(va)` | Copy va_list |
| `@cVaEnd(va)` | End variadic args |

### Miscellaneous Builtins
| Builtin | Description |
|---------|-------------|
| `@compileError("msg")` | Fail compilation with message |
| `@compileLog(vals...)` | Log at compile time |
| `@panic("msg")` | Runtime panic |
| `@trap()` | Trap/illegal instruction |
| `@breakpoint()` | Insert debugger breakpoint |
| `@returnAddress()` | Return address of current fn |
| `@frameAddress()` | Frame address (EBP/RBP) |
| `@inComptime()` | Is current code comptime? |
| `@call(modifier, fn, args)` | Call with modifier (.never_inline, etc.) |
| `@src()` | Source location (file, line, fn) |
| `@tagName(enum_val)` | Get enum variant name as string |
| `@unionInit(T, field, val)` | Initialize union by field name |
| `@embedFile("path")` | Embed file as `[]const u8` at comptime |
| `@export(symbol, options)` | Export symbol |
| `@extern(T, options)` | Declare external symbol |
| `@setEvalBranchQuota(n)` | Increase comptime eval limit |
| `@setFloatMode(.optimized)` | Set float mode for current fn |
| `@setRuntimeSafety(enabled)` | Enable/disable runtime safety |
| `@prefetch(ptr, options)` | Prefetch memory |
| `@memcpy(dst, src)` | Copy memory |
| `@memset(dst, val)` | Set memory |
| `@memmove(dst, src)` | Move memory (overlapping safe) |
| `@workGroupId(dim)` | GPU work group ID |
| `@workGroupSize(dim)` | GPU work group size |
| `@workItemId(dim)` | GPU work item ID |
| `@wasmMemorySize(idx)` | WASM memory size |
| `@wasmMemoryGrow(idx, n)` | Grow WASM memory |

### Introspection Type Constructors
| Builtin | Description |
|---------|-------------|
| `@Int(signedness, bits)` | Create integer type |
| `@Tuple(types)` | Create tuple type |
| `@Pointer(info)` | Create pointer type |
| `@Fn(info)` | Create function type |
| `@Struct(info)` | Create struct type |
| `@Union(info)` | Create union type |
| `@Enum(info)` | Create enum type |
| `@EnumLiteral()` | Type of enum literals |
| `@errorReturnTrace()` | Get current error return trace |

---

## Build Mode

| Mode | Speed | Safety | Binary Size |
|------|-------|--------|-------------|
| `Debug` | Slow | On | Large |
| `ReleaseSafe` | Fast | On | Medium |
| `ReleaseFast` | Fastest | Off | Medium |
| `ReleaseSmall` | Fast | Off | Smallest |

Set with: `zig build-exe -O ReleaseFast file.zig`

---

## Illegal Behavior

In **safe** build modes (Debug, ReleaseSafe), these cause a **panic**:
- Reaching `unreachable` code
- Array/slice index out of bounds
- Integer overflow
- Casting a negative number to unsigned
- Truncating data in a cast
- Division or remainder by zero
- Exact division has remainder (`@divExact`)
- Exact shift loses bits (`@shlExact`, `@shrExact`)
- Attempting to unwrap `null` (`opt.?`)
- Attempting to unwrap an error (`try` on error)
- Invalid error code
- Invalid enum cast
- Wrong union field access
- Out-of-bounds float-to-integer cast
- Pointer cast through invalid null

In **unsafe** modes (ReleaseFast, ReleaseSmall), these are **undefined behavior**.

---

## Memory

Zig has no hidden allocations. Every allocation must go through an explicit `std.mem.Allocator`.

### Allocator Interface
```zig
const std = @import("std");
const Allocator = std.mem.Allocator;

fn myFn(allocator: Allocator) !void {
    const data = try allocator.alloc(u8, 100);
    defer allocator.free(data);
    // use data
}
```

### Choosing an Allocator
| Allocator | Use Case |
|-----------|----------|
| `std.heap.page_allocator` | Simple; allocates full pages from OS |
| `std.heap.GeneralPurposeAllocator(.{})` | Debug/test; detects leaks |
| `std.heap.ArenaAllocator` | Free all at once; efficient for parse/build |
| `std.heap.FixedBufferAllocator` | Stack-based, no heap needed |
| `std.heap.c_allocator` | Uses C malloc/free |

```zig
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
defer _ = gpa.deinit();
const allocator = gpa.allocator();
```

### Arena Allocator Pattern
```zig
var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
defer arena.deinit(); // frees everything at once
const allocator = arena.allocator();
```

### Heap Allocation Failure
All `allocator.alloc()` and similar calls return `!T`. Always handle `error.OutOfMemory`.

### Recursion
Zig has no guaranteed tail call optimization. Deep recursion can overflow the stack. Use iteration where possible.

### Lifetime and Ownership
Zig has no GC or borrow checker. The programmer is responsible for:
- Not using memory after freeing it
- Not freeing memory more than once
- Ensuring returned pointers remain valid

---

## Compile Variables

Access compile-time info through `@import("builtin")`:
```zig
const builtin = @import("builtin");

const target = builtin.target;      // std.Target
const os = builtin.os.tag;          // std.Target.Os.Tag
const cpu = builtin.cpu.arch;       // std.Target.Cpu.Arch
const mode = builtin.mode;          // std.builtin.OptimizeMode
const is_test = builtin.is_test;    // bool
const zig_version = builtin.zig_version; // std.SemanticVersion
```

---

## Compilation Model

### Source File Structs
Each `.zig` file is an implicit `struct`. Declarations inside it are fields/members:
```zig
// math.zig
pub fn add(a: i32, b: i32) i32 { return a + b; }
pub const PI = 3.14159;
```

```zig
// main.zig
const math = @import("math.zig");
const sum = math.add(1, 2);
const pi = math.PI;
```

### Special Root Declarations
In the root file (main entry point), these are recognized:
- `pub fn main()` or `pub fn main(init: std.process.Init)` — program entry point
- `pub fn panic(...)` — custom panic handler
- `pub const std_options` — configure std library behavior

### Entry Point
```zig
// Simple: no init
pub fn main() void { ... }
// With error handling:
pub fn main() !void { ... }
// With init (for I/O context):
pub fn main(init: std.process.Init) !void { ... }
```

---

## Zig Build System

Zig has a built-in build system. `build.zig` describes how to build your project:
```zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "my-app",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
```

Run:
```
$ zig build          # build
$ zig build run      # build and run
$ zig build test     # run tests
```

---

## C Interoperability

### C Type Primitives
- `c_char`, `c_short`, `c_ushort`, `c_int`, `c_uint`, `c_long`, `c_ulong`
- `c_longlong`, `c_ulonglong`, `c_longdouble`
- `c_void` (use `anyopaque` instead)

### Import from C Header File
```zig
const c = @cImport({
    @cInclude("stdio.h");
    @cInclude("stdlib.h");
});

pub fn main() void {
    _ = c.printf("Hello from C!\n");
}
```

### C Translation CLI
```
$ zig translate-c myheader.h > myheader.zig
```

### C Pointers
Type `[*c]T` — analogous to C's `T*` (may be null, pointer arithmetic allowed):
```zig
extern fn strlen(s: [*c]const u8) usize;
```

### C Variadic Functions
```zig
extern fn printf(format: [*c]const u8, ...) c_int;
```
Implement variadic in Zig using `@cVaStart`, `@cVaArg`, `@cVaEnd`.

### Exporting a C Library
```zig
export fn add(a: i32, b: i32) i32 {
    return a + b;
}
```

Build as shared library:
```
$ zig build-lib mylib.zig -dynamic
```

### Mixing Object Files
```
$ zig build-exe main.zig mylib.o -lc
```

---

## WebAssembly

### Freestanding WASM
```zig
// No stdlib dependency
export fn add(a: i32, b: i32) i32 {
    return a + b;
}
```

Build:
```
$ zig build-exe main.zig -target wasm32-freestanding -fno-entry
```

### WASI (WebAssembly System Interface)
```
$ zig build-exe main.zig -target wasm32-wasi
$ wasmtime main.wasm
```

---

## Targets

Zig supports cross-compilation to many targets:
```
$ zig targets  # list all supported targets
$ zig build-exe main.zig -target x86_64-linux-gnu
$ zig build-exe main.zig -target aarch64-macos
$ zig build-exe main.zig -target wasm32-wasi
$ zig build-exe main.zig -target arm-freestanding-eabi
```

---

## Style Guide

### Naming Conventions
| Item | Convention | Example |
|------|-----------|---------|
| Types | `TitleCase` | `MyStruct`, `MyEnum` |
| Functions | `camelCase` | `myFunction()` |
| Variables | `snake_case` | `my_variable` |
| Constants | `SCREAMING_SNAKE_CASE` (per-team preference; Zig itself uses snake) | `MAX_SIZE` or `max_size` |
| Namespaces | `snake_case` | `std.mem`, `std.fs` |

### Whitespace Rules
- 4 spaces for indentation (no tabs)
- Opening brace on same line
- One blank line between top-level declarations

### Avoid Redundancy
```zig
// Bad: redundant typename in namespace
const MyList = struct {
    MyList_head: *MyList_Node, // don't prefix with type name
};

// Good:
const MyList = struct {
    head: *Node,
};
```

---

## Source Encoding

Zig source files must be valid UTF-8. The compiler accepts any Unicode in string literals and comments.

---

## Keyword Reference

| Keyword | Description |
|---------|-------------|
| `addrspace` | Specify address space for pointer |
| `align` | Alignment specifier |
| `allowzero` | Allow zero address in pointer |
| `and` | Logical AND (short-circuit) |
| `anyframe` | Async frame type |
| `anytype` | Parameter type inferred at call site |
| `asm` | Inline assembly |
| `async` | Declare async fn (currently experimental) |
| `await` | Await async fn |
| `break` | Exit loop or labeled block |
| `callconv` | Calling convention |
| `catch` | Handle error union |
| `comptime` | Compile-time execution |
| `const` | Immutable variable or comptime-required parameter |
| `continue` | Skip to next loop iteration |
| `defer` | Execute at block exit |
| `else` | Alternative branch |
| `enum` | Enumeration type |
| `errdefer` | Execute at block exit if error |
| `error` | Error value |
| `export` | Export symbol (C ABI) |
| `extern` | External linkage |
| `fn` | Function declaration |
| `for` | For loop |
| `if` | Conditional |
| `inline` | Inline function or loop |
| `linksection` | Put symbol in specific section |
| `noalias` | Pointer non-aliasing hint |
| `noinline` | Prevent inlining |
| `nosuspend` | Assert no suspending |
| `opaque` | Opaque type |
| `or` | Logical OR (short-circuit) |
| `orelse` | Unwrap optional with fallback |
| `packed` | Packed struct/union |
| `pub` | Public visibility |
| `resume` | Resume suspended async fn |
| `return` | Return from function |
| `struct` | Structure type |
| `suspend` | Suspend async fn |
| `switch` | Switch statement/expression |
| `test` | Test block |
| `threadlocal` | Thread-local variable |
| `try` | Propagate error |
| `union` | Union type |
| `unreachable` | Assert unreachable code |
| `usingnamespace` | Import namespace into current scope |
| `var` | Mutable variable |
| `volatile` | Volatile memory access |
| `while` | While loop |

---

## Appendix: Grammar Overview

Zig grammar is available at: https://ziglang.org/documentation/master/#Grammar

Key grammar rules:
- Declarations at top level: `const`, `var`, `fn`, `test`, `comptime`, `usingnamespace`
- Expressions: primary, suffix, prefix, binary ops
- Statements: assignment, loop, conditional, defer, etc.
- Types: builtin, array, slice, pointer, optional, error union, function pointer

---

## Zig Zen

1. Communicate intent precisely.
2. Edge cases matter.
3. Favor reading code over writing code.
4. Only one obvious way to do things.
5. Runtime crashes are better than bugs.
6. Compile errors are better than runtime crashes.
7. Incremental improvements.
8. Avoid local maximums.
9. Reduce the amount one must remember.
10. Focus on code rather than style.
11. Resource allocation may fail; resource deallocation must succeed.
12. Memory is a resource.
13. Together we serve the users.
