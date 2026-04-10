# Structured Output Rubric

Grading rubric for Category A skills. All checks are automatable via filesystem inspection, regex, or YAML parsing.

## Check Types

| Type | Method | Tooling |
|------|--------|---------|
| `file-exists` | Path matches glob pattern | `glob` / `os.path.exists` |
| `section-present` | Regex `^## Section Name` in file | `re.search` |
| `string-match` | Pattern present in file content | `re.search` / `in` |
| `string-absent` | Pattern NOT present in file content | `not in` |
| `quantitative` | Line count, array length, section count | `wc -l` / line counter |

---

## research

| Check | Type | Assertion |
|-------|------|-----------|
| Artifact path | `file-exists` | `.light/\d{4}-\d{2}-\d{2}-[a-z0-9-]+-research.md` |
| Sections | `section-present` | `^## Summary`, `^## Relevant Files`, `^## Existing Patterns`, `^## Web Research`, `^## Open Questions`, `^## Next Steps` |
| Confidence levels | `string-match` | Each web finding line matches `\*\*(High\|Medium\|Low)\*\*` |
| Line count | `quantitative` | `150 <= line_count <= 250` |

## plan-tasks

| Check | Type | Assertion |
|-------|------|-----------|
| Plan path | `file-exists` | `.light/\d{4}-\d{2}-\d{2}-[a-z0-9-]+-plan.md` |
| Sections | `section-present` | `^## Goal`, `^## Acceptance Criteria`, `^## Files to Create`, `^## Files to Modify`, `^## Implementation Phases`, `^## Constraints`, `^## Out of Scope` |
| Agent Context blocks | `string-match` | `^#### Agent Context` present; each block contains `Files to`, `Test spec`, `Test command`, `RED gate`, `GREEN gate`, `Architectural constraints` |
| Tracker fallback | `section-present` | `^## Inline Task Graph` (only when task tracker unavailable) |
| Line count | `quantitative` | `150 <= line_count <= 250` |

## implement

| Check | Type | Assertion |
|-------|------|-----------|
| Execution log | `file-exists` | `implement-execution-log.md` in project root |
| Log entries | `string-match` | `\[DISPATCHED\]`, `\[GATE PASS\]` or `\[GATE FAIL\]`, `\[CLOSED\]` (success), `\[REMEDIATION\]` (remediation path), `\[BLOCKED\]` (after 2 failures) |
| Lint fast path | `string-absent` | `\[REMEDIATION\]` absent when only biome failed |
| Agent types | `string-match` | At least one of: `agent-test`, `agent-impl`, `agent-validate` |

### Session manifest (implement-07, implement-08)

| Check | Type | Assertion |
|-------|------|-----------|
| Manifest path | `file-exists` | `.light/sessions/\d{4}-\d{2}-\d{2}-[a-z0-9-]+\.manifest\.json` |
| Valid JSON | `string-match` | File parses as valid JSON |
| Version field | `string-match` | `"version":\s*1` |
| Files created | `string-match` | `"files_created"` key present with array value |
| Files modified | `string-match` | `"files_modified"` key present with array value |
| Workflow steps | `string-match` | `"workflow_steps"` key present with array containing `"plan"` and `"implement"` |
| Gates object | `string-match` | `"gates"` key present with `red_passed`, `green_passed`, `validate_passed` |
| Test suite result | `string-match` | `"test_suite_passed"` key present with boolean value |
| Phase counts | `string-match` | `"phases_completed"` and `"total_phases"` keys present with number values |
| Timestamp | `string-match` | `"timestamp"` matches ISO-8601 pattern `\d{4}-\d{2}-\d{2}T` |

## scaffold

