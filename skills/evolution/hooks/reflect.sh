#!/bin/bash
# Auto-Evolution Reflect Hook
# Runs at session end to analyze patterns and generate insights

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib.sh"

evo_init_state

# ============================================================================
# Main
# ============================================================================

main() {
    echo "[evolution] Generating session reflection..."
    
    generate_session_insight
    detect_patterns
    generate_session_report
    generate_suggestions
    
    echo "[evolution] Session report: $REPORTS_DIR/sessions/session-$EVOLUTION_SESSION_ID.md"
    echo "[evolution] Dashboard: $REPORTS_DIR/dashboard.html"
    
    evo_cleanup_session
}

# ============================================================================
# Session Insight Draft
# ============================================================================

generate_session_insight() {
    local auto_draft
    auto_draft="$(evo_config_get auto_draft_on_session_end true)"
    
    local used_file="$STATE_DIR/skills-used.log"
    
    if [[ "$auto_draft" != "true" ]] || [[ ! -s "$used_file" ]]; then
        return 0
    fi
    
    local skills_list
    skills_list="$(sort -u "$used_file" | sed 's/^/- /')"
    
    local content
    content=$(cat <<EOF
## Skills Used This Session

${skills_list}

## Insights

- **What worked well**: TODO
- **What could be improved**: TODO
- **Patterns noticed**: TODO

## Action Items

- [ ] Review and promote useful patterns
- [ ] Update skills that caused confusion
- [ ] Document any new discoveries

EOF
)
    
    local draft_file
    draft_file="$(evo_create_draft "insight" "Session Insight $(date +%Y-%m-%d)" "$content" "session")"
    echo "[evolution] Insight draft: $draft_file"
}

# ============================================================================
# Pattern Detection
# ============================================================================

