---
id: 8F4C2B7A-9D3E-4C5F-B2E8-7F6A3C1D5E9B
title: Split
domain: agenticdevelopertoolkit://recipes/split
type: ingredient
version: 1.0.0
status: review
language: en
created: 2026-09-22
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Responsive layout container that renders two panels side by side on wide
  viewports and stacked on narrow ones.
platforms:
- typescript
- web
tags:
- layout
- responsive
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Split

## Overview

Split is a responsive layout container that arranges child elements in two columns on wide viewports and switches to a single-column stacked layout below a specified breakpoint. It is commonly used to position prose content beside an illustration or complementary visual element.

## Behavioral Requirements

- **must-render-children**: Component MUST render all child elements passed to it.
- **must-apply-classname**: Component MUST apply the `lp-split` class to its root element.
- **must-merge-classnames**: Component MUST merge the `lp-split` class with any additional `className` prop provided, applying both to the root element.
- **must-be-responsive**: Component MUST respond to viewport width changes and switch layout orientation according to the breakpoint defined in `css/base.css`.

## Appearance

- **Layout**: Two-column grid on wide viewports; single-column stack on narrow viewports
- **Container**: Flex or grid display (implementation detail; see Platform Notes)
- **Breakpoint**: Defined in `css/base.css`
- **Padding**: Inherited from component nesting and layout context
- **Background**: Transparent (inherits from parent)
- **Foreground/Text**: Inherits from child elements
- **Border**: None by default
- **Shadow**: None by default
- **Min/Max size**: No explicit constraints

## States

Split is a stateless layout container with no interactive states.

| State | Appearance change |
|-------|------------------|
| Default | Two columns wide / single column narrow |

## Accessibility

Split is a generic container with no interactive semantics. Child elements retain their own accessibility properties. The component itself requires no special accessibility attributes — semantic meaning is determined by its children.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| split-001 | must-render-children | Two `<div>` children | Both children rendered in DOM |
| split-002 | must-apply-classname | No `className` prop | Root element has class `lp-split` |
| split-003 | must-merge-classnames | `className="custom-class"` | Root element has classes `lp-split custom-class` |
| split-004 | must-be-responsive | Viewport width 1200px, then 600px | Layout changes from two columns to single column at breakpoint |

## Edge Cases

- **Empty children**: When no children are provided, the component renders an empty `lp-split` container. Behavior is not an error; the container simply occupies no space.
- **Single child**: When only one child is provided, the component renders it within the split container; the single-column layout renders it normally, the two-column layout leaves one column empty.
- **Null className**: When `className` prop is `undefined` or `null`, the component does not append empty strings to the class list; only `lp-split` is applied.
- **Viewport resize**: The component responds to dynamic viewport resizes (e.g., orientation change, window resize) via CSS media queries; no JavaScript-based resize listener is implemented.
- **Very wide viewports**: No maximum width constraint is enforced; the two-column layout expands indefinitely.
- **Very narrow viewports**: Below the breakpoint, the component stacks to a single column with no minimum width enforced.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `children` | `ReactNode` | required | Content to render within the split container |
| `className` | `string` | `undefined` | Additional CSS class(es) to merge with `lp-split` |

## Deep Linking

Not applicable: Split is a layout container without independent navigation or state representation.

## Localization

Not applicable: Split is a structural component with no user-facing text.

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | Not applicable; Split contains no motion or animation. Behavior is determined by child components. |
| Increase Contrast | Not applicable; Split has no visual styling. Contrast is determined by child components. |
| Differentiate Without Color | Not applicable; Split is a layout container with no color-dependent information. |

## Feature Flags

Not applicable: Split is a foundational layout component with no conditional feature behavior.

## Analytics

Not applicable: Split is a structural component that does not track user interactions.

## Privacy

Not applicable: Split does not collect, store, or transmit any data.

## Logging

Not applicable: Split is a presentation component with no runtime state changes to log.

## Platform Notes

- **TypeScript/Web**: `Split.tsx` accepts `children: ReactNode` and optional `className: string`. Renders a `<div>` with class `lp-split` merged with any provided `className`. Responsive behavior is driven by CSS media queries defined in `css/base.css`.
- **SwiftUI**: Map to a `VStack` or `HStack` with adaptive layout. Use `@Environment(\.horizontalSizeClass)` to switch between two-column (`.regular`) and single-column (`.compact`) layouts. Apply styling to the container.
- **Compose**: Map to a `Column` (vertical) or `Row` (horizontal) with `Modifier.fillMaxWidth()`. Use `LocalConfiguration.current.screenWidthDp` to detect breakpoint and switch layout orientation dynamically.
- **AppKit / UIKit**: Map to `NSStackView` (macOS) or `UIStackView` (iOS) with `axis` toggled between `.horizontal` and `.vertical` based on size class. Use `traitCollectionDidChange(_:)` or `viewWillTransition(to:with:)` to respond to layout changes.
- **WinUI 3**: Map to `StackPanel` with `Orientation` switched between `Horizontal` and `Vertical` based on `ActualWidth` or `Window.Current.Bounds.Width` compared to breakpoint. Use `SizeChanged` event to detect viewport changes and update layout orientation. Set `HorizontalAlignment` and `VerticalAlignment` to `Stretch` to fill available space.

## Design Decisions

The component delegates all styling and layout logic to CSS (`css/base.css`). This keeps the component stateless and focuses its responsibility on rendering children with the appropriate class names. Implementations on other platforms SHOULD follow this principle: use platform-native layout primitives (HStack, Row, StackPanel) and drive the orientation toggle via environment/configuration rather than imperative state management.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| Semantic structure (children preserved) | passed | Accessibility |
| No color-dependent information | passed | Accessibility |
| Responsive layout coverage | passed | Responsiveness |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation |
