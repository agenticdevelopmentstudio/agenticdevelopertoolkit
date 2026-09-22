---
id: c5703986-6d14-4341-8719-b89e44f2ab80
title: Label
domain: agenticdevelopertoolkit://recipes/label
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A semantic form label element with Tailwind styling that renders flexbox-aligned
  text with support for peer-based disabled state.
platforms:
- typescript
- web
tags:
- form-controls
- label
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Label

## Overview

The Label component is a reusable HTML `label` element wrapper that applies default Tailwind CSS styling for typography and layout. It is designed as a primitive form label that pairs with form controls via the `htmlFor` attribute or nesting. The component accepts all standard HTML label properties and supports class merging for additional customization.

## Behavioral Requirements

- **must-render-label-element**: Component MUST render as an HTML `label` element.
- **must-accept-all-label-props**: Component MUST accept and forward all standard HTML label attributes (`htmlFor`, `id`, event handlers, etc.) via prop spreading.
- **must-apply-default-styling**: Component MUST apply default Tailwind CSS classes: `flex`, `items-center`, `gap-2`, `text-sm`, `font-medium`, `leading-none`, `text-apt-text`, and `select-none`.
- **must-merge-classname-prop**: Component MUST accept a `className` prop and merge it with default classes using a class merging utility.
- **must-respond-to-peer-disabled-state**: Component MUST apply `cursor-not-allowed` and `opacity-50` when a peer form control (via CSS `:peer-disabled` selector) is in a disabled state.

## Appearance

- **Corner radius**: None
- **Padding**: None (explicit padding not applied; flexbox layout provides spacing)
- **Font**: Medium weight (font-medium), small size (text-sm)
- **Foreground/Text**: `text-apt-text` (design system token)
- **Gap between children**: 2 units (via `gap-2` flex gap)
- **User select**: None (text is not user-selectable)
- **Text alignment**: Flexbox centered vertically on the cross-axis (items-center)

## States

| State | Appearance change |
|-------|------------------|
| Default | Standard text color and cursor |
| Peer Disabled | Cursor changes to `not-allowed`; opacity reduces to 50% |

## Accessibility

The component renders a native `label` element, providing semantic meaning for assistive technologies. Consumers are responsible for associating the label with its form control via the `htmlFor` attribute (matching the control's `id`) or by nesting the form control within the label. Per the source code ESLint comment, this association is the consumer's responsibility because the component is a reusable primitive that does not know which control it pairs with.

- **Role**: Label (native HTML semantic element)
- **Label requirements**: Consumer MUST provide `htmlFor` attribute or nest the associated form control
- **Announce state changes**: Disabled state is communicated via opacity and cursor change; screen readers perceive this via the peer element's disabled state

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| label-001 | must-render-label-element | Render with no props | HTML `label` element in DOM |
| label-002 | must-accept-all-label-props | Pass `htmlFor="input-id"` and `id="label-1"` | Label renders with matching `htmlFor` and `id` attributes |
| label-003 | must-apply-default-styling | Render with default props | Class list includes `flex`, `items-center`, `gap-2`, `text-sm`, `font-medium`, `leading-none`, `text-apt-text`, `select-none` |
| label-004 | must-merge-classname-prop | Pass `className="custom-class"` | Rendered element has both default classes and `custom-class` |
| label-005 | must-respond-to-peer-disabled-state | Render adjacent to disabled input; input becomes disabled | Label applies `peer-disabled:cursor-not-allowed` and `peer-disabled:opacity-50` |

## Edge Cases

- **Missing htmlFor or nesting**: Component renders; however, the label is not semantically associated with a control. This is a consumer error, not a component failure.
- **Empty label text**: Component renders as an empty label element; flexbox layout applies but with no visible content.
- **Multiple children**: Component layout supports multiple children via flexbox with `gap-2` spacing between them.
- **className collision**: If the `className` prop includes any of the default class names, the class merging utility handles deduplication.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `className` | string | undefined | Additional CSS classes to merge with defaults |
| `htmlFor` | string | undefined | Associates label with form control by its `id` |
| `id` | string | undefined | HTML id attribute for the label element |
| `...props` | all label props | — | All other standard HTML label attributes (event handlers, data attributes, etc.) |

## Deep Linking

Not applicable: Label is a low-level form control primitive without its own deep linking behavior.

## Localization

Not applicable: Label component contains no user-facing strings; localization is the consumer's responsibility via text content passed as children.

## Accessibility Options

Not applicable: Label responds only to the native disabled state of peer elements, which is handled by the form control itself. No additional accessibility display options (Reduce Motion, Increase Contrast, Differentiate Without Color) are directly managed by this component.

## Feature Flags

Not applicable: Label is a primitive component with no feature flags.

## Analytics

Not applicable: Label is a non-interactive primitive; no analytics events are emitted.

## Privacy

Not applicable: Label does not collect or transmit any data.

## Logging

Not applicable: Label does not perform any logging.

## Platform Notes

- **React/Web**: Direct implementation from the source. Files: `packages/web/packages/ui/src/components/label.tsx`. Exports a named `Label` function component that accepts `React.ComponentProps<"label">`. Uses Tailwind CSS utility classes and a `cn()` class merging utility from a sibling `../lib/utils` module.
- **SwiftUI**: Start from SwiftUI's native `Label` or compose using `HStack` with `Text` and optional icon. Wrap in a view modifier to disable user selection and apply the equivalent font (medium, small) and color styling. Peer disabled state would be managed via an `@Environment` property binding to the associated form field's disabled state.
- **Compose (Kotlin)**: Use Jetpack Compose's `Text` composable within a `Row` layout with appropriate `Modifier` settings for alignment, padding, and text style. Apply `Modifier.selectableGroup(false)` to prevent text selection. Disabled state styling would respond to a sibling control's enabled state.
- **AppKit / UIKit**: Use `NSTextField` with `editable: false` (macOS) or `UILabel` (iOS). Configure font as system font with medium weight and small size. Apply text color to match design system. For disabled state, observe the associated control's enabled property and update opacity and cursor accordingly.
- **WinUI 3**: Use `TextBlock` control or a custom `Label` control. Set `FontWeight` to `Bold` (medium equivalent), `FontSize` to a small value (e.g., 12pt), and `Foreground` to the design system text color. For disabled state, bind the `Opacity` and `Cursor` properties to the associated input control's `IsEnabled` state via a converter or code-behind logic.

## Design Decisions

- **Flexbox layout**: The component uses flexbox (`flex items-center gap-2`) rather than block or inline layout to support flexible alignment of children and spacing. This accommodates common patterns like icon + text within a label.
- **No explicit padding**: Padding is intentionally omitted at the component level to allow consumers full control over spacing, supporting a wide range of container contexts.
- **Peer-disabled styling**: Rather than accepting a disabled prop, the component responds to a peer element's disabled state via CSS `:peer-disabled` selectors. This avoids double-management of state and keeps the label primitive simple.
- **Consumer responsibility for association**: The `htmlFor` prop is accepted but not enforced, making this a true primitive. Consumers supply the association; the ESLint comment signals this contract.

## Compliance

Not applicable: Label is a display-only primitive with no state management, authentication, or compliance-sensitive behavior.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation from web source |
