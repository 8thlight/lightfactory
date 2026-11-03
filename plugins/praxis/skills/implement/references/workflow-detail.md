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
| `slice-review` | `praxis:reuse-simplify-reviewer` + `praxis:technical-project-manager` (`mode: slice-check`) | Review the validated phase diff for reuse and planned mitigations (SLICE gate, the REFACTOR step) — see [Slice Review](#slice-review) |
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
- `reuse-simplify-reviewer.md` — Slice review: logic the diff duplicates and code it doesn't need, reports only
- `technical-project-manager.md` — Slice review (`mode: slice-check`): mitigations tagged to the phase, reports only

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

- Within a TDD triplet: Write Tests → Implement → Validate → Slice Review MUST be sequential
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

## Slice Review

A slice review checks each TDD phase's diff once its VALIDATE gate passes, on `03-validate` or a `05-revalidate-attempt-{M}`. It is the REFACTOR step of RED → GREEN → REFACTOR: it reviews code that already passes the full suite, and since the next phase waits for the whole group, it runs before later phases build on the slice. Leaf `no-test` phases get no slice review; final verification's plan check covers their mitigations.

### Procedure

1. **When a validate task reports VALIDATE PASS**, create `06-slice-review` under the phase group before marking the validate task done (skip this if the group already has one):
   - **Phase diff.** The working tree against the run's base commit, limited to the paths the phase's `01-write-tests`, `02-implement` and `04-remediate-attempt-{N}` reports listed: `git diff {run base} -- {paths}`. The run base is the parent of the first commit the execution log records (`[WRITE] … git commit {sha}`), or `HEAD` when it records none, so the diff includes whatever the [commit policy](#commits) already committed. Untracked new files don't appear in `git diff`, so list them for the reviewers to read in full.
   - **Known issues.** List the `[CARRIED]` entries logged so far. The phase diff also shows earlier phases' changes to files they share, so without this list the reuse reviewer reports those again.
2. **Mark the validate task done.** `06-slice-review` is then the group's only open task, so it runs next.
3. **Dispatch** both reviewers in one message once it is ready. The TPM matches the plan's "Delivered in" column against the phase group name (`P2-Core-Logic`), and reports nothing to check when no row names it:
   ```
   Task(description="P{N}: {Phase} — reuse/simplify", subagent_type="praxis:reuse-simplify-reviewer", prompt="{slice review context}")
   Task(description="P{N}: {Phase} — slice check", subagent_type="praxis:technical-project-manager", prompt="mode: slice-check\nplan: {plan path}\nphase group: {phase group}\ndiff: {phase diff}")
   ```
4. **SLICE gate.** The remediation items are reuse findings rated HIGH or MEDIUM, plus each entry under the TPM's `### Remediation`. Log LOW findings, and TPM `changed` rows that still cover their risk, as `[CARRIED]`. Then:
   - **No items:** log `[GATE PASS]` and mark `06-slice-review` done.
   - **Items:** log `[GATE FAIL]` and route each one (below) while `06-slice-review` is still open. Mark it done only once every item has somewhere to go: a slice remediation task, a `[CARRIED]` entry, or tasks the user added at a STOP. Until then, log `[BLOCKED]` and leave it open. Closed, it would let a resumed run move past an unrouted item, because recovery only waits on open tasks.

### Routing Items

Route each item by what fixing it touches. For a TPM entry, go by the Evidence column of its plan row.

| Item | Fixing it touches | Route |
|------|-------------------|-------|
| Reuse finding with **Test impact:** none | implementation only | Slice remediation |
| Reuse finding that names tests to change | tests | STOP — ask the user |
| TPM entry whose evidence is code, a gate or config | implementation only | Slice remediation |
| TPM entry whose evidence is a test | tests | STOP — ask the user |
| TPM entry whose evidence is a runbook step or metric | outside the repo | `[CARRIED]` |

The STOP is there because `agent-remediate` never edits tests, and changed behavior needs a RED step first. Show the user the item and the tests it touches. They can update the task graph explicitly, for example by adding a write-tests/implement pair for the phase. Or they can defer the item, which you then log as `[CARRIED]`.

"Call the existing X instead" is usually implementation-only. Phase tests assert behavior at L3/L4 boundaries, so replacing a re-derived rule with a call to the existing implementation leaves them passing, as long as the two agree. If they disagree (the copy diverged), tests fail during remediation and `agent-remediate` reports that the fix needs a test change. STOP then too, because deciding which behavior is right is the user's call.

### Slice Remediation

1. Create, in this order under the phase group: `07-slice-remediate-attempt-{M}` (agent-type `agent-remediate`), `08-slice-revalidate-attempt-{M}` (agent-type `agent-validate`, with the phase's validate context) and `09-slice-verify-attempt-{M}` (agent-type `slice-review`).
2. Re-validation runs the validate task's checks on the remediated code, as `05-revalidate-attempt-{N}` does. Behavior or type-check failures don't start [Remediation](#remediation): log `[GATE FAIL]`, mark it done, and pass its failure output to the next slice attempt. Other failures follow [Gate Outcomes](#gate-outcomes).
3. The verify task's diff covers the phase's paths plus every file the remediation report lists as modified, since an item may restructure an existing implementation outside the phase. It re-dispatches only the reviewers that still have open items:
   - the reuse reviewer, with **Findings to verify** set to its open items;
   - the TPM, with the same slice-check on the wider diff.

   If tests fail or items are still open, route them again and start the next attempt with the implementation-only items and any failure output. Log each attempt as `[REMEDIATION] {group} / 06-slice-review — attempt {M}: {items}`; `M` = 1 + the slice attempts already logged for the group. If `M` would exceed 2, log `[BLOCKED]`, leave the verify task open and **STOP — ask the user**.

Mark `07-` and `08-` tasks done once they have reported, as with `03-validate`. Close a verify task by the same rule as `06-slice-review` (Procedure step 4): only once every open item has a next attempt, a `[CARRIED]` entry or tasks the user added, and never while it is `[BLOCKED]`.

### Per-Tracker Commands

| Tracker | Create `{name}` with agent-type `{type}` |
|---------|------------------------------------------|
| YAKS | `yx add "{name}" --under "{group id}" --field "agent-type={type}"`, with the context in a quoted heredoc (below); `{group id}` comes from `yx list --format json` |
| BEADS | `Skill: beads:create --title "{phase group} / {name}" --epic "{epic-id}" --label "{type}"`, with the context as its description. Then `Skill: beads:dep --from "{new task id}" --to "{previous task id}"`, where the previous task is the validate task that passed or the slice task before it. Then add the next-phase dependency (below) |
| NATIVE | `TaskCreate: { title: "{phase group} / {name} [{type}]", description: "{context}" }` |

In beads, the next P{N} groups depend on the validate task that passed, so closing it would make them ready alongside `06-slice-review`. Before closing the task a new slice task follows, make each next group's first task (a leaf group's only task) depend on the group's newest terminal slice task: `06-slice-review`, then each `09-slice-verify-attempt-{M}`. Re-validation does the same ([tracker-beads.md](tracker-beads.md#create-re-validation-task)):

```
Skill: beads:dep --from "{next group's first task id}" --to "{06-slice-review or 09-slice-verify id}"
```

Slice contexts are full of backticked paths and `git diff` commands. Inside `echo "{context}"` the shell would run them, so quote the heredoc delimiter instead:

```bash
yx add "{name}" --under "{group id}" --field "agent-type={type}" <<'CONTEXT'
{context}
CONTEXT
```

### Slice Review Context

Use this for `06-slice-review` and `09-slice-verify-attempt-{M}`:

```markdown
## Agent Task: Slice Review — {Phase Name} (Phase {N})

**Role:** Review this phase's diff and report. Do NOT modify any files.

### Agent Context
- **Phase group:** `{phase group}`
- **Diff:** `git diff {run base} -- {paths}`; new files (read in full): `{paths}`
- **Reuse candidates:** `{research artifact path}` (`### Reuse candidates`), or "none"
- **Plan:** `{plan path}`
- **Repo root:** `{path}`
- **Known issues:** {the `[CARRIED]` entries so far, or "none"}
- **Findings to verify:** {verify tasks only: the open items from the previous attempt}
```

### Slice Remediation Context

```markdown
## Agent Task: Remediate Slice Review — {Phase Name} (Phase {N}, attempt {M})

**Role:** Apply the slice review items below to the implementation. Do NOT modify test files. Each item's suggested change is the fix, and every test must still pass.

### Agent Context
- **Files to modify (implementation):** `{implementation file path(s)}`, plus the existing implementations the items name
- **Files to read (tests, DO NOT MODIFY):** `{test file path(s)}`
- **Full test command:** `{full test suite command}`
- **Failure output:** {attempt 2 only: the previous attempt's re-validation failures, or omit}
- **Items:**

{for each item: location, the existing implementation it duplicates (file:symbol) or the missing mitigation, and the suggested change}

### Instructions
1. Read each item's existing implementation before changing anything
2. Call or restructure the existing implementation as the item suggests. Never add a parallel path
3. Run the full test suite. ALL tests must pass
4. If an item can't be fixed without changing a test, leave it and say why

### Report
- Files modified: [list paths]
- Items: [for each item: fixed, or not fixed and why]
- Test command output: [paste]
- Result: ALL PASS or STILL FAILING
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
| agent-validate: PASS | Log `[GATE PASS]`. In a TDD phase group with no slice review yet, create `06-slice-review` first ([Slice Review](#slice-review)). Mark done. When the context has a Journey spec command, it is a PASS only if the report's Journey spec line says PASS; a "not run" line is an environmental failure (next row). A missing line: re-dispatch the task once; missing again, log `[BLOCKED]`, leave it open, STOP and ask |
| agent-validate: failures | On an `08-slice-revalidate-attempt-{M}`, behavior or type-check failures go to the next slice attempt ([Slice Remediation](#slice-remediation)). Otherwise take the first match: (1) a behavior test failure or a type-check failure → [Remediation](#remediation), with any FLAKY or environmental failures listed in the remediation context as not to fix; (2) otherwise a lint failure → [Lint Fast Path](#lint-fast-path); (3) otherwise only FLAKY or environmental test failures → log `[GATE FAIL] {task} — VALIDATE gate failed: {FLAKY: command, reruns, log path / environmental: line}` and `[BLOCKED]`, leave the task open, STOP and ask. The user accepts (mark done, logging `[CLOSED] {task} — user approval: "{quote}"`), asks for a rerun (re-dispatch the task), or fixes the environment or test and then asks for a rerun |
| agent-remediate: ALL PASS or STILL FAILING | Log `[GATE PASS]` or `[GATE FAIL] {task} — GREEN gate …`, mark done; its re-validation runs next |
| slice-review: SLICE gate PASS | Log `[GATE PASS]` and each non-blocking item as `[CARRIED]`, mark done |
| slice-review: SLICE gate FAIL | Log `[GATE FAIL]` and each non-blocking item as `[CARRIED]`, then route the items ([Routing Items](#routing-items)). Mark done once every item has a slice remediation task, a `[CARRIED]` entry or tasks the user added. An item that needs a STOP, or a third slice attempt: log `[BLOCKED]`, leave the task open, STOP and ask |
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
[DISPATCHED] {task} — agent type: {agent-test|agent-impl|agent-validate|agent-remediate|slice-review|no-test}, mode: {sync|parallel}
[GATE PASS] {task} — {RED|GREEN|VALIDATE|SLICE|ACCEPTANCE} gate passed (RED: {decisive line} @ {file:line}; GREEN: YAGNI removals: {from the agent's report, or none}); files: {paths}
[GATE PASS] {task} — RED gate N/A: test repair accepted; files: {paths}
[GATE FAIL] {task} — {RED|GREEN|VALIDATE|SLICE|ACCEPTANCE} gate failed: {reason}; files: {paths}
[REMEDIATION] {task} — attempt {N}: {failures | cause=TEST-DEFECT: {test, why} | cause=TEST-DEFECT rejected: {test, assertion}: {why}}[; files: {paths}]
[BLOCKED] {task} — {reason: escalation, attempt limit, refused close by {id}, commit rejected, repair diff rejected, pending user decision}[: TEST-DEFECT {test, assertion, why}][; files: {paths}]
[CARRIED] {task} — {deferred item: what, where, and why it was deferred}
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
3. **Decide.** Compare the cited assertion with the acceptance criteria in the epic context,
   the Interface contract in the group's `02-implement` context, and the owner's test spec.
   Uphold the claim only if the assertion contradicts a criterion or the contract (no
   implementation that meets them could pass it); reject it if the assertion follows from them,
   or from the owner's test spec where they say nothing. If neither settles it, log `[BLOCKED] {task} —
   pending user decision: TEST-DEFECT {test, assertion, why}`, leave the reporting task open,
   and ask the user.
4. **Rejected:** log `[REMEDIATION] {task} — attempt {N}: cause=TEST-DEFECT rejected: {test,
   assertion}: {why}` and mark the reporting task done. Its validate (`03-validate` or
   `05-revalidate-attempt-{M}`) runs next, and the next remediation context carries
   `Rejected TEST-DEFECT: {test, assertion} — {why}`.
5. **Upheld:** first log `[REMEDIATION] {task} — attempt {N}: cause=TEST-DEFECT: {test, why}`.
   Then copy the cited file to `.light/test-defect-{group}-attempt-{N}.orig`, create a repair task in
   the same group that sorts just before the reporting task — `01r-test-repair-attempt-{N}` for
   `02-implement`, `03r-test-repair-attempt-{N}` for `04-remediate-attempt-{M}` (agent-type
   `agent-test`; tracker commands in the tracker files; `M` is the attempt number in the
   reporting task's name) — and, for a claim from `04-remediate-attempt-{M}`, mark that task done
   (its `05-revalidate-attempt-{M}` then runs after the repair). The repair's context is the
   owner's write-tests context (with its runner, preflight and RED gate profile), the TEST-DEFECT
   report, and the violated acceptance criterion. On resume, an upheld-claim line whose `.orig`
   copy or repair task is missing, or whose `04-remediate-attempt-{M}` is still open, means this
   step stopped part-way: finish the missing parts (never re-copy an existing `.orig`).
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
re-validation that fails starts the next attempt from step 1. On resume, a validate's
`[REMEDIATION]` line whose `04-`/`05-` tasks are missing, or whose validate is still open, means
this procedure stopped part-way: create only the missing `04-`/`05-` task (never a second copy),
then do step 5, instead of re-dispatching the validate.

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
- **Files to read (tests, DO NOT MODIFY):** `{test file path(s)} — for a journey fragment's last validate, also the journey spec and its page objects and fixtures; the test-runner config is test-side too`
- **Acceptance criterion:** {copied from the phase's `02-implement` context — for a journey fragment's last validate, every criterion the fragment serves}
- **Interface contract:** {copied from the phase's `02-implement` context — for a journey fragment's last validate, every phase's contract in the fragment; omit when none}
- **Full test command:** `{the failed validate task's Full test command}`
- **Journey spec command:** `{the failed validate task's Journey spec command}` — omit when it had none
- **Preflight:** {the failed validate task's Preflight — omit when it had none}
- **Not behavior (don't fix):** {FLAKY or environmental failures from the same report — omit when none}
- **Rejected TEST-DEFECT:** {test, assertion} — {why the orchestrator rejected the claim; one line per rejected claim on this phase — omit when none}
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
3. If it passes, the validate task is done as usual. If lint still fails in implementation
   files, go to [Remediation](#remediation) (any FLAKY or environmental failures go under Not
   behavior). If it still fails only in test files, no implementation agent may fix it: log
   `[GATE FAIL]` and `[BLOCKED]`, leave the validate open, STOP and ask the user. Otherwise act
   on the result per [Gate Outcomes](#gate-outcomes).

## Commits

The policy is the `commit:` line in the epic context: `per-task`, `per-group`, or `none`
(also when absent). Only the orchestrator commits; agents never commit or stage.

- **Clean start.** On a fresh run (not a resume) whose policy commits, check
  `git status --porcelain --untracked-files=no` before dispatching anything. If it lists a file
  outside `.light/` and `.beads/` (tracker state), STOP and ask the user to commit or stash it:
  `git add` stages whole files, so a task's commit would take the user's own edits in any file
  the task also touched.

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
  stage with `git --literal-pathspecs add -- {files}`, each path quoted (paths such as
  `app/[id]/page.tsx` are otherwise globs), leaving out paths `git check-ignore` reports and
  `.light/`; if it fails, treat it like a rejected commit (below). If nothing is staged, skip
  the commit.
- **Draft manifest.** Before each commit, write the session manifest with progress so far,
  `"draft": true` and `test_suite_passed: false` (see [session-manifest.md](session-manifest.md)),
  so a manifest-checking `commit-msg` hook can see the work. Step 5b's final write replaces it.
- **Log** `[WRITE] {task} — git commit {sha}; orchestrator wrote: {files}`, where `{task}` is
  the task about to be marked done.
- **A hook rejects the commit:** unstage everything (`git reset -q`; the index held only this
  commit's files) so a retry passes the index check, log `[BLOCKED] {task} — commit rejected: {hook
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
