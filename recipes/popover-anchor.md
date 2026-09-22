---
id: c130d5d5-2ac4-4a15-a13a-9127ddad6ca1
title: Popover Anchor
domain: agenticdevelopertoolkit://recipes/popover-anchor
type: ingredient
version: 1.0.0
status: review
language: en
created: 2026-09-22
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Positioning wrapper for a popover trigger and panel that prevents dismissal
  delay gaps when pointer moves between elements.
platforms:
- typescript
- web
tags:
- popover
- positioning
- layout
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Popover Anchor

## Overview

PopoverAnchor is a positioning context wrapper that groups a popover trigger and its associated panel as a single hover target. It establishes `position: relative` as the reference frame for the popover's absolute positioning and prevents pointer-leave events from firing when the cursor moves between the trigger and panel, eliminating the close delay gap that would otherwise appear.

## Behavioral Requirements

- **must-wrap-content**: Component MUST render its `children` prop as-is without modification or wrapping in additional elements beyond the anchor div itself.
- **must-set-relative-positioning**: Component MUST apply `position: relative` CSS to establish a positioning context for absolutely positioned children.
- **must-concatenate-classname**: Component MUST concatenate the string `hover-popover-anchor` with any `className` prop value. If `className` is provided, the final class MUST be `hover-popover-anchor <className>`. If `className` is not provided, the class MUST be exactly `hover-popover-anchor`.
- **must-handle-mouse-leave**: Component MUST accept an optional `onMouseLeave` callback and invoke it when the pointer leaves the anchor element (exiting both trigger and panel boundary).
- **must-preserve-hover-state-across-elements**: Component MUST ensure that moving the pointer from the trigger to the panel (or vice versa) does NOT trigger the `onMouseLeave` callback, because both elements are contained within the same anchor div.

## Appearance

Not applicable: PopoverAnchor is a layout utility and does not define visual appearance. Styling is applied via the `className` prop and external stylesheets targeting the `hover-popover-anchor` class.

## States

| State | Behavior |
|-------|----------|
| Default | Anchor is mounted and ready to receive children. No visual state. |

## Accessibility

Not applicable: PopoverAnchor is a positioning wrapper with no interactive element of its own. Accessibility concerns belong to the trigger and panel components it contains.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| anchor-001 | must-wrap-content | `children` = `<button>Trigger</button><div>Panel</div>` | Anchor renders both children in order without wrapping them in additional elements |
| anchor-002 | must-set-relative-positioning | Anchor rendered with no props | Computed style includes `position: relative` |
| anchor-003 | must-concatenate-classname | `className` = `"custom-class"` | Final class attribute is `"hover-popover-anchor custom-class"` |
| anchor-004 | must-concatenate-classname | No `className` prop | Final class attribute is exactly `"hover-popover-anchor"` |
| anchor-005 | must-handle-mouse-leave | `onMouseLeave` callback provided, pointer leaves anchor | Callback is invoked exactly once |
| anchor-006 | must-preserve-hover-state-across-elements | Pointer on trigger, moves to panel sibling | `onMouseLeave` is NOT invoked (anchor still contains pointer) |

## Edge Cases

- **Multiple children**: Component accepts ReactNode, which can be a single element, multiple elements, or a fragment. Children are rendered without iteration or mapping, so the developer is responsible for uniqueness and key management.
- **Null or undefined children**: If `children` is null or undefined, the anchor renders an empty div. This is valid and matches React's children handling.
- **Callback not provided**: If `onMouseLeave` is not passed, no callback is invoked. The anchor still functions as a positioning context. This is the expected behavior for a pure layout component.
- **Rapid pointer entry/exit**: If the pointer enters and exits the anchor within a single event cycle, `onMouseLeave` is invoked once upon final exit.
- **Nested interactive elements**: Child elements can be interactive. The `onMouseLeave` handler on the anchor fires only when the pointer leaves the entire anchor boundary, not when interacting with children.

## Configuration

Not applicable: PopoverAnchor accepts only the `children`, `className`, and `onMouseLeave` props. No additional configuration is required.

## Deep Linking

Not applicable: PopoverAnchor is a layout utility, not a user-facing destination.

## Localization

Not applicable: PopoverAnchor contains no user-visible text.

## Accessibility Options

Not applicable: PopoverAnchor is a positioning wrapper without interactive state or text to respond to accessibility display options (e.g., Reduce Motion, Increase Contrast).

## Feature Flags

Not applicable: PopoverAnchor is a utility component that requires no feature toggle.

## Analytics

Not applicable: PopoverAnchor is a layout wrapper and not a user interaction point.

## Privacy

Not applicable: PopoverAnchor does not collect or transmit data.

## Logging

Not applicable: PopoverAnchor is an internal layout component with no user-visible events to log.

## Platform Notes

- **SwiftUI**: Use a container view or modifier that establishes a `position: relative` equivalent context (e.g., wrapping content in a background frame with no clip). Apply a gesture modifier to detect `onEnded` on a hover drag target that encompasses both the trigger and panel. SwiftUI has no direct CSS model, so focus on the semantic grouping of the trigger and panel as a single hit target and ensure pointer leave events fire only when exiting both.

- **Compose**: Create a `Box` or `Surface` with `modifier.position(Absolute)` or use a custom `PointerInteropModifier` to establish the positioning context. Attach an `onPointerEvent` listener for `PointerEventType.Exit` to the layout node. Ensure the layout node's bounds include both the trigger and panel so the exit event fires only when leaving the entire group.

- **React/Web**: (Source) Render a `<div>` with `className="hover-popover-anchor"` (plus optional additional classes). Set `position: relative` in CSS. Attach `onMouseLeave` handler to the div. Children (trigger and panel) are placed inside the same div, so pointer movement between them does not fire the leave event.

- **AppKit / UIKit**: Create a container view (NSView or UIView) that sets `position: static` or uses Auto Layout to position children absolutely within it. Attach a pointer/hover event tracker (NSTrackingArea on macOS, UIPointerInteraction on iOS 13.4+) to the container. Ensure the tracking area spans the bounding rect of both the trigger and panel so the pointer-leave callback fires only when exiting the entire container.

- **WinUI 3**: Use a `Grid` or `Canvas` with a transparent background to establish the positioning context. Apply `Grid.RowDefinitions` or absolute Canvas positioning to layout the trigger and panel as children. Attach a `PointerExited` event handler to the container element. Set the container's `Background` to `Transparent` if needed to ensure the pointer events fire across its entire bounds, not just opaque regions.

## Design Decisions

**Positioning context as a wrapper**: PopoverAnchor deliberately wraps both the trigger and panel in the same container rather than wrapping only the trigger. This prevents the pointer from leaving the trigger for the panel and firing a close delay. The developer is responsible for placing both elements as children of the anchor.

**No visual styling in component**: The component does not define padding, background, or border. It is purely a positioning context. Styling is applied through the `className` prop and external CSS.

**onMouseLeave over onPointerLeave**: The source uses `onMouseLeave` rather than the newer `onPointerLeave` event. This is a deliberate choice in the source; implementations SHOULD match this API to maintain consistency.

## Compliance

Not applicable: PopoverAnchor is a layout component with no compliance requirements.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude | Initial creation |
