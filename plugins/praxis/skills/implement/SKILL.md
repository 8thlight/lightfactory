---
name: implement
description: Implement phase of RPI methodology. Executes a task-graph-driven implementation using isolated agents with strict RED/GREEN/VALIDATE gate enforcement. Use when executing an implementation plan from the plan-tasks skill.
triggers:
  - "implement the plan"
  - "execute plan"
  - "build from plan"
  - "implement from plan"
allowed-tools: Read Glob Write Bash Task TaskOutput Skill
---

# Implement Skill

**RPI Phase 3 of 3:** Research → Plan → **Implement**

Use this skill to execute an implementation plan using task-graph-driven orchestration with isolated agents for strict test-first discipline.

## Phase Contract

**Receives:** Task graph (epic + per-agent-step child tasks) created by `/plan-tasks` — or creates it from the plan file if the task graph doesn't exist yet
**Produces:** Working feature with passing tests + execution audit trail + session artifact at `.light/sessions/`
**Does NOT read:** The plan file during execution — task contexts are self-contained

## Purpose

The Implement phase executes a task graph created by `/plan-tasks`. Each task's context contains everything needed for agent dispatch. The naming convention enforces ordering. Readiness is computed from the task graph state.

Three registered agents per TDD phase (see `plugins/praxis/agents/`):
- **agent-test** (RED): Creates failing tests from the task's test spec — knows nothing about the implementation
- **agent-impl** (GREEN): Writes minimal code to make tests pass + YAGNI simplification — guided only by the tests
- **agent-validate** (VALIDATE): Runs the full test suite — confirms nothing is broken

Plus **agent-remediate** for fixing failures and **agent-no-test** for non-TDD phases.

## When to Use

Use this skill when:
- Have a complete task graph from `/plan-tasks`
- Ready to execute plan phase by phase
- Want strict test/implementation isolation enforced
- Resuming an interrupted implementation session

**Don't use** for:
- Exploratory coding without a plan
- Simple bug fixes
- Research or planning tasks

## Execution Log

**REQUIRED:** Create `.light/sessions/YYYY-MM-DD-{topic}-implementation.md` in the project root at the start of every RPI session. Append entries throughout orchestration. This provides an observable audit trail of agent dispatch and gate results.

Entry format (one per line, append-only):
```
[DISPATCHED] {task name} — agent type: {agent-test|agent-impl|agent-validate}, mode: {sync|parallel}
[GATE PASS] {task name} — {RED|GREEN|VALIDATE} gate passed
[GATE FAIL] {task name} — {RED|GREEN|VALIDATE} gate failed: {reason}
[CLOSED] {task name}
[REMEDIATION] {task name} — attempt {N}: {description}
[BLOCKED] {task name} — escalating to user: {reason}
```

## Task Tracker Detection

Before starting the orchestration loop, detect which tracker is available:

1. Run `yx list --format json` — if it succeeds → **YAKS mode**
2. Run `ls .beads/config.yaml` — if it exists → **BEADS mode**
3. Otherwise → **NATIVE mode** (use `TaskCreate`/`TaskList`/`TaskUpdate`)

Each mode follows the same workflow structure. The tracker is an infrastructure detail — agent isolation, TDD gates, and execution log are identical across all three modes.

## Workflow

### 1. Identify the Epic (or Create Task Graph)

**YAKS:** Find the target epic via user input or `yx list --format json`. Verify the epic has child yaks with agent-type fields set. If no epic exists yet, read the plan file and create the yaks task graph now — see the [task-graph-decomposition procedure](../plan-tasks/references/task-graph-decomposition.md).

**BEADS:** Use `Skill: beads:list` to find the target epic bead. Verify child beads exist with agent-type fields set. If no epic exists yet, create beads from the plan file using `Skill: beads:create`.

**NATIVE:** Use `TaskList` to find existing tasks for this session. If no tasks exist yet, create them with `TaskCreate`. Note: native tasks are session-scoped — they do not persist across sessions (see Session Recovery).

If resuming a previous session, this step is the same — the readiness computation skips done tasks automatically.

### 2. Orchestration Loop

This is the core execution loop. It runs until all tasks in the epic are done or an unrecoverable error occurs.

