---
id: d7a1229c-cf03-436f-8287-d99b52747510
title: ConnectorSVG
domain: agenticdevelopercookbook://recipes/connector-svg
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Renders SVG connector lines between referenced DOM elements with real-time
  position tracking.
platforms:
- typescript
- web
tags:
- ui
- svg
- connector
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# ConnectorSVG

## Overview

ConnectorSVG renders decorative SVG connector lines between pairs of DOM elements identified by reference. The component automatically tracks element positions and redraws connections when elements resize, the viewport scrolls, or the window resizes. Connections are visual-only and hidden from accessibility trees.

## Behavioral Requirements

- **must-render-svg-root**: Component MUST render an SVG element with class name `pc-connector-svg`.
- **must-hide-from-accessibility**: Component MUST set `aria-hidden="true"` on the SVG element.
- **must-accept-frame-ref**: Component MUST accept a React ref to the container HTML element and use it as the coordinate origin for all connector calculations.
- **must-accept-connector-pairs**: Component MUST accept an array of connector pairs, each with `from` and `to` string identifiers.
- **must-resolve-elements-by-id**: Component MUST resolve each connector pair's `from` and `to` identifiers to DOM elements using a provided registry snapshot.
- **must-draw-line-between-centers**: For each resolvable pair, the component MUST draw an SVG line from the center of the source element to the center of the target element.
- **must-compute-center-coordinates**: The component MUST calculate the center of each element's bounding rectangle and transform coordinates relative to the container element's position.
- **must-skip-unresolved-pairs**: If either element in a pair cannot be resolved from the registry, that connection MUST be omitted from the rendered output.
- **must-render-endpoint-circles**: Component MUST render a circle element at each line endpoint (source and target).
- **must-use-source-color**: The stroke and fill color of each connector line and endpoint circles MUST be derived from the source element's computed CSS `color` property.
- **must-update-on-element-resize**: Component MUST recompute connector positions whenever any tracked element is resized, detected via ResizeObserver.
- **must-update-on-window-resize**: Component MUST recompute connector positions whenever the window resizes.
- **must-update-on-scroll**: Component MUST recompute connector positions when the window or any ancestor element scrolls, including scroll during capture phase.
- **must-use-request-animation-frame**: Component MUST batch position recomputation requests using `requestAnimationFrame` to avoid redundant calculations during rapid layout changes.
- **must-cancel-pending-animation-frame**: If a scheduled animation frame is still pending when the component unmounts, the component MUST cancel it.
- **must-disconnect-resize-observer**: Component MUST disconnect the ResizeObserver and remove event listeners when unmounting.

## Appearance

- **SVG stroke**: 1 pixel width, opacity 0.4, color inherited from source element's computed `color` property
- **SVG line**: Straight line connecting element centers
- **Endpoint circles**: Radius 3 pixels, fill color inherited from source element's computed `color` property, opacity 0.4
- **SVG class**: `pc-connector-svg`

## States

Not applicable: The component is stateless and non-interactive. Position updates are data-driven by the connector pairs array and registry snapshot, not user interaction.

## Accessibility

Not applicable: This component renders purely decorative connector lines with `aria-hidden="true"`. The lines convey no semantic information and are not interactive.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| connector-001 | must-render-svg-root, must-hide-from-accessibility | frameRef pointing to valid container, pairs = [] | SVG with class "pc-connector-svg" and aria-hidden="true" |
| connector-002 | must-accept-connector-pairs, must-resolve-elements-by-id | frameRef, pairs = [{from: "el1", to: "el2"}], both elements registered | One line drawn from center of el1 to center of el2 |
| connector-003 | must-skip-unresolved-pairs | frameRef, pairs = [{from: "el1", to: "missing"}] | No line rendered for that pair |
| connector-004 | must-render-endpoint-circles | frameRef, pairs = [{from: "el1", to: "el2"}] | Two circles (r=3) rendered, one at each line endpoint |
| connector-005 | must-use-source-color | frameRef, source element has computed color = "#ff0000", pairs = [{from: "el1", to: "el2"}] | Line and circles rendered with stroke/fill "#ff0000" and opacity 0.4 |
| connector-006 | must-compute-center-coordinates | frameRef at (100, 200), element at (150, 250) with width=100 height=50 | Line starts at (150, 275) relative to frameRef origin |
| connector-007 | must-update-on-element-resize | frameRef, one element resizes from 100×50 to 200×100 | Line endpoints redrawn to new center positions |
| connector-008 | must-use-request-animation-frame | Rapid resize events fire in succession | Only one recomputation occurs via single requestAnimationFrame call |
| connector-009 | must-cancel-pending-animation-frame | requestAnimationFrame scheduled, component unmounts before frame executes | No render occurs after unmount |

## Edge Cases

- **Empty pairs array**: When `pairs` is an empty array, the component MUST render an empty SVG (no lines or circles).
- **Missing registry entries**: When an element identifier in a pair is not found in the registry snapshot, that connector MUST be silently omitted and not cause an error.
- **Null container ref**: When `frameRef.current` is `null`, the component MUST abort computation and render an empty SVG.
- **Rapid layout changes**: When multiple resize or scroll events fire in quick succession, position updates MUST be deduplicated via `requestAnimationFrame` to ensure only one recomputation per frame.
- **Unmount during scheduled animation frame**: If the component unmounts while a recomputation is scheduled in `requestAnimationFrame`, the frame callback MUST be cancelled to prevent operations on unmounted DOM.
- **Element with zero dimensions**: If an element has zero width or height, its center is still calculated correctly from the bounding rectangle.

## Configuration

Not applicable: The component exposes no configuration options. Behavior is entirely determined by the `frameRef` and `pairs` props, and the registry snapshot provided by the context.

## Deep Linking

Not applicable: This component renders decorative connectors without interactive affordances or internal state that could be deep-linked.

## Localization

Not applicable: The component contains no user-facing strings.

## Accessibility Options

Not applicable: This component is marked as decorative and hidden from accessibility trees. Accessibility display options do not apply.

## Feature Flags

Not applicable: The component has no feature flag gating.

## Analytics

Not applicable: This component is non-interactive and renders no events that warrant analytics instrumentation.

## Privacy

Not applicable: This component does not collect, store, or transmit any data.

## Logging

Not applicable: The component has no significant logging needs. Internal RAF scheduling is an implementation detail.

## Platform Notes

- **React/Web**: Reference implementation uses `requestAnimationFrame` for batched updates, `ResizeObserver` for element tracking, and event listeners on `window` for resize/scroll. Key files: `ConnectorSVG.tsx` with hooks for effect cleanup and state management. Uses `useRegistrySnapshot()` to resolve element identifiers to DOM nodes.
- **SwiftUI**: No native connector component exists. Implement using a custom `Canvas` view that draws `Path` elements with `stroke()` modifiers. Track element frames using `GeometryReader` and anchor preferences to establish connection endpoints. Use `onChange` on the frame or a timer to update positions on layout changes.
- **Compose**: Implement using a `Canvas` composable that draws connector paths with `drawLine()`. Obtain element positions via layout measurement callbacks or `onGloballyPositioned` modifiers. Schedule redraws using `LaunchedEffect` and frame-based timing similar to `requestAnimationFrame`.
- **AppKit / UIKit**: Implement using `CAShapeLayer` with `UIBezierPath` or Core Graphics. Create a custom view that subclasses `UIView` (iOS) or `NSView` (macOS) and uses `CADisplayLink` for frame-rate updates. Compute element frames using `convert(_:to:)` to transform coordinates relative to the connector view's bounds.
- **WinUI 3**: Implement using a `Canvas` or `Path` element in XAML. Bind connector endpoints to computed properties derived from element bounds. Use a `DispatcherTimer` to update positions on layout changes, or hook into layout events on tracked elements. Render line and endpoint shapes using `LineSegment` and `EllipseGeometry` primitives.

## Design Decisions

The component uses `requestAnimationFrame` for position updates rather than continuous polling or explicit timers to ensure computations occur at most once per display refresh cycle. This minimizes layout thrashing and aligns with browser rendering constraints. The color is derived from the source element's computed style to allow per-connector color customization without requiring explicit props, keeping the interface minimal.

The component is marked `aria-hidden="true"` because connector lines are purely decorative and add no semantic value to the document structure. They support visual understanding but do not convey information necessary for keyboard or screen reader users.

## Compliance

Not applicable: No specific compliance checks are defined for this component.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
