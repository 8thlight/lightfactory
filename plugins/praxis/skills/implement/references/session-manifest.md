# Session Manifest

The session manifest is a structured JSON file written alongside the session artifact after `/implement` completes. It enables **automated commit-time verification** that the lightfactory workflow was followed.

## Purpose

Teams that adopt lightfactory as their standard implementation workflow need a way to verify at commit time that the workflow was actually used. The manifest provides a machine-readable record that downstream git hooks can check against the staged diff.

### The verification flow (downstream)

A project's `commit-msg` hook can:

1. Check if the commit was authored by Claude (via `Co-Authored-By` in the commit message)
2. If yes, analyze the diff to determine if changes are significant enough to require lightfactory
3. If significant, check `.light/sessions/` for a manifest whose files overlap with staged changes
4. Block the commit if no manifest covers the work

The manifest makes step 3 possible. Without it, the session artifact (`.md`) would need to be parsed — fragile and unreliable.

## File Location

```
.light/sessions/YYYY-MM-DD-{topic}.manifest.json
```

Written at the same time as the session artifact (`.light/sessions/YYYY-MM-DD-{topic}.md`), using the same topic slug.

## Schema

```json
{
  "version": 1,
  "session": "YYYY-MM-DD-{topic}",
  "timestamp": "ISO-8601 timestamp",
  "workflow_steps": ["research", "plan", "implement"],
  "files_created": ["src/lib/foo.ts", "src/lib/foo.test.ts"],
  "files_modified": ["src/app/api/bar/route.ts", "prisma/schema.prisma"],
  "phases_completed": 5,
  "total_phases": 5,
  "gates": {
    "red_passed": 3,
    "green_passed": 3,
    "validate_passed": 3
  },
  "test_suite_passed": true
}
```

### Field Reference

| Field | Type | Description |
|-------|------|-------------|
| `version` | number | Schema version (see Version Policy below). |
| `session` | string | Session identifier matching the artifact filename. |
| `timestamp` | string | ISO-8601 timestamp when the manifest was written. |
| `workflow_steps` | string[] | Which RPI steps were completed. Subset of `["research", "plan", "implement"]`. |
| `files_created` | string[] | Paths of files created during the session, relative to project root. |
| `files_modified` | string[] | Paths of files modified (not created) during the session, relative to project root. |
| `phases_completed` | number | Count of task phases that completed successfully. |
| `total_phases` | number | Total task phases in the plan. |
| `gates` | object | Count of each gate type that passed during the session. |
| `gates.red_passed` | number | Number of RED gates (test-writing) that passed. |
| `gates.green_passed` | number | Number of GREEN gates (implementation) that passed. |
| `gates.validate_passed` | number | Number of VALIDATE gates (full suite) that passed. |
| `test_suite_passed` | boolean | Whether the final verification test suite passed. |

## How File Lists Are Built

Each agent already reports files in its output:

- **agent-test**: `Files created: [list paths]` → all paths go to `files_created`
- **agent-impl**: `Files created/modified: [list paths]` → paths go to `files_modified` (unless already in `files_created`)
- **agent-no-test**: `Files created/modified: [list paths]` → paths that did not exist before the session go to `files_created`; paths that already existed go to `files_modified`
- **agent-remediate**: `Files modified: [list paths]` → all paths go to `files_modified` (unless already in `files_created`)
- **agent-validate**: no files reported (read-only agent, never modifies files)

The implement skill's orchestration loop collects these from each agent's report as tasks complete. At session end, it deduplicates and splits into `files_created` vs `files_modified`.

**Classification rule:** A file appears in `files_created` if it did not exist before the session started. A file appears in `files_modified` if it existed before the session and was changed. If a file was created by one agent and later modified by another (e.g., by agent-impl after agent-test), it stays in `files_created`. For `agent-no-test` which reports a combined `Files created/modified:` list, the orchestrator must check whether each path existed before the session to classify correctly.

## Workflow Steps Detection

The `workflow_steps` array records which RPI phases were completed:

- `"research"` — included if a research artifact (`.light/sessions/{bare-topic}-research.md`) exists for this topic. Note: research artifacts use the bare topic slug without the `YYYY-MM-DD-` date prefix that the session artifact and manifest use.
- `"plan"` — always included (implement requires a plan)
- `"implement"` — always included (the manifest is written by implement)

## Version Policy

Increment `version` when a field is removed or its semantics change. Adding new optional fields does not require a version bump. Consumers (e.g., git hooks) should reject manifests with an unknown version rather than silently misinterpreting them.
