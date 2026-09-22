---
id: 3785363d-118e-4d7e-98e6-afaca8bf0838
title: List
domain: agenticdevelopercookbook://recipes/ui/list
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A bordered container component with row dividers for displaying flat collections
  of items.
platforms:
- typescript
- web
tags:
- ui
- list
- collection
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# List

## Overview

List is a semantic container component for displaying flat collections of items (e.g., team members, search results). It provides consistent visual treatment with borders and row dividers. The component comprises two parts: `List` (the container) and `ListItem` (individual rows). Both are simple presentational wrappers that forward all React props to their underlying HTML elements.

## Behavioral Requirements

- **must-render-semantic-list**: The List component MUST render a `<ul>` element.
- **must-render-semantic-item**: The ListItem component MUST render an `<li>` element.
- **must-accept-classname**: Both List and ListItem MUST accept a `className` prop and merge it with their base styles using the `cn()` utility.
- **must-forward-props**: Both List and ListItem MUST forward all remaining React props (`...props`) to their underlying HTML element.
- **must-set-data-slot**: The List component MUST set `data-slot="list"` on the rendered `<ul>`. The ListItem component MUST set `data-slot="list-item"` on the rendered `<li>`.

## Appearance

### List Container

- **Border**: 1px solid border on all sides, using `border-apt-border` color token
- **Border Radius**: Rounded corners via `rounded-lg`
- **Layout**: Flex column layout with `flex flex-col`
- **Row Dividers**: Horizontal dividers between rows via `divide-y` with `divide-apt-border` color
- **Overflow**: Content overflow hidden via `overflow-hidden`
- **Background**: Inherits from parent (not explicitly set)

### ListItem

- **Minimum Height**: 36px (Tailwind `min-h-9`)
- **Layout**: Flex row layout (`flex items-center`)
- **Horizontal Padding**: 12px on left and right (`px-3`)
- **Vertical Padding**: 6px on top and bottom (`py-1.5`)
- **Item Gap**: 12px spacing between flex children (`gap-3`)

## States

Not applicable: List and ListItem are static presentational components with no interactive states. State management is the responsibility of parent components.

## Accessibility

Not applicable: List and ListItem render semantic HTML (`<ul>` and `<li>`) without additional ARIA attributes or accessible labels. Accessibility concerns (such as list semantics, item announcements, and screen reader handling) are inherited from the HTML elements. Parent components are responsible for adding labels or descriptions as needed for the content displayed within the list items.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| list-001 | must-render-semantic-list | Render `<List />` | Output contains `<ul data-slot="list">` |
| list-002 | must-render-semantic-item | Render `<ListItem />` | Output contains `<li data-slot="list-item">` |
| list-003 | must-accept-classname | Render `<List className="custom-class" />` | Output element has both base classes and `custom-class` applied |
| list-004 | must-accept-classname | Render `<ListItem className="custom-item" />` | Output element has both base classes and `custom-item` applied |
| list-005 | must-forward-props | Render `<List id="test-list" role="region" />` | Output `<ul>` contains `id="test-list"` and `role="region"` attributes |
| list-006 | must-forward-props | Render `<ListItem id="item-1" data-test="value" />` | Output `<li>` contains `id="item-1"` and `data-test="value"` attributes |
| list-007 | must-set-data-slot | Render `<List />` with child `<ListItem />` | Both elements have correct `data-slot` values |

## Edge Cases

- **Empty list**: Rendering `<List />` with no children produces an empty bordered container.
- **Single item**: Rendering a List with one ListItem produces the container with no visible row dividers (dividers appear between rows, not above or below).
- **Nested flex content**: ListItem uses flex layout; when child content includes flex or grid elements, they inherit the flex context.
- **className collision**: If a `className` prop contains conflicting Tailwind classes (e.g., `p-4` conflicting with `px-3 py-1.5`), standard CSS cascade applies; specificity and source order determine which wins. The `cn()` utility does not deduplicate conflicting classes.

## Configuration

Not applicable: List and ListItem have no configuration options. All appearance and behavior is determined by Tailwind classes and React props.

## Deep Linking

Not applicable: List and ListItem are UI components, not views or pages. Deep linking is not applicable.

## Localization

Not applicable: List and ListItem render no text content and require no localization.

## Accessibility Options

Not applicable: List and ListItem do not implement accessibility display options (such as Reduce Motion, Increase Contrast, or Differentiate Without Color). These concerns are the responsibility of the consuming component.

## Feature Flags

Not applicable: List and ListItem have no feature flags.

## Analytics

Not applicable: List and ListItem do not emit analytics events.

## Privacy

Not applicable: List and ListItem do not collect, store, or transmit any data.

## Logging

Not applicable: List and ListItem do not emit any logs.

## Platform Notes

- **SwiftUI**: SwiftUI's `List` view with `.divider()` modifier provides an equivalent component, rendering rows with dividers and border. Use `List { ForEach(...) { item in ... } }` to compose rows dynamically.
- **Compose**: Android Compose's `LazyColumn` with `Divider()` composables between items provides equivalent row divider behavior. Combine with `Card` or custom styling to add the border treatment.
- **React/Web**: The source implementation is in `packages/web/packages/ui/src/components/list.tsx`. The List component renders a styled `<ul>` with Tailwind classes (`flex flex-col divide-y divide-apt-border overflow-hidden rounded-lg border border-apt-border`). The ListItem component renders a styled `<li>` with Tailwind classes (`flex min-h-9 items-center gap-3 px-3 py-1.5`). Both use the `cn()` utility from `lib/utils` to merge classnames.
- **AppKit/UIKit**: NSTableView (macOS) or UITableView (iOS) with `separatorStyle = .singleLine` provides row dividers. A custom cell layout with flex-equivalent auto-layout constraints replicates the padding and gap behavior.
- **WinUI 3**: `ItemsRepeater` with a Separator element between items, or `ListView` with `SingleSelectionMode`, provides row dividers. Use `Grid` for cell layout with column spacing equivalent to `gap-3`.

## Design Decisions

List and ListItem are minimal presentational components designed for simplicity and reusability. They do not enforce content structure or manage state; they forward all props to underlying HTML elements, allowing flexible composition and styling. The `data-slot` attributes enable targeted CSS and testing selectors without requiring a class-based API.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| [semantic-html](agenticdevelopercookbook://compliance/html#semantic-html) | passed | HTML |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude | Initial creation |
