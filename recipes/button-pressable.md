---
id: f483dfb7-d60e-4b12-8b17-2eb150b550db
title: PressableButton
domain: agenticdevelopercookbook://recipes/button-pressable
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Client-side pointer-tracking layer that wraps the Base UI Button primitive
  and reflects a held/pressed state via data-pressed, composing with consumer pointer
  handlers.
platforms:
- web
tags:
- component
- button
- pointer-events
- pressable
- ui
depends-on: []
related:
- agenticdevelopercookbook://recipes/button
references: []
---

# PressableButton

## Overview

`PressableButton` is the `"use client"` interactivity layer for the shared
`Button` component. It wraps the Base UI `Button` primitive and tracks a
pointer-driven "held" and "pressed" state that CSS `:active` cannot express —
in particular, the case where the pointer is dragged out of the button while
still held, and dragged back in before release. It reflects the pressed state
via a `data-pressed` attribute for the consuming styles to key off of, and it
composes with any pointer handlers the caller supplies rather than replacing
them. It lives in its own module, separate from the plain `button.tsx` module
that computes the visual variant classes, so that module can stay free of a
`"use client"` directive and remain callable from server components. See
[Button](agenticdevelopercookbook://recipes/button) for the composed component,
its visual variants, and its accessibility surface.

## Behavioral Requirements

- **must-render-primitive-with-forwarded-props**: PressableButton MUST render the underlying Base UI `Button` primitive with every prop other than the five intercepted pointer handlers (`onPointerDown`, `onPointerUp`, `onPointerLeave`, `onPointerEnter`, `onPointerCancel`) passed through unchanged.
- **must-set-data-slot**: PressableButton MUST set `data-slot="button"` on the rendered primitive.
- **must-set-data-pressed-attribute-when-pressed**: PressableButton MUST set a `data-pressed` attribute with an empty-string value on the rendered primitive when its internal pressed state is `true`.
- **must-omit-data-pressed-attribute-when-not-pressed**: PressableButton MUST leave the `data-pressed` attribute unset on the rendered primitive when its internal pressed state is `false`.
- **must-set-held-true-on-pointerdown**: PressableButton MUST set its internal held state to `true` when a `pointerdown` event is dispatched on the rendered primitive.
- **must-set-pressed-true-on-pointerdown**: PressableButton MUST set its internal pressed state to `true` when a `pointerdown` event is dispatched on the rendered primitive.
- **must-set-held-false-on-element-pointerup**: PressableButton MUST set its internal held state to `false` when a `pointerup` event is dispatched on the rendered primitive.
- **must-set-pressed-false-on-element-pointerup**: PressableButton MUST set its internal pressed state to `false` when a `pointerup` event is dispatched on the rendered primitive.
- **must-clear-pressed-on-pointerleave-while-held**: PressableButton MUST set its internal pressed state to `false` when a `pointerleave` event is dispatched on the rendered primitive while its internal held state is `true`.
- **must-not-change-held-on-pointerleave**: PressableButton MUST NOT change its internal held state when a `pointerleave` event is dispatched on the rendered primitive.
- **must-restore-pressed-on-pointerenter-while-held**: PressableButton MUST set its internal pressed state to `true` when a `pointerenter` event is dispatched on the rendered primitive while its internal held state is `true`.
- **must-not-change-pressed-on-pointerenter-while-not-held**: PressableButton MUST NOT change its internal pressed state when a `pointerenter` event is dispatched on the rendered primitive while its internal held state is `false`.
- **must-set-held-false-on-element-pointercancel**: PressableButton MUST set its internal held state to `false` when a `pointercancel` event is dispatched on the rendered primitive.
- **must-set-pressed-false-on-element-pointercancel**: PressableButton MUST set its internal pressed state to `false` when a `pointercancel` event is dispatched on the rendered primitive.
- **must-attach-window-release-listeners-only-while-held**: PressableButton MUST attach a `pointerup` listener and a `pointercancel` listener to `window` only while its internal held state is `true`.
- **must-remove-window-release-listeners-when-held-becomes-false**: PressableButton MUST remove the `window`-level `pointerup` and `pointercancel` listeners as soon as its internal held state becomes `false`, or when the component unmounts while held.
- **must-set-held-false-on-window-pointerup-while-held**: PressableButton MUST set its internal held state to `false` when a `pointerup` event is dispatched anywhere on `window` while its internal held state is `true`, regardless of the event's target.
- **must-set-pressed-false-on-window-pointerup-while-held**: PressableButton MUST set its internal pressed state to `false` when a `pointerup` event is dispatched anywhere on `window` while its internal held state is `true`, regardless of the event's target.
- **must-set-held-false-on-window-pointercancel-while-held**: PressableButton MUST set its internal held state to `false` when a `pointercancel` event is dispatched anywhere on `window` while its internal held state is `true`, regardless of the event's target.
- **must-set-pressed-false-on-window-pointercancel-while-held**: PressableButton MUST set its internal pressed state to `false` when a `pointercancel` event is dispatched anywhere on `window` while its internal held state is `true`, regardless of the event's target.
- **must-invoke-forwarded-pointer-handler-when-provided**: PressableButton MUST invoke a caller-supplied `onPointerDown`, `onPointerUp`, `onPointerLeave`, `onPointerEnter`, or `onPointerCancel` prop, when one is provided, every time the corresponding pointer event fires on the rendered primitive.
- **must-invoke-forwarded-handler-before-internal-state-update**: PressableButton MUST invoke the caller-supplied handler for a given pointer event before applying its own internal held/pressed state update for that same event.
- **must-not-change-pressed-state-on-keyboard-activation**: PressableButton MUST NOT change its internal pressed state in response to keyboard activation (Space or Enter).
- **must-not-call-set-pointer-capture**: PressableButton MUST NOT call `setPointerCapture` on any pointer event it handles.

## Appearance

Not applicable: PressableButton is a pointer-event tracking layer with no styling of its own; visual appearance (radius, padding, font, colors, borders, shadows, size constraints) is defined in `button.tsx`'s `buttonVariants` and the Base UI `Button` primitive.

## States

| State | Appearance change |
|-------|------------------|
| Default | `data-pressed` absent; `held` and `pressed` both `false` |
| Pressed | `data-pressed=""` present; entered on `pointerdown`, held through `pointerleave`/`pointerenter` cycles while still held |
| Disabled | Not applicable: PressableButton contains no `disabled` logic; disabling is a concern of the primitive/CSS layer. |
| Focused | Not applicable: PressableButton contains no focus handling; focus state is managed by the Base UI Button primitive. |
| Loading | Not applicable: PressableButton contains no loading-state logic. |

The "Pressed" row above covers two nested transitions traceable to the source:
while `held` is `true`, a `pointerleave` clears `data-pressed` (the visual
returns to Default while still armed) and a subsequent `pointerenter`
restores it, without ever leaving the held state.

## Accessibility

- Role/trait: Not applicable: PressableButton sets no accessibility role; the role comes from the Base UI Button primitive it wraps.
- Label requirements: Not applicable: PressableButton accepts and forwards label-related props but imposes no label requirements.
- Announce state changes: Not applicable: PressableButton sets no ARIA announcements; `data-pressed` is a plain data attribute for CSS selectors, not an ARIA state.
- Minimum tap target: Not applicable: PressableButton imposes no size constraints; touch target sizing is a concern of the primitive/CSS layer.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| button-pressable-001 | must-render-primitive-with-forwarded-props | Render with `variant="secondary"` and `aria-label="Save"` | Rendered element receives `variant="secondary"` and `aria-label="Save"` unchanged |
| button-pressable-002 | must-set-data-slot | Render with any props | Rendered element has `data-slot="button"` |
| button-pressable-003 | must-set-data-pressed-attribute-when-pressed | `pointerdown` dispatched on the element | Rendered element has attribute `data-pressed=""` |
| button-pressable-004 | must-omit-data-pressed-attribute-when-not-pressed | Initial render, no interaction | Rendered element has no `data-pressed` attribute |
| button-pressable-005 | must-set-held-true-on-pointerdown | `pointerdown` on the element, then `pointerleave` on the element (no `pointerup`), then `pointerup` on `window` | `data-pressed` is cleared by the window `pointerup`, which only happens if held was `true` — proving held was set on `pointerdown` |
| button-pressable-006 | must-set-pressed-true-on-pointerdown | `pointerdown` on the element | `data-pressed=""` present immediately after the event |
| button-pressable-007 | must-set-held-false-on-element-pointerup | `pointerdown` then `pointerup`, both on the element, then dispatch `pointerup` on `window` | The window `pointerup` produces no further state change, proving held was already `false` |
| button-pressable-008 | must-set-pressed-false-on-element-pointerup | `pointerdown` then `pointerup`, both on the element | `data-pressed` absent after `pointerup` |
| button-pressable-009 | must-clear-pressed-on-pointerleave-while-held | `pointerdown` then `pointerleave`, both on the element | `data-pressed` absent after `pointerleave` |
| button-pressable-010 | must-not-change-held-on-pointerleave | `pointerdown`, `pointerleave`, both on the element, then `pointerup` on `window` | The window `pointerup` ends the hold, proving held remained `true` through the `pointerleave` |
| button-pressable-011 | must-restore-pressed-on-pointerenter-while-held | `pointerdown`, `pointerleave`, `pointerenter`, all on the element | `data-pressed=""` present again after `pointerenter` |
| button-pressable-012 | must-not-change-pressed-on-pointerenter-while-not-held | `pointerenter` on the element with no prior `pointerdown` | `data-pressed` remains absent after `pointerenter` |
| button-pressable-013 | must-set-held-false-on-element-pointercancel | `pointerdown` then `pointercancel`, both on the element, then `pointerup` on `window` | The window `pointerup` produces no further state change, proving held was already `false` |
| button-pressable-014 | must-set-pressed-false-on-element-pointercancel | `pointerdown` then `pointercancel`, both on the element | `data-pressed` absent after `pointercancel` |
| button-pressable-015 | must-attach-window-release-listeners-only-while-held | Dispatch `pointerup` on `window` with no prior `pointerdown` on the element | No state change and no error is thrown (listener was never attached) |
| button-pressable-016 | must-remove-window-release-listeners-when-held-becomes-false | `pointerdown` then `pointerup`, both on the element, then dispatch a second `pointerup` on `window` | The second window `pointerup` produces no additional state change, proving the window listener was removed once held became `false` |
| button-pressable-017 | must-set-held-false-on-window-pointerup-while-held | `pointerdown` on the element, then `pointerup` dispatched on `window` (not on the element) | `data-pressed` absent after the window `pointerup` |
| button-pressable-018 | must-set-pressed-false-on-window-pointerup-while-held | `pointerdown` on the element, then `pointerup` dispatched on `window` (not on the element) | `data-pressed` absent after the window `pointerup` |
| button-pressable-019 | must-set-held-false-on-window-pointercancel-while-held | `pointerdown` on the element, then `pointercancel` dispatched on `window` (not on the element) | `data-pressed` absent after the window `pointercancel` |
| button-pressable-020 | must-set-pressed-false-on-window-pointercancel-while-held | `pointerdown` on the element, then `pointercancel` dispatched on `window` (not on the element) | `data-pressed` absent after the window `pointercancel` |
| button-pressable-021 | must-invoke-forwarded-pointer-handler-when-provided | Render with an `onPointerDown` spy prop, dispatch `pointerdown` on the element | Spy is called exactly once |
| button-pressable-022 | must-invoke-forwarded-handler-before-internal-state-update | Render with an `onPointerDown` spy that synchronously reads `data-pressed` when called, dispatch `pointerdown` | Spy observes `data-pressed` absent at the moment it runs; `data-pressed=""` is present once the event finishes processing |
| button-pressable-023 | must-not-change-pressed-state-on-keyboard-activation | Focus the element, press `Enter` (and separately, `Space`), with no pointer event | `data-pressed` remains absent throughout and after activation |
| button-pressable-024 | must-not-call-set-pointer-capture | `pointerdown` on the element, then call `element.hasPointerCapture(pointerId)` | Returns `false` |

## Edge Cases

- **Handler prop omitted** (no `onPointerDown`/`onPointerUp`/`onPointerLeave`/`onPointerEnter`/`onPointerCancel` prop supplied): the component MUST NOT throw when the corresponding pointer event fires — `compose()`'s `theirs?.(event)` short-circuits safely via optional chaining.
- **Repeated `pointerdown` without an intervening release** (a second `pointerdown` fires while `held`/`pressed` are already `true`): the component MUST leave `held` and `pressed` at `true` — the state assignment is idempotent and produces no observable change.
- **Release delivered only to `window`, never to the element** (`pointerdown` on the element, the pointer leaves before any element-level `pointerup`, and `pointerup` fires only on `window`): the component MUST still end the hold (`held` and `pressed` both `false`) via the window listener, because `pointerleave` alone does not clear `held`.
- **`pointercancel` delivered while `held` is already `false`** (`pointercancel` fires on the element after a prior `pointerup` already ended the hold): the component MUST re-apply `held = false` and `pressed = false`, which is a no-op with no observable change.
- **Boundary values**: Not applicable — the component has no numeric, length-, or count-bounded input; its only inputs are pointer/keyboard events and arbitrary forwarded props, none of which are constrained to a min/max range in this source.
- **Concurrent access**: Not applicable — pointer events are dispatched serially on the browser's single UI thread, and `held`/`pressed` are local, in-memory React state with no cross-thread or cross-session access path.
- **Error states**: Not applicable — the component has no dependency on a network, database, or file system; it performs no I/O.
- **Offline or disconnected state**: Not applicable — the component performs no network operation, so connectivity has no effect on its behavior.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `onPointerDown` | `(event: PointerEvent) => void` (optional) | `undefined` | Consumer handler invoked before the component's own `pointerdown` tracking runs. |
| `onPointerUp` | `(event: PointerEvent) => void` (optional) | `undefined` | Consumer handler invoked before the component's own `pointerup` tracking runs. |
| `onPointerLeave` | `(event: PointerEvent) => void` (optional) | `undefined` | Consumer handler invoked before the component's own `pointerleave` tracking runs. |
| `onPointerEnter` | `(event: PointerEvent) => void` (optional) | `undefined` | Consumer handler invoked before the component's own `pointerenter` tracking runs. |
| `onPointerCancel` | `(event: PointerEvent) => void` (optional) | `undefined` | Consumer handler invoked before the component's own `pointercancel` tracking runs. |
| `...props` | `ButtonPrimitive.Props` | — | All other Base UI `Button` props, forwarded unchanged. |

## Deep Linking

Not applicable: PressableButton is a pointer-event tracking layer with no navigation or routing responsibility.

## Localization

Not applicable: PressableButton renders no user-facing strings.

## Accessibility Options

Document which accessibility display options (Rule 15) this component responds to:

| Option | Behavior |
|--------|----------|
| Reduce Motion | Not applicable: PressableButton contains no motion or transitions. |
| Increase Contrast | Not applicable: PressableButton contains no color or contrast logic. |
| Differentiate Without Color | Not applicable: PressableButton contains no color-dependent signaling. |

## Feature Flags

Not applicable: PressableButton contains no feature-flag logic or conditional behavior.

## Analytics

Not applicable: PressableButton fires no analytics events.

## Privacy

- **Data collected**: None. `button-pressable.tsx` collects no user data; `held` and `pressed` are transient boolean UI state.
- **Storage**: None. `held`/`pressed` live only in in-memory React component state (`useState`) and are never written to disk, cookies, or any storage API.
- **Transmission**: None. This file makes no network calls and sends no data anywhere.
- **Retention**: None beyond the component's lifetime. State resets to `false`/`false` on every fresh mount and is discarded on unmount.

## Logging

Subsystem: N/A | Category: N/A

No logging. `button-pressable.tsx` makes no logging or telemetry calls; state
changes are purely in-memory, and any telemetry belongs in the consumer's own
forwarded pointer handler, not in this file.

## Platform Notes

- **SwiftUI**: A SwiftUI developer would start from `ButtonStyle`'s `configuration.isPressed`, which SwiftUI already derives from its own gesture recognizer — unlike this source, no manual `pointerdown`/`pointerup`/`pointerleave`/`pointerenter`/`pointercancel` tracking or window-level release listener is needed, because SwiftUI's gesture system already handles release-outside-the-view.
- **Compose**: A Jetpack Compose developer would start from `Modifier.pointerInput` combined with a `MutableInteractionSource`, reading press state via `interactionSource.collectIsPressedAsState()` (backed by `PressInteraction.Press`/`Release`/`Cancel`); Compose's `Interaction` API already models a held/pressed distinction comparable to this source's `held`/`pressed`, so no manual window-level listener is required.
- **React/Web**: This is the source. `PressableButton` wraps the Base UI `Button` primitive in a `"use client"` module, tracks `held`/`pressed` via `useState`, and reflects `pressed` through the `data-pressed` attribute; a `useEffect` attaches `window` `pointerup`/`pointercancel` listeners only while `held` is `true` to catch release outside the element.
- **AppKit / UIKit**: A UIKit developer would start from `UIControl`'s built-in `.isHighlighted` state driven by `touchDown`/`touchUpInside`/`touchDragExit`/`touchDragEnter`, which already maps directly onto this source's `pointerdown`/`pointerup`/`pointerleave`/`pointerenter` logic. AppKit's `NSButton` has no equivalent live-pressed state and would need a custom `NSView` tracking `mouseDown`/`mouseDragged`/`mouseUp`, mirroring this source's manual approach rather than UIKit's built-in one.
- **WinUI 3**: A Windows developer would start from the `Button` control's default `ControlTemplate`, which already defines a `"Pressed"` `VisualState` (via `VisualStateManager`) driven by `PointerPressed`/`PointerReleased`/`PointerCaptureLost`/`PointerExited`/`PointerEntered`, so the starting point is customizing that template's `Pressed` state rather than re-implementing pointer tracking from scratch. The key difference from this source: WinUI 3's default template calls `CapturePointer` on press, retargeting subsequent pointer events to the button, whereas this source deliberately avoids pointer capture (`// No setPointerCapture`) and instead relies on a `window`-level release listener to detect release outside the element — a WinUI 3 port that wants this source's exact leave/re-enter semantics would need to release capture (or avoid relying on it) and track `PointerExited`/`PointerEntered` manually instead.

## Design Decisions

- **All requirements are MUST; none are SHOULD or MAY.** The source contains no conditional or caller-configurable deviation in its press-tracking logic — every state transition is an unconditional, deterministic response to a specific event. No permitted alternative behavior is exposed, so no SHOULD/MAY requirement was written.
- **Window-level release listeners, attached only while held.** Because `pointerleave` alone does not end the hold (by design, to support re-entry), a release or cancel that lands outside the element would otherwise leave the press stuck forever. The `useEffect` attaches `window` `pointerup`/`pointercancel` listeners only while `held` is `true` and tears them down as soon as it becomes `false`, so no listener is left attached when idle.
- **No `setPointerCapture`.** The source comment states this explicitly: capture would re-target subsequent pointer events to the button and defeat the leave/re-enter detection that the `pointerleave`/`pointerenter` handlers depend on.
- **Keyboard activation is deliberately unaffected.** The source comment states the pressed visual is "intentionally pointer-only" — Space/Enter activation is left to the underlying primitive and never touches `pressed`.
- **Consumer handlers are composed, never replaced.** `compose()` always calls the caller's handler before the component's own logic, so passing e.g. `onPointerUp` does not silently disable this component's press tracking, and the component does not silently disable a caller's handler.
- **Larger requirement count than the sibling `Button` recipe is expected, not a completeness gap.** [Button](agenticdevelopercookbook://recipes/button) states several of this component's transitions as single compound requirements (e.g. "ends the held state" covering both `held` and `pressed`, and both the `pointerup`/`pointercancel` cases). This recipe decomposes each into its own atomic, independently testable requirement per the behavioral-requirements guideline's prohibition on compound statements, which accounts for the higher count (24 here vs. 12 there) despite both recipes describing the same underlying source file.
- **`platforms: [web]`, not `[typescript, web]` like sibling recipes.** [Button](agenticdevelopercookbook://recipes/button) and `copy-button` list both `typescript` and `web`. This recipe was generated from a single specified source-platform set of `web` only, so `platforms` reflects exactly that input rather than inferring `typescript` from the source file's extension.
- **New tags `pointer-events` and `pressable`.** The established family vocabulary (`component`, `button`, `ui`) is kept, and two new tags are added because this recipe's scope — the interaction layer alone, apart from `Button`'s visual variants — is not covered by any existing tag in the family.
- **Appearance, Accessibility, States (Disabled/Focused/Loading), Deep Linking, Localization, Accessibility Options, Feature Flags, and Analytics are not applicable, not incomplete.** `button-pressable.tsx` is purely a pointer-tracking behavior layer; it owns no styling, no ARIA semantics, no routing, no strings, no flags, and no telemetry. Those concerns belong to `button.tsx` (styling) and the Base UI `Button` primitive (semantics), neither of which was provided as source for this recipe.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| No `setPointerCapture` call anywhere in the pointer-tracking logic | pass | interaction |
| Every forwarded pointer handler prop is invoked, never swallowed, when supplied | pass | interaction |
| Keyboard activation (Space/Enter) does not alter the pressed visual | pass | interaction |

## Change History
