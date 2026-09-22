---
id: 98444e89-1044-43a7-9ec5-75da579c528a
title: Versus
domain: agenticdevelopercookbook://ingredients/versus
type: ingredient
version: 1.0.0
status: review
language: en
created: 2026-09-22
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Side-by-side comparison of two options, emphasizing the active choice.
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

# Versus

## Overview

`Versus` displays two panels side by side, presenting a comparison between two options or approaches. The component visually distinguishes the "us" (active) side from the "them" (reference) side through styling, allowing users to quickly grasp the contrast at a glance. Each panel contains a title, an optional one-line lede, and optional bullet points.

## Behavioral Requirements

- **must-render-both-sides**: Component MUST render exactly two panels, one for the "them" option and one for the "us" option.
- **must-render-required-title**: Component MUST render the title from each `VersusSide` as an h3 element.
- **must-render-optional-lede**: Component MUST render the lede as a paragraph element only if `lede` is defined (not undefined).
- **must-render-optional-points**: Component MUST render points as a bullet list only if `points` is defined and has length greater than zero.
- **must-distinguish-sides**: Component MUST apply a visual style that marks the "us" side as the active or highlighted option, distinct from the "them" side.
- **must-omit-empty-fragments**: Component MUST NOT render an empty paragraph or empty list when `lede` or `points` is provided but empty; callers MUST omit these props entirely to indicate absence.
- **must-render-identical-structure**: Component MUST use a single Panel implementation for both sides to ensure consistent rendering regardless of which side is displayed.

## Appearance

- **Layout**: Two columns of equal width, arranged horizontally
- **Column spacing**: Gap between panels determined by platform design guidelines
- **Title styling**: h3 element with inherited typography
- **Lede styling**: Paragraph element with top margin, styled as introductory text
- **Points styling**: Unordered list with bullet markers, items as li elements
- **Visual distinction**: "us" panel receives highlighting (background, border, or accent color); "them" panel uses neutral styling
- **Padding**: Consistent padding within each panel
- **Background**: Platform-dependent; typically neutral for "them", accent or highlight for "us"

## States

| State | Appearance change |
|-------|------------------|
| Default | Both panels visible; "them" neutral, "us" highlighted |
| No lede | Paragraph element absent; title and points (if present) render normally |
| No points | List element absent; title and lede (if present) render normally |
| No lede or points | Only title renders in the panel |

## Accessibility

- **Role**: Each side is a div container; title is an h3 heading; lede is a paragraph; points are a list.
- **Semantic structure**: Heading hierarchy is preserved; assistive technologies announce list structure for points.
- **Label requirements**: Titles are read as headings; lede provides context; bullet points are announced as list items.
- **Announce visual distinction**: Assistive technology users must be able to distinguish "us" from "them" through non-visual means. A text label, aria-label, or semantic role difference is required.
- **Minimum tap target**: Panels are containers; no interactive tap targets within this component itself.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|----|----|----|
| versus-001 | must-render-both-sides | `them: { title: "Option A" }`, `us: { title: "Option B" }` | Two panels rendered, each with its title in an h3 |
| versus-002 | must-render-required-title | `them: { title: "Text" }` | h3 element contains "Text" |
| versus-003 | must-render-optional-lede | `{ lede: "Introduction" }` | Paragraph element renders with "Introduction" |
| versus-004 | must-render-optional-lede | `{ lede: undefined }` | No paragraph element in panel |
| versus-005 | must-render-optional-points | `{ points: ["Point 1", "Point 2"] }` | Unordered list with two li elements |
| versus-006 | must-render-optional-points | `{ points: [] }` or `points: undefined` | No list element in panel |
| versus-007 | must-distinguish-sides | `them` and `us` provided | "us" panel visually distinct from "them" panel |
| versus-008 | must-omit-empty-fragments | `{ lede: <></> }` passed instead of omitted | Empty fragment renders as styled empty paragraph (indicates caller error) |
| versus-009 | must-render-identical-structure | Both sides with identical props | Both panels render with identical DOM structure |

## Edge Cases

