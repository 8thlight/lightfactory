# Contrast and Visual Accessibility Reference

Checklist: color contrast, focus indicators, visual accessibility. Review agent reads this when diff shows relevant pattern (color values, CSS/theme changes, focus styles, animation, `prefers-*` queries). Not an agent itself, no tools, no autonomous action — informs findings the review agent reports for human validation.

<!-- Adapted from Community-Access/accessibility-agents, claude-code-plugin/agents/contrast-master.md, upstream commit 0872b4a, copied 2026-07-10 -->
<!-- Text compressed with the caveman skill to reduce token load -->

## Authoritative Sources

- **WCAG 1.4.3 Contrast (Minimum)** — <https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html>
- **WCAG 1.4.11 Non-text Contrast** — <https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast.html>
- **WCAG 2.4.13 Focus Appearance** — <https://www.w3.org/WAI/WCAG22/Understanding/focus-appearance.html>
- **WebAIM Contrast Checker** — <https://webaim.org/resources/contrastchecker/>
- **CSS Color Module** — <https://www.w3.org/TR/css-color/>

## Scope

Everything visual affecting readability/perception:

- Text color contrast ratios
- UI component contrast (borders, icons, focus indicators)
- Color-only information (status indicators, errors, charts)
- Dark mode and theme implementation
- Focus indicator visibility
- Animation and motion safety
- User preference media queries (`prefers-*` and `forced-colors`)

## A Note on Contrast Findings

Per team decision: contrast findings always framed as **"may be insufficient — verify with a contrast checker / discuss with the designer,"** never a hard failure or instruction to change design. Ratios can't always be measured precisely from a diff (variables, dynamic theming, gradients) — even a measured ratio is a signal to raise with a human, not a verdict to enforce. Never assert a combo "fails" — flag for discussion, suggest verification. Never instruct the design be changed; designer's intent takes precedence, fix belongs to reviewer/designer conversation.

## WCAG AA Contrast Ratios (Reference Thresholds)

Targets to check against when flagging for discussion — not automatic-fail thresholds.

### Text Contrast (4.5:1 target)

- Normal text (under 18px or under 14px bold): 4.5:1 against background
- Applies to all text incl. placeholders, captions, timestamps, secondary text
- "It's just a caption" isn't a reason to skip the check

### Large Text Contrast (3:1 target)

- Large text (18px+ or 14px+ bold): 3:1 against background
- Headings often qualify as large text — verify actual rendered size

### Non-Text Contrast (3:1 target)

- UI components: buttons, inputs, checkboxes, toggles, cards
- Component boundary should have 3:1 against adjacent colors
- Focus indicators: 3:1 against both component and surrounding background
- Icons conveying meaning (not decorative) need 3:1

## How to Check Contrast

WCAG contrast ratio formula, for estimating whether a combo is worth flagging:

```python
import sys

def luminance(r, g, b):
    vals = []
    for v in [r, g, b]:
        v = v / 255.0
        vals.append(v / 12.92 if v <= 0.04045 else ((v + 0.055) / 1.055) ** 2.4)
    return 0.2126 * vals[0] + 0.7152 * vals[1] + 0.0722 * vals[2]

def contrast(hex1, hex2):
    r1, g1, b1 = int(hex1[1:3],16), int(hex1[3:5],16), int(hex1[5:7],16)
    r2, g2, b2 = int(hex2[1:3],16), int(hex2[3:5],16), int(hex2[5:7],16)
    l1, l2 = luminance(r1,g1,b1), luminance(r2,g2,b2)
    lighter, darker = max(l1,l2), min(l1,l2)
    return (lighter + 0.05) / (darker + 0.05)

fg = sys.argv[1]
bg = sys.argv[2]
ratio = contrast(fg, bg)
status = 'LIKELY OK' if ratio >= 4.5 else ('LARGE TEXT ONLY' if ratio >= 3.0 else 'WORTH FLAGGING')
print(f'{ratio:.2f}:1 -- {status}')
```

