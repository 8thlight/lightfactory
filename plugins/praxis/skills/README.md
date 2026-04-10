# LightFactory Praxis Skills

Skills for day-to-day software development best practices.

## Core Flow (RPI)

The primary workflow flows seamlessly through three phases, with artifacts at `.light/sessions/` as handoff points:

1. **Research** (`/research`) — Explore codebase + web, write research artifact to `.light/sessions/`
2. **Plan** (`/plan-tasks`) — Consumes research artifact, produces plan with Agent Context blocks + task graph
3. **Execute** (`/implement`) — Task-tracker-driven orchestration with three-agent TDD isolation
4. **Reflect** (`/reflect`) — Post-session learning loop

Each phase flows directly into the next. Context clearing is only suggested when the conversation is extensive — the artifacts carry all needed context forward.

## All Skills

| Skill | Command | Description |
|-------|---------|-------------|
| [research](research/) | `/research` | Spawns parallel subagents to explore a codebase and produce a compact research artifact |
| [plan-tasks](plan-tasks/) | `/plan-tasks` | Produces a compact implementation plan with L3/L4 test specs and Agent Context blocks |
| [implement](implement/) | `/implement` | Executes a task-graph-driven implementation plan with RED/GREEN/VALIDATE gate enforcement; delegates to `/plan-tasks` to create the task graph if one does not yet exist |
| [tdd](tdd/) | `/tdd` | Boundary-focused TDD workflow for interactive, human-in-the-loop development |
| [harness](harness/) | `/harness` | Audits the agentic coding environment (instruction files, hooks, type safety, linting, pre-commit, CI gates, sandbox, secret scanning) and produces a gap analysis with actionable improvements |
| [adr](adr/) | `/adr` | Guides writing minimal Architecture Decision Records |
| [reflect](reflect/) | `/reflect` | Post-session reflection that extracts learnings and produces improvement proposals |
