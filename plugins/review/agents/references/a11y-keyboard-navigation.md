# Keyboard Navigation and Focus Management Reference

Checklist for keyboard nav, tab order, focus management. Accessibility review agent reads this on relevant diff patterns (interactive components, nav/routing changes, tab order, shortcuts, focus traps, skip links). Not an agent, no tools, no autonomous action — informs findings for human validation.

<!-- Adapted from Community-Access/accessibility-agents, claude-code-plugin/agents/keyboard-navigator.md, upstream commit 0872b4a, copied 2026-07-10 -->
<!-- Text compressed with the caveman skill to reduce token load -->

## Authoritative Sources

- **WCAG 2.1.1 Keyboard** — <https://www.w3.org/WAI/WCAG22/Understanding/keyboard.html>
- **WCAG 2.4.3 Focus Order** — <https://www.w3.org/WAI/WCAG22/Understanding/focus-order.html>
- **WCAG 2.4.7 Focus Visible** — <https://www.w3.org/WAI/WCAG22/Understanding/focus-visible.html>
- **ARIA Keyboard Navigation** — <https://www.w3.org/WAI/ARIA/apg/practices/keyboard-interface/>
- **HTML Living Standard** — <https://html.spec.whatwg.org/multipage/>

Unreachable/inoperable/inescapable-by-keyboard = broken for keyboard-only users: motor disabilities, screen reader users, mouse-averse users alike.

## Scope

- Tab order and focus sequence
- Focus management during page transitions/dynamic content
- Keyboard traps (bad ones to catch, intentional ones to verify)
- Skip links
- Arrow key navigation patterns
- Focus indicator visibility (contrast/styling detail → `contrast-and-visual.md`)
- SPA route-change focus handling

## Tab Order

### Natural Order

- DOM order = tab order
- Positive `tabindex` (>0): flag — breaks natural flow, unpredictable nav
- `tabindex="0"`: makes non-interactive elements focusable (fine in moderation)
- `tabindex="-1"`: programmatically focusable, not in tab order (focus management)

### Verification

Trace tab order through the changed section:

1. Start at skip link, if present
2. Walk every interactive element in the diff
3. Check order against visual layout (left→right, top→bottom)
4. No elements skipped
5. No unexpected elements receive focus

Grep for problems:

```text
tabindex="[1-9]    # Positive tabindex -- almost always worth flagging
outline: none      # Focus indicator possibly removed
outline: 0         # Focus indicator possibly removed
```

## Focus Management

### Page/Route Changes (SPA)

On route change:

- Focus moves to new page content
- Recommended: focus H1 or main content area
- H1/main needs `tabindex="-1"` for programmatic focus
- Screen reader announces new page (heading text)
- Flag: focus left on the just-clicked nav link

```javascript
// After route change
const heading = document.querySelector('h1');
heading.setAttribute('tabindex', '-1');
heading.focus();
```

### Dynamic Content

Content appearing dynamically (search results, loaded sections, notifications):

- User-triggered: focus moves to new content, or a live-region announcement — either is expected
- Automatic: `aria-live` announces without stealing focus
- Toasts: `aria-live="polite"`, no focus move

### Deletion and Removal

- Deleting a list item → focus moves to next item
- Last item deleted → focus moves to previous item
- List now empty → focus moves to container or heading
- Flag: focus lost to `<body>`

## Keyboard Traps

### Bad Traps (flag)

- Custom widgets capturing Tab with no Escape exit
- Embedded content (iframes, video players) trapping keyboard
- Infinite scroll where Tab never reaches content below

### Good Traps (expected)

- Modal dialogs: Tab/Shift+Tab cycling only within the modal is correct
- `<dialog>` + `showModal()` handles natively
- Custom implementations: track first/last focusable elements, wrap Tab last→first and Shift+Tab first→last

## Skip Links

Expected on web apps/sites.

```html
<body>
  <a href="#main-content" class="skip-link">Skip to main content</a>
  <header><nav>...</nav></header>
  <main id="main-content" tabindex="-1">...</main>
</body>
```

```css
.skip-link {
  position: absolute;
  top: -40px;
  left: 0;
  background: #000;
  color: #fff;
  padding: 8px 16px;
  z-index: 100;
}
.skip-link:focus {
  top: 0;
}
```

Checklist: first focusable element on page; visually hidden until focused; links to `<main>` with `tabindex="-1"`; verify Tab-on-load actually reaches it.

## Arrow Key Patterns

Per WAI-ARIA APG:

| Component | Arrow Behavior |
|-----------|---------------|
| Tabs | Left/Right moves between tabs |
| Menu | Up/Down moves between items |
| Combobox | Up/Down moves through options |
| Radio group | Up/Down or Left/Right moves selection |
| Tree view | Up/Down moves, Left collapses, Right expands |
| Grid/Table | All four arrows navigate cells |
| Toolbar | Left/Right moves between tools |
| Listbox | Up/Down moves between options |

For all: arrows move focus within the component; Tab moves OUT to the next component; Home/End jump to first/last item.

### Roving Tabindex

Standard technique for arrow-key nav in composite widgets. One item `tabindex="0"` (in tab order), rest `tabindex="-1"`. Arrow keys swap the values and call `focus()`.

```html
<!-- Roving tabindex on a tab list -->
<div role="tablist">
  <button role="tab" tabindex="0" aria-selected="true">Tab 1</button>
  <button role="tab" tabindex="-1" aria-selected="false">Tab 2</button>
  <button role="tab" tabindex="-1" aria-selected="false">Tab 3</button>
</div>
```

```javascript
function moveFocus(current, next) {
  current.setAttribute('tabindex', '-1');
  next.setAttribute('tabindex', '0');
  next.focus(); // Browser scrolls into view automatically
}
```

