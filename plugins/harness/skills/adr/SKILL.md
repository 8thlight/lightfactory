---
name: adr
description: Guides writing minimal Architecture Decision Records (ADRs). Use when recording architectural decisions, documenting design choices, capturing technical decisions with context and alternatives, or when user mentions ADR, architecture decision, or decision record.
triggers:
  - "architecture decision record"
  - "write an ADR"
  - "decision record"
  - "architectural decision"
  - "record a decision"
  - "create an ADR"
allowed-tools: Read Glob Write
---

# Architecture Decision Records

## Decision Filter

Before writing an ADR, check if the decision qualifies (Harmel-Law signals):

- Requires consulting multiple people to resolve
- Introduces a new technology or changes the tech radar stance
- Conflicts with an existing architectural principle
- Affects more than one team's autonomy

**If unsure:** The template itself is the filter. If you can't fill it in, it's probably not a decision worth recording.

## The Template

```markdown
# ADR-NNNN: [Imperative verb phrase]

**Date:** YYYY-MM-DD
**Status:** Proposed | Accepted | Superseded by ADR-NNNN
**Author:** [Name]

## Context
[2-3 sentences. Forces and constraints. Value-neutral.]

## Decision
[1-2 sentences. Active voice. "We will..."]

## Options Considered
- **Option A** — [one line]
- **Option B** — [one line]

## Consequences
- Good: [positive outcome]
- Bad: [accepted tradeoff]

## Advice
- [Name, Date]: [What they said]
```

Full template with field guidance: [references/template.md](references/template.md)

## Workflow

1. **Decide if an ADR is needed** — Run through the decision filter above. Skip if no signals match.

2. **Start with a Y-statement** — Forcing function to clarify the decision before writing:
   > "In the context of _____, facing _____, we decided for _____, to achieve _____, accepting _____."
   If you can't complete this sentence, the decision isn't clear enough to record yet.

3. **Create the ADR file** — Naming: `NNNN-kebab-case-title.md` (4-digit zero-padded). Directory: `docs/decisions/`. Check existing files to determine the next number:
   ```
   ls docs/decisions/
   ```

4. **Fill in the template** — Section by section:
   - **Context**: State forces and constraints. Value-neutral tone. Don't justify the decision here.
   - **Decision**: Active voice. "We will use X." Not "X was chosen."
   - **Options Considered**: At least 2 options. Include "do nothing" if applicable. One line each — detail goes in consequences.
   - **Consequences**: Both good and bad for the chosen option. Be honest about tradeoffs.
   - **Advice**: Recommended when multiple stakeholders are affected. Record name, date, and what they said. Advice is not consent — the decision-maker listens, records, and decides.

5. **Finalize** — Set status to `Proposed`. Commit the ADR alongside the code change it documents (same PR). Update status to `Accepted` after review and approval.

## Naming Conventions

- File: `NNNN-kebab-case-title.md` — e.g., `0001-use-postgresql-for-persistence.md`
- Title: Imperative verb phrase — e.g., "Use PostgreSQL for Persistence"
- Directory: `docs/decisions/`

## Status Lifecycle

- **Proposed** → Initial state when ADR is written
- **Accepted** → Approved and in effect
- **Superseded by ADR-NNNN** → Replaced by a newer decision (link to the superseding ADR)

ADRs are immutable once accepted. To change a decision, write a new ADR that supersedes the old one.

## Anti-Patterns

**Retroactive ADRs** — Writing ADRs long after the decision was made. Record decisions when they happen.

**Bikeshedding Status** — Agonizing over Proposed vs Accepted. Start as Proposed, move to Accepted when the team agrees.

**Skipping Options** — Recording only the chosen option. The value is in showing what was considered and why alternatives were rejected.

**Missing Advice Attribution** — "The team agreed" instead of who said what. Name names and dates.

**Over-Scoping** — Trying to capture every technical choice. ADRs are for architecturally significant decisions, not implementation details.

## When NOT to Use

- Trivial decisions with obvious answers
- Decisions already made and shipped long ago (unless capturing for onboarding context)
- Implementation details that don't affect architecture
- Temporary spikes or experiments

## References

- [Full template with field guidance](references/template.md)
- [Harmel-Law philosophy and Y-statement examples](references/philosophy.md)
- [ADR format comparison (Nygard vs MADR vs Harmel-Law)](references/comparison.md)
