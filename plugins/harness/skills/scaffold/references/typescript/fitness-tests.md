# Fitness Test Templates

Generate four fitness test files in `fitness/` using the `archunit` npm package (ArchUnitTS). All fitness tests use `allowEmptyTests: true` so they pass against an empty scaffold.

## `fitness/architecture.test.ts`

Dependency direction and bounded context isolation:
- Domain must not depend on infrastructure
- Domain must not depend on application
- Each context must not import from any other context

## `fitness/naming.test.ts`

File naming conventions:
- `src/**/domain/aggregates/**` files end with `-aggregate.ts`
- `src/**/domain/repositories/**` files end with `-repository.ts`
- `src/**/infrastructure/**` files start with `in-memory-` or end with `-adapter.ts`
- `src/**/domain/events/**` files end with `-event.ts`
- `src/**/domain/value-objects/**` files are in `value-objects/` directories

## `fitness/complexity.test.ts`

Size and cohesion:
- All source files: ≤ 300 LOC
- Domain and infrastructure files: ≤ 200 LOC
- Application services: LCOM96b < 0.5
- Domain aggregates: LCOM96b < 0.5

## `fitness/coupling.test.ts`

Structural coupling:
- Overall, application-layer, and infrastructure-layer coupling factor < 0.3
- Application, domain, and all modules: distance from main sequence < 0.5
