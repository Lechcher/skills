#!/usr/bin/env bash

# sepay-reference-skill installer
# Supports cross-platform skill installation

SKILL_NAME="sepay-reference-skill"
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Detect platform if not specified
PLATFORM=$1

if [ -z "$PLATFORM" ]; then
    if [ -d "$HOME/.claude" ]; then
        PLATFORM="claude"
    elif [ -d "$HOME/.agents" ]; then
        PLATFORM="universal"
    elif [ -d ".cursor" ] || [ -d "$HOME/.cursor" ]; then
        PLATFORM="cursor"
    else
        PLATFORM="universal"
    fi
fi

echo "Installing $SKILL_NAME for $PLATFORM..."

if [ "$PLATFORM" = "claude" ]; then
    INSTALL_DIR="$HOME/.claude/skills/$SKILL_NAME"
elif [ "$PLATFORM" = "cursor" ]; then
    INSTALL_DIR="./.cursor/rules/$SKILL_NAME"
elif [ "$PLATFORM" = "universal" ]; then
    INSTALL_DIR="$HOME/.agents/skills/$SKILL_NAME"
else
    INSTALL_DIR="$HOME/.agents/skills/$SKILL_NAME"
fi

mkdir -p "$INSTALL_DIR"
cp -r "$SOURCE_DIR/"* "$INSTALL_DIR/"

echo "Skill installed successfully at: $INSTALL_DIR"
echo ""
echo "To use it, open your agent chat and type:"
echo "  /$SKILL_NAME How do I integrate SePay with Shopify?"
