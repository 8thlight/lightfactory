---
name: specialist-review
description: Run a multi-pass, human-validated code review of the current diff using domain specialist agents — universal checks (basic quality, security, diff cleanliness) always run, plus conditional specialists (database, frontend, accessibility, react, rails, stimulus/turbo, CI conventions) dispatched only when relevant files changed. Use when the user wants a thorough review before opening a PR, asks to "review my changes," "check for accessibility issues," "run a review," or wants a second opinion spanning security/database/accessibility/quality/framework-specific concerns before merging. Never auto-fixes — surfaces findings for human review.
triggers:
  - "review my changes"
  - "review this diff"
  - "run a review"
  - "check for accessibility issues"
  - "multi-pass review"
  - "review before pr"
  - "specialist review"
allowed-tools: Read Glob Grep Bash Agent
---

# Specialist Review Skill

Orchestrates multi-pass review: shallow universal pass + specialist agents dispatched by what actually changed. Adapted from EnGen `review-deep` orchestration pattern (parallel specialist dispatch) — see `plugins/review/agents/` for specialists themselves, each with source attribution comment where copied.

## Design Principles (per 2026-07-02 CoP decision)

- **Self-contained.** No required external MCP dependency. Never blocks on Linear/Figma/Gemini config — check opportunistically only, never as gate.
- **Human validation only.** Every specialist reports findings; nothing here edits files or opens PR comments automatically.
- **Modular.** Universal specialists always run; conditional specialists run only when diff touches their domain. Any specialist skippable via `--skip` argument.
- **Precision over recall.** Missed issue better than false positive that erodes trust in tool.

## Workflow

### Step 1: Determine the Diff

1. Check staged changes: `git diff --staged --name-only`
2. If none, check unstaged: `git diff --name-only`
3. If none, compare against default branch: `git diff main...HEAD --name-only` (or `master` if repo default)
4. No diff at all → tell user nothing to review, stop.
5. Capture actual diff content (`git diff [chosen strategy]`) — this is what every specialist reviews, not whole codebase.

### Step 2: Load Local Specialist Overrides

Local specialists are real project-registered subagents living at `.claude/agents/*.md` in the diffed repo — not a plugin-bundled file, not dispatched generically. A project's `.claude/agents/` may hold agents unrelated to review entirely, so membership in this skill's dispatch set requires an explicit, purpose-specific marker — **not** just the presence of a plausibly-named field a coincidental or copied file might also carry. A file counts as a local review specialist only if its frontmatter has `review_specialist: true`. Treat `dispatch_condition` alone, without that marker, as insufficient — some unrelated custom agent could define a same-named field for its own purposes.

1. `Glob .claude/agents/*.md` at the repo root (`git rev-parse --show-toplevel`).
2. For each match, `Read` its frontmatter. Skip any file without `review_specialist: true` — not a review specialist, regardless of what other fields it happens to carry.
3. For files that do carry the marker, read `dispatch_condition:` (required) and `overrides: <built-in-name>` (optional).

```yaml
---
name: agent-payments
description: "Reviews payments/billing code paths. Report-only."
model: sonnet
review_specialist: true
dispatch_condition: "Changed files include app/services/payments/* or any *.billing.rb"
---
```

```yaml
---
name: agent-database-local
description: "Project-specific database review, overrides the built-in agent-database."
model: sonnet
review_specialist: true
dispatch_condition: "Changed files include db/migrate/*, schema.rb, or Terraform under infra/db/"
overrides: agent-database
---
```

- No `overrides:` field → added as an extra conditional specialist, dispatched by its own `name`.
- `overrides: agent-database` → skip the built-in `agent-database` entirely this run; dispatch this local specialist (by its own distinct `name`) in its place.
- No `.claude/agents/*.md` file carries `review_specialist: true` → proceed with built-ins only, silently.
- A local specialist's file exists but its `name` isn't yet a resolvable `subagent_type` (created this session, before a restart) → note it in the final report as "created but not yet available — restart the session, then re-run this review" rather than failing the whole review over one specialist.

**Nested-workspace case** (a git repo living inside a non-git parent workspace folder): unlike the old yaml-based lookup, this step can't independently check a parent directory for local specialists — subagent discovery is Claude Code's own mechanism, tied to wherever the session's `.claude/agents/` actually is. Place local specialist files at whatever directory the session is launched from; if that's the parent workspace root, put `.claude/agents/` there, not in the nested repo. Confirm with the user where their session actually starts if unsure — don't assume the diffed repo's own git top-level.

Use the `create-local-specialist` skill (`plugins/review/skills/create-local-specialist/`) to scaffold new specialist files — it keeps generated specialists conformant with the pattern this skill expects.

### Step 3: Classify Changed Files

From changed-file list, determine which conditional specialists to dispatch. Start from the built-in table, then merge in Step 2's local overrides/additions:

| Specialist | Dispatch condition |
|---|---|
| `agent-basic-quality` | Always |
| `agent-security` | Always |
| `agent-diff-cleanliness` | Always |
| `agent-database` | Changed files include migration/schema paths (e.g. `db/migrate/*`, `schema.rb`, or equivalent) |
| `agent-frontend` | Changed files include `.html`, `.erb`, `.jsx`, `.tsx`, `.vue`, `.svelte`, `.css`, `.scss`, or similar template/style files |
| `agent-accessibility` | Changed files include markup with interactive elements or components (`.html`, `.jsx`, `.tsx`, `.vue`, `.svelte`, `.erb`, `.ejs`, `.hbs`, `.liquid`) |
| `agent-react` | Changed files include `.jsx`, `.tsx`, or `.js` files defining React components, hooks, or JSX |
| `agent-rails` | Changed files include `.rb`, `.erb`, or other Rails application files (models, controllers, components, views, specs) |
| `agent-stimulus-turbo` | Changed files include Stimulus controllers (`*_controller.js`) or Turbo view files (`.turbo_stream.erb`, templates using `<turbo-frame>`/`turbo_frame_tag`) |
| `agent-ci-conventions` | Changed files include CI/CD workflow config (`.github/workflows/*.yml`, `.gitlab-ci.yml`, `Jenkinsfile`, `.circleci/config.yml`) or test files, or the commit/PR/branch metadata is available and worth checking |

