---
id: 5e401b96-7157-4c5b-a623-b90dde372231
title: Section Header
domain: agenticdevelopercookbook://ingredients/section-header
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A layout header for content sections with title, optional eyebrow label,
  help popover, and action slots.
platforms:
- kotlin
- swift
- typescript
- web
- windows
tags:
- layout
- header
- structure
depends-on: []
related: []
references: []
---

# Section Header

## Overview

A section header is a layout component that anchors a content area with a prominent title, an optional descriptive eyebrow label, contextual help, and action controls. Commonly used to introduce major sections of a dashboard or content view. The component organizes a left section (title and eyebrow) and right section (actions and help) in a horizontal flex layout with clear visual hierarchy.

## Behavioral Requirements

- **must-render-title**: The component MUST render the `title` prop content as an h2 heading.
- **must-support-eyebrow**: The component MUST render the `eyebrow` prop if provided; if not provided or empty, the eyebrow slot MUST NOT be rendered.
- **must-support-help**: The component MUST render a help trigger button if the `help` prop is provided; if not provided or empty, the help trigger button MUST NOT be rendered.
- **must-support-actions**: The component MUST render the `actions` prop content if provided; if not provided or empty, the actions slot MUST NOT be rendered.
- **must-apply-custom-class**: The component MUST apply the `className` prop to the root container if provided.
- **must-display-help-popover**: When the help trigger button is activated (click or keyboard Enter), the component MUST display a popover containing the `help` prop content, positioned below and aligned to the end (right edge).
- **must-label-help-trigger**: The help trigger button MUST have an accessible label "About this section" via `aria-label` attribute.
- **must-maintain-layout-order**: Left section (title area) MUST be positioned before right section (actions and help) in visual and DOM order.

## Appearance

- **Layout**: Flex container with `items-start justify-between gap-4`, allowing left section to grow and right section to shrink without wrapping.
- **Left section spacing**: Vertical stack with `space-y-1` between eyebrow and title.
- **Eyebrow font**: Monospace, 0.65rem (10.4px), uppercase, tracking-wider, color uses `apt-text-dim` semantic token.
- **Title font**: Monospace, text-sm (14px), font-medium (500 weight), tracking-wide, color uses `apt-gold` semantic token.
- **Help button**: Uses `quietControlClass` for muted styling; icon is 16×16px CircleHelp (lucide-react).
- **Help popover**: Fixed width of 288px (`w-72`), positioned at `bottom` and aligned to `end` (right edge).
- **Right section spacing**: Flex with `gap-2` between actions and help button; `shrink-0` prevents flex shrinking.

## States

| State | Appearance change |
|-------|------------------|
| Default (no eyebrow, no help, no actions) | Title only, left-aligned. |
| With eyebrow | Eyebrow rendered above title in dim monospace. |
| With help | Help trigger button displayed in right section; interactive. |
| With actions | Actions rendered in right section before help button. |
| Help popover open | Popover appears below help trigger with content; overlay covers page. |
| Custom className | Additional classes merged with root container. |

## Accessibility

- **Semantic heading**: Title is rendered as an `<h2>` to establish document outline hierarchy.
- **Help button label**: `aria-label="About this section"` describes the button purpose for screen readers.
- **Popover keyboard**: Help button is activated by click or Enter/Space keys; popover receives focus management per Popover component implementation (trapFocus, dismissOnEscape).
- **Text content**: Eyebrow and title content are read as-is; no additional aria-labels required if text is meaningful.
- **Icon-only button**: Help button contains only an icon; `aria-label` is REQUIRED to provide accessible name.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| section-header-001 | must-render-title | `title="All ecosystems"` | h2 heading with text "All ecosystems" rendered in left section |
| section-header-002 | must-support-eyebrow | `eyebrow="Section"`, `title="Title"` | Eyebrow text rendered above title in dim monospace; title rendered below in gold monospace |
| section-header-003 | must-support-eyebrow | `title="Title"` (no eyebrow) | Only title rendered; eyebrow slot absent from DOM |
| section-header-004 | must-support-help | `help={<div>Help content</div>}`, `title="Title"` | Help button visible in right section |
| section-header-005 | must-support-help | `title="Title"` (no help) | Help button not rendered |
| section-header-006 | must-display-help-popover | Help button present, user clicks help trigger | Popover appears; popover content (help prop) is visible; popover positioned below trigger, aligned right |
| section-header-007 | must-display-help-popover | Help button present, user presses Enter on focused help trigger | Popover opens (same as click) |
| section-header-008 | must-label-help-trigger | Help button rendered | Button has `aria-label="About this section"` |
| section-header-009 | must-support-actions | `actions={<button>Action</button>}`, `title="Title"` | Actions content rendered in right section, before help button |
| section-header-010 | must-support-actions | `title="Title"` (no actions) | Actions slot absent from DOM |
| section-header-011 | must-apply-custom-class | `className="my-custom-class"`, `title="Title"` | Root container has both default flex classes and "my-custom-class" |
| section-header-012 | must-maintain-layout-order | All props provided | Left section (title area) precedes right section (actions + help) in visual layout; justified to opposite edges |

## Edge Cases

- **Empty title string**: Title MUST still render as an h2; h2 will be empty but semantically present.
- **Very long title**: Title renders without constraint; text may wrap if container width allows.
- **Very long help content**: Popover has fixed width (288px); content may scroll vertically if overflows height; no max-height constraint in source.
- **Help button focus during popover open**: Focus remains in popover; pressing Escape SHOULD close popover and return focus to trigger (Popover component handles this).
- **Multiple rapid help button activations**: Popover opens on first activation; subsequent activations toggle state (Popover component manages state).
- **Actions slot too wide**: Actions element shares right section with help button; if actions exceed available space, layout depends on actions' own flex properties. Component applies `shrink-0` to right section container, preventing flex shrinking.
- **Custom className conflicts**: If `className` prop contains flex or positioning classes, they merge via `cn()` utility; later classes may override defaults (standard Tailwind precedence).

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `title` | ReactNode | (required) | Content displayed as section heading; rendered as h2 |
| `eyebrow` | ReactNode \| undefined | undefined | Optional label above title; not rendered if undefined |
| `help` | ReactNode \| undefined | undefined | Optional help content displayed in popover; help button not rendered if undefined |
| `actions` | ReactNode \| undefined | undefined | Optional action controls rendered in right section; not rendered if undefined |
| `className` | string \| undefined | undefined | Additional CSS classes merged with root container |

## Deep Linking

Not applicable: Section Header is a layout primitive without associated routes or deep-link targets.

## Localization

Not applicable: Section Header contains no user-facing strings; all content is passed via props and localized by parent component.

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | Help popover open/close animation respects `prefers-reduced-motion` (handled by Popover component) |
| Increase Contrast | No component-specific support; parent theme applies contrast adjustments to `apt-gold` and `apt-text-dim` tokens |
| Differentiate Without Color | Eyebrow and title rely on monospace font weight and size for differentiation, not color alone |

## Feature Flags

Not applicable: Section Header is a foundational layout component with no feature-gating.

## Analytics

Not applicable: Section Header is a layout primitive and does not track user interactions; analytics for help popover interaction delegated to parent component or Popover implementation.

## Privacy

Not applicable: Section Header does not collect, store, or transmit user data.

## Logging

Not applicable: Section Header does not emit application logs.

## Platform Notes

- **SwiftUI**: Use a `VStack` for the left section (eyebrow above title as Text/Label components), and an `HStack` for the right section (actions leading, help PopoverButton trailing). Title should use `.font(.system(.body, design: .monospaced))` with gold semantic color; eyebrow uses dim secondary text color. Spacing mirrors the Tailwind gap tokens. PopoverButton triggers a popover modifier on the top-level HStack.

