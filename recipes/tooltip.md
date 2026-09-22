---
id: a17a8253-0be8-4646-a76a-6941b1af3528
title: Tooltip
domain: agenticdevelopercookbook://ingredients/tooltip
type: ingredient
version: 1.0.1
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Contextual label that appears on hover or focus, positioned relative to its
  trigger element with configurable placement and optional pointer.
platforms:
- web
tags:
- ui
- primitives
- tooltips
depends-on: []
related: []
references:
- https://base-ui.io/react/components/tooltip/
---

# Tooltip

## Overview

A tooltip is a non-interactive label that displays supplementary information when a user hovers over or focuses on a trigger element. The component wraps Base UI's tooltip primitive, providing consistent styling, positioning, and behavior across the application. It is used to provide brief, contextual help text without cluttering the primary interface. Use a tooltip when you need to explain an icon, clarify a button's action, or provide additional context that is not critical to understanding the interface.

## Behavioral Requirements

- **must-render-on-hover**: The tooltip MUST display when the user hovers over the trigger element.
- **must-render-on-focus**: The tooltip MUST display when the trigger element receives keyboard focus.
- **must-respect-provider-delay**: The tooltip MUST respect the `delay` property set on the `TooltipProvider`, which controls the number of milliseconds before the tooltip opens (default 200ms).
- **must-use-portal**: The tooltip content MUST render in a React Portal to avoid CSS stacking context conflicts with ancestor elements.
- **must-position-relative-to-trigger**: The tooltip MUST position relative to the trigger element using a Positioner component that supports `side` (top, bottom, left, right), `sideOffset`, and `align` (start, center, end) properties.
- **must-support-custom-className**: The tooltip content wrapper MUST accept a `className` prop to allow consumers to extend or override default styling.
- **should-show-arrow**: The tooltip SHOULD display an optional pointer (arrow) by default; it MAY be disabled by setting the `arrow` prop to `false`.
- **must-render-children-in-content**: The tooltip content MUST render the provided `children` prop as the label text.

## Appearance

- **Corner radius**: 6px (rounded-md)
- **Padding**: vertical 6px × horizontal 10px (py-1.5 px-2.5)
- **Font**: weight 400, size 12px (text-xs)
- **Background**: `apt-surface-2` token (secondary surface color)
- **Foreground/Text**: `apt-text` token (primary text color)
- **Border**: 1px solid, `apt-border` token
- **Shadow**: Medium drop shadow (shadow-md)
- **Arrow**: 8px × 8px diamond (size-2), rotated 45deg, 1px border on right and bottom edges, inherits background and border from content, positioned to touch the edge of the trigger element
- **Max width**: 320px (max-w-xs)
- **Z-index**: 50 (z-50)

## States

| State | Appearance change |
|-------|------------------|
| Default | Not visible; hidden off-screen |
| Visible | Rendered with full styling, positioned adjacent to trigger |
| Arrow visible | Diamond pointer visible (default state when arrow=true) |
| Arrow hidden | No pointer element rendered (when arrow=false) |

## Accessibility

- **Role**: `tooltip` (inherited from Base UI primitive via `role="tooltip"`)
- **Label requirements**: The trigger element SHOULD have an associated label or accessible name that describes its purpose; the tooltip content provides supplementary information only, not the primary label.
- **Keyboard support**: The tooltip MUST display when the trigger element receives focus via keyboard navigation.
- **Announce on open**: The wrapper inherits Base UI Tooltip's `role="tooltip"` and `aria-describedby` wiring. Screen readers announce the tooltip content as the description of the trigger element when the relationship is established via `aria-describedby`.
- **Minimum touch target**: The trigger element MUST have a minimum touch target of at least 44×44pt (per platform guidelines); the tooltip itself is non-interactive and does not require its own target.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|----|-------|----------|
| tooltip-001 | must-render-on-hover | User hovers over a trigger element within a `TooltipProvider` | Tooltip content displays after the provider's configured delay (default 200ms) |
| tooltip-002 | must-render-on-focus | User presses Tab to focus a trigger element | Tooltip content displays after the provider's configured delay |
| tooltip-003 | must-respect-provider-delay | `TooltipProvider` with `delay={500}` wraps a trigger | Tooltip does not appear until 500ms after hover begins |
| tooltip-004 | must-use-portal | A tooltip is rendered within a nested container with `overflow: hidden` | Tooltip content is not clipped and renders outside the container's bounds |
| tooltip-005 | must-position-relative-to-trigger | `TooltipContent` with `side="bottom"` and `sideOffset={8}` | Tooltip appears below the trigger, 8px from its bottom edge |
| tooltip-006 | must-position-relative-to-trigger | `TooltipContent` with `align="start"` | Tooltip left edge aligns with trigger's left edge |
| tooltip-007 | must-support-custom-className | `TooltipContent` with `className="custom-bg"` where custom-bg sets background to red | Content renders with red background instead of default `apt-surface-2` |
| tooltip-008 | should-show-arrow | `TooltipContent` with default props (no `arrow` prop) | Diamond pointer is rendered adjacent to the content |
| tooltip-009 | should-show-arrow | `TooltipContent` with `arrow={false}` | No pointer element is rendered |
| tooltip-010 | must-render-children-in-content | `TooltipContent` with `children="Help text"` | The text "Help text" appears inside the tooltip |

## Edge Cases

