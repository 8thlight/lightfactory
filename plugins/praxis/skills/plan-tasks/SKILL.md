---
name: plan-tasks
description: Create a detailed implementation plan with test specs, phased task breakdown, and Agent Context blocks for agent-driven execution. Consumes a research artifact or works from a feature description directly. Creates a task graph in yaks, beads, or native tasks. Use when the user wants to plan a feature, create an implementation roadmap, break down work into tasks, or prepare for TDD implementation. Do NOT use for codebase exploration (use research instead) or executing a plan (use implement instead). Triggers on phrases like "plan the implementation", "create a roadmap", "break this into tasks", "plan before coding", "draft a plan", "turn research into a plan", or "create task breakdown".
triggers:
  - "draft plan"
  - "implementation plan"
  - "plan the implementation"
  - "plan non-trivial work"
  - "plan a feature"
  - "plan tasks"
  - "plan task graph"
  - "build a plan"
allowed-tools: Read Glob Write Bash AskUserQuestion Skill
---

# Plan Tasks Skill

**RPI Phase 2 of 3:** Research → **Plan** → Implement

Use this skill after research (or standalone) to create a compact implementation plan with behavioral test specifications and Agent Context blocks for each phase.

## Phase Contract

**Receives:** Research artifact at `.light/sessions/{topic}-research.md` (or inline feature description if no research phase was run)
**Produces:** Plan artifact at `.light/sessions/{topic}-plan.md` + task graph (yaks, beads, or native tasks) created after plan approval
**Hands off to:** `/implement` — consumes the task graph, NOT the plan file

## Purpose

The Plan phase creates a compact spec that fits in context by:
- Summarizing research findings inline (consuming the `.light/sessions/` artifact)
- Defining files to create/modify in order of operations
- Specifying test specs as behavioral descriptions at architectural boundaries
- Including Agent Context blocks so `/implement` can dispatch isolated agents per phase
- Setting clear acceptance criteria
- Identifying phase boundaries for incremental implementation

**Output:** Plan in the Claude Code session plan file (the only plan file during planning — the persistent session artifact is written by `/implement` at the end of execution)

## When to Use

Use this skill when:
- After completing research (has research artifact in `.light/sessions/`)
- Starting a non-trivial feature (no research artifact, will explore inline)
- Need a clear implementation roadmap before coding
- Want to specify test boundaries before implementing

**Don't use** for:
- Simple bug fixes
- Trivial features with obvious implementation
- Exploratory spikes

## Workflow

### 1. Consume Research Artifact (If Exists)

Check for research artifact:
```
Glob: .light/sessions/*-research.md
```

If research artifact exists, read it and summarize findings inline in the plan. The plan should be self-contained — a reader should not need to go back to the research artifact.

If no research artifact, create an inline summary (condensed):
- Identify relevant files
- Note existing patterns
- List integration points

### 2. Define Plan Scope

Ask the user to clarify if needed:
- What are the acceptance criteria?
- Are there specific constraints or preferences?
- What's the priority (MVP vs full feature)?
- Commit policy: `per-task`, `per-group`, or `none` (default `none`)

### 3. Write Plan Artifact

Write the plan to `.light/sessions/{topic}-plan.md`. This is the planning output — the user reviews and approves it before task graph creation.

**Required sections:**
- **Metadata** — Include `tracker: yaks|beads|native` to record which task tracker will be used, and `commit: per-task|per-group|none`. The orchestrator (`/implement`) commits per this policy; agents never commit. `per-task` commits failing tests by design; choose `per-group` or `none` when hooks or CI run the suite on every commit
- **Context** — Why this change is being made, summarizing research findings
- **Goal** — 1-2 sentence description of what we're building and why
- **Acceptance Criteria** — Testable outcomes as checklist
- **Files to Create** — Organized by layer (Core, Features, Shell, Tests)
- **Files to Modify** — What changes in existing files
- **Implementation Phases** — Ordered steps, each with:
  - Clear goal
  - Behavioral test specification (what to test, not how)
  - Tasks list
  - Verification checklist
  - **Agent Context block** (file paths, test command, gates, constraints)
- **RED Gate Profiles** — per test phase, the rule file whose `RED gate` section was copied (see RED gate profile lookup), or "none — generic"
- **Constraints & Considerations** — Architectural, testing, performance, security
- **Out of Scope** — Explicitly deferred features

See [template.md](references/template.md) for the complete template with Agent Context block reference.

**Phase ordering (application code projects):**
0. Journey fragment RED (optional, tier `e2e-journey`) — before the phases that turn it green; see Phase tiers
1. Database Schema (if needed)
2. Core Logic (L3 boundary — property/invariant tests) — tier `unit`
3. Repository Layer (if needed)
4. Feature Use Cases (L3 boundary — behavioral assertions) — tier `integration`
5. HTTP Routes (L4 boundary — contract tests) — tier `http-contract`; then the UI change a journey stage asserts, if any
6. Full Integration (verification)

**Phase tiers.** Tag every test phase `unit | integration | http-contract | e2e-journey`
(`no-test` phases have no tier). This list is the source for the journey rules; the
phase shape is in [template.md](references/template.md):
- `e2e-journey` is a browser-driven user journey, used only for behavior that needs the
  browser; it is distinct from `http-contract` (API-level tests, even if the project
  keeps them under an `e2e/` directory). Everything else is asserted at the lowest tier
  that can assert it.
- A journey phase states its **runner**, **build target** (e.g. production build, not a
  dev server) and **preflight** (externally managed services and ports that must be up;
  what the runner starts itself is checked by running it). If the runner does not build
  the app itself, the spec's command builds first (`{build} && {runner} {spec}`); a runner
  that starts the server must not reuse one already running. Every run sees the current tree.
- A journey splits into **fragments** (open surface, inputs, submit, result visible). A
  fragment is a leaf RED task `P{N}-E2E-Red-{Step}` that extends the same spec by one
  stage, then the lower-tier phases that turn it green, including the phase that builds
  the UI the stage asserts.
- **Placement:** a fragment's RED leaf gets a lower `P{N}` than its phases; fragment N+1's
  RED follows fragment N's phases.
- **Validate scope:** validates inside an open fragment run the suite minus this journey's
  spec. The fragment's last phase is a single TDD group (no same-prefix sibling, not
  no-test); its validate also carries the **Journey spec command**, the journey RED task's
  Preflight and RED gate profile, and every implementation file in the fragment; stages
  1..K must pass.
- A stage's RED shows earlier stages passing and stage K failing on the predicted
  testid. The agreed contract testids go into the Implement context (Interface contract)
  of the phase that builds them.

For content or configuration projects with no application code, use flat `[no-test]` phases ordered by dependency. The TDD phase ordering above applies to application code projects.

### 4. Present Plan for Review

Check plannotator availability: `Bash: plannotator --help`

**If available:** Run `plannotator annotate .light/sessions/{topic}-plan.md` via Bash. Iterate on non-empty annotation feedback. Empty annotations = approved.

**If unavailable:** Present a brief summary (goal, phases, acceptance criteria) via `AskUserQuestion`. Iterate until approved.

### 5. Create Task Graph

Once the plan is approved, immediately create the task graph — this is the **commitment point** where the approved plan becomes executable.

See [task-graph-decomposition.md](references/task-graph-decomposition.md) for the full procedure including three-tier tracker detection (yaks, beads, or native tasks), epic and phase group creation, naming conventions, agent context piping, and an example decomposition for a 6-phase feature. For the most common path (yaks), the key commands are `yx add` for tasks and a quoted heredoc into `yx context` (`<<'CONTEXT'`) for agent context — see [tracker-yaks.md](references/tracker-yaks.md) directly.

Write the epic's own context in tracker step 1: a `commit: {policy}` line and the Acceptance Criteria, so `/implement` can read both without the plan file (absent `commit:` = `none`).

Report the result:
```
Task graph created ({tracker} mode): {epic/graph name}
Tasks: {N} ({M} TDD triplets, {J} journey RED leaves, {K} no-test phases)
Ready to execute with /implement.
```

### 6. Prompt Next Steps

**Context check:** If the conversation has been extensive (research phase + planning), suggest clearing context before implementation. The task graph and plan artifact carry all needed context forward.

Use `AskUserQuestion` to present:

```
Plan approved. Task graph: {name} ({N} tasks, {tracker} mode)
Plan artifact: .light/sessions/{topic}-plan.md

What would you like to do?

1. Continue to implementation — run /implement now (recommended)
2. Clear context first — if conversation is long, run /clear then /implement
3. Inspect task graph — review tasks before executing
4. Request changes — describe what to adjust (I'll update the graph)
```

- **Option 1:** Invoke `/implement` directly via `Skill: implement`. The flow continues seamlessly in the same conversation.
- **Option 2:** STOP. The user will run `/clear` and then `/implement` manually. The task graph provides full context for implementation.
- **Option 3:** Show the task graph (e.g., `yx list` for yaks), then re-present options.
- **Option 4:** Update the task graph, then re-present options.

## Test Specifications at Boundaries

Test specs in the plan MUST be behavioral descriptions, not tool-specific code. The agents executing `/implement` will consult the project's CLAUDE.md for testing tools and patterns.

### L3 Core Tests (Property/Invariant)

Describe invariant properties that must hold:
- **Good:** "Splitting a total into N parts preserves the total"
- **Bad:** Code snippet using a specific testing library

### L3 Feature Tests (Behavioral)

Describe behavior at the use case boundary:
- **Good:** "Creating an order returns success with an order ID and correct total"
- **Bad:** `expect(mockRepository.create).toHaveBeenCalledWith(...)`

### L4 HTTP Tests (Contract)

Describe the HTTP contract:
- **Good:** "POST /orders returns 201 with `{ id, total }` on success, 400 with `{ error }` on validation failure"
- **Bad:** Testing internal handler implementation details

See [template.md](references/template.md) for detailed guidelines.

For detailed L3/L4 testing guidelines including property-based tests and architectural anti-patterns, see [boundary-testing.md](../tdd/references/boundary-testing.md).

## Agent Context Blocks

Every implementation phase with tests MUST include an `#### Agent Context` subsection. The same Agent Context is stored in each task's context (for execution). This is the contract between `/plan-tasks` and `/implement`.

**Required fields:**
- **Files to create/modify** — explicit paths
- **Test spec** — behavioral description (what to test)
- **Test command** — shell command to run
- **RED gate / GREEN gate** — observable success criteria
- **Architectural constraints** — boundaries the agent must respect
- **Tier** — on each test phase and in its Write Tests context; for `e2e-journey` also runner, build target and preflight
- **Acceptance criterion / Interface contract** (Implement contexts) — the criterion the phase serves, and testids or shapes it must expose

**Authoring the RED gate signature:** The RED gate field tells `agent-test` what a
*correct* initial failure looks like for this phase — so it can distinguish the
intended failure (the asserted behavior is absent) from a wrong-reason failure
(compile/import/setup error, or tests passing outright). Make it specific to the
phase's framework and test tier rather than generic. Where the project or user has a
testing skill or guideline (e.g. a framework-specific testing skill referenced from
CLAUDE.md), consult it to describe the expected failure in that framework's terms. If
no such guidance exists, describe the expected failure behaviorally (which assertion
fails and why) and `agent-test` falls back to a generic at-assertion vs.
before-assertion check. Write the signature from the acceptance criterion and the agreed
interface contract (e.g. testids), naming user-visible behavior or contract testids,
never internals. For `e2e-journey` phases it names the locator/step expected to fail
(e.g. "earlier steps pass; waiting for `{testid}` times out") — a timeout elsewhere is a
wrong-reason RED. The signature goes only into the write-tests context, never
`agent-impl`'s or `agent-remediate`'s.

### RED gate profile lookup

Repo rule files may already define what a correct RED looks like per area. For each test
task, before writing its Agent Context (a manual step, not a hook):

1. Collect the test files the task will write or extend.
2. Find rule files whose `paths:` frontmatter globs match any of them —
   `.claude/rules/**/*.md` (recursive, as Claude Code loads them), plus rule files the
   project's CLAUDE.md references.
3. In each matching file, take the section whose heading text starts with `RED gate`
   (through the next heading of equal or higher level).
4. Copy it **verbatim** into the test task's Agent Context under a `#### RED gate profile`
   heading, first line `Source: {rule file path}`. Several matches: include each
   section, each labelled by its source file; prefer splitting the phase by tier when
   they conflict.
5. No match: omit the heading; praxis's generic RED definition applies.
6. Record the file(s) used (or "none — generic") per phase in the plan's **RED Gate
   Profiles** section so reviewers can see what the gate was judged against.

`agent-test` judges RED against the profile and `agent-validate` uses its wrong-reason
list. The profile is placed ONLY in write-tests and validate contexts (for a journey
fragment's last validate, also the journey RED task's profile), never `agent-impl`'s or
`agent-remediate`'s. Claude Code may still auto-load a path-scoped rule file for any
agent that reads matching files, so treat the profile as guidance, not a secret.
No new config: it reuses existing rule files and headings.

See [template.md](references/template.md) for the Agent Context block reference and task context templates.

## Phase Boundaries

Each phase should:
1. **Have a clear goal** — What capability is being added?
2. **Be independently verifiable** — Can you confirm it works, with the suite green afterwards (inside an open journey fragment, the suite minus that journey's spec)?
3. **Be in logical order** — Database → Core → Features → Routes; a journey fragment's RED leaf comes first
4. **Have a self-contained Agent Context** — An isolated agent can execute it

Good boundaries: Database schema, Core functions, Repository, Feature use cases, HTTP routes

Bad boundaries: "Implement everything", mixing multiple layers

## Anti-Patterns to Avoid

- **Don't write full implementations** — Specs only, not code
- **Don't skip Agent Context blocks** — Each phase needs one for `/implement` to dispatch agents
- **Don't prescribe testing tools** — Describe behavior, reference project CLAUDE.md for tools
- **Don't create giant phases** — Keep phases small and focused
- **Don't omit verification steps** — Each phase needs concrete, observable checks

## Session Recovery

The task graph provides durable state across sessions:
- **Done tasks** = completed work (agents ran, gates passed, files on disk)
- **Ready tasks** = next tasks to dispatch (computed from naming convention)
- **Waiting tasks** = predecessor groups not yet done
- If a session is interrupted, running `/implement` again picks up exactly where it left off
- **beads and yaks** = cross-session durable (task graph persists between Claude Code sessions)
- **native tasks** = session-scoped only (task graph is lost if the session ends)
