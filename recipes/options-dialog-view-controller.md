---
id: 56388aa3-bc75-4d0a-830b-222f39750a9d
title: Options Dialog View Controller
domain: agenticdevelopercookbook://ingredients/options-dialog-view-controller
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A container-agnostic macOS dialog that presents customizable rows and applies
  changes immediately without requiring commit or cancel.
platforms:
- swift
- macos
tags:
- ui
- dialog
- macos
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Options Dialog View Controller

## Overview

`OptionsDialogViewController` is a macOS NSViewController that presents a modal or sheet dialog containing an optional heading, a stack of customizable rows (any NSView subclasses), and a Done button. The dialog applies all changes immediately as the user interacts with rows—there is no commit or cancel operation. This component is designed to be container-agnostic; the same view controller body is used whether the dialog is presented as a sheet, a modal window, or through other presentation mechanisms. The caller controls presentation and dismissal through callbacks.

## Behavioral Requirements

- **must-render-content-in-vertical-stack**: The component MUST render the heading (if provided), all rows, and the Done button in a vertical stack with consistent spacing and alignment.
- **must-accept-custom-rows**: The component MUST accept an array of NSView subclasses as row content and render them without modification or filtering.
- **must-support-dynamic-heading**: The component MUST allow the heading text to be changed after initialization via the `heading` property, with the UI updating immediately to reflect the change or hide the heading if set to `nil`.
- **must-apply-changes-immediately**: The component MUST NOT buffer or defer changes made by row controls; all changes MUST be applied and persisted (or propagated) as they occur.
- **must-provide-done-callback**: The component MUST invoke the `onDone` callback when the Done button is pressed, allowing the presenter to decide how to close the dialog (sheet dismissal, modal stop loop, etc.).
- **must-provide-close-callback**: The component MUST invoke the `onDidClose` callback once the dialog is off-screen, signaling the end of any pending row control gestures and allowing the presenter to finalize state.
- **must-set-return-key-equivalent**: The Done button MUST have Return (Carriage Return, `\r`) as its key equivalent, enabling keyboard activation.
- **must-support-accessibility-identification**: The component MUST assign accessibility identifiers to the dialog container (`<prefix>.dialog`) and Done button (`<prefix>.dialog.done`), where `<prefix>` is customizable at initialization and defaults to `"options"`.
- **must-respect-row-width-constraint**: The component MUST size each row to the full width of the dialog minus left and right insets, preventing row content from narrowing the dialog.
- **must-use-minimum-width-floor**: The component MUST apply a minimum width constraint (not an exact width) so that row content wider than the default width can expand the dialog; this allows the dialog to grow as needed while maintaining a baseline size.
- **may-hide-heading-when-nil**: The component MAY hide the heading label when the heading value is `nil`; the presenter is responsible for providing a heading if one is semantically required.

## Appearance

- **Corner radius**: Rounded corners applied via the `NSButton` bezel style (`.rounded`) on the Done button; dialog background is system-defined.
- **Padding (dialog insets)**: Top 18pt, left 20pt, bottom 8pt, right 20pt.
- **Padding (Done button spacing)**: 12pt above the Done button (from stack bottom), 16pt below the Done button (to dialog bottom), 20pt to the right edge.
- **Row spacing**: 16pt vertical spacing between rows and between the heading and first row.
- **Font**: The heading uses `ThemedLabel` with `role: .secondaryText` and `textRole: .button`; rows use caller-provided styling.
- **Background**: `ThemedBackgroundView` with `role: .windowBackground` for the dialog container; Done button uses default system button styling.
- **Foreground/Text**: Heading text color determined by the `secondaryText` role of `ThemedLabel`.
- **Border**: None on the dialog; system button styling on Done button.
- **Shadow**: None visible; system window/sheet presentation may add shadow depending on context.
- **Min/Max size**: Minimum width is 340pt by default (customizable via `width` parameter); width grows if rows require more space. Minimum height is determined by the sum of heading, rows, spacing, and Done button.

## States

| State | Appearance change |
|-------|------------------|
| Default | Dialog displays heading (if provided), rows, and Done button in vertical stack. |
| Heading hidden | Heading label is not visible; rows and Done button remain. |
| Row interaction | No change to dialog appearance; row changes propagate immediately. |
| Loaded off-screen | Dialog is removed from view hierarchy; `onDidClose` fires to allow cleanup. |

## Accessibility

- **Role/trait**: Dialog container is identified as `.dialog`; Done button is identified as a button with accessibility ID and key equivalent set.
- **Heading label**: When present, the heading is rendered as a label with `role: .secondaryText`, providing context about the dialog's purpose. When `nil`, the label is hidden.
- **Row accessibility**: Rows are passed in by the caller; the component does not impose accessibility requirements on row content. Callers are responsible for ensuring rows are accessible (labels, roles, traits).
- **Done button**: The button has a clear, descriptive label ("Done") and is keyboard-accessible via the Return key. The button's accessibility ID (`<prefix>.dialog.done`) allows UI tests to identify and interact with it.
- **Minimum tap target**: The Done button is sized according to system defaults for `NSButton` with `.rounded` bezel style, which typically exceeds 44×44pt on macOS.
- **Keyboard navigation**: The Return key activates the Done button; Tab and Shift+Tab move focus through interactive row controls as defined by each row.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| options-001 | must-accept-custom-rows | Initialize with `rows: [sliderView, popupView, textFieldView]` | All three row views are rendered in the dialog in vertical order. |
| options-002 | must-render-content-in-vertical-stack | Initialize with heading, 2 rows, Done button | Stack is vertical; heading renders above rows; rows render above Done button; spacing and alignment are consistent. |
| options-003 | must-support-dynamic-heading | Initialize with `heading: "Settings"`, then set `heading = nil` | Heading label is hidden; layout recalculates without heading space. |
| options-004 | must-support-dynamic-heading | Set heading to a new string after initialization | Heading label updates immediately to show the new text; dialog layout remains stable. |
| options-005 | must-provide-done-callback | Initialize with `onDone` callback, press Done button | `onDone` callback fires exactly once. |
| options-006 | must-provide-close-callback | Initialize with `onDidClose` callback, present dialog, then dismiss | `onDidClose` fires after dialog is off-screen. |
| options-007 | must-set-return-key-equivalent | Initialize and focus the Done button, press Return key | Done button action fires; Return key acts as equivalent to clicking Done. |
| options-008 | must-apply-changes-immediately | Add a slider row that triggers an action on value change, interact with slider | Row action fires immediately; no commit or cancel operation occurs. |
| options-009 | must-support-accessibility-identification | Initialize with `accessibilityPrefix: "prefs"` | Dialog container has accessibility ID `"prefs.dialog"`; Done button has ID `"prefs.dialog.done"`. |
| options-010 | must-respect-row-width-constraint | Add a row with a long label and trailing button | Row is sized to full dialog width minus insets; content does not exceed dialog width. |
| options-011 | must-use-minimum-width-floor | Add a row wider than 340pt (e.g., a popup with a long provider name) | Dialog expands to accommodate the row; minimum width is not restrictive. |
| options-012 | must-set-return-key-equivalent | Initialize with default accessibility prefix | Done button accessibility ID is `"options.dialog.done"`. |

## Edge Cases

- **Null or empty heading**: If `heading` is `nil`, the heading label is hidden and does not occupy space. Setting `heading` to `nil` after initialization hides the label; setting to a non-nil string shows it again.
- **Empty rows array**: If `rows` is an empty array, the dialog renders only the heading (if provided) and the Done button. No row spacing is applied.
- **Very long heading text**: The heading label may wrap or truncate depending on the dialog width and the length of the text. The caller is responsible for managing heading length.
- **Row gesture coalescing**: Rows that coalesce writes (e.g., a stepper ticking through a multi-step gesture) may have the last change pending when the dialog closes. The `onDidClose` callback fires when the dialog is off-screen, allowing the presenter to finalize any pending row state.
- **Dialog resizing during interaction**: As rows change (e.g., a text-size slider moves), the dialog window resizes dynamically behind the dialog. This is expected behavior and requires the presenter to support dynamic window sizing.
- **Multiple dialogs presented simultaneously**: Two or more `OptionsDialogViewController` instances can be presented at the same time (e.g., sheet + modal). Each must use a distinct `accessibilityPrefix` to avoid accessibility ID collisions.
- **Dialog dismissed while row gesture in progress**: If the dialog is dismissed while a row control (e.g., a slider) is in the middle of a continuous gesture, `onDidClose` fires to allow the presenter to terminate the gesture and release any resources held by the row.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `heading` | `String?` | `nil` | The optional heading text displayed at the top of the dialog. Settable after initialization; `nil` hides the heading. |
| `rows` | `[NSView]` | (required) | An array of NSView subclasses to render as dialog rows. Passed at initialization only. |
| `width` | `CGFloat` | `340` | The minimum (floor) width of the dialog in points. Dialog expands if row content requires more space. |
| `accessibilityPrefix` | `String` | `"options"` | Prefix for accessibility identifiers applied to the dialog and Done button. Allows multiple dialogs to coexist without ID collisions. |

## Deep Linking

Not applicable: This is an internal UI component used to present options dialogs within an app. It does not handle deep linking or URL routing.

## Localization

Not applicable: The component uses only the hardcoded string `"Done"` for the Done button. Localization of the heading and row content is the responsibility of the caller. The string `"Done"` is a platform-level button label not localized by this component.

