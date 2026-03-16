---
name: scaffold
description: Scaffold an agentic engineering harness for a project. Supports TypeScript via subtype dispatch (extensible to other languages). Use when scaffolding projects, creating hexagonal architecture, domain-driven design structures, or generating project boilerplate from acceptance tests.
triggers:
  - "scaffold harness"
  - "create harness"
  - "DDD harness"
  - "scaffold project"
  - "scaffold architecture"
  - "domain-driven design harness"
allowed-tools: Read Glob Write Bash
---

# Scaffold Harness

TODO: This needs refactoring...

Read the Gherkin feature files to understand the domain requirements before creating any files. The feature files define the acceptance tests — every file you scaffold must serve those tests.

## Language Selection

Identify the target language from the user's request, then load the matching reference files.

| User Intent | Language | Load |
|---|---|---|
| TypeScript, TS, Bun, DDD typescript | `typescript` | `references/typescript/` |

**REQUIRED:** After selecting the language from the table above, use the Read tool to load ALL markdown files from `references/{language}/`. These files provide language-specific code templates, tooling choices, and fitness test patterns. Do not proceed without reading them.

## Derivation Workflow

### Step 1 — Read feature files

Read every Gherkin feature file in the project. These are the acceptance tests. Every module you create must exist to satisfy a scenario; do not create modules that no scenario references.

### Step 2 — Select language subtype

Apply the dispatch table above to determine which language directory to load.

### Step 3 — Load reference files

Use the Read tool to load all markdown files from `references/{language}/`. The code-templates file provides module scaffolds and naming patterns. The fitness-tests file provides the structural test templates to generate.

### Step 4 — Identify bounded contexts

Group scenarios by aggregate root. Each aggregate root becomes a top-level context directory: `src/<context>/`. Name contexts after the domain concept they encapsulate, not after technical roles.

### Step 5 — Extract domain entities

Given/When steps reveal aggregate and value-object types. Create those types in `<context>/domain/`. Read every import statement in the acceptance tests — create modules at exactly those paths and no others.

### Step 6 — Identify use cases and ports

When verb phrases map to use-case functions in `<context>/application/`. Read test imports to determine which repository methods are called; the infrastructure adapter implements exactly those methods and no others. Then steps that assert on emitted events reveal domain event types in `<context>/domain/events/`.

### Step 7 — Scaffold project structure

Create the directory tree following DDD hexagonal conventions from the language reference:

```
src/
├── shared-kernel/
└── <context>/
    ├── domain/
    │   ├── aggregates/
    │   ├── value-objects/
    │   ├── repositories/
    │   └── events/
    ├── application/
    └── infrastructure/
```

Repeat the `<context>/` subtree for each bounded context. If acceptance tests import from a conventional path that does not match the DDD layout, create proxy shim modules at those paths that re-export from the DDD structure.

### Step 8 — Wire dependencies and generate fitness tests

Create entry points and dependency wiring. Generate fitness test files as described in the language reference's fitness-tests file.

### Step 9 — Verify

Run the verification commands from the language reference in order. All must pass before the scaffold is considered complete.

## Architectural Rules

**Domain layer purity** — `domain/` must not import from `infrastructure/` or `application/`. Dependencies flow inward only.

**Bounded context isolation** — No cross-context imports. Contexts communicate exclusively through domain events dispatched via the shared-kernel event bus.

**Aggregates are the consistency boundary** — State changes happen only through aggregate methods. Value objects are immutable: use readonly fields, factory methods, and no setters.

**Application services are functions, not classes** — Each use case is a named async function. Return a discriminated union:
- Success: `{ success: true, ...fields }`
- Failure: `{ success: false, error: { code: string } }`

Error codes use SCREAMING_SNAKE_CASE.

**Ports are interfaces** — Every repository port is an interface in the domain layer. One aggregate, one use case, and one repository interface per file.

## TDD Discipline

1. Read all acceptance tests before writing any source code.
2. Implement one test file at a time; do not scaffold ahead.
3. Follow Red → Green → Refactor for each test.
4. Run fitness tests after completing each file.
5. Run the full suite after completing each use case.

## Anti-Patterns

**Do not invent paths.** Only create modules at paths that acceptance tests actually import.

**Do not mix layers.** Infrastructure adapters must not contain business logic. Application services must not import infrastructure directly — depend on the repository port interface.

**Do not create god aggregates.** If a single aggregate handles every scenario, you have missed a bounded context boundary.

**Do not skip fitness tests.** Generate all four fitness test files (architecture, naming, complexity, coupling) at the start of scaffolding so structural violations are caught continuously.

**Do not use mocks for domain logic.** Fitness tests assert structural properties of real source files, not mocked behaviour.

## References

- [TypeScript reference files](references/typescript/) — code-templates.md, fitness-tests.md
