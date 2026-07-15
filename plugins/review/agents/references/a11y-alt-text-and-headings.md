# Alt Text and Headings Reference

Checklist for review agent: read when diff shows images, icons, SVGs, videos, figures, charts, or heading markup. Not an agent, no tools, no autonomous action — loaded on demand to inform what review agent reports.

<!-- Adapted from Community-Access/accessibility-agents, claude-code-plugin/agents/alt-text-headings.md, upstream commit 0872b4a, copied 2026-07-10 -->
<!-- Text compressed with the caveman skill to reduce token load -->

## Authoritative Sources

- **WCAG 1.1.1 Non-text Content** — <https://www.w3.org/WAI/WCAG22/Understanding/non-text-content.html>
- **WCAG 2.4.6 Headings and Labels** — <https://www.w3.org/WAI/WCAG22/Understanding/headings-and-labels.html>
- **WAI Alternative Text Tutorial** — <https://www.w3.org/WAI/tutorials/images/>
- **HTML alt attribute** — <https://html.spec.whatwg.org/multipage/images.html#alt>
- **ARIA Landmarks** — <https://www.w3.org/WAI/ARIA/apg/practices/landmark-regions/>

Images without alt text: invisible to screen reader users. Broken heading hierarchies: pages impossible to navigate. Covers text alternatives and document structure.

## Automated Check Scope: Presence, Not Quality

**The automated check here only flags missing alt text.** Doesn't, shouldn't, render a verdict on whether existing alt text is "good enough," accurate, or well-written. Judging alt text quality requires understanding image purpose/context — genuinely a human call; CoP decided this is explicitly deferred to human review.

When reviewing a diff:
- Flag any `<img>` with no `alt` attribute at all — unambiguous, always worth flagging.
- Flag alt text obviously a filename (e.g. `alt="IMG_20250115_143022.jpg"`) or empty placeholder pattern — effectively "missing" in practice.
- Do **not** independently assess whether present alt text accurately describes the image, is sufficiently descriptive, or well phrased. Report presence/absence only; note quality is a human-review item.

The optional guidance below (image analysis workflow, quality ratings, question prompts) is kept as **human-facing reference** — for a human reviewer thinking through alt text quality themselves. Not something the automated check should execute or use to generate a verdict.

## Optional Human Reference: Judging Alt Text Quality

Following is for a human reviewer's own use, not for the automated check to act on.

### Image Analysis Workflow (human-driven)

Human reviewer evaluating alt text can work through:

1. **Look at the image** — examine what it actually contains.
2. **Read the existing alt text** — check what `alt`, `aria-label`, or `aria-labelledby` provides.
3. **Evaluate the context** — surrounding HTML/text to understand image's role on page.
4. **Compare and assess** — does alt text accurately describe what image communicates in context?

### Quality Rating Scale (for human use)

| Rating | Meaning | Action |
|--------|---------|--------|
| **Good** | Alt text accurately describes the image's purpose in context | No change needed |
| **Inaccurate** | Alt text exists but does not match the image content or misrepresents it | Suggest corrected text |
| **Incomplete** | Alt text partially describes the image but misses important information | Suggest enhanced text |
| **Generic** | Alt text is vague ("image", "photo", "icon") and adds no value | Suggest specific text |
| **Missing** | No alt attribute present | Ask about purpose, then suggest text |
| **Incorrect type** | Image is decorative but has descriptive alt, or meaningful but has empty alt | Suggest correct approach |

### Questions a Human Might Ask When Context Is Ambiguous

1. **Purpose**: Decorative (purely visual) or conveys information user needs?
2. **Context**: Image's role on page — illustrating a concept, showing a product, or purely aesthetic?
3. **Audience**: Would a screen reader user miss important info if image removed entirely?
4. **Action**: Does image link somewhere/trigger an action? If so, what destination/action?
5. **Data**: Chart/graph — what data does it represent, so description is accurate?
6. **Identity**: Shows a person — should alt text identify them by name/role?

## W3C Image Categories

W3C WAI Images Tutorial defines seven image categories. Category determines correct alt text approach:

