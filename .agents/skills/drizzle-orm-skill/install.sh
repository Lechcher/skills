#!/bin/bash
# install.sh for drizzle-orm-skill

set -e

SKILL_NAME="drizzle-orm-skill"
SOURCE_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

echo "Installing ${SKILL_NAME}..."

# Default universal platform check
TARGET_DIR="${HOME}/.agents/skills/${SKILL_NAME}"

# If Cursor is detected and preferred locally
if [ -d ".cursor/rules" ]; then
    TARGET_DIR=".cursor/rules/${SKILL_NAME}"
    echo "Detected Cursor Local Project. Installing to ${TARGET_DIR}"
elif [ -d "${HOME}/.claude/skills" ]; then
    TARGET_DIR="${HOME}/.claude/skills/${SKILL_NAME}"
    echo "Detected Claude Code. Installing to ${TARGET_DIR}"
fi

mkdir -p "$TARGET_DIR"

if [ "$SOURCE_DIR" != "$TARGET_DIR" ]; then
    cp -R "$SOURCE_DIR/"* "$TARGET_DIR/"
    echo "Skill successfully installed to $TARGET_DIR"
else
    echo "Skill is already in the target directory."
fi

echo ""
echo "Installation complete!"
echo "To use this skill, open your agent chat and type:"
echo "  /${SKILL_NAME} setup a pg schema with relations"
