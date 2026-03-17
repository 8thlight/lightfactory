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

## refactor

| Check | Type | Assertion |
|-------|------|-----------|
| Summary artifact | `file-exists` | `REFACTORING_SUMMARY.md` in project root |
| Initial sections | `section-present` | `^## Baseline`, `^## Steps` present after Prep stage |
| Baseline fields | `string-match` | `## Baseline` section contains `Files in scope:` and `Test result:` |
| Step entries | `string-match` | Each step heading matches `^### Step \d+:` and its block contains `Commit:`, `Test result: PASS`, `Files changed:` |
| Commit format | `string-match` | Every commit message value in Steps matches `- r .+` |
| Final section | `section-present` | `^## Final` present after Summary stage |
| Final fields | `string-match` | `## Final` section contains `Total steps:`, `Files touched:`, `All commits:`, `Final test result: PASS` |
| No test assertion changes | `string-absent` | No test assertion lines changed (diff of test files before/after shows only import/rename updates) |

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

## diagram

| Check | Type | Assertion |
|-------|------|-----------|
| LikeC4 file path | `file-exists` | `docs/architecture/[a-z0-9-]+\.likec4` (for likec4-c4 and likec4-dynamic subtypes) |
| Data-flow file path | `file-exists` | `docs/architecture/data-flow-[a-z0-9-]+\.md` (for data-flow subtype) |
| Dynamic view file path | `file-exists` | `docs/architecture/views/flows/[a-z0-9-]+\.likec4` (for likec4-dynamic subtype) |
| LikeC4 specification block | `string-match` | `specification \{` present in generated `.likec4` file |
| LikeC4 model block | `string-match` | `model \{` present in generated `.likec4` file |
| LikeC4 views block | `string-match` | `views \{` present in generated `.likec4` file |
| LikeC4 block order | `quantitative` | Line position of `specification {` < line position of `model {` < line position of `views {` |
| No duplicate identifiers | `string-absent` | Same identifier token does not appear more than once as a top-level element declaration within a single `.likec4` file |
| DFD Mermaid block | `string-match` | `flowchart` keyword present in data-flow output file |
| DFD classDef present | `string-match` | `classDef` present in data-flow output file (entities, processes, data stores styled) |

---

## Scoring

Each check is binary: pass (1) or fail (0).

| Result | Rule |
|--------|------|
| PASS | All `file-exists`, `section-present`, `string-match` checks pass |
| WARN | Only a `quantitative` check fails (line count out of range) |
| FAIL | Any `file-exists`, `section-present`, or `string-match` check fails |