| Category | Purpose | Alt Text Approach |
|----------|---------|-------------------|
| **Informative** | Conveys information (photos, illustrations) | Describe the content concisely |
| **Decorative** | Visual embellishment only | `alt=""` (empty string) |
| **Functional** | Inside a link or button | Describe the action/destination, not the image |
| **Text images** | Contain readable text | Alt text = the text in the image |
| **Complex** | Charts, diagrams, infographics | Short alt + long description |
| **Groups** | Multiple images forming a single concept | One image gets full alt, others get `alt=""` |
| **Image maps** | Clickable regions within an image | Each `<area>` gets its own `alt` |

**Context determines category:** same image of a phone could be informative ("Samsung Galaxy S24"), functional ("Buy Samsung Galaxy S24"), or decorative (background lifestyle photo) depending on role on page.

## The `<picture>` Element

`<picture>` provides art direction for responsive images. `alt` goes on inner `<img>`, not on `<picture>`:

```html
<picture>
  <source media="(min-width: 800px)" srcset="hero-wide.jpg">
  <source media="(min-width: 400px)" srcset="hero-medium.jpg">
  <img src="hero-small.jpg" alt="Sunset over the Golden Gate Bridge">
</picture>
```

All `<source>` variants should convey same information — single `alt` on `<img>` must be accurate for every resolution. Automated check: flag if inner `<img>` has no `alt`.

## CSS Background Images

CSS background images invisible to screen readers. Must be purely decorative:

```css
/* GOOD: purely decorative background */
.hero-section {
  background-image: url('abstract-pattern.svg');
}
```

CSS background image conveying meaningful information → replace with `<img>` with proper alt text, or supplement with visually hidden text alternative. Flag CSS background images in contexts that look informational (e.g. containing text or standing in for content) for human review.

## Logo Alt Text

Logo images: alt text identifies company/organization, not describes the logo:

```html
<!-- GOOD -->
<a href="/"><img src="logo.svg" alt="Acme Corporation"></a>

<!-- BAD: describes appearance -->
<a href="/"><img src="logo.svg" alt="Blue circle with white A"></a>

<!-- BAD: redundant "logo" -->
<a href="/"><img src="logo.svg" alt="Acme Corporation logo"></a>

<!-- BAD: states the obvious -->
<a href="/"><img src="logo.svg" alt="Home page"></a>
```

Automated check flags only the missing case (no `alt` at all). "Describes appearance"/"redundant"/"states the obvious" variants above: quality judgments — human-facing reference only.

## Form Image Buttons

Image buttons in forms describe function, not image:

```html
<!-- GOOD: describes the function -->
<input type="image" src="search-icon.png" alt="Search">
<input type="image" src="go-arrow.png" alt="Submit order">

<!-- BAD: describes appearance -->
<input type="image" src="search-icon.png" alt="Magnifying glass icon">
```

Automated check: flag `<input type="image">` with no `alt` attribute. Appearance-vs-function distinction: quality judgment for human review.

## Alternative Text — The Rules

### Rule 1: Every `<img>` Gets an `alt` Attribute

No exceptions. Core automated check — presence, not content.

```html
<!-- Meaningful image: describe the content -->
<img src="team-photo.jpg" alt="The engineering team at the 2025 company retreat, standing in front of the main office">

<!-- Decorative image: empty alt -->
<img src="decorative-swirl.png" alt="">

<!-- Linked image: describe the destination -->
<a href="/profile">
  <img src="avatar.jpg" alt="Your profile">
</a>
```

Note: `alt=""` counts as present (decorative intent) — don't flag as missing.

### Rule 2: Describe Content, Not Appearance (human-facing quality note)

```html
<!-- BAD: Describes what it looks like -->
<img src="graph.png" alt="A blue bar chart with 5 bars">

<!-- GOOD: Describes what it communicates -->
<img src="graph.png" alt="Quarterly revenue: Q1 $2M, Q2 $2.5M, Q3 $3.1M, Q4 $3.8M, Q5 $4.2M">
```

Distinction is quality, not presence — human review only.

### Rule 3: Functional Images Describe the Action (human-facing quality note)

Image inside a link/button → alt text ideally describes where it goes/what it does, not what image looks like. Quality judgment; automated check only confirms an `alt` attribute exists.

```html
<a href="/">
  <img src="logo.svg" alt="Acme Corp home page">
</a>
```

### Rule 4: Decorative Images Are Hidden

Images adding no information — visual flourishes, spacers, backgrounds, dividers:

