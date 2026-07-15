# Live Regions and Dynamic Content Announcements

Reference checklist for reviewing dynamic content updates (content changing without full page reload). Accessibility review agent reads this when diff shows patterns like search results, filters, notifications, toasts, loading states, AJAX responses, form submission feedback, counters, timers, chat messages, progress indicators. Not an agent itself — no tools, no autonomous action. Checklist for producing findings a human reviews and fixes.

<!-- Adapted from Community-Access/accessibility-agents, claude-code-plugin/agents/live-region-controller.md, upstream commit 0872b4a, copied 2026-07-10 -->
<!-- Text compressed with the caveman skill to reduce token load -->

## Authoritative Sources

- **ARIA Live Regions** — <https://www.w3.org/WAI/ARIA/apg/practices/>
- **ARIA Notifications** — <https://www.w3.org/WAI/ARIA/apg/patterns/alert/>
- **WCAG 4.1.3 Status Messages** — <https://www.w3.org/WAI/WCAG22/Understanding/status-messages.html>
- **aria-live attribute** — <https://www.w3.org/TR/wai-aria-1.2/#aria-live>

## Scope

Applies to any dynamic content update:

- Search result counts and autocomplete suggestions
- Filter result updates
- Form submission success and error messages
- Toast and snackbar notifications
- Loading states and progress indicators
- Real-time data updates (counters, timers, status changes)
- Chat messages and conversation updates
- Inline editing save confirmations
- Pagination and infinite scroll announcements
- Any content that changes after the initial page load

## Core Rule

Content changes visually, sighted user would notice → screen reader user must be informed. Question always: how urgently?

## Politeness Levels

### `aria-live="polite"` (use for almost everything)

Screen reader waits until it finishes current announcement, then reads update. Doesn't interrupt.

Use for:

- Search result counts ("5 results available")
- Filter updates ("Showing 12 of 48 items")
- Form success messages ("Changes saved")
- Content loaded ("Comments loaded")
- Sort order changes ("Sorted by date, newest first")
- Pagination ("Page 2 of 5")
- Non-critical status changes ("Connected", "Synced")

### `aria-live="assertive"` (use rarely)

Screen reader interrupts whatever it's currently reading to announce update immediately.

Use ONLY for:

- Error messages requiring immediate attention ("Session expired, please log in again")
- Critical alerts ("Unsaved changes will be lost")
- Time-sensitive warnings ("Connection lost")

Never use assertive for routine updates. Interrupting screen reader is disorienting. Default to polite when unsure.

### `role="status"`

Implicit `aria-live="polite"`. Use for frequently updating status indicators.

```html
<div role="status">5 items in cart</div>
```

### `role="alert"`

Implicit `aria-live="assertive"`. Use for error conditions.

**Per W3C APG Alert Pattern:**

- Alerts must not affect keyboard focus -- never move focus to an alert
- Alerts present in DOM at page load are NOT announced -- screen reader's own page-load announcement takes precedence
- Avoid alerts that auto-disappear: users may not have time to read (WCAG 2.2.3 No Timing, 2.2.4 Interruptions)
- Avoid firing alerts too frequently -- each interrupts user's current task

```html
<div role="alert">Payment failed. Please try again.</div>
```

### `role="log"`

Implicit `aria-live="polite"`. Use for sequential content where new entries added (chat, activity feeds, console output).

```html
<div role="log" aria-label="Chat messages">
  <!-- new messages append here -->
</div>
```

### `role="timer"`

Use for elements displaying elapsed/remaining time. Does NOT imply `aria-live` -- add explicitly if announcements wanted.

```html
<div role="timer" aria-live="off" aria-label="Session timeout">4:59 remaining</div>
```

Typically keep `aria-live="off"` to prevent constant interruption; announce milestones separately via polite live region.

### The `<output>` Element

HTML `<output>` has implicit `role="status"` (polite live region). Use for calculation results or form output:

```html
<output for="qty price" aria-label="Total cost">$24.00</output>
```

### Live Region Attribute Reference

