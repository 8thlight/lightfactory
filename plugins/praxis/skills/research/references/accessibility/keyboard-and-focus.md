# Keyboard and Focus

> Provenance and license: `PROVENANCE.md`, `LICENSE-community-access.md`.

Read this for any interactive UI. It matters most when the feature adds a composite widget (tabs, menu, listbox, tree, toolbar, grid), routes between pages in a single-page app, or adds and removes items dynamically.

## What to look for in the codebase

- Positive `tabindex` values: grep for `tabindex="[1-9]`.
- Removed focus indicators: grep for `outline: none` and `outline: 0`, and check whether a replacement style exists.
- Whether route changes move focus, and whether a skip link exists.
- A focus helper or a headless library that already implements roving tabindex.

## Requirements

**Tab order**
- DOM order is tab order. Never use `tabindex` above 0. Use `tabindex="0"` sparingly. Use `tabindex="-1"` for focus that is set by code.
- The first focusable element is a "Skip to main content" link.
- Tab order matches visual order, skips nothing, and reaches nothing unexpected.

**Arrow keys in composite widgets** (W3C APG)

| Component | Arrow behavior |
|---|---|
| Tabs | Left and Right (Up and Down if vertical) |
| Menu, listbox, combobox | Up and Down |
| Radio group | Up and Down, or Left and Right |
| Tree | Up and Down move, Left collapses, Right expands |
| Grid or table | All four arrows move between cells |
| Toolbar | Left and Right (Up and Down if vertical) |

- Arrow keys move focus within the widget. Tab leaves it and never cycles inside it.
- Home and End jump to the first and last item. They are optional in some patterns, such as tabs and toolbars.

**Which focus technique**
- Roving tabindex: one item has `tabindex="0"` and the rest `-1`. Arrow keys swap them and call `focus()`. The last focused item keeps `0`, so Shift+Tab returns to it. Use it when each item can take real focus (tabs, menus, toolbars, radio groups, trees).
- `aria-activedescendant`: DOM focus stays on the container, which names the highlighted item by id. Use it when the container must keep focus for typing (a combobox input, a grid with editable cells). The highlighted item needs a class for its visual state, since `:focus` does not apply. Clear it when nothing is highlighted.

**Disabled items**
- Standalone disabled controls leave the tab order.
- Disabled items inside a composite (listbox options, menu items, tabs, tree items) stay focusable, so arrow navigation is not broken. Mark them `aria-disabled="true"`.

**Focus management**
- Route change in a single-page app: move focus to the new page content, usually the H1 or main with `tabindex="-1"`, so the new page is announced. Never leave focus on the link that was clicked.
- Content the user triggered: move focus to it or announce it. Content that appears on its own: announce it with a live region and do not take focus (see `live-regions.md`).
- Deleting a list item: focus goes to the next item, or the previous if the last was deleted, or to the list or a heading if the list is now empty. Focus must never be lost.
- Never remove a focus indicator without a visible replacement. See `visual-and-motion.md`.

## Criteria wording

| Criterion | Check |
|---|---|
| Every interactive element can be reached and operated by keyboard | `[auto]` |
| In the widget, arrow keys move focus and Tab leaves it | `[auto]` |
| After a route change or delete, focus is on the named element | `[auto]` |
| No element has `tabindex` above 0 | `[auto]` |
| Focus is visible on every focusable element | `[manual]` |
| Tab order matches the visual order across the full page | `[manual]` |
