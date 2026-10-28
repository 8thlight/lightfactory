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

Name issues by their ID from `Skill: beads:list`, never by child name: child names
(`03-validate`, `04-remediate-attempt-1`, …) repeat in every group.

### Create remediation task

```
Skill: beads:create --title "P2-Core-Logic / 04-remediate-attempt-1" --epic "{epic-id}" --label "agent-remediate"
  description: {remediation context}
```

Then set the dependency:

```
Skill: beads:dep "{04-remediate id}" depends-on "{validate id}"
```

### Create re-validation task

```
Skill: beads:create --title "P2-Core-Logic / 05-revalidate-attempt-1" --epic "{epic-id}" --label "agent-validate"
  description: {the original validate task's context}
Skill: beads:dep "{05-revalidate id}" depends-on "{04-remediate id}"
```

The next P{N} groups depend on the validate that is about to close, so make each one's first
task (a leaf group's only task) depend on the re-validation too; otherwise `beads:ready` starts
the next phase while this one is still being remediated:

```
Skill: beads:dep "{next group's first task id}" depends-on "{05-revalidate id}"
```

### Mark original validate task as done

```
Skill: beads:close "{validate id}"
```

## TEST-DEFECT Repair Commands

For an upheld claim from `02-implement` (from `04-remediate-attempt-{M}`, use `03r-…` and make `05-revalidate-attempt-{M}` depend on it):

```
Skill: beads:create --title "P2-Core-Logic / 01r-test-repair-attempt-1" --epic "{epic-id}" --label "agent-test"
  description: {repair context}
Skill: beads:dep "{02-implement id}" depends-on "{repair id}"
```
