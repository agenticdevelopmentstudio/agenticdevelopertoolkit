---
id: 5182f5ec-186b-4605-8c40-ea70a49262c2
title: Checklist
domain: agenticdevelopercookbook://ingredients/checklist
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Dense columnar list of checked items, grouped under quiet headings, designed
  for dense scanning.
platforms:
- typescript
- web
tags:
- list
- informational
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Checklist

## Overview

Checklist renders one or more columns of marked items, each grouped under a heading. The component is designed for dense, scannable layouts where a user needs to see what features, features-to-come, or status items are present. Each item is independently marked with a checked state or a "coming soon" state, and empty item groups render no list element at all (to avoid invisible layout artifacts).

## Behavioral Requirements

- **must-accept-groups**: Component MUST accept an array of `ChecklistGroup` objects, each containing a `heading` (ReactNode) and `items` array of `ChecklistItem` objects.
- **must-render-heading**: Component MUST render the heading for each group as an `<h3>` element.
- **must-render-items**: Component MUST render each item in a group as an `<li>` element, wrapping the item's `text` (ReactNode) in a `<span>`.
- **must-not-render-empty-list**: Component MUST NOT render a `<ul>` element for groups with zero items; the group div and heading still render.
- **must-support-soon-state**: Component MUST support an optional `soon` boolean property on items; when `soon` is true, the item's `<li>` element MUST receive the `lp-checklist__item--soon` CSS class.
- **must-apply-lp-checklist-class**: Component MUST apply the `lp-checklist` CSS class to the root container div.

## Appearance

- **Container**: `<div class="lp-checklist">` with no inline styles; styling is via CSS class.
- **Group container**: `<div>` wrapping each group heading and list, with no class or inline styles.
- **Heading**: `<h3>` with no class or inline styles.
- **List**: `<ul>` with no class or inline styles, rendered only when items array is non-empty.
- **List item**: `<li>` with optional `lp-checklist__item--soon` class (applied when `item.soon` is truthy).
- **Item text**: `<span>` containing the item's `text` ReactNode, with no class or inline styles.

## States

Not applicable: Checklist is a presentational component that renders items in a static state. State transitions are managed by the parent component updating the `groups` prop.

## Accessibility

- Role: The component uses semantic HTML (`<h3>`, `<ul>`, `<li>`, `<span>`) to convey structure; no additional ARIA roles are applied.
- Heading hierarchy: Headings are rendered as `<h3>`, which implies a three-level heading structure in the document hierarchy; the containing page MUST ensure the context is appropriate.
- List semantics: Items are wrapped in `<ul>` and `<li>` elements to signal a list to assistive technologies.
- Labels: Item text is directly embedded in the item; there is no explicit labeling mechanism beyond the text itself.
- NEEDS REVIEW: Not implemented in source. Behavior undefined. Whether "soon" items require explicit announcement to assistive technologies (e.g., aria-label, aria-description, or a visual indicator) is not specified in the source code. Evidence: no ARIA attributes or screen-reader-specific markup present.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| checklist-001 | must-accept-groups | groups array with one group containing one item with text "Feature A" | Render div.lp-checklist containing h3 with "Feature A"'s heading and li containing span with "Feature A" text |
| checklist-002 | must-render-heading | groups array with heading "Group 1" | h3 element contains heading text "Group 1" |
| checklist-003 | must-render-items | group with items array [{ text: "Item A" }, { text: "Item B" }] | ul renders two li elements, each containing span with respective text |
| checklist-004 | must-not-render-empty-list | group with empty items array [] | h3 heading renders, but no ul element is rendered for that group |
| checklist-005 | must-support-soon-state | item with { text: "Coming soon", soon: true } | li element receives class "lp-checklist__item--soon" |
| checklist-006 | must-support-soon-state | item with { text: "Available", soon: false } or soon undefined | li element does not receive "lp-checklist__item--soon" class |
| checklist-007 | must-apply-lp-checklist-class | any valid groups array | root div element has class "lp-checklist" |
| checklist-008 | must-accept-groups | groups array with multiple groups | component renders a separate div for each group, maintaining order |

## Edge Cases

- **Empty groups array**: If the groups prop is an empty array, the component renders an empty div with class `lp-checklist`. No error occurs.
- **Null or undefined items array**: Not applicable: TypeScript interface requires `items: ChecklistItem[]` (non-nullable); items array is always present and is always an array.
- **Empty text**: An item with an empty string or empty ReactNode for `text` renders the list item and span; the span contains the empty text. No special handling or hiding occurs.
- **soon property edge cases**: When `soon` is any truthy value, the class is applied; when `soon` is falsy (false, undefined, 0, null, "", etc.), the class is not applied. The code does not distinguish between different falsy values.
- **ReactNode content in heading and text**: Both `heading` and `text` accept ReactNode, permitting complex nested content (elements, fragments, conditionals). The component renders them as-is without validation or sanitization.

