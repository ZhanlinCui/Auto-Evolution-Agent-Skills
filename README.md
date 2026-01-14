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

## The Problem

Every day, you solve the same problems. You fix the same errors. You rediscover the same patterns.

**Your AI assistant forgets everything between sessions.**

## The Solution

Auto-Evolution gives your AI agent a **memory** that persists, learns, and evolves.

```
Before:  You → Agent → Output → (forgotten)
After:   You → Agent → Output → Memory → Learning → Evolution
```

---

## ✨ Key Features

| | Feature | Description |
|---|---------|-------------|
| 🧠 | **Three-Layer Memory** | Episodic → Semantic → Procedural knowledge, inspired by human cognition |
| ⚡ | **Pattern Detection** | Automatically identifies workflows and solutions that repeat |
| 📊 | **Visual Dashboard** | Real-time visualization of your agent's learning progress |
| 🔄 | **Reflexion Loop** | Learn from both successes and failures |
| 🎯 | **Quality Gates** | Only validated knowledge gets promoted |
| 🌍 | **Community Sharing** | Share and reuse patterns across projects |

---

## 🚀 Quick Start

### One Command Install

```bash
curl -fsSL https://raw.githubusercontent.com/ZhanlinCui/Auto-Evolution-Agent-Skills/main/install.sh | bash -s -- --with-hooks
```

### What Happens Next

1. **Work normally** — Auto-Evolution captures silently in the background
2. **Patterns emerge** — System detects repeated workflows and solutions
3. **Knowledge evolves** — Validated patterns become reusable skills
4. **Agent improves** — Your assistant gets smarter over time

---

## 🧠 Three-Layer Memory

Inspired by cognitive science, Auto-Evolution implements a hierarchical memory system:

```
┌────────────────────────────────────────────────────────────────┐
│  EPISODIC                                    TTL: 7 days       │
│  Raw events: "Used layout.md" "Fixed error X"                  │
└────────────────────────────────────────────────────────────────┘
                              ↓ abstraction
┌────────────────────────────────────────────────────────────────┐
│  SEMANTIC                                    TTL: 30 days      │
│  Patterns: "TypeScript errors follow pattern X"                │
└────────────────────────────────────────────────────────────────┘
                              ↓ validation
┌────────────────────────────────────────────────────────────────┐
│  PROCEDURAL                                  Permanent         │
│  Skills: Ready-to-use knowledge for future sessions            │
└────────────────────────────────────────────────────────────────┘
```

---

## 📊 Visual Dashboard

See your agent's evolution in real-time:

<p align="center">
  <img src="docs/dashboard-preview.png" alt="Dashboard Preview" width="800" />
</p>

- 📈 Session statistics and trends
- 🧠 Memory layer visualization
- ⚡ Detected patterns awaiting promotion
- 💡 Evidence-based improvement suggestions
- 📊 Skill usage heatmap

**Try it:** `open reports/dashboard.html`

---

## 🏗️ Architecture

```
evolution/
├── SKILL.md              # Entry point
├── config.json           # Configuration
│
├── memory/               # 🧠 Three-layer memory
│   ├── episodes.jsonl    # Raw events
│   ├── patterns.json     # Detected patterns
│   └── drafts/           # Skill candidates
│
├── hooks/                # 🪝 Event capture
│   ├── capture.sh        # Pre/post tool hooks
│   └── reflect.sh        # Session-end analysis
│
├── reports/              # 📊 Visualization
│   └── dashboard.html    # Visual dashboard
│
└── community/            # 🌍 Shared knowledge
```

---

## 📖 Usage

### Automatic Mode

Once hooks are enabled, everything happens automatically:

- ✅ Skill usage is tracked
- ✅ Errors are captured with context
- ✅ Patterns are detected and drafted
- ✅ Session reports are generated

### Manual Commands

| Command | What it does |
|---------|--------------|
| `/retrospective` | Generate a session review with insights |
| `/evolve` | Promote a detected pattern to a skill |
| `/dashboard` | Open the visual dashboard |

### Example Session

```
You: Fix this TypeScript error
Agent: [fixes error using a specific pattern]

You: /retrospective
Agent: I noticed you've fixed similar TypeScript errors 4 times.
       Pattern detected: "Type Guard for API Responses"
       Would you like me to save this as a reusable skill?

You: Yes, /evolve it
Agent: Created: community/yourhandle-api-type-guard.md
       This pattern will now be available for future sessions.
```

---

## ⚙️ Configuration

All settings in one file — `config.json`:

```json
{
  "memory": {
    "episodic_ttl_days": 7,
    "semantic_ttl_days": 30,
    "pattern_threshold": 3
  },
  "evolution": {
    "auto_draft_on_error": true,
    "auto_pattern_detection": true
  }
}
```

---

## 🤝 Contributing

### Share Your Patterns

1. Create `community/{your-handle}-{pattern-name}.md`
2. Use templates from `templates/`
3. Submit a PR

### Quality Guidelines

- ✅ Solves a real, repeatable problem
- ✅ Includes "Use when..." trigger scenarios
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

## 📄 License

MIT License — see [LICENSE](LICENSE) for details.

---

<p align="center">
  <strong>Let your agent learn. Let it evolve.</strong>
</p>

<p align="center">
  <a href="https://github.com/ZhanlinCui/Auto-Evolution-Agent-Skills">⭐ Star this repo</a> •
  <a href="https://github.com/ZhanlinCui/Auto-Evolution-Agent-Skills/issues">Report Bug</a> •
  <a href="https://github.com/ZhanlinCui/Auto-Evolution-Agent-Skills/issues">Request Feature</a>
</p>