**`aria-atomic`** -- controls whether screen reader announces entire region or just changed portion:

- `aria-atomic="true"` -- announce ENTIRE region content on any change (status messages where context matters: "3 of 10 items")
- `aria-atomic="false"` (default) -- announce only changed nodes (chat logs where only new message matters)

**`aria-relevant`** -- controls which change types trigger announcements:

- `additions` (default for most roles) -- new nodes added
- `removals` -- nodes removed (rare; "user left the chat" scenarios)
- `text` -- text content changed
- `all` -- shorthand for `additions removals text`
- `additions text` (default) -- most common; new nodes + text changes

**`aria-busy`** -- suppress announcements during batch updates:

```javascript
// Start batch update
regionEl.setAttribute('aria-busy', 'true');

// Apply multiple DOM changes...
items.forEach(item => regionEl.appendChild(createItemEl(item)));

// End batch update -- screen reader now announces the final state
regionEl.setAttribute('aria-busy', 'false');
```

Without `aria-busy`, screen reader may announce intermediate states during rapid multi-step updates.

## Implementation Rules

### The Region Must Exist First

Live region element must be in DOM BEFORE content changes. Element created and content set simultaneously → screen reader won't announce it.

```html
<!-- GOOD: Region exists on page load, content updated later -->
<div aria-live="polite" id="search-status"></div>

<script>
// Later, when results load:
document.getElementById('search-status').textContent = '5 results available';
</script>
```

```html
<!-- BAD: Region created and filled simultaneously -->
<script>
const status = document.createElement('div');
status.setAttribute('aria-live', 'polite');
status.textContent = '5 results available';
document.body.appendChild(status); // Screen reader may not announce this
</script>
```

### Update Text Content, Do Not Replace Elements

Changing `textContent`/`innerText` triggers announcement. Replacing entire element may not.

```javascript
// GOOD
statusEl.textContent = '3 results available';

// BAD -- may not trigger announcement
statusEl.innerHTML = '<span>3 results available</span>';

// BAD -- replacing the element entirely
oldStatusEl.replaceWith(newStatusEl);
```

### Keep Announcements Short

Screen reader reads entire live region content on change. Long announcements are disorienting.

```javascript
// GOOD
statusEl.textContent = '5 results';

// BAD
statusEl.textContent = 'Your search for "accessibility" returned 5 results. Please review the results below and refine your search if needed.';
```

### Do Not Announce Too Frequently

Content updates rapidly (typing in search, dragging slider) → debounce announcements.

```javascript
let debounceTimer;
function announceResults(count) {
  clearTimeout(debounceTimer);
  debounceTimer = setTimeout(() => {
    statusEl.textContent = `${count} results`;
  }, 500); // Wait 500ms after last change
}
```

Without debouncing, screen reader tries to announce every intermediate value, creating garbled overlapping speech.

### Visually Hidden Live Regions

If announcement shouldn't be visible on screen, use visually-hidden pattern:

```html
<div aria-live="polite" class="visually-hidden" id="screen-reader-status"></div>
```

```css
.visually-hidden {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border: 0;
}
```

Never use `display: none`/`visibility: hidden` on live regions. Screen readers ignore hidden elements entirely.

## Common Patterns

### Search/Filter Results

```html
<div aria-live="polite" id="result-count" class="visually-hidden"></div>

<script>
const count = filteredResults.length;
document.getElementById('result-count').textContent = 
  count === 0 ? 'No results found' : `${count} results`;
</script>
```

### Loading States

```html
<div aria-live="polite" id="loading-status"></div>

<script>
// Start loading
loadingStatus.textContent = 'Loading...';

// Finish loading
loadingStatus.textContent = 'Content loaded';
</script>
```

Operations over 2 seconds: announce loading is happening. Don't leave user in silence.

### Form Submission

```html
<div aria-live="polite" id="form-status"></div>

<script>
// Success
formStatus.textContent = 'Changes saved';

// Error
formStatus.setAttribute('role', 'alert');
formStatus.textContent = 'Error: Email address is invalid';
</script>
```

### Toast Notifications