```
Loop:
  a. Compute ready tasks (see Readiness Computation below)
  b. If no ready tasks and non-done tasks remain → escalate to user
  c. If no ready tasks and all tasks are done → proceed to final verification
  d. For each ready task:
     - Read task context (see tracker-specific command below)
     - Determine agent type from field: agent-type
     - Dispatch Task with agent prompt built from task context
     - If multiple ready tasks: dispatch in parallel (single message, multiple Task calls)
  e. Wait for agent(s) to complete
  f. For each completed agent:
     - If gate PASSED → mark done (tracker-specific command below)
     - If RED gate FAILED (tests pass immediately) → STOP, report to user
     - If GREEN gate FAILED → proceed to validation anyway
     - If VALIDATE found failures → create remediation tasks (see Remediation)
  g. Loop back to (a)
```

**Tracker commands for step (d) read context and step (f) mark done:**

| Action | YAKS | BEADS | NATIVE |
|--------|------|-------|--------|
| Read context | `yx context "{name}"` | `Skill: beads:show "{name}"` | `TaskGet {id}` |
| Mark done | `yx done "{name}"` | `Skill: beads:close "{name}"` | `TaskUpdate {id} completed` |
| List/progress | `yx list` | `Skill: beads:list` | `TaskList` |

See [workflow-detail.md](references/workflow-detail.md) for agent prompt templates and dispatch details.

### Readiness Computation

**YAKS and NATIVE:** Parse the task list for the epic and apply these rules:

1. **Extract phase prefix** from each top-level child's name (e.g., `P2` from `P2-Core-Logic`)
2. **Group by prefix number**: P1 group, P2 group, etc.
3. **A group is active** when ALL yaks in ALL lower-numbered groups are done
4. **Within an active group**:
   - **Leaf task** (no children): ready if state != `done`
   - **Parent task** (has children): first child by name sort with state != `done` is ready
5. **Collect all ready tasks** across all active groups → dispatch in parallel

**BEADS:** Use `Skill: beads:ready` — it returns the set of ready tasks directly, replacing the in-skill computation above.

This enables parallel dispatch across independent phase groups while enforcing sequential ordering within TDD triplets.

#### Dispatching Agents

For each ready task, build the agent prompt from its context:

1. Read the task context via the tracker-specific command above
2. The context contains the full Agent Context — file paths, test specs, commands, gates, constraints
3. Dispatch via `Task` tool using the registered agent type matching the task's `agent-type` field (e.g., `subagent_type: praxis:agent-test`)
4. The agent does NOT need to read the plan file — the task context is self-contained

#### Parallel Dispatch

When readiness computation returns multiple tasks, dispatch them all in a **single message with multiple `Task` tool calls**. TDD phases can't parallelize internally (Implement needs Write Test's output on disk), but independent phases parallelize across each other automatically via the naming convention.

#### Remediation

When Agent 3 (Validate) finds failures:

**YAKS:** Create remediation and re-validation yaks via `yx add` with `--field "agent-type=agent-remediate"` / `--field "agent-type=agent-validate"`. See [workflow-detail.md](references/workflow-detail.md) for the full procedure and context template.

**BEADS:** Create remediation and re-validation beads via `Skill: beads:create` under the same phase group parent.

**NATIVE:** Create remediation and re-validation tasks via `TaskCreate` under the same phase group.

In all modes: name remediation `04-remediate-attempt-{M}` and re-validation `05-revalidate-attempt-{M}`. Mark the original validate task done (it completed its job — reporting failures). If attempt count reaches 2 and re-validation still fails, **STOP — ask the user**.

### 3. Report Progress

After each task completes, report status using the tracker list command:
```markdown
**Progress Update:**
- [done] P1-Schema-Setup
- [done] P2-Core-Logic / 01-write-tests
- [done] P2-Core-Logic / 02-implement
- [wip]  P2-Core-Logic / 03-validate (dispatched)
- [todo] P3-Repository-Layer (waiting for P2)
```

### 4. Final Verification

After all tasks in the epic are done:
1. Run the full test suite one final time
2. Verify all acceptance criteria from the epic are met
3. Report the agent execution summary (tasks closed, remediations)

Check plannotator availability: `Bash: plannotator --version`

**If available:** Run `plannotator review` via Bash to open the full git diff in the browser code review UI. Wait for the result:
- **"LGTM" returned:** Proceed to the next-steps prompt.
- **Feedback returned:** Address each item — fix code, NOT tests. Re-run the full test suite after fixes. Then re-run `plannotator review`. Repeat until LGTM.

