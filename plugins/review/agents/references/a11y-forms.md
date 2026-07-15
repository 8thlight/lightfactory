# Form Accessibility

Checklist for reviewing form accessibility. Review agent reads this when diff touches a form, input, select, textarea, checkbox, radio button, date picker, file upload, multi-step wizard, search field, or any user input interface. Not an agent — no tools, no autonomous action. Checklist for producing findings a human reviews and fixes.

<!-- Adapted from Community-Access/accessibility-agents, claude-code-plugin/agents/forms-specialist.md, upstream commit 0872b4a, copied 2026-07-10 -->
<!-- Text compressed with the caveman skill to reduce token load -->

## Authoritative Sources

- **WCAG 3.3 Input Assistance** — <https://www.w3.org/WAI/WCAG22/Understanding/input-assistance>
- **WCAG 3.3.2 Labels or Instructions** — <https://www.w3.org/WAI/WCAG22/Understanding/labels-or-instructions.html>
- **WCAG 1.3.5 Identify Input Purpose** — <https://www.w3.org/WAI/WCAG22/Understanding/identify-input-purpose.html>
- **HTML Forms** — <https://html.spec.whatwg.org/multipage/forms.html>
- **ARIA Forms** — <https://www.w3.org/WAI/ARIA/apg/patterns/>

Forms are where users give up their data: name, payment info, identity. Broken form means blocked user.

## Scope

Covers form accessibility:

- Input labeling and association
- Error handling and validation feedback
- Required field indication
- Form grouping and fieldsets
- Autocomplete attributes
- Multi-step forms and wizards
- Search forms
- Date and time pickers
- File uploads
- Custom form controls (toggles, star ratings, etc.)
- Form submission feedback
- Password fields and visibility toggles

Note: dynamic status messages/announcements from a form (save confirmations, error summaries announced live) also intersect with `live-regions.md` in this directory — check that file too when a form uses live regions.

## Labels -- The Foundation

Every form control MUST have a programmatically associated label. Visual proximity isn't enough — screen readers need explicit association.

### Standard Pattern

```html
<label for="email">Email address</label>
<input id="email" type="email" autocomplete="email">
```

Requirements:

- `<label>` element with `for` attribute matching input's `id`
- Never use `placeholder` as the only label — disappears on input, poor contrast
- Never use `aria-label` when a visible label is possible — sighted users benefit from visible labels too
- Label text must be descriptive: "Email address" not "Input 1"
- Clicking a `<label>` activates its associated control (`aria-label`/`aria-labelledby` do NOT provide this click behavior — why `<label>` is always preferred)
- Implicit labels (wrapping input inside `<label>`) work but less well-supported than explicit `for`/`id`

### When `aria-label` Is Acceptable

Only when a visible label genuinely can't exist:

```html
<!-- Search input with visible button -->
<input type="search" aria-label="Search products">
<button>Search</button>

<!-- Icon-only clear button inside an input -->
<button aria-label="Clear search">
  <svg aria-hidden="true">...</svg>
</button>
```

### When to Use `aria-labelledby`

When label text comes from multiple elements or is already visible elsewhere:

```html
<h2 id="billing-heading">Billing Address</h2>
<input aria-labelledby="billing-heading street-label" id="street">
<span id="street-label">Street</span>
```

### Labels for Wrapped Inputs

Works but explicit `for`/`id` association preferred:

```html
<!-- Works but less explicit -->
<label>
  Email address
  <input type="email">
</label>

<!-- Preferred -- explicit association -->
<label for="email">Email address</label>
<input id="email" type="email">
```

## Help Text and Descriptions

Additional instructions beyond label must be programmatically associated:

```html
<label for="password">Password</label>
<input id="password" type="password" aria-describedby="password-help">
<p id="password-help">Must be at least 8 characters with one number and one special character.</p>
```

- Use `aria-describedby` to link help text to input
- Screen readers announce label first, then description
- Multiple descriptions can be space-separated: `aria-describedby="help-text format-hint"`
- Help text must be visible, not hidden in tooltips

## Required Fields

```html
<label for="name">Full name <span aria-hidden="true">*</span></label>
<input id="name" type="text" required aria-required="true">
```

Requirements:

- Use native `required` attribute — gives browser validation and screen reader announcement for free
- Add `aria-required="true"` for reinforcement (some screen readers prefer it)
- Using an asterisk: hide it from screen readers with `aria-hidden="true"` — `required` already announces "required"
- Explain asterisk convention at top of form: "Fields marked with * are required"
- Never indicate required status through color alone

## Grouping with Fieldset and Legend

Related inputs MUST be grouped:

```html
<fieldset>
  <legend>Shipping Address</legend>
  <label for="street">Street</label>
  <input id="street" type="text" autocomplete="street-address">
  <label for="city">City</label>
  <input id="city" type="text" autocomplete="address-level2">
</fieldset>
```

When to use fieldset/legend:

- Radio button groups (always)
- Checkbox groups (always)
- Related field groups (address, payment info, personal details)
- When group label provides essential context for understanding individual fields

```html
<!-- Radio buttons -- fieldset is mandatory -->
<fieldset>
  <legend>Preferred contact method</legend>
  <label><input type="radio" name="contact" value="email"> Email</label>
  <label><input type="radio" name="contact" value="phone"> Phone</label>
  <label><input type="radio" name="contact" value="text"> Text message</label>
</fieldset>

<!-- Checkboxes -- fieldset is mandatory -->
<fieldset>
  <legend>Notification preferences</legend>
  <label><input type="checkbox" name="notify" value="updates"> Product updates</label>
  <label><input type="checkbox" name="notify" value="news"> Newsletter</label>
  <label><input type="checkbox" name="notify" value="offers"> Special offers</label>
</fieldset>
```

Without fieldset/legend, screen reader user hearing "Email" has no idea it refers to a contact method preference.

## Error Handling

Most commonly broken part of form accessibility.

### Error Message Structure

```html
<label for="email">Email address</label>
<input id="email" type="email" aria-describedby="email-error" aria-invalid="true">
<p id="email-error" role="alert">Please enter a valid email address.</p>
```

Requirements:

- `aria-invalid="true"` on the field with an error
- Error message linked via `aria-describedby`
- Error text visible (not just an icon or color change)
- Error text specific: "Please enter a valid email address" not "Invalid input"
- Remove `aria-invalid` when error is corrected

### Error Summary on Submit

Forms with multiple errors: provide a summary at the top:

```html
<div role="alert" id="error-summary" tabindex="-1">
  <h2>There are 3 errors in this form</h2>
  <ul>
    <li><a href="#email">Email address: Please enter a valid email</a></li>
    <li><a href="#phone">Phone number: Please include area code</a></li>
    <li><a href="#zip">ZIP code: Must be 5 digits</a></li>
  </ul>
</div>
```

Requirements:

- `role="alert"` so screen readers announce immediately
- `tabindex="-1"` so focus can be moved there programmatically
- Focus moves to error summary on submit
- Each error links to the offending field
- Heading describes the count of errors

### Focus Management on Error

```javascript
// On form submit with errors:
const errorSummary = document.getElementById('error-summary');
errorSummary.focus(); // Focus the summary

// If no summary, focus the first invalid field:
const firstError = document.querySelector('[aria-invalid="true"]');
firstError.focus();
```

### Inline Validation

Validating as user types or on blur:

- Don't validate on every keystroke — wait for blur or a pause
- Announce errors via `aria-live="polite"` or `aria-describedby` association
- Remove errors immediately when corrected
- Never block input while validating

### Error Indicators

- Red border alone NOT sufficient
- Must include visible error text
- Should include icon for additional visual indicator
- Associate error icon with `aria-hidden="true"` (text conveys the message)

```html
<!-- GOOD: Text + icon + color -->
<p id="email-error" role="alert">
  <svg aria-hidden="true" class="error-icon">...</svg>
  Please enter a valid email address.
</p>

<!-- BAD: Color only -->
<input class="border-red-500" type="email">
<!-- Screen reader has no idea there's an error -->
```

## Autocomplete

Use `autocomplete` attributes to help browsers/password managers fill fields:

