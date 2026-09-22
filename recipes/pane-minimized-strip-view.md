---
id: 5ec45ac4-a02f-4ee7-becb-7894c2893f23
title: Pane Minimized Strip View
domain: agenticdevelopercookbook://recipes/ui/pane-minimized-strip-view
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A vertical rail representing a minimized pane, showing its glyph and restore
  button.
platforms:
- swift
tags:
- pane
- layout
- chrome
- minimized
depends-on: []
related: []
references: []
---

# Pane Minimized Strip View

## Overview

A vertical rail component that represents a minimized multi-pane layout element. When a pane is minimized to the side edge of a window, it appears as a thin vertical strip showing a symbol representing the pane's content and a restore button to expand it. Used in multi-pane layouts where content can be hidden to maximize workspace while remaining accessible.

## Behavioral Requirements

- **must-render-at-fixed-width**: Component MUST render at exactly 28 points wide.
- **must-display-restore-button**: Component MUST display a restore button with a plus symbol (`+`) at the top.
- **must-display-glyph**: Component MUST display a glyph or symbol representing the minimized pane's content.
- **must-fire-restore-callback**: Component MUST invoke the `onRestore` callback when the restore button is tapped.
- **must-accept-symbol-name**: Component MUST accept a `symbolName` property to specify which SF Symbol to display as the glyph.
- **must-update-glyph-on-symbol-change**: Component MUST update the displayed glyph immediately when `symbolName` property changes.
- **must-accept-tooltip**: Component MUST accept a `tooltip` property that appears on hover over the glyph.
- **must-update-tooltip-dynamically**: Component MUST update the tooltip text immediately when the `tooltip` property changes.
- **must-place-hairline-by-edge**: Component MUST place a vertical separator hairline on the interior side (inward) based on the edge the pane docks to—trailing side if pane docks to leading edge, or leading side if pane docks to trailing edge.
- **must-use-default-glyph**: Component MUST display a dashed square (`square.dashed`) when the provided `symbolName` is invalid or unavailable.
- **must-observe-theme-colors**: Component MUST observe theme changes and update button and glyph colors to secondary text color from the current theme palette.
- **must-set-accessibility-labels**: Component MUST set accessibility label "Restore Pane" on the restore button and provide accessibility description based on tooltip or "Minimized Pane" for the glyph.

## Appearance

- **Width**: 28 points (fixed)
- **Background**: Elevated surface background (theme-aware)
- **Icon size**: 16 × 16 points
- **Icon color**: Secondary text color (theme-aware)
- **Button color**: Secondary text color (theme-aware)
- **Separator**: Vertical hairline (border color, theme-aware) on inward side
- **Spacing**: 
  - Restore button: 4 points from top, centered horizontally
  - Glyph: 6 points below restore button, centered horizontally
- **Corner radius**: None (rectangular)
- **Shadow**: None

## States

| State | Appearance change |
|-------|------------------|
| Default | Icon and restore button rendered in secondary text color, hairline visible |
| Restore button pressed | Button responds to platform's press state (handled by NSButton bezel style) |
| Restore button focused | Focus ring visible (handled by NSButton) |
| Theme changed | Icon and button colors update to match new theme palette |

## Accessibility

- **Role**: Container holding button and icon
- **Restore button role**: Button (role automatically provided by NSButton)
- **Restore button label**: "Restore Pane" (set via accessibility label and accessibility description)
- **Glyph accessibility description**: Tooltip text if provided, otherwise "Minimized Pane"
- **Accessibility IDs**: `pane.restore` for restore button, `pane.minimized.glyph` for glyph view
- **Minimum tap target**: Restore button and glyph area should meet 44×44 point minimum (dependent on system-wide button sizing; verify in implementation)
- **Keyboard navigation**: Restore button is keyboard-accessible via Tab (provided by NSButton)

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| pane-strip-001 | must-render-at-fixed-width | View initialized with edge `.leading` | View width is 28 points |
| pane-strip-002 | must-display-restore-button | Default initialization | Restore button visible at top, displays plus symbol |
| pane-strip-003 | must-display-glyph | Default initialization with no symbolName override | Glyph displays `square.dashed` symbol |
| pane-strip-004 | must-accept-symbol-name | Initialize with `symbolName: "folder"` | Glyph displays folder symbol |
| pane-strip-005 | must-update-glyph-on-symbol-change | After init, set `symbolName = "star"` | Glyph updates to star symbol immediately |
| pane-strip-006 | must-fire-restore-callback | Set `onRestore` callback, tap restore button | Callback is invoked |
| pane-strip-007 | must-accept-tooltip | Initialize with `tooltip: "Documents"` | Tooltip text "Documents" appears on glyph hover |
| pane-strip-008 | must-update-tooltip-dynamically | After init, set `tooltip = "Settings"` | Tooltip updates to "Settings" immediately |
| pane-strip-009 | must-place-hairline-by-edge | Initialize with edge `.leading` | Hairline positioned at trailing side (interior) |
| pane-strip-010 | must-place-hairline-by-edge | Initialize with edge `.trailing` | Hairline positioned at leading side (interior) |
| pane-strip-011 | must-use-default-glyph | Initialize with `symbolName: "nonexistent.symbol"` | Glyph displays `square.dashed` fallback |
| pane-strip-012 | must-set-accessibility-labels | Default initialization | Restore button has accessibility label "Restore Pane", accessibility ID `pane.restore` |
| pane-strip-013 | must-set-accessibility-labels | Initialize with `tooltip: "Mail"` | Glyph accessibility description is "Mail" |
| pane-strip-014 | must-observe-theme-colors | Apply theme with secondary text color #666666 | Icon and button render in #666666 |

## Edge Cases

- **Empty tooltip**: If `tooltip` is empty string, glyph's tooltip is `nil` (no tooltip appears on hover).
- **Very long tooltip**: Tooltip text is set directly on glyph; platform handles wrapping and display.
- **Rapid symbol changes**: Multiple rapid updates to `symbolName` will update the glyph each time; no debouncing is performed.
- **onRestore callback not set**: If `onRestore` is `nil`, tapping restore button has no observable effect (safe no-op).
- **Invalid symbol name**: If provided symbol name cannot be loaded, fallback to `square.dashed` automatically.
- **Theme not observed**: If theme observation setup fails, component continues to render but colors will not update; client is responsible for providing valid theme palette.
- **View initialization**: Component cannot be initialized from a coder (`.xib`, `.storyboard`); `init(coder:)` is unavailable.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `edge` | `PaneEdge` enum | required | Which side the pane docks to (`.leading` or `.trailing`); determines hairline placement |
| `symbolName` | `String` | `"square.dashed"` | SF Symbol name to display as the glyph |
| `tooltip` | `String` | `""` (empty) | Tooltip text for the glyph; no tooltip if empty |
| `onRestore` | `() -> Void` closure | `nil` | Callback invoked when restore button is tapped |

## Deep Linking

Not applicable: This component is a chrome/layout element without user-navigable content; it has no corresponding deep link URL.

## Localization

Not applicable: The component uses only hardcoded English strings ("Restore Pane", "Minimized Pane") that are UI chrome labels, not user-facing content strings requiring translation.

## Accessibility Options

Not applicable: This component does not respond to platform accessibility display options (Reduce Motion, Increase Contrast, Differentiate Without Color); it delegates to the system's theme and button styling.

## Feature Flags

Not applicable: This component has no feature flag controls; it is always enabled.

## Analytics

Not applicable: This component does not emit analytics events; analytics for pane restore actions belong to the pane manager, not the view itself.

## Privacy

Not applicable: This component does not collect or transmit any user data.

## Logging

Not applicable: This component does not emit diagnostic logs; logging of pane state changes belongs to the client that manages the pane lifecycle.

## Platform Notes

- **Source**: `PaneMinimizedStripView.swift` in `AgenticDeveloperToolkit/SourcesUI/macOS/Chrome/`. Uses `NSView`, `NSButton`, `NSImageView`, theme-aware `ThemedBackgroundView` and `ThemedSeparatorView` helpers. Fixed layout via Auto Layout constraints. `@MainActor` actor-isolated for UI thread safety.
- **SwiftUI**: Wrap the AppKit view using `NSViewRepresentable`, or build natively using `VStack` with `Button` (label: Image), a `Divider` for the hairline, and state to bind `symbolName` and `tooltip`. Apply secondary text color via `.foregroundStyle()`.
- **Compose**: Implement using `Column` with `Button` (icon: painter.painterMutableState("plus")) at top, `Spacer(height = 6.dp)`, and icon glyph below. Use `fillMaxHeight()` for column, `width(28.dp)` for fixed width, and `Divider(color = ..., thickness = 1.dp, modifier = Modifier.fillMaxHeight())` positioned based on edge parameter.
- **AppKit / UIKit**: On UIKit/iOS, adapt using `UIView` with `UIButton` (system style, image: UIImage(systemName: "plus")), `UIImageView` for glyph, and `UIView` separator. Use Auto Layout constraints matching desktop spacing. Ensure button and glyph areas meet 44×44 minimum tap target on iOS.
- **WinUI 3**: Implement as a `StackPanel` (Orientation=Vertical) with fixed Width=28. Add a `Button` (icon: SymbolIcon(Symbol.Add)) at top with Padding="4,0,0,0", then `Grid` spacer (Height=6), then `Image` for glyph (Width=16, Height=16). Add a `Rectangle` as vertical `Divider` on the side facing inward, positioned via attached properties. Use `Acrylic` brush for background to match `elevatedSurface` role. Set `ToolTipService.ToolTip` for glyph tooltip.

## Design Decisions

- **Fixed width of 28 points**: Chosen to accommodate a 16×16 icon with padding on both sides (2pt each) and align multiple minimized panes vertically. This size reads as "a pane is present" without taking excessive screen space.
- **Hairline placement by edge**: The hairline is placed on the inward side (interior) to avoid doubling a line at the window edge. The `edge` parameter drives this decision at initialization time and cannot be changed post-construction.
- **Fallback to square.dashed symbol**: Provides a safe default when a pane does not implement `PaneMinimizedRepresenting` or supplies an invalid symbol. A completely empty strip would be unidentifiable to users.
- **No debouncing on symbol/tooltip changes**: The source code applies changes immediately in `didSet` observers. Rapid changes are rare in practice; if debouncing is needed, the client should throttle updates before setting properties.
- **NSButton bezel style `.accessoryBarAction`**: A platform convention for small chrome buttons in narrow spaces; provides appropriate sizing and appearance for the restore action.
- **Theme observation via closure**: Colors are updated dynamically when theme changes by observing the palette; this allows the component to remain visually consistent without requiring external updates.
- **No coder initialization**: Component is designed for programmatic use in layout code, not for instantiation from `.xib` or `.storyboard` files; this keeps the interface focused and enforces the layout-by-code pattern.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| Keyboard accessibility | Passed | Accessibility: Restore button is keyboard-navigable via NSButton |
| Touch target size | Needs verification | Accessibility: Dependent on NSButton's effective target size in final layout |
| Contrast ratio | Delegated | Appearance: Follows theme palette; palette responsible for contrast compliance |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation from PaneMinimizedStripView.swift |
