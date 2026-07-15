<!-- Adapted from an 8th Light client project using Rails with Stimulus/Turbo, genericized 2026-07-14. Historical PR numbers and reviewer attributions were stripped and replaced with generalized illustrative examples. -->

# Turbo Frames

Reference material for Stimulus/Turbo review agent. Load when diff adds/changes `<turbo-frame>` elements, `turbo_frame_tag` helper calls, `data-turbo-frame` attributes, or a component rendering a `<turbo-frame>`. Not itself an agent — no tools, no autonomous action. Findings for human developer to confirm/fix.

## Authoritative Source

- **Turbo Handbook: Frames** — <https://turbo.hotwired.dev/handbook/frames>

## ID Uniqueness Requirement

Each `<turbo-frame>` on a page must have unique `id`. Turbo matches response content to frames by ID — duplicate IDs in same DOM produce unpredictable behavior: updates land in wrong frame instance, or navigation targets wrong one.

## Lazy Loading

```html
<turbo-frame id="messages" src="/messages" loading="lazy">
  Content replaced when the frame becomes visible
</turbo-frame>
```

## Navigation Scoping

- Default: links/forms inside a frame target that frame only.
- `target="_top"` navigates entire page.
- `target="[frame-id]"` targets specific frame from outside it.
- `data-turbo-frame` on individual link/form gives granular per-element control.

## Official Pitfalls

- Server response missing expected frame element causes Turbo to raise exception.
- Frame used purely for styling/layout adds overhead with no benefit — frames are for scoped navigation/partial updates, not layout.
- Excessive eager-loading frames on one page creates visible load-in jitter.
- Cache complexity increases with number of frames on a page.

## What to Flag

### Duplicate Turbo Frame IDs From Component Reuse

**Severity:** CRITICAL

```erb
<%# A shared search component rendered in two different contexts on the same page %>

<%# Inside a rich-text editor's link panel %>
<turbo-frame id="pages-search">...</turbo-frame>

<%# Inside a separate "link to page" picker, also open on the same page %>
<turbo-frame id="pages-search">...</turbo-frame>

<%# Result: two frames with id="pages-search" live in the DOM at once → breaks Turbo %>
```

Most common source of duplicate-ID bugs: a shared component rendering a `<turbo-frame>` gets instantiated more than once on same page by two independent features, each unaware other exists. Neither usage site looks wrong in isolation — ID collision only shows up when both live in DOM simultaneously, which static review of a single diff hunk can miss.

**Detection approach:**

1. Find components/partials rendering a `<turbo-frame>` with hardcoded `id`.
2. Check whether that component is rendered from more than one call site (search codebase for component's usage, not just changed file).
3. If plausible both usage sites could be mounted on same page at same time, flag ID collision risk.

**Fix — one of:**

```erb
<%# Option 1: make the ID unique per instance %>
<turbo-frame id="pages-search-<%= dom_id %>">

<%# Option 2: scope the ID to the calling context %>
<turbo-frame id="pages-search-<%= context %>">

<%# Option 3: extract the diverging behavior into a separate, non-shared component %>
```

### Shared Component Side Effects From Frame-Scoped Styling Changes

**Severity:** MAJOR

Because a component rendering a `<turbo-frame>` is often reused across several features, a styling/markup change intended for one call site can leak visually/behaviorally to every other place that component is rendered.

**Detection approach:** for any changed component file under a shared components directory, search for all render call sites of that component. If change looks specific to one use case (e.g. new spacing/typography meant for a particular panel) but component itself is shared, flag it.

**Recommendation:** if new behavior applies only to one context, consider extracting a separate component/view for that context rather than special-casing the shared one.

## Validation Checklist

1. Does any changed `<turbo-frame id="...">` use a hardcoded ID inside a component that's rendered from more than one call site?
2. If duplicate IDs are plausible, could both usage sites realistically be mounted on the same page simultaneously?
3. Is a `<turbo-frame>` being added purely for layout/styling rather than scoped navigation or partial updates?
4. Does a styling/behavior change to a shared frame-rendering component affect only the intended call site, or could it leak to other usages?
5. Does the corresponding server action actually return a matching frame element in every response path (including error/redirect paths)?
