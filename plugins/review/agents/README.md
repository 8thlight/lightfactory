# Review Agents — Maintainer Notes

Notes for anyone modifying these agent definitions. Not loaded as agent context — the agent `.md` files themselves stay lean and operational.

> All prose in these agent and reference files was compressed using the `caveman` skill to reduce the token load each carries at load time. If you're editing one, match the terse fragment style already in place rather than reverting to full prose.

## Architecture pattern: one agent, reference files on demand

The rule every specialist agent follows (fast inline detection pass, `references/{file}.md` read only when a category's trigger pattern is actually present) is the LLM-facing instruction in `CLAUDE.md` in this directory — that's the source of truth agents load as context, so it isn't repeated here.

For maintainers: `agent-accessibility.md` establishes this pattern first, with a detection table (category → trigger pattern → reference file) and a `references/` directory alongside it. `agent-rails.md` and `agent-stimulus-turbo.md` follow the same shape for their larger anti-pattern/framework checklists. The other specialists (`agent-database`, `agent-frontend`, `agent-security`, `agent-basic-quality`, `agent-diff-cleanliness`, `agent-react`, `agent-ci-conventions`) are expected to grow into the same shape as they pick up more specific checks: rather than inlining every check into the agent body, or growing the body indefinitely, split detail out into `references/` and gate it behind a detection pass.

This is a deliberate rejection of the Community Access `accessibility-lead` pattern, where one lead agent spawns ~9 specialist sub-agents (one per category). That pattern was evaluated and rejected here as too expensive: each sub-agent dispatch pays its own fixed context/model overhead regardless of how small its job is. A diff that only touches one category (e.g. adds an `<img>` tag) would still pay for 9 dispatches under that pattern; here it pays for one agent run plus one reference-file read. This tradeoff applies equally to every specialist, not just accessibility — it's the reason to keep expanding specialists via reference files instead of sub-agent fan-out.

Keep this pattern when extending any specialist: add new categories to its detection table and a new `references/` file, rather than splitting categories out into separate dispatched sub-agents.

## Shared agent rules and output format

`CLAUDE.md` (this directory) holds the behavioral rules every specialist agent must follow — report-only, confidence threshold, citation/tone, domain ownership. The `review-output-format` skill (`plugins/review/skills/review-output-format/`) holds the per-finding output template and severity tier definitions. Both exist to avoid re-deriving or drifting on the same boilerplate across ten agent files — extend those two files rather than restating rules inline in a new or existing specialist. The orchestrating skill itself lives at `plugins/review/skills/specialist-review/SKILL.md`.
