#!/usr/bin/env bash
# Varlock Skill Installer

SKILL_NAME="varlock-skill"
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing $SKILL_NAME..."

# Install globally for agents
AGENT_PATH="$HOME/.agents/skills/$SKILL_NAME"
mkdir -p "$HOME/.agents/skills"
rm -rf "$AGENT_PATH"
cp -R "$SKILL_DIR" "$AGENT_PATH"

echo "Installed to $AGENT_PATH"

# Try installing to Claude Code
if [ -d "$HOME/.claude/skills" ]; then
    rm -rf "$HOME/.claude/skills/$SKILL_NAME"
    cp -R "$SKILL_DIR" "$HOME/.claude/skills/$SKILL_NAME"
    echo "Installed to ~/.claude/skills/$SKILL_NAME"
fi

# Try installing to Cursor
if [ -d ".cursor/rules" ]; then
    rm -rf ".cursor/rules/$SKILL_NAME"
    cp -R "$SKILL_DIR" ".cursor/rules/$SKILL_NAME"
    echo "Installed to .cursor/rules/$SKILL_NAME"
fi

echo "Done! You can now invoke the skill with: /$SKILL_NAME"
