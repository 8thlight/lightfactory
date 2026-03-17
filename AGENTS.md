# CLAUDE.md

This file provides guidance to Claude Code when working with this repository.

This project is a Claude Code plugin marketplace containing **skills** — structured markdown workflow documents. There is no application code or build system. Skills are validated by a three-layer test pipeline (see Testing Skills below).

For project architecture, key concepts (RPI methodology, testing philosophy, hexagonal architecture), artifact lifecycle, and installation commands, see `docs/architecture.md`.

## Skill Authoring Guidelines

- A skill's `SKILL.md` MUST be under 300 lines of markdown. Keep the main file focused on the core workflow and decision logic.
- Supporting content (examples, reference tables, deep-dive explanations, templates) SHOULD go in the skill's `references/` subdirectory as separate markdown files, linked from the main `SKILL.md`.
- Each skill is a directory containing `SKILL.md` and an optional `references/` subdirectory.

### Frontmatter Format

Every `SKILL.md` MUST begin with YAML frontmatter in this format:

```yaml
---
name: skill-name
description: One-sentence description of what the skill does and when to use it.
triggers:
  - "specific trigger phrase"
  - "another trigger phrase"
allowed-tools: Read Glob Write
---
```

- `name` — Kebab-case identifier matching the skill directory name.
- `description` — Concise summary shown in plugin listings.
- `triggers` — List of phrases that activate the skill. Use specific multi-word phrases; avoid bare single-word triggers that risk false activation.
- `allowed-tools` — Space-separated list of Claude Code tools the skill may use.

## Core Workflow (Plan Mode Native)

The primary workflow aligns with Claude Code's native plan mode:

1. **Research** (outside plan mode) — Assess complexity, dispatch parallel subagents if warranted, write temporary artifact to `.light/sessions/`
2. **Plan** (inside plan mode) — Draft behavior activates, produces plan summarizing research with Agent Context blocks
3. **Execute** (`/implement`) — Creates task graph from approved plan, runs three-agent TDD orchestration, writes session artifact to `.light/sessions/`
4. **Post-execution** — code-review, simplify, reflect recommendations
5. **Reflect** (`/reflect`) — Optional post-session learning loop

## Creating New Skills

Use the Anthropic `/skill-creator` skill to guide you through creating new skills. It provides an interactive workflow for designing effective skill documents.

Before creating a skill, review the Skill Authoring Guidelines and Frontmatter Format sections above.

### Where Skills Live

```
plugins/praxis/skills/   — research, plan-tasks, implement, tdd, refactor, reflect
plugins/harness/skills/  — adr, diagram, distill, hexagonal-architecture, scaffold
```

Each skill directory contains:
```
{skill-name}/
├── SKILL.md              # Main skill document (≤300 lines)
└── references/           # Optional supporting markdown (one level deep)
```

### Writing Effective Descriptions

The `description` field is the single most important frontmatter field — Claude uses it to decide whether to load the skill.

- **Write in third person.** The description is injected into the system prompt.
- **Structure:** `[What it does] + [When to use it] + [Key trigger phrases]`
- **Max 1024 chars.** No XML angle brackets in frontmatter.

Good: `"Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction."`

Bad: `"Helps with documents."`

**Debug triggering:** Ask Claude *"When would you use the [skill-name] skill?"* — it will quote the description back. Adjust based on what's missing.

### Extended Frontmatter Fields

Beyond the standard fields (`name`, `description`, `triggers`, `allowed-tools`), Claude Code supports:

| Field | Effect |
|-------|--------|
| `context: fork` | Run skill in isolated subagent (no conversation history) |
| `agent: Explore` | Use a specific subagent type (`Explore`, `Plan`, or custom) |
| `disable-model-invocation: true` | Prevent auto-loading; user must invoke via `/skill-name` |

