# Tracker: BEADS

Reference for the BEADS tracker mode — agent prompt reading, readiness computation, remediation and TEST-DEFECT repair commands.

## Agent Prompt Reading

```
Skill: beads:show {issue-id}
```

Reads agent context from the issue description. The epic's description holds the `commit:` line and the acceptance criteria.

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
Skill: beads:create --title "P2-Core-Logic / 04-remediate-attempt-1" --epic "{epic-id}" --label "agent-remediate"
  description: {remediation context}
```

Then set the dependency:

```
Skill: beads:dep "04-remediate-attempt-1" depends-on "03-validate"
```

### Create re-validation task

```
Skill: beads:create --title "P2-Core-Logic / 05-revalidate-attempt-1" --epic "{epic-id}" --label "agent-validate"
  description: {the original validate task's context}
Skill: beads:dep "05-revalidate-attempt-1" depends-on "04-remediate-attempt-1"
```

### Mark original validate task as done

```
Skill: beads:close "03-validate"
```

## TEST-DEFECT Repair Commands

For an upheld claim from `02-implement` (from `04-remediate-attempt-{M}`, use `03r-…` and make `05-revalidate-attempt-{M}` depend on it):

```
Skill: beads:create --title "P2-Core-Logic / 01r-test-repair-attempt-1" --epic "{epic-id}" --label "agent-test"
  description: {repair context}
Skill: beads:dep "02-implement" depends-on "01r-test-repair-attempt-1"
```
