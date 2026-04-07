# drizzle-orm-skill

This skill adds expert-level Drizzle ORM capabilities to your AI agent.
It contains the full (215+ pages) Drizzle ORM documentation and a script to search it, allowing your agent to write exact, up-to-date Drizzle configurations, schemas, relational queries, and kit commands without hallucinating.

## Installation

Run the installation script to copy this skill to your agent's skill directory:

```bash
./install.sh
```

## Usage

In your AI assistant chat, start your prompt with `/drizzle-orm-skill`:

- `/drizzle-orm-skill create a User and Post schema with drizzle/pg-core`
- `/drizzle-orm-skill how do I write an inner join with limit 10?`
- `/drizzle-orm-skill explain relational queries in v2`

When invoked, the agent will analyze your request, consult the massive bundled documentation (stored in `references/drizzle-orm-docs.md`), and provide the precise code or command you need.
