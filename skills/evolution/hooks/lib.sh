#!/bin/bash
# Auto-Evolution Shared Library
# Core utilities for the evolution hooks system

set -euo pipefail

# ============================================================================
# Directory Discovery
# ============================================================================

evo_find_dirs() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # Navigate from hooks/ to evolution/
    EVOLUTION_DIR="$(cd "$script_dir/.." && pwd)"
    SKILLS_DIR="$(cd "$EVOLUTION_DIR/.." && pwd)"
    
    export EVOLUTION_DIR SKILLS_DIR
}

# ============================================================================
# Configuration
# ============================================================================

evo_config_get() {
    local key="$1"
    local default="${2:-}"
    local config_file="$EVOLUTION_DIR/config.json"
    local value=""
    
    if [[ -f "$config_file" ]]; then
        # Extract value using sed (POSIX compatible)
        value="$(sed -nE "s/.*\"$key\"[[:space:]]*:[[:space:]]*\"?([^\",}]*)\"?.*/\\1/p" "$config_file" | head -n 1)"
    fi
    
    echo "${value:-$default}"
}

# ============================================================================
# State Management
# ============================================================================

evo_init_state() {
    evo_find_dirs
    
    # Core directories
    MEMORY_DIR="$EVOLUTION_DIR/memory"
    REPORTS_DIR="$EVOLUTION_DIR/reports"
    DRAFTS_DIR="$MEMORY_DIR/drafts"
    STATE_DIR="$MEMORY_DIR/.state"
    
    # Core files
    EPISODES_FILE="$MEMORY_DIR/episodes.jsonl"
    PATTERNS_FILE="$MEMORY_DIR/patterns.json"
    SESSION_EPISODES_FILE="$STATE_DIR/session-episodes.jsonl"
    
    # Create directories
    mkdir -p "$MEMORY_DIR" "$REPORTS_DIR" "$DRAFTS_DIR" "$STATE_DIR" "$REPORTS_DIR/sessions"
    
    # Initialize patterns file if needed
    [[ -f "$PATTERNS_FILE" ]] || echo '{"patterns": [], "updated": ""}' > "$PATTERNS_FILE"
    
    # Session management
    SESSION_FILE="$STATE_DIR/session.env"
    if [[ -f "$SESSION_FILE" ]]; then
        # shellcheck disable=SC1090
        source "$SESSION_FILE"
    fi
    
    if [[ -z "${EVOLUTION_SESSION_ID:-}" ]]; then
        local seed="${CLAUDE_SESSION_ID:-${CODEX_SESSION_ID:-}}"
        if [[ -z "$seed" ]]; then
            seed="$(date +%Y%m%d%H%M%S)-$$"
        fi
        EVOLUTION_SESSION_ID="$seed"
        echo "EVOLUTION_SESSION_ID=$EVOLUTION_SESSION_ID" > "$SESSION_FILE"
    fi
    
    export MEMORY_DIR REPORTS_DIR DRAFTS_DIR STATE_DIR
    export EPISODES_FILE PATTERNS_FILE SESSION_EPISODES_FILE
    export EVOLUTION_SESSION_ID
}

# ============================================================================
# JSON Utilities
# ============================================================================

evo_json_escape() {
    local input="$1"
    if command -v python3 &>/dev/null; then
        printf '%s' "$input" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read())[1:-1], end="")'
    else
        # Fallback: basic escaping
        printf '%s' "$input" | sed 's/\\/\\\\/g; s/"/\\"/g' | tr '\n' ' '
    fi
}

# ============================================================================
# Event Logging
# ============================================================================

evo_log_event() {
    local type="$1"
    local tool="${2:-}"
    local skill="${3:-}"
    local category="${4:-}"
    local status="${5:-ok}"
    local detail="${6:-}"
    
    local ts
    ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    
    local event
    event=$(printf '{"ts":"%s","session":"%s","type":"%s","tool":"%s","skill":"%s","category":"%s","status":"%s","detail":"%s"}' \
        "$ts" \
        "$(evo_json_escape "$EVOLUTION_SESSION_ID")" \
        "$(evo_json_escape "$type")" \
        "$(evo_json_escape "$tool")" \
        "$(evo_json_escape "$skill")" \
        "$(evo_json_escape "$category")" \
        "$(evo_json_escape "$status")" \
        "$(evo_json_escape "$detail")")
    
    # Append to global episodes
    echo "$event" >> "$EPISODES_FILE"
    
    # Append to session episodes
    echo "$event" >> "$SESSION_EPISODES_FILE"
}

# ============================================================================
# Skill Tracking
# ============================================================================

evo_record_skill_usage() {
    local file_path="$1"
    local relative="${file_path#$SKILLS_DIR/}"
    local category="${relative%%/*}"
    local ts
    ts="$(date +%s)"
    
    # Track in session
    local used_file="$STATE_DIR/skills-used.log"
    echo "$relative" >> "$used_file"
    
    # Remember last skill for attribution
    cat > "$STATE_DIR/last-skill.env" <<EOF
LAST_SKILL_PATH=$relative
LAST_SKILL_CATEGORY=$category
LAST_SKILL_TS=$ts
EOF
}

