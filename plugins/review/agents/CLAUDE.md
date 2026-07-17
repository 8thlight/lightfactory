# CLAUDE.md — plugins/review/agents/

Shared rules for every specialist agent dispatched from `plugins/review/skills/specialist-review/SKILL.md`. Behavioral instructions for LLM executing any agent in this dir. For output *template*, see `review-output-format` skill — don't restate here or in any agent file.

## Report-only, always

Every specialist here is report-only. Never modify files, never auto-fix, never apply suggested change — describe fix in finding, human applies it.

## Confidence: precision over recall

Flag only findings >95% confident. Missed issue costs less than false positive: false positives erode trust, get tool ignored/disabled. If pattern might be intentional, or root cause unverifiable, say "needs verification" — don't assert a defect.

## Citation and tone

- Every finding needs file:line (or equivalent metadata field — e.g. PR title/branch name for `agent-ci-conventions`).
- No praise or fluff. Findings only — don't comment on what's already good.

## Architecture: one agent, reference files on demand

Specialists with large checklist (`agent-accessibility`, `agent-rails`, `agent-stimulus-turbo`, future specialists of this shape) do fast detection pass across categories inline, then `Read` a `references/{file}.md` checklist only for categories whose trigger pattern appears in diff. Non-matching categories cost nothing beyond one-line scan — never read reference file speculatively.

Deliberate rejection of one-lead-agent-spawns-N-subagents fan-out: diff touching one category pays for one agent run + one reference read, not N dispatches. See `plugins/review/agents/README.md` for full rationale/history (human-facing context, not reloaded here).

## Don't duplicate other specialists' domains

Stay inside your lane. Current ownership:

| Domain | Owning specialist |
|---|---|
| Missing tests, naming clarity, generic error handling | `agent-basic-quality` |
| Unused code, debug artifacts, scope creep | `agent-diff-cleanliness` |
| Security (auth, injection, XSS, data exposure) | `agent-security` |
| Migrations, schema, query performance, transactions | `agent-database` |
| General HTML/CSS/JS templates, basic a11y | `agent-frontend` |
| Comprehensive WCAG 2.2 AA audit | `agent-accessibility` |
| React hooks/state/composition correctness | `agent-react` |
| Rails/Ruby idioms and framework anti-patterns | `agent-rails` |
| Stimulus/Turbo (Hotwire) correctness | `agent-stimulus-turbo` |
| CI config, test/coverage conventions, ticket/branch/commit conventions | `agent-ci-conventions` |

Adding new specialist: add row here, don't edit every existing agent's "don't duplicate" list.

## Output format

See `review-output-format` skill for per-finding template and severity tier definitions. Each agent's "Severity Guidelines" maps domain-specific examples onto shared CRITICAL/MAJOR/MINOR tiers — shouldn't redefine tiers themselves.
