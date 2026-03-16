# LightFactory Praxis Skills

Skills for day-to-day software development best practices.

## Core Flow (Plan Mode Native)

The primary workflow aligns with Claude Code's native plan mode:

1. **Research** (`/research`, outside plan mode) — Explore codebase + web, write temporary artifact to `.light/sessions/`
2. **Plan** (`/plan-tasks`, inside plan mode) — Draft behavior activates, produces plan with Agent Context blocks
3. **Execute** (`/implement`) — Task-tracker-driven orchestration with three-agent TDD isolation
4. **Reflect** (`/reflect`) — Post-session learning loop

## All Skills

| Skill | Command | Description |
|-------|---------|-------------|
| [research](research/) | `/research` | Spawns parallel subagents to explore a codebase and produce a compact research artifact |
| [plan-tasks](plan-tasks/) | `/plan-tasks` | Produces a compact implementation plan with L3/L4 test specs and Agent Context blocks |
| [implement](implement/) | `/implement` | Executes an implementation plan phase by phase with strict test-first discipline |
| [tdd](tdd/) | `/tdd` | Boundary-focused TDD workflow for interactive, human-in-the-loop development |
| [refactor](refactor/) | `/refactor` | Refactoring process with test safety and incremental commits |
| [reflect](reflect/) | `/reflect` | Post-session reflection that extracts learnings and produces improvement proposals |
