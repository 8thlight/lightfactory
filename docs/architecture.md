# Architecture

## What This Project Is

LightFactory is a Claude Code plugin marketplace that delivers skills (structured markdown workflow documents) for software development best practices. There is no application code or build system. Testing is handled by a three-layer pipeline described below.

## Project Structure

- `.claude-plugin/marketplace.json` — Plugin registry declaring plugins: `praxis` and `harness`
- `plugins/praxis/skills/` — Skills for the praxis plugin (research, plan-tasks, implement, tdd, ...)
- `.light/sessions/` — Persistent session artifacts (one per completed flow)

Each skill is a directory containing `SKILL.md` (with YAML frontmatter for name, description, triggers, allowed-tools) and an optional `references/` subdirectory with supplementary markdown.

## Testing Pipeline

Skills are validated by a three-layer pipeline:

| Layer | What | How |
|-------|------|-----|
| 1 — Deterministic | Structural and trigger validation (no API calls) | `bash tests/local/validate-skills.sh` |
| 2 — Promptfoo evals | Functional and behavioral evaluation via Claude CLI | `cd tests/evals && promptfoo eval` |
| 3 — Human review | Subjective quality review | Manual |

See `tests/README.md` for methodology and `tests/evals/README.md` for eval setup and cost.

## Key Concepts

### RPI Methodology (Research → Plan → Implement)

The core workflow aligns with Claude Code's native plan mode:

1. **Research** (outside plan mode) — Claude assesses complexity first. If research is warranted, spawns parallel subagents (Explore + web) and writes a temporary artifact to `.light/sessions/{topic}-research.md`. Transitions into plan mode when complete — this replaces the old `/clear` context compaction ritual.
2. **Plan** (inside plan mode) — Draft behavior activates automatically. Reads the research artifact (if exists), summarizes findings inline, and produces a plan with Agent Context blocks per phase. The plan lives in the Claude Code session plan file only during planning.
3. **Execute** (`/implement`) — First action after plan approval: creates a yaks epic + per-agent-step yaks from the approved plan. Then runs the yaks-driven orchestration loop with three-agent TDD isolation. Final step writes a session artifact to `.light/sessions/YYYY-MM-DD-{topic}.md` combining research summary, plan, and execution log.
4. **Post-execution recommendations** — code-review, simplify, reflect
5. **Reflect** (`/reflect`) — Optional post-session learning loop that mines git history and artifacts to produce improvement proposals for skills, CLAUDE.md, hooks, and templates.


### L3/L4 Boundary Testing Philosophy

Enforced across TDD, implement, and plan-tasks skills:
- **L3 core tests**: Property-based testing with `fast-check` against domain logic
- **L3 feature tests**: Behavioral assertions against real databases via `Testcontainers`
- **L4 HTTP tests**: HTTP contract verification (status codes, response shapes) via `Supertest`
- Internal mocks are forbidden — test at architectural boundaries only
- ZOMBIES heuristic (Zero, One, Many, Boundary, Interface, Exception, Simple) guides test planning

### Subtype Dispatch Pattern

Skills that serve multiple related use cases (e.g., different diagram types, different project scaffolds) use the **subtype dispatch pattern** instead of creating separate skills:

1. **Dispatch table in `SKILL.md`** — A table mapping user intent to a subtype identifier and its reference directory.
2. **Subtype reference directories** — `references/{subtype}/` contains all syntax, examples, and conventions for that subtype.
3. **Explicit load instruction** — The skill MUST instruct the agent to "read ALL files from `references/{subtype}/`" before proceeding.

Skills using this pattern: `diagram` (subtypes: `likec4-c4`, `likec4-dynamic`, `data-flow`) and `scaffold` (subtypes: `typescript`).
