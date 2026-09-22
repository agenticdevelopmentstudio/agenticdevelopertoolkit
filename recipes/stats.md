---
id: a63de97e-d75c-4733-a875-bad20e001fcb
title: Stats
domain: agenticdevelopercookbook://ingredients/stats
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: 'A horizontal strip of statistics: number-and-caption pairs scanned in one
  visual sweep.'
platforms:
- typescript
- web
tags:
- statistics
- data-display
- semantic-html
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Stats

## Overview

Stats renders a horizontal strip of statistics pairs—each a number or metric (`term`) paired with its explanation or label (`detail`). The component is designed for quick visual scanning across multiple statistics without interaction. It uses semantic HTML (`dl`, `dt`, `dd`) to encode the relationship between statistic and caption, making it accessible and SEO-friendly. Use it to display side-by-side key metrics, counts, or comparable measurements.

## Behavioral Requirements

- **must-render-entries**: Component MUST render one entry for each item in the `entries` array.
- **must-wrap-each-entry**: Component MUST wrap each entry in its own `div` container (the wrapper div, not the `dl`, is the grid item).
- **must-render-term-and-detail**: Component MUST render the `term` and `detail` of each entry as `dt` and `dd` elements respectively within the entry wrapper.
- **must-preserve-node-content**: Component MUST accept and render `term` and `detail` as `ReactNode`, preserving inline elements, text, and component structures passed by the caller.
- **must-use-semantic-markup**: Component MUST wrap all entries in a `dl` (description list) element to encode the statistical relationship.
- **must-maintain-order**: Component MUST render entries in the order they appear in the `entries` array.

## Appearance

- **Layout**: Three-column grid (declared column count, not auto-derived; see css/blocks.css for grid rules).
- **Container**: `dl` with class `lp-stats`.
- **Grid item**: Each entry wrapped in a `div` (class applied to wrapper, not the `dl`).
- **Term (`dt`)**: No specific padding, font, or color defined in component; defer to CSS rules via `lp-stats` class.
- **Detail (`dd`)**: No specific padding, font, or color defined in component; defer to CSS rules via `lp-stats` class.

## States

Not applicable: Stats is a static, non-interactive component. It has no pressed, disabled, focused, loading, or hover states.

## Accessibility

