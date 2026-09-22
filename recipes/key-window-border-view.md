---
id: 9e06ce25-a124-473e-9cf6-ea11a7c40b2d
title: KeyWindowBorderView
domain: agenticdevelopercookbook://ingredients/key-window-border-view
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A hairline accent-color border drawn inside the window frame, brightening
  when the window is key.
platforms:
- swift
- macos
tags:
- ui
- chrome
- macos
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# KeyWindowBorderView

## Overview

`KeyWindowBorderView` is a macOS window decoration that draws a faint accent-colored hairline on the inside edge of a frameless or translucent window. The line brightens when the window becomes key, providing a visual affordance for which window has focus. The view is click-through and does not respond to mouse events.

## Behavioral Requirements

- **must-draw-border**: Component MUST draw a 1-point stroked rounded rectangle aligned to the window's edge.
- **must-inset-by-half-point**: Component MUST inset the path by 0.5 points horizontally and vertically to align the stroke center with the pixel grid, preventing blurring from sub-pixel rendering.
- **must-use-accent-color**: Component MUST use the theme's accent color as the stroke color.
- **must-apply-inactive-alpha**: Component MUST apply `inactiveAlpha` opacity to the stroke when the window is not key.
- **must-apply-active-alpha**: Component MUST apply `activeAlpha` opacity to the stroke when the window is key.
- **must-be-click-through**: Component MUST return `nil` from `hitTest(_:)` and not intercept mouse events.
- **must-respond-to-key-state-changes**: Component MUST observe window key state notifications and redraw when key state changes.
- **must-support-corner-radius-customization**: Component MUST allow the corner radius to be customized via the public `cornerRadius` property.
- **must-support-alpha-customization**: Component MUST allow the inactive and active alpha values to be customized via the public `inactiveAlpha` and `activeAlpha` properties.
- **must-redraw-on-property-change**: Component MUST mark itself for redisplay when `cornerRadius`, `inactiveAlpha`, or `activeAlpha` properties are modified.
- **must-respond-to-theme-changes**: Component MUST observe theme palette changes and update the accent color when the theme changes.
- **must-clean-up-observers**: Component MUST remove all observers from the notification center when deallocated or moved to a window.
- **must-be-main-actor-isolated**: Component MUST be annotated as `@MainActor` to ensure all drawing and observation occur on the main thread.

## Appearance

- **Stroke width**: 1 point
- **Stroke inset**: 0.5 points (half the stroke width) on all sides
- **Corner radius**: Default 10 points (customizable via `cornerRadius` property)
- **Color**: Theme accent color
- **Inactive opacity**: Default 0.28 (customizable via `inactiveAlpha` property)
- **Active opacity**: Default 0.85 (customizable via `activeAlpha` property)
- **Background**: Transparent (no fill)
- **Rendering**: Drawn using `NSBezierPath` with `stroke()` method

## States

| State | Appearance change | Opacity | When triggered |
|-------|------------------|---------|-----------------|
| Inactive | Border faded | `inactiveAlpha` (0.28) | Window is not key; see `NSWindow.didResignKeyNotification` |
| Active | Border brightened | `activeAlpha` (0.85) | Window is key; see `NSWindow.didBecomeKeyNotification` |

## Accessibility

Not applicable: This component is a purely decorative visual affordance with no interactive function. It serves as a window chrome hint and does not expose accessible content, controls, or state beyond its visual appearance.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| key-001 | must-draw-border | Component initialized and added to a window | 1-point stroked rounded rectangle is drawn within the component's bounds |
| key-002 | must-inset-by-half-point | Component draws | Stroke path is inset by (0.5, 0.5) on all sides; stroke appears sharp without sub-pixel blurring |
| key-003 | must-use-accent-color | Theme accent is red (example) | Stroke color is red with appropriate alpha |
| key-004 | must-apply-inactive-alpha | Window is not key; `inactiveAlpha` = 0.28 | Stroke is drawn with 0.28 alpha component |
| key-005 | must-apply-active-alpha | Window becomes key; `activeAlpha` = 0.85 | Stroke is drawn with 0.85 alpha component |
| key-006 | must-be-click-through | Mouse event at (x, y) within component bounds | `hitTest(_:)` returns `nil`; event passes through to view underneath |
| key-007 | must-respond-to-key-state-changes | Window key state changes from inactive to active | Component redraws and stroke brightness increases visibly |
| key-008 | must-support-corner-radius-customization | Set `cornerRadius` to 15 | Stroke path is drawn with corner radius 15 instead of default 10 |
| key-009 | must-support-alpha-customization | Set `inactiveAlpha` to 0.5; window is not key | Stroke is drawn with 0.5 alpha |
| key-010 | must-redraw-on-property-change | Modify `cornerRadius` property | Component marks itself for display; redraw occurs |
| key-011 | must-respond-to-theme-changes | Theme palette changes; accent color changes to blue | Stroke color updates to blue |
| key-012 | must-clean-up-observers | Move component between windows | Observers for the previous window are removed; observers for the new window are registered |
| key-013 | must-be-main-actor-isolated | Component is allocated and drawn | No thread safety warnings; all UI updates occur on main thread |

## Edge Cases

