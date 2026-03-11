#!/usr/bin/env bash
set -euo pipefail

SKILL_NAME="motia-skill"
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${BLUE}[motia-skill]${NC} $1"; }
success() { echo -e "${GREEN}[motia-skill]${NC} $1"; }
warn() { echo -e "${YELLOW}[motia-skill]${NC} $1"; }

detect_platform() {
  if [[ -d "$HOME/.gemini" ]]; then echo "gemini"
  elif [[ -d "$HOME/.claude" ]]; then echo "claude"
  elif [[ -d ".cursor" || -d "$HOME/.cursor" ]]; then echo "cursor"
  elif [[ -d ".github" ]]; then echo "copilot"
  elif [[ -d "$HOME/.codeium/windsurf" || -d ".windsurf" ]]; then echo "windsurf"
  elif [[ -d ".clinerules" ]]; then echo "cline"
  elif [[ -d "$HOME/.agents" || -d ".agents" ]]; then echo "universal"
  else echo "unknown"
  fi
}

install_skill() {
  local platform="${1:-$(detect_platform)}"

  log "Installing ${SKILL_NAME} for platform: ${platform}"

  case "$platform" in
    gemini)
      DEST="$HOME/.gemini/skills/${SKILL_NAME}"
      mkdir -p "$HOME/.gemini/skills"
      ;;
    claude)
      DEST="$HOME/.claude/skills/${SKILL_NAME}"
      mkdir -p "$HOME/.claude/skills"
      ;;
    cursor)
      if [[ -d ".cursor" ]]; then
        DEST=".cursor/rules/${SKILL_NAME}"
        mkdir -p ".cursor/rules"
      else
        DEST="$HOME/.cursor/skills/${SKILL_NAME}"
        mkdir -p "$HOME/.cursor/skills"
      fi
      ;;
    copilot)
      DEST=".github/skills/${SKILL_NAME}"
      mkdir -p ".github/skills"
      ;;
    windsurf)
      if [[ -d ".windsurf" ]]; then
        DEST=".windsurf/rules/${SKILL_NAME}"
        mkdir -p ".windsurf/rules"
      else
        DEST="$HOME/.codeium/windsurf/skills/${SKILL_NAME}"
        mkdir -p "$HOME/.codeium/windsurf/skills"
      fi
      ;;
    cline)
      DEST=".clinerules/${SKILL_NAME}"
      mkdir -p ".clinerules"
      ;;
    universal|unknown|*)
      if [[ -d "$HOME/.agents" ]]; then
        DEST="$HOME/.agents/skills/${SKILL_NAME}"
        mkdir -p "$HOME/.agents/skills"
      else
        DEST=".agents/skills/${SKILL_NAME}"
        mkdir -p ".agents/skills"
      fi
      ;;
  esac

  # Copy skill
  if [[ "$SKILL_DIR" != "$DEST" ]]; then
    cp -R "$SKILL_DIR" "$DEST"
    success "Installed to: ${DEST}"
  else
    success "Already in place at: ${DEST}"
  fi
}

# Parse args
PLATFORM=""
DRY_RUN=false
INSTALL_ALL=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --platform) PLATFORM="$2"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    --all) INSTALL_ALL=true; shift ;;
    *) shift ;;
  esac
done

if [[ "$DRY_RUN" == "true" ]]; then
  warn "Dry run — detected platform: $(detect_platform)"
  exit 0
fi

if [[ "$INSTALL_ALL" == "true" ]]; then
  for p in gemini claude cursor copilot windsurf cline universal; do
    install_skill "$p" 2>/dev/null || true
  done
else
  install_skill "${PLATFORM}"
fi

echo ""
success "Installation complete!"
echo ""
echo "To use the skill, open a new session and type:"
echo ""
echo "  /motia-skill Create an HTTP endpoint for user registration"
echo "  /motia-skill Set up a queue worker with retry logic"
echo "  /motia-skill Configure Redis for production in config.yaml"
echo ""
