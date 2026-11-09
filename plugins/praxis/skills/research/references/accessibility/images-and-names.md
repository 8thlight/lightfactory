# Accessibility Reference: Images, Icons, and Accessible Names

> **Source repo:** Community-Access/accessibility-agents (https://github.com/Community-Access/accessibility-agents)
> **Upstream commit:** `a538edc9edfb98cdd8bae96d6b79542874b478f7` (main, 2026-11-07)
> **Retrieved:** 2026-11-09
> **License:** MIT, Copyright (c) 2026 Taylor Arndt
> **Upstream files:**
> - `skills/alt-text-headings/references/alternative-text-the-rules.md`
> - `skills/alt-text-headings/SKILL.md` (the `<picture>`, CSS background, form image button, and icon font sections)
> - `skills/alt-text-headings/references/video-and-audio.md` (the figure and figcaption section)
> - `skills/aria-specialist/references/landmark-and-region-overuse.md` (the Accessible Names and Descriptions section)
> - `skills/text-quality-reviewer/references/detection-rules.md`
>
> **Adapted:** merged three upstream areas (alt text, accessible names, bad-name detection) into one file for research. Detection rules are condensed to the patterns a person can grep for. Fix code and severity labels removed. Criteria wording is new.

Read this when the feature shows images, icons, SVGs, or icon-only controls, or when control names come from data or translations.

## What to look for in the codebase

- An image or icon component and whether it requires an alt or label prop.
- Where names come from: hard-coded strings, a CMS, a translation file, or a template. Data-driven names fail in bulk.
- Icon sets (SVG components, icon fonts) and how they are hidden.
- Charts and diagrams, which have their own file (`data-visualization.md`).

## Images

- Every `<img>` has an `alt` attribute. The question is what goes in it.
- Meaningful images: describe what the image communicates in context, not how it looks. The same photo can need different alt text on different pages.
- Functional images (inside a link or button): describe the destination or action ("Acme Corp home page", "Print this page"), not the picture.
- Decorative images: `alt=""`. On an `img` this already removes it from the accessibility tree. Use `aria-hidden="true"` for decorative inline SVGs and other decorative elements with no `alt`.
- Alt text that repeats adjacent visible text adds noise ("Photo of our CEO" under a heading "Our CEO").
- Complex images (charts, diagrams, infographics): a short alt plus a long description, either visible adjacent text or `aria-describedby`.
- `<picture>`: the `alt` goes on the inner `<img>` and must fit every source variant.
- CSS background images are invisible to screen readers, so they must be decorative. Meaningful ones become an `<img>`.
- `<figure>`: the `<img>` still needs its own `alt`. `<figcaption>` does not replace it, and the two should complement and not repeat each other.
- Image buttons (`input type="image"`) describe the function ("Search"), not the image.

## SVGs and icons

- Meaningful inline SVG: `role="img"`, a `<title>` as first child, an optional `<desc>`, and `aria-labelledby` naming both. Do not add `focusable="false"` to a meaningful SVG.
- Decorative inline SVG: `aria-hidden="true"`, `focusable="false"`, no `<title>` or `<desc>`.
- Icon with visible text: hide the icon. Icon-only control: hide the icon and label the control itself.
- Never name both the SVG and its button or link, which causes a double announcement.
- Icon fonts: always `aria-hidden="true"`, never rely on ligatures for a name, and put the name on the interactive parent.

## Accessible names

- Prefer visible text and native labeling (`<label>`, `<caption>`, `<legend>`, `<figcaption>`) over `aria-label`. Do not rely on `title` or `placeholder` as a name.
- Name precedence, first match wins: `aria-labelledby`, `aria-label`, native mechanisms (`label`, `alt`, `caption`, `legend`), content text for roles named from content, `title`, `placeholder`.
- `aria-label` on a role named from content (heading, button, link) replaces all descendant text for assistive technology. Do not put it on headings or paragraphs.
- A name describes function, not form ("Close", not "X icon"), starts with the distinguishing word ("Delete account"), is brief (one to three words), does not include the role ("Close", not "Close button"), and is unique ("Edit profile" and "Edit preferences", not two "Edit").
- The accessible name must contain the visible label text (2.5.3 Label in Name), or speech-input users cannot activate the control.
- Descriptions go in `aria-describedby` pointing at visible text. `aria-description` is in WAI-ARIA 1.3, which is a Working Draft, and support varies.

## Bad names to grep for

| Pattern | Examples |
|---|---|
| Unresolved template or code syntax | `{0}`, `{{name}}`, `${item.title}`, `%s`, `property.altText`, `heroImageAlt`, `getAltText()` |
| Placeholder or filler | `TODO`, `lorem ipsum`, `test`, `untitled`, `null`, `undefined`, and bare `image`, `photo`, `icon`, `logo` |
| The attribute or role as its own value | `alt="alt text"`, `aria-label="button"`, a button whose text is "Button" |
| Empty or whitespace-only names | `alt=" "`, a zero-width space |
| Duplicate names on different actions | three buttons all named "Delete" |
| Filenames and paths | `DSC_0492.jpg`, `/media/photo-123.webp` |
| One-character names | `alt="i"`, `aria-label="?"` (icon buttons with a full `aria-label` are fine) |
| Name that does not contain the visible text | visible "Settings", `aria-label="Manage your profile"` |
| Raw or unloaded data | `[object Object]`, `undefined`, a "0 items" name where zero makes no sense |

## Common failures

- Missing `alt`, so the screen reader reads the filename.
- Decorative images with descriptive alt text.
- Icon-only buttons with no name.
- SVGs with neither a title nor `aria-hidden`.
- Icon fonts announced as private-use characters.
- Names built from data fields that can be empty.

## Criteria wording

| Criterion | Check |
|---|---|
| Every image has an `alt` attribute, and decorative images have an empty one | `[auto]` |
| Every icon-only control has an accessible name | `[auto]` |
| No accessible name contains template syntax, a filename, or placeholder text | `[auto]` |
| Controls that do different things have different names | `[auto]` |
| Each control's name contains its visible text | `[auto]` |
| Alt text conveys the image's purpose in this context | `[manual]` |
| Long descriptions for complex images say what a sighted user takes from them | `[manual]` |

## Questions for the research report

- Where do image and control names come from, and what happens when the source is empty?
- Does the project's image or icon component enforce an alt or label?
