<!-- Adapted from an 8th Light client project using Rails with Stimulus/Turbo, genericized 2026-07-14. Historical PR numbers and reviewer attributions were stripped and replaced with generalized illustrative examples. -->

# Stimulus Controller Lifecycle

Reference material for Stimulus/Turbo review agent. Load when diff touches a `*_controller.js` file and changed lines involve `connect()`, `disconnect()`, `initialize()`, a `[name]TargetConnected`/`Disconnected` callback, `Object.assign(this, ...)`, timers, direct DOM queries, or focus/blur handling. Not itself an agent — no tools, no autonomous action. Findings for human developer to confirm/fix.

## Authoritative Source

- **Stimulus Lifecycle Callbacks** — <https://stimulus.hotwired.dev/reference/lifecycle-callbacks>

## Lifecycle Execution Order

1. `initialize()` — once, when the controller is first instantiated
2. `[name]TargetConnected(target)` — when a target connects to the DOM
3. `connect()` — when the controller connects to the DOM
4. `[name]TargetDisconnected(target)` — when a target disconnects from the DOM
5. `disconnect()` — when the controller disconnects from the DOM

## Official Best Practices

- Use `initialize()` for one-time setup only — doesn't re-run when Turbo reconnects controller to DOM.
- Use `connect()` for setup that must repeat on reconnection (Turbo page visits, DOM re-attachment via morphing/frames).
- Implement `disconnect()` to remove event listeners, cancel timers, release any external resource acquired in `connect()`.
- Never assume synchronous execution — lifecycle callbacks run asynchronously in next microtask.

## What to Flag

### Missing Timer/Interval Cleanup

**Severity:** MAJOR (memory leak, compounds on every Turbo reconnect)

```javascript
connect() {
  this.timer = setInterval(() => this.poll(), 5000) // created…
}
// …but no disconnect() clears it — leaks on every Turbo navigation
```

Check: any controller creating `setInterval`/`setTimeout` in `connect()`/`initialize()` must clear it in `disconnect()`.

### `Object.assign(this, mixin)` Overriding Lifecycle Methods

**Severity:** CRITICAL

```javascript
// BAD: replaces this controller's own lifecycle methods with the mixin's
Object.assign(this, linkPanelMixin)

disconnect() {
  this.editor.destroy() // never called — the real disconnect() was overwritten
}
```

`Object.assign(this, mixin)` silently overwrites whatever `connect`/`disconnect`/`initialize` mixin defines onto controller instance. If controller also defines its own version of that method, one of the two is lost entirely — usually without error, since JS doesn't warn about clobbered methods. Has caused real production memory leaks (rich text editors, subscriptions, DOM listeners never torn down) when a mixin's `disconnect()` silently replaced controller's own.

**Fix:** Prefer explicit method delegation over `Object.assign` for anything that shares a lifecycle method name:

```javascript
connect() {
  this.setupLinkPanel()   // delegate to mixin helper by name
  this.editor = new Editor()
}

disconnect() {
  this.teardownLinkPanel() // delegate to mixin helper by name
  this.editor.destroy()    // controller-specific cleanup — not lost
}
```

**Flag if:** `Object.assign(this, ...)` appears in any Stimulus controller. Read referenced mixin (if visible in diff) to confirm whether it defines lifecycle methods that would collide.

### Missing DOM Elements in Shared Controllers

**Severity:** CRITICAL

```javascript
// Shared controller assumes an element exists unconditionally
connect() {
  const panel = document.querySelector('#link-bubble-panel')
  panel.addEventListener('click', ...) // throws when panel isn't present
}
```

A controller reused across multiple contexts (e.g. attached via shared `data-controller` value on very different pages) can't assume every optional collaborator element exists in every context. A `querySelector`/`getElementById` call with no null check throws the moment controller connects somewhere that element is absent — breaking an unrelated feature that happens to share the controller, with an error message that doesn't obviously point back to the missing element.

**Fix:** guard, or use Stimulus targets (with `has[Name]Target`) instead of raw DOM queries where element lives inside controller's own scope:

```javascript
connect() {
  const panel = document.querySelector('#link-bubble-panel')
  if (!panel) {
    return // graceful no-op in contexts without this collaborator
  }
  panel.addEventListener('click', ...)
}
```

**Flag if:** shared/reusable controller queries DOM directly without existence check, especially for an element optional depending on page/context controller is mounted in.

### Cross-Browser Focus/Blur Behavior

**Severity:** CRITICAL (silent, browser-specific failure)

```javascript
focusOut(event) {
  if (!this.element.contains(event.relatedTarget)) {
    this.dismiss() // fires on button click in Firefox/Safari!
  }
}
```

Browsers disagree on whether clicking a `<button>` moves focus to it. Chrome focuses button on click, so `relatedTarget` still points inside panel, guard correctly skips `dismiss()`. Firefox/Safari don't focus `<button>` elements on click by default — `relatedTarget` is `null`, guard fails, `dismiss()` fires before click handler underneath it runs. Result: feature works perfectly in Chrome, silently breaks in Firefox/Safari, no thrown error.

**Flag if:** `focusOut`/`focusIn`/`blur` handlers reference `relatedTarget` to decide whether to keep something open. Emit as REMINDER for human to manually test in Firefox/Safari — not something static analysis can confirm without a real browser.

## Validation Checklist

1. Does every `setInterval`/`setTimeout` created in `connect()`/`initialize()` have a matching clear in `disconnect()`?
2. Does `disconnect()` remove every event listener added in `connect()`?
3. Is `Object.assign(this, ...)` used anywhere a mixin might define a lifecycle method the controller also defines?
4. Does a shared/reusable controller guard every `querySelector`/`getElementById` call, or does it assume the element always exists?
5. Do any `focusOut`/`blur` handlers gate behavior on `relatedTarget` without a cross-browser test note?
