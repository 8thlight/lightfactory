# Light Factory

A Claude Code plugin providing skills for agentic engineering patterns and practices.

## Getting Started

### Install

```
/plugin marketplace add 8thlight/lightfactory
/plugin install lightfactory@praxis
```

After installation, skills are available as `praxis:skill-name` and activate automatically when relevant to your task.

### Install from Local Clone

```bash
git clone https://github.com/8thlight/lightfactory
```

```
/plugin marketplace add /path/to/lightfactory
/plugin install lightfactory@praxis
```

### Update

```
/plugin marketplace update lightfactory@praxis
```

## Available Skills

### Praxis Plugin

| Skill | Command | Description |
|-------|---------|-------------|
| **research** | `/research` | Spawns parallel subagents to explore a codebase and produce a compact research artifact |
| **plan-tasks** | `/plan-tasks` | Consumes research artifact and produces a compact implementation plan with L3/L4 test specs |
| **implement** | `/implement` | Executes an implementation plan phase by phase with strict test-first discipline |
| **tdd** | `/tdd` | Boundary-focused TDD workflow enforcing L3/L4 altitude testing and property-based tests |
| **adr** | `/adr` | Guides writing minimal Architecture Decision Records |
| **reflect** | `/reflect` | Post-session reflection that mines git history and artifacts to produce improvement proposals |

### RPI Methodology (Research → Plan → Implement)

The praxis plugin's core workflow for non-trivial features follows three phases:

1. **Research** (`/research`) — Explore the codebase with parallel subagents, output a compact research artifact to `.light/sessions/`
2. **Plan** (`/plan-tasks`) — Consume the research artifact, produce a compact implementation plan with test specs and Agent Context blocks
3. **Implement** (`/implement`) — Execute the plan phase by phase with strict RED → GREEN → VALIDATE discipline

#### Key Concepts

- **Plan Mode Native** — The workflow aligns with Claude Code's native plan mode. Research happens outside plan mode; planning activates draft behavior inside plan mode; implementation executes the approved plan.
- **Three-Agent TDD Isolation** — During implementation, each TDD phase dispatches isolated agents: `agent-test` (writes failing tests), `agent-impl` (writes minimal code to pass), and `agent-validate` (runs full test suite). Agents never modify each other's artifacts.
- **Context Compaction** — Research produces a ~200-line artifact that carries forward into planning, replacing unbounded codebase exploration with a focused summary. Plan mode entry is the compaction boundary.
- **Tracker Detection Chain** — The implement and plan-tasks skills auto-detect available task trackers: yaks (preferred) → beads (fallback) → native tasks (last resort).

#### Standalone Skills

- **TDD** (`/tdd`) — For interactive, human-in-the-loop test-driven development outside the full RPI flow. Enforces boundary-focused testing at the L3/L4 altitude with ZOMBIES progression.
- **ADR** (`/adr`) — Guides writing Architecture Decision Records following the Harmel-Law signal check pattern. Ensures decisions are actually made before documenting them.
- **Reflect** (`/reflect`) — Post-session learning loop that mines git history and session artifacts to produce improvement proposals for skills, CLAUDE.md, and hooks.

## Testing

Skills are validated by a three-layer pipeline. See `tests/README.md` for full methodology.

**Layer 1 — Deterministic (local):** Validates skill structure, frontmatter, triggers, and scenario schemas. No API calls.

```bash
bash tests/local/validate-skills.sh
```

**Layer 2 — Promptfoo evals:** Functional and behavioral evaluation using real Claude API calls. See `tests/evals/README.md` for setup and cost.

```bash
cd tests/evals && promptfoo eval
```

**Layer 3 — Human review:** Manual review for subjective quality and calibrating LLM-judge rubrics.

## Contributing

See `AGENTS.md` for skill authoring guidelines, testing workflows, and the pre-ship checklist.
