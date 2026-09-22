---
id: 79093eb5-83e8-46d8-9efe-3cc6ff88d8db
title: Trust
domain: agenticdevelopercookbook://ingredients/trust
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Semantic list of trust claims or assertions visitors should verify before
  engaging with features.
platforms:
- typescript
- web
tags:
- trust
- list
- semantic-html
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Trust

## Overview

The Trust component renders a semantic unordered list of trust claims—things a visitor wants settled before reading product capabilities. It accepts an array of React nodes and renders each as a list item, deliberately unstyled to avoid elevating claims to the visual prominence of product features.

## Behavioral Requirements

- **must-render-items-as-list**: Component MUST render each item in the `items` array as a distinct `<li>` element within a `<ul>`.
- **must-use-ul-semantic**: Component MUST render the container as a semantic unordered list (`<ul>`) element.
- **must-accept-react-nodes**: Component MUST accept `items` as a `ReactNode[]` prop, supporting text, React elements, fragments, and null values.
- **must-apply-container-class**: Component MUST apply the className `lp-trust` to the rendered `<ul>` element.

## Appearance

- **Container**: Semantic `<ul>` element with className `lp-trust`; no inline styles defined.
- **Items**: `<li>` elements containing provided React nodes; no item-level styling.
- **Layout**: List items flow vertically in document order; styling is controlled by the `.lp-trust` CSS class and item-level styles.

## States

Not applicable: The Trust component is a static container that does not respond to user input or exhibit interactive state changes.

## Accessibility

- **Role**: Semantic `<ul>` and `<li>` establish list structure; screen readers announce the list and each item's nesting level.
- **Label requirements**: Individual items should provide meaningful content; if items contain interactive controls, they MUST include accessible labels or descriptions.
- **Keyboard navigation**: No interactive behavior in the container; keyboard access is inherited from item content.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| trust-001 | must-render-items-as-list | `items={[<span>Claim A</span>, <span>Claim B</span>]}` | Renders `<ul class="lp-trust"><li><span>Claim A</span></li><li><span>Claim B</span></li></ul>` |
| trust-002 | must-use-ul-semantic | Any valid items | Rendered output contains exactly one `<ul>` as the root element |
| trust-003 | must-apply-container-class | Any valid items | Rendered `<ul>` includes `className="lp-trust"` |
| trust-004 | must-accept-react-nodes | `items={["Text", <Badge />, <span>Mixed</span>, null]}` | Renders list item for each non-null ReactNode in order |
| trust-005 | must-render-items-as-list | `items={[]}` | Renders an empty `<ul class="lp-trust"></ul>` |

## Edge Cases

- **Empty array**: Component renders an empty `<ul>` with no error or fallback message.
- **Single item**: Component renders a `<ul>` containing one `<li>` child.
- **Null or undefined items**: Component skips null/undefined values in the array and renders only non-null ReactNodes.
- **Deeply nested React elements**: Component renders the full tree of each item without flattening or transforming structure.
- **Dynamic items**: Component re-renders when items array or item content changes; items are rendered in array order, not reordered by component logic.

## Configuration

Not applicable: The Trust component accepts only the `items` prop and provides no configuration options.

## Deep Linking

Not applicable: The Trust component is a presentational container with no navigation or routing behavior.

## Localization

Not applicable: The Trust component does not define, render, or own any translatable strings. Item content is the responsibility of consuming code.

## Accessibility Options

- **Reduce Motion**: Not applicable; component does not animate.
- **Increase Contrast**: Not applicable; component does not define foreground or background colors.
- **Differentiate Without Color**: Not applicable; component relies on semantic structure, not color-based distinctions.

## Feature Flags

Not applicable: The Trust component has no feature flag requirements or runtime configuration switches.

## Analytics

Not applicable: The Trust component does not emit user interaction events or track engagement.

## Privacy

Not applicable: The Trust component does not collect, store, or transmit personal data.

## Logging

Not applicable: The Trust component does not emit diagnostic or debug log messages.

## Platform Notes

- **TypeScript/Web**: Render as `<ul className="lp-trust">` wrapping `<li>` children. See `packages/web/packages/landing/src/blocks/Trust.tsx`. Items are passed as `ReactNode[]` and rendered in order via `map()`.
- **SwiftUI**: Compose using a `List` view with `listStyle(.plain)` to render a semantic unordered list. Map each item to a `Text`, `VStack`, or custom view. Styling is delegated to the consuming view's style modifiers; the component provides no wrapper styling.
- **Compose**: Use `LazyColumn` or `Column` with `verticalScroll(rememberScrollState())` to provide semantic list semantics. Map each item to a composable within the column. Styling is the responsibility of item-level composables and the surrounding context; the container applies no default styling.
- **AppKit / UIKit**: On macOS, use `NSOutlineView` or `NSTableView` with a single column to render a semantic list; on iOS, use `UITableView` with `UITableViewCell` or a modern `UICollectionView` with a list layout. Delegate item rendering to each cell's configuration. No cell-level styling is applied by the component; styling is the responsibility of the cell renderer.
- **WinUI 3**: Use `ItemsRepeater` within a `ScrollViewer`, binding to the items collection, or use `ListView` with `SelectionMode="None"`. Define a `DataTemplate` to render each item. Apply no item-level styling; styling is delegated to the template and the app's resource dictionary.

## Design Decisions

The Trust component is intentionally minimal and unstyled. It provides only semantic structure, not visual treatment. The name and source comment emphasize that these are trust claims requiring visitor verification—not product features—and therefore should not be visually elevated to the same prominence as a capabilities list. Implementations SHOULD apply styling that reflects this distinction in their design systems.

## Compliance

Not applicable: The component's structural simplicity and lack of interactive, data-handling, or state-management behavior place it outside the scope of most compliance frameworks. Semantic HTML (`<ul>` and `<li>`) satisfies baseline accessibility requirements.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | (recipe-author) | Initial creation |
