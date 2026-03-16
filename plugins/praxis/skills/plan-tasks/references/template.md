# Implementation Plan Template

## Plan File Role

The plan lives in the Claude Code session plan file during planning. It is NOT read by `/implement` during execution — yak contexts are self-contained. The persistent session artifact (combining research, plan, and execution log) is written by `/implement` to `.light/sessions/` at the end of execution.

## Template Structure

```markdown
# {Feature Name} - Implementation Plan

**Date:** YYYY-MM-DD
**Status:** Plan - Ready for Review
**Tracker:** yaks|beads|native
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
- `tests/e2e/{entity}.test.ts` - HTTP contract tests

## Files to Modify

- `src/db/schema/{entity}.ts` - {what changes}
- `src/shell/http/app.ts` - {register new routes}

## Implementation Phases

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
- **RED gate:** Tests fail because implementation does not exist yet
- **GREEN gate:** All tests pass with minimal implementation
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
- **RED gate:** Tests fail because feature implementation does not exist yet
- **GREEN gate:** All integration tests pass
- **Architectural constraints:** Orchestration only — delegates to core logic and repository, no direct database access

---

### Phase 5: HTTP Routes (L4 Boundary)
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
- **Test command:** `{project e2e/HTTP test command}`
- **RED gate:** Tests fail because route handler does not exist yet
- **GREEN gate:** All HTTP contract tests pass
- **Architectural constraints:** Thin adapter — validates input, delegates to feature, maps result to HTTP response

---

### Phase 6: Full Integration
**Goal:** Verify entire feature works end-to-end

**Tasks:**
1. Run full test suite
2. Manual smoke test via API
3. Verify acceptance criteria

**Verification:**
- [ ] All tests pass (full suite)
- [ ] All acceptance criteria met
- [ ] No test skips
- [ ] No console errors

#### Agent Context
- **Test command:** `{full test suite command}`
- **Acceptance gate:** All acceptance criteria from top of plan verified

## Constraints & Considerations

### Architectural
- {Constraint 1}
- {Constraint 2}

### Testing
- Test at architectural boundaries (L3/L4) — see project CLAUDE.md for specific tools and patterns
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
- [ ] Test specs are behavioral descriptions (not tool-specific code)
- [ ] Acceptance criteria are testable
- [ ] Constraints documented
- [ ] Out of scope items noted

## Next Steps

After human review and approval:
1. Run `/implement` to execute — dispatches agents from task graph
2. Each TDD phase: Agent 1 writes failing tests → Agent 2 implements → Agent 3 validates
3. If interrupted, `/implement` picks up where it left off via readiness computation
```

---

## Agent Context Block Reference

Each implementation phase MUST include an `#### Agent Context` subsection. This block is the contract between the plan-tasks (planning) and implement (execution) skills — it provides everything an isolated agent needs to execute one step of a phase.

### Required Fields

| Field | Purpose | Example |
|-------|---------|---------|
| **Files to create** | Exact paths the agent will write | `src/core/discounts/apply.ts` |
| **Files to modify** | Existing files that need changes | `src/shell/http/app.ts` |
| **Test spec** | Behavioral description of what to test | "Discount never exceeds original price" |
| **Test command** | Shell command to run tests | `bun run test` |
| **RED gate** | What failure looks like (confirms test-first) | "Tests fail because module does not exist" |
| **GREEN gate** | What success looks like | "All tests pass with minimal implementation" |
| **Acceptance gate** | For non-TDD phases (schema, integration) | "Migration applies without error" |
| **Architectural constraints** | Boundaries the agent must respect | "Pure functions only, no I/O" |

### Guidelines

- **Test specs are behavioral, not code.** Describe *what* to test (properties, invariants, contracts), not *how* to test it (specific libraries or syntax). The agent will consult the project's CLAUDE.md for testing tools and patterns.
- **File paths must be explicit.** The agent operates in isolation — it cannot discover paths by exploring.
- **Gates must be observable.** "Tests fail" is observable. "Code is clean" is not.
- **Phases without tests** (schema, repository) use an **Acceptance gate** instead of RED/GREEN gates.

---

## Test Specification Guidelines

### L3 Core Tests (Property-Based)

Specify properties to test, not examples:

```
GOOD - behavioral property description:
"Splitting a total into N parts preserves the total — sum of parts equals original"
"Discount percentage applied to any positive price produces a result strictly less than the original"

BAD - hardcoded example:
"split(100, 4) returns [25, 25, 25, 25]"
```

### L3 Feature Tests (Behavioral Assertions)

Specify behavior at the use case boundary:

```
GOOD - behavioral specification:
"Given a valid order with items, creating the order returns success with an order ID and correct total"
"Given an expired discount code, applying it returns an error with reason 'expired'"

BAD - implementation specification:
"mockRepository.create is called with the order data"
```

### L4 HTTP Tests (Contract)

Specify the HTTP contract:

```
GOOD - contract specification:
"POST /orders with valid body returns 201 with { id: string, total: number }"
"POST /orders with missing items returns 400 with { error: string }"

BAD - internal behavior:
"createOrderHandler is called"
```

---

## Phase Boundary Guidelines

Each phase should:

1. **Have a clear goal** - What capability is being added?
2. **Be independently verifiable** - Can you confirm it works?
3. **Be in logical order** - Database → Core → Features → Routes
4. **Be small enough** - Completable in a focused session
5. **Have a self-contained Agent Context** - An isolated agent can execute it without additional context

**Good phase boundaries:**
- Database schema
- Core pure functions
- Repository operations
- Feature use cases
- HTTP routes

**Bad phase boundaries:**
- "Implement everything"
- "Add tests and code"
- Mixing multiple layers in one phase

---

## Quality Standards Checklists

### Completeness
- [ ] All files to create/modify listed with purpose
- [ ] Implementation phases have clear boundaries
- [ ] Each phase has an Agent Context block
- [ ] Test specs are behavioral descriptions at L3/L4 boundaries
- [ ] Acceptance criteria are specific and testable
- [ ] Constraints and considerations documented
- [ ] Out of scope items explicitly noted

### Conciseness
- [ ] Plan is ~200 lines or less
- [ ] Test specs are behavioral descriptions, not full implementations
- [ ] Each phase has clear goal and verification
- [ ] No unnecessary detail

### Actionability
- [ ] Phase order is logical (database → core → features → routes)
- [ ] Each phase can be executed by an isolated agent using its Agent Context block
- [ ] Verification steps are concrete and observable
- [ ] Ready to hand off to `/implement`

### Task Graph Integration
- [ ] Epic/parent task created with feature name
- [ ] Each agent step has its own task with context piped in
- [ ] Task contexts are self-contained (no plan file reference needed)
- [ ] Phase groups named with P{N} prefix for ordering
- [ ] Children named with NN- prefix for sequential execution
- [ ] Agent type specified per step (agent-test/agent-impl/agent-validate/no-test)
- [ ] (yaks) Custom fields set: agent-type
- [ ] (yaks) Epic yak created; phase groups and steps as child yaks

---

## Yak Context Templates

Each yak's context MUST be self-contained — everything an agent needs to execute without reading the plan file. Use these templates when piping context in Step 5.

### Write Tests Yak (agent-test)

```markdown
## Agent Task: Write Tests — {Phase Name} (Phase {N})

**Role:** Write failing tests ONLY. Do NOT write implementation code.

### Agent Context
- **Files to create:** `{test file path(s)}`
- **Test spec:** {Behavioral description — properties, invariants, contracts to test. Be specific.}
- **Test command:** `{shell command to run tests}`
- **RED gate:** Tests fail because `{implementation file}` does not exist yet
- **Architectural constraints:** {L3/L4 boundary, property-based with fast-check, no mocks, etc.}

### Instructions
1. Read the project's CLAUDE.md for testing tools and conventions
2. Read existing test files to match style
3. Write test file(s) at the specified paths
4. Run the test command
5. Verify tests FAIL (RED gate)

### Report
- Test files created: [list paths]
- Test command output: [paste]
- RED gate status: PASS (tests fail as expected) or FAIL
```

### Implement Yak (agent-impl)

```markdown
## Agent Task: Implement — {Phase Name} (Phase {N})

**Role:** Write minimal implementation to pass tests. Do NOT modify test files.

### Agent Context
- **Files to create:** `{implementation file path(s)}`
- **Files to read (tests):** `{test file path(s)}`
- **Test command:** `{shell command to run tests}`
- **GREEN gate:** All tests pass
- **Architectural constraints:** {Pure functions, no side effects, adapter layer, etc.}

### Instructions
1. Read the test files to understand expected behavior
2. Read the project's CLAUDE.md for coding patterns
3. Write minimal implementation to pass all tests
4. Run the test command
5. Verify tests PASS (GREEN gate)

### Report
- Implementation files created/modified: [list paths]
- Test command output: [paste]
- GREEN gate status: PASS or FAIL
```

### Validate Yak (agent-validate)

```markdown
## Agent Task: Validate — {Phase Name} (Phase {N})

**Role:** Run the full test suite and report. Do NOT modify any files.

### Agent Context
- **Full test command:** `{full test suite command}`
- **Phase test files:** `{test file path(s)}`
- **Phase impl files:** `{implementation file path(s)}`

### Instructions
1. Run the full test suite
2. Report results — both new and pre-existing tests

### Report
- Result: ALL PASS or FAILURES FOUND
- Total tests: [count]
- Failures: [count and details]
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

### Instructions
1. Read the project's CLAUDE.md for conventions
2. Execute the tasks listed above
3. Verify the acceptance gate

### Report
- Files created/modified: [list paths]
- Task completed: [brief description]
- Acceptance gate: PASS or FAIL
- Details: [any relevant output or notes]
```

### Remediation Yak (agent-remediate)

Created dynamically by `/implement` when validation fails. Not created during `/plan-tasks`.

```markdown
## Agent Task: Remediate — {Phase Name} (Phase {N}, attempt {M})

**Role:** Fix the implementation to make all tests pass. Do NOT modify test files.

### Agent Context
- **Files to modify (implementation):** `{implementation file path(s)}`
- **Files to read (tests, DO NOT MODIFY):** `{test file path(s)}`
- **Full test command:** `{full test suite command}`
- **Failure output from validation:**
{paste Agent 3's failure output}

### Instructions
1. Read the failing tests to understand expected behavior
2. Read the implementation files to find the issue
3. Fix the implementation — minimal changes only
4. Run the full test suite
5. Verify ALL tests pass

### Report
- Files modified: [list paths]
- What was fixed: [brief description]
- Test command output: [paste]
- Result: ALL PASS or STILL FAILING
```
