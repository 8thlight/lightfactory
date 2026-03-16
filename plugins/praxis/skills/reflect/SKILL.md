---
name: reflect
description: Post-session skill to reflect on what was built and produce improvement proposals. Reads recent git history, artifacts, and context files to extract learnings for skills, CLAUDE.md, hooks, and plan templates. Use after any substantive session as a post-mortem or retrospective.
triggers:
  - "reflect on session"
  - "session retrospective"
  - "session reflection"
  - "what did we learn"
  - "post-mortem review"
allowed-tools: Read Glob Grep Bash Task TaskOutput Write AskUserQuestion EnterPlanMode ExitPlanMode
---

# Reflect Skill

**Post-session learning loop:** Capture what worked, what caused friction, and embed those insights back into the codebase's context engineering.

## Purpose

After coding sessions, learnings about workflow friction, missing context, and skill gaps evaporate. The Reflect skill closes this loop by:
- Mining git history and artifacts for what actually happened
- Identifying friction points and successful patterns
- Producing concrete improvement proposals for skills, CLAUDE.md, hooks, and templates
- Applying approved improvements with atomic commits

**Output:** Reflection artifact at `.light/YYYY-MM-DD-{topic}-reflection.md`

## When to Use

Use this skill when:
- A substantive session just finished (feature, refactor, debugging)
- Workflow friction was noticeable during the session
- A skill felt incomplete or produced unexpected results
- New conventions emerged that should be documented
- CLAUDE.md or hooks need updating based on experience

**Don't use** for:
- Mid-session course corrections (just fix it directly)
- Trivial sessions with no learnings
- Reviewing someone else's work (use code review instead)

## Workflow

### 1. Establish Session Context — BEFORE Plan Mode

If the trigger includes a topic, use it. Otherwise, use `AskUserQuestion` to ask:
- What session or feature did you just finish?
- Which skill(s) did you use (if any)?
- What felt off or notably well?

Derive a reflection slug from the topic (e.g., `auth-feature`, `payment-refactor`).

### 2. Dispatch 4 Parallel Context Agents — BEFORE Plan Mode

**CRITICAL: Dispatch ALL agents in a SINGLE message with `run_in_background: true`.**

Agents need full tool access, so this step MUST happen before plan mode.

See [agent prompts](references/agent-prompts.md) for full templates.

| Agent | Type | What It Reads |
|-------|------|---------------|
| Git Historian | Explore | `git log --oneline -20`, `git diff HEAD~5..HEAD --stat` |
| Artifact Scout | Explore | `.light/` files from last 14 days |
| Context Reader | Explore | `./CLAUDE.md`, `~/.claude/CLAUDE.local.md`, `.claude/settings.json` |
| Skill Inspector | Explore | SKILL.md files for skills used in the session |

#### Agent Dispatch Manifest

The reflection artifact MUST include an **Agent Dispatch Manifest** table documenting the agents dispatched:

```markdown
## Agent Dispatch Manifest
| Agent | Type | Status | Key Finding |
|-------|------|--------|-------------|
| Git Historian | Explore | completed | {1-line summary} |
| Artifact Scout | Explore | completed | {1-line summary} |
| Context Reader | Explore | completed | {1-line summary} |
| Skill Inspector | Explore | completed | {1-line summary} |
```

This table provides observable evidence of parallel agent dispatch.

#### Git Unavailable Fallback

If git is unavailable (e.g., eval sandbox), include a **Commits (Simulated)** section in the reflection artifact listing the commits that would have been created:

```markdown
## Commits (Simulated)
- `reflect: {description of improvement 1}`
- `reflect: {description of improvement 2}`
```

### 3. Collect Agent Results — BEFORE Plan Mode

- Poll agents with `TaskOutput block: false` to check progress
- Collect completed results with `TaskOutput block: true`
- If `TaskOutput` is unavailable, run agents in foreground mode (omit `run_in_background`) and collect results directly
- If an agent returns thin results, note the gap — do NOT dispatch a follow-up

### 4. Enter Plan Mode

Call `EnterPlanMode` — synthesis is a read/write-only activity.

### 5. Synthesize and Write Reflection Artifact — IN Plan Mode

Use the [reflection artifact template](references/template.md) to structure the output.

Cross-reference agent findings to identify:
- **What worked well** — patterns to preserve or document
- **Friction points** — where the session slowed down or went wrong
- **Missing context** — information that should have been in CLAUDE.md or skills
- **Improvement proposals** — concrete changes to make

Categorize each improvement using the taxonomy from the [improvement guide](references/improvement-guide.md).

**Improvement types:**

| Type | Target | Example |
|------|--------|---------|
| `skill-update` | A SKILL.md | Add missing anti-pattern to /implement |
| `claude-md` | ./CLAUDE.md or ~/.claude/CLAUDE.local.md | Document new convention |
| `hook` | .claude/settings.json | Add PreToolUse reminder |
| `plan-template` | A references/template.md | Add missing section |
| `new-skill` | New skill directory (sketch only) | Outline a /standup skill |

**Constraints:**
- Cap at **5 proposals max**, priority-ordered
- Each proposal includes: Type, Priority (P1-P3), Target file, Current state (quoted), Proposed change, Rationale

Write the reflection artifact to the plan file.

### 6. Exit Plan Mode — User Reviews

Call `ExitPlanMode` to present the reflection for review.

Then use `AskUserQuestion` to list each proposal with its type and target. Ask the user to pick: **All / None / specific items by number**.

### 7. Apply Approved Improvements

For each approved proposal:
1. Read the target file
2. Apply the change using `Edit` or `Write`
3. Commit with message: `reflect: <description>`

One improvement per commit. Do NOT bundle multiple changes.

### 8. Persist Artifact

Save the reflection artifact:
```
.light/YYYY-MM-DD-{topic}-reflection.md
```

Commit with: `reflect: add session reflection for {topic}`

## Anti-Patterns to Avoid

- **Don't invent problems** — only propose improvements for friction that actually occurred during the session
- **Don't propose more than 5 improvements** — prioritize signal over noise
- **Don't bundle multiple fixes in one commit** — one improvement per commit
- **Don't update `~/.claude/CLAUDE.md`** — it's auto-overwritten by tech-pass; use `~/.claude/CLAUDE.local.md`
- **Don't add hooks that already exist** — read `.claude/settings.json` first
- **Don't dispatch agents inside plan mode** — they need full tool access; dispatch before entering plan mode
- **Don't propose sweeping rewrites** — small, targeted improvements compound better

## After Reflect

Once improvements are applied:
1. Review the reflection artifact in `.light/`
2. Verify applied changes with `git log --oneline -5`
3. Consider whether any deferred proposals should become issues or tasks
4. The next session benefits automatically from the updated context