| Check | Type | Assertion |
|-------|------|-----------|
| Shared kernel | `file-exists` | `src/shared-kernel/event-bus.ts` |
| EventBus interface | `string-match` | `src/shared-kernel/event-bus.ts` contains `EventBus` and `DomainEvent` |
| Domain layers | `file-exists` | `src/<context>/domain/aggregates/`, `src/<context>/domain/repositories/`, `src/<context>/domain/events/`, `src/<context>/domain/value-objects/` |
| Application layer | `file-exists` | `src/<context>/application/` directory exists |
| Infrastructure layer | `file-exists` | `src/<context>/infrastructure/` directory exists |
| Aggregate naming | `string-match` | All files under `src/**/domain/aggregates/` match `*-aggregate.ts` |
| Repository naming | `string-match` | All files under `src/**/domain/repositories/` match `*-repository.ts` |
| Event naming | `string-match` | All files under `src/**/domain/events/` match `*-event.ts` |
| Use case shape | `string-absent` | No `class` keyword in `src/**/application/` files (use cases are functions) |
| Domain purity | `string-absent` | No `/infrastructure/` or `/application/` import paths in `src/**/domain/` files |
| Fitness tests | `file-exists` | `fitness/architecture.test.ts`, `fitness/naming.test.ts`, `fitness/complexity.test.ts`, `fitness/coupling.test.ts` |
| Architecture fitness content | `string-match` | `fitness/architecture.test.ts` contains `infrastructure` and `domain` |


## tdd

| Check | Type | Assertion |
|-------|------|-----------|
| Session log | `file-exists` | `tdd-session-log.md` in project root |
| Phase entries | `string-match` | `\[PLAN\]`, `\[RED-PREDICT\]`, `\[RED-CONFIRM\]`, `\[GREEN\]`, `\[REFACTOR\]` present in session log |
| TEST comments | `string-match` | Lines matching `\[TEST\]` appear in test files |
| ZOMBIES | `string-match` | `<- Z`, `<- O`, `<- M`, `<- B`, `<- I`, `<- E`, `<- S` each present at least once |

## harness

| Check | Type | Assertion |
|-------|------|-----------|
| Report path | `file-exists` | `.light/sessions/\d{4}-\d{2}-\d{2}-[a-z0-9-]*harness-report.md` |
| Audit table | `section-present` | `^## Audit Summary` |
| Nine pillars | `quantitative` | Audit Summary table contains exactly 9 data rows |
| Status values | `string-match` | Each pillar row status matches `Strong\|Partial\|Missing\|N/A` |
| Changes section | `section-present` | `^## Changes Applied` or `^## Deferred Items` |
| Toolchain info | `string-match` | Report contains `Language:` and `Toolchain:` fields |
| Commit format | `string-match` | Commits match `harness: .+ — .+` (when changes are applied) |

## adr

| Check | Type | Assertion |
|-------|------|-----------|
| ADR path | `file-exists` | `docs/decisions/\d{4}-[a-z0-9-]+\.md` |
| Sequential number | `string-match` | Filename number is one greater than the highest existing ADR number |
| Title heading | `section-present` | `^# ADR-\d{4}:` present in file |
| Status field | `string-match` | `\*\*Status:\*\* Proposed` |
| Date field | `string-match` | `\*\*Date:\*\* \d{4}-\d{2}-\d{2}` |
| Sections | `section-present` | `^## Context`, `^## Decision`, `^## Options Considered`, `^## Consequences` |
| Active voice decision | `string-match` | Decision section contains `We will` or `We adopt` |
| At least two options | `quantitative` | `Options Considered` section contains `>= 2` option headings (`^### `) |
| Consequences tradeoffs | `string-match` | `Good:` and `Bad:` both present in `## Consequences` section |
| No trivial ADRs | `string-absent` | File MUST NOT be created when no Harmel-Law decision filter signals are present |

---

## Scoring

Each check is binary: pass (1) or fail (0).

| Result | Rule |
|--------|------|
| PASS | All `file-exists`, `section-present`, `string-match` checks pass |
| WARN | Only a `quantitative` check fails (line count out of range) |
| FAIL | Any `file-exists`, `section-present`, or `string-match` check fails |
