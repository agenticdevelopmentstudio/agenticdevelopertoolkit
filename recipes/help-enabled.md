---
id: fcb8a0a4-2446-46f9-99bb-49b0317529d4
title: HelpEnabled
domain: agenticdevelopertoolkit://recipes/help-enabled
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Interactive text wrapper that reveals contextual help via a popover on hover
  or focus.
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

# HelpEnabled

## Overview

HelpEnabled wraps text or labels to make them interactive help triggers. When a user hovers over or focuses the element, it reveals a small information badge and opens a popover displaying help content. This component is designed for inline help on headlines, labels, and other text regions where additional context is valuable without blocking the primary content.

## Behavioral Requirements

- **must-render-children**: Component MUST render the provided `children` prop as the primary text content.
- **must-render-badge**: Component MUST render an Info icon badge adjacent to the children.
- **must-accept-id-prop**: Component MUST accept an `id` prop (string) to look up help content in the help store.
- **must-open-popover-on-trigger**: Component MUST open a Popover containing help content when the trigger element is clicked or activated.
- **must-show-popover-content**: Component MUST render a HelpPopoverContent component with the retrieved help entry inside the Popover.
- **must-accept-fallback**: Component MUST accept an optional `fallback` prop (string) to display when no help entry exists for the given `id`.
- **must-accept-classname**: Component MUST accept an optional `className` prop and apply it to the root element.
- **must-render-plain-text-fallback**: When no help entry exists for the `id` and no `fallback` is provided, component MUST render the children as plain text in a span element without opening a popover.
- **must-mark-plain-text-variant**: Component MUST apply `data-slot="help-enabled-plain"` to the span when rendering the plain text fallback variant.
- **must-preserve-layout-on-missing-entry**: Component MUST preserve the `className` prop on the plain text fallback to maintain layout and styling applied by the caller.
- **must-warn-on-missing-entry**: Component MUST emit a console warning once per missing help `id` (throttled by `id`, not per render) indicating the missing help entry.
- **must-mark-interactive-variant**: Component MUST apply `data-slot="help-enabled"` to the PopoverTrigger element when rendering the interactive variant.
- **must-hide-badge-by-default**: Component MUST render the Info badge with `opacity-0` by default so it does not reflow the layout.
- **must-show-badge-on-hover**: Component MUST transition the badge to `opacity-70` when the user hovers over the trigger element.
- **must-show-badge-on-focus**: Component MUST transition the badge to `opacity-70` when the trigger element receives keyboard focus.
- **must-show-badge-when-popover-open**: Component MUST transition the badge to `opacity-70` when the popover is open.
- **must-mark-badge-aria-hidden**: Component MUST apply `aria-hidden="true"` to the Info badge icon.

## Appearance

- **Layout**: Inline flex container with horizontal gap, items vertically centered.
- **Gap**: 1 unit (0.25rem) between children and badge.
- **Padding**: Horizontal 0.25rem, vertical 0 (internal spacing for focus ring).
- **Badge size**: 12×12 pixels (size-3 in Tailwind; equivalent to 0.75rem).
- **Badge shrink**: Badge does not grow or shrink beyond its natural size.
- **Corner radius**: Small rounded corners (rounded-sm; 0.125rem).
- **Background color (default)**: Transparent.
- **Background color (hover/focus)**: `apt-surface-2`.
- **Border**: None.
- **Focus ring**: 2px ring in `apt-gold/40` (gold at 40% opacity) around the trigger element.
- **Focus ring outline**: None (outline set to outline-none to avoid double focus indicators).
- **Badge opacity (default)**: 0 (fully transparent).
- **Badge opacity (hover/focus/open)**: 0.7 (70% opaque).
- **Transitions**: Colors and opacity transition smoothly.

## States

| State | Appearance change |
|-------|------------------|
| Default | Badge opacity 0; no background color |
| Hover | Background changes to `apt-surface-2`; badge opacity transitions to 0.7 |
| Keyboard Focus | Background changes to `apt-surface-2`; badge opacity transitions to 0.7; focus ring appears (`ring-apt-gold/40`) |
| Popover Open | Badge opacity transitions to 0.7 (via `group-data-[popup-open]` selector) |
| No Help Entry (Plain Text) | Renders as plain span; no background, no badge, no focus ring styling |

## Accessibility

