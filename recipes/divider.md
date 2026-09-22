---
id: 89a912f3-f0a0-4896-ba06-a386407ecb15
title: Divider
domain: agenticdevelopertoolkit://recipes/divider
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A semantic horizontal line that visually separates content sections.
platforms:
- typescript
- web
tags:
- divider
- separator
- layout
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Divider

## Overview

A divider is a horizontal line element that provides visual separation between distinct sections of content. It renders as a semantic `<hr>` element on the web and MAY accept an optional CSS class for custom styling or visual variants.

## Behavioral Requirements

- **must-render-hr-element**: The component MUST render as an HTML `<hr>` element.
- **must-apply-base-class**: The component MUST apply the class `aws-divider` to the rendered element.
- **should-accept-className**: The component SHOULD accept an optional `className` prop that is appended to the base class.
- **must-filter-empty-classes**: The component MUST not render empty or null class names; class filtering MUST remove falsy values before joining.

## Appearance

- **Border**: Single horizontal line; styling inherited from `aws-divider` class and any additional className.
- **Height**: Determined by browser `<hr>` default rendering and CSS class definitions.
- **Margin**: Determined by browser `<hr>` default rendering and CSS class definitions.
- **Background**: None (line rendered via border).
- **Corner radius**: Not applicable; element is a line.
- **Shadow**: None.
- **Min/Max size**: No constraints enforced by component; sizing determined by CSS.

## States

| State | Appearance change |
|-------|------------------|
| Default | Horizontal line with styling from `aws-divider` class |

Not applicable: Divider is a static, non-interactive element with no pressed, disabled, focused, or loading states.

## Accessibility

- **Role**: Presentational separator; implicit role of `<hr>` element is separator.
- **Label requirements**: Not applicable; the `<hr>` element is a semantic separator and requires no additional label or aria-label.
- **Keyboard interaction**: Not applicable; divider is not interactive.
- **Screen reader**: The semantic `<hr>` element is recognized by assistive technologies as a separator or thematic break.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| divider-001 | must-render-hr-element | No props | Rendered element is `<hr>` |
| divider-002 | must-apply-base-class | No props | Element has class `aws-divider` |
| divider-003 | should-accept-className | `className="custom-style"` | Element has classes `aws-divider custom-style` |
| divider-004 | must-filter-empty-classes | `className={undefined}` or `className=""` | Element has only `aws-divider`, no empty values in class list |
| divider-005 | must-filter-empty-classes | `className="variant"` | Element has classes `aws-divider variant` with single space separator |

## Edge Cases

- **Null or undefined className**: Component MUST filter out falsy values; the rendered element receives only `aws-divider`.
- **Empty string className**: Component MUST filter out empty strings; the rendered element receives only `aws-divider`.
- **Multiple class names in className prop**: The string is passed as-is to the class list; whitespace and multiple tokens within the prop are preserved as provided by the caller.
- **No props provided**: Component MUST render with only the `aws-divider` class.

## Configuration

Not applicable: Divider has no configuration options beyond the optional className prop.

## Deep Linking

Not applicable: Divider is a layout component with no associated deep linking behavior.

## Localization

Not applicable: Divider is a presentational element with no user-facing text.

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | Not applicable; divider has no motion or animation. |
| Increase Contrast | Not applicable; contrast is controlled by CSS class, not the component. |
| Differentiate Without Color | Not applicable; divider is rendered as a line, not dependent on color alone. |

## Feature Flags

Not applicable: Divider has no feature flags.

## Analytics

Not applicable: Divider is a non-interactive presentational element; no user events to track.

## Privacy

Not applicable: Divider neither collects nor transmits data.

## Logging

Not applicable: Divider requires no diagnostic logging.

## Platform Notes

- **React/Web**: Render as `<hr className={cls} />` where cls combines `aws-divider` with optional additional classes. Files: `packages/web/packages/controls/src/user-settings/components/Divider.tsx`.
- **SwiftUI**: Render using native `Divider()` view, which provides a semantic dividing line. Pass through any platform-equivalent styling via `.frame(height:)` or divider modifier if custom sizing is needed.
- **Compose**: Render using `Divider()` composable, which is a horizontal line semantic separator. Apply Compose styling for custom appearance via padding and modifier chains.
- **AppKit / UIKit**: Render as `NSView` or `UIView` with `backgroundColor` set to a separator color. Set appropriate height (typically 1pt) and configure constraints to span horizontally with appropriate margins.
- **WinUI 3**: Render using `<muxc:Separator />` XAML control with `Grid.Column` spanning the content width, or manually render a `Rectangle` with `Height="1"` and `Fill="{ThemeResource DividerStrokeColorDefaultBrush}"`. Apply margin via `Margin` property for spacing.

## Design Decisions

The component is intentionally minimal: it delegates all visual styling to CSS classes and renders a semantic `<hr>` element rather than a styled `<div>`. This approach preserves accessibility (the `<hr>` element is recognized as a separator by assistive technologies) and allows flexible styling via the `aws-divider` class and additional classes provided via the `className` prop.

## Compliance

Not applicable: Divider is a simple presentational element without security, data handling, or complex interaction concerns.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
