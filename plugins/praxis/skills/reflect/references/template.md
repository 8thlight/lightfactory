# Reflection Artifact Template

Use this template when writing the reflection artifact in Step 5. Replace placeholders with actual content from agent findings.

---

```markdown
# Session Reflection: {Topic}

**Date:** YYYY-MM-DD
**Session focus:** {Brief description of what was built/fixed/refactored}
**Skills used:** {List of skills invoked, e.g., /research, /plan-tasks, /implement}
**Duration signal:** {Number of commits, files changed — NOT a time estimate}

## What Happened

{2-4 sentence summary of the session: what was attempted, what was achieved, what was deferred.}

## What Worked Well

{Bulleted list of patterns, decisions, or approaches that went smoothly.}

- {Pattern or decision that helped}
- {Tool or workflow that was effective}

## Friction Points

{Bulleted list of moments where the session slowed down, went wrong, or required backtracking.}

- **{Category}:** {Description of friction and its impact}
- **{Category}:** {Description of friction and its impact}

## Missing Context

{Information that should have been available but wasn't — things that would have prevented friction if they were in CLAUDE.md, a skill, or a hook.}

- {What was missing and where it should live}

## Improvement Proposals

{Max 5 proposals, priority-ordered. Each follows this format:}

### Proposal 1: {Short title}

| Field | Value |
|-------|-------|
| **Type** | `{skill-update \| claude-md \| hook \| plan-template \| new-skill}` |
| **Priority** | {P1 \| P2 \| P3} |
| **Target** | `{file path}` |

**Current state:**
> {Quote the relevant section as it exists today, or "N/A — new addition"}

**Proposed change:**
{Describe the specific change. For skill-updates and claude-md, show the new/modified text. For hooks, show the JSON. For new-skill, provide a 3-5 line sketch.}

**Rationale:**
{Why this change would have prevented the friction or preserved the learning.}

---

{Repeat for each proposal, up to 5.}

## Deferred

{Anything noticed but not worth a proposal right now. Keep for future sessions.}

- {Observation that might matter later}
```
