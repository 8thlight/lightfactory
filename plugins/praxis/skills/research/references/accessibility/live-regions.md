# Live Regions and Status Messages

> Provenance and license: `PROVENANCE.md`, `LICENSE-community-access.md`.

Read this when content changes without a page load: search or filter results, saved or failed states, toasts, loading and progress, chat, timers, and counters (WCAG 4.1.3 Status Messages).

## What to look for in the codebase

- An existing toast, snackbar, or notification component, and how it announces.
- Whether loading and result-count changes are announced anywhere today.
- Where messages are rendered: a region that already exists, or an element created at the moment of the message.

## Requirements

**Choose the role**

| Need | Use |
|---|---|
| Most updates (results count, saved, filters, pagination, sort change) | `aria-live="polite"` or `role="status"` |
| Errors and time-sensitive warnings only (session expired, connection lost) | `role="alert"` (assertive) |
| Sequential entries (chat, activity feed) | `role="log"` |
| Elapsed or remaining time | `role="timer"` (not announced by default, so announce milestones through a polite region) |
| Calculation or form output | `<output>` (implicit status) |

If unsure, use polite. Assertive interrupts the screen reader.

**Rules that decide whether it works**
- The live region must be in the DOM before its content changes. A region created and filled in one step is often not announced.
- Update the region's text. Replacing the element or its markup may not trigger an announcement.
- Keep messages short, and debounce rapid changes (500 ms or more).
- Never hide a live region with `display: none` or `visibility: hidden`. Use a visually hidden class.
- Never move focus to an alert or a toast. Toasts are polite, brief, and do not stack rapidly.
- Alerts present at page load are not announced. Avoid alerts that disappear before they can be read.
- Use `aria-atomic="true"` when context matters ("3 of 10 items"). Use `aria-busy` to suppress intermediate states during a batch update.
- For loading over about 2 seconds, announce that loading started and finished. For progress, announce milestones, not every percent.
- For chat or streaming output, do not make the streaming transcript live. Keep it `aria-live="off"` and announce each completed turn through a small visually hidden status region outside it.

## Common failures

- Content injected with a freshly created live region.
- Assertive used for routine updates.
- Focus moved to a toast.
- A region removed from the accessibility tree by `display: none`.
- Every keystroke or percent announced.
- Streaming text in a live log that re-reads whole entries.

## Criteria wording

| Criterion | Check |
|---|---|
| The status region exists in the DOM before the first update | `[auto]` |
| After the action, the region's text holds the expected message | `[auto]` |
| Focus does not move when a status or toast appears | `[auto]` |
| Rapid updates produce one announcement after the debounce | `[auto]` |
| A screen reader announces the message once, at the right time, without interrupting | `[manual]` |
| Announcement wording is short and says what changed | `[manual]` |

## Questions for the research report

- Does an announcer already exist that the feature can reuse?
- Which changes in the feature are results of a user action, and which arrive on their own?
