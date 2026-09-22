---
id: 0c8a7db3-9948-466c-8c97-20de2ae53a17
title: Pane Minimize Picker
domain: agenticdevelopertoolkit://recipes/pane-minimize-picker
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Four directional arrow buttons in a cross pattern within a popover, for selecting
  which edge a pane should minimize toward.
platforms:
- swift
- macos
tags:
- pane-management
- popover
- directional-selection
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Pane Minimize Picker

## Overview

The Pane Minimize Picker is a directional arrow picker presented in a popover. It displays four arrows arranged in a cross (↑, ←, →, ↓) representing the four edges (top, leading, trailing, bottom). The picker allows users to select which direction a pane should minimize toward. Arrows corresponding to unavailable edges are disabled. The picker closes automatically after an edge is selected.

## Behavioral Requirements

- **must-render-four-arrows**: The component MUST render exactly four arrow buttons arranged in a cross pattern: top, leading, trailing, and bottom.
- **must-initialize-with-available-edges**: The component MUST accept an initial set of available edges at initialization and enable only those arrows.
- **must-disable-unavailable-arrows**: The component MUST disable arrow buttons for edges not in the available edges set.
- **must-invoke-callback-on-selection**: The component MUST invoke the onPick callback with the selected edge when an arrow is tapped.
- **must-close-popover-before-callback**: The component MUST close the popover before invoking the onPick callback.
- **must-support-dynamic-availability**: The component MUST update button enabled states when the available edges set is changed after initialization.
- **must-apply-theme-tint**: The component MUST apply primary text color to enabled arrows and tertiary text color to disabled arrows based on the current theme.
- **must-display-tooltips**: Each arrow button MUST display a tooltip with the edge's display name.

## Appearance

- **Layout**: 3×3 grid with center column and row empty, four arrow buttons at cardinal positions.
- **Button style**: Accessory bar action (AppKit system style).
- **Button content**: System symbol image only (SF Symbols), no text or border.
- **Grid spacing**: 2pt between rows and columns.
- **Padding**: 8pt on all sides (top, leading, trailing, bottom) around the grid.
- **Icon color (enabled)**: Primary text color from current theme.
- **Icon color (disabled)**: Tertiary text color from current theme.
- **Border**: None.

## States

| State | Appearance change |
|-------|------------------|
| Default (available) | Arrow button enabled, primary text tint. |
| Disabled (unavailable) | Arrow button disabled (visual disabled state), tertiary text tint. |
| Shown | Popover is visible. |
| Hidden | Popover is not visible. |

## Accessibility

- **Role**: Each arrow button is a button control.
- **Label**: Each button has an accessibility label matching the edge's display name (e.g., "Minimize top", "Minimize leading").
- **ID**: Each button has an accessibility ID in the format `pane.minimize.{edge}` (e.g., `pane.minimize.top`).
- **Tooltip**: Each button displays a tooltip matching the edge's display name.
- **Symbol description**: Arrow symbol includes an accessibility description matching the edge display name.
- **Minimum tap target**: 44×44pt (AppKit system buttons meet this automatically).

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| pane-minimize-001 | must-render-four-arrows | Initialize PaneMinimizeCrossView with any available edges set | Grid contains exactly four buttons at top, leading, trailing, and bottom positions. |
| pane-minimize-002 | must-initialize-with-available-edges | Initialize with availableEdges = {.top, .leading} | Top and leading buttons are enabled; trailing and bottom buttons are disabled. |
| pane-minimize-003 | must-disable-unavailable-arrows | Initialize with availableEdges = {} | All four buttons are disabled. |
| pane-minimize-004 | must-invoke-callback-on-selection | availableEdges = {.top}; user taps top arrow | onPick callback is called with .top. |
| pane-minimize-005 | must-close-popover-before-callback | Picker is shown; user taps available arrow | Popover closes before onPick is invoked. |
| pane-minimize-006 | must-support-dynamic-availability | Initialize with {.top}; set availableEdges = {.top, .leading} | Leading button transitions from disabled to enabled; tint color updates immediately. |
| pane-minimize-007 | must-apply-theme-tint | Verify button tint colors | Enabled buttons show primary text color; disabled buttons show tertiary text color. |
| pane-minimize-008 | must-display-tooltips | Hover over any arrow button | Tooltip appears with the edge's display name. |

## Edge Cases

- **Empty available edges set**: If availableEdges is empty, all four buttons are disabled. User cannot select any edge, and onPick is not invoked if a disabled button is tapped. The popover remains open.
- **All edges available**: If availableEdges contains all four edges, all buttons are enabled. User can select any direction.
- **Availability change while popover is shown**: If availableEdges is updated while the popover is displayed, button states update immediately without closing the popover.
- **Button not found**: The component stores buttons in a dictionary keyed by edge. If a button lookup fails (internal error), the component uses fail-fast semantics and raises a fatalError rather than returning nil.
- **Disabled button interaction**: Tapping a disabled arrow button has no effect (platform buttons ignore taps when disabled).

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| availableEdges | Set<PaneEdge> | (required) | Set of edges for which arrows should be enabled. |
| onPick | (PaneEdge) -> Void | (required) | Callback invoked with the selected edge after the popover closes. |

## Deep Linking

Not applicable: This is a UI picker component with no deep linking requirement. Edge selection is local to the pane layout interaction.

## Localization

Not applicable: Arrow directions are represented by system symbols. Labels are derived from PaneEdge.displayName, which SHOULD be localized by the calling code if needed.

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | Platform default: popover presentation respects system reduce-motion setting. |
| Increase Contrast | Platform default: button tint colors are derived from theme palette, which SHOULD respect contrast settings. |
| Differentiate Without Color | Not applicable: Component relies on arrow symbols and position, not color alone, to convey direction. |

## Feature Flags

Not applicable: This component is a foundational UI element with no feature flag gating in the source.

## Analytics

Not applicable: The component does not emit analytics events. Event logging is the responsibility of the calling code.

## Privacy

Not applicable: This component does not collect, store, or transmit any user data.

## Logging

Not applicable: The component does not emit log messages in the source code.

## Platform Notes

- **Apple (AppKit)**: Implemented in `packages/apple/AgenticDeveloperToolkit/SourcesUI/macOS/Chrome/PaneMinimizePicker.swift`. The `PaneMinimizeCrossView` constructs a 3×3 `NSGridView` with four `NSButton` instances positioned at cardinal points. Button state is managed via `isEnabled` and `contentTintColor` properties. The `PaneMinimizePicker` wraps the cross in an `NSPopover` with transient behavior and shows it relative to an anchor view at the minY edge.
- **SwiftUI**: Start from a grid-based container (e.g., `Grid` with custom layout or nested stacks in a 3×3 arrangement). Use `Button` views with SF Symbols for arrow images. Bind button disabled state to the availableEdges set. Use an `@State` popover presentation modifier to show/hide the picker. Apply theme-aware foreground colors using `.foregroundColor()` based on enabled/disabled state. Call the onPick closure and dismiss the popover on button tap.
- **Compose (Android)**: Use a `GridLayout` or `Box` with custom layout to arrange four `IconButton` instances in a cross pattern. Supply Material Design arrow icons (e.g., `Icons.AutoMirrored.Filled.KeyboardArrowUp`). Disable buttons by setting `enabled = false` on the `IconButton`. Wrap in a `PopupMenu` or custom `Popup` composable. Invoke the callback and dismiss the popup on button click.
- **AppKit / UIKit (iOS)**: On iOS, use `UIView` layout constraints or SwiftUI. Construct a 3×3 grid using `UIStackView` with arranged subviews, or SwiftUI `Grid`. Use `UIButton` or SwiftUI `Button` with system arrow images. Toggle button enabled state via `isEnabled`. Present the picker in a `UIPopoverPresentationController` (iPad) or a sheet/modal (iPhone). Invoke the callback and dismiss after selection.
- **WinUI 3**: Build a 3×3 Grid in XAML with four `Button` controls at cardinal positions. Use `SymbolIcon` with arrow symbols (e.g., `SymbolIconSource` with "Up", "Left", "Right", "Down" glyphs from the Fluent icon set). Bind button `IsEnabled` to the available edges set. Bind `Foreground` color to a converter that selects primary or tertiary text color based on `IsEnabled`. Wrap the grid in a `Flyout` or `MenuFlyout` attached to a trigger button. Invoke the callback from the button `Click` event handler and close the flyout before invoking onPick.

## Design Decisions

- **Grid layout vs. nested stacks**: The component uses `NSGridView` rather than nested `NSStackView` because the grid layout structurally conveys the cross shape — a user sees four directions around a center. This improves code clarity and maintainability (`native-controls`).
- **Separate cross and picker classes**: `PaneMinimizeCrossView` (the cross buttons) is separate from `PaneMinimizePicker` (the popover wrapper). This separation allows tests to verify button state without opening a popover (`tight-feedback-loops`).
- **Fail-fast on button lookup**: The `button(for:)` method raises `fatalError` rather than returning `nil` because buttons for all four edges are always created in `init`. A nil return cannot be safely handled by callers, so fast failure is the correct semantics.
- **Popover closes before callback**: The popover is explicitly closed before invoking onPick. This ensures the anchor view's layout can change without the popover pointing at a moved or removed view.
- **Theme-aware tint color**: Button color is updated reactively via `observeTheme` whenever the theme changes, ensuring the picker respects user theme preferences.

## Compliance

Not applicable: This component is a UI control with no specific compliance requirements (e.g., security, data protection, regulatory) in the source.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation |
