# Provenance

For maintainers. The research accessibility agent does not read this file. This file records where the adapted text came from. Links to standards, specs, platform docs, and laws for the agent are in `standards-and-docs.md`.

Every reference file here except `INDEX.md`, `README.md`, `PROVENANCE.md`, `LICENSE-community-access.md`, and `standards-and-docs.md` is an adaptation of material from Community-Access/accessibility-agents (https://github.com/Community-Access/accessibility-agents). The upstream license is MIT, and its text is in `LICENSE-community-access.md`. Criteria wording in each file is new and is not upstream content.

`tests/local/check-a11y-reference-drift.sh` reads this file. Keep each section's heading, `Upstream commit` line, and `Upstream files` list in the format below.

## citing-wcag.md

- Upstream commit: `a538edc9edfb98cdd8bae96d6b79542874b478f7` (main, 2026-11-07)
- Retrieved: 2026-11-09
- Upstream files:
  - `docs/standards/citation-policy.md`
  - `docs/standards/wcag.md`
  - `skills/wcag-guide/references/common-wcag-misconceptions.md`
- Adapted: the policy is rewritten for research reports, with no agent registry or fingerprint rules. Upstream's finding-score framing is removed. The default target (WCAG 2.2 AA, overridable by the project) is a praxis convention. The criteria list lives in `wcag-criteria-list.md`.

## wcag-criteria-list.md

- Upstream commit: `a538edc9edfb98cdd8bae96d6b79542874b478f7` (main, 2026-11-07)
- Retrieved: 2026-11-09
- Upstream files:
  - `skills/a11y-core/schemas/wcag22-criteria.json`
- Adapted: a markdown table of the JSON, with names and levels unchanged, split out of `citing-wcag.md` so the rules part loads without the list. The JSON states it was verified against the 12 December 2024 Recommendation on 27 October 2026.

## cognitive.md

- Upstream commit: `a538edc9edfb98cdd8bae96d6b79542874b478f7` (main, 2026-11-07)
- Retrieved: 2026-11-09
- Upstream files:
  - `skills/kb-cognitive-accessibility/SKILL.md`
  - `skills/forms-specialist/references/combobox-autocomplete-pattern.md` (the Accessible Authentication section)
- Adapted: condensed from 313 lines. Removed: severity scoring, the reading-level formula and syllable rules, code samples, and reviewer integration notes. Kept: the criteria, what to check, and the failure patterns.

## composite-widgets.md

- Upstream commit: `a538edc9edfb98cdd8bae96d6b79542874b478f7` (main, 2026-11-07)
- Retrieved: 2026-11-09
- Upstream files:
  - `mcp-server/server-core.js` (the `tabs`, `accordion`, `carousel`, and `combobox` entries of the `GUIDELINES` constant)
  - `skills/forms-specialist/references/combobox-autocomplete-pattern.md`
  - `skills/keyboard-navigator/references/arrow-key-patterns.md` (menu item behavior)
- Adapted: the upstream has no dedicated file for tabs, accordion, carousel, or menu. The first three come from short summary entries and were expanded only where the combobox file or the APG statements it cites support it. Menu guidance here is limited to the arrow-key and disabled-item rules in the keyboard file. For anything beyond this, a research agent falls back to the W3C APG and says so.

## criteria-template.md

- Upstream commit: `a538edc9edfb98cdd8bae96d6b79542874b478f7` (main, 2026-11-07)
- Retrieved: 2026-11-09
- Upstream files:
  - `skills/kb-testing-strategy/SKILL.md` (acceptance criteria template, automated versus manual coverage, testing decision tree, screen reader matrix)
  - `mcp-server/server-core.js` (the `general` entry of the `GUIDELINES` constant)
- Adapted: the story template is reshaped into criteria the plan can place in a test spec. Removed: CI gate and regression sections, per-reader keystroke quick references, and the secondary browser list. Added: the `[auto]` and `[manual]` split and the optional manual check format, which are praxis conventions and not upstream content. Also added: three baseline pointers (focus visible, target size, error and result regions), each linking to the file that owns the full rule.

## data-visualization.md

- Upstream commit: `a538edc9edfb98cdd8bae96d6b79542874b478f7` (main, 2026-11-07)
- Retrieved: 2026-11-09
- Upstream files:
  - `skills/kb-data-visualization-accessibility/SKILL.md`
  - `skills/data-visualization-accessibility/SKILL.md`
- Adapted: reorganized for research. Removed: the HTML and JavaScript samples, the library code blocks, and reviewer output rules. Library notes are kept as one line each and were current at retrieval, so confirm against the project's installed version.

## dialogs.md

- Upstream commit: `a538edc9edfb98cdd8bae96d6b79542874b478f7` (main, 2026-11-07)
- Retrieved: 2026-11-09
- Upstream files:
  - `skills/modal-specialist/references/non-negotiable-rules.md`
- Adapted: reorganized for research (what to look for, requirements, failures, criteria wording). Code samples shortened to the structures a plan must name. The upstream MCP summary says focus always lands on the Close button. That conflicts with this file's source, so the scenario table in `dialogs.md` follows the source.

## forms.md

- Upstream commit: `a538edc9edfb98cdd8bae96d6b79542874b478f7` (main, 2026-11-07)
- Retrieved: 2026-11-09
- Upstream files:
  - `skills/forms-specialist/references/labels-the-foundation.md`
  - `skills/forms-specialist/references/validation-checklist.md`
  - `skills/forms-specialist/references/multi-step-forms-wizards.md`
- Adapted: reorganized for research (what to look for, requirements, failures, criteria wording). Reviewer output formats, severity rules, and framework fix code removed.

## images-and-names.md

- Upstream commit: `a538edc9edfb98cdd8bae96d6b79542874b478f7` (main, 2026-11-07)
- Retrieved: 2026-11-09
- Upstream files:
  - `skills/alt-text-headings/references/alternative-text-the-rules.md`
  - `skills/alt-text-headings/SKILL.md` (the `<picture>`, CSS background, form image button, and icon font sections)
  - `skills/alt-text-headings/references/video-and-audio.md` (the figure and figcaption section)
  - `skills/aria-specialist/references/landmark-and-region-overuse.md` (the Accessible Names and Descriptions section)
  - `skills/text-quality-reviewer/references/detection-rules.md`
- Adapted: merged three upstream areas (alt text, accessible names, bad-name detection) into one file for research. Detection rules are condensed to the patterns a person can grep for. Fix code and severity labels removed.

## internationalization.md

- Upstream commit: `a538edc9edfb98cdd8bae96d6b79542874b478f7` (main, 2026-11-07)
- Retrieved: 2026-11-09
- Upstream files:
  - `skills/i18n-accessibility/SKILL.md`
  - `skills/alt-text-headings/SKILL.md` (the Language Attributes section)
- Adapted: reorganized for research. Removed: the three-phase audit process and the output contract. This upstream source is short, so most of it is kept.

## keyboard-and-focus.md

- Upstream commit: `a538edc9edfb98cdd8bae96d6b79542874b478f7` (main, 2026-11-07)
- Retrieved: 2026-11-09
- Upstream files:
  - `skills/keyboard-navigator/references/arrow-key-patterns.md`
  - `skills/keyboard-navigator/references/tab-order.md`
  - `mcp-server/server-core.js` (the `navigation` entry of the `GUIDELINES` constant)
- Adapted: reorganized for research (what to look for, requirements, failures, criteria wording). Code samples removed except the one structure a plan must name.

## live-regions.md

- Upstream commit: `a538edc9edfb98cdd8bae96d6b79542874b478f7` (main, 2026-11-07)
- Retrieved: 2026-11-09
- Upstream files:
  - `skills/live-region-controller/references/politeness-levels.md`
- Adapted: condensed from 321 lines to the choices a plan must make (which role, when to announce, what not to do). Long code samples removed.

## media.md

- Upstream commit: `a538edc9edfb98cdd8bae96d6b79542874b478f7` (main, 2026-11-07)
- Retrieved: 2026-11-09
- Upstream files:
  - `skills/kb-media-accessibility/SKILL.md`
  - `skills/alt-text-headings/references/video-and-audio.md` (the Video and Audio section)
- Adapted: reorganized for research. Removed: caption file samples, HTML samples, the severity table, and reviewer output rules. Style-guide values are kept but labeled as such, because upstream states WCAG sets none of them.

## mobile.md

- Upstream commit: `a538edc9edfb98cdd8bae96d6b79542874b478f7` (main, 2026-11-07)
- Retrieved: 2026-11-09
- Upstream files:
  - `skills/kb-mobile-accessibility/SKILL.md` (the touch target table and the testing tool sections)
  - `skills/mobile-accessibility/SKILL.md` (the manual testing section)
  - `skills/mobile-accessibility/references/phase-1-react-native-and-expo-auditing.md` (touch targets, focus management, reading order, grouping, TalkBack and Switch Access)
  - `skills/wcag-guide/references/complete-wcag-2-2-aa-success-criteria-reference.md` (the 1.3.4, 2.5.1, 2.5.2, 2.5.4, 2.5.7, and 2.5.8 entries)
- Adapted: most upstream mobile material is API reference for React Native, SwiftUI, UIKit, and Compose (property names, role tables, fix code), and it is left out on purpose. What is kept here is the part that does not depend on a language or framework. When the project's stack is known, read the platform's own accessibility documentation for property names.

## structure-and-landmarks.md

- Upstream commit: `a538edc9edfb98cdd8bae96d6b79542874b478f7` (main, 2026-11-07)
- Retrieved: 2026-11-09
- Upstream files:
  - `skills/alt-text-headings/references/video-and-audio.md` (the Heading Structure section)
  - `skills/alt-text-headings/SKILL.md` (document outline, page titles, language, and landmark structure sections)
  - `skills/alt-text-headings/references/validation-checklist.md`
  - `skills/aria-specialist/references/landmark-and-region-overuse.md` (everything before the Accessible Names section)
- Adapted: reorganized for research (what to look for, requirements, failures, criteria wording). Markup examples removed except where a rule is easier to see than to state.

## tables.md

- Upstream commit: `a538edc9edfb98cdd8bae96d6b79542874b478f7` (main, 2026-11-07)
- Retrieved: 2026-11-09
- Upstream files:
  - `skills/tables-data-specialist/references/simple-data-tables.md`
  - `skills/tables-data-specialist/references/responsive-tables.md`
- Adapted: reorganized for research (what to look for, requirements, failures, criteria wording). Full markup examples reduced to the rules a plan must name.

## visual-and-motion.md

- Upstream commit: `a538edc9edfb98cdd8bae96d6b79542874b478f7` (main, 2026-11-07)
- Retrieved: 2026-11-09
- Upstream files:
  - `skills/contrast-master/references/color-independence.md`
  - `skills/contrast-master/references/user-preference-media-queries-prefers.md`
  - `skills/contrast-master/references/validation-checklist.md`
  - `skills/wcag-guide/references/complete-wcag-2-2-aa-success-criteria-reference.md` (the 1.4.13 Content on Hover or Focus entry)
  - `skills/wcag-guide/references/common-wcag-misconceptions.md` (the disabled controls entry)
- Adapted: condensed from about 400 lines. Removed: CSS and JavaScript samples, framework notes, and reviewer output rules. Kept: the numbers, the exceptions, and what to grep for.
