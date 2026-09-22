---
id: 8f2e4a12-7c3b-4d9f-a1e2-6b5f9c1d3e4a
title: "Toast"
domain: agenticdevelopercookbook://ingredients/toast
type: ingredient
version: 1.0.1
status: review
language: en
created: 2026-09-22
modified: 2026-09-22
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: "Transient notification displayed in a fixed viewport at the bottom-right corner with optional dismiss button."
platforms:
- typescript
- web
tags:
  - notification
  - toast
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Toast

## Overview

A toast is a transient, non-modal notification displayed in a fixed viewport at the bottom-right of the viewport. It conveys brief messages with optional title and description text, and allows the user to dismiss it via a close button. Toasts are enqueued and rendered as a stacked list.

## Behavioral Requirements

- **must-render-title**: Toast MUST render a title element when provided.
- **must-render-description**: Toast MUST render a description element when provided.
- **must-render-close-button**: Toast MUST render a clickable close button.
- **must-dismiss-on-close**: Toast MUST dismiss and remove itself from the viewport when the close button is clicked.
- **must-enqueue-toasts**: The `useToast()` hook MUST accept objects with `title` and `description` properties and enqueue them for display.
- **must-position-viewport-bottom-right**: The toast viewport MUST be positioned at the bottom-right corner of the viewport (4rem from right edge, 4rem from bottom edge).
- **must-manage-z-index**: The toast viewport MUST render at z-index 50 (above typical page content).
- **must-animate-entrance**: Toasts MUST fade in smoothly (opacity transition from 0 to 1) on entrance.
- **must-animate-exit**: Toasts MUST fade out smoothly (opacity transition to 0) on exit.
- **must-stack-toasts**: Multiple toasts MUST render in a vertical stack with 0.5rem gap between each.
- **must-constrain-width**: Each toast MUST have a maximum width of 320px (w-80), and MUST respond responsively to viewport constraints (max-width: calc(100vw - 2rem)).

## Appearance

- **Corner radius**: 0.5rem (rounded-lg)
- **Padding**: 1rem vertical × 1rem horizontal (p-4), with right padding of 2.25rem (pr-9) to accommodate close button
- **Font (title)**: weight 500 (font-medium), size 0.875rem (text-sm)
- **Font (description)**: size 0.875rem (text-sm)
- **Background**: design token `apt-surface-2`
- **Foreground/Text**: design token `apt-text` for title and primary text; `apt-text-muted` for description
- **Border**: 1px solid, color `apt-border`
- **Shadow**: drop shadow with lg blur (shadow-lg)
- **Gap between title and description**: 0.25rem (gap-1)
- **Close button**: 1rem icon (size-4), positioned absolute top-3 right-3, color `apt-text-muted` at rest, color `apt-text` on hover

## States

| State | Appearance change |
|-------|------------------|
| Default | Fully opaque (opacity 1), border and background visible, title and description rendered |
| Hovered (close button) | Close button text color transitions to `apt-text` |
| Focused (close button) | Close button displays focus ring: 2px ring at `apt-gold/40` opacity |
| Entering | Opacity animates from 0 to 1 (via `data-starting-style:opacity-0`) |
| Exiting | Opacity animates to 0 (via `data-ending-style:opacity-0`) |

## Accessibility

- **Role**: Implicit alertdialog or status region (delegated to `ToastPrimitive.Root` from Base UI)
- **Close button label**: The close button MUST have `aria-label="Close"`, a hard-coded English string in the source code.
- **Focus management**: Close button MUST be keyboard-focusable and dismissible via Enter key
- **Minimum tap target**: Close button icon area MUST meet 44×44pt minimum touch target (achieved via padding and button sizing)
- **Announcement**: Toast entry and exit is announced via ARIA live region semantics provided by Base UI Toast primitive

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| toast-001 | must-render-title | `useToast().add({ title: "Success" })` | Toast renders containing "Success" in title element |
| toast-002 | must-render-description | `useToast().add({ description: "Operation complete" })` | Toast renders containing "Operation complete" in description element |
| toast-003 | must-render-close-button | Toast rendered in viewport | Close button with X icon is visible and clickable |
| toast-004 | must-dismiss-on-close | User clicks close button | Toast animates out and is removed from viewport |
| toast-005 | must-enqueue-toasts | `useToast().add({ title: "Alert" })` called inside ToastProvider subtree | Toast appears in viewport |
| toast-006 | must-position-viewport-bottom-right | Viewport rendered in page | Viewport is positioned 1rem from right edge and 1rem from bottom edge of window |
| toast-007 | must-manage-z-index | Toast viewport and multiple page layers present | Toast viewport appears above other content at z-index 50 |
| toast-008 | must-animate-entrance | Toast added to queue | Toast element opacity transitions from 0 to 1 over transition duration |
| toast-009 | must-animate-exit | Close button clicked or toast auto-dismissed | Toast element opacity transitions to 0 over transition duration |
| toast-010 | must-stack-toasts | Multiple toasts enqueued | Each toast renders below previous with 0.5rem (gap-2) vertical spacing |
| toast-011 | must-constrain-width | Toast rendered at viewport width 1024px | Toast displays at maximum 320px width |
| toast-012 | must-constrain-width | Toast rendered at viewport width 320px | Toast displays at width calc(100vw - 2rem) (32px margins total) |

## Edge Cases

- **Empty title and description**: Toast renders with no title or description content; only close button visible. MUST not error.
- **Very long title text**: Title text MUST wrap to multiple lines and remain readable; no text truncation or overflow.
- **Very long description text**: Description text MUST wrap to multiple lines; container height expands to fit content.
- **Close button rapid clicks**: Rapid clicks on close button MUST dismiss toast once (no double-dismiss error); subsequent clicks on dismissed toast MUST have no effect.
- **Viewport overflow (many toasts)**: The viewport is a fixed flex container with `flex-col` layout and `gap-2` vertical spacing, with no overflow scrolling defined in the source. Toasts extending beyond the viewport height are not clipped; they stack outside the visible area.
- **Viewport near right or bottom edge**: When rendered near right or bottom edges, toast MUST respect max-width and not overflow window; responsive max-width constraint ensures this.
- **Multiple providers in same app**: Each ToastProvider instance MUST manage its own toast queue independently.

## Configuration

Not applicable: Toast is rendered via the `Toaster` component with fixed viewport position and dimensions. Consumers configure content via `useToast().add({ title, description })` but not the component's layout or styling.

## Deep Linking

Not applicable: Toast is a transient, non-navigable UI element with no persistent state or deep-link target.

## Localization

- **Close button aria-label**: The aria-label is hard-coded to the English string "Close" in the source code. Localization string extraction and translation are not implemented in the source.

## Accessibility Options

- **Reduce Motion**: The source uses CSS `transition-all` on the toast root and `transition-colors` on the close button. The source does not read or respond to the `prefers-reduced-motion` media query; transitions are always applied.
- **Increase Contrast**: Close button colors MUST use the design tokens `apt-text-muted` (rest state), `apt-text` (hover), and focus ring MUST use `apt-gold/40` opacity. NEEDS REVIEW: Whether these tokens meet WCAG AA contrast requirements not confirmed in source; color token values and current theme settings would need to be reviewed to verify minimum 4.5:1 contrast ratio for text and 3:1 for graphics.
- **Differentiate Without Color**: The close button focus indication relies on color change (apt-text-muted to apt-text) and a colored focus ring (apt-gold/40). No non-color visual indicator such as a border, outline, or text styling change is present in the source.

## Feature Flags

Not applicable: Toast component has no feature flags; it is always enabled when `Toaster` is rendered.

## Analytics

Not applicable: Toast component does not emit analytics events in source code.

## Privacy

Not applicable: Toast component does not collect, store, or transmit any personal data. Title and description are caller-provided and not retained after dismissal.

## Logging

Not applicable: Toast component does not emit logs in source code.

## Platform Notes

- **React/Web**: Implemented using Base UI React toast primitives (`@base-ui/react/toast`), styled with Tailwind CSS utility classes and design tokens (e.g., `apt-border`, `apt-surface-2`). Exports `ToastProvider`, `Toaster` component, and `useToast` hook. Leverages CSS transitions and `data-*` attributes for animation (e.g., `data-starting-style:opacity-0`).
- **SwiftUI**: Implement using native `Notification` or `ProgressView` in conjunction with `.transition()` for opacity animation. Position in a fixed overlay at `safeAreaInset(edge: .bottom)`. Manage queue using an `@ObservedObject` view model.
- **Compose**: Implement using `Snackbar` from Material 3 or custom `Composable` with `Modifier.pointerInput()` for dismiss. Position using `Modifier.align(Alignment.BottomEnd)` within a Box with `Modifier.fillMaxSize()`. Manage queue with `State<List<Toast>>`.
- **AppKit / UIKit**: Implement using `NSView` (macOS) or `UIView` (iOS) subclass with `NSStackView` (macOS) or `UIStackView` for layout. Use `CABasicAnimation` for opacity transitions. Position with `NSLayoutConstraint` or Auto Layout to bottom-right corner. Manage queue with custom view controller or state management.
- **WinUI 3**: Implement using `TeachingTip` control positioned in `PART_PopupRoot` XAML host at bottom-right via Canvas or Grid with `HorizontalAlignment="Right"` and `VerticalAlignment="Bottom"`. Set `IsOpen` property and `Closed` event for dismissal. Use `DoubleAnimation` on `Opacity` property for fade transitions. Bind queue to `ItemsControl` with `StackPanel` as `ItemsPanel`. Use `{ThemeResource SystemControlBackgroundAltHighBrush}` for surface background and `{ThemeResource SystemControlForeground}` for text color.

## Design Decisions

- **Fixed bottom-right positioning**: Toast viewport is positioned at bottom-right rather than top-center or full-width, to avoid blocking critical interface elements and keep toasts out of the visual center. Bottom-right is a conventional position in Material Design and web applications.
- **Opacity-only animation**: Exit animation uses opacity fade rather than slide-out or scale-down, minimizing layout thrashing and keeping animation lightweight.
- **Portal pattern**: Toast renders via `ToastPrimitive.Portal` to escape local DOM hierarchy, preventing stacking context issues and ensuring consistent z-index management.
- **Close button as primary dismiss control**: Close button is explicit and always available, giving users full control over dismissal rather than relying on auto-dismiss timeout (which is not implemented in source).
- **Design token color references**: Background, text, and focus ring colors reference design tokens (`apt-surface-2`, `apt-text`, `apt-gold/40`) rather than hardcoded hex values, enabling consistent theming across the application.

## Compliance

Not applicable: The Toast component itself does not implement compliance checks. Implementations of this recipe on each platform MUST satisfy applicable accessibility standards: web implementations MUST conform to WCAG 2.1 Level AA for keyboard navigation, focus management, and sufficient color contrast; platform-specific implementations MUST follow Apple Human Interface Guidelines (iOS), Material Design 3 (Android), or Fluent 2 Design System (Windows) accessibility requirements.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.1 | 2026-09-22 | Mike Fullerton | Revise accessibility sections and edge cases: document hard-coded Close label, add Reduce Motion fact, clarify Differentiate Without Color limitation, state viewport overflow behavior, reword Compliance as Not applicable |
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
