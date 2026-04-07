#!/bin/bash
# install.sh for rust-lang-skill
# Auto-detects platform and installs the skill

set -e

SKILL_NAME="rust-lang-skill"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=false
TARGET_PLATFORM=""
INSTALL_ALL=false

# Color output
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run) DRY_RUN=true; shift;;
        --platform) TARGET_PLATFORM="$2"; shift 2;;
        --all) INSTALL_ALL=true; shift;;
        --help) echo "Usage: $0 [--dry-run] [--platform PLATFORM] [--all]"
                echo "Platforms: claude, cursor, copilot, windsurf, cline, gemini, universal"
                exit 0;;
        *) error "Unknown argument: $1"; exit 1;;
    esac
done

install_to() {
    local dest="$1"
    local platform="$2"
    if [ "$DRY_RUN" = true ]; then
        info "[DRY RUN] Would install to: $dest"
        return
    fi
    mkdir -p "$dest"
    cp -R "$SCRIPT_DIR" "$dest/$SKILL_NAME"
    info "✅ Installed to $dest/$SKILL_NAME ($platform)"
}

detect_and_install() {
    local installed=false
    
    # Claude Code
    if [ -d "$HOME/.claude" ] && { [ -z "$TARGET_PLATFORM" ] || [ "$TARGET_PLATFORM" = "claude" ]; }; then
        install_to "$HOME/.claude/skills" "Claude Code"
        installed=true
    fi
    
    # Cursor (user-level)
    if [ -d "$HOME/.cursor" ] && { [ -z "$TARGET_PLATFORM" ] || [ "$TARGET_PLATFORM" = "cursor" ]; }; then
        install_to "$HOME/.cursor/rules" "Cursor (user)"
        installed=true
    fi
    
    # GitHub Copilot
    if [ -d ".github" ] && { [ -z "$TARGET_PLATFORM" ] || [ "$TARGET_PLATFORM" = "copilot" ]; }; then
        install_to ".github/skills" "GitHub Copilot"
        installed=true
    fi
    
    # Windsurf
    if [ -d "$HOME/.codeium/windsurf" ] && { [ -z "$TARGET_PLATFORM" ] || [ "$TARGET_PLATFORM" = "windsurf" ]; }; then
        install_to "$HOME/.codeium/windsurf/skills" "Windsurf"
        installed=true
    fi
    
    # Cline
    if [ -d ".clinerules" ] && { [ -z "$TARGET_PLATFORM" ] || [ "$TARGET_PLATFORM" = "cline" ]; }; then
        install_to ".clinerules" "Cline"
        installed=true
    fi
    
    # Gemini CLI
    if [ -d "$HOME/.gemini" ] && { [ -z "$TARGET_PLATFORM" ] || [ "$TARGET_PLATFORM" = "gemini" ]; }; then
        install_to "$HOME/.gemini/skills" "Gemini CLI"
        installed=true
    fi
    
    # Universal (.agents/skills)
    if [ -d "$HOME/.agents" ] || { [ -n "$TARGET_PLATFORM" ] && [ "$TARGET_PLATFORM" = "universal" ]; }; then
        install_to "$HOME/.agents/skills" "Universal"
        installed=true
    fi
    
    # Antigravity
    if [ -d ".agents" ] && { [ -z "$TARGET_PLATFORM" ] || [ "$TARGET_PLATFORM" = "antigravity" ]; }; then
        install_to ".agents/skills" "Antigravity"
        installed=true
    fi
    
    if [ "$installed" = false ]; then
        warn "No platform auto-detected. Installing to universal path: ~/.agents/skills/"
        install_to "$HOME/.agents/skills" "Universal"
    fi
}

echo ""
echo "🦀 Installing $SKILL_NAME..."
echo ""
detect_and_install
echo ""
info "Installation complete!"
echo ""
echo "To use the skill, open a new session and type:"
echo "  /rust-lang-skill <your Rust question or task>"
echo ""
echo "Examples:"
echo "  /rust-lang-skill Explain ownership and borrowing"
echo "  /rust-lang-skill How do I use async/await with Tokio?"
echo "  /rust-lang-skill Write a thread-safe counter"
