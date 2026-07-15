# ARIA Reference Checklist

Reference for accessibility review agent. Load when diff shows ARIA attributes, roles, or interactive widget markup (modals, tabs, accordions, comboboxes, live regions, carousels, custom widgets, forms, dynamic content). Not an agent itself — no tools, no autonomous action. Findings: for human dev/designer to confirm and fix, never auto-applied.

<!-- Adapted from Community-Access/accessibility-agents, claude-code-plugin/agents/aria-specialist.md, upstream commit 0872b4a, copied 2026-07-10 -->
<!-- Text compressed with the caveman skill to reduce token load -->

## Authoritative Sources

- **WAI-ARIA 1.2 Specification** — <https://www.w3.org/TR/wai-aria-1.2/>
- **ARIA Authoring Practices Guide (APG)** — <https://www.w3.org/WAI/ARIA/apg/>
- **WCAG 2.2 Specification** — <https://www.w3.org/TR/WCAG22/>
- **axe-core ARIA Rules** — <https://github.com/dequelabs/axe-core/blob/develop/doc/rule-descriptions.md>
- **HTML Living Standard** — <https://html.spec.whatwg.org/multipage/>

Incorrect ARIA worse than no ARIA — actively breaks screen reader experience.

## First Rule of ARIA

Don't use ARIA if native HTML expresses semantics. `<button>` beats `<div role="button">`. `<dialog>` beats `<div role="dialog">`. Native HTML first, ARIA second.

## ARIA That Should Never Be Added

These already have implicit roles. Adding ARIA redundant, can cause double announcements:

- `<header>` — already banner landmark
- `<nav>` — already navigation landmark
- `<main>` — already main landmark
- `<footer>` — already contentinfo landmark
- `<button>` — never add `role="button"`
- `<a href>` — never add `role="link"`
- `<input type="checkbox">` — never add `role="checkbox"`
- `<select>` — never add `role="listbox"`

Exception: multiple `<nav>` on one page need `aria-label` to differentiate ("Main navigation", "Footer navigation").

## ARIA That Must Be Used Correctly

### Modals

```html
<dialog role="dialog" aria-modal="true" aria-labelledby="modal-title">
  <button aria-label="Close">Close</button>
  <h2 id="modal-title">Title</h2>
</dialog>
```

Requirements:

- `role="dialog"` and `aria-modal="true"` on `<dialog>`
- `aria-labelledby` pointing to the heading
- Focus lands on Close button immediately (no Tab needed)
- Close button is first element inside modal
- Escape closes and returns focus to trigger
- Heading starts at H2 (H1 is the page title)
- Trigger button gets `aria-haspopup="dialog"`

(Also check `references/a11y-modals-overlays.md` for overlay/modal diffs — covers focus trapping, focus return, dialog variants in depth.)

### Tabs

```html
<div role="tablist" aria-label="Section tabs">
  <button role="tab" aria-selected="true" aria-controls="panel-1">Tab 1</button>
  <button role="tab" aria-selected="false" aria-controls="panel-2" tabindex="-1">Tab 2</button>
</div>
<div role="tabpanel" id="panel-1" aria-labelledby="tab-1">Content</div>
```

Requirements:

- Container has `role="tablist"` with `aria-label`
- Each tab is a `<button>` with `role="tab"` and `aria-selected`
- Unselected tabs have `tabindex="-1"`
- Panels have `role="tabpanel"` and `aria-labelledby`
- Arrow keys move between tabs
- Screen reader must announce "Tab 1, selected" not just "Tab 1"

### Accordions

```html
<h2>
  <button aria-expanded="false" aria-controls="panel-1">Question</button>
</h2>
<div id="panel-1" role="region" aria-labelledby="accordion-btn-1" hidden>Answer</div>
```

Requirements:

- Toggle button inside a heading element
- `aria-expanded` reflects open/closed state
- `aria-controls` links to panel ID
- Panel has `role="region"` and `aria-labelledby`
- Escape closes the open panel

### Live Regions

```html
<div aria-live="polite" id="status">25 results</div>
```

Rules:

- `aria-live="polite"` for non-urgent updates (search results, filter changes, form success)
- `aria-live="assertive"` only for critical alerts (errors, session expiring)
- Never assertive for routine updates — interrupts whatever screen reader is currently reading
- Live region element must exist in DOM before content changes
- Update text content, don't replace element
- Keep announcements short, meaningful

### Combobox / Autocomplete

```html
<input role="combobox" aria-expanded="false" aria-controls="results" aria-autocomplete="list" autocomplete="off">
<div aria-live="polite" class="visually-hidden" id="status"></div>
<ul id="results" role="listbox" hidden>
  <li role="option" id="result-0">Item</li>
</ul>
```

Requirements:

- Input: `role="combobox"`, `aria-expanded`, `aria-controls`, `aria-autocomplete="list"`
- Results list: `role="listbox"`, items `role="option"`
- Arrow keys navigate options
- `aria-activedescendant` tracks current option
- Live region announces result count ("3 results available")
- Escape closes list

### Carousels

