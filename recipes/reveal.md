---
id: b5b27bc2-99b2-469e-9dd4-e446b0157444
title: Reveal
domain: agenticdevelopertoolkit://recipes/reveal
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Fades and lifts content into place as it enters the viewport, improving perceived
  performance and visual flow for scrollable layouts.
platforms:
- typescript
- web
tags:
- animation
- viewport
- scroll
depends-on: []
related: []
references:
- https://developer.mozilla.org/en-US/docs/Web/API/Intersection_Observer_API
approved-by: ''
approved-date: ''
---

# Reveal

## Overview

Reveal is a wrapper component that fades and lifts its children into place as they enter the viewport. It uses the Intersection Observer API to detect when the wrapped element becomes visible and transitions it from a hidden state to a visible state. The component preserves accessibility by rendering content in its visible (finished) state by default; JavaScript enhancements only apply the hidden state after the component mounts.

## Behavioral Requirements

- **must-render-visible-by-default**: The component MUST render its children in the visible, resting state initially. If JavaScript is disabled or the Intersection Observer fires before mount, content remains visible and is never hidden.
- **must-detect-viewport-entry**: The component MUST use the Intersection Observer API to detect when the wrapped element enters the viewport.
- **must-arm-after-mount**: The component MUST not arm the observe state on initial mount if the element is already visible on screen at that time (top offset less than window height).
- **must-disconnect-on-first-intersection**: The component MUST disconnect the Intersection Observer immediately after the first intersection is detected; a reveal is a one-way transition and the element MUST NOT re-hide when scrolled past.
- **must-apply-hidden-state-class**: When armed (observing but not yet shown), the component MUST apply the `lp-reveal--armed` CSS class to the wrapper element.
- **must-apply-base-class**: The component MUST always apply the base `lp-reveal` CSS class to the wrapper.
- **may-accept-classname-prop**: The component MAY accept an optional `className` prop to allow consumers to add custom classes to the wrapper element.
- **must-forward-children**: The component MUST render its children as-is within the wrapper element.

## Appearance

- **Corner radius**: None (transparent wrapper)
- **Padding**: None (transparent wrapper)
- **Font**: Inherited from children
- **Background**: Transparent (no background applied by component)
- **Foreground/Text**: Inherited from children
- **Border**: None
- **Shadow**: None
- **Min/Max size**: None (size determined by children)

## States

| State | Appearance change |
|-------|------------------|
| Default (visible on page load) | Children render in full opacity and normal vertical position; no animation occurs |
| Armed (below viewport, observing) | Children render with hidden state defined in CSS (transform and opacity reduced); awaiting intersection |
| Revealed (intersected viewport) | Transition from armed to visible state occurs via CSS animation; observer disconnects |

## Accessibility

- **Role/trait**: None on the wrapper; the component is transparent and forwards semantic meaning to children.
- **Label requirements**: No label needed; the wrapper carries no semantic role.
- **Announce state changes**: Not applicable; state transitions are visual only and do not affect assistive technology.
- **Minimum tap target**: Not applicable; the component itself is not interactive.
- **Graceful degradation**: With JavaScript disabled or if the Intersection Observer is unavailable, content remains visible in its resting state, ensuring no content loss.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| reveal-001 | must-render-visible-by-default | Component with children, JavaScript enabled, no observer fired | Children render immediately in visible state (no fade or lift) |
| reveal-002 | must-arm-after-mount | Component with children initially below viewport, mounted | After mount, `lp-reveal--armed` class is added to wrapper; children are in hidden state (per CSS) |
| reveal-003 | must-detect-viewport-entry | Component with armed state, user scrolls element into viewport | Intersection Observer fires; observer disconnects; `lp-reveal--armed` class is removed; animation to visible state occurs |
| reveal-004 | must-disconnect-on-first-intersection | Component revealed, user scrolls past element out of viewport | Observer remains disconnected; element stays visible; no re-hiding occurs |
| reveal-005 | must-apply-hidden-state-class | Component mounted below viewport | `lp-reveal--armed` class is present on wrapper div |
| reveal-006 | must-apply-base-class | Component at any state | `lp-reveal` class is always present on wrapper div |
| reveal-007 | may-accept-classname-prop | Component with `className="custom-class"` | Custom class is included in wrapper's class list alongside `lp-reveal` and `lp-reveal--armed` |
| reveal-008 | must-forward-children | Component with children `<img src="..." />`, `<p>Text</p>` | Children are rendered as-is within the wrapper |
| reveal-009 | must-render-visible-by-default | Component already on screen at mount (top offset < window.innerHeight) | `lp-reveal--armed` is not applied; observer is not created; children remain visible throughout session |

## Edge Cases

- **Already on screen at mount**: If the wrapped element's top offset is less than `window.innerHeight` at mount time, it is considered already visible. The component sets `shown: true` immediately and does not create an Intersection Observer. This prevents the blank-out flicker that would occur if the element were armed and then immediately intersected.
- **Root margin offset**: The Intersection Observer is configured with `rootMargin: '0px 0px -12% 0px'`, meaning intersection is triggered 12% above the bottom of the viewport. This provides an early reveal for visual smoothness as the user approaches the element.
- **Null ref**: If the ref is null when the effect runs (component was unmounted before effect execution), the effect returns early and does not proceed with observation.
- **Multiple child updates**: The component re-renders if children change. The ref to the wrapper element is stable; the observer (if created) remains active unless already disconnected by intersection.
- **Window resize**: The Intersection Observer automatically adapts to viewport changes; no resize listener is needed.
- **Cleanup on unmount**: The cleanup function disconnects the observer if one was created, preventing memory leaks.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| children | ReactNode | (required) | The content to reveal as it enters the viewport |
| className | string | undefined | Optional custom CSS class to add to the wrapper element alongside `lp-reveal` |

## Deep Linking

Not applicable: Reveal is a visual enhancement wrapper with no navigable state or deep-link target.

## Localization

Not applicable: Reveal contains no user-facing text strings.

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | `prefers-reduced-motion` media query in CSS neutralizes the transform and transition; the component still arms and unarms (state changes occur), but the element appears instantaneously without animation. Handled entirely in CSS, not in JavaScript. |
| Increase Contrast | Not applicable; Reveal does not render text or interactive elements. |
| Differentiate Without Color | Not applicable; Reveal does not use color alone to convey state. |

## Feature Flags

Not applicable: Reveal is a foundational component with no opt-in or opt-out behavior.

## Analytics

Not applicable: Reveal is a transparent wrapper with no user interaction or event of its own.

## Privacy

Not applicable: Reveal does not collect, store, or transmit any user data.

## Logging

Not applicable: Reveal does not emit diagnostic events or logs.

## Platform Notes

- **TypeScript/React (source)**: Implemented in `packages/web/packages/landing/src/flow/Reveal.tsx`. Wraps children in a `div` with ref forwarding, uses `useState` for armed/shown flags, and `useEffect` with Intersection Observer API. Class names are assembled dynamically and concatenated with filter. The resting (visible) state is the default; the armed (hidden) state is added only after mount if the element is below the fold.
- **SwiftUI**: Create a view modifier that applies a fade and scale animation using `.transition(.asymmetric(insertion: .opacity.combined(with: .scale(scale: 0.95)), removal: .identity))` or similar. Trigger the transition via a `@State` boolean that toggles when a scroll reader (using `GeometryReader` and coordinate space tracking) detects the view entering the visible area. Ensure the view renders in its visible state by default to preserve content for VoiceOver users.
- **Compose**: Implement using a `Box` composable that tracks its scroll position via `BoxWithConstraints` and `Modifier.onSizeChanged`. Apply fade and translate animations using `AnimatedVisibility` with `enterTransition` set to `fadeIn() + slideInVertically()` and `exitTransition = ExitTransition.None` (one-way). Render children in the visible state initially; apply hidden state after composition only if needed.
- **AppKit / UIKit**: Create an NSView or UIView subclass that observes scroll position through the responder chain or KVO on a parent scroll view. Apply fade and transform animations via `CABasicAnimation` on the layer when the view's frame moves into the visible region. Alternatively, use a `UIViewController` with scroll view delegation to detect content offset and trigger Core Animation transitions.
- **WinUI 3**: Create a UserControl with a StackPanel or Grid containing children. Bind an `IsArmed` dependency property to track whether the control is visible on screen. In code-behind, attach a `ScrollViewer.ViewChanged` event handler (or poll `ActualHeight` and parent scroll position) to detect viewport entry. Apply a Storyboard animation with `DoubleAnimation` on `Opacity` and `TranslateTransform.Y` when visibility is detected. Set `Visibility = Visibility.Visible` by default to ensure content appears before the component initializes; only add the hidden state class/template after load if the element is below the fold.

## Design Decisions

- **Render visible by default**: Content is rendered in the visible, resting state on initial render. This follows the accessibility principle that hiding content by default and revealing it conditionally is a content-loss bug if JavaScript fails. A reader with JS disabled sees the finished page, not a blank one.
- **Disconnect after first intersection**: The observer disconnects immediately after the first intersection. Re-hiding content that has scrolled past is a well-known anti-pattern that makes pages feel broken. Reveal is intended as a one-way visual enhancement, not a repeating animation.
- **CSS handles prefers-reduced-motion**: The preference is read from a CSS media query rather than JavaScript. This ensures a single source of truth: if the media query in the stylesheet says to omit animation, the browser's preference is respected without needing to re-read it in code. The component still arms and unarms, but the transition is instant.
- **Root margin of -12%**: The Intersection Observer is configured with a bottom margin of -12% of the viewport height. This triggers intersection detection when the element is 12% above the bottom of the viewport, providing a smooth reveal as the user scrolls toward it rather than waiting for it to fully enter the viewport.
- **Class concatenation with filter**: Custom classes are merged with base classes by filtering out empty strings and joining. This avoids conditional class application and produces a clean class list suitable for CSS selectors.

## Compliance

Not applicable: Reveal is a visual enhancement component that defers all behavioral and accessibility requirements to its children. It does not introduce new compliance obligations beyond standard web platform practices (e.g., Event loop management, memory cleanup).

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation from web source |
