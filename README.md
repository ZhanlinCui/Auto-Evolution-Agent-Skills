<p align="center">
  <img src="docs/logo.svg" alt="Auto-Evolution" width="120" />
</p>

<h1 align="center">Auto-Evolution</h1>

<p align="center">
  <strong>Memory-Driven Self-Evolution for AI Agent Skills</strong>
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License: MIT"></a>
  <a href="#"><img src="https://img.shields.io/badge/Version-2.0.0-blue.svg" alt="Version"></a>
  <a href="#"><img src="https://img.shields.io/badge/Claude_Code-Compatible-8A2BE2.svg" alt="Claude Code"></a>
  <a href="#"><img src="https://img.shields.io/badge/PRs-Welcome-brightgreen.svg" alt="PRs Welcome"></a>
</p>

<p align="center">
  <a href="README.md">English</a> •
  <a href="README.zh.md">中文</a>
</p>

---

## 💡 The Story

> *"I've fixed this exact error three times this week. Why doesn't my AI assistant remember?"*

Every developer has been there. You spend 30 minutes debugging an issue, finally fix it, and move on. Two days later, you hit the same problem — and your AI assistant has completely forgotten how you solved it.

**Your AI is smart, but it has no memory.**

Auto-Evolution changes that. It gives your AI agent a persistent memory that learns from every interaction, detects patterns in your work, and evolves into a smarter assistant over time.

```
Week 1:  You fix TypeError #1 → Agent forgets
Week 2:  You fix TypeError #2 → Agent forgets  
Week 3:  You fix TypeError #3 → Agent forgets

With Auto-Evolution:
Week 1:  You fix TypeError #1 → Agent remembers
Week 2:  You fix TypeError #2 → Agent notices pattern
Week 3:  TypeError #3 → Agent: "I've seen this before. Here's the fix."
```

---

## 🎯 Problems We Solve

| Problem | Without Auto-Evolution | With Auto-Evolution |
|---------|----------------------|---------------------|
| **Repeated errors** | Fix the same bug multiple times | Agent learns from first fix |
| **Lost knowledge** | Solutions disappear after session | Patterns persist across sessions |
| **No personalization** | Generic responses every time | Agent adapts to your workflow |
| **Manual documentation** | You document everything yourself | Auto-generated skill drafts |
| **Blind spots** | No visibility into what works | Dashboard shows what's effective |

---

## ✨ Key Features

<table>
<tr>
<td width="50%">

### 🧠 Three-Layer Memory
Inspired by human cognition:
- **Episodic**: Raw events (7 days)
- **Semantic**: Patterns (30 days)  
- **Procedural**: Skills (permanent)

</td>
<td width="50%">

### ⚡ Pattern Detection
Automatically identifies:
- Repeated workflows
- Common error solutions
- Frequently used techniques

</td>
</tr>
<tr>
<td width="50%">

### 📊 Visual Dashboard
Real-time visualization of:
- Skill usage heatmap
- Detected patterns
- Evolution progress

</td>
<td width="50%">

### 🔄 Quality Gates
Only validated knowledge gets promoted:
- 3+ occurrences → detected
- Validation → approved
- Usage → permanent skill

</td>
</tr>
</table>

---

## 📊 Visual Dashboard

See your agent's evolution in real-time:

<p align="center">
  <img src="docs/dashboard-preview.png" alt="Dashboard Preview" width="800" />
</p>

---

## 🚀 Quick Start

### Step 1: Install (30 seconds)

```bash
curl -fsSL https://raw.githubusercontent.com/ZhanlinCui/Auto-Evolution-Agent-Skills/main/install.sh | bash -s -- --with-hooks
```

<details>
<summary>📦 Alternative: Manual Installation</summary>

```bash
# Clone repository
git clone https://github.com/ZhanlinCui/Auto-Evolution-Agent-Skills.git

# Copy to your project
cp -r Auto-Evolution-Agent-Skills/skills/evolution your-project/.claude/skills/

# Make hooks executable
chmod +x your-project/.claude/skills/evolution/hooks/*.sh
```

</details>

### Step 2: Configure Hooks

Add to your `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Read|Write|Edit|Bash",
        "hooks": [{"type": "command", "command": "bash .claude/skills/evolution/hooks/capture.sh \"$TOOL_NAME\" \"$TOOL_INPUT\""}]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{"type": "command", "command": "bash .claude/skills/evolution/hooks/capture.sh post-bash \"$TOOL_OUTPUT\" \"$EXIT_CODE\""}]
      }
    ],
    "Stop": [
      {
        "matcher": "",
        "hooks": [{"type": "command", "command": "bash .claude/skills/evolution/hooks/reflect.sh"}]
      }
    ]
  }
}
```

### Step 3: Work Normally

That's it! Just use Claude Code as you always do. Auto-Evolution works silently in the background.

### Step 4: Watch It Evolve

```bash
# Open the dashboard
open .claude/skills/evolution/reports/dashboard.html
```

---

## 📖 Usage Guide

### Automatic Mode (Default)

Once installed, everything happens automatically:

| What Happens | When | Result |
|--------------|------|--------|
| Skill usage tracked | You read any `.md` skill file | Recorded in episodic memory |
| Errors captured | Bash command fails | Error + context saved |
| Patterns detected | Same action 3+ times | Pattern hypothesis created |
| Insights generated | Session ends | Draft + suggestions created |

### Manual Commands

