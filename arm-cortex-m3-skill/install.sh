#!/usr/bin/env bash

set -e

SKILL_NAME="arm-cortex-m3-skill"
PLATFORM="${1:---all}"

echo "Installing $SKILL_NAME..."

install_skill() {
    local target_dir="$1"
    if [ -d "$target_dir" ]; then
        mkdir -p "$target_dir/skills/$SKILL_NAME"
        cp -R ./* "$target_dir/skills/$SKILL_NAME/"
        echo "✅ Installed to $target_dir/skills/$SKILL_NAME"
    fi
}

install_skill_rules() {
    local target_dir="$1"
    if [ -d "$target_dir" ]; then
        mkdir -p "$target_dir/rules/$SKILL_NAME"
        cp -R ./* "$target_dir/rules/$SKILL_NAME/"
        echo "✅ Installed to $target_dir/rules/$SKILL_NAME"
    fi
}

if [[ "$PLATFORM" == "--all" || "$PLATFORM" == "universal" ]]; then
    install_skill "$HOME/.agents"
    install_skill ".agents"
fi

if [[ "$PLATFORM" == "--all" || "$PLATFORM" == "claude" ]]; then
    install_skill "$HOME/.claude"
fi

if [[ "$PLATFORM" == "--all" || "$PLATFORM" == "cursor" ]]; then
    install_skill_rules ".cursor"
fi

if [[ "$PLATFORM" == "--all" || "$PLATFORM" == "copilot" ]]; then
    install_skill ".github"
fi

echo ""
echo "Installation complete!"
echo "To use this skill, open your agent chat and type:"
echo "  /$SKILL_NAME explain the exception entry sequence"
