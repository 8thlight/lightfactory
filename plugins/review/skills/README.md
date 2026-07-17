# LightFactory Review Skills

Multi-pass, human-validated code review skills.

> All prose in these skills and their companion agent/reference files (`../agents/`) was compressed using the `caveman` skill to reduce the token load each carries at load time. If you're editing one, match the terse fragment style already in place rather than reverting to full prose.

## All Skills

| Skill | Command | Description |
|-------|---------|--------------|
| [specialist-review](specialist-review/) | `/specialist-review` | Runs a multi-pass review of the current diff — universal checks (basic quality, security, diff cleanliness) always run, plus conditional specialists (database, frontend, accessibility) dispatched based on what changed. Surfaces findings only; never auto-fixes. |
| [create-local-specialist](create-local-specialist/) | — | Scaffolds a project-local specialist (new, or overriding a built-in) as a real registered agent at `.claude/agents/<name>.md` in the consuming project — no changes to this plugin required. |

## Specialists

Specialist agent definitions live in `../agents/`, not here — each is a standalone subagent dispatched by the `specialist-review` skill's orchestrator:

| Agent | Dispatch |
|-------|----------|
| `agent-basic-quality` | Always |
| `agent-security` | Always |
| `agent-diff-cleanliness` | Always |
| `agent-database` | Migration/schema files changed |
| `agent-frontend` | HTML/CSS/JS/template files changed |
| `agent-accessibility` | Markup/component files with interactive elements changed |

Projects can add their own specialists, or override any of the above, without editing this plugin — see `.claude/agents/*.md` (project-local, optional, requires a session restart after creation) documented in `specialist-review/SKILL.md` Step 2, and use `create-local-specialist` to scaffold them.
