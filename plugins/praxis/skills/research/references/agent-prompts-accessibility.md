# Accessibility Researcher

Prompt template for the Accessibility Researcher, dispatched by `/research` for UI work. Read with [agent-prompts.md](agent-prompts.md).

UI work only. Fill `{a11y_refs_dir}` with the absolute path of `references/accessibility/` under the research skill's base directory.

**Agent type:** `Explore` (subagent_type)
**Model:** `haiku`

```
Research accessibility for the feature: [{feature_description}].

Context about the codebase: [{brief_codebase_context}]

Reference folder: [{a11y_refs_dir}]

Instructions:
- Identify the interaction patterns in scope from the feature and the UI files it touches
- Read [{a11y_refs_dir}]/INDEX.md first. Then read every file whose row matches a pattern in scope, not only the closest one, plus criteria-template.md and citing-wcag.md. Grep wcag-criteria-list.md for an SC number, for example `grep -n "^| 2.5.8" wcag-criteria-list.md`. Do not read it whole
- If the folder is missing or no row matches a pattern, use your own knowledge, cite W3C APG or WCAG, and say in the report that no reference file existed
- For a native or cross-platform mobile app, mobile.md holds only platform-neutral principles. Read that platform's accessibility documentation for property and role names, and say so in the report
- Use the codebase context above for UI test tooling and target sources. Read only the UI files it names, for current accessibility patterns (semantic elements, roles, names, focus handling)
- Report a gap in a shared component only if you confirmed it by reading how its rendered output is built (including what its library supplies). Otherwise tag the line `unverified, confirm in a test`
- Target: use the WCAG version and level the project states (CLAUDE.md, linked docs, the ticket), and say where it came from. If none is stated, the target is WCAG 2.2 AA, marked as the default
- Cite the file and the requirement behind each finding. Follow citing-wcag.md: no source, no claim, and cite the WCAG version the project is held to
- Run no audits or scanners. Nothing is built at research time
- Read INDEX.md on its own. Then read the matching pattern files in at most two `cat` commands, each under 25,000 characters of output (check with `wc -c` first). Read criteria-template.md and citing-wcag.md together in a third. Never pipe through `head` or `cut`.
- Add no advice outside the format. `[manual]` items are optional checks
- One requirement per line. Do not join several behaviours on one line. Your whole reply is the report below, under 40 lines. No preamble and no other headings

Report format:

### Accessibility

**Verdict:** Applies | Not applicable: {reason}
**Target:** {WCAG version and level with its source, or "default: WCAG 2.2 AA (none stated)"}
**UI test tooling:** {existing tools and the tier each runs in, or "none found". Suggest none.}
**Patterns in scope:** {patterns, noting any with no reference file}

**Requirements:**
- {pattern}: {requirement} `[auto]` | `[manual]` ({reference file})
- Baseline: {each criteria-template.md baseline item that applies, one per line, tagged `[auto]` or `[manual]`, citing criteria-template.md}
```