| Command | What It Does | Example |
|---------|--------------|---------|
| `/retrospective` | Generate session review | "What did I learn today?" |
| `/evolve` | Promote pattern to skill | "Save this fix as a skill" |
| `/dashboard` | Open visual dashboard | "Show my evolution" |

### Example Session

```
You: Fix this TypeScript error: "Object is possibly undefined"

Agent: [fixes with optional chaining]

--- After 3 similar fixes ---

Agent: 💡 I noticed you've fixed "possibly undefined" errors 3 times 
       using optional chaining. Want me to save this as a reusable pattern?

You: Yes, create a skill for it

Agent: ✅ Created: community/typescript-optional-chaining.md
       Next time, I'll suggest this pattern immediately.
```

---

## 🧠 How It Works

### The Evolution Loop

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                  │
│    📝 CAPTURE           🔍 ANALYZE           🚀 EVOLVE          │
│    ───────────          ──────────           ─────────          │
│    Tool usage     →     Find patterns   →    Create skills      │
│    Errors         →     Detect repeats  →    Promote drafts     │
│    Commands       →     Score success   →    Retire failures    │
│                                                                  │
│                         🧠 MEMORY                                │
│                         ─────────                                │
│                    Episodic → Semantic → Procedural              │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Three-Layer Memory

| Layer | What It Stores | Retention | Example |
|-------|---------------|-----------|---------|
| **Episodic** | Raw events | 7 days | "Used layout.md at 14:32" |
| **Semantic** | Patterns | 30 days | "Grid layouts need Flow + Sizing" |
| **Procedural** | Skills | Permanent | `responsive-grid-pattern.md` |

### Quality Gates

Knowledge must prove itself before becoming permanent:

```
[Detected]  ──3+ occurrences──▶  [Draft]  ──validated──▶  [Approved]  ──used──▶  [Skill]
     │                              │                          │                    │
   Pattern                    Auto-generated              Human/AI               Permanent
   noticed                    documentation               verified               knowledge
```

---

## ⚙️ Configuration

All settings in `evolution/config.json`:

```json
{
  "memory": {
    "episodic_ttl_days": 7,      // How long to keep raw events
    "semantic_ttl_days": 30,     // How long to keep patterns
    "pattern_threshold": 3       // Occurrences needed to detect pattern
  },
  "evolution": {
    "auto_draft_on_error": true,        // Create draft when errors occur
    "auto_pattern_detection": true,     // Automatically detect patterns
    "require_validation": true          // Require validation before promotion
  }
}
```

---

## 📁 Project Structure

```
.claude/skills/evolution/
│
├── 📄 SKILL.md                 # Entry point & documentation
├── ⚙️ config.json              # All configuration
│
├── 🧠 memory/                  # Three-layer memory system
│   ├── episodes.jsonl          # Layer 1: Raw events
│   ├── patterns.json           # Layer 2: Detected patterns
│   └── drafts/                 # Layer 3: Skill candidates
│
├── 🪝 hooks/                   # Event capture system
│   ├── capture.sh              # Pre/post tool hooks
│   ├── reflect.sh              # Session-end analysis
│   └── lib.sh                  # Shared utilities
│
├── 📊 reports/                 # Visualization & reports
│   ├── dashboard.html          # Visual dashboard
│   ├── improvements.md         # Suggestions
│   └── sessions/               # Session reports
│
├── 📝 templates/               # Skill templates
│   ├── skill.md                # General skill template
│   └── error.md                # Error solution template
│
└── 🌍 community/               # Your contributed skills
    └── README.md               # Contribution guide
```

---

## 🤝 Contributing

### Share Your Patterns

Discovered a useful pattern? Share it with the community:

1. Create `community/{your-handle}-{pattern-name}.md`
2. Use templates from `templates/`
3. Submit a PR

### Quality Checklist

- ✅ Solves a real, repeatable problem
- ✅ Includes trigger scenarios ("Use when...")
- ✅ Has tested, concrete examples
- ✅ No project-specific hardcoded values

---

## 🗺️ Roadmap

- [x] **v2.0** — Three-layer memory system
- [x] **v2.0** — Visual dashboard
- [x] **v2.0** — Pattern detection
- [ ] **v2.1** — Cross-project knowledge sync
- [ ] **v2.2** — LLM-as-judge validation
- [ ] **v2.3** — Community knowledge federation

---

## ❓ FAQ

<details>
<summary><strong>Does it work with other AI assistants?</strong></summary>

Currently optimized for Claude Code, but the architecture is designed to be portable. Contributions for other platforms welcome!

</details>

<details>
<summary><strong>Where is data stored?</strong></summary>

All data stays local in your project's `.claude/skills/evolution/memory/` directory. No data is sent externally.

</details>

<details>
<summary><strong>How much overhead does it add?</strong></summary>

Minimal. Hooks are shell scripts that append to JSONL files. Pattern detection only runs at session end.

</details>

<details>
<summary><strong>Can I disable it temporarily?</strong></summary>

Yes, just remove the hooks from `.claude/settings.json`. Your memory data is preserved.

</details>

---

## 📄 License

MIT License — see [LICENSE](LICENSE) for details.

---

<p align="center">
  <strong>Stop re-solving. Start evolving.</strong>
</p>

<p align="center">
  <a href="https://github.com/ZhanlinCui/Auto-Evolution-Agent-Skills">⭐ Star</a> •
  <a href="https://github.com/ZhanlinCui/Auto-Evolution-Agent-Skills/issues">Issues</a> •
  <a href="https://github.com/ZhanlinCui/Auto-Evolution-Agent-Skills/pulls">PRs</a>
</p>
