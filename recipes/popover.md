---
id: c61a220c-b63e-4dcd-a12b-715de20f7b5d
title: Popover
domain: agenticdevelopertoolkit://recipes/popover
type: ingredient
version: 1.0.1
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A positioned overlay component that displays content relative to a trigger
  element.
platforms:
- typescript
- web
tags:
- ui
- overlay
- positioning
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Popover

## Overview

A popover is a floating overlay component that displays content positioned relative to a trigger element. It supports directional placement and optional pointer indicators. Popovers are used for contextual menus, help text, auxiliary information, and other positioned content that appears on demand.

## Behavioral Requirements

- **must-render-when-open**: The component MUST render visible when the `open` prop is `true`.
- **must-hide-when-closed**: The component MUST hide content when the `open` prop is `false` using CSS visibility and opacity rather than removing it from the DOM.
- **must-support-placement-prop**: The component MUST accept a `placement` or `side` prop to control which side of the anchor element the popover appears on (top, bottom, left, or right).
- **must-render-children**: The component MUST render all provided child content within the popover panel.
- **must-support-offset**: The component MUST accept a `sideOffset` prop to control the gap between the popover panel and the trigger element.
- **must-support-alignment**: The component MUST accept an `align` prop to control alignment of the popover along the perpendicular axis (start, center, or end).
- **must-allow-custom-styling**: The component MUST accept a `className` prop to allow custom CSS class application.
- **may-render-arrow**: The component MAY render an optional pointer indicator (controlled by `arrow` prop, default false).

## Appearance

- **Corner radius**: 8px (rounded-lg class)
- **Padding**: 1rem (16px) on all sides
- **Font**: 14px (text-sm), default weight from context
- **Background**: Surface color token (apt-surface)
- **Foreground/Text**: Text color token (apt-text)
- **Border**: 1px solid, border color token (apt-border)
- **Shadow**: Drop shadow with blur and offset (shadow-lg)
- **Min/Max size**: Maximum width 288px (w-72); constrained by available viewport width

## States

| State | Appearance change |
|-------|------------------|
| Open | Panel is visible with full opacity and visibility:visible |
| Closed | Panel has opacity:0 and visibility:hidden; content remains in DOM |
| Arrow enabled | Optional diamond pointer (8px) rendered at panel edge, rotated per placement |
| Arrow disabled | No pointer element rendered |

## Accessibility

The component wraps Base UI's Popover, which provides dialog semantics, focus management, and keyboard interaction. The wrapper inherits:

