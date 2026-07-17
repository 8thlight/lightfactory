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

### Step 2: Load Local Specialist Overrides

Before classifying, check the project root (not cwd) for `.claude/review-specialists.yaml`. This file is optional, project-local, and never bundled with the plugin — it's how a project adds its own specialists or overrides a built-in one without forking this skill.

```yaml
specialists:
  - name: agent-payments
    dispatch_condition: "Changed files include app/services/payments/* or any *.billing.rb"
    location: .claude/review-specialists/agent-payments.md   # relative to repo root, or absolute
  - name: agent-database   # matches a built-in name below → overrides it entirely
    dispatch_condition: "Changed files include db/migrate/*, schema.rb, or Terraform under infra/db/"
    location: .claude/review-specialists/agent-database.md
```

- **Name not in the built-in table below** → added as an extra conditional specialist.
- **Name matches a built-in** → override. Skip that built-in entirely for this run; use the local file's dispatch condition and content instead.
- File missing → proceed with built-ins only, silently.
- File present but malformed/unreadable → proceed with built-ins only, note it in the final report rather than failing the review.

Use the `create-local-specialist` skill (`plugins/review/skills/create-local-specialist/`) to scaffold new entries in this file — it keeps generated specialists conformant with the pattern this skill expects. See `plugins/review/skills/create-local-specialist/references/review-specialists.example.yaml` for a worked example.

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

Report which specialists will run before dispatching, e.g.: `"Running: basic-quality, security, diff-cleanliness, frontend, agent-payments (local) — skipping database (overridden by local agent-database), skipping accessibility (no matching files)"`.

**Opportunistic design context (never blocking):** if a Linear or Figma MCP tool is available this session, a quick best-effort check for linked ticket/design file can give specialists extra context on designer intent — but proceed identically whether or not this succeeds. Don't prompt user to set anything up.

### Step 4: Dispatch Specialists in Parallel

Launch every applicable specialist from Step 3 via Agent tool, all in same message so they run concurrently. Pass each specialist the diff content from Step 1 (not whole repo), instruct it to scope findings to changed lines — pre-existing issues in unchanged code out of scope.

- **Built-in specialists** dispatch by their registered subagent type (e.g. `agent-database`) as usual.
- **Local specialists** (new or overriding a built-in) aren't registered plugin agents, so dispatch them as a generic agent (e.g. `subagent_type: general-purpose`): read the file at `location` from Step 2, and pass its full content as the agent's operating instructions in the prompt, followed by the diff. Since the local file may not have access to `plugins/review/agents/CLAUDE.md`, restate the three shared rules inline in the dispatch prompt: report-only (never edit files), flag only >95% confidence findings, cite every finding with file:line and follow the `review-output-format` per-finding template.

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
- `.claude/review-specialists.yaml` (project-local, optional) — adds or overrides specialists per-project, see Step 2.
- `plugins/review/skills/create-local-specialist/` — scaffolds new local specialist files and registers them in `.claude/review-specialists.yaml`.
- Superpowers `requesting-code-review:code-reviewer` — general code-review quality reference this orchestration pattern draws from
