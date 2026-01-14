# Community Contributions

This directory contains community-contributed skills, patterns, and error solutions that evolved from real-world usage.

## How to Contribute

### 1. From Auto-Detection

When the evolution system detects a pattern, it creates a draft in `memory/drafts/`. To promote it:

```
User: /evolve promote [draft-name]
```

The skill will be created here with your GitHub handle as author.

### 2. Manual Creation

Create a file following this naming convention:

```
{github-handle}-{skill-name}.md
```

Examples:
- `johndoe-api-retry-pattern.md`
- `janedoe-typescript-guard.md`

### 3. Use Templates

Copy the appropriate template from `../templates/`:

| Type | Template |
|------|----------|
| General skill | `skill.md` |
| Error solution | `error.md` |

## Contribution Guidelines

### Required Frontmatter

```yaml
---
name: descriptive-skill-name
description: "Clear description. Use when [specific scenarios]."
author: your-github-handle
source: project-name
date: YYYY-MM-DD
tags: [relevant, tags]
level: beginner|intermediate|advanced
---
```

### Quality Checklist

Before submitting:

- [ ] Skill solves a real, repeatable problem
- [ ] Description includes "Use when..." trigger scenarios
- [ ] Examples are concrete and tested
- [ ] No project-specific hardcoded values
- [ ] Follows template structure

### File Naming

- Use lowercase with hyphens: `my-skill-name.md`
- Include your GitHub handle: `yourhandle-skill-name.md`
- Be descriptive but concise

## Promotion Path

High-quality community contributions may be promoted to the official `_base/` directory:

1. **Community validation**: Used successfully by multiple users
2. **Documentation complete**: All sections filled out
3. **Positive feedback**: No reported issues
4. **Author credit preserved**: `author` field maintained

## Examples

### Good Contribution

```markdown
---
name: graceful-api-fallback
description: "Handle API failures with cached fallback. Use when external APIs may be unreliable."
author: johndoe
source: production-dashboard
date: 2024-01-15
tags: [api, error-handling, resilience]
level: intermediate
---

# Graceful API Fallback

When an external API call fails, return cached data instead of crashing.

## When to Use

- External APIs with occasional downtime
- Non-critical data that can be slightly stale
- User-facing features that should degrade gracefully
...
```

### Avoid

- Generic or vague descriptions
- Untested code examples
- Project-specific configurations
- Missing author/date information

## Questions?

Open an issue on the [main repository](https://github.com/ZhanlinCui/Auto-Evolution-Agent-Skills).
