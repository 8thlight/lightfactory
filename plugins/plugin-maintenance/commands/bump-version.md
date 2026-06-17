---
description: Find all plugin.json files under plugins/ that are modified in git, increment their patch version, and print a summary for review before committing.
allowed-tools: Bash(git diff:*) Read Write
---

## Your Task

### 1. Find modified plugin.json files

Run:

```bash
git diff --name-only HEAD
git diff --name-only --cached
```

Collect all unique paths from both outputs that match the pattern `plugins/*/plugin.json` or `plugins/*/.claude-plugin/plugin.json`.

If no plugin.json files are modified (staged or unstaged), print:

```
No modified plugin.json files found. Nothing to bump.
```

Then stop.

### 2. For each modified plugin.json

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
