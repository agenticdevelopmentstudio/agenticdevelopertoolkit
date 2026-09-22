---
id: 51d3b1ba-ced7-4c08-8a63-c83094d91299
title: Wrap
domain: agenticdevelopercookbook://ingredients/wrap
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Layout wrapper that constrains content width while allowing full-width backgrounds
  on the screen.
platforms:
- typescript
- web
tags: []
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Wrap

## Overview

Wrap is a presentational layout component that renders a `div` element containing child content. It applies a consistent CSS class (`lp-wrap`) and optionally accepts additional CSS classes, filtering out falsy values. The component enables a screen to paint edge-to-edge while constraining the logical content to a single centered column.

## Behavioral Requirements

- **must-render-children**: Component MUST render all child elements unchanged.
- **must-apply-lp-wrap-class**: Component MUST apply the class `lp-wrap` to the rendered div element.
- **must-support-custom-class**: Component MUST conditionally apply a `className` prop when provided.
- **must-filter-falsy-classnames**: Component MUST filter out falsy (null, undefined, empty string) values from the className before applying it.
- **must-combine-classes**: Component MUST combine `lp-wrap` and any custom className with a space separator.

## Appearance

Wrap itself defines no appearance — it is purely a layout container. All visual styling is controlled by the `lp-wrap` class, which is defined in the consuming application's stylesheet. The component accepts no appearance-related props.

## States

Not applicable: Wrap is a static, non-interactive container with no state-dependent behavior.

## Accessibility

Not applicable: Wrap is a transparent layout container that passes all content through to the DOM. Accessibility roles and labels are determined by the child elements it contains, not by Wrap itself.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| wrap-001 | must-render-children | `<Wrap><span>Hello</span></Wrap>` | Rendered output includes `<span>Hello</span>` |
| wrap-002 | must-apply-lp-wrap-class | `<Wrap><div></div></Wrap>` | Rendered div has class `lp-wrap` |
| wrap-003 | must-support-custom-class | `<Wrap className="extra"><div></div></Wrap>` | Rendered div has both `lp-wrap` and `extra` classes |
| wrap-004 | must-filter-falsy-classnames | `<Wrap className={undefined}><div></div></Wrap>` | Rendered div has only `lp-wrap` class, no undefined artifacts |
| wrap-005 | must-filter-falsy-classnames | `<Wrap className=""><div></div></Wrap>` | Rendered div has only `lp-wrap` class |
| wrap-006 | must-combine-classes | `<Wrap className="custom"><div></div></Wrap>` | Class attribute reads exactly `lp-wrap custom` |

## Edge Cases

- **Empty children**: Wrap MUST render an empty div when children is undefined, null, or an empty array. The `lp-wrap` class is still applied.
- **Undefined className**: When className is undefined or null, Wrap MUST NOT include it in the output; only `lp-wrap` is applied.
- **Empty string className**: When className is an empty string, Wrap MUST filter it out; only `lp-wrap` is applied.
- **Boolean or number className**: When className is a boolean or number (edge cases in JavaScript), Wrap MUST filter out falsy values (false, 0) but preserve truthy values. This behavior is determined by the `.filter(Boolean)` logic in the source.

## Configuration

Not applicable: Wrap accepts only `children` and optional `className` props. These are not configuration settings but core props for rendering content and styling.

## Deep Linking

Not applicable: Wrap is a layout container with no semantic URL representation or deep-linking capability.

## Localization

Not applicable: Wrap contains no user-facing strings or localization concerns.

## Accessibility Options

Not applicable: Wrap is a transparent container that does not respond to accessibility display options.

## Feature Flags

Not applicable: Wrap is a foundational layout component with no feature flag gates.

## Analytics

Not applicable: Wrap is a non-interactive container that produces no user interaction events.

## Privacy

Not applicable: Wrap does not collect, store, or transmit any data.

## Logging

Not applicable: Wrap is a simple presentational component with no noteworthy lifecycle or state change events to log.

## Platform Notes

- **TypeScript / Web**: React functional component in `packages/web/packages/landing/src/deck/Wrap.tsx`. Accepts `children: ReactNode` and `className?: string`. Combines class names using `['lp-wrap', className].filter(Boolean).join(' ')` to omit falsy values.
- **SwiftUI**: Implement using a `VStack` or `Container` that takes child views and applies layout constraints via frame modifiers. The `lp-wrap` styling equivalent would be applied via `.frame(maxWidth: .infinity)` and padding/margin modifiers defined in a custom layout container.
- **Compose**: Implement using a `Column` composable that accepts child composables and applies width constraints via `modifier.fillMaxWidth()`. Conditional class application is replaced with conditional layout parameters. CSS class names become `Modifier` chains applied conditionally.
- **AppKit / UIKit**: Implement as a subclass of `NSView` (macOS) or `UIView` (iOS) that acts as a container view. Layout is managed via Auto Layout constraints or manual frame calculation. The `lp-wrap` styling is replicated through view properties (backgroundColor, layer properties, or layout guides).
- **WinUI 3**: Implement as a `UserControl` or directly as a `StackPanel` with `Orientation="Vertical"` and `HorizontalAlignment="Stretch"`. Bind the `Children` property to accept multiple UIElements. Apply the `lp-wrap` styling via XAML style resources that set Width, Padding, or other layout properties. Use `VisualStateManager` if conditional styling is needed, otherwise manage visibility through binding converters for the custom class equivalents.

## Design Decisions

Wrap uses a simple className filtering strategy (`filter(Boolean)`) rather than conditional ternary operators. This approach handles edge cases — undefined, null, empty strings, false, 0 — uniformly without explicit type guards, reducing boilerplate. The consequence is that any falsy className value is discarded, not conditionally included based on type.

## Compliance

Not applicable: Wrap is a foundational layout component that makes no normative claims about accessibility compliance, security, or data handling. Compliance concerns are owned by child components and the consuming application's styles.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
