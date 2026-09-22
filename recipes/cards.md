---
id: 7e4a2c5b-8f3d-4a7e-b9f2-1c5e8d3b6a2f
title: "Cards"
domain: agenticdevelopertoolkit://recipes/cards
type: ingredient
version: 1.0.0
status: review
language: en
created: 2026-09-22
modified: 2026-09-22
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: "Responsive grid container for arranging card items with adaptive column layout."
platforms: 
  - typescript
  - web
tags: 
  - layout
  - grid
  - cards
depends-on: []
related: []
references: []
approved-by: ""
approved-date: ""
---

# Cards

## Overview

A responsive grid container that arranges card items in a flexible column layout. The component supports adaptive behavior for common use cases: default auto-fit layout, explicit two-column layout when holding exactly two items (`pair`), and explicit three-column layout when holding exactly nine items (`trio`). The component renders a single `<div>` container that accepts children and optional styling.

## Behavioral Requirements

- **must-render-as-div**: Component MUST render as a single `<div>` element.
- **must-apply-base-class**: Component MUST apply the `lp-cards` class to the rendered element.
- **must-pass-children**: Component MUST render all provided children within the container.
- **must-support-pair-layout**: When `pair` prop is `true`, component MUST apply the `lp-cards--pair` class to enable two-column layout.
- **must-support-trio-layout**: When `trio` prop is `true`, component MUST apply the `lp-cards--trio` class to enable three-column layout.
- **must-reject-conflicting-props**: Component MUST throw an error with message `"Cards: \`pair\` and \`trio\` set the same column track — pass at most one"` when both `pair` and `trio` are `true`.
- **must-support-classname-prop**: Component MUST accept an optional `className` prop and include it in the rendered element's class list.
- **must-combine-classes**: Component MUST combine all applicable classes with single space separators and filter out empty strings.

## Appearance

- **Container element**: `<div>`
- **Base class**: `lp-cards`
- **Variant classes**: `lp-cards--pair`, `lp-cards--trio`
- **Layout basis**: CSS Grid (via `lp-cards` class definition in stylesheet)
- **Default behavior**: Auto-fit grid layout defined by `lp-cards` CSS rule
- **Pair behavior**: Explicit two-column layout when `pair={true}` (see Platform Notes for visual reference)
- **Trio behavior**: Explicit three-column layout when `trio={true}` (see Platform Notes for visual reference)
- **Styling**: Controlled entirely through CSS classes; no inline styles applied by component

## States

Not applicable: Cards is a pure layout container with no interactive states.

## Accessibility

- Role: Generic container (`<div>` has no semantic role unless children are interactive)
- Semantics: Responsibility for meaningful content structure falls to children rendered within the container
- Keyboard navigation: Not applicable; component is not interactive
- Screen reader: Announcements depend entirely on children; container itself is transparent to assistive technology

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| cards-001 | must-render-as-div | No props | Renders `<div>` element |
| cards-002 | must-apply-base-class | No props | Element has class `lp-cards` |
| cards-003 | must-pass-children | `children: <span>Item</span>` | Span element is rendered within container |
| cards-004 | must-support-pair-layout | `pair={true}` | Element has classes `lp-cards lp-cards--pair` |
| cards-005 | must-support-trio-layout | `trio={true}` | Element has classes `lp-cards lp-cards--trio` |
| cards-006 | must-reject-conflicting-props | `pair={true} trio={true}` | Throws error: `"Cards: \`pair\` and \`trio\` set the same column track — pass at most one"` |
| cards-007 | must-support-classname-prop | `className="custom"` | Element has classes `lp-cards custom` |
| cards-008 | must-combine-classes | `pair={true} className="custom"` | Element has classes `lp-cards lp-cards--pair custom` in output |

## Edge Cases

- **Conflicting props**: When both `pair` and `trio` are true, an error MUST be thrown synchronously before rendering. This is a caller error, not a silent resolution.
- **Null or undefined children**: Component MUST render successfully with no children or `null` as children; the container remains empty.
- **Empty className**: When `className` is an empty string, it MUST be filtered out and not produce double spaces in the class attribute.
- **Falsy pair/trio**: When `pair` or `trio` are `false`, `undefined`, or not provided, the corresponding class MUST NOT be applied.
- **Boolean prop identity**: The check for conflicting props MUST use strict equality (`=== true`); falsy values like `0`, empty string, or `null` MUST NOT trigger the error.

## Configuration

Not applicable: Cards accepts only presentation-layer props (`children`, `pair`, `trio`, `className`) and has no configurable behavior or options.

## Deep Linking

Not applicable: Cards is a layout container with no user-facing interaction or navigation targets.

## Localization

Not applicable: Cards renders no user-facing text; all content is provided by children.

## Accessibility Options

Not applicable: Cards responds to no platform accessibility options. Accessibility concerns are delegated to children and CSS styling rules (`lp-cards`, `lp-cards--pair`, `lp-cards--trio`).

## Feature Flags

Not applicable: Cards has no conditional behavior subject to feature flags.

## Analytics

Not applicable: Cards is a pure layout container and does not emit user interaction events.

## Privacy

Not applicable: Cards does not collect, store, or transmit data.

## Logging

Not applicable: Cards performs no operations requiring diagnostic logging beyond native browser DevTools inspection.

## Platform Notes

- **TypeScript/Web**: Component defined in `packages/web/packages/landing/src/blocks/Cards.tsx`. Renders a semantic `<div>` with CSS class composition. Grid behavior controlled by three CSS rules: `lp-cards` (base auto-fit layout), `lp-cards--pair` (two-column floor at the component's measure), and `lp-cards--trio` (three-column layout at the component's measure). See `css/blocks.css` for visual specifications.
- **SwiftUI**: Use `VStack` or `LazyVGrid` with adaptive column sizing (`GridItem(.adaptive(minimum: <card-width>))`) to achieve responsive column layout. Accept a view builder for children and provide explicit `gridColumns` binding to match `pair` and `trio` behaviors as computed properties (`pair` → 2 columns, `trio` → 3 columns).
- **Compose**: Use `LazyVerticalGrid` with `GridCells.Adaptive(minSize = <card-width>)` for default layout. Accept a `@Composable` lambda for children and compute column count from `pair` and `trio` flags, passing `GridCells.Fixed(columnCount)` when either is true.
- **AppKit / UIKit**: On macOS, use `NSCollectionView` or `NSStackView` with horizontal axis and wrapping. On iOS, use `UICollectionView` with adaptive layout (`UICollectionViewFlowLayout`) or `UIStackView` nested vertically. Compute column count and floor width from `pair` and `trio` flags; apply width constraints via `NSLayoutConstraint`.
- **WinUI 3**: Use `GridView` control with `ItemsPanel` template set to `WrapGrid` with `Orientation="Horizontal"` and `MaximumRowsOrColumns` bound to column count. When `pair=true`, set `MaximumRowsOrColumns=2`; when `trio=true`, set `MaximumRowsOrColumns=3`; otherwise leave unset for auto-fit. Bind the `ItemsSource` to children collection and apply `ColumnSpacing` and `RowSpacing` properties to match the web CSS spacing values.

## Design Decisions

The `pair` and `trio` props exist to address a CSS Grid auto-fit limitation: a nine-item grid with auto-fit will lay out as 4 + 4 + 1 columns when cards are small, creating a visually incomplete trailing row. The explicit `trio` flag forces exactly three columns when all nine items are present, maintaining visual balance. The `pair` flag similarly enforces two-column layout for exactly two items. Both are opt-in constraints; the default behavior is auto-fit responsive layout. The validation (throwing when both are true) prevents ambiguity: the two flags set the same CSS property, so permitting both would create undefined behavior depending on stylesheet load order.

## Compliance

Not applicable: Cards is a simple layout container that delegates compliance concerns to its children and to CSS styling rules.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
