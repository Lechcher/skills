#!/usr/bin/env bash
# install.sh — Cross-platform installer for zig-lang-skill
# Usage:
#   ./install.sh                  # auto-detect platform
#   ./install.sh --platform gemini
#   ./install.sh --all            # install to all detected platforms
#   ./install.sh --dry-run        # preview without copying

set -euo pipefail

SKILL_NAME="zig-lang-skill"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLATFORM=""
DRY_RUN=false
INSTALL_ALL=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --platform) PLATFORM="$2"; shift 2 ;;
    --dry-run)  DRY_RUN=true; shift ;;
    --all)      INSTALL_ALL=true; shift ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done

install_to() {
  local dest="$1"
  local label="$2"
  local target_dir="$dest/$SKILL_NAME"

  echo "→ Installing to $label: $target_dir"
  if [ "$DRY_RUN" = true ]; then
    echo "  [DRY RUN] Would copy $SCRIPT_DIR → $target_dir"
    return
  fi
  mkdir -p "$dest"
  cp -R "$SCRIPT_DIR" "$target_dir"
  echo "  ✓ Installed"
}

detect_and_install() {
  local installed=false

  # Priority platform detection (check in order)
  if [ -d "$HOME/.gemini" ]; then
    install_to "$HOME/.gemini/skills" "Gemini CLI (user)"
    installed=true
  fi
  if [ -d "$HOME/.claude" ]; then
    install_to "$HOME/.claude/skills" "Claude Code (user)"
    installed=true
  fi
  if [ -d "$HOME/.agents" ]; then
    install_to "$HOME/.agents/skills" "Universal (user)"
    installed=true
  fi
  if [ -d ".cursor" ]; then
    install_to ".cursor/rules" "Cursor (project)"
    installed=true
  elif [ -d "$HOME/.cursor" ]; then
    install_to "$HOME/.cursor/extensions/skills" "Cursor (user)"
    installed=true
  fi
  if [ -d ".github" ]; then
    install_to ".github/skills" "GitHub Copilot (project)"
    installed=true
  fi
  if [ -d ".windsurf" ]; then
    install_to ".windsurf/rules" "Windsurf (project)"
    installed=true
  elif [ -d "$HOME/.codeium/windsurf" ]; then
    install_to "$HOME/.codeium/windsurf/skills" "Windsurf (user)"
    installed=true
  fi
  if [ -d ".clinerules" ]; then
    install_to ".clinerules" "Cline (project)"
    installed=true
  fi
  if [ -d ".kiro" ]; then
    install_to ".kiro/skills" "Kiro (project)"
    installed=true
  fi
  if [ -d "$HOME/.agents" ]; then
    install_to "$HOME/.agents/skills" "Universal fallback"
    installed=true
  fi

  if [ "$installed" = false ]; then
    echo "⚠ No supported AI platform detected."
    echo ""
    echo "Manual installation options:"
    echo "  Gemini CLI:      cp -R . ~/.gemini/skills/$SKILL_NAME"
    echo "  Claude Code:     cp -R . ~/.claude/skills/$SKILL_NAME"
    echo "  Universal:       cp -R . ~/.agents/skills/$SKILL_NAME"
    echo "  Cursor:          cp -R . .cursor/rules/$SKILL_NAME"
    echo ""
    echo "Or specify: ./install.sh --platform gemini"
    exit 1
  fi
}

install_platform() {
  case "$PLATFORM" in
    gemini)     install_to "$HOME/.gemini/skills" "Gemini CLI" ;;
    claude)     install_to "$HOME/.claude/skills" "Claude Code" ;;
    universal)  install_to "$HOME/.agents/skills" "Universal" ;;
    cursor)     install_to ".cursor/rules" "Cursor (project)" ;;
    copilot)    install_to ".github/skills" "GitHub Copilot" ;;
    windsurf)   install_to ".windsurf/rules" "Windsurf" ;;
    cline)      install_to ".clinerules" "Cline" ;;
    kiro)       install_to ".kiro/skills" "Kiro" ;;
    goose)      install_to "$HOME/.config/goose/skills" "Goose" ;;
    trae)       install_to ".trae/rules" "Trae" ;;
    roo-code)   install_to ".roo/rules" "Roo Code" ;;
    antigravity) install_to ".agents/skills" "Antigravity" ;;
    *)
      echo "Unknown platform: $PLATFORM"
      echo "Supported: gemini, claude, universal, cursor, copilot, windsurf, cline, kiro, goose, trae, roo-code, antigravity"
      exit 1
      ;;
  esac
}

echo "╔══════════════════════════════════════╗"
echo "║  Installing: $SKILL_NAME             ║"
echo "╚══════════════════════════════════════╝"
echo ""

if [ -n "$PLATFORM" ]; then
  install_platform
elif [ "$INSTALL_ALL" = true ]; then
  detect_and_install
else
  detect_and_install
fi

echo ""
echo "✅ Done! Open a new session and type:"
echo ""
echo "  /zig-lang Write a generic stack in Zig"
echo "  /zig-lang How do I handle errors in Zig?"
echo "  /zig-lang Build a WASM module with Zig"
echo ""
