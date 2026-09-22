---
id: 40a6b717-cbdb-4d49-9f98-b318668b396c
title: Syntax Quick Reference
domain: agenticdevelopercookbook://ingredients/quick-reference
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Toolbar control that opens a dismissible popover displaying a syntax cheatsheet
  for language features.
platforms:
- web
tags:
- toolbar
- popover
- cheatsheet
- reference
depends-on: []
related: []
references: []
---

# Syntax Quick Reference

## Overview

A toolbar control that opens a dismissible popover listing a language syntax cheatsheet. The component provides a reusable shell for displaying reference material as labeled code examples. It is language-agnostic: the entries (label and syntax pairs) are provided by the consumer. Built on the shared Popover primitive, it inherits outside-click and Escape dismissal, plus automatic focus restoration to the trigger button on close.

## Behavioral Requirements

- **must-render-trigger-button**: The component MUST render a button trigger with an outline variant and small size.
- **must-show-book-icon**: The trigger button MUST display a BookText icon positioned at the inline start.
- **must-set-aria-label**: The trigger button MUST have an `aria-label` attribute set to the value of the `ariaLabel` prop.
- **must-open-popover-on-click**: The component MUST open the popover when the trigger button is clicked.
- **must-display-title**: The popover MUST display the provided title using field-caption typography styling.
- **must-render-entries-as-grid**: The component MUST render syntax entries as a definition list (`dl`) in a two-column grid layout with label (`dt`) and code (`dd`) pairs.
- **must-style-entry-labels**: Entry labels (dt elements) MUST be displayed at small font size with muted foreground color.
- **must-style-code-block**: Code blocks (dd elements) MUST use monospace font, extra-small font size, pre-wrap whitespace handling, and snug line height.
- **must-dismiss-on-escape**: The popover MUST close when the Escape key is pressed (inherited from Popover primitive).
- **must-dismiss-on-outside-click**: The popover MUST close when the user clicks outside the popover bounds (inherited from Popover primitive).
- **must-restore-focus**: The component MUST restore focus to the trigger button after the popover is dismissed (inherited from Popover primitive).
- **must-accept-optional-trigger-label**: The component MUST accept an optional `triggerLabel` prop to display visible text on the trigger button.
- **may-customize-width**: The component MAY accept a `contentClassName` prop to customize the popover's width (default is `w-80` for 20rem).
- **may-customize-columns**: The component MAY accept a `columnsClassName` prop to customize the grid column layout (default is `grid-cols-[7rem_1fr]`).
- **may-customize-position**: The component MAY accept `side` and `align` props to position the popover relative to the trigger (default side is `bottom`, default align is `end`).
- **may-apply-custom-classes**: The component MAY accept a `className` prop to apply additional CSS classes to the trigger button.

## Appearance

- **Trigger button**: Outline variant, small size, with BookText icon positioned at inline-start and optional text label.
- **Title**: Uses field-caption typography class with vertical spacing (space-y-3 in grid container).
- **Entry label (dt)**: Small font size, muted foreground color (text-apt-text-muted).
- **Code block (dd)**: 
  - Font: monospace (font-mono)
  - Size: extra-small (text-xs)
  - Whitespace: pre-wrap (preserves formatting)
  - Line height: snug (leading-snug)
  - Foreground: default text color (text-apt-text)
  - Width constraint: min-w-0 to prevent overflow in grid
- **Grid layout**: Two-column definition list with horizontal gap of 3 units (gap-x-3) and vertical gap of 2 units (gap-y-2).
- **Popover container**: Default width of 20rem (w-80), vertical spacing of 3 units (space-y-3).

## States

| State | Appearance change |
|-------|------------------|
| Default (closed) | Trigger button displays in outline style. Popover is hidden. |
| Open | Popover is visible above, below, or beside the trigger (per `side` and `align` props). |
| Focused | Trigger button receives keyboard focus (inherited from button element). |

## Accessibility