- **must-assign-dialog-role**: The popover content MUST be assigned the `dialog` role via Base UI's Popover.Popup.
- **must-trap-focus**: When open, focus MUST be trapped within the popover (Base UI Popover's focus trap behavior); focus MUST return to the trigger element when closed.
- **must-handle-escape**: The Escape key MUST close the popover (Base UI Popover's native keyboard handling).
- **must-set-aria-expanded**: The trigger element MUST have `aria-expanded="true"` when the popover is open and `aria-expanded="false"` when closed (Base UI Popover.Trigger handles this automatically).
- **should-associate-label**: The popover SHOULD be associated with a descriptive label via `aria-labelledby` or `aria-label` on the Popover.Popup for screen reader users.
- **should-announce-live-updates**: Dynamic content changes inside the popover SHOULD use `aria-live="polite"` or `aria-live="assertive"` as appropriate to announce updates to assistive technology users.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| popover-001 | must-render-when-open | `open={true}` | Popover panel is visible (opacity and visibility at full/normal) |
| popover-002 | must-hide-when-closed | `open={false}` | Popover panel is hidden (opacity:0, visibility:hidden) but markup remains in DOM |
| popover-003 | must-support-placement-prop | `placement="top"` or `side="top"` | Panel appears above the trigger element |
| popover-004 | must-support-placement-prop | `placement="bottom"` or `side="bottom"` | Panel appears below the trigger element |
| popover-005 | must-support-placement-prop | `side="left"` | Panel appears to the left of the trigger element |
| popover-006 | must-support-placement-prop | `side="right"` | Panel appears to the right of the trigger element |
| popover-007 | must-render-children | `children={<p>Content text</p>}` | Child content is rendered and visible inside the panel |
| popover-008 | must-support-offset | `sideOffset={16}` | Gap between panel edge and trigger element is 16px |
| popover-009 | must-support-alignment | `align="start"` | Popover's start edge aligns with trigger's start edge |
| popover-010 | must-support-alignment | `align="center"` | Popover center aligns with trigger center along the perpendicular axis |
| popover-011 | must-support-alignment | `align="end"` | Popover's end edge aligns with trigger's end edge |
| popover-012 | must-allow-custom-styling | `className="custom-popover-class"` | Custom class is applied to popover element alongside default classes |
| popover-013 | may-render-arrow | `arrow={true}` | Diamond pointer (8px square, rotated) appears at the edge of the panel facing the trigger |
| popover-014 | may-render-arrow | `arrow={false}` (default) | No pointer element is rendered |
| popover-015 | must-assign-dialog-role | Popover rendered via `PopoverContent` | Inspect DOM; Popover.Popup element has `role="dialog"` |
| popover-016 | must-trap-focus | Popover open, Tab within popover | Focus cycles within popover content and trigger |
| popover-017 | must-trap-focus | Popover open, press Tab to exit last focusable element | Focus returns to trigger element |
| popover-018 | must-handle-escape | Popover open, press Escape | Popover closes; `open` prop becomes `false` |
| popover-019 | must-set-aria-expanded | Popover open | Trigger element has `aria-expanded="true"` |
| popover-020 | must-set-aria-expanded | Popover closed | Trigger element has `aria-expanded="false"` |

## Edge Cases

- **Content larger than max-width**: If popover content exceeds 288px width, text MUST wrap and content MUST be scrollable rather than overflow the layout.
- **Placement adjustment**: If the requested placement would render the popover outside the viewport, the positioning library (base-ui) MAY auto-adjust placement or alignment to keep the popover visible.
- **Empty children**: If no children are provided, the popover MUST render as an empty panel; no fallback content is added.
- **Rapid visibility toggles**: If `open` prop toggles rapidly, the popover MUST remain stable without layout thrashing; CSS transitions apply smoothly.
- **Arrow orientation per placement**: When `arrow={true}`, the arrow MUST be rotated per the active placement: 45deg for top, 225deg for bottom, 315deg for left, 135deg for right.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `open` | boolean | — | Controls visibility; true renders visible, false hidden (but in DOM) |
| `placement` / `side` | 'top' \| 'bottom' \| 'left' \| 'right' | 'bottom' | Which side of the trigger the popover appears on |
| `sideOffset` | number | 8 | Gap in pixels between popover panel and trigger element |
| `align` | 'start' \| 'center' \| 'end' | 'center' | Alignment along the axis perpendicular to placement |
| `arrow` | boolean | false | Whether to render the optional pointer indicator |
| `className` | string | — | Custom CSS class for styling (concatenated with default classes) |
| `children` | ReactNode | — | Content to display inside the popover panel |

## Deep Linking

Not applicable: Popovers are transient, context-dependent UI elements without independent navigation identity; they cannot be deep-linked.

## Localization

Not applicable: The component renders only the child content provided by the parent; it does not define any locale-specific strings.

## Accessibility Options

- **Reduce Motion**: When enabled at the system level, transitions and animations on the popover (if any) SHOULD be disabled or shortened to instant.
- **Increase Contrast**: Border and background colors SHOULD adapt to provide WCAG AA contrast ratios (4.5:1 for text, 3:1 for non-text elements) when high-contrast mode is active.
- **Differentiate Without Color**: If the arrow is the sole visual indicator of placement direction, SHOULD be paired with text labels or semantic markers.

## Feature Flags

Not applicable: No feature flags are defined in the source implementation.

## Analytics

Not applicable: This is a presentational component; event tracking is the responsibility of parent components or trigger elements.

## Privacy

Not applicable: The component does not collect, store, or transmit user data.

## Logging

Not applicable: No logging behavior is specified in the source implementation.

## Platform Notes

- **React/Web (full-featured)** (source: `packages/web/packages/ui/src/components/popover.tsx`): Built on `@base-ui/react/popover`. Export `Popover` (wraps `Popover.Root`), `PopoverTrigger` (wraps `Trigger`), and `PopoverContent` (wraps `Popup` + `Positioner` + `Portal`). Styling uses Tailwind classes and `apt-*` design tokens (apt-surface, apt-border, apt-text). Arrow is a conditionally rendered rotated square with CSS `data-[side=...]` attribute selectors to control rotation per placement (45deg, 225deg, 315deg, 135deg). Supports all four sides; default placement is bottom.
- **React/Web (lightweight variant)** (source: `packages/web/packages/popover/src/Popover.tsx`): Simpler hover-only popover using CSS class composition. Supports top/bottom placement only. Always rendered in DOM, hidden via `opacity` and `visibility` CSS. Mouse event handlers pass through from children to parent. Useful for inline hover popovers without positioning library overhead.
- **SwiftUI**: Use `ToolTip` modifier or compose with `ZStack` for manual positioning. Position relative to the source view's `CGRect` frame. Arrow indicator drawn via rotated `Rectangle` or custom `Shape` rotated per placement angle.
- **Compose**: Build with `Material3 Tooltip` or custom `Popup` overlay. Position via `Modifier.offset()` and `Modifier.align()` relative to the anchor. Arrow drawn with Canvas or custom `Composable` shape.
- **AppKit / UIKit**: Use `NSPopover` (AppKit, supports automatic positioning) or custom `UIViewController`/SwiftUI overlay. Manage visibility via `.isShown` (AppKit) or `.alpha`/`isHidden` (UIKit). Arrow drawn via Core Graphics or custom view layer.
- **WinUI 3**: Use `Flyout` or `MenuFlyout` control with `Placement` property (Top, Bottom, Left, Right, Full). Styling via `ControlTemplate` overrides; arrow rendered as a custom element in the template styled with `Brush` and rotated via `RenderTransform` with `RotateTransform`. Offset controlled via margin on the Flyout's inner content.

## Design Decisions

1. **Persistent DOM presence**: The component remains in the DOM when closed (hidden via CSS) rather than unmounting. This ensures server-rendered HTML includes the full page structure accessible to non-JavaScript clients and screen readers, and allows CSS animations to work smoothly.

2. **Arrow is opt-in**: The arrow indicator defaults to `arrow={false}` to maintain backward compatibility with existing consumers who were built before the arrow feature was added and do not expect it.

3. **Portal rendering**: On web, PopoverContent renders in a React Portal to escape stacking context and ensure correct z-index layering above other page content without relying on parent CSS properties.

4. **Token-based styling**: Appearance is defined using `apt-*` design tokens (apt-surface, apt-border, apt-text) rather than hard-coded color values, allowing theming via token override without duplicating CSS rules.

5. **Default placement bottom, offset 8px**: The choice of "bottom" as default placement and 8px gap is conventional for popover components and provides adequate visual separation from the trigger without excessive vertical displacement.

6. **Accessibility delegation to Base UI**: The component explicitly relies on Base UI Popover's accessibility implementation rather than re-implementing focus management, keyboard handling, and ARIA roles. This ensures consistency with Base UI's tested and maintained standards.

## Compliance

Not applicable: No compliance checks are defined in the source implementation.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.1 | 2026-09-22 | Claude Haiku 4.5 | Revise Accessibility section: state Base UI delegation as requirements (dialog role, focus trap, Escape handling, aria-expanded); add test vectors for accessibility features; drop review marker |
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation |
