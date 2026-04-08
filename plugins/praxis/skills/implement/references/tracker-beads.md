# Tracker: BEADS

Reference for the BEADS tracker mode — agent prompt reading, readiness computation, and remediation commands.

## Agent Prompt Reading

```
Skill: beads:show {issue-id}
```

Reads agent context from the issue description.

---

## Readiness Computation

```
Skill: beads:ready
```

Returns the unblocked tasks directly — no in-skill computation needed.

---

## Remediation Commands

### Create remediation task

```
Skill: beads:create "04-remediate-attempt-1"
```

Set parent to `P2-Core-Logic` and include the `agent-type=agent-remediate` field. Then set the dependency:

```
Skill: beads:dep "04-remediate-attempt-1" depends-on "03-validate"
```

### Create re-validation task

```
Skill: beads:create "05-revalidate-attempt-1"
Skill: beads:dep "05-revalidate-attempt-1" depends-on "04-remediate-attempt-1"
```

### Mark original validate task as done

```
Skill: beads:close "03-validate"
```
