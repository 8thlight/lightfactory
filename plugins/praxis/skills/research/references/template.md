# Research Artifact Template

## Structure

```markdown
# {Feature Name} - Research

**Date:** YYYY-MM-DD
**Status:** Research Complete
**Depth:** Quick | Standard | Deep

## Summary

2-3 sentence overview of what was discovered from both codebase exploration and web research.

## Relevant Files

### Core Layer (Pure Functions)
- `src/core/{module}/{file}.ts` - What it does, how it's relevant

### Features Layer (Use Cases)
- `src/features/{domain}/{file}.ts` - What it does, how it's relevant

### Shell Layer (I/O)
- `src/shell/database/repositories/{file}.ts` - What it does
- `src/shell/http/routes/{file}.ts` - What it does

### Tests
- `tests/unit/core/{module}/{file}.test.ts` - Test patterns to follow
- `tests/integration/features/{file}.test.ts` - Integration patterns

## Existing Patterns

### Pattern 1: {Name}
**Used in:** {files}
**How it works:** {brief description}
**Applicable to new feature:** {yes/no and why}

### Pattern 2: {Name}
...

## Web & Pattern Research

### Finding 1: {Name}
**Sources:** {URLs or library docs consulted}
**Confidence:** High | Medium | Low
**Summary:** {what was learned}
**Implication for this feature:** {how it applies to the codebase and planned work}

### Finding 2: {Name}
**Sources:** {URLs or library docs consulted}
**Confidence:** High | Medium | Low
**Summary:** {what was learned}
**Implication for this feature:** {how it applies}

### Contested Findings

Findings where web sources disagree or where web best practices conflict with codebase patterns:

- **{Topic}:** Source A recommends X, Source B recommends Y. Codebase currently does Z.
  **Recommendation:** {which approach and why, or flag as open question}

## Architectural Boundaries Affected

### L3 Boundaries (Core/Features)
- {Which core functions will be needed}
- {Which feature use cases will change}

### L4 Boundaries (HTTP/External)
- {Which HTTP routes will be added/modified}
- {Which external integrations are involved}

## Database Schema

### Existing Tables
- `{table_name}` - {relevant fields}

### Schema Changes Needed
- {table modifications or new tables}

## Integration Points

### Internal
- {Which features this integrates with}
- {Shared core functions}

### External
- {External API integration points}
- {Other external services}

## Constraints & Considerations

Each constraint should note its source:

- {Technical constraint} *(codebase)*
- {Architectural constraint} *(codebase)*
- {Best practice constraint} *(web research, confidence: High)*
- {Performance consideration} *(web research, confidence: Medium)*
- {Security consideration} *(codebase + web research)*

## Open Questions

- {Question 1 for user clarification}
- {Question 2 for user clarification}
- {Low-confidence web finding needing validation: ...}

## Next Steps

Hand off to `/plan-tasks` with this research artifact.
```

## Example Research Scenario

When user says:
> "I need to add discount codes to order creation"

**Codebase investigation areas:**
1. **Existing discount logic** - Are there discounts already? Where?
2. **Order creation flow** - How are orders created today?
3. **Validation patterns** - How are other codes/slugs validated?
4. **Database schema** - Where would discount codes be stored?

**Web research topics:**
1. **Discount code validation patterns** - Best practices for code format, uniqueness, expiration
2. **Coupon/discount API patterns** - How Stripe, Square, or similar services handle discount codes

Your research artifact should synthesize findings from both sources, noting where codebase patterns align with or deviate from web best practices.

## Quality Standards

### Completeness
- [ ] All relevant files identified and documented
- [ ] Existing patterns analyzed for applicability
- [ ] Architectural boundaries clearly mapped
- [ ] Database schema impact understood
- [ ] Integration points identified
- [ ] Constraints and considerations listed
- [ ] Web research conducted for relevant external patterns
- [ ] All web findings include confidence levels (High/Medium/Low)

### Conciseness
- [ ] Research artifact is ~200 lines or less
- [ ] Only relevant details included
- [ ] No unnecessary code snippets (file paths and brief descriptions only)
- [ ] Clear and scannable structure

### Actionability
- [ ] Findings directly inform planning phase
- [ ] Open questions clearly stated
- [ ] Low-confidence findings flagged for validation
- [ ] Contested findings surfaced with recommendations
- [ ] Next steps clearly defined
