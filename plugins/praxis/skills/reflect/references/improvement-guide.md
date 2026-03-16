# Improvement Type Guide

Use this guide when categorizing improvement proposals in Step 5. Each type targets a different part of the context engineering stack.

## Decision Table

| Friction Signal | Likely Type | Target |
|-----------------|-------------|--------|
| "I had to explain the same convention twice" | `claude-md` | ./CLAUDE.md or ~/.claude/CLAUDE.local.md |
| "The skill didn't mention X scenario" | `skill-update` | The relevant SKILL.md |
| "I kept making the same mistake" | `hook` | .claude/settings.json |
| "The plan template was missing a section" | `plan-template` | A references/template.md |
| "There's no skill for this workflow" | `new-skill` | New skill directory |
| "CLAUDE.md says X but we actually do Y" | `claude-md` | ./CLAUDE.md |
| "The skill's anti-patterns list is incomplete" | `skill-update` | The relevant SKILL.md |
| "I forgot to run X before Y" | `hook` | .claude/settings.json |

## Type Details

### `skill-update`

**Target:** An existing SKILL.md file
**Scope:** Add anti-patterns, clarify steps, add references, fix inaccuracies
**Commit prefix:** `reflect: update {skill-name} skill —`

Examples:
- Add "Don't skip validation agent" to /implement anti-patterns
- Add a depth-level signal to /research's decision table
- Add a missing reference doc to a skill's references/ directory

**Important:** Keep SKILL.md under 300 lines. If the update would push it over, move content to a references/ file.

### `claude-md`

**Target:** `./CLAUDE.md` (project) or `~/.claude/CLAUDE.local.md` (personal)
**Scope:** Document conventions, update stale information, add missing context
**Commit prefix:** `reflect: update CLAUDE.md —`

Examples:
- Document a naming convention that emerged during the session
- Add a new key concept section
- Update the project structure section after adding new directories

**NEVER update `~/.claude/CLAUDE.md`** — it's managed by tech-pass and will be overwritten. Use `~/.claude/CLAUDE.local.md` for personal customizations.

### `hook`

**Target:** `.claude/settings.json`
**Scope:** Add PreToolUse or PostToolUse hooks to prevent recurring mistakes
**Commit prefix:** `reflect: add hook —`

Examples:
- Add a PreToolUse hook that reminds about test isolation before Bash
- Add a PostToolUse hook that checks for common mistakes after Write
- Add a PreToolUse hook on EnterPlanMode that surfaces existing research artifacts from `.light/sessions/`

**Always read `.claude/settings.json` and `.claude/settings.local.json` first** to avoid duplicating existing hooks. The praxis plugin uses a PreToolUse hook on EnterPlanMode to surface research artifacts — check for this before proposing similar hooks.

### `plan-template`

**Target:** A `references/template.md` file within a skill
**Scope:** Add missing sections, clarify existing sections, add examples
**Commit prefix:** `reflect: update {skill-name} template —`

Examples:
- Add a "Migration Strategy" section to the draft plan template
- Add an example to the research artifact template
- Clarify the acceptance criteria format

### `new-skill`

**Target:** New skill directory (sketch only — don't build the full skill)
**Scope:** Propose a new skill with name, purpose, and 3-5 line workflow sketch
**Commit prefix:** `reflect: sketch {skill-name} skill proposal —`

The reflection only sketches the idea. Building the full skill is a separate task using `/skill-creator` or the plan's skill authoring guidelines.

Example sketch:
```
Skill: /standup
Purpose: Generate daily standup summary from git log and open tasks
Workflow: Read git log → Read open issues → Synthesize → Present
Trigger: "standup", "daily summary"
```

## Priority Levels

| Priority | Criteria | Action |
|----------|----------|--------|
| **P1** | Friction occurred multiple times or caused significant backtracking | Apply immediately |
| **P2** | Friction occurred once but is likely to recur | Apply in this session |
| **P3** | Nice-to-have improvement based on observation | Defer or apply if time permits |

## Ordering Proposals

1. P1 items first, ordered by impact
2. P2 items next, ordered by likelihood of recurrence
3. P3 items last (may be moved to Deferred section if at the 5-proposal cap)
