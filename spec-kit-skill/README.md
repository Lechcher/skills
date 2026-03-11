# spec-kit-skill

A Level 5 skill that manages and runs GitHub Spec Kit projects for Spec-Driven Development. Automates initialization, checks prerequisites, and guides you step-by-step through the `/speckit.*` command workflow.

## Installation

### Mac / Linux
```bash
git clone <your-repo> ./spec-kit-skill
cd spec-kit-skill
chmod +x install.sh
./install.sh
```

### Supported Platforms
Works identically on all agent environments using the Open Standards SKILL.md format:
- Claude Code
- Cursor
- Windsurf
- GitHub Copilot
- Gemini CLI
- Antigravity
- and 20+ more.

## Description
This skill turns your AI agent into an expert at using GitHub Spec Kit by providing explicit guidance, prerequisite checking with `scripts/check_prereqs.py`, and a structured sequence of slash commands that enforces proper Spec-Driven Development architecture.