Per W3C APG: Tab enters the widget on the `tabindex="0"` item; arrows move that value + call `focus()`; Tab exits entirely, never cycles; last-focused item keeps `tabindex="0"` so Shift+Tab return lands correctly.

### `aria-activedescendant` Alternative

DOM focus stays on the container; a visual indicator tracks the "active" descendant. Useful when the container must keep focus (combobox input, grid with editable cells).

```html
<input role="combobox" aria-activedescendant="option-2" aria-controls="listbox-1">
<ul id="listbox-1" role="listbox">
  <li role="option" id="option-1">Apple</li>
  <li role="option" id="option-2" class="visually-focused">Banana</li>
  <li role="option" id="option-3">Cherry</li>
</ul>
```

Per W3C APG: container (DOM focus) sets `aria-activedescendant` to the visually-focused item's `id`; referenced element must be a DOM descendant or owned via `aria-owns`; container needs `aria-controls` → popup; CSS must visually mark the active descendant (no true DOM focus, so `:focus` doesn't apply — use a class); clear `aria-activedescendant` (`""`) when nothing highlighted.

### When to Use Which

| Pattern | Use When |
|---------|----------|
| Roving tabindex | Tab list, menu, toolbar, radio group, tree -- any widget where each item can receive true DOM focus |
| `aria-activedescendant` | Combobox (focus must stay on input), grid with editable cells, any composite where the container must retain focus for typing |

## Disabled Element Focus Conventions

Per W3C APG, focusability of disabled elements depends on context.

### Remove from Tab Sequence (standalone controls)

Disabled standalone controls (buttons, links, inputs outside a composite) should not be in tab order. Use `disabled`, or `tabindex="-1"` + `aria-disabled="true"`.

### Keep Focusable When Disabled (items inside composites)

Disabled items inside composite widgets stay focusable so arrow-key nav isn't broken — user arrows to it, hears "disabled," continues. Applies to: listbox options, menu items, tabs, tree items, toolbar buttons (discoverability).

```html
<!-- Disabled menu item: focusable via arrow keys, announced as disabled -->
<li role="menuitem" aria-disabled="true">Paste</li>
```

## The `inert` Attribute

Makes a subtree non-interactive and invisible to AT — native replacement for manually toggling `aria-hidden="true"` + `tabindex="-1"` on multiple elements.

```html
<!-- Content behind a modal -->
<div id="page-content" inert>
  <header>...</header>
  <main>...</main>
</div>

<dialog open>
  <!-- Modal content -->
</dialog>
```

Supported in all modern browsers. Elements inside `inert` can't be focused, clicked, or read by screen readers. Remove `inert` when the modal closes to restore interactivity. `inert` beats manual `aria-hidden` toggling for background overlays.

## Keyboard Shortcut Conflicts

Custom shortcuts shouldn't conflict with OS/AT/browser shortcuts.

### Reserved Keys — Flag If Overridden

- **OS:** modifier + Tab/Enter/Space/Escape; Meta + single key (Win/Cmd shortcuts); Alt + function keys
- **AT:** CapsLock/Insert/ScrollLock + any key (screen reader commands); single keys in screen reader virtual mode (H, K, T, etc.)
- **Browser:** Ctrl+L (address bar), Ctrl+T (new tab), Ctrl+W (close tab), F5 (refresh), F6 (address bar), F11 (fullscreen)

### Safe Patterns

- Single-key shortcuts (Gmail "j/k") should be disablable/remappable per WCAG 2.1.4
- Prefer Ctrl+Shift or app-specific modifier combos for custom shortcuts
- Document shortcuts with a discoverable help panel

## Scroll Containers

Non-natively-focusable scrollable regions (e.g. `<div overflow: auto>`) need `tabindex="0"` for arrow-key scrolling.

```html
<div class="code-block" tabindex="0" role="region" aria-label="Code example">
  <pre><code>/* scrollable code */</code></pre>
</div>
```

Without `tabindex="0"`, keyboard users can't scroll it at all. Add `role="region"` + `aria-label` only for significant navigable sections; otherwise `tabindex="0"` alone suffices.

## Common Mistakes Worth Catching

- Click handlers on `<div>`/`<span>` with no keyboard equivalent (no `onKeyDown`, `role="button"`, `tabindex`)
- Hover-only interactions with no keyboard trigger
- Drag-and-drop without keyboard alternative
- Custom dropdowns that open on click but ignore arrow keys
- Scroll-to-reveal content with no keyboard trigger
- Infinite scroll pushing footer/other content permanently out of reach
- Focus left on a removed DOM element (goes to `<body>`, user loses place)
- `mousedown`/`mouseup` handlers with no `keydown`/`keyup` counterpart
- Elements hidden via `display: none`/`visibility: hidden` still focusable via stale refs
- `outline: none`/`outline: 0` with no alternative focus style

## Validation Checklist

1. Every interactive element reachable by Tab?
2. Every interactive element activatable by Enter or Space?
3. Tab order matches visual layout?
4. No positive `tabindex`?
5. Focus managed on route changes?
6. Focus managed when content added/removed?
7. No keyboard traps (except intentional modal traps)?
8. Skip link present and working?
9. Arrow keys work in tabs, menus, comboboxes?
10. Escape closes overlays and returns focus?
11. Focus indicators visible on every interactive element?

## Reporting Findings

Report for human review — never apply a fix autonomously. State the specific broken behavior (e.g. "positive tabindex found," "no keyboard equivalent for this click handler," "focus indicator appears removed"), what a keyboard-only user experiences, and where in the diff (file:line). Framework-specific fix suggestions (React Router `useEffect`, Vue Router `afterEach`, Angular `Router.events`, etc.) are useful context, not instructions. Focus indicator *contrast/styling* specifics → `contrast-and-visual.md`.
