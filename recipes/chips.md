---
id: 12cc7564-cb08-4b62-9785-c3b1cc0c46f0
title: Chips
domain: agenticdevelopercookbook://ingredients/chips
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A row of inline label chips that displays provider availability or planned
  features with optional visual variants.
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

# Chips

## Overview

A horizontal list component that renders a row of provider chips. Each chip displays a label and MAY indicate availability. The component supports two visual treatments: a standard appearance for currently available providers and a dimmed, dashed variant for planned or upcoming providers.

## Behavioral Requirements

- **must-render-list**: Component MUST render entries as an unordered list (`<ul>`).
- **must-render-entries**: Component MUST render each entry in the list as a list item (`<li>`).
- **must-apply-open-class**: Component MUST apply the `lp-chip--open` class to list items whose corresponding entry has `open === true`.
- **must-not-apply-open-class**: Component MUST NOT apply the `lp-chip--open` class to list items whose corresponding entry has `open !== true` or `open` is undefined.
- **must-render-label**: Component MUST render the `label` property from each entry as the content of its list item.
- **must-apply-soon-class**: Component MUST apply the `lp-chips--soon` class to the list when `soon === true`.
- **must-not-apply-soon-class**: Component MUST NOT apply the `lp-chips--soon` class when `soon` is not `true` or is undefined.
- **must-apply-base-class**: Component MUST apply the `lp-chips` class to the list.

## Appearance

- **List element**: `<ul>` with class `lp-chips` (or `lp-chips lp-chips--soon` when `soon` is true)
- **List items**: `<li>` elements, each with optional class `lp-chip--open` when the entry's `open` property is `true`
- **Label content**: Rendered as-is from the `label` property (ReactNode); styling is defined in `css/blocks.css` under `.lp-chips` and `.lp-roadmap` rules
- **Standard appearance**: `.lp-chips` class provides the baseline styling for available providers
- **Planned variant**: `.lp-chips--soon` provides dashed, dimmed, accent-free treatment for planned agents (see `css/blocks.css` `.lp-roadmap` comment for structural reasoning)

## States

| State | Appearance change |
|-------|------------------|
| Default | Renders with `lp-chips` class; open entries have `lp-chip--open` applied |
| Planned | Renders with both `lp-chips` and `lp-chips--soon` classes; dashed, dimmed, accent-free treatment |

## Accessibility

Semantic HTML: component uses standard `<ul>` and `<li>` elements, which are recognized by assistive technologies as a list structure. Labels are rendered as passed; if labels require accessible text alternatives or ARIA attributes, that is the responsibility of the caller to provide through the `label` prop (which accepts ReactNode).

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| chips-001 | must-render-list, must-apply-base-class | `{ entries: [{ label: "Provider A" }], soon: false }` | `<ul class="lp-chips">` contains rendered entries |
| chips-002 | must-render-entries, must-render-label | `{ entries: [{ label: "Provider A" }, { label: "Provider B" }] }` | Two `<li>` elements rendered; first contains "Provider A", second contains "Provider B" |
| chips-003 | must-apply-open-class | `{ entries: [{ label: "Open", open: true }] }` | `<li class="lp-chip--open">` contains "Open" |
| chips-004 | must-not-apply-open-class | `{ entries: [{ label: "Closed" }] }` | `<li>` (no `lp-chip--open` class) contains "Closed" |
| chips-005 | must-apply-soon-class | `{ entries: [{ label: "Coming Soon" }], soon: true }` | `<ul class="lp-chips lp-chips--soon">` rendered |
| chips-006 | must-not-apply-soon-class | `{ entries: [{ label: "Available" }], soon: false }` | `<ul class="lp-chips">` (no `lp-chips--soon` class) |
| chips-007 | must-not-apply-soon-class | `{ entries: [{ label: "Available" }] }` | `<ul class="lp-chips">` (no `lp-chips--soon` class) |
| chips-008 | must-render-list | `{ entries: [] }` | `<ul class="lp-chips"></ul>` (empty list) |

## Edge Cases

