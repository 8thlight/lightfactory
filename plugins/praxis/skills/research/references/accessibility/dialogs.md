# Dialogs and Modals

> Provenance and license: `PROVENANCE.md`, `LICENSE-community-access.md`.

Read this when the feature adds a modal, alert dialog, confirmation prompt, drawer, sheet, or popover that covers the page.

## What to look for in the codebase

- Native `<dialog>` use, or a component library's dialog (Radix, MUI, Headless UI, and similar), or hand-built `div` overlays.
- How the trigger is wired, and whether the dialog stores it to return focus.
- Whether the page behind is made inert (`inert` attribute or the library's equivalent).

## Requirements

**Focus landing.** Where focus goes on open depends on the dialog:

| Scenario | Focus target |
|---|---|
| Destructive confirmation (delete, discard) | The least destructive action (Cancel) |
| Complex content (settings, forms, long text) | A static element, such as the title with `tabindex="-1"` |
| Simple continuation (save, proceed) | The most-used action |
| Default | The first focusable element |

Do not always focus the Close button.

**Containment and return**
- Focus stays inside while open. A native `<dialog>` opened with `showModal()` makes the rest of the page inert and is exposed as modal by the browser. Do not add `role="dialog"` or `aria-modal` to it.
- A custom modal needs `role="dialog"`, `aria-modal="true"`, `aria-labelledby`, a Tab and Shift+Tab loop, and the `inert` attribute on the page behind it. Manual `aria-hidden` on every sibling is the legacy pattern.
- On close by any route (Escape, Close, an action), focus returns to the element that opened it.
- Escape closes the dialog. If Escape would lose data, intercept the `cancel` event and confirm first.

**Structure and naming**
- The dialog has a visible close button. An icon-only one needs `aria-label="Close"`.
- The title is an H2 or lower, never an H1.
- `aria-labelledby` points at the title.
- Omit `aria-describedby` when the body holds lists, tables, or form fields, because it flattens them into one string. Use it only for a short plain-text paragraph, as in an alert dialog.
- Confirmations use `role="alertdialog"`.
- The trigger is a `<button>`. Mark a dialog modal only when code blocks the outside content and styling obscures it.

## Criteria wording

| Criterion | Check |
|---|---|
| On open, focus moves into the dialog to the target the scenario calls for | `[auto]` |
| Tab and Shift+Tab never leave the dialog while it is open | `[auto]` |
| Escape closes the dialog and focus returns to the trigger | `[auto]` |
| Closing by the Close button or an action also returns focus to the trigger | `[auto]` |
| The dialog has an accessible name from its title | `[auto]` |
| The page behind is not reachable by keyboard or screen reader | `[manual]` |
| A screen reader announces the dialog name and role on open | `[manual]` |