- **Role**: The interactive variant (with help entry) acts as a button that opens a popover. The component does not explicitly set role; it relies on Popover and PopoverTrigger to establish the correct semantics.
- **Label**: The trigger element contains the children text as its accessible label.
- **Badge accessibility**: The Info icon badge is marked `aria-hidden="true"` as it is a visual affordance that duplicates the interactive nature of the parent element.
- **Focus**: The trigger element is focusable via keyboard (Tab key) and displays a visible focus indicator (gold ring).
- **Popover context**: The help content is announced by the popover's own accessibility attributes (out of scope for this component).
- **Plain text variant**: When rendered as plain text (no help entry, no fallback), the element is not interactive and does not receive focus.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| help-enabled-001 | must-render-children | `<HelpEnabled id="test-id">Help Text</HelpEnabled>` with valid help entry | "Help Text" appears in the document |
| help-enabled-002 | must-render-badge | `<HelpEnabled id="test-id">Help Text</HelpEnabled>` with valid help entry | Info icon badge is rendered next to the text with `data-slot="help-enabled-badge"` |
| help-enabled-003 | must-accept-id-prop | `<HelpEnabled id="unique-id">Text</HelpEnabled>` | Component calls `useHelpEntry` with `id="unique-id"` to retrieve help content |
| help-enabled-004 | must-open-popover-on-trigger | User clicks the trigger element | Popover opens and displays help content |
| help-enabled-005 | must-show-popover-content | `<HelpEnabled id="test-id">Text</HelpEnabled>` with valid entry `{ body: "Help", flavor: "info" }` | HelpPopoverContent is rendered inside the Popover with the entry |
| help-enabled-006 | must-accept-fallback | `<HelpEnabled id="no-entry" fallback="Fallback help">Text</HelpEnabled>` with no stored entry | Popover opens with fallback text in an `info` flavor entry |
| help-enabled-007 | must-accept-classname | `<HelpEnabled id="test-id" className="custom-class">Text</HelpEnabled>` with valid entry | `custom-class` is applied to the PopoverTrigger root element |
| help-enabled-008 | must-render-plain-text-fallback | `<HelpEnabled id="no-entry">Text</HelpEnabled>` with no stored entry and no fallback | Renders as plain text in a span; no popover opens |
| help-enabled-009 | must-mark-plain-text-variant | `<HelpEnabled id="no-entry">Text</HelpEnabled>` with no stored entry and no fallback | span element has `data-slot="help-enabled-plain"` attribute |
| help-enabled-010 | must-preserve-layout-on-missing-entry | `<HelpEnabled id="no-entry" className="layout-class">Text</HelpEnabled>` with no entry and no fallback | `layout-class` is preserved on the plain text span |
| help-enabled-011 | must-warn-on-missing-entry | First render of `<HelpEnabled id="unknown">Text</HelpEnabled>` with no entry and no fallback | Console outputs warning: `[HelpEnabled] no help entry for id "unknown" — rendering plain text` |
| help-enabled-012 | must-warn-on-missing-entry | Second render of `<HelpEnabled id="unknown">Text</HelpEnabled>` in same session | No additional console warning (warning throttled by id) |
| help-enabled-013 | must-mark-interactive-variant | `<HelpEnabled id="test-id">Text</HelpEnabled>` with valid entry | PopoverTrigger root has `data-slot="help-enabled"` attribute |
| help-enabled-014 | must-hide-badge-by-default | Component renders with valid entry | Info badge has `opacity-0` class in default state |
| help-enabled-015 | must-show-badge-on-hover | User hovers over trigger element | Badge transitions to `opacity-70` via `group-hover:opacity-70` |
| help-enabled-016 | must-show-badge-on-focus | User tabs to trigger element with keyboard | Badge transitions to `opacity-70` via `group-focus-visible:opacity-70` |
| help-enabled-017 | must-show-badge-on-popover-open | Popover is open | Badge has `opacity-70` via `group-data-[popup-open]:opacity-70` |
| help-enabled-018 | must-mark-badge-aria-hidden | Component renders badge | Info icon has `aria-hidden="true"` |

## Edge Cases

- **Missing help entry, no fallback**: Renders plain text span. Caller's layout styles are preserved so the UI does not reflow. Console warning is emitted once.
- **Missing help entry, with fallback**: Popover opens with fallback text in an `info` flavor entry. No console warning is emitted because a fallback is provided.
- **Empty children prop**: Component will render an empty inline flex container with only the badge visible. This is allowed; the component does not validate input.
- **Very long children text**: Component does not limit text length. Layout depends on caller-provided `className` and page context.
- **Popover open, element removed from DOM**: Popover state is managed by the Popover component; behavior follows Popover's unmount logic.
- **Multiple renders with same `id` and no entry**: Warning is throttled by id; only one warning emitted per session even if component mounts/unmounts multiple times.
- **`fallback` prop without `id`**: Component will use the `id` to look up help first; if not found, fallback is used regardless of `id` value.

## Configuration

Not applicable: HelpEnabled accepts configuration via props (`id`, `children`, `className`, `fallback`), not via separate configuration objects or settings.

## Deep Linking

Not applicable: HelpEnabled is not a navigable destination and does not define URL patterns.

## Localization

Not applicable: HelpEnabled does not render hardcoded strings. Help content is retrieved via `useHelpEntry(id)` and managed by the help store. Fallback text is supplied by the caller as a string prop.

