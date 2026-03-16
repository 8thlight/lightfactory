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

## Procedure: YAKS Mode

1. **Create the epic** yak: `yx add "{Feature Name}"`
2. **For each phase**, create yaks per the agent-step decomposition:
   - **Leaf phases** (schema, infrastructure): single yak under the epic with `--field "agent-type=no-test"`
   - **TDD phases**: parent yak under epic + 3 children (write-tests, implement, validate)
   - **Final verification**: single yak under epic with `--field "agent-type=agent-validate"`
3. **Set custom fields** on each yak: `--field "agent-type={agent-test|agent-impl|agent-validate|no-test}"`
4. **Pipe context** into each leaf yak (the Agent Context block from the plan):
   ```bash
   echo "{agent context markdown}" | yx context "{yak name}"
   ```

### Creating a TDD Phase Group (YAKS)

```bash
# Create the phase group parent
yx add "P2-Core-Logic" --under "{Feature Name}"

# Create TDD triplet children
yx add "01-write-tests" --under "P2-Core-Logic" --field "agent-type=agent-test"
yx add "02-implement" --under "P2-Core-Logic" --field "agent-type=agent-impl"
yx add "03-validate" --under "P2-Core-Logic" --field "agent-type=agent-validate"

# Pipe agent context into each child
echo "{write-tests agent context}" | yx context "01-write-tests"
echo "{implement agent context}" | yx context "02-implement"
echo "{validate agent context}" | yx context "03-validate"
```

### Creating a Leaf Phase (YAKS)

```bash
yx add "P1-Schema-Setup" --under "{Feature Name}" --field "agent-type=no-test"
echo "{agent context}" | yx context "P1-Schema-Setup"
```

### Readiness Convention (YAKS)

The implement skill computes readiness from `yx list --format json` using these rules:

1. **Phase groups ordered by prefix**: P1 < P2 < P3 (extracted from name)
2. **Same-prefix groups are independent**: P2-Feature-A and P2-Feature-B can run in parallel
3. **A phase group is "active"** when all lower-prefix groups are done
4. **Within an active group**:
   - Leaf (no children): the yak itself is ready if state != done
   - Parent (has children): the first child by name sort with state != done is ready
5. **All ready tasks** from all active groups are dispatched in parallel

## Procedure: BEADS Mode

1. **Create the epic**: `Skill: beads:epic --title "{Feature Name}"`
2. **For each phase**, create issues per the agent-step decomposition:
   - **Leaf phases**: `Skill: beads:create --title "P1-Schema-Setup [no-test]" --epic "{epic-id}" --label "no-test"`
   - **TDD phases**: three issues per phase group (write-tests, implement, validate)
   - **Final verification**: `Skill: beads:create --title "P6-Full-Integration [agent-validate]" --epic "{epic-id}" --label "agent-validate"`
3. **Set dependencies** between issues: `Skill: beads:dep --from "{child-id}" --to "{parent-id}"`
   - Each TDD child depends on its predecessor within the phase group
   - Each phase group's first task depends on the last task of the preceding phase group
4. **Store agent context** in each issue's description body (the Agent Context block from the plan)

### Creating a TDD Phase Group (BEADS)

```
Skill: beads:create --title "P2-Core-Logic / 01-write-tests" --epic "{epic-id}" --label "agent-test"
  description: {write-tests agent context}

Skill: beads:create --title "P2-Core-Logic / 02-implement" --epic "{epic-id}" --label "agent-impl"
  description: {implement agent context}

Skill: beads:create --title "P2-Core-Logic / 03-validate" --epic "{epic-id}" --label "agent-validate"
  description: {validate agent context}

# Set sequential dependencies within the phase group
Skill: beads:dep --from "02-implement-id" --to "01-write-tests-id"
Skill: beads:dep --from "03-validate-id" --to "02-implement-id"

# Set phase group dependency on preceding phase
Skill: beads:dep --from "P2/01-write-tests-id" --to "P1-last-task-id"
```

### Creating a Leaf Phase (BEADS)

```
Skill: beads:create --title "P1-Schema-Setup [no-test]" --epic "{epic-id}" --label "no-test"
  description: {agent context}
```

### Readiness Convention (BEADS)

The implement skill computes readiness from `Skill: beads:list --epic "{epic-id}"` using the same P{N} prefix ordering rules as YAKS mode. Tasks with all dependencies resolved and status != done are ready.

## Procedure: NATIVE Mode

Use Claude Code's built-in task tools (TaskCreate/TaskList/TaskUpdate) when neither yaks nor beads is available.

1. **Create the epic task**: `TaskCreate: { title: "{Feature Name} [epic]", description: "Epic for {feature}" }`
2. **For each phase**, create tasks per the agent-step decomposition:
   - **Leaf phases**: `TaskCreate: { title: "P1-Schema-Setup [no-test]", description: "{full agent context}" }`
   - **TDD phases**: three tasks per phase group with agent-type encoded in the title
   - **Final verification**: `TaskCreate: { title: "P6-Full-Integration [agent-validate]", description: "{full agent context}" }`
3. **Agent-type and ordering** are encoded in task titles using the same `P{N}` and `[agent-type]` naming convention — no custom fields needed
4. **Agent context** is stored in the task description (the Agent Context block from the plan)

### Creating a TDD Phase Group (NATIVE)

```
TaskCreate: { title: "P2-Core-Logic / 01-write-tests [agent-test]", description: "{write-tests agent context}" }
TaskCreate: { title: "P2-Core-Logic / 02-implement [agent-impl]", description: "{implement agent context}" }
TaskCreate: { title: "P2-Core-Logic / 03-validate [agent-validate]", description: "{validate agent context}" }
```

### Creating a Leaf Phase (NATIVE)

```
TaskCreate: { title: "P1-Schema-Setup [no-test]", description: "{agent context}" }
```

### Readiness Convention (NATIVE)

The implement skill computes readiness from `TaskList` by:
1. Parsing titles for `P{N}` prefix to determine phase ordering
2. Filtering tasks by status (not done)
3. Applying the same P{N} ordering and parallel-prefix rules as YAKS mode

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
