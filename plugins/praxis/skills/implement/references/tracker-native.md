# Tracker: NATIVE

Reference for the NATIVE tracker mode — agent prompt reading, readiness computation, remediation and TEST-DEFECT repair commands.

## Agent Prompt Reading

```
TaskGet: { id: "{task-id}" }
```

Reads agent context from the description field. The epic task's description holds the `commit:` line and the acceptance criteria.

---

## Readiness Computation

Use `TaskList` to fetch all tasks, then apply the same naming-convention algorithm as YAKS: extract the `P{N}` prefix from each task title, group by prefix, and return the first non-done tasks at the lowest incomplete prefix level. Parse `TaskList` output instead of yaks JSON.

---

## Remediation Commands

### Create remediation task

```
TaskCreate: { title: "P2-Core-Logic / 04-remediate-attempt-1 [agent-remediate]", description: "{remediation context}" }
```

Titles carry the `P{N}` group and `[agent-type]`, which readiness and dispatch read. Include the full remediation context in the description field.

### Create re-validation task

```
TaskCreate: { title: "P2-Core-Logic / 05-revalidate-attempt-1 [agent-validate]", description: "{the original validate task's context}" }
```

### Mark original validate task as done

```
TaskUpdate: { id: "{task-id}", status: "completed" }
```

## TEST-DEFECT Repair Commands

For an upheld claim from `02-implement` (from `04-remediate-attempt-{M}`, use `03r-…`):

```
TaskCreate: { title: "P2-Core-Logic / 01r-test-repair-attempt-1 [agent-test]", description: "{repair context}" }
```
