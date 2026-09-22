---
id: 3C65C844-6C3C-43E2-B792-8575F5DDA9CF
title: EditorToolbar
domain: agenticdevelopercookbook://ingredients/editor-toolbar
type: ingredient
version: 1.0.0
status: review
language: en
created: 2026-09-22
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Semantic HTML toolbar wrapper with flexbox layout and ARIA accessibility
  for text editor surfaces.
platforms:
- web
tags: []
depends-on: []
related: []
references: []
---

# EditorToolbar

## Overview

EditorToolbar is a semantic layout wrapper that houses a horizontal control strip for text-editor surfaces (such as the row above a MarkdownEditor's textarea). It provides proper `role="toolbar"` and `aria-label` semantics for assistive technology, combined with flexbox layout and consistent gap spacing. The component is server-safe—it contains no hooks or client-side logic—and exists purely to establish correct HTML semantics and layout constraints for its children.

## Behavioral Requirements

- **must-render-toolbar-role**: Component MUST render a `div` element with `role="toolbar"` to identify itself to assistive technology as a toolbar region.
- **must-accept-aria-label**: Component MUST accept an `ariaLabel` prop that is passed directly to the `aria-label` attribute of the rendered element.
- **must-default-aria-label**: Component MUST use the default aria-label value `"Editor toolbar"` when the `ariaLabel` prop is not provided.
- **must-render-children**: Component MUST render the `children` prop without modification or filtering.
- **must-accept-class-name**: Component MUST accept a `className` prop and merge it with the component's default Tailwind classes using the `cn()` utility.
- **must-use-flexbox-layout**: Component MUST render with `display: flex` to establish flexbox layout for its children.
- **must-center-items-vertically**: Component MUST use flexbox alignment to center children vertically (`align-items: center`).
- **must-apply-gap-spacing**: Component MUST apply a consistent horizontal gap of `0.375rem` (6 pixels) between direct child elements via the `gap-1.5` Tailwind class.

## Appearance

- **Layout**: Flexbox row with horizontal gap
- **Gap spacing**: 0.375rem (6px) between children
- **Vertical alignment**: Children centered vertically
- **Background**: None (transparent by default)
- **Border**: None
- **Shadow**: None
- **Min/Max size**: No constraints applied by the component

## States

Not applicable: EditorToolbar is a pure layout container with no interactive state. It does not respond to user input and has no pressed, disabled, focused, or loading states.

## Accessibility

- **Role**: `toolbar` — identifies the region as a toolbar to assistive technology.
- **Accessible name**: MUST be provided via `aria-label`. The default name is `"Editor toolbar"`, which is announced by screen readers when focus enters or the region is explicitly searched.
- **Child focus management**: The component does not manage focus; child elements are responsible for their own keyboard and focus behavior.
- **Minimum tap target**: Not applicable to the container itself; child elements are responsible for meeting touch target size requirements (44×44pt minimum on iOS, 48×48dp minimum on Android, per platform guidelines).

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| editor-toolbar-001 | must-render-toolbar-role | Render component with default props | `<div role="toolbar" ...>` is present in the DOM |
| editor-toolbar-002 | must-default-aria-label | Render component without `ariaLabel` prop | Element has `aria-label="Editor toolbar"` |
| editor-toolbar-003 | must-accept-aria-label | Render with `ariaLabel="Custom toolbar"` | Element has `aria-label="Custom toolbar"` |
| editor-toolbar-004 | must-render-children | Render with `children={<button>Bold</button>}` | Button element is rendered inside the toolbar |
| editor-toolbar-005 | must-accept-class-name | Render with `className="custom-class"` | Element has both default classes and `custom-class` applied |
| editor-toolbar-006 | must-use-flexbox-layout | Render component and inspect computed style | `display: flex` is present on the element |
| editor-toolbar-007 | must-center-items-vertically | Render with tall and short children; inspect alignment | All children are vertically centered; no baseline drift |
| editor-toolbar-008 | must-apply-gap-spacing | Render with multiple child elements; inspect spacing | Horizontal gap between children is 6px (0.375rem) |

## Edge Cases

- **No children**: Component MUST render successfully with `children={undefined}` or `children={[]}`, producing an empty `<div role="toolbar">` element.
- **Single child**: Component MUST render successfully with a single child; gap spacing is not visible with only one child.
- **Empty ariaLabel**: If `ariaLabel=""` is explicitly passed, component MUST apply the empty string as the aria-label; assistive technology will announce "toolbar" (the role alone).
- **Multiple className values with conflicting styles**: The `cn()` utility resolves class conflicts by Tailwind's precedence rules; the last class in the argument order typically wins.
- **Server-side rendering**: Component is server-safe; it contains no hooks or client-side logic and MUST render correctly in server-side rendering contexts.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `ariaLabel` | `string` | `"Editor toolbar"` | Accessible name for the toolbar, announced by assistive technology |
| `className` | `string` | `undefined` | Optional CSS class string merged with default layout classes |
| `children` | `ReactNode` | `undefined` | Child elements to render inside the toolbar |

## Deep Linking

Not applicable: EditorToolbar is a layout container without deep-linking capabilities. Navigation and routing are managed by child components or parent pages.

## Localization

Not applicable: EditorToolbar has no user-facing strings beyond the `ariaLabel` prop, which is supplied by the caller and is not localized by the component itself.

## Accessibility Options

Not applicable: EditorToolbar is a pure layout component that responds to no accessibility display options (reduce motion, increase contrast, etc.). Child elements are responsible for responding to accessibility options as needed.

## Feature Flags

Not applicable: EditorToolbar is a foundational layout component with no feature flag support. Conditional rendering is handled at the parent level.

## Analytics

Not applicable: EditorToolbar is a layout container with no analytics instrumentation. Analytics for toolbar interactions are managed by child components.

## Privacy

Not applicable: EditorToolbar processes no user data and transmits no information. It is a static layout container.

## Logging

Not applicable: EditorToolbar has no logging. Debugging of toolbar child elements is performed at the child component level.

## Platform Notes

- **React/Web**: Source files `packages/web/packages/ui/src/components/editor-toolbar.tsx`. Uses Tailwind CSS classes (`flex`, `items-center`, `gap-1.5`) for layout and the `cn()` utility from the local `lib/utils` module to merge custom className props. Server-safe; no `use client` directive required.
- **SwiftUI**: Start from a `HStack` with spacing set to `6` points. Apply a `ControlGroup` wrapper or semantic `Section` header if the platform's equivalent toolbars require it. Ensure focus management for keyboard navigation within the stack.
- **Compose**: Start from a `Row` (or `LazyRow` if large datasets) with `horizontalArrangement = Arrangement.spacedBy(6.dp)` and `verticalAlignment = Alignment.CenterVertically`. Wrap in a `Box` with semantic role (`role = Role.ToolBar` if the Compose runtime supports it) or apply a content description for accessibility.
- **AppKit / UIKit**: Start from an `NSStackView` (AppKit) or `UIStackView` (UIKit) configured with `axis = .horizontal`, `spacing = 6`, and `alignment = .center`. If using SwiftUI on iOS/macOS, use a native `HStack` as above. Apply appropriate accessibility labels and traits to the container.
- **WinUI 3**: Start from a `StackPanel` with `Orientation="Horizontal"` and `Spacing="6"`. Apply `VerticalAlignment="Center"` to align children. Use a `Grid` or `Border` as the parent if a toolbar control with built-in styling is preferred. Set `AutomationProperties.Name` to the equivalent of the `aria-label` prop for UIA accessibility.

## Design Decisions

EditorToolbar is deliberately minimal and headless — it provides only semantic HTML structure and basic flexbox layout, deferring all visual styling to the caller via the `className` prop. This design allows the component to work in any visual context (light mode, dark mode, custom themes) without baking in colors or opinionated styling. The component's sole responsibility is to establish correct toolbar semantics and consistent child spacing, leaving presentational concerns to the parent or a parent-provided theme.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| [toolbar-semantics](agenticdevelopercookbook://compliance/accessibility#toolbar-semantics) | passed | Accessibility |
| [aria-label-presence](agenticdevelopercookbook://compliance/accessibility#aria-label-presence) | passed | Accessibility |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation from web source |
