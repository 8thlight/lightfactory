---
name: plan-tasks
description: Plan phase of RPI methodology. Consumes research artifact or topic and produces compact implementation plan with test specs and Agent Context blocks. Activates naturally inside plan mode for non-trivial work, or invoke explicitly with /plan-tasks. Use after research or to start planning a non-trivial feature.
triggers:
  - "draft plan"
  - "implementation plan"
  - "plan the implementation"
  - "plan non-trivial work"
  - "plan a feature"
  - "plan tasks"
  - "plan task graph"
  - "build a plan"
allowed-tools: Read Glob Write Bash AskUserQuestion Skill ExitPlanMode
---

# Plan Tasks Skill

**RPI Phase 2 of 3:** Research → **Plan** → Implement

Use this skill after research (or standalone) to create a compact implementation plan with behavioral test specifications and Agent Context blocks for each phase.

**Plan-mode-native:** When Claude is inside plan mode for non-trivial work, this skill's planning behavior applies naturally — no slash command required. The research skill transitions into plan mode automatically after research is complete.

## Phase Contract

**Receives:** Research artifact at `.light/sessions/{topic}-research.md` (or inline feature description if no research phase was run)
**Produces:** Plan in the Claude Code session plan file + task graph (yaks, beads, or native tasks) created after plan approval
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
- Inside plan mode after completing research (has research artifact in `.light/sessions/`)
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

### 3. Write Plan to Session Plan File

Write the plan to the Claude Code session plan file. This is the plan mode's native output — the user sees it for approval before exiting plan mode.

**Required sections:**
- **Metadata** — Include `tracker: yaks|beads|native` to record which task tracker will be used
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
- **Constraints & Considerations** — Architectural, testing, performance, security
- **Out of Scope** — Explicitly deferred features

See [template.md](references/template.md) for the complete template with Agent Context block reference.

**Phase ordering (application code projects):**
1. Database Schema (if needed)
2. Core Logic (L3 boundary — property/invariant tests)
3. Repository Layer (if needed)
4. Feature Use Cases (L3 boundary — behavioral assertions)
5. HTTP Routes (L4 boundary — contract tests)
6. Full Integration (verification)

For content or configuration projects with no application code, use flat `[no-test]` phases ordered by dependency. The TDD phase ordering above applies to application code projects.

### 4. Present Plan for Review

Check plannotator availability: `Bash: plannotator --version`

**If available:** Run `plannotator annotate` on the plan file via Bash. Iterate on non-empty annotation feedback. Empty annotations = approved.

**If unavailable:** Present a brief summary (goal, phases, acceptance criteria) via `AskUserQuestion`. Iterate until approved.

### 5. Exit Plan Mode and Create Task Graph

Once the plan is approved, call `ExitPlanMode`. Then immediately create the task graph — this is the **commitment point** where the approved plan becomes executable.

See [task-graph-decomposition.md](references/task-graph-decomposition.md) for the full procedure including three-tier tracker detection (yaks, beads, or native tasks), epic and phase group creation, naming conventions, agent context piping, and an example decomposition for a 6-phase feature.

Report the result:
```
Task graph created ({tracker} mode): {epic/graph name}
Tasks: {N} ({M} TDD triplets, {K} no-test phases)
Ready to execute with /implement.
```

### 6. Prompt Next Steps

Use `AskUserQuestion` to present:

```
Plan approved. Task graph: {name} ({N} tasks, {tracker} mode)

What would you like to do?

1. Run /implement — execute the plan now
2. Inspect task graph — review tasks before executing
3. Request changes — describe what to adjust (I'll update the graph)
```

- **Option 1:** STOP. The user will run `/implement`.
- **Option 2:** Show the task graph (e.g., `yx list` for yaks), then re-present options.
- **Option 3:** Update the task graph, then re-present options.

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

## Agent Context Blocks

Every implementation phase with tests MUST include an `#### Agent Context` subsection. The same Agent Context is stored in each task's context (for execution). This is the contract between `/plan-tasks` and `/implement`.

**Required fields:**
- **Files to create/modify** — explicit paths
- **Test spec** — behavioral description (what to test)
- **Test command** — shell command to run
- **RED gate / GREEN gate** — observable success criteria
- **Architectural constraints** — boundaries the agent must respect

See [template.md](references/template.md) for the Agent Context block reference and task context templates.

## Phase Boundaries

Each phase should:
1. **Have a clear goal** — What capability is being added?
2. **Be independently verifiable** — Can you confirm it works?
3. **Be in logical order** — Database → Core → Features → Routes
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