```html
<div aria-live="polite" id="toast-container"></div>

<script>
function showToast(message) {
  toastContainer.textContent = message;
  setTimeout(() => {
    toastContainer.textContent = '';
  }, 5000);
}
</script>
```

- Never move focus to a toast
- Use polite, not assertive
- Keep message brief
- Don't stack multiple toasts rapidly

### Progress Indicators

```html
<div role="progressbar" aria-valuenow="45" aria-valuemin="0" aria-valuemax="100" aria-label="Upload progress">
  45%
</div>
<div aria-live="polite" id="progress-status" class="visually-hidden"></div>

<script>
function updateProgress(percent) {
  progressBar.setAttribute('aria-valuenow', percent);
  progressBar.textContent = `${percent}%`;
  
  // Announce milestones, not every percentage
  if (percent === 25 || percent === 50 || percent === 75) {
    progressStatus.textContent = `${percent}% complete`;
  } else if (percent === 100) {
    progressStatus.textContent = 'Upload complete';
  }
}
</script>
```

### Inline Editing

```html
<div aria-live="polite" id="save-status" class="visually-hidden"></div>

<script>
saveStatus.textContent = 'Saved';
// Clear after a moment so next save triggers a fresh announcement
setTimeout(() => { saveStatus.textContent = ''; }, 1000);
</script>
```

## React-Specific Notes

Manage live regions carefully in React:

```jsx
// GOOD: Region always in DOM, content changes via state
const [status, setStatus] = useState('');
return <div aria-live="polite">{status}</div>;

// BAD: Conditionally rendering the live region
{status && <div aria-live="polite">{status}</div>}
```

Conditional render creates and fills element simultaneously. Screen reader may not announce it.

## Validation Checklist

1. Every dynamic content update has corresponding live region or focus management?
2. Live regions in DOM before content changes?
3. `aria-live="assertive"` used only for genuine critical alerts?
4. Rapid updates debounced?
5. Loading states announced for operations over 2 seconds?
6. Announcements short and meaningful?
7. Live regions not hidden with `display: none`/`visibility: hidden`?
8. `textContent` used to update (not innerHTML or element replacement)?
9. React: live regions unconditionally rendered?
10. Toasts announced without stealing focus?
11. `aria-atomic` set correctly (true for status messages, false/default for logs)?
12. `aria-busy` used to suppress intermediate announcements during batch updates?
13. Alerts avoid auto-disappearing without user control?
14. Alerts absent from initial page load DOM (won't be announced otherwise)?

## Common Mistakes to Flag

- No live region at all for search results/filter changes (user hears nothing)
- `aria-live` on container that gets replaced instead of updated
- `aria-live="assertive"` on search result count (interrupts constantly)
- Live region created dynamically same time as content
- Multiple live regions updating simultaneously (screen reader picks one, ignores others)
- Announcements during page load overridden by screen reader's own page-load announcement
- Missing loading state announcements (user doesn't know anything is happening)
- Using `display: none` to hide live region (screen reader ignores completely)

## Reporting Findings

Findings from this checklist are for human to review and fix — nothing auto-fixed. Report each finding in this format:

```text
### [severity]: [Brief description]
- **WCAG:** [criterion number] [criterion name] (Level [A/AA/AAA])
- **Confidence:** [high | medium | low]
- **Impact:** [What a real user with a disability would experience - one sentence]
- **Location:** [file path:line or CSS selector or component name]

**Current code:**
[code block showing the problem]

**Suggested fix (for human review):**
[code block showing the corrected code in the detected framework syntax]
```

**Confidence rules:**

- **high** - definitively wrong: no live region for dynamic content, `aria-live="assertive"` on non-critical update, live region conditionally rendered, confirmed missing announcement
- **medium** - likely wrong: live region placement may not announce, debouncing absent for high-frequency updates, loading state may be insufficient
- **low** - possibly wrong: announcement timing may be intentional, toast duration may meet user needs, manual verification with screen reader needed

Always explain reasoning behind a finding. Developers need to understand why, not just what.
