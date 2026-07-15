---
name: review
description: Run a multi-pass, human-validated code review of the current diff — universal checks (basic quality, security, diff cleanliness) always run, plus conditional specialists (database, frontend, accessibility, react, rails, stimulus/turbo, CI conventions) dispatched only when relevant files changed. Use when the user wants a thorough review before opening a PR, asks to "review my changes," "check for accessibility issues," "run a review," or wants a second opinion spanning security/database/accessibility/quality/framework-specific concerns before merging. Never auto-fixes — surfaces findings for human review.
triggers:
  - "review my changes"
  - "review this diff"
  - "run a review"
  - "check for accessibility issues"
  - "multi-pass review"
  - "review before pr"
allowed-tools: Read Glob Grep Bash Agent
---

# Review Skill

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

### Step 2: Classify Changed Files

From changed-file list, determine which conditional specialists to dispatch:

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

Report which specialists will run before dispatching, e.g.: `"Running: basic-quality, security, diff-cleanliness, frontend, accessibility (skipping database — no migration/schema files changed)"`.

**Opportunistic design context (never blocking):** if a Linear or Figma MCP tool is available this session, a quick best-effort check for linked ticket/design file can give specialists extra context on designer intent — but proceed identically whether or not this succeeds. Don't prompt user to set anything up.

### Step 3: Dispatch Specialists in Parallel

Launch every applicable specialist from Step 2 via Agent tool, all in same message so they run concurrently. Pass each specialist the diff content from Step 1 (not whole repo), instruct it to scope findings to changed lines — pre-existing issues in unchanged code out of scope.

### Step 4: Compile the Report

1. Collect all specialist findings.
2. Normalize severity to single scale for combined report: `CRITICAL → High`, `MAJOR → Medium`, `MINOR → Low` (OPP- and EnGen-derived specialists — `agent-basic-quality`, `agent-database`, `agent-diff-cleanliness`, `agent-frontend`, `agent-security`, `agent-react`, `agent-rails`, `agent-stimulus-turbo`, `agent-ci-conventions` — use CRITICAL/MAJOR/MINOR internally; accessibility specialist already reports High/Medium/Low natively).
3. De-duplicate findings overlapping across specialists (e.g. both `agent-frontend` and `agent-accessibility` may flag same missing-alt-text case — keep once, note which specialists agreed).
4. Present single report to user in this format:

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

5. Specialist found nothing → say so explicitly rather than omitting — empty section is real result, not gap.

### Step 5: Hand Off

Present report directly in conversation. Do NOT auto-post PR comments, auto-create tracker issues, or auto-fix anything — that decision belongs to human reviewing report. If project has beads or yaks initialized and user asks to save report, reasonable follow-up, but never do it by default.

## Error Handling

Specialist agent fails/times out → continue with others, note incomplete section in final report rather than blocking whole review. Offer to retry just the failed specialist.

## Out of Scope (v1)

- CI/build-time hook integration — on-demand only, never a forced gate (explicit CoP decision)
- Auto-fix of any kind
- Required Linear/Figma/Gemini setup

## Related

- `plugins/review/agents/` — specialist definitions, each self-contained. Universal: `agent-basic-quality`, `agent-security`, `agent-diff-cleanliness`. Conditional: `agent-database`, `agent-frontend`, `agent-accessibility`, `agent-react`, `agent-rails`, `agent-stimulus-turbo`, `agent-ci-conventions`.
- Superpowers `requesting-code-review:code-reviewer` — general code-review quality reference this orchestration pattern draws from
