# rocket-skill

An AI agent skill for the **Rocket web framework** (v0.5) for Rust. Provides expert guidance on building, configuring, testing, and deploying Rocket web applications.

## What It Does

Invoke `/rocket-skill` in any AI coding assistant to get expert help with:

- 🚀 Building REST APIs and web applications with Rocket
- 🛡️ Request guards for authentication, authorization, rate limiting
- 📦 Database integration (SQLite, PostgreSQL, MySQL via `rocket_db_pools`)
- 🔄 Middleware/fairings for CORS, logging, security headers
- ⚙️ Configuration (Rocket.toml, environment variables, profiles)
- 🐳 Deployment (Docker, Nginx, Fly.io, Railway)
- 🧪 Testing with Rocket's built-in test client
- 🎯 Forms, JSON, file uploads, WebSockets, SSE

## Installation

### Gemini CLI
```bash
git clone https://github.com/your-org/rocket-skill ~/.gemini/skills/rocket-skill
```

### Claude Code
```bash
git clone https://github.com/your-org/rocket-skill ~/.claude/skills/rocket-skill
```

### Cursor
```bash
git clone https://github.com/your-org/rocket-skill .cursor/rules/rocket-skill
```

### GitHub Copilot
```bash
git clone https://github.com/your-org/rocket-skill .github/skills/rocket-skill
```

### Windsurf
```bash
git clone https://github.com/your-org/rocket-skill .windsurf/rules/rocket-skill
```

### Universal (Codex CLI, Antigravity, etc.)
```bash
git clone https://github.com/your-org/rocket-skill ~/.agents/skills/rocket-skill
```

### Auto-Detect Platform
```bash
git clone https://github.com/your-org/rocket-skill rocket-skill
cd rocket-skill
./install.sh
```

## Usage

```
/rocket-skill Create a REST API with users and posts, using PostgreSQL
/rocket-skill Add JWT authentication to my routes
/rocket-skill How do I handle file uploads in Rocket?
/rocket-skill Set up CORS for my Rocket API
/rocket-skill Write tests for my route handlers
/rocket-skill Deploy my Rocket app using Docker
/rocket-skill Connect to a SQLite database with rocket_db_pools
```

## Reference Files

| File | Contents |
|------|----------|
| `references/requests.md` | Routing, dynamic paths, request guards, forms, cookies, query strings |
| `references/responses.md` | Responders, JSON, templates, redirects, typed URIs, SSE |
| `references/state-databases.md` | Managed state, request-local state, databases |
| `references/fairings-testing.md` | Middleware fairings, testing patterns |
| `references/configuration-deployment.md` | Config, TLS, Docker, deployment |
| `references/pastebin-tutorial.md` | Complete step-by-step tutorial |
| `references/faq.md` | Common questions and patterns |

## Rocket Resources

- [Rocket Guide v0.5](https://rocket.rs/guide/v0.5/)
- [Rocket API Docs](https://api.rocket.rs/v0.5/rocket/)
- [Rocket GitHub](https://github.com/rwf2/Rocket)
- [Rocket Examples](https://github.com/rwf2/Rocket/tree/v0.5/examples)
- [rocket_db_pools](https://api.rocket.rs/v0.5/rocket_db_pools/)
- [rocket_dyn_templates](https://api.rocket.rs/v0.5/rocket_dyn_templates/)

## License

MIT
