# Modals and Overlays Reference Checklist

Reference for accessibility review agent. Load when diff shows modal, dialog, popover, sheet, drawer, confirmation prompt, alert dialog, or any overlay above page content. Not an agent, no tools, no autonomous action. Findings for human dev/designer to confirm/fix; nothing here auto-applied.

<!-- Adapted from Community-Access/accessibility-agents, claude-code-plugin/agents/modal-specialist.md, upstream commit 0872b4a, copied 2026-07-10 -->
<!-- Text compressed with the caveman skill to reduce token load -->

## Authoritative Sources

- **ARIA Dialog (Modal) Pattern** — <https://www.w3.org/WAI/ARIA/apg/patterns/dialog-modal/>
- **WCAG 2.4.3 Focus Order** — <https://www.w3.org/WAI/WCAG22/Understanding/focus-order.html>
- **ARIA dialog role** — <https://www.w3.org/TR/wai-aria-1.2/#dialog>
- **HTML dialog element** — <https://html.spec.whatwg.org/multipage/interactive-elements.html#the-dialog-element>

Broken modal = one of the worst a11y failures: users trapped with no exit, or interacting with content behind the modal unknowingly.

**Related:** `inert` mechanics, tab-order behind the trap, general keyboard-operability beyond the modal-specific focus trap → `references/a11y-keyboard-navigation.md`.

## Scope

Everything overlaying the page:

- Modal dialogs
- Alert dialogs / confirmation prompts
- Drawers and sheets (side panels)
- Popovers and disclosure panels
- Filter modals
- Settings panels
- Any content appearing above the page requiring dismissal

## Required Structure

Prefer native `<dialog>`. `<div>`-built modals without a documented technical constraint = flag-worthy.

```html
<button id="trigger" aria-haspopup="dialog">Open Settings</button>

<dialog id="settings-modal" role="dialog" aria-modal="true" aria-labelledby="modal-title">
  <button id="close-btn" aria-label="Close">
    <svg aria-hidden="true">...</svg>
    Close
  </button>

  <h2 id="modal-title">Settings</h2>

  <!-- Modal content -->
</dialog>
```

(Also check `references/a11y-aria.md` for ARIA roles/attrs beyond modal structure — naming, live regions, other widget patterns.)

## Non-Negotiable Rules

### Focus Landing

Per W3C APG, target depends on content/purpose:

| Scenario | Focus Target | Reason |
|----------|-------------|--------|
| Simple confirmation (delete, discard) | Least destructive action (Cancel) | Prevents accidental destructive Enter |
| Complex content (settings, forms, long text) | Static element (`tabindex="-1"` on title/first paragraph) | Lets user read before acting; avoids skipping content |
| Simple continuation (save, proceed) | Most-used action (Save/Continue) | Streamlines common path |
| Default / general | First focusable element | W3C APG default |

```javascript
// Complex dialog: focus the heading so screen reader reads it first
const heading = modal.querySelector('h2');
heading.setAttribute('tabindex', '-1');
modal.showModal();
heading.focus();

// Destructive confirmation: focus Cancel
modal.showModal();
modal.querySelector('#cancel-btn').focus();
```

Flag a dialog that always focuses Close regardless of scenario — Close is usually a last resort, not the primary action.

### Visible Close Button

Every dialog needs a visible close button (W3C APG). Icon-only → `aria-label="Close"`. Consistent, discoverable location (typically top-right), reachable by keyboard without scrolling.

### Focus Trapping

- `<dialog>` + `showModal()` traps focus natively
- Tab/Shift+Tab cycles only inside the modal
- Nothing behind it reachable
- Check for `tabindex` on backdrop/outer container leaking focus out

### Focus Return

- On close, focus returns to the trigger
- Look for a stored trigger reference before opening
- Look for `triggerButton.focus()` after `modal.close()`
- Applies to Escape, Close button, any dismissal path

### Escape Key

- Escape must close the modal
- `<dialog>` handles natively — verify diff doesn't override/suppress
- After Escape, focus returns to trigger
- Confirmation dialogs risking data loss: expect Escape intercepted with a confirmation first

### `aria-modal` and Background Inertness

`aria-modal="true"` tells AT that outside content is inert — modern replacement for manually applying `aria-hidden="true"` to every sibling.

```html
<!-- Modern: aria-modal handles background hiding -->
<dialog role="dialog" aria-modal="true" aria-labelledby="modal-title">
  ...
</dialog>

<!-- Legacy (flag as outdated): manual aria-hidden on siblings -->
<div aria-hidden="true"><!-- page content --></div>
<div role="dialog">...</div>
```

Prefer `aria-modal="true"` on `<dialog>`. `inert` on background content gives even stronger protection.

### Heading Structure

- Modal heading starts at H2 (H1 = page title behind it)
- Flag H1 inside a modal
- Normal hierarchy inside modal (H2, H3, H4)

### Labeling

- `aria-labelledby` → heading ID
- Omit `aria-describedby` when body has semantic structures (lists/tables/fields) — it flattens content to a single string, destroying structure
- `aria-describedby` fits only short plain-text paragraphs (alert dialogs)
- Trigger needs `aria-haspopup="dialog"`
- Flag as needing `role="dialog"`/`aria-modal` only when BOTH true: (1) code blocks outside interaction, (2) styling obscures the page behind. Otherwise may be non-modal (below).

## Alert Dialogs

For confirmations requiring a decision:

```html
<dialog role="alertdialog" aria-modal="true" aria-labelledby="alert-title" aria-describedby="alert-desc">
  <h2 id="alert-title">Delete Project?</h2>
  <p id="alert-desc">This action cannot be undone. All data will be permanently removed.</p>
  <button id="cancel-btn">Cancel</button>
  <button id="confirm-btn">Delete</button>
</dialog>
```

- Use `role="alertdialog"`, not `role="dialog"`
- Focus lands on least destructive action (Cancel, not Delete)
- `aria-describedby` links the explanation
- Screen reader announces title + description on open

## Drawers and Sheets

Same rules as modals: `<dialog>` + `showModal()`, focus on Close, focus trapped, Escape closes, focus returns to trigger. Only difference is CSS positioning — a11y requirements identical.

## Filter Modal Pattern

Common filter interface pattern:

```html
<button id="filters-btn">Filters</button>
<button id="clear-all-btn" hidden>Clear All Filters</button>
<div id="applied-filters" aria-live="polite"></div>

<dialog id="filters-modal" role="dialog" aria-modal="true" aria-labelledby="filters-title">
  <button aria-label="Close filters">Close</button>
  <h2 id="filters-title">Filters</h2>
  <div aria-live="polite" id="result-count">25 results</div>

  <form>
    <fieldset>
      <legend><h3>Category</h3></legend>
      <!-- Checkboxes -->
    </fieldset>
    <button type="submit">Apply Filters</button>
    <button type="button">Clear All</button>
  </form>
</dialog>
```

Filter-specific requirements:

- Live region updates result count as checkboxes change
- Headings per filter group (inside fieldset legends)
- Apply button confirms selection
- Clear All available inside modal AND on the page after closing
- Applied filters shown on the page after closing
- Focus returns to Filters button on close

## Non-Modal Dialogs

Allow interaction with content behind them; close on outside click or Escape.

```html
<dialog id="tooltip-dialog" role="dialog" aria-labelledby="tooltip-title">
  <h3 id="tooltip-title">Field Help</h3>
  <p>Enter your company registration number.</p>
</dialog>
```

Requirements:

- No `aria-modal="true"` — content behind stays accessible
- Open with `dialog.show()`, not `showModal()`
- Closes on losing focus (outside click or Tab away)
- Escape closes it
- No focus trap — Tab can leave
- Focus returns to trigger on close

## Popover API

`popover` attribute: lightweight overlay with built-in dismiss-on-click-outside and Escape handling. Good for tooltips, menus, non-modal overlays.

```html
<button popovertarget="help-popover">Help</button>
<div id="help-popover" popover>
  <p>This field accepts your company registration number.</p>
</div>
```

- Non-modal by default — no focus trap
- Browser handles Escape + light-dismiss (click outside)
- `popover="manual"` disables light-dismiss
- Promoted to top layer — no z-index issues
- Popover fits simple overlays; `<dialog>` + `showModal()` for true modals

## Validation Checklist

1. Uses `<dialog>` with `showModal()`?
2. Focus lands per scenario rules (least-destructive / heading / first-focusable)?
3. Focus trapped inside (modal dialogs)?
4. Escape closes it?
5. Focus returns to trigger on close?
6. Heading at H2 or lower?
7. `aria-labelledby` points to a valid heading ID?
8. Trigger has `aria-haspopup="dialog"`?
9. `aria-modal="true"` present on modal dialogs?
10. `aria-describedby` used only for short plain-text descriptions?
11. Visible close button?
12. Alert dialogs: focus on least destructive action?
13. Icons inside modal hidden with `aria-hidden="true"`?
14. Filter modals: live region for result counts?

## Common Mistake Patterns

- `<div>`-built modal with `role="dialog"` but no focus trap
- Focus on heading instead of Close (or vice versa, depending on scenario)
- Missing focus return on close (drops to top of page)
- Nested modals without a proper focus stack
- Backdrop click closes but doesn't return focus
- `aria-hidden="true"` left on modal container after opening
- Scrollable modal content unreachable by keyboard

Findings here are for a human to confirm and act on — never applied as automatic fixes.
