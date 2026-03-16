# Code Templates

## Shared Kernel

`src/shared-kernel/event-bus.ts` must define exactly:

```typescript
export type DomainEvent = {
  type: string;
  payload?: Record<string, unknown>;
  [key: string]: unknown;
};

export interface EventBus {
  publish(event: DomainEvent): Promise<void>;
  getEmittedEvents(): DomainEvent[];
}
```

`InMemoryEventBus` stores every published event in an internal array so tests can assert on emitted events via `getEmittedEvents()`.

## Domain Events

Plain typed objects with a `type` discriminant and optional `payload`. Emit inside use cases via `deps.eventBus.publish(event)`:

```typescript
export type <Context>CreatedEvent = { type: "<Context>Created"; payload: { id: string } };
export type <Context>Event = <Context>CreatedEvent; // union all event types
```

## Zod Input Validation

Install Zod (`bun add zod`). Define a schema for every use case input and call `.parse(rawInput)` at the top of the function. Map `ZodError` to the domain error code `"INVALID_INPUT"`:

```typescript
import { z } from "zod";

const CreateInputSchema = z.object({ name: z.string().min(1) });

export async function create<Context>(rawInput: unknown, deps: { ... }) {
  const input = CreateInputSchema.parse(rawInput);
  // ... use case logic
}
```

Catch `ZodError` and return `{ success: false, error: { code: "INVALID_INPUT" } }`.
