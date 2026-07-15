# LightFactory Review Skills

Multi-pass, human-validated code review skills.

> All prose in these skills and their companion agent/reference files (`../agents/`) was compressed using the `caveman` skill to reduce the token load each carries at load time. If you're editing one, match the terse fragment style already in place rather than reverting to full prose.

## All Skills

| Skill | Command | Description |
|-------|---------|--------------|
| [review](review/) | `/review` | Runs a multi-pass review of the current diff — universal checks (basic quality, security, diff cleanliness) always run, plus conditional specialists (database, frontend, accessibility) dispatched based on what changed. Surfaces findings only; never auto-fixes. |

## Specialists

Specialist agent definitions live in `../agents/`, not here — each is a standalone subagent dispatched by the `review` skill's orchestrator:

| Agent | Dispatch |
|-------|----------|
| `agent-basic-quality` | Always |
| `agent-security` | Always |
| `agent-diff-cleanliness` | Always |
| `agent-database` | Migration/schema files changed |
| `agent-frontend` | HTML/CSS/JS/template files changed |
| `agent-accessibility` | Markup/component files with interactive elements changed |
