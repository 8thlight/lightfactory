# Tracker: NATIVE Mode

Use this procedure when neither yaks nor beads is available. Uses Claude Code's built-in task tools (TaskCreate/TaskList/TaskUpdate).

## Procedure

1. **Create the epic task**: `TaskCreate: { title: "{Feature Name} [epic]", description: "Epic for {feature}" }`
2. **For each phase**, create tasks per the agent-step decomposition:
   - **Leaf phases**: `TaskCreate: { title: "P1-Schema-Setup [no-test]", description: "{full agent context}" }`
   - **TDD phases**: three tasks per phase group with agent-type encoded in the title
   - **Final verification**: `TaskCreate: { title: "P6-Full-Integration [agent-validate]", description: "{full agent context}" }`
3. **Agent-type and ordering** are encoded in task titles using the same `P{N}` and `[agent-type]` naming convention — no custom fields needed
4. **Agent context** is stored in the task description (the Agent Context block from the plan)

## Creating a TDD Phase Group (NATIVE)

```
TaskCreate: { title: "P2-Core-Logic / 01-write-tests [agent-test]", description: "{write-tests agent context}" }
TaskCreate: { title: "P2-Core-Logic / 02-implement [agent-impl]", description: "{implement agent context}" }
TaskCreate: { title: "P2-Core-Logic / 03-validate [agent-validate]", description: "{validate agent context}" }
```

## Creating a Leaf Phase (NATIVE)

```
TaskCreate: { title: "P1-Schema-Setup [no-test]", description: "{agent context}" }
```

## Readiness Convention (NATIVE)

The implement skill computes readiness from `TaskList` by:
1. Parsing titles for `P{N}` prefix to determine phase ordering
2. Filtering tasks by status (not done)
3. Applying the same P{N} ordering and parallel-prefix rules as YAKS mode
