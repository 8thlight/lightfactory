# Accessibility Reference: Citing WCAG and Other Sources

> **Source repo:** Community-Access/accessibility-agents (https://github.com/Community-Access/accessibility-agents)
> **Upstream commit:** `a538edc9edfb98cdd8bae96d6b79542874b478f7` (main, 2026-11-07)
> **Retrieved:** 2026-11-09
> **License:** MIT, Copyright (c) 2026 Taylor Arndt
> **Upstream files:**
> - `docs/standards/citation-policy.md`
> - `docs/standards/wcag.md`
> - `skills/wcag-guide/references/common-wcag-misconceptions.md`
> - `skills/a11y-core/schemas/wcag22-criteria.json` (the criteria list below is generated from this file)
>
> **Adapted:** the policy is rewritten for research reports, with no agent registry or fingerprint rules. Upstream's AA-by-default and finding-score framing is removed, because praxis sets no default level. The criteria list is a markdown table of the JSON, with names and levels unchanged. The JSON states it was verified against the 12 December 2024 Recommendation on 27 October 2026.

Read this before writing any accessibility finding or criterion that cites a standard. The criteria list at the end is the check for an invented or mislabeled number.

## Source hierarchy

When sources disagree, the higher tier wins. State both and say which you followed.

| Tier | Source type | Examples |
|---|---|---|
| 1 | Normative specs | WCAG 2.2, WAI-ARIA 1.2, the HTML Living Standard |
| 2 | Informative guidance | Understanding WCAG 2.2, the ARIA Authoring Practices Guide |
| 3 | Platform vendor docs | MDN, Microsoft Learn, Apple Developer |
| 4 | Assistive technology vendor docs | NVDA, JAWS, VoiceOver |
| 5 | Established practitioner sources | Deque University, WebAIM, TPGi, Adrian Roselli |
| 6 | Government and legal | Section508.gov, Access Board, EN 301 549 |

## Rules

1. **No source, no claim.** If a recommendation has no published source, say: "This recommendation is based on practical accessibility testing experience and is not codified in a published standard."
2. **Cite inline** as a link on the criterion (`[WCAG 2.2 SC 1.4.3](https://www.w3.org/TR/WCAG22/#contrast-minimum)`) and list every source under the report's sources.
3. **Cite the version the project is held to.** WCAG 2.2 does not replace 2.1, and several laws name an earlier version. Upstream lists ADA Title II and the HHS Section 504 rule (WCAG 2.1 AA), Section 508 (WCAG 2.0 AA), and EN 301 549 V3.2.1, the version cited for presumption of conformity in the EU (WCAG 2.1). Upstream's list was current at retrieval, so confirm it for the project. When a feature answers to one of those, cite that version. Praxis sets no target level. Read it from project config, and say so when none is stated.
4. **ARIA version.** Cite WAI-ARIA 1.2. WAI-ARIA 1.3 is a Working Draft, so cite it as a draft.
5. **Criteria numbers come from the list below.** Do not cite `4.1.1 Parsing`. It was obsoleted in 2.2. Reports under WCAG 2.0 or 2.1 (Section 508, EN 301 549 V3.2.1) may still cite it, since errata treat it as always satisfied for HTML and XML.
6. **Level is not severity.** The level says what conformance requires. How bad a failure is for a person is a separate judgment.

## What automated checks cannot do

- Automated checks find a minority of barriers. A clean report is a floor, not conformance.
- In upstream's axe-core 4.14, only `target-size` (2.5.8) covers a new 2.2 criterion, and it runs only when the tag list includes `wcag22aa`. The full AA tag set is `wcag2a,wcag2aa,wcag21a,wcag21aa,wcag22aa`.
- The other new 2.2 criteria at A and AA (2.4.11, 2.5.7, 3.2.6, 3.3.7, 3.3.8) have no axe rule and need manual testing. Check the tool version in the project, because rule coverage changes.
- WCAG 3.0 is a draft, and APCA contrast is proposed but not part of any W3C standard. Do not treat either as normative.

## Misconceptions to avoid in findings

- "WCAG only applies to screen reader users." It covers visual, auditory, motor, and cognitive disabilities.
- "A clean axe report means we comply." Many criteria can only be judged by a person.
- "Alt text describes what the image looks like." It describes the image's purpose in context.
- "ARIA makes things accessible." Native HTML first. ARIA overrides semantics and adds no behavior, so `<div role="button">` still needs Enter, Space, tab order, and state handling.
- "We will add accessibility at the end." Upstream calls retrofitting far more expensive because it can force changes to DOM order, state, and structure. Its "10 to 100 times" figure is the upstream's own estimate and is not sourced there, so do not repeat it as a fact.
- "Disabled controls need no accessibility." They are exempt from contrast, but users still need to know they exist and why they are disabled.
- "We target mobile, so WCAG does not apply." It applies to all web content, and touch target size, orientation, and gesture alternatives matter more there.

## Questions for the research report

- Which WCAG version and level does the project, contract, or law require, and where is that written down?
- Which test tool version is installed, and which criteria does it have no rule for?

## Criteria list (WCAG 2.2, levels A and AA)

| SC | Name | Level |
|---|---|---|
| 1.1.1 | Non-text Content | A |
| 1.2.1 | Audio-only and Video-only (Prerecorded) | A |
| 1.2.2 | Captions (Prerecorded) | A |
| 1.2.3 | Audio Description or Media Alternative (Prerecorded) | A |
| 1.2.4 | Captions (Live) | AA |
| 1.2.5 | Audio Description (Prerecorded) | AA |
| 1.3.1 | Info and Relationships | A |
| 1.3.2 | Meaningful Sequence | A |
| 1.3.3 | Sensory Characteristics | A |
| 1.3.4 | Orientation | AA |
| 1.3.5 | Identify Input Purpose | AA |
| 1.4.1 | Use of Color | A |
| 1.4.2 | Audio Control | A |
| 1.4.3 | Contrast (Minimum) | AA |
| 1.4.4 | Resize Text | AA |
| 1.4.5 | Images of Text | AA |
| 1.4.10 | Reflow | AA |
| 1.4.11 | Non-text Contrast | AA |
| 1.4.12 | Text Spacing | AA |
| 1.4.13 | Content on Hover or Focus | AA |
| 2.1.1 | Keyboard | A |
| 2.1.2 | No Keyboard Trap | A |
| 2.1.4 | Character Key Shortcuts | A |
| 2.2.1 | Timing Adjustable | A |
| 2.2.2 | Pause, Stop, Hide | A |
| 2.3.1 | Three Flashes or Below Threshold | A |
| 2.4.1 | Bypass Blocks | A |
| 2.4.2 | Page Titled | A |
| 2.4.3 | Focus Order | A |
| 2.4.4 | Link Purpose (In Context) | A |
| 2.4.5 | Multiple Ways | AA |
| 2.4.6 | Headings and Labels | AA |
| 2.4.7 | Focus Visible | AA |
| 2.4.11 | Focus Not Obscured (Minimum) | AA |
| 2.5.1 | Pointer Gestures | A |
| 2.5.2 | Pointer Cancellation | A |
| 2.5.3 | Label in Name | A |
| 2.5.4 | Motion Actuation | A |
| 2.5.7 | Dragging Movements | AA |
| 2.5.8 | Target Size (Minimum) | AA |
| 3.1.1 | Language of Page | A |
| 3.1.2 | Language of Parts | AA |
| 3.2.1 | On Focus | A |
| 3.2.2 | On Input | A |
| 3.2.3 | Consistent Navigation | AA |
| 3.2.4 | Consistent Identification | AA |
| 3.2.6 | Consistent Help | A |
| 3.3.1 | Error Identification | A |
| 3.3.2 | Labels or Instructions | A |
| 3.3.3 | Error Suggestion | AA |
| 3.3.4 | Error Prevention (Legal, Financial, Data) | AA |
| 3.3.7 | Redundant Entry | A |
| 3.3.8 | Accessible Authentication (Minimum) | AA |
| 4.1.2 | Name, Role, Value | A |
| 4.1.3 | Status Messages | AA |

AAA criteria, for reference: 1.2.6 Sign Language (Prerecorded); 1.2.7 Extended Audio Description (Prerecorded); 1.2.8 Media Alternative (Prerecorded); 1.2.9 Audio-only (Live); 1.3.6 Identify Purpose; 1.4.6 Contrast (Enhanced); 1.4.7 Low or No Background Audio; 1.4.8 Visual Presentation; 1.4.9 Images of Text (No Exception); 2.1.3 Keyboard (No Exception); 2.2.3 No Timing; 2.2.4 Interruptions; 2.2.5 Re-authenticating; 2.2.6 Timeouts; 2.3.2 Three Flashes; 2.3.3 Animation from Interactions; 2.4.8 Location; 2.4.9 Link Purpose (Link Only); 2.4.10 Section Headings; 2.4.12 Focus Not Obscured (Enhanced); 2.4.13 Focus Appearance; 2.5.5 Target Size (Enhanced); 2.5.6 Concurrent Input Mechanisms; 3.1.3 Unusual Words; 3.1.4 Abbreviations; 3.1.5 Reading Level; 3.1.6 Pronunciation; 3.2.5 Change on Request; 3.3.5 Help; 3.3.6 Error Prevention (All); 3.3.9 Accessible Authentication (Enhanced).
