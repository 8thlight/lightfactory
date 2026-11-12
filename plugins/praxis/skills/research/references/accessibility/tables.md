# Tables and Data Grids

> Provenance and license: `PROVENANCE.md`, `LICENSE-community-access.md`.

Read this when the feature displays tabular data, adds sorting, or adds a grid with editable cells or row actions.

## What to look for in the codebase

- A table or grid component (TanStack Table, AG Grid, MUI DataGrid, or hand-built), and whether it renders real `<table>` markup or `div`s.
- Sorting, selection, and inline-edit support, and how the sort state is shown.
- Existing responsive behavior for narrow screens.

## Requirements

**Simple data tables**
- Tabular data is marked up as a `<table>`, or has equivalent table roles on every part, not a bare `div` grid.
- `<caption>` is the table's name and is the first child of `<table>`.
- Header cells are `<th>`, never styled `<td>`. Use `scope="col"` and `scope="row"` explicitly, even with one header row.
- `thead`, `tbody`, and `tfoot` carry no accessibility meaning. They are for styling and print.
- The `summary` attribute is obsolete. For a longer description, use `aria-describedby` pointing at a paragraph outside the table.
- Use `headers` and `id` only when irregular spans make `scope` insufficient. Flatten tables that span three or more levels of `colspan` or `rowspan`.
- Use relative widths so text resizing does not force horizontal scrolling (1.4.10).

**Sortable tables**
- The sort control is a `<button>` inside the `<th>`.
- `aria-sort` sits on the `<th>` with `ascending`, `descending`, or `none`. Only one column is sorted at a time, and the value updates on each sort.
- The arrow icon is `aria-hidden`. `aria-sort` is the accessible indicator, and the sort change is announced.

**Interactive grids**
- Use `role="grid"` only when cells are interactive. Plain data tables must not have it.
- The grid is one Tab stop. Arrow keys move between cells, and Enter or Space activates the cell's control.
- Controls inside cells carry context in their name ("Edit Jane Smith", not "Edit").

**Responsive**
- Horizontal scroll: a wrapper with `role="region"`, an `aria-label`, and `tabindex="0"` so keyboard users can scroll, plus a visible hint that more content exists.
- Stacked cards: each cell shows its header. Changing `display` on table elements can drop table semantics, so restore them with explicit roles and test with a screen reader. `display: none` on `thead` hides headers from screen readers too.
- Priority columns: hide with `display: none`, which also removes them for assistive technology. Never use `aria-hidden` alone.

## Criteria wording

| Criterion | Check |
|---|---|
| The table has an accessible name and header cells with a scope | `[auto]` |
| The sorted column exposes its direction through `aria-sort` | `[auto]` |
| Row action controls have names that identify the row | `[auto]` |
| A scrollable table region is reachable and scrollable by keyboard | `[auto]` |
| In a grid, arrow keys move between cells and the grid is a single Tab stop | `[auto]` |
| A screen reader reads each cell with its row and column header | `[manual]` |
| Sorting is announced by a screen reader | `[manual]` |
| The table is usable at 400% zoom without losing headers | `[manual]` |