**Warning:** `triggers` MUST be a top-level frontmatter key. Do not nest it inside `metadata:` or any other block — Claude Code's parser will not find it. Undocumented fields (e.g., `license`, `metadata`) are passed through but have no effect on skill loading.

**Dynamic context injection** — prefix commands with `!` to preprocess data:

```markdown
- PR diff: !`gh pr diff`
- Changed files: !`gh pr diff --name-only`
```

Claude receives the fully-rendered prompt with actual data.

### Writing the Skill Body

**Core principle: concise is key.** The context window is shared. Only add context Claude doesn't already have.

- Challenge each paragraph: "Does Claude need this explanation?"
- See the Skill Authoring Guidelines section above for the 300-line rule and `references/` pattern.
- Keep references one level deep from `SKILL.md` — deeply nested references cause partial reads.

**Match specificity to task fragility (degrees of freedom):**

| Freedom | Format | When |
|---------|--------|------|
| High | Text instructions | Multiple valid approaches, context-dependent |
| Medium | Pseudocode / parameterized scripts | Preferred pattern exists but variation is OK |
| Low | Exact scripts, no parameters | Fragile operations, consistency is critical |

**Progressive disclosure** — don't front-load everything:

```markdown
## Advanced features
**Form filling**: See [FORMS.md](references/forms.md) for complete guide
```

**Feedback loops** — for quality-critical tasks, provide a checklist with validation:

```markdown
- [ ] Step 1: Create plan
- [ ] Step 2: Validate (run scripts/validate.py)
- [ ] Step 3: Fix errors → repeat step 2
```

### Common Skill Patterns

| Pattern | Use When |
|---------|----------|
| **Sequential Workflow** | Multi-step process with dependencies and validation at each stage |
| **Iterative Refinement** | Draft → validate → fix → repeat until quality threshold |
| **Context-Aware Tool Selection** | Same outcome, different tools depending on context |
| **Domain-Specific Intelligence** | Specialized knowledge (compliance rules, heuristics) |
| **Template Pattern** | Strict output format for APIs/data; flexible for general content |
| **Examples Pattern** | Input/output pairs — examples beat descriptions for style |
| **Conditional Workflow** | Decision trees with branching paths based on context |

## Testing Skills

### Philosophy

**Build evaluations BEFORE writing extensive documentation.** Work through one challenging task until Claude succeeds, then extract the winning approach into a skill.

### Three-Layer Testing Pipeline

Skills are validated across three layers. Each layer catches different failure modes.

**Layer 1 — Deterministic (local).** Validates structure, frontmatter, triggers, and scenario schemas. No API calls. Must pass before shipping.

```bash
bash tests/local/validate-skills.sh
```

**Layer 2 — Promptfoo evals.** Functional and behavioral evaluation using real Claude API calls. See `tests/evals/README.md` for setup, cost, and per-scenario breakdown.

```bash
cd tests/evals && promptfoo eval

# Run a single skill's scenarios
promptfoo eval --filter-description "^\[research"
```

**Layer 3 — Human review.** Manual review for subjective quality. Use for `human`-graded scenarios and to calibrate LLM-judge rubrics.

### What Each Layer Tests

| Area | What to check | Validated by |
|------|--------------|-------------|
| **Triggering** | Positive triggers load the skill; negative triggers do not | Layer 1 (structure), Layer 2 (live probe) |
| **Functional** | Skill produces correct outputs (Given/When/Then assertions) | Layer 2 (Promptfoo evals) |
| **Performance** | Token usage, clarification turns, error rates vs. baseline | Manual comparison |

**Fixing trigger issues:**
- Under-triggering → add more keywords/phrases to `description`
- Over-triggering → add negative scope, be more specific in `description`

### The Claude A/B Method

Use two separate Claude sessions for manual testing:

1. **Claude A** (expert) helps design and refine the skill.
2. **Claude B** (tester) tests the skill cold — no prior context.
3. Return specific failures to Claude A: "Claude B forgot to X when asked to Y."
4. Iterate until Claude B succeeds reliably.

