# Implementation Plan Template

## Plan File Role

The plan lives in the Claude Code session plan file during planning. It is NOT read by `/implement` during execution — yak contexts are self-contained. The persistent session artifact (combining research, plan, and execution log) is written by `/implement` to `.light/sessions/` at the end of execution.

## Template Structure

```markdown
# {Feature Name} - Implementation Plan

**Date:** YYYY-MM-DD
**Status:** Plan - Ready for Review
**Tracker:** yaks|beads|native
**Commit:** per-task|per-group|none  (orchestrator commits; agents never do)
**Yaks Epic:** {epic name}

## Goal

1-2 sentence description of what we're building and why.

## Acceptance Criteria

- [ ] Criterion 1 (testable outcome)
- [ ] Criterion 2 (testable outcome)
- [ ] Criterion 3 (testable outcome)

## Files to Create

### Core Layer
- `src/core/{module}/{function-name}.ts` - {purpose}

### Features Layer
- `src/features/{domain}/{use-case}.ts` - {purpose}

### Shell Layer
- `src/shell/database/repositories/{entity}-repository.ts` - {purpose}
- `src/shell/http/routes/{entity}.ts` - {purpose}
- `src/shell/http/schemas/{entity}.ts` - {purpose}

### Tests
- `tests/unit/core/{module}/{function}.test.ts` - core boundary tests
- `tests/integration/features/{feature}.test.ts` - feature boundary tests
- `tests/e2e/{entity}.test.ts` - HTTP contract tests (tier `http-contract`; the directory name is the project's, not a browser journey)
- `{journey spec path}` - browser journey stages (tier `e2e-journey`; only when a phase needs the browser)

## Files to Modify

- `src/db/schema/{entity}.ts` - {what changes}
- `src/shell/http/app.ts` - {register new routes}

## RED Gate Profiles

Per test phase, the repo rule file(s) whose `RED gate` section was copied into the test
task's Agent Context (see plan-tasks "RED gate profile lookup"), or "none — generic".

| Phase | Profile source |
|-------|----------------|
| P2 | `.claude/rules/{file}.md` |

## Implementation Phases

### Phase 0: Journey Fragment RED (E2E-Journey, optional)
**Tier:** e2e-journey — only for behavior that needs the browser; assert everything else at a lower tier.
**Goal:** Add stage {K} of the {journey} spec: {user-visible step}

**Placement:** before the phases that turn it green (here Phases 1-5, plus a UI phase that
renders the contract testids, not shown), so its leaf gets a lower `P{N}` than theirs; the
last of those phases' validate carries the **Journey spec command**. Rules: plan-tasks
SKILL.md, "Phase tiers".

**Test Spec (Journey):** Extend the existing spec by one stage. Earlier stages keep passing; the new step is the only new assertion group.

**Tasks:**
1. Extend the spec (RED) — leaf `agent-test` task; the lower-tier phases that follow turn it green
2. Preflight, run, verify failure matches the prediction

**Verification:**
- [ ] Spec stages 1..K pass at the fragment's last validate; the rest of the suite stays green

#### Agent Context
- **Files to create/modify:** `{spec path}`, `{page object / fixtures path}`
- **Tier:** e2e-journey
- **Runner:** `{browser/e2e runner}` — **Build target:** `{e.g. production build of the app under test}`
- **Preflight:** {externally managed services and ports that must be up, with a check for each; "none" when the runner starts everything itself (e.g. Playwright `webServer`)}
- **Test spec:** {user-visible journey step, using the agreed contract testids}
- **Test command:** `{runner command for this spec — prefixed with the build command when the runner does not build the app itself; a runner-started server is never reused and retries are off (see SKILL.md, Phase tiers)}`
- **RED gate:** {Stages 1..K-1 pass; step K times out waiting for `{contract testid}` — the element the task has not built. Connection refused, login/page-load timeout, or a missing build is a wrong-reason RED.}
- **GREEN gate:** checked by the fragment's last validate (its Journey spec command)
- **Architectural constraints:** user-visible behavior and contract testids only, never internals

---

### Phase 1: Database Schema
**Goal:** Add database support for {entity}

**Tasks:**
1. Add {table} to schema
2. Generate migration
3. Apply migration

**Verification:**
- [ ] Migration applied successfully
- [ ] Database tool shows new table

#### Agent Context
- **Files to create/modify:** `src/db/schema/{entity}.ts`, `migrations/NNNN_{name}.sql`
- **Test command:** `{project test command — check project CLAUDE.md}`
- **Acceptance gate:** Migration applies without error; table visible in database

---

### Phase 2: Core Logic (L3 Boundary)
**Tier:** unit
**Goal:** Implement pure business logic for {capability}

**Test Spec (Behavioral):**
- Test invariant properties of the pure function (e.g., "splitting preserves total", "discount never exceeds price")
- Test edge cases: zero input, boundary values, invalid input
- Use the project's preferred property-based testing approach (see project CLAUDE.md for tools)

**Tasks:**
1. Write tests according to spec (RED)
2. Run tests, verify failure
3. Implement pure function (GREEN)
4. Refactor if needed

**Verification:**
- [ ] Tests pass
- [ ] Tests validate invariant properties, not example values

#### Agent Context
- **Files to create:** `{test file path}`, `{implementation file path}`
- **Test spec:** {Behavioral description of what to test — properties, invariants, edge cases. Reference project CLAUDE.md for testing tools and patterns.}
- **Test command:** `{project test command}`
- **RED gate:** {Expected initial failure for this phase, in the framework's terms — consult the project/user testing skill if one exists. E.g. "assertion fails: split total != original total" — not just "tests fail". A compile/import/setup error or a passing test is a wrong-reason RED.}
- **GREEN gate:** All tests pass with minimal implementation
- **Acceptance criterion:** {the criterion this phase serves}
- **Architectural constraints:** Pure functions only, no I/O, no side effects

---

### Phase 3: Repository Layer
**Goal:** Add database operations for {entity}

**Tasks:**
1. Create repository with CRUD operations
2. Integration tested via feature layer (next phase)

**Verification:**
- [ ] Repository created
- [ ] Ready for feature layer

#### Agent Context
- **Files to create:** `{repository file path}`
- **Files to modify:** `{any DI/registry files}`
- **Test command:** `{project test command}`
- **Acceptance gate:** Repository compiles, types check
- **Architectural constraints:** Adapter layer — depends on domain types, implements port interface

---

### Phase 4: Feature Use Case (L3 Boundary)
**Tier:** integration
**Goal:** Orchestrate {use case} with real database

**Test Spec (Behavioral):**
- Test the use case boundary: given valid input, expect successful result with correct data
- Test error paths: given invalid input, expect structured error
- Use real infrastructure (database, etc.) per project CLAUDE.md testing patterns — no internal mocks

**Tasks:**
1. Write behavioral tests (RED)
2. Run tests, verify failure
3. Implement feature orchestration (GREEN)
4. Refactor if needed

**Verification:**
- [ ] Integration tests pass
- [ ] Tests verify behavior, not implementation calls

#### Agent Context
- **Files to create:** `{test file path}`, `{feature file path}`
- **Test spec:** {Behavioral description — what the use case should do on success, what it should return on each error case. Reference project CLAUDE.md for integration test patterns.}
- **Test command:** `{project integration test command}`
- **RED gate:** {Expected initial failure for this phase, in the framework's terms — consult the project/user testing skill if one exists. E.g. "use case returns null / 404 instead of the created entity" — not just "tests fail". A compile/import/setup error or a passing test is a wrong-reason RED.}
- **GREEN gate:** All integration tests pass
- **Acceptance criterion:** {the criterion this phase serves}
- **Architectural constraints:** Orchestration only — delegates to core logic and repository, no direct database access

---

### Phase 5: HTTP Routes (L4 Boundary)
**Tier:** http-contract
**Goal:** Expose {use case} via HTTP API

**Test Spec (Contract):**
- Test HTTP contract: correct status codes (201, 400, 404, etc.)
- Test response shapes: required fields present with correct types
- Test error responses: structured error format
- Use the project's HTTP testing approach (see project CLAUDE.md)

**Tasks:**
1. Create validation schema
2. Write HTTP contract tests (RED)
3. Run tests, verify failure
4. Implement route handler (GREEN)
5. Register route in app
6. Refactor if needed

**Verification:**
- [ ] HTTP tests pass
- [ ] Tests verify HTTP contract (status, shape, errors)

#### Agent Context
- **Files to create:** `{test file path}`, `{route file path}`, `{schema file path}`
- **Files to modify:** `{app registration file}`
- **Test spec:** {HTTP contract description — method, path, request body shape, success response shape and status, each error response shape and status. Reference project CLAUDE.md for HTTP test patterns.}
- **Test command:** `{project HTTP contract test command}`
- **RED gate:** {Expected initial failure for this phase, in the framework's terms — consult the project/user testing skill if one exists. E.g. "request returns 404, expected 201 with body {id}" — not just "tests fail". A compile/import/setup error or a passing test is a wrong-reason RED.}
- **GREEN gate:** All HTTP contract tests pass
- **Acceptance criterion:** {the criterion this phase serves}
- **Interface contract:** {method, path, response shapes this phase must expose}
- **Architectural constraints:** Thin adapter — validates input, delegates to feature, maps result to HTTP response

---

### Phase 6: Full Integration
**Goal:** Verify entire feature works end-to-end

**Tasks:**
1. Run full test suite, and each journey through its spec command
2. Manual smoke test via API
3. Verify acceptance criteria

**Verification:**
- [ ] All tests pass (full suite)
- [ ] All acceptance criteria met
- [ ] No test skips
- [ ] No console errors

#### Agent Context
- **Full test command:** `{full test suite command}`
- **Journey spec command:** `{each journey's spec command — they build first when needed}`
- **Acceptance gate:** All acceptance criteria from top of plan verified

## Constraints & Considerations

### Architectural
- {Constraint 1}
- {Constraint 2}

### Testing
- Test at architectural boundaries (L3/L4; browser journeys at the e2e-journey tier) — see project CLAUDE.md for specific tools and patterns
- No internal mocks — test behavior at boundaries with real infrastructure where possible
- Test HTTP contracts for route layers (status codes, response shapes)

### Performance
- {Consideration if applicable}

### Security
- {Consideration if applicable}

## Out of Scope

- {Feature explicitly not included}
- {Enhancement deferred to later}

## Approval Checklist

Before implementing, verify:
- [ ] All files to create/modify listed
- [ ] Implementation phases have clear boundaries
- [ ] Each phase has an Agent Context block with file paths, test spec, test command, and gates
- [ ] Every test phase has a tier; each journey fragment's RED leaf precedes its phases, and its last validate carries the Journey spec command
- [ ] Commit policy chosen
- [ ] RED Gate Profiles recorded per test phase
- [ ] Test specs are behavioral descriptions (not tool-specific code)
- [ ] Acceptance criteria are testable
- [ ] Constraints documented
- [ ] Out of scope items noted

## Next Steps

After human review and approval:
1. Run `/implement` to execute — dispatches agents from task graph
2. Each TDD phase: Agent 1 writes failing tests → Agent 2 implements → Agent 3 validates; a journey fragment starts with its RED leaf
3. If interrupted, `/implement` picks up where it left off via readiness computation
```

## Yak Context Templates

Each yak's context MUST be self-contained — everything an agent needs to execute without reading the plan file. Use these templates when piping context in Step 5.

The RED gate signature appears **only** in Write Tests contexts; the RED gate profile in Write Tests and Validate contexts. Neither appears in Implement or Remediate.

### Write Tests Yak (agent-test)

```markdown
## Agent Task: Write Tests — {Phase Name} (Phase {N})

**Role:** Write failing tests ONLY. Do NOT write implementation code.

### Agent Context
- **Files to create/modify:** `{test file path(s)}`
- **Test spec:** {Behavioral description — properties, invariants, contracts to test. Be specific.}
- **Test command:** `{shell command to run tests — for e2e-journey, prefixed with the build command when the runner does not build the app}`
- **RED gate:** {Expected initial failure for this phase, in the framework's terms — what assertion fails and why. Consult the project/user testing skill if one exists. A compile/import/setup error or a passing test is a wrong-reason RED.}
- **Tier:** {unit|integration|http-contract|e2e-journey}
- **Runner / build target / preflight:** {e2e-journey only — see plan-tasks SKILL.md "Phase tiers"}
- **Architectural constraints:** {L3/L4 boundary or e2e-journey tier, property-based with fast-check, no mocks, etc.}

#### RED gate profile
{Omit when no rule file matched. Otherwise the `RED gate` section(s) copied verbatim from the matching repo rule file(s), each preceded by `Source: {rule file path}`.}

Follow your `praxis:agent-test` definition for the procedure (output capture to a log file, judging the failure against the RED gate above) and report format. The Agent Context above is your task input.
```

### Implement Yak (agent-impl)

```markdown
## Agent Task: Implement — {Phase Name} (Phase {N})

**Role:** Write minimal implementation to pass tests. Do NOT modify test files.

### Agent Context
- **Files to create:** `{implementation file path(s)}`
- **Files to read (tests):** `{test file path(s)}`
- **Acceptance criterion:** {the criterion this phase serves}
- **Interface contract:** {testids or shapes this phase must expose — omit when none}
- **Test command:** `{shell command to run tests}`
- **GREEN gate:** All tests pass
- **Architectural constraints:** {Pure functions, no side effects, adapter layer, etc.}

Follow your `praxis:agent-impl` definition for the procedure and report format. The Agent Context above is your task input.
```

### Validate Yak (agent-validate)

```markdown
## Agent Task: Validate — {Phase Name} (Phase {N})

**Role:** Run the validate commands and report. Do NOT modify any files.

### Agent Context
- **Full test command:** `{full test suite command — inside an open e2e-journey fragment, the suite minus the journey spec}`
- **Journey spec command:** `{the journey RED task's test command}` — only on a fragment's last validate (stages 1..K must pass); omit elsewhere
- **Preflight:** {the journey RED task's preflight — only with a Journey spec command}
- **Phase test files:** `{test file path(s)}`
- **Phase impl files:** `{implementation file path(s) — on a fragment's last validate, every implementation file in the fragment}`

#### RED gate profile
{Same verbatim section(s) as the Write Tests yak, with `Source:` lines (on a fragment's last validate, also the journey RED task's); omit when none matched.}

Follow your `praxis:agent-validate` definition for the procedure and report format. The Agent Context above is your task input.
```

### No-Test Yak (no-test)

```markdown
## Agent Task: {Task Name} (Phase {N})

**Role:** Execute non-TDD phase task.

### Agent Context
- **Files to create/modify:** `{file path(s)}`
- **Commands to run:** `{migration commands, etc.}`
- **Acceptance gate:** {Observable success criterion — e.g., "Migration applies without error"}
- **Architectural constraints:** {Any relevant constraints}

Follow your `praxis:agent-no-test` definition for the procedure and report format. The Agent Context above is your task input.
```

### Remediation Yak (agent-remediate)

Created dynamically by `/implement` when validation fails; not created during `/plan-tasks`. Its context template is in the implement skill's `references/workflow-detail.md` ("Remediation Task Context Template").
