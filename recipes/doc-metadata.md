---
id: 26c4eb3c-9af9-4092-9546-bb5c5532b59c
title: DocMetadata
domain: agenticdevelopercookbook://ingredients/doc-metadata
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Right-aligned definition list for rendering document frontmatter metadata
  fields.
platforms:
- typescript
- web
tags:
- metadata
- definition-list
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# DocMetadata

## Overview

DocMetadata is a stateless display component that renders document frontmatter fields in a right-aligned definition list. The component accepts an array of label-value pairs and renders them as a semantic `<dl>` element. Array values wrap as a flex group; scalar values render inline. The component renders nothing when the fields array is empty.

## Behavioral Requirements

- **must-render-dl-element**: Component MUST render as an HTML `<dl>` (definition list) element.
- **must-render-label-value-pairs**: Component MUST render each field as a label (`<dt>`) paired with its value (`<dd>`).
- **must-render-nothing-when-empty**: Component MUST return `null` when the `fields` prop is an empty array.
- **must-handle-array-values**: Component MUST detect when a field value is an array and render array items wrapped in a `<span>` element with flex layout properties.
- **must-render-scalar-values-directly**: Component MUST render non-array field values as-is without additional wrapping.
- **must-apply-classname-prop**: Component MUST merge the optional `className` prop with its default Tailwind classes using a utility function.
- **must-spread-rest-attributes**: Component MUST accept and apply additional HTML `<dl>` attributes via the `...rest` spread parameter.

## Appearance

- **Corner radius**: 0 (none; element is a list structure)
- **Padding**: 0 × 0 (no internal padding; gap-0.5 controls spacing between rows)
- **Font**: monospace font family, 11px size
- **Background**: transparent (inherited from parent)
- **Foreground/Text**: Labels use `--color-text-dim` CSS variable; values use `--color-text-secondary` CSS variable
- **Spacing**: 0.5 (4px) vertical gap between rows; 2 (8px) horizontal gap between label and value
- **Layout**: Flex column with right-aligned items and end justification for wrapping array values
- **Margin**: 6px (mb-6) below the component

## States

| State | Appearance change |
|-------|------------------|
| Default (fields present) | Renders `<dl>` with all fields visible |
| Empty (fields array is empty) | Renders nothing (returns `null`) |

## Accessibility

The component uses semantic HTML (`<dl>`, `<dt>`, `<dd>` elements) to represent label-value pairs. The definition list structure correctly expresses the relationship between labels and values for assistive technologies. Font size of 11px is below recommended minimums for body text; this is acceptable as the component displays metadata annotations rather than primary content. The component is not interactive and requires no additional ARIA attributes.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| doc-metadata-001 | must-render-nothing-when-empty | `{ fields: [] }` | Component returns `null` and renders no DOM element |
| doc-metadata-002 | must-render-dl-element | `{ fields: [{ label: "Status", value: "active" }] }` | Renders `<dl>` element in the DOM |
| doc-metadata-003 | must-render-label-value-pairs | `{ fields: [{ label: "Version", value: "1.0.0" }] }` | Renders `<dt>` containing "Version" and `<dd>` containing "1.0.0" |
| doc-metadata-004 | must-handle-array-values | `{ fields: [{ label: "Tags", value: ["ui", "form"] }] }` | Renders `<span>` with flex layout containing two items right-aligned with 3 (12px) horizontal gap |
| doc-metadata-005 | must-render-scalar-values-directly | `{ fields: [{ label: "Author", value: "Jane Doe" }] }` | Value "Jane Doe" renders directly in `<dd>` without additional wrapper |
| doc-metadata-006 | must-apply-classname-prop | `{ fields: [...], className: "custom-class" }` | `<dl>` element includes both default Tailwind classes and "custom-class" |
| doc-metadata-007 | must-spread-rest-attributes | `{ fields: [...], data-testid: "metadata", id: "doc-meta" }` | `<dl>` element has `data-testid="metadata"` and `id="doc-meta"` attributes |

## Edge Cases

- **Empty fields array**: Component returns `null`; no DOM render occurs.
- **Null or undefined in fields array**: The component does not guard against malformed field objects. A field with `value: null` or `value: undefined` renders as an empty `<dd>`.
- **ReactNode values in arrays**: Array items are rendered as React fragments; any valid ReactNode (strings, components, elements) render correctly.
- **Special characters and markup in values**: Scalar values render as text; markup is escaped. Array item values depend on ReactNode content; if a value is a React element, it renders as intended by the host.
- **Very long labels or values**: The component applies no truncation or text overflow handling; content wraps or overflows according to the browser's default behavior and the parent container's width.
- **Dynamic field changes**: The component is stateless; re-rendering with new fields updates the DOM.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `fields` | `DocMetadataField[]` | (required) | Array of label-value pairs to display. Component renders nothing when empty. |
| `className` | `string` | `undefined` | Optional CSS class name(s) to merge with default Tailwind classes. |
| (HTML attributes) | `HTMLAttributes<HTMLDListElement>` | — | All standard `<dl>` attributes (e.g., `id`, `data-*`, `aria-*`) are accepted via rest spread. |

## Deep Linking

Not applicable: DocMetadata is a non-interactive display component with no deep-linking capability.

## Localization

Not applicable: The component does not render any text strings. All labels and values are provided by the host application, which is responsible for localization.

## Accessibility Options

Not applicable: The component is not interactive and does not respond to accessibility display options such as motion reduction or contrast enhancement. It delegates all text rendering to its container and parent theme.

## Feature Flags

Not applicable: The component contains no conditional rendering or feature-gated behavior.

## Analytics

Not applicable: The component is stateless and non-interactive; it generates no events to track.

## Privacy

Not applicable: The component does not collect, store, or transmit any data. The host application is responsible for managing the sensitivity of data passed as field values.

## Logging

Not applicable: The component performs no logging or error reporting.

## Platform Notes

- **SwiftUI**: Start with a `VStack` containing `HStack` rows for each field pair. Each row pairs a `Text` label (styled with `.secondary` foreground) with a `Text` value. For array values, nest the value text items in an `HStack` with right alignment. Use `.font(.system(.caption, design: .monospaced))` for the 11px monospace effect and `.lineLimit(1)` or full wrapping based on layout needs.

- **Compose**: Use a `Column` with right alignment (`Modifier.align(Alignment.End)`). For each field, create a `Row` containing two `Text` composables—the label styled with a dim color token and the value with secondary color. For array values, place the items in a wrapping `Row` with `Modifier.horizontalScroll()` or use `FlowRow` if available, right-aligned. Apply `fontFamily = FontFamily.Monospace` and `fontSize = 11.sp`.

- **React/Web**: Uses semantic `<dl>` and `<dd>` elements with Tailwind utility classes. The layout is a flex column with right alignment and 4px row gaps. Leverages CSS custom properties (`--color-text-dim`, `--color-text-secondary`) for colors, allowing theme injection at the document root. Array values wrap in a `<span>` with `flex flex-wrap justify-end gap-x-3` for right-aligned flow layout.

- **AppKit / UIKit**: Use `NSStackView` (macOS) or `UIStackView` (iOS) with vertical distribution and right alignment. For each field, create a horizontal stack containing a label `NSTextField` or `UILabel` in a dim text color and a value field styled as secondary text. Monospace styling uses `NSFont(name: "Menlo", size: 11)` on macOS or `UIFont(name: "Menlo", size: 11)` on iOS. Array values nest in a separate horizontal stack with right alignment and adequate spacing.

- **WinUI 3**: Use a `StackPanel` with `Orientation="Vertical"` and `HorizontalAlignment="Right"`. Each field row is an `Inline` or custom control pair: label as a `TextBlock` in a subtle foreground brush, value as a `TextBlock` in secondary brush. Apply `FontFamily="Courier New"` and `FontSize="11"` for monospace. For array values, nest the items in a `WrapGrid` with right alignment or use a horizontal `StackPanel` with wrapping behavior via a parent `Grid` or custom layout.

## Design Decisions

The component is intentionally minimal and stateless: it accepts pre-formatted data and renders it with no transformation. Labels and values come from the host; the component's sole job is layout and styling. The use of a `<dl>` element reflects semantic HTML; definition lists are the correct structure for label-value metadata. Right alignment is intentional—it positions the metadata visually as supplementary annotation, not primary content. Monospace 11px font is a conventional pattern for document metadata, distinguishing frontmatter from prose body text. Array value wrapping allows the component to handle multi-valued fields (tags, references, platforms) without forcing horizontal scroll or truncation.

## Compliance

Not applicable: The component has no security, authentication, data-persistence, or networking concerns. Its semantic HTML and CSS use align with WCAG guidelines for structure and color contrast.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation |
