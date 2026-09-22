---
id: fcc6d4c4-d83e-402a-857c-fbd0aff91113
title: Stack
domain: agenticdevelopercookbook://ingredients/stack
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Vertical and horizontal layout containers that arrange children with flexible
  gap, alignment, and justification.
platforms:
- web
tags:
- layout
- flexbox
depends-on: []
related: []
references: []
---

# Stack

## Overview

VStack and HStack are layout containers that arrange child elements in a vertical or horizontal direction using CSS Flexbox. They provide a flexible gap property, alignment control via `alignItems`, and justification control via `justifyContent`. Both components render as semantic div elements and accept custom CSS classes and inline styles for further customization.

## Behavioral Requirements

- **must-render-children**: Both VStack and HStack MUST render all child elements passed via the `children` prop.
- **must-apply-gap-prop**: The component MUST apply the `gap` prop as a CSS gap property; when `gap` is a number, it MUST be converted to a pixel string (e.g., `16` becomes `"16px"`); when `gap` is a string, it MUST be applied as-is.
- **must-apply-align**: The component MUST apply the `align` prop directly to the CSS `alignItems` property.
- **must-apply-justify**: The component MUST apply the `justify` prop directly to the CSS `justifyContent` property.
- **must-apply-inline-styles**: The component MUST merge provided `style` prop values with layout-specific styles, giving precedence to `style` prop values when both are present.
- **must-apply-class-names**: The component MUST apply the base class name `aws-stack` to the root element; MUST apply either `aws-stack--v` for VStack or `aws-stack--h` for HStack; MUST append the `className` prop if provided.
- **must-handle-undefined-gap**: The component MUST return `undefined` for the CSS gap property when the `gap` prop is not provided.
- **should-preserve-semantic-div**: The component SHOULD render a semantic `div` element to preserve document outline and allow CSS overrides via class-based styling.

## Appearance

- **Container element**: `<div>`
- **Display**: `flex` (set by `aws-stack` class or equivalent)
- **Gap**: Customizable via `gap` prop; defaults to `undefined` (no gap)
- **Alignment**: Customizable via `align` prop (maps to `alignItems`); defaults to `undefined`
- **Justification**: Customizable via `justify` prop (maps to `justifyContent`); defaults to `undefined`
- **Direction**: VStack uses column; HStack uses row (set by `aws-stack--v` or `aws-stack--h` class)
- **Padding**: None by default; customizable via inline `style` prop

## States

Not applicable: Stack is a non-interactive layout container and does not have interaction states.

## Accessibility

- **Role**: Container; no explicit ARIA role required if used to group semantic content.
- **Keyboard navigation**: Not applicable; Stack is a layout primitive and does not handle keyboard interaction. Child elements within the Stack maintain their native keyboard behavior.
- **Screen reader**: Stack MUST NOT obscure semantic meaning of child elements. The root `div` MUST NOT be marked as a landmark or presentation role unless the consuming code explicitly sets it.
- **Labels**: Not applicable; Stack is a layout container and carries no label. Child interactive elements within the Stack MUST maintain their own labels.
- **Semantic structure**: Stack MUST be transparent to the document outline. Child elements MUST maintain their semantic value (headings, buttons, etc.).

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|----|----|----|
| stack-001 | must-render-children | VStack with two child divs | Both child elements rendered in the DOM |
| stack-002 | must-apply-gap-prop (number) | VStack with `gap={16}` | CSS style has `gap: "16px"` |
| stack-003 | must-apply-gap-prop (string) | VStack with `gap="1rem"` | CSS style has `gap: "1rem"` |
| stack-004 | must-apply-gap-prop (undefined) | VStack with no `gap` prop | CSS style has `gap: undefined` (no gap in output) |
| stack-005 | must-apply-align | HStack with `align="center"` | CSS style has `alignItems: "center"` |
| stack-006 | must-apply-justify | VStack with `justify="space-between"` | CSS style has `justifyContent: "space-between"` |
| stack-007 | must-apply-inline-styles | VStack with `style={{ padding: '10px' }}` | Inline styles merged; rendered element includes `padding: 10px` |
| stack-008 | must-apply-class-names (VStack) | VStack with `className="custom"` | Root element has classes: `aws-stack aws-stack--v custom` |
| stack-009 | must-apply-class-names (HStack) | HStack with `className="custom"` | Root element has classes: `aws-stack aws-stack--h custom` |
| stack-010 | should-preserve-semantic-div | Both VStack and HStack | Root element is a `<div>` tag, not a custom element |

## Edge Cases

- **Undefined children**: If `children` is `undefined` or `null`, the component MUST render an empty div with layout classes applied.
- **Empty children array**: If `children` is an empty array, the component MUST render an empty div with layout classes applied.
- **Gap as zero**: If `gap={0}`, the component MUST apply `gap: "0px"`; if `gap="0"`, it MUST apply `gap: "0"`.
- **Conflicting inline styles**: If `style` prop contains `gap`, `alignItems`, or `justifyContent` properties, those MUST take precedence over props, as the merge operation spreads `style` last.
- **Missing direction class**: If the `aws-stack--v` or `aws-stack--h` class is not applied, the component's flex direction is undefined and layout will fail. Implementations MUST ensure one directional class is always present.
- **className filtering**: Empty strings in the className filter operation MUST be removed; only truthy class names MUST be joined.

## Configuration

Not applicable: Stack is a layout primitive with props-based configuration and does not require runtime configuration flags or options beyond what the props provide.

## Deep Linking

Not applicable: Stack is a layout container with no standalone URL representation or deep linking capability.

## Localization

Not applicable: Stack contains no user-facing strings or locale-dependent behavior.

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | Not directly handled by Stack. Consuming code may use this setting to suppress gap animations or transitions. Stack itself does not define transitions. |
| Increase Contrast | Not applicable; Stack is a layout container with no colors or contrast requirements. |
| Differentiate Without Color | Not applicable; Stack does not rely on color to convey information. |

## Feature Flags

Not applicable: Stack is a foundational layout component and does not require feature flags.

## Analytics

Not applicable: Stack is a non-interactive layout container and does not generate user events.

## Privacy

Not applicable: Stack does not collect, store, or transmit any user data.

## Logging

Not applicable: Stack is a layout primitive with no logging requirements in the source code.

## Platform Notes

- **React/Web**: Implemented as functional components in `Stack.tsx`. VStack renders a div with `aws-stack--v` class; HStack renders a div with `aws-stack--h` class. Gap conversion from number to pixel string is handled by the `gapValue()` utility. Styles are merged inline using spread syntax, with the `style` prop taking precedence. Classes are filtered and joined using a simple boolean filter to avoid empty strings.
- **SwiftUI**: Implement using SwiftUI's native `VStack` and `HStack` views. Map the `gap` parameter to SwiftUI's `.spacing()` modifier; map `align` to the alignment parameter; map `justify` to VStack/HStack's alignment parameter. SwiftUI aligns and distributes children natively — no CSS classes needed.
- **Compose (Android)**: Implement using Jetpack Compose's `Column` (for VStack) and `Row` (for HStack) composables. Map `gap` to the `verticalArrangement` (Column) or `horizontalArrangement` (Row) parameter; use `Arrangement.spacedBy()` for gap values. Map `align` to the `verticalAlignment` (Column) or `horizontalAlignment` (Row) parameter. Compose does not use CSS classes; styling is via modifier composition.
- **AppKit / UIKit**: Use `NSStackView` (macOS) or `UIStackView` (iOS) as the container. Set the `axis` property to `.vertical` for VStack or `.horizontal` for HStack. Map `gap` to the `spacing` property; map `align` to the `alignment` property; map `justify` to the `distribution` property (using `.fillEqually`, `.equalCentering`, or `.fill` as appropriate for the semantic intent).
- **WinUI 3**: Implement using XAML `StackPanel` or a `Grid` with defined rows/columns. For VStack, set `Orientation="Vertical"`; for HStack, set `Orientation="Horizontal"`. Map `gap` to the `Spacing` property (an integer). WinUI 3 does not have a direct `alignItems` equivalent; use `VerticalAlignment` or `HorizontalAlignment` on child elements or the StackPanel itself, depending on the desired layout behavior. Use `HorizontalAlignment="Stretch"` or `VerticalAlignment="Stretch"` to achieve flex-like fill behavior. Custom classes can be applied via `Style` property if CSS-in-XAML is available in the project.

## Design Decisions

- **Gap prop accepts number or string**: The component accepts both numeric and string gap values to provide flexibility. Numeric values are converted to pixels; string values allow for any CSS unit (rem, em, %, etc.). This design accommodates both fixed-pixel spacing and responsive relative sizing.
- **Inline style precedence**: The `style` prop is spread last in the merged styles object, giving it precedence over layout-derived styles. This allows consumers to override gap, alignment, or justification when needed without modifying the component.
- **CSS class filtering**: The className array is filtered to remove falsy values (empty strings) before joining. This prevents malformed class strings and ensures clean DOM output.
- **Undefined gap handling**: When `gap` is undefined, the CSS gap property is not set. This allows default styling from the CSS class definitions to apply, reducing redundant inline style declarations.

## Compliance

Not applicable: Stack is a layout primitive with no security, compliance, or regulatory requirements in its domain.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | | Initial creation |
