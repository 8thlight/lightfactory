# ADR Template

This is the full copy-pasteable template. Copy the code block below into your ADR file and fill in every field. Field guidance follows the template.

````markdown
# ADR-NNNN: [Imperative verb phrase]

**Date:** YYYY-MM-DD
**Status:** Proposed | Accepted | Superseded by ADR-NNNN
**Author:** [Name]

## Context

[Describe the forces and constraints that led to this decision. 2-3 sentences.
Be value-neutral — don't justify the decision here, just state the situation.]

## Decision

[State the decision using the Y-statement in the philosphy.md reference in 1-2 sentences. Use active voice: "We will use X" not "X was chosen."]

## Options Considered

### [Selected Option] (Selected)

[1-2 sentence description.]

**Consequences:**
- Good: [positive outcome]
- Bad: [accepted tradeoff]

### [Alternative Option]

[1-2 sentence description.]

**Consequences:**
- Good: [what it would have provided]
- Bad: [why it was not chosen]

## Consequences

- Good: [primary benefit of the decision]
- Bad: [primary tradeoff accepted]

## Advice

_Recommended when multiple stakeholders are affected._

- [Name, Date]: [What they advised and any concerns raised]
````

---

## Field Guidance

- **Title**: Use an imperative verb phrase. Examples: "Use PostgreSQL for Persistence", "Adopt Event Sourcing for Order History". The title should be scannable in a file listing — someone reading the directory should understand the decision at a glance.

- **Status**: Start as `Proposed`. Move to `Accepted` after team review. Never edit an accepted ADR — write a new one that supersedes it and set the old status to `Superseded by ADR-NNNN`.

- **Context**: Forces, constraints, circumstances. No opinion. Think "a journalist would write this." The decision-maker's reasoning belongs in the Decision section, not here.

- **Decision**: Active voice. Short. "We will..." or "We adopt..." If you cannot write this in 1-2 sentences, the decision is not clear enough to record yet — write the Y-statement first (see `philosophy.md`).

- **Options Considered**: At minimum two options. Include "do nothing" or "status quo" when applicable. The selected option is marked `(Selected)`. Each option gets its own `Consequences` block with at least one good and one bad consequence.

- **Consequences**: Top-level summary of the chosen option's impact. Both upsides and accepted downsides. This section stands alone for readers who skip the options analysis.

- **Advice**: Name, date, and substance. "The team discussed" is not advice. "Jane (2026-02-15): Concerned about migration cost, suggested phased rollout" is advice. Advice is not consent — the decision-maker listens, records, and decides.
