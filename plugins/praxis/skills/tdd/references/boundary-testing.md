# Boundary Testing at L3/L4 Altitude

Tests must survive refactoring. We test at architectural boundaries (L3/L4), not implementation details (L1/L2).

- **L1/L2 unit tests go extinct** under AI refactoring because they couple to implementation
- **L3/L4 boundary tests survive** because they describe stable contracts and observable behavior
- **Humans own specs, AI owns implementation** - tests are the contract

## Test Altitude by Layer

| Altitude | Layer | What to Test | How |
|----------|-------|-------------|-----|
| **L3** | `core/` public API | Behavioral invariants (properties, not examples) | fast-check |
| **L3** | `features/` public API | Use case outcomes with real database | Testcontainers |
| **L4** | `shell/http/` routes | HTTP contract: status, response shapes, errors | Supertest |
| **L4** | `shell/external/` | Contract with external APIs | mocked HTTP |

**What NOT to test (L1/L2):**
- Private functions or internal helpers
- Repository implementation details
- How data transforms internally
- Internal function call sequences

## Test Writing Order (Per Feature)

When implementing a vertical slice, write tests in this sequence:

1. **Core** - L3 property tests (run unit tests, verify failure)
2. **Features** - L3 behavioral tests (run integration tests, verify failure)
3. **HTTP Routes** - L4 contract tests (run e2e tests, verify failure)

After writing each test, STOP and verify failure before implementing.

## The Five Testing Rules

### 1. Survive Refactoring

Tests MUST survive complete refactoring of internals. If a test breaks when you rename a variable or move a function without changing behavior, the test is at the wrong altitude.

**Good:** `expect(response.status).toBe(201)`
**Bad:** `expect(mockRepository.create).toHaveBeenCalled()`

### 2. Phase Separation

Write a FAILING test first. Do NOT write implementation yet. Never combine red and green.

### 3. Mock Constraint

Only mock at the **system boundary** (external HTTP APIs). Never mock internal modules.

**Allowed:** Mocking external API responses (Square, Stripe, etc.)
**Forbidden:** Mocking internal repositories, core functions, feature use cases, using in-memory DB instead of Testcontainers

### 4. No Tautological Tests

Assert on **observable behavior**, not implementation calls.

**Good:** `expect(order.total).toBe(150)`
**Bad:** `expect(mockPricing.calculate).toHaveBeenCalledWith(cart)`

### 5. Property-Based for core/

Pure functions should have property-based tests. Test invariants, not examples.

**Properties:** round-trip, idempotency, boundary preservation, commutativity, associativity

## Property-Based Testing with fast-check

For `core/` pure functions, use fast-check to test invariants:

```typescript
import fc from 'fast-check';

describe('splitAmount', () => {
  it('should preserve total when splitting across parts', () => {
    fc.assert(
      fc.property(
        fc.integer({ min: 0, max: 1000000 }),
        fc.integer({ min: 1, max: 10 }),
        (total, parts) => {
          const split = splitAmount(total, parts);
          return split.reduce((sum, n) => sum + n, 0) === total;
        }
      )
    );
  });

  it('should create exact number of parts requested', () => {
    fc.assert(
      fc.property(
        fc.integer({ min: 0, max: 1000000 }),
        fc.integer({ min: 1, max: 10 }),
        (total, parts) => splitAmount(total, parts).length === parts
      )
    );
  });

  it('should produce non-negative values', () => {
    fc.assert(
      fc.property(
        fc.integer({ min: 0, max: 1000000 }),
        fc.integer({ min: 1, max: 10 }),
        (total, parts) => splitAmount(total, parts).every(n => n >= 0)
      )
    );
  });
});
```

### Common Property Patterns

**Round-trip:**
```typescript
fc.property(fc.anything(), (value) => decode(encode(value)) === value)
```

**Idempotency:**
```typescript
fc.property(fc.string(), (input) => normalize(normalize(input)) === normalize(input))
```

**Boundary preservation:**
```typescript
fc.property(validInputArbitrary, (input) => isValid(transform(input)))
```

## Behavioral Assertion Tests (Features)

Test use case outcomes with real database. Assert behavior at L3 boundary:

```typescript
describe('createOrder', () => {
  // Uses Testcontainers for real database

  it('creates order with correct total from multiple tickets', async () => {
    await seedTickets([
      { id: 't1', price: 50, available: true },
      { id: 't2', price: 30, available: true }
    ]);

    const result = await createOrder({ ticketIds: ['t1', 't2'], customerId: 'c1' });

    // Assert BEHAVIOR at L3 boundary
    expect(result.success).toBe(true);
    expect(result.data.total).toBe(80);
    expect(result.data.tickets).toHaveLength(2);
  });

  it('returns error when ticket not found', async () => {
    const result = await createOrder({ ticketIds: ['nonexistent'], customerId: 'c1' });

    expect(result.success).toBe(false);
    expect(result.error).toContain('Ticket not found');
  });
});
```

## HTTP Contract Tests (Routes)

Test the HTTP contract at L4 boundary: status codes, response shapes, error formats:

```typescript
describe('POST /orders', () => {
  it('returns 201 with order data on valid request', async () => {
    const response = await request(app)
      .post('/orders')
      .send({ ticketIds: ['t1'], customerId: 'c1' });

    expect(response.status).toBe(201);
    expect(response.body).toMatchObject({
      id: expect.any(String),
      total: 50,
      status: 'pending'
    });
  });

  it('returns 400 with error on invalid request', async () => {
    const response = await request(app)
      .post('/orders')
      .send({ ticketIds: 'not-an-array' });

    expect(response.status).toBe(400);
    expect(response.body.error).toBeDefined();
  });
});
```

## Anti-Patterns (FORBIDDEN)

### Never Assert Mock Calls for Internal Functions
```typescript
// FORBIDDEN
expect(mockRepository.create).toHaveBeenCalledWith({ ... });

// CORRECT
expect(order.total).toBe(expectedTotal);
```

### Never Delete Failing Tests
If a test fails: fix implementation (if test correct), fix test (if wrong altitude), or discuss with human (if requirement changed).

### Never Combine Red and Green
Write test, run test (MUST fail), STOP, write implementation, run test (pass).

### Never Mock Internal Modules
```typescript
// FORBIDDEN
vi.mock('@/shell/database/repositories/order-repository');
vi.mock('@/core/pricing/calculate-discount');

// CORRECT - only mock external systems
vi.mock('@/shell/external/square-client');
```

### Never Snapshot Test (Except Small Data)
Snapshot tests forbidden except for small serialized data structures (< 20 lines).
