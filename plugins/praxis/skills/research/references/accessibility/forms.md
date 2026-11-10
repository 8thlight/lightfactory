# Forms

> Provenance and license: `PROVENANCE.md`, `LICENSE-community-access.md`.

Read this when the feature has inputs, selects, checkboxes, radios, search fields, or a multi-step flow. Authentication has its own rules in `cognitive.md`. Custom selects and autocompletes are in `composite-widgets.md`.

## What to look for in the codebase

- The form library and any shared field component (label, error, and help text are usually set in one place).
- How errors are shown: summary, inline, or toast, and whether they are linked to fields.
- When validation runs: keystroke, blur, or submit.
- Whether `autocomplete` is set on identity and payment fields.
- Custom controls (toggles, ratings, date pickers) and whether they wrap native inputs.

## Requirements

**Labels**
- Every control has a programmatically associated label. Use `<label for>` matching the input `id`. Clicking the label activates the control, which `aria-label` does not do.
- A placeholder is never the only label. It disappears on input and has poor contrast.
- Instructions and format rules live in persistent help text linked with `aria-describedby`, not only in a placeholder.
- Use `aria-label` only when a visible label cannot exist (a search input beside its button, an icon-only clear button). Use `aria-labelledby` when the label text comes from other visible elements.
- Label text is descriptive ("Email address", not "Input 1").

**Grouping and input purpose**
- Related radios and checkboxes sit in `<fieldset>` with `<legend>`.
- Identity and payment fields carry the matching `autocomplete` token (WCAG 1.3.5).

**Required fields and errors**
- Required fields use the `required` attribute and a visible indicator that does not rely on color alone.
- Each error names the specific problem and how to fix it, and is not conveyed by color alone.
- Errors are linked to their field with `aria-describedby`, and the field has `aria-invalid="true"`.
- On submit with errors, focus moves to an error summary or the first invalid field.
- Validation does not fire on every keystroke. Inline messages are announced without interrupting typing. Error and result regions follow `live-regions.md`.
- Use `aria-disabled` instead of `disabled` when the control must stay focusable.

**Submit and keyboard**
- Submit is `<button type="submit">`, not a link or a div.
- The whole form can be completed by keyboard alone, and tab order matches DOM order.
- Custom controls keep native keyboard behavior or implement the full ARIA pattern.
- Password show/hide toggles are buttons. File upload constraints are described, and upload status is announced.

**Multi-step flows**
- A progress indicator marks the current step with `aria-current="step"`.
- Each step has a heading with its number and name, and focus moves to that heading on a step change.
- A Back button exists, entered data persists across steps, and each step validates on its own.

**Search**
- Use `<search>`, or `<form role="search">` where `<search>` is unavailable. Do not also name the inner form, which would create a second landmark.
- The input has a label (visually hidden is acceptable). A live region announces the result count, debounced to 500 ms or more for live search.

## Common failures

- Placeholder as the only label.
- Error text not linked with `aria-describedby`, or no `aria-invalid`.
- Radio or checkbox groups without `fieldset` and `legend`.
- Styled custom inputs that lose native keyboard behavior.
- Submit control built from a `div` or `a`.
- No focus move after failed validation, so the user never learns errors exist.
- Missing `autocomplete` on identity and payment fields.
- Required state shown only by an asterisk's color.
- Tab order broken by CSS positioning that differs from DOM order.

## Criteria wording

| Criterion | Check |
|---|---|
| Each input has an accessible name matching its visible label | `[auto]` |
| Each error is linked to its field and the field is marked invalid | `[auto]` |
| After a failed submit, focus is on the error summary or first invalid field | `[auto]` |
| The form can be completed and submitted by keyboard alone | `[auto]` |
| Groups of radios or checkboxes have a group name | `[auto]` |
| Error text says what is wrong and how to fix it | `[manual]` |
| Errors and step changes are announced by a screen reader | `[manual]` |
| Label wording is clear to a first-time user | `[manual]` |

## Questions for the research report

- Is there one shared field component, or does each form wire its own labels and errors?
- What does the project already use to test forms (role-based queries, axe, Playwright)?