- **Button role**: The trigger is a native `button` element with semantic button role.
- **Accessible name**: The trigger MUST have an `aria-label` that describes the cheatsheet purpose (e.g., "Markdown quick reference").
- **Definition list structure**: Entries are marked up as `dl`, `dt`, and `dd` elements, providing semantic structure for assistive technology.
- **Focus management**: The Popover primitive handles focus containment while open and restores focus to the trigger when dismissed.
- **Keyboard interaction**: Escape dismisses the popover. Tab and Shift+Tab navigate within the popover (inherited from Popover).
- **Minimum touch target**: The trigger button MUST meet platform touch target size requirements (44×44pt on iOS, 48×48dp on Android). On web, the button size is small; applications SHOULD ensure adequate click/touch target area.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| quick-ref-001 | must-render-trigger-button, must-show-book-icon | Component rendered | Trigger button is visible with BookText icon |
| quick-ref-002 | must-set-aria-label | ariaLabel="Markdown quick reference" | Trigger has aria-label="Markdown quick reference" |
| quick-ref-003 | must-open-popover-on-click | User clicks trigger button | Popover becomes visible |
| quick-ref-004 | must-display-title | title="Markdown Syntax" | Popover displays "Markdown Syntax" in field-caption style |
| quick-ref-005 | must-render-entries-as-grid | entries=[{label: "Bold", syntax: "**text**"}, {label: "Italic", syntax: "*text*"}] | Popover displays two rows in grid: "Bold" / "**text**" and "Italic" / "*text*" |
| quick-ref-006 | must-style-entry-labels | Entry with label "Bold" | Label rendered at small font size in muted color |
| quick-ref-007 | must-style-code-block | Syntax with newlines: "line1\nline2" | Code block preserves newlines, uses monospace font, xs size, snug leading |
| quick-ref-008 | must-dismiss-on-escape | Popover is open; user presses Escape | Popover closes |
| quick-ref-009 | must-dismiss-on-outside-click | Popover is open; user clicks outside popover | Popover closes |
| quick-ref-010 | must-restore-focus | Popover is open and receives focus; user dismisses popover | Focus returns to trigger button |
| quick-ref-011 | must-accept-optional-trigger-label | triggerLabel="Syntax" | Trigger button displays "Syntax" text alongside icon |
| quick-ref-012 | may-customize-width | contentClassName="w-96" | Popover renders with width class w-96 (24rem) instead of default w-80 |
| quick-ref-013 | may-customize-columns | columnsClassName="grid-cols-[10rem_1fr]" | Entry grid uses 10rem / 1fr column split instead of default 7rem / 1fr |
| quick-ref-014 | may-customize-position | side="top", align="start" | Popover opens above trigger (top) and aligns to start |
| quick-ref-015 | may-apply-custom-classes | className="custom-trigger-class" | Trigger button receives custom-trigger-class in addition to outline and size classes |

## Edge Cases

- **Empty entries array**: If no entries are provided, the popover still renders the title and a definition list with no rows. Result: a popover with only the title text is shown.
- **No triggerLabel**: If `triggerLabel` is undefined or null, the trigger button displays only the BookText icon without text. Result: icon-only button.
- **Very long syntax text**: The `dd` element has `min-w-0` to allow its content to shrink below its grid column's default size, preventing overflow. If syntax text is exceptionally long, the `whitespace-pre-wrap` class breaks lines within the code block. Result: text wraps instead of overflowing.
- **Narrow customized width**: If `contentClassName` is set to a very narrow width, the popover may be too small to display entries clearly. Responsibility rests with the consumer to provide appropriate width. Result: entries may be cramped or wrap unexpectedly.
- **Custom className conflicts**: If `className` prop contains classes that conflict with outline/size styling, the merged classes follow Tailwind's conflict resolution (later classes override). Result: unexpected styling if conflicting classes are intentional.
- **No aria-label provided**: If `ariaLabel` is not provided or is an empty string, the trigger button lacks an accessible name. Result: screen readers cannot announce the button's purpose. (This is a constraint from the source: `ariaLabel` is a required prop.)

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `title` | string | required | The popover's heading text, e.g., "Markdown quick reference" |
| `entries` | ReadonlyArray<{label: string; syntax: string}> | required | Array of syntax entries to display as label-code pairs |
| `ariaLabel` | string | required | The accessible name for the trigger button, typically matching the title |
| `triggerLabel` | React.ReactNode | undefined | Optional visible text to display on the trigger button alongside the icon |
| `side` | "top" \| "right" \| "bottom" \| "left" | "bottom" | Popover placement relative to the trigger (vertical) |
| `align` | "start" \| "center" \| "end" | "end" | Popover placement relative to the trigger (horizontal) |
| `className` | string | undefined | Additional CSS classes to apply to the trigger button |
| `contentClassName` | string | "w-80" | CSS class(es) for the popover width; override for wider content |
| `columnsClassName` | string | "grid-cols-[7rem_1fr]" | CSS class(es) for grid column layout; adjust label column width if needed |

