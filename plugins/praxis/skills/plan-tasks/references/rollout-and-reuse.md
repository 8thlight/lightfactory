# Rollout, Risks and Reuse

How `/plan-tasks` writes a plan's `## Rollout Phases` and `## Risks & Mitigations` sections, and how research's reuse candidates reach the phases.

## Rollout and Risks

Write these two sections last, once the draft plan has its phases. Run the `praxis:technical-project-manager` agent with `mode: plan` for every plan. For new features and epics it is required: do not present the plan for review without its two sections. Pass:
- **Research artifact path** (or "none")
- **Ticket or epic** — text or URL
- **Linked plans, runbooks, ADRs** — anything the ticket or epic links to, as content or URLs
- **Draft plan path** — `.light/sessions/{topic}-plan.md`

Insert the `## Rollout Phases` and `## Risks & Mitigations` sections it returns into the plan, and apply its **Plan changes** (a phase to add, scope to move out). Then make each row whose evidence lives in the repo an acceptance criterion: add it to the plan's `## Acceptance Criteria`, and to the test spec of the phase it's tagged with (for a `no-test` phase, its Acceptance gate). agent-test then writes a failing test for it and agent-impl makes that test pass, so the agents build what the slice review checks. Rows whose evidence lives outside the repo (a runbook step, a metric to watch) stay in the table only; `/implement` carries them as known issues.

The tags are the phase group names Step 5 creates (`P{N}-{Name}`, e.g. `P2-Core-Logic`). If you add, rename or renumber phases afterwards, update the tags to match.

## Reuse Before Re-deriving

An implementation phase that mirrors an existing implementation listed under the research artifact's `### Reuse candidates` — a rule, a planner, a preview or dry-run of a job — must call it, or refactor it so both callers share one path. If it can't, record why under Constraints & Considerations → Reuse, naming the candidate. Put the entry point the phase must call in that phase's Agent Context as **Reuse**.

## Anti-Patterns to Avoid

- **Don't re-derive an existing rule** — Call or refactor the reuse candidate, or say why not under Constraints
- **Don't leave a mitigation untagged** — Every row in Risks & Mitigations names the phase group (`P{N}-{Name}`) that delivers it, and each row with in-repo evidence is an acceptance criterion in that phase's test spec or Acceptance gate
