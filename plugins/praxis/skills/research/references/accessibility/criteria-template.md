# Accessibility Reference: Acceptance Criteria and Testing Split

> **Source repo:** Community-Access/accessibility-agents (https://github.com/Community-Access/accessibility-agents)
> **Upstream commit:** `a538edc9edfb98cdd8bae96d6b79542874b478f7` (main, 2026-11-07)
> **Retrieved:** 2026-11-09
> **License:** MIT, Copyright (c) 2026 Taylor Arndt
> **Upstream files:**
> - `skills/kb-testing-strategy/SKILL.md` (acceptance criteria template, automated versus manual coverage, testing decision tree, screen reader matrix)
> - `mcp-server/server-core.js` (the `general` entry of the `GUIDELINES` constant)
>
> **Adapted:** the story template is reshaped into criteria the plan can place in a test spec. Removed: CI gate and regression sections, per-reader keystroke quick references, and the secondary browser list. Added: the `[auto]` and `[manual]` split and the evidence format, which are praxis conventions and not upstream content.

Read this once per UI feature, after the pattern files. It sets the baseline that applies to any UI, and how criteria are split so each lands in a test or in recorded evidence.

## Baseline for any UI work

- Native elements first: `<button>` for actions, `<a href>` for navigation. Do not build `<div role="button">`.
- One H1 per page, and no skipped heading levels.
- Meaningful images have descriptive `alt`. Decorative images have `alt=""`.
- `<html lang>` is set, and each page has a descriptive `<title>`.
- Text contrast is 4.5:1, or 3:1 for large text and UI components.
- Information is never carried by color alone.
- Motion respects `prefers-reduced-motion`.
- Text resizes to 200% without loss, and content reflows at 320 CSS px wide, about 400% zoom, without horizontal scrolling (1.4.4, 1.4.10).

## Criteria shape

Write each criterion as a testable sentence about the outcome:

```text
Given [context],
When [an action by keyboard or screen reader],
Then [the accessible outcome].
```

Draw the outcomes from this list where they apply:

- The component has an accessible name and the right role.
- It can be reached and operated by keyboard (Tab, Enter, Space, Escape, arrows as the pattern requires).
- Focus is visible.
- State changes are exposed (`aria-expanded`, `aria-selected`, `aria-checked`).
- Errors are associated with their inputs.

## Automated versus manual

Tag every criterion. A clean automated scan is a floor, not a pass. Most WCAG 2.2 additions (2.4.11, 2.5.7, 3.2.6, 3.3.7, 3.3.8) have no axe rule.

| Automated tools catch | Needs a person |
|---|---|
| Missing alt text, form labels, `lang` | Alt text quality, label clarity |
| Computed color contrast | Contrast in context (gradients, images) |
| ARIA syntax errors, duplicate ids that ARIA references | Whether the role fits the interaction |
| Heading hierarchy violations | Whether heading text is meaningful |
| Empty links and buttons | Whether link and button text is descriptive |
| Missing table headers | Header association quality |
| Keyboard and focus order, when scripted | Reading order, announcement correctness |

- `[auto]` criteria go into the test spec of the phase that delivers the feature, written as role-based, keyboard, or axe assertions.
- `[manual]` criteria become out-of-repo evidence: name what a person must check, with which tool, and who owns it.

## Manual evidence format

When a criterion is `[manual]`, record:

- **What to check:** the observable result ("the error is announced once after submit").
- **How:** keyboard only, screen reader and browser pair, or a zoom level.
- **Minimum screen reader coverage:** NVDA with Firefox and Chrome, JAWS with Chrome, and VoiceOver with Safari on macOS and iOS. TalkBack with Chrome on Android is advisory.

## What to test when

```text
New component or page: full coverage.
  axe or Lighthouse scan, keyboard-only pass,
  screen reader pass (NVDA and VoiceOver at minimum), 200% zoom check.
Existing component changed:
  colors or styling      -> contrast check and visual review
  interactive behavior   -> keyboard and screen reader
  content or text        -> screen reader announcement
  layout or order        -> reading order and focus order
  dependency update      -> regression scan
```

## Questions for the research report

- Which target WCAG level does the project state? Do not assume one. If none is stated, say so.
- Which of axe, Playwright, or Testing Library does the project already run, and in which tier?
- Which criteria in this feature are `[manual]`, and who owns the evidence?