When diff introduces/changes color values: extract from CSS/Tailwind, estimate ratio for each changed text-on-background combo. Report as discussion point, not verdict.

## Color Independence

Info shouldn't depend on color alone. Every color-coded element benefits from a secondary indicator — flag when missing.

### Status Indicators

```html
<!-- Worth a note: color only -->
<span class="text-red-500">Error</span>
<span class="text-green-500">Success</span>

<!-- Better: color plus text/icon -->
<span class="text-red-500">
  <svg aria-hidden="true"><!-- X icon --></svg>
  Error: Invalid email address
</span>
<span class="text-green-500">
  <svg aria-hidden="true"><!-- Check icon --></svg>
  Success: Changes saved
</span>
```

### Form Errors

- Red border alone may not be enough — check for accompanying text
- Error text via `aria-describedby` is more robust
- Icon or prefix ("Error:") helps
- Focus moving to first error field: good pattern to look for

### Charts and Data Visualization

- Patterns, shapes, labels alongside color are more robust than color alone
- Direct labels on data points more robust than color-coded legends
- Color-coded legend → suggest pattern fills or distinct markers

### Links

- Links in body text should be visually distinct beyond color
- Underline is most reliable indicator
- If not underlined: look for 3:1 contrast against surrounding text AND non-color change on hover/focus

## Focus Indicators

Every interactive element needs visible focus indicator — flag if missing/removed.

### What to Check

- Focus indicator contrast against adjacent colors (target 3:1)
- Visibility on both light and dark backgrounds
- Outline thickness (2px reasonable minimum)
- `outline: none`/`outline: 0` without alternative — flag regardless of contrast, likely removes indicator entirely

### Reference Pattern

```css
:focus-visible {
  outline: 2px solid #005fcc;
  outline-offset: 2px;
}
```

- `:focus-visible` (not `:focus`) avoids outlines on mouse click
- `outline-offset` prevents outline overlapping content
- Check against every background color used in changed component

### Dark Mode Focus

- Light focus indicator on dark backgrounds
- Double-ring technique: robust pattern for universal visibility:

```css
:focus-visible {
  outline: 2px solid #ffffff;
  box-shadow: 0 0 0 4px #000000;
}
```

## Dark Mode

When diff touches dark mode/theming:

1. Check each text-on-background combo in both themes
2. Inverting colors doesn't reliably preserve contrast — don't assume
3. Placeholder text often low-contrast in dark mode (gray on dark gray)
4. Borders visible on white may become invisible on dark backgrounds
5. Shadows that gave depth on light mode do nothing on dark — borders read more reliably
6. Re-check focus indicators in both themes

## Animation and Motion

- Check for `prefers-reduced-motion` support
- Flashing content (3 flashes/sec max, ideally zero): flag
- Controls to pause/stop/hide animation: good pattern to look for
- Auto-playing content without visible stop mechanism: flag

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

## User Preference Media Queries (`prefers-*`)

Respecting these OS-level preferences required for WCAG conformance.

### `prefers-reduced-motion` (WCAG 2.3.3)

- Loading spinners/meaning-carrying animations: usually better simplified (crossfade not slide) than removed entirely.
- Scroll-triggered animations, parallax, auto-advancing carousels should all disable under this preference.
- JS: check `window.matchMedia('(prefers-reduced-motion: reduce)').matches` before starting JS-driven animations.
- Frameworks: React `framer-motion` supports `reducedMotion="user"`. CSS-based animation libs should be wrapped in the media query.

```js
const prefersReducedMotion = window.matchMedia(
  '(prefers-reduced-motion: reduce)'
).matches;

if (!prefersReducedMotion) {
  element.animate([/* keyframes */], { duration: 300 });
}
```

### `prefers-contrast` (WCAG 1.4.11)

Users needing higher contrast set this in OS (macOS "Increase contrast", Windows "Contrast themes"). Check it's respected.

Values: `more` | `less` | `custom` | `no-preference`

```css
/* Increase border and text contrast for users who request it */
@media (prefers-contrast: more) {
  :root {
    --border-color: #000000;
    --text-secondary: #1a1a1a; /* Upgrade from gray to near-black */
    --bg-subtle: #f5f5f5;      /* Lighten subtle backgrounds */
  }

  /* Make borders more prominent */
  button, input, select, textarea {
    border: 2px solid #000000;
  }

  /* Remove semi-transparent overlays */
  .overlay {
    background-color: #000000;
    opacity: 1;
  }
}

/* Some users prefer lower contrast (e.g., light sensitivity) */
@media (prefers-contrast: less) {
  :root {
    --text-primary: #333333;
    --bg-primary: #f0f0f0;
  }
}
```

Worth checking:

- `prefers-contrast: more` — subtle grays, thin borders, transparency: candidates to flag
- `prefers-contrast: less` — softened black-on-white fine as long as it doesn't drop below ~4.5:1 for text (flag for discussion if close)
- Semi-transparent backgrounds (`rgba()`, `opacity < 1`) becoming opaque under `more`: good pattern
- Gradient text and low-contrast placeholder text: common gaps under `more`

### `prefers-color-scheme` (WCAG 1.4.3, 1.4.11)

Dark mode is a preference, not just a design trend — some users depend on it for light sensitivity, migraines, low vision.

```css
/* Light mode defaults */
:root {
  --bg: #ffffff;
  --text: #1a1a1a;
  --link: #0066cc;
}

/* Dark mode overrides */
@media (prefers-color-scheme: dark) {
  :root {
    --bg: #121212;
    --text: #e0e0e0;
    --link: #6db3f2;
  }
}
```

Worth checking:

- Every contrast ratio re-checked in dark mode — inverting colors doesn't preserve ratios
- Dark mode backgrounds not pure black (`#000000`) — `#121212` to `#1e1e1e` reduces halation for astigmatism
- Pure white text on dark backgrounds for body text: common over-correction — `#e0e0e0` to `#f0f0f0` gentler
- Shadows invisible on dark backgrounds — borders/lighter backgrounds read better for elevation
- Status colors (red, green, amber) often need different shades in dark mode to maintain contrast
- Test both OS-level dark mode and any in-app theme toggle

### `forced-colors` (Windows High Contrast / Contrast Themes)

Windows High Contrast Mode overrides all colors with system-defined palette. Distinct from `prefers-contrast: more` — browser applies `forced-colors: active` and replaces colors entirely.

```css
@media (forced-colors: active) {
  /* The browser replaces your colors, but layout may need fixing */

  /* Use system colors for intentional styling */
  .custom-button {
    border: 2px solid ButtonText;
    background: ButtonFace;
    color: ButtonText;
  }

  /* SVG icons may become invisible - use currentColor */
  svg {
    fill: currentColor;
  }

  /* Decorative backgrounds/gradients are removed - use borders instead */
  .card {
    border: 1px solid CanvasText;
  }

  /* Ensure custom checkboxes/radios remain visible */
  input[type="checkbox"]::before {
    forced-color-adjust: none; /* Only if you handle all states manually */
  }
}
```

System color keywords for `forced-colors: active`:

- `Canvas` - page background
- `CanvasText` - page text
- `LinkText` - link color
- `VisitedText` - visited link
- `ActiveText` - active link
- `ButtonFace` - button background
- `ButtonText` - button text
- `Field` - input background
- `FieldText` - input text
- `Highlight` - selected item background
- `HighlightText` - selected item text
- `GrayText` - disabled text
- `Mark` / `MarkText` - highlighted (find-on-page) text

Worth checking:

