---
id: 31198bb7-2270-449e-94c1-026b68d2bc81
title: Head
domain: agenticdevelopertoolkit://recipes/head
type: ingredient
version: 1.0.0
status: review
language: en
created: 2026-09-22
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Section heading block with optional eyebrow label, title, and content area.
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

# Head

## Overview

A container for a section's heading that renders an optional eyebrow (contextual label), optional title as an h2, and child content. Used to introduce sections within a layout, typically followed by other content blocks like Lede or body content.

## Behavioral Requirements

- **must-render-container**: Component MUST render a `div` element with class `lp-head`.
- **must-conditionally-render-eyebrow**: Component MUST render a `span` element with class `lp-eyebrow` and the eyebrow content only when the `eyebrow` prop is defined (not `undefined`).
- **must-conditionally-render-title**: Component MUST render an `h2` element containing the title content only when the `title` prop is defined (not `undefined`).
- **must-render-children**: Component MUST render the `children` prop content within the container when `children` is provided.
- **must-preserve-order**: Component MUST render child elements in the order: eyebrow (if present), title (if present), children (if present).

## Appearance

Styling is applied via external CSS classes (`lp-head`, `lp-eyebrow`). The source does not define inline styles, colors, typography, spacing, or dimensions. Refer to the CSS module for the landing page block styles.

## States

Not applicable: This is a static container component with no user interaction or interactive states.

## Accessibility

- The title is rendered as an `h2` element, providing semantic structure for document outline and screen reader navigation.
- The eyebrow is rendered as a `span` without semantic role; a developer using this component SHOULD provide semantic context through parent structure or ARIA attributes if the eyebrow conveys important information.
- Child content inherits accessibility characteristics from its own implementation; the component does not alter or wrap accessibility properties of children.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| head-001 | must-render-container | No props | `<div class="lp-head"></div>` rendered |
| head-002 | must-conditionally-render-eyebrow, must-preserve-order | `eyebrow="Section"` | `<div class="lp-head"><span class="lp-eyebrow">Section</span></div>` |
| head-003 | must-conditionally-render-title, must-preserve-order | `title="Heading"` | `<div class="lp-head"><h2>Heading</h2></div>` |
| head-004 | must-render-children, must-preserve-order | `children={<p>Content</p>}` | `<div class="lp-head"><p>Content</p></div>` |
| head-005 | must-conditionally-render-eyebrow, must-conditionally-render-title, must-render-children, must-preserve-order | `eyebrow="Nav"`, `title="Title"`, `children={<p>Body</p>}` | `<div class="lp-head"><span class="lp-eyebrow">Nav</span><h2>Title</h2><p>Body</p></div>` |
| head-006 | must-conditionally-render-eyebrow | `eyebrow={undefined}` | Eyebrow span not rendered |
| head-007 | must-conditionally-render-title | `title={undefined}` | h2 element not rendered |
| head-008 | must-render-children | `children={undefined}` | No children rendered |

## Edge Cases

- **Undefined props**: When `eyebrow`, `title`, or `children` are `undefined`, the component skips rendering the corresponding element. The container div is always rendered.
- **Null vs. undefined**: The component uses `!== undefined` checks; passing `null` for any prop will cause it to render (e.g., `<span className="lp-eyebrow">{null}</span>`). This may produce an empty element.
- **Empty string or falsy values**: An empty string `""` satisfies the `!== undefined` check and will be rendered, resulting in empty `span` or `h2` elements or no visible content for children.
- **ReactNode types**: The props accept `ReactNode`, allowing strings, numbers, components, fragments, or arrays. All valid ReactNode types are rendered as-is without additional wrapping.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `eyebrow` | `ReactNode` | `undefined` | Optional eyebrow label rendered as a span with class `lp-eyebrow`. |
| `title` | `ReactNode` | `undefined` | Optional title rendered as an h2 element. |
| `children` | `ReactNode` | `undefined` | Optional content rendered within the container. |

## Deep Linking

Not applicable: This is a layout component, not a screen or navigable entity.

## Localization

Not applicable: The component does not define any static text; all content is provided via props.

## Accessibility Options

Not applicable: This component does not respond to platform-level accessibility display options like Reduce Motion or Increase Contrast; styling is applied via external CSS.

## Feature Flags

Not applicable: This component has no feature flag controls.

## Analytics

Not applicable: This component does not emit analytics events.

## Privacy

Not applicable: This component does not collect, store, or transmit data.

## Logging

Not applicable: This component does not emit diagnostic logs.

## Platform Notes

- **TypeScript/Web**: Defined in `packages/web/packages/landing/src/blocks/Head.tsx`. The component accepts `ReactNode` props and conditionally renders semantic HTML (`h2` for title, `span` for eyebrow) using JSX conditional rendering (`&&` operator). Styling is delegated to external CSS classes.
- **SwiftUI**: Implement as a `VStack` containing optional views for eyebrow (a small Text, perhaps in a secondary color or font), a title (larger Text or use `.font(.headline)`), and a content view. Use conditional rendering with `if` statements and `@ViewBuilder` to match the conditional behavior.
- **Compose**: Implement as a `Column` with optional composables for eyebrow (small text, secondary color), title (larger text or `MaterialTheme.typography.headlineSmall`), and content. Use conditional composability to render only defined props.
- **AppKit / UIKit**: Implement as a `UIStackView` (vertical) containing optional UILabel subviews for eyebrow and title, plus a content view. Conditionally add subviews based on prop presence. On iOS, ensure the title is appropriately sized; on macOS, match the aesthetic to the containing application.
- **WinUI 3**: Implement as a `StackPanel` with `Orientation="Vertical"` containing optional TextBlock elements for eyebrow (smaller font, secondary foreground) and title (larger font, `FontWeight.Medium` or `Bold`), plus a content presenter. Use `Visibility` property to conditionally show/hide the eyebrow and title TextBlocks based on whether they are provided.

## Design Decisions

The component uses `!== undefined` to check prop presence rather than truthiness. This allows falsy values like empty strings, `0`, or `false` to render as content, matching React's treatment of these as valid children. This is intentional and preserves the distinction between "prop not provided" (undefined) and "prop provided with a falsy value" (render it).

The eyebrow is rendered as a generic `span` without semantic role, making it suitable for visual labels that don't require screen reader announcement. If semantic importance is needed, the developer must wrap the component or provide ARIA attributes.

## Compliance

Not applicable: This component is a presentational container with no compliance checks.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation from source |