- **Null title**: `title` is required; null or undefined title is a prop contract violation.
- **Empty title**: Title is rendered as provided; an empty string produces an empty h3.
- **Empty lede string**: If `lede` is defined as an empty string, a paragraph renders. Caller should omit `lede` to avoid empty paragraph.
- **Empty points array**: If `points` is defined as an empty array, no list renders (length check prevents rendering).
- **Single point**: `points: ["Only one"]` renders a list with one item.
- **Very long content**: Component imposes no length limits; overflow is handled by CSS or parent container.
- **Rich content in lede or points**: ReactNode allows any React element; complex JSX in lede or points is supported.
- **Missing "us" or "them" prop**: Both `them` and `us` are required; omitting either is a prop contract violation.

## Configuration

Not applicable. Component accepts `them` and `us` props of type `VersusSide`; no configuration options or feature flags are present.

## Deep Linking

Not applicable. Component is a presentational element with no associated URL or deep link pattern.

## Localization

Not applicable. Component renders user-provided content; localization is the caller's responsibility. Titles, ledes, and points MAY contain localized strings.

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | Not applicable. Component is static and does not animate. |
| Increase Contrast | Component rendering does not adapt. Platform CSS or theme must apply contrast enhancement. |
| Differentiate Without Color | Component rendering does not adapt. Platform CSS or theme must ensure "us" and "them" sides are distinguishable without relying on color alone. |

## Feature Flags

Not applicable. Component has no feature flag configuration.

## Analytics

Not applicable. Component is presentational and does not emit user interaction events.

## Privacy

Not applicable. Component does not collect, store, or transmit data.

## Logging

Not applicable. Component does not emit structured logs.

## Platform Notes

- **SwiftUI**: Leverage `VStack` with two horizontal sections; apply `FontWeight.bold` or `Font.headline` styling to titles. Use conditional rendering (`if lede != nil`) to render optional content. Compose the comparison layout with `HStack` or a custom container that highlights the "us" side with background color or border. Manage tap targets and semantic context through `AccessibilityElement` wrappers.
- **Compose**: Use `Row` with two equal-weight children for side-by-side layout. Apply `BasicText` for titles with heading semantics. Conditionally render `Text` for lede and `LazyRow` or `Column` for points. Apply `Modifier.background()` to distinguish "us" from "them". Ensure keyboard navigation uses `focusable()` and `semantics()` to label the comparison sides.
- **React/Web**: Render two `<div>` containers with CSS flexbox (display: flex; gap). Apply CSS class `.lp-versus__them` and `.lp-versus__us` to control styling. Use conditional rendering (`{lede && <p>...}`) to show optional content. Ensure "us" panel has visual prominence through background, border, or accent color. Apply `role="article"` or `role="region"` if the comparison needs to be announced as a distinct section.
- **AppKit / UIKit**: Use `NSView` (macOS) or `UIView` (iOS) in a horizontal stack (NSSplitView on macOS, UIStackView on iOS with axis `.horizontal`). Render title as `NSTextView` (macOS) or `UILabel` (iOS) with heading typography. Conditionally add lede and points subviews. Apply background color or `CALayer.borderWidth` to mark the "us" side as active. Implement custom layout logic or use Auto Layout constraints to maintain equal column widths.
- **WinUI 3**: Render two `Grid` elements within a parent `StackPanel` with `Orientation="Horizontal"`. Set both `Grid` elements to equal width using `ColumnDefinition` with `Width="*"`. Place `TextBlock` for the title with `FontSize="20"` and `FontWeight="Bold"`. Conditionally render a `TextBlock` for lede and an `ItemsControl` or `ListView` for points. Apply `Background="{StaticResource AccentBrush}"` to the "us" side and a neutral `Background` (e.g., `"#F0F0F0"`) to the "them" side. Use `Padding` and `Margin` properties to control spacing within and between panels.

## Design Decisions

The component uses a shared `Panel` implementation for both sides rather than duplicating JSX. This decision reduces the risk of divergent rendering between sides and ensures that any fix applied to one side automatically applies to the other. When the caller provides an empty collection or empty fragment to `lede` or `points`, the component renders it as styled empty content (e.g., a paragraph with margins but no text). This is intentional: callers must explicitly omit optional props to indicate "no content," not provide empty values. An empty fragment passed to `points` would render an empty `<ul>` with margins; the component checks `points.length > 0` to prevent an empty list, but does not guard against `points` being an empty fragment directly.

## Compliance

Not applicable. Component is a presentational element; no security, data-handling, or regulatory compliance concerns apply.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | | Initial creation |