```html
<div role="group" aria-roledescription="slide" aria-label="Slide 1 of 3">
  <img src="photo.jpg" alt="Descriptive text about what is shown">
</div>
```

Requirements:

- Each slide: `role="group"` with `aria-roledescription="slide"`
- `aria-label` includes position ("Slide 1 of 3")
- No auto-rotation (or stop button accessible before carousel)
- Previous/Next buttons before the slides
- Dot navigation: list of buttons with labels ("Go to slide 1")
- Current dot: `aria-current="true"`
- All images have descriptive alt text

## Icons and Decorative Elements

Always hide icons from screen readers — they create verbosity.

```html
<!-- Button with icon -- hide the icon -->
<button>
  <svg aria-hidden="true">...</svg>
  Save
</button>

<!-- Icon-only button -- needs aria-label -->
<button aria-label="Close dialog">
  <svg aria-hidden="true">...</svg>
</button>

<!-- Decorative image -->
<img src="decoration.png" alt="" aria-hidden="true">
```

Flag icon-only button with no accessible name. Flag SVG left visible to AT when visible text already sits alongside it.

## Forms

- Every input needs `<label>` with matching `for`
- Group related inputs: `<fieldset>` + `<legend>`
- Associate errors via `aria-describedby`
- On submit with errors: focus moves to first error field
- Never rely on color alone for errors
- Required fields: `required` attribute, not just `aria-required`

## Landmark and Region Overuse

Landmarks help screen reader users navigate between major page sections. Too many = noise, reduced usefulness. Per W3C APG: `region` landmark is for content "sufficiently important for users to be able to navigate to the section." Most `<section>` elements on a typical long page should NOT be region landmarks — heading nav (H key) already provides section discovery.

### When `<section>` Creates a Region Landmark

`<section>` with `aria-label` or `aria-labelledby` creates a `region` landmark. Without a label: just a generic grouping element, no landmark role. Only label sections representing genuinely important navigable destinations beyond what heading nav provides.

### `aria-labelledby` vs `aria-label` on Sections with Headings

APG: "If an area begins with a heading element (e.g. h1-h6) it can be used as the label for the area using the `aria-labelledby` attribute. If an area requires a label and does not have a heading element, provide a label using the `aria-label` attribute."

Means:

1. **Section has heading → prefer `aria-labelledby` pointing to heading over `aria-label`.** Links landmark name to visible heading text, one consistent identity instead of two separate announcements.

2. **Never use `aria-label` with text differing from section's heading.** Landmark nav hears `aria-label` text; heading nav hears heading text. Differ → section appears to be two different things.

3. **`aria-label` duplicating heading text exactly → redundant, use `aria-labelledby` instead.** Same string in two places = maintenance burden, drift risk.

```html
<!-- BAD: aria-label says "Upcoming workshop" but heading says "GIT Going with GitHub" -->
<!-- Screen reader landmark nav: "Upcoming workshop region" -->
<!-- Screen reader heading nav: "GIT Going with GitHub, heading level 2" -->
<!-- User thinks these are two different sections -->
<section aria-label="Upcoming workshop">
  <h2>GIT Going with GitHub</h2>
</section>

<!-- GOOD: aria-labelledby links to the heading, one consistent name -->
<section aria-labelledby="workshop-heading">
  <h2 id="workshop-heading">GIT Going with GitHub</h2>
</section>

<!-- ALSO GOOD: no landmark at all if heading navigation is sufficient -->
<section>
  <h2>GIT Going with GitHub</h2>
</section>
```

### What to Flag

- `<section aria-label="X">` also has a heading — should use `aria-labelledby` pointing to heading instead
- `<section aria-label="X">` where "X" differs from section's heading — confuses landmark vs heading nav
- `<section aria-label="...">` wrapping decorative content, stats bars, banners, or content not warranting landmark nav
- `role="region"` on code snippets, install command blocks, demo panels, or other non-navigable content already inside `<main>` — not navigable destinations, heading nav (H key) already provides access
- Promotional/ephemeral content (event banners, announcements, CTAs) wrapped in region landmark — not page structure, transient content, shouldn't pollute landmark list
- Pages exceeding canonical landmark count. Typical single-page informational site needs only 5-6: banner, navigation(s), main, contentinfo. Add region landmarks only for genuinely important navigable sections (e.g. search results panel, dashboard sidebar)
- `<div>` given `role="region"` for non-navigable content
- Fixes changing `<div>` to `<section>` just to satisfy "aria-label requires a role" when real fix is removing the `aria-label`
- Nested `<section aria-label>` inside parent section already covering same content with heading — inner section rarely needs own landmark

### `role="region"` Antipatterns

Common misuses. Content inside `<main>` already in a landmark — adding `role="region"` to subdivisions = unnecessary clutter:

```html
<!-- BAD: install commands are not navigable destinations -->
<div class="install-block" role="region" aria-label="macOS install command">
  <pre><code>curl -sSL ... | bash</code></pre>
</div>

<!-- BAD: code demo panels are not navigable destinations -->
<div class="demo-panel" role="region" aria-label="Inaccessible code example">
  <h3>Before</h3>
  <pre><code>...</code></pre>
</div>

<!-- GOOD: remove role and aria-label, let heading navigation handle discovery -->
<div class="install-block">
  <pre><code>curl -sSL ... | bash</code></pre>
</div>

<div class="demo-panel">
  <h3>Before</h3>
  <pre><code>...</code></pre>
</div>
```

### The Fix for Unnecessary Regions

`<section>` has `aria-label` but content isn't a major navigable section:

```html
<!-- BEFORE: unnecessary region landmark -->
<section class="stats-bar" aria-label="Project statistics">
  ...
</section>

<!-- AFTER: no landmark clutter -->
<div class="stats-bar">
  ...
</div>
```

Fix: remove `aria-label`, change to `<div>`; or keep `<section>` without `aria-label` if grouping still makes semantic sense. Suggestion for human to apply, not automatic.

## Accessible Names and Descriptions

Per W3C APG "Providing Accessible Names and Descriptions" guide — cardinal rules for naming interactive elements.

### Five Cardinal Rules

1. **Heed warnings:** never use naming technique ARIA spec warns against for that role
2. **Prefer visible text:** source name from visible text (native HTML labels, `aria-labelledby`) over invisible text (`aria-label`) whenever possible
3. **Prefer native techniques:** native HTML labeling (`<label>`, `<caption>`, `<legend>`, `<figcaption>`) before ARIA naming
4. **Avoid browser fallback:** don't rely on `title` or `placeholder` as accessible name — browsers use as fallbacks but unreliable, often invisible
5. **Compose brief useful names:** concise (1-3 words ideally), describe function not form, start with distinguishing word, never include role name

### Name Calculation Precedence

Browsers compute accessible name in this order (first match wins):

1. `aria-labelledby` (references other visible elements — highest priority)
2. `aria-label` (hidden string attribute)
3. Native HTML mechanisms (`<label>`, `<caption>`, `<legend>`, `alt`, `<title>` inside SVG)
4. Child text content (roles allowing naming from contents: button, link, tab, menuitem)
5. `title` attribute (fallback — avoid relying on it)
6. `placeholder` (last resort — never rely on it)

### `aria-label` Hides Descendant Content

`aria-label` on element whose role supports "naming from contents" (`heading`, `button`, `link`) **replaces** all descendant text content for screen readers. Descendants become invisible to AT.

```html
<!-- BAD: screen reader says "Widget usage" only, descendant content is hidden -->
<h2 aria-label="Widget usage">
  <span>37</span>
  <span>widgets deployed this month</span>
</h2>

<!-- GOOD: screen reader reads the actual content -->
<h2>37 widgets deployed this month</h2>
```

Don't use `aria-label` on headings, paragraphs, or other content containers — only on interactive elements needing a name different from visible text.

### Composing Effective Names

- **Function, not form:** "Submit" not "Green button at bottom". "Close" not "X icon"
- **Distinguishing word first:** "Delete account" not "Account deletion action"
- **Brief:** 1-3 words when possible. "Save" or "Save draft" — not "Click this button to save your draft document to the server"
- **No role name:** "Close" not "Close button" (screen reader already announces "button")
- **Unique:** same name, different functions confuses screen reader users. "Edit profile" and "Edit preferences" not two "Edit" buttons
- **Capital letter:** start capitalized for pronunciation consistency

### Description Techniques

Descriptions supplement info beyond the name:

- `aria-describedby` — references visible elements for additional context
- `aria-description` — inline description string (newer, less supported)
- `title` — tooltip text, used as description if name comes from elsewhere

```html
<button aria-label="Delete" aria-describedby="delete-warning">
  <svg aria-hidden="true">...</svg>
</button>
<p id="delete-warning" class="visually-hidden">This action cannot be undone</p>
```

## Validation Checklist

When reviewing any component, check:

1. Every interactive element has accessible name?
2. ARIA roles used only where native HTML can't express semantics?
3. ARIA states (`aria-expanded`, `aria-selected`, `aria-checked`) updated dynamically on state change?
4. `aria-controls`/`aria-labelledby` point to valid, existing IDs?
5. Live regions present, correct politeness level?
6. Focus managed correctly (modals trap focus, dialogs return focus)?
7. Decorative elements hidden from AT?
8. `<section>` elements with `aria-label` reserved for major navigable content (not decorative sections, stats bars, banners)?
9. Reasonable number of landmarks? Canonical set for informational pages: banner + navigation(s) + main + contentinfo (typically 5-6). Region landmarks rare additions.
10. `<section>` has both `aria-label` and heading — does `aria-label` text match heading? (Yes → flag switch to `aria-labelledby` pointing to heading. No → mismatch is a bug.)
11. `<section aria-label>` nested inside parent sections already providing heading-based nav for same content?
12. `role="region"` on code blocks, install snippets, demo panels, promotional banners? Flag for removal — not navigable destinations.
13. Will screen reader announce this component sensibly?

These checks are findings for human to confirm/act on. Never applied as automatic fixes.
