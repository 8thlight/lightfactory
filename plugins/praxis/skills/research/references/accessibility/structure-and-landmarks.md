# Headings, Page Titles, and Landmarks

> Provenance and license: `PROVENANCE.md`, `LICENSE-community-access.md`.

Read this when the feature adds a page, a route, a layout, or a section of a long page.

## What to look for in the codebase

- The layout or shell component that renders `header`, `nav`, `main`, and `footer`, and whether a skip link exists.
- Where the page `<title>` is set, and whether a router updates it on navigation.
- A shared page-heading component, and whether it forces a level.
- `<section>` and `role="region"` use, and whether each carries an `aria-label`.

## Headings

- Exactly one H1 per page. It names the page's purpose. A site logo or brand is not the H1 on every page.
- Do not skip levels (H1 to H3). Returning to a higher level starts a new section and is fine.
- Choose the level for structure, not for size. Style headings with CSS.
- Headings are descriptive ("Pricing Plans", not "Section 1" or "Details"). Screen reader users list all headings on a page.
- The outline should read like a table of contents. If it does not, the headings are wrong.
- Modal headings start at H2, because the page H1 stays the H1.
- Use real heading elements, not a `div` with a heading class. No empty headings, and no headings inside buttons or links.

## Page titles

- Format "Page name - Site name". Unique for every page and describing its purpose.
- A single-page app updates `document.title` on every route change. Screen readers announce the title first when a page loads.
- A missing title, or the same generic title on every page, is a failure (2.4.2).

## Landmarks

- One `<main>` per page. `<header>` and `<footer>` at page level, not inside `<main>`.
- Several `<nav>` elements each need an `aria-label` to tell them apart.
- A `<section>` is a region landmark only when it has an `aria-label` or `aria-labelledby`. Without one it is a plain grouping.
- Do not add redundant ARIA roles to semantic landmark elements.
- Too many landmarks create noise. A typical single-page informational site needs about five or six (banner, navigation, main, content info). Add a region only for a section that is a real navigable destination, such as a search results panel or a dashboard sidebar. Heading navigation already covers ordinary sections.
- When a section has a heading, name the region with `aria-labelledby` pointing at the heading, not an `aria-label` with different text. Two names for one section read as two sections.
- Do not make regions of install snippets, demo panels, stats bars, promotional banners, or other content already inside `<main>`.
- A skip link ("Skip to main content") is the first focusable element and its target can take focus (`tabindex="-1"` on `main`).
- Language: `<html lang>` is mandatory (3.1.1). See `internationalization.md`.

## Criteria wording

| Criterion | Check |
|---|---|
| The page has one H1 and no skipped heading levels | `[auto]` |
| Each route sets a unique, descriptive title | `[auto]` |
| The page has one main landmark, and every repeated landmark type has a name | `[auto]` |
| A skip link is the first focusable element and moves focus to main | `[auto]` |
| The heading outline reads as a table of contents for the page | `[manual]` |
| Headings and titles describe their content to someone who cannot see the layout | `[manual]` |
