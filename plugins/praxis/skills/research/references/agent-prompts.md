# Agent Prompt Templates

Prompt templates for the two agent types dispatched during research. Use these as the basis for Task tool prompts, filling in the bracketed placeholders.

## Codebase Explorer

**Agent type:** `Explore` (subagent_type)
**Model:** `haiku`

```
Investigate [{investigation_area}] in the codebase for the feature: [{feature_description}].

Your goal is to understand how this area works today and how it relates to the planned feature.

Instructions:
- Examine up to 10 relevant files using Read, Glob, and Grep
- Focus on: file paths, function signatures, data flow, and patterns — not full file contents
- Note any architectural boundaries (core vs features vs shell layers)

Report format:

### {investigation_area}

**Files Examined:**
- `path/to/file.ts` — brief purpose

**Patterns Observed:**
- {pattern name}: {how it works, where it's used}

**Architectural Notes:**
- {layer boundaries, dependency direction, naming conventions}

**Relevance to Feature:**
- {how this area connects to the planned feature}

**Gaps:**
- {anything you expected to find but didn't}
- {areas that need deeper investigation}
```

## Web Researcher

**Agent type:** `general-purpose` (subagent_type)
**Model:** `haiku`

```
Research [{research_topic}] for the feature: [{feature_description}].

Context about the codebase: [{brief_codebase_context — e.g., "TypeScript Node.js app using hexagonal architecture with PostgreSQL"}]

Instructions:
- Use WebSearch to find 2-4 authoritative sources (official docs, well-known blogs, Stack Overflow answers with high votes)
- Use WebFetch to read the most relevant pages
- Focus on patterns and approaches applicable to the codebase context above
- Do NOT recommend tools or libraries without checking if they fit the tech stack

Report format:

### {research_topic}

**Sources Consulted:**
1. {URL} — {what it covered}
2. {URL} — {what it covered}

**Findings:**

#### Finding 1: {name}
**Confidence:** High | Medium | Low
**Summary:** {what the sources say}
**Applicable to this feature:** {yes/no, how it maps to the codebase context}

#### Finding 2: {name}
**Confidence:** High | Medium | Low
**Summary:** {what the sources say}
**Applicable to this feature:** {yes/no, how it maps}

**Contested Points:**
- {any disagreements between sources, or areas where sources conflict}

**Recommended Approach:**
- {based on findings, what approach fits best for this codebase and feature}
```

## Confidence Levels

Use these definitions consistently across all web research findings:

| Level | Definition |
|-------|-----------|
| **High** | Multiple authoritative sources agree. Official documentation supports it. Well-established pattern. |
| **Medium** | One authoritative source or multiple less-authoritative sources agree. Pattern is common but has caveats. |
| **Low** | Single source, opinion-based content, or sources disagree. Pattern may be emerging or context-dependent. |

## Synthesis Notes

When combining codebase and web findings during Step 4 (Synthesize):

- **Align:** Where codebase patterns match web best practices, note the alignment — this increases confidence in the approach
- **Contradict:** Where codebase deviates from web recommendations, surface as a **Contested Finding** in the template — don't assume the web is right
- **Discard:** Web findings that don't apply to the tech stack, architecture, or feature context should be omitted entirely
- **Promote/Demote:** Low-confidence web findings corroborated by codebase evidence become Medium or High. High-confidence web findings contradicted by codebase constraints get flagged as contested.
- **Open Questions:** Low-confidence findings with no codebase corroboration become Open Questions for the user to resolve
