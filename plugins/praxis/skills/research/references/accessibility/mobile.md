# Mobile Principles (Platform-Neutral)

> Provenance and license: `PROVENANCE.md`, `LICENSE-community-access.md`.

Read this when the feature is a native or cross-platform mobile app, or a web app used mostly on phones and tablets. Web criteria still apply to mobile web (see `citing-wcag.md`).

## What to look for in the codebase

- The platform and UI toolkit, and whether the project wraps its tappable components.
- Pressable areas set smaller than the minimum sizes below.
- Gestures with no alternative: swipe, pinch, long press, drag, shake.
- Rows built from several separate text labels.
- Custom modals, sheets, and drawers.
- Locked screen orientation.
- The project's component test library and any end-to-end tool.

## Requirements

**Name, role, state, value.** The same four things a web control needs, whatever the platform calls them:
- Every interactive element has a name, and the name replaces its child text for assistive technology. Icon-only controls need one.
- Controls expose their role and their state (checked, expanded, selected, disabled, busy), and a value for sliders, steppers, and progress.
- A hint is for when the action is not obvious from name and role.
- Informational images have a label. Decorative images are hidden from assistive technology.
- Placeholder text is not a label.

**Touch targets**

| Platform | Minimum | Source |
|---|---|---|
| iOS | 44 x 44 pt | Apple Human Interface Guidelines |
| Android | 48 x 48 dp | Material Design |
| Mobile web, AA | 24 x 24 CSS px, or spacing between targets | WCAG 2.5.8 |
| Mobile web, AAA | 44 x 44 CSS px | WCAG 2.5.5 |

A control can look small and still meet the size by padding its pressable area. Content size inside a padded target still matters.

**Gestures and motion**
- Anything done with a multipoint or path gesture (pinch, swipe, draw) is also doable with a single-point gesture (2.5.1).
- A single-pointer action can be canceled before it completes: it fires on release, can be aborted by sliding off, or can be undone (2.5.2).
- Anything triggered by shaking or tilting also has an on-screen control, and the motion trigger can be turned off (2.5.4).
- Anything done by dragging can be done without dragging, for example "move up" and "move down" buttons (2.5.7).
- Custom actions (an actions menu on an item) are a route to replace long-press and swipe actions for assistive technology.
- Do not lock the screen to portrait or landscape unless essential (1.3.4). A wheelchair-mounted tablet may only ever be landscape.

**Reading order and grouping**
- Screen readers read in layout order, top-left to bottom-right. Override only when the visual order and the logical order differ.
- One phrase, one stop. A row made of title, subtitle, and time costs one swipe per label. When the pieces read as one phrase, expose the row as one element with one label. Group static text only. On some platforms a control inside a grouped row can no longer be reached on its own.
- Web content inside a mobile web view splits phrases the same way when flex or grid items drop the space between words, so check it on a device.

**Focus and dynamic content**
- After navigation or opening a modal, move assistive technology focus to the new content.
- A modal, sheet, or drawer keeps the screen reader inside it. Nothing behind it is reachable.
- Status changes are announced by a live region equivalent, polite by default (see `live-regions.md`).
- Every interactive element is reachable without touch: with an external keyboard, directional pad, or switch access. Custom views must be focusable for that to work.

**Testing**
- Run the platform inspector: Xcode Accessibility Inspector on iOS (its audit and inspection), and Google's Accessibility Scanner on Android.
- VoiceOver does not run in the iOS Simulator. Test it on a device. Test TalkBack on an Android device too.
- Component tests use role-and-name queries from the project's test library. End-to-end tools match on the accessible label.

## Common failures

- Icon-only buttons with no name.
- Pressable areas under the platform minimum.
- A swipe or long press as the only way to do something.
- A list row that takes three swipes to read one phrase.
- A custom modal that lets the screen reader reach the screen behind it.
- Focus left behind after a navigation.
- Orientation locked with no reason.

## Criteria wording

| Criterion | Check |
|---|---|
| Each interactive element exposes a name, role, and its state | `[auto]` |
| Each pressable area meets the platform minimum size | `[auto]` |
| Each gesture action has a single-point alternative | `[manual]` |
| Each list row reads as one phrase with one stop, and its controls stay reachable | `[manual]` |
| After a navigation or modal opens, the screen reader lands on the new content | `[manual]` |
| A screen reader on a physical device, VoiceOver and TalkBack, completes the main task | `[manual]` |
| The screen works in both orientations | `[manual]` |

## Questions for the research report

- Which platform and UI toolkit does the feature use, and does the project wrap its pressable components?
- Is there a device lab or only simulators, since VoiceOver needs a device?
