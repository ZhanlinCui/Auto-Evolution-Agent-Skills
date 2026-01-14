#!/bin/bash
# Auto-Evolution Capture Hook
# Captures skill usage, command execution, and errors

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib.sh"

evo_init_state

# ============================================================================
# Main Logic
# ============================================================================

main() {
    local mode="${1:-}"
    
    case "$mode" in
        post-bash)
            handle_post_bash "$2" "$3"
            ;;
        *)
            handle_pre_tool "$1" "$2"
            ;;
    esac
}

# ============================================================================
# Pre-Tool Handler
# ============================================================================

handle_pre_tool() {
    local tool_name="${1:-}"
    local tool_input="${2:-}"
    
    case "$tool_name" in
        Bash)
            local cmd
            cmd="$(evo_extract_command "$tool_input")"
            if [[ -n "$cmd" ]]; then
                evo_record_command "$cmd"
                evo_log_event "command_started" "bash" "" "" "ok" "$cmd"
            fi
            ;;
        Read|Write|Edit)
            local file_path
            file_path="$(evo_extract_path "$tool_input")"
            
            if [[ -z "$file_path" ]]; then
                return 0
            fi
            
            # Check if it's a skill file
            case "$file_path" in
                "$SKILLS_DIR"/*.md)
                    # Skip evolution internal files
                    case "$file_path" in
                        "$EVOLUTION_DIR/memory/"*|"$EVOLUTION_DIR/reports/"*|"$EVOLUTION_DIR/.state/"*)
                            return 0
                            ;;
                    esac
                    
                    evo_record_skill_usage "$file_path"
                    
                    local relative="${file_path#$SKILLS_DIR/}"
                    local category="${relative%%/*}"
                    local event_type="skill_used"
                    local status="ok"
                    
                    if [[ "$tool_name" == "Write" || "$tool_name" == "Edit" ]]; then
                        event_type="skill_updated"
                        status="mutated"
                    fi
                    
                    evo_log_event "$event_type" "$tool_name" "$relative" "$category" "$status" ""
                    ;;
            esac
            ;;
    esac
}

# ============================================================================
# Post-Bash Handler
# ============================================================================

handle_post_bash() {
    local tool_output="${1:-}"
    local exit_code="${2:-0}"
    
    # Success case
    if [[ "$exit_code" == "0" ]]; then
        local cmd
        cmd="$(evo_last_command)"
        evo_log_event "command_succeeded" "bash" "" "" "ok" "$cmd"
        return 0
    fi
    
    # Check if we should ignore this error
    local cmd
    cmd="$(evo_last_command)"
    
    if evo_should_ignore_error "$exit_code" "$cmd" "$tool_output"; then
        evo_log_event "command_failed" "bash" "" "" "ignored" "$cmd"
        return 0
    fi
    
    # Get context
    local last_skill last_category
    last_skill="$(evo_last_skill)"
    if [[ -n "$last_skill" ]]; then
        last_category="${last_skill%%/*}"
    fi
    
    # Extract error signature
    local force_patterns error_line
    force_patterns="$(evo_config_get force_output_patterns 'error|fatal|panic|traceback|exception')"
    error_line="$(echo "$tool_output" | grep -m 1 -Ei "$force_patterns" || echo "$tool_output" | head -n 1)"
    
    # Log the failure
    evo_log_event "command_failed" "bash" "${last_skill:-unknown}" "${last_category:-general}" "fail" "$error_line"
    
    # Check if auto-draft is enabled
    local auto_draft
    auto_draft="$(evo_config_get auto_draft_on_error true)"
    
    if [[ "$auto_draft" == "true" ]]; then
        # Truncate output
        local max_lines output_snippet
        max_lines="$(evo_config_get max_output_lines 200)"
        output_snippet="$(echo "$tool_output" | tail -n "$max_lines")"
        [[ -z "$output_snippet" ]] && output_snippet="(no output captured)"
        
        local content
        content=$(cat <<EOF
## Command

\`\`\`bash
${cmd:-unknown}
\`\`\`

Exit code: ${exit_code}

## Output

\`\`\`
${output_snippet}
\`\`\`

## Context

- Last skill used: ${last_skill:-none}
- Category: ${last_category:-general}

## Analysis

- **Symptom**: TODO - describe what happened
- **Cause**: TODO - explain why
- **Fix**: TODO - how to resolve

EOF
)
        
        local draft_file
        draft_file="$(evo_create_draft "error" "Error: ${error_line:0:60}" "$content" "${last_skill:-unknown}")"
        echo "[evolution] Draft captured: $draft_file"
    fi
}

# ============================================================================
# Run
# ============================================================================

main "$@"
