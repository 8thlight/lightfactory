# Language and Text Direction

> Provenance and license: `PROVENANCE.md`, `LICENSE-community-access.md`.

Read this when the feature ships in more than one language, supports a right-to-left language, or mixes languages in one view.

## What to look for in the codebase

- An i18n library and the list of supported locales, and whether any is right-to-left (Arabic, Hebrew, Persian, Urdu).
- Where `<html lang>` and `dir` are set, and whether they change with the locale.
- CSS that uses physical properties (`margin-left`, `padding-right`, `float: left`).
- User-generated or mixed-language content.
- Directional icons (arrows, back and forward chevrons).

## Requirements

**Language**
- `<html>` has a valid `lang` attribute (3.1.1), and it follows the active locale.
- Inline content in another language has its own `lang` (3.1.2). Screen readers switch pronunciation by it.
- Use BCP 47 tags, such as `en`, `es`, `fr`, `de`, `ja`, `ko`, `zh-Hans`, `ar`, `he`, `fa`, `ur`.

**Direction**
- `<html dir="rtl">` for right-to-left languages.
- `dir="auto"` for user-generated content. Isolate mixed-direction runs with `<bdi>` or `unicode-bidi: isolate`.
- Use logical CSS properties (`margin-inline-start`, not `margin-left`).
- Directional icons flip in right-to-left layouts. Non-directional icons do not.

**Forms**
- A right-to-left label with a left-to-right value needs `dir="ltr"` on the input.
- `type="email"`, `type="url"`, and `type="tel"` fields are always left-to-right.

## Common failures

- `lang` hard-coded to `en` while the content is not English.
- Mixed-language text read in the wrong accent.
- A right-to-left locale that keeps a left-to-right layout, with icons not mirrored.
- Physical CSS properties that break the layout when direction changes.
- Mixed-direction text that reorders punctuation or numbers.

## Criteria wording

| Criterion | Check |
|---|---|
| `<html lang>` matches the active locale on every page | `[auto]` |
| Content in another language has its own `lang` | `[auto]` |
| In a right-to-left locale, `<html dir="rtl">` is set and layout uses logical properties | `[auto]` |
| Mixed-direction text and form values render in the correct order | `[manual]` |
| A screen reader pronounces each language correctly | `[manual]` |
| Directional icons are mirrored and non-directional ones are not | `[manual]` |

## Questions for the research report

- Which locales are supported or planned, and is any right-to-left? If only one language, record "not applicable" for direction and keep the `lang` check.
