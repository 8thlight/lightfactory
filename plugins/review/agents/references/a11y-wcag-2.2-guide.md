# WCAG 2.2 Success Criteria Reference

Consult when citing a WCAG 2.2 success criterion. Use to verify SC number, name, conformance level (A/AA/AAA) before including in a finding. Review scope targets AA — criteria below marked AAA-only so they aren't cited as required AA findings.

<!-- Adapted from Community-Access/accessibility-agents, claude-code-plugin/agents/wcag-guide.md, upstream commit 0872b4a, copied 2026-07-10 -->
<!-- Text compressed with the caveman skill to reduce token load -->

Exists because models sometimes invent accessibility findings or cite wrong SC number from memory. Citing against this table instead of recalling from training data reduces that failure mode.

## Authoritative Sources

- **WCAG 2.2 Quick Reference** — <https://www.w3.org/WAI/WCAG22/quickref/>
- **Understanding WCAG 2.2** — <https://www.w3.org/WAI/WCAG22/Understanding/>
- **WCAG 2.2 Specification** — <https://www.w3.org/TR/WCAG22/>
- **What's New in WCAG 2.2** — <https://www.w3.org/WAI/standards-guidelines/wcag/new-in-22/>

## WCAG Structure

### The Four Principles (POUR)

Everything in WCAG falls under one of four principles:

| Principle | Meaning | Example |
|-----------|---------|---------|
| **Perceivable** | Users must be able to perceive the content | Alt text for images, captions for video, sufficient contrast |
| **Operable** | Users must be able to operate the interface | Keyboard access, enough time, no seizure triggers |
| **Understandable** | Users must be able to understand the content | Readable text, predictable behavior, input assistance |
| **Robust** | Content must work with current and future technologies | Valid HTML, proper ARIA, compatible with assistive tech |

### Conformance Levels

| Level | Meaning | Required for our AA scope? |
|-------|---------|-----------|
| **A** | Bare minimum. Without this, some users literally cannot access the content. | Yes — always required |
| **AA** | The standard target. Covers the majority of accessibility barriers. Most laws reference AA. | Yes — this is our target |
| **AAA** | Enhanced. Ideal but not always achievable for all content types. | No — do not cite as a required AA finding |

**Important:** Conformance is inclusive. "Conforms to AA" means ALL Level A criteria AND all Level AA criteria met. A finding can't claim AA conformance while failing any Level A criterion.

### Success Criteria Numbering

Example: **WCAG 2.1.1**

- **2** = Principle 2 (Operable)
- **1** = Guideline 2.1 (Keyboard Accessible)
- **1** = Success Criterion 2.1.1 (Keyboard)

---

## Complete WCAG 2.2 AA Success Criteria Reference

### Principle 1: Perceivable

#### 1.1.1 Non-text Content (Level A)

**What:** All non-text content (images, icons, charts, audio) needs text alternative.
**Why:** Screen reader users can't see images. Text alternative conveys same info.
**Applies to:** Images, icons, SVGs, charts, graphs, audio/video, CAPTCHA, decorative images.
**Common mistake:** Generic alt text like "image"/"photo". Alt text should describe image's purpose in context, not just appearance.
**Does NOT mean:** Every image needs description. Decorative images: `alt=""` to skip.

#### 1.2.1 Audio-only and Video-only (Prerecorded) (Level A)

**What:** Prerecorded audio needs transcript. Prerecorded video (no audio) needs transcript or audio description.
**Why:** Deaf users can't hear audio. Blind users can't see video-only content.

#### 1.2.2 Captions (Prerecorded) (Level A)

**What:** All prerecorded video with audio must have synchronized captions.
**Why:** Deaf/hard-of-hearing users rely on captions.
**Common mistake:** Auto-generated captions without review. Auto-captions ~85% accuracy — 15% error rate confuses content.

#### 1.2.3 Audio Description or Media Alternative (Prerecorded) (Level A)

