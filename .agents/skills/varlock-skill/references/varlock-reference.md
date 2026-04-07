<SYSTEM>This is the full developer documentation for varlock</SYSTEM>

# Best Practices for using @env-spec

> Recommended best practices for writing .env files with @env-spec

While the parser itself is fairly flexible to maintain backwards-compatibility, we recommend some best practices if you are writing a new .env file or cleaning up an existing one.

* Only use triple quotes for multi-line strings. Either backticks or double quotes are fine, but stay consistent.
* Only use unwrapped values for simple strings that do not contain any spaces or special characters.
* Single quotes do not support expansion, so use them if an item contains $ characters you do not want expanded.
* Stay consistent with quote usage in general
* Be generous with descriptions, unless it is totally obvious
* Add documentation links wherever possible
* For ref expansion, always use brackets - `` GOOD=`pre-${OTHERVAR}` `` `BAD=pre-$OTHERVAR`
* use `# --- dividers ---` to organize sections of related items
* Make all keys `ALL_CAPS`, and don’t use any ”-” or ”.”
* Don’t use extra whitespace around item definitions (ex: `KEY="good!"` `KEY = "bad!"`)
* Don’t use optional `export` prefix

# About @env-spec

> Understanding the env-spec specification and how varlock implements it

Contribute to @env-spec

The `@env-spec` specification is currently in development. If you’d like to contribute, please join the [discussion](https://github.com/dmno-dev/varlock/discussions/17) in the RFC on GitHub.

## Overview

[Section titled “Overview”](#overview)

@env-spec is a DSL that extends normal `.env` syntax. It allows adding structured metadata using `@decorator` style comments (similar to [JSDoc](https://jsdoc.app/)) and a syntax for setting values via explicit function calls.

This lets us express a declarative schema of our environment variables in a familiar format, not tied to any specific programming language or framework.

### A short example:

[Section titled “A short example:”](#a-short-example)

.env.schema

```env-spec
# Stripe secret api key
# @required @sensitive @type=string(startsWith="sk_")
# @docsUrl=https://docs.stripe.com/keys
STRIPE_SECRET_KEY=encrypted("asdfqwerqwe2374298374lksdjflksdjf981273948okjdfksdl")
```

### Why is this useful?

[Section titled “Why is this useful?”](#why-is-this-useful)

Loading a schema file full of structured metadata gives us:

* additional validation, coercion, type-safety for your env vars
* extra guard-rails around handling of `@sensitive` data
* more flexible loading logic without hand-rolled application code or config files
* a place to store default values, clearly differentiated from placeholders

This schema information is most valuable when it is **shared across team members** and machines. So in most cases, this means creating a git-committed `.env.schema` file, instead of the familiar `.env.example` file used by many projects. The difference is that now the schema can be used on an ongoing basis, instead of just once to create an untracked local copy.

Building on this, you could use additional files which set values. They could add additional items or override properties of existing ones. Whether you want to use a single git-ignored `.env` file, or apply a cascade of environment-specific files (e.g., `.env`, `.env.local`, `.env.test`, etc) is up to you. However the new ability to use function calls to safely decrypt data, or load values from external sources, means you’ll likely be tempted to use git-committed `.env` files much more.

An env-spec enabled tool would load all env files appropriately, merging together both schema and values, as well as additional values read from the shell/process. Then the schema would be applied which could transform and fill values, for example decrypting or fetching from an external source, as well as applying coercion and validation.

Backwards compatibility

This is designed to be mostly backwards compatible with traditional .env files. However, as there is no standard .env spec and various tools have different rules and features, we made some decisions to try to standardize things. Our tools may support additional compatibility flags if users want to opt in/out of specific behaviours that match other legacy tools.

The extended feature set means an env-spec enabled parser will successfully parse env files that other tools may not.

### What is included in env-spec?

[Section titled “What is included in env-spec?”](#what-is-included-in-env-spec)

This package defines a parser and related tools for parsing an @env-spec enabled .env file. It does not provide anything past this parsing step, such as actually loading environment variables.

### Why did we create this?

[Section titled “Why did we create this?”](#why-did-we-create-this)

We previously created DMNO and saw immense value in this schema-driven approach to configuration. With env-spec, we wanted to provide a standard that could benefit anyone who uses .env files (and even those who don’t!). There’s an incredible ecosystem of libraries and tools that have adopted .env, and we want to make it easier for everyone to benefit from additional guardrails, with as little upfront work as possible.

We’ve also seen the explosion of AI-assisted coding tools which means that users are even more likely to leak sensitive configuration items, like API keys. If we can help to improve the security posture for these users, then hopefully that improves things for everyone. How can I help? If you’re a maintainer, author, contributor, or an opinionated user of tools that rely on .env files, please read through our RFC. We are not trying to build in a vacuum and we want your input. We’d also love your feedback on varlock which is built on top of @env-spec since it provides (we hope!) a solid reference implementation.

*If this resonates with you, please reach out. We welcome your feedback and we welcome additional contributors.*

***

# @env-spec Reference

> Reference docs and details for @env-spec

Tip

In this spec, we don’t make any assumptions about the meaning of specific decorators, or function calls. This document just deals with how the syntax itself is parsed and structured.

## Config Items

[Section titled “Config Items”](#config-items)

Config items define individual env vars.

* Each has a key, an optional value, and optional attached comments
* Keys must start with `[a-ZA-Z_]`, followed by any of `[a-ZA-Z0-9_]` — ✅ `SOME_ITEM`, ❌ `BAD-KEY`, ❌ `2BAD_KEY`
* Setting no value is allowed and will be treated as `undefined` — `UNDEF_VAR=`
  * note that no value (`ITEM=`) is treated slightly differently than an explicit `ITEM=undefined` when combining multiple definitions
* An explicit empty string is allowed — `EMPTY_STRING_VAR=""`
* Single-line values may be wrapped in quotes or not, and will follow the common value-handling rules (see below)
* Multi-line string values may be wrapped in either `( ' | " | """ | ``` )` - but we **strongly** recommend using triple backticks only for consistency

````env-spec
NO_VALUE=
EXPLICIT_UNDEFINED=undefined
EMPTY_STRING=""
UNQUOTED=asdf
QUOTED="asdf"
FUNCTION_CALL=fn(foo, "bar")
MULTILINE_STRING=```
multiple
lines
```
````

## Comments and @decorators

[Section titled “Comments and @decorators”](#comments-and-decorators)

Comments in env-spec (like traditional .env files) start with a `#`. Unlike traditional .env files, comments may contain additional metadata by using `@decorators`, which may be attached to specific config items, sections, or the entire document.

* Comments can be either on their own line, or at the end of a line after something else
* Leading whitespace after the `#` is optional, but a single space is recommended
* If a comment line starts with a @decorator, it will be considered a *decorator comment line*
* Otherwise it is a *regular comment line* and any contained @decorators will be ignored
* A decorator comment line may contain multiple decorators
* A decorator comment line may end with an additional comment, in which decorators will be ignored
* A post-value comment may also contain decorators, but is not recommended

```env-spec
   # ❌ leading space makes this invalid
# this is a regular comment line
# @dec2 @dec2=foo # this is a decorator comment line
FOO=val # this is a post-value comment
BAR=val # @dec # post-value comments may also contain decorators


# regular comment lines @ignore contained @decorators
# @dec # as are @decorators within an extra comment after a decorator comment line
BAZ= # @dec # this is @ignored too
```

### Decorators

[Section titled “Decorators”](#decorators)

Decorators are used within comments to attach structured data to specific config items, or within a standalone comment block to alter a group of items or the entire document and loading process.

* Each decorator has a name and optional value (`@name=value`) or is a bare function call `@func()`
* Decorators with values may only be used once per comment block, while function calls may be used multiple times
* Using the name only is equivalent to setting the value to true — `@required` === `@required=true`
* Multiple decorators may be specified on the same line
* Decorator values will be parsed using the common value-handling rules (see below)

.env.schema

```env-spec
# @willBeTrue @willBeFalse=false @explicitTrue=true @undef=undefined @trueString="true"
# @int=123 @float=123.456 @willBeString=123.456.789
# @doubleQuoted="with spaces" @singleQuote='hi' @backTickQuote=`hi`
# @unquoted=this-works-too @withNewline="new\nline"
# @funcCallNoArgs=func() @dec=funcCallArray(val1, "val2") @dec=funcCallObj(k1=v1, k2="v2")
# @anotherOne # and some comments, this @decorator is ignored
# this is a comment and this @decorator is ignored
```

### Dividers

[Section titled “Dividers”](#dividers)

A divider is a comment that serves as a separator, like a `<hr/>` in HTML.

* A comment starting with `---` or `===` is considered a divider — `# ---`, `# ===`
* A *single* leading whitespace is optional (but recommended — `# ---`, `#---` )
* Anything after that is ignored and valid — `# --- some info`, `# ------------`

```env-spec
# the header comment block (see below) must end with a divider
# ---
ITEM1=
ITEM2=
# --- another divider ---
ITEM3=
```

### Config Item Comments

[Section titled “Config Item Comments”](#config-item-comments)

Comment lines directly preceeding an item will be attached to that item, along with the decorators contained within.

* A blank line or a divider will break the above comments from being attached to the item below
* Both decorator and regular comment lines may be interspersed
* Post-value comments may also contain decorators, but should be used sparingly

```env-spec
# these comments are attached to ITEM1 below
# @dec1 @dec2 # meaning these decorators will affect the item
# additional comments can be interspersed with decorators
ITEM1= # @dec3 # and a post-value comment can be used too


# not attached due to blank line


# also not attached due to divider
# ---
ITEM2=
```

### Comment blocks & document header

[Section titled “Comment blocks & document header”](#comment-blocks--document-header)

A comment block is a group of continuous comments that is not attached to a specific config item.

* The comment block is ended by an empty line, a divider, or the end of the file
* A comment block that is the first element of the document and ends with a divider is the *document header*
* Decorators from this header can be used to configure all contained elements, or the loading process itself

```env-spec
# this is the document header and usually contains root decorators
# which affect default settings and the behavior of the tool that will be parsing this file
# @dec1 @dec2
# ---


# this is another comment block
# and is not attached to an item


# this comment is attached to the item below
ITEM1=
```

## Common rules

[Section titled “Common rules”](#common-rules)

### Value handling

[Section titled “Value handling”](#value-handling)

Values are interpreted similarly for config item values, decorator values, and values within function call arguments. Values may be wrapped in quotes or not, but handling varies slightly:

#### Unquoted values

[Section titled “Unquoted values”](#unquoted-values)

* Will coerce `true`, `false`, `undefined` — `@foo=false`

* Will coerce numeric values — `@int=123 @float=123.456`
  * if the number is too large, would lose precision, or would change formatting, it will remain a string

* May be interpreted as a function call (see below)

* Otherwise will be treated as a string

* May not contain other characters depending on the context:

  * config item values - may not contain `#`
  * decorator values - may not contain `[ #]`
  * function call arg values - may not contain `[),]`

#### Quoted values

[Section titled “Quoted values”](#quoted-values)

* A value in quotes is *always* treated as a string — `@d1="with spaces"`, `@trueString="true"`, `@numStr="123"`
* All quote styles ``[`'"]`` are ok — ``@dq="c" @bt=`b` @sq='a'``
* Escaped quotes matching the wrapping quote style are ok — `@ok="escaped\"quote"`
* Single quote wrapped strings do not support [expansion (see below)](#expansion)
* In `"` or `` ` `` wrapped values, the string `\n` will be converted to an actual newline
* Multi-line strings may be wrapped in `(```|"""|"|')`
  * only available for config item values, not decorators or within function args

### Function calls

[Section titled “Function calls”](#function-calls)

Function calls may be used for item values `ITEM=fn()`, decorator values `# @dec=fn()`, and bare decorator functions `# @func()`. In each case, much of the handling is the same.

* a value must not be wrapped in quotes to be interpreted as a function call
* function names must start with a letter, and can then contain letters, numbers, and underscores `/[a-ZA-Z][a-ZA-Z0-9_]*/`
* you can pass no args, a single arg, or multiple args
* you may also pass key value pairs at the end of the list
* each value will be interpreted using common value-handling rules (see above)

```env-spec
NO_ARGS=fn()
SINGLE_ARG=fn(asdf)
MULTIPLE_ARGS=fn(one, "two", three, 123.456)
KEY_VALUE_ARGS=fn(key1=v1, key2="v2", key3=true)
MIXED_ARGS=fn(item1, item2, key1=v1, key2="v2", key3=true)
NOT_FN_CALL="fn()" # treated as string
```

### String expansion

[Section titled “String expansion”](#expansion)

While the parser itself does not include any implemention of specific functions, it does handle *expansion* of strings - and it uses several function calls under the hood to do so. This means a few basic function calls, while not implemented, have specific inherent meaning and must be implemented similarly across all tools that support this spec.

Expansion can be used within item values, decorator values, and function call arguments.

*Note that single quote wrapped strings are NOT expanded.*

* `$ITEM_NAME` -> `ref(ITEM_NAME)`
* `${ITEM_NAME}` -> `ref(ITEM_NAME)`
* `pre${ITEM_NAME}post` -> `concat("pre", ref(ITEM_NAME), "post")`
* `${ITEM_NAME:-defaultval}` -> `fallback(ref(ITEM_NAME), "defaultval")`
* `${ITEM_NAME-defaultval}` -> `fallback(ref(ITEM_NAME), "defaultval")`
* `$(my-cli arg --arg2)` -> `exec("my-cli arg --arg2")`

Keep it simple

We recommend using expansion only for simple refs `$ITEM`/`${ITEM}` and skipping the rest.

* Use bracketed version within a larger string - `fn("${ENV}_db")`
* Skip the brackets otherwise - `fn($ENV)`

The rest is implemented to match other popular tools, but we do not recommend using them, as intent can be more clearly expressed using function calls directly.

# @env-spec VS Code extension

> Syntax highlighting and tooling for @env-spec enabled .env files

The @env-spec VS Code and Open VSX extensions provide language support for @env-spec enabled .env files.

## Installation

[Section titled “Installation”](#installation)

The extension is available on the [VS Code Marketplace](https://marketplace.visualstudio.com/items?itemName=varlock.env-spec-language) and [Open VSX Registry](https://open-vsx.org/extension/varlock/env-spec-language) for those who use VS Code forks like Cursor and Windsurf.

## Features

[Section titled “Features”](#features)

* Syntax highlighting
* Hover info for common @decorators
* Comment continuation - automatically continue comment blocks when you hit enter within one

## How to use this extension

[Section titled “How to use this extension”](#how-to-use-this-extension)

The new @env-spec language mode should be enabled automatically for any .env and .env.\* files, but you can always set it via the Language Mode selector in the bottom right of your editor.

# Installation

> How to install and set up Varlock in your project

There are two ways to install `varlock`:

1. Install as a `package.json` dependency in JavaScript/TypeScript projects
2. Install as a standalone binary

## As a JavaScript/TypeScript dependency

[Section titled “As a JavaScript/TypeScript dependency”](#as-a-javascripttypescript-dependency)

Requires:

* Node.js version 22 or higher

### Installation

[Section titled “Installation”](#installation)

To install `varlock` in your project, run:

* npm

  ```bash
  npx varlock init
  ```

* pnpm

  ```bash
  pnpm dlx varlock init
  ```

* bun

  ```bash
  bunx varlock init
  ```

* vlt

  ```bash
  vlx varlock init
  ```

* yarn

  ```bash
  yarn dlx varlock init
  ```

This will install `varlock` as a dependency and scan your project for `.env` files and create a `.env.schema` file in the root of your project. Depending on your project configuration, it will optionally:

* Remove your existing `.env.example` file
* Add decorators to your `.env.schema` file to specify the type of each environment variable

## As a standalone binary

[Section titled “As a standalone binary”](#as-a-standalone-binary)

To install `varlock` CLI as a binary, run:

```bash
# Install via homebrew
brew install dmno-dev/tap/varlock


# OR via cURL
curl -sSfL https://varlock.dev/install.sh | sh -s
```

Then run the setup wizard to help you get started:

```bash
varlock init
```

You can then run `varlock --help` to see the available commands or read the [CLI Reference](/reference/cli-commands/).

## Docs MCP

[Section titled “Docs MCP”](#docs-mcp)

If you prefer to let AI tools do the heavy lifting, you can use the Docs MCP server. See more details [here](/guides/mcp/#docs-mcp).

# Introduction

> Introduction to Varlock - the AI-safe env var toolkit for validating, securing, and sharing your environment variables

Varlock is a universal configuration/secrets/environment variable management tool built on top of the [@env-spec](/env-spec/overview/) specification. It provides a comprehensive set of features out of the box that simplify managing, validating, and securing your environment configuration. Whether you need type-safe environment variables, multi-environment management, secure secret handling, or leak prevention, Varlock lets you focus on building your application instead of wrestling with configuration. While it is written in TypeScript, it is language and framework agnostic, and meant to be used in any project that needs configuration at build or boot time, usually passed in via environment variables.

## Features

[Section titled “Features”](#features)

Varlock aims to be the most comprehensive environment variable management tool. It provides a wide range of features out of the box:

* **[AI-Safe Config](/guides/ai-tools/)** - Your `.env.schema` gives AI agents full context on your config without ever exposing secret values. Prevent leaks to AI servers by design, and scan for leaked secrets with `varlock scan`
* **[Security](/guides/secrets/)** - Automatic log redaction for sensitive values, leak detection in bundled code and server responses, and proactive scanning via `varlock scan`
* **[Validation & Type Safety](/reference/data-types/)** - Powerful validation capabilities with clear error messages, plus automatic type generation for IntelliSense support
* **[Secure Secrets](/guides/secrets/)** - Load secrets from 6 provider plugins ([1Password](/plugins/1password/), [Infisical](/plugins/infisical/), [AWS](/plugins/aws-secrets/), [Azure](/plugins/azure-key-vault/), [GCP](/plugins/google-secret-manager/), [Bitwarden](/plugins/bitwarden/)) or any CLI tool using [exec()](/reference/functions/#exec)
* **[Multi-Environment Management](/guides/environments/)** - Flexible environment handling with support for environment-specific files, local overrides, and value composition
* **[Value Composition](/reference/functions/)** - Compose values together using functions, references, and external data sources
* **[Framework Integrations](/integrations/overview/)** - Official integrations for Next.js, Vite, Astro, and more, plus support for any language via `varlock run`
* **[Replacement for dotenv](/guides/migrate-from-dotenv/)** - Can be used as a direct replacement for `dotenv` in most projects with minimal code changes

## AI Tooling

[Section titled “AI Tooling”](#ai-tooling)

Varlock is purpose-built for the AI era. Your `.env.schema` gives AI agents full context on your configuration — variable names, types, validation rules, descriptions — without ever exposing secret values. Use `varlock scan` to catch secrets that may have leaked into AI-generated code, and `varlock run` to securely inject secrets into AI CLI tools like Claude Code, Cursor, Aider, and Gemini CLI.

### Docs MCP

[Section titled “Docs MCP”](#docs-mcp)

Varlock provides a Docs MCP server that allows AI tools to search and understand the Varlock documentation. This makes it easier for AI assistants to help you integrate and use Varlock in your projects.

See the [MCP guide](/guides/mcp/#docs-mcp) for setup instructions for Cursor, Claude, Opencode, VS Code, and other MCP-compatible tools.

### LLMs.txt

[Section titled “LLMs.txt”](#llmstxt)

Varlock also provides an `LLMs.txt` file that helps AI models understand how to integrate and interact with your environment variable configuration. See it at <https://varlock.dev/llms.txt>.

## Next Steps

[Section titled “Next Steps”](#next-steps)

Ready to get started? Check out the [Installation](/getting-started/installation/) guide to set up Varlock in your project.

# Migration

> An overview if you have existing .env files and want to migrate to Varlock

## Loading env vars using Varlock

[Section titled “Loading env vars using Varlock”](#loading-env-vars-using-varlock)

### Migration from dotenv (Node.js)

[Section titled “Migration from dotenv (Node.js)”](#migration-from-dotenv-nodejs)

In a [Node.js](/integrations/javascript/) app if you are already calling `dotenv/config`, you can replace it with `varlock/auto-load`.

index.js

```diff
-import 'dotenv/config';
+import 'varlock/auto-load';
```

In some cases where `dotenv` is being called deep under the hood by another dependency, you may instead want to swap it in as a dependency override. See our [migrate from dotenv](/guides/migrate-from-dotenv/) guide for more information.

### Within a framework

[Section titled “Within a framework”](#within-a-framework)

We must replace framework’s existing `.env` logic with Varlock. Our [framework integrations](/integrations/overview/) handle most of the work for you. After [installation](/getting-started/installation/), simply follow the instructions in the relevant integration guide to set up Varlock in your project. Usually this involves adding a new plugin to the existing build system or framework’s config file.

### Minimal setup

[Section titled “Minimal setup”](#minimal-setup)

In some cases, a code-level integration may be challenging or impossible. In this case you can use [`varlock run`](/reference/cli-commands/#run) to boot your application with env vars injected from Varlock. For example `varlock run -- your-app`. Sometimes you may need to use this alongside a deeper integration, for example to feed env vars into external tools or additional scripts.

## Using `varlock/env`

[Section titled “Using varlock/env”](#using-varlockenv)

If you’re currently using `import.meta.env` or `process.env`, your code will still work after switching to Varlock. However, we recommend using varlock’s `ENV` object for better type-safety and an improved developer experience.

index.js

```diff
// Before (import.meta.env)
 -console.log(import.meta.env.SOMEVAR);


// After (ENV)
import { ENV } from 'varlock/env';
 +console.log(ENV.SOMEVAR);
```

![intellisense](/_astro/intellisense.l7SBUQg3_jY8ez.png)

See our [integrations](/integrations/overview/) section for more information.

# Usage

> How to use Varlock in your project

## Basics

[Section titled “Basics”](#basics)

The basic workflow for using Varlock is to:

1. Run [`varlock init`](/reference/cli-commands/#init) to set up your `.env.schema` file

2. Run [`varlock load`](/reference/cli-commands/#load) to debug and refine your .env file(s)

3. Use Varlock to load, validate, and inject env vars into your application, either:

   * Use an [existing framework / tool integration](/integrations/overview/) that automatically calls Varlock under the hood (*recommended*)
   * Use `import 'varlock/auto-load'` in a backend JavaScript/TypeScript project
   * Boot your command via [`varlock run`](/reference/cli-commands/#run)\
     (*necessary for non-JS/TS projects, or feeding env vars to external tools*)

## CLI Commands

[Section titled “CLI Commands”](#cli-commands)

### `varlock load`

[Section titled “varlock load”](#varlock-load)

* npm

  ```bash
  npm exec -- varlock load
  ```

* pnpm

  ```bash
  pnpm exec -- varlock load
  ```

* bun

  ```bash
  bun exec varlock load
  ```

* vlt

  ```bash
  vlx -- varlock load
  ```

* yarn

  ```bash
  yarn exec -- varlock load
  ```

* standalone binary

  ```bash
  varlock load
  ```

Validates your environment variables according to your `.env.schema` and associated `.env.*` files, and prints the results.

Useful for debugging locally, and in CI to print out a summary of env vars, also when you’re authoring your `.env.schema` file and want immediate feedback.

Tip

Our [integrations](/integrations/overview) all use `varlock load` under the hood, so you’ll get the same developer experience, but typically they will only let you know if there are errors, rather than the full summary.

See the [`varlock load` CLI Reference](/reference/cli-commands/#load) for more information.

### `varlock run`

[Section titled “varlock run”](#varlock-run)

* npm

  ```bash
  npm exec -- varlock run -- <your-command>
  ```

* pnpm

  ```bash
  pnpm exec -- varlock run -- <your-command>
  ```

* bun

  ```bash
  bun exec varlock run -- <your-command>
  ```

* vlt

  ```bash
  vlx -- varlock run -- <your-command>
  ```

* yarn

  ```bash
  yarn exec -- varlock run -- <your-command>
  ```

* standalone binary

  ```bash
  varlock run -- <your-command>
  ```

Executes a command in a child process, injecting your resolved and validated environment variables. This is useful when a code-level integration is not possible. For example, if you’re using a database migration tool, you can use `varlock run` to run the migration tool with the correct environment variables. Or if you’re using a non-js/ts language, you can use `varlock run` to run a command and inject validated environment variables.

See the [`varlock run` CLI Reference](/reference/cli-commands/#run) for more information.

# Wrapping up

> How to get your project ready for production and collaboration

## Next steps with your schema

[Section titled “Next steps with your schema”](#next-steps-with-your-schema)

With a more flexible env var toolkit, after an initial migration, you may be tempted to take advantage of Varlock’s features to improve your developer experience and security posture.

* Move more configuration constants out of application code and into your `.env` files
* Reduce the number of env-style checks in your code, favouring individual flags, with a default value set based on the current env
* Add deeper validation, more thorough comments, and additional docs links to each env var within your schema
* Compose values together to keep your configuration DRY
* Use [imports](/guides/import/) to share common configuration across a monorepo, or to break up a large `.env.schema`
* Reduce secret sprawl, by loading secrets from a single source of truth, instead of injecting them from your CI/hosting platform

## Repo setup

[Section titled “Repo setup”](#repo-setup)

### `.gitignore`

[Section titled “.gitignore”](#gitignore)

Depending on your setup you will want to update your `.gitignore` to *not* ignore your `.env.schema` file and any other `.env.xxx` files that can now be safely committed to your repo if they don’t contain secrets (which they shouldn’t).

If using [generated types](/reference/root-decorators/#generatetypes), we also recommend that you ignore the generated file (usually `env.d.ts` in TypeScript) as it is dynamically generated based the hierarchy of env files being loaded on each individual machine.

.gitignore

```diff
# Include .env.schema, .env.<dev|preview|prod|...> file
# exclude local overrides
.env.*
.env.local
.env.*.local


# Exclude generated env types file
env.d.ts
```

Tip

Depending on the [AI Tools](/guides/ai-tools/) you use, you may need to add a similar rule to allow `.env.schema` to be modified. For example, in `.cursorignore`.

### Monorepos

[Section titled “Monorepos”](#monorepos)

Consider how you can reuse and modularize your schema if you have a monorepo or multi-service setup. See the [Imports](/guides/import/) guide for more information.

## Deployment

[Section titled “Deployment”](#deployment)

### CI/CD platforms

[Section titled “CI/CD platforms”](#cicd-platforms)

It may be useful to validate your schema in CI/CD pipelines, especially if you want to validate configurations that you don’t have access to locally (e.g. Staging or Production). You can do this manually by running `varlock load` in your pipeline. And if you’re using GitHub Actions, you can use the [Varlock GitHub Action](/integrations/github-action/) to validate your schema automatically.

Tip

Having a well architected multi-environment setup is key to healthy CI/CD workflows. See the [Environments](/guides/environments/) guide for more information.

### Production deployments

[Section titled “Production deployments”](#production-deployments)

Because varlock supports loading environment variables from the environment itself or via a [function](/reference/functions/) in your `.env.schema`, there are a few different approaches.

If you’re already using your deployment platform’s environment variable management, you may not need to do anything to benefit from varlock’s validation and security features. If you have a multi-environment setup, you may need to set the `currentEnv` environment flag to the correct environment.

```bash
APP_ENV=production varlock run -- your-production-command
```

If you’re not using your deployment platform’s environment variable management, you may consider using one of our [plugins](/plugins/overview/) to securely load environment variables from a secret storage system such as [1Password](/plugins/1password/).

# AI Tools

> Varlock is purpose-built for the AI era — your schema gives agents full context, your secrets never touch AI servers

Varlock is purpose-built for the AI era. Your `.env.schema` gives AI agents full context on your configuration — variable names, types, validation rules, descriptions — while your secret values never leave your machine or touch AI servers.

This solves two critical problems with AI-assisted development:

1. **Secret exposure** — AI tools read your project files, including `.env` files. With varlock, secrets are never stored in plain text — they’re fetched at runtime from secure providers.
2. **AI-generated leaks** — AI agents may hardcode secrets or log sensitive values in generated code. `varlock scan` catches these leaks before they’re committed, and runtime protection redacts secrets from logs and responses.

## Securely inject secrets into AI CLI tools

[Section titled “Securely inject secrets into AI CLI tools”](#securely-inject-secrets-into-ai-cli-tools)

Many AI coding assistants offer CLI tools that require API keys and other secrets. Instead of storing these secrets in plain text `.env` or `.json` files or exposing them in your shell history, use `varlock` to inject them securely at runtime. This applies both to config that might be required to bootstrap the tool itself, as well as things like [MCP servers](/guides/mcp/) that require API keys.

### 1. Install varlock

[Section titled “1. Install varlock”](#1-install-varlock)

If you haven’t already, [install varlock](/getting-started/installation/) on your system.

### 2. Create an environment schema

[Section titled “2. Create an environment schema”](#2-create-an-environment-schema)

Define your API keys and secrets in your `.env.schema` file. Mark sensitive values appropriately:

.env.schema

```env-spec
# @sensitive @required
OPENAI_API_KEY=exec('op read "op://api-local/openai/api-key"')


# @sensitive @required
ANTHROPIC_API_KEY=exec('op read "op://api-local/anthropic/api-key"')


# @sensitive @required
GOOGLE_API_KEY=exec('op read "op://api-local/google/api-key"')
```

Store the actual secret values in your preferred [secrets provider](/guides/secrets-providers) like 1Password (as shown above), AWS Secrets Manager, or any other provider with a CLI to fetch invidual secrets.

Tip

You can use any secrets provider you want, but we like 1Password since it uses biometric authentication for local access. All the examples in this guide use 1Password as a means of showing more real world examples.

### 3. Run your tool via `varlock run`

[Section titled “3. Run your tool via varlock run”](#3-run-your-tool-via-varlock-run)

Execute your AI CLI tool through `varlock` to securely inject the environment variables:

```bash
varlock run -- <your-cli-command>
```

### Popular AI CLI tool examples

[Section titled “Popular AI CLI tool examples”](#popular-ai-cli-tool-examples)

Here’s how to configure and run popular AI coding CLI tools with varlock:

* Claude

  [Claude Code](https://docs.claude.com/en/docs/claude-code/overview) is Anthropic’s CLI tool for AI-assisted coding.

  **Environment variable:**

  * `ANTHROPIC_API_KEY` - Your Anthropic API key

  **Add to `.env.schema`:**

  ```env-spec
  # @sensitive @required
  ANTHROPIC_API_KEY=exec('op read "op://api-local/anthropic/api-key"')
  ```

  **Run with varlock:**

  ```bash
  varlock run -- claude
  ```

  See supported env variables [here](https://docs.claude.com/en/docs/claude-code/settings#environment-variables).

* Opencode

  [Opencode](https://opencode.ai/) is a provider-agnostic AI coding assistant that works in your terminal.

  **Environment variables:**

  * `ANTHROPIC_API_KEY` - For Claude models
  * `OPENAI_API_KEY` - For OpenAI models
  * `OPENCODE_CONFIG` - Path to custom config file (optional)

  **Add to `.env.schema`:**

  ```env-spec
  # @sensitive @required
  ANTHROPIC_API_KEY=exec('op read "op://api-local/anthropic/api-key"')


  # @sensitive
  OPENAI_API_KEY=exec('op read "op://api-local/openai/api-key"')
  ```

  **Add an auth configuration:**

  ```bash
  opencode auth login
  ```

  It will ask you to paste your API key. Instead, paste in an `env reference` like this:

  `{"env:ANTHROPIC_API_KEY"}`

  Your config file (`~/.local/share/opencode/auth.json`) should now look like this:

  \~/.local/share/opencode/auth.json

  ```json
  {
    "anthropic": {
      "type": "api",
      "key": "{env:ANTHROPIC_API_KEY}"
    }
  }
  ```

  **Run with varlock:**

  ```bash
  varlock run -- opencode


  # or with specific model
  varlock run -- opencode --model claude-3-5-sonnet
  ```

  See the [Opencode docs](https://opencode.ai/docs/) for more information.

* Gemini

  [Gemini CLI](https://github.com/google-gemini/gemini-cli) is Google’s open source AI agent.

  **Environment variable:**

  * `GOOGLE_API_KEY` or `GEMINI_API_KEY` - Your Google AI API key

  **Add to `.env.schema`:**

  ```env-spec
  # @sensitive @required
  GOOGLE_CLOUD_PROJECT=exec('op read "op://api-local/google/cloud-project"')


  # @sensitive @required
  GOOGLE_API_KEY=exec('op read "op://api-local/google/api-key"')
  ```

  **Run with varlock:**

  ```bash
  varlock run -- gemini
  ```

  See the [Gemini CLI auth docs](https://github.com/google-gemini/gemini-cli/blob/main/docs/get-started/authentication.md) for more information.

***

## Allowing schema files for AI tools

[Section titled “Allowing schema files for AI tools”](#allowing-schema-files-for-ai-tools)

Most AI tools ignore `.env.*` files by default. To ensure your AI tool can access your environment schema, add the following to your `.gitignore`:

```txt
!.env.schema
```

If you use a tool with its own ignore file, check that tool’s documentation to see how it handles ignore files and make sure `.env.schema` is allowed.

## Custom instructions and rules

[Section titled “Custom instructions and rules”](#custom-instructions-and-rules)

To give your AI tool full context about `varlock`, you can provide it with the [full Varlock `llms.txt`](https://varlock.dev/llms-full.txt). In Cursor, this is accomplished via ‘Add New Custom Docs’.

If your tool supports custom rules, you can use our own varlock [Cursor rule file from this repo](https://github.com/dmno-dev/varlock/blob/main/.cursor/rules/varlock.mdc) as a starting point to create your own that is most suited to your workflow.

## Scan for leaked secrets

[Section titled “Scan for leaked secrets”](#scan-for-leaked-secrets)

AI agents can sometimes hardcode secret values or leak them into generated code. Use `varlock scan` to proactively detect leaked secrets in your codebase:

```bash
# Scan the current directory for leaked secret values
varlock scan


# Scan specific paths
varlock scan ./src ./config
```

You can also set up `varlock scan` as a git pre-commit hook to automatically catch leaks before they’re committed:

```bash
# Add to your .git/hooks/pre-commit or use a hook manager like husky/lefthook
varlock scan --staged
```

This is especially valuable when working with AI coding tools — the scan command compares your resolved secret values against your codebase to find any that may have been accidentally included in plain text.

## Varlock Docs MCP

[Section titled “Varlock Docs MCP”](#varlock-docs-mcp)

We also have a docs MCP server that allows you to search the Varlock docs. See more details [here](/guides/mcp/#docs-mcp).

# Docker

> Using varlock with Docker containers and CI/CD pipelines

Varlock provides an official Docker image for use in containerized environments and CI/CD pipelines. The image is hosted on GitHub Container Registry (GHCR) and makes it easy to integrate varlock into your Docker workflows and ensures consistent behavior across different environments.

## Quick Start

[Section titled “Quick Start”](#quick-start)

```bash
# Pull the latest version
docker pull ghcr.io/dmno-dev/varlock:latest


# Run varlock help
docker run --rm ghcr.io/dmno-dev/varlock:latest --help


# Run varlock load in a directory
docker run --rm -v $(pwd):/work -w /work -e PWD=/work ghcr.io/dmno-dev/varlock:latest load
```

## Available Tags

[Section titled “Available Tags”](#available-tags)

* `ghcr.io/dmno-dev/varlock:latest` - Latest stable release
* `ghcr.io/dmno-dev/varlock:1.2.3` - Specific version (replace with actual version)

## Usage Examples

[Section titled “Usage Examples”](#usage-examples)

### Basic Usage

[Section titled “Basic Usage”](#basic-usage)

```bash
# Validate and load environment variables
docker run --rm -v $(pwd):/work -w /work -e PWD=/work ghcr.io/dmno-dev/varlock:latest load


# Run a command with loaded environment variables
docker run --rm -v $(pwd):/work -w /work -e PWD=/work ghcr.io/dmno-dev/varlock:latest run -- node app.js
```

### CI/CD Pipeline

[Section titled “CI/CD Pipeline”](#cicd-pipeline)

```yaml
# GitHub Actions example
- name: Validate environment schema
  run: |
    docker run --rm \
      -v ${{ github.workspace }}:/work \
      -w /work \
      -e PWD=/work \
      ghcr.io/dmno-dev/varlock:latest load
```

### Multi-stage Docker Builds

[Section titled “Multi-stage Docker Builds”](#multi-stage-docker-builds)

Use varlock in multi-stage builds to copy the binary into your application:

```dockerfile
# Use varlock in a multi-stage build
FROM ghcr.io/dmno-dev/varlock:latest AS varlock


FROM node:18-alpine
COPY --from=varlock /usr/local/bin/varlock /usr/local/bin/varlock


# Now varlock is available in your application container
RUN varlock --help
```

### Docker Compose

[Section titled “Docker Compose”](#docker-compose)

docker-compose.yml

```yaml
version: '3.8'
services:
  app:
    build: .
    environment:
      - NODE_ENV=production
    volumes:
      - .:/app
      - /app/node_modules
    command: ["varlock", "run", "--", "node", "app.js"]
```

## Security

[Section titled “Security”](#security)

The Docker image is built from the official varlock binary releases and includes:

* Minimal Alpine Linux base for reduced attack surface
* Non-root user execution (when possible)
* Regular security updates through Alpine package updates

## Troubleshooting

[Section titled “Troubleshooting”](#troubleshooting)

### Permission Issues

[Section titled “Permission Issues”](#permission-issues)

If you encounter permission issues when mounting volumes:

````bash
# Run with appropriate user permissions
docker run --rm -u $(id -u):$(id -g) -v $(pwd):/work -w /work -e PWD=/work ghcr.io/dmno-dev/varlock:latest load


### Network Issues


If you need to access external services (like 1Password CLI):


```bash
# Pass through host network
docker run --rm --network host -v $(pwd):/work -w /work -e PWD=/work ghcr.io/dmno-dev/varlock:latest load


## Building Locally


To build the Docker image locally:


```bash
# Build with specific version
docker build --build-arg VARLOCK_VERSION=1.2.3 -t varlock:local .


# Build with latest version
docker build --build-arg VARLOCK_VERSION=latest -t varlock:local .
````

# Environments

> Best practices for managing multiple environments with varlock

One of the main benefits of using environment variables is the ability to boot your application with configuration intended for different environments (e.g., development, preview, staging, production, test).

You may use both [functions](/reference/functions/) and/or environment-specific `.env` files (e.g., `.env.production`) to alter configuration accordingly in a declarative way. Plus the additional guardrails provided by `varlock` also make this much safer no matter where values come from.

environment-specific files are optional

While many have traditionally shied away from using environment-specific `.env` files due to fear of committing sensitive values, the ability to set values using [plugins](/guides/plugins/) makes it easier to securely, and collaboratively, manage these values.

### Process overrides

[Section titled “Process overrides”](#process-overrides)

`varlock` will always treat environment variables passed into the process with the most precedence. Generally, we recommend moving as much configuration as possible into your `.env` files, but there are cases where you may want to override specific values at runtime, either from the environment itself, or by prepending them to your command (e.g., `APP_ENV=prod pnpm run build`).

At the very least, you’ll often need to to inject an environment flag (e.g., `APP_ENV`) and a *secret-zero* which allows access to the rest of your secrets.

That said, as a first step to adopting `varlock`, you could rely entirely on process overrides to inject all config values, but still benefit from having a clear schema with validation applied to them.

### Loading environment-specific `.env` files

[Section titled “Loading environment-specific .env files”](#loading-environment-specific-env-files)

Any environment-specific files (e.g., `.env.development`) will automatically be loaded if they match the value of the *current environment* as set by the [`@currentEnv`](/reference/root-decorators/#currentenv) root decorator in your `.env.schema` file.

The files are applied with a specific precedence (increasing):

* `.env.schema` - your schema file, which can also contain default values
* `.env` - will be loaded, but not recommended, instead use something more specific
* `.env.local` - local overrides (gitignored)
* `.env.[currentEnv]` - environment-specific values
* `.env.[currentEnv].local` - environment-specific local overrides (gitignored)

Auto-detect with `VARLOCK_ENV`

Instead of managing your own environment flag, you can use the built-in `$VARLOCK_ENV` variable which auto-detects the environment from your CI/deploy platform. See the [builtin variables reference](/reference/builtin-variables/) for details.

.env.schema

```env-spec
# @currentEnv=$VARLOCK_ENV
# ---
```

For example, consider the following `.env.schema`:

.env.schema

```env-spec
# @currentEnv=$APP_ENV
# ---
# @type=enum(development, test, staging, production)
APP_ENV=development
```

Your environment flag key is set to `APP_ENV`, which has a default value of `development` - meaning that `.env.development` and `.env.development.local` will be loaded if they exist.

To tell `varlock` to load `.env.staging` instead, you must set `APP_ENV` to `staging` - usually using an override passed into the process. For example:

```bash
APP_ENV=staging varlock run -- node my-test-script.js
```

Loading `.env.local` in `test` environment

Some tools ([dotenv-flow](https://github.com/kerimdzhanov/dotenv-flow), [Next.js](https://nextjs.org/docs/pages/guides/environment-variables#test-environment-variables), etc) make a special exception to skip loading `.env.local` if the current environment is `test`. Others tools ([Vite](https://vite.dev/config/#env-variables)) do not have any special handling.

We chose to follow Vite’s lead, and instead provide a way to explicitly opt-in to that behavior:

.env.local

```env-spec
# @disable=forEnv(test)
# ---
```

Next.js precedence order

Unlike Varlock (which matches Vite and dotenv-flow), [Next.js](https://nextjs.org/docs/pages/guides/environment-variables#environment-variable-load-order) swaps the order of precedence for `.env.local` vs `.env.[currentEnv]`.

## Advanced logic using functions

[Section titled “Advanced logic using functions”](#advanced-logic-using-functions)

On some platforms, you may not have full control over a build or boot command or the env vars passed into them. In this case, we can use functions to transform other env vars provided by the platform into the environment flag value we want. We can use [`remap()`](/reference/functions#remap) to transform a value according to a lookup, along with [`regex()`](/reference/functions#regex) if we need to match a pattern instead of an exact value.

For example, on the Cloudflare Workers CI platform, we get the current branch name injected as `WORKERS_CI_BRANCH`, which we can use to determine which environment to load:

.env.schema

```env-spec
# @currentEnv=$APP_ENV
# ---
# set to current branch name when build is running on Cloudflare CI, empty otherwise
WORKERS_CI_BRANCH=
# @type=enum(development, preview, production, test)
APP_ENV=remap($WORKERS_CI_BRANCH, production="main", preview=regex(.*), development=undefined)
```

You’ll notice that `test` is one of the possible enum values, but it is not listed in the remap. When running tests, you would just explicitly set `APP_ENV` when invoking your command.

```bash
APP_ENV=test varlock run -- your-test-command
# or if your command is loading varlock internally
APP_ENV=test your-test-command
```

or you could run a production style build locally `APP_ENV=production varlock run -- your-build-command`

Tip

You can also use the [`forEnv()` helper](/reference/functions/#forenv) to dynamically set whether configuration items are required or optional based on the current environment.

## Setting a *default* environment flag

[Section titled “Setting a default environment flag”](#setting-a-default-environment-flag)

You can set the default environment flag directly when running CLI commands using the `--env` flag:

```bash
varlock load --env production
```

This is only useful if you do not want to create a new env var for your env flag, and you are only using varlock via CLI commands. Mostly it is used internally by some integrations to match existing default behavior, and should not be used otherwise.

Caution

If `@currentEnv` is used, this will be ignored!

## Using `currentEnv` in Turborepo

[Section titled “Using currentEnv in Turborepo”](#using-currentenv-in-turborepo)

Turborepo users should be aware of a common pitfall when using `varlock`’s `@currentEnv` in monorepos managed by Turborepo, especially since Turborepo v2.0+ now enables **Strict Environment Mode** by default.

### The Problem

[Section titled “The Problem”](#the-problem)

Turborepo, when running tasks, filters the environment variables available to each task. By default in Strict Mode, **only** variables listed in the `env` or `globalEnv` keys in your `turbo.json` are passed to your scripts. This means that if your environment flag set by `@currentEnv` (e.g., `APP_ENV`) is not explicitly listed, it will not be available to your process, even if you set it in your shell or CI environment. This can cause `varlock` to load the wrong environment, or fail to load the correct `.env.[currentEnv]` file.

### Solution: Add your environment flag to turbo.json

[Section titled “Solution: Add your environment flag to turbo.json”](#solution-add-your-environment-flag-to-turbojson)

To ensure your environment flag variable is always available to your scripts, add it to the `env` or `globalEnv` section of your `turbo.json`:

turbo.json

```json
{
  "globalEnv": ["APP_ENV"],
  "tasks": {
    "build": {
      "env": ["APP_ENV"]
    },
    "dev": {
      "env": ["APP_ENV"]
    }
  }
}
```

* Use `globalEnv` if the variable should be available to all tasks.
* Use `env` under a specific task if only needed for that task.

Now when you run the following:

```bash
APP_ENV=production turbo run build
```

it will load the correct `.env.production` file because the override for `APP_ENV` is passed correctly to `turbo` and in turn to `varlock`.

> Substitute whatever your env flag is for `APP_ENV` in the above example.

Tip

In the above example, we’re *only* passing the `APP_ENV` because that’s the variable you are most likely going to want to override in your scripts. If there are other variables you want to pass to your scripts, they will need to be explicitly added as well.

***

### Setting the Environment Flag

[Section titled “Setting the Environment Flag”](#setting-the-environment-flag)

When running locally, or on a platform you control, you can set the env flag explicitly as an environment variable. However on some cloud platforms, there is a lot of magic happening, and the ability to set environment variables per branch is limited. In these cases you can use functions to transform env vars injected by the platform, like a current branch name, into the value you need.

#### Local/Custom Scripts

[Section titled “Local/Custom Scripts”](#localcustom-scripts)

You can set the env var explicitly when you run a command, but often you will set it in `package.json` scripts:

package.json

```json
"scripts": {
  "build:preview": "APP_ENV=preview next build",
  "start:preview": "APP_ENV=preview next start",
  "build:prod": "APP_ENV=production next build",
  "start:prod": "APP_ENV=production next start",
  "test": "APP_ENV=test jest"
}
```

#### Vercel

[Section titled “Vercel”](#vercel)

You can use the injected `VERCEL_ENV` variable to match their concept of environment types, while adding your own additional options.

.env.schema

```env-spec
# @currentEnv=$APP_ENV
# ---
# @type=enum(development, preview, production)
VERCEL_ENV=
# @type=enum(development, preview, production, test)
APP_ENV=fallback($VERCEL_ENV, development)
```

For more granular environments, use the branch name in `VERCEL_GIT_COMMIT_REF` (see Cloudflare example below).

#### Cloudflare Workers Build

[Section titled “Cloudflare Workers Build”](#cloudflare-workers-build)

Use the branch name in `WORKERS_CI_BRANCH` to determine the environment:

.env.schema

```env-spec
# @currentEnv=$APP_ENV
# ---
WORKERS_CI_BRANCH=
# @type=enum(development, preview, production, test)
APP_ENV=remap($WORKERS_CI_BRANCH, production="main", preview=regex(.*), development=undefined)
```

# Imports

> Learn how to use the @import decorator to share environment variables across files and services

The [`@import()` root decorator](/reference/root-decorators/#import) allows you to import schema and/or values from other sources (currently just `.env` files), making it easy to share config across services within a monorepo, split up large schemas, or reuse pre-defined schemas. Multiple `@import()` calls may be used, and an imported source may itself import more sources.

**Basic examples:**

```env-spec
# @import(./.env.imported)              # import specific file
# @import(./env-dir/)                   # import directory
# @import(./.env.partial, KEY1, KEY2)   # import specific keys
# @import(~/.env.shared)                # import from home directory
# ---
```

## Import source types

[Section titled “Import source types”](#import-source-types)

The first argument to `@import()` specifies where to look for file(s) to import. Currently only local file imports are supported, but we plan to support importing over http in a style similar to Deno’s http imports.

For now, all imported files must be `.env` files (and may contain @env-spec decorators), but in the future, we may also support other formats (e.g., JSON, YAML, etc.) or even JS/TS files.

### Single file

[Section titled “Single file”](#single-file)

* Path must begin with `./`, `../`, `/`, or `~/`
* Imported file name must be begin with `.env.`

```env-spec
# @import(./.env.common)
```

Home directory (`~`)

You can import files from your home directory using the `~/` prefix. This is useful for sharing personal configuration across multiple projects without placing files inside any specific repo.

```env-spec
# @import(~/.env.shared)
```

### Directory

[Section titled “Directory”](#directory)

* Path must begin with `./`, `../`, `/`, or `~/`
* Path must end with a trailing `/`
* Multiple `.env.*` files will be detected and loaded, based on the current environment flag, similar to what happens in the current directory (see [environments guide](/guides/environments#loading-environment-specific-env-files))
* The environment flag value will be inherited, unless another `@currentEnv` is defined within the directory’s `.env.schema`

```env-spec
# @import(../shared-config-dir/)
```

## Partial imports

[Section titled “Partial imports”](#partial-imports)

By default, all items will be imported, but you may add a list of specific keys to import as additional args after the first.

* If there is a chain of imports, an item is only imported if every ancestor import includes it (or imports all items)

```env-spec
# @import(./.env.imported, KEY1, KEY2)
```

## Conditional imports

[Section titled “Conditional imports”](#conditional-imports)

While you can use the [`@disable`](/reference/root-decorators/#disable) root decorator to disable a file *from within that file*, you can also use the `enabled` parameter of the `@import()` decorator to conditionally load the file.

The `enabled` parameter accepts any expression that evaluates to a boolean. It can be combined with partial imports to only import specific keys from a file.

**Example:**

.env.schema

```env-spec
# Combine with partial imports
# @import(./.env.features, FEATURE_X, enabled=eq($ENABLE_X, "true"))
# ---
ENABLE_X=true
```

## Optional imports

[Section titled “Optional imports”](#optional-imports)

By default, `@import()` will cause a loading error if the specified file or directory does not exist. You can use the `allowMissing` parameter to make an import optional - if the file or directory doesn’t exist, it will be silently skipped without causing an error.

The `allowMissing` parameter accepts a boolean value (defaults to `false`). It can be combined with partial imports and the `enabled` parameter.

**Example:**

.env.schema

```env-spec
# Import if exists, skip if not
# @import(./.env.local, allowMissing=true)
# ---
```

**Combine with other parameters:**

.env.schema

```env-spec
# Optional partial import with conditional loading
# @import(./.env.features, FEATURE_X, enabled=true, allowMissing=true)
# ---
```

## Import precedence and merging multiple sources

[Section titled “Import precedence and merging multiple sources”](#import-precedence-and-merging-multiple-sources)

Varlock is designed to load multiple definitions for a single item and merge them together. The common case would be taking schema info from `.env.schema` and overriding a value from another source (e.g., `.env.local`, `.env.production`, etc.), but there are many cases where root decorators, item decorators, and descriptions may be merged as well.

To do this, we usually walk our data sources in decreasing order of precedence, until we find something defined for the value/decorator/etc we are evaluating.

**Precedence rules are:**

* Imported files are processed in order, with later imports overriding previous imports
* Definitions and root decorators in the importing file override those in files it imports
* For a directory, the precedence order is `.env.schema` < `.env` < `.env.local` < `.env.{currentEnv}` < `.env.{currentEnv}.local`

For example, given a `.env.local` and a `.env.schema` that imports 2 files:

.env.schema

```env-spec
# @import(./.env.import1)
# @import(./.env.import2)
# ---
```

The precedence order would be `.env.import1` < `.env.import2` < `.env.schema` < `.env.local`.

Meaning if there was a value for `ITEM` in all 4 files, the final value used would be the one from `.env.local`.

## More details

[Section titled “More details”](#more-details)

* Root decorators that affect individual items (e.g., `@defaultRequired`) affect only the items that are defined in the file, not those in imported files
* An item with no value at all (e.g., `ITEM=`) will be skipped when looking for a value / function to use, but its presence can be used to add other decorators/description to the item
* If an imported file is marked with [`@disable`](/reference/root-decorators/#disable), it and any files it imports are skipped entirely

# MCP Security

> Using varlock to secure MCP clients and servers - protecting secrets in AI agent connections

The [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) enables AI agents to connect to external data sources and tools. When using MCP, you often need to handle sensitive configuration like API keys, database credentials, and authentication tokens. `varlock` provides a secure way to manage these secrets without exposing them in your configuration files or to AI agents.

This guide covers three scenarios:

* **Local MCP servers** using stdio transport with `varlock run`
* **Remote MCP servers** using varlock’s Node.js integration
* **Third-party MCP servers** using varlock to load secrets and pass them to the server

## Local MCP Servers with stdio

[Section titled “Local MCP Servers with stdio”](#local-mcp-servers-with-stdio)

For local development and testing, MCP servers often use stdio transport for communication with clients. This is perfect for using `varlock run` to securely load environment variables before starting your server.

### Server Setup

[Section titled “Server Setup”](#server-setup)

Create a `.env.schema` file for your MCP server:

.env.schema

```env-spec
# @defaultSensitive=true
# @defaultRequired=true
# ---


# Database connection for MCP server
# @type=url
DATABASE_URL=


# API key for external service
# @type=string(startsWith="sk_")
EXTERNAL_API_KEY=


# Authentication secret
# @type=string(minLength=32)
AUTH_SECRET=


# Server configuration
# @sensitive=false
# @type=number(min=1024, max=65535)
SERVER_PORT=3000


# @sensitive=false
# @type=enum(debug, info, warn, error)
LOG_LEVEL=info
```

Create your local `.env` file with values from your 1Password vault:

.env

```env-spec
DATABASE_URL=exec(`op read "op://devTest/myVault/database-url"`)
EXTERNAL_API_KEY=exec(`op read "op://devTest/myVault/external-api-key"`)
AUTH_SECRET=exec(`op read "op://devTest/myVault/auth-secret"`)
LOG_LEVEL=debug
```

Note

We’re using 1Password as an example here, but you can use any secret management tool you prefer as long as it has a CLI to load values.

Update your MCP server’s `package.json` to use `varlock run`:

package.json

```json
{
  "name": "my-mcp-server",
  "scripts": {
    "start": "varlock run -- node server.js",
    "dev": "varlock run -- node --watch server.js"
  },
  "dependencies": {
    "@modelcontextprotocol/sdk": "^0.4.0"
  }
}
```

### Docker (local)

[Section titled “Docker (local)”](#docker-local)

For containerized local development, create a Dockerfile that uses varlock:

Dockerfile

```dockerfile
FROM node:22-alpine


# Install varlock
RUN npm install -g @varlock/cli


WORKDIR /app


# Copy package files
COPY package*.json ./
COPY pnpm-lock.yaml ./


# Install dependencies
RUN npm install -g pnpm && pnpm install


# Copy application files
COPY . .


# Build the application
RUN pnpm build


# Use varlock run to start the server
CMD ["varlock", "run", "--", "node", "dist/server.js"]
```

Build and run your Docker container:

```bash
# Build the image
docker build -t my-mcp-server:latest .


# Run the container (for testing)
docker run --rm -it my-mcp-server:latest
```

### Client Configuration

[Section titled “Client Configuration”](#client-configuration)

* Cursor

  Create a Cursor configuration file to connect to your local MCP server:

  \~/.cursor/mcp-servers.json

  ```json
  {
    "mcpServers": {
      "my-local-server": {
        "command": "npm",
        "args": ["start"],
        "cwd": "/path/to/your/mcp-server",
        "env": {
          "NODE_ENV": "development"
        }
      }
    }
  }
  ```

  For local MCP servers running in Docker: In this case an off-the-shelf MCP server is used, so we need to use `varlock run` to load the `GITHUB_TOKEN` environment variable and pass it to the server.

  \~/.cursor/mcp-servers.json

  ```json
  {
    "mcpServers": {
      "github": {
        "command": "varlock",
        "args": [
          "run",
          "--",
          "docker",
          "run",
          "--rm",
          "-i",
          "ghcr.io/github/github-mcp-server:latest"
        ],
        "env": {
          "GITHUB_TOKEN": "${GITHUB_TOKEN}"
        }
      }
    }
  }
  ```

  And the corresponding `.env.schema` file would look something like this:

  .env.schema

  ```env-spec
  # @defaultSensitive=true
  # @defaultRequired=true
  # ---


  # GitHub token
  # @type=string(startsWith="ghp_")
  GITHUB_TOKEN=exec(`op read "op://devTest/myVault/github-token"`)
  ```

* Claude Desktop

  For Claude Desktop, create a configuration file:

  \~/.config/claude/desktop\_config.json

  ```json
  {
    "mcpServers": {
      "my-local-server": {
        "command": "npm",
        "args": ["start"],
        "cwd": "/path/to/your/mcp-server"
      }
    }
  }
  ```

  For local MCP servers running in Docker: In this case an off-the-shelf MCP server is used, so we need to use `varlock run` to load the `GITHUB_TOKEN` environment variable and pass it to the server.

  \~/.config/claude/desktop\_config.json

  ```json
  {
    "mcpServers": {
      "github": {
        "command": "varlock",
        "args": [
          "run",
          "--",
          "docker",
          "run",
          "--rm",
          "-i",
          "ghcr.io/github/github-mcp-server:latest"
        ],
        "env": {
          "GITHUB_TOKEN": "${GITHUB_TOKEN}"
        }
      }
    }
  }
  ```

* Custom Client

  Here’s an example of a custom MCP client that uses varlock for its own configuration:

  client.ts

  ```typescript
  import 'varlock/auto-load';
  import { Client } from '@modelcontextprotocol/sdk/client/index.js';
  import { StdioClientTransport } from '@modelcontextprotocol/sdk/client/stdio.js';
  import { spawn } from 'child_process';
  import { ENV } from 'varlock/env';


  const client = new Client(
    {
      name: 'my-mcp-client',
      version: '1.0.0'
    },
    {
      capabilities: {
        tools: {}
      }
    }
  );


  // Start the server process with varlock
  const serverProcess = spawn('pnpm', ['start'], {
    cwd: ENV.MCP_SERVER_PATH,
    stdio: ['pipe', 'pipe', 'pipe']
  });


  const transport = new StdioClientTransport(serverProcess.stdin, serverProcess.stdout);
  await client.connect(transport);


  // Use the client to interact with your MCP server
  const result = await client.callTool({
    name: 'my-tool',
    arguments: {}
  });
  ```

  For third-party MCP servers that require API keys:

  third-party-client.ts

  ```typescript
  import 'varlock/auto-load';
  import { Client } from '@modelcontextprotocol/sdk/client/index.js';
  import { StdioClientTransport } from '@modelcontextprotocol/sdk/client/stdio.js';
  import { spawn } from 'child_process';
  import { ENV } from 'varlock/env';


  async function connectToOpenAIServer() {
    const client = new Client(
      { name: 'openai-mcp-client', version: '1.0.0' },
      { capabilities: { tools: {} } }
    );


    const serverProcess = spawn('npx', [
      '@modelcontextprotocol/server-openai',
      '--api-key', ENV.OPENAI_API_KEY
    ], {
      stdio: ['pipe', 'pipe', 'pipe'],
      env: { ...process.env, OPENAI_API_KEY: ENV.OPENAI_API_KEY }
    });


    const transport = new StdioClientTransport(serverProcess.stdin, serverProcess.stdout);
    await client.connect(transport);
    return client;
  }


  async function connectToGitHubServer() {
    const client = new Client(
      { name: 'github-mcp-client', version: '1.0.0' },
      { capabilities: { tools: {} } }
    );


    const serverProcess = spawn('npx', [
      '@modelcontextprotocol/server-github',
      '--token', ENV.GITHUB_TOKEN
    ], {
      stdio: ['pipe', 'pipe', 'pipe'],
      env: { ...process.env, GITHUB_TOKEN: ENV.GITHUB_TOKEN }
    });


    const transport = new StdioClientTransport(serverProcess.stdin, serverProcess.stdout);
    await client.connect(transport);
    return client;
  }
  ```

## Remote MCP Servers

[Section titled “Remote MCP Servers”](#remote-mcp-servers)

For production deployments, you’ll want to run MCP servers as standalone processes with varlock integrated directly into the server code.

Note

Code is for example purposes only. Server implementations will vary depending on the MCP server you’re using. See the [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) for more information.

### Server Implementation

[Section titled “Server Implementation”](#server-implementation)

server.ts

```typescript
import 'varlock/auto-load';
import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { ENV } from 'varlock/env';


async function main() {
  const server = new Server(
    {
      name: 'my-mcp-server',
      version: '1.0.0'
    },
    {
      capabilities: {
        tools: {}
      }
    }
  );


  // Register tools with access to secure configuration
  server.setRequestHandler('tools/call', async (request) => {
    const { name, arguments: args } = request.params;


    switch (name) {
      case 'query-database':
        // Use secure database connection from config
        return await queryDatabase(ENV.DATABASE_URL, args);


      case 'call-external-api':
        // Use secure API key from config
        return await callExternalAPI(ENV.EXTERNAL_API_KEY, args);


      default:
        throw new Error(`Unknown tool: ${name}`);
    }
  });


  const transport = new StdioServerTransport(process.stdin, process.stdout);
  await server.connect(transport);
}


async function queryDatabase(databaseUrl: string, args: any) {
  // Implementation using secure database URL
  console.log('Querying database with secure connection');
  return { result: 'database query result' };
}


async function callExternalAPI(apiKey: string, args: any) {
  // Implementation using secure API key
  console.log('Calling external API with secure key');
  return { result: 'api call result' };
}


main().catch(console.error);
```

### Production Deployment

[Section titled “Production Deployment”](#production-deployment)

For production, create environment-specific schema files. See the [environments guide](/guides/environments) for detailed information on managing multiple environments with varlock.

.env.schema

```env-spec
# @defaultSensitive=true
# @defaultRequired=true
# @currentEnv=$APP_ENV
# ---


# env flag is used to determine which environment to load
# default is development
# @type=enum(development, staging, test, production)
APP_ENV=development


# Database connection
# @type=url
DATABASE_URL=


# External API credentials
# @type=string(startsWith="sk_")
EXTERNAL_API_KEY=


# Authentication
# @type=string(minLength=32)
AUTH_SECRET=


# Server settings
# @sensitive=false
# @type=number(min=1024, max=65535)
SERVER_PORT=3000


# @sensitive=false
# @type=enum(debug, info, warn, error)
LOG_LEVEL=info
```

.env.production

```env-spec
DATABASE_URL=exec(`op read "op://prodTest/prodVault/prod-database-url"`)
EXTERNAL_API_KEY=exec(`op read "op://prodTest/prodVault/prod-external-api-key"`)
AUTH_SECRET=exec(`op read "op://prodTest/prodVault/prod-auth-secret"`)
SERVER_PORT=3000
LOG_LEVEL=warn
```

Then in the command to start the server, you can use the `varlock run` command to load the environment variables with the correct `currentEnv` environment override.

```bash
APP_ENV=production varlock run -- node server.js
```

## Security Best Practices

[Section titled “Security Best Practices”](#security-best-practices)

### 1. Never Store Secrets in Plain Text

[Section titled “1. Never Store Secrets in Plain Text”](#1-never-store-secrets-in-plain-text)

Always use external secret management such as 1Password or the built-in env var management in your deployment platform.

```env-spec
# ❌ Never do this
API_KEY=sk_live_1234567890abcdef


# ✅ Use external secret management
API_KEY=exec(`op read "op://devTest/myVault/api-key"`)


# ✅ Use external secret management
API_KEY=exec(`op read "op://devTest/myVault/api-key"`)
```

### 2. Use Environment-Specific Schemas

[Section titled “2. Use Environment-Specific Schemas”](#2-use-environment-specific-schemas)

Create separate schema files for different environments. See the [environments guide](/guides/environments) for detailed information on managing multiple environments with varlock.

.env.schema

```env-spec
# @defaultSensitive=true
# @currentEnv=$APP_ENV
# ---


# env flag is used to determine which environment to load
# default is development
# @type=enum(development, staging, test, production)
APP_ENV=development


# Common configuration
DATABASE_URL=
API_KEY=
```

.env.development

```env-spec
DATABASE_URL=postgresql://localhost:5432/dev_db
API_KEY=exec(`op read "op://devTest/myVault/dev-api-key"`)
```

.env.production

```env-spec
DATABASE_URL=exec(`op read "op://prodTest/prodVault/prod-database-url"`)
API_KEY=exec(`op read "op://prodTest/prodVault/prod-api-key"`)
```

### 3. Validate Sensitive Data

[Section titled “3. Validate Sensitive Data”](#3-validate-sensitive-data)

Use varlock’s validation features to ensure data integrity:

.env.schema

```env-spec
# @type=string(startsWith="sk_", minLength=20)
API_KEY=


# @type=url
DATABASE_URL=
```

### 4. Monitor and Log Securely

[Section titled “4. Monitor and Log Securely”](#4-monitor-and-log-securely)

Use varlock’s redaction features to prevent sensitive data from appearing in logs:

```typescript
import 'varlock/auto-load';
import { ENV } from 'varlock/env';


// Sensitive values are automatically redacted in logs
console.log('API Key:', ENV.API_KEY); // Shows: [xx▒▒▒▒▒]
console.log('Database URL:', ENV.DATABASE_URL); // Shows: [xx▒▒▒▒▒]
```

Note

Redaction is on by default, see [root decorators - redactLogs](/reference/root-decorators/#redactlogs) for more information.

## Docs MCP

[Section titled “Docs MCP”](#docs-mcp)

We also have a MCP server that allows you to search the Varlock docs. Yes, this getting a bit meta.

The MCP server is available at:

* <https://docs.mcp.varlock.dev/mcp> (Streamable HTTP)
* <https://docs.mcp.varlock.dev/sse> (Server-Sent Events)

See below for tool-specific setup instructions.

* Cursor

  Click below to install the MCP server in Cursor:

  [![Install MCP Server](https://cursor.com/deeplink/mcp-install-dark.svg)](https://cursor.com/en-US/install-mcp?name=varlock-docs-mcp\&config=eyJjb21tYW5kIjoibnB4IG1jcC1yZW1vdGUgaHR0cHM6Ly9kb2NzLm1jcC52YXJsb2NrLmRldi9tY3AifQ%3D%3D)

  Or add the following to your `.cursor/mcp-servers.json` file:

  \~/.cursor/mcp.json

  ```json
  {
    "mcpServers": {
      "varlock-docs-mcp": {
        "command": "npx",
        "args": ["mcp-remote", "https://docs.mcp.varlock.dev/mcp"]
      }
    }
  }
  ```

* Claude

  To add a server in Claude Code, run the following command:

  ```bash
  claude mcp add --transport http varlock-docs-mcp https://docs.mcp.varlock.dev/mcp
  ```

  See [Claude’s documentation](https://docs.claude.com/en/docs/claude-code/mcp#option-1%3A-add-a-remote-http-server) for more information.

* opencode

  To add a remote MCP server in Opencode, add the following to your `opencode.json` file:

  opencode.json

  ```json
  {
    "$schema": "https://opencode.ai/config.json",
    "mcp": {
      "varlock-docs-mcp": {
        "type": "remote",
        "url": "https://docs.mcp.varlock.dev/mcp",
        "enabled": true,
      }
    }
  }
  ```

  See [Opencode’s documentation](https://opencode.ai/docs/mcp-servers/#remote) for more information.

* VS Code

  To add a remote MCP server in VS Code, add the following to your `.vscode/mcp.json` file:

  .vscode/mcp.json

  ```json
  {
    "servers": {
      "varlock-docs-mcp": {
        "type": "http",
        "url": "https://docs.mcp.varlock.dev/mcp"
      }
    }
  }
  ```

  See [VS Code’s documentation](https://code.visualstudio.com/docs/copilot/customization/mcp-servers) for more information.

## Next Steps

[Section titled “Next Steps”](#next-steps)

* Learn more about [varlock’s environment specification](/env-spec/overview)
* Explore [available data types](/reference/data-types) for validation
* Check out [function reference](/reference/functions) for external integrations
* Read about [secrets management](/guides/secrets) best practices

# Migrate from dotenv

> How to migrate from dotenv (CLI and npm package) to varlock

## Why migrate from dotenv?

[Section titled “Why migrate from dotenv?”](#why-migrate-from-dotenv)

* **Validation**: Catch misconfigurations early with schema-driven validation.
* **Security**: Redact secrets and prevent accidental leaks.
* **Type-safety**: Generate types automatically for your config.
* **External secrets**: Load secrets from providers like 1Password, AWS, and more.

***

## Migrating from dotenvx CLI

[Section titled “Migrating from dotenvx CLI”](#migrating-from-dotenvx-cli)

If you use `dotenvx` via the CLI, you can switch to `varlock run`:

```bash
# Before (dotenv CLI)
dotenvx run -- node app.js


# env specific
dotenvx run -f .env.staging -- node app.js


# install varlock
brew install dmno-dev/tap/varlock


# After (varlock CLI)
varlock run -- node app.js


# To specify an environment, set your env flag (see your .env.schema)
APP_ENV=staging varlock run -- node app.js
```

> You can use multiple `.env` files (see [Environments guide](/guides/environments)).

***

## Migrating from dotenv npm package

[Section titled “Migrating from dotenv npm package”](#migrating-from-dotenv-npm-package)

Initialize your project with `varlock init` to install `varlock` and generate a `.env.schema` from any existing `.env` files.

* npm

  ```bash
  npx varlock init
  ```

* pnpm

  ```bash
  pnpm dlx varlock init
  ```

* bun

  ```bash
  bunx varlock init
  ```

* vlt

  ```bash
  vlx varlock init
  ```

* yarn

  ```bash
  yarn dlx varlock init
  ```

Then to use `varlock` in your code, you can replace `dotenv/config` with `varlock/auto-load`:

index.js

```diff
// Before (dotenv)
 import 'dotenv/config';
 import 'varlock/auto-load';
```

Finally, you can remove `dotenv` from your dependencies:

* npm

  ```bash
  npm uninstall dotenv
  ```

* pnpm

  ```bash
  pnpm remove dotenv
  ```

* bun

  ```bash
  bun remove dotenv
  ```

* yarn

  ```bash
  yarn remove dotenv
  ```

* vlt

  ```bash
  vlt uninstall dotenv
  ```

## Using overrides

[Section titled “Using overrides”](#using-overrides)

If `dotenv` is being used under the hood of one of your dependencies, you can use `overrides` to seamlessly swap in `varlock` instead.

* npm

  See [NPM overrides docs](https://docs.npmjs.com/cli/v9/configuring-npm/package-json#overrides)

  package.json

  ```diff
  {
    +"overrides": {
      +"other-dep": {
        +"dotenv": "npm:varlock"
  +    }
  +  }
  }
  ```

* yarn

  See [yarn resolutions docs](https://yarnpkg.com/configuration/manifest#resolutions)

  package.json

  ```diff
  {
    +"resolutions": {
      +"**/dotenv": "npm:varlock"
  +  },
  }
  ```

  **In a monorepo, this override must be done in the monorepo’s root package.json file!**

* pnpm

  * pnpm version 10+

    See [pnpm v10 overrides docs](https://pnpm.io/settings#overrides)

    pnpm-workspace.yaml

    ```diff
    +overrides:
      +"dotenv": "npm:varlock"
    ```

    **This must be set in `pnpm-workspace.yaml`, which lives at the root of your repo, regardless of whether you are using a monorepo or not.**

  * pnpm version 9

    ### pnpm version 9

    [Section titled “pnpm version 9”](#pnpm-version-9)

    See [pnpm v9 overrides docs](https://pnpm.io/9.x/package_json#pnpmoverrides)

    package.json

    ```diff
    {
      +"pnpm": {
        +"overrides": {
          +"dotenv": "npm:varlock"
    +    }
    +  }
    }
    ```

    **In a monorepo, this override must be done in the monorepo’s root package.json file!**

* pnpm version 10+

  See [pnpm v10 overrides docs](https://pnpm.io/settings#overrides)

  pnpm-workspace.yaml

  ```diff
  +overrides:
    +"dotenv": "npm:varlock"
  ```

  **This must be set in `pnpm-workspace.yaml`, which lives at the root of your repo, regardless of whether you are using a monorepo or not.**

* pnpm version 9

  ### pnpm version 9

  [Section titled “pnpm version 9”](#pnpm-version-9)

  See [pnpm v9 overrides docs](https://pnpm.io/9.x/package_json#pnpmoverrides)

  package.json

  ```diff
  {
    +"pnpm": {
      +"overrides": {
        +"dotenv": "npm:varlock"
  +    }
  +  }
  }
  ```

  **In a monorepo, this override must be done in the monorepo’s root package.json file!**

***

## Further reading

[Section titled “Further reading”](#further-reading)

* [Environments guide](/guides/environments)
* [Schema guide](/guides/schema)
* [Reference: CLI commands](/reference/cli-commands)
* [Reference: Item decorators](/reference/item-decorators)

# Plugins

> Using plugins with varlock

Plugins allow extending the functionality of Varlock. Specifically they may introduce new [root decorators](/reference/root-decorators/), [item decorators](/reference/item-decorators/), [data types](/reference/data-types/), and [resolver functions](/reference/functions/).

1Password plugin example

```env-spec
# @plugin(@varlock/1password-plugin) # load + install plugin
# @initOp(token=$OP_TOKEN, allowAppAuth=true) # init via custom root decorator
# ---
# @type=opServiceAccountToken # custom data type
OP_TOKEN=
# @sensitive
XYZ_API_KEY=op(op://api-prod/xyz/api-key) # custom resolver function
```

This unlocks use cases like:

* loading values from cloud providers or locally running services
* adding domain-specific validation/coercion logic via custom data types
* generating values dynamically via custom resolver functions

Plugins are authored in TypeScript and can be loaded via local files, or from package registries like npm. Varlock will handle downloading and caching plugins automatically.

Plugin authoring SDKs coming soon

Plugin authoring SDKs are still in development. For now, only official Varlock plugins are available for use.

Please reach out on [Discord](https://chat.dmno.dev) if you are interested in developing your own plugins.

## Plugin installation

[Section titled “Plugin installation”](#installation)

Plugins are loaded using their npm package name, and an optional version specifier. The version can be a fixed version or a [simple semver range](https://devhints.io/semver), similar to what is used in `package.json` files (e.g., `1.2.3`,`1.x`, `^1.2.3`, etc).

You may omit the version specifier only if your project has a `package.json` file - in which case the version installed in your `node_modules` directory will be used. If you add a version specifier AND it is installed locally, the local version will be used unless it does not satisfy the specified version/range - in which case an error will be thrown.

.env.schema

```env-spec
# @plugin(@varlock/a-plugin)        # use installed version
# @plugin(@varlock/b-plugin@1.2.3)  # pinned to v1.2.3
# @plugin(@varlock/c-plugin@^2.3.4) # use latest v2.3.x
```

Only `@varlock/*` plugins supported for now

For now, only official Varlock plugins under the `@varlock` npm scope are supported. We plan to support third-party plugins in the future, along with additional plugin source types (e.g., jsr, git, http, etc.).

## Plugin scope

[Section titled “Plugin scope”](#plugin-scope)

Plugins are loaded globally, and the additional functionality they provide will be available in all `.env` files in your project. Only a single `@plugin()` decorator is needed to load the plugin, even if multiple files use its functionality. If a plugin is loaded in multiple files, no error will be thrown, as long as they all use the same version.

Note that plugins will not be loaded from an inactive file - for example an environment-specific file that does not match the current environment, or one that uses the [`@disable` root decorator](/reference/root-decorators/#disable).

No specific namespacing or prefixes are enforced, and any naming conflicts will trigger an error, but plugins will use specific names to avoid conflicts.

## Initialization

[Section titled “Initialization”](#initialization)

Plugins are initialized using custom root decorators that they introduce. In some cases, no specific initialization is needed, and in others, you may need to initialize multiple instances of a plugin with different options, referred to by some identifier. How (or if) a plugin needs to be initialized depends on the specific plugin and can depend on the the external service’s data/auth model.

A plugin initialization root decorator is used to set IDs, toggle features, and wire up auth. Note that sensitive data should be passed in via references to config items within your schema.

Plugin initialization example

```env-spec
# @initOp(account=acmeco, token=$OP_TOKEN, allowAppAuth=forEnv(dev))
# ---
# @type=opServiceAccountToken @sensitive
OP_TOKEN=
```

### Multiple plugin instances

[Section titled “Multiple plugin instances”](#multiple-plugin-instances)

In secret storage tools, you should segment your data to follow the [*principle of least privilege*](https://en.wikipedia.org/wiki/Principle_of_least_privilege), so that different environments/services/devs only have access to the minimal secrets they need. At the very least, this usually means splitting your extra sensitive prod secrets from everything else, but it can be as fine-grained as needed.

We cannot always assume that you won’t need access to multiple segments at the same time. In these cases, a plugin may be designed to be initialized multiple times with some kind of id parameter. Resolver functions and decorators can then accept an additional parameter to specify which instance to use.

.env.schema

```env-spec
# @plugin(@varlock/1password-plugin)
# @initOp(id=dev, token=$OP_TOKEN_DEV, allowAppAuth=forEnv(dev))
# @initOp(id=prod, token=$OP_TOKEN_PROD, allowAppAuth=false);
# ---
# @type=opServiceAccountToken @sensitive
OP_TOKEN_DEV=
# @type=opServiceAccountToken @sensitive
OP_TOKEN_PROD=
XYZ_API_KEY=op(dev, op://api-creds-dev/xyz/api-key)
```

.env.production

```env-spec
XYZ_API_KEY=op(prod, op://api-creds-prod/xyz/api-key)
```

*While the 1Password plugin can be set up using a single instance (using a higher scoped service account for prod) you might want to use multiple instances if you want to make sure you don’t accidentally access prod secrets while working locally.*

## Usage

[Section titled “Usage”](#usage)

Once installed, all decorators, data types, and resolver functions provided by the plugin will be available for use within your `.env` files. These are available globally, and ordering is not important.

Some decorators or resolver functions may require the plugin to be initialized and will throw an error if not set up properly.

Please refer to the specific plugin’s documentation for details on usage.

# Schema

> Using the schema to manage your environment variables

One of the core features of varlock is its schema-driven approach to environment variables - which is best when shared with your team and committed to version control. We recommend creating a new `.env.schema` file to hold schema info set by [config item decorators](/reference/item-decorators), non-sensitive default values, and [root decorators](/reference/root-decorators) to specify global settings that affect `varlock` itself.

This schema should include all of the environment variables that your application depends on, along with comments and documentation about them, and decorators which affect coercion, validation, and generated types / documentation.

The more complete your schema is, the more validation and coercion `varlock` can perform, and the more it can help you catch errors earlier in your development cycle.

> Running [`varlock init`](/reference/cli-commands#init) will attempt to convert an existing `.env.example` file into a `.env.schema` file. It must be reviewed, but it should be a good starting point.

## Root Decorators

[Section titled “Root Decorators”](#root-decorators)

The *header* section of a `.env` file is a comment block at the beginning of the file that ends with a divider. Within this header, you can use [root decorators](/reference/root-decorators) to specify global settings and default behavior for all config items.

.env.schema

```env-spec
# This is the header, and may contain root decorators
# @currentEnv=$APP_ENV
# @defaultSensitive=false @defaultRequired=false
# @generateTypes(lang=ts, path=env.d.ts)
# ---


# This is a config item comment block and may contain decorators which affect only the item
# @required @type=enum(dev, test, staging, prod)
APP_ENV=dev
```

More details:

* [Root decorators reference](/reference/root-decorators)

## Config Items

[Section titled “Config Items”](#config-items)

Config items are the environment variables that your application depends on. Like normal `.env` syntax, each item is a key-value pair of the form `KEY=value`. The key is the name of the environment variable, and a value may be specified or not.

While simply enumerating all of them in your `.env.schema` is useful (like a `.env.example` file), [@env-spec](/env-spec/) allows us to attach additional comments and [item decorators](/reference/item-decorators), making our schema much more powerful.

### Item Values

[Section titled “Item Values”](#item-values)

Values may be static, or set using [functions](/reference/functions/), which can facilitate loading values from external sources without exposing any sensitive values.

**Quote rules:**

* Static values can be wrapped in quotes or not — all quotes styles (`` ` ``, `"`, `'`) are supported
* Values wrapped in single quotes do not support [expansion](#ref-expansion)
* Single line values may not contain newlines, but `\n` will be converted to an actual newline except in single quotes
* Multiline values can be wrapped in ` ``` `, `"""`. Also supported is `"` and `'` but not recommended.
* Unquoted values will be parsed as a number/boolean/undefined where possible (`ITEM=foo` -> `"foo"`, while `ITEM=true` -> `true`), however data-types may further coerce values
* No value (undefined) and empty string ("") are distinct

.env.schema

```env-spec
NO_VALUE= # will resolve to undefined
EMPTY_STRING_VALUE="" # will resolve to empty string
STATIC_VALUE_UNQUOTED=quotes are optional # but are recommended!
STATIC_VALUE_QUOTED="#hashtag" # and are necessary in some cases
BOOLEAN_VALUE=true
NUMERIC_VALUE=123.456
FUNCTION_VALUE=exec(`op read "op://api-config/item/credential"`)
EXPANSION_VALUE=${OTHER_VAR}-suffix
MULTILINE_VALUE="""
multiple
lines
"""
```

### Item comments

[Section titled “Item comments”](#item-comments)

Comments are used to attach additional documentation and metadata to config items using [item decorators](/reference/item-decorators). This additional metadata is used by varlock to perform validation, coercion, and generate types / documentation.

Multiple comment lines *directly* preceeding an item will be attached to that item. A blank line or a divider (`# ---`) break a comment block, and detach it from the following config item. Comment lines can either contain regular comments or [item decorators](/reference/item-decorators). Note that if a line does not start with a decorator, it will be treated as a regular comment.

```env-spec
# description of item can be multiple lines
# this @decorator will be ignored because the line does not start with @
# @sensitive=false @required # decorator lines can end with a comment
# @type=string(startsWith=pk-) # multiple lines of decorators are allowed
SERVICE_X_PUBLISHABLE_KEY=pk-abc123
```

More details:

* [Item decorators reference](/reference/item-decorators)
* [@type data types reference](/reference/data-types)
* [Functions reference](/reference/functions)

## Resolver Functions

[Section titled “Resolver Functions”](#resolver-functions)

You may use [resolver functions](/reference/functions/) instead of static values within both config items and decorator values.

Functions may be composed together to create more complex value resolution logic.

```env-spec
# @required=forEnv(prod)
API_DOMAIN=if(eq(ref(APP_ENV), prod), api.myapp.com, staging-api.myapp.com)
```

### Referencing other values

[Section titled “Referencing other values”](#ref-expansion)

Within values and function args, you often need to reference other env vars within your schema.

You may use [`ref()`](/reference/functions/#ref) but we support *expansion* syntax (like many other .env tools) for convenience.

Both `$ITEM` and `${ITEM}` are equivalent to `ref(ITEM)`.

We recommend using the bracket version only when used within a larger string.

```env-spec
WITH_BRACKETS=exec(`op read "op://${OP_VAULT_NAME}/service/api-key"`)
NO_BRACKETS=fallback($OTHERVAR, foo)
```

Read more about string expansion in the [@env-spec reference](/env-spec/reference/#expansion).

## Decorator details

[Section titled “Decorator details”](#decorator-details)

### Functions vs single use

[Section titled “Functions vs single use”](#functions-vs-single-use)

Most decorators take a single value (e.g., `@sensitive`, `@currentEnv`) and may be used only once per item (or file in the case of a root decorator). Some decorators however, are function calls (e.g., `@docs()`, `@import()`) and may be called multiple times.

```env-spec
# @sensitive=true
# @docs(https://xyzapi.com/docs/auth)
# @docs(https://xyzapi.com/manage-api-keys)
XYZ_API_KEY=
```

### Value resolution

[Section titled “Value resolution”](#value-resolution)

Values passed to decorators will be resolved, meaning if a decorator is expecting a boolean, either a static `true`/`false` or a [resolver function](/reference/functions) that resolves to a boolean may be used.

```env-spec
# @required=false
NEVER_REQUIRED=


# @required=forEnv(prod) # resolves to true/false depending on the current environment
REQUIRED_FOR_PROD=
```

# Secrets management

> Best practices for managing secrets and sensitive environment variables with varlock

`varlock` uses the term *sensitive* to describe any value that should not be exposed to the outside world. This includes secret api keys, passwords, and other generally sensitive information. Instead of relying on prefixes (e.g., `NEXT_PUBLIC_`) to know which items may be “public”, varlock relies on `@decorators` to mark sensitive items explicitly.

Coming soon

We’ll be adding support for our own trustless, cloud-based secret storage in the very near future.

## Marking `@sensitive` items

[Section titled “Marking @sensitive items”](#marking-sensitive-items)

Whether each item is sensitive or not is controlled by the [`@defaultSensitive`](/reference/root-decorators/#defaultsensitive) root decorator and the [`@sensitive`](/reference/item-decorators/#sensitive) item decorator. Whether you want to default to sensitive or not, or infer based on key names is up to you. For example:

.env.schema

```env-spec
# @defaultSensitive=false
# ---
# not sensitive by default (because of the root decorator)
NON_SECRET_FOO=
# @sensitive # explicitly marking this item as sensitive
SECRET_FOO=
```

## Loading secrets from external sources

[Section titled “Loading secrets from external sources”](#loading-secrets-from-external-sources)

### Using plugins (recommended)

[Section titled “Using plugins (recommended)”](#using-plugins-recommended)

`varlock` provides official plugins for popular secret management platforms, offering a seamless and type-safe way to fetch secrets directly in your `.env` files.

Available plugins include:

* [1Password](/plugins/1password/)
* [AWS Secrets Manager & Parameter Store](/plugins/aws-secrets/)
* [Azure Key Vault](/plugins/azure-key-vault/)
* [Bitwarden](/plugins/bitwarden/)
* [Google Secret Manager](/plugins/google-secret-manager/)
* [Infisical](/plugins/infisical/)

See the [plugins overview](/plugins/overview/) for the complete list.

Plugins are able to register new decorators and resolver functions that declaratively fetch secrets:

```env-spec
# Install and initialize the 1Password plugin
# @plugin(@varlock/1password-plugin)
# @initOp(token=$OP_TOKEN, allowAppAuth=forEnv(dev))
# ---


# Load secrets using the op() resolver function
# @sensitive @required
MY_SECRET=op(op://my-vault/item-name/field-name)
```

Benefits of using plugins:

* Declarative secret references safe to check into version control
* Built-in validation and type safety applied to fetched values
* Built-in authentication handling
* Better error messages and debugging
* Platform-specific features (e.g., biometric unlock for 1Password)

See each plugin’s documentation for detailed setup instructions.

### Using exec() as a fallback

[Section titled “Using exec() as a fallback”](#using-exec-as-a-fallback)

For cases where a plugin doesn’t exist or you need custom logic, `varlock` supports fetching secrets via CLI commands using `exec()` function syntax.

```env-spec
# A secret fetched via CLI
# @sensitive @required
MY_SECRET=exec(`op read "op://devTest/myVault/credential"`);
```

This approach works with any CLI tool, ensuring no secrets are left in plaintext on your system, even if they are gitignored.

### Bulk injection with `@setValuesBulk()`

[Section titled “Bulk injection with @setValuesBulk()”](#bulk-injection-with-setvaluesbulk)

For some secret management platforms, you may already be setting key names that match your environment variable names - in which case, wiring up each value can feel like a lot of boilerplate.

In case like this, you can set many values at once using the [`@setValuesBulk()`](/reference/root-decorators/#setvaluesbulk) root decorator.

For example, using 1Password, you could store a .env style blob within a text field, or you could fetch values from their new environments tool.

.env.schema

```env-spec
# fetch a dotenv style blob within a text field
# @setValuesBulk(op("op://vault/field/item"))
#
# load values in a 1Password environment
# @setValuesBulk(opLoadEnvironment(your-environment-id), createMissing=true)
#
# load all secrets from an Infisical project environment
# @setValuesBulk(infisicalBulk())
#
# load Infisical secrets filtered by path or tag
# @setValuesBulk(infisicalBulk(path="/database", tag="backend"))
#
# Fetch all secrets from HashiCorp Vault as JSON
# @setValuesBulk(exec("vault kv get -format=json secret/myapp"), format=json)
# ---
```

The bulk values are injected at the precedence level of the file containing the decorator — so `.env.local` and `process.env` will still override them as expected. See the [reference docs](/reference/root-decorators/#setvaluesbulk) for full details.

## Security enhancements

[Section titled “Security enhancements”](#security-enhancements)

Unlike other tools where you have to rely on pattern matching to detect *sensitive-looking* data, `varlock` knows exactly which values are sensitive, and can take extra precautions to protect them.

For example, some of the features supported by our libraries and integrations:

* Redact sensitive values from logs
* Scan client-facing bundled code at build time
* Scan outgoing HTTP responses at runtime
* Pre-commit git hooks to keep sensitive values out of version control

## Scanning for leaked secrets

[Section titled “Scanning for leaked secrets”](#scanning-for-leaked-secrets)

The [`varlock scan` command](/reference/cli-commands/#scan) checks your project files for any plaintext occurrences of your `@sensitive` values. It loads your varlock config, resolves all sensitive values, and then searches through files to detect leaks.

```bash
varlock scan
```

This is intended to be used as a pre-commit git hook to prevent accidentally committing secrets into version control. If no sensitive values are found in plaintext, it exits successfully. If any are detected, it reports the file, line number,and which secret was found, then exits with a non-zero status code.

### Scanning modes

[Section titled “Scanning modes”](#scanning-modes)

* `varlock scan` - default mode, scans all files except gitignored ones
* `varlock scan --include-ignored` - scans all files including gitignored ones
* `varlock scan --staged` - scans only the files you have staged for commit

#### Automatic setup

[Section titled “Automatic setup”](#automatic-setup)

The easiest way to set this up is:

```bash
varlock scan --install-hook
```

This will detect if you use a hook manager (like [husky](https://typicode.github.io/husky/) or [lefthook](https://github.com/evilmartians/lefthook)) and provide appropriate instructions. If no hook manager is detected, it will create a `.git/hooks/pre-commit` script for you.

Note

If varlock is installed as a project dependency (rather than a standalone binary), the generated hook command will automatically be prefixed with your package manager’s exec command (e.g., `npx varlock scan` or `bunx varlock scan`).

#### Manual setup

[Section titled “Manual setup”](#manual-setup)

If you prefer to set it up yourself, add the following to your pre-commit hook:

**Plain git hook** (`.git/hooks/pre-commit`):

```bash
#!/bin/sh
varlock scan
```

Make sure the hook file is executable:

```bash
chmod +x .git/hooks/pre-commit
```

**With husky** (`.husky/pre-commit`):

```bash
varlock scan
```

**With lefthook** (`lefthook.yml`):

```yaml
pre-commit:
  commands:
    varlock-scan:
      run: varlock scan
```

Tip

If you already have an existing pre-commit hook, just add `varlock scan` as an additional line in the script. It will exit with a non-zero code if any secrets are found, which will abort the commit.

# Telemetry

> Learn about varlock's anonymous usage analytics and how to opt out

The `varlock` CLI collects **anonymous telemetry data** about usage to help us understand how the tool is being used and to make it better. Participation is optional, and you may opt-out at any time.

## What We Collect

[Section titled “What We Collect”](#what-we-collect)

We track general usage information, and the environment in which `varlock` is being used. Specifically we collect *anonymous* information about:

* Which varlock command is being invoked
* Version and settings for varlock, Node.js, and any plugins
* General system/machine information
* Anonymous user + project ID

**We will never collect any of your config files or environment variables.**

## How to Opt Out

[Section titled “How to Opt Out”](#how-to-opt-out)

You can opt out of analytics in three ways:

### Using the CLI

[Section titled “Using the CLI”](#using-the-cli)

Run the following command to permanently opt out:

* npm

  ```bash
  npm exec -- varlock telemetry disable
  ```

* pnpm

  ```bash
  pnpm exec -- varlock telemetry disable
  ```

* bun

  ```bash
  bun exec varlock telemetry disable
  ```

* vlt

  ```bash
  vlx -- varlock telemetry disable
  ```

* yarn

  ```bash
  yarn exec -- varlock telemetry disable
  ```

* standalone binary

  ```bash
  varlock telemetry disable
  ```

This will create/update a configuration file saving your preference at `$XDG_CONFIG_HOME/varlock/config.json` (defaults to `~/.config/varlock/config.json`).

*You may re-enable telemetry by running `varlock telemetry enable`*

### Using an Environment Variable

[Section titled “Using an Environment Variable”](#using-an-environment-variable)

You can also opt out temporarily by setting the `VARLOCK_TELEMETRY_DISABLED` environment variable:

```bash
export VARLOCK_TELEMETRY_DISABLED=true
```

This could be set in a specific terminal session, while running a specific command, in a Dockerfile, or in a CI/CD pipeline.

### With a project config file

[Section titled “With a project config file”](#with-a-project-config-file)

You can also opt out at the project level by creating a `.varlock/config.json` file in your project root with the following content:

my-app/.varlock/config.json

```json
{
  "telemetryDisabled": true
}
```

## Privacy

[Section titled “Privacy”](#privacy)

* All analytics data is completely anonymous
* No personal or sensitive information is collected
* Data is only used to improve the product
* You can opt out at any time
* Analytics are handled by [PostHog](https://posthog.com/), a privacy-friendly analytics platform

## Data Usage

[Section titled “Data Usage”](#data-usage)

The anonymous usage data helps us:

* Understand which features are most used
* Identify areas for improvement
* Make informed decisions about future development
* Prioritize bug fixes and new features

If you have any questions about our analytics or privacy practices, please [start a discussion](https://github.com/dmno-dev/varlock/discussions) on GitHub.

# Astro

> How to integrate varlock with Astro for secure, type-safe environment management

[![](https://img.shields.io/npm/v/@varlock/astro-integration?label=%40varlock%2Fastro-integration\&color=9B55F5\&logo=npm)](https://www.npmjs.com/package/@varlock/astro-integration)

While Astro has [`astro:env`](https://docs.astro.build/en/guides/environment-variables/) to help with environment variables, we think Varlock has more to offer:

* Your `.env.schema` is not tied to JavaScript, and is a better place to store this schema info versus your `astro.config.*` file
* Facilitates loading and composing multiple `.env` files
* You can use validated env vars right away within your `astro.config.*` file
* Facilitates setting values and handling multiple environments, not just setting defaults
* More data types and options available
* Leak detection, log redaction, and more security guardrails

To integrate varlock into an Astro application, you must use our [`@varlock/astro-integration`](https://www.npmjs.com/package/@varlock/astro-integration) package, which is an [Astro integration](https://docs.astro.build/en/guides/integrations-guide/).

## Setup

[Section titled “Setup”](#setup)

Requirements

* Node.js v22 or higher
* Astro v4 or higher

1. **Install varlock and the Astro integration package**

   * npm

     ```bash
     npm install @varlock/astro-integration varlock
     ```

   * pnpm

     ```bash
     pnpm add @varlock/astro-integration varlock
     ```

   * bun

     ```bash
     bun add @varlock/astro-integration varlock
     ```

   * yarn

     ```bash
     yarn add @varlock/astro-integration varlock
     ```

   * vlt

     ```bash
     vlt install @varlock/astro-integration varlock
     ```

2. **Run `varlock init` to set up your `.env.schema` file**

   This will guide you through setting up your `.env.schema` file, based on your existing `.env` file(s). Make sure to review it carefully.

   * npm

     ```bash
     npm exec -- varlock init
     ```

   * pnpm

     ```bash
     pnpm exec -- varlock init
     ```

   * bun

     ```bash
     bun exec varlock init
     ```

   * vlt

     ```bash
     vlx -- varlock init
     ```

   * yarn

     ```bash
     yarn exec -- varlock init
     ```

3. **Enable the Astro integration**

   You must add our `varlockAstroIntegration` to your `astro.config.*` file:

   astro.config.ts

   ```diff
   import { defineConfig } from 'astro/config';
   +import varlockAstroIntegration from '@varlock/astro-integration';


   export default defineConfig({
     integrations: [varlockAstroIntegration(), otherIntegration()],
   });
   ```

***

## Accessing environment variables

[Section titled “Accessing environment variables”](#accessing-environment-variables)

You can continue to use `import.meta.env.SOMEVAR` as usual, but we recommend using varlock’s imported `ENV` object for better type-safety and improved developer experience:

example.ts

```ts
import { ENV } from 'varlock/env';


console.log(import.meta.env.SOMEVAR); // 🆗 still works
console.log(ENV.SOMEVAR);             // ✨ recommended
```

#### Why use `ENV` instead of `import.meta.env`?

[Section titled “Why use ENV instead of import.meta.env?”](#why-use-env-instead-of-importmetaenv)

* Non-string values (e.g., number, boolean) are properly typed and coerced
* All non-sensitive items are replaced at build time (not just `VITE_` prefixed ones)
* Better error messages for invalid or unavailable keys
* Enables future DX improvements and tighter control over what is bundled

### Within `astro.config.*`

[Section titled “Within astro.config.\*”](#within-astroconfig)

It’s often useful to be able to access env vars in your Astro config. Without varlock, it’s a bit awkward, but varlock makes it dead simple - in fact it’s already available! Just import varlock’s `ENV` object and reference env vars via `ENV.SOME_ITEM` like you do everywhere else.

astro.config.ts

```diff
import { defineConfig } from 'astro/config';
import varlockAstroIntegration from '@varlock/astro-integration';
+import { ENV } from 'varlock/env';


+doSomethingWithEnvVar(ENV.FOO);


export default defineConfig({ /* ... */ });
```

TypeScript config

If you find you are not getting type completion on `ENV`, you may need to add your generated type files (usually `env.d.ts`) to your `tsconfig.json`’s `include` array.

### Within other scripts

[Section titled “Within other scripts”](#within-other-scripts)

Even in a static front-end project, you may have other scripts in your project that rely on sensitive config.

You can use [`varlock run`](/reference/cli-commands/#run) to inject resolved config into other scripts as regular env vars.

* npm

  ```bash
  npm exec -- varlock run -- node ./script.js
  ```

* pnpm

  ```bash
  pnpm exec -- varlock run -- node ./script.js
  ```

* bun

  ```bash
  bun exec varlock run -- node ./script.js
  ```

* vlt

  ```bash
  vlx -- varlock run -- node ./script.js
  ```

* yarn

  ```bash
  yarn exec -- varlock run -- node ./script.js
  ```

### Type-safety and IntelliSense

[Section titled “Type-safety and IntelliSense”](#type-safety-and-intellisense)

To enable type-safety and IntelliSense for your env vars, enable the [`@generateTypes` root decorator](/reference/root-decorators/#generatetypes) in your `.env.schema`. Note that if your schema was created using `varlock init`, it will include this by default.

.env.schema

```diff
+# @generateTypes(lang='ts', path='env.d.ts')
# ---
# your config items...
```

***

## Managing multiple environments

[Section titled “Managing multiple environments”](#managing-multiple-environments)

Varlock can load multiple *environment-specific* `.env` files (e.g., `.env.development`, `.env.preview`, `.env.production`) by using the [`@currentEnv` root decorator](/reference/root-decorators/#currentenv). **This is different than Astro/Vite’s default behaviour, which relies on it’s own [`MODE` flag](https://vite.dev/guide/env-and-mode.html#modes).**

Usually this env var will be defaulted to something like `development` in your `.env.schema` file, and you can override it by overriding the value when running commands - for example `APP_ENV=production vite build`. For a JavaScript based project, this will often be done in your `package.json` scripts.

package.json

```json
{
  "scripts": {
    "dev": "astro dev",
    "build": "APP_ENV=production astro build",
    "preview": "APP_ENV=production vite preview",
  }
}
```

In some cases, you could also set the current environment value based on other vars already injected by your CI platform, like the current branch name. See the [environments guide](/guides/environments) for more information.

## Managing sensitive config values

[Section titled “Managing sensitive config values”](#managing-sensitive-config-values)

Astro uses the `PUBLIC_` prefix to determine which env vars are public (bundled for the browser). Varlock decouples the concept of being *sensitive* from key names, and instead you control this with the [`@defaultSensitive`](/reference/root-decorators/#defaultsensitive) root decorator and the [`@sensitive`](/reference/item-decorators/#sensitive) item decorator. See the [secrets guide](/guides/secrets) for more information.

Set a default and explicitly mark items:

.env.schema

```diff
+# @defaultSensitive=false
# ---
NON_SECRET_FOO= # sensitive by default
# @sensitive
SECRET_FOO=
```

Or if you’d like to continue using Astro’s prefix behavior:

.env.schema

```diff
+# @defaultSensitive=inferFromPrefix('PUBLIC_')
# ---
FOO= # sensitive
PUBLIC_FOO= # non-sensitive, due to prefix
```

Bundling behavior

All non-sensitive items are bundled at build time via `ENV`, while `import.meta.env` replacements continue to only include `PUBLIC_`-prefixed items.

### Leak Detection

[Section titled “Leak Detection”](#leak-detection)

This integration will automatically inject a new middleware that scans outgoing http responses for any sensitive values.

***

## Reference

[Section titled “Reference”](#reference)

* [Root decorators reference](/reference/root-decorators)
* [Item decorators reference](/reference/item-decorators)
* [Functions reference](/reference/functions)
* [Astro’s environment variable docs](https://docs.astro.build/en/guides/environment-variables/)

# Bun

> How to integrate Varlock with a Bun-powered JavaScript project

For the most part, Varlock just works with Bun the same way it works with Node.js, and other JavaScript integrations work the same way.

### Conflicts with Bun’s .env loading

[Section titled “Conflicts with Bun’s .env loading”](#conflicts-with-buns-env-loading)

Bun does its own automatic loading of `.env` files, based on the current value of `NODE_ENV` (or `BUN_ENV`), which it defaults to `development` if not set. This causes problems when bun decides to load `.env.development` and passes those env vars into varlock.

The best way to fix this is to [disable bun’s automatic loading of `.env` files](https://bun.com/docs/runtime/environment-variables#disabling-automatic-env-loading) in your `bunfig.toml` file:

bunfig.toml

```toml
env = false
```

You may also use the `--no-env-file` CLI flag when invoking scripts with `bun`/`bunx`.

Note that if you are building a standalone executable using `bun build`, you can use the `--no-compile-autoload-dotenv` flag to disable this behavior in the final executable.

### Using a preload script (optional)

[Section titled “Using a preload script (optional)”](#using-a-preload-script-optional)

One option we have with bun is to use a [preload script](https://bun.com/docs/runtime/bunfig#preload), configured in `bunfig.toml`. If you do this, you will no longer have to use `bun run varlock run -- yourscript` or use `import 'varlock/auto-load'` in your code!

bunfig.toml

```toml
preload = ["varlock/auto-load"]
```

Do not use preload with framework integrations

Note that you should not do this if using a framework integration, as those integrations watch your `.env` files to trigger live-reloading.

# Cloudflare Workers

> How to integrate varlock with Cloudflare Workers and Wrangler for secure, type-safe environment management

Varlock provides a robust solution for managing environment variables in Cloudflare Workers, offering validation, type safety, and security features that go beyond Cloudflare’s built-in environment variable handling.

## Two approaches

[Section titled “Two approaches”](#two-approaches)

There are two main ways to use varlock with Cloudflare Workers:

1. **With Vite plugin** (recommended) - Use the [Varlock Vite integration](/integrations/vite/) alongside the [Cloudflare Workers Vite plugin](https://developers.cloudflare.com/workers/vite-plugin/)
2. **Without Vite** - Use Wrangler’s `vars` and `secrets` directly

## Approach 1: Using the Vite plugin (recommended)

[Section titled “Approach 1: Using the Vite plugin (recommended)”](#approach-1-using-the-vite-plugin-recommended)

Using the [Cloudflare Workers Vite plugin](https://developers.cloudflare.com/workers/vite-plugin/) allows more flexiblity in the bundling process. We can then use the [Varlock Vite plugin](/integrations/vite/) to bundle resolved environment variables into your built code, making it safe and straightforward to use.

Even though it may feel a bit strange to use Vite on a backend-only project, it is the [recommended approach](https://developers.cloudflare.com/workers/development-testing/wrangler-vs-vite/#when-to-use-the-cloudflare-vite-plugin) by Cloudflare when you need more flexibility in your build process.

Bundled secrets

**Using this method, your sensitive values will never be exposed to any client-side code.**

However, within the Cloudflare dashboard, your team members can view the bundled source code, and you must be mindful of sending source maps to external services.

### Setup

[Section titled “Setup”](#setup)

1. **Install varlock and the Vite integration package**

   * npm

     ```bash
     npm install @varlock/vite-integration varlock
     ```

   * pnpm

     ```bash
     pnpm add @varlock/vite-integration varlock
     ```

   * bun

     ```bash
     bun add @varlock/vite-integration varlock
     ```

   * yarn

     ```bash
     yarn add @varlock/vite-integration varlock
     ```

   * vlt

     ```bash
     vlt install @varlock/vite-integration varlock
     ```

2. **Run `varlock init` to set up your `.env.schema` file**

   This will guide you through setting up your `.env.schema` file, based on your existing `.env` file(s). Make sure to review it carefully.

   * npm

     ```bash
     npm exec -- varlock init
     ```

   * pnpm

     ```bash
     pnpm exec -- varlock init
     ```

   * bun

     ```bash
     bun exec varlock init
     ```

   * vlt

     ```bash
     vlx -- varlock init
     ```

   * yarn

     ```bash
     yarn exec -- varlock init
     ```

3. **Enable the Vite config plugin**

   Add the Varlock Vite plugin alongside the Cloudflare Workers Vite plugin to your `vite.config.*` file:

   vite.config.ts

   ```diff
   import { defineConfig } from 'vite';
   +import { varlockVitePlugin } from '@varlock/vite-integration';


   export default defineConfig({
     plugins: [
       +varlockVitePlugin(),
       cloudflare(),
       // other plugins ...
     ],
   });
   ```

   The varlock plugin will automatically detect Cloudflare Workers and use the `resolved-env` mode, which injects the fully resolved environment data into your built code.

### Update package.json scripts

[Section titled “Update package.json scripts”](#update-packagejson-scripts)

If you were not already using the Vite plugin, you’ll also need to update your `package.json` scripts:

package.json

```json
{
  "scripts": {
    "dev": "vite dev",
    "build": "vite build",
    "preview": "npm run build && vite preview",
    "deploy": "npm run build && wrangler deploy"
  }
}
```

You can see more details in the [Cloudflare’s Vite getting started guide](https://developers.cloudflare.com/workers/vite-plugin/get-started/).

***

## Approach 2: Using Wrangler vars and secrets (without Vite)

[Section titled “Approach 2: Using Wrangler vars and secrets (without Vite)”](#approach-2-using-wrangler-vars-and-secrets-without-vite)

For local development, you can use Wrangler’s `--var` flag to pass the entire resolved env:

package.json

```diff
{
  "scripts": {
    -"dev": "wrangler dev",
    +"dev": "wrangler dev --var \"__VARLOCK_ENV:$(varlock load --format json-full)\"",
  }
}
```

For deployments we can use the same method. Note that you may need to set your current env, either within the deploy command or infer it from the CI environment (see below).

package.json

```diff
{
  "scripts": {
    -"deploy": "wrangler deploy",
    +"deploy": "wrangler deploy --var \"__VARLOCK_ENV:$(varlock load --format json-full)\"",
  }
}
```

Team visibility

For deployments, when using `--var`, the environment variables will be visible in the Cloudflare dashboard to your team members. For higher security, consider using the secrets approach below.

### Using Cloudflare secrets

[Section titled “Using Cloudflare secrets”](#using-cloudflare-secrets)

To attach the resolved env blob as a secret, you must use a 3-step deployment process using Wrangler’s [versions commands](https://developers.cloudflare.com/workers/wrangler/commands/#versions):

1. Upload new deployment version of your bundled code
2. Create a second version with the secret attached
3. Promote the latest version to be the active deployment

```bash
# Step 1: Create a version that's not deployed immediately
# note the empty __VARLOCK_ENV so it will not reuse existing config
npx wrangler versions upload --var "__VARLOCK_ENV:{}"


# Step 2: Attach a new secret containing the resolved env as a single JSON object
echo "$(APP_ENV=prod npx varlock load --format json-full)" | npx wrangler versions secret put __VARLOCK_ENV


# Step 3: Activate the deployment
npx wrangler versions deploy --version-id=$(npx wrangler versions list | grep -oE 'Version ID:[[:space:]]*[a-f0-9-]+' | tail -n1 | sed 's/Version ID:[[:space:]]*//') --percentage=100 --yes
```

Future improvement

Cloudflare is working on the ability to push secrets atomically with the deploy command. See [this pull request](https://github.com/cloudflare/workers-sdk/pull/10896) for updates. Feel free to comment and tell them it is important!

## Accessing environment variables

[Section titled “Accessing environment variables”](#accessing-environment-variables)

Because we are not re-emitting all env vars into the Cloudflare’s vars/secrets, you must using varlock’s `ENV` object instead of Cloudflare’s built-in environment variable access:

src/index.ts

```ts
// ❌ Do not use Cloudflare's built-in env
import { env } from "cloudflare:workers";
console.log(env.API_KEY);


// ✅ Recommended - uses varlock's ENV
import { ENV } from 'varlock/env';
console.log(ENV.API_KEY);
```

***

## Managing Multiple Environments

[Section titled “Managing Multiple Environments”](#managing-multiple-environments)

Varlock can load multiple *environment-specific* `.env` files (e.g., `.env.development`, `.env.preview`, `.env.production`) by using the [`@currentEnv` root decorator](/reference/root-decorators/#currentenv).

If you are using Cloudflare’s CI, you can use the current branch name (`WORKERS_CI_BRANCH`) to determine the environment:

.env.schema

```env-spec
# @currentEnv=$APP_ENV
# ---
WORKERS_CI_BRANCH=
# @type=enum(development, preview, production, test)
APP_ENV=remap($WORKERS_CI_BRANCH, production="main", preview=regex(.*), development=undefined)
```

For more information, see the [environments guide](/guides/environments).

# direnv

> Load validated environment variables into your shell with direnv and varlock

[direnv](https://direnv.net/) is a shell extension that automatically loads and unloads environment variables when you enter and leave a directory. By combining it with varlock, you can get validated, schema-driven environment variables loaded directly into your shell session.

Consider a deeper integration

For projects where you control the codebase, using one of varlock’s [framework integrations](/integrations/overview/) or the [JavaScript / Node.js integration](/integrations/javascript/) is usually a better fit than direnv. Those integrations wire validation, type safety, and leak protection directly into your build and runtime — rather than relying on shell-level injection. You can also use [`varlock run`](/reference/cli/#run) to inject env vars into any process without needing direnv. direnv is most useful when you need env vars available in your shell session itself, or when working with tools that cannot be launched via `varlock run`.

## How it works

[Section titled “How it works”](#how-it-works)

direnv works by executing a `.envrc` file in your project directory and capturing any exported variables into the current shell. Varlock’s `--format shell` flag outputs your resolved env vars as `export KEY=VALUE` lines that direnv can capture via `eval`.

.envrc

```bash
eval "$(varlock load --format shell)"
```

When you `cd` into your project, direnv runs this command and exports all your validated environment variables into the shell.

## Setup

[Section titled “Setup”](#setup)

1. **Install direnv**

   Follow the [official direnv installation guide](https://direnv.net/docs/installation.html) for your platform and shell, then hook it into your shell profile. For example, for bash:

   ```bash
   echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
   ```

2. **Create a `.envrc` file** in your project root

   .envrc

   ```bash
   watch_file .env .env.*
   eval "$(varlock load --format shell)"
   ```

   The `watch_file` line tells direnv to re-evaluate whenever any of your `.env` files change. Note that **new files added after the initial load will not be watched until you run `direnv reload`** — but this is rarely a concern since adding new env files is uncommon.

   Imported files outside the project directory

   If your `.env` files [import](/guides/import/) other files from outside the current directory, those external files will **not** be watched automatically. You would need to add additional `watch_file` entries for them, or run `direnv reload` manually after changing them.

3. **Allow the `.envrc` file**

   ```bash
   direnv allow
   ```

## How it looks

[Section titled “How it looks”](#how-it-looks)

Once set up, when you `cd` into your project directory, direnv automatically loads your varlock-validated environment:

```bash
$ cd my-project
direnv: loading .envrc
direnv: export +API_URL +DB_PASS +PORT
```

And when you leave the directory, those variables are automatically unloaded.

## Skip undefined values

[Section titled “Skip undefined values”](#skip-undefined-values)

By default, varlock outputs an empty assignment for undefined optional variables (e.g. `OPTIONAL_VAR=""`). If you prefer to skip undefined values entirely, use the `--compact` flag:

.envrc

```bash
watch_file .env .env.*
eval "$(varlock load --format shell --compact)"
```

## Troubleshooting

[Section titled “Troubleshooting”](#troubleshooting)

direnv strict mode

Some shells or direnv configurations run `.envrc` files in strict mode (`set -euo pipefail`). If `varlock load` exits with a non-zero code (e.g. due to a validation error), direnv will halt and show an error. This is intentional — it prevents your shell from loading a broken environment.

Loading errors

If your environment fails validation, run `varlock load` directly in your terminal to see the full colorized output and error details before direnv loads it.

# esbuild / tsup

> How to integrate Varlock with simple JS build tools like esbuild and tsup

Here is a simple example of an integration with [tsup](https://tsup.egoist.dev/).

tsup.config.ts

```ts
import { defineConfig } from 'tsup';
import 'varlock/auto-load';
import { getBuildTimeReplacements } from 'varlock';


export default defineConfig({
  // ...
  esbuildOptions(options) {
    options.define ||= {};
    Object.assign(options.define, getBuildTimeReplacements());
  },
});
```

# GitHub Actions

> Use Varlock in GitHub Actions to securely load and validate environment variables

[![GitHub Actions Marketplace](https://img.shields.io/badge/GitHub%20Actions-Marketplace-blue?logo=github)](https://github.com/marketplace/actions/varlock-environment-loader)

The Varlock GitHub Action provides a secure way to load and validate environment variables in your GitHub Actions workflows. It automatically detects and loads your `.env.schema` file and all relevant `.env.*` files, validates all environment variables against your schema, and exports them as either environment variables or a JSON blob for use in subsequent steps.

## Features

[Section titled “Features”](#features)

* 🔒 **Schema Validation**: Validates all environment variables against your `.env.schema` file
* 🚀 **Auto-installation**: Automatically installs varlock if not present
* 🔍 **Smart Detection**: Automatically loads `.env` and relevant `.env.*` files
* 🛡️ **Security**: Handles sensitive values as GitHub secrets
* 📊 **Flexible Output**: Export as environment variables or JSON blob

.env.schema not required

While you are encouraged to create a `.env.schema` file while using varlock, you can still use this GitHub Action without one. If you do not have a `.env.schema` file, the action will only load `.env`, since we won’t know what to use as your [environment flag](/guides/environments), and therefore which other `.env.*` files to load.

## Setup

[Section titled “Setup”](#setup)

1. **Create or update your `.env.schema` file**

   Make sure you have a `.env.schema` file in your repository that defines your environment variables and their validation rules.

   .env.schema

   ```env-spec
   # @currentEnv=$APP_ENV
   # @defaultSensitive=false @defaultRequired=false
   # @generateTypes(lang='ts', path='env.d.ts')
   # ---


   # Environment flag
   # @type=enum(development, staging, production)
   APP_ENV=development


   # Database configuration
   # @type=url @required
   DATABASE_URL=


   # API configuration
   # @type=string(startsWith=sk-) @sensitive
   API_KEY=


   # Feature flags
   # @type=boolean
   ENABLE_FEATURE_X=false
   ```

2. **Add the action to your workflow**

   .github/workflows/deploy.yml

   ```yaml
   name: Deploy Application


   on:
     push:
       branches: [main]


   jobs:
     deploy:
       runs-on: ubuntu-latest


       steps:
         - name: Checkout code
           uses: actions/checkout@v4


         - name: Load environment variables
           uses: dmno-dev/varlock@v1
   ```

## Inputs

[Section titled “Inputs”](#inputs)

| Input               | Description                                    | Required | Default |
| ------------------- | ---------------------------------------------- | -------- | ------- |
| `working-directory` | Directory containing `.env.schema` files       | No       | `.`     |
| `show-summary`      | Show a summary of loaded environment variables | No       | `true`  |
| `fail-on-error`     | Fail the action if validation errors are found | No       | `true`  |
| `output-format`     | Output format: `env` or `json`                 | No       | `env`   |

## Outputs

[Section titled “Outputs”](#outputs)

| Output        | Description                                                                                    |
| ------------- | ---------------------------------------------------------------------------------------------- |
| `summary`     | Summary of loaded environment variables using `varlock load`                                   |
| `error-count` | Number of validation errors found                                                              |
| `json-env`    | JSON blob containing all environment variables (only available when `output-format` is `json`) |

## Usage Examples

[Section titled “Usage Examples”](#usage-examples)

### Basic Environment Variable Loading

[Section titled “Basic Environment Variable Loading”](#basic-environment-variable-loading)

This example loads environment variables and exports them for use in subsequent steps:

.github/workflows/basic.yml

```yaml
name: Basic Environment Loading


on:
  push:
    branches: [main]


jobs:
  build:
    runs-on: ubuntu-latest


    steps:
      - name: Checkout code
        uses: actions/checkout@v4


      - name: Load environment variables
        uses: dmno-dev/varlock@v1


      - name: Use environment variables
        run: |
          echo "Database URL: $DATABASE_URL"
          echo "API Key: $API_KEY"
          echo "Environment: $APP_ENV"
```

### JSON Output Format

[Section titled “JSON Output Format”](#json-output-format)

Use JSON output when you need to reuse environment variables in multi-job workflows or pass them to other tools:

.github/workflows/json-output.yml

```yaml
name: JSON Output Example


on:
  push:
    branches: [main]


jobs:
  load-env:
    runs-on: ubuntu-latest
    outputs:
      env-vars: ${{ steps.varlock.outputs.json-env }}


    steps:
      - name: Checkout code
        uses: actions/checkout@v4


      - name: Load environment variables as JSON
        uses: dmno-dev/varlock@v1
        with:
          show-summary: false
          output-format: 'json'


  build:
    needs: load-env
    runs-on: ubuntu-latest


    steps:
      - name: Checkout code
        uses: actions/checkout@v4


      - name: Process environment variables
        run: |
          # Access the JSON blob from the previous job
          echo '${{ needs.load-env.outputs.env-vars }}' > env-vars.json


          # Use jq to process the JSON
          echo "Database URL: $(jq -r '.DATABASE_URL' env-vars.json)"
          echo "API Key: $(jq -r '.API_KEY' env-vars.json)"


      - name: Build application
        run: |
          # Use environment variables from JSON in build process
          DATABASE_URL=$(jq -r '.DATABASE_URL' env-vars.json)
          API_KEY=$(jq -r '.API_KEY' env-vars.json)


          echo "Building with DATABASE_URL: $DATABASE_URL"
          echo "Building with API_KEY: $API_KEY"
          # Your build logic here


  deploy:
    needs: build
    runs-on: ubuntu-latest


    steps:
      - name: Checkout code
        uses: actions/checkout@v4


      - name: Deploy with environment variables
        run: |
          # Access the same environment variables from the first job
          echo '${{ needs.load-env.outputs.env-vars }}' > env-vars.json


          # Use environment variables in deployment
          DATABASE_URL=$(jq -r '.DATABASE_URL' env-vars.json)
          API_KEY=$(jq -r '.API_KEY' env-vars.json)


          echo "Deploying with DATABASE_URL: $DATABASE_URL"
          echo "Deploying with API_KEY: $API_KEY"
          # Your deployment logic here
```

### Multi-Environment Workflows

[Section titled “Multi-Environment Workflows”](#multi-environment-workflows)

Handle different environments based on branch or deployment context:

.github/workflows/multi-env.yml

```yaml
name: Multi-Environment Deployment


on:
  push:
    branches: [main, staging, develop]


jobs:
  deploy:
    runs-on: ubuntu-latest


    steps:
      - name: Checkout code
        uses: actions/checkout@v4


      - name: Load environment variables
        uses: dmno-dev/varlock@v1
        env:
          # Set environment-specific values
          APP_ENV: ${{ github.ref_name == 'main' && 'production' || github.ref_name == 'staging' && 'staging' || 'development' }}


      - name: Deploy to environment
        run: |
          echo "Deploying to $APP_ENV environment"
          # Your deployment logic here
```

## Error Handling

[Section titled “Error Handling”](#error-handling)

The action provides comprehensive error handling and reporting:

### Validation Errors

[Section titled “Validation Errors”](#validation-errors)

When environment variables fail validation, the action will:

1. **Show detailed error messages** in the action logs
2. **Set the `error-count` output** with the number of errors found
3. **Fail the action** if `fail-on-error` is set to `true` (default)

.github/workflows/error-handling.yml

```yaml
name: Error Handling Example


on:
  push:
    branches: [main]


jobs:
  validate:
    runs-on: ubuntu-latest


    steps:
      - name: Checkout code
        uses: actions/checkout@v4


      - name: Load environment variables
        uses: dmno-dev/varlock@v1
        with:
          fail-on-error: false  # Don't fail on validation errors


      - name: Handle validation errors
        if: steps.varlock.outputs.error-count > '0'
        run: |
          echo "Found ${{ steps.varlock.outputs.error-count }} validation errors"
          echo "Check the varlock output above for details"
          # Your error handling logic here
```

## Security Considerations

[Section titled “Security Considerations”](#security-considerations)

### Sensitive Data Handling

[Section titled “Sensitive Data Handling”](#sensitive-data-handling)

The action automatically detects sensitive values based on your `.env.schema` configuration and handles them securely:

* **Sensitive values** are exported as GitHub secrets available in the current workflow run
* **Non-sensitive values** are exported as regular environment variables
* **All values** are available in subsequent steps, but sensitive ones are masked in logs

### Environment Variable Scope

[Section titled “Environment Variable Scope”](#environment-variable-scope)

* Environment variables are only available within the job where the action runs
* They are not persisted across jobs or workflow runs
* Use the `json-env` output if you need to pass values between jobs, keeping in mind that this could possibly leak sensitive data if not handled correctly. You can also re-run the varlock action in a subsequent job to get the latest values.

## Best Practices

[Section titled “Best Practices”](#best-practices)

1. **Always use `.env.schema` and \`.env.**\*: Define your environment structure and validation rules, see [environments guide](/guides/environments) for more information.
2. **Set `fail-on-error: true` (default)**: Catch configuration issues early in your CI/CD pipeline
3. **Handle errors gracefully**: Check the `error-count` output and provide meaningful feedback
4. **Secure sensitive data**: Mark sensitive values in your schema and let the action handle them securely

## Related Documentation

[Section titled “Related Documentation”](#related-documentation)

* [Environment Variables Guide](/guides/environments) - Learn about managing multiple environments
* [Schema Reference](/reference/root-decorators) - Understand schema decorators and validation
* [Getting Started](/getting-started) - Set up varlock in your project
* [CLI Reference](/reference/cli) - Command-line interface documentation

# JavaScript / Node.js

> How to integrate Varlock with JavaScript and Node.js for secure, type-safe environment management

There are a few different ways to integrate Varlock into a JavaScript / Node.js application.

Some tools/frameworks may require an additional package, or have more specific instructions. Check the Integrations section in the navigation for more details.

**Want to help us build more integrations? Join our [Discord](https://chat.dmno.dev)!**

## Node.js - `varlock/auto-load`

[Section titled “Node.js - varlock/auto-load”](#nodejs---varlockauto-load)

The best way to integrate varlock into a plain Node.js application (⚠️ version 22 or higher) is to import the `varlock/auto-load` module. This uses `execSync` to call out to the varlock CLI, sets resolved env vars into `process.env`, and initializes varlock’s runtime code, including:

* varlock’s `ENV` object
* log redaction (if enabled)
* leak detection (if enabled)

example-index.js

```js
import 'varlock/auto-load';
import { ENV } from 'varlock/env';


const FROM_VARLOCK_ENV = ENV.MY_CONFIG_ITEM; // ✨ recommended
const FROM_PROCESS_ENV = process.env.MY_CONFIG_ITEM; // 🆗 still works
```

dotenv drop-in replacement

If you are using [`dotenv`](https://www.npmjs.com/package/dotenv), or a package you are using is using it under the hood - you can seamlessly swap in varlock using your package manager’s override feature. See the [migrate from dotenv](/guides/migrate-from-dotenv) guide for more information.

## Boot via `varlock run`

[Section titled “Boot via varlock run”](#boot-via-varlock-run)

A less invasive way to use varlock with your application is to run your application via [`varlock run`](/reference/cli-commands/#run).

```bash
varlock run -- <your-command>
```

This will load and validate your environment variables, then run the command you provided with those environment variables injected into the process. This will not inject any runtime code, and varlock’s `ENV` object will not be available.

If you have installed varlock as a project dependency instead of globally, you should run this via your package manager:

* npm

  ```bash
  npm exec -- varlock run -- <your-command>
  ```

* pnpm

  ```bash
  pnpm exec -- varlock run -- <your-command>
  ```

* bun

  ```bash
  bun exec varlock run -- <your-command>
  ```

* vlt

  ```bash
  vlx -- varlock run -- <your-command>
  ```

* yarn

  ```bash
  yarn exec -- varlock run -- <your-command>
  ```

In `package.json` scripts, calling `varlock` directly will work, as your package manager handles path issues:

package.json

```json
"scripts": {
  "start": "varlock run -- node index.js"
}
```

Even when using a deeper integration for your code, you may still need to use `varlock run` when calling external scripts/tools, like database migrations, to pass along resolved env vars.

Setting the current environment

Varlock can load multiple environment-specific `.env` files (e.g., `.env.development`, `.env.production`) by using the [`@currentEnv` root decorator](/reference/root-decorators/#currentenv) to specify which env var will set the current environment.

If not using the default (usually `development`), you’ll want to pass it in as an environment variable when running your command.

```bash
APP_ENV=production varlock run -- node index.js
```

See the [environments guide](/guides/environments) for more information about how to set the current environment.

## Front-end frameworks

[Section titled “Front-end frameworks”](#front-end-frameworks)

While environment variables are not available in the browser, many frameworks expose some env vars that are available *at build time* to the client by embedding them into your bundled code. This is best accomplished using tool-specific integrations, especially for frameworks that are handling both client and server-side code.

Isomorphic env vars

The `varlock/env` module is designed to be imported on both the client and server, so frameworks that run code in both places (like Next.js) can import it.



Help us build more integrations!

If you are using a tool/framework that is not listed here, and you’d like to see support for it, or collaborate on building it, we’d love to hear from you. Please hop into our [Discord](https://chat.dmno.dev)!

# Next.js

> How to integrate Varlock with Next.js for secure, type-safe environment management

[![](https://img.shields.io/npm/v/@varlock/nextjs-integration?label=%40varlock%2Fnextjs-integration\&color=9B55F5\&logo=npm)](https://www.npmjs.com/package/@varlock/nextjs-integration)

Varlock provides a huge upgrade over the [default Next.js environment variable tooling](https://nextjs.org/docs/pages/guides/environment-variables) - adding validation, type safety, flexible multi-environment management, log redaction, leak detection, and more.

To integrate varlock into a Next.js application, you must use our [`@varlock/nextjs-integration`](https://www.npmjs.com/package/@varlock/nextjs-integration) package. This package provides a drop-in replacement for [`@next/env`](https://www.npmjs.com/package/@next/env), the internal package that handles .env loading, plus a small config plugin which injects our additional security features.

Turbopack supported, but not fully

[Turbopack](https://nextjs.org/docs/app/api-reference/turbopack) does not yet provide a plugin system, so using the config plugin is not supported. You can use the `@next/env` override only, but you will not get the additional security features.

## Setup

[Section titled “Setup”](#setup)

Requirements

* Node.js v22 or higher
* Next.js v14 or higher

1. **Install varlock and the Next.js integration package**

   * npm

     ```bash
     npm install @varlock/nextjs-integration varlock
     ```

   * pnpm

     ```bash
     pnpm add @varlock/nextjs-integration varlock
     ```

   * bun

     ```bash
     bun add @varlock/nextjs-integration varlock
     ```

   * yarn

     ```bash
     yarn add @varlock/nextjs-integration varlock
     ```

   * vlt

     ```bash
     vlt install @varlock/nextjs-integration varlock
     ```

2. **Run `varlock init` to set up your `.env.schema` file**

   This will guide you through setting up your `.env.schema` file, based on your existing `.env` file(s). Make sure to review it carefully.

   * npm

     ```bash
     npm exec -- varlock init
     ```

   * pnpm

     ```bash
     pnpm exec -- varlock init
     ```

   * bun

     ```bash
     bun exec varlock init
     ```

   * vlt

     ```bash
     vlx -- varlock init
     ```

   * yarn

     ```bash
     yarn exec -- varlock init
     ```

3. **Override `@next/env` with our drop-in replacement**

   Next.js does not have APIs we can hook into, so we must override their internal .env-loading package. Overriding dependencies is a bit different for each package manager:

   * npm

     See [NPM overrides docs](https://docs.npmjs.com/cli/v9/configuring-npm/package-json#overrides)

     package.json

     ```diff
     {
       +"overrides": {
         +"next": {
           +"@next/env": "npm:@varlock/nextjs-integration"
     +    }
     +  }
     }
     ```

   * yarn

     See [yarn resolutions docs](https://yarnpkg.com/configuration/manifest#resolutions)

     root/package.json

     ```diff
     {
       +"resolutions": {
         +"**/@next/env": "npm:@varlock/nextjs-integration"
     +  },
     }
     ```

     **In a monorepo, this override must be done in the monorepo’s root package.json file!**

   * pnpm

     * pnpm version 10+

       See [pnpm v10 overrides docs](https://pnpm.io/settings#overrides)

       root/pnpm-workspace.yaml

       ```diff
       packages: # <- ⚠️ this field is also required
         - .     # set this to '.' if not in a monorepo
       +overrides:
         +"@next/env": "npm:@varlock/nextjs-integration"
       ```

       **This must be set in `pnpm-workspace.yaml`, which lives at the root of your repo, regardless of whether you are using a monorepo or not.**

     * pnpm version 9

       See [pnpm v9 overrides docs](https://pnpm.io/9.x/package_json#pnpmoverrides)

       root/package.json

       ```diff
       {
         +"pnpm": {
           +"overrides": {
             +"@next/env": "npm:@varlock/nextjs-integration"
       +    }
       +  }
       }
       ```

       **In a monorepo, this override must be done in the monorepo’s root package.json file!**

   * bun

     See [pnpm v10 overrides docs](https://pnpm.io/settings#overrides)

     root/pnpm-workspace.yaml

     ```diff
     packages: # <- ⚠️ this field is also required
       - .     # set this to '.' if not in a monorepo
     +overrides:
       +"@next/env": "npm:@varlock/nextjs-integration"
     ```

     **This must be set in `pnpm-workspace.yaml`, which lives at the root of your repo, regardless of whether you are using a monorepo or not.**

   * pnpm version 10+

     See [pnpm v9 overrides docs](https://pnpm.io/9.x/package_json#pnpmoverrides)

     root/package.json

     ```diff
     {
       +"pnpm": {
         +"overrides": {
           +"@next/env": "npm:@varlock/nextjs-integration"
     +    }
     +  }
     }
     ```

     **In a monorepo, this override must be done in the monorepo’s root package.json file!**

   * pnpm version 9

     See [Bun overrides docs](https://bun.com/docs/pm/overrides)

     package.json

     ```diff
     {
       +"overrides": {
         +"@next/env": "npm:@varlock/nextjs-integration"
     +  }
     }
     ```

   Then re-run your package manager’s install command to apply the override:

   * npm

     ```bash
     npm install
     ```

   * yarn

     ```bash
     yarn install
     ```

   * pnpm

     ```bash
     pnpm install
     ```

   * bun

     ```bash
     bun install
     ```

4. **Enable the Next.js config plugin**

   At this point, varlock will now load your .env files into `process.env`. But to get the full benefits of this integration, you must add `varlockNextConfigPlugin` to your `next.config.*` file.

   next.config.ts

   ```diff
   import type { NextConfig } from "next";
   +import { varlockNextConfigPlugin } from '@varlock/nextjs-integration/plugin';


   const nextConfig: NextConfig = {
     // your existing config...
   };


   -export default nextConfig;
   +export default varlockNextConfigPlugin()(nextConfig);
   ```

***

## Accessing environment variables

[Section titled “Accessing environment variables”](#accessing-environment-variables)

You can continue to use `process.env.SOMEVAR` as usual, but we recommend using Varlock’s imported `ENV` object for better type-safety and improved developer experience:

example.ts

```ts
import { ENV } from 'varlock/env';


console.log(process.env.SOMEVAR); // 🆗 still works
console.log(ENV.SOMEVAR);         // ✨ recommended
```

Caution

If you are not using the `varlockNextConfigPlugin`, only `process.env` will work.

### Type-safety and IntelliSense

[Section titled “Type-safety and IntelliSense”](#type-safety-and-intellisense)

To enable type-safety and IntelliSense for your env vars, enable the [`@generateTypes` root decorator](/reference/root-decorators/#generatetypes) in your `.env.schema`. Note that if your schema was created using `varlock init`, it will include this by default.

.env.schema

```diff
+# @generateTypes(lang='ts', path='env.d.ts')
# ---
# your config items...
```

#### Why use `ENV` instead of `process.env`?

[Section titled “Why use ENV instead of process.env?”](#why-use-env-instead-of-processenv)

* Non-string values (e.g., number, boolean) are properly typed and coerced
* All non-sensitive items are replaced at build time (not just `NEXT_PUBLIC_`)
* Better error messages for invalid or unavailable keys
* Enables future DX improvements and tighter control over what is bundled

***

## Managing multiple environments

[Section titled “Managing multiple environments”](#managing-multiple-environments)

Varlock can load multiple *environment-specific* `.env` files (e.g., `.env.development`, `.env.preview`, `.env.production`).

By default, the environment flag is determined as follows (matching Next.js):

* `test` if `NODE_ENV` is `test`
* `development` if running `next dev`
* `production` otherwise

Tip

Without a custom env flag, you cannot use non-production env files (like `.env.preview`, `.env.staging`) for non-prod deployments.

Instead, we recommend explicitly setting your own environment flag using the [`@currentEnv` root decorator](/reference/root-decorators/#currentenv), e.g. `APP_ENV`. See the [environments guide](/guides/environments) for more information.

Loading `.env.local` in `test` environment

Next.js makes [a special exception](https://nextjs.org/docs/pages/guides/environment-variables#test-environment-variables) to skip loading `.env.local` if the current environment is `test`.

Varlock does not, but you may explicitly opt-in to that behavior:

.env.local

```env-spec
# @disable=forEnv(test)
# ---
```

Precedence of `.env.local` vs `.env.[currentEnv]`

Next.js swaps the order of precedence for `.env.local` vs `.env.[currentEnv]` compared to Varlock.

### Setting the environment flag

[Section titled “Setting the environment flag”](#setting-the-environment-flag)

When running locally, or on a platform you control, you can set the env flag explicitly as an environment variable. However on some cloud platforms, there is a lot of magic happening, and the ability to set environment variables per branch is limited. In these cases you can use functions to transform env vars injected by the platform, like a current branch name, into the value you need.

#### Local/custom scripts

[Section titled “Local/custom scripts”](#localcustom-scripts)

You can set the env var explicitly when you run a command, but often you will set it in `package.json` scripts:

package.json

```json
"scripts": {
  "build:preview": "APP_ENV=preview next build",
  "start:preview": "APP_ENV=preview next start",
  "build:prod": "APP_ENV=production next build",
  "start:prod": "APP_ENV=production next start",
  "test": "APP_ENV=test jest"
}
```

#### Vercel

[Section titled “Vercel”](#vercel)

You can use the injected `VERCEL_ENV` variable to match their concept of environment types:

.env.schema

```env-spec
# @currentEnv=$APP_ENV
# ---
# @type=enum(development, preview, production)
VERCEL_ENV=
# @type=enum(development, preview, production, test)
APP_ENV=fallback($VERCEL_ENV, development)
```

For more granular environments, use the branch name in `VERCEL_GIT_COMMIT_REF` (see Cloudflare example below).

#### Cloudflare Workers Build

[Section titled “Cloudflare Workers Build”](#cloudflare-workers-build)

Use the branch name in `WORKERS_CI_BRANCH` to determine the environment:

.env.schema

```env-spec
# @currentEnv=$APP_ENV
# ---
WORKERS_CI_BRANCH=
# @type=enum(development, preview, production, test)
APP_ENV=remap($WORKERS_CI_BRANCH, production="main", preview=regex(.*), development=undefined)
```

***

## Managing sensitive config values

[Section titled “Managing sensitive config values”](#managing-sensitive-config-values)

Next.js uses the `NEXT_PUBLIC_` prefix to determine which env vars are public (bundled for the browser). Varlock lets you control this with the [`@defaultSensitive`](/reference/root-decorators/#defaultsensitive) root decorator.

Set a default and explicitly mark items:

.env.schema

```diff
+# @defaultSensitive=true
# ---
SECRET_FOO= # sensitive by default
# @sensitive=false
NON_SECRET_FOO=
```

Or, if you’d like to continue using Next.js’s prefix behavior:

.env.schema

```diff
+# @defaultSensitive=inferFromPrefix('NEXT_PUBLIC_')
# ---
FOO= # sensitive
NEXT_PUBLIC_FOO= # non-sensitive, due to prefix
```

Bundling behavior

All non-sensitive items are bundled at build time via `ENV`, while `process.env` replacements only include `NEXT_PUBLIC_`-prefixed items.

## Extra setup for standalone mode

[Section titled “Extra setup for standalone mode”](#standalone)

**⚠️ This is only needed if you are using `output: standalone`**

Next’s standalone build command will not copy all our `.env` files to the `.next/standalone` directory, so we must copy them manually. Add this to your build command:

package.json

```json
{
  "scripts": {
    "build": "next build && cp .env.* .next/standalone",
  }
}
```

*you may need to adjust if you don’t want to copy certain .local files*

Standalone builds do not copy dependency binaries, and varlock depends on the CLI to load. So wherever you are booting your standalone server, you will also need to [install the varlock binary](/getting-started/installation/) and boot your server via [`varlock run`](/reference/cli-commands/#run)

```bash
varlock run -- node .next/standalone/server.js
```

***

## Troubleshooting

[Section titled “Troubleshooting”](#troubleshooting)

* ❌ `process.env.__VARLOCK_ENV is not set`\
  💡 This error appears when the `@next/env` override has not been set up properly

  * You may need to re-run your package manager’s install command
  * If using pnpm, check if you are using pnpm v9 or v10, because overrides config changed (see above)

* ❌ `Error [ERR_REQUIRE_ESM]: require() of ES Module ...`\
  💡 Varlock requires node v22 or higher - which has better CJS/ESM interoperability

* ❌ `Property 'SOMEVAR' does not exist on type 'TypedEnvSchema'`\
  💡 If the item does exist in your schema, then the generated types are not being loaded properly by TypeScript

  * make sure the [`@generateTypes` root decorator](/reference/root-decorators/#generatetypes) is enabled
  * ensure the path to the generated types file is included in your `tsconfig.json`

***

## Reference

[Section titled “Reference”](#reference)

* [Root decorators reference](/reference/root-decorators)
* [Item decorators reference](/reference/item-decorators)
* [Functions reference](/reference/functions)
* [Next.js environment variable docs](https://nextjs.org/docs/pages/guides/environment-variables)

# Other languages

> Integrating varlock into other languages

To use varlock with other languages, you’ll likely want to [install the standalone binary](/getting-started/installation/#as-a-binary), rather than using a JS package manager.

To use it with your application code, you must use [`varlock run`](/reference/cli-commands/#run) to load and validate your environment variables, then run the command you provided with those environment variables injected into the process.

```bash
varlock run -- <your-command>
```

We are working on language-specific helper libraries, that will make this integration better, and provide additional security features like we do in JavaScript.

We will also be implementing automatic type-generation based on your schema for various languages.

**Want to help us build these integrations? Join our [Discord](https://chat.dmno.dev).**

# Integrations Overview

> How Varlock integrates with popular frameworks, bundlers, and runtimes

Varlock ships with official integrations that wire the CLI, runtime helpers, and framework-specific plugins together so your configuration is validated, type-safe, and protected everywhere it runs.

Integrations allow you to:

* load and validate `.env` files automatically during dev and use them in CI/CD and production
* inject config into your code at build or request time
* enable runtime protections such as leak prevention, and log redaction

## Official integrations

[Section titled “Official integrations”](#official-integrations)

* [JavaScript / Node.js](/integrations/javascript/) — use `varlock` in custom toolchains, scripts, and servers
* [Bun](/integrations/bun/) — instructions to set up Varlock with Bun
* [Next.js](/integrations/nextjs/) — drop-in replacement for `@next/env`
* [Vite](/integrations/vite/) — Vite plugin that validates and replaces at build time
* [Qwik](/integrations/vite/) — use the Vite integration
* [React Router](/integrations/vite/) — use the Vite integration
* [Cloudflare Workers](/integrations/cloudflare/) — use the Vite integration or Wrangler vars/secrets directly
* [Astro](/integrations/astro/) — Astro integration built on top of our Vite plugin
* [GitHub Actions](/integrations/github-action/) — validate your `.env.schema` in GitHub Actions workflows
* [Other languages](/integrations/other-languages/) — guidance for piping varlock output into non-JS runtimes
* [Docker](/guides/docker/) — a Docker wrapper around the varlock CLI including examples
* [direnv](/integrations/direnv/) — load validated env vars directly into your shell session

## Coming soon

[Section titled “Coming soon”](#coming-soon)

We’re actively working on additional first-party integrations for popular runtimes, frameworks and hosting platforms. If yours isn’t listed yet, let us know!

Request an integration

Join us on [Discord](https://chat.dmno.dev) or open a GitHub issue describing your use case so we can prioritize it.

# Vite

> How to integrate varlock with Vite for secure, type-safe environment management

[![](https://img.shields.io/npm/v/@varlock/vite-integration?label=%40varlock%2Fvite-integration\&color=9B55F5\&logo=npm)](https://www.npmjs.com/package/@varlock/vite-integration)

Some frameworks use Vite under the hood, and some projects use Vite directly. Either way, often there is some [automatic loading of .env files](https://vite.dev/guide/env-and-mode.html) happening, but it is fairly limited. To integrate varlock into a Vite-powered application, you must use our [`@varlock/vite-integration`](https://www.npmjs.com/package/@varlock/vite-integration) package, which is a [Vite plugin](https://vite.dev/guide/using-plugins.html).

This plugin does a few things:

* Loading and validating your .env files using varlock, injecting resolved env into process.env at build/dev time
* Simplifies using env vars within your `vite.config.*` file
* Build time replacements of `ENV.xxx` of non-sensitive items (no prefix required)
* Within SSR contexts, injecting additional initialization code and enabling additional [security features](https://varlock.dev/guides/secrets/#security-enhancements)

Astro users

For [Astro](https://astro.build) - which is also powered by Vite - you should use our [Astro integration](/integrations/astro/).

## Frameworks that use Vite

[Section titled “Frameworks that use Vite”](#frameworks)

If you’re using [Qwik](https://qwik.dev/) or [React Router](https://reactrouter.com/)/[Remix](https://remix.run/), you can follow the Vite instructions below. If you’re using [Cloudflare Workers](https://developers.cloudflare.com/workers/) with the [Cloudflare Vite plugin](https://developers.cloudflare.com/workers/vite-plugin/) then these instructions also apply. For anything framework-specific on Cloudflare Workers (like Next.js) follow the [integration](/integrations/overview) docs for that framework.

## Setup

[Section titled “Setup”](#setup)

Requirements

* Node.js v22 or higher
* Vite v5 or higher

1. **Install varlock and the Vite integration package**

   * npm

     ```bash
     npm install @varlock/vite-integration varlock
     ```

   * pnpm

     ```bash
     pnpm add @varlock/vite-integration varlock
     ```

   * bun

     ```bash
     bun add @varlock/vite-integration varlock
     ```

   * yarn

     ```bash
     yarn add @varlock/vite-integration varlock
     ```

   * vlt

     ```bash
     vlt install @varlock/vite-integration varlock
     ```

2. **Run `varlock init` to set up your `.env.schema` file**

   This will guide you through setting up your `.env.schema` file, based on your existing `.env` file(s). Make sure to review it carefully.

   * npm

     ```bash
     npm exec -- varlock init
     ```

   * pnpm

     ```bash
     pnpm exec -- varlock init
     ```

   * bun

     ```bash
     bun exec varlock init
     ```

   * vlt

     ```bash
     vlx -- varlock init
     ```

   * yarn

     ```bash
     yarn exec -- varlock init
     ```

3. **Enable the Vite config plugin**

   You must add our `varlockVitePlugin` to your `vite.config.*` file:

   vite.config.ts

   ```diff
   import { defineConfig } from 'vite';
   +import { varlockVitePlugin } from '@varlock/vite-integration';


   export default defineConfig({
     plugins: [varlockVitePlugin(), otherPlugin()]
   });
   ```

***

## SSR Code Injection

[Section titled “SSR Code Injection”](#ssr-code-injection)

Within SSR builds, this plugin will automatically inject varlock initialization code into your entry points. There are 3 modes to choose from and specify during plugin initialization. For example:

```ts
varlockVitePlugin({ ssrInjectMode: 'auto-load' })
```

* `init-only` - injects varlock initialization code, but does not load the env vars. You must still boot your app via `varlock run` in this mode.
* `auto-load` - injects `import 'varlock/auto-load';` to load your resolved env via the varlock CLI
* `resolved-env` - injects the fully resolved env data into your built code. This is useful in environments like Vercel/Cloudflare/etc where you have no control over your build command, and limited access to use CLI commands or the filesystem

**If not specified, we will attempt to infer the correct mode based on the presence of other vite plugins and environment variables, which give us hints about how your application will be run.** Otherwise defaulting to `init-only`.

## Accessing environment variables

[Section titled “Accessing environment variables”](#accessing-environment-variables)

You can continue to use `import.meta.env.SOMEVAR` as usual, but we recommend using varlock’s imported `ENV` object for better type-safety and improved developer experience:

example.ts

```ts
import { ENV } from 'varlock/env';


console.log(import.meta.env.SOMEVAR); // 🆗 still works
console.log(ENV.SOMEVAR);             // ✨ recommended
```

#### Why use `ENV` instead of `import.meta.env`?

[Section titled “Why use ENV instead of import.meta.env?”](#why-use-env-instead-of-importmetaenv)

* Non-string values (e.g., number, boolean) are properly typed and coerced
* All non-sensitive items are replaced at build time (not just `VITE_` prefixed ones)
* Better error messages for invalid or unavailable keys
* Enables future DX improvements and tighter control over what is bundled

### Within `vite.config.*`

[Section titled “Within vite.config.\*”](#within-viteconfig)

It’s often useful to be able to access env vars in your Vite config. Without varlock, it’s a bit awkward, but varlock makes it dead simple - in fact it’s already available! Just import varlock’s `ENV` object and reference env vars via `ENV.SOME_ITEM` like you do everywhere else.

vite.config.ts

```diff
import { defineConfig } from 'vite';
import { varlockVitePlugin } from '@varlock/vite-integration';
+import { ENV } from 'varlock/env';


+doSomethingWithEnvVar(ENV.FOO);


export default defineConfig({ /* ... */ });
```

TypeScript config

If you find you are not getting type completion on `ENV`, you may need to add your vite config and generated type files (usually `env.d.ts`) to your `tsconfig.json`’s `include` array.

### Within HTML templates

[Section titled “Within HTML templates”](#within-html-templates)

Vite [natively supports](https://vite.dev/guide/env-and-mode.html#html-constant-replacement) injecting env vars into HTML files using a special syntax like `%SOME_VAR%`.

This plugin injects additional replacements for strings like `%ENV.SOME_VAR%`.

Note that unlike the native functionality which does not replace missing/non-existant items, we will try to replace all items, and will throw helpful errors if something goes wrong.

HTML comments

Note that replacements anywhere in the file, including HTML comments, are still attempted and can cause errors. For example `<!-- %ENV.BAD_ITEM_KEY% -->` will still fail!

### Within other scripts

[Section titled “Within other scripts”](#within-other-scripts)

Even in a static front-end project, you may have other scripts in your project that rely on sensitive config.

You can use [`varlock run`](/reference/cli-commands/#run) to inject resolved config into other scripts as regular environment vars.

* npm

  ```bash
  npm exec -- varlock run -- node ./script.js
  ```

* pnpm

  ```bash
  pnpm exec -- varlock run -- node ./script.js
  ```

* bun

  ```bash
  bun exec varlock run -- node ./script.js
  ```

* vlt

  ```bash
  vlx -- varlock run -- node ./script.js
  ```

* yarn

  ```bash
  yarn exec -- varlock run -- node ./script.js
  ```

### Type-safety and IntelliSense

[Section titled “Type-safety and IntelliSense”](#type-safety-and-intellisense)

To enable type-safety and IntelliSense for your env vars, enable the [`@generateTypes` root decorator](/reference/root-decorators/#generatetypes) in your `.env.schema`. Note that if your schema was created using `varlock init`, it will include this by default.

.env.schema

```diff
+# @generateTypes(lang='ts', path='env.d.ts')
# ---
# your config items...
```

***

## Managing multiple environments

[Section titled “Managing multiple environments”](#managing-multiple-environments)

Varlock can load multiple *environment-specific* `.env` files (e.g., `.env.development`, `.env.preview`, `.env.production`) by using the [`@currentEnv` root decorator](/reference/root-decorators/#currentenv). **This is different than Vite’s default behaviour, which relies on it’s own [`MODE` flag](https://vite.dev/guide/env-and-mode.html#modes).**

Usually this env var will be defaulted to something like `development` in your `.env.schema` file, and you can override it by overriding the value when running commands - for example `APP_ENV=production vite build`. For a JavaScript based project, this will often be done in your `package.json` scripts.

package.json

```json
{
  "scripts": {
    "dev": "vite dev",
    "test": "APP_ENV=test vitest",
    "build": "APP_ENV=production vite build",
    "preview": "APP_ENV=production vite preview",
  }
}
```

In some cases, you could also set the current environment value based on other vars already injected by your CI platform, like the current branch name. See the [environments guide](/guides/environments) for more information.

## Managing sensitive config values

[Section titled “Managing sensitive config values”](#managing-sensitive-config-values)

Vite uses the `VITE_` prefix to determine which env vars are public (bundled for the browser). Varlock decouples the concept of being *sensitive* from key names, and instead you control this with the [`@defaultSensitive`](/reference/root-decorators/#defaultsensitive) root decorator and the [`@sensitive`](/reference/item-decorators/#sensitive) item decorator. See the [secrets guide](/guides/secrets) for more information.

Set a default and explicitly mark items:

.env.schema

```diff
+# @defaultSensitive=false
# ---
NON_SECRET_FOO= # sensitive by default
# @sensitive
SECRET_FOO=
```

Or if you’d like to continue using Vite’s prefix behavior:

.env.schema

```diff
+# @defaultSensitive=inferFromPrefix('VITE_')
# ---
FOO= # sensitive
VITE_FOO= # non-sensitive, due to prefix
```

Bundling behavior

All non-sensitive items are bundled at build time via `ENV`, while `import.meta.env` replacements continue to only include `VITE_`-prefixed items.

***

## Reference

[Section titled “Reference”](#reference)

* [Root decorators reference](/reference/root-decorators)
* [Item decorators reference](/reference/item-decorators)
* [Functions reference](/reference/functions)
* [Vite environment variable docs](https://vite.dev/guide/env-and-mode.html)

# 1Password Plugin

> Using 1Password with Varlock

[![](https://img.shields.io/npm/v/@varlock/1password-plugin?label=%40varlock%2F1password-plugin\&color=9B55F5\&logo=npm)](https://www.npmjs.com/package/@varlock/1password-plugin)

Our [1Password](https://1password.com/) plugin enables secure loading of values from 1Password vaults using declarative instructions within your `.env` files.

For local development, it (optionally) supports authenticating using the local 1Password desktop app, including using biometric unlock. Otherwise, it uses a [service account](https://developer.1password.com/docs/service-accounts/) making it suitable for CI/CD and production environments.

This plugin is compatible with any 1Password account type (personal, family, teams, business), but note that [rate limits](https://developer.1password.com/docs/service-accounts/rate-limits/) vary by account type.

## Installation and setup

[Section titled “Installation and setup”](#installation-and-setup)

In a JS/TS project, you may install the `@varlock/1password-plugin` package as a normal dependency. Otherwise you can just load it directly from your `.env.schema` file, as long as you add a version specifier. See the [plugins guide](/guides/plugins/#installation) for more instructions on installing plugins.

.env.schema

```env-spec
# 1. Load the plugin
# @plugin(@varlock/1password-plugin)
#
# 2. Initialize the plugin - see below for more details on options
# @initOp(token=$OP_TOKEN, allowAppAuth=forEnv(dev), account=acmeco)
# ---


# 3. Add a service account token config item (if applicable)
# @type=opServiceAccountToken @sensitive
OP_TOKEN=
```

### Vault setup

[Section titled “Vault setup”](#vault-setup)

If your secrets are already stored in 1Password, you may not need to do anything. However, if secrets live in a vault that holds other sensitive data, you should create a new vault and move your secrets to it, because **the access system of 1Password is based on vaults, not individual items**.

You can create multiple vaults to segment access to different environments, services, etc. This can be done using any 1Password app, the web app, or the CLI. [link](https://support.1password.com/create-share-vaults/#create-a-vault)

Remember to grant access to necessary team members, particularly if you plan on using the desktop app auth method during local development, as they will be authenticating as themselves.

Vault organization best practices

Consider how you want to organize your vaults and service accounts, keeping in mind [best practices](https://support.1password.com/business-security-practices/#access-management-and-the-principle-of-least-privilege). At a minimum, we recommend having a vault for highly sensitive production secrets and another for everything else.

### Service account setup (for deployed environments)

[Section titled “Service account setup (for deployed environments)”](#service-account-setup-for-deployed-environments)

If you plan on using data from 1Password in deployed environments (CI/CD, production, etc), you will need to create a [service account](https://developer.1password.com/docs/service-accounts/get-started/) to allow machine-to-machine authentication. You could also use a service account for local development, although we recommend using the desktop app auth method described below for convenience.

This service account token will now serve as your *secret-zero* - which grants access to the rest of your sensitive data stored in 1Password.

1. **Create a new service account** and grant access to necessary vault(s). This is a special account used for machine-to-machine communication. This can only be done in the 1Password web interface. Be sure to save the new service account token in another vault so you can find it later. [link](https://developer.1password.com/docs/service-accounts/get-started/)

   Vault access is set during creation only

   Vault access rules cannot be edited after creation, so if your vault setup changes, you will need to create new service account(s) and update the tokens.

2. **Wire up the service account token in your config**. Add a config item of type `opServiceAccountToken` to hold the token value, and reference it when initializing the plugin.

   .env.schema

   ```diff
   # @plugin(@varlock/1password-plugin)
   # @initOp(token=$OP_TOKEN)
   # ---
   +# @type=opServiceAccountToken @sensitive
   OP_TOKEN=
   ```

3. **Set your service account token in deployed environments**. Copy the token value from where you saved it earlier, and set it in deployed environments using your platform’s env var management UI. Be sure to use the same name as you defined in your schema (e.g. `OP_TOKEN`).

Ensure service account access is enabled

Each vault has a toggle to disable service account access *in general*. It is on by default, so you will likely not need to do anything. [link](https://developer.1password.com/docs/service-accounts/manage-service-accounts/#manage-access)

### Desktop app auth (for local dev)

[Section titled “Desktop app auth (for local dev)”](#desktop-app-auth-for-local-dev)

During local development, you may find it convenient to skip the service account tokens and instead rely on your local 1Password desktop app (via the [CLI integration](https://developer.1password.com/docs/cli/get-started/#step-2-turn-on-the-1password-desktop-app-integration)), including using its biometric unlocking features.

1. **Opt-in while initializing the plugin**

   .env.schema

   ```env-spec
   # @plugin(@varlock/1password-plugin)
   # @initOp(token=$OP_TOKEN, allowAppAuth=true)
   ```

   You may use other functions to conditionally enable this, for example `forEnv(dev)`.

2. **Specify 1Password account (optional)**

   .env.schema

   ```env-spec
   # @plugin(@varlock/1password-plugin)
   # @initOp(token=$OP_TOKEN, allowAppAuth=true, account=acmeco)
   ```

   This value is passed through under the `--account` flag to the `op` CLI, and accepts account shorthand, sign-in address, account ID, or user ID.

   You can run `op account list` to see your available accounts. The shorthand is the subdomain of your `x.1password.com` sign-in address.

   This is optional, but recommended if you have access to multiple 1Password accounts, to ensure you connect to the correct one.

3. **Ensure the `op` CLI is installed**. [docs](https://developer.1password.com/docs/cli/get-started/)

4. **Enable the desktop app + CLI integration**. [docs](https://developer.1password.com/docs/cli/get-started/#step-2-turn-on-the-1password-desktop-app-integration)

With this option enabled, if the resolved service account token is empty, we will call out to the `op` cli installed on your machine (it must be in your `$PATH`) and use the auth it provides. With the desktop app integration enabled, it will call out and may trigger biometric verification to unlock. It is secure and very convenient!

Connecting as yourself

Keep in mind that this method is connecting as *YOU* who likely has more access than a tightly scoped service account. Consider only enabling this method for a plugin instance that will be handling non-production secrets.

## Pulling data from 1Password

[Section titled “Pulling data from 1Password”](#pulling-data-from-1password)

Once the plugin is installed and initialized, you can start adding config items that load values from 1Password using the `op()` resolver function.

You can wire up individual items to specific fields in by using [1Password secret references](https://developer.1password.com/docs/cli/secret-references/).

```env-spec
DB_PASS=op(op://my-vault/database-password/password)
```

Where to find a secret reference

The secret reference for invidivual fields within an item can be found by clicking on the down arrow icon on the field and selecting `Copy Secret Reference`.

If you have multiple plugin instances, the `op()` function accepts an optional first parameter to specify which instance id to use.

```env-spec
# @initOp(id=dev, token=$OP_TOKEN_DEV, allowAppAuth=true)
# @initOp(id=prod, token=$OP_TOKEN_PROD, allowAppAuth=false)
# ---
DEV_ITEM=op(dev, op://vault-name/item-name/field-name)
PROD_ITEM=op(prod, op://vault-name/item-name/field-name)
```

### Loading 1Password Environments

[Section titled “Loading 1Password Environments”](#loading-1password-environments)

Use `opLoadEnvironment()` with `@setValuesBulk` to load all variables from a [1Password environment](https://developer.1password.com/docs/sdks/concepts/environments/) at once, instead of wiring up each secret individually:

.env.schema

```env-spec
# @plugin(@varlock/1password-plugin)
# @initOp(token=$OP_TOKEN, allowAppAuth=forEnv(dev), account=acmeco)
# @setValuesBulk(opLoadEnvironment(your-environment-id))
# ---


# @type=opServiceAccountToken @sensitive
OP_TOKEN=


API_KEY=
DB_PASSWORD=
```

With a named instance:

.env.schema

```env-spec
# @initOp(id=prod, token=$OP_TOKEN_PROD, allowAppAuth=false)
# @setValuesBulk(opLoadEnvironment(prod, your-environment-id))
```

Beta CLI required for desktop app auth

When using desktop app auth (`allowAppAuth`), the `op environment` command requires a beta version of the 1Password CLI (v2.33.0+). Download it from the [CLI release history](https://app-updates.agilebits.com/product_history/CLI2) (click “show betas”). Service account auth via the SDK does not have this requirement.

***

## Reference

[Section titled “Reference”](#reference)

### Root decorators

[Section titled “Root decorators”](#root-decorators)

#### `@initOp()`

[Section titled “@initOp()”](#initop)

Initializes an instance of the 1Password plugin - setting up options and authentication. Can be called multiple times to set up different instances.

**Key/value args:**

* `id` (optional): identifier for this instance, used when multiple instances are needed
* `token` (optional): service account token. Should be a reference to a config item of type `opServiceAccountToken`.
* `allowAppAuth` (optional): boolean flag to enable authenticating using the local desktop app
* `account` (optional): limits the `op` cli to connect to specific 1Password account (shorthand, sign-in address, account ID, or user ID)

```env-spec
# @initOp(id=notProd, token=$OP_TOKEN, allowAppAuth=forEnv(dev), account=acmeco)
# ---
# @type=opServiceAccountToken
OP_TOKEN=
```

### Data types

[Section titled “Data types”](#data-types)

#### `opServiceAccountToken`

[Section titled “opServiceAccountToken”](#opserviceaccounttoken)

Represents a [1Password service account token](https://developer.1password.com/docs/service-accounts/). Validation ensures the token is in the correct format, and a link to the 1Password docs is added for convenience. Note that the type itself is marked as `@sensitive`, so adding an explicit `@sensitive` decorator is optional.

```env-spec
# @type=opServiceAccountToken
OP_TOKEN=
```

### Resolver functions

[Section titled “Resolver functions”](#resolver-functions)

#### `op()`

[Section titled “op()”](#op)

Fetches an individual field using a 1Password secret reference

**Array args:**

* `instanceId` (optional): instance identifier to use when multiple plugin instances are initialized
* `secretReference`: secret reference to fetch value from, in the format `op://vault-name/item-name/field-name`

```env-spec
ITEM=op(op://vault-name/item-name/field-name)


# example using a plugin instance id
ITEM_WITH_INSTANCE_ID=op(prod, op://vault-name/item-name/field-name)
```

#### `opLoadEnvironment()`

[Section titled “opLoadEnvironment()”](#oploadenvironment)

Load all variables from a [1Password environment](https://developer.1password.com/docs/sdks/concepts/environments/). Intended for use with `@setValuesBulk`.

**Array args:**

* `instanceId` (optional): instance identifier to use when multiple plugin instances are initialized
* `environmentId`: the 1Password environment ID to load variables from

```env-spec
# Load all variables from a 1Password environment
# @setValuesBulk(opLoadEnvironment(your-environment-id))


# With a named instance
# @setValuesBulk(opLoadEnvironment(prod, your-environment-id))
```

# AWS Secrets Manager Plugin

> Using AWS Secrets Manager and Systems Manager Parameter Store with Varlock

[![](https://img.shields.io/npm/v/@varlock/aws-secrets-plugin?label=%40varlock%2Faws-secrets-plugin\&color=9B55F5\&logo=npm)](https://www.npmjs.com/package/@varlock/aws-secrets-plugin)

Our AWS plugin enables secure loading of secrets from [AWS Secrets Manager (SM)](https://aws.amazon.com/secrets-manager/) and from [AWS Systems Manager Parameter Store (SSM)](https://aws.amazon.com/systems-manager/features/#Parameter_Store) using declarative instructions within your `.env` files.

The plugin automatically integrates with AWS authentication, including IAM roles for AWS-hosted applications, AWS CLI credentials for local development, and explicit credentials for non-AWS environments.

## Features

[Section titled “Features”](#features)

* **Zero-config authentication** - Automatically uses AWS credentials from your environment
* **IAM role support** - No credentials needed for AWS-hosted apps (EC2, ECS, Lambda, etc.)
* **AWS CLI authentication** - Works seamlessly with `aws configure` for local development
* **Auto-infer secret/parameter names** from environment variable names
* **JSON key extraction** from secrets/parameters using `#` syntax or named `key` parameter
* **Name prefixing** with `namePrefix` option for organized secret management
* Support for named AWS profiles
* Support for explicit credentials
* Support for temporary credentials with session tokens

## Installation and setup

[Section titled “Installation and setup”](#installation-and-setup)

In a JS/TS project, you may install the `@varlock/aws-secrets-plugin` package as a normal dependency. Otherwise you can just load it directly from your `.env.schema` file, as long as you add a version specifier. See the [plugins guide](/guides/plugins/#installation) for more instructions on installing plugins.

.env.schema

```env-spec
# 1. Load the plugin
# @plugin(@varlock/aws-secrets-plugin)
#
# 2. Initialize the plugin - see below for more details on options
# @initAws(region=us-east-1)
# ---
```

### Authentication options

[Section titled “Authentication options”](#authentication-options)

The plugin tries authentication methods in this priority order:

1. **Explicit credentials** - If `accessKeyId` and `secretAccessKey` are provided
2. **Named profile** - If `profile` is specified, uses credentials from `~/.aws/credentials`
3. **Default AWS credential chain** - Environment variables → `~/.aws/credentials` → IAM roles

### Automatic authentication (Recommended)

[Section titled “Automatic authentication (Recommended)”](#automatic-authentication-recommended)

For most use cases, you only need to provide the AWS region:

.env.schema

```env-spec
# @plugin(@varlock/aws-secrets-plugin)
# @initAws(region=us-east-1)
# ---
```

**How this works:**

* **Local development:** Run `aws configure` → automatically uses AWS CLI credentials
* **AWS-hosted apps** (EC2, ECS, Lambda, Fargate): Attach an IAM role → automatically authenticates (no secrets needed!)
* **Works everywhere** with zero configuration beyond the region!

### Explicit credentials (For non-AWS environments)

[Section titled “Explicit credentials (For non-AWS environments)”](#explicit-credentials-for-non-aws-environments)

If you’re deploying outside of AWS (e.g., Azure, GCP, on-premises), wire up IAM credentials:

1. **Create an IAM user** with the necessary permissions (see AWS Setup section below)

2. **Wire up the credentials in your config**. Add config items for the access key and secret key, and reference them when initializing the plugin.

   .env.schema

   ```env-spec
   # @plugin(@varlock/aws-secrets-plugin)
   # @initAws(
   #   region=us-east-1,
   #   accessKeyId=$AWS_ACCESS_KEY_ID,
   #   secretAccessKey=$AWS_SECRET_ACCESS_KEY
   # )
   # ---


   # @type=awsAccessKey
   AWS_ACCESS_KEY_ID=


   # @type=awsSecretKey @sensitive
   AWS_SECRET_ACCESS_KEY=
   ```

3. **Set your credentials in deployed environments**. Use your platform’s env var management UI to securely inject these values.

### Using named profiles

[Section titled “Using named profiles”](#using-named-profiles)

Use a specific profile from your `~/.aws/credentials` file:

.env.schema

```env-spec
# @plugin(@varlock/aws-secrets-plugin)
# @initAws(region=us-east-1, profile=production)
# ---
```

You can run `aws configure --profile production` to create additional profiles, or manually edit `~/.aws/credentials`:

```ini
[default]
aws_access_key_id = REDACTED_KEY_ID
aws_secret_access_key = REDACTED_SECRET_KEY


[production]
aws_access_key_id = REDACTED_PROD_KEY_ID
aws_secret_access_key = REDACTED_PROD_SECRET_KEY
```

### Multiple instances

[Section titled “Multiple instances”](#multiple-instances)

If you need to connect to multiple regions or use different authentication, register multiple named instances:

.env.schema

```env-spec
# @initAws(id=us, region=us-east-1)
# @initAws(id=eu, region=eu-west-1, profile=eu-prod)
# ---


US_DATABASE_URL=awsSecret(us, "db-connection")
EU_DATABASE_URL=awsSecret(eu, "db-connection")
```

## Loading secrets and parameters

[Section titled “Loading secrets and parameters”](#loading-secrets-and-parameters)

Once the plugin is installed and initialized, you can start adding config items that load values using the `awsSecret()` and `awsParam()` resolver functions.

### AWS Secrets Manager

[Section titled “AWS Secrets Manager”](#aws-secrets-manager)

The `awsSecret()` function fetches secrets from AWS Secrets Manager.

.env.schema

```env-spec
# Auto-infer secret names (DATABASE_URL -> "DATABASE_URL")
DATABASE_URL=awsSecret()
API_KEY=awsSecret()


# Explicit secret names
STRIPE_KEY=awsSecret("payments/stripe-secret-key")
```

### Systems Manager Parameter Store

[Section titled “Systems Manager Parameter Store”](#systems-manager-parameter-store)

The `awsParam()` function fetches parameters from Parameter Store.

.env.schema

```env-spec
# Parameters from Parameter Store
APP_CONFIG=awsParam("/prod/app/config")
FEATURE_FLAGS=awsParam("/prod/features")


# Auto-infer parameter names too
DATABASE_HOST=awsParam()
```

### JSON key extraction

[Section titled “JSON key extraction”](#json-key-extraction)

If your secrets or parameters contain JSON, you can extract specific keys:

.env.schema

```env-spec
# If "database-creds" contains: {"host": "db.example.com", "password": "secret"}


# Using # syntax (shorthand)
DB_HOST=awsSecret("database-creds#host")
DB_PASSWORD=awsSecret("database-creds#password")


# Or use named "key" parameter
DB_PORT=awsSecret("database-creds", key="port")
```

### Name prefixing

[Section titled “Name prefixing”](#name-prefixing)

Use `namePrefix` to automatically prefix all secret/parameter names for better organization:

.env.schema

```env-spec
# @initAws(region=us-east-1, namePrefix="prod/api/")
# ---


# Fetches "prod/api/DATABASE_URL"
DATABASE_URL=awsSecret()


# Fetches "prod/api/stripe-key"
STRIPE_KEY=awsSecret("stripe-key")
```

You can even use dynamic prefixes:

.env.schema

```env-spec
# @initAws(region=us-east-1, namePrefix="${ENV}/")
# ---


# In prod: fetches "prod/DATABASE_URL"
# In dev: fetches "dev/DATABASE_URL"
DATABASE_URL=awsSecret()
```

***

## AWS Setup

[Section titled “AWS Setup”](#aws-setup)

### Required IAM permissions

[Section titled “Required IAM permissions”](#required-iam-permissions)

Your IAM user or role needs specific permissions to access secrets and parameters.

#### For AWS Secrets Manager

[Section titled “For AWS Secrets Manager”](#for-aws-secrets-manager)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["secretsmanager:GetSecretValue"],
      "Resource": "arn:aws:secretsmanager:*:*:secret:*"
    }
  ]
}
```

#### For AWS Systems Manager Parameter Store

[Section titled “For AWS Systems Manager Parameter Store”](#for-aws-systems-manager-parameter-store)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["ssm:GetParameter"],
      "Resource": "arn:aws:ssm:*:*:parameter/*"
    }
  ]
}
```

Least privilege principle

For production, scope down the `Resource` field to only the specific secrets/parameters your application needs. For example: `"arn:aws:secretsmanager:us-east-1:123456789012:secret:prod/*"`

### IAM roles for AWS-hosted apps (Recommended)

[Section titled “IAM roles for AWS-hosted apps (Recommended)”](#iam-roles-for-aws-hosted-apps-recommended)

IAM roles are the AWS-native way to authenticate - no credentials needed!

1. **Create an IAM role** with the necessary permissions and trust policy for your service (EC2, ECS, or Lambda)

2. **Attach the role to your application**

   * **EC2:** Create an instance profile and attach it to your instance
   * **ECS:** Set the `taskRoleArn` in your task definition
   * **Lambda:** Set the execution role in your function configuration

3. **That’s it!** Your app will automatically authenticate using the IAM role.

See the [AWS documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html) for detailed instructions on creating and attaching IAM roles.

### IAM user for non-AWS environments

[Section titled “IAM user for non-AWS environments”](#iam-user-for-non-aws-environments)

1. **Create an IAM user**

   ```bash
   aws iam create-user --user-name varlock-secrets-reader
   ```

2. **Attach the permissions policy**

   ```bash
   aws iam put-user-policy \
     --user-name varlock-secrets-reader \
     --policy-name secrets-access \
     --policy-document file://policy.json
   ```

3. **Create access credentials**

   ```bash
   aws iam create-access-key --user-name varlock-secrets-reader
   ```

   Save the `AccessKeyId` and `SecretAccessKey` from the output - you’ll need them for your deployments.

### Configure AWS CLI for local development

[Section titled “Configure AWS CLI for local development”](#configure-aws-cli-for-local-development)

1. **Run `aws configure`**

   ```bash
   aws configure
   # AWS Access Key ID: [your key]
   # AWS Secret Access Key: [your secret]
   # Default region name: us-east-1
   # Default output format: json
   ```

2. **Test the configuration**

   ```bash
   aws sts get-caller-identity
   ```

***

## Reference

[Section titled “Reference”](#reference)

### Root decorators

[Section titled “Root decorators”](#root-decorators)

#### `@initAws()`

[Section titled “@initAws()”](#initaws)

Initialize an AWS plugin instance for accessing Secrets Manager and Parameter Store.

**Key/value args:**

* `region` (required): AWS region (e.g., `us-east-1`, `eu-west-1`)
* `namePrefix` (optional): Prefix automatically prepended to all secret/parameter names
* `accessKeyId` (optional): AWS access key ID for explicit authentication
* `secretAccessKey` (optional): AWS secret access key for explicit authentication
* `sessionToken` (optional): AWS session token for temporary credentials
* `profile` (optional): Named profile from `~/.aws/credentials`
* `id` (optional): Instance identifier for multiple instances

```env-spec
# @initAws(region=us-east-1, namePrefix="prod/api/")
# ---
```

### Data types

[Section titled “Data types”](#data-types)

#### `awsAccessKey`

[Section titled “awsAccessKey”](#awsaccesskey)

Represents an AWS access key ID (20-character alphanumeric string). Note that the type itself is marked as `@sensitive`, so adding an explicit `@sensitive` decorator is optional.

```env-spec
# @type=awsAccessKey
AWS_ACCESS_KEY_ID=
```

#### `awsSecretKey`

[Section titled “awsSecretKey”](#awssecretkey)

Represents an AWS secret access key (40-character string). This type is marked as `@sensitive`.

```env-spec
# @type=awsSecretKey
AWS_SECRET_ACCESS_KEY=
```

### Resolver functions

[Section titled “Resolver functions”](#resolver-functions)

#### `awsSecret()`

[Section titled “awsSecret()”](#awssecret)

Fetch a secret from AWS Secrets Manager.

**Array args:**

* `instanceId` (optional): instance identifier to use when multiple plugin instances are initialized
* `secretId` (optional): secret name, ARN, or name with JSON key using `#` syntax. If omitted, uses the variable name.
* `key` (optional, named parameter): JSON key to extract from the secret value

```env-spec
# Auto-infer secret name
DATABASE_URL=awsSecret()


# Explicit secret name
STRIPE_KEY=awsSecret("payments/stripe-key")


# Extract JSON key (shorthand)
DB_HOST=awsSecret("database-creds#host")


# Extract JSON key (named parameter)
DB_PORT=awsSecret("database-creds", key="port")


# With instance ID
US_SECRET=awsSecret(us, "my-secret")
```

#### `awsParam()`

[Section titled “awsParam()”](#awsparam)

Fetch a parameter from AWS Systems Manager Parameter Store.

**Array args:**

* `instanceId` (optional): instance identifier to use when multiple plugin instances are initialized
* `parameterName` (optional): parameter name/path or name with JSON key using `#` syntax. If omitted, uses the variable name.
* `key` (optional, named parameter): JSON key to extract from the parameter value

```env-spec
# Auto-infer parameter name
DATABASE_HOST=awsParam()


# Explicit parameter path
APP_CONFIG=awsParam("/prod/app/config")


# Extract JSON key
DB_CREDS=awsParam("/prod/db/creds#password")


# With instance ID
EU_CONFIG=awsParam(eu, "/prod/config")
```

***

## Troubleshooting

[Section titled “Troubleshooting”](#troubleshooting)

### Secret not found

[Section titled “Secret not found”](#secret-not-found)

* Verify the secret exists: `aws secretsmanager list-secrets --query 'SecretList[?Name==\`my-secret\`]’\`
* Check you’re using the correct region
* Ensure the secret name matches exactly (including any prefix)

### Parameter not found

[Section titled “Parameter not found”](#parameter-not-found)

* Verify the parameter exists: `aws ssm describe-parameters --parameter-filters "Key=Name,Values=/my/param"`
* Check you’re using the correct region
* Parameter Store paths are case-sensitive

### Permission denied

[Section titled “Permission denied”](#permission-denied)

* Check your IAM permissions: Test with `aws sts get-caller-identity` to see which identity you’re using
* For IAM roles on EC2/ECS/Lambda: Verify the role is attached and has the required permissions
* Ensure the IAM policy includes `secretsmanager:GetSecretValue` and/or `ssm:GetParameter`

### Authentication failed

[Section titled “Authentication failed”](#authentication-failed)

* **Local dev:** Run `aws configure` or ensure `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` are set
* **AWS-hosted apps:** Verify IAM role is attached
* **Other environments:** Verify credentials are correct and properly injected
* Test credentials: `aws sts get-caller-identity`

### JSON parsing errors

[Section titled “JSON parsing errors”](#json-parsing-errors)

* Verify your secret/parameter contains valid JSON
* Check that the key you’re extracting exists in the JSON
* Test manually: `aws secretsmanager get-secret-value --secret-id my-secret --query SecretString --output text | jq .`

## Resources

[Section titled “Resources”](#resources)

* [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/)
* [AWS Systems Manager Parameter Store](https://aws.amazon.com/systems-manager/features/#Parameter_Store)
* [IAM Roles](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html)
* [AWS SDK for JavaScript](https://docs.aws.amazon.com/AWSJavaScriptSDK/v3/latest/)

# Azure Key Vault Plugin

> Using Azure Key Vault with Varlock

[![](https://img.shields.io/npm/v/@varlock/azure-key-vault-plugin?label=%40varlock%2Fazure-key-vault-plugin\&color=9B55F5\&logo=npm)](https://www.npmjs.com/package/@varlock/azure-key-vault-plugin)

Our [Azure Key Vault](https://azure.microsoft.com/en-us/products/key-vault) plugin enables secure loading of secrets from Azure Key Vault using declarative instructions within your `.env` files.

The plugin automatically integrates with Azure authentication, including Managed Identity for Azure-hosted applications, Azure CLI credentials for local development, and service principal credentials for non-Azure environments.

## Features

[Section titled “Features”](#features)

* **Zero-config authentication** - Just provide your vault URL, authentication happens automatically
* **Managed Identity support** - No credentials needed for Azure-hosted apps (App Service, Container Instances, VMs, Functions, AKS)
* **Azure CLI authentication** - Works seamlessly with `az login` for local development
* **Auto-infer secret names** from environment variable names (e.g., `DATABASE_URL` → `database-url`)
* Support for service principal credentials (for non-Azure environments)
* Support for versioned secrets
* Automatic token caching and renewal
* Lightweight implementation using REST API (47 KB bundle, no heavy Azure SDK dependencies)

## Installation and setup

[Section titled “Installation and setup”](#installation-and-setup)

In a JS/TS project, you may install the `@varlock/azure-key-vault-plugin` package as a normal dependency. Otherwise you can just load it directly from your `.env.schema` file, as long as you add a version specifier. See the [plugins guide](/guides/plugins/#installation) for more instructions on installing plugins.

.env.schema

```env-spec
# 1. Load the plugin
# @plugin(@varlock/azure-key-vault-plugin)
#
# 2. Initialize the plugin - see below for more details on options
# @initAzure(vaultUrl="https://my-vault.vault.azure.net/")
# ---
```

### Authentication options

[Section titled “Authentication options”](#authentication-options)

The plugin tries authentication methods in this priority order:

1. **Service Principal** - If all three credentials (`tenantId`, `clientId`, `clientSecret`) are provided
2. **Managed Identity** - Automatically used when running on Azure infrastructure
3. **Azure CLI** - Falls back to `az login` for local development

### Automatic authentication (Recommended)

[Section titled “Automatic authentication (Recommended)”](#automatic-authentication-recommended)

For most use cases, you only need to provide the vault URL:

.env.schema

```env-spec
# @plugin(@varlock/azure-key-vault-plugin)
# @initAzure(vaultUrl="https://my-vault.vault.azure.net/")
# ---
```

**How this works:**

* **Local development:** Run `az login` → automatically uses Azure CLI credentials
* **Azure-hosted apps** (App Service, Container Instances, VMs, Functions, AKS): Enable Managed Identity → automatically authenticates (no secrets needed!)
* **Works everywhere** with zero configuration beyond the vault URL!

Finding your vault URL

Run `az keyvault show --name my-vault --query properties.vaultUri -o tsv` to get your vault URL.

### Service principal credentials (For non-Azure environments)

[Section titled “Service principal credentials (For non-Azure environments)”](#service-principal-credentials-for-non-azure-environments)

If you’re deploying outside of Azure (e.g., AWS, GCP, on-premises), wire up service principal credentials:

1. **Create a service principal** with the necessary permissions (see Azure Setup section below)

2. **Wire up the credentials in your config**. Add config items for the tenant ID, client ID, and client secret, and reference them when initializing the plugin.

   .env.schema

   ```env-spec
   # @plugin(@varlock/azure-key-vault-plugin)
   # @initAzure(
   #   vaultUrl="https://my-vault.vault.azure.net/",
   #   tenantId=$AZURE_TENANT_ID,
   #   clientId=$AZURE_CLIENT_ID,
   #   clientSecret=$AZURE_CLIENT_SECRET
   # )
   # ---


   # @type=azureTenantId @sensitive
   AZURE_TENANT_ID=


   # @type=azureClientId @sensitive
   AZURE_CLIENT_ID=


   # @type=azureClientSecret @sensitive
   AZURE_CLIENT_SECRET=
   ```

3. **Set your credentials in deployed environments**. Use your platform’s env var management UI to securely inject these values.

### Multiple vaults

[Section titled “Multiple vaults”](#multiple-vaults)

If you need to connect to multiple vaults, but never at the same time, you can alter the vault URL using a function:

.env.schema

```env-spec
# @plugin(@varlock/azure-key-vault-plugin)
# @initAzure(vaultUrl="https://my-vault-${ENV}.vault.azure.net/")
# ---
```

Or if you need to connect to multiple vaults simultaneously, register multiple named instances:

.env.schema

```env-spec
# @initAzure(id=prod, vaultUrl="https://my-vault-prod.vault.azure.net/")
# @initAzure(id=dev, vaultUrl="https://my-vault-dev.vault.azure.net/")
# ---


PROD_SECRET=azureSecret(prod, "database-url")
DEV_SECRET=azureSecret(dev, "database-url")
```

## Loading secrets

[Section titled “Loading secrets”](#loading-secrets)

Once the plugin is installed and initialized, you can start adding config items that load values using the `azureSecret()` resolver function.

### Basic usage

[Section titled “Basic usage”](#basic-usage)

The `azureSecret()` function fetches secrets from Azure Key Vault.

.env.schema

```env-spec
# Auto-infer secret names (DATABASE_URL -> "database-url")
DATABASE_URL=azureSecret()
API_KEY=azureSecret()


# Explicit secret names
CUSTOM_SECRET=azureSecret("my-custom-secret-name")
```

Secret name conversion

Azure Key Vault uses hyphens instead of underscores. When auto-inferring, the plugin automatically converts `DATABASE_URL` to `database-url` to match Azure’s naming convention.

### Versioned secrets

[Section titled “Versioned secrets”](#versioned-secrets)

You can fetch specific versions of secrets by appending `@version` to the secret name:

.env.schema

```env-spec
# Fetch latest version (default)
API_KEY=azureSecret("api-key")


# Fetch specific version
API_KEY_V1=azureSecret("api-key@abc123def456")
```

***

## Azure Setup

[Section titled “Azure Setup”](#azure-setup)

### Required permissions

[Section titled “Required permissions”](#required-permissions)

Your managed identity, service principal, or user needs one of:

* **Access Policy**: “Get” permission for secrets
* **RBAC**: “Key Vault Secrets User” role

### Managed Identity for Azure-hosted apps (Recommended)

[Section titled “Managed Identity for Azure-hosted apps (Recommended)”](#managed-identity-for-azure-hosted-apps-recommended)

Managed Identity is the Azure-native way to authenticate - no credentials needed!

1. **Enable system-assigned managed identity** for your Azure resource

   ```bash
   # For App Service
   az webapp identity assign --name my-app --resource-group my-rg


   # For Container Instance
   az container create --assign-identity --name my-container ...


   # For VM
   az vm identity assign --name my-vm --resource-group my-rg
   ```

2. **Grant Key Vault access to the identity**

   Get the identity’s principal ID:

   ```bash
   PRINCIPAL_ID=$(az webapp identity show --name my-app --resource-group my-rg --query principalId -o tsv)
   ```

   Then grant access using either RBAC or Access Policy:

   **Option A: RBAC (Recommended)**

   ```bash
   az role assignment create \
     --role "Key Vault Secrets User" \
     --assignee $PRINCIPAL_ID \
     --scope /subscriptions/<sub-id>/resourceGroups/<rg>/providers/Microsoft.KeyVault/vaults/<vault-name>
   ```

   **Option B: Access Policy**

   ```bash
   az keyvault set-policy \
     --name my-vault \
     --object-id $PRINCIPAL_ID \
     --secret-permissions get
   ```

3. **That’s it!** Your app will automatically authenticate using Managed Identity.

### Service principal for non-Azure environments

[Section titled “Service principal for non-Azure environments”](#service-principal-for-non-azure-environments)

1. **Create a service principal**

   ```bash
   az ad sp create-for-rbac --name "varlock-keyvault-reader"
   ```

   Save the `appId`, `password`, and `tenant` from the output.

2. **Grant Key Vault access**

   **Option A: RBAC (Recommended)**

   ```bash
   az role assignment create \
     --role "Key Vault Secrets User" \
     --assignee <appId> \
     --scope /subscriptions/<sub-id>/resourceGroups/<rg>/providers/Microsoft.KeyVault/vaults/<vault-name>
   ```

   **Option B: Access Policy**

   ```bash
   az keyvault set-policy \
     --name my-vault \
     --spn <appId> \
     --secret-permissions get
   ```

### Azure CLI for local development

[Section titled “Azure CLI for local development”](#azure-cli-for-local-development)

1. **Install the Azure CLI** if you haven’t already: [Installation guide](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)

2. **Log in to Azure**

   ```bash
   az login
   ```

3. **Verify your identity**

   ```bash
   az account show
   ```

4. **Grant Key Vault access to your user account** (if needed)

   ```bash
   az keyvault set-policy \
     --name my-vault \
     --upn your-email@domain.com \
     --secret-permissions get
   ```

***

## Reference

[Section titled “Reference”](#reference)

### Root decorators

[Section titled “Root decorators”](#root-decorators)

#### `@initAzure()`

[Section titled “@initAzure()”](#initazure)

Initialize an Azure Key Vault plugin instance for accessing secrets.

**Key/value args:**

* `vaultUrl` (required): Azure Key Vault URL (e.g., `https://my-vault.vault.azure.net/`)
* `tenantId` (optional): Azure AD tenant ID (directory ID)
* `clientId` (optional): Service principal application (client) ID
* `clientSecret` (optional): Service principal client secret (password)
* `id` (optional): Instance identifier for multiple vaults

```env-spec
# @initAzure(vaultUrl="https://my-vault.vault.azure.net/")
# ---
```

### Data types

[Section titled “Data types”](#data-types)

#### `azureTenantId`

[Section titled “azureTenantId”](#azuretenantid)

Represents an Azure AD tenant ID (UUID format). This type is marked as `@sensitive`.

```env-spec
# @type=azureTenantId
AZURE_TENANT_ID=
```

#### `azureClientId`

[Section titled “azureClientId”](#azureclientid)

Represents a service principal application (client) ID (UUID format). This type is marked as `@sensitive`.

```env-spec
# @type=azureClientId
AZURE_CLIENT_ID=
```

#### `azureClientSecret`

[Section titled “azureClientSecret”](#azureclientsecret)

Represents a service principal client secret (password). This type is marked as `@sensitive`.

```env-spec
# @type=azureClientSecret
AZURE_CLIENT_SECRET=
```

### Resolver functions

[Section titled “Resolver functions”](#resolver-functions)

#### `azureSecret()`

[Section titled “azureSecret()”](#azuresecret)

Fetch a secret from Azure Key Vault.

**Array args:**

* `instanceId` (optional): instance identifier to use when multiple plugin instances are initialized
* `secretName` (optional): secret name or name with version using `@` syntax. If omitted, uses the variable name (converted to kebab-case).

```env-spec
# Auto-infer secret name (DATABASE_URL -> "database-url")
DATABASE_URL=azureSecret()


# Explicit secret name
CUSTOM_SECRET=azureSecret("my-custom-secret")


# Specific version
API_KEY_V1=azureSecret("api-key@abc123def456")


# With instance ID
PROD_SECRET=azureSecret(prod, "database-url")
```

***

## Troubleshooting

[Section titled “Troubleshooting”](#troubleshooting)

### Secret not found

[Section titled “Secret not found”](#secret-not-found)

* Verify the secret exists: `az keyvault secret list --vault-name my-vault`
* Remember: Azure uses hyphens, not underscores (use `database-url` not `database_url`)
* Check for typos in the secret name

### Permission denied

[Section titled “Permission denied”](#permission-denied)

* Check your RBAC role: `az role assignment list --assignee <your-id> --scope <vault-scope>`
* Or check access policies: `az keyvault show --name my-vault --query properties.accessPolicies`
* Ensure your identity has “Get” permission for secrets

### Authentication failed

[Section titled “Authentication failed”](#authentication-failed)

* **Local dev:** Run `az login` and ensure service principal env vars are empty
* **Azure-hosted apps:** Verify Managed Identity is enabled and has Key Vault permissions
* **Other environments:** Verify service principal credentials are correct and properly injected
* Test identity: `az account show`

### Vault not accessible

[Section titled “Vault not accessible”](#vault-not-accessible)

* Verify the vault URL is correct
* Check network access: Ensure firewall rules allow access from your IP/resource
* Verify the vault exists in the specified subscription

## Resources

[Section titled “Resources”](#resources)

* [Azure Key Vault](https://azure.microsoft.com/en-us/products/key-vault)
* [Managed Identity](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview)
* [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/)
* [Key Vault Access Policies](https://learn.microsoft.com/en-us/azure/key-vault/general/assign-access-policy)

# Bitwarden Plugin

> Using Bitwarden Secrets Manager with Varlock

[![](https://img.shields.io/npm/v/@varlock/bitwarden-plugin?label=%40varlock%2Fbitwarden-plugin\&color=9B55F5\&logo=npm)](https://www.npmjs.com/package/@varlock/bitwarden-plugin)

Our [Bitwarden Secrets Manager](https://bitwarden.com/products/secrets-manager/) plugin enables secure loading of secrets from Bitwarden using declarative instructions within your `.env` files.

The plugin uses machine account access tokens for programmatic access to your Bitwarden secrets, making it suitable for both CI/CD and production environments.

## Features

[Section titled “Features”](#features)

* **Zero-config authentication** - Just provide your machine account access token
* **UUID-based secret access** - Fetch secrets by their unique identifiers
* **Self-hosted Bitwarden support** - Configure custom API and identity URLs
* **Multiple instances** - Connect to different organizations or self-hosted instances
* **Comprehensive error handling** with helpful tips
* **Lightweight implementation** using REST API (48 KB bundle, no native SDK dependencies)

## Installation and setup

[Section titled “Installation and setup”](#installation-and-setup)

In a JS/TS project, you may install the `@varlock/bitwarden-plugin` package as a normal dependency. Otherwise you can just load it directly from your `.env.schema` file, as long as you add a version specifier. See the [plugins guide](/guides/plugins/#installation) for more instructions on installing plugins.

.env.schema

```env-spec
# 1. Load the plugin
# @plugin(@varlock/bitwarden-plugin)
#
# 2. Initialize the plugin - see below for more details on options
# @initBitwarden(accessToken=$BITWARDEN_ACCESS_TOKEN)
# ---


# 3. Add a machine account access token config item
# @type=bitwardenAccessToken @sensitive
BITWARDEN_ACCESS_TOKEN=
```

### Machine account setup

[Section titled “Machine account setup”](#machine-account-setup)

1. **Create a machine account** in your Bitwarden organization

   Navigate to your Bitwarden organization’s **Secrets Manager** → **Machine accounts** → Click **New machine account**.

   Provide a name (e.g., “Production App”) and save it.

2. **Copy the access token** (displayed only once!)

   After creating the machine account, you’ll see an **Access token**. Copy it immediately - it will only be displayed once.

   Save the token securely

   Store the access token securely. You won’t be able to see it again after this step!

3. **Grant access to secrets**

   Grant your machine account access to the specific projects or secrets you need.

   **Via Projects:**

   * Create or select a project in Secrets Manager
   * Add secrets to the project
   * Grant your machine account access to the project

   **Direct Secret Access:**

   * Navigate to a specific secret
   * Click **Access**
   * Add your machine account with “Can read” permissions

4. **Wire up the token in your config**

   .env.schema

   ```env-spec
   # @plugin(@varlock/bitwarden-plugin)
   # @initBitwarden(accessToken=$BITWARDEN_ACCESS_TOKEN)
   # ---


   # @type=bitwardenAccessToken @sensitive
   BITWARDEN_ACCESS_TOKEN=
   ```

5. **Set your access token in environments**

   Use your CI/CD system or platform’s env var management to securely inject the `BITWARDEN_ACCESS_TOKEN` value.

Permission levels

Machine accounts can have *Can read* (retrieve secrets only) or *Can read, write* (retrieve, create, and edit secrets) permissions. For most use cases, *Can read* is sufficient.

### Self-hosted Bitwarden

[Section titled “Self-hosted Bitwarden”](#self-hosted-bitwarden)

For self-hosted Bitwarden instances, you’ll need to provide both the API and identity URLs:

.env.schema

```env-spec
# @plugin(@varlock/bitwarden-plugin)
# @initBitwarden(
#   accessToken=$BITWARDEN_ACCESS_TOKEN,
#   apiUrl="https://bitwarden.yourcompany.com/api",
#   identityUrl="https://bitwarden.yourcompany.com/identity"
# )
# ---
```

### Multiple instances

[Section titled “Multiple instances”](#multiple-instances)

If you need to connect to multiple organizations or instances, register multiple named instances:

.env.schema

```env-spec
# @initBitwarden(id=prod, accessToken=$PROD_ACCESS_TOKEN)
# @initBitwarden(id=dev, accessToken=$DEV_ACCESS_TOKEN)
# ---


PROD_SECRET=bitwarden(prod, "11111111-1111-1111-1111-111111111111")
DEV_SECRET=bitwarden(dev, "22222222-2222-2222-2222-222222222222")
```

## Loading secrets

[Section titled “Loading secrets”](#loading-secrets)

Once the plugin is installed and initialized, you can start adding config items that load values using the `bitwarden()` resolver function.

### Basic usage

[Section titled “Basic usage”](#basic-usage)

Fetch secrets by their UUID:

.env.schema

```env-spec
# Fetch secrets by UUID
DATABASE_URL=bitwarden("12345678-1234-1234-1234-123456789abc")
API_KEY=bitwarden("87654321-4321-4321-4321-cba987654321")
```

Finding secret UUIDs

To find a secret’s UUID:

1. Open your Bitwarden Secrets Manager
2. Navigate to the secret
3. Copy the UUID from the URL or secret details (format: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`)

### Multiple instances

[Section titled “Multiple instances”](#multiple-instances-1)

If you have multiple plugin instances, specify which instance to use:

.env.schema

```env-spec
PROD_ITEM=bitwarden(prod, "11111111-1111-1111-1111-111111111111")
DEV_ITEM=bitwarden(dev, "22222222-2222-2222-2222-222222222222")
```

***

## Bitwarden Setup

[Section titled “Bitwarden Setup”](#bitwarden-setup)

### Create a machine account

[Section titled “Create a machine account”](#create-a-machine-account)

Machine accounts provide programmatic access to Bitwarden Secrets Manager.

1. **Log in to your Bitwarden organization** web vault

2. **Navigate to Secrets Manager → Machine accounts**

3. **Click “New machine account”**

4. **Provide a name** (e.g., “Production App”)

5. **Copy the Access token** (shown only once!)

6. **Grant access** to specific projects or secrets

**Permission Levels:**

* **Can read** - Retrieve secrets only (recommended for most use cases)
* **Can read, write** - Retrieve, create, and edit secrets

Access token security

Store the access token securely - it will only be displayed once during creation!

### Grant access to secrets

[Section titled “Grant access to secrets”](#grant-access-to-secrets)

**Via Projects (Recommended):**

1. Create or select a project in Secrets Manager
2. Add secrets to the project
3. Grant your machine account access to the project

This approach makes it easier to manage access to multiple secrets at once.

**Direct Secret Access:**

1. Navigate to a specific secret
2. Click **Access**
3. Add your machine account with appropriate permissions

***

## Reference

[Section titled “Reference”](#reference)

### Root decorators

[Section titled “Root decorators”](#root-decorators)

#### `@initBitwarden()`

[Section titled “@initBitwarden()”](#initbitwarden)

Initialize a Bitwarden Secrets Manager plugin instance for accessing secrets.

**Key/value args:**

* `accessToken` (required): Machine account access token. Should be a reference to a config item of type `bitwardenAccessToken`.
* `apiUrl` (optional): API URL for self-hosted Bitwarden (defaults to `https://api.bitwarden.com`)
* `identityUrl` (optional): Identity service URL for self-hosted Bitwarden (defaults to `https://identity.bitwarden.com`)
* `id` (optional): Instance identifier for multiple instances

```env-spec
# @initBitwarden(accessToken=$BITWARDEN_ACCESS_TOKEN)
# ---
# @type=bitwardenAccessToken @sensitive
BITWARDEN_ACCESS_TOKEN=
```

### Data types

[Section titled “Data types”](#data-types)

#### `bitwardenAccessToken`

[Section titled “bitwardenAccessToken”](#bitwardenaccesstoken)

Represents a Bitwarden Secrets Manager machine account access token. Validation ensures the token is in the correct format (`0.<client_id>.<client_secret>:<encryption_key>`). Note that the type itself is marked as `@sensitive`, so adding an explicit `@sensitive` decorator is optional.

```env-spec
# @type=bitwardenAccessToken
BITWARDEN_ACCESS_TOKEN=
```

#### `bitwardenSecretId`

[Section titled “bitwardenSecretId”](#bitwardensecretid)

Represents a secret UUID in Bitwarden Secrets Manager. Validation ensures the ID is a valid UUID format.

```env-spec
# @type=bitwardenSecretId
MY_SECRET_ID=12345678-1234-1234-1234-123456789abc
```

#### `bitwardenOrganizationId`

[Section titled “bitwardenOrganizationId”](#bitwardenorganizationid)

Represents an organization UUID in Bitwarden. Validation ensures the ID is a valid UUID format.

```env-spec
# @type=bitwardenOrganizationId
BITWARDEN_ORG_ID=87654321-4321-4321-4321-cba987654321
```

### Resolver functions

[Section titled “Resolver functions”](#resolver-functions)

#### `bitwarden()`

[Section titled “bitwarden()”](#bitwarden)

Fetch a secret from Bitwarden Secrets Manager by UUID.

**Array args:**

* `instanceId` (optional): instance identifier to use when multiple plugin instances are initialized
* `secretId` (required): secret UUID in the format `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`

```env-spec
# Fetch by secret UUID
DATABASE_URL=bitwarden("12345678-1234-1234-1234-123456789abc")


# With instance ID
PROD_SECRET=bitwarden(prod, "11111111-1111-1111-1111-111111111111")
```

***

## Troubleshooting

[Section titled “Troubleshooting”](#troubleshooting)

### Secret not found

[Section titled “Secret not found”](#secret-not-found)

* Verify the secret UUID is correct (must be valid UUID format)
* Check that the secret exists in your Bitwarden Secrets Manager
* Ensure your machine account has access to the secret or its project

### Permission denied

[Section titled “Permission denied”](#permission-denied)

* Verify your machine account has “Can read” or “Can read, write” permissions
* Check that the machine account has access to the specific secret
* Review the access settings in Bitwarden Secrets Manager console

### Authentication failed

[Section titled “Authentication failed”](#authentication-failed)

* Verify the access token is correct
* Check if the access token has been revoked or expired
* Ensure the machine account is not disabled
* For self-hosted: verify `apiUrl` and `identityUrl` are correct

### Invalid UUID format

[Section titled “Invalid UUID format”](#invalid-uuid-format)

* Secret IDs must be valid UUIDs: `12345678-1234-1234-1234-123456789abc`
* Check for typos or incorrect format
* UUIDs should contain 32 hexadecimal characters and 4 hyphens

## Resources

[Section titled “Resources”](#resources)

* [Bitwarden Secrets Manager](https://bitwarden.com/products/secrets-manager/)
* [Machine Accounts Documentation](https://bitwarden.com/help/machine-accounts/)
* [Self-Hosting Bitwarden](https://bitwarden.com/help/manage-your-secrets-org/#self-hosting)

# Google Secret Manager Plugin

> Using Google Cloud Secret Manager with Varlock

[![](https://img.shields.io/npm/v/@varlock/google-secret-manager-plugin?label=%40varlock%2Fgoogle-secret-manager-plugin\&color=9B55F5\&logo=npm)](https://www.npmjs.com/package/@varlock/google-secret-manager-plugin)

Our [Google Cloud Secret Manager](https://cloud.google.com/secret-manager) plugin enables secure loading of secrets from GCP Secret Manager using declarative instructions within your `.env` files.

It supports authentication via [Application Default Credentials (ADC)](https://cloud.google.com/docs/authentication/application-default-credentials) or explicitly passing in a service account JSON key.

**Key features:**

* ✅ Automatic secret naming using config item keys
* ✅ Application Default Credentials or Service Account authentication
* ✅ Versioned secret access
* ✅ Multiple plugin instances for different projects

## Installation and setup

[Section titled “Installation and setup”](#installation-and-setup)

In a JS/TS project, you may install the `@varlock/google-secret-manager-plugin` package as a normal dependency. Otherwise you can just load it directly from your `.env.schema` file, as long as you add a version specifier. See the [plugins guide](/guides/plugins/#installation) for more instructions on installing plugins.

.env.schema

```env-spec
# 1. Load the plugin
# @plugin(@varlock/google-secret-manager-plugin)
#
# 2. Initialize the plugin - see below for more details on options
# @initGsm(projectId=my-gcp-project)
# ---
```

Project ID

The `projectId` parameter is optional if your service account JSON includes a `project_id` field, or if you have set `GOOGLE_CLOUD_PROJECT` in your environment. However, it’s recommended to set it explicitly for clarity. If you don’t provide `projectId` and are using ADC, the plugin will attempt to detect it from your `gcloud` configuration or environment variables.

### Using Application Default Credentials (ADC) - recommended

[Section titled “Using Application Default Credentials (ADC) - recommended”](#using-application-default-credentials-adc---recommended)

By default (when no `credentials` parameter is set), this plugin will use [Application Default Credentials (ADC)](https://cloud.google.com/docs/authentication/application-default-credentials) to authenticate with Google Cloud. This is the recommended way to authenticate for local dev, and within GCP.

Within GCP, you will need to set up a [service account](https://cloud.google.com/iam/docs/service-accounts) with the correct permissions, and attach it to the resources where your code will be running.

Outside of GCP, you may set up ADC credentials using the [`gcloud auth application-default login`](https://docs.cloud.google.com/sdk/gcloud/reference/auth/application-default/login) command, which will store credentials locally, and make them available for ADC.

### Using a service account key

[Section titled “Using a service account key”](#using-a-service-account-key)

In rare cases, it may be useful to pass in a service account key explicitly. This is useful for deployed environments other than GCP, or if you need to use a different service account than the one attached to your service.

1. **Create and download a JSON key** for your service account. This can be done via the [Cloud Console](https://console.cloud.google.com/iam-admin/serviceaccounts) or using the `gcloud` CLI. [docs](https://cloud.google.com/iam/docs/keys-create-delete)

   ```bash
   gcloud iam service-accounts keys create key.json \
     --iam-account=SERVICE_ACCOUNT_EMAIL
   ```

2. **Wire up the service account key in your config**. Add a config item of type `gcpServiceAccountJson` to hold the key value, and reference it when initializing the plugin.

   .env.schema

   ```diff
   # @plugin(@varlock/google-secret-manager-plugin)
   # @initGsm(projectId=my-gcp-project, credentials=$GCP_SA_KEY)
   # ---
   +# @type=gcpServiceAccountJson @sensitive
   GCP_SA_KEY=
   ```

3. **Set your service account key in deployed environments**. Copy the JSON key content from the file you downloaded, and set it in deployed environments using your platform’s env var management UI. Be sure to use the same name as you defined in your schema (e.g. `GCP_SA_KEY`).

Keep service account keys secure

Service account JSON keys are highly sensitive credentials. Store them securely and never commit them to version control. Consider using your platform’s secret management system to store the key itself.

### GCP Prerequisites

[Section titled “GCP Prerequisites”](#gcp-prerequisites)

If you are already using GCP Secret Manager, you likely have completed these steps already, but if not, you will need to do so before using this plugin:

1. **Enable the Secret Manager API** (if not already done)

   Go to the Google Cloud Console and enable the Secret Manager API for your project.

2. **Create a new service account** in your GCP project. This can be done via the [Google Cloud Console](https://console.cloud.google.com/iam-admin/serviceaccounts) or using the `gcloud` CLI. [docs](https://cloud.google.com/iam/docs/service-accounts-create)

   This service account, whether accessed using ADC or a service account key, will now serve as your *secret-zero* - which grants access to the rest of your sensitive data stored in Secret Manager.

3. **Grant the service account permissions** to access secrets. The service account needs the `Secret Manager Secret Accessor` role (`roles/secretmanager.secretAccessor`) on the secrets or project level. [docs](https://cloud.google.com/secret-manager/docs/access-control)

   ```bash
   gcloud projects add-iam-policy-binding PROJECT_ID \
     --member="serviceAccount:SERVICE_ACCOUNT_EMAIL" \
     --role="roles/secretmanager.secretAccessor"
   ```

4. **Attach the service account to GCP resources**

   You must [attach this service account](https://docs.cloud.google.com/iam/docs/attach-service-accounts#attaching-to-resources) to any resources where your code will be running.

## Pulling data from Secret Manager

[Section titled “Pulling data from Secret Manager”](#pulling-data-from-secret-manager)

Once the plugin is installed and initialized, you can start adding config items that load values from Google Secret Manager using the new `gsm()` resolver function.

### Basic Secret Fetching

[Section titled “Basic Secret Fetching”](#basic-secret-fetching)

```env-spec
# @plugin(@varlock/google-secret-manager-plugin)
# @initGsm(projectId=my-project)
# ---


# Secret name defaults to the config item key
SIMPLEST_VAR=gsm()


# Or you can explicitly specify the secret name
RENAMED_VAR=gsm("database-password")


# You can fetch a specific version
API_KEY_LATEST=gsm("api-key@latest")
API_KEY_V5=gsm("api-key@5")


# Use complete resource paths for maximum control:
FULL_PATH_VAR=gsm("projects/my-project/secrets/db-url/versions/3")
```

Auto-naming

When called without arguments, `gsm()` automatically uses the config item key as the secret name in Google Secret Manager (e.g., `DATABASE_URL=gsm()` will fetch a secret named `DATABASE_URL`). This provides a clean, convention-over-configuration approach when your secret names match your config keys.

Secret versions

If you don’t specify a version in the short format, `latest` will be used automatically. For the full path format, you must include the version (use `latest` if you want the most recent version).

### Multiple plugin instances

[Section titled “Multiple plugin instances”](#multiple-plugin-instances)

If you need to connect using different project ids, or different credentials, particularly at the same time, you can create multiple named instances, and then use that id when fetching secrets.

```env-spec
# @plugin(@varlock/google-secret-manager-plugin)
# @initGsm(id=prod, projectId=prod-project, credentials=$PROD_KEY)
# @initGsm(id=dev, projectId=dev-project, credentials=$DEV_KEY)
# ---


PROD_DATABASE=gsm(prod, "database-url")
DEV_DATABASE=gsm(dev, "database-url")
```

### Dynamic project ID

[Section titled “Dynamic project ID”](#dynamic-project-id)

The `projectId` parameter supports dynamic resolution, allowing you to specify project IDs from environment variables or other resolver functions. This is useful when you need to use different project IDs based on your deployment environment.

```env-spec
# @plugin(@varlock/google-secret-manager-plugin)
# @initGsm(projectId=$GCP_PROJECT_ID)
# ---
# Use environment variable for project ID
GCP_PROJECT_ID=
API_KEY=gsm("api-key")
```

You can also use resolver functions to construct the project ID dynamically:

```env-spec
# @plugin(@varlock/google-secret-manager-plugin)
# @initGsm(projectId=concat($APP_ENV, "-project"))
# ---
APP_ENV=
API_KEY=gsm("api-key")
```

***

## Reference

[Section titled “Reference”](#reference)

### Root decorators

[Section titled “Root decorators”](#root-decorators)

#### `@initGsm()`

[Section titled “@initGsm()”](#initgsm)

Initializes an instance of the Google Secret Manager plugin - setting up options and authentication. Can be called multiple times to set up different instances.

**Key/value args:**

* `id` (optional): identifier for this instance, used when multiple instances are needed
* `projectId` (optional): GCP project ID. Required for short secret reference format, or if credentials don’t include a `project_id` field
* `credentials` (optional): service account JSON key. Should be a reference to a config item of type `gcpServiceAccountJson`. If omitted, Application Default Credentials will be used

```env-spec
# @initGsm(id=prod, projectId=my-gcp-project, credentials=$GCP_SA_KEY)
# ---
# @type=gcpServiceAccountJson @sensitive
GCP_SA_KEY=
```

### Data types

[Section titled “Data types”](#data-types)

#### `gcpServiceAccountJson`

[Section titled “gcpServiceAccountJson”](#gcpserviceaccountjson)

Represents a [Google Cloud service account JSON key](https://cloud.google.com/iam/docs/service-accounts). Validation ensures the JSON is valid and contains required fields (`type`, `project_id`, `private_key`, `client_email`). The type itself is marked as `@sensitive`, so adding an explicit `@sensitive` decorator is optional.

```env-spec
# @type=gcpServiceAccountJson
GCP_SA_KEY=
```

### Resolver functions

[Section titled “Resolver functions”](#resolver-functions)

#### `gsm()`

[Section titled “gsm()”](#gsm)

Fetches a secret value from Google Secret Manager

**Signatures:**

* `gsm()` - Fetch using config item key as secret name from default instance (e.g., `DATABASE_URL=gsm()` will fetch a secret named `DATABASE_URL`)
* `gsm(secretRef)` - Fetch specific secret from default instance
* `gsm(instanceId, secretRef)` - Fetch from named instance

**Array args:**

* `instanceId` (optional): instance identifier to use when multiple plugin instances are initialized
* `secretReference` (optional): secret reference, either in short format (`"secret-name"` or `"secret-name@version"`) or full path format (`"projects/PROJECT_ID/secrets/SECRET_NAME/versions/VERSION"`). If omitted, uses the config item key as the secret name

**Secret Reference Formats:**

* `"secret-name"` - Uses latest version from configured project
* `"secret-name@5"` - Specific version from configured project
* `"projects/PROJECT/secrets/NAME/versions/VERSION"` - Full resource path

**Returns:** The secret value as a string

```env-spec
# Secret name defaults to the config item key
SIMPLEST_VAR=gsm()


# Or you can explicitly specify the secret name
RENAMED_VAR=gsm("database-password")


# You can fetch a specific version
API_KEY_V5=gsm("api-key@5")


# Use complete resource paths for maximum control:
FULL_PATH_VAR=gsm("projects/my-project/secrets/db-url/versions/3")


# Example using a plugin instance id
PROD_SECRET=gsm(prod, "prod-secret")
```

# Infisical Plugin

> Using Infisical with Varlock

[![](https://img.shields.io/npm/v/@varlock/infisical-plugin?label=%40varlock%2Finfisical-plugin\&color=9B55F5\&logo=npm)](https://www.npmjs.com/package/@varlock/infisical-plugin)

Our [Infisical](https://infisical.com/) plugin enables secure loading of secrets from Infisical using declarative instructions within your `.env` files.

The plugin uses machine identities with Universal Auth for programmatic access to your Infisical secrets, making it suitable for both CI/CD and production environments.

## Features

[Section titled “Features”](#features)

* **Fetch secrets** from Infisical projects and environments
* **Bulk-load secrets** with `infisicalBulk()` via `@setValuesBulk`
* **Universal Auth** with Client ID and Client Secret
* **Support for self-hosted** Infisical instances
* **Secret paths** for hierarchical organization
* **Filter by tag** to load only matching secrets
* **Multiple plugin instances** for different projects/environments
* **Auto-infer secret names** from variable names for convenience
* **Helpful error messages** with resolution tips

## Installation and setup

[Section titled “Installation and setup”](#installation-and-setup)

In a JS/TS project, you may install the `@varlock/infisical-plugin` package as a normal dependency. Otherwise you can just load it directly from your `.env.schema` file, as long as you add a version specifier. See the [plugins guide](/guides/plugins/#installation) for more instructions on installing plugins.

.env.schema

```env-spec
# 1. Load the plugin
# @plugin(@varlock/infisical-plugin)
#
# 2. Initialize the plugin - see below for more details on options
# @initInfisical(
#   projectId=your-project-id,
#   environment=dev,
#   clientId=$INFISICAL_CLIENT_ID,
#   clientSecret=$INFISICAL_CLIENT_SECRET
# )
# ---


# 3. Add machine identity credentials
# @type=infisicalClientId
INFISICAL_CLIENT_ID=


# @type=infisicalClientSecret @sensitive
INFISICAL_CLIENT_SECRET=
```

### Machine identity setup

[Section titled “Machine identity setup”](#machine-identity-setup)

1. **Create a machine identity** in Infisical

   Navigate to your Infisical project settings → **Access Control** → **Machine Identities** → Click **Create Identity**.

2. **Select Universal Auth**

   Choose **Universal Auth** as the authentication method.

3. **Save the credentials** (displayed only once!)

   Copy the **Client ID** and **Client Secret** immediately - they will only be displayed once.

   Save credentials securely

   Store the client ID and secret securely. You won’t be able to see them again after this step!

4. **Grant access to your project and environment**

   Ensure the machine identity has access to the specific project and environment you’ll be using.

5. **Wire up the credentials in your config**

   .env.schema

   ```env-spec
   # @plugin(@varlock/infisical-plugin)
   # @initInfisical(
   #   projectId=your-project-id,
   #   environment=dev,
   #   clientId=$INFISICAL_CLIENT_ID,
   #   clientSecret=$INFISICAL_CLIENT_SECRET
   # )
   # ---


   # @type=infisicalClientId
   INFISICAL_CLIENT_ID=


   # @type=infisicalClientSecret @sensitive
   INFISICAL_CLIENT_SECRET=
   ```

6. **Set your credentials in environments**

   Use your CI/CD system or platform’s env var management to securely inject the credential values.

For detailed instructions, see [Infisical Machine Identities documentation](https://infisical.com/docs/documentation/platform/identities/machine-identities).

### Self-hosted Infisical

[Section titled “Self-hosted Infisical”](#self-hosted-infisical)

For self-hosted Infisical instances, specify the `siteUrl`:

.env.schema

```env-spec
# @plugin(@varlock/infisical-plugin)
# @initInfisical(
#   projectId=my-project,
#   environment=production,
#   clientId=$CLIENT_ID,
#   clientSecret=$CLIENT_SECRET,
#   siteUrl=https://infisical.mycompany.com
# )
# ---
```

### Multiple instances

[Section titled “Multiple instances”](#multiple-instances)

If you need to connect to multiple projects or environments, register multiple named instances:

.env.schema

```env-spec
# @initInfisical(id=dev, projectId=dev-project, environment=development, clientId=$DEV_CLIENT_ID, clientSecret=$DEV_CLIENT_SECRET)
# @initInfisical(id=prod, projectId=prod-project, environment=production, clientId=$PROD_CLIENT_ID, clientSecret=$PROD_CLIENT_SECRET)
# ---


DEV_DATABASE=infisical(dev, "DATABASE_URL")
PROD_DATABASE=infisical(prod, "DATABASE_URL")
```

## Loading secrets

[Section titled “Loading secrets”](#loading-secrets)

Once the plugin is installed and initialized, you can start adding config items that load values using the `infisical()` resolver function.

### Basic usage

[Section titled “Basic usage”](#basic-usage)

Fetch secrets from Infisical:

.env.schema

```env-spec
# Secret name defaults to the config item key
DATABASE_URL=infisical()
API_KEY=infisical()


# Or explicitly specify the secret name
STRIPE_SECRET=infisical("STRIPE_SECRET_KEY")
```

When called without arguments, `infisical()` automatically uses the config item key as the secret name in Infisical. This provides a convenient convention-over-configuration approach.

### Using secret paths

[Section titled “Using secret paths”](#using-secret-paths)

Organize secrets with hierarchical paths:

.env.schema

```env-spec
# Default path for all secrets
# @initInfisical(projectId=my-project, environment=production, clientId=$ID, clientSecret=$SECRET, secretPath=/production/app)
# ---


# Fetches from /production/app/DB_PASSWORD
DB_PASSWORD=infisical("DB_PASSWORD")
```

Or specify path per secret:

.env.schema

```env-spec
# @initInfisical(projectId=my-project, environment=production, clientId=$ID, clientSecret=$SECRET)
# ---


DB_PASSWORD=infisical("DB_PASSWORD", "/database")
API_KEY=infisical("API_KEY", "/api")
```

### Bulk loading secrets

[Section titled “Bulk loading secrets”](#bulk-loading-secrets)

Use `infisicalBulk()` with `@setValuesBulk` to load all secrets from a project environment at once, instead of wiring up each secret individually:

.env.schema

```env-spec
# @plugin(@varlock/infisical-plugin)
# @initInfisical(projectId=my-project, environment=dev, clientId=$INFISICAL_CLIENT_ID, clientSecret=$INFISICAL_CLIENT_SECRET)
# @setValuesBulk(infisicalBulk())
# ---
# @type=infisicalClientId
INFISICAL_CLIENT_ID=
# @type=infisicalClientSecret @sensitive
INFISICAL_CLIENT_SECRET=


API_KEY=
DB_PASSWORD=
```

You can filter by path and/or tag:

.env.schema

```env-spec
# Load secrets from a specific path
# @setValuesBulk(infisicalBulk(path="/database"))


# Load secrets with a specific tag
# @setValuesBulk(infisicalBulk(tag="backend"))


# Combine path and tag
# @setValuesBulk(infisicalBulk(path="/production", tag="app"))


# With a named instance
# @setValuesBulk(infisicalBulk(prod, path="/database"))
```

***

## Reference

[Section titled “Reference”](#reference)

### Root decorators

[Section titled “Root decorators”](#root-decorators)

#### `@initInfisical()`

[Section titled “@initInfisical()”](#initinfisical)

Initialize an Infisical plugin instance for accessing secrets.

**Key/value args:**

* `projectId` (required): Infisical project ID
* `environment` (required): Environment name (e.g., `dev`, `staging`, `production`)
* `clientId` (required): Universal Auth Client ID. Should be a reference to a config item of type `infisicalClientId`.
* `clientSecret` (required): Universal Auth Client Secret. Should be a reference to a config item of type `infisicalClientSecret`.
* `siteUrl` (optional): Custom Infisical instance URL (defaults to `https://app.infisical.com`)
* `secretPath` (optional): Default secret path for all secrets (defaults to `/`)
* `id` (optional): Instance identifier for multiple instances

```env-spec
# @initInfisical(
#   projectId=your-project-id,
#   environment=dev,
#   clientId=$INFISICAL_CLIENT_ID,
#   clientSecret=$INFISICAL_CLIENT_SECRET
# )
# ---
# @type=infisicalClientId
INFISICAL_CLIENT_ID=
# @type=infisicalClientSecret @sensitive
INFISICAL_CLIENT_SECRET=
```

### Data types

[Section titled “Data types”](#data-types)

#### `infisicalClientId`

[Section titled “infisicalClientId”](#infisicalclientid)

Represents an Infisical Universal Auth Client ID. This is not marked as sensitive.

```env-spec
# @type=infisicalClientId
INFISICAL_CLIENT_ID=
```

#### `infisicalClientSecret`

[Section titled “infisicalClientSecret”](#infisicalclientsecret)

Represents an Infisical Universal Auth Client Secret. This type is marked as `@sensitive`.

```env-spec
# @type=infisicalClientSecret
INFISICAL_CLIENT_SECRET=
```

### Resolver functions

[Section titled “Resolver functions”](#resolver-functions)

#### `infisical()`

[Section titled “infisical()”](#infisical)

Fetch a secret from Infisical.

**Array args:**

* `instanceId` (optional): instance identifier to use when multiple plugin instances are initialized
* `secretName` (optional): secret name in Infisical. If omitted, uses the variable name.
* `secretPath` (optional): path to the secret (overrides default path)

```env-spec
# Auto-infer secret name from variable
DATABASE_URL=infisical()


# Explicit secret name
STRIPE_KEY=infisical("STRIPE_SECRET_KEY")


# With custom path
DB_PASSWORD=infisical("DB_PASSWORD", "/database")


# With instance ID
DEV_SECRET=infisical(dev, "DATABASE_URL")


# Full form
PROD_SECRET=infisical(prod, "DATABASE_URL", "/production")
```

#### `infisicalBulk()`

[Section titled “infisicalBulk()”](#infisicalbulk)

Bulk-load all secrets from an Infisical project environment. Intended for use with `@setValuesBulk`.

**Array args:**

* `instanceId` (optional): instance identifier to use when multiple plugin instances are initialized

**Key/value args:**

* `path` (optional): secret path to fetch from (overrides default path from `@initInfisical`)
* `tag` (optional): tag slug to filter secrets by

```env-spec
# Load all secrets from default instance
# @setValuesBulk(infisicalBulk())


# Load from a specific path
# @setValuesBulk(infisicalBulk(path="/database"))


# Filter by tag
# @setValuesBulk(infisicalBulk(tag="backend"))


# With instance ID and path
# @setValuesBulk(infisicalBulk(prod, path="/database"))
```

***

## Example Configurations

[Section titled “Example Configurations”](#example-configurations)

### Development setup with auto-named secrets

[Section titled “Development setup with auto-named secrets”](#development-setup-with-auto-named-secrets)

.env.schema

```env-spec
# @plugin(@varlock/infisical-plugin)
# @initInfisical(projectId=dev-app, environment=dev, clientId=$INFISICAL_CLIENT_ID, clientSecret=$INFISICAL_CLIENT_SECRET)
# ---
# @type=infisicalClientId
INFISICAL_CLIENT_ID=
# @type=infisicalClientSecret @sensitive
INFISICAL_CLIENT_SECRET=


# Secret names automatically match config keys
DATABASE_URL=infisical()
REDIS_URL=infisical()
STRIPE_KEY=infisical()
```

### Production with path organization

[Section titled “Production with path organization”](#production-with-path-organization)

.env.schema

```env-spec
# @plugin(@varlock/infisical-plugin)
# @initInfisical(
#   projectId=prod-app,
#   environment=production,
#   clientId=$INFISICAL_CLIENT_ID,
#   clientSecret=$INFISICAL_CLIENT_SECRET,
#   secretPath=/production
# )
# ---


# Database secrets at /production/database
DB_HOST=infisical("DB_HOST", "/database")
DB_PASSWORD=infisical("DB_PASSWORD", "/database")


# API keys at /production/api
STRIPE_KEY=infisical("STRIPE_KEY", "/api")
SENDGRID_KEY=infisical("SENDGRID_KEY", "/api")
```

### Multi-region setup

[Section titled “Multi-region setup”](#multi-region-setup)

.env.schema

```env-spec
# @plugin(@varlock/infisical-plugin)
# @initInfisical(id=us, projectId=app-us, environment=production, clientId=$US_CLIENT_ID, clientSecret=$US_CLIENT_SECRET)
# @initInfisical(id=eu, projectId=app-eu, environment=production, clientId=$EU_CLIENT_ID, clientSecret=$EU_CLIENT_SECRET)
# ---


US_DATABASE=infisical(us, "DATABASE_URL")
EU_DATABASE=infisical(eu, "DATABASE_URL")
```

***

## Troubleshooting

[Section titled “Troubleshooting”](#troubleshooting)

### Secret not found

[Section titled “Secret not found”](#secret-not-found)

* Verify the secret exists in your Infisical project and environment
* Check the secret name matches exactly (including case)
* Verify the secret path is correct if using paths
* Ensure your machine identity has access to the secret

### Access denied

[Section titled “Access denied”](#access-denied)

* Check that your machine identity has been granted access to the project and environment
* Verify the machine identity permissions in Infisical console
* Ensure the project ID and environment match your configuration

### Authentication failed

[Section titled “Authentication failed”](#authentication-failed)

* Verify the client ID and client secret are correct
* Check if the machine identity has been revoked or disabled
* For self-hosted: verify `siteUrl` is correct

### Wrong environment

[Section titled “Wrong environment”](#wrong-environment)

* Double-check the `environment` parameter matches the environment where your secret is stored
* Remember that secrets in Infisical are environment-specific

## Resources

[Section titled “Resources”](#resources)

* [Infisical Documentation](https://infisical.com/docs)
* [Machine Identities](https://infisical.com/docs/documentation/platform/identities/machine-identities)
* [Universal Auth](https://infisical.com/docs/documentation/platform/identities/universal-auth)
* [Infisical Node SDK](https://infisical.com/docs/sdks/languages/node)

# Plugins Overview

> Varlock plugins overview

Plugins allow extending the functionality of Varlock. See the [plugins guide](/guides/plugins/) for more details on using plugins.

For now, only official Varlock plugins under the `@varlock` npm scope are supported. We plan to support third-party plugins in the future, along with loading plugins from different sources (e.g., local files, git, npm/jsr, http, etc.).

## Official plugins

[Section titled “Official plugins”](#official-plugins)

| Plugin                                                           | npm package                                                                                                                                                                                                            |
| ---------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [1Password](/plugins/1password/)                                 | [![](https://img.shields.io/npm/v/@varlock/1password-plugin?label=%40varlock%2F1password-plugin\&color=9B55F5\&logo=npm)](https://www.npmjs.com/package/@varlock/1password-plugin)                                     |
| [AWS](/plugins/aws-secrets/) *Secrets Manager & Parameter Store* | [![](https://img.shields.io/npm/v/@varlock/aws-secrets-plugin?label=%40varlock%2Faws-secrets-plugin\&color=9B55F5\&logo=npm)](https://www.npmjs.com/package/@varlock/aws-secrets-plugin)                               |
| [Azure Key Vault](/plugins/azure-key-vault/)                     | [![](https://img.shields.io/npm/v/@varlock/azure-key-vault-plugin?label=%40varlock%2Fazure-key-vault-plugin\&color=9B55F5\&logo=npm)](https://www.npmjs.com/package/@varlock/azure-key-vault-plugin)                   |
| [Bitwarden](/plugins/bitwarden/)                                 | [![](https://img.shields.io/npm/v/@varlock/bitwarden-plugin?label=%40varlock%2Fbitwarden-plugin\&color=9B55F5\&logo=npm)](https://www.npmjs.com/package/@varlock/bitwarden-plugin)                                     |
| [Google Secrets Manager](/plugins/google-secret-manager/)        | [![](https://img.shields.io/npm/v/@varlock/google-secret-manager-plugin?label=%40varlock%2Fgoogle-secret-manager-plugin\&color=9B55F5\&logo=npm)](https://www.npmjs.com/package/@varlock/google-secret-manager-plugin) |
| [Infisical](/plugins/infisical/)                                 | [![](https://img.shields.io/npm/v/@varlock/infisical-plugin?label=%40varlock%2Finfisical-plugin\&color=9B55F5\&logo=npm)](https://www.npmjs.com/package/@varlock/infisical-plugin)                                     |
| [Pass](/plugins/pass/) *the standard unix password manager*      | [![](https://img.shields.io/npm/v/@varlock/pass-plugin?label=%40varlock%2Fpass-plugin\&color=9B55F5\&logo=npm)](https://www.npmjs.com/package/@varlock/pass-plugin)                                                    |

Looking for something else?

If you have a specific plugin in mind, please join us on [Discord](https://chat.dmno.dev) and let us know!

# Pass Plugin

> Using pass (the standard unix password manager) with Varlock

[![](https://img.shields.io/npm/v/@varlock/pass-plugin?label=%40varlock%2Fpass-plugin\&color=9B55F5\&logo=npm)](https://www.npmjs.com/package/@varlock/pass-plugin)

Our [pass](https://www.passwordstore.org/) plugin enables loading secrets from `pass` (the standard unix password manager) using declarative instructions within your `.env` files.

Pass stores each secret as a GPG-encrypted file in `~/.password-store`, organized in a simple directory hierarchy. This plugin shells out to the `pass` CLI, so it works with your existing GPG agent, git-backed stores, and all standard pass configuration.

## Features

[Section titled “Features”](#features)

* **Zero-config** - Works with your existing pass store out of the box
* **GPG-backed encryption** - Leverages pass’s native GPG security model
* **Auto-infer entry paths** from variable names for convenience
* **Bulk-load secrets** with `passBulk()` via `@setValuesBulk`
* **Multiple store instances** for accessing different pass stores
* **Name prefixing** for scoped entry access
* **`allowMissing`** option for graceful handling of optional secrets
* **In-session caching** - Each entry is decrypted only once per resolution
* **Helpful error messages** with resolution tips

## Installation and setup

[Section titled “Installation and setup”](#installation-and-setup)

In a JS/TS project, you may install the `@varlock/pass-plugin` package as a normal dependency. Otherwise you can just load it directly from your `.env.schema` file, as long as you add a version specifier. See the [plugins guide](/guides/plugins/#installation) for more instructions on installing plugins.

.env.schema

```env-spec
# 1. Load the plugin
# @plugin(@varlock/pass-plugin)
#
# 2. Initialize the plugin - no arguments needed for default setup
# @initPass()
# ---
```

### Prerequisites

[Section titled “Prerequisites”](#prerequisites)

You must have `pass` installed on your system:

```bash
# macOS
brew install pass


# Ubuntu/Debian
sudo apt-get install pass


# Arch
pacman -S pass
```

Your password store must already be initialized (`pass init "Your GPG Key ID"`). See the [pass documentation](https://www.passwordstore.org/) for setup details.

Note

The plugin does **not** fail at load time if `pass` is not installed. It only fails when you actually try to access a secret, making it safe to include in shared configs where some developers may not have pass set up.

### Custom store path

[Section titled “Custom store path”](#custom-store-path)

If your password store is in a non-standard location, use `storePath`:

.env.schema

```env-spec
# @plugin(@varlock/pass-plugin)
# @initPass(storePath=/path/to/custom/store)
# ---
```

This sets `PASSWORD_STORE_DIR` for all pass commands issued by this plugin instance.

### Name prefixing

[Section titled “Name prefixing”](#name-prefixing)

Use `namePrefix` to scope all entry lookups under a common prefix:

.env.schema

```env-spec
# @plugin(@varlock/pass-plugin)
# @initPass(namePrefix=production/app/)
# ---


# Fetches "production/app/DATABASE_PASSWORD" from the store
DATABASE_PASSWORD=pass()


# Fetches "production/app/stripe-key"
STRIPE_KEY=pass("stripe-key")
```

### Multiple instances

[Section titled “Multiple instances”](#multiple-instances)

Access multiple different password stores (e.g., personal and team):

.env.schema

```env-spec
# @plugin(@varlock/pass-plugin)
# @initPass(id=personal)
# @initPass(id=team, storePath=/shared/team-store)
# ---


MY_TOKEN=pass(personal, "tokens/github")
SHARED_KEY=pass(team, "api-keys/stripe")
```

## Loading secrets

[Section titled “Loading secrets”](#loading-secrets)

Once the plugin is installed and initialized, you can start adding config items that load values using the `pass()` resolver function.

### Basic usage

[Section titled “Basic usage”](#basic-usage)

Fetch secrets from your pass store:

.env.schema

```env-spec
# Entry path defaults to the variable name
DATABASE_PASSWORD=pass()
API_KEY=pass()


# Or explicitly specify the entry path
STRIPE_KEY=pass("services/stripe/live-key")


# Nested entries
DB_URL=pass("production/database/url")
```

When called without arguments, `pass()` automatically uses the config item key as the entry path. This provides a convenient convention-over-configuration approach.

### Handling optional secrets

[Section titled “Handling optional secrets”](#handling-optional-secrets)

Use `allowMissing` when a secret may not exist in the store:

.env.schema

```env-spec
# Returns empty string instead of erroring if entry doesn't exist
OPTIONAL_KEY=pass("monitoring/datadog-key", allowMissing=true)
```

### Multiline entries

[Section titled “Multiline entries”](#multiline-entries)

By default, `pass()` returns only the **first line** of the entry (the password), matching pass’s own convention where the password lives on line 1 and metadata follows. This is the same behavior as `pass -c` (copy to clipboard).

To retrieve the full multiline content, use `multiline=true`:

.env.schema

```env-spec
# Only returns the first line (the password)
DB_PASSWORD=pass("production/database")


# Returns all lines (password + metadata)
DB_FULL_ENTRY=pass("production/database", multiline=true)
```

### Bulk loading secrets

[Section titled “Bulk loading secrets”](#bulk-loading-secrets)

Use `passBulk()` with `@setValuesBulk` to fetch all entries under a directory in your pass store in one go, instead of wiring up each secret individually:

.env.schema

```env-spec
# @plugin(@varlock/pass-plugin)
# @initPass()
# @setValuesBulk(passBulk("services"))
# ---


# These will be populated from entries under services/ in the pass store
STRIPE_KEY=
DATABASE_URL=
```

`passBulk()` lists entries via `pass ls`, then fetches each one in parallel. Each entry returns the first line only (matching the `pass()` default).

You can customize the scope:

.env.schema

```env-spec
# Load everything from the store root
# @setValuesBulk(passBulk())


# Load from a specific subdirectory
# @setValuesBulk(passBulk("production/api"))


# With a named instance
# @setValuesBulk(passBulk(team, "shared"))
```

***

## Reference

[Section titled “Reference”](#reference)

### Root decorators

[Section titled “Root decorators”](#root-decorators)

#### `@initPass()`

[Section titled “@initPass()”](#initpass)

Initialize a pass plugin instance for accessing secrets from a password store.

**Key/value args:**

* `storePath` (optional): Custom password store path (overrides `PASSWORD_STORE_DIR`, defaults to `~/.password-store`)
* `namePrefix` (optional): Prefix automatically prepended to all entry paths
* `id` (optional): Instance identifier for multiple instances

```env-spec
# Default setup
# @initPass()


# Custom store location
# @initPass(storePath=/path/to/store)


# With prefix and ID
# @initPass(id=prod, namePrefix=production/)
```

### Resolver functions

[Section titled “Resolver functions”](#resolver-functions)

#### `pass()`

[Section titled “pass()”](#pass)

Fetch a secret from the pass store. Returns the first line of the entry (the password) by default, matching pass’s convention.

**Array args:**

* `instanceId` (optional): instance identifier to use when multiple plugin instances are initialized
* `entryPath` (optional): path to the entry in the pass store. If omitted, uses the variable name.

**Key/value args:**

* `allowMissing` (optional): if `true`, returns empty string instead of erroring when the entry doesn’t exist
* `multiline` (optional): if `true`, returns the full entry content instead of just the first line

```env-spec
# Auto-infer entry path from variable name
DATABASE_PASSWORD=pass()


# Explicit entry path
STRIPE_KEY=pass("services/stripe/live-key")


# With instance ID
TEAM_SECRET=pass(team, "shared/api-key")


# Allow missing entries
OPTIONAL=pass("maybe/exists", allowMissing=true)


# Get full multiline content
FULL_ENTRY=pass("services/config", multiline=true)
```

#### `passBulk()`

[Section titled “passBulk()”](#passbulk)

Fetch all entries under a directory in the pass store at once. Intended for use with `@setValuesBulk`.

Lists entries via `pass ls`, then fetches each one in parallel. Each entry returns the first line only (matching the `pass()` default).

**Array args:**

* `instanceId` (optional): instance identifier to use when multiple plugin instances are initialized
* `pathPrefix` (optional): directory prefix to load entries from

```env-spec
# Load all entries from the store root
# @setValuesBulk(passBulk())


# Load entries under a specific path
# @setValuesBulk(passBulk("services"))


# With instance ID
# @setValuesBulk(passBulk(team, "shared"))
```

***

## Example configurations

[Section titled “Example configurations”](#example-configurations)

### Simple development setup

[Section titled “Simple development setup”](#simple-development-setup)

.env.schema

```env-spec
# @plugin(@varlock/pass-plugin)
# @initPass()
# ---


# Entry paths match variable names
DATABASE_URL=pass()
REDIS_URL=pass()
STRIPE_KEY=pass()
```

### Production with path organization

[Section titled “Production with path organization”](#production-with-path-organization)

.env.schema

```env-spec
# @plugin(@varlock/pass-plugin)
# @initPass(namePrefix=production/)
# ---


# Fetches production/database/url, production/database/password, etc.
DB_URL=pass("database/url")
DB_PASSWORD=pass("database/password")
STRIPE_KEY=pass("api/stripe-key")
SENDGRID_KEY=pass("api/sendgrid-key")
```

### Team and personal stores

[Section titled “Team and personal stores”](#team-and-personal-stores)

.env.schema

```env-spec
# @plugin(@varlock/pass-plugin)
# @initPass(id=personal)
# @initPass(id=team, storePath=/shared/team-pass-store)
# ---


# Personal dev tokens
GH_TOKEN=pass(personal, "tokens/github")


# Shared team secrets
SHARED_DB=pass(team, "databases/staging")
SHARED_API_KEY=pass(team, "api-keys/internal")
```

***

## Troubleshooting

[Section titled “Troubleshooting”](#troubleshooting)

### `pass` command not found

[Section titled “pass command not found”](#pass-command-not-found)

* Install pass using your system package manager (see [Prerequisites](#prerequisites))
* Ensure `pass` is in your `PATH`

### Entry not found

[Section titled “Entry not found”](#entry-not-found)

* Verify the entry exists: `pass show <path>`
* List available entries: `pass ls`
* Check for typos in the entry path
* If using `namePrefix`, remember it’s prepended automatically

### GPG decryption failed

[Section titled “GPG decryption failed”](#gpg-decryption-failed)

* Ensure your GPG key is available: `gpg --list-keys`
* Start the GPG agent: `gpgconf --launch gpg-agent`
* You may need to enter your GPG passphrase

### Password store not initialized

[Section titled “Password store not initialized”](#password-store-not-initialized)

* Run `pass init "Your GPG Key ID"` to initialize the store
* See `pass init --help` for details

## Resources

[Section titled “Resources”](#resources)

* [pass - The Standard Unix Password Manager](https://www.passwordstore.org/)
* [pass man page](https://git.zx2c4.com/password-store/about/)
* [GPG documentation](https://gnupg.org/documentation/)

# Builtin variables

> Auto-detected VARLOCK_* variables for CI platform, branch, commit, and environment info

Varlock provides a set of **builtin `VARLOCK_*` variables** that are automatically populated with information about the current CI/deploy platform, git branch, commit, and inferred deployment environment. They are entirely **opt-in** — they only exist in your schema when you reference them.

## Usage

[Section titled “Usage”](#usage)

Builtin variables are activated when you reference them via `$VARLOCK_*` in a value expression:

.env.schema

```env-spec
# @currentEnv=$VARLOCK_ENV
# ---
BUILD_TAG="build-$VARLOCK_COMMIT_SHA_SHORT"
DB_URL=if(
  eq($VARLOCK_ENV, development),
  postgres://localhost/myapp,
  postgres://${VARLOCK_ENV}-db.example.com/myapp
)
```

If you want to include a builtin variable in your resolved env without referencing it from another item, just define it with an empty value — varlock will populate it automatically:

.env.schema

```env-spec
VARLOCK_BRANCH=
VARLOCK_COMMIT_SHA_SHORT=
```

You can also use `VARLOCK_ENV` as your environment flag with `@currentEnv`, which means you don’t need to create your own `APP_ENV` variable — Varlock will auto-detect the environment for you.

Verify detection works for your setup

Auto-detection is based on environment variables set by each CI/deploy platform. Different platforms expose different information, and detection heuristics (especially branch-to-environment inference) may not match your conventions.

**Always verify that the detected values match your expectations** before relying on them in production. You can check the resolved values using `varlock run -- env | grep VARLOCK_` or by inspecting the output of `varlock load`.

## Builtin Vars

[Section titled “Builtin Vars”](#builtin-vars)

### `VARLOCK_ENV`

[Section titled “VARLOCK\_ENV”](#varlock_env)

**Type:** `string` — one of `development`, `preview`, `staging`, `production`, `test`

The inferred deployment environment. Detection follows this priority:

1. **Test environment** — detected from `NODE_ENV=test`, `VITEST`, `JEST_WORKER_ID`, or `VITEST_POOL_ID`
2. **Platform-provided** — uses the platform’s own environment concept (e.g., Vercel’s `VERCEL_ENV`, Netlify’s `CONTEXT`)
3. **Branch inference** — in CI, infers from branch name: `main`/`master`/`production`/`prod` → `production`, `staging`/`stage`/`develop`/`dev` → `staging`, `qa`/`test` → `test`, anything else → `preview`
4. **CI fallback** — if in CI but no branch info is available, defaults to `preview`
5. **Local fallback** — if not in CI, defaults to `development`

#### Using with `@currentEnv`

[Section titled “Using with @currentEnv”](#using-with-currentenv)

.env.schema

```env-spec
# @currentEnv=$VARLOCK_ENV
# ---
DB_HOST=if(forEnv(production), "prod-db.example.com", "localhost")
DB_NAME=myapp
DB_URL="postgres://$DB_HOST/$DB_NAME"
```

#### Test environment caveat

[Section titled “Test environment caveat”](#test-environment-caveat)

Test runners and `VARLOCK_ENV`

Many test runners (Vitest, Jest, etc.) set `NODE_ENV=test` **after** the process has started — often after varlock has already loaded and resolved your env vars. This means `VARLOCK_ENV` may not detect `test` automatically in all setups.

If you depend on `VARLOCK_ENV=test` to load `.env.test` or toggle behavior via `forEnv(test)`, **explicitly pass it** when running tests:

```bash
VARLOCK_ENV=test bun run test
# or
VARLOCK_ENV=test varlock run -- vitest
```

This is the same pattern recommended for any environment flag — see the [environments guide](/guides/environments/) for more details.

### `VARLOCK_IS_CI`

[Section titled “VARLOCK\_IS\_CI”](#varlock_is_ci)

**Type:** `string` — `"true"` or `"false"`

Whether the current process is running in a CI environment.

### `VARLOCK_BRANCH`

[Section titled “VARLOCK\_BRANCH”](#varlock_branch)

**Type:** `string | undefined`

The current git branch name, as reported by the CI platform. Undefined when not in CI or when the platform doesn’t expose branch info.

### `VARLOCK_PR_NUMBER`

[Section titled “VARLOCK\_PR\_NUMBER”](#varlock_pr_number)

**Type:** `string | undefined`

The pull/merge request number, if the current build is for a PR. Undefined otherwise.

### `VARLOCK_COMMIT_SHA`

[Section titled “VARLOCK\_COMMIT\_SHA”](#varlock_commit_sha)

**Type:** `string | undefined`

The full git commit SHA.

### `VARLOCK_COMMIT_SHA_SHORT`

[Section titled “VARLOCK\_COMMIT\_SHA\_SHORT”](#varlock_commit_sha_short)

**Type:** `string | undefined`

The short (7-character) git commit SHA.

### `VARLOCK_PLATFORM`

[Section titled “VARLOCK\_PLATFORM”](#varlock_platform)

**Type:** `string | undefined`

The name of the detected CI/deploy platform (e.g., `"GitHub Actions"`, `"Vercel"`, `"Netlify CI"`).

### `VARLOCK_BUILD_URL`

[Section titled “VARLOCK\_BUILD\_URL”](#varlock_build_url)

**Type:** `string | undefined`

A URL linking to the current build or deploy in the CI platform’s UI.

### `VARLOCK_REPO`

[Section titled “VARLOCK\_REPO”](#varlock_repo)

**Type:** `string | undefined`

The repository name in `owner/repo` format.

## Supported platforms

[Section titled “Supported platforms”](#supported-platforms)

Detection is built-in for these platforms (no configuration required):

* GitHub Actions
* GitLab CI
* Vercel
* Netlify
* Cloudflare Pages / Workers
* AWS CodeBuild
* Azure Pipelines
* Bitbucket Pipelines
* Buildkite
* CircleCI
* Jenkins
* Render
* Travis CI
* and [many more](https://github.com/dmno-dev/varlock/tree/main/packages/ci-env-info/src/platforms.ts)

Not all platforms expose all fields. For example, some may not provide branch name or PR number.

CI/deploy platform detection is powered by [`@varlock/ci-env-info`](https://www.npmjs.com/package/@varlock/ci-env-info), which can also be used as a standalone package.

# CLI Commands

> Reference documentation for Varlock CLI commands

Varlock provides a command-line interface for managing environment variables and secrets. This reference documents all available CLI commands.

See [installation](/getting-started/installation) for instructions on how to install Varlock.

### Running commands in JS projects

[Section titled “Running commands in JS projects”](#running-commands-in-js-projects)

If you have installed varlock as a `package.json` dependency, rather than a standalone binary, the best way to invoke the CLI is via your package manager:

* npm

  ```bash
  npm exec -- varlock ...
  ```

* pnpm

  ```bash
  pnpm exec -- varlock ...
  ```

* bun

  ```bash
  bun exec varlock ...
  ```

* vlt

  ```bash
  vlx -- varlock ...
  ```

* yarn

  ```bash
  yarn exec -- varlock ...
  ```

Also note that within package.json scripts, you can use it directly:

package.json

```json
{
  "scripts": {
    "start": "varlock run -- node app.js"
  }
}
```

## Commands reference

[Section titled “Commands reference”](#commands-reference)

### `varlock init`

[Section titled “varlock init”](#init)

Starts an interactive onboarding process to help you get started. Will help create your `.env.schema` and install varlock as a dependency if necessary.

```bash
varlock init
```

### `varlock load`

[Section titled “varlock load”](#load)

Loads and validates environment variables according to your .env files, and prints the results. Default prints a nicely formatted, colorized summary of the results, but can also print out machine-readable formats.

Useful for debugging locally, and in CI to print out a summary of env vars.

```bash
varlock load [options]
```

**Options:**

* `--format`: Format of output \[pretty|json|env|shell]
* `--show-all`: Shows all items, not just failing ones, when validation is failing
* `--env`: Set the default environment flag (e.g., `--env production`), only useful if not using `@currentEnv` in `.env.schema`
* `--path` / `-p`: Path to a specific `.env` file or directory to use as the entry point

**Examples:**

```bash
# Load and validate environment variables
varlock load


# Load and validate for a specific environment (when not using @currentEnv in .env.schema)
varlock load --env production


# Output validation results in JSON format
varlock load --format json


# Output as shell export statements (useful for direnv / eval)
eval "$(varlock load --format shell)"


# When validation is failing, will show all items, rather than just failing ones
varlock load --show-all


# Load from a specific .env file
varlock load --path .env.prod


# Load from a specific directory
varlock load --path ./config/
```

Caution

Setting `@currentEnv` in your `.env.schema` will override the `--env` flag.

### `varlock run`

[Section titled “varlock run”](#run)

Executes a command in a child process, injecting your resolved and validated environment variables from your .env files. This is useful when a code-level integration is not possible.

```bash
varlock run -- <command>
```

**Options:**

* `--no-redact-stdout`: Disable stdout/stderr redaction to preserve TTY detection for interactive tools
* `--path` / `-p`: Path to a specific `.env` file or directory to use as the entry point

**Examples:**

```bash
varlock run -- node app.js      # Run a Node.js application
varlock run -- python script.py # Run a Python script


# Use a specific .env file as entry point
varlock run --path .env.prod -- node app.js


# Use a specific directory as entry point
varlock run --path ./config/ -- node app.js
```

Shell expansion of env vars in commands

Because of the way that shell expansion works, you may need to use use `sh -c` to properly expand environment variables in your command *after* varlock has injected them.

```bash
varlock run -- echo $MY_VAR # ❌ will not work
varlock run -- sh -c 'echo $MY_VAR' # ✅ will work
```

Interactive tools and TTY detection

By default, `varlock run` pipes stdout/stderr through a redaction filter, which causes child processes to detect `!process.stdout.isTTY` and enter non-interactive mode. This can break interactive tools like `claude` or `psql` that require TTY detection.

Use `--no-redact-stdout` to disable stdout/stderr redaction and preserve TTY detection:

```bash
varlock run --no-redact-stdout -- claude --env development
varlock run --no-redact-stdout -- bash -c 'psql $DATABASE_URL'
```

Note: This flag only disables stdout/stderr redaction. Other redaction mechanisms (like console patching) may still apply if enabled in your configuration.

### `varlock printenv`

[Section titled “varlock printenv”](#printenv)

Resolves and prints the value of a single environment variable to stdout. Only the requested item and its transitive dependencies are resolved, making this faster than loading the full graph.

This is useful within larger shell commands where you need to embed a single resolved env var value.

```bash
varlock printenv <VAR_NAME> [options]
```

**Options:**

* `--path` / `-p`: Path to a specific `.env` file or directory to use as the entry point

**Examples:**

```bash
# Print the resolved value of MY_VAR
varlock printenv MY_VAR


# Use a specific .env file as entry point
varlock printenv --path .env.prod MY_VAR


# Embed in a shell command using subshell expansion
sh -c 'some-tool --token $(varlock printenv MY_TOKEN)'
```

Why not use `varlock run -- echo $MY_VAR`?

Shell expansion happens *before* varlock runs, so `$MY_VAR` is substituted by the shell with whatever value it already has (likely empty). `varlock printenv` avoids this by printing the value directly to stdout, letting you capture it with `$(...)` *after* varlock has resolved it.

```bash
varlock run -- echo $MY_VAR         # ❌ shell expands $MY_VAR before varlock runs
varlock printenv MY_VAR             # ✅ varlock resolves and prints the value
sh -c 'echo $(varlock printenv MY_VAR)'  # ✅ embed in a larger command
```

### `varlock scan`

[Section titled “varlock scan”](#scan)

Scans your project files for sensitive config values that should not appear in plaintext. Loads your varlock config, resolves all `@sensitive` values, then checks files for any occurrences of those values.

This is especially useful as a **pre-commit git hook** to prevent accidentally committing secrets into version control.

```bash
varlock scan [options]
```

**Options:**

* `--staged`: Only scan staged git files
* `--include-ignored`: Include git-ignored files in the scan (by default, gitignored files are skipped)
* `--install-hook`: Set up `varlock scan` as a git pre-commit hook
* `--path` / `-p`: Path to a specific `.env` file or directory to use as the schema entry point

**Examples:**

```bash
# Scan all non-gitignored files in the current directory
varlock scan


# Only scan staged git files
varlock scan --staged


# Scan all files, including gitignored ones
varlock scan --include-ignored


# Use a specific .env file as the schema entry point
varlock scan --path .env.prod


# Set up as a git pre-commit hook
varlock scan --install-hook
```

Git pre-commit hook

The easiest way to set up scanning as a pre-commit hook is to run:

```bash
varlock scan --install-hook
```

This will detect if you are using a hook manager (like husky or lefthook) and provide the appropriate setup instructions. Otherwise, it will create a `.git/hooks/pre-commit` hook for you automatically.

If varlock is installed as a project dependency, the hook command will be automatically prefixed with your package manager (e.g., `npx varlock scan`).

You can also set it up manually — see the [Secrets guide](/guides/secrets/#scanning-for-leaked-secrets) for more details.

### `varlock typegen`

[Section titled “varlock typegen”](#typegen)

Generates type files according to [`@generateTypes`](/reference/root-decorators/#generatetypes) and your config schema. Uses only non-environment-specific schema info, so output is deterministic regardless of which environment is active.

This command is particularly useful when you have set `auto=false` on the [`@generateTypes`](/reference/root-decorators/#generatetypes) decorator to disable automatic type generation during `varlock load` or `varlock run`.

```bash
varlock typegen [options]
```

**Options:**

* `--path` / `-p`: Path to a specific `.env` file or directory to use as the entry point

**Examples:**

```bash
# Generate types using the default schema
varlock typegen


# Generate types from a specific .env file
varlock typegen --path .env.prod
```

### `varlock telemetry`

[Section titled “varlock telemetry”](#telemetry)

Opts in/out of anonymous usage analytics. This command creates/updates a configuration file at `$XDG_CONFIG_HOME/varlock/config.json` (defaults to `~/.config/varlock/config.json`) saving your preference.

```bash
varlock telemetry disable
varlock telemetry enable
```

Note

You can also temporarily opt out by setting the `VARLOCK_TELEMETRY_DISABLED` environment variable. See the [Telemetry guide](/guides/telemetry/) for more information about our analytics and privacy practices.

### `varlock help`

[Section titled “varlock help”](#help)

Displays general help information, alias for `varlock --help`

```bash
varlock help
```

For help about specific commands, use:

```bash
varlock subcommand --help
```

# @type data types

> A reference page of available data types to be used with the `@type` item decorator

The [`@type` item decorator](/reference/item-decorators/#type) sets the data type associated with an item. The data type affects coercion, validation, and [generated type files](/reference/root-decorators/#generatetypes).

### Additional data type options

[Section titled “Additional data type options”](#additional-data-type-options)

All types (except `enum`) can be used without any arguments, but most take optional arguments that further narrow the type’s behavior.

```env-spec
# @type=string
NO_ARGS=
# @type=string(minLength=5, maxLength=10, toUpperCase=true)
WITH_ARGS=
```

### Coercion & validation process

[Section titled “Coercion & validation process”](#coercion--validation-process)

Once a raw value is resolved - which could from a static value in an `.env` file, a [function](/reference/functions/), or an override passed into the process - the raw value will be coerced and validated based on the type, respecting additional arguments provided to the type.

Consider the following example:

```env-spec
# @type=number(precision=0, max=100)
ITEM="123.45"
```

The internal coercion/validation process looks like:\
`"123.45"` -> `123.45` -> `123` -> ❌ invalid (greater than max)

### Default behavior

[Section titled “Default behavior”](#default-behavior)

When no `@type` is specified, a type will be inferred where possible - for static values, and some functions that return a known type. Note that the use of quotes matters. Otherwise the type will default to `string`.

```env-spec
INFERRED_STRING_QUOTED="foo"
INFERRED_STRING_UNQUOTED=foo
INFERRED_NUMBER=123     # infers number type
QUOTED_NUM_STRING="123" # remains a string unless @type=number is used
INFERRED_BOOLEAN=true


# return type of some functions can be inferred
CONCAT_INFERS_STRING=`concat-${SOMEVAR}-will-be-string`
FN_INFER_BOOLEAN=eq($VAR1, $VAR2)
DEFAULTS_TO_STRING_FN=fnThatCannotInferType()


# with no other info, we default to string
DEFAULTS_TO_STRING=
```

Note that numeric values that would lose precision, or change any formatting (like leading/trailing zeros), will be treated as strings unless explicitly adding `@type=number`.

In any slightly ambiguous situation, it is better to explicitly add a `@type` decorator.

## Built-in data types

[Section titled “Built-in data types”](#built-in-data-types)

These are the built-in data types. [Plugins](/guides/plugins/) may register additional data types.

### `string`

[Section titled “string”](#string)

**Options:**

* `minLength` (number): Minimum length of the string
* `maxLength` (number): Maximum length of the string
* `isLength` (number): Exact length required
* `startsWith` (string): Required starting substring
* `endsWith` (string): Required ending substring
* `matches` (string|RegExp): Regular expression pattern to match
* `toUpperCase` (boolean): Convert to uppercase
* `toLowerCase` (boolean): Convert to lowercase
* `allowEmpty` (boolean): Allow empty string (default: false)

```env-spec
# @type=string(minLength=5, maxLength=10, toUpperCase=true)
MY_STRING=value
```

The default type is string

No need to add `@type=string` on everything, as it is the default.

### `number`

[Section titled “number”](#number)

**Options:**

* `min` (number): Minimum allowed value (inclusive)
* `max` (number): Maximum allowed value (inclusive)
* `coerceToMinMaxRange` (boolean): Coerce value to be within `min`/`max` range
* `isDivisibleBy` (number): Value must be divisible by this number
* `isInt` (boolean): Value must be an integer (equivalent to `precision=0`)
* `precision` (number): Number of decimal places to keep

```env-spec
# @type=number(min=0, max=100, precision=1)
MY_NUMBER=42.5
```

### `boolean`

[Section titled “boolean”](#boolean)

The following values will be coerced to a boolean and considered valid:

* True values: `"t"`, `"true"`, `true`, `"yes"`, `"on"`, `"1"`, `1`
* False values: `"f"`, `"false"`, `false`, `"no"`, `"off"`, `"0"`, `0`

Anything else will be considered invalid.

```env-spec
# @type=boolean
MY_BOOL=true
```

### `url`

[Section titled “url”](#url)

**Options:**

* `prependHttps` (boolean): Automatically prepend “https\://” if no protocol is specified

```env-spec
# @type=url(prependHttps=true)
MY_URL=example.com/foobar
```

### `enum`

[Section titled “enum”](#enum)

Checks a value is contained in a list of possible values - it must match one exactly.

**NOTE** - this is the only type that cannot be used without any additional arguments

```env-spec
# @type=enum(development, staging, production)
ENV=development
```

### `email`

[Section titled “email”](#email)

**Options:**

* `normalize` (boolean): Convert email to lowercase

```env-spec
# @type=email(normalize=true)
MY_EMAIL=User@Example.com
```

### `port`

[Section titled “port”](#port)

Checks for valid port number. Coerces to a number.

**Options:**

* `min` (number): Minimum port number (default: 0)
* `max` (number): Maximum port number (default: 65535)

```env-spec
# @type=port(min=1024, max=9999)
MY_PORT=3000
```

### `ip`

[Section titled “ip”](#ip)

Checks for a valid [IP address](https://en.wikipedia.org/wiki/IP_address).

**Options:**

* `version` (`4|6`): IPv4 or IPv6
* `normalize` (boolean): Convert to lowercase

```env-spec
# @type=ip(version=4, normalize=true)
MY_IP=192.168.1.1
```

### `semver`

[Section titled “semver”](#semver)

Checks for a valid [semantic version](https://semver.org/).

```env-spec
# @type=semver
MY_VERSION=1.2.3-beta.1
```

### `isoDate`

[Section titled “isoDate”](#isodate)

Checks for valid [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) date strings with optional time and milliseconds.

```env-spec
# @type=isoDate
MY_DATE=2024-03-20T15:30:00Z
```

### `uuid`

[Section titled “uuid”](#uuid)

Checks for valid [UUID](https://en.wikipedia.org/wiki/UUID) (versions 1-5 per RFC4122, including `NIL`).

```env-spec
# @type=uuid
MY_UUID=123e4567-e89b-12d3-a456-426614174000
```

### `md5`

[Section titled “md5”](#md5)

Checks for valid [MD5 hash](https://en.wikipedia.org/wiki/MD5).

```env-spec
# @type=md5
MY_HASH=a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6
```

### `simple-object`

[Section titled “simple-object”](#simple-object)

Validates and coerces JSON strings into objects.

```env-spec
# @type=simple-object
MY_OBJECT={"key": "value"}
```

# Resolver functions

> A comprehensive reference of all available function resolvers in varlock

You may use *resolver functions* instead of static values within both config items and decorator values.

Functions can be composed together to create more complex value resolution logic.

```env-spec
ITEM=fn(arg1, arg2)
COMPOSITION=fn1(fn1Arg1, fn2(fn2Arg1, fn2Arg2))
```

Note that many built-in utility functions have *expansion* equivalents and often it will be more clear to use them that way. For example:

```env-spec
EXPANSION_EQUIVALENT="pre-${OTHER}-post"
USING_FN_CALLS=concat("pre-", ref(OTHER), "-post")


# mixed example
CONFIG=exec(`aws ssm get-parameter --name "/config/${APP_ENV}" --with-decryption`)
```

Currently, there are built-in utility functions, and soon there will be functions to handle values encrypted using varlock provided tools.

Plugins may also register additional resolvers - which can be used to generate and transform values, or fetch data from external providers.

### `ref()`

[Section titled “ref()”](#ref)

References another config item (env var) - which is useful when composing multiple functions together.

Expansion equivalent: `ref(OTHER_VARL)` === `${OTHER_VAR}` (and also `$OTHER_VAR`)

We recommend using the bracketed version within string templates, and the simpler version when referencing an item directly.

```env-spec
API_URL=https://api.example.com
USERS_API_URL=${API_URL}/users
USERS_API_URL2=concat(ref("API_URL"), "/users") # without using expansion
```

### `concat()`

[Section titled “concat()”](#concat)

Concatenates multiple values into a single string.

Expansion uses `concat()` to combine multiple parts of strings when they include multiple parts.

```env-spec
PATH=concat("base/", ref("APP_ENV"), "/config.json")
PATH2=`base/${APP_ENV}/config.json` # equivalent using expansion
```

### `exec()`

[Section titled “exec()”](#exec)

Executes a CLI command and uses its output as the value. This is particularly useful for integrating with external tools and services.

NOTE - many CLI tools output an additional newline. `exec()` will trim this automatically.

Expansion equivalent: `exec(command)` === `$(command)`

```env-spec
# Using 1Password CLI
API_KEY=exec(`op read "op://dev test/service x/api key"`)
# Using AWS CLI
AWS_CREDENTIALS=exec(`aws sts get-session-token --profile prod`)
```

### `fallback()`

[Section titled “fallback()”](#fallback)

Returns the first non-empty value in a list of possible values.

```env-spec
POSSIBLY_EMPTY=
ANOTHER=
EXAMPLE=fallback(ref(POSSIBLY_EMPTY), ref(ANOTHER), "default-val")
```

### `remap()`

[Section titled “remap()”](#remap)

Maps a value to a new value based on a set of remapping rules. This is useful for translating one value, often provided by an external platform, into another.

* The first argument is the value to remap (often a `ref()` to another variable).
* All following arguments are key=value pairs, where the key is the new value and the value is what to match against, which can be a string, `undefined`, or a `regex()` call.
* If no match is found, the original value is returned.

```env-spec
# env var that is set by CI/platform
CI_BRANCH=


# @type=enum(development, preview, production)
APP_ENV=remap($CI_BRANCH, production="main", preview=regex(.*), development=undefined)
```

### `regex()`

[Section titled “regex()”](#regex)

Creates a regular expression for use in other functions, such as `remap()`.

* Takes a single string argument, which is the regex pattern (using JavaScript regex syntax)
* **This cannot be used as a standalone value. It must be used only as a function argument.**

```env-spec
# Example usage within remap
ENV_TYPE=remap($APP_ENV, dev=regex("^dev.*"), prod="production")
```

### `forEnv()`

[Section titled “forEnv()”](#forenv)

Resolves to a boolean, if the current [environment](/reference/root-decorators/#currentenv) matches any in the list passed in as args.

**Requirements:**

* Requires an [`@currentEnv`](/reference/root-decorators/#currentenv) to be set in your `.env.schema` file
* Takes one or more environment names as arguments

```env-spec
# @currentEnv=$APP_ENV @defaultRequired=false
# @disable=forEnv(test)  # entire file will be disabled if env is test
# ---
APP_ENV=staging


# Required only in development
# @required=forEnv(development)
DEV_API_KEY=


# Required in staging and production
# @required=forEnv(staging, production)
PROD_API_KEY=
```

### `eq()`

[Section titled “eq()”](#eq)

Checks if 2 values are equal and resolves to a boolean.

```env-spec
IS_STAGING_DEPLOYMENT=eq($GIT_BRANCH, "staging")
```

### `if()`

[Section titled “if()”](#if)

Checks a boolean to return a true/false option

```env-spec
API_URL=if(eq($GIT_BRANCH, "main"), api.example.com, staging-api.example.com)
```

### `not()`

[Section titled “not()”](#not)

Negates a value and returns a boolean. Falsy values are - `false`, `""`, `0`, `undefined`, and will be negated to `true`. Otherwise will return `false`.

```env-spec
# Negate the result of another function
SHOULD_DISABLE_FEATURE=not(forEnv(production))
```

### `isEmpty()`

[Section titled “isEmpty()”](#isempty)

Returns `true` if the value is `undefined` or an empty string, `false` otherwise.

```env-spec
# Check if a value is empty
HAS_API_KEY=not(isEmpty($API_KEY))


# Use with conditional logic
API_URL=if(isEmpty($CUSTOM_API_URL), "https://api.default.com", $CUSTOM_API_URL)
```

# Config Item @decorators

> A reference page of available env-spec decorators for items

Decorators in a comment block *directly* preceeding a config item will be attached to that item. Multiple decorators can be specified on the same line. A comment block is broken by either an empty line or a divider.

```env-spec
# @required @sensitive @type=string(startsWith=sk-)
# @docsUrl=https://docs.servicex.com/api-keys
SERVICE_X_API_KEY=
```

More details of the minutiae of decorator handling can be found in the [@env-spec reference](/env-spec/reference/#comments-and-decorators).

## Built-in item decorators

[Section titled “Built-in item decorators”](#built-in-item-decorators)

These are the item decorators that are built into Varlock. [Plugins](/guides/plugins/) may introduce more.

### `@required`

[Section titled “@required”](#required)

**Value type:** `boolean`

Sets whether an item is *required* - meaning validation will fail if the value resolves to `undefined` or an empty string.

Default behavior for all items within the same file can be toggled using the [`@defaultRequired` root decorator](/reference/root-decorators/#defaultrequired).

💡 Use the [`forEnv()` function](/reference/functions/#forenv) to set required based on the current environment.

```env-spec
# @defaultRequired=false
# ---
# @required # same as @required=true
REQUIRED_ITEM=


# @required=forEnv(prod)
REQUIRED_FOR_PROD_ITEM=


# @required=eq($OTHER, foo)
REQUIRED_IF_OTHER_IS_FOO=
```

### `@optional`

[Section titled “@optional”](#optional)

**Value type:** `boolean`

Opposite of [`@required`](#required). Equivalent to writing `@required=false`.

```env-spec
# @defaultRequired=true
# ---
# @optional
OPTIONAL_ITEM=
```

### `@sensitive`

[Section titled “@sensitive”](#sensitive)

**Value type:** `boolean`

Sets whether the item should be considered *sensitive* - meaning it cannot be exposed to the public. The value will be always be redacted in CLI output, and client integrations can take further action to prevent leaks.

Default behavior for all items can be set using the [`@defaultSensitive` root decorator](/reference/root-decorators/#defaultsensitive)

```env-spec
# @sensitive
SERVICE_X_PRIVATE_KEY=
# @sensitive=false
SERVICE_X_CLIENT_ID=
```

### `@public`

[Section titled “@public”](#public)

**Value type:** `boolean`

Opposite of [`@sensitive`](#sensitive). Equivalent to writing `@sensitive=false`.

```env-spec
# @defaultSensitive=true
# ---
# @public
PUBLIC_API_URL=https://api.example.com
```

### `@type`

[Section titled “@type”](#type)

**Value type:** [`data type`](/reference/data-types) (name only or function call)

Sets the data type of the item - which affects validation, coercion, and generated types. Note that some data types take additional arguments. See [data types reference](/reference/data-types) for more details.

If not specified, a data type will be inferred when possible, or default to `string` otherwise.

```env-spec
# @type=url # name only
SOME_URL=


# @type=string(startsWith=abc) # function call with options
EXAMPLE_WITH_TYPE_OPTIONS=


INFER_NUMBER=123 # data type of `number` will be inferred from the value
```

### `@example`

[Section titled “@example”](#example)

**Value type:** `string`

Provides an example value for the item. This lets you avoid setting placeholder values that are not meant to be used.

```env-spec
# @example="sk-abc123"
SECRET_KEY=
```

### `@docs()`

[Section titled “@docs()”](#docs)

**Arg types:** `[ url: string ] | [ description: string, url: string ]`

URL of documentation related to the item. Will be included in [generated types](/reference/root-decorators/#generatetypes). *Can be called multiple times.*

```env-spec
# @docs(https://xyz.com/docs/api-keys)
# @docs("Authentication guide", https://xyz.com/docs/auth-guide)
XYZ_API_KEY=
```

![example of docs() in generated types](/_astro/multiple-docs-intellisense.DsdGRzO3.png)*example of `docs()` info in generated types / IntelliSense*

### `@docsUrl` (deprecated)

[Section titled “@docsUrl (deprecated)”](#docsurl)

**Value type:** `string`

URL of documentation related to the item.

Use [`@docs()`](#docs) instead, which supports multiple docs entries with optional descriptions.

`@docsUrl=https://example.com` -> `@docs(https://example.com)`

# Root @decorators

> A reference page of available env-spec decorators that apply to the schema itself, rather than individual items

Root decorators appear in the *header* section of a .env file - which is a comment block at the beginning of the file that ends with a divider. Usually root decorators are used only in your `.env.schema` file.

.env.schema

```env-spec
# This is the header, it can contain root decorators
# @defaultSensitive=false @defaultRequired=infer
# @generateTypes(lang=ts, path=./env.d.ts)
# ---
# ... config items
```

More details of the minutiae of decorator handling can be found in the [@env-spec reference](/env-spec/reference/#comments-and-decorators).

## Built-in root decorators

[Section titled “Built-in root decorators”](#built-in-root-decorators)

These are the root decorators that are built into Varlock. [Plugins](/guides/plugins/) may introduce more.

### `@currentEnv`

[Section titled “@currentEnv”](#currentenv)

**Value type:** [`ref()`](/reference/functions/#ref) (usually written as `$ITEM_NAME`)

Sets the current *environment* value, which will be used when determining if environment-specific .env files will be loaded (e.g. `.env.production`), and also may affect other dynamic behaviour in your schema, such as the [`forEnv()` function](/reference/functions/#forenv). We refer to the name of this item as your *environment flag*.

* It *must* be set to a simple reference to a single config item (e.g. `$APP_ENV`).
* This decorator should only be set in your `.env.schema` file.
* The referenced item *must* be defined within the same file.
* This will override the `--env` CLI flag if it is set.
* We do not recommend using `NODE_ENV` as your environment flag, as it has other implications, and is often set out of your control.

See [environments guide](/guides/environments) for more info.

```env-spec
# @currentEnv=$APP_ENV
# ---
# @type=enum(dev, preview, prod, test)
APP_ENV=dev
```

### `@envFlag` (deprecated)

[Section titled “@envFlag (deprecated)”](#envflag)

**Value type:** `string` (must be a valid item name within same file)

Sets the current *environment flag* by name.

⚠️ Deprecated at v0.1 - use [`@currentEnv`](#currentenv) instead.

`@envFlag=APP_ENV` -> `@currentEnv=$APP_ENV`

### `@defaultRequired`

[Section titled “@defaultRequired”](#defaultrequired)

**Value type:** `boolean | "infer"`

Sets the default behavior of each item being *required*. Only applied to items that have a definition within the same file. Can be overridden on individual items using [`@required`](/reference/item-decorators/#required)/[`@optional`](/reference/item-decorators/#optional).

* `infer` (default): Items with a value set in the same file will be required; items with an empty string or no value are optional.
* `true`: All items are required unless marked optional.
* `false`: All items are optional unless marked required.

```env-spec
# @defaultRequired=infer
# ---


FOO=bar        # required (static value)
BAR=fnCall()   # required (function value)
BAZ=           # optional (no value)
QUX=''         # optional (empty string)


# @optional
OPTIONAL_ITEM=foo # optional (explicit)


# @required
REQUIRED_ITEM= # required (explicit)
```

### `@defaultSensitive`

[Section titled “@defaultSensitive”](#defaultsensitive)

**Value type:** `boolean | inferFromPrefix(PREFIX)`

Sets the default state of each item being treated as [*sensitive*](/guides/secrets/). Only applied to items that have a definition within the same file. Can be overridden on individual items using [`@sensitive`](/reference/item-decorators/#sensitive).

* `true` (default): All items are sensitive unless marked otherwise.
* `false`: All items are not sensitive unless marked otherwise.
* `inferFromPrefix(PREFIX)`: Item is marked not sensitive if key starts with the given `PREFIX`; all others are sensitive. Useful for marking e.g. `PUBLIC_` keys as non-sensitive by default.

```env-spec
# @defaultSensitive=inferFromPrefix(PUBLIC_)
# ---


PUBLIC_FOO= # not sensitive (due to matching prefix)
OTHER_FOO=  # sensitive (default when prefix does not match)


# @sensitive
PUBLIC_BAR= # sensitive (explicit decorator overrides prefix)
# @sensitive=false
OTHER_BAR=  # not sensitive (explicit)
```

### `@disable`

[Section titled “@disable”](#disable)

**Value type:** `boolean`

If true, disables loading the file - meaning no items or plugins are loaded from it. Useful for temporarily or conditionally disabling a `.env` file.

💡 The [`forEnv()`](/reference/functions/#forenv) function can disable an explicitly [imported](/guides/import/) file based on the current [environment](/guides/environments/).

```env-spec
# @disable  # (shorthand for @disable=true)
#
# @plugin(@varlock/x-plugin)  # will not be loaded
# ---
FOO=bar  # will be ignored
```

### `@import()`

[Section titled “@import()”](#import)

**Arg types:** `[ path: string, ...keys?: string[] ]`\
**Named args:** `enabled?: boolean`, `allowMissing?: boolean`

Imports other `.env` file(s) - useful for sharing config across monorepos and splitting up large schemas. *Can be called multiple times.*

You may import a specific file, or a directory of files - automatically loading all `.env.*` files appropriately according to the current environment flag.

The optional `enabled` parameter allows conditional imports based on boolean expressions. It defaults to `true` if not specified.

The optional `allowMissing` parameter makes the import optional - if set to `true`, the import will be silently skipped if the file or directory doesn’t exist instead of causing a loading error. It defaults to `false` if not specified.

See the [imports guide](/guides/import/) for more details and advanced usage.

```env-spec
# @import(./.env.imported)                        # import a specific file
# @import(./.env.other, KEY1, KEY2)               # import specific keys
# @import(../shared-env/)                         # import a directory
# @import(~/.env.shared)                          # import from home directory
# @import(./.env.dev, enabled=eq($ENV, "dev"))    # conditional import
# @import(./.env.local, allowMissing=true)        # optional import (no error if missing)
# ---


# this definition is merged with any found in imports, but this one has more precedence
IMPORTED_ITEM=overriden-value
```

### `@setValuesBulk()`

[Section titled “@setValuesBulk()”](#setvaluesbulk)

**Arg types:** `[ data: string ]` **Named args:** `format?: "json" | "env"`, `createMissing?: boolean`, `enabled?: boolean`

Injects multiple config values at once from an external data source. The first argument is a resolver that produces a string (e.g., `exec()` calling a secrets manager), which is parsed and injected as definitions within the file containing the decorator.

Bulk values participate in the normal file override chain — `process.env` still overrides everything, higher-precedence files (`.env.local`, `.env.production`, etc.) override bulk values, and bulk values override schema-defined defaults in the same file. You control precedence by choosing which file to put `@setValuesBulk` in.

**Options:**

* `format`: How to parse the data string. `json` expects a flat JSON object, `env` expects `.env` file format. If not specified, auto-detected by checking if the string starts with `{`.
* `createMissing`: If `true`, keys in the bulk data that don’t already exist in your schema will be created as new config items. Defaults to `false` (unknown keys are silently skipped).
* `enabled`: If `false`, the bulk data resolver is skipped entirely. Accepts any boolean expression, including dynamic references to other config items. Defaults to `true`.

*Can be called multiple times — later calls overwrite earlier ones for the same keys.*

.env.schema

```env-spec
# Inject secrets from a vault as JSON
# @setValuesBulk(exec("vault kv get -format=json secret/myapp"), format=json)
# ---
API_KEY=
DB_PASSWORD=
```

.env.schema

```env-spec
# Inject from a secrets file as .env format
# @setValuesBulk(exec("cat /run/secrets/env"), format=env)
# ---
API_KEY=
DB_PASSWORD=
```

.env.schema

```env-spec
# Create items not already in the schema
# @setValuesBulk(exec("vault kv get -format=json secret/myapp"), format=json, createMissing=true)
# ---
```

.env.schema

```env-spec
# Only fetch from the vault in non-production environments
# @setValuesBulk(exec("vault kv get -format=json secret/dev"), format=json, enabled=eq($APP_ENV, "dev"))
# ---
API_KEY=
APP_ENV=dev
```

Note

When using `format=env`, function calls like `$VAR` references in unquoted values are not supported and will cause an error. Use single quotes for literal `$` signs (e.g., `'$LITERAL'`) or use `format=json` instead.

`createMissing` and type generation

Items created via `createMissing=true` — those that don’t already exist in your schema — **will not be included in generated TypeScript types**. Type generation happens at build/schema-load time before values are fetched, so dynamically created keys are invisible to the type generator.

For this reason, **`createMissing=true` is not recommended**. Instead, declare all expected items explicitly in your schema (with an empty value) so they are known at type-generation time.

### `@plugin()`

[Section titled “@plugin()”](#plugin)

**Arg types:** `[ identifier: string ]`

Loads a plugin, which can register new root decorators, item decorators, and resolver functions. *Can be called multiple times.*

See [plugins guide](/guides/plugins/) for more details.

```env-spec
# @plugin(@varlock/1password-plugin)
# @initOp(allowAppAuth=true) # new root decorator
# ---
# @type=opServiceAccountToken # new data type
OP_TOKEN=
# @sensitive
XYZ_API_KEY=op(op://api-prod/xyz/api-key) # new resolver
```

### `@generateTypes()`

[Section titled “@generateTypes()”](#generatetypes)

**Arg types (key/value):**

* `lang`: Language to generate types for (currently only `ts` / TypeScript is supported, with more languages planned)
* `path`: Relative filepath to output generated type file
* `auto`: Controls whether types are generated automatically on every load (defaults to `true`). Set to `false` to disable automatic generation and instead run [`varlock typegen`](/reference/cli-commands/#typegen) explicitly.
* `executeWhenImported`: overrides the default behaviour of not executing when the containing file is imported (defaults to `false`)

Triggers type generation based on your schema. *Can be called multiple times.*

```env-spec
# @generateTypes(lang=ts, path=./env.d.ts)
# ---
```

Tip

Usually this decorator will live in your primary `.env.schema` file, and it will be ignored if it is within an imported file.

To override this behaviour, set `executeWhenImported` to `true`.

Disabling automatic type generation

If you prefer to generate types manually rather than on every load, set `auto=false` and run [`varlock typegen`](/reference/cli-commands/#typegen) explicitly:

```env-spec
# @generateTypes(lang=ts, path=./env.d.ts, auto=false)
# ---
```

This is useful when you want full control over when your type definitions are updated, for example in a CI pipeline or as a dedicated build step.

### `@redactLogs`

[Section titled “@redactLogs”](#redactlogs)

**Value type:** `boolean`

Controls whether sensitive config values are automatically redacted from console output. When enabled, any sensitive values will be replaced with `▒▒▒▒▒` in logs.

*Only applies in JavaScript based projects where varlock runtime code is imported.*

* `true` (default): Console logs are automatically redacted
* `false`: Console logs are not redacted (useful for debugging)

```env-spec
# @redactLogs=false
# ---
SECRET_KEY=my-secret-value # @sensitive
```

```js
console.log(process.env.SECRET_KEY)
// This will log "my▒▒▒▒▒" instead of "my-secret-value" when @redactLogs=true
```

Caution

There is a potential performance impact for both `@preventLeaks` and `@redactLogs` when enabled. It depends on the integration and how your application is served. Please [reach out](https://chat.dmno.dev) if you have any questions.

We feel that they are beneficial enough to have them on by default but you can always opt out if you prefer.

### `@preventLeaks`

[Section titled “@preventLeaks”](#preventleaks)

**Value type:** `boolean`

Controls whether leak prevention is enabled. When enabled, varlock will scan outgoing HTTP responses to detect if sensitive values are being leaked.

*Only applies in JavaScript based projects where varlock runtime code is imported.*

**Options:**

* `true` (default): Leak detection is enabled
* `false`: Leak detection is disabled (useful for debugging)

```env-spec
# @preventLeaks=false
# ---
SECRET_KEY=my-secret-value # @sensitive
```

![Leak prevention](/_astro/leak.D-sjPUs5_1XAfab.png) *a sample leak detection warning in an [Astro project](/integrations/astro/)*

Caution

See note on [`@redactLogs`](#redactlogs) about potential performance impact.