# Memory System

This directory implements the three-layer memory architecture for Auto-Evolution.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    THREE-LAYER MEMORY                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ EPISODIC MEMORY                                          │    │
│  │ ─────────────────                                        │    │
│  │ • Raw events from tool usage                             │    │
│  │ • Append-only JSONL format                               │    │
│  │ • TTL: 7 days (configurable)                             │    │
│  │ • File: episodes.jsonl                                   │    │
│  └─────────────────────────────────────────────────────────┘    │
│                          │                                       │
│                          ▼ (abstraction)                         │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ SEMANTIC MEMORY                                          │    │
│  │ ─────────────────                                        │    │
│  │ • Patterns extracted from episodes                       │    │
│  │ • Structured JSON format                                 │    │
│  │ • TTL: 30 days (configurable)                            │    │
│  │ • File: patterns.json                                    │    │
│  └─────────────────────────────────────────────────────────┘    │
│                          │                                       │
│                          ▼ (validation)                          │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ PROCEDURAL MEMORY                                        │    │
│  │ ─────────────────                                        │    │
│  │ • Validated how-to knowledge                             │    │
│  │ • Markdown skill drafts                                  │    │
│  │ • TTL: Permanent                                         │    │
│  │ • Directory: drafts/                                     │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## File Structure

```
memory/
├── episodes.jsonl      # Episodic memory (raw events)
├── patterns.json       # Semantic memory (patterns)
├── drafts/             # Procedural memory (skill drafts)
│   └── *.md
├── .state/             # Session state (temporary)
│   ├── session.env
│   ├── skills-used.log
│   ├── last-skill.env
│   ├── last-command.env
│   └── session-episodes.jsonl
└── README.md           # This file
```

## Data Formats

### Episode Record (JSONL)

```json
{
  "ts": "2024-01-15T14:32:00Z",
  "session": "20240115143200-12345",
  "type": "skill_used|skill_updated|command_started|command_succeeded|command_failed|draft_created",
  "tool": "Read|Write|Edit|Bash|system",
  "skill": "01-core/layout.md",
  "category": "01-core",
  "status": "ok|fail|ignored|mutated",
  "detail": "additional context"
}
```

### Pattern Record (JSON)

```json
{
  "id": "pattern-20240115-001",
  "name": "Descriptive Pattern Name",
  "type": "error_resolution|workflow|optimization",
  "occurrences": 3,
  "first_seen": "2024-01-10T10:00:00Z",
  "last_seen": "2024-01-15T14:32:00Z",
  "episodes": ["ep-001", "ep-003", "ep-007"],
  "signature": {
    "description": "Human-readable description",
    "matcher": "regex or keywords"
  },
  "status": "detected|pending|approved|archived",
  "draft_path": "drafts/pattern-name.md"
}
```

## Memory Lifecycle

### Episodic → Semantic (Abstraction)

When similar episodes occur 3+ times:

1. Group by similarity (skill, error signature, command pattern)
2. Extract common elements
3. Generate pattern hypothesis
4. Store in `patterns.json`

### Semantic → Procedural (Validation)

When a pattern is validated:

1. Pattern used successfully in multiple contexts
2. Human review confirms usefulness
3. Generate skill draft from template
4. Store in `drafts/`

### Procedural → Community (Promotion)

When a draft is promoted:

1. Draft reviewed and refined
2. Moved to `community/` directory
3. Available for all users
4. May eventually reach `_base/`

## Cleanup

Automatic cleanup based on TTL:

- Episodes older than 7 days: Archived
- Patterns unused for 30 days: Archived
- Drafts: Never auto-deleted

Manual cleanup:

```bash
# Remove old episodes
find memory/ -name "*.jsonl" -mtime +7 -exec rm {} \;

# Archive unused patterns
# (done automatically by reflect.sh)
```

## Privacy

All data stays local:
- No network calls
- No external dependencies
- Full user control over deletion
