# Citing WCAG and Other Sources

> Provenance and license: `PROVENANCE.md`, `LICENSE-community-access.md`.

Read this before writing any accessibility finding or criterion that cites a standard. `wcag-criteria-list.md` is the check for an invented or mislabeled number.

## Source hierarchy

When sources disagree, the higher tier wins. State both and say which you followed. Links for each tier are in `standards-and-docs.md`.

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
3. **Cite the version the project is held to.** WCAG 2.2 does not replace 2.1, and several laws name an earlier version. Upstream lists ADA Title II and the HHS Section 504 rule (WCAG 2.1 AA), Section 508 (WCAG 2.0 AA), and EN 301 549 V3.2.1, the version cited for presumption of conformity in the EU (WCAG 2.1). Upstream's list was current at retrieval, so confirm it for the project. When a feature answers to one of those, cite that version. The default target is WCAG 2.2 Level AA. A project overrides it by stating a level or version (CLAUDE.md, a linked doc, the ticket, or a law it answers to). Record the target and where it came from, or "default (none stated)".
4. **ARIA version.** Cite WAI-ARIA 1.2. WAI-ARIA 1.3 is a Working Draft, so cite it as a draft.
5. **Criteria numbers come from `wcag-criteria-list.md`.** Do not cite `4.1.1 Parsing`. It was obsoleted in 2.2. Reports under WCAG 2.0 or 2.1 (Section 508, EN 301 549 V3.2.1) may still cite it, since errata treat it as always satisfied for HTML and XML.
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