- **Semantic structure**: The `dl`/`dt`/`dd` markup encodes a description-list relationship, conveying that each `dd` (detail) is associated with its preceding `dt` (term). Screen readers announce this relationship, making the statistics intelligible without visual cues.
- **Label requirement**: No separate `aria-label` is needed because the `dt` (term) serves as the label for each statistic. The `dd` (detail) provides additional context.
- **Minimum tap/click target**: Inline text links within `term` or `detail` are exempt from touch-target minimums. If interactive elements (buttons, links) are added to the term or detail content by the caller, those elements SHOULD each have a minimum touch target of 44×44pt (per agenticdevelopercookbook://guidelines/implementing/ui/touch-click-targets).

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|-------|----------------------------------------|-------------------|-------------|
| stats-001 | must-render-entries | `entries: [{term: "10", detail: "Users"}]` | Component renders one entry wrapper `div` |
| stats-002 | must-render-entries | `entries: [{...}, {...}, {...}]` (3 items) | Component renders three entry wrapper divs |
| stats-003 | must-wrap-each-entry | Any valid entries array | Each entry is wrapped in a `div` child of the `dl` |
| stats-004 | must-render-term-and-detail | `entries: [{term: "42", detail: "Days"}]` | Rendered as `<dt>42</dt><dd>Days</dd>` within the entry div |
| stats-005 | must-preserve-node-content | `entries: [{term: <strong>99</strong>, detail: "Active"}]` | Strong element is preserved and rendered within the `dt` |
| stats-006 | must-preserve-node-content | `entries: [{term: "10", detail: <em>Total Users</em>}]` | Em element is preserved and rendered within the `dd` |
| stats-007 | must-use-semantic-markup | Any valid entries array | Top-level element is `dl` with class `lp-stats` |
| stats-008 | must-maintain-order | `entries: [{term: "A", detail: "First"}, {term: "B", detail: "Second"}]` | First entry renders before second entry in DOM order |

## Edge Cases

- **Empty entries array**: If `entries` is an empty array, the component MUST render an empty `dl` with class `lp-stats` and no child divs.
- **Single entry**: If `entries` contains only one item, the component MUST render that entry in a single wrapper div. The three-column grid layout may render this at full or partial width depending on CSS rules.
- **Null or undefined ReactNode content**: If `term` or `detail` is `null` or `undefined`, the component MUST render the corresponding `dt` or `dd` as an empty element. This is allowed and does not constitute an error.
- **Large content in term or detail**: If the `term` or `detail` contains very long text or large inline components, layout may wrap or overflow according to CSS rules; the component itself places no constraint on content size.
- **React Fragments or multiple children**: If the caller passes a React Fragment or array as the `term` or `detail`, the Fragment/array is rendered as-is within the `dt` or `dd`. React handles this transparently.

## Configuration

| Option | Type | Default | Required | Description |
|--------|------|---------|----------|-------------|
| `entries` | `StatEntry[]` | — | Yes | Array of `{term: ReactNode, detail: ReactNode}` objects to display. |

## Deep Linking

Not applicable: Stats is a display-only component without its own route or deep-link semantics. Any deep linking is handled by the consuming page or application.

## Localization

Not applicable: Stats accepts `term` and `detail` as `ReactNode`, giving the caller full control over localized content. The component renders whatever is passed; localization is the responsibility of the data source.

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | Not applicable: Stats is static and contains no animations. |
| Increase Contrast | Not applicable: The component has no built-in color values; contrast is governed by CSS rules applied via the `lp-stats` class and the caller's styling. |
| Differentiate Without Color | Not applicable: Stats uses semantic HTML and does not rely on color alone to convey meaning. The `dt`/`dd` structure encodes the relationship independent of color. |

## Feature Flags

Not applicable: Stats contains no conditional features or toggles. All functionality is always active.

## Analytics

Not applicable: Stats is a static display component and does not emit user-interaction events. Any analytics tracking is the responsibility of the consumer context or parent component.

## Privacy

Not applicable: Stats does not collect, store, or transmit user data. It simply renders content passed to it.

## Logging

Not applicable: Stats does not emit logs. Errors in rendering (e.g., invalid React children) are reported by React's own dev-mode warnings, not by the component.

## Platform Notes

- **TypeScript/Web (React)**: See `packages/web/packages/landing/src/blocks/Stats.tsx`. The component returns a `dl` with class `lp-stats` containing entry wrapper `div`s, each with a `dt` (term) and `dd` (detail). Styling is defined in `css/blocks.css`; the grid is explicitly three columns (see comments in the CSS file for why column count is declared rather than auto-derived).
- **SwiftUI**: On Apple platforms with SwiftUI, use `HStack` to arrange statistics horizontally. Each statistic pair should be a `VStack` with `Text` for the term (value) and a smaller secondary `Text` for the detail (label). Use `frame(maxWidth: .infinity)` on each statistic to distribute space evenly across three columns. No semantic equivalent to `dl`/`dt`/`dd` exists in SwiftUI; label each statistic via proximity and visual hierarchy.
- **Compose**: On Android with Jetpack Compose, use `Row` for the horizontal layout. Each statistic is a `Column` containing a `Text` for the term (value, larger) and a `Text` for the detail (label, smaller). Use `Modifier.weight(1f)` on each column to distribute space equally. Compose has no semantic description-list equivalent; the visual arrangement and size difference between term and detail conveys the relationship.
- **AppKit / UIKit**: On macOS and iOS using traditional UIKit, use `UIStackView` with `axis = .horizontal` and `distribution = .fillEqually`. Each statistic is a `UIStackView` with `axis = .vertical` containing a `UILabel` for the term (larger font, prominent) and a `UILabel` for the detail (smaller font, secondary). For accessibility, wrap each statistic pair in a `UIAccessibilityElement` and set an appropriate `accessibilityLabel` combining term and detail (e.g., "10 users").
- **WinUI 3**: On Windows with WinUI 3, use `StackPanel` with `Orientation = Orientation.Horizontal` to layout statistics side-by-side. Each statistic is a `StackPanel` with `Orientation = Orientation.Vertical` containing a `TextBlock` for the term (larger FontSize, FontWeight.Bold) and a `TextBlock` for the detail (smaller FontSize, Opacity=0.7). Set `HorizontalAlignment = HorizontalAlignment.Stretch` and `Width = "Auto"` on each statistic column to distribute space. Use `AutomationProperties.Name` on the parent `StackPanel` to announce the entire statistic pair to assistive technologies.

## Design Decisions

- **Wrapper div per entry**: The component wraps each entry in its own `div` rather than placing `dt` and `dd` directly as children of the `dl`. This allows the CSS grid layout to treat each entry pair as a single grid item, enabling the three-column arrangement. The `dl` itself is not the grid container; the wrapper `div`s are the grid items (see css/blocks.css comment).
- **ReactNode for term and detail**: Both `term` and `detail` accept `ReactNode` rather than restricting to strings. This gives the caller maximum flexibility to compose rich content (formatted numbers, icons, inline components) without the component prescribing a structure.
- **No default styling within component**: All visual properties (padding, font, color, layout) are delegated to CSS rules applied via the `lp-stats` class. The component focuses on semantic structure; presentation is the responsibility of the CSS file and the calling context.

## Compliance

Not applicable: This ingredient implements a simple semantic HTML pattern and does not introduce security, data handling, or regulatory compliance concerns.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation from web source (Stats.tsx) |
