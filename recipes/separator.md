---
id: da56ecc7-18f6-412e-9368-3beb29309d8d
title: Separator
domain: agenticdevelopercookbook://ingredients/separator
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A visual divider line that separates sections horizontally or vertically
  with semantic accessibility markup.
platforms:
- typescript
- web
tags:
- divider
- separator
- layout-primitive
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Separator

## Overview

The Separator component renders a thin line that visually and semantically separates adjacent content. It is a layout primitive with no interactivity, used to organize sections within a layout. It supports both horizontal and vertical orientations and communicates its orientation to assistive technologies.

## Behavioral Requirements

- **must-render-semantic-separator**: The component MUST render with `role="separator"` to mark it as a separating element in the accessibility tree.
- **must-support-horizontal-orientation**: The component MUST render as a horizontal line by default when orientation is not specified or set to `"horizontal"`.
- **must-support-vertical-orientation**: The component MUST render as a vertical line when orientation is set to `"vertical"`.
- **must-communicate-orientation**: The component MUST set `aria-orientation` to match the orientation prop value (`"horizontal"` or `"vertical"`) to inform assistive technologies of the layout direction the separator follows.
- **must-accept-custom-classname**: The component MUST accept a `className` prop and merge it with the component's base styles.
- **must-accept-standard-element-props**: The component MUST accept and forward standard HTML element props (via `...props`) to the underlying element.

## Appearance

- **Thickness**: 1px (height for horizontal orientation; width for vertical orientation)
- **Full span**: 100% of available width (horizontal) or height (vertical); does not constrain the orthogonal dimension
- **Background**: Uses design token `bg-apt-border` for the separator line color
- **Border**: None
- **Corner radius**: None
- **Shadow**: None
- **Shrink behavior**: Shrinks to 0 when layout space is oversubscribed (does not expand beyond its minimum 1px thickness)

## States

| State | Appearance change |
|-------|---|
| Horizontal (default) | 1px height, full width, horizontal line |
| Vertical | 1px width, full height, vertical line |

## Accessibility

- **Role**: The component renders with `role="separator"` to identify itself as a separating element.
- **Orientation**: The `aria-orientation` attribute MUST reflect the orientation prop value, communicating to screen reader users whether the separator runs horizontally or vertically.
- **No interactive state**: The separator is not keyboard-navigable and does not receive focus; it is an inert presentational element.
- **Label not required**: No accessible name is needed because the separator's purpose is visual layout, not a labeled interactive control.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|---|---|---|
| separator-001 | must-render-semantic-separator, must-support-horizontal-orientation | No props (defaults) | `<div role="separator" aria-orientation="horizontal" data-orientation="horizontal" ... />` with 1px height and full width |
| separator-002 | must-support-vertical-orientation, must-communicate-orientation | `orientation="vertical"` | `<div role="separator" aria-orientation="vertical" data-orientation="vertical" ... />` with 1px width and full height |
| separator-003 | must-accept-custom-classname | `className="custom-class"` | Rendered element includes `custom-class` in its className alongside base styles |
| separator-004 | must-accept-standard-element-props | `data-testid="my-sep" id="sep1"` | Rendered element includes `data-testid="my-sep"` and `id="sep1"` |

## Edge Cases

- **Empty or undefined className**: Component renders with base styles; missing or undefined className does not break rendering.
- **Invalid orientation value**: Behavior undefined; source code has no validation. Developers SHOULD pass only `"horizontal"` or `"vertical"`.
- **Width/height override**: If parent layout or custom className sets explicit dimensions orthogonal to the separator's orientation, the separator renders within those constraints.
- **Zero-space layout**: If the separator's orthogonal dimension is constrained to less than 1px, the line may not be visible; the component does not resize itself.

## Configuration

Not applicable: The Separator component has no configuration options. Its appearance is fully determined by the orientation prop and CSS classes.

## Deep Linking

Not applicable: The Separator is a layout primitive without its own screen or navigation target.

## Localization

Not applicable: The Separator contains no user-facing text.

## Accessibility Options

Not applicable: The Separator is a stateless, non-interactive element and does not respond to accessibility display options (motion, contrast, color differentiation).

## Feature Flags

Not applicable: The Separator component has no feature flags.

## Analytics

Not applicable: The Separator is a passive layout element with no user interaction to track.

## Privacy

Not applicable: The Separator does not collect, store, or transmit any data.

## Logging

Not applicable: The Separator component has no logging behavior.

## Platform Notes

- **SwiftUI**: Use `Divider()` for a default horizontal separator or construct a custom `Rectangle().fill(Color.border).frame(height: 1)` for horizontal and `.frame(width: 1)` for vertical. Set accessibility with `.accessibilityElement(children: .ignore)` and `.accessibilityAddTraits(.updatesFrequently)` if needed, or rely on structural semantics.
- **Compose**: Use `HorizontalDivider()` (Android Material 3) for horizontal or `VerticalDivider()` for vertical orientation. Both render a 1dp line and support color customization via `.surfaceVariant` tokens. No explicit orientation attribute is needed; compose infers it from the composable used.
- **React/Web**: Use the Separator component (`separator.tsx`). Pass `orientation="horizontal"` or `orientation="vertical"`, and optionally a `className` prop for styling. The component handles aria-orientation and role semantics.
- **AppKit / UIKit**: Construct a custom `NSView` (macOS) or `UIView` (iOS) with `wantsLayer = true`, set `backgroundColor = NSColor.separatorColor` (or equivalent), and constrain height to 1 point (horizontal) or width to 1 point (vertical). Alternatively, use `NSBox` with `boxType = .separator` on macOS. Do not add accessibility markup; the separator is semantically inert.
- **WinUI 3**: Use a `Rectangle` control with `Height="1"` (horizontal) or `Width="1"` (vertical), set `Fill` to the border brush resource, and set `HorizontalAlignment="Stretch"` for horizontal or `VerticalAlignment="Stretch"` for vertical. Set `AutomationProperties.AccessibilityView` to `AutomationControlType.Pane` if grouping content.

## Design Decisions

- **1px thickness across platforms**: The separator uses a 1-pixel line to ensure consistent appearance across web, mobile, and desktop. This thickness is the thinnest visually distinct line on standard displays and avoids rendering artifacts.
- **Semantic role and aria-orientation**: The component explicitly marks itself as a separator and communicates its orientation to assistive technologies, ensuring that screen reader users understand the visual structure even when the line may not be visible or distinguishable.
- **No validation of orientation prop**: The source code accepts the orientation prop without validation. Implementations on other platforms are free to either validate or default to horizontal on unrecognized values; this choice should be documented in platform-specific implementation guidelines.

## Compliance

Not applicable: The Separator is a foundational UI primitive with no compliance concerns beyond WCAG 2.1 (semantic role and aria-orientation), which are met by the component's design.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation from web source |