```html
<img src="divider.png" alt="" aria-hidden="true">
<img src="background-pattern.png" alt="" role="presentation">
```

Both `alt=""` and `role="presentation"` work. `alt=""` is primary method; `aria-hidden="true"` reinforces it for SVGs and complex decorative elements.

### Rule 5: Complex Images Need Long Descriptions

Charts, diagrams, infographics, data visualizations too complex for short alt text:

```html
<!-- Method 1: Adjacent visible description -->
<figure>
  <img src="org-chart.png" alt="Company organizational chart. Full description below.">
  <figcaption>
    <details>
      <summary>Full description of organizational chart</summary>
      <p>The CEO reports to the board. Three VPs report to the CEO: VP Engineering (5 teams, 47 people), VP Product (3 teams, 18 people), VP Marketing (4 teams, 22 people)...</p>
    </details>
  </figcaption>
</figure>

<!-- Method 2: aria-describedby for longer descriptions -->
<img src="flowchart.png" alt="User registration flow" aria-describedby="flow-desc">
<div id="flow-desc" class="visually-hidden">
  Step 1: User enters email. Step 2: System checks if email exists. If yes, show login prompt. If no, proceed to step 3...
</div>
```

Automated check: flag complex images (charts/diagrams identified by filename/context) with no `alt` at all. Whether description is adequately "long enough": quality judgment for human review.

## SVG Accessibility

### Inline SVGs

```html
<!-- Meaningful inline SVG -->
<svg role="img" aria-labelledby="svg-title svg-desc">
  <title id="svg-title">Monthly Sales</title>
  <desc id="svg-desc">Bar chart showing sales increasing from $10K in January to $45K in June</desc>
  <!-- SVG content -->
</svg>

<!-- Decorative inline SVG -->
<svg aria-hidden="true" focusable="false">
  <!-- SVG content -->
</svg>
```

Requirements for meaningful SVGs:

- `role="img"` on `<svg>` element
- `<title>` element as first child (acts as accessible name)
- `<desc>` element for longer descriptions
- `aria-labelledby` referencing both title and desc IDs
- Do NOT add `focusable="false"` on meaningful SVGs

Requirements for decorative SVGs:

- `aria-hidden="true"` on `<svg>` element
- `focusable="false"` to prevent IE/Edge focus issues
- No `<title>` or `<desc>` elements

Automated check: flag SVG with no `aria-hidden`, no `role="img"`, no `<title>`/`<desc>` — no determinable accessible name, neither marked decorative nor labeled.

### SVGs in Buttons and Links

```html
<!-- Icon with visible text: hide the SVG -->
<button>
  <svg aria-hidden="true" focusable="false">...</svg>
  Save document
</button>

<!-- Icon-only button: label the button, hide the SVG -->
<button aria-label="Close dialog">
  <svg aria-hidden="true" focusable="false">...</svg>
</button>
```

Never give SVG an accessible name AND label the parent button/link — creates double announcements. Flag icon-only buttons/links with no `aria-label` and no visible text.

## Icon Fonts

```html
<!-- Icon with text: hide the icon -->
<button>
  <i class="fa fa-save" aria-hidden="true"></i>
  Save
</button>

<!-- Icon-only: hide the icon, label the parent -->
<button aria-label="Delete item">
  <i class="fa fa-trash" aria-hidden="true"></i>
</button>
```

- Always `aria-hidden="true"` on icon font elements
- Never rely on icon font ligatures for accessible names
- Accessible name goes on interactive parent, never on the icon

Flag: icon-only interactive elements using icon fonts with no `aria-label` on parent.

## Video and Audio

### Video

```html
<video controls aria-label="Product demo walkthrough">
  <source src="demo.mp4" type="video/mp4">
  <track kind="captions" src="captions.vtt" srclang="en" label="English captions" default>
  <track kind="descriptions" src="descriptions.vtt" srclang="en" label="Audio descriptions">
  Your browser does not support video.
</video>
```

Requirements:

- Captions for all spoken content (WCAG 1.2.2)
- Audio descriptions for important visual content not described in audio track (WCAG 1.2.5)
- `controls` attribute so users can pause, stop, adjust volume
- No autoplay (or muted autoplay with visible play/pause control)
- Transcript recommended as alternative
- `aria-label` or visible heading to identify the video