- `forced-color-adjust: none` applied globally: flag — should only apply to specific elements where every color state is manually managed
- Custom UI controls built from `<div>`/`<span>` often become invisible — semantic HTML (`<button>`, `<input>`) fares better
- Background images used for icons disappear — inline SVGs with `fill: currentColor` fare better
- CSS gradients vanish — if gradient conveys info, suggest text/border alternative
- Reliable verification: test in Windows with at least two contrast themes (e.g., "High Contrast Black" and "High Contrast White")

### `prefers-reduced-transparency` (WCAG 1.4.11)

Some users find transparent/translucent backgrounds hard to read against.

```css
@media (prefers-reduced-transparency: reduce) {
  .modal-backdrop {
    background-color: #000000; /* Replace rgba(0,0,0,0.5) */
  }

  .frosted-glass {
    backdrop-filter: none;
    background-color: var(--bg);
  }

  .tooltip {
    background-color: #333333;
    /* Remove any opacity or backdrop-filter */
  }
}
```

### Combined Preference Patterns

Users may set multiple preferences at once. Worth checking combos:

```css
/* High contrast + dark mode */
@media (prefers-color-scheme: dark) and (prefers-contrast: more) {
  :root {
    --bg: #000000;
    --text: #ffffff;
    --border: #ffffff;
  }
}

/* Reduced motion + dark mode */
@media (prefers-color-scheme: dark) and (prefers-reduced-motion: reduce) {
  /* Dark mode without transitions */
}
```

### JavaScript Detection

All `prefers-*` queries readable/watchable in JS:

```js
// Check current preference
const darkMode = window.matchMedia('(prefers-color-scheme: dark)').matches;
const highContrast = window.matchMedia('(prefers-contrast: more)').matches;
const reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
const forcedColors = window.matchMedia('(forced-colors: active)').matches;

// Watch for changes (user can toggle mid-session)
window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (e) => {
  document.documentElement.classList.toggle('dark', e.matches);
});
```

## WCAG 2.2 Visual Requirements

### Focus Appearance (2.4.13 -- Level AAA, recommended)

Defines what a *sufficient* focus indicator looks like. Though AAA, it's the authoritative spec for focus indicator quality — useful bar even at AA.

**Per W3C Understanding doc:**

- Focus indicator has minimum area of a **2px thick perimeter** of the focused component
- Indicator has **3:1 contrast** between focused and unfocused states (change-of-contrast test)
- Indicator not entirely obscured by author-created content

**Relationship to Non-Text Contrast (1.4.11):** Focus Appearance measures the *change between* focused and unfocused states. Non-Text Contrast measures indicator contrast *against adjacent colors within* a single state. Both worth checking.

**C40 Two-Color Focus Technique:**

```css
/* Two concentric outlines ensure visibility on any background */
:focus-visible {
  outline: 2px solid #000000;      /* Dark inner ring */
  outline-offset: 2px;
  box-shadow: 0 0 0 4px #ffffff;   /* Light outer ring */
}
```

**Inset focus indicators:** Inset (inner) outline should be thicker than 2px — reduces component's visible area instead of adding to it. 3px+ reasonable minimum for inset indicators.

### Target Size (2.5.8 -- Level AA)

Interactive targets should be at least **24x24 CSS pixels**, or have sufficient spacing from adjacent targets so a 24px diameter circle centered on each target doesn't overlap another target.

```css
/* Ensure small targets like icon buttons meet minimum size */
.icon-button {
  min-width: 24px;
  min-height: 24px;
}

/* More comfortable: 44x44px touch targets (per WCAG 2.5.5 Level AAA) */
.touch-target {
  min-width: 44px;
  min-height: 44px;
}
```

**Exceptions (per W3C Understanding doc):**

- **Spacing exception:** Targets smaller than 24px pass if sufficient spacing around them (24px circle test passes)
- **Inline:** Targets within a sentence/paragraph of text (underlined links in body copy)
- **User agent default:** Unmodified browser-default controls
- **Essential:** A specific presentation is legally or functionally essential

**What to flag:**

