# motia-skill

An agent skill for the **Motia** backend framework — the unified backend where everything is a Step.

## What Is Motia?

Motia is a production-grade backend framework where APIs, background jobs, cron tasks, workflows, and AI agents are all built from a single primitive: the **Step**. Powered by the **iii engine**, it replaces juggling separate frameworks for queues, crons, and APIs.

## What This Skill Does

Helps you build Motia backends by:

- Creating Steps for any trigger type (HTTP, queue, cron, state, stream)
- Writing complete, working TypeScript and Python step files
- Designing event-driven workflows with `enqueue()` patterns
- Configuring the iii engine (`config.yaml`) for dev and production
- Implementing state management with atomic updates
- Building real-time streams (WebSocket-based)
- Adding middleware for auth, rate limiting, and error handling
- Deploying to Docker, Railway, or Fly.io

## Installation

### Gemini CLI
```bash
git clone https://github.com/your-org/motia-skill ~/.gemini/skills/motia-skill
```

### Claude Code
```bash
git clone https://github.com/your-org/motia-skill ~/.claude/skills/motia-skill
```

### Cursor
```bash
git clone https://github.com/your-org/motia-skill .cursor/rules/motia-skill
```

### GitHub Copilot
```bash
git clone https://github.com/your-org/motia-skill .github/skills/motia-skill
```

### Universal (Codex CLI, Kiro, Antigravity, etc.)
```bash
git clone https://github.com/your-org/motia-skill ~/.agents/skills/motia-skill
```

### Auto-install script
```bash
./install.sh                    # Auto-detect platform
./install.sh --platform cursor  # Specific platform
./install.sh --all              # All detected platforms
./install.sh --dry-run          # See where it would install
```

## Usage

Open a new agent session and type:

```
/motia-skill Create an HTTP endpoint to register users and enqueue a welcome email
/motia-skill Set up a queue worker with retry logic and state tracking
/motia-skill Add a cron job that runs a daily report at midnight
/motia-skill Build a real-time notification stream for my React app
/motia-skill Configure the iii engine with Redis for production deployment
/motia-skill Implement a parallel-then-merge workflow using state triggers
/motia-skill Build an AI agent that streams LLM responses to the frontend
```

## Reference Files

| File | Contents |
|------|----------|
| `references/steps-reference.md` | All trigger types with complete TypeScript/Python examples |
| `references/state-streams-reference.md` | State methods, atomic updates, stream creation and usage |
| `references/iii-engine-reference.md` | `config.yaml` reference for all modules and adapters |
| `references/middleware-observability.md` | Middleware, logging, tracing, and flows |
| `references/deployment-guide.md` | Docker, Railway, Fly.io deployment with production configs |

## License

MIT
