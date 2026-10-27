# Tracker: YAKS

Reference for the YAKS tracker mode — agent prompt reading, readiness computation, remediation and TEST-DEFECT repair commands.

## Agent Prompt Reading

```bash
yx context "{task name}"
```

Returns the self-contained agent task description stored with the task. The epic's own context (`yx context "{epic}"`) holds the `commit:` line and the acceptance criteria.

---

## Readiness Computation

Use `yx list --format json` to fetch the epic tree, then apply this algorithm:

```python
# Pseudocode — applies to YAKS mode
def compute_ready(epic_json):
    phase_groups = epic_json["children"]  # top-level children of the epic

    # 1. Extract prefix number from name (e.g., "P2-Core-Logic" → 2)
    for group in phase_groups:
        group["prefix"] = int(re.match(r"P(\d+)", group["name"]).group(1))

    # 2. Group by prefix number
    by_prefix = defaultdict(list)
    for group in phase_groups:
        by_prefix[group["prefix"]].append(group)

    # 3. Find active groups (all lower-prefix groups done)
    ready = []
    for prefix in sorted(by_prefix.keys()):
        # Check all lower-prefix groups are done
        all_lower_done = all(
            g["state"] == "done"
            for p in by_prefix if p < prefix
            for g in by_prefix[p]
        )
        if not all_lower_done:
            break  # This prefix and all higher are blocked

        for group in by_prefix[prefix]:
            if group["state"] == "done":
                continue
            if not group["children"]:
                # Leaf phase group — the group itself is the task
                ready.append(group)
            else:
                # Parent phase group — find first non-done child
                for child in sorted(group["children"], key=lambda c: c["name"]):
                    if child["state"] != "done":
                        ready.append(child)
                        break

    return ready
```

---

## Remediation Commands

### Create remediation task

```bash
yx add "04-remediate-attempt-1" --under "P2-Core-Logic" --field "agent-type=agent-remediate"
echo "{remediation context}" | yx context "04-remediate-attempt-1"
```

### Create re-validation task

```bash
yx add "05-revalidate-attempt-1" --under "P2-Core-Logic" --field "agent-type=agent-validate"
echo "{the original validate task's context}" | yx context "05-revalidate-attempt-1"
```

### Mark original validate task as done

```bash
yx done "03-validate"
```

## TEST-DEFECT Repair Commands

For an upheld claim from `02-implement` (from `04-remediate-attempt-{M}`, use `03r-…` instead):

```bash
yx add "01r-test-repair-attempt-1" --under "P2-Core-Logic" --field "agent-type=agent-test"
echo "{repair context}" | yx context "01r-test-repair-attempt-1"
```

Name sorting puts it after `01-write-tests` and before `02-implement`, so readiness dispatches it next.
