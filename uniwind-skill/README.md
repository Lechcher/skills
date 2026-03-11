# Uniwind Skill

This is an agent skill for [Uniwind](https://uniwind.dev), providing Tailwind CSS v4 styling for React Native projects. It is built to the Agent Skills Open Standard and supports multiple AI coding platforms.

## Installation

You can install this skill into your preferred AI coding tool.

### Auto-Install (Recommended)
Run the included installer to automatically detect your AI tool and install the skill:
```bash
./install.sh
```

### Specific Platforms

**For Claude Code:**
```bash
./install.sh --platform claude-code
# Or manually:
cp -R . ~/.claude/skills/uniwind-skill
```

**For Cursor:**
```bash
./install.sh --platform cursor
# Or manually:
cp -R . .cursor/rules/uniwind-skill
```

**For Windsurf:**
```bash
./install.sh --platform windsurf
```

**For VS Code Copilot:**
```bash
./install.sh --platform copilot
# Or manually:
cp -R . .github/skills/uniwind-skill
```

**For Universal (Codex, Gemini, Antigravity, Kiro, Trae):**
```bash
./install.sh --platform universal
# Or manually:
cp -R . ~/.agents/skills/uniwind-skill
```

## Usage

Once installed, open a new chat session in your AI tool and invoke the skill:

```
/uniwind-skill Style this button component
```

Or just ask questions referencing Tailwind and React Native, and the skill's discovery keywords will automatically trigger it!
