<!-- Adapted from an 8th Light client project using Rails with Stimulus/Turbo, genericized 2026-07-14. Historical PR numbers and reviewer attributions were stripped and replaced with generalized illustrative examples. -->

# Turbo Streams

Reference material for Stimulus/Turbo review agent. Load when diff adds/changes a `.turbo_stream.erb` file, or uses `turbo_stream.append/prepend/replace/update/remove`. Not itself an agent — no tools, no autonomous action. Findings for human developer to confirm/fix.

## Authoritative Source

- **Turbo Handbook: Streams** — <https://turbo.hotwired.dev/handbook/streams>

## Common Operations

- `turbo_stream.append` — add to the end of the target
- `turbo_stream.prepend` — add to the beginning of the target
- `turbo_stream.replace` — replace the target element
- `turbo_stream.update` — replace the target's contents
- `turbo_stream.remove` — remove the target element

Turbo Streams enable partial page updates without full reload — but response still renders server-side view partials, so every ordinary Rails view-layer risk (N+1 queries chief among them) applies just as much as in normal HTML response.

## What to Flag

### N+1 Queries in Turbo Stream Templates

**Severity:** CRITICAL

```erb
<%# BAD: N+1 queries %>
<%= turbo_stream.replace "nav_items" do %>
  <% @pages.each do |page| %>
    <% page.child_pages.each do |child| %>  <%# one query per page! %>
      <%= child.title %>
    <% end %>
  <% end %>
<% end %>
```

100 pages, each accessed for its `child_pages` without eager loading = 1 query for pages + 100 more for children — 101 total. Under load: database CPU spike, slow stream responses.

**Detection approach:**

1. In changed `.turbo_stream.erb` file, find `.each` loops accessing an association (`page.child_pages`, `.each do |child|` nested inside outer `.each`).
2. Trace controller action rendering this stream template (matched by naming convention, e.g. `pages/reorder.turbo_stream.erb` → `PagesController#reorder`).
3. Check whether that action eager-loads the association (`includes`, `eager_load`, `preload`).
4. If not, flag missing eager-load.

**Fix:**

```ruby
# Controller eager-loads the association used in the stream template
def reorder
  @pages = @site.pages.includes(:child_pages)
end
```

### Verify Root Cause Before Recommending a Query Fix

**Most important rule in this file.** Before suggesting `.includes()`, composite index, or any query-level optimization, verify what query is actually doing and why it's slow/wrong — don't pattern-match on code shape alone.

Worked example of getting this wrong: a review once assumed sort-order weirdness caused by NULL title values, recommended `NULLS LAST` clause — actual data had empty-string titles (`""`), not nulls; real fix was normalizing data, not reordering SQL. Lesson: **premise of a "fix" can be wrong even when symptom (slow, weird-looking results) is real.** Before recommending query change, check what data query actually returns — don't assume obvious-looking cause is real one.

**Flag as CRITICAL** (confirmed N+1) only when:
1. Turbo Stream template accesses association in a loop, **and**
2. Corresponding controller action visibly lacks eager loading for that association, **and**
3. Nothing in diff suggests "obvious" pattern might actually be data problem in disguise.

**Flag as "needs verification"** whenever actual root cause can't be confirmed from diff alone — e.g. controller action not visible, data shape unclear, or query pattern unusual enough that eager-loading might not be real fix. State limitation explicitly rather than asserting confirmed defect.

## Validation Checklist

1. Does the stream template loop over a collection and access an association per iteration?
2. Does the rendering controller action eager-load that association?
3. Is there any hint the underlying data itself (not the query shape) might be the actual root cause?
4. If the answer to (3) is unclear, is the finding labeled "needs verification" rather than asserted as a confirmed N+1?
