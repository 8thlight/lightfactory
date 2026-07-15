# Link Text Reference Checklist

Reference checklist for accessibility review agent. Read on-demand when diff contains hyperlinks — not an agent itself, produces no output alone. Findings always framed as observations for human review, never auto-applied fixes or final verdicts.

<!-- Adapted from Community-Access/accessibility-agents, claude-code-plugin/agents/link-checker.md, upstream commit 0872b4a, copied 2026-07-10 -->
<!-- Text compressed with the caveman skill to reduce token load -->

## Authoritative Sources

- **WCAG 2.4.4 Link Purpose (In Context)** — <https://www.w3.org/WAI/WCAG22/Understanding/link-purpose-in-context.html>
- **WCAG 2.4.9 Link Purpose (Link Only)** — <https://www.w3.org/WAI/WCAG22/Understanding/link-purpose-link-only.html>
- **WCAG 3.2.5 Change on Request** — <https://www.w3.org/WAI/WCAG22/Understanding/change-on-request.html>
- **HTML `<a>` element** — <https://html.spec.whatwg.org/multipage/text-level-semantics.html#the-a-element>

## Why This Matters

Screen reader users often navigate by pulling up a list of all links on a page. Every link "Read more" or "Click here" → list useless. Every link must communicate purpose, whether read in context or isolation.

## WCAG Success Criteria

### 2.4.4 Link Purpose (In Context) — Level A

Purpose of each link determinable from link text alone, or link text + programmatically determined context. Default target of this checklist.

### 2.4.9 Link Purpose (Link Only) — Level AAA

Purpose of each link determinable from link text alone (stricter — must make sense without surrounding context). Flag violations as recommendation, not required-AA finding.

## Ambiguous Link Patterns

### Always Ambiguous — Flag as Findings

| Ambiguous Text | Problem | Better Alternative |
|----------------|---------|-------------------|
| "Click here" | Action-focused, not purpose-focused | "Download the annual report" |
| "Here" | No purpose at all | "View our pricing plans" |
| "Read more" | More about what? | "Read more about our accessibility policy" |
| "Learn more" | Learn more about what? | "Learn more about WCAG 2.2 changes" |
| "More" | More what? | "More articles about web accessibility" |
| "More info" | Info about what? | "More info about screen reader support" |
| "Link" | Describes the element, not the destination | "Annual accessibility audit results" |
| "Details" | Details about what? | "Details about the January release" |
| "Info" | Info about what? | "Information about our return policy" |
| "Go" | Go where? | "Go to account settings" |
| "See more" | See more of what? | "See more customer reviews" |
| "Continue" | Continue to what? | "Continue to payment" |
| "Start" | Start what? | "Start your free trial" |
| "Submit" | For links (not form buttons) | "Submit your application" |
| "Download" | Download what? | "Download the 2025 annual report (PDF, 2.4 MB)" |
| "View" | View what? | "View your order history" |
| "Open" | Open what? | "Open the accessibility settings" |
| URL as text | URLs are not descriptive | "Visit the W3C accessibility guidelines" |

### Context-Dependent — Flag as Lower-Confidence, Needs Human Judgment

- **"Read more" inside a card/article** — OK only if `aria-label`/`aria-labelledby` gives full context.
- **"View details" in table row** — OK only if `aria-label` includes row context (e.g. `aria-label="View details for Order #1234"`).
- **Icon-only links** — OK only if `aria-label` present and descriptive.

## Detection Patterns

### Pattern 1: Exact Match on Known Ambiguous Strings

Flag any link whose visible text (trimmed, case-insensitive) exactly matches an ambiguous pattern above.

```html
<!-- FLAG: Exact match on "click here" -->
<a href="/pricing">Click here</a>

<!-- FLAG: Exact match on "read more" -->
<a href="/blog/post-1">Read more</a>

<!-- NOT A FINDING: Descriptive text -->
<a href="/pricing">View our pricing plans</a>
```

### Pattern 2: Starts With Ambiguous Prefix

```html
<!-- FLAG: Starts with "click here" -->
<a href="/report">Click here to download</a>

<!-- BETTER: Purpose-first -->
<a href="/report">Download the 2025 annual report</a>
```

### Pattern 3: Repeated Identical Link Text to Different Destinations

```html
<!-- FLAG: Three "Read more" links going to different pages -->
<a href="/blog/post-1">Read more</a>
<a href="/blog/post-2">Read more</a>
<a href="/blog/post-3">Read more</a>

<!-- FIXED: Each link is unique -->
<a href="/blog/post-1">Read more about accessible forms</a>
<a href="/blog/post-2">Read more about ARIA best practices</a>
<a href="/blog/post-3">Read more about focus management</a>

<!-- ALSO ACCEPTABLE: Using aria-label for uniqueness -->
<a href="/blog/post-1" aria-label="Read more about accessible forms">Read more</a>
<a href="/blog/post-2" aria-label="Read more about ARIA best practices">Read more</a>
<a href="/blog/post-3" aria-label="Read more about focus management">Read more</a>
```

### Pattern 4: URL as Link Text

```html
<!-- FLAG: URL is not descriptive -->
<a href="https://www.w3.org/TR/WCAG22/">https://www.w3.org/TR/WCAG22/</a>

<!-- FIXED: Descriptive text with URL available -->
<a href="https://www.w3.org/TR/WCAG22/">WCAG 2.2 specification</a>
```

### Pattern 5: Adjacent Duplicate Links

Flag when image + text link sit adjacent, go to same destination — should combine into single link.

```html
<!-- FLAG: Two separate links to the same destination -->
<a href="/product/123"><img src="widget.jpg" alt="Widget Pro"></a>
<a href="/product/123">Widget Pro</a>

<!-- FIXED: Single combined link -->
<a href="/product/123">
  <img src="widget.jpg" alt="">
  Widget Pro
</a>
```

### Pattern 6: Links Opening in New Windows Without Warning

```html
<!-- FLAG: No indication of new window -->
<a href="https://example.com" target="_blank">Example Site</a>

<!-- FIXED: User is warned -->
<a href="https://example.com" target="_blank" rel="noopener noreferrer">
  Example Site (opens in new tab)
</a>

<!-- ALSO ACCEPTABLE: Using aria-label or visually hidden text -->
<a href="https://example.com" target="_blank" rel="noopener noreferrer"
   aria-label="Example Site (opens in new tab)">
  Example Site
  <span class="visually-hidden">(opens in new tab)</span>
</a>
```

### Pattern 7: Links to Non-HTML Resources Without File-Type Indication

```html
<!-- FLAG: No indication this is a PDF -->
<a href="/reports/annual-2025.pdf">Annual Report</a>

<!-- FIXED: File type and size indicated -->
<a href="/reports/annual-2025.pdf">Annual Report 2025 (PDF, 2.4 MB)</a>
```

## Human-Facing Fix Guidance

Include these strategies in a finding write-up so human can act without further research.

### Strategy 1: Rewrite the Link Text (preferred)

```html
<!-- Before -->
<p>To learn about our services, <a href="/services">click here</a>.</p>

<!-- After -->
<p><a href="/services">Learn about our services</a>.</p>
```

### Strategy 2: Use `aria-label` for Context

When visible text can't change (design constraints), `aria-label` provides full context to screen readers.

```html
<article>
  <h3>Accessible Forms Guide</h3>
  <p>Learn how to build forms that work for everyone...</p>
  <a href="/guides/forms" aria-label="Read more about accessible forms">Read more</a>
</article>
```

**Important:** `aria-label` completely replaces visible text for screen readers. `aria-label` should include the visible text to satisfy WCAG 2.5.3 (Label in Name).

### Strategy 3: Use `aria-labelledby` for Composed Labels

```html
<article>
  <h3 id="post-title">Accessible Forms Guide</h3>
  <p>Learn how to build forms that work for everyone...</p>
  <a href="/guides/forms" aria-labelledby="post-title read-more-1">
    <span id="read-more-1">Read more</span>
  </a>
</article>
```

### Strategy 4: Use Visually Hidden Text

```html
<a href="/guides/forms">
  Read more<span class="visually-hidden"> about accessible forms</span>
</a>
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

## Common Framework Patterns

### React/JSX

```jsx
{/* FLAG: Generic link text in a map */}
{posts.map(post => (
  <div key={post.id}>
    <h3>{post.title}</h3>
    <a href={`/blog/${post.slug}`}>Read more</a>
  </div>
))}

{/* FIXED: Dynamic aria-label */}
{posts.map(post => (
  <div key={post.id}>
    <h3>{post.title}</h3>
    <a href={`/blog/${post.slug}`} aria-label={`Read more about ${post.title}`}>
      Read more
    </a>
  </div>
))}

{/* BETTER: Descriptive link text wrapping the title */}
{posts.map(post => (
  <article key={post.id}>
    <h3>
      <a href={`/blog/${post.slug}`}>{post.title}</a>
    </h3>
    <p>{post.excerpt}</p>
  </article>
))}
```

### Vue

```vue
<!-- FLAG -->
<router-link :to="`/blog/${post.slug}`">Read more</router-link>

<!-- FIXED -->
<router-link :to="`/blog/${post.slug}`" :aria-label="`Read more about ${post.title}`">
  Read more
</router-link>
```

### Next.js

```jsx
{/* FLAG */}
<Link href="/about">Click here</Link>

{/* FIXED */}
<Link href="/about">About our company</Link>
```

## Links vs Buttons

- `<a href="...">` — navigates to URL/page/section. Screen readers announce "link".
- `<button>` — performs action (submit, toggle, open modal). Screen readers announce "button".

`<a>` without `href` not keyboard focusable, won't appear in screen reader's link list. If seen: should be `<button>` or given `role="button"` with `tabindex="0"` and keydown handlers for Enter/Space.

## Label in Name (WCAG 2.5.3)

When `aria-label` overrides visible link text, must contain visible text as substring. Speech-input users say what they see — visible text "Read more" but `aria-label` "Continue to the article about forms" → command "click Read more" fails.

```html
<!-- GOOD: aria-label includes visible text "Read more" -->
<a href="/forms" aria-label="Read more about accessible forms">Read more</a>

<!-- BAD: aria-label does not include visible text -->
<a href="/forms" aria-label="Continue to forms article">Read more</a>
```

## Do Not Include "Link" in Link Text

Screen readers already announce element role ("link"). Adding "link" to text creates redundant speech: "link, link to pricing page."

```html
<!-- BAD: Redundant role in text -->
<a href="/pricing">Link to pricing page</a>

<!-- GOOD -->
<a href="/pricing">Pricing</a>
```

## Download Links

Use `download` attribute for file downloads, always indicate file type and size:

```html
<a href="/report.pdf" download aria-label="Download Annual Report 2025 (PDF, 2.4 MB)">
  Download Annual Report 2025 (PDF, 2.4 MB)
</a>
```

## Validation Checklist

Use when writing up findings for a diff touching links.

### Link Text Quality
1. Every link has text describing its purpose?
2. Any "click here", "read more", "learn more", "here" links?
3. Purpose of each link understood from link text alone (or with programmatic context)?
4. URLs used as visible link text?

### Uniqueness
5. Links with identical text all point to same destination?
6. Repeated generic links differentiated with `aria-label`/`aria-labelledby`?

### Context
7. Links inside cards/articles have sufficient context (`aria-label`, `aria-labelledby`, descriptive text)?
8. Icon-only links labeled with `aria-label`?

### New Windows and Resources
9. Links opening in new tabs warn user (visible text or `aria-label`)?
10. Links to non-HTML files indicate file type and size?

### Adjacent Links
11. Adjacent image + text links to same destination combined into one link?
12. Adjacent links to different destinations separated by more than whitespace?

### Correct Element Usage
13. Links used for navigation (page/section)?
14. Buttons used for actions (submit, toggle, open)?
15. Links without `href`? (Should be buttons or `role="button"`)

## Common Mistakes to Catch

- "Click here"/"Read more" — most common link a11y failures globally.
- Multiple "Learn more" links on one page, no differentiation.
- Card components: entire card wrapped in link, no discernible text.
- Icon-only links (social media icons) without `aria-label`.
- Links styled as buttons that should actually be `<button>` elements.
- `<a>` tags without `href` (not keyboard focusable by default).
- Accessible name doesn't include visible text (2.5.3 Label in Name violation).
- "Read more" links inside `<article>` relying on article heading for context without programmatic association.
- File download links not indicating file type or size.

## Reporting Findings

Every finding from this checklist is a candidate for human review, not a verdict. When surfacing:

- Cite specific WCAG criterion number, name, level (e.g. "2.4.4 Link Purpose (In Context), Level A").
- State confidence: **high** (exact match to known ambiguous pattern, or raw URL as visible text), **medium** (short non-descriptive text in card context, or repeated link text across page), **low** (link text short but may have sufficient surrounding context — flag for human review rather than asserting violation).
- Before flagging, check whether `aria-label`, `aria-labelledby`, or visually hidden text already resolves ambiguity — if so, don't flag.
- Report surrounding context (card pattern, list item, component) so reviewer can judge isolated vs systemic issue across shared component.