```html
<input type="text" autocomplete="given-name">     <!-- First name -->
<input type="text" autocomplete="family-name">     <!-- Last name -->
<input type="email" autocomplete="email">          <!-- Email -->
<input type="tel" autocomplete="tel">              <!-- Phone -->
<input type="text" autocomplete="street-address">  <!-- Street -->
<input type="text" autocomplete="address-level2">  <!-- City -->
<input type="text" autocomplete="address-level1">  <!-- State/Province -->
<input type="text" autocomplete="postal-code">     <!-- ZIP/Postal code -->
<input type="text" autocomplete="country-name">    <!-- Country -->
<input type="text" autocomplete="cc-name">         <!-- Cardholder name -->
<input type="text" autocomplete="cc-number">       <!-- Card number -->
<input type="text" autocomplete="cc-exp">          <!-- Expiry -->
<input type="text" autocomplete="cc-csc">          <!-- CVV -->
<input type="password" autocomplete="new-password"> <!-- New password -->
<input type="password" autocomplete="current-password"> <!-- Login password -->
<input type="text" autocomplete="username">        <!-- Username -->
```

WCAG 1.3.5 requirement (Input Purpose). Helps users with cognitive disabilities via autofill; helps password managers work correctly.

## Select Elements

```html
<label for="country">Country</label>
<select id="country" autocomplete="country-name">
  <option value="">Select a country</option>
  <option value="us">United States</option>
  <option value="ca">Canada</option>
</select>
```

- Always include a default/placeholder option
- Using `<optgroup>`: the `label` attribute is the accessible name
- Never build custom selects from `<div>` elements without full ARIA and keyboard support
- Custom select necessary → follow listbox pattern with full arrow key navigation

## Checkboxes and Radio Buttons

### Individual Checkboxes

```html
<label>
  <input type="checkbox" name="terms" required>
  I agree to the <a href="/terms">Terms of Service</a>
</label>
```

### Tri-state / Indeterminate Checkboxes

```html
<label>
  <input type="checkbox" aria-checked="mixed" id="select-all">
  Select all items
</label>
```

Set via JavaScript: `checkbox.indeterminate = true;`

## Password Fields

```html
<label for="password">Password</label>
<div class="password-wrapper">
  <input id="password" type="password" autocomplete="new-password" aria-describedby="password-requirements">
  <button type="button" aria-label="Show password" aria-pressed="false" onclick="togglePassword()">
    <svg aria-hidden="true"><!-- eye icon --></svg>
  </button>
</div>
<p id="password-requirements">At least 8 characters, one uppercase, one number.</p>
```

Requirements:

- Show/hide toggle is a `<button>` with `aria-pressed`
- `aria-label` updates: "Show password" / "Hide password"
- Use `aria-pressed` to indicate toggle state
- Never disable paste in password fields
- Requirements text linked via `aria-describedby`

## File Uploads

```html
<label for="avatar">Profile photo</label>
<input id="avatar" type="file" accept="image/*" aria-describedby="file-help">
<p id="file-help">JPG, PNG, or GIF. Maximum 5MB.</p>
<div aria-live="polite" id="upload-status"></div>
```

Requirements:

- Label the file input
- Describe accepted formats/size limits via `aria-describedby`
- Announce upload progress via live region
- Custom styled upload button: ensure it triggers native input
- Show selected filename after selection
- Provide way to remove/change selected file

## Multi-Step Forms / Wizards

```html
<nav aria-label="Form progress">
  <ol>
    <li aria-current="step">
      <span>Step 1: Personal Info</span>
    </li>
    <li>
      <span>Step 2: Address</span>
    </li>
    <li>
      <span>Step 3: Payment</span>
    </li>
  </ol>
</nav>

<form>
  <h2>Step 1: Personal Information</h2>
  <!-- Step fields -->
  <button type="button">Next</button>
</form>
```

Requirements:

- Progress indicator with `aria-current="step"` on current step
- Each step has heading indicating step number and name
- Focus moves to step heading when navigating between steps
- Back button available (don't rely on browser back)
- Data persists when navigating between steps
- Validation per step, not just on final submit
- Announce step changes via heading focus or live region

## Search Forms

```html
<search>
  <form aria-label="Site search">
    <label for="search" class="visually-hidden">Search</label>
    <input id="search" type="search" aria-describedby="search-help" autocomplete="off">
    <button type="submit">Search</button>
    <p id="search-help" class="visually-hidden">Search by product name, category, or keyword</p>
  </form>
</search>
<div aria-live="polite" id="search-results-count" class="visually-hidden"></div>
```

Requirements:

- Use `<search>` element (HTML5 semantic element, maps to `role="search"` automatically). Falls back gracefully in older browsers. If `<search>` unavailable, use `<form role="search">`
- Label the search input (visually hidden acceptable for search)
- Live region announces result count
- Debounce announcements for live search (500ms minimum)
- Clear button if input has content

## Date and Time Inputs

Prefer native inputs when possible:

```html
<label for="dob">Date of birth</label>
<input id="dob" type="date" autocomplete="bday">
```

Custom date picker:

- Must be fully keyboard navigable
- Arrow keys move between days/months
- Escape closes the picker
- Selected date announced by screen reader
- Manual text input as fallback (some users can't use pickers)
- Follow ARIA date picker pattern or use a tested library

## Combobox / Autocomplete Pattern

Per W3C APG Combobox Pattern: a combobox is an input with associated popup (listbox, grid, tree, or dialog) that helps user set the value.

### Two Types

- **Editable combobox:** User can type any value; popup filters suggestions (e.g., address autocomplete)
- **Select-only combobox:** User selects from predefined list; typing filters options (custom styled `<select>` replacement)

### Required Structure

```html
<label for="city">City</label>
<input id="city" role="combobox" type="text"
  aria-expanded="false"
  aria-controls="city-listbox"
  aria-autocomplete="list"
  autocomplete="off">
<ul id="city-listbox" role="listbox" hidden>
  <li role="option" id="city-1">Austin</li>
  <li role="option" id="city-2">Boston</li>
  <li role="option" id="city-3">Chicago</li>
</ul>
<div aria-live="polite" class="visually-hidden" id="city-status"></div>
```

### Autocomplete Behaviors

| `aria-autocomplete` | Behavior |
|---------------------|----------|
| `none` | Popup shows all options regardless of input |
| `list` | Popup filters to match input text |
| `both` | Popup filters AND inline completion appears in the input |
| `inline` | Only inline completion, no popup |

### Key Requirements (W3C APG)

- Use `aria-controls` (NOT `aria-owns`) to link input to popup
- `aria-expanded` toggles `true`/`false` as popup opens/closes
- DOM focus stays on the input; use `aria-activedescendant` to track highlighted option
- Arrow Down opens popup, moves to first option
- Escape closes popup without changing value
- Enter accepts highlighted option
- Live region announces result count: "3 cities match. Use arrow keys to navigate"
- Set `autocomplete="off"` on input to prevent browser autocomplete from conflicting

## Accessible Authentication (WCAG 3.3.8) {#accessible-auth}

Authentication must not require cognitive function tests (memorizing passwords, transcribing codes, solving puzzles) unless an alternative method is available.

### Requirements

- **Never block paste** in password fields. Users depend on password managers
- **Support password managers:** use correct `autocomplete` attributes (`current-password`, `new-password`, `username`)
- **Provide show/hide password toggle** so users can verify what they typed
- **Support alternative auth:** passkeys/WebAuthn, biometrics, OAuth/social login, email/SMS magic links
- **Two-factor/verification codes:** input field must support paste so users can paste from authenticator apps or SMS
- **CAPTCHAs** are a cognitive function test. If used, provide an alternative (audio CAPTCHA, email verification, or invisible reCAPTCHA)

```html
<!-- Password field that supports password managers -->
<label for="password">Password</label>
<input id="password" type="password" autocomplete="current-password">
<button type="button" aria-label="Show password" aria-pressed="false">Show</button>

<!-- Verification code that supports paste -->
<label for="code">Verification code</label>
<input id="code" type="text" inputmode="numeric" autocomplete="one-time-code"
  aria-describedby="code-help">
<p id="code-help">Enter the 6-digit code sent to your phone</p>
```

## Redundant Entry (WCAG 3.3.7) {#redundant-entry}

In multi-step processes, information previously entered by user must be auto-populated or available for selection. Don't force re-entry.

- Step 1 collects shipping address → Step 3 (billing) should offer "Same as shipping" or pre-populate
- User entered email on a previous page → don't ask again
- Data should persist when navigating back and forth between steps
- Auto-populate where safely possible; offer selection for the rest

## Custom Controls

### Toggle Switch

```html
<button role="switch" aria-checked="false" aria-label="Dark mode">
  <span aria-hidden="true" class="toggle-track">
    <span class="toggle-thumb"></span>
  </span>
</button>
```

- Use `role="switch"` with `aria-checked`
- Activate with Enter or Space
- Announce state change
- Visible on/off indicator beyond color

### Star Rating

```html
<fieldset>
  <legend>Rate this product</legend>
  <label><input type="radio" name="rating" value="1"> 1 star</label>
  <label><input type="radio" name="rating" value="2"> 2 stars</label>
  <label><input type="radio" name="rating" value="3"> 3 stars</label>
  <label><input type="radio" name="rating" value="4"> 4 stars</label>
  <label><input type="radio" name="rating" value="5"> 5 stars</label>
</fieldset>
```

Use native radio buttons, style visually as stars. Don't build from clickable SVGs without full ARIA.

## Disabled vs Read-Only

```html
<!-- Disabled: cannot interact, not submitted -->
<input type="text" disabled value="Cannot change this">

<!-- Read-only: cannot edit, IS submitted -->
<input type="text" readonly value="Will be submitted">
```

- Disabled fields excluded from form submission and tab order
- Read-only fields in tab order and ARE submitted
- Both announced by screen readers
- Field conditionally disabled: consider `aria-disabled="true"` with custom handling — native `disabled` removes from tab order and some users may not find it

## Form Layout

- One column is most accessible — multi-column forms confuse tab order
- Left-aligned labels above inputs (or left of inputs for short forms)
- Never use a `<table>` for form layout
- Group related fields visually AND semantically (fieldset/legend)
- Adequate spacing between form groups (at least 24px)

## Validation Checklist

1. Does every input have a programmatically associated label?
2. Are required fields indicated with `required` attribute and visible indicator?
3. Do error messages identify the specific problem and how to fix it?
4. Are errors linked to fields via `aria-describedby`?
5. Does `aria-invalid="true"` appear on fields with errors?
6. Does focus move to error summary or first error on submit?
7. Are related inputs grouped with `<fieldset>` and `<legend>`?
8. Do inputs have appropriate `autocomplete` attributes?
9. Can the entire form be completed by keyboard alone?
10. Are password show/hide toggles accessible buttons?
11. Are file upload constraints described and status announced?
12. For multi-step forms: does focus move to each step heading?
13. Are custom controls (toggles, ratings) built with proper ARIA?
14. Are inline validation messages announced without disrupting input?
15. Is submit button a `<button type="submit">` (not a link or div)?

## Common Mistakes to Flag

- `placeholder` used as the only label (disappears on input, poor contrast)
- Error messages not associated with `aria-describedby`
- Missing `aria-invalid` on error fields
- Radio/checkbox groups without `<fieldset>` and `<legend>`
- Custom styled inputs that lose native keyboard behavior
- Submit button is a `<div>` or `<a>` instead of `<button>`
- No focus management on validation errors (user doesn't know errors exist)
- Autocomplete attributes missing on identity/payment fields
- Required fields indicated only by asterisk color
- Validation on every keystroke creating screen reader noise
- `disabled` used when `aria-disabled` would be more appropriate
- Tab order broken by CSS positioning that differs from DOM order

## Reporting Findings

Findings from this checklist are for a human to review and fix — nothing here is auto-fixed. Provide framework-specific code in suggested fixes. React: use `htmlFor` (not `for`). Angular: use `[attr.aria-describedby]`. Vue: use standard HTML attributes. Controlled inputs: show the state management pattern.

Report each finding in this format:

```text
### [N]. [Brief one-line description]

- **Severity:** [critical | serious | moderate | minor]
- **WCAG:** [criterion number] [criterion name] (Level [A/AA/AAA])
- **Confidence:** [high | medium | low]
- **Impact:** [What a real user with a disability would experience - one sentence]
- **Location:** [file path:line or component name]

**Current code:**
[code block showing the problem]

**Suggested fix (for human review):**
[code block showing the corrected code in the detected framework syntax]
```

**Confidence rules:**

- **high** - definitively wrong: input with no label association, error message with no `aria-describedby`, required field with no `required` attribute
- **medium** - likely wrong: label and input appear visually associated but lack programmatic link, placeholder-only label suspected
- **low** - possibly wrong: custom form control pattern may have accessible equivalent not visible in static analysis

For each finding, include: file path and line number, which form control is affected, what the screen reader experience would be, the specific WCAG criterion violated, and a suggested code fix for a human to apply.