Flag: `<video>` with no `<track kind="captions">` at all, or autoplay without mute.

### Audio

```html
<audio controls aria-label="Episode 42: Accessibility in 2025">
  <source src="podcast.mp3" type="audio/mpeg">
</audio>
<a href="transcript-ep42.html">Read transcript for Episode 42</a>
```

Requirements:

- Transcript for all audio content (WCAG 1.2.1)
- `controls` attribute
- No autoplay

## Figures and Figcaptions

```html
<figure>
  <img src="dashboard.png" alt="Analytics dashboard showing 45% increase in mobile traffic over 6 months">
  <figcaption>Figure 3: Mobile traffic growth from January to June 2025</figcaption>
</figure>
```

**Critical rules per W3C Images Tutorial:**

- `<img>` inside `<figure>` still MUST have `alt` text — `<figcaption>` does NOT replace `alt`
- `<figcaption>` provides visible caption for ALL users; `alt` provides text alternative for screen readers
- Should complement each other but not be identical (avoids double-reading)
- `<figcaption>` must be first or last child of `<figure>`
- `<figure>` can contain content other than images (code blocks, quotes, tables)

Automated check: flag `<img>` inside `<figure>` with no `alt`, regardless of whether `<figcaption>` present.

## Heading Structure — The Rules

### Rule 1: Exactly One H1 Per Page

```html
<!-- GOOD -->
<h1>Shopping Cart</h1>
<h2>Your Items</h2>
<h3>Widget Pro</h3>
<h2>Order Summary</h2>

<!-- BAD: Multiple H1s -->
<h1>My Store</h1>
<h1>Shopping Cart</h1>
```

H1 is the page title, describes purpose of entire page. Exactly one.

### Rule 2: Never Skip Levels

```html
<!-- GOOD -->
<h1>Products</h1>
  <h2>Electronics</h2>
    <h3>Laptops</h3>
    <h3>Phones</h3>
  <h2>Clothing</h2>
    <h3>Shirts</h3>

<!-- BAD: Skipped H2 -->
<h1>Products</h1>
  <h3>Electronics</h3>  <!-- WRONG: Jumped from H1 to H3 -->
```

Screen reader users navigate by headings. Skipped levels make them think they missed content.

### Rule 3: Headings Can Return to Higher Levels

```html
<!-- This is perfectly valid -->
<h1>Blog</h1>
  <h2>Latest Post</h2>
    <h3>Introduction</h3>
    <h3>Main Points</h3>
  <h2>Previous Post</h2>   <!-- Returning to H2 is fine -->
    <h3>Summary</h3>
```

Going H3 back to H2 is correct — starts new section at H2 level.

### Rule 4: Never Choose Heading Level for Visual Appearance

```html
<!-- BAD: Using H4 because it "looks right" -->
<h4>Welcome to our site</h4>  <!-- Should be H1 if it's the page heading -->

<!-- GOOD: Use CSS for visual appearance -->
<h1 class="text-lg font-normal">Welcome to our site</h1>
```

Heading level communicates document structure, not visual design. Use CSS to control how headings look.

### Rule 5: Headings Must Be Descriptive (human-facing quality note)

```html
<!-- BAD -->
<h2>Section 1</h2>
<h2>More Info</h2>
<h2>Details</h2>

<!-- GOOD -->
<h2>Pricing Plans</h2>
<h2>Customer Testimonials</h2>
<h2>Frequently Asked Questions</h2>
```

Screen reader users can pull up a list of all headings on the page. "Section 1" in a list is useless. Quality judgment for human review, not part of automated structural check.

### Rule 6: Modal Headings Start at H2

```html
<!-- Page (behind modal) -->
<h1>Dashboard</h1>

<!-- Modal -->
<dialog>
  <h2>Settings</h2>           <!-- H2, not H1 -->
    <h3>Notifications</h3>
    <h3>Privacy</h3>
</dialog>
```

Page H1 remains the H1. Modal content is subordinate.

## Document Outline Verification

When reviewing a diff, extract heading structure, verify it makes sense as an outline:

```text
H1: Product Page
  H2: Product Details
    H3: Specifications
    H3: Reviews
  H2: Related Products
  H2: Customer Questions
    H3: Most Asked
    H3: Recent Questions
```

