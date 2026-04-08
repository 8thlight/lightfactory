# ADR Philosophy

## Architecture as Distributed Practice

The core insight from Andrew Harmel-Law's "Facilitating Software Architecture" is that architecture is not a centralized role. Anyone can make architectural decisions — provided they follow the advice process. The locus of authority shifts from a designated architect to the person closest to the problem, constrained by a lightweight accountability mechanism.

The advice process (borrowed from Laloux's "Reinventing Organizations"): before making a decision, seek advice from (1) those meaningfully affected and (2) subject matter experts. Advice is not consent — the decision-maker listens, records, and decides. The obligation is to consider the advice, not to follow it.

ADRs become the organization's "decision lore": searchable, auditable records that help new team members understand why things are the way they are. An ADR is not a changelog entry — it captures the context and reasoning that made the decision reasonable at the time, including the voices that were heard.

## The Advice Process

- Identify who is affected by the decision
- Identify subject matter experts
- Seek their advice (1:1, async, or via an Architecture Advisory Forum)
- Record advice with attribution: name, date, substance
- Make the decision — you are not bound by the advice, but you must consider it
- The Advice section in the ADR makes dissent visible and auditable

## Y-Statement

The Y-statement (Zdun et al.) is a single-sentence forcing function. If you cannot complete it, the decision is not clear enough to record.

**Format:** "In the context of [situation], facing [concern], we decided for [option], to achieve [quality], accepting [downside]."

**Examples:**

> "In the context of order processing, facing high write contention, we decided for event sourcing, to achieve auditability and temporal queries, accepting increased read complexity."

> "In the context of API authentication, facing multiple consumer types, we decided for JWT with short-lived tokens, to achieve stateless verification, accepting the need for a refresh token flow."

> "In the context of frontend state management, facing growing component complexity, we decided for React Context with reducers, to achieve simpler dependency graph, accepting less middleware flexibility than Redux."

Write the Y-statement before filling in the template. If you cannot write it, keep discussing until you can.

## Sources

- Andrew Harmel-Law, "Facilitating Software Architecture" (2023)
- Andrew Harmel-Law, "Scaling Architecture Conversationally" (martinfowler.com)
- Uwe Zdun et al., "Sustainable Architectural Decisions" (WICSA 2015)
