# Tracker: NATIVE

Reference for the NATIVE tracker mode — agent prompt reading, readiness computation, and remediation commands.

## Agent Prompt Reading

```
TaskGet: { id: "{task-id}" }
```

Reads agent context from the description field.

---

## Readiness Computation

Use `TaskList` to fetch all tasks, then apply the same naming-convention algorithm as YAKS: extract the `P{N}` prefix from each task title, group by prefix, and return the first non-done tasks at the lowest incomplete prefix level. Parse `TaskList` output instead of yaks JSON.

---

## Remediation Commands

### Create remediation task

```
TaskCreate: { title: "04-remediate-attempt-1", description: "{remediation context}" }
```

Include the full remediation context (failure output, files to fix, instructions) in the description field.

### Create re-validation task

```
TaskCreate: { title: "05-revalidate-attempt-1", description: "{revalidation context}" }
```

### Mark original validate task as done

```
TaskUpdate: { id: "{task-id}", status: "completed" }
```