**What:** Prerecorded video needs audio description or full text transcript.
**Why:** Blind users miss visual-only info in videos (on-screen text, demonstrations, visual gags).

#### 1.2.4 Captions (Live) (Level AA)

**What:** Live audio content in synchronized media needs captions.
**Why:** Deaf users need real-time captioning for live events.

#### 1.2.5 Audio Description (Prerecorded) (Level AA)

**What:** Audio description must be provided for prerecorded video.
**Why:** More specific than 1.2.3 — at AA level, transcript alone isn't sufficient.

#### 1.3.1 Info and Relationships (Level A)

**What:** Info, structure, and relationships conveyed visually must also be conveyed programmatically.
**Why:** Screen readers can't see visual layout. Bold heading that's just styled `<p>` is invisible to screen reader.
**Applies to:** Headings, lists, tables, form labels, required fields, groups of related content.
**Common mistake:** Using CSS to style text large/bold instead of proper `<h1>`-`<h6>` elements.

#### 1.3.2 Meaningful Sequence (Level A)

**What:** When reading order matters, DOM order must match visual order.
**Why:** Screen readers read DOM in source order. CSS reordering content visually gives screen reader users a different (often confusing) sequence.

#### 1.3.3 Sensory Characteristics (Level A)

**What:** Instructions must not rely solely on shape, color, size, visual location, orientation, or sound.
**Why:** "Click the green button" means nothing to blind user or someone with color blindness.
**Example fix:** "Click the green Submit button" -> "Click Submit" (button's label is sufficient).

#### 1.3.4 Orientation (Level AA) — *New in 2.1*

**What:** Content must not be locked to portrait or landscape unless essential.
**Why:** Some users mount devices in fixed orientation. Wheelchair-mounted tablet may always be landscape.
**Exception:** Piano keyboard app may legitimately require landscape.

#### 1.3.5 Identify Input Purpose (Level AA) — *New in 2.1*

**What:** Input fields collecting user data must identify purpose programmatically via `autocomplete` attributes.
**Why:** Lets browsers/AT auto-fill forms, present fields with icons/labels user understands.
**Applies to:** Name, email, phone, address, credit card, birthday, other personal data fields.
**Implementation:** `<input autocomplete="given-name">`, `<input autocomplete="email">`, etc.

#### 1.4.1 Use of Color (Level A)

**What:** Color must not be the only way to convey information.
**Why:** Color-blind users (8% of men) may not distinguish colors. Blind users can't see color at all.
**Example:** Form shows invalid fields in red, no icon/text/programmatic error message. Fix: add error text and/or icon alongside color change.

#### 1.4.2 Audio Control (Level A)

**What:** Audio auto-playing over 3 seconds needs way to pause/stop or control volume independently.
**Why:** Background audio interferes with screen reader speech output.

#### 1.4.3 Contrast (Minimum) (Level AA)

**What:** Text needs ≥4.5:1 contrast ratio against background. Large text (18pt or 14pt bold) requires 3:1.
**Why:** Low contrast text hard to read for users with low vision, aging eyes, or in bright sunlight.
**Numbers to remember:** 4.5:1 normal text. 3:1 large text. "Large" = 18pt (24px) regular or 14pt (18.66px) bold.

#### 1.4.4 Resize Text (Level AA)

**What:** Text must be resizable up to 200% without loss of content/functionality.
**Why:** Low-vision users increase text size. Layout breaking at 200% zoom makes content inaccessible.
**Common mistake:** Fixed pixel heights on containers that clip text when enlarged.

#### 1.4.5 Images of Text (Level AA)

**What:** Use real text instead of images of text, except logos/decorative purposes.
**Why:** Images of text can't be resized, restyled, or read reliably by screen readers.

#### 1.4.10 Reflow (Level AA) — *New in 2.1*

**What:** Content must reflow to single column at 320px CSS width (= 400% zoom on 1280px screen) without horizontal scrolling.
**Why:** Users zooming heavily shouldn't need horizontal scroll to read content.
**Exception:** Content requiring two-dimensional layout (data tables, images, video, toolbars, maps).

#### 1.4.11 Non-text Contrast (Level AA) — *New in 2.1*

**What:** UI components and graphical objects need ≥3:1 contrast against adjacent colors.
**Why:** Buttons, inputs, icons, chart elements need to be visible.
**Applies to:** Form input borders, button boundaries, icons conveying info, states (focus indicator, checked state), chart data.
**Does NOT apply to:** Inactive/disabled controls, pure decoration, logos, photos.

#### 1.4.12 Text Spacing (Level AA) — *New in 2.1*

**What:** No content loss when users override text spacing to: line height 1.5x, paragraph spacing 2x, letter spacing 0.12em, word spacing 0.16em.
**Why:** Some users with dyslexia or low vision need increased spacing.
**Implementation:** Don't use fixed heights on text containers. Use relative units. Test via browser tools or bookmarklet overrides.

#### 1.4.13 Content on Hover or Focus (Level AA) — *New in 2.1*

**What:** Content appearing on hover/focus (tooltips, popups) must be: dismissible (Escape hides it), hoverable (pointer can move to new content without it disappearing), persistent (stays visible until dismissed, focus moves, or hover ends).
**Why:** Screen magnifier users need to move their view to read hover content.

### Principle 2: Operable

#### 2.1.1 Keyboard (Level A)

**What:** All functionality must be operable via keyboard.
**Why:** Users who can't use a mouse rely on keyboard (or devices emulating keyboard input).
**Exception:** Functions requiring analog input (freehand drawing, flight simulation).

#### 2.1.2 No Keyboard Trap (Level A)

**What:** If keyboard focus enters a component, user must be able to move focus away using only keyboard.
**Why:** A keyboard trap makes the entire page unusable. User is stuck.
**Exception:** Modal dialogs intentionally trap focus — but MUST provide Escape to close.

#### 2.1.4 Character Key Shortcuts (Level A) — *New in 2.1*

**What:** Single character key shortcuts must be turn-off-able, remappable, or activate only on focus.
**Why:** Speech recognition users may accidentally trigger shortcuts when speaking commands.

#### 2.2.1 Timing Adjustable (Level A)

**What:** Content with a time limit must be turn-off-able, adjustable, or extendable by user.
**Why:** Some users need more time to read, understand, or interact.
**Exception:** Real-time events (auctions), essential time limits (exam), 20+ hour time limits.

#### 2.2.2 Pause, Stop, Hide (Level A)

**What:** Moving, blinking, scrolling, or auto-updating content needs mechanism to pause, stop, or hide it.
**Why:** Moving content distracts users with attention disorders, makes screen reader users' page reading hard.

#### 2.3.1 Three Flashes or Below Threshold (Level A)

**What:** Content must not flash more than three times per second.
**Why:** Flashing content can trigger seizures in people with photosensitive epilepsy.

#### 2.4.1 Bypass Blocks (Level A)

**What:** Provide mechanism to skip repeated blocks of content (e.g. skip navigation link).
**Why:** Keyboard users would otherwise Tab through entire navigation on every page.
**Implementation:** "Skip to main content" link as first focusable element, or proper landmark regions.

#### 2.4.2 Page Titled (Level A)

**What:** Every page needs descriptive, unique `<title>`.
**Why:** Screen readers announce title on page load — how users know where they are.
**Pattern:** `[Page Name] - [Site Name]` (e.g. "Checkout - Acme Store")

#### 2.4.3 Focus Order (Level A)

**What:** Focusable elements must receive focus in an order preserving meaning and operability.
**Why:** Tab order not matching visual layout loses keyboard users.

#### 2.4.4 Link Purpose (In Context) (Level A)

**What:** Purpose of each link must be determinable from link text alone, or link text plus context.
**Why:** "Click here"/"Read more" mean nothing out of context. Screen readers list all links on a page — ten "Read more" links is useless.

#### 2.4.5 Multiple Ways (Level AA)

**What:** Provide more than one way to find a page (navigation + search + sitemap).
**Why:** Different users prefer different navigation strategies.

#### 2.4.6 Headings and Labels (Level AA)

**What:** Headings and labels must describe topic or purpose.
**Why:** Vague headings like "Information"/"Section 2" don't help users understand content.

#### 2.4.7 Focus Visible (Level AA)

**What:** Keyboard focus indicator must be visible.
**Why:** Keyboard users need to see where they are. No visible focus indicator = mouse with invisible cursor.
**Common mistake:** `outline: none` without replacement focus style.

#### 2.4.11 Focus Not Obscured (Minimum) (Level AA) — *New in 2.2*

**What:** Element receiving keyboard focus must not be entirely hidden by other content (sticky headers, modals, cookie banners).
**Why:** Focused element hidden behind sticky header → user can't see where they are.

#### 2.4.12 Focus Appearance (Level AAA) — *AAA only, do not cite as required for our AA scope*

Requires focus indicators ≥2px thick with 3:1 contrast. Worth knowing, not a valid citation for AA finding.

#### 2.5.1 Pointer Gestures (Level A) — *New in 2.1*

**What:** Functionality using multipoint/path-based gestures (pinch, swipe, draw) must also be operable with single-point gesture.
**Why:** Some users can only use a single finger or head pointer.

#### 2.5.2 Pointer Cancellation (Level A) — *New in 2.1*

**What:** For single-point pointer input, at least one of: down-event doesn't trigger function; function triggers on up-event with ability to abort; up-event reverses down-event.
**Why:** Users with tremors may accidentally touch targets — need to slide off before releasing.

#### 2.5.3 Label in Name (Level A) — *New in 2.1*

**What:** UI components with visible text labels: accessible name must contain the visible text.
**Why:** Speech recognition users say the visible label to activate controls. Mismatch → command fails.
**Example problem:** Button shows "Search" visually, `aria-label="Find products"`. Speech user saying "Click Search" gets nothing.

#### 2.5.4 Motion Actuation (Level A) — *New in 2.1*

**What:** Functions triggered by device motion (shake to undo) must also be available via UI controls, motion triggering must be disableable.
**Why:** Users with mobility impairments may have involuntary motion. Mounted devices can't shake.

#### 2.5.7 Dragging Movements (Level AA) — *New in 2.2*

**What:** Any dragging function must also be achievable with single pointer without dragging.
**Why:** Not all users can drag. Provide click-to-move, arrow keys, or other alternatives.
**Example:** Drag-to-reorder list must also have "move up"/"move down" buttons.

#### 2.5.8 Target Size (Minimum) (Level AA) — *New in 2.2*

**What:** Touch/click targets need ≥24x24 CSS pixels, OR sufficient spacing from other targets.
**Why:** Users with motor impairments, tremors, or large fingers need adequately sized targets.
**Exception:** Inline text links, targets sized by user agent, essential presentations.

### Principle 3: Understandable

#### 3.1.1 Language of Page (Level A)

**What:** Default human language of page must be programmatically identified (`<html lang="en">`).
**Why:** Screen readers use language attribute to switch pronunciation engines.

#### 3.1.2 Language of Parts (Level AA)

**What:** Language of passages/phrases in a different language must be identified (`<span lang="fr">`).
**Why:** French phrase in English page should get French pronunciation from screen reader.

#### 3.2.1 On Focus (Level A)

**What:** Receiving focus must not trigger context change (page navigation, form submission, focus move).
**Why:** Users Tab to explore — unexpected changes on focus are disorienting.

#### 3.2.2 On Input (Level A)

**What:** Changing form input value must not auto-trigger context change unless user warned.
**Why:** Dropdown navigating on selection is unexpected. Users should click a "Go" button.

#### 3.2.3 Consistent Navigation (Level AA)

**What:** Navigation mechanisms on multiple pages must appear in same relative order.
**Why:** Users build a mental model of the site. Rearranging navigation across pages breaks it.

#### 3.2.4 Consistent Identification (Level AA)

**What:** Components with same functionality must be identified consistently (same labels, same icons).
**Why:** Search field labeled "Search" on one page, "Find" on another, confuses users.

#### 3.2.6 Consistent Help (Level AA) — *New in 2.2*

**What:** Help mechanisms (contact info, chat, FAQ) on multiple pages must be in same relative location.
**Why:** Users needing help should find it reliably.

#### 3.3.1 Error Identification (Level A)

**What:** Detected input error must be identified and described to user in text.
**Why:** "The form has errors" isn't helpful. "Email address is required" tells user exactly what to fix.

#### 3.3.2 Labels or Instructions (Level A)

**What:** Labels/instructions provided when content requires user input.
**Why:** Users need to know what to enter. Placeholder text isn't a label — disappears on input.

#### 3.3.3 Error Suggestion (Level AA)

**What:** Detected input error with known suggestions must provide them to user.
**Why:** "Invalid email" less helpful than "Please enter an email address in the format user@example.com."

#### 3.3.4 Error Prevention (Legal, Financial, Data) (Level AA)

**What:** Legal/financial/data-altering submissions: reversible, verified, or user can review/confirm before submitting.
**Why:** Mistakes on financial or legal forms have serious consequences.

#### 3.3.7 Redundant Entry (Level A) — *New in 2.2*

**What:** Info previously provided by user must be auto-populated or available for selection in subsequent steps.
**Why:** Users with cognitive disabilities or motor impairments shouldn't re-enter info already provided.
**Example:** User enters address in step 1, step 3 shouldn't ask again. Auto-populate or offer "same as shipping address."

#### 3.3.8 Accessible Authentication (Minimum) (Level AA) — *New in 2.2*

**What:** Authentication must not require cognitive function tests (remembering passwords, solving puzzles) UNLESS alternative provided (paste support, password managers, biometrics, passkeys).
**Why:** Users with cognitive disabilities may not remember passwords or solve CAPTCHAs.
**In practice:** Support password managers (don't block paste), support passkeys/biometrics, don't use cognitive CAPTCHAs without alternatives, allow email/SMS codes.

### Principle 4: Robust

#### 4.1.2 Name, Role, Value (Level A)

**What:** All UI components need programmatically determinable name, role, value. State changes must be announced to AT.
**Why:** This makes custom components work with screen readers. Custom dropdown must announce "Dropdown, collapsed" -> "Dropdown, expanded."
**Most violated criterion.** Covers every custom widget not using native HTML elements.

#### 4.1.3 Status Messages (Level AA) — *New in 2.1*

**What:** Status messages (success, error, loading, search results count) must be programmatically announced without receiving focus.
**Why:** Screen reader users don't see visual notifications. Use `role="status"`, `aria-live="polite"`, or `role="alert"`.

---

## What Changed in WCAG 2.2 (vs 2.1)

WCAG 2.2 added 9 new success criteria. Ones affecting AA conformance:

| Criterion | Level | What It Added |
|-----------|-------|---------------|
| 2.4.11 Focus Not Obscured | AA | Focused element must not be hidden behind sticky headers/banners |
| 2.5.7 Dragging Movements | AA | Dragging functions must have non-drag alternatives |
| 2.5.8 Target Size (Minimum) | AA | Touch targets >= 24 x 24px (or sufficient spacing) |
| 3.2.6 Consistent Help | AA | Help mechanisms in same location across pages |
| 3.3.7 Redundant Entry | A | Don't make users re-enter info already provided |
| 3.3.8 Accessible Authentication | AA | Don't require cognitive tests for login |

WCAG 2.2 also **removed** one criterion:

- **4.1.1 Parsing** — removed; modern browsers handle parsing errors well. HTML validation still good practice but no longer a WCAG requirement. Don't cite 4.1.1 in a finding against current WCAG 2.2.

---

## Common WCAG Misconceptions

Useful for sanity-checking a finding before writing up.

### "WCAG only applies to screen reader users"

**False.** WCAG covers four disability groups: visual (blindness, low vision, color blindness), auditory (deafness, hard of hearing), motor (tremors, limited reach, paralysis), cognitive (dyslexia, memory, attention). Most criteria help multiple groups.

### "If axe gives us a clean report, we're WCAG compliant"

**False.** Automated tools catch roughly 30% of WCAG criteria. Remaining 70% need manual testing — correct tab order, meaningful alt text, logical focus management, screen reader announcements.

### "alt text should describe what the image looks like"

**Partially true.** Alt text should describe image's **purpose in context**. CEO photo on "About Us" page: "Jane Smith, CEO." Same photo on news article: "Jane Smith announcing the merger at the 2025 keynote." Same photo as decoration: `alt=""`.

### "ARIA makes things accessible"

**Opposite.** First Rule of ARIA: don't use ARIA if native HTML works. ARIA overrides semantics — doesn't add functionality. `<div role="button">` announced as button but doesn't respond to Enter/Space, doesn't appear in tab order, requires manual ARIA state management. `<button>` does all that natively.

### "We'll add accessibility at the end"

**Disastrous.** Retrofitting is 10-100x more expensive than building in. Often requires architectural changes (DOM order, state management, component structure) painful after the fact.

### "Disabled controls don't need to be accessible"

**Complicated.** WCAG doesn't require disabled controls to be perceivable, but users still need to know they exist and why disabled. Best practice: keep disabled controls visible, provide a reason ("Submit disabled - please fix 2 errors above").

### "We target mobile, so WCAG doesn't apply"

**False.** WCAG applies to all web content regardless of device. Mobile web apps must meet same criteria. Touch targets (2.5.8), orientation (1.3.4), gesture alternatives (2.5.1) especially relevant on mobile.

---

## Understanding "Sufficient Techniques" vs "Advisory Techniques"

WCAG provides techniques to meet criteria. Two types:

**Sufficient techniques** — use one, pass the criterion. Example: for 1.1.1, `alt` text on `<img>` is sufficient.

**Advisory techniques** — recommendations beyond the requirement. Not required for conformance. Example: long descriptions for complex images, advisory beyond basic alt text.

**Failures** — common mistakes violating a criterion. Example: `alt="image"` for all images is a documented failure of 1.1.1.

A specific technique isn't mandatory. Same outcome via different method still holds conformance. Success criteria describe the outcome, not the method — don't flag something wrong just because it doesn't match a textbook implementation.

---

## How to Cite a Criterion in a Finding

When citing a WCAG criterion against this reference:

1. Look up criterion number, confirm exact name against tables above — don't rely on memory for number or name.
2. Confirm conformance level (A, AA, AAA) from this table. AAA-only → omit or label "AAA — beyond our AA scope," never as required-AA finding.
3. State plainly what it requires and why, using "What"/"Why" from matching entry above.
4. Give concrete pass/fail example where useful.
5. Note what it does NOT require, if relevant, to avoid over-flagging.

Example:

```text
WCAG 1.4.11 Non-text Contrast (Level AA, new in WCAG 2.1)

Requires: UI components and meaningful graphics must have at least
3:1 contrast against adjacent colors.

Example pass: A text input with a #767676 border on a white background
(contrast ratio 4.48:1).

Example fail: A text input with a #CCCCCC border on white (contrast
ratio 1.6:1 - the border is nearly invisible).

Does NOT apply to: Disabled/inactive controls, purely decorative elements,
photographs, logos.
```
