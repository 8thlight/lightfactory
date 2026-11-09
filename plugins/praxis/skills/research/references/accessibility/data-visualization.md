# Accessibility Reference: Charts, Graphs, and Dashboards

> **Source repo:** Community-Access/accessibility-agents (https://github.com/Community-Access/accessibility-agents)
> **Upstream commit:** `a538edc9edfb98cdd8bae96d6b79542874b478f7` (main, 2026-11-07)
> **Retrieved:** 2026-11-09
> **License:** MIT, Copyright (c) 2026 Taylor Arndt
> **Upstream files:**
> - `skills/kb-data-visualization-accessibility/SKILL.md`
> - `skills/data-visualization-accessibility/SKILL.md`
>
> **Adapted:** reorganized for research. Removed: the HTML and JavaScript samples, the library code blocks, and reviewer output rules. Library notes are kept as one line each and were current at retrieval, so confirm against the project's installed version. Criteria wording is new.

Read this when the feature draws a chart, graph, map, heatmap, or dashboard. Basic image alt text is in `images-and-names.md`, and tables in `tables.md`.

## What to look for in the codebase

- The charting library and its version (Highcharts, Chart.js, D3, Recharts, or another), and whether it renders SVG or canvas.
- Whether any accessibility module or option is enabled.
- An existing data table or text summary beside the chart.
- The chart color palette.

## Requirements

**Text alternative.** Every chart has a short text summary of its key takeaway and a data table alternative (visually hidden or toggleable). A static SVG chart uses `role="img"` with a title and description (see `images-and-names.md`), plus a link to the table. A decorative chart is `aria-hidden`.

**By chart type**

| Chart | What to provide |
|---|---|
| Bar or column | Takeaway text and a data table. Each bar focusable, announcing its value. Patterns or textures as well as color. |
| Line | The trend in words and a table of all points. Left and Right arrows move between points. Distinct line styles as well as colors. |
| Pie or donut | A table of percentages and focusable segments with label and percentage. Patterns, since color alone fails 1.4.1. Upstream notes pie charts are often a poor choice, and a bar chart with a table is usually better. |
| Scatter | Summary statistics as text and a table of points. Keyboard exploration of large datasets may not be feasible, so prioritize the summary. |
| Treemap or heatmap | A hierarchical table alternative, keyboard movement through segments with values announced, and enough contrast between adjacent levels. |

**Interactive charts**
- Data points are focusable with a name and value. Avoid `role="application"`, which turns off screen reader browse mode, unless every interaction is built and tested.
- Keyboard model: Tab enters and leaves the chart, Left and Right move between points, Up and Down move between series, Enter or Space shows detail, Escape exits a drill-down, Home and End jump to the first and last point.
- On a dashboard, Tab moves between chart widgets, Enter enters an interactive chart, and Escape returns to the dashboard.
- Announce focus changes with chart type, title, and summary first, then each point's value. Announce trends, not only values.

**Color**
- Never rely on red versus green. Add a second channel (pattern, shape, label, or position). Direct labels on points beat a color-coded legend.
- Adjacent chart colors need enough contrast with each other, not only with the background.
- Upstream's color-vision-safe set is the Wong palette: black `#000000`, orange `#E69F00`, sky blue `#56B4E9`, bluish green `#009E73`, yellow `#F0E442`, blue `#0072B2`, vermillion `#D55E00`, reddish purple `#CC79A7`. The upstream describes them as color-vision safe. It does not say they meet contrast against any background, so check each one.
- Test with a color-vision simulator, such as the Chrome DevTools vision emulation.

**Responsive.** Charts reflow at 400% zoom, pointer targets are at least 24 by 24 CSS px, and text scales.

**Library notes** (as of upstream's retrieval)
- Highcharts: load its accessibility module. Without it the chart lacks keyboard navigation and announcements. Its data table view needs the exporting modules.
- Chart.js: draws to canvas, so there are no DOM nodes. It needs `role="img"` and an `aria-label`, or a fallback table, and custom keyboard navigation.
- D3: draws SVG with no accessibility built in. Add roles, names, focus, and keys yourself.
- Recharts: `accessibilityLayer` adds keyboard navigation and basic ARIA. It is on by default in Recharts 3 and opt-in in 2.x. Add a data table anyway.

## Common failures

- A canvas chart with no label or table.
- Series told apart by color alone.
- Hover-only tooltips with no keyboard path.
- Interactive charts built on `role="application"`.
- Chart image with a one-word alt text.
- A dashboard where Tab walks through every data point.

## Criteria wording

| Criterion | Check |
|---|---|
| The chart has a text summary and a data table alternative with the same data | `[auto]` |
| Each data point is reachable by keyboard and exposes its name and value | `[auto]` |
| Series are distinguishable without color | `[manual]` |
| The summary states the main takeaway, not only the chart type | `[manual]` |
| A screen reader announces chart type, title, and a point's value in a useful order | `[manual]` |

## Questions for the research report

- Is the chart library canvas or SVG based, and does it ship an accessibility option the project has turned off?
- Can the table alternative come from the same data the chart draws?
