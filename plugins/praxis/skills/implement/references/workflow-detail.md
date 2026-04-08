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
| `agent-validate` | `praxis:agent-validate` | Run full test suite, report only (VALIDATE gate) |
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

See `plugins/praxus/agents/` for the full agent definitions:
- `agent-test.md` — RED gate: writes failing tests only
- `agent-impl.md` — GREEN gate: minimal implementation + YAGNI simplification pass
- `agent-validate.md` — VALIDATE gate: runs full suite, reports only, never fixes
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

## Remediation Task Creation

When Agent 3 (Validate) reports failures, create new tasks under the same phase group parent to handle remediation. The procedure is the same across all tracker modes — only the commands differ.

### Procedure

1. **Create remediation task** (name: `04-remediate-attempt-{M}`, agent-type: `agent-remediate`) — see tracker file for commands
2. **Create re-validation task** (name: `05-revalidate-attempt-{M}`, agent-type: `agent-validate`) — see tracker file for commands
3. **Mark the original validate task as done** — it completed its job (reporting failures) — see tracker file for commands
4. The sequential naming (`04-`, `05-`) ensures remediation runs next, then re-validation

Per-tracker commands:

- **YAKS** — see [tracker-yaks.md](tracker-yaks.md#remediation-commands)
- **BEADS** — see [tracker-beads.md](tracker-beads.md#remediation-commands)
- **NATIVE** — see [tracker-native.md](tracker-native.md#remediation-commands)

### Remediation Task Context Template

```markdown
## Agent Task: Remediate — {Phase Name} (attempt {M})

**Role:** Fix the implementation to make all tests pass. Do NOT modify test files.

### Agent Context
- **Files to modify (implementation):** `{implementation file path(s)}`
- **Files to read (tests, DO NOT MODIFY):** `{test file path(s)}`
- **Full test command:** `{full test suite command}`
- **Failure output from validation:**

{paste Agent 3's failure output here}

### Instructions
1. Read the failing tests to understand expected behavior
2. Read the implementation files to find the issue
3. Fix the implementation — minimal changes only
4. Run the full test suite
5. Verify ALL tests pass

### Report
- Files modified: [list paths]
- What was fixed: [brief description]
- Test command output: [paste]
- Result: ALL PASS or STILL FAILING
```

### Escalation

If attempt count reaches 2 and re-validation still fails:
1. Report the failure to the user with full context
2. Wait for user guidance before proceeding

---

## Error Handling Procedures

### If Agent 1 RED Gate Fails

If tests pass immediately (before implementation):
1. **STOP** — the test is not testing new behavior
2. **Do NOT mark the task as done** — leave it
3. **Report to user** — explain that tests pass without implementation
4. **Do NOT dispatch Agent 2** — the phase is broken

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
