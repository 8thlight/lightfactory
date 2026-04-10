# Harness Report Template

Use this template when writing the harness audit report to `.light/sessions/`.

---

```markdown
# Harness Report: {project-name}

**Date:** {YYYY-MM-DD}
**Language:** {detected language(s)}
**Toolchain:** {package manager, linter, type checker, CI provider}

## Audit Summary

| # | Pillar | Status | Finding |
|---|--------|--------|---------|
| 1 | Instruction Files | {Strong/Partial/Missing/N/A} | {1-line finding} |
| 2 | Hooks | {status} | {finding} |
| 3 | Type Safety | {status} | {finding} |
| 4 | Linting | {status} | {finding} |
| 5 | Pre-commit | {status} | {finding} |
| 6 | Architecture Tests | {status} | {finding} |
| 7 | CI Gates | {status} | {finding} |
| 8 | Sandbox & Permissions | {status} | {finding} |
| 9 | Secret Scanning | {status} | {finding} |

**Overall:** {X}/9 Strong, {Y}/9 Partial, {Z}/9 Missing, {W}/9 N/A

## Changes Applied

{For each improvement that was implemented:}

### {Pillar Name}
- **What:** {description of change}
- **Commit:** `{commit hash}` — `{commit message}`
- **Files:** {list of files modified}

## Deferred Items

{For items the user chose not to implement now:}

- **{Pillar}:** {what was deferred and why}

## Recommended Next Steps

1. {Highest-priority remaining improvement}
2. {Second priority}
3. {Third priority}
```
