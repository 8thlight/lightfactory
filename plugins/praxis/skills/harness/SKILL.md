---
name: harness
description: Assess and strengthen the agentic coding environment surrounding a codebase. Audits instruction files, hooks, type safety, linting, pre-commit, architecture tests, CI gates, and sandbox permissions — then produces a gap analysis with actionable improvements. Use when the user wants to improve their Claude Code setup, harden their development environment for AI agents, add hooks or guardrails, assess harness maturity, or mentions "harness engineering". Also use when the user says things like "make my repo more agent-friendly", "add guardrails", "improve my Claude setup", "audit my dev environment", or "what controls am I missing".
triggers:
  - "harness engineering"
  - "audit my harness"
  - "improve harness"
  - "strengthen harness"
  - "add guardrails"
  - "make repo agent-friendly"
  - "audit dev environment"
allowed-tools: Read Glob Grep Bash Write Edit AskUserQuestion Agent
---

# Harness Skill

Assess and strengthen the controls surrounding an agentic coding environment.

## Conceptual Model

An agentic system has two parts: **Model + Harness**. The model is fixed — you improve agent performance by improving the harness. Controls fall into two categories:

| Control Type | Timing | Purpose | Examples |
|-------------|--------|---------|----------|
| **Feedforward** (guides) | Before agent acts | Steer toward correct behavior | CLAUDE.md, type definitions, skills, architecture docs |
| **Feedback** (sensors) | After agent acts | Catch and correct errors | Linters, tests, type checkers, hooks, code review |

Both types can be **computational** (deterministic — linters, type checkers) or **inferential** (probabilistic — LLM-as-judge). Prefer computational controls: they're cheaper, faster, and always reliable.

## When to Use

- Starting a new project and want a solid agentic foundation
- Existing project feels brittle under AI-assisted development
- Want to audit what controls exist and what's missing
- Adding hooks, linting, type safety, or CI gates for agent workflows
- After a session where the agent made preventable mistakes

## Workflow

### 1. Detect Project Context

Auto-detect the project's language ecosystem and existing tooling. Read these files (skip any that don't exist):

```
./CLAUDE.md
.claude/settings.json
.claude/settings.local.json
package.json / pyproject.toml / Cargo.toml / go.mod / Gemfile
tsconfig.json / pyrightconfig.json / mypy.ini
.eslintrc* / ruff.toml / .ruff.toml / pyproject.toml [tool.ruff]
.pre-commit-config.yaml
.github/workflows/*.yml / .gitlab-ci.yml
.gitignore
```

Determine: primary language(s), package manager, existing linter/formatter, existing type checker, existing hooks, CI provider.

### 2. Run the Harness Audit

Assess each of the **nine pillars** against the current project state. For each pillar, determine the status:

| Status | Meaning |
|--------|---------|
| **Strong** | Pillar is well-configured, no action needed |
| **Partial** | Some controls exist but have gaps |
| **Missing** | No controls in this area |
| **N/A** | Not applicable to this project |

#### The Nine Pillars

See [pillar details](references/pillars.md) for language-specific recommendations per pillar.

1. **Instruction Files** — CLAUDE.md quality, path-scoped rules, managed policy
2. **Hooks** — SessionStart, PreToolUse, PostToolUse in `.claude/settings.json`
3. **Type Safety** — Strict typing configuration for the project's language
4. **Linting** — AI-relevant linter rules (not just style — focus on correctness and security)
5. **Pre-commit** — Hook pipeline with secret scanning, linting, type checking
6. **Architecture Tests** — Import boundary enforcement, structural invariants
7. **CI Gates** — Fast-fail pipeline structure (lint → test → integration)
8. **Sandbox & Permissions** — Tool allowlists, writable path scoping
9. **Secret Scanning** — Credential detection at commit and CI time

### 3. Present the Gap Analysis

Present results as a table, then ask what to improve:

```
## Harness Audit Results

| # | Pillar | Status | Key Finding |
|---|--------|--------|-------------|
| 1 | Instruction Files | Partial | CLAUDE.md exists but exceeds 200 lines |
| 2 | Hooks | Missing | No hooks configured |
| ... | ... | ... | ... |

Which pillars would you like to strengthen?
- Enter numbers (e.g., "2, 4, 5") to improve specific pillars
- Enter "all" to address everything marked Partial or Missing
- Enter "none" to save the report and stop
```

Use `AskUserQuestion` and wait for the user's choice. Do NOT proceed without input.

### 4. Implement Selected Improvements

For each selected pillar, apply the recommendations from [pillar details](references/pillars.md).

**Implementation rules:**
- One change per commit — do not bundle unrelated improvements
- Commit message format: `harness: <pillar-name> — <description>`
- Read existing config before modifying — never overwrite user customizations
- For hooks: validate JSON syntax before writing to `.claude/settings.json`
- For linter/type configs: use the project's existing config format
- For new dependencies: explain what each dependency does before adding it

**Order of operations** (when implementing multiple pillars):
1. Instruction files first (cheapest, highest leverage)
2. Type safety and linting (computational feedforward)
3. Hooks (feedback sensors)
4. Pre-commit (combines multiple checks)
5. Architecture tests, CI gates, secret scanning, sandbox (infrastructure)

### 5. Write the Harness Report

Save the audit results and applied changes to:
```
.light/sessions/{date}-harness-report.md
```

Use the [report template](references/report-template.md). Include:
- Full audit table with status for all nine pillars
- What was implemented (with commit hashes)
- What was deferred (and why)
- Recommended next steps

### 6. Verify and Close

After all improvements are applied:

```bash
# Verify hooks work (if hooks were added)
echo '{}' | claude --print-only  # dry-run to check hook syntax

# Verify pre-commit works (if pre-commit was added)
pre-commit run --all-files

# Verify type checker works (if type safety was added)
# (language-specific command)
```

Present a summary of what was done and what the user might want to tackle next.

## Anti-Patterns to Avoid

- **Don't install every possible tool** — only add controls relevant to the project
- **Don't configure linters to maximum strictness on existing codebases** — start with rules that catch real bugs, tighten incrementally
- **Don't duplicate existing controls** — if pre-commit already runs a linter, don't add a PostToolUse hook for the same linter
- **Don't add inferential controls where computational ones exist** — a type checker beats an LLM reviewing types
- **Don't overwhelm with changes** — if many pillars are missing, prioritize the top 3-4 highest-leverage items
- **Don't modify `~/.claude/CLAUDE.md`** — it may be managed externally; use `~/.claude/CLAUDE.local.md` for user-level changes

## Interaction with Other Skills

- **Delegate CLAUDE.md auditing** to `claude-md-management:claude-md-improver` if deep CLAUDE.md restructuring is needed — the harness skill focuses on whether instruction files *exist and are sized correctly*, not on rewriting their content
- **After harness improvements**, suggest running `/reflect` to capture what was learned
- **Differs from `claude-code-setup:claude-automation-recommender`** — that skill focuses narrowly on Claude Code automations; harness engineering covers the full development environment (typing, linting, architecture tests, CI)
