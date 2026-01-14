#!/bin/bash
#
# Auto-Evolution Agent Skills Installer
# https://github.com/ZhanlinCui/Auto-Evolution-Agent-Skills
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/ZhanlinCui/Auto-Evolution-Agent-Skills/main/install.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/ZhanlinCui/Auto-Evolution-Agent-Skills/main/install.sh | bash -s -- --with-hooks
#   curl -fsSL https://raw.githubusercontent.com/ZhanlinCui/Auto-Evolution-Agent-Skills/main/install.sh | bash -s -- --target /path/to/project
#

set -e

# ============================================================================
# Configuration
# ============================================================================

REPO_URL="https://github.com/ZhanlinCui/Auto-Evolution-Agent-Skills"
BRANCH="main"
TARGET_DIR=""
WITH_HOOKS=false
TEMP_DIR=""
VERSION="2.0.0"

# ============================================================================
# Colors & Output
# ============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; exit 1; }

# ============================================================================
# Banner
# ============================================================================

print_banner() {
    echo ""
    echo -e "${PURPLE}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${NC}                                                           ${PURPLE}║${NC}"
    echo -e "${PURPLE}║${NC}   ${BOLD}🧠 Auto-Evolution Agent Skills${NC}                         ${PURPLE}║${NC}"
    echo -e "${PURPLE}║${NC}   ${CYAN}Memory-Driven Self-Evolution for AI Agents${NC}             ${PURPLE}║${NC}"
    echo -e "${PURPLE}║${NC}                                                           ${PURPLE}║${NC}"
    echo -e "${PURPLE}║${NC}   Version: ${GREEN}${VERSION}${NC}                                          ${PURPLE}║${NC}"
    echo -e "${PURPLE}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# ============================================================================
# Usage
# ============================================================================

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --target DIR      Install to specific directory (default: current)"
    echo "  --with-hooks      Enable self-evolution hooks"
    echo "  --branch BRANCH   Use specific branch (default: main)"
    echo "  --help            Show this help message"
    echo ""
    echo "Examples:"
    echo "  # Install to current project"
    echo "  $0"
    echo ""
    echo "  # Install with hooks enabled (recommended)"
    echo "  $0 --with-hooks"
    echo ""
    echo "  # Install to specific project"
    echo "  $0 --target /path/to/my-project --with-hooks"
    echo ""
}

# ============================================================================
# Argument Parsing
# ============================================================================

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --target)
                TARGET_DIR="$2"
                shift 2
                ;;
            --with-hooks)
                WITH_HOOKS=true
                shift
                ;;
            --branch)
                BRANCH="$2"
                shift 2
                ;;
            --help)
                usage
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                ;;
        esac
    done
}

# ============================================================================
# Dependency Check
# ============================================================================

check_deps() {
    info "Checking dependencies..."

    if ! command -v curl &> /dev/null && ! command -v git &> /dev/null; then
        error "Either curl or git is required. Please install one."
    fi

    if command -v curl &> /dev/null && ! command -v unzip &> /dev/null; then
        if ! command -v git &> /dev/null; then
            error "unzip is required when using curl. Install unzip or git."
        fi
        warn "unzip not found, will use git instead"
    fi

    success "Dependencies OK"
}

# ============================================================================
# Target Directory
# ============================================================================

determine_target() {
    if [[ -z "$TARGET_DIR" ]]; then
        TARGET_DIR="$(pwd)"
    fi

    TARGET_DIR="$(cd "$TARGET_DIR" 2>/dev/null && pwd)" || error "Directory does not exist: $TARGET_DIR"
    
    info "Target directory: ${CYAN}$TARGET_DIR${NC}"
}

# ============================================================================
# Download
# ============================================================================

download_skills() {
    info "Downloading Auto-Evolution..."

    TEMP_DIR=$(mktemp -d)
    trap "rm -rf $TEMP_DIR" EXIT

    local ZIP_URL="https://github.com/ZhanlinCui/Auto-Evolution-Agent-Skills/archive/refs/heads/${BRANCH}.zip"

    if command -v curl &> /dev/null && command -v unzip &> /dev/null; then
        if curl -fsSL "$ZIP_URL" -o "$TEMP_DIR/auto-evolution.zip" 2>/dev/null; then
            unzip -q "$TEMP_DIR/auto-evolution.zip" -d "$TEMP_DIR" 2>/dev/null
            mv "$TEMP_DIR/Auto-Evolution-Agent-Skills-${BRANCH}" "$TEMP_DIR/auto-evolution"
            success "Downloaded via ZIP"
            return
        fi
    fi

    if command -v git &> /dev/null; then
        git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$TEMP_DIR/auto-evolution" 2>/dev/null && \
            success "Downloaded via git" && return
    fi

    error "Failed to download. Check your internet connection."
}

# ============================================================================
# Install
# ============================================================================

install_skills() {
    local SKILLS_DIR="$TARGET_DIR/.claude/skills"
    local EVOLUTION_SRC="$TEMP_DIR/auto-evolution/skills/evolution"

    info "Installing to $SKILLS_DIR..."

    mkdir -p "$TARGET_DIR/.claude"

    # Backup existing evolution if present
    if [[ -d "$SKILLS_DIR/evolution" ]]; then
        local BACKUP_DIR="$SKILLS_DIR/evolution.backup.$(date +%Y%m%d%H%M%S)"
        warn "Existing evolution found. Backing up to $BACKUP_DIR"
        mv "$SKILLS_DIR/evolution" "$BACKUP_DIR"
    fi
    
    # Also backup old 99-evolution if present
    if [[ -d "$SKILLS_DIR/99-evolution" ]]; then
        local BACKUP_DIR="$SKILLS_DIR/99-evolution.backup.$(date +%Y%m%d%H%M%S)"
        warn "Old 99-evolution found. Backing up to $BACKUP_DIR"
        mv "$SKILLS_DIR/99-evolution" "$BACKUP_DIR"
    fi

    mkdir -p "$SKILLS_DIR"
    cp -r "$EVOLUTION_SRC" "$SKILLS_DIR/evolution"

    success "Evolution skills installed"
}

# ============================================================================
# Hooks
# ============================================================================

install_hooks() {
    if [[ "$WITH_HOOKS" != true ]]; then
        return
    fi

    local SKILLS_DIR="$TARGET_DIR/.claude/skills"
    local HOOKS_SRC="$SKILLS_DIR/evolution/hooks"
    local HOOKS_DST="$SKILLS_DIR/hooks"

    info "Installing hooks..."

    if [[ -d "$HOOKS_SRC" ]]; then
        # Backup existing hooks
        if [[ -d "$HOOKS_DST" ]]; then
            mv "$HOOKS_DST" "$HOOKS_DST.backup.$(date +%Y%m%d%H%M%S)"
        fi
        
        cp -r "$HOOKS_SRC" "$HOOKS_DST"
        chmod +x "$HOOKS_DST"/*.sh
        success "Hooks installed"

        echo ""
        echo -e "${YELLOW}┌─────────────────────────────────────────────────────────────┐${NC}"
        echo -e "${YELLOW}│${NC} ${BOLD}⚠️  Action Required: Enable hooks in settings.json${NC}          ${YELLOW}│${NC}"
        echo -e "${YELLOW}└─────────────────────────────────────────────────────────────┘${NC}"
        echo ""
        echo "Add to your .claude/settings.json (or merge with existing):"
        echo ""
        echo -e "${CYAN}$(cat "$HOOKS_SRC/settings.example.json")${NC}"
        echo ""
    else
        warn "Hooks source not found, skipping"
    fi
}

# ============================================================================
# Summary
# ============================================================================

print_summary() {
    local SKILLS_DIR="$TARGET_DIR/.claude/skills"

    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC} ${BOLD}✨ Installation Complete!${NC}                                 ${GREEN}║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  ${BOLD}Location:${NC} $SKILLS_DIR/evolution"
    echo ""
    echo -e "  ${BOLD}Structure:${NC}"
    echo "  └── evolution/"
    echo "      ├── SKILL.md          # Main entry point"
    echo "      ├── config.json       # Configuration"
    echo "      ├── memory/           # Three-layer memory"
    echo "      ├── hooks/            # Event capture"
    echo "      ├── reports/          # Dashboard & reports"
    echo "      ├── templates/        # Skill templates"
    echo "      └── community/        # Shared knowledge"
    echo ""
    echo -e "  ${BOLD}Next Steps:${NC}"
    echo ""
    if [[ "$WITH_HOOKS" == true ]]; then
        echo "  1. Add hooks config to .claude/settings.json (see above)"
        echo "  2. Open your project with Claude Code"
        echo "  3. Work normally - evolution happens automatically!"
        echo "  4. View dashboard: open evolution/reports/dashboard.html"
    else
        echo "  1. Enable hooks for full auto-evolution:"
        echo "     curl -fsSL https://raw.githubusercontent.com/ZhanlinCui/Auto-Evolution-Agent-Skills/main/install.sh | bash -s -- --with-hooks --target $TARGET_DIR"
        echo ""
        echo "  2. Or use manually by asking Claude to read evolution/SKILL.md"
    fi
    echo ""
    echo -e "  ${BOLD}Documentation:${NC} https://github.com/ZhanlinCui/Auto-Evolution-Agent-Skills"
    echo ""
}

# ============================================================================
# Main
# ============================================================================

main() {
    print_banner
    parse_args "$@"
    check_deps
    determine_target
    download_skills
    install_skills
    install_hooks
    print_summary
}

main "$@"
