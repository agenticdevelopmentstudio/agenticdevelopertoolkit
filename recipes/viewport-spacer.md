---
id: 556f7dbf-2a14-4e97-aaa2-0954c7488e6f
title: ViewportSpacer
domain: agenticdevelopercookbook://ingredients/viewport-spacer
type: ingredient
version: 1.0.0
status: review
language: en
created: 2026-09-22
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Flex spacer that absorbs leftover vertical space in a ViewportShell, pushing
  siblings downward.
platforms:
- web
tags: []
depends-on: []
related: []
references: []
---

# ViewportSpacer

## Overview

A flex spacer component that absorbs leftover vertical space inside a `<ViewportShell>`, pushing siblings (typically a `<ViewportComposer>`) to the bottom. The component renders as a flex item that grows to fill available space.

## Behavioral Requirements

- **must-render-children**: Component MUST render any children passed via the `children` prop.
- **must-apply-default-class**: Component MUST apply the CSS class `vp-spacer` to its root element.
- **must-support-custom-class**: Component MUST apply a custom `className` prop when provided.
- **must-combine-classes**: Component MUST combine the default class `vp-spacer` with a custom `className`, separating them by a space (e.g., `vp-spacer custom-class`).

## Appearance

Not applicable: ViewportSpacer is a layout-only component with no built-in visual styling. Appearance is entirely controlled by CSS classes applied to it and its parent flex container.

## States

Not applicable: ViewportSpacer is a static layout component with no interactive states or state transitions.

## Accessibility

Not applicable: ViewportSpacer is a structural layout component that has no semantic role. It does not require a label, role attribute, or state announcements. Accessibility is inherited from the parent flex container and sibling components.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| viewport-spacer-001 | must-render-children | `children={<p>Content</p>}` | Component renders the paragraph element as a child |
| viewport-spacer-002 | must-apply-default-class | No props provided | Root div element has `class="vp-spacer"` |
| viewport-spacer-003 | must-support-custom-class | `className="my-custom"` | Root div element has `class="vp-spacer my-custom"` |
| viewport-spacer-004 | must-combine-classes | `className="custom-a custom-b"` | Root div element has `class="vp-spacer custom-a custom-b"` |
| viewport-spacer-005 | must-render-children | `children={undefined}` (no children) | Component renders an empty div with class `vp-spacer` |
| viewport-spacer-006 | must-support-custom-class | `className=""` (empty string) | Root div element has `class="vp-spacer"` (empty string does not add extra space) |

## Edge Cases

- **No children**: When no children are passed, the component renders an empty flex item. Expected behavior: the spacer still occupies and grows to fill available vertical space per flex layout rules.
- **Empty className**: When an empty string is passed as `className`, the component MUST NOT create a trailing space in the class attribute.
- **Null or undefined children**: When children is explicitly `null` or `undefined`, the component MUST render an empty element without error.
- **Multiple children**: When multiple children are passed (e.g., within a fragment), the component MUST render all of them.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| children | ReactNode | undefined | Optional content to render inside the spacer |
| className | string | undefined | Optional custom CSS class(es) to apply alongside the default `vp-spacer` class |

## Deep Linking

Not applicable: ViewportSpacer is a layout component without a user-facing URL or deep link target.

## Localization

Not applicable: ViewportSpacer contains no user-facing text or localization strings.

## Accessibility Options

Not applicable: ViewportSpacer is a structural component without interactive elements or visual content that responds to accessibility display options.

## Feature Flags

Not applicable: ViewportSpacer has no feature flag logic in the source code.

## Analytics

Not applicable: ViewportSpacer is a layout component that does not track user interactions or analytics events.

## Privacy

Not applicable: ViewportSpacer does not collect, store, or transmit any data.

## Logging

Not applicable: ViewportSpacer contains no logging or diagnostic output in the source code.

## Platform Notes

- **SwiftUI**: Use the built-in `Spacer()` modifier with `frame(minHeight: .infinity)` to achieve the same flex-grow behavior. Place it within a `VStack` with `.layoutPriority(-1)` to ensure it absorbs extra space while siblings remain at their natural size.
- **Compose**: Use `Spacer(modifier = Modifier.weight(1f))` within a `Column` layout to absorb available vertical space and push siblings downward.
- **React/Web**: The ViewportSpacer component as defined in the source. Relies on parent flex container (ViewportShell) having `display: flex` and `flex-direction: column`. The component itself implicitly uses `flex-grow: 1` via CSS class `vp-spacer`.
- **AppKit / UIKit**: Create a `NSView` (macOS) or `UIView` (iOS) with a transparent background and add layout constraints or use Auto Layout stack views. Set the view's vertical content hugging priority to `.defaultLow` and compression resistance to `.defaultLow` so it expands to fill available space.
- **WinUI 3**: Use a `Grid` element with a `RowDefinition` of `"*"` (star sizing) inside a parent `StackPanel` with `Orientation="Vertical"`. The star-sized row automatically absorbs leftover vertical space. Alternatively, use a `Border` with `VerticalAlignment="Stretch"` inside a vertical `StackPanel`.

## Design Decisions

ViewportSpacer is a pure layout component with no visual appearance or interactive behavior. It delegates all styling to CSS and relies entirely on flex layout for its behavior. The component is intentionally minimal: it accepts only `children` and `className` props to allow maximum flexibility in class composition and content while maintaining a predictable flex-grow-1 behavior.

The class composition logic (combining `vp-spacer` with an optional `className`) follows a common React pattern: the default class is always applied, and custom classes are concatenated with a space separator. This allows consuming code to extend the component's styling without needing to recreate the base class.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| Source code fidelity | passed | Implementation |
| Behavioral completeness | passed | Requirements |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation from source |
