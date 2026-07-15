# Data Tables Reference

Checklist for review agent: read when diff shows data table, sortable table, grid, spreadsheet-like interface, comparison table, pricing table, or other tabular data display. Not an agent, no tools, no autonomous action — loaded on demand to inform what review agent reports.

<!-- Adapted from Community-Access/accessibility-agents, claude-code-plugin/agents/tables-data-specialist.md, upstream commit 0872b4a, copied 2026-07-10 -->
<!-- Text compressed with the caveman skill to reduce token load -->

## Authoritative Sources

- **WCAG 1.3.1 Info and Relationships** — <https://www.w3.org/WAI/WCAG22/Understanding/info-and-relationships.html>
- **WAI Tables Tutorial** — <https://www.w3.org/WAI/tutorials/tables/>
- **HTML Tables** — <https://html.spec.whatwg.org/multipage/tables.html>
- **ARIA Grid Pattern** — <https://www.w3.org/WAI/ARIA/apg/patterns/grid/>
- **ARIA Table Role** — <https://www.w3.org/TR/wai-aria-1.2/#table>

Tables: one of the most broken areas of web accessibility. Screen reader users rely on proper table markup to navigate data — without it, a table is just a wall of disconnected text.

## Scope

Covers tabular data accessibility:

- Table markup and structure (`<table>`, `<thead>`, `<tbody>`, `<tfoot>`)
- Column and row headers (`<th>`, `scope`, `headers`)
- Table captions and summaries
- Sortable columns (`aria-sort`)
- Responsive table patterns
- ARIA grid and treegrid roles
- Data grids with interactive cells
- Comparison and pricing tables
- Layout tables (and why they shouldn't exist)
- Merged cells (`colspan`, `rowspan`)
- Pagination and virtual scrolling in tables

## Simple Data Tables

### The Basics

Every data table needs these elements:

```html
<table>
  <caption>Quarterly sales by region, 2025</caption>
  <thead>
    <tr>
      <th scope="col">Region</th>
      <th scope="col">Q1</th>
      <th scope="col">Q2</th>
      <th scope="col">Q3</th>
      <th scope="col">Q4</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th scope="row">North America</th>
      <td>$2.1M</td>
      <td>$2.4M</td>
      <td>$2.8M</td>
      <td>$3.1M</td>
    </tr>
    <tr>
      <th scope="row">Europe</th>
      <td>$1.8M</td>
      <td>$1.9M</td>
      <td>$2.2M</td>
      <td>$2.5M</td>
    </tr>
  </tbody>
</table>
```

Requirements:

- `<caption>` describes table contents — this is the table's accessible name. MUST be first child element after `<table>`
- `<th>` for all header cells, never `<td>` styled to look like header
- `scope="col"` on column headers, `scope="row"` on row headers — always explicit, even with only one header row
- `<thead>` wraps header row(s), `<tbody>` wraps data rows
- `<tfoot>` for summary/total rows if present

### Structural Clarifications (per WebAIM)

**`<thead>`, `<tbody>`, `<tfoot>`** provide no accessibility semantics — screen readers don't use them. Exist for CSS styling, print rendering, fixed-header scrolling. Still use for code organization, but don't rely on them for accessibility.

**`summary` attribute** deprecated in HTML5. Use `<caption>` for table's accessible name. Longer description needed → `aria-describedby` pointing to paragraph outside table.

**`headers`/`id` associations**: last resort. Prefer `scope` on every `<th>`. Only use `headers`/`id` when table has irregular header spans `scope` can't express. Over-complex `headers`/`id` markup is fragile, error-prone.

**Proportional sizing:** Use percentage/relative widths (`width: 30%`, `min-width: 8em`) not fixed pixel widths. Prevents horizontal scrolling at increased text sizes (WCAG 1.4.10 Reflow).

**Flatten when possible:** Table requiring nested `colspan`/`rowspan` spanning 3+ levels → consider restructuring into simpler tables. Complex spanning creates substantial screen reader navigation difficulty.

### Why `scope` Matters

Without `scope`, screen readers guess which headers apply to which cells. Simple tables: often guess correctly. Complex tables: will guess wrong. Always be explicit.

```html
<!-- BAD: Screen reader has to guess -->
<th>Region</th>

<!-- GOOD: Explicit relationship -->
<th scope="col">Region</th>
```

## Complex Tables

### Multi-Level Headers

When a table has headers spanning multiple columns or rows:

```html
<table>
  <caption>Employee schedule, week of January 20</caption>
  <thead>
    <tr>
      <td></td>
      <th scope="col" colspan="2">Morning</th>
      <th scope="col" colspan="2">Afternoon</th>
    </tr>
    <tr>
      <td></td>
      <th scope="col">Task</th>
      <th scope="col">Location</th>
      <th scope="col">Task</th>
      <th scope="col">Location</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th scope="row">Monday</th>
      <td>Code review</td>
      <td>Remote</td>
      <td>Sprint planning</td>
      <td>Room 4A</td>
    </tr>
  </tbody>
</table>
```

### The `headers` Attribute

Truly complex tables where `scope` is insufficient (cells relate to headers non-obviously) → use `headers` attribute:

```html
<table>
  <caption>Test results by browser and operating system</caption>
  <thead>
    <tr>
      <td></td>
      <th id="chrome" scope="col">Chrome</th>
      <th id="firefox" scope="col">Firefox</th>
      <th id="safari" scope="col">Safari</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th id="windows" scope="row">Windows</th>
      <td headers="chrome windows">Pass</td>
      <td headers="firefox windows">Pass</td>
      <td headers="safari windows">N/A</td>
    </tr>
    <tr>
      <th id="macos" scope="row">macOS</th>
      <td headers="chrome macos">Pass</td>
      <td headers="firefox macos">Pass</td>
      <td headers="safari macos">Fail</td>
    </tr>
  </tbody>
</table>
```

Each cell's `headers` attribute lists IDs of all applicable headers. Screen readers announce these when user navigates to the cell.

## Sortable Tables

```html
<table>
  <caption>User accounts</caption>
  <thead>
    <tr>
      <th scope="col" aria-sort="ascending">
        <button>
          Name
          <span aria-hidden="true">^</span>
        </button>
      </th>
      <th scope="col" aria-sort="none">
        <button>
          Email
          <span aria-hidden="true"></span>
        </button>
      </th>
      <th scope="col" aria-sort="none">
        <button>
          Joined
          <span aria-hidden="true"></span>
        </button>
      </th>
    </tr>
  </thead>
  <tbody>
    <!-- sorted data rows -->
  </tbody>
</table>
```

Requirements:

- Sort buttons inside `<th>` elements
- `aria-sort` on `<th>`: `"ascending"`, `"descending"`, or `"none"`
- Only one column can have `aria-sort="ascending"` or `"descending"` at a time
- Update `aria-sort` on click-to-sort
- Visual sort indicator (arrow/chevron) with `aria-hidden="true"` — `aria-sort` is the accessible indicator
- Announce sort change via live region or `aria-sort` update

```javascript
function sortColumn(th, direction) {
  // Reset all columns
  document.querySelectorAll('th[aria-sort]').forEach(h => {
    h.setAttribute('aria-sort', 'none');
  });
  // Set the active column
  th.setAttribute('aria-sort', direction);
  // Sort the data...
}
```

## Interactive Data Grids

Table with interactive content (editable cells, inline actions, checkboxes) → use ARIA grid pattern:

```html
<table role="grid" aria-label="User management">
  <thead>
    <tr>
      <th scope="col">
        <input type="checkbox" aria-label="Select all users">
      </th>
      <th scope="col">Name</th>
      <th scope="col">Role</th>
      <th scope="col">Actions</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>
        <input type="checkbox" aria-label="Select Jane Smith">
      </td>
      <td>Jane Smith</td>
      <td>
        <select aria-label="Role for Jane Smith">
          <option>Admin</option>
          <option selected>Editor</option>
          <option>Viewer</option>
        </select>
      </td>
      <td>
        <button aria-label="Edit Jane Smith">Edit</button>
        <button aria-label="Delete Jane Smith">Delete</button>
      </td>
    </tr>
  </tbody>
</table>
```

Requirements for `role="grid"`:

- Arrow keys navigate between cells
- Tab moves to next interactive element within grid, then exits grid
- Enter/Space activates focused cell's interactive element
- Every interactive element inside cells needs descriptive `aria-label` with context (not just "Edit" — "Edit Jane Smith")
- `role="grid"` goes on `<table>`, not individual cells
- Only use `role="grid"` when cells are interactive — plain data tables should NOT have `role="grid"`

## Select-All Checkboxes

```html
<th scope="col">
  <input type="checkbox" 
         aria-label="Select all users" 
         id="select-all"
         aria-checked="mixed">
</th>
```

Three states:

- **Unchecked**: No rows selected
- **Checked**: All rows selected
- **Mixed/indeterminate**: Some rows selected — set via `checkbox.indeterminate = true`

When select-all state changes, announce result:

```javascript
selectAll.addEventListener('change', () => {
  const count = getSelectedCount();
  liveRegion.textContent = selectAll.checked 
    ? `All ${total} users selected` 
    : 'All users deselected';
});
```

## Row Selection and Actions

```html
<tr aria-selected="true">
  <td><input type="checkbox" checked aria-label="Selected: Jane Smith"></td>
  <td>Jane Smith</td>
  <!-- ... -->
</tr>
```

- Use `aria-selected="true"` on selected rows
- Bulk action buttons outside table: enable/disable based on selection
- Announce selection count changes via live region
- Provide keyboard shortcut for select all (Ctrl+A when grid focused)

## Responsive Tables

### Approach 1: Horizontal Scroll

```html
<div role="region" aria-label="User accounts" tabindex="0">
  <table>
    <!-- full table -->
  </table>
</div>
```

- Wrap in `<div>` with `role="region"` and `aria-label`
- Add `tabindex="0"` so keyboard users can scroll
- Add `overflow-x: auto` on wrapper
- Visual scroll indicator so users know there's more content

### Approach 2: Stacked Cards on Mobile

```css
@media (max-width: 768px) {
  table, thead, tbody, th, td, tr {
    display: block;
  }
  thead { display: none; } /* Hide visual headers */
  td::before {
    content: attr(data-label); /* Show header as label */
    font-weight: bold;
  }
}
```

```html
<td data-label="Name">Jane Smith</td>
<td data-label="Email">jane@example.com</td>
```

Requirements for stacked pattern:

- Each cell's header must be visible (via `data-label` or other technique)
- `<thead>` visually hidden but remains in DOM for screen readers
- Row boundaries clear (borders, spacing, visual grouping)

### Approach 3: Priority Columns

Show only essential columns on mobile, with "View details" button per row:

```html
<tr>
  <td>Jane Smith</td>
  <td class="hide-mobile">jane@example.com</td>
  <td class="hide-mobile">Admin</td>
  <td>
    <button aria-label="View details for Jane Smith">Details</button>
  </td>
</tr>
```

Use `aria-hidden` and `display: none` together — never `aria-hidden` alone for hidden content.

## Pagination

```html
<table aria-describedby="table-info">
  <!-- table content -->
</table>
<p id="table-info">Showing 1-10 of 247 results</p>
<nav aria-label="Table pagination">
  <button aria-label="Previous page" disabled>Previous</button>
  <button aria-current="page" aria-label="Page 1">1</button>
  <button aria-label="Page 2">2</button>
  <button aria-label="Page 3">3</button>
  <button aria-label="Next page">Next</button>
</nav>
<div aria-live="polite" class="visually-hidden" id="page-status"></div>
```

Requirements:

- `aria-current="page"` on current page button
- `aria-label` on each page button with page number
- Disabled buttons use `disabled` attribute (not `aria-disabled` for pagination)
- Live region announces page changes: "Page 2 of 25, showing results 11-20"
- Focus management: after page change, move focus to first row or table caption

## Empty States

```html
<table>
  <caption>Search results</caption>
  <thead>
    <tr>
      <th scope="col">Name</th>
      <th scope="col">Date</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td colspan="2">
        <p>No results found. Try adjusting your search filters.</p>
      </td>
    </tr>
  </tbody>
</table>
```

- Use `colspan` to span full width
- Provide helpful message, not just "No data"
- Announce empty state via live region if it results from filter/search action

## Layout Tables — Detection and Remediation

Tables used for layout (not data) are an accessibility antipattern. Per WebAIM, a layout table is identified by:

- No `<th>` elements
- No `<caption>` element
- No `scope` or `headers` attributes
- Data makes no logical sense read in table cell order

```html
<!-- NEVER DO THIS -->
<table>
  <tr>
    <td>Sidebar content</td>
    <td>Main content</td>
  </tr>
</table>

<!-- If you absolutely must (legacy code), strip the semantics -->
<table role="presentation">
  <tr>
    <td>Sidebar content</td>
    <td>Main content</td>
  </tr>
</table>
```

- `role="presentation"` removes table semantics from screen readers
- No `<th>`, `<caption>`, `scope`, or `headers` on layout tables
- Correct fix always: CSS Grid or Flexbox instead
- Remediating legacy layout tables: ensure data still presented in logical, meaningful linear order when table structure removed

## Visual Data Grids Without Semantic Markup

CSS grid/flexbox layouts often display structured data (stats, metrics, KPIs, dashboards, pricing cards) that *looks* tabular/structured visually but uses only `<div>`/`<span>` elements. Screen readers linearize these into undifferentiated text.

### The Problem

```html
<!-- PROBLEMATIC: looks structured visually, but screen readers read
     "47 Specialized Agents 3 Platforms 52 Prompts" as one long line -->
<div class="stats-grid">
  <div>
    <span class="stat-number">47</span>
    <span class="stat-label">Specialized Agents</span>
  </div>
  <div>
    <span class="stat-number">3</span>
    <span class="stat-label">Platforms</span>
  </div>
</div>
```

### The Fix: Use `<dl>` for Key-Value Pairs

Data presenting label-value pairs (stat dashboards, profile fields, spec lists, pricing highlights):

```html
<dl class="stats-grid">
  <div class="stat-item">
    <dt class="stat-label">Specialized Agents</dt>
    <dd class="stat-number">47</dd>
  </div>
  <div class="stat-item">
    <dt class="stat-label">Platforms</dt>
    <dd class="stat-number">3</dd>
  </div>
</dl>
```

Use CSS `order: -1` on `<dd>` if value should display above label visually while keeping label first in DOM order for screen readers.

### When to Use `<table>` Instead

Data with multiple dimensions (rows AND columns) → use proper `<table>`. `<dl>` is for flat key-value lists.

### What to Flag

- Any CSS grid/flexbox container with 3+ child elements where each has "label"/"value" pattern using only `<div>`/`<span>`
- Stats bars, KPI dashboards, pricing highlights, feature counts, metric summaries using only generic elements
- Any visual grid of structured data without `<dl>`, `<table>`, or ARIA table/grid roles

## Validation Checklist

### Structure

1. Is `<table>` used for tabular data (not layout)?
2. Does table have `<caption>` or `aria-label`?
3. Are header cells `<th>` (not styled `<td>`)?
4. Do column headers have `scope="col"` and row headers `scope="row"`?
5. Are `<thead>`, `<tbody>`, `<tfoot>` used correctly?
6. Complex tables: are `headers` attributes correct?
7. Merged cells: do `colspan`/`rowspan` have correct header associations?

### Sorting

8. Do sortable columns have `aria-sort` attributes?
9. Is `aria-sort` updated when sort changes?
10. Are sort buttons inside `<th>` elements?
11. Is sort change announced (live region or `aria-sort` update)?

### Interactive

12. Do interactive tables use `role="grid"` appropriately?
13. Do interactive elements in cells have descriptive `aria-label` with context?
14. Does select-all checkbox handle indeterminate state?
15. Are row selections indicated with `aria-selected`?
16. Are selection count changes announced?

### Responsive

17. Is table scrollable on mobile with `role="region"` and `tabindex="0"`?
18. Or does stacked pattern retain header context per cell?
19. Are hidden columns properly hidden (not just `aria-hidden`)?

### Pagination

20. Does pagination have `aria-current="page"` on current page?
21. Are page changes announced via live region?
22. Is focus managed after page changes?
23. Is "showing X of Y" text linked via `aria-describedby`?

### General

24. Are empty states communicated with descriptive messages?
25. Are layout tables avoided (or marked with `role="presentation"`)?
26. Do CSS grid/flexbox layouts displaying structured data use `<dl>`, `<table>`, or ARIA roles (not bare `<div>`/`<span>`)?

## Common Mistakes to Catch

- CSS grid/flexbox layouts displaying key-value data (stats, metrics, KPIs) with only `<div>`/`<span>` — use `<dl>`/`<dt>`/`<dd>` for label-value pairs
- `<div>` grids styled to look like tables — screen readers can't navigate them as tables
- `<td>` elements styled bold to look like headers — use `<th>` with `scope`
- Missing `<caption>` — screen readers announce "table" with no description
- `scope` attribute on `<td>` elements (only valid on `<th>`)
- `aria-sort` on all columns simultaneously instead of just active sort column
- Sort buttons outside `<th>` (breaks header/button association)
- `role="grid"` on non-interactive data tables (adds unnecessary complexity for screen readers)
- Responsive tables hiding columns with `display: none` but not hiding from screen readers
- Inline edit controls without `aria-label` context ("Edit" button in 50 rows — edit what?)
- Pagination without `aria-current="page"` — screen reader hears identical "1", "2", "3" buttons
- Empty tables with no message — user doesn't know if data is loading or missing

## Reporting

When this reference informs a finding: report with severity, WCAG citation, location, current code, recommended fix, framed for human validation — review agent flags and suggests, doesn't autonomously apply fixes.

Diff shows structured key-value data (stats/metrics/KPI patterns) rendered with `<div>`/`<span>` only → cross-reference this file's "Visual Data Grids Without Semantic Markup" section rather than treating it purely as missing-table issue — correct fix is often `<dl>`, not `<table>`.
