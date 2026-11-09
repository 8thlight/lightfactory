# Color, Contrast, Focus Appearance, Size, and Motion

> Provenance and license: `PROVENANCE.md`, `LICENSE-community-access.md`.

Read this when the feature adds or changes colors, themes, focus styles, small controls, animation, tooltips, or layout that must survive zoom.

## What to look for in the codebase

- Design tokens and the theme setup (light, dark, high contrast), and whether dark values were checked or only inverted.
- `outline: none` or `outline: 0`, and what replaces it.
- Fixed pixel heights with `overflow: hidden`, `line-height` set in `px`, and `min-width` or `width` that blocks reflow.
- Any `@media` block for `prefers-reduced-motion`, `prefers-contrast`, `prefers-color-scheme`, `forced-colors`, or `prefers-reduced-transparency`.
- Icon buttons and chips, and their pixel sizes.
- Sticky headers, footers, and banners that can cover a focused element.

## Contrast and color

- Text is 4.5:1 against its background, or 3:1 for large text (1.4.3). UI components and their states are 3:1 against adjacent colors (1.4.11).
- Placeholder text meets the contrast requirement. Disabled controls are exempt from contrast, but they should stay visible and say why they are disabled.
- Information is never carried by color alone (1.4.1). A red border alone is not an error. Add text, an icon, or a prefix. Charts use patterns, shapes, or labels as well (see `data-visualization.md`).
- Links inside body text are distinguishable beyond color. An underline is the most reliable. Without one, the link needs 3:1 against the surrounding text and a non-color change on hover and focus.
- Dark mode is a separate palette. Re-check every ratio, because inverting does not preserve them. Avoid pure black backgrounds and pure white body text (upstream suggests about `#121212` to `#1e1e1e` and `#e0e0e0` to `#f0f0f0`). Status colors often need different shades.

## Focus appearance and size

- Focus is visible (2.4.7). A sticky header or banner never completely hides the focused element (2.4.11, AA). At AAA, no part of it is hidden (2.4.12).
- A strong indicator (2.4.13, AAA) has an area at least as large as a 2 CSS px perimeter of the unfocused component, with 3:1 contrast between its focused and unfocused pixels. An inset outline must be thicker than 2px (use 3px or more). A two-color ring (light inner, dark outer) stays visible on any background.
- Pointer targets are at least 24 by 24 CSS px (2.5.8, AA), or pass the spacing test (a 24px circle centered on the target does not touch another target). Exceptions: an equivalent control that is big enough, inline targets in text, targets sized by the browser, and essential or legally required presentations. 44 by 44 is the AAA value (2.5.5).
- Content shown on hover or focus (tooltips, popups) is dismissible (Escape), hoverable (the pointer can move onto it), and persistent (1.4.13).

## Text and layout

- Text spacing overrides must not clip or lose content (1.4.12): line height 1.5 times the font size, letter spacing 0.12, word spacing 0.16, paragraph spacing 2. Avoid fixed-height text containers and absolute `line-height` values.
- Content reflows into one column at 320 CSS px wide, about 400% zoom, with no horizontal scrolling (1.4.10). Tables and complex data visualizations are exempt. Resize to 200% is in `criteria-template.md`.

## User preferences

WCAG does not require honoring these queries as such, but they are the practical way to meet several criteria, such as 2.3.3 Animation from Interactions (AAA).

- **Reduced motion:** simplify meaningful animation (crossfade instead of slide) instead of removing it, such as a loading spinner. Disable parallax, scroll-triggered animation, and auto-advancing carousels. Check the preference in JavaScript before starting JS-driven animation.
- **More contrast:** replace subtle grays and semi-transparent overlays with opaque, higher-contrast values and heavier borders. Under less contrast, never drop text below 4.5:1.
- **Color scheme:** see dark mode above. Test the OS setting and any in-app toggle.
- **Forced colors** (Windows Contrast Themes): the browser replaces your colors with a system palette. Custom controls built from `div`s often vanish, so use semantic elements. Icons and SVG use `currentColor`. Background-image icons and gradients disappear, so give information a border or text alternative. Do not set `forced-color-adjust: none` globally. Test at least one dark and one light theme.
- **Reduced transparency:** give translucent and frosted backgrounds a solid fallback.
- Handle combinations, such as dark with more contrast.

## Common failures

- Focus outline removed with no replacement.
- A sticky header that covers the focused field.
- Meaning carried by color alone, in status text, errors, links, or charts.
- Dark theme made by inversion with ratios never re-checked.
- Icon buttons smaller than 24 px with no spacing.
- Fixed-height text boxes that clip under text spacing overrides.
- Layout that scrolls sideways at 400% zoom.
- Animation that ignores the reduced-motion setting.

## Criteria wording

| Criterion | Check |
|---|---|
| Text and UI colors meet the contrast ratios in both light and dark themes | `[auto]` |
| Pointer targets are at least 24 by 24 CSS px or pass the spacing test | `[auto]` |
| With reduced motion set, the animation is removed or simplified | `[auto]` |
| No element's focus indicator is removed without a replacement | `[auto]` |
| Information shown by color also has text, an icon, or a pattern | `[manual]` |
| A focused element is never hidden by sticky content | `[manual]` |
| With text spacing overrides applied, no content is clipped or lost | `[manual]` |
| At 400% zoom (320 CSS px), content reflows without horizontal scrolling | `[manual]` |
| In a forced-colors theme, every control and icon is still visible | `[manual]` |

## Questions for the research report

- Does the project have a token or theme system that already encodes contrast, and was it checked?
- Which preference queries does the codebase already honor?