- **Compose**: Use a `Row` (horizontal flex) as root container with `verticalAlignment = Alignment.Top` and `modifier = Modifier.fillMaxWidth()`. Left section is a `Column` (vertical stack) with title and optional eyebrow as Text components, using monospace font (default serif family or explicit monospace typeface) and semantic gold color. Right section is a `Row` for actions and help button. Help button uses `IconButton` wrapping a CircleHelpIcon (24dp or Material Icons equivalent); clicking opens a PopupMenu or Dialog for help content.

- **React/Web**: Component implemented in `packages/web/packages/ui/src/blocks/section-header.tsx`. Props: `eyebrow` (ReactNode), `title` (ReactNode, required), `help` (ReactNode), `actions` (ReactNode), `className` (string). Title rendered as `<h2>` with monospace font and gold color. Help button uses Lucide's `CircleHelp` icon (16px) wrapped in a Popover trigger; popover content positioned via `side="bottom" align="end"` with fixed width `w-72`. Uses Tailwind utility classes for styling; no inline styles.

- **AppKit / UIKit**: Use `NSStackView` (AppKit) or `UIStackView` (UIKit) with `axis = .horizontal`, `alignment = .top`, `distribution = .fill`. Left stack contains title `NSTextField` (AppKit) or `UILabel` (UIKit) and optional eyebrow label, both using system monospace font (`.monospacedSystemFont(ofSize:weight:)`) and gold semantic color. Right stack contains optional actions and help button (`NSButton` / `UIButton`). Help button uses a system symbol image (`circle.fill.badge.questionmark` or equivalent) and triggers a popover with help text via `NSPopover` (AppKit) or a `UIPopoverPresentationController` (UIKit).

- **WinUI 3**: Use a `StackPanel` with `Orientation="Horizontal"` and `VerticalAlignment="Top"` as root. Left section is a `StackPanel` with `Orientation="Vertical"` containing a `TextBlock` for title (`FontFamily="Courier New"` or system monospace, `Foreground="{StaticResource GoldBrush}"`) and optional eyebrow `TextBlock` with secondary text color. Right section is a `StackPanel` with `Orientation="Horizontal"` for actions and help button. Help button uses `AppBarButton` or standard `Button` with a `SymbolIcon` (CircleQuestion or equivalent); clicking opens a `TeachingTip` or custom popup to display help content at the same position. Popover behavior (dismiss on outside click, trap focus) configured via `TeachingTip.IsOpen` and event handlers.

## Design Decisions

- **Monospace typography**: Title and eyebrow use monospace font to create visual distinction and hierarchy, aligned with a technical/data-focused design system. This reinforces the component's use in dashboards and structured content.
- **Gold semantic color for title**: Gold conveys prominence and primary hierarchy. The `apt-gold` token is reserved for the section title, distinguishing it from standard text.
- **Subtle help button styling**: The `quietControlClass` keeps the help button visually subordinate to content, preventing distraction while remaining discoverable for users who need help.
- **Fixed popover width (288px)**: The `w-72` constraint ensures readability of help text without forcing unnecessary wrapping; help content longer than ~300 characters may wrap or require scrolling.
- **Help popover position (bottom, end)**: Positioning below and aligned to the right follows standard popover conventions; this placement avoids overlap with title and keeps the trigger button visible.
- **Left-justified title, right-justified help/actions**: The `justify-between` flex property creates a clear visual separation between content (left) and controls (right).
- **Required title prop**: Title is not optional because the component's purpose is to introduce a section; a section header without a title is meaningless.
- **Optional slots for flexibility**: Eyebrow, help, and actions are optional to accommodate simple use cases (title-only headers) without requiring conditional rendering at call sites.

## Compliance

Not applicable: Section Header is a foundational layout component without direct compliance concerns; parent application handles compliance for help content and actions.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | | Initial creation |