evo_last_skill() {
    local last_file="$STATE_DIR/last-skill.env"
    if [[ -f "$last_file" ]]; then
        # shellcheck disable=SC1090
        source "$last_file"
        
        # Check TTL
        local ttl
        ttl="$(evo_config_get skill_context_ttl_seconds 900)"
        local now
        now="$(date +%s)"
        
        if [[ -n "${LAST_SKILL_TS:-}" ]] && (( now - LAST_SKILL_TS <= ttl )); then
            echo "${LAST_SKILL_PATH:-}"
        fi
    fi
}

# ============================================================================
# Command Tracking
# ============================================================================

evo_record_command() {
    local cmd="$1"
    local ts
    ts="$(date +%s)"
    
    cat > "$STATE_DIR/last-command.env" <<EOF
LAST_COMMAND=$(printf '%q' "$cmd")
LAST_COMMAND_TS=$ts
EOF
}

evo_last_command() {
    local last_file="$STATE_DIR/last-command.env"
    if [[ -f "$last_file" ]]; then
        # shellcheck disable=SC1090
        source "$last_file"
        echo "${LAST_COMMAND:-}"
    fi
}

# ============================================================================
# Pattern Matching
# ============================================================================

evo_matches_pattern() {
    local value="$1"
    local pattern="$2"
    
    [[ -z "$pattern" ]] && return 1
    echo "$value" | grep -Eiq "$pattern"
}

evo_should_ignore_error() {
    local exit_code="$1"
    local command="$2"
    local output="$3"
    
    local ignore_codes ignore_cmd_patterns ignore_out_patterns force_patterns
    ignore_codes="$(evo_config_get ignore_exit_codes '')"
    ignore_cmd_patterns="$(evo_config_get ignore_command_patterns '')"
    ignore_out_patterns="$(evo_config_get ignore_output_patterns '')"
    force_patterns="$(evo_config_get force_output_patterns 'error|fatal|panic|traceback|exception')"
    
    # If output matches force patterns, don't ignore
    if evo_matches_pattern "$output" "$force_patterns"; then
        return 1
    fi
    
    # Check if exit code is in ignore list
    if [[ -n "$ignore_codes" ]]; then
        local IFS=','
        for code in $ignore_codes; do
            code="$(echo "$code" | tr -d '[:space:][]')"
            if [[ "$exit_code" == "$code" ]]; then
                # Also check command pattern
                if [[ -z "$ignore_cmd_patterns" ]] || evo_matches_pattern "$command" "$ignore_cmd_patterns"; then
                    # And output pattern
                    if [[ -z "$output" ]] || [[ -z "$ignore_out_patterns" ]] || evo_matches_pattern "$output" "$ignore_out_patterns"; then
                        return 0
                    fi
                fi
            fi
        done
    fi
    
    return 1
}

# ============================================================================
# Input Parsing
# ============================================================================

evo_extract_path() {
    local input="$1"
    local path=""
    
    # Try JSON fields
    for field in path file_path filename; do
        path="$(echo "$input" | sed -nE "s/.*\"$field\"[[:space:]]*:[[:space:]]*\"([^\"]+)\".*/\\1/p" | head -n 1)"
        [[ -n "$path" ]] && break
    done
    
    # If input itself is a path
    if [[ -z "$path" && -e "$input" ]]; then
        path="$input"
    fi
    
    # Make absolute if relative
    if [[ -n "$path" && "${path:0:1}" != "/" ]]; then
        path="$PWD/$path"
    fi
    
    echo "$path"
}

evo_extract_command() {
    local input="$1"
    sed -nE 's/.*"command"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/p' <<< "$input" | head -n 1
}

# ============================================================================
# Draft Management
# ============================================================================

evo_create_draft() {
    local type="$1"      # error | insight | pattern
    local title="$2"
    local content="$3"
    local skill="${4:-unknown}"
    
    local author source date_str stamp filename
    author="$(evo_config_get author 'auto-evolution')"
    source="$(evo_config_get source 'unknown')"
    date_str="$(date +%Y-%m-%d)"
    stamp="$(date +%Y%m%d-%H%M%S)"
    
    filename="$DRAFTS_DIR/${stamp}-${type}.md"
    
    cat > "$filename" <<EOF
---
name: auto-${type}-${stamp}
author: ${author}
source: ${source}
date: ${date_str}
type: ${type}
skill_context: ${skill}
status: pending
tags: [auto-draft, ${type}]
---

# ${title}

${content}

---
*Auto-generated by Evolution System*
EOF
    
    evo_log_event "draft_created" "system" "$skill" "" "ok" "$filename"
    echo "$filename"
}

# ============================================================================
# Cleanup
# ============================================================================

evo_cleanup_session() {
    rm -f "$STATE_DIR/session.env" \
          "$STATE_DIR/skills-used.log" \
          "$STATE_DIR/last-skill.env" \
          "$STATE_DIR/last-command.env" \
          "$STATE_DIR/session-episodes.jsonl"
}
