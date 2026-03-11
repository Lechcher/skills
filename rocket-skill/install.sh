#!/usr/bin/env bash
# install.sh — Auto-installer for rocket-skill
# Detects platform and installs the skill to the correct location.

set -e

SKILL_NAME="rocket-skill"
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=false
PLATFORM=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --platform) PLATFORM="$2"; shift 2 ;;
        --dry-run)  DRY_RUN=true; shift ;;
        --all)      INSTALL_ALL=true; shift ;;
        -h|--help)
            echo "Usage: ./install.sh [--platform <name>] [--dry-run] [--all]"
            echo ""
            echo "Platforms: universal, gemini, claude, cursor, copilot, windsurf, cline, kiro, roo, trae, goose, opencode, antigravity"
            exit 0 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

copy_skill() {
    local dest="$1"
    local label="$2"
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY RUN] Would install to: $dest"
        return
    fi
    mkdir -p "$dest"
    cp -R "$SKILL_DIR" "$dest/$SKILL_NAME"
    echo "✅ Installed to $dest/$SKILL_NAME ($label)"
}

detect_and_install() {
    local installed=false

    if [ -n "$PLATFORM" ]; then
        case "$PLATFORM" in
            universal|codex) copy_skill "$HOME/.agents/skills" "Universal"; installed=true ;;
            gemini)          copy_skill "$HOME/.gemini/skills" "Gemini CLI"; installed=true ;;
            claude)          copy_skill "$HOME/.claude/skills" "Claude Code"; installed=true ;;
            cursor)
                if [ -d ".cursor" ]; then copy_skill ".cursor/rules" "Cursor (project)"; 
                else copy_skill "$HOME/.cursor/rules" "Cursor (user)"; fi
                installed=true ;;
            copilot)         copy_skill ".github/skills" "GitHub Copilot"; installed=true ;;
            windsurf)
                if [ -d ".windsurf" ]; then copy_skill ".windsurf/rules" "Windsurf (project)";
                else copy_skill "$HOME/.codeium/windsurf/rules" "Windsurf (user)"; fi
                installed=true ;;
            cline)           copy_skill ".clinerules" "Cline"; installed=true ;;
            kiro)            copy_skill ".kiro/skills" "Kiro"; installed=true ;;
            roo)             copy_skill ".roo/rules" "Roo Code"; installed=true ;;
            trae)            copy_skill ".trae/rules" "Trae"; installed=true ;;
            goose)           copy_skill "$HOME/.config/goose/skills" "Goose"; installed=true ;;
            opencode)        copy_skill "$HOME/.config/opencode/skills" "OpenCode"; installed=true ;;
            antigravity)     copy_skill ".agents/skills" "Antigravity"; installed=true ;;
            *) echo "Unknown platform: $PLATFORM"; exit 1 ;;
        esac
    else
        # Auto-detect
        if [ -d "$HOME/.claude" ]; then
            copy_skill "$HOME/.claude/skills" "Claude Code"; installed=true
        fi
        if [ -d ".cursor" ]; then
            copy_skill ".cursor/rules" "Cursor (project)"; installed=true
        elif [ -d "$HOME/.cursor" ]; then
            copy_skill "$HOME/.cursor/rules" "Cursor (user)"; installed=true
        fi
        if [ -d "$HOME/.gemini" ]; then
            copy_skill "$HOME/.gemini/skills" "Gemini CLI"; installed=true
        fi
        if [ -d ".agents" ] || [ -d "$HOME/.agents" ]; then
            copy_skill "$HOME/.agents/skills" "Universal (.agents)"; installed=true
        fi
        if [ "$installed" = false ]; then
            # Fallback: install universally
            copy_skill "$HOME/.agents/skills" "Universal (fallback)"
            installed=true
        fi
    fi
}

if [ "${INSTALL_ALL:-false}" = true ]; then
    for p in claude cursor copilot windsurf cline gemini kiro roo trae goose opencode universal; do
        PLATFORM=$p detect_and_install 2>/dev/null || true
    done
else
    detect_and_install
fi

echo ""
echo "🚀 rocket-skill installed!"
echo ""
echo "To use it, open a new session and type:"
echo "  /rocket-skill Build a REST API with Rocket and SQLite"
echo "  /rocket-skill How do I add authentication to my routes?"
echo "  /rocket-skill Deploy my Rocket app to production"
