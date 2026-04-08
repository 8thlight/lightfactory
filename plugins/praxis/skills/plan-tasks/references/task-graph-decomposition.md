# Task Graph Decomposition

After writing the plan file, create a task graph epic with per-agent-step tasks that `/implement` will execute. The task graph is the **contract between plan-tasks and implement** — each task's context contains everything an agent needs.

## Task Tracker Detection

Before creating tasks, detect which tracker is available:

1. Check yaks: `yx list --format json` → Success = YAKS mode
2. Check beads: `ls .beads/config.yaml` → Success = BEADS mode
3. Default = NATIVE mode (TaskCreate/TaskList/TaskUpdate)

Use the first mode that succeeds. Proceed to the corresponding procedure below.

## Naming Convention

The naming convention drives ordering. The implement skill uses these names to compute readiness.

### Phase Groups (parent tasks under the epic)

Use `P{N}-{Name}` format:
- **Numeric prefix** determines ordering: P1 must complete before P2 starts
- **Same prefix number** = independent, can run in parallel (e.g., `P2-Feature-A` and `P2-Feature-B`)
- **Leaf phase groups** (no children): the phase group itself is the task (e.g., `P1-Schema-Setup`)
- **Parent phase groups** (with children): contain the TDD triplet as numbered children

### Children (individual agent tasks)

Use `NN-{role}` format within each phase group:
- `01-write-tests` — RED gate agent
- `02-implement` — GREEN gate agent
- `03-validate` — VALIDATE gate agent

Children execute sequentially by their numeric prefix within the parent.

## Tracker Procedures

See the appropriate reference file for the full procedure for each tracker mode:

- **YAKS mode** — See [tracker-yaks.md](tracker-yaks.md) for the full YAKS procedure (epic creation, TDD phase groups, leaf phases, readiness convention).
- **BEADS mode** — See [tracker-beads.md](tracker-beads.md) for the full BEADS procedure (epic creation, TDD phase groups, leaf phases, readiness convention).
- **NATIVE mode** — See [tracker-native.md](tracker-native.md) for the full NATIVE procedure (epic creation, TDD phase groups, leaf phases, readiness convention).

## Inline Task Graph (Edge Case)

Only use the inline task graph when ALL three trackers are unavailable. Instead of creating external tasks, embed the full task graph directly in the plan file as an additional section:

```markdown
## Inline Task Graph (no tracker available)

### P1-Apply-Schema [no-test] [no prerequisites]
- **Agent Context:** {full agent context as would appear in task context}

### P2-Core-Logic / 01-write-tests [agent-test, L3] [after: P1]
- **Agent Context:** {full agent context}

### P2-Core-Logic / 02-implement [agent-impl] [after: 01-write-tests]
- **Agent Context:** {full agent context}

### P2-Core-Logic / 03-validate [agent-validate] [after: 02-implement]
- **Agent Context:** {full agent context}

### P3-Feature-Use-Case / 01-write-tests [agent-test, L3] [after: P2]
- **Agent Context:** {full agent context}
```

Each inline task follows the same description format as task contexts — self-contained with everything an agent needs. `/implement` will consume this inline graph when no tracker is available.

## Example Decomposition (6-phase feature)

```
Epic: "Add Discount Codes"

P1-Schema-Setup              (leaf, agent-type=no-test)

P2-Core-Logic                (parent, TDD L3)
├── 01-write-tests           (agent-type=agent-test)
├── 02-implement             (agent-type=agent-impl)
╰── 03-validate              (agent-type=agent-validate)

P3-Repository-Layer          (leaf, agent-type=no-test)

P4-Apply-Discount            (parent, TDD L3)
├── 01-write-tests           (agent-type=agent-test)
├── 02-implement             (agent-type=agent-impl)
╰── 03-validate              (agent-type=agent-validate)

P5-HTTP-Routes               (parent, TDD L4)
├── 01-write-tests           (agent-type=agent-test)
├── 02-implement             (agent-type=agent-impl)
╰── 03-validate              (agent-type=agent-validate)

P6-Full-Integration          (leaf, agent-type=agent-validate)
```

**Readiness walk-through:**
1. Start: P1 is ready (no prerequisites)
2. P1 done → P2 active → `01-write-tests` ready
3. P2/01-write-tests done → P2/02-implement ready
4. P2/03-validate done → P3 ready (all P2 groups done)
5. P3 done → P4 active → `01-write-tests` ready
6. ...and so on until P6 completes

**With parallel phases** (same prefix number):
```
P2-Feature-A / 01-write-tests  AND  P2-Feature-B / 01-write-tests  → both ready when P1 done
```
