---
name: diagram
description: Creates architecture diagrams using LikeC4 (structural C4, dynamic flows) or Mermaid (data flow diagrams). Use when creating C4 diagrams, architecture diagrams, sequence diagrams, data flow diagrams, or any system visualization.
triggers:
  - "C4 diagram"
  - "architecture diagram"
  - "LikeC4 diagram"
  - "system diagram"
  - "container diagram"
  - "component diagram"
  - "deployment diagram"
  - "architecture as code"
  - "dynamic view"
  - "sequence diagram"
  - "workload flow"
  - "request flow"
  - "service interaction"
  - "temporal flow"
  - "dynamic diagram"
  - "data flow diagram"
  - "DFD diagram"
  - "data flow visualization"
  - "data movement"
  - "data transformation"
allowed-tools: Read Glob Write
---

# Diagram Skill

## Diagram Type Selection

Determine the subtype before writing any DSL or Mermaid. Match the user's intent to the table below, then load the corresponding reference files.

| User Intent | Subtype | Load |
|---|---|---|
| C4, architecture, system/container/component/deployment diagram | `likec4-c4` | `references/likec4-c4/` |
| Sequence, flow, temporal, dynamic view, service interaction | `likec4-dynamic` | `references/likec4-dynamic/` |
| Data flow, DFD, data movement/transformation | `data-flow` | `references/data-flow/` |

**REQUIRED:** After selecting the subtype from the table above, use the Read tool to load ALL markdown files from `references/{subtype}/`. These files are your complete reference for generating the artifact. Do not proceed without reading them.

---

## View Type Decision Tree

```
What question is the user asking?
│
├── "What systems interact with X and who uses it?"
│   └── likec4-c4 — Context view
│
├── "What's inside system X?" / "What containers does it have?"
│   └── likec4-c4 — Container view
│
├── "What's inside container X?" / "What components does it have?"
│   └── likec4-c4 — Component view
│
├── "How is this deployed on infrastructure?"
│   └── likec4-c4 — Deployment view
│
├── "How does a request flow through the system?" / "Show the sequence"
│   └── likec4-dynamic — Dynamic view
│   └── (if no model exists yet, run likec4-c4 first)
│
└── "Where does data move and transform?" / "Show me the DFD"
    └── data-flow — Mermaid flowchart DFD
```

---

## Shared Workflow

### Step 1 — Gather Context

Ask (or infer from context) before writing any code:

1. What is the system being modeled? (name, brief purpose)
2. What is the scope? (use the decision tree above)
3. Who are the actors? (human users, external systems)
4. Are there key containers, components, or data stores to include?

### Step 2 — Check for Existing Model Files

```
Glob **/*.likec4
Glob **/*.c4
```

If existing files are found, read them before writing. LikeC4 merges all `.likec4` files in a project — do not duplicate element definitions. For data-flow diagrams, check `docs/architecture/` for existing Mermaid files.

### Step 3 — Select Subtype from Dispatch Table

Apply the dispatch table and decision tree above. Confirm the subtype before loading references.

**LikeC4 Model Dependency:** If the user wants a `likec4-dynamic` view but no `.likec4` model exists yet, route to the `likec4-c4` subtype first. Dynamic views reference elements defined in the model — they cannot invent new elements. Build `specification { }` and `model { }` blocks first, then return to create the dynamic view.

### Step 4 — Load ALL Reference Files

Using the Read tool, load ALL markdown files from the selected subtype's `references/` directory. Use Glob to enumerate the files if needed:

```
Glob references/{subtype}/*.md
```

These files are your complete syntax and convention reference. Do not generate the diagram without reading them.

### Step 5 — Generate the Diagram

Follow the subtype-specific syntax, conventions, and file placement from the loaded references:

- **likec4-c4**: Write `.likec4` files under `docs/architecture/`. Use `specification { }`, `model { }`, `views { }` blocks in that order. Follow naming conventions: `camelCase` identifiers, `'Title Case'` display names, `kebab-case.likec4` filenames.
- **likec4-dynamic**: Write to `docs/architecture/views/flows/{scenario-name}.likec4`. Reference existing model element identifiers only — do not re-declare `specification` or `model`.
- **data-flow**: Write a Mermaid `flowchart` block in a markdown file at `docs/architecture/data-flow-{level}.md`. Apply `classDef` to distinguish entities, processes, and data stores.

### Step 6 — Review and Refine

After writing, present a summary:

- Diagram type and scope
- Elements included (count and kinds)
- Key relationships or flows modeled
- Which file was written

Ask whether the user wants to adjust scope, add styling, drill into a sub-system, or create a variant.

---

## Anti-Patterns

**Duplicating element definitions across files** — Each LikeC4 identifier must be declared once. All `.likec4` files in a directory are merged; duplicate definitions cause errors.

**Overloading one dynamic view** — Combining happy path, error path, and edge cases in a single `dynamic view` produces an unreadable tangle. Create one view per scenario variant.

**Including too many elements in one C4 view** — A context view with 30 systems is unreadable. Use `exclude` predicates or scope with `view of X`.

**Connecting external entities directly to data stores in a DFD** — External entities must always interact through a process. A direct entity-to-store connection means a process is missing.

**Mixing temporal with topological concerns** — DFDs show topology, not sequence. Do not add step numbers or attempt ordering. Use `likec4-dynamic` for temporal flows.

**Skipping the specification block** — Element kinds without a `specification` entry default to generic rectangles. Define kinds explicitly so diagrams share consistent vocabulary and styling.

**Using vague DFD flow labels** — `sends data`, `calls service` are not data names. Label flows with the data itself: `order request`, `payment result`, `session token`.

---

## References

- `references/likec4-c4/` — DSL syntax, view examples (context/container/component/deployment), style guide
- `references/likec4-dynamic/` — Dynamic view DSL syntax, flow examples (request/response, fan-out, saga, error paths)
- `references/data-flow/` — DFD notation mapped to Mermaid, DFD examples (context, Level 1, multi-boundary)
