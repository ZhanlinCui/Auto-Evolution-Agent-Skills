# Auto-Evolution Architecture

This document describes the internal architecture of the Auto-Evolution system.

## Design Philosophy

1. **Evidence-Driven**: All learning is based on observed behavior, not speculation
2. **Low Overhead**: Shell-only capture, minimal runtime impact
3. **Human-in-the-Loop**: Suggestions require validation before promotion
4. **Progressive Enhancement**: Works with any skills library

## System Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         AUTO-EVOLUTION SYSTEM                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐   │
│  │   CAPTURE   │───▶│   MEMORY    │───▶│   ANALYZE   │───▶│   EVOLVE    │   │
│  │    Layer    │    │    Layer    │    │    Layer    │    │    Layer    │   │
│  └─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘   │
│        │                  │                  │                  │           │
│        ▼                  ▼                  ▼                  ▼           │
│   ┌─────────┐        ┌─────────┐        ┌─────────┐        ┌─────────┐      │
│   │ hooks/  │        │ memory/ │        │patterns │        │community│      │
│   │capture  │        │episodes │        │ .json   │        │ /drafts │      │
│   │reflect  │        │patterns │        │         │        │         │      │
│   └─────────┘        └─────────┘        └─────────┘        └─────────┘      │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Component Details

### 1. Capture Layer

**Files**: `hooks/capture.sh`, `hooks/lib.sh`

**Responsibilities**:
- Intercept tool invocations (Read, Write, Edit, Bash)
- Record skill usage with timestamps
- Capture command context and results
- Apply noise filters (ignore patterns, TTL)

**Event Types**:
| Type | Trigger | Data Captured |
|------|---------|---------------|
| `skill_used` | Read on skill file | path, category, timestamp |
| `skill_updated` | Write/Edit on skill | path, category, changes |
| `command_started` | Bash pre-hook | command, working directory |
| `command_succeeded` | Bash exit 0 | duration, output summary |
| `command_failed` | Bash non-zero exit | error, skill context |

### 2. Memory Layer

**Files**: `memory/episodes.jsonl`, `memory/patterns.json`

**Three-Tier Structure**:

```
┌─────────────────────────────────────────────────────┐
│              MEMORY ARCHITECTURE                     │
├─────────────────────────────────────────────────────┤
│                                                      │
│  EPISODIC (Short-term)                              │
│  ├── Raw events as they happen                      │
│  ├── TTL: 7 days                                    │
│  └── Format: JSONL (append-only)                    │
│                                                      │
│  SEMANTIC (Medium-term)                             │
│  ├── Patterns extracted from episodes              │
│  ├── TTL: 30 days                                   │
│  └── Format: JSON (structured)                      │
│                                                      │
│  PROCEDURAL (Long-term)                             │
│  ├── Validated how-to knowledge                    │
│  ├── TTL: Permanent                                 │
│  └── Format: Markdown (skill drafts)                │
│                                                      │
└─────────────────────────────────────────────────────┘
```

**Memory Lifecycle**:

```
Episode → (aggregation) → Pattern → (validation) → Skill Draft
   │                          │                          │
   └── 7 days ────────────────┴── 30 days ───────────────┴── Permanent
```

### 3. Analyze Layer

**Files**: `hooks/reflect.sh` (pattern detection logic)

**Pattern Detection Algorithm**:

```
1. Group episodes by similarity:
   - Same skill involved
   - Same error signature
   - Same command pattern

2. Count occurrences within window (30 days)

3. If count >= threshold (default: 3):
   - Extract common elements
   - Generate pattern hypothesis
   - Create draft if not duplicate
```

**Similarity Metrics**:
- Command prefix matching (first word)
- Error message substring matching
- Skill path exact match
- Time proximity (within same session)

### 4. Evolve Layer

**Files**: `templates/skill.md`, `community/`

**Evolution Pipeline**:

```
┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│ Detected │───▶│  Draft   │───▶│ Validated│───▶│ Promoted │
│          │    │          │    │          │    │          │
│ pattern  │    │ in draft/│    │ tested   │    │ official │
│ found    │    │ folder   │    │ working  │    │ skill    │
└──────────┘    └──────────┘    └──────────┘    └──────────┘
     │               │               │               │
     ▼               ▼               ▼               ▼
  3+ occur      auto-gen        2+ valid       community/
  same type     from tmpl       confirms         _base/
```

## Data Formats

### Episode Record (JSONL)

```json
{
  "ts": "2024-01-15T14:32:00Z",
  "session": "abc123",
  "type": "skill_used",
  "tool": "Read",
  "skill": "01-core/layout.md",
  "category": "01-core",
  "status": "ok",
  "detail": ""
}
```

### Pattern Record (JSON)

```json
{
  "id": "pattern-typescript-type-guard",
  "name": "TypeScript Type Guard",
  "occurrences": 5,
  "first_seen": "2024-01-10T10:00:00Z",
  "last_seen": "2024-01-15T14:32:00Z",
  "episodes": ["ep-001", "ep-003", "ep-007", "ep-012", "ep-015"],
  "signature": {
    "type": "error_resolution",
    "error_pattern": "Type .* is not assignable",
    "resolution_pattern": "type guard function"
  },
  "status": "pending_validation",
  "draft_path": "memory/drafts/typescript-type-guard.md"
}
```

## Hook Integration

### Claude Code Settings

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Read|Write|Edit|Bash",
        "hooks": [{
          "type": "command",
          "command": "bash .claude/skills/evolution/hooks/capture.sh \"$TOOL_NAME\" \"$TOOL_INPUT\""
        }]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{
          "type": "command",
          "command": "bash .claude/skills/evolution/hooks/capture.sh post-bash \"$TOOL_OUTPUT\" \"$EXIT_CODE\""
        }]
      }
    ],
    "Stop": [
      {
        "matcher": "",
        "hooks": [{
          "type": "command",
          "command": "bash .claude/skills/evolution/hooks/reflect.sh"
        }]
      }
    ]
  }
}
```

### Environment Variables

| Variable | Description |
|----------|-------------|
| `TOOL_NAME` | Name of the tool being invoked |
| `TOOL_INPUT` | JSON input to the tool |
| `TOOL_OUTPUT` | Output from Bash command |
| `EXIT_CODE` | Exit code from Bash command |
| `CLAUDE_SESSION_ID` | Current session identifier |

## Performance Considerations

1. **Append-Only Writes**: Episodes use JSONL for O(1) appends
2. **Lazy Pattern Detection**: Only runs at session end
3. **TTL-Based Cleanup**: Old episodes auto-expire
4. **No Blocking**: All hooks are fire-and-forget
5. **Shell-Only**: No external dependencies required

## Security Notes

1. **Local Storage Only**: All data stays in project directory
2. **No Network Calls**: System is fully offline
3. **User Controlled**: All promotions require confirmation
4. **Auditable**: Full event trail in JSONL format

## Extension Points

### Custom Pattern Detectors

Add detection logic in `hooks/reflect.sh`:

```bash
# Example: Custom pattern for API rate limiting
detect_rate_limit_pattern() {
  grep -l "rate limit\|429\|too many requests" "$SESSION_EVENTS"
}
```

### Custom Quality Gates

Modify `config.json` quality_gates section:

```json
{
  "quality_gates": {
    "custom_gate": {
      "script": "scripts/custom-validator.sh",
      "required": true
    }
  }
}
```

### Dashboard Customization

The dashboard (`reports/dashboard.html`) is a self-contained HTML file that reads from:
- `memory/episodes.jsonl`
- `memory/patterns.json`
- `config.json`

Modify the embedded JavaScript to add custom visualizations.