detect_patterns() {
    local auto_detect
    auto_detect="$(evo_config_get auto_pattern_detection true)"
    
    if [[ "$auto_detect" != "true" ]]; then
        return 0
    fi
    
    local min_occurrences
    min_occurrences="$(evo_config_get min_occurrences_for_pattern 3)"
    
    # Check for repeated skill usage
    local used_file="$STATE_DIR/skills-used.log"
    if [[ -s "$used_file" ]]; then
        # Find skills used 3+ times
        local high_use
        high_use="$(sort "$used_file" | uniq -c | awk -v min="$min_occurrences" '$1 >= min {print $2 " (" $1 ")"}')"
        
        if [[ -n "$high_use" ]]; then
            echo "[evolution] High-use patterns detected:"
            echo "$high_use" | sed 's/^/  - /'
        fi
    fi
    
    # Check for repeated errors
    if [[ -s "$SESSION_EPISODES_FILE" ]]; then
        local error_patterns
        error_patterns="$(grep '"type":"command_failed"' "$SESSION_EPISODES_FILE" 2>/dev/null | \
            sed -nE 's/.*"detail":"([^"]{0,50}).*/\1/p' | \
            sort | uniq -c | sort -rn | head -3)"
        
        if [[ -n "$error_patterns" ]]; then
            echo "[evolution] Repeated error patterns:"
            echo "$error_patterns" | sed 's/^/  /'
        fi
    fi
}

# ============================================================================
# Session Report
# ============================================================================

generate_session_report() {
    local report_file="$REPORTS_DIR/sessions/session-$EVOLUTION_SESSION_ID.md"
    local used_file="$STATE_DIR/skills-used.log"
    
    {
        echo "# Session Report"
        echo ""
        echo "- **Session ID**: $EVOLUTION_SESSION_ID"
        echo "- **Generated**: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
        echo ""
        
        echo "## Skills Used"
        echo ""
        if [[ -s "$used_file" ]]; then
            sort "$used_file" | uniq -c | sort -rn | awk '{print "- " $2 " (" $1 " times)"}'
        else
            echo "- None"
        fi
        echo ""
        
        echo "## Events Summary"
        echo ""
        if [[ -s "$SESSION_EPISODES_FILE" ]]; then
            local total started succeeded failed
            total="$(wc -l < "$SESSION_EPISODES_FILE" | tr -d ' ')"
            started="$(grep -c '"type":"command_started"' "$SESSION_EPISODES_FILE" 2>/dev/null || echo 0)"
            succeeded="$(grep -c '"type":"command_succeeded"' "$SESSION_EPISODES_FILE" 2>/dev/null || echo 0)"
            failed="$(grep -c '"status":"fail"' "$SESSION_EPISODES_FILE" 2>/dev/null || echo 0)"
            
            echo "- Total events: $total"
            echo "- Commands started: $started"
            echo "- Commands succeeded: $succeeded"
            echo "- Failures: $failed"
        else
            echo "- No events recorded"
        fi
        echo ""
        
        echo "## Drafts Created"
        echo ""
        if ls "$DRAFTS_DIR"/*.md &>/dev/null; then
            ls -1 "$DRAFTS_DIR"/*.md 2>/dev/null | while read -r f; do
                echo "- $(basename "$f")"
            done
        else
            echo "- None"
        fi
        
    } > "$report_file"
    
    evo_log_event "report_generated" "system" "session" "report" "ok" "$report_file"
}

# ============================================================================
# Improvement Suggestions
# ============================================================================

generate_suggestions() {
    local suggestions_file="$REPORTS_DIR/improvements.md"
    local used_file="$STATE_DIR/skills-used.log"
    
    # Analyze session data
    local fail_skills="" unattributed_fails=0 high_use_skills="" drafts_list=""
    
    if [[ -s "$SESSION_EPISODES_FILE" ]]; then
        # Skills with failures
        fail_skills="$(grep '"status":"fail"' "$SESSION_EPISODES_FILE" 2>/dev/null | \
            sed -nE 's/.*"skill":"([^"]+)".*/\1/p' | \
            grep -v '^unknown$' | sort -u)"
        
        # Unattributed failures
        unattributed_fails="$(grep '"status":"fail"' "$SESSION_EPISODES_FILE" 2>/dev/null | \
            grep '"skill":"unknown"' | wc -l | tr -d ' ')"
        
        # Drafts created
        drafts_list="$(grep '"type":"draft_created"' "$SESSION_EPISODES_FILE" 2>/dev/null | \
            sed -nE 's/.*"detail":"([^"]+)".*/\1/p')"
    fi
    
    # High-use skills
    local threshold
    threshold="$(evo_config_get high_use_threshold 3)"
    if [[ -s "$used_file" ]]; then
        high_use_skills="$(sort "$used_file" | uniq -c | awk -v t="$threshold" '$1 >= t {print $2 " (" $1 ")"}')"
    fi
    
    # Generate report
    {
        echo "# Improvement Suggestions"
        echo ""
        echo "- **Session**: $EVOLUTION_SESSION_ID"
        echo "- **Generated**: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
        echo ""
        
        echo "## Evidence"
        echo ""
        
        echo "### Skill Usage"
        if [[ -s "$used_file" ]]; then
            sort "$used_file" | uniq -c | sort -rn | awk '{print "- " $2 " (" $1 ")"}'
        else
            echo "- None recorded"
        fi
        echo ""
        
        echo "### Failures Linked to Skills"
        if [[ -n "$fail_skills" ]]; then
            echo "$fail_skills" | sed 's/^/- /'
        else
            echo "- None"
        fi
        echo ""
        
        echo "### Unattributed Failures"
        echo "- Count: $unattributed_fails"
        echo ""
        
        echo "### Drafts Created"
        if [[ -n "$drafts_list" ]]; then
            echo "$drafts_list" | sed 's/^/- /'
        else
            echo "- None"
        fi
        echo ""
        
        echo "## Suggestions"
        echo ""
        
        if [[ -n "$fail_skills" ]]; then
            echo "- ⚠️ **Review failed skills**: Add corrections or troubleshooting entries"
        fi
        
        if [[ -n "$drafts_list" ]]; then
            echo "- 📝 **Promote drafts**: Review and move to proper skill templates"
        fi
        
        if [[ -n "$high_use_skills" ]]; then
            echo "- 📊 **High-use skills** (consider optimization):"
            echo "$high_use_skills" | sed 's/^/  - /'
        fi
        
        if (( unattributed_fails > 0 )); then
            echo "- 🔍 **Improve attribution**: Capture relevant skills before commands"
        fi
        
        if [[ -z "$fail_skills" && -z "$drafts_list" && -z "$high_use_skills" ]]; then
            echo "- ✅ No obvious improvements needed this session"
        fi
        
    } > "$suggestions_file"
    
    evo_log_event "report_generated" "system" "session" "suggestions" "ok" "$suggestions_file"
}

# ============================================================================
# Run
# ============================================================================

main "$@"
