# Accessibility Reference: Cognitive Load, Authentication, and Timeouts

> **Source repo:** Community-Access/accessibility-agents (https://github.com/Community-Access/accessibility-agents)
> **Upstream commit:** `a538edc9edfb98cdd8bae96d6b79542874b478f7` (main, 2026-11-07)
> **Retrieved:** 2026-11-09
> **License:** MIT, Copyright (c) 2026 Taylor Arndt
> **Upstream files:**
> - `skills/kb-cognitive-accessibility/SKILL.md`
> - `skills/forms-specialist/references/combobox-autocomplete-pattern.md` (the Accessible Authentication section)
>
> **Adapted:** condensed from 313 lines. Removed: severity scoring, the reading-level formula and syllable rules, code samples, and reviewer integration notes. Kept: the criteria, what to check, and the failure patterns. Criteria wording is new.

Read this when the feature has login or sign-up, multi-step input, a session timeout, or user-facing messages. Most of these checks are manual or have no axe rule, so the plan must carry them as out-of-repo evidence unless a test is written.

## What to look for in the codebase

- Login, password reset, and verification-code inputs. Look for `onpaste` handlers, blocked autofill, and CAPTCHA components.
- Multi-step flows that ask for the same data twice.
- Session expiry timers and auto-logout code.
- Error and help copy that lives in one place or is scattered through components.

## Authentication (3.3.8 AA, 3.3.9 AAA)

Authentication must not require a cognitive function test (memorizing, transcribing, solving a puzzle) unless an alternative exists.

- Never block paste in password fields, and never block password managers. Use `autocomplete="current-password"`, `new-password`, `username`, and `one-time-code` as they apply.
- Offer a show/hide password toggle.
- Offer an alternative where possible: passkeys, biometrics, social login, or an email magic link.
- A verification-code input must accept paste.
- A CAPTCHA that asks for transcription is a cognitive test, and an audio CAPTCHA that must be transcribed does not count as an alternative. Provide a non-cognitive alternative. Object-recognition CAPTCHAs pass at AA but not at AAA.
- A security question that needs exact recall fails.

## Redundant entry (3.3.7 A)

Information already given in the same session is not asked for again, except where it is security-essential (password confirmation) or may have gone stale (a new address versus the current one).

- Offer "same as shipping" on billing. Pre-fill name and email from earlier steps. Do not re-ask a date of birth.

## Timeouts (2.2.1 A)

- A session or form that expires warns at least 20 seconds before expiry, and lets the user extend it at least ten times or turn the limit off.
- Warn about data loss from inactivity at the start of a session (2.2.6 AAA).

## Errors and guidance

| Criterion | What to check |
|---|---|
| 3.3.1 A | The error is stated in text, not only by color. |
| 3.3.2 A | Format requirements and required fields are shown before the error, not only after. |
| 3.3.3 AA | The error suggests a correction where it is safe to do so. |
| 3.3.4 AA | Legal, financial, and data actions have a review, confirmation, or undo step. |

A usable error message names the field and the exact problem, says why, gives a specific example or format, and is neutral or supportive in tone. "Email must include @, for example name@company.com" passes. "Invalid input" and "You entered the wrong password" fail.

## Clarity and consistency

- Headings and labels describe their content (2.4.6 AA). "Section 1" and "Details" do not.
- Navigation keeps the same order across pages (3.2.3 AA). The same function has the same name everywhere (3.2.4 AA).
- Instructional text uses short sentences (about 25 words or fewer), the active voice, no double negatives, and one term per concept ("sign in" or "log in", not both).
- Moving or blinking content that lasts over 5 seconds has a pause or stop control (2.2.2 A). Nothing flashes more than three times a second (2.3.1 A).
- Reading level is advisory (3.1.5 AAA). Consumer content aims at grade 8 or below.

## Common failures

- Paste disabled on a password field.
- Transcription-only CAPTCHA.
- The same address entered on two steps.
- Session ends with no warning.
- Error shown only as a red border.
- "Search" on one page and "Find" on another for the same control.

## Criteria wording

| Criterion | Check |
|---|---|
| Password and code inputs accept paste and password-manager fill | `[auto]` |
| A step does not re-ask for data collected earlier in the same flow | `[auto]` |
| A session warning appears before expiry and offers to extend | `[auto]` |
| Each error states the problem in text and how to fix it | `[manual]` |
| Wording is plain, consistent, and free of unexplained jargon | `[manual]` |
| A person can complete the task without recalling data from another screen | `[manual]` |

## Questions for the research report

- Does the feature touch authentication, a timeout, or a multi-step form? If none, record "not applicable" for this file.
