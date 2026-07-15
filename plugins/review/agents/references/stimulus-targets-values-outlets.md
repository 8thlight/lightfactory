<!-- Adapted from an 8th Light client project using Rails with Stimulus/Turbo, genericized 2026-07-14. Historical PR numbers and reviewer attributions were stripped and replaced with generalized illustrative examples. -->

# Stimulus Targets, Values & Outlets

Reference for Stimulus/Turbo review agent. Load when diff touches `static targets`/`values`/`outlets` declarations, or `data-*-target`/`data-*-outlet` attr added/removed/renamed. Not an agent, no tools, no autonomous action. Findings for human dev to confirm/fix.

## Authoritative Source

- **Stimulus Targets** — <https://stimulus.hotwired.dev/reference/targets>
- **Stimulus Outlets** — <https://stimulus.hotwired.dev/reference/outlets>
- **Stimulus Values** — <https://stimulus.hotwired.dev/reference/values>

## Targets

```javascript
static targets = [ "query", "errorMessage", "results" ]
```

Generated properties:

- `this.[name]Target` — first match; **throws** if missing.
- `this.[name]Targets` — array of all matches.
- `this.has[Name]Target` — boolean presence check.

**Best practice:** guard optional target with `has[Name]Target` before singular access. Use `[name]TargetConnected`/`Disconnected` for targets appearing/disappearing dynamically.

### Unused Declared Targets

**Severity:** MAJOR

```javascript
static targets = [ "navReorderForm", "submitButton" ]

connect() {
  // submitButton is used; navReorderForm is never referenced anywhere
  this.submitButtonTarget.disabled = true
}
```

Declared-unreferenced target = dead code. Usually incomplete refactor; misleads readers into thinking controller depends on it.

**Flag if:** any `static targets` name has zero references (`this.[name]Target`, `[name]Targets`, `has[Name]Target`) anywhere in controller file.

### Ungated Singular Target Access

**Severity:** MAJOR

```javascript
// Throws if the "results" target isn't present in this render
this.resultsTarget.innerHTML = ""
```

**Flag if:** singular `this.[name]Target` accessed without prior `has[Name]Target` check, unless guaranteed present in every render path (e.g. static, always-rendered template).

## Outlets

Outlets let one controller reference another by CSS selector, via `data-{controller}-{outlet-name}-outlet` attribute.

### Outlet Removed From the DOM Without Controller Cleanup

**Severity:** CRITICAL — silent failure, no thrown error, tests still pass

```html
<!-- BEFORE -->
<div data-controller="page-editor-menu"
     data-page-editor-menu-autosave-outlet="#autosave">
  ...
</div>
```

```javascript
class PageEditorMenuController extends ApplicationController {
  static outlets = [ "autosave" ]

  connect() {
    this.autosaveOutlet?.scheduleSave() // becomes a silent no-op
  }
}
```

```html
<!-- AFTER: the outlet attribute is gone -->
<div data-controller="page-editor-menu">
  ...
</div>
```

Why dangerous:

1. **No runtime error** — `?.` turns broken ref into silent no-op.
2. **Tests stay green** — nothing to fail on.
3. **No compile-time check** — JS won't validate outlet still resolves.
4. **Looks harmless in diff** — reads as dead-code removal, not a break.

**Detection:**

1. Diff removes a `data-*-outlet="..."` attribute.
2. ID controller/outlet from attribute: `data-{controller}-{outlet-name}-outlet`.
3. Check `{controller}_controller.js` still references `this.{outletName}Outlet` (with/without `?.`).
4. If yes, and `static outlets` wasn't updated to drop it too → flag.

**Fix — one of:**

```javascript
// Option 1: remove the outlet usage and its declaration entirely
class PageEditorMenuController extends ApplicationController {
  // static outlets = [ "autosave" ]  ← removed
  connect() {
    // outlet usage removed
  }
}

// Option 2: keep the outlet but guard explicitly
connect() {
  if (this.hasAutosaveOutlet) {
    this.autosaveOutlet.scheduleSave()
  }
}

// Option 3: confirm the attribute move was intentional (e.g. moved to a different element)
```

**Output format for this specific finding:**

```markdown
### [CRITICAL] Stimulus Outlet Removed Without Controller Cleanup
- **Location:** <template file> (outlet attribute removed), <controller file>:<line> (still referenced)
- **Issue:** `data-{controller}-{outlet}-outlet` removed from the DOM but the controller still calls `this.{outlet}Outlet?.{method}()`
- **Impact:** The dependent feature silently stops working. Optional chaining prevents any error; tests pass; nothing signals the regression.
- **Fix:** Remove the outlet usage and its `static outlets` entry, add an explicit `has{Outlet}Outlet` guard, or confirm the removal was intentional.
- **Reference:** https://stimulus.hotwired.dev/reference/outlets
```

## Values

`static values` = typed, DOM-reflected properties. Flag: type mismatched vs usage (e.g. `Number` compared against string); `this.[name]Value` read with no `[name]ValueChanged` callback when controller must react to external attribute changes.

## Validation Checklist

1. Every declared target referenced in controller?
2. Every singular target access guarded by `has[Name]Target` unless guaranteed present?
3. Any `data-*-outlet` removed from template this diff? Controller still reference it?
4. If outlet ref remains: guarded, or was `static outlets` entry dropped too?
5. Declared `static values` types match actual usage?