**If unavailable:** Skip browser review; proceed to next-steps prompt.

### 5. Write Session Artifact

After final verification passes, write a single session artifact to `.light/artifacts/YYYY-MM-DD-{topic}.md`. This is the ONLY persistent artifact from the entire research → plan → implement flow.

**Required sections:**
- **Research Summary** — Key findings from the plan's inline research section (or "No research phase" if skipped)
- **Plan Summary** — Phases, acceptance criteria, architectural decisions
- **Execution Log** — Agent dispatches, gate results, remediations (from `./light/YYYY-MM-DD-{topic}-execution.md`)
- **Outcome** — Final test suite result, acceptance criteria status

Use kebab-case for the topic slug (e.g., `2026-03-07-add-discount-codes.md`).

### 6. Post-Execution Recommendations

Use `AskUserQuestion` to present:

```
Implementation complete. All {N} tasks done, tests passing.
Session artifact: .light/sessions/YYYY-MM-DD-{topic}.md

What would you like to do?

1. Code review — review the diff for quality issues
2. Simplify — refine recently modified code for clarity and maintainability
3. Reflect — extract learnings to improve skills, hooks, CLAUDE.md
4. Commit and push — run /commit
```

## Agent Isolation Discipline

**CRITICAL:** The three-agent pattern exists to maintain honest separation between tests and implementation.

### Rules

1. **Agent 1 writes tests only** — never implementation code
2. **Agent 2 writes implementation only** — never modifies test files
3. **Agent 3 modifies nothing** — only runs tests and reports
4. **Agent 2-R fixes implementation only** — never modifies test files
5. **Each agent starts fresh** — no shared context between agents

### If RED Gate Fails

If Agent 1's tests pass immediately (before implementation):
1. STOP — the test is tautological or the feature already exists
2. Report to user — explain what happened
3. Do NOT mark the task as done — leave it for user decision

### VALIDATE Gate Definition

The VALIDATE gate is the project's full test and lint suite. Agent 3 determines the gate command by reading the project's `CLAUDE.md` (or `package.json` / equivalent build file) for the configured test, type-check, and lint commands. All commands must exit 0.

Example for a TypeScript/Bun project: `tsc --noEmit && vitest run && biome check .`
Example for a Python project: `mypy . && pytest && ruff check .`

Agent 3 always derives the actual commands from the project rather than using hardcoded defaults.

### If GREEN Gate Fails

If Agent 2 cannot make tests pass:
1. Proceed to Agent 3 anyway (to get full failure report)
2. Enter remediation via dynamic task creation
3. After 2 failed remediations, STOP and ask user

## Session Recovery

**YAKS:** Run `yx list --format json` for the epic and recompute readiness. Done tasks = completed work; ready tasks = next to dispatch; waiting tasks = predecessors not yet done. No special recovery logic needed.

**BEADS:** Same as YAKS — use `Skill: beads:list` and `Skill: beads:ready`. Bead state persists cross-session.

**NATIVE:** Native tasks are session-scoped only — they do not persist across Claude Code sessions. On recovery, recreate the task list from the session artifact at `.light/sessions/` or the plan file, then resume the orchestration loop.

## Anti-Patterns to Avoid

- **Don't let agents share context** — each agent starts from the task context and files on disk
- **Don't skip Agent 3** — validation catches regressions in other tests
- **Don't modify tests during implementation** — tests define the contract
- **Don't read the plan file during execution** — task contexts are self-contained
- **Don't improvise beyond the plan** — stick to the tasks or update them explicitly
- **Don't run agents in background** — synchronous dispatch ensures ordering
- **Don't treat a lint-only VALIDATE failure as a full remediation event** — use the lint fast path

## After Implementation

Once all tasks done and verified:
1. **Session artifact written** — `.light/artifact/YYYY-MM-DD-{topic}.md` is the persistent record
2. **Post-execution recommendations presented** — code-review, simplify, reflect, commit
3. **Manual smoke test** — try key user journeys if applicable
4. **Create commit** — use `/commit` skill
5. **Document follow-up** — note any deferred work

## Context Compaction

**Why isolated agents?** Each agent loads only what it needs:
- **Agent 1:** Task's test spec + project test patterns → writes tests
- **Agent 2:** Test files on disk + task's constraints → writes implementation
- **Agent 3:** Test command from task → runs and reports

No agent carries the full research or planning context. Each task context provides exactly the information the dispatched agent needs.
