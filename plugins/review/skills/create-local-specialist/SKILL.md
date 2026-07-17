---
name: create-local-specialist
description: Scaffold a project-local review specialist as a real registered Claude Code subagent (`.claude/agents/<name>.md`) that plugs into the `specialist-review` skill, without editing the review plugin itself. Use when a user wants to add a custom review specialist scoped to their own project (e.g. domain-specific checks, or a specialist that overrides a built-in one like agent-database), or asks to "add a review specialist," "create a local review agent," "override the database reviewer for this project."
triggers:
  - "add a review specialist"
  - "create a local review agent"
  - "override the review specialist"
  - "add a custom reviewer"
allowed-tools: Read Write Edit Glob
---

# Create Local Specialist

Scaffolds a project-local specialist for the `specialist-review` skill (`plugins/review/skills/specialist-review/`) as a real Claude Code project agent — one that lives in the *consuming* project's `.claude/agents/`, not this plugin. Use this instead of hand-writing a specialist file so the generated agent matches the pattern `specialist-review`'s orchestrator expects and gets registered correctly.

**Important — takes effect next session, not this one.** Claude Code discovers `.claude/agents/*.md` files at session start; a file written mid-session isn't callable as a `subagent_type` until the session restarts. Tell the user this plainly in Step 7 — it isn't a bug, it's how project-agent registration works.

## Workflow

### Step 1: Gather Requirements

Ask (or infer from context) if not already clear:

- **Name** — kebab-case, e.g. `agent-payments`. If the intent is to **override** a built-in specialist (`agent-database`, `agent-frontend`, `agent-accessibility`, `agent-react`, `agent-rails`, `agent-stimulus-turbo`, `agent-ci-conventions`, `agent-basic-quality`, `agent-security`, `agent-diff-cleanliness`), give the local specialist its **own distinct name** (e.g. `agent-database-local`) rather than reusing the built-in's name — whether a project-registered agent actually shadows a plugin-registered one of the identical name is unverified, so don't rely on it. The `overrides:` frontmatter field (Step 4) is what tells `specialist-review` to skip the built-in, not name collision.
- **Purpose/scope** — what domain this specialist reviews, in one or two sentences.
- **Dispatch condition** — what changed-file pattern or condition should trigger it (e.g. "changed files include `app/services/payments/*`").
- **Checks** — the specific patterns to catch. Ask for at least one concrete Bad/Good example per check; if the user only has a vague idea, help turn it into a checkable pattern rather than scaffolding a vague specialist.

### Step 2: Determine Location

Default: `.claude/agents/<name>.md` in the project root — the diffed repo's own git top-level. This is Claude Code's own project-agent directory, not a plugin-specific location — the file must live where the session actually discovers project agents.

**If the repo is nested inside a non-git parent workspace** (e.g. a client-engagement folder containing the actual app repo as an untracked subdirectory with its own independent git history), agent discovery is tied to wherever the Claude Code session is launched from — ask the user where that is. If sessions for this repo are launched from the parent workspace root, `.claude/agents/` must live there, not inside the nested repo, or the session won't discover it. Don't assume the repo's own git top-level is the right place.

### Step 3: Decide Inline vs. Reference-File Shape

Same rule the built-in specialists follow (`plugins/review/agents/CLAUDE.md`, "Architecture: one agent, reference files on demand" — `agent-accessibility.md` is the canonical example): keep the specialist lean, push bulk into `references/` read on demand.

Go inline (Step 4a) when there are roughly 3 or fewer checks and each fits in a few lines. Split into a detection table + reference files (Step 4b) when:

- There are 4+ distinct checks, or
- Any single check needs enough content (multiple examples, a sub-checklist, framework-specific nuance) that inlining it would bloat the specialist file, or
- The checks naturally group into categories a diff will only sometimes touch (e.g. "payments webhooks" vs. "payments refund flow") — no reason to pay the token cost of every category on every dispatch.

Don't split just to split — a specialist with two tight checks stays inline. The goal is the same as upstream: one specialist file scans cheaply every time, detail costs tokens only when its trigger actually fires.

### Step 4a: Scaffold the Specialist File (inline shape)

Write the file at the location from Step 2. It MUST be self-contained — a project may not have the `review` plugin's source on disk, so inline the shared rules rather than referencing `plugins/review/agents/CLAUDE.md`.

```markdown
---
name: <name>
description: "<one or two sentence purpose + when the orchestrator should dispatch this>. Report-only — never modifies files."
model: sonnet
review_specialist: true   # required marker — specialist-review ignores any .claude/agents/*.md file without this, even if it has a dispatch_condition field, since an unrelated custom agent could coincidentally define one
dispatch_condition: "<condition from Step 1, verbatim — this is what specialist-review's Step 2/3 reads to classify and dispatch this specialist>"
overrides: <built-in-name>   # omit this line entirely if not overriding a built-in
---

# <Title> Review

## Purpose

<what this catches, why it matters>

## Scope

- <bullet list of what's in scope>

## Checks

### <Check Name>

**Pattern:** <what to detect>

**Why:** <consequence if missed>

**Example:**

\`\`\`<language>
# Bad
<example>

# Good
<example>
\`\`\`

**Check:**
- <how to verify — grep pattern, question to ask, etc.>

**Flag if:**
- <concrete trigger condition>

<repeat per check>

## Output Format

### [CRITICAL/MAJOR/MINOR] <Issue Title>
- **Location:** file:line
- **Issue:** <what's wrong>
- **Impact:** <why it matters>
- **Fix:** <how to resolve>

No issues found → say so explicitly, e.g. "No <domain> issues found."

Severity: **CRITICAL** = crashes/data loss/security/broken prod path. **MAJOR** = real defect or convention violation, not immediately catastrophic. **MINOR** = style/naming/small optimization.

## Rules

- Report-only. Never modify files, never auto-fix — describe the fix, human applies it.
- Flag only findings you're >95% confident are real defects. A missed issue costs less than a false positive — false positives erode trust and get specialists ignored.
- Every finding needs a file:line citation.
- No praise or fluff — findings only.

## Out of Scope

- <domains this specialist explicitly defers to other specialists, if any>
```

### Step 4b: Scaffold the Specialist File (detection-table + reference-files shape)

Same file, same location as Step 4a — but the `## Checks` section is replaced with a **Detection Table**, and each category's actual checklist moves to its own file in a `references/` directory sitting next to the specialist file (e.g. `.claude/agents/references/<name>-<category>.md` for the default location from Step 2). This mirrors `agent-accessibility.md` exactly — read it if you need a worked example.

Specialist file — Detection Table replaces `## Checks`:

```markdown
## Detection Table

Fast scan per category below; `Read` the matching reference file only when its trigger pattern actually appears in the diff. Non-matching categories cost nothing beyond the one-line scan.

| Category | Trigger (scan for this first) | Reference file |
|---|---|---|
| <Category A> | <what to scan for> | `references/<name>-<category-a>.md` |
| <Category B> | <what to scan for> | `references/<name>-<category-b>.md` |

## Workflow

1. Read diff. For each row above, one-line scan the "Trigger" column against changed lines + immediate context — not the whole file.
2. For every category whose trigger is present, `Read` that category's reference file, apply its checklist to the specific instances found.
3. Compile findings into Output Format below.
```

Each reference file gets the detail a Step 4a inline Check would have held — same Pattern/Why/Example/Check/Flag-if shape, just one category per file:

```markdown
# <Category Name> — <Specialist Title> Reference

## <Check Name>

**Pattern:** <what to detect>

**Why:** <consequence if missed>

**Example:**

\`\`\`<language>
# Bad
<example>

# Good
<example>
\`\`\`

**Check:**
- <how to verify>

**Flag if:**
- <concrete trigger condition>

<repeat per check within this category>
```

The specialist file still carries its own `## Output Format`, `## Rules`, and `## Out of Scope` sections exactly as in Step 4a — only `## Checks` is replaced by the Detection Table, and detail moves out to `references/`.

### Step 5: Validate Against Checklist

- [ ] Frontmatter has `name` (distinct from any built-in if this overrides one — see Step 1), `description` stating purpose + report-only, `review_specialist: true` (required — without it, `specialist-review` won't recognize this file at all), `dispatch_condition` set verbatim from Step 1, `overrides:` present only if actually overriding a built-in, no XML tags
- [ ] Inline shape: at least one Check with a concrete Bad/Good example, not just a vague description. Reference-file shape: Detection Table has a real trigger per category, and every reference file has at least one concrete Bad/Good example
- [ ] Output Format section present, matching the shared per-finding template — don't invent a different shape
- [ ] Rules section states report-only, >95% confidence threshold, and file:line citation — inline, since the local file can't rely on the plugin's shared `CLAUDE.md`
- [ ] File is self-contained — no reference to `plugins/review/agents/...` paths a project won't have
- [ ] File lives at `.claude/agents/<name>.md` in the location confirmed in Step 2 — not a plugin-specific directory
- [ ] Reference-file shape only: reference files actually live in `references/` next to the specialist file, and every Detection Table row's file path resolves to one that exists
- [ ] If `<name>` already exists at that path, confirmed with the user this is an intentional replacement, not silently clobbering their prior local specialist

### Step 6: Confirm and Flag the Restart Requirement

Tell the user, explicitly and without burying it:

1. What was created and where (`.claude/agents/<name>.md`).
2. What it does and what triggers it (`dispatch_condition`), and what it overrides if anything.
3. **It is not usable yet this session.** Claude Code discovers `.claude/agents/*.md` at session start — until the user restarts their Claude Code session, `<name>` isn't a resolvable `subagent_type` and `specialist-review` cannot dispatch it. After restarting, the next `specialist-review` run will pick it up automatically — nothing else to register, no plugin changes, no reinstall.

## Related

- `plugins/review/skills/specialist-review/SKILL.md` — Step 2 (discovers `.claude/agents/*.md` local specialists via the `review_specialist: true` marker plus `dispatch_condition`/`overrides` frontmatter), Step 4 (dispatches local specialists by `subagent_type` same as built-ins)
- `plugins/review/skills/review-output-format/SKILL.md` — canonical per-finding template this scaffold mirrors
- `plugins/review/agents/CLAUDE.md` — shared rules this scaffold inlines, since local files can't assume plugin context is available
- `plugins/review/agents/agent-accessibility.md` and `plugins/review/agents/references/` — worked example of the detection-table + reference-files shape Step 4b mirrors
