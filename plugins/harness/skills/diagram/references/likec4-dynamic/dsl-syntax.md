# LikeC4 Dynamic View DSL Syntax

## Declaration

```likec4
dynamic view viewName {
  title 'Human-readable title'

  // steps go here ...
}
```

The `title` is optional but strongly recommended — it appears as the diagram heading in all renderings.

Dynamic views live inside the top-level `views { }` block or can be declared at the file root (LikeC4 merges all files). View names must be unique across the entire project.

---

## Messages (Ordered Steps)

Each line inside a `dynamic view` is a numbered step, rendered left-to-right (or top-to-bottom in sequence variant). Steps are executed in declaration order.

### Forward message (call / request)

```likec4
source -> target 'label'
```

- `source` and `target` are element identifiers defined in the `model { }` block.
- `'label'` is optional — describes the interaction (e.g., HTTP verb + path, event name).

### Reverse message (response / callback)

```likec4
target <- source 'label'
```

Use `<-` to show a response flowing back. This is rendered as a return arrow in sequence diagrams.

### Step with body (notes or navigateTo)

```likec4
source -> target 'label' {
  notes 'Single-line markdown note'
}
```

```likec4
source -> target 'label' {
  notes '''
    **Multi-line** markdown note.
    - bullet one
    - bullet two
  '''
}
```

---

## Parallel Blocks

Steps inside `parallel { }` (or the alias `par { }`) execute concurrently. The renderer draws them as a group with a visual bracket.

```likec4
dynamic view fanOut {
  title 'Fan-out to downstream services'

  api -> gateway 'route request'
  parallel {
    gateway -> serviceA 'call A'
    gateway -> serviceB 'call B'
    gateway -> serviceC 'call C'
  }
  gateway -> api 'aggregate responses'
}
```

**Limitations:**
- Parallel blocks cannot be nested inside another `parallel { }` block.
- In the sequence rendering variant, elements inside `parallel` must be leaf elements (no nesting under a parent that is also in the view).

---

## navigateTo — Drill-Down Links

A step can link to another dynamic view, enabling hierarchical exploration. When a user clicks the step in the interactive renderer, they navigate to the target view.

```likec4
dynamic view highlevel {
  title 'High-Level Flow'

  ui -> api 'HTTP request' {
    navigateTo apiInternals
  }
}

dynamic view apiInternals {
  title 'API Internal Steps'

  api -> authMiddleware 'authenticate'
  api -> handler 'dispatch'
  handler -> db 'query'
  db <- handler 'result set'
}
```

`navigateTo` takes a view identifier (not a quoted string). The referenced view must exist in the project.

---

## Sequence Rendering Variant

By default, dynamic views render as a flow diagram with numbered edges. Adding `sequence` inside the view body switches to a classic sequence-diagram (UML-like lifeline) layout:

```likec4
dynamic view loginSequence {
  title 'Login Flow — Sequence Variant'

  // sequence layout is enabled by the 'sequence' keyword
  // (exact keyword may vary by LikeC4 version — check likec4.dev if unavailable)

  browser -> api 'POST /login'
  api -> authService 'validate credentials'
  authService -> api 'token'
  api <- authService 'JWT'
  browser <- api '200 OK + Set-Cookie'
}
```

**Sequence variant constraints:**
- Only leaf elements (elements with no children in the model) can be participants.
- `navigateTo` is still supported in sequence variant steps.
- Parallel blocks render as combined fragments (`par` box) in sequence diagrams.

---

## Complete Syntax Summary

| Construct | Syntax | Notes |
|---|---|---|
| View declaration | `dynamic view id { }` | Must be unique project-wide |
| Title | `title 'string'` | Optional, shown as heading |
| Forward step | `a -> b 'label'` | Label optional |
| Reverse step | `b <- a 'label'` | Reverse arrow / response |
| Step with metadata | `a -> b 'label' { ... }` | Body holds notes or navigateTo |
| Inline note | `notes 'markdown'` | Single quotes, markdown supported |
| Multi-line note | `notes ''' ... '''` | Triple-quote block |
| Parallel block | `parallel { }` or `par { }` | Steps inside run concurrently |
| Drill-down link | `navigateTo viewId` | Inside step body |
| Sequence layout | `sequence` | Inside view body, switches renderer |
