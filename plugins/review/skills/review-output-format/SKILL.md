---
name: review-output-format
description: Canonical per-finding markdown template and severity tier definitions (CRITICAL/MAJOR/MINOR) shared by every review specialist agent in plugins/review/agents/. Internal formatting contract, not user-triggered directly — invoked by review specialists and the review orchestrator to keep report structure consistent across specialists.
triggers:
  - "review output format"
disable-model-invocation: true
allowed-tools: Read
---

# Review Output Format

Canonical output contract for every specialist in `plugins/review/agents/`. Behavioral rules governing report content (confidence threshold, report-only, domain ownership) live in `plugins/review/agents/CLAUDE.md` — this skill only defines the shape of a finding.

## Per-Finding Template

```markdown
### [CRITICAL/MAJOR/MINOR] <Issue Title>
- **Location:** file:line
- **Category:** <specialist-specific category, if the agent defines categories>
- **Issue:** <what's wrong>
- **Impact:** <why it matters>
- **Fix:** <how to resolve, with a code example where useful>
```

If no issues are found in a category, say so explicitly — e.g. "No basic quality issues found." Never omit the report or leave it implicit; an empty result is a real result, not a gap.

Some specialists extend this template with an extra field where their domain needs it (e.g. `agent-stimulus-turbo` adds a **Reference** field linking the Hotwire docs). Extending is fine; redefining the core fields is not.

## Severity Tiers

- **CRITICAL** — causes crashes, data loss, security exposure, or a broken production path. Blocking.
- **MAJOR** — a real defect or convention violation that degrades quality, maintainability, or correctness, but isn't immediately catastrophic.
- **MINOR** — style, naming, or small optimization opportunities.

Each specialist maps its own domain-specific examples onto these three tiers in its own "Severity Guidelines" section — the tier definitions themselves don't get redefined per agent.

## Exception: agent-accessibility

`agent-accessibility` reports natively in High/Medium/Low, not CRITICAL/MAJOR/MINOR, because its findings map onto WCAG conformance impact rather than general code-defect severity. The review orchestrator normalizes CRITICAL→High, MAJOR→Medium, MINOR→Low when compiling the combined report (see `plugins/review/skills/review/SKILL.md`, Step 4).
