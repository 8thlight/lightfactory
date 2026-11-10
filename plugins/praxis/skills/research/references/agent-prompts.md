# Agent Prompt Templates

Prompt templates for the three agent types dispatched during research (the Accessibility Researcher only for UI work). Use these as the basis for Task tool prompts, filling in the bracketed placeholders.

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
- **Reuse candidates:** search for code that already computes what the feature needs, including read-only previews, monitors or dry-runs of a job, planners, and the job itself. Report each with its entry point and callers, and say whether the feature can call it directly. If the feature would have to mirror a rule that lives elsewhere, say where that rule lives.

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

**Reuse Candidates:**
- `{entry point}` — already computes: {what}; callers: {who}; call it directly: {yes / no — why}
- {or "none found"}

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

## Accessibility Researcher

UI work only. Fill `{a11y_refs_dir}` with the absolute path of `references/accessibility/` under the research skill's base directory.

**Agent type:** `Explore` (subagent_type)
**Model:** `haiku`

```
Research accessibility for the feature: [{feature_description}].

Context about the codebase: [{brief_codebase_context}]

Reference folder: [{a11y_refs_dir}]

Instructions:
- Identify the interaction patterns in scope from the feature and the UI files it touches
- Read [{a11y_refs_dir}]/INDEX.md first. Then read every file whose row matches a pattern in scope, not only the closest one, plus criteria-template.md and citing-wcag.md. Open wcag-criteria-list.md only to check an SC number
- If the folder is missing or no row matches a pattern, use your own knowledge, cite W3C APG or WCAG, and say in the report that no reference file existed
- For a native or cross-platform mobile app, mobile.md holds only platform-neutral principles. Read that platform's accessibility documentation for property and role names, and say so in the report
- Check existing UI code for current accessibility patterns (semantic elements, roles, names, focus handling) and for UI test tooling and the tier it runs in
- Target: use the WCAG version and level the project states (CLAUDE.md, linked docs, the ticket), and say where it came from. If none is stated, the target is WCAG 2.2 AA, marked as the default
- Cite the file and the requirement behind each finding. Follow citing-wcag.md: no source, no claim, and cite the WCAG version the project is held to
- Run no audits or scanners. Nothing is built at research time
- Read each reference file on its own with Read, not several in one command
- Add no advice outside the format. `[manual]` items are optional checks
- Your whole reply is the report below, under 30 lines. No preamble and no other headings

Report format:

### Accessibility

**Verdict:** Applies | Not applicable: {reason}
**Target:** {WCAG version and level with its source, or "default: WCAG 2.2 AA (none stated)"}
**UI test tooling:** {existing tools and the tier each runs in, or "none found". Suggest none.}
**Patterns in scope:** {patterns, noting any with no reference file}

**Requirements:**
- {pattern}: {requirement} `[auto]` | `[manual]` ({reference file})
- Baseline: {items from criteria-template.md that apply}
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
- **Reuse:** Merge every explorer's reuse candidates into the template's `### Reuse candidates`, one entry per entry point. `/plan-tasks` requires each phase that mirrors one to call it or say why not, so don't drop a candidate because it looks awkward to call — say why in **Call it, or why not**
- **Accessibility:** copy the accessibility agent's output into the template's `### Accessibility` trimmed to its shape. Where a codebase explorer found UI test tooling the accessibility agent missed, add it.
