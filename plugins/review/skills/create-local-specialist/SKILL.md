---
name: create-local-specialist
description: Scaffold a project-local review specialist agent that plugs into the `review` skill via `.claude/review-specialists.yaml`, without editing the review plugin itself. Use when a user wants to add a custom review specialist scoped to their own project (e.g. domain-specific checks, or a specialist that overrides a built-in one like agent-database), or asks to "add a review specialist," "create a local review agent," "override the database reviewer for this project."
triggers:
  - "add a review specialist"
  - "create a local review agent"
  - "override the review specialist"
  - "add a custom reviewer"
allowed-tools: Read Write Edit Glob
---

# Create Local Specialist

Scaffolds a project-local specialist for the `review` skill (`plugins/review/skills/review/`) — one that lives in the *consuming* project, not this plugin, discovered via `.claude/review-specialists.yaml`. Use this instead of hand-writing a specialist file so the generated agent matches the pattern `review`'s orchestrator expects and gets registered correctly.

## Workflow

### Step 1: Gather Requirements

Ask (or infer from context) if not already clear:

- **Name** — kebab-case, e.g. `agent-payments`. If it matches a built-in specialist name (`agent-database`, `agent-frontend`, `agent-accessibility`, `agent-react`, `agent-rails`, `agent-stimulus-turbo`, `agent-ci-conventions`, `agent-basic-quality`, `agent-security`, `agent-diff-cleanliness`), confirm the user actually intends to **override** that built-in, not create an unrelated specialist that happens to collide.
- **Purpose/scope** — what domain this specialist reviews, in one or two sentences.
- **Dispatch condition** — what changed-file pattern or condition should trigger it (e.g. "changed files include `app/services/payments/*`").
- **Checks** — the specific patterns to catch. Ask for at least one concrete Bad/Good example per check; if the user only has a vague idea, help turn it into a checkable pattern rather than scaffolding a vague specialist.

### Step 2: Determine Location

Default: `.claude/review-specialists/<name>.md` in the project root. Confirm with the user if they want a different path — relative or absolute both work with `review`'s loader.

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

Same file, same location as Step 4a — but the `## Checks` section is replaced with a **Detection Table**, and each category's actual checklist moves to its own file in a `references/` directory sitting next to the specialist file (e.g. `.claude/review-specialists/references/<name>-<category>.md` for the default location from Step 2). This mirrors `agent-accessibility.md` exactly — read it if you need a worked example.

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

- [ ] Frontmatter has `name` matching the intended registry name, `description` stating purpose + report-only, no XML tags
- [ ] Inline shape: at least one Check with a concrete Bad/Good example, not just a vague description. Reference-file shape: Detection Table has a real trigger per category, and every reference file has at least one concrete Bad/Good example
- [ ] Output Format section present, matching the shared per-finding template — don't invent a different shape
- [ ] Rules section states report-only, >95% confidence threshold, and file:line citation — inline, since the local file can't rely on the plugin's shared `CLAUDE.md`
- [ ] File is self-contained — no reference to `plugins/review/agents/...` paths a project won't have
- [ ] Reference-file shape only: reference files actually live in `references/` next to the specialist file, and every Detection Table row's file path resolves to one that exists

### Step 6: Register in `.claude/review-specialists.yaml`

Create the file if it doesn't exist (repo root, alongside `.claude/settings.json`). Read existing content first if present — this is an append/merge, not an overwrite of the whole file.

```yaml
specialists:
  - name: <name>
    dispatch_condition: "<condition from Step 1>"
    location: <path from Step 2>
```

See `references/review-specialists.example.yaml` for a worked example with both a new specialist and a built-in override side by side.

- If `<name>` already exists in the file, confirm with the user this is an intentional replacement (overriding their own prior local specialist, not silently clobbering it) before overwriting that entry.
- If `<name>` matches a built-in, remind the user: from now on, `review` will use this local file instead of the built-in for every run in this project, until the entry is removed or renamed.

### Step 7: Confirm

Tell the user what was created and where, and that it takes effect the next time the `review` skill runs in this project — no plugin changes needed, nothing to reinstall.

## Related

- `plugins/review/skills/review/SKILL.md` — Step 2 (loads this config), Step 4 (dispatches local specialists as generic agents)
- `plugins/review/skills/review-output-format/SKILL.md` — canonical per-finding template this scaffold mirrors
- `plugins/review/agents/CLAUDE.md` — shared rules this scaffold inlines, since local files can't assume plugin context is available
- `plugins/review/agents/agent-accessibility.md` and `plugins/review/agents/references/` — worked example of the detection-table + reference-files shape Step 4b mirrors
- `references/review-specialists.example.yaml` — example `.claude/review-specialists.yaml` content, Step 6
