---
id: f7fbabba-4b48-4b6b-a99c-b888cedec056
title: Pane Control Cluster
domain: agenticdevelopercookbook://ingredients/pane-control-cluster
type: ingredient
version: 1.0.0
status: review
language: en
created: 2026-09-22
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A trio of control buttons (close, minimize, zoom) for a pane's title bar,
  mirroring window-level controls.
platforms:
- swift
- macos
tags:
- pane
- controls
- title-bar
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Pane Control Cluster

## Overview

A horizontal cluster of three buttons at the leading edge of a pane's title bar: close, minimize, and zoom. The component mirrors the arrangement and meanings of the window title bar controls, ensuring visual and behavioral consistency. The cluster reports state (zoomed, minimized, enabled/disabled) and does not make decisions about pane lifecycle — the hosting container retains full responsibility for closing, resizing, and state management.

## Behavioral Requirements

- **must-render-three-buttons**: The component MUST render exactly three buttons in left-to-right order: close, minimize, zoom.
- **must-use-standard-glyphs**: The component MUST display SF Symbol glyphs: "xmark" for close, "minus" or "plus" for minimize/restore, "arrow.up.left.and.arrow.down.right" or "arrow.down.right.and.arrow.up.left" for zoom/unzoom.
- **must-report-close-action**: The component MUST invoke the `onClose` closure when the close button is tapped.
- **must-report-minimize-action**: The component MUST invoke the `onMinimize` closure with the minimize button as a parameter when the minimize button is tapped in the non-minimized state.
- **must-report-restore-action**: The component MUST invoke the `onRestore` closure when the minimize button is tapped in the minimized state.
- **must-report-zoom-action**: The component MUST invoke the `onZoom` closure when the zoom button is tapped.
- **must-render-minimized-state**: When `isMinimized` is true, the component MUST render the minimize button with a "plus" glyph, "Restore Pane" label, "pane.restore" accessibility ID, and enable it regardless of `canMinimize`.
- **must-render-zoomed-state**: When `isZoomed` is true, the component MUST render the zoom button with the "arrow.down.right.and.arrow.up.left" glyph and "Unzoom Pane" label; when false, MUST render "arrow.up.left.and.arrow.down.right" and "Zoom Pane" label.
- **must-disable-close-button**: When `canClose` is false, the component MUST disable the close button and render it with reduced opacity (tertiary text color).
- **must-disable-minimize-button**: When `canMinimize` is false and `isMinimized` is false, the component MUST disable the minimize button and render it with reduced opacity (tertiary text color).
- **must-respond-to-state-changes**: The component MUST respond to changes in `isZoomed`, `isMinimized`, `canMinimize`, and `canClose` properties and update the button appearances and enabled states accordingly.
- **must-use-accessory-bar-style**: The component MUST use bezel style `.accessoryBarAction` for all buttons.
- **must-use-tinted-rendering**: The component MUST render buttons with `imagePosition = .imageOnly` and use `contentTintColor` for glyph coloring.
- **must-theme-aware-tinting**: The component MUST observe theme changes and re-apply tinting to all buttons: secondary text color for enabled buttons, tertiary text color for disabled buttons.

## Appearance

- **Layout**: Horizontal stack, 2pt spacing between buttons, centered vertically
- **Buttons**: Three equal-sized button controls with no border
- **Glyphs**: SF Symbols rendered at system size, tinted (not filled)
- **Spacing**: 2pt between each button
- **Padding**: None specified; buttons manage their own bounds
- **Background**: Transparent; inherits from container
- **Tint**: Secondary text color (enabled), tertiary text color (disabled), theme-responsive

## States

| State | Appearance Change |
|-------|------------------|
| Default (not zoomed, not minimized, all enabled) | Close: "xmark" enabled; Minimize: "minus" enabled; Zoom: "arrow.up.left.and.arrow.down.right" enabled |
| Zoomed | Zoom button: "arrow.down.right.and.arrow.up.left" glyph; label changes to "Unzoom Pane" |
| Minimized | Minimize button: "plus" glyph, label "Restore Pane", enabled regardless of `canMinimize`; minimize button appears in restore role |
| Close disabled | Close button: opacity reduced to tertiary text color, no interaction |
| Minimize disabled | Minimize button: opacity reduced to tertiary text color (only when not minimized) |
| Dark mode | Tinting automatically adjusts to match dark theme; secondary/tertiary text colors recalculated |
| Light mode | Tinting automatically adjusts to match light theme; secondary/tertiary text colors recalculated |

## Accessibility

- **Role/trait**: Container with three buttons, each with button role
- **Accessibility IDs**: Close: "pane.close"; Minimize: "pane.minimize" (or "pane.restore" when minimized); Zoom: "pane.zoom"
- **Accessibility labels**: Close: "Close Pane"; Minimize: "Minimize Pane" or "Restore Pane"; Zoom: "Zoom Pane" or "Unzoom Pane"
- **Tooltips**: Identical to accessibility labels; displayed on hover
- **Glyph accessibility**: Each button's SF Symbol includes an accessibility description matching its label (e.g., "Close Pane" for the xmark)
- **State announcements**: Minimize button's label and glyph change reflect the state; screen readers announce the change on next access
- **Minimum tap target**: Each button SHOULD meet the minimum 44×44pt target size per Apple HIG

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| cluster-001 | must-render-three-buttons | Component initialized | Three buttons appear in order: close, minimize, zoom |
| cluster-002 | must-use-standard-glyphs | Component in default state | Close button shows "xmark"; Minimize shows "minus"; Zoom shows "arrow.up.left.and.arrow.down.right" |
| cluster-003 | must-report-close-action | Close button tapped | `onClose` closure invoked once |
| cluster-004 | must-report-minimize-action | `isMinimized = false`, minimize button tapped | `onMinimize` closure invoked with minimize button parameter |
| cluster-005 | must-report-restore-action | `isMinimized = true`, minimize button tapped | `onRestore` closure invoked once |
| cluster-006 | must-report-zoom-action | Zoom button tapped | `onZoom` closure invoked once |
| cluster-007 | must-render-minimized-state | `isMinimized = true` | Minimize button renders "plus" glyph, "Restore Pane" label, "pane.restore" ID, enabled state |
| cluster-008 | must-render-zoomed-state | `isZoomed = true` | Zoom button renders "arrow.down.right.and.arrow.up.left" glyph, "Unzoom Pane" label |
| cluster-009 | must-render-zoomed-state | `isZoomed = false` | Zoom button renders "arrow.up.left.and.arrow.down.right" glyph, "Zoom Pane" label |
| cluster-010 | must-disable-close-button | `canClose = false` | Close button disabled, rendered with tertiary text color (reduced opacity) |
| cluster-011 | must-disable-minimize-button | `isMinimized = false`, `canMinimize = false` | Minimize button disabled, rendered with tertiary text color (reduced opacity) |
| cluster-012 | must-disable-minimize-button | `isMinimized = true`, `canMinimize = false` | Minimize button enabled (restore state overrides canMinimize disable) |
| cluster-013 | must-respond-to-state-changes | `isZoomed` changes from false to true | Zoom button glyph and label update immediately |
| cluster-014 | must-respond-to-state-changes | `canClose` changes from true to false | Close button immediately disables and visual opacity reduces |
| cluster-015 | must-theme-aware-tinting | System theme changes to dark mode | All button tints re-resolve to dark theme secondary/tertiary text colors |
| cluster-016 | must-use-tinted-rendering | Component rendered | No border visible; buttons appear borderless; glyphs tinted, not filled |

## Edge Cases

- **Minimize when canMinimize is false**: Component ignores clicks on the minimize button; the button appears disabled. When `isMinimized` becomes true programmatically (set by the host), the button becomes enabled and shows restore state.
- **Restore when isMinimized is true**: The minimize button is always enabled while `isMinimized = true`, even if `canMinimize = false`. This ensures the user can always restore a minimized pane.
- **Close when canClose is false**: Component ignores clicks on the close button; the button appears disabled. The button remains visually reachable (disabled, not hidden) to communicate state, not capability, per principle-of-least-astonishment.
- **Multiple state changes in sequence**: If `isZoomed`, `isMinimized`, `canClose`, and `canMinimize` are all modified before layout occurs, the component updates all buttons in one pass via `applyState()` rather than updating each independently.
- **Theme changes during interaction**: If the system theme changes while a button is highlighted or in interaction, the component's `observeTheme` callback re-applies tinting immediately.
- **No actions configured**: All four closures (`onClose`, `onMinimize`, `onRestore`, `onZoom`) are optional. If a closure is nil, tapping the corresponding button has no effect.

## Configuration

Not applicable: This component takes no configuration parameters beyond its four state properties (`isZoomed`, `isMinimized`, `canMinimize`, `canClose`).

## Deep Linking

Not applicable: This component is a UI control cluster with no deep linking semantics; navigation and routing belong to the hosting pane or window container.

## Localization

Not applicable: All strings (accessibility labels, tooltips) are hard-coded and English-only in the source. Localization would require refactoring the component to accept string parameters or use a localization provider.

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | Not applicable: The component has no animations; it renders states instantly. Reduce Motion does not affect visual appearance. |
| Increase Contrast | Not applicable: The component inherits contrast from the semantic palette's secondary and tertiary text colors; the palette respects system Increase Contrast settings and the component responds automatically via theme observation. |
| Differentiate Without Color | Not applicable: The component's state is conveyed by glyph changes (xmark, minus, plus, arrows) and accessibility labels, not color alone; glyphs are always shape-distinct. |

## Feature Flags

Not applicable: This component has no feature flag gates; it is always enabled when instantiated.

## Analytics

Not applicable: The component does not emit analytics events; event tracking belongs to the hosting container.

## Privacy

Not applicable: The component does not collect, store, or transmit any user data or personal information.

## Logging

Not applicable: The component does not emit diagnostic logs. Hosting containers may log user interactions with pane controls.

## Platform Notes

- **SwiftUI**: Wrap `PaneControlCluster` (an NSViewRepresentable) in a state-binding adapter to connect SwiftUI property updates to the component's four state properties. SwiftUI consumers pass `@State` values for `isZoomed`, `isMinimized`, `canMinimize`, `canClose` and receive callbacks via closures. Alternatively, port the three-button layout directly to SwiftUI using `.accessoryBarAction` button style (if available) or a custom button style matching the window title bar aesthetic.
- **Compose**: Build an equivalent using three composable buttons in a `Row` with a small fixed spacing (2dp). Use Material Design 3 icon buttons (`IconButton`) with appropriate icons (close, minimize, unfold less/more). Apply theme-aware tinting via `contentColor` parameter. Manage minimize/restore state via a `MutableState<Boolean>` for `isMinimized` and disable buttons based on `canMinimize` and `canClose` flags.
- **React/Web**: Render three buttons in a horizontal flex container with 2px gap. Use icon assets (SVG or Font Awesome equivalents: ×, −, ⬆↙/⬇↗). Apply `aria-label` attributes for screen readers ("Close Pane", "Minimize Pane" / "Restore Pane", "Zoom Pane" / "Unzoom Pane"). Toggle button disabled state and aria-disabled based on the four state properties. Use CSS custom properties for theme-aware text color tinting (secondary/tertiary).
- **AppKit / UIKit**: The source `PaneControlCluster.swift` is the canonical AppKit implementation. On UIKit (iOS), adapt using three `UIButton` instances configured with system images and `.accessoryBarAction`-equivalent styling (borderless, image-only, content tint color). Manage state via observed properties and KVO, or adopt Combine publishers if the hosting container uses reactive patterns. On macOS with AppKit, use `PaneControlCluster` directly from AgenticDeveloperToolkit.
- **WinUI 3**: Use three `Button` controls in a `StackPanel` with `Orientation="Horizontal"` and `Spacing="2"`. Apply `Windows.UI.Xaml.Controls.SymbolIcon` or `FontIcon` for glyphs (close: 0xE8BB, minimize: 0xE738, maximize/restore: 0xE740/0xE71E). Set `IsEnabled` binding for each button based on the four state flags. Use `Foreground` property to apply theme-aware tinting (secondary/tertiary text from app theme resources). Bind `Command` or `Click` events to minimize state machine that conditionally invokes the four event handlers; handle the minimize button's dual role (minimize when not minimized, restore when minimized) in the click handler logic.

## Design Decisions

The component follows the principle-of-least-astonishment by mirroring window title bar controls exactly: same left-to-right order, same glyphs, same meanings. A disabled button is rendered dimly (tertiary color) rather than hidden, communicating that it is protected, not missing — this matches the host's responsibility model: the host decides whether a pane may be closed or minimized.

The minimize button's dual role (minimize/restore) is communicated through glyph and label changes, and accessibility is maintained by swapping the accessibility ID and label in response to `isMinimized`. This avoids a second button and keeps the control cluster compact.

Theme observation (via `observeTheme`) is used to re-apply tinting when the system theme changes, ensuring the component responds to system-wide appearance changes without requiring explicit property updates for disabled state tinting.

The component does not infer `isZoomed` from user clicks; the host retains full control over whether a zoom request is granted. This separation of concerns ensures that the pane's zoom state always reflects the host's actual internal state and prevents race conditions.

## Compliance

Not applicable: Compliance checks (security, accessibility audit, platform policy) belong to the consuming application, not this component in isolation.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation from PaneControlCluster.swift source |