## Accessibility Options

- **Reduce Motion**: When "Reduce Motion" is enabled, badge opacity and background transitions SHOULD respect the user's preference (handled by Tailwind's `transition-*` classes and system settings). The component does not explicitly disable transitions; this is delegated to the CSS framework and browser.
- **Increase Contrast**: Badge color at `opacity-70` may not meet WCAG AA contrast on all backgrounds. This is a Design Decision for the design system to address via color tokens (`apt-surface-2`, `apt-gold/40`).
- **Differentiate Without Color**: Badge is an icon shape (Info symbol), not solely color-based. Badge opacity changes on focus satisfy this requirement.

## Feature Flags

Not applicable: HelpEnabled does not define feature flags. Help content retrieval is controlled by the help store (out of scope for this component).

## Analytics

Not applicable: HelpEnabled does not emit analytics events. Event tracking for help interactions is delegated to the Popover or HelpPopoverContent components.

## Privacy

Not applicable: HelpEnabled does not collect or transmit user data. The `id` prop is a lookup key for the help store and does not expose personal information.

## Logging

Not applicable: HelpEnabled emits a console warning for missing help entries (as documented in Behavioral Requirements), but does not use structured logging or subsystem/category tags.

## Platform Notes

- **React/Web**: HelpEnabled is a React functional component exported from `packages/web/packages/ui/src/components/help-enabled.tsx`. It uses Tailwind CSS for styling, the `lucide-react` library for the Info icon, and internal Popover and HelpPopoverContent components. The component is marked with the `"use client"` directive for server-side rendering compatibility.
- **SwiftUI**: Start with a standard button or disclosure group. SwiftUI does not have a direct Popover API equivalent; use a Modifier or conditional overlay. Replicate the hover/focus badge reveal using opacity animations. Use `AccessibilityElement` to mark the badge as hidden from screen readers.
- **Compose**: Build with a `Box` or `Surface` composable wrapping the text. Use `Modifier.clickable()` to enable the trigger. Implement badge visibility changes via `animateFloatAsState` for opacity. Use `Modifier.semantics { contentDescription = null }` on the icon to hide it from accessibility readers.
- **AppKit / UIKit**: Use a custom NSButton or UIButton subclass. Overlay the Info badge as a small CALayer or UIImageView. Implement hover detection via `NSTrackingArea` (AppKit) or `UIGestureRecognizer` (UIKit). Use `UIAccessibility.isVoiceOverRunning` to conditionally adjust badge visibility.
- **WinUI 3**: Use a `Grid` or `StackPanel` (horizontal orientation) as the root, hosting a `TextBlock` for the children and a `Glyph` or `FontIcon` (from Segoe MDL2 Assets) for the badge. Wrap in a `Button` to make it interactive. Bind badge opacity to a VisualState (default, hover, focus) using `VisualStateManager`. The button's `Click` event opens a `Flyout` (WinUI's equivalent to a popover). Use the `AutomationProperties.HelpText` attached property on the button, and set `AutomationProperties.AccessibilityView` to `Raw` on the icon to hide it from automation readers.

## Design Decisions

- **Horizontal inline layout with gap**: The component uses `inline-flex items-center gap-1` to position the badge adjacent to the text without adding extra line height or block layout. This keeps the help affordance compact and preserves the caller's line metrics.
- **Badge transparency by default**: The Info badge is rendered but fully transparent (`opacity-0`) so that its presence does not reflow the layout when invisible. Revealing it on hover/focus is a smooth transition without layout shift.
- **Warning throttling by id, not per-render**: Missing help entries emit a warning once per unique `id` per session (not per render), because the component may be rendered multiple times on the same page. Per-render warnings would produce console noise without additional value.
- **Fallback as HelpEntry, not plain text**: When a fallback string is provided, it is wrapped in a HelpEntry object with flavor `"info"` so that it flows through the same rendering pipeline as stored entries. This keeps the implementation simple and consistent.
- **Preserve className on plain text variant**: When help is not available and no fallback is provided, the component preserves the caller's `className` on the plain text span. This ensures that caller-specific layout styles (e.g., centering, ellipsis clipping) are not lost due to the missing help entry.
- **data-slot attributes for variant detection**: The component applies `data-slot="help-enabled"` and `data-slot="help-enabled-plain"` to distinguish interactive and plain text variants in CSS and for testing. This avoids requiring pseudo-class selectors or attribute mutations to detect state.
- **Focus ring uses gold token**: The focus indicator uses `ring-apt-gold/40` (gold at 40% opacity) for consistency with other interactive controls in the design system (quietControlClass pattern). This token is shared with chevrons, split dividers, dialog close buttons, and collapse toggles.

## Compliance

Not applicable: Compliance checks are managed at the design system level. HelpEnabled delegates accessibility and compliance validation to the Popover component, the help store, and the design system's color tokens.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