Report which specialists will run before dispatching, e.g.: `"Running: basic-quality, security, diff-cleanliness, frontend, agent-payments (local) — skipping database (overridden by agent-database-local), skipping accessibility (no matching files)"`.

**Opportunistic design context (never blocking):** if a Linear or Figma MCP tool is available this session, a quick best-effort check for linked ticket/design file can give specialists extra context on designer intent — but proceed identically whether or not this succeeds. Don't prompt user to set anything up.

### Step 4: Dispatch Specialists in Parallel

Launch every applicable specialist from Step 3 via Agent tool, all in same message so they run concurrently. Pass each specialist the diff content from Step 1 as the primary scope — findings should be about changed lines, pre-existing issues in unchanged code out of scope — but expect and budget for **diff plus targeted verification reads**, not diff-only. Confident findings routinely require reading unchanged code the diff touches or calls into (association/method definitions, other callers, route/config files). Give every specialist Read/Grep access to the repo, not just the diff text. As a standard first step, instruct each specialist to grep the repo for other callers of any newly-touched public method with default create!/update! semantics before concluding no other paths are affected.

- **Built-in and local specialists dispatch the same way**: by `subagent_type: <name>` directly (e.g. `agent-database`, or `agent-payments` for a local one) — local specialists scaffolded by `create-local-specialist` are real registered project agents, not generic-agent dispatches with pasted-in content. No prompt assembly needed beyond the diff itself.
- **If a local specialist's `subagent_type` doesn't resolve** (created this session, before a restart — see Step 2), don't fail the whole review: note it in the final report as unavailable this session, dispatch every other applicable specialist normally, and suggest the user restart before re-running to pick it up.
- **Metrics/instrumentation passthrough (opt-in):** if this skill is invoked with metrics/instrumentation instructions supplied by the caller (e.g. a wrapper's `--metrics <instructions>` flag), append that instructions text verbatim to every specialist's dispatch prompt this step — built-in and local alike. This skill doesn't define what "recording metrics" means; it only threads whatever text the caller supplies into each dispatch.

### Step 5: Compile the Report

1. Collect all specialist findings.
2. Normalize severity to single scale for combined report: `CRITICAL → High`, `MAJOR → Medium`, `MINOR → Low` (OPP- and EnGen-derived specialists — `agent-basic-quality`, `agent-database`, `agent-diff-cleanliness`, `agent-frontend`, `agent-security`, `agent-react`, `agent-rails`, `agent-stimulus-turbo`, `agent-ci-conventions` — use CRITICAL/MAJOR/MINOR internally; accessibility specialist already reports High/Medium/Low natively). Local specialists follow the same CRITICAL/MAJOR/MINOR scale unless their file states otherwise.
3. De-duplicate findings overlapping across specialists (e.g. both `agent-frontend` and `agent-accessibility` may flag same missing-alt-text case — keep once, note which specialists agreed).
4. Tag local specialists' findings with `(local)` alongside the source name, e.g. `(source: agent-payments, local)`, so reviewers know it isn't a plugin-shipped specialist.
5. Present single report to user in this format:

```markdown
## Review Report

### High Priority
- [File:Line] {finding} (source: {specialist})

### Medium Priority
- [File:Line] {finding} (source: {specialist})

### Low Priority / Discussion
- [File:Line] {finding} (source: {specialist})

### Specialists Run
{list of what ran and what was skipped, and why}
```

6. Specialist found nothing → say so explicitly rather than omitting — empty section is real result, not gap.

### Step 6: Hand Off

Present report directly in conversation. Do NOT auto-post PR comments, auto-create tracker issues, or auto-fix anything — that decision belongs to human reviewing report. If project has beads or yaks initialized and user asks to save report, reasonable follow-up, but never do it by default.

## Error Handling

Specialist agent fails/times out → continue with others, note incomplete section in final report rather than blocking whole review. Offer to retry just the failed specialist.

## Out of Scope (v1)

- CI/build-time hook integration — on-demand only, never a forced gate (explicit CoP decision)
- Auto-fix of any kind
- Required Linear/Figma/Gemini setup

## Related

- `plugins/review/agents/` — specialist definitions, each self-contained. Universal: `agent-basic-quality`, `agent-security`, `agent-diff-cleanliness`. Conditional: `agent-database`, `agent-frontend`, `agent-accessibility`, `agent-react`, `agent-rails`, `agent-stimulus-turbo`, `agent-ci-conventions`.
- `.claude/agents/*.md` (project-local, optional) — adds or overrides specialists per-project via the `review_specialist: true` marker plus `dispatch_condition`/`overrides` frontmatter, see Step 2. Requires a session restart after creation before dispatchable (subagent discovery happens at session start).
- `plugins/review/skills/create-local-specialist/` — scaffolds new local specialist files as real registered agents at `.claude/agents/<name>.md`.
- Superpowers `requesting-code-review:code-reviewer` — general code-review quality reference this orchestration pattern draws from
