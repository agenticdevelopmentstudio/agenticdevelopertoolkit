---
id: e5165b31-6a06-4d79-8fb8-98ba491623b1
title: Tool Call Pill View
domain: agenticdevelopercookbook://ingredients/tool-call-pill-view
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Displays a tool invocation as a bordered pill with status-based coloring
  and error messaging.
platforms:
- swift
tags: []
depends-on: []
related: []
references: []
---

# Tool Call Pill View

## Overview

The Tool Call Pill View displays a single `CommandActivity` as a bordered, status-colored pill in a chat transcript. It shows the command name and, when the command has failed, appends the error message. The pill is color-coded by execution state: neutral blue (info) while running, green (success) on successful completion, and red (danger) on failure. The component observes theme palette changes and recolors its border and text live without requiring a rebuild.

## Behavioral Requirements

- **must-render-activity-name**: The component MUST display the command's name from `activity.invocation.commandName` as the pill's text content.
- **must-display-error-on-failure**: When `activity.result` exists and `result.ok` is `false`, the component MUST append the error message in the format `"<name> — <message>"` where `<name>` is the command name and `<message>` is `result.errorMessage`, or display only the name if `errorMessage` is `null` or empty.
- **must-truncate-overflow-text**: Text longer than the available width MUST be truncated at the tail with an ellipsis (`…`).
- **must-apply-status-color**: The component MUST color its label text and border according to the activity state: `.info` (neutral blue) while `activity.result` is `nil`, `.success` (green) when `result.ok` is `true`, and `.danger` (red) when `result.ok` is `false`.
- **must-observe-theme-changes**: The component MUST register a `ThemePaletteObserver` on initialization and recolor itself when the theme palette changes, without requiring a view hierarchy rebuild.
- **must-use-caption-font**: The component MUST render text using `palette.font(.caption)` from the semantic palette.
- **must-render-border**: The component MUST display a 1-point border around the pill.
- **must-apply-corner-radius**: The component MUST have a corner radius of 9 points.
- **must-apply-padding**: The component MUST apply 4 points of vertical padding and 10 points of horizontal padding between the text and the pill's edges.
- **must-use-elevated-surface**: The component MUST use `palette.nsColor(.elevatedSurface)` as the pill's background color.

## Appearance

- **Corner radius**: 9 points
- **Padding**: 4pt vertical × 10pt horizontal
- **Font**: Caption weight and size from semantic palette
- **Background**: Elevated surface color from semantic palette
- **Foreground/Text**: Status-dependent color (info / success / danger)
- **Border**: 1 point, status-dependent color (info / success / danger)
- **Shadow**: None
- **Min/Max size**: No explicit constraints; size determined by text width and padding

## States

| State | Appearance change |
|-------|------------------|
| Running (result == nil) | Text and border colored `.info` |
| Success (result.ok == true) | Text and border colored `.success` |
| Failed (result.ok == false) | Text and border colored `.danger`; error message appended to name |
| Theme changed | All colors updated to match new palette without rebuild |

## Accessibility

- **Role**: Static text display (read-only, non-interactive)
- **Label**: The full text of the pill (command name or "name — error message") serves as the accessible label and is read by screen readers
- **State announcements**: The component does not announce state changes; it is embedded in a message bubble whose parent is responsible for announcing activity updates
- **Minimum tap target**: Not applicable; this component is not interactive and is embedded in read-only message content

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| pill-001 | must-render-activity-name | CommandActivity with `invocation.commandName = "fetch_data"`, `result = nil` | Text reads "fetch_data" |
| pill-002 | must-apply-status-color, must-render-border | CommandActivity with `result = nil` | Label text and border colored `.info` |
| pill-003 | must-apply-status-color, must-render-border | CommandActivity with `result.ok = true` | Label text and border colored `.success` |
| pill-004 | must-apply-status-color, must-render-border | CommandActivity with `result.ok = false` | Label text and border colored `.danger` |
| pill-005 | must-display-error-on-failure | CommandActivity with `result.ok = false`, `result.errorMessage = "Connection timeout"` | Text reads "fetch_data — Connection timeout" |
| pill-006 | must-display-error-on-failure | CommandActivity with `result.ok = false`, `result.errorMessage = ""` or `nil` | Text reads "fetch_data" (name only) |
| pill-007 | must-truncate-overflow-text | CommandActivity with command name exceeding available width | Text ends with ellipsis; does not overflow pill boundary |
| pill-008 | must-observe-theme-changes | Pill on screen; theme palette changes | Border and text colors update without view rebuild |
| pill-009 | must-use-caption-font | Pill rendered | Font matches `palette.font(.caption)` |
| pill-010 | must-apply-padding, must-apply-corner-radius | Pill rendered | Vertical padding 4pt, horizontal 10pt, corner radius 9pt |
| pill-011 | must-use-elevated-surface | Pill rendered | Background color matches `palette.nsColor(.elevatedSurface)` |
| pill-012 | must-render-border | Pill rendered | 1-point border present and colored per status |

## Edge Cases

