---
id: 811cc18f-e33a-42bb-bd2d-dfc3dc21bc77
title: Lede
domain: agenticdevelopertoolkit://recipes/lede
type: ingredient
version: 1.0.0
status: review
language: en
created: 2026-09-22
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Introductory paragraph component that renders semantic text content under
  headings.
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

# Lede

## Overview

A paragraph component used for introductory or emphasized text following headings, cards, or other content blocks. The lede renders semantic HTML paragraph markup and accepts optional additional styling via className.

## Behavioral Requirements

- **must-render-as-paragraph**: Component MUST render as an HTML `<p>` element.
- **must-render-children**: Component MUST render the provided `children` prop as the paragraph content.
- **must-apply-lede-class**: Component MUST apply the `lp-lede` CSS class to the rendered element.
- **may-accept-additional-class**: Component MAY accept an optional `className` prop that is concatenated with `lp-lede`.
- **must-filter-empty-classes**: Component MUST filter empty class values before joining (remove undefined or falsy className values).

## Appearance

- **Element**: Semantic `<p>` HTML element
- **Base class**: `lp-lede`
- **Additional styling**: Applied via optional `className` prop
- **Visual styling details**: Defined by `lp-lede` CSS rule (not provided in source)

## States

Not applicable: Lede is a static presentational component with no interactive or stateful behavior.

## Accessibility

- **Role**: Paragraph (implicit via `<p>` element)
- **Semantic markup**: The component uses semantic HTML paragraph markup, which provides proper document structure for assistive technologies.
- **Content**: Component content is read as-is by screen readers; no additional ARIA labeling required.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| lede-001 | must-render-as-paragraph | `<Lede>Text</Lede>` | Element is rendered as `<p>` in the DOM |
| lede-002 | must-render-children | `<Lede>Hello World</Lede>` | Text content "Hello World" appears in paragraph |
| lede-003 | must-apply-lede-class | `<Lede>Text</Lede>` | Rendered element includes `lp-lede` class |
| lede-004 | may-accept-additional-class | `<Lede className="extra">Text</Lede>` | Rendered element includes both `lp-lede` and `extra` classes |
| lede-005 | must-filter-empty-classes | `<Lede className={undefined}>Text</Lede>` | Rendered element class is `lp-lede` only (undefined filtered out) |

## Edge Cases

- **Empty children**: If children is empty string or not provided, component renders an empty paragraph.
- **Null or undefined className**: Optional className prop defaults to undefined; component handles this by filtering falsy values.
- **Multiple class names in className**: If className contains multiple space-separated class names, all are appended after `lp-lede`.
- **No className provided**: Component renders with only the `lp-lede` class.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `children` | ReactNode | required | The paragraph content |
| `className` | string | undefined | Optional additional CSS class(es) to apply |

## Deep Linking

Not applicable: Lede is a presentational component that does not handle routing or deep linking.

## Localization

Not applicable: Lede contains no text strings of its own. All text content is provided via children prop and subject to host application localization.

## Accessibility Options

Not applicable: Lede is a static text component that does not animate or respond to motion preferences.

## Feature Flags

Not applicable: Lede is a core presentational component with no feature flag control.

## Analytics

Not applicable: Lede is a presentational component with no interactive behavior to track.

## Privacy

Not applicable: Lede renders provided content without collecting, storing, or transmitting data.

## Logging

Not applicable: Lede is a presentational component with no operational state or error conditions to log.

## Platform Notes

- **React/Web**: Render as `<p>` with `className` attribute. Source file: `packages/web/packages/landing/src/blocks/Lede.tsx`. Implementation filters falsy class values before joining with space.
- **SwiftUI**: Use `Text` view with conditional `.padding()` modifier. Apply font, size, and color via `.font()` and `.foregroundColor()` modifiers to match `lp-lede` styling.
- **Compose**: Use `Text` composable with `Modifier.then()` to apply padding and font styling. Pass text content as `text` parameter. Apply color via `.color()` modifier.
- **AppKit / UIKit**: Use `NSTextField` (macOS) or `UILabel` (iOS) with `attributedStringValue` or `attributedText` to match `lp-lede` styling. Disable editing on UITextField. Configure font, size, and text color properties.
- **WinUI 3**: Use `TextBlock` control with `Text` property for content. Set `FontSize`, `FontFamily`, and `Foreground` (color) properties to match web styling. Apply padding via `Margin` property.

## Design Decisions

Lede is deliberately implemented as a standalone component rather than scoped to appear only under a specific heading component, because the same visual treatment and measure are desired for paragraphs following card grids, chip lists, and other content blocks. This provides flexibility for repeated use across different layout contexts.

## Compliance

Not applicable: Lede is a simple semantic element with no security, authentication, or regulatory compliance concerns.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation |
