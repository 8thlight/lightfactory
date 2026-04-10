# Pillar Details

Language-specific recommendations for each of the nine harness pillars. Read only the sections relevant to the project's detected language ecosystem.

---

## 1. Instruction Files

**What to check:**
- Does `./CLAUDE.md` exist? Is it under 200 lines?
- Are there path-scoped rules in `.claude/rules/`?
- Does it contain: build commands, test runners, style rules, env gotchas?
- Is there content that belongs in scoped rules rather than the root file?

**Recommendations:**
- Keep CLAUDE.md under 200 lines — agents ignore noisy context
- Move domain-specific instructions to `.claude/rules/{domain}.md` (e.g., `api.md`, `frontend.md`)
- Include only non-obvious information: build commands, test runners, conventions that differ from language defaults
- Treat instruction files like code — review and prune them regularly

**Strong signals:** CLAUDE.md exists, under 200 lines, has build/test commands, uses path-scoped rules for domain-specific guidance.

---

## 2. Hooks

**What to check:**
- Does `.claude/settings.json` or `.claude/settings.local.json` exist?
- Are any hooks configured under `hooks`?
- Are the three hook types covered?

**Hook types and examples:**

| Type | Purpose | Example Script |
|------|---------|---------------|
| `SessionStart` | Environment setup | Set PATH, NODE_ENV, verify tool versions |
| `PreToolUse` | Guard before action | Block writes to migration files without approval |
| `PostToolUse` | Validate after action | Run linter after Edit/Write operations |

**Exit codes:**
- `0` = allow (hook passes)
- `1` = non-blocking warning (stderr shown to user)
- `2` = block action + feed stderr back to agent as correction

**Recommended starter hooks:**

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "command": "echo 'Remember: run tests after significant changes'",
        "async": true
      }
    ]
  }
}
```

**Strong signals:** At least one PostToolUse hook for feedback, matcher patterns are specific (not overly broad), async flag used for non-blocking observations.

---

## 3. Type Safety

**What to check per language:**

### TypeScript
- `tsconfig.json` exists with `"strict": true`
- Additional strict flags: `noUncheckedIndexedAccess`, `noImplicitReturns`, `exactOptionalPropertyTypes`
- No `any` escape hatches in production code

### Python
- Type checker configured: pyright (`pyrightconfig.json`) or mypy (`mypy.ini` / `pyproject.toml`)
- Strict mode enabled: `typeCheckingMode: "strict"` (pyright) or `--strict` (mypy)
- Type stubs installed for dependencies (`types-*` packages)

### Go
- Go is statically typed by default — check for `golangci-lint` with `govet` enabled

### Rust
- Rust is statically typed by default — check `#![deny(warnings)]` and `clippy` in CI

**Why strict typing matters for agents:** Type checkers are the highest-leverage feedforward control. They constrain the agent's output space before it generates code, catching entire categories of errors at zero runtime cost.

**Strong signals:** Strict mode enabled, no blanket `any`/`type: ignore` suppressions, type stubs for dependencies.

---

## 4. Linting

**What to check:** Is a linter configured? Does it include rules beyond style — specifically correctness, security, and complexity?

### Python (Ruff)
Priority rule sets for AI-assisted development:
- `F` (pyflakes) — unused imports, undefined names
- `B` (bugbear) — common Python gotchas
- `S` (bandit) — security issues
- `ANN` (annotations) — missing type annotations
- `SIM` (simplify) — unnecessarily complex code
- `RET` (returns) — implicit returns, unnecessary else after return

### TypeScript (ESLint)
- `@typescript-eslint/recommended-type-checked` + `strict`
- `no-explicit-any` — prevents type escape hatches
- `no-floating-promises` — catches unhandled async errors

### Go
- `golangci-lint` with: `govet`, `errcheck`, `staticcheck`, `gosec`

**Custom linter messages (Fowler pattern):** Configure linter output to include self-correction instructions so agents can remediate automatically. Example: instead of "unused import", output "unused import — remove it or use it."

**Strong signals:** Linter configured with correctness + security rules (not just formatting), integrated into editor and CI.

---

## 5. Pre-commit

**What to check:**
- Does `.pre-commit-config.yaml` exist?
- Does the pipeline cover: secrets, lint, types, config validation?

**Recommended pipeline order:**
1. **Secret scanning** (gitleaks or truffleHog) — unconditional, fast
2. **Lint + format** (ruff --fix / eslint --fix + prettier)
3. **Type check** (mypy/pyright/tsc --noEmit)
4. **Config validation** (check-jsonschema, yamllint)
5. **Typo scanning** (typos) — optional but cheap

**Strong signals:** Pre-commit installed and configured, runs secret scanning first, includes type checking.

---

## 6. Architecture Tests

**What to check:**
- Are there import boundary rules or structural invariants enforced?
- Does the project have module boundaries that should be protected?

**Language-specific tools:**

| Language | Tool | What It Enforces |
|----------|------|-----------------|
| Java | ArchUnit | Layer dependencies, cycle detection |
| TypeScript | eslint-plugin-boundaries | Import graph rules by folder |
| Python | import-linter | Contract-based import restrictions |

**When this pillar is N/A:** Small projects, single-module projects, or projects without clear architectural layers. Don't force architecture tests where there's no architecture to protect.

**Strong signals:** Import boundaries enforced, no circular dependencies allowed, architectural invariants documented and tested.

---

## 7. CI Gates

**What to check:**
- Does a CI configuration exist?
- Does it follow the three-gate structure?

**Three-gate pipeline:**

| Gate | Time Target | What Runs |
|------|------------|-----------|
| Gate 1 | ~1 min | Format, lint, type check — fail fast |
| Gate 2 | ~5 min | Unit tests, architecture tests |
| Gate 3 | ~15 min | Integration tests, security scans, dependency audit |

**AI-specific additions:**
- `pip-audit` / `npm audit` — AI may introduce unvetted packages
- `detect-secrets` baseline — catches secrets missed by pre-commit
- Dependency license check — AI doesn't consider license compatibility

**Strong signals:** CI exists, gates are ordered fast-to-slow, type checking runs before tests.

---

## 8. Sandbox & Permissions

**What to check:**
- Is tool access scoped in `.claude/settings.json` under `permissions.allow`?
- Are writable paths explicitly defined?
- Does CI use `--allowedTools` for non-interactive runs?

**Recommendations:**
- Scope `permissions.allow` to tools the project actually needs
- Use git worktrees for parallel agent tasks (isolation per task)
- In CI: use `--allowedTools` to restrict what the agent can do

**Strong signals:** Permissions are scoped (not blanket allow-all), CI uses tool allowlists.

---

## 9. Secret Scanning

**What to check:**
- Is gitleaks or truffleHog configured?
- Does `.gitignore` exclude `.env`, credential files?
- Is secret scanning in both pre-commit AND CI?

**Recommended setup:**
- Pre-commit: gitleaks (fast, local)
- CI: gitleaks + `detect-secrets` baseline
- `.gitignore`: must include `.env`, `*.pem`, `credentials.json`, `*.key`

**Strong signals:** Secret scanning in pre-commit AND CI, `.gitignore` covers common credential patterns.