- Icon-only buttons under 24x24px without spacing compensation
- Dense button groups/toolbars where targets overlap the 24px circle
- Mobile nav items or filter chips under 24x24px

### Text Spacing (1.4.12 -- Level AA)

Content shouldn't clip or get lost when users override text spacing to these minimums:

- Line height: 1.5x font size
- Letter spacing: 0.12x font size
- Word spacing: 0.16x font size
- Paragraph spacing: 2x font size

```css
/* Test text spacing overrides -- content must remain readable */
p {
  line-height: 1.5 !important;
  letter-spacing: 0.12em !important;
  word-spacing: 0.16em !important;
  margin-bottom: 2em !important;
}
```

**What to flag:**

- Fixed-height containers with `overflow: hidden` that would clip expanded text
- CSS overriding `line-height` with absolute values (`line-height: 16px` instead of `line-height: 1.5`)
- Layouts that break when paragraph margins increase

### Content Reflow (1.4.10 -- Level AA)

Content should reflow to single column at 320 CSS pixels width (equivalent to 400% zoom on 1280px viewport) without horizontal scrolling.

**What to flag:**

- `min-width` or fixed `width` values preventing reflow below 320px
- Horizontal scroll appearing at 400% zoom
- Two-dimensional scrolling for content (tables and complex data viz exempt)
- `overflow: hidden` on viewport or main containers

## Tailwind-Specific Guidance

Tailwind classes worth double-checking on white backgrounds:

- `text-gray-400` (#9CA3AF) — ~2.85:1, worth flagging
- `text-gray-500` (#6B7280) — ~4.64:1, likely fine for normal text
- `text-gray-300` (#D1D5DB) — ~1.74:1, worth flagging

Tailwind classes worth double-checking on dark backgrounds (`bg-gray-900` #111827):

- `text-gray-500` (#6B7280) — ~3.41:1, worth flagging for normal text
- `text-gray-400` (#9CA3AF) — ~5.51:1, likely fine
- `text-gray-600` (#4B5563) — ~2.11:1, worth flagging

Tailwind color names don't guarantee compliance — verify rather than assume.

## Validation Checklist

1. Text elements ~4.5:1 contrast (or 3:1 large text) — flag any that look short, for discussion
2. UI components ~3:1 contrast against adjacent colors
3. No info conveyed by color alone
4. Focus indicators visible with contrast against adjacent colors (1.4.11)
5. Focus indicators vs 2.4.13 Focus Appearance: 2px perimeter minimum, contrast change between focused/unfocused
6. Links distinguishable from surrounding text without color
7. `prefers-reduced-motion` handled
8. Dark mode colors re-checked (not just inverted)
9. Placeholder text contrast worth a look
10. Disabled states still visually distinguishable (even if interaction blocked)
11. Error states use text and/or icons, not just red
12. `prefers-contrast: more` — subtle colors and transparency worth a look
13. `prefers-color-scheme: dark` — ratios worth re-verifying in dark mode
14. `forced-colors: active` — custom controls still visible? SVGs use `currentColor`?
15. `prefers-reduced-transparency` — frosty/translucent backgrounds have solid fallback?
16. Combined preferences considered (e.g., dark + high contrast)
17. Interactive targets meet 24x24 CSS pixel minimum (or sufficient spacing)
18. Content not clipped/lost with text spacing overrides (1.4.12)
19. Content reflows at 320px width without horizontal scrolling (1.4.10)

## Reporting Findings

When this reference surfaces a finding: report it, don't fix, don't assert failure. For contrast specifically: "may be insufficient — worth verifying with a contrast checker" or "worth discussing with the designer" — never present a color change as required. For focus indicators, keyboard-adjacent findings, and other non-color issues: state more directly (e.g., "focus indicator appears to be removed") — not subject to the same designer-intent framing as color choices. See `keyboard-navigation.md` for focus-management/tab-order concerns beyond visual indicator styling.
