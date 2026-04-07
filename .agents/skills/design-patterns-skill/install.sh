#!/usr/bin/env bash

SKILL_NAME="design-patterns-skill"
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Universal Agent Skills directory
TARGET_DIR="$HOME/.agents/skills/$SKILL_NAME"

echo "Installing $SKILL_NAME..."
mkdir -p "$HOME/.agents/skills"
cp -R "$SOURCE_DIR" "$TARGET_DIR"

echo "✅ Installed $SKILL_NAME successfully."
echo "You can now use this skill in any supported agent via /design-patterns-skill"
