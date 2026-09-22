---
id: 91db9191-1ab2-4d09-a9a8-b0dc23669066
title: Points
domain: agenticdevelopertoolkit://recipes/points
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Marked list of long-form claims with optional bold lead-in text per item,
  supporting ordered and unordered presentation.
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

# Points

## Overview

Points is a marked list component designed for presenting a sequence of related claims or arguments, each substantial enough to be a sentence or longer. Unlike short-form lists (Trust) or parallel boxed items (Cards), Points emphasizes the logical flow of a multi-part argument by keeping items inline and marked with a consistent token. Each item has an optional bold lead-in term followed by the detail content; the lead-in provides visual scannability without truncating the full text. The marker itself is configurable via token, and the list supports both unordered and ordered presentation.

## Behavioral Requirements

- **must-render-list-element**: Component MUST render `<ul>` when `ordered` is false (default) or omitted, and MUST render `<ol>` when `ordered` is true.
- **must-render-list-items**: Component MUST render one `<li>` element for each entry in the `entries` array.
- **must-wrap-content-in-span**: Each list item content MUST be wrapped in a single `<span>` element to enforce grid layout structure (two-column: marker and content).
- **must-render-term-as-bold**: When an entry has a `term` property, Component MUST render it as `<b>{term}</b>`.
- **must-render-detail-text**: Component MUST render the `detail` property of each entry as ReactNode content.
- **must-space-term-and-detail**: When both `term` and `detail` are present, Component MUST render a space character between them.
- **must-omit-term-when-undefined**: When an entry has no `term` property, Component MUST NOT render a `<b>` element or space separator.
- **must-apply-base-class**: Component MUST apply the CSS class `lp-points` to the root list element.
- **must-apply-ordered-class**: Component MUST apply the CSS class `lp-points--ordered` to the root element when `ordered` is true.
- **must-not-apply-ordered-class-when-unordered**: Component MUST NOT apply `lp-points--ordered` class when `ordered` is false.
- **must-handle-empty-entries**: Component MUST accept an empty `entries` array and render an empty list element with no items.

## Appearance

- **Marker appearance**: Configurable via CSS token; appearance and size delegated to style layer.
- **Item spacing**: Delegated to CSS; each `<li>` element receives default browser list styling by element type.
- **Typography**: Text within `<span>` inherits from parent container; no inline typography overrides.
- **Grid layout**: Two-column structure (marker column, content column) is enforced by CSS Grid on the root element.
- **Bold text**: Term text rendered with `<b>` element; visual weight delegated to CSS.

## States

| State | Appearance change |
|-------|------------------|
| Default | List items display normally |
| Empty | Renders empty `<ul>` or `<ol>` element (no items rendered) |
| Ordered | Uses `<ol>` instead of `<ul>`; numbers auto-generated from CSS counter |
| Unordered | Uses `<ul>`; marker glyph from CSS token |

## Accessibility

- **Role**: List item containers are semantic `<ul>` or `<ol>` and `<li>` elements, providing correct list semantics to assistive technologies.
- **Ordered list semantics**: When `ordered=true`, the `<ol>` element signals to screen readers that the sequence is ordered and announces "list item N of M" for each item.
- **Unordered list semantics**: When `ordered=false`, the `<ul>` element signals that items are not sequenced.
- **Label requirements**: The component itself has no explicit label; list context is provided by surrounding content or page structure. Each item's `detail` content MUST be meaningful and complete.
- **Text content**: Term and detail text are read in sequence; screen readers announce bold formatting on the term if supported by the platform.
- **No interactive elements**: Points is a static list and does not require focus management, keyboard navigation, or state announcement beyond list semantics.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| points-001 | must-render-list-element, must-apply-base-class | `{entries: [], ordered: false}` | Renders `<ul class="lp-points"></ul>` |
| points-002 | must-render-list-element, must-apply-ordered-class | `{entries: [], ordered: true}` | Renders `<ol class="lp-points lp-points--ordered"></ol>` |
| points-003 | must-render-list-items, must-wrap-content-in-span | `{entries: [{detail: "Content"}]}` | Renders `<li><span>Content</span></li>` |
| points-004 | must-render-term-as-bold, must-space-term-and-detail | `{entries: [{term: "Term", detail: "Description"}]}` | Renders `<li><span><b>Term</b> Description</span></li>` |
| points-005 | must-omit-term-when-undefined | `{entries: [{detail: "Text"}]}` | Renders `<li><span>Text</span></li>` with no `<b>` element |
| points-006 | must-handle-empty-entries | `{entries: []}` | Renders empty list with zero items |
| points-007 | must-apply-ordered-class | `{entries: [{detail: "First"}, {detail: "Second"}], ordered: true}` | Root element has class `lp-points--ordered` |
| points-008 | must-not-apply-ordered-class-when-unordered | `{entries: [{detail: "Item"}], ordered: false}` | Root element does not have class `lp-points--ordered` |

