# Test Specifications at Boundaries

Examples for each test layer in a plan's test specs. Read with the Test Specifications section of [SKILL.md](../SKILL.md).

### L3 Core Tests (Property/Invariant)

Describe invariant properties that must hold:
- **Good:** "Splitting a total into N parts preserves the total"
- **Bad:** Code snippet using a specific testing library

### L3 Feature Tests (Behavioral)

Describe behavior at the use case boundary:
- **Good:** "Creating an order returns success with an order ID and correct total"
- **Bad:** `expect(mockRepository.create).toHaveBeenCalledWith(...)`

### L4 HTTP Tests (Contract)

Describe the HTTP contract:
- **Good:** "POST /orders returns 201 with `{ id, total }` on success, 400 with `{ error }` on validation failure"
- **Bad:** Testing internal handler implementation details

See [template.md](template.md) for detailed guidelines.

For detailed L3/L4 testing guidelines including property-based tests and architectural anti-patterns, see [boundary-testing.md](../../tdd/references/boundary-testing.md).
