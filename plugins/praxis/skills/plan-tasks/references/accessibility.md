# Accessibility

How `/plan-tasks` turns accessibility into acceptance criteria for UI work. The criteria ride the existing chain: test spec, RED gate, VALIDATE, and the final plan check. No new agent or gate.

## When It Applies

- The research artifact's `### Accessibility` verdict says it applies.
- With no research artifact, check the request and the files in scope for UI words (page, form, screen, component, modal) or UI files (components, templates, styles).
- Otherwise it is not applicable. Omit the `### Accessibility` heading and add no criteria.

## Where the Requirements Come From

- **Research artifact exists:** write criteria from its `### Accessibility` section. It carries each requirement tagged `[auto]` or `[manual]`, the baseline items that apply, the target, and the UI test tooling and tier. Do not read the reference files unless the section is thin for a pattern in scope.
- **Research skipped:** read [INDEX.md](../../research/references/accessibility/INDEX.md) and use its "Pattern in scope" table. Read every file whose row matches, not only the closest one (a login form matches `forms.md`, `cognitive.md`, and `keyboard-and-focus.md`). Also read `criteria-template.md`, and `citing-wcag.md` when a criterion cites a standard. Do not restate the pattern list here.
- **No row matches:** use your own knowledge, cite W3C APG or WCAG, and say in the plan that no reference file existed. For a native or cross-platform mobile app, `mobile.md` holds only platform-neutral principles. Read that platform's accessibility documentation for property and role names, and note it in the plan.

## Target

Use the research target. With no research, use the level or version the project states (CLAUDE.md, a linked doc, the ticket, or a law it answers to), else WCAG 2.2 AA. Say which in `### Accessibility`, and mark the default.

## Writing the Criteria

In step 3, write them into `## Acceptance Criteria` before running `technical-project-manager`.

- **Route** each `[auto]` criterion to the test spec of the phase that delivers the UI it covers, at the lowest tier where the project already runs UI tests (Phase tiers in SKILL.md). Name and role checks run wherever those tests run, such as a component test with Testing Library. Keyboard paths, focus movement, and whole-page automated scans need a browser, so they go in the `e2e-journey` fragment for that surface. Database and repository phases hold no UI. Only a project with no UI test setup makes a criterion `[manual]`.
- **Describe behavior, not tool calls:** "no automated accessibility violations on the surface", "focus returns to the trigger after Escape".
- **RED gate signature:** for each routed criterion, write what a correct failure looks like, following "Authoring the RED gate signature" in SKILL.md. Examples: no element with role `button` and name "Place order"; after Escape, focus is not on the trigger; the scan lists a violation on the form. A setup error or a timeout on a different step is a wrong-reason RED. This is how `agent-test` gets the guidance.
- **RED gate profile:** a project that wants stricter accessibility RED rules adds a `RED gate` section to a UI rule file under `.claude/rules/`. The existing lookup copies it.
- **`[manual]` checks** are optional. List them under Constraints → Accessibility only, in the format in `criteria-template.md`. They are not acceptance criteria or risk rows, and `/implement` does not carry them.

## Ordering with the TPM

The TPM reads the draft's acceptance criteria. Do not add a Risks & Mitigations row for a requirement that is already a criterion. When merging the TPM's in-repo mitigations into the criteria, skip any that duplicate one.

## Anti-Patterns to Avoid

- **Don't route a criterion to a phase with no UI**
- **Don't turn a `[manual]` check into an acceptance criterion**
- **Don't add a criterion the TPM also lists as a mitigation**