## Edge Cases

- **Empty entries array**: Component renders an empty list container. Expected behavior: list is rendered but contains no items.
- **Null or undefined term property**: When term is undefined, no term text or spacing is rendered. Expected behavior: detail text appears without preceding bold text.
- **ReactNode as term or detail**: Both `term` and `detail` accept ReactNode (can be strings, elements, fragments). Expected behavior: ReactNode is rendered as-is within the wrapper structure.
- **Very long term or detail text**: No truncation occurs in the component; wrapping and overflow are delegated to CSS. Expected behavior: text flows according to CSS rules.
- **Empty detail text**: An entry with empty string or empty ReactNode as detail renders an empty span. Expected behavior: `<li><span></span></li>` for that entry.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| entries | `PointEntry[]` | (required) | Array of list items, each with optional `term` and required `detail` |
| ordered | `boolean` | `false` | When true, renders `<ol>` and applies `lp-points--ordered` class |

## Deep Linking

Not applicable: Points is a presentational list component with no interactive navigation or state that maps to a URL.

## Localization

Not applicable: The component renders the `term` and `detail` content as-is. Localization of list text is the responsibility of the parent component or content source.

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | Not applicable: Points is a static list with no animations or transitions. |
| Increase Contrast | Delegated to CSS; the component does not set any color values. Parent styles MUST ensure sufficient contrast. |
| Differentiate Without Color | Delegated to CSS; the component does not rely on color to distinguish content. The term is marked with bold weight (`<b>` element) and distinct in layout. |

## Feature Flags

Not applicable: Points is a core presentational component with no conditional behavior requiring feature flags.

## Analytics

Not applicable: Points is a static list component without user interaction. No events are generated by the component itself.

## Privacy

Not applicable: Points is a presentational component that does not collect, store, or transmit user data.

## Logging

Not applicable: Points is a presentational component with no state changes, errors, or lifecycle events to log.

## Platform Notes

- **Typescript/Web**: Exported as a React functional component from `packages/web/packages/landing/src/blocks/Points.tsx`. Accepts `entries: PointEntry[]` and `ordered?: boolean`. Each entry is a union type with optional `term` (ReactNode) and required `detail` (ReactNode). The component renders `<ul>` or `<ol>` with class `lp-points` and conditionally `lp-points--ordered`. CSS Grid structure assumes two columns (marker, content) via class-based selectors.
- **SwiftUI**: Use `List` for unordered presentation (bulleted), or `List` with `.listStyle(.numbered)` for ordered. Each item displays a leading marker followed by a two-line vertical stack: the term as a bold Text overlay or separate Text with `.bold()` weight, then the detail text below. No explicit spacing element needed; SwiftUI handles marker rendering. Conditional rendering of term text based on whether it is present.
- **Compose**: Use `LazyColumn` for the list container; swap to `LazyColumn` with numbered indices when ordered. Each item is a `Row` with a `Text` marker (bullet or number from `Char('•')` or the index), then a `Column` for term and detail. Apply `fontWeight(FontWeight.Bold)` to the term Text. The row enforces horizontal spacing and marker alignment.
- **AppKit / UIKit**: Use `UITableView` (iOS) or `NSTableView` (macOS) with a custom cell layout. Each cell contains a `UIStackView` (iOS) or `NSStackView` (macOS) in horizontal orientation: a leading `UILabel` or `NSTextField` for the marker, then a vertical stack for term (bold font weight) and detail text. Conditional layout of term view based on whether it exists. Use `UIListContentConfiguration` (iOS 14+) for convenience.
- **WinUI 3**: Use `ItemsControl` with `ItemsStackPanel` as the ItemsPanel. For ordered lists, replace ItemsControl with `ListView` which provides automatic numbering. Each item template is a `Grid` with two columns (auto, *): first column is a `TextBlock` with the marker (bullet or number), second column is a `StackPanel` (Vertical) containing a bold `TextBlock` for the term (via `FontWeight.Bold`) and a regular `TextBlock` for the detail. Bind the marker to a converter that returns the bullet character or the index. Visibility of the term TextBlock is bound to the presence of a term in the data model.

## Design Decisions

The component wraps all content (term + detail) in a single `<span>` to support a two-column CSS Grid layout where the marker is in the first column and the wrapped content is in the second. This prevents the term text from being laid out as a separate grid item, which would break the intended "marker → lead-in + body" visual structure. The `ordered` prop changes both the HTML element type (ul vs. ol) and the CSS class to signal to styling layers that numbers (from CSS counter) replace the marker glyph.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| Semantic HTML | passed | Accessibility |
| List element types | passed | Accessibility |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation |
