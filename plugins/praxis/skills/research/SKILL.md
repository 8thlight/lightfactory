---
name: research
description: Research phase of RPI methodology. Spawns parallel subagents for codebase exploration AND web/pattern research, then synthesizes findings for user review. Produces a temporary research artifact at .light/sessions/ and transitions into plan mode. Use before implementing non-trivial features to understand what already exists.
triggers:
  - "research the codebase"
  - "explore codebase"
  - "investigate the code"
  - "research before implementing"
allowed-tools: Read Glob Grep Task TaskOutput WebSearch WebFetch AskUserQuestion Write EnterPlanMode Bash(plannotator:*)
---

# Research Skill

**RPI Phase 1 of 3:** Research → Plan → Implement

Use this skill at the start of non-trivial features to explore the codebase AND research external patterns before planning or implementing.

## Phase Contract

**Receives:** User's feature description (or codebase context from previous conversation)
**Produces:** Temporary research artifact at `.light/sessions/{topic}-research.md` (~200 lines)
**Hands off to:** Plan mode — entering plan mode is the context compaction boundary where draft behavior activates

## Purpose

The Research phase prevents thrashing and discovers constraints early by:
- Exploring relevant parts of the codebase in parallel
- Researching external patterns, libraries, and best practices
- Identifying existing patterns and architectural boundaries
- Understanding dependencies and integration points
- Uncovering constraints before they become blockers

**Output:** Temporary research artifact (~200 lines) at `.light/sessions/{topic}-research.md`

## When to Use

Use this skill when:
- Starting work on a non-trivial feature
- Need to understand how a new feature fits into existing architecture
- Want to discover existing patterns before creating new ones
- Need to identify integration points and dependencies
- Working in an unfamiliar part of the codebase
- Need to evaluate external libraries or architectural approaches

**Don't use** for:
- Simple bug fixes
- Trivial features with obvious implementation
- Pure research tasks (use Explore agent instead)

## Depth Levels

| Depth | Codebase Agents | Web Agents | When to Use |
|-------|----------------|------------|-------------|
| Quick | 2-3 | 0-1 | Well-understood pattern, single codebase area, no external unknowns |
| Standard | 3-4 | 1-2 | Multiple codebase areas affected, some external patterns to validate |
| Deep | 4-5 | 2-3 | Unfamiliar domain, new technology, multiple integration points |

**Choosing depth:** Infer the appropriate depth from the user's prompt using these signals:

| Signal | Points toward |
|--------|--------------|
| User names a specific file or function to change | Quick |
| Feature touches one module with known patterns | Quick |
| Feature spans multiple modules or layers | Standard |
| User mentions a library, API, or pattern they haven't used before | Standard or Deep |
| Feature involves new technology, unfamiliar domain, or architectural change | Deep |
| User explicitly says "quick look" or "just check" | Quick |
| User explicitly says "deep dive" or "thorough" | Deep |

**Not all research needs web agents.** If the feature is purely internal (no new libraries, APIs, or unfamiliar patterns), skip web research entirely and dispatch only codebase agents.

**When uncertain**, ask the user with `AskUserQuestion` — briefly explain what you'd investigate at each level and let them choose. Do NOT default to a deeper level than the prompt warrants.

## Workflow

### 1. Define Research Scope

Ask the user to clarify the research scope if needed:
- What is the feature or capability being built?
- Which architectural boundaries are likely affected?
- Are there specific concerns or constraints?

Based on the chosen depth, decompose the scope into:
- **Codebase investigation areas** (2-5 depending on depth)
- **Web research topics** (0-3 depending on depth)

### 2. Dispatch Parallel Agents

**CRITICAL: Dispatch ALL agents in a SINGLE message using multiple Task tool calls with `run_in_background: true`.**

Two agent types — see [agent prompts](references/agent-prompts.md) for full templates:

**Codebase Explorer** (subagent_type: `Explore`)
- Receives one investigation area
- Uses Read/Glob/Grep to examine up to 10 files
- Reports: files examined, patterns observed, architectural notes, relevance, gaps

**Web Researcher** (subagent_type: `general-purpose`)
- Receives one research topic + feature context
- Uses WebSearch/WebFetch to consult 2-4 sources
- Reports findings with **High/Medium/Low** confidence levels

### 3. Collect Agent Results

- Poll agents with `TaskOutput block: false` to check progress
- Collect completed results with `TaskOutput block: true`
- If an agent returns thin results, note the gap — do NOT dispatch a follow-up agent

### 4. Synthesize and Write Artifact

Cross-reference codebase patterns against web findings:
- Align codebase patterns with web best practices
- Surface contradictions as open questions
- Discard irrelevant web findings that don't apply to the codebase context
- Low-confidence web findings become **Open Questions** unless corroborated by codebase evidence
- Flag contested findings where web sources disagree

Write the research artifact **immediately** to disk:
```
.light/sessions/{topic}-research.md
```

Use the [research artifact template](references/template.md). Target ~200 lines. Use kebab-case for the topic slug — make it descriptive of the feature (e.g., `add-discount-codes`, `user-auth-refresh-tokens`).

### 5. Review with User

**REQUIRED — Do not skip this step.**

Check if plannotator is available:
```
Bash: plannotator --version
```

**If plannotator is available:**
Run `plannotator annotate .light/sessions/{topic}-research.md` via Bash. This opens the artifact in a browser annotation UI and blocks until the user submits.
- **Non-empty annotations returned:** Address each annotation by updating the artifact with `Write`, then re-run `plannotator annotate` on the same file. Repeat until empty annotations.
- **Empty annotations returned:** The user is satisfied. Proceed to Step 6.

**If plannotator is not available (command not found):**
Fall back to `AskUserQuestion`: present a summary of key findings (3-5 bullet points) and the artifact path. If the user requests edits → update the artifact with `Write`, then ask again. Repeat until approved.

### 6. Transition to Plan Mode

Use `AskUserQuestion` to present the following options:

```
Research complete. Artifact saved: `.light/sessions/{topic}-research.md`

What would you like to do next?

1. Enter plan mode — begin planning (recommended)
2. Request more research — describe what else to investigate
3. Edit the artifact — describe changes and I'll update it
```

Replace `{topic}` with the actual artifact path.

- **Option 1:** Call `EnterPlanMode`. This transitions into the planning phase where draft behavior activates. The plan mode entry IS the context compaction boundary — it replaces the old `/clear` ritual. The research artifact at `.light/sessions/` will be read during planning.
- **Option 2:** Return to Step 2 (dispatch additional agents), then repeat Steps 4-6.
- **Option 3:** Update artifact with `Write`, then re-present Step 6 options.

**After entering plan mode, STOP. Draft behavior takes over inside plan mode.**

## Anti-Patterns to Avoid

- **Don't copy entire files** — note file paths and purpose only
- **Don't write code yet** — this is research, not implementation
- **Don't create plans** — that happens in plan mode (draft behavior)
- **Don't research sequentially** — use parallel agents dispatched in a single message
- **Don't include irrelevant details** — stay focused on the feature
- **Don't present web findings without confidence levels** — every web finding needs High/Medium/Low
- **Don't trust a single web source** — cross-reference when possible

## Context Compaction

**Why research first?** The research phase is a compaction point:
- **Before research:** Entire codebase + unbounded web knowledge (too much context)
- **After research:** Compact artifact (~200 lines, only relevant details from both sources)
- **Plan mode** works from compact artifact, not raw codebase or web searches
- **Entering plan mode** is the boundary — research context stays behind, only the artifact carries forward