### Cross-Model Testing

Skills are additions to models, so effectiveness varies:
- **Haiku**: Does the skill provide enough guidance?
- **Sonnet**: Is the skill clear and efficient?
- **Opus**: Does the skill avoid over-explaining?

### Observation Signals

Watch for these during testing:
- **Unexpected exploration paths** → restructure content
- **Missed references** → make links more explicit
- **Overreliance on certain sections** → promote that content to `SKILL.md`
- **Ignored content** → file is unnecessary or poorly signaled

## Pre-Ship Checklist

### Structure (per Frontmatter Format above)
- [ ] Directory name matches frontmatter `name` (kebab-case)
- [ ] `SKILL.md` has valid YAML frontmatter with `---` delimiters
- [ ] `name`: kebab-case, max 64 chars, no spaces/capitals
- [ ] `description`: includes WHAT and WHEN, max 1024 chars, no XML tags
- [ ] `triggers`: top-level key with specific multi-word phrases (not bare single words)
- [ ] `allowed-tools` lists only the tools the skill actually needs
- [ ] Main file stays under 300 lines; extras go in `references/`

### Content
- [ ] Instructions are concise — only context Claude doesn't already have
- [ ] Degrees of freedom match task fragility
- [ ] Error handling included
- [ ] Examples provided (input/output pairs preferred)
- [ ] Feedback loops for quality-critical tasks
- [ ] No time-sensitive information
- [ ] Consistent terminology throughout
- [ ] Forward slashes in all file paths

### Testing
- [ ] At least 3 evaluation scenarios created in `tests/scenarios/<skill>.yaml`
- [ ] `bash tests/local/validate-skills.sh` passes with no failures
- [ ] Triggering: loads on relevant queries, doesn't load on unrelated ones
- [ ] Functional: produces correct outputs for all scenarios (run `cd tests/evals && promptfoo eval --filter-description "^\[<skill>"`)
- [ ] Tested with target models (Haiku, Sonnet, Opus)
- [ ] Tested with real usage scenarios (not just test scenarios)

## External Tools

### plannotator

Browser-based code review and annotation UI used by the implement and plan-tasks skills. The implement skill runs `plannotator review` after final verification to open a diff review in the browser. Returns "LGTM" or feedback items.

Install: `npm install -g plannotator`

Optional — skills gracefully skip plannotator steps when it's not installed.

## Issue Tracking

This project supports a three-tier tracker detection chain. The implement and plan-tasks skills auto-detect which tracker is available:

1. **yaks** (preferred) — git-native, CRDT-based CLI. Cross-session durable.
2. **beads** — Claude Code plugin-based tracker. Cross-session durable.
3. **native tasks** — Claude Code's built-in TaskCreate/TaskList/TaskUpdate. Session-scoped only.

### yaks (primary)

```bash
yx list               # Show all yaks (tasks)
yx list --format json # Machine-readable output for agents
yx show <name>        # View yak details
yx start <name>       # Mark as work-in-progress
yx done <name>        # Mark complete
yx sync               # Sync with git remote
```

Install: `curl -fsSL https://raw.githubusercontent.com/mattwynne/yaks/main/install.sh | bash`

### beads (fallback)

Used when yaks is unavailable. Requires `beads:init` to initialize. Key commands via Skill tool:
- `beads:epic` — create epic
- `beads:create` — create issue with `--label` for agent-type
- `beads:dep` — set dependencies
- `beads:ready` — find unblocked tasks

### native tasks (last resort)

Used when neither yaks nor beads is available. Agent-type is encoded in task titles (e.g., `P1-Schema-Setup [no-test]`). Progress is lost when the session ends.

## Session Completion

When ending a work session, all changes MUST be pushed to remote:

```bash
git pull --rebase
yx sync
git push
git status  # Must show "up to date with origin"
```
