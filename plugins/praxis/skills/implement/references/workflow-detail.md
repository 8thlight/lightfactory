# RPI Implement: Workflow Details

This reference provides detailed templates, examples, and procedures for executing the task-graph-driven implementation workflow across all three tracker modes (YAKS, BEADS, NATIVE).

## Agent Dispatch

Each task contains a self-contained agent task description in its context. The RPI praxis orchestrator reads the context via the tracker-specific command and uses it to build the agent prompt. No plan file reading is needed.

### Building Agent Prompts

For each ready task (from readiness computation), read the task context using the tracker-specific command:

- **YAKS** — see [tracker-yaks.md](tracker-yaks.md#agent-prompt-reading)
- **BEADS** — see [tracker-beads.md](tracker-beads.md#agent-prompt-reading)
- **NATIVE** — see [tracker-native.md](tracker-native.md#agent-prompt-reading)

After reading the context:

1. The context follows the self-contained format from `/plan-tasks` (see plan-tasks template.md)
2. Dispatch via `Task` tool using the registered agent type matching the task's `agent-type` field
3. The agent receives the task context as its prompt — its system prompt is defined in the plugin's `agents/` directory

### Agent Dispatch Table

| agent-type Field | Agent Type (subagent_type) | Purpose |
|------------------|---------------------------|---------|
| `agent-test` | `praxis:agent-test` | Write failing tests (RED gate) |
| `agent-impl` | `praxis:agent-impl` | Minimal implementation + YAGNI check (GREEN gate) |
| `agent-validate` | `praxis:agent-validate` | Run the validate task's tests, type-check and lint; report only (VALIDATE gate) |
| `no-test` | `praxis:agent-no-test` | Non-TDD tasks (schema, infrastructure) |
| `agent-remediate` | `praxis:agent-remediate` | Fix implementation after validation failures |

### Dispatch Format

For each agent dispatch, pass the task context as the prompt:

```
Task(
  description="P{N}: {Phase} — {agent role}",
  subagent_type="praxis:agent-test",  // or agent-impl, agent-validate, etc.
  prompt="{task_context}"
)
```

The registered agents have their own system prompts defining role, rules, and report format. The task context provides the task-specific context (file paths, test specs, gates, constraints).

See `plugins/praxis/agents/` for the full agent definitions:
- `agent-test.md` — RED gate: writes failing tests only
- `agent-impl.md` — GREEN gate: minimal implementation + YAGNI simplification pass
- `agent-validate.md` — VALIDATE gate: runs the validate commands, reports only, never fixes
- `agent-no-test.md` — Non-TDD tasks (schema, config, infrastructure). After completing the task, the agent should verify that any markdown links in modified files point to existing files.
- `agent-remediate.md` — Fixes implementation after validation failures (uses opus)

---

## Readiness Computation Algorithm

The implement skill computes readiness from the task list. In YAKS and NATIVE modes, this is an in-skill computation. In BEADS mode, `Skill: beads:ready` returns the ready set directly.

Per-tracker details and pseudocode:

- **YAKS** — see [tracker-yaks.md](tracker-yaks.md#readiness-computation)
- **BEADS** — see [tracker-beads.md](tracker-beads.md#readiness-computation)
- **NATIVE** — see [tracker-native.md](tracker-native.md#readiness-computation)

### Example Walk-Through

Given this task tree:
```
Epic: "Add Discount Codes"
  P1-Schema-Setup         [done]
  P2-Core-Logic           [wip]
    01-write-tests        [done]
    02-implement          [done]
    03-validate           [todo]    ← READY
  P2-Feature-B            [todo]
    01-write-tests        [todo]    ← READY (P2 group independent)
  P3-Repository           [todo]        (blocked — P2 not done)
```

Ready tasks: `P2-Core-Logic/03-validate` AND `P2-Feature-B/01-write-tests` — dispatched in parallel.

---

## Parallel Dispatch

When readiness computation returns multiple tasks, dispatch them all in a **single message** with multiple `Task` tool calls.

### When Parallel Dispatch Occurs

- Two phase groups share the same prefix number (e.g., P2-Feature-A and P2-Feature-B)
- Multiple leaf phase groups are active simultaneously
- A no-test phase and a test-write phase are both ready

### When NOT to Parallelize

- Within a TDD triplet: Write Tests → Implement → Validate MUST be sequential
- Agent 2 needs Agent 1's test files on disk before it can run
- Agent 3 needs Agent 2's implementation on disk before it can run

### Example: Parallel Dispatch

If readiness returns `P1-Schema-Setup` (leaf, no-test) and `P1-Config-Setup` (leaf, no-test):

```
# Single message with two Task calls:
Task(description="P1: Schema Setup", subagent_type="praxis:agent-no-test", prompt="...")
Task(description="P1: Config Setup", subagent_type="praxis:agent-no-test", prompt="...")
```

---

## Gate Outcomes

The orchestrator acts on each agent's reported outcome as follows. This table is the single
source; `SKILL.md` step 2f summarizes it. "Mark done" means: commit first when the policy
calls for it (see [Commits](#commits)), close the task in the tracker, then log `[CLOSED] {task}`.

| Agent → outcome | Orchestrator action |
|---|---|
| agent-test: RED gate PASS | Confirm the report's Failure excerpt matches the task's RED gate (a mismatch is a wrong-reason RED, below). Log `[GATE PASS]` with the evidence (kept for the session artifact's RED evidence), mark done. On a `01r-`/`03r-` repair task, treat RED PASS as N/A (next rows) |
| agent-test: RED gate FAIL (tests passed, wrong reason, or preflight) | Log `[GATE FAIL]` and `[BLOCKED]`, leave the task open, STOP and report with the agent's excerpt. Never re-dispatch it on your own |
| agent-test: RED gate N/A (TEST-DEFECT repair) | [TEST-DEFECT Route](#test-defect-route) step 6 |
| agent-impl: GREEN gate PASS | Log `[GATE PASS]`, mark done |
| agent-impl: GREEN gate FAIL | Log `[GATE FAIL]`, mark done; its validate runs next and reports the failures |
| agent-impl or agent-remediate: TEST-DEFECT | [TEST-DEFECT Route](#test-defect-route) |
| agent-validate: PASS | Log `[GATE PASS]`, mark done |
| agent-validate: failures | Take the first match: (1) a behavior test failure or a type-check failure → [Remediation](#remediation), with any FLAKY or environmental failures listed in the remediation context as not to fix; (2) otherwise a lint failure → [Lint Fast Path](#lint-fast-path); (3) otherwise only FLAKY or environmental test failures → log `[GATE FAIL] {task} — VALIDATE gate failed: {FLAKY: command, reruns, log path / environmental: line}` and `[BLOCKED]`, leave the task open, STOP and ask. The user accepts (close with `[CLOSED] {task} — user approval: "{quote}"`), asks for a rerun (re-dispatch the task), or fixes the environment or test and then asks for a rerun |
| agent-remediate: ALL PASS or STILL FAILING | Log `[GATE PASS]` or `[GATE FAIL] {task} — GREEN gate …`, mark done; its re-validation runs next |
| agent-no-test: acceptance gate PASS | Log `[GATE PASS]`, mark done |
| agent-no-test: acceptance gate FAIL | Log `[GATE FAIL]` and `[BLOCKED]`, leave the task open, STOP and ask |

When agents run in parallel, act on every completed agent in the batch before stopping.
On resume, a ready task whose last log entry is `[GATE FAIL]` or `[BLOCKED]` waits for the
user's decision; it is not re-dispatched automatically.

## Execution Log Format

One entry per line, append-only, in `.light/sessions/YYYY-MM-DD-{topic}-execution.md`.
`{task}` is always the qualified name `{group} / {child}` (e.g. `P2-Core-Logic / 02-implement`;
a leaf group uses its own name), because child names repeat in every group.

```
[DISPATCHED] {task} — agent type: {agent-test|agent-impl|agent-validate|agent-remediate|no-test}, mode: {sync|parallel}
[GATE PASS] {task} — {RED|GREEN|VALIDATE|ACCEPTANCE} gate passed (RED: {decisive line} @ {file:line}); files: {paths}
[GATE PASS] {task} — RED gate N/A: test repair accepted; files: {paths}
[GATE FAIL] {task} — {RED|GREEN|VALIDATE|ACCEPTANCE} gate failed: {reason}; files: {paths}
[REMEDIATION] {task} — attempt {N}: {failures | cause=TEST-DEFECT: {test, why} | cause=TEST-DEFECT rejected: {why}}[; files: {paths}]
[BLOCKED] {task} — {reason: escalation, attempt limit, refused close by {id}, commit rejected, repair diff rejected, pending user decision}[: TEST-DEFECT {test, assertion, why}][; files: {paths}]
[CLOSED] {task}[ — user approval: "{quote}"]
[WRITE] {task} — {command}; orchestrator wrote: {files}
```

`files:` lists the files the agent reported creating or modifying (omit when none). `[WRITE]`
covers every file the orchestrator itself writes to the project — the lint fast path's
formatter, a `.orig` restore, and each commit (`[WRITE] {task} — git commit {sha}; orchestrator
wrote: {files}`) — and names the task it serves (`final` after the loop). On resume, rebuild
`files_created`/`files_modified` and the files still to commit, per task, from these lines: a
file is still to commit for a task when an entry for that task lists it after the last commit
line that lists it (parallel groups commit separately, so the last commit overall is not a
cutoff). RED gate N/A lines are not counted as RED passes in the session manifest. Record
each user decision as a quote on the next entry for that task (e.g.
`[DISPATCHED] {task} — … — user decision: "{quote}"`). A close the tracker refuses (open
dependency) is never forced without user approval; record the approval on the close:
`[CLOSED] {task} — force-closed past {id}; user approval: "{quote}"`.

## TEST-DEFECT Route

agent-impl or agent-remediate reports TEST-DEFECT (test, assertion, why) when a test seems
wrong. The orchestrator decides the claim; the reporting agent never does. Tests change only
through agent-test: no implementation agent edits them, and the orchestrator edits them only
through the [Lint Fast Path](#lint-fast-path)'s formatter or by restoring a `.orig` copy at the
user's request (step 7), each logged `[WRITE]`. Agents may edit files before a stop, so every
`[REMEDIATION]` or `[BLOCKED]` entry this route logs ends with `; files: {paths}` from the report
it acts on (the reporting agent's, or the repair's in step 7).

1. **Owner.** Find the task that wrote the cited test: the phase's `01-write-tests`, or for a
   journey spec the `P{N}-E2E-Red-*` leaf that wrote the cited stage. If no task in the graph
   wrote it, log `[BLOCKED] {task} — pending user decision: TEST-DEFECT {test, assertion, why}`,
   leave the reporting task open, STOP and ask the user.
2. **Budget.** The claim is attempt `N` of its phase group, where `N` = 1 + the
   `[REMEDIATION]` lines already logged for the group. If this is the group's second claim,
   or `N` > 2, log `[BLOCKED] {task} — attempt limit: TEST-DEFECT {test, assertion, why}`, leave
   the reporting task open, STOP and ask the user.
3. **Decide.** Compare the cited assertion with the owner's test spec and the acceptance
   criteria in the epic context. If that does not settle it, log `[BLOCKED] {task} — pending
   user decision: TEST-DEFECT {test, assertion, why}`, leave the reporting task open, and ask
   the user.
4. **Rejected** (the assertion states the criterion): log
   `[REMEDIATION] {task} — attempt {N}: cause=TEST-DEFECT rejected: {why}` and mark the
   reporting task done. Its validate (`03-validate` or `05-revalidate-attempt-{M}`) runs next,
   and the next remediation context carries `Rejected TEST-DEFECT: {why}`.
5. **Upheld:** copy the cited file to `.light/test-defect-{group}-{child}.orig`, create a repair
   task in the same group that sorts just before the reporting task — `01r-test-repair-attempt-{N}`
   for `02-implement`, `03r-test-repair-attempt-{N}` for `04-remediate-attempt-{M}` (agent-type
   `agent-test`; tracker commands in the tracker files; `M` is the attempt number in the
   reporting task's name). Then log `[REMEDIATION] {task} — attempt {N}: cause=TEST-DEFECT:
   {test, why}`, and, for a claim from `04-remediate-attempt-{M}`, mark that task done (its
   `05-revalidate-attempt-{M}` then runs after the repair). The repair's context is the owner's
   write-tests context (with its runner, preflight and RED gate profile), the TEST-DEFECT
   report, and the violated acceptance criterion. On resume, an upheld-claim line with no
   repair task, or with its `04-remediate-attempt-{M}` still open, means this step did not
   finish: finish it.
6. **Repair result.** agent-test reports RED gate N/A when its run passes or fails anywhere in
   the code under test; go to step 7. A failure of the test file itself (it does not compile or
   load, or its fixtures, setup or preflight fail) is a RED gate FAIL (see [Gate Outcomes](#gate-outcomes)).
7. **Review.** Diff the cited file against the `.orig` copy. If the repair's Files modified is
   exactly the cited file, only the cited assertion changed, and no assertion the criterion
   requires was dropped or weakened, log `[GATE PASS] {repair} — RED gate N/A: test repair
   accepted` and mark the repair done; readiness then re-dispatches `02-implement` or runs the
   re-validation. Otherwise log `[BLOCKED] {repair} — repair diff rejected: {assertion}; files:
   {paths}`, leave the repair open, STOP and ask the user.

**After a stop on this route,** the user's answer replaces step 3 and waives the budget:
reject → step 4; uphold → step 5 with the next `N`. After a rejected repair diff, the user
either accepts it (mark the repair done) or has the orchestrator restore the `.orig` copy
(logged `[WRITE]`) and re-dispatch the repair.

## Remediation

When a validate task reports behavior or type-check failures, create new tasks under the same
phase group to handle remediation. The procedure is the same across all tracker modes; only
the commands differ.

### Procedure

1. **Attempt number.** `N` = 1 + the `[REMEDIATION]` lines already logged for the phase group
   (TEST-DEFECT claims included). If `N` > 2, log `[BLOCKED]`, leave the failed validate open,
   STOP and ask the user. A failing leaf validate (one with no phase group, such as the final
   integration task) also logs `[BLOCKED]` and stops for the user, since there is no group to
   hold remediation.
2. **Log** `[GATE FAIL] {validate task} — VALIDATE gate failed: {failing tests}` and
   `[REMEDIATION] {validate task} — attempt {N}: {failing tests}`.
3. **Create the remediation task** `04-remediate-attempt-{N}` (agent-type `agent-remediate`)
   with the context below.
4. **Create the re-validation task** `05-revalidate-attempt-{N}` (agent-type `agent-validate`)
   with the original validate task's context unchanged: the same commands (inside an open
   journey fragment it still excludes the journey spec), preflight and RED gate profile.
5. **Mark the failed validate task done**: it did its job by reporting the failures.

The sequential naming (`04-`, `05-`) makes remediation run next, then re-validation. A
re-validation that fails starts the next attempt from step 1.

Per-tracker commands:

- **YAKS** — see [tracker-yaks.md](tracker-yaks.md#remediation-commands)
- **BEADS** — see [tracker-beads.md](tracker-beads.md#remediation-commands)
- **NATIVE** — see [tracker-native.md](tracker-native.md#remediation-commands)

### Remediation Task Context Template

```markdown
## Agent Task: Remediate — {Phase Name} (attempt {N})

**Role:** Fix the implementation to make all tests pass. Do NOT modify test files.

### Agent Context
- **Files to modify (implementation):** `{the phase's implementation files — for a journey fragment's last validate, every implementation file in the fragment}`
- **Files to read (tests, DO NOT MODIFY):** `{test file path(s)} — for a journey fragment's last validate, also the journey spec`
- **Acceptance criterion:** {copied from the phase's `02-implement` context — for a journey fragment's last validate, every criterion the fragment serves}
- **Full test command:** `{the failed validate task's Full test command}`
- **Journey spec command:** `{the failed validate task's Journey spec command}` — omit when it had none
- **Preflight:** {the failed validate task's Preflight — omit when it had none}
- **Not behavior (don't fix):** {FLAKY or environmental failures from the same report — omit when none}
- **Rejected TEST-DEFECT:** {why the orchestrator rejected a claim on this phase — omit when none}
- **Failure output from validation:**

{paste Agent 3's failure output here}

Follow your `praxis:agent-remediate` definition for the procedure and report format. The Agent Context above is your task input.
```

## Lint Fast Path

When a validate task's only failures are lint failures, the orchestrator handles them itself
instead of creating remediation (`agent-validate` only reports):

1. Run the project's lint auto-fix on the files the lint output names, without unsafe fixes
   (e.g. `biome check --write`, `eslint --fix`). Besides a user-requested `.orig`
   restore on the TEST-DEFECT route, this formatter is the only way the orchestrator may touch a
   test file. Log `[WRITE]` and add the files to `files_modified`.
2. Re-dispatch the validate task.
3. If it passes, the validate task is done as usual. If lint still fails, go to
   [Remediation](#remediation) (any FLAKY or environmental failures go under Not behavior);
   otherwise act on the result per [Gate Outcomes](#gate-outcomes).

## Commits

The policy is the `commit:` line in the epic context: `per-task`, `per-group`, or `none`
(also when absent). Only the orchestrator commits; agents never commit or stage.

- **When.** With `per-task`, commit right before marking each task done, staging only the
  files that task reported (and the orchestrator's own `[WRITE]` files for it); each commit
  holds whatever state the task left, failing tests included. With `per-group`, commit right
  before marking a group's last task done, staging the files that group's tasks reported (and
  their `[WRITE]` files). A journey fragment is open from its `P{N}-E2E-Red-*` leaf until the
  next validate whose context has a Journey spec command is done (passed, or accepted by the
  user); `per-group` commits nothing in that span, the leaf included, then commits the whole
  fragment right before marking that validate done. If hooks or CI run the test suite on every commit, prefer
  `per-group` or `none`.
- **Stage only this commit's files.** First check the index (`git diff --cached --name-only`):
  a commit takes everything already staged, so if it lists anything, log `[BLOCKED] {task} —
  commit rejected: already staged: {paths}`, leave the task open, STOP and ask the user. Then
  `git add -- {files}`; if it fails, treat it like a rejected commit (below). Never stage
  `.light/`. If nothing is staged, skip the commit.
- **Draft manifest.** Before each commit, write the session manifest with progress so far,
  `"draft": true` and `test_suite_passed: false` (see [session-manifest.md](session-manifest.md)),
  so a manifest-checking `commit-msg` hook can see the work. Step 5b's final write replaces it.
- **Log** `[WRITE] {task} — git commit {sha}; orchestrator wrote: {files}`, where `{task}` is
  the task about to be marked done.
- **A hook rejects the commit:** unstage this commit's files (`git restore --staged --
  {files}`) so a retry passes the index check, log `[BLOCKED] {task} — commit rejected: {hook
  output line}`, leave the task open (it was not yet marked done), STOP and ask the user. Never
  commit with `--no-verify`.

---

## Error Handling Procedures

### If Phase Cannot Be Completed

If a phase cannot be completed after remediation:
1. **Report to user** with full failure context
2. **Ask for guidance** — should we adjust the approach?
3. **Don't skip ahead** — the naming convention prevents this (lower numbers must complete first)

### If Tracker State is Inconsistent

If readiness computation returns no tasks but non-done tasks remain:
1. Fetch the full task tree (tracker list command with JSON/verbose output)
2. Look for phase groups where all children are done but the parent isn't
3. Mark completed parents as done using the tracker's close/done command
4. Report to user with details