Should read like a table of contents. Broken level sequence (skipped levels, multiple H1s): flag it — structural, not a quality judgment.

## Page Titles

```html
<title>Shopping Cart - Acme Store</title>
```

- Format: "Page Name - Site Name"
- Must be unique for every page
- Must describe page purpose
- Updated on SPA route changes
- Screen readers announce title first when page loads

```javascript
// SPA route change
document.title = 'Product Details - Acme Store';
```

Flag: missing `<title>`, or generic title like "Page" reused across routes.

## Language Attributes

```html
<!-- Page language -->
<html lang="en">

<!-- Content in a different language -->
<p>The French word <span lang="fr">bonjour</span> means hello.</p>
```

- `lang` on `<html>` mandatory (WCAG 3.1.1)
- `lang` on elements with different language content (WCAG 3.1.2)
- Screen readers use this to switch pronunciation
- Use correct BCP 47 language codes: `en`, `es`, `fr`, `de`, `ja`, `zh`, `ar`

Flag: missing `lang` on `<html>`.

## Landmark Structure

```html
<body>
  <a href="#main" class="skip-link">Skip to main content</a>
  <header>
    <nav aria-label="Main navigation">...</nav>
  </header>
  <main id="main" tabindex="-1">
    <h1>Page Title</h1>
    ...
  </main>
  <aside aria-label="Related articles">...</aside>
  <footer>...</footer>
</body>
```

- One `<main>` per page
- `<header>` and `<footer>` at page level (not inside `<main>`)
- Multiple `<nav>` elements need `aria-label` to differentiate
- `<aside>` for complementary content
- Do not add redundant ARIA roles to semantic landmarks

## Validation Checklist

### Images (structural — automated check should flag)

1. Does every `<img>` have an `alt` attribute?
2. Do decorative images have `alt=""`?
3. Do functional images (in links/buttons) have *some* alt text (presence, not wording)?
4. Do complex images (charts/diagrams) have at least a short `alt`?
5. Are SVGs given either `aria-hidden` or a `role="img"` + `<title>`?
6. Are icon fonts hidden with `aria-hidden="true"`?
7. Do icon-only buttons/links have `aria-label`?

### Images (quality — human review only, do not auto-flag as a verdict)

8. Is the alt text descriptive rather than generic ("image", "photo", filename)?
9. Does the alt text match what the image actually shows?

### Headings (structural)

10. Is there exactly one H1 per page?
11. Are heading levels sequential (no skipped levels)?
12. Do modal headings start at H2?

### Headings (quality — human review only)

13. Do headings describe their section content meaningfully?

### Document Structure

14. Is `<html lang="...">` set correctly?
15. Is `<title>` present and non-generic?
16. Are landmarks used correctly (header, nav, main, footer)?
17. Is there a skip link to main content?
18. Are language changes within content marked with `lang`?

### Media

19. Do videos have caption tracks?
20. Is autoplay disabled or muted with visible controls?
21. Is a transcript link present for audio content?

## Common Mistakes to Catch

Structural (automated, flag directly):

- Missing `alt` attribute entirely (screen reader reads the filename)
- SVGs without `aria-hidden` or proper `title`/`desc`
- Empty headings (`<h2></h2>` or headings with only whitespace)
- Headings inside interactive elements (`<button><h2>Click me</h2></button>`)
- Missing page `<title>` or generic title like "Page" on every page
- Missing `lang` attribute on `<html>`
- `<div class="heading">` instead of actual heading elements
- Heading levels skipped or multiple H1s

Quality (human-facing note, do not render a verdict in the automated check):

- `alt="image"`, `alt="photo"`, `alt="icon"` — describes format, not content
- `alt="IMG_20250115_143022.jpg"` — filename as alt text (borderline: treat as effectively missing)
- `alt` text that repeats adjacent text content
- Decorative images with descriptive alt (creates noise)
- H1 used as a site logo/brand on every page instead of page-specific title
- Heading levels chosen for font size rather than structure
- Charts and graphs with `alt="chart"` instead of describing the data

## Reporting

When this reference informs a finding: report only structural/presence issues as findings with confidence and WCAG citation. Alt-text and heading *quality* observations should be surfaced as suggestions for human review, explicitly labeled as such — not as pass/fail verdicts.
