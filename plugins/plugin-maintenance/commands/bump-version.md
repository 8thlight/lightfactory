---
description: Find all plugin.json files under plugins/ that are modified in git, increment their patch version, and print a summary for review before committing.
allowed-tools: Bash(git diff:*) Read Write
---

## Your Task

### 1. Find plugins with modified files

Run:

```bash
git diff --name-only origin/HEAD
```

> If this errors with "unknown revision", run `git remote set-head origin -a` to sync the remote's default branch pointer, then retry.

Collect all paths that begin with `plugins/`. Extract the unique plugin directory names (the segment at `plugins/<name>/`). These are the plugins that need a version bump.

If no files under `plugins/` differ from `origin/HEAD`, print:

```
No modified plugin files found relative to origin/HEAD. Nothing to bump.
```

Then stop.

For each plugin with modified files, the target manifest is `plugins/<name>/.claude-plugin/plugin.json`.

### 2. For each affected plugin.json

Read the file and extract the current `"version"` field (semver string, e.g. `"1.4.1"`).

Increment the patch component:
- `1.4.1` → `1.4.2`
- `2.0.0` → `2.0.1`

Write the updated JSON back to the file with the new version value. Preserve all other fields and formatting.

### 3. Print a summary

After all files are updated, output a table:

```
Bumped plugin versions:

  plugins/example/.claude-plugin/plugin.json   1.4.1 → 1.4.2
  plugins/other/.claude-plugin/plugin.json     2.0.0 → 2.0.1

Review the changes above before committing.
```

Do not commit. Do not stage. The user will review and commit.
