#!/usr/bin/env bash
# Auto-installer for sinric-pro-esp32-skill
# Supports Claude Code, Cursor, Windsurf, Cline, Copilot, Kiro, Goose, OpenCode, Roo Code, Trae, Gemini CLI, Universal

set -e

SKILL_NAME="sinric-pro-esp32-skill"
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Platform detection
declare -A PLATFORMS=(
    ["claude-code"]="$HOME/.claude/skills/$SKILL_NAME"
    ["cursor"]=".cursor/rules/$SKILL_NAME"
    ["windsurf"]=".windsurf/rules/$SKILL_NAME"
    ["cline"]=".clinerules/$SKILL_NAME"
    ["copilot"]=".github/skills/$SKILL_NAME"
    ["kiro"]=".kiro/skills/$SKILL_NAME"
    ["goose"]="$HOME/.config/goose/skills/$SKILL_NAME"
    ["opencode"]="$HOME/.config/opencode/skills/$SKILL_NAME"
    ["roo-code"]=".roo/rules/$SKILL_NAME"
    ["trae"]=".trae/rules/$SKILL_NAME"
    ["gemini-cli"]="$HOME/.gemini/skills/$SKILL_NAME"
    ["universal"]="$HOME/.agents/skills/$SKILL_NAME"
    ["antigravity"]=".agents/skills/$SKILL_NAME"
)

echo -e "${BLUE}Installing $SKILL_NAME...${NC}"

# Target handling
TARGET_PLATFORM=""
if [ "$1" == "--platform" ] && [ -n "$2" ]; then
    TARGET_PLATFORM="$2"
    if [ -z "${PLATFORMS[$TARGET_PLATFORM]}" ]; then
        echo -e "${RED}Unknown platform: $TARGET_PLATFORM${NC}"
        echo "Supported platforms: ${!PLATFORMS[@]}"
        exit 1
    fi
fi

if [ -n "$TARGET_PLATFORM" ]; then
    TARGET_DIR="${PLATFORMS[$TARGET_PLATFORM]}"
    mkdir -p "$(dirname "$TARGET_DIR")"
    cp -r "$SOURCE_DIR" "$TARGET_DIR"
    echo -e "${GREEN}✓ Installed specifically for $TARGET_PLATFORM in $TARGET_DIR${NC}"
else
    # Auto-detect and install for all
    INSTALLED=0
    for PLATFORM in "${!PLATFORMS[@]}"; do
        TARGET_DIR="${PLATFORMS[$PLATFORM]}"
        BASE_DIR="$(dirname "$TARGET_DIR")"
        if [ -d "$BASE_DIR" ]; then
            cp -r "$SOURCE_DIR" "$TARGET_DIR"
            echo -e "${GREEN}✓ Installed for $PLATFORM in $TARGET_DIR${NC}"
            INSTALLED=1
        fi
    done

    if [ $INSTALLED -eq 0 ]; then
        # Fallback to universal
        TARGET_DIR="${PLATFORMS[universal]}"
        mkdir -p "$(dirname "$TARGET_DIR")"
        cp -r "$SOURCE_DIR" "$TARGET_DIR"
        echo -e "${YELLOW}No specific IDE detected. Installed to universal path: $TARGET_DIR${NC}"
    fi
fi

echo -e "\n${GREEN}Installation complete!${NC}"
echo -e "To use the skill, open your AI assistant and type:"
echo -e "  ${BLUE}/$SKILL_NAME help me set up a Sinric Pro switch${NC}\n"