- **Empty command name**: If `invocation.commandName` is an empty string, the pill displays an empty label. This is not anticipated by the source and has undefined visual behavior.
- **Null error message with failed result**: If `result.ok` is `false` but `result.errorMessage` is `nil`, the component displays only the command name (no error message appended). This is a MUST per requirement must-display-error-on-failure.
- **Very long error message**: If the error message is very long, the combined "name — message" text is truncated at the tail with an ellipsis. The full text is not available via tooltip or other means.
- **Theme palette deallocated**: If the theme palette is deallocated while the observer is active, the observer pattern (as implemented in AgenticDeveloperToolkit's `ThemePaletteObserver`) handles deregistration. Expected behavior confirmed by use of weak self capture.
- **Multiple theme changes in rapid succession**: Each theme change triggers a full recolor via `applyTheme(_:)`. No debouncing or batching is implemented; rapid theme changes apply each update immediately.

## Configuration

Not applicable: The component accepts a `CommandActivity` at initialization and has no configuration options. All appearance parameters (padding, corner radius, font size) are hardcoded constants.

## Deep Linking

Not applicable: This component is a passive display element embedded in a chat message transcript and does not handle deep links.

## Localization

Not applicable: The component displays only the command name and error message from the `CommandActivity` object, which are supplied by the caller. No strings are generated or localized by the component itself.

## Accessibility Options

- **Reduce Motion**: Not applicable. The component has no animations.
- **Increase Contrast**: Not applicable. The component uses semantic palette colors determined by the theme; contrast compliance is the palette's responsibility.
- **Differentiate Without Color**: Not applicable. The component communicates status only through color (info / success / danger). No alternate visual indicator (icon, pattern, or label) is provided; this is a potential accessibility gap.

## Feature Flags

Not applicable: The component has no feature flags. It is always active when instantiated.

## Analytics

Not applicable: The component does not emit analytics events. Event tracking, if desired, is the responsibility of the parent message bubble or transcript view.

## Privacy

Not applicable: The component displays command names and error messages supplied by the caller. It does not collect, store, or transmit data beyond what is rendered on screen.

## Logging

Not applicable: The component does not emit log messages.

## Platform Notes

- **Source (Apple/Swift)**: Implemented as an `NSView` subclass in `/packages/apple/AgenticDeveloperToolkit/SourcesUI/macOS/Chat/ToolCallPillView.swift`. Uses `NSTextField` for text rendering and `CALayer` for border, corner radius, and background. Integrates with the semantic palette via `ThemePaletteObserver` pattern.
- **SwiftUI**: A SwiftUI wrapper would bridge the `NSView` via `NSViewRepresentable` or embed a native SwiftUI `Capsule` shape with `Text` overlay, applying the same padding, corner radius, and semantic colors. Live theme observation would require a SwiftUI `@EnvironmentObject` or `.environment(_:_:)` modifier.
- **Compose**: An Android Compose equivalent would use `Box` or `Surface` with a `border` modifier, applying the same padding and corner radius. Status color would be driven by a Compose state or `remember` block observing the palette. Material 3 would use `Surface` with `contentColor` for theming.
- **AppKit / UIKit**: On UIKit (iOS), replace `NSView` with `UIView`, `NSTextField` with `UILabel`, and `CALayer` properties with frame-based layout or Auto Layout. The `ThemePaletteObserver` pattern adapts to UIKit lifecycle (viewWillAppear for observer registration). UIKit has no built-in semantic palette; the palette would need to be passed as an environment or observed via NotificationCenter.
- **WinUI 3**: Implement as a `UserControl` with a `Border` as the root element, containing a `TextBlock` for the text. Apply `CornerRadius` property for 9-point radius, `BorderThickness` for 1-point border, and `Padding` for 4pt/10pt vertical/horizontal. Use WinUI's `SolidColorBrush` bindings to apply status-dependent colors from a semantic color dictionary. Subscribe to a theme-changed event or binding to update colors live.

## Design Decisions

**Status-Color Mapping**: The component deliberately uses `.info` (neutral blue) for the running state rather than `.warning` (yellow/orange). This decision prioritizes reduced alert fatigue: a running command is neither good news nor bad, and using a warning color would create false urgency on every tool call. This differs from error indicators (red / `.danger`) and success indicators (green / `.success`), which are meaningful outcomes.

**Error Message Concatenation Format**: When a command fails, the error message is appended to the name using a dash-space separator (`" — "`). This format is consistent with the error handling approach taken in `MessageBubbleView` for failed message deliveries: a colored pill with no words requires the user to decode the color; the message makes the failure legible.

**No Tooltip for Truncated Text**: Truncated text does not display a tooltip showing the full text. This is consistent with the source code (no tooltip implementation). A tooltip would improve UX for long error messages but is out of scope for this component.

**Rebuild-Free Theme Changes**: The component holds its own `ThemePaletteObserver` and recolors on palette changes, rather than relying on a full view-tree rebuild. This is a performance optimization for live theme switching in a transcript view: pills already rendered remain on screen and update their colors directly, reducing layout churn.

## Compliance

Not applicable: The component has no security, privacy, or data handling concerns beyond the scope of a UI display element.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation from ToolCallPillView.swift source |