- **Initial window state**: When the view is first added to a window via `viewDidMoveToWindow()`, the current key state is read and drawn correctly without requiring user interaction.
- **Window move between windows**: If the view is moved from one window to another, observers for the old window are removed and re-registered for the new window. The stroke is redrawn to reflect the new window's key state.
- **Nil window**: If `viewDidMoveToWindow()` is called and `window` is `nil` (view removed), all observers are cleaned up and no drawing occurs.
- **Zero or negative corner radius**: The behavior is not explicitly constrained by the source; the underlying `NSBezierPath` method determines the rendering. A host that sets invalid radii accepts that consequence.
- **Alpha values outside [0, 1]**: Setting `inactiveAlpha` or `activeAlpha` to values outside the valid range does not raise an error; the `NSColor.withAlphaComponent(_:)` method handles or clips the value, and drawing proceeds.
- **Theme change during deallocating**: The `ThemePaletteObserver` is held by the view; when the view deallocates, the observer is released and no further theme updates are received.
- **Rapid key state toggles**: Each key state notification triggers a redraw. No debounce or deduplication is performed; rapid toggles result in multiple draw cycles.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `cornerRadius` | `CGFloat` | `10.0` | Corner radius of the stroked rectangle in points |
| `inactiveAlpha` | `CGFloat` | `0.28` | Opacity of the stroke when the window is not key (range [0, 1]) |
| `activeAlpha` | `CGFloat` | `0.85` | Opacity of the stroke when the window is key (range [0, 1]) |

## Deep Linking

Not applicable: This component is a window decoration with no user interaction or navigation. It does not handle deep links or URL-based state.

## Localization

Not applicable: This component displays no user-facing text or strings.

## Accessibility Options

Not applicable: This component is a decorative visual element with no semantic meaning or interactive state for assistive technologies to expose.

## Feature Flags

Not applicable: No feature flag mechanism is implemented in the source. The component is always enabled when instantiated.

## Analytics

Not applicable: The component does not perform user interaction tracking or emit analytics events.

## Privacy

Not applicable: The component does not collect, store, or transmit any user data.

## Logging

Not applicable: No logging is implemented in the source.

## Platform Notes

- **SwiftUI**: `KeyWindowBorderView` is an `NSView` subclass and requires wrapping in `NSViewRepresentable` for use in SwiftUI. Create a simple wrapper that instantiates the view and exposes the `cornerRadius`, `inactiveAlpha`, and `activeAlpha` properties as SwiftUI bindings or state parameters. The wrapper must ensure the view is added to the SwiftUI hierarchy as a background or overlay layer so it does not interfere with interactive content.

- **Compose**: Not applicable: Android does not have frameless or translucent windows with key state semantics equivalent to macOS. A Compose-based companion component would need to redefine the concept (e.g., as a subtle top border on a translucent dialog) and adapt to Material Design principles rather than replicate the macOS behavior.

- **React/Web**: Not applicable: Web browsers do not expose window-level focus or key state in the same way as macOS. A web implementation would require simulating window focus via JavaScript `window.focus()` and `blur()` events, which have different semantics and limited utility in a browser context.

- **AppKit / UIKit**: On macOS, `KeyWindowBorderView` is implemented as an `NSView` subclass using `NSBezierPath` and direct drawing in `draw(_:)`. The view observes `NSWindow.didBecomeKeyNotification` and `NSWindow.didResignKeyNotification` to respond to key state changes. On iOS, `UIView` does not have an equivalent key state (windows are always "key"), so a UIKit equivalent would need to use alternative signals such as visibility or user interaction to simulate the active/inactive states. A cross-platform AppKit/UIKit component would likely remain AppKit-only or require a significant redesign for iOS.

- **WinUI 3**: On Windows, implement this as a custom `Control` that draws a border using `CanvasControl` or `Windows.UI.Xaml.Shapes.Rectangle` with a `Stroke`. Hook the window's `Activated` and `Deactivated` events to toggle between `inactiveAlpha` and `activeAlpha` opacity states. Use `Windows.UI.Xaml.Media.SolidColorBrush` to apply the accent color dynamically from the app's theme resources. Set `IsHitTestVisible` to `false` to make the border click-through. Draw the border inset by 0.5 logical pixels on all sides and apply the appropriate `CornerRadius` property to match macOS rendering. Bind the accent color to the system theme palette via `Windows.UI.Xaml.Application.Current.Resources["SystemAccentColor"]` or the app's custom theme provider.

## Design Decisions

- **Half-point inset**: The stroke is inset by 0.5 points on all sides to align the stroke center with the pixel grid. This prevents the 1-point stroke from straddling two pixel columns, which would cause the line to render as a 2-point blur. This is a pixel-grid-specific rendering detail that applies to AppKit and WinUI 3 but may not be necessary on platforms with different rendering pipelines.

- **Inactive/active opacity defaults (0.28 / 0.85)**: The large gap between the two opacity values is intentional. The inactive line must be quiet enough to read as the window's edge rather than a highlight, while the active line must be bright enough to clearly signal which window has focus. These defaults are calibrated for readability against a light or dark desktop.

- **Click-through behavior**: The view is implemented as a hit-test sink (`hitTest` returns `nil`) rather than using `isUserInteractionEnabled = false` or `canBecomeFirstResponder`. This keeps the view in the responder chain but prevents it from consuming events, allowing windows with this border to remain interactive.

- **Theme palette observation**: The component uses `ThemePaletteObserver` to update the accent color dynamically. This ties the border to the app's theme and ensures the border adapts if the user or the app changes the accent color.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| Decorative element; no accessibility violations | passed | Accessibility |
| Click-through design ensures no mouse event blocking | passed | Usability |
| Main-actor isolation ensures thread safety | passed | Concurrency |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial recipe extraction from KeyWindowBorderView.swift |
