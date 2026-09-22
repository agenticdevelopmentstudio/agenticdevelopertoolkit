---
id: 4a2dcdee-4d2a-4f3f-a3a5-d243ec2b799b
title: SendIcon
domain: agenticdevelopercookbook://ingredients/send-icon
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Static SVG icon depicting a send or forward arrow for messaging and action
  contexts.
platforms:
- typescript
- web
tags:
- icon
- ui
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# SendIcon

## Overview

SendIcon is a static, presentation-only SVG icon component that renders a diagonal send/forward arrow. It provides a visual affordance for send, submit, or forward actions in messaging, chat, and form contexts. The component has no interactive behavior, state management, or configuration options.

## Behavioral Requirements

- **must-render-svg**: Component MUST render as an SVG element with a `<line>` and `<polygon>` path forming a send arrow pointing from lower-left to upper-right.
- **must-use-current-color**: Component MUST use `currentColor` for the stroke color, allowing the icon to inherit text color from its parent context.
- **must-maintain-aspect-ratio**: Component MUST maintain a square aspect ratio and MUST NOT distort the arrow shape when scaled.
- **must-be-static**: Component MUST NOT respond to user interaction, state changes, or dynamic updates; it is a static presentation.

## Appearance

- **Dimensions**: 20×20 pixels (SVG viewBox: 0 0 24 24)
- **Stroke width**: 2 units
- **Stroke linecap**: round
- **Stroke linejoin**: round
- **Fill**: none (stroke only)
- **Stroke color**: currentColor (inherits from parent text color)
- **Geometry**: line from (22, 2) to (11, 13); polygon with points (22, 2), (15, 22), (11, 13), (2, 9), forming a triangular arrowhead

## States

Not applicable: SendIcon is a static presentation component with no interactive states. It does not respond to user input, focus, or state changes.

## Accessibility

- **Role**: presentational image; MUST be treated as an icon, not interactive
- **Label requirement**: The component itself MUST NOT have a label or `aria-label`. A containing button or action that uses SendIcon as its visual indicator MUST provide an accessible label for the entire control (e.g., `aria-label="Send message"`).
- **Semantic use**: SendIcon SHOULD be wrapped in a `<button>` or similar interactive control; the label belongs to the wrapper, not the icon itself.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|-----|-------------|-------|----------|
| send-icon-001 | must-render-svg | Render component with no props | SVG renders with `<line>` and `<polygon>` elements visible |
| send-icon-002 | must-use-current-color | Render in context with `color: red` | Icon stroke appears red (inherits currentColor) |
| send-icon-003 | must-maintain-aspect-ratio | Scale container from 20px to 40px | Icon remains square and proportionally scaled |
| send-icon-004 | must-be-static | Render component | No event listeners, no state updates, no response to clicks or focus |

## Edge Cases

- **Empty or null rendering**: Not applicable. SendIcon is a functional component that always renders; it has no inputs to be null or empty.
- **Container scaling**: When the parent container is sized differently than 20×20, the component MUST scale proportionally. Aspect ratio preservation is a MUST.
- **Color inheritance failure**: If `currentColor` is not supported by the rendering context, the stroke MUST fall back to black or a reasonable default; this is platform-dependent.
- **Accessibility in non-interactive context**: If SendIcon is rendered standalone without a wrapping interactive control, it SHOULD include a comment or documentation note that a label must be provided by the parent context.

## Configuration

Not applicable: SendIcon accepts no configuration options. All visual properties (size, stroke width, color) are fixed or inherited from parent context.

## Deep Linking

Not applicable: SendIcon is a presentation component with no deep linking concerns.

## Localization

Not applicable: SendIcon is a visual icon with no text content to localize.

## Accessibility Options

Not applicable: SendIcon is a static graphical element that does not respond to accessibility display options like Reduce Motion or Increase Contrast.

## Feature Flags

Not applicable: SendIcon has no feature flags or conditional rendering.

## Analytics

Not applicable: SendIcon does not emit events or track user interactions.

## Privacy

Not applicable: SendIcon collects no data.

## Logging

Not applicable: SendIcon performs no logging.

## Platform Notes

- **React/Web**: `SendIcon.tsx` in `packages/web/packages/chat/src/components/` renders a 20×20 SVG with `fill="none"`, `stroke="currentColor"`, and `strokeWidth="2"`. The `<line>` (22,2)→(11,13) and `<polygon>` (22,2), (15,22), (11,13), (2,9) define the send arrow pointing upper-right. No props or state management.

- **SwiftUI**: Implement using `Image(systemName:)` with SF Symbols (e.g., `"arrow.up.right.circle"` or `"paperplane.fill"`) for consistency with platform conventions. Alternatively, create a custom `Shape` or use `.foregroundColor(.primary)` to inherit text color like `currentColor` behavior. Size using `.font(.system(size: 20))` or explicit frame.

- **Compose**: Create a `@Composable` function that draws the path using `Canvas` or `Modifier`. Use `drawLine()` and `drawPath()` with `Color.currentColor` analog (e.g., `LocalContentColor.current`). Render at 20dp × 20dp to match web dimensions. Consider wrapping in a `Box(modifier = Modifier.size(20.dp))` to enforce aspect ratio.

- **AppKit / UIKit**: Implement as a custom `UIView` subclass or `NSView` that draws the path using `UIBezierPath` / `NSBezierPath`. Use `tintColor` or `UIColor.label` to inherit the parent's text color. Create a `20×20` image and scale as needed. Alternatively, use system SF Symbols if available on target OS versions.

- **WinUI 3**: Implement as a `Canvas` control in XAML or a custom `UserControl` with `<Path>` elements using `Stroke="{StaticResource SystemBaseHighBrush}"` (or data binding to foreground color). Define the `<Line>` and `<Polygon>` geometry in `<Path.Data>`. Set `Width="20"` and `Height="20"` with `Stretch="Uniform"` to preserve aspect ratio and inherit color from parent `Foreground` property.

## Design Decisions

The component uses `stroke` and `fill="none"` rather than a filled shape because a hollow arrow is more versatile: it remains visible at small sizes, scales cleanly, and works well on both light and dark backgrounds when using `currentColor` for inheritance. The round line caps and joins soften the visual appearance and make the arrow more friendly and less geometric.

The fixed 20×20 size (matching common icon conventions in web UI) is preserved through the SVG viewBox and can be scaled by the parent container. This avoids requiring size props while remaining flexible.

## Compliance

Not applicable: No compliance checks specified for this icon component.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