- **Empty content**: If `children` is an empty string or falsy, the tooltip still renders and positions normally with no visible text content. Behavior is MUST.
- **Very long text**: Text longer than `max-w-xs` (320px) will wrap to multiple lines and the tooltip will grow vertically. Behavior is MUST.
- **Rapid hover on multiple triggers**: If a user quickly moves between trigger elements within the same `TooltipProvider`, only one tooltip is open at a time; the delay timer resets. Behavior is MUST (inherited from Base UI).
- **Positioning near viewport edge**: If `side="bottom"` and the trigger is near the bottom viewport edge, Base UI's Positioner will adjust the side automatically to fit in the viewport. Behavior is MUST.
- **Arrow rotation on different sides**: When `side="bottom"`, the arrow rotates 225deg instead of 45deg to point upward. When `side="left"` or `side="right"`, positioning is adjusted accordingly. Behavior is MUST.
- **Disabled trigger**: If the trigger element becomes disabled after the tooltip opens, the tooltip should dismiss. This behavior is not explicitly controlled by the Tooltip component; it depends on whether the trigger's `onMouseEnter`/`onFocus` events fire. Behavior is SHOULD.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| delay | number | 200 | Milliseconds before the tooltip opens after the user hovers or focuses the trigger (set on `TooltipProvider`) |
| side | "top" \| "bottom" \| "left" \| "right" | "top" | Which side of the trigger the tooltip appears on |
| sideOffset | number | 6 | Distance in pixels from the trigger to the tooltip |
| align | "start" \| "center" \| "end" | "center" | Horizontal/vertical alignment of the tooltip relative to the trigger |
| arrow | boolean | true | Whether to display the pointer diamond |
| className | string | undefined | Additional CSS class(es) to apply to the content wrapper |
| children | ReactNode | required | The text or content to display in the tooltip |

## Deep Linking

Not applicable: Tooltip is a non-interactive UI component overlay; it does not correspond to navigable app states or deep-linkable destinations.

## Localization

Not applicable: The Tooltip component does not render any static text strings; all content comes from the `children` prop, which the consuming application provides.

## Accessibility Options

Not applicable: The component does not implement platform-specific accessibility display options (Reduce Motion, Increase Contrast, Differentiate Without Color). These concerns SHOULD be addressed at the application level by conditionally disabling tooltips or adjusting the provider's delay based on user preferences.

## Feature Flags

Not applicable: No feature flags are present in the source code; the component is always enabled.

## Analytics

Not applicable: The component does not emit any analytics events; event tracking is the responsibility of the consuming application.

## Privacy

Not applicable: The component does not collect, store, or transmit any user data.

## Logging

Not applicable: The component does not emit any structured logs; debugging relies on React DevTools and browser console.

## Platform Notes

- **React/Web**: Base UI tooltip primitive from `@base-ui/react/tooltip` (`tooltip.tsx`, lines 919–980). Supports all Positioner properties (side, sideOffset, align) and Portal rendering. Arrow is a custom 2px rotated square with conditional CSS transforms for different sides.
- **SwiftUI**: Implement using `Menu` with a custom label and secondary/tertiary content, or create a custom overlay using `ZStack` with `offset()` modifiers to position relative to the trigger. No native tooltip equivalent exists; position management is manual.
- **Compose**: Use a `Tooltip` from Material Design 3 (androidx.compose.material3.Tooltip) or create a custom composable with `Popup` and `DropdownPosition` to manage placement relative to an anchor element.
- **AppKit / UIKit**: Use `NSPopover` (macOS) with a custom positioning logic to place near the hovered/focused control, or `UIPopoverController` (iOS, deprecated) with an anchorRect. Custom overlay views may be necessary to replicate positioning and arrow behavior.
- **WinUI 3**: Use `TeachingTip` (Windows 10+) with `PreferredPlacement` property to control side positioning (Top, Bottom, Left, Right). Set `IsLightDismissEnabled="true"` to close on focus loss. `Icon` property can display an optional visual indicator. Target property pins the tip to a control. Styling is controlled via `CornerRadius`, `Background`, `Foreground`, `BorderBrush` properties.

## Design Decisions

- **Default delay of 200ms**: Base UI default; this timing prevents tooltip flicker on quick mouse passes while remaining responsive to intentional hovers. The delay is configurable per provider, allowing different contexts to trade responsiveness for noise reduction.
- **Arrow as optional**: Tooltips on left/right sides can have arrows that visually overlap text content, reducing readability. The `arrow` prop allows consumers to disable the arrow for those cases while keeping it enabled for top/bottom (the common case).
- **Portal rendering**: Ensures tooltips are not clipped by `overflow: hidden` ancestors and always render on top of sibling content via z-index.
- **Z-index 50**: Chosen to float above typical content (z-10 to z-40) but below modals or critical overlays (z-50 is Tailwind's convention for floating UI elements).

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| [wcag-touch-target-size](agenticdevelopercookbook://compliance/accessibility#wcag-touch-target-size) | N/A | Accessibility |
| [wcag-color-contrast](agenticdevelopercookbook://compliance/accessibility#wcag-color-contrast) | Requires review | Accessibility |
| [wcag-keyboard-navigation](agenticdevelopercookbook://compliance/accessibility#wcag-keyboard-navigation) | Passed | Accessibility |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.1 | 2026-09-22 | Claude Haiku 4.5 | Remove review marker from Accessibility section; state that wrapper inherits Base UI Tooltip's role and aria-describedby wiring for screen reader announcement |
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation from Base UI tooltip source |
