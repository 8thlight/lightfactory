# Accessibility Reference Index

Read this file first. It routes the agent to per-pattern reference files.

## How to use

1. Identify the interaction patterns in scope from the request and the UI files it touches.
2. Read every file whose row matches, not only the closest one, plus `criteria-template.md`.
3. Cite the file and the requirement when a finding or criterion comes from it.
4. If a pattern has no file here, use your own knowledge, cite the W3C APG or WCAG source, and say in the report or plan that no reference file existed.
5. `mobile.md` holds only platform-neutral principles. For property and role names on a specific toolkit, read that platform's accessibility documentation and say so in the report or plan.

| Pattern in scope | File |
|---|---|
| Inputs, selects, checkboxes, radios, search, multi-step forms | `forms.md` |
| Modal, alert dialog, drawer, sheet, popover | `dialogs.md` |
| Data tables, sortable tables, editable grids | `tables.md` |
| Toasts, status messages, loading, progress, chat, counters | `live-regions.md` |
| Tab order, arrow-key widgets, route changes, deletes | `keyboard-and-focus.md` |
| Tabs, accordion, carousel, combobox, menu | `composite-widgets.md` |
| Login, sign-up, timeouts, error copy, multi-step data entry | `cognitive.md` |
| Images, icons, SVGs, icon-only controls, names that come from data | `images-and-names.md` |
| New page, route, or layout: headings, titles, landmarks, skip link | `structure-and-landmarks.md` |
| Colors, themes, focus styles, small targets, zoom, animation, hover content | `visual-and-motion.md` |
| Charts, graphs, maps, dashboards | `data-visualization.md` |
| Video, audio, media players | `media.md` |
| More than one language, right-to-left, mixed-language content | `internationalization.md` |
| Native or cross-platform mobile app, or a phone-first web app | `mobile.md` |
| Every UI feature | `criteria-template.md` |
| Any finding or criterion that cites a standard | `citing-wcag.md` |
| Checking a WCAG SC number, name, or level before citing it | `wcag-criteria-list.md` |
| A reference file has no answer, or you need the exact wording of a spec, a tutorial, platform docs, or a law | `standards-and-docs.md` (links) |
