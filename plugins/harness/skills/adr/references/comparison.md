# ADR Format Comparison

Three major ADR formats compared. This skill's template blends MADR's structure with Harmel-Law's advice process.

| Aspect | Nygard Original (2011) | MADR | Harmel-Law |
|---|---|---|---|
| **Sections** | Title, Context, Decision, Status, Consequences | Context, Decision Drivers, Options (with pros/cons), Decision Outcome, Consequences | Context, Decision, Options, Consequences, Advice |
| **Status values** | Proposed, Accepted, Deprecated, Superseded | Proposed, Accepted, Deprecated, Superseded (+ YAML frontmatter) | Draft, Proposed, Accepted, Adopted, Superseded, Expired |
| **Options tracking** | Not included | Central feature with pros/cons per option | Included with consequences per option |
| **Decision authority** | Implicit (team/architect) | Implicit | Explicit: anyone, via advice process |
| **Advice tracking** | Not a concept | "Consulted" and "Informed" in YAML frontmatter | Dedicated section with name/role/date attribution |
| **Immutability** | Immutable once accepted — supersede, never edit | Mutable (allows updates) | Immutable once accepted |
| **Length guidance** | "One or two pages" | Minimal variant ~10 lines, full variant ~40 lines | ~1 page |
| **Directory convention** | `doc/arch/adr-NNN.md` | `docs/decisions/NNNN-*.md` | No specific convention |
| **Primary purpose** | Documentation artifact | Structured decision documentation | Facilitation artifact + learning mechanism |
| **Best for** | Teams wanting minimal overhead | Teams wanting structured options analysis | Teams practicing distributed architecture |

This skill's template uses: MADR's structured options, Harmel-Law's advice section, Nygard's immutability principle, and a simplified 3-value status (Proposed, Accepted, Superseded).