## Configuration

Not applicable: Checklist is a presentational component with no configuration options. The component's appearance and behavior are entirely controlled via the `groups` prop structure and the parent's CSS.

## Deep Linking

Not applicable: Checklist is a presentational component with no URL routes, navigation, or deep-linking behavior.

## Localization

Not applicable: Checklist does not render any static text or labels. All user-facing strings are provided via the `groups` prop by the parent component; localization is the parent's responsibility.

## Accessibility Options

Not applicable: Checklist does not respond to system accessibility options (reduce motion, increase contrast, differentiate without color, etc.); all styling is delegated to the `lp-checklist` CSS class.

## Feature Flags

Not applicable: Checklist is a presentational component with no feature flags or conditional behavior.

## Analytics

Not applicable: Checklist does not emit any events or analytics. Parent components are responsible for tracking user interactions with checklist content.

## Privacy

Not applicable: Checklist does not collect, store, transmit, or retain any data. It is a presentational component that renders data provided by the parent.

## Logging

Not applicable: Checklist does not perform any logging. Subsystem-level logging is the responsibility of parent components.

## Platform Notes

- **TypeScript/React (Web)**: Render using React's JSX syntax with the `Checklist` functional component from `packages/web/packages/landing/src/blocks/Checklist.tsx`. The component accepts a `groups` prop of type `ChecklistGroup[]`. Styling via CSS class selectors `.lp-checklist` and `.lp-checklist__item--soon`; see `css/blocks.css` for layout and column-count implementation.
- **SwiftUI**: Use a VStack containing multiple sections, each with a header Text rendering the group heading and a VStack of Text or Label elements for items. Apply the "soon" state via a modifier (e.g., opacity or foreground color) conditioned on the item's `soon` property. Do not render the list container if items are empty.
- **Compose**: Use a Column containing multiple sections, each with a Text composable for the group heading and a LazyColumn of Row elements for items. Apply the "soon" state via Modifier.conditional or a conditional composable (e.g., alpha or color) when the item's `soon` property is true. Do not render the list if items are empty.
- **AppKit / UIKit**: On AppKit (macOS), use NSStackView or NSGridView with an NSTextField for each group heading and NSTableView or NSStackView for items, conditionally hiding the list view if items are empty. On UIKit (iOS), use UIStackView with UILabel for headings and UITableView or UIStackView for items, similarly hiding the list if empty. Apply the "soon" state via text attributes (italics, reduced opacity, or different color).
- **WinUI 3**: Use a Grid or StackPanel for each group, with a TextBlock for the group heading and a ListView or ItemsControl for items. Set ItemsControl visibility to Collapsed if the items collection is empty. Apply the "soon" state via a style or visual state (e.g., Opacity or Foreground brush) bound to the `soon` property via a data template or converter. Ensure the root Grid or StackPanel has the equivalent of a CSS class hook for styling (e.g., x:Name="ChecklistRoot") to match `.lp-checklist` styling.

## Design Decisions

- **No ul rendering for empty items**: The source code conditionally renders the `<ul>` only when `items.length > 0`. This design prevents invisible layout artifacts (empty list elements with no visible content that still occupy space). This is a deliberate choice and not a bug.
- **soon as a field, not a phrase in text**: The source code accepts `soon` as a boolean property rather than requiring the parent to include "coming soon" text. This allows the component to apply a consistent visual treatment (CSS class) without duplicating the concept in multiple places. The comment explicitly notes: "The distinction has to be structural, which is why it is a field here and not a phrase in `text`."
- **ReactNode for heading and text**: Both `heading` and `text` accept ReactNode, not just strings. This allows rich content (nested elements, conditional rendering, fragments) without modifying the component. It is the parent's responsibility to ensure complex content renders accessibly.
- **Map index as key**: The component uses array index as the React key for both groups and items (`key={i}` and `key={j}`). This is appropriate for stable lists that do not reorder, filter, or insert items dynamically. If the groups or items are reordered, the component may not update correctly.

## Compliance

Not applicable: Checklist is a basic presentational component with no compliance requirements specific to security, data handling, or regulatory frameworks. Implementers should ensure the containing page meets WCAG, GDPR, or other applicable standards through their own practices.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation from web source |
