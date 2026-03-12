# SePay Reference Skill

An agent skill that provides deep technical knowledge about the [SePay](https://sepay.vn) payment automation and bank reconciliation platform based on its official documentation.

## Features
- Complete offline reference guide to SePay (including REST APIs, WebHooks, eShop, and integrations).
- Search capabilities to quickly retrieve code snippets and API definitions.
- Works across any platform that supports the `SKILL.md` standard.

## Installation

Run the provided installation script to add it to your agent:
```bash
./install.sh
```

Or copy the directory to your skills folder directly:
```bash
# Universal
cp -R sepay-reference-skill ~/.agents/skills/

# Claude Code
cp -R sepay-reference-skill ~/.claude/skills/
```

## Usage

In your agent chat, run:
```
/sepay-reference-skill How do I configure WooCommerce?
/sepay-reference-skill What is the webhook format for a bank transfer?
```