## Accessibility Options

Not applicable: The component does not respond to system accessibility display options (Reduce Motion, Increase Contrast, Differentiate Without Color). Row content may respond to these options if implemented by the row views themselves; the dialog container does not enforce or configure them.

## Feature Flags

Not applicable: This component does not use or check feature flags. Feature flag logic is the responsibility of the presenter and the row implementations.

## Analytics

Not applicable: This component does not collect or emit analytics events. Analytics tracking (if needed) must be implemented by the caller or within individual row controls.

## Privacy

Not applicable: This component does not collect, store, or transmit any user data. Any data handled by rows is the responsibility of the row implementations.

## Logging

Not applicable: This component does not emit log messages. Logging (if needed) must be implemented by the caller or row implementations.

## Platform Notes

- **Source (AppKit/UIKit)**: `OptionsDialogViewController` is an NSViewController subclass implemented in `packages/apple/AgenticDeveloperToolkit/SourcesUI/macOS/Chrome/OptionsDialogViewController.swift`. It uses NSStackView for layout, NSButton for the Done button, and NSLayoutConstraint for sizing. The `ThemedLabel` and `ThemedBackgroundView` are AgenticDeveloperToolkit UI components that provide system-aware theming.
- **SwiftUI**: A SwiftUI version would wrap this NSViewController in a `NSViewControllerRepresentable`, or build an equivalent SwiftUI View using `VStack`, `GroupBox`, and `Button` with similar layout and callback patterns. State would be managed via `@State` or `@ObservedObject` rather than properties.
- **Compose (Android)**: A Compose implementation would use `Column` for vertical layout, optional `Text` for the heading, a `LazyColumn` or nested views for rows, and a `Button` at the bottom. Callbacks would use `MutableState<(() -> Unit)?>` or a `ViewModel`. Insets would be applied via `Modifier.padding()`.
- **AppKit / UIKit (cross-platform macOS/iOS)**: On iOS, this would use `UIViewController` with a `UIStackView` (vertical). The Done button would be styled as `UIButton.Configuration.plain()` or `.tinted()`. Presentation would use `UISheetPresentationController` or `UIAlertController` modal style. Sheet detection (`isModalInPresentation`) would replace the macOS window-sizing logic.
- **WinUI 3**: A WinUI 3 implementation would use `StackPanel` (Orientation="Vertical") as the root, `TextBlock` for the heading, nested controls or a `ItemsControl` for rows, and a `Button` with `Content="Done"` at the bottom. Sizing would use `MinWidth`, `HorizontalAlignment="Stretch"` on rows, and `IsEnabled` for the Done button. Window resizing would be handled via `SizeToContent="Width"` or binding the `ActualWidth` of the StackPanel to a property.

## Design Decisions

1. **Container-agnostic design**: The component makes no assumptions about how it is presented (sheet, modal window, custom container). This flexibility requires the presenter to provide the `onDone` and `onDidClose` callbacks, as the component cannot know how closing should be handled. This design avoids duplication of the layout logic across multiple presentation contexts.

2. **Immediate application of changes**: Rather than collecting row changes and applying them on a commit operation, the component requires rows to apply their changes as they are made. This is appropriate for settings dialogs where preview is useful and the cost of reverting a change is low. For dialogs with destructive or expensive operations, the caller must add confirmation logic in the row control itself.

3. **Dynamic heading support**: The `heading` property is settable and observable because dialogs named after their content (e.g., "Preferences for: FPS Meter") may be renamed while the dialog is presented. A frozen heading would misname the dialog. The property uses `didSet` to update the label and visibility in real-time.

4. **Minimum width as floor, not exact**: Using `>=` constraint on width allows rows wider than the default 340pt to expand the dialog. This prevents truncation of long labels or UI elements that should remain fully visible (e.g., a popup with many options). If an exact width were required, compression resistance on rows would be sacrificed, leading to truncated content.

5. **Accessibility identifiers as namespace**: The `accessibilityPrefix` parameter allows multiple dialogs to coexist on screen with distinct accessibility IDs, essential for UI testing scenarios. The prefix is applied to both the dialog and the Done button, creating a namespace that prevents ID collisions.

6. **Return key as Done button key equivalent**: The Return key is the standard macOS convention for confirming dialogs. Setting `keyEquivalent = "\r"` makes the Done button the default action for the Return key, improving keyboard navigation and accessibility.

7. **Row width constraint approach**: Each row is pinned to the stack width minus left and right insets using a single constraint per row. This ensures consistent indentation and allows row content to expand or contract with the dialog without special handling in individual row controls.

## Compliance

No compliance checks are defined for this component. Accessibility compliance (if required) is deferred to the row implementations and the platform's accessibility APIs.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
