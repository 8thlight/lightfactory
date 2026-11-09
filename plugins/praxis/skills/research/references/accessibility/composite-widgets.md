# Accessibility Reference: Tabs, Accordion, Carousel, Combobox, Menu

> **Source repo:** Community-Access/accessibility-agents (https://github.com/Community-Access/accessibility-agents)
> **Upstream commit:** `a538edc9edfb98cdd8bae96d6b79542874b478f7` (main, 2026-11-07)
> **Retrieved:** 2026-11-09
> **License:** MIT, Copyright (c) 2026 Taylor Arndt
> **Upstream files:**
> - `mcp-server/server-core.js` (the `tabs`, `accordion`, `carousel`, and `combobox` entries of the `GUIDELINES` constant)
> - `skills/forms-specialist/references/combobox-autocomplete-pattern.md`
> - `skills/keyboard-navigator/references/arrow-key-patterns.md` (menu item behavior)
>
> **Adapted:** the upstream has no dedicated file for tabs, accordion, carousel, or menu. The first three come from short summary entries and were expanded only where the combobox file or the APG statements it cites support it. Menu guidance here is limited to the arrow-key and disabled-item rules in the keyboard file. For anything beyond this, a research agent falls back to the W3C APG and says so. Criteria wording is new.

Read this when the feature adds a custom widget that has no native HTML equivalent. Prefer the native element (`<select>`, `<details>`, `<button>`) when it meets the need. Keyboard rules shared by all of these are in `keyboard-and-focus.md`.

## What to look for in the codebase

- A headless or component library that already ships these widgets (Radix, Headless UI, MUI, Reach, and similar), and which version.
- Hand-built widgets made from `div`s with click handlers.

## Tabs

- The container is `role="tablist"` with an `aria-label`. Each tab is a `<button role="tab">` with `aria-selected`. Each panel is `role="tabpanel"` with `aria-labelledby`.
- Unselected tabs have `tabindex="-1"` (roving tabindex).
- Left and Right move between tabs. Tab moves out of the tablist. Home and End jump to the first and last tab.

## Accordion

- Each toggle is a button inside a heading element.
- `aria-expanded` reflects open or closed. `aria-controls` points at the panel. The panel is `role="region"` with `aria-labelledby`.

## Carousel

- Each slide is `role="group"` with `aria-roledescription="slide"` and an `aria-label` that includes position ("Slide 1 of 3").
- No auto-rotation, or a stop button placed before the carousel.
- Previous and Next buttons come before the slides. Dot navigation uses labeled buttons ("Go to slide 1"), and the current dot has `aria-current="true"`.

## Combobox and autocomplete

A combobox is an input with a popup (listbox, grid, tree, or dialog) that helps set the value. There are two kinds: editable (the user can type any value, and the popup filters) and select-only (a custom `<select>` replacement, where typing jumps to a matching option).

- The input has `role="combobox"`, `aria-expanded`, `aria-controls` pointing at the popup, and `aria-autocomplete` (`none`, `list`, `both`, or `inline`). Use `aria-controls`, not `aria-owns`.
- The popup is `role="listbox"` and each item is `role="option"`.
- DOM focus stays on the input. `aria-activedescendant` names the highlighted option.
- Down arrow opens the popup and moves to the first option. Escape closes it without changing the value. Enter accepts the highlighted option.
- A live region announces the result count ("3 cities match. Use arrow keys to navigate").
- Set `autocomplete="off"` to stop browser autocomplete from competing, except on fields that collect information about the user (1.3.5). Keep the matching token there, such as `address-level2` for a city.

## Menu

- Up and Down move between items. A disabled item stays focusable and carries `aria-disabled="true"`. See `keyboard-and-focus.md`.
- No further upstream guidance. Research should cite the W3C APG menu and menu button patterns and say that the reference has no file for it.

## Common failures

- Tabs where every tab is a Tab stop.
- Accordion toggle that is a `div`, or an `aria-expanded` that does not change.
- Auto-rotating carousel with no stop control.
- Combobox using `aria-owns`, or moving DOM focus into the list.
- Result count never announced.

## Criteria wording

| Criterion | Check |
|---|---|
| The widget exposes the expected roles and names for each part | `[auto]` |
| State attributes (`aria-selected`, `aria-expanded`, `aria-current`) change with the interaction | `[auto]` |
| Arrow keys, Home, End, and Escape behave as listed for the pattern | `[auto]` |
| Tab leaves the widget in one press | `[auto]` |
| A screen reader announces state changes and the combobox result count | `[manual]` |
| The widget makes sense when its purpose is announced without sight | `[manual]` |

## Questions for the research report

- Does the project's component library already cover this widget? If so, which accessibility behavior does it provide, and which does the feature still owe?