## Deep Linking

Not applicable: this component is a toolbar control for displaying reference material within a page, not a navigable destination or route target.

## Localization

Not applicable: string content (title, triggerLabel, ariaLabel, entry labels, syntax) is provided entirely by the consumer. The component renders no hard-coded UI strings.

## Accessibility Options

Not applicable: the component inherits focus management and popover behavior from the shared Popover primitive. It does not respond to system accessibility display options such as Reduce Motion, Increase Contrast, or Differentiate Without Color. Applications using this component SHOULD implement motion and contrast handling at the Popover level if needed.

## Feature Flags

Not applicable: no feature flags are present in the source code. The component is always enabled.

## Analytics

Not applicable: no analytics instrumentation is present in the source code. Applications using this component MAY instrument interactions (e.g., trigger click, dismiss) themselves if desired.

## Privacy

Not applicable: the component does not collect, store, or transmit user data. It renders static reference material provided by the consumer.

## Logging

Not applicable: no logging is implemented in the source code.

## Platform Notes

- **React/Web**: Source files are in `packages/web/packages/ui/src/components/quick-reference.tsx`. Uses React hooks, the shared Popover primitive (PopoverTrigger, PopoverContent), button variants from the component library, and Tailwind CSS for styling. The BookText icon is from lucide-react.
- **SwiftUI**: Start from a button with a sheet or popover modifier. The trigger is a button with an SF Symbol (book.fill or similar) and optional text. The content is a VStack with a Text title and a List or ScrollView of label-code pairs. Handle dismiss with onDismiss callback and restore focus via @FocusState.
- **Compose**: Use a Button composable as the trigger with an Icon from Material Icons. Wrap the popover content in a Popup or Dialog composable. Entries can be rendered as a LazyColumn with rows displaying label and code. Use Material's color tokens and typography.
- **AppKit / UIKit**: 
  - **macOS (AppKit)**: Create an NSButton with an icon image and optional label. Use NSPopover for the content, positioning it with NSRectEdge. Display entries in an NSTableView with two columns (label and code) or a custom stack view. Restore responder chain focus on close.
  - **iOS (UIKit)**: Create a UIButton styled as a system button. Use UIPopoverPresentationController to present the reference content. Display entries in a UITableView or a UIScrollView with UIStackViews for rows. Manage focus and accessibility via UIAccessibility.
- **WinUI 3**: Use a Button control styled with outline and containing a Glyph (e.g., Segoe MDL2 Assets "PageHeaderEdit" icon). Use a Flyout or MenuFlyout control for the popover. Define DataTemplate for entries to display label (TextBlock) and code (RichEditBox or TextBlock in monospace). Handle focus and keyboard dismissal in the Flyout properties.

## Design Decisions

**Popover Inheritance**: The component is built on the shared Popover primitive to ensure consistent behavior across the application. Outside-click and Escape dismissal, focus restoration, and focus containment are handled by the Popover, not reimplemented here. This reduces code duplication and ensures all popovers behave identically.

**Definition List Markup**: Entries are marked up as a definition list (dl, dt, dd) rather than a table or unordered list. This provides semantic meaning to assistive technology: each label-syntax pair is explicitly a term and its definition. The grid layout is applied via CSS (Tailwind), decoupling presentation from semantics.

**Default Dimensions**: The default width (w-80 = 20rem) and column split (7rem for labels, 1fr for code) are based on common use cases (Markdown, code snippets). They can be customized via `contentClassName` and `columnsClassName` props when a specific language requires more or less space.

**Icon Positioning**: The BookText icon is positioned at the inline-start (left in LTR, right in RTL) using the `data-icon="inline-start"` data attribute. This allows the icon to participate in the button's icon-handling logic (if any) without hardcoding absolute positioning.

**Optional Trigger Label**: The `triggerLabel` prop is optional, allowing icon-only triggers for space-constrained toolbars. When present, the label appears alongside the icon.

**Pre-wrap Whitespace**: Code blocks use `whitespace-pre-wrap` to preserve formatting (indentation, line breaks) in syntax examples. This is essential for code reference material.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| Semantic HTML (definition list) | passed | Accessibility |
| Button element has accessible name (aria-label) | passed | Accessibility |
| Monospace font for code | passed | Typography |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation from source |