- **Empty entries array**: Component renders an empty `<ul class="lp-chips"></ul>` with no list items.
- **Undefined `soon` property**: Treated as falsy; `lp-chips--soon` class is not applied. Component renders with base `lp-chips` class only.
- **Undefined `open` property on entry**: Treated as falsy; `lp-chip--open` class is not applied to that list item.
- **Mixed open states**: Some entries have `open: true`, others do not. Each entry renders with or without `lp-chip--open` independently based on its own `open` value.
- **ReactNode label**: The `label` prop accepts any ReactNode (string, number, element, fragment, etc.). Component renders it as-is without validation or transformation.
- **Null or undefined label**: If `label` is falsy (null, undefined, empty string), the component renders an `<li>` with that falsy content. Behavior depends on React's rendering of falsy children.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `entries` | `ChipEntry[]` | (required) | Array of chip entries, each with a required `label` and optional `open` boolean |
| `soon` | `boolean` | `undefined` (falsy) | When `true`, applies the `lp-chips--soon` class for the planned/roadmap visual treatment |

## Deep Linking

Not applicable: component is a stateless display element with no navigation targets.

## Localization

Not applicable: component renders labels provided by the caller. Any string localization is the responsibility of the caller passing localized text via the `label` prop.

## Accessibility Options

Not applicable: component renders semantic HTML (`<ul>` / `<li>`) and does not respond to display accessibility options. Label content and meaning are determined by what the caller passes.

## Feature Flags

Not applicable: component has no feature-flag-gated behavior.

## Analytics

Not applicable: component is a stateless display element with no user interactions or state changes to track.

## Privacy

Not applicable: component does not collect, store, or transmit any data. It renders labels provided by the caller.

## Logging

Not applicable: component has no logging.

## Platform Notes

- **React/Web**: Defined in `packages/web/packages/landing/src/blocks/Chips.tsx`. Styling applied via CSS classes `lp-chips`, `lp-chip--open`, and `lp-chips--soon` defined in `css/blocks.css`. The component maps entries to `<li>` elements and applies conditional classes based on `open` and `soon` props. Key decision: the `<li>` carries no base chip class of its own (as noted in source comment), only `lp-chip--open` when explicitly set. This asymmetry matches the source design.

- **SwiftUI**: Create a vertical or horizontal stack (`VStack` or `HStack`) containing views for each entry. Bind each view's appearance to its `open` state using `.opacity()` or `.foregroundColor()` for the dimmed effect when `soon` is true. Use a Capsule or RoundedRectangle shape for the chip appearance and apply conditional modifiers for the dashed border when needed.

- **Compose**: Implement as a Compose Row containing Chip composables (or Surface + Text combinations) for each entry. Use `Modifier.alpha()` to dim chips when in the "soon" state, and apply a dashed stroke to the container using `BorderStroke` with `DashPathEffect` for the planned variant.

- **AppKit / UIKit**: Create an NSStackView (macOS) or UIStackView (iOS) with axis `.horizontal` containing custom NSView or UIView subclasses for each chip. Apply `CAShapeLayer` for dashed borders and `CABasicAnimation` for any state transitions. Use `NSView.alpha` or `UIView.alpha` to dim the entire stack when `soon` is true.

- **WinUI 3**: Implement using a StackPanel with Orientation="Horizontal" containing Button or ContentPresenter controls for each chip. Bind visibility and opacity to the `open` and `soon` state using ConverterValueConverter. Use a dashed stroke from `Windows.UI.Xaml.Media.StrokeStyle` for the planned variant's border treatment.

## Design Decisions

The component is intentionally simple: it accepts an array of entry objects and renders them as a list with conditional CSS classes. The asymmetry between the base `lp-chips` class on the container and the conditional `lp-chip--open` class on individual items (rather than a base `lp-chip` class) preserves the structural pattern established in the source CSS and avoids over-engineering a straightforward display component.

## Compliance

Not applicable: component is a presentational element without security, authentication, or privacy implications.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku | Initial creation from web source |
