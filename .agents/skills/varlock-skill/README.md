# varlock-skill

A cross-platform agent skill for managing Varlock environment configurations.

## What it does

This skill equips your AI agent with the ability to:
- Generate `.env.schema` files with `@env-spec` decorators.
- Validate, type-check, and secure Varlock configurations.
- Scaffold multi-environment configurations and cloud secret integrations.
- Utilize the full Varlock documentation offline.

## Installation

### Automatic Install
Run the installer script:
```bash
./install.sh
```

### Manual Install

**For Claude Code:**
```bash
git clone <this-repo> ~/.claude/skills/varlock-skill
```

**For Cursor:**
```bash
git clone <this-repo> .cursor/rules/varlock-skill
```

**For Other Agents (Windsurf, Copilot, etc.):**
```bash
git clone <this-repo> ~/.agents/skills/varlock-skill
```

## Usage

Once installed, just prompt your agent with the invocation trigger:

```
/varlock-skill migrate my old .env to be an AI-Safe .env.schema
```
