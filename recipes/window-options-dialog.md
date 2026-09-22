---
id: 9c1e6915-44ec-435e-a159-57b80b455698
title: Window Options Dialog
domain: agenticdevelopertoolkit://recipes/window-options-dialog
type: ingredient
version: 1.0.0
status: review
language: en
created: 2026-09-22
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: 'Modal dialog for window-specific appearance settings: text size, transparency,
  floating behavior. Built dynamically by the host, positioned center-screen, maintains
  host window level.'
platforms:
- swift
- macos
tags:
- ui
- modal
- window-chrome
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Window Options Dialog

## Overview

The Window Options Dialog is a modal dialog system for managing window-specific appearance settings — distinct from application-wide settings. It is presented via a gear button positioned in the window's title bar chrome or custom layout. The dialog itself is app-modal (the window behind remains visible and interactive but does not accept text input), centered on the screen (not anchored to the gear), and dynamically built at open time from a host-supplied closure. This design allows live updates to controls as underlying state changes and ensures the dialog follows the host window's level hierarchy.

The component comprises four related pieces: the dialog manager (`WindowOptionsDialog`), an optional slider with live caption (`WindowOptionsSlider`), an optional toggle/checkbox (`WindowOptionsToggle`), and an optional "Reset to Defaults" button (`WindowOptionsResetButton`).

## Behavioral Requirements

- **must-present-modal**: The dialog MUST be presented as an app-modal window, blocking interaction with the host window's content until dismissed, while keeping the host window visible and live.
- **must-center-on-screen**: The dialog MUST be positioned at the center of the screen the host window is on, not anchored to the gear button or positioned relative to the host window's frame.
- **must-maintain-host-level**: The dialog MUST adopt the host window's level (e.g., `.normal`, `.floating`) at open time and MUST follow level changes made to the host while the dialog is open, remaining at the same level for the duration of the session.
- **must-build-controls-at-open-time**: Controls MUST be built from the host's closure when the dialog is opened, not at construction time, allowing the host to read live state.
- **must-rebuild-on-title-change**: When the `title` property changes while the dialog is open, the dialog MUST rebuild its controls to reflect any state changes related to the new title.
- **must-support-toggle**: The dialog MUST support a `toggle()` method that opens the dialog if closed and closes it if open.
- **must-support-present-close**: The dialog MUST support `present()` to open and `close()` to close independently.
- **must-track-shown-state**: The dialog MUST track whether it is currently shown via the read-only `isShown` property.
- **gear-button-must-be-borderless**: The gear button MUST be borderless (`bezelStyle = .accessoryBarAction`, `isBordered = false`).
- **gear-button-must-use-gearshape-symbol**: The gear button MUST display the system `gearshape` symbol as its image, `imageOnly` position.
- **gear-button-must-tint-secondary-text**: The gear button's content tint MUST match the theme's secondary text color and MUST respond to theme changes.
- **gear-button-must-have-tooltip**: The gear button MUST have a tooltip set (default "Window appearance", customizable).
- **dialog-window-must-have-titlebar-closable**: The dialog window MUST have a title bar with the host-provided title and MUST have a close button. The close button MUST route through the component's `close()` method.
- **dialog-window-must-be-undecorated-except-title**: The dialog window style MUST be `.titled` and `.closable` only, with no other decorations.
- **gear-button-must-be-public**: The `gearButton` property MUST be public so the host can add it to the window's chrome via `makeTitlebarAccessory()` or custom layout.
- **must-provide-titlebar-accessory-helper**: The component MUST provide a `makeTitlebarAccessory()` method to position the gear button in a right-aligned title bar accessory, optionally with leading views.
- **titlebar-accessory-must-right-align**: The title bar accessory MUST right-align the gear button using autoresizing masks and `NSTitlebarAccessoryViewController` with `.right` layout attribute.
- **titlebar-accessory-must-accept-leading-views**: The `makeTitlebarAccessory()` method MUST accept an optional array of leading views to place left of the gear button, with configurable spacing (6pt default) and centered vertical alignment.
- **must-close-on-window-close-button**: When the dialog's close button is clicked, the dialog MUST close and the modal session MUST end. Clicking the button MUST NOT close the window itself — only dismiss the dialog.
- **must-reposition-on-screen-change**: If the host window moves to a different screen while the dialog is open, the dialog's position MUST remain at the current screen's center.
- **must-support-configurable-width**: The dialog body width MUST be configurable at construction time (default `OptionsDialogViewController.defaultWidth`), allowing hosts with wider controls to avoid cramping.
- **slider-must-update-caption-continuously**: The slider's caption MUST update continuously as the user moves the slider, reflecting the value via the host-supplied `caption` closure.
- **slider-must-constrain-value-to-range**: The slider's value MUST be constrained to the provided range; initial values outside the range MUST be clamped to the valid bounds.
- **slider-must-call-onchange**: When the slider moves, the slider MUST call the `onChange` callback with the new value.
- **slider-must-support-custom-range**: The slider MUST support a custom closed range (e.g., 0.0...100.0, 1.0...10.0).
- **toggle-must-update-state**: When the user clicks the checkbox, the toggle's `isOn` property MUST reflect the new state and the `onChange` callback MUST be called.
- **toggle-isOn-must-be-settable**: The `isOn` property MUST be settable from outside, allowing the host to update the displayed state without triggering `onChange` (one-way assignment).
- **toggle-must-support-accessibility-id**: The toggle MUST provide a `checkboxAccessibilityID()` method to set an accessibility identifier on the underlying checkbox, not the wrapper view.
- **reset-button-must-have-standard-title**: The "Reset to Defaults" button MUST use the static `WindowOptionsResetButton.title` string for consistency across windows.
- **reset-button-must-be-centered**: The reset button MUST be centered horizontally under the rows, not stretched to the full dialog width.
- **reset-button-must-be-rounded**: The reset button MUST use `bezelStyle = .rounded`.
- **reset-button-must-call-onreset**: When the reset button is clicked, it MUST call the host-supplied `onReset` closure.
- **dialog-must-not-reenter**: If `present()` is called when the dialog is already open, or if `beginDialog()` is called when one already exists, the call MUST return `nil` (a no-op). The dialog MUST not allow multiple instances.
- **dialog-must-end-modal-session**: When `close()` is called, the modal session MUST be ended via `NSApp.stopModal()` only if the dialog is the current modal window. Calling `close()` when the dialog is not open MUST be a no-op.

## Appearance

- **Gear Button**:
  - Bezel style: `.accessoryBarAction` (borderless, toolbar-appropriate)
  - Image: `NSImage(systemSymbolName: "gearshape")`
  - Image position: `.imageOnly` (no text)
  - Content tint color: `palette.nsColor(.secondaryText)`, responds to theme changes
  - Tooltip: "Window appearance" (default, customizable)

- **Dialog Window**:
  - Style: `.titled, .closable` (no resize handle, no minimize/maximize)
  - Title: Provided by host at construction
  - Background: `palette.windowBackgroundColor` (theme-aware)
  - Width: Configurable via `width` parameter, default `OptionsDialogViewController.defaultWidth`
  - Position: Centered horizontally and vertically on the screen

- **Slider** (`WindowOptionsSlider`):
  - Title font: `.systemFont(ofSize: .systemFontSize)` (standard control size)
  - Caption font: `.systemFont(ofSize: .systemFontSize)` (standard size)
  - Caption color: `.secondaryLabelColor`
  - Caption alignment: Right-aligned
  - Layout: Title and caption in horizontal stack at top, slider below
  - Title-caption spacing: 6pt horizontal gap with flexible distribution
  - Slider-caption spacing: 6pt vertical gap

- **Toggle** (`WindowOptionsToggle`):
  - Checkbox font: `.systemFont(ofSize: .systemFontSize)` (standard control size)
  - Checkbox state: `.on` / `.off`
  - Layout: Checkbox only (title embedded in checkbox)

- **Reset Button** (`WindowOptionsResetButton`):
  - Bezel style: `.rounded`
  - Title: `"Reset to Defaults"` (static, consistent)
  - Horizontal alignment: Centered under rows
  - Margin: Leading and trailing constraints ensure it does not exceed dialog width but allows centering

## States

| Component | State | Appearance Change |
|-----------|-------|------------------|
| Dialog | Hidden (closed) | Not visible, `isShown == false` |
| Dialog | Shown (open) | Visible and focused, `isShown == true`, title bar active |
| Gear Button | Default | Borderless, secondary text tint |
| Gear Button | Hover | Secondary text tint with slight highlight (standard AppKit button behavior) |
| Gear Button | Pressed | Highlighted momentarily when tapped |
| Slider | Moving | Caption updates in real time as slider value changes |
| Slider | At minimum | Caption shows minimum value result |
| Slider | At maximum | Caption shows maximum value result |
| Toggle | On | Checkbox displays checkmark, `isOn == true` |
| Toggle | Off | Checkbox empty, `isOn == false` |
| Reset Button | Ready | Rounded bezel, clickable |
| Reset Button | Hover | Slight highlight (standard AppKit button behavior) |
| Reset Button | Pressed | Highlighted momentarily when clicked |

## Accessibility

- **Dialog Window**:
  - Role: Modal dialog (AppKit window delegate handles modal session)
  - Label: Window title (provided by host)
  - Keyboard: ⌘W closes the dialog; Tab navigates between controls; Enter/Space activate buttons

- **Gear Button**:
  - Role: Button
  - Label: Tooltip "Window appearance" (set via `accessibilityDescription` in `NSImage`)
  - Action: Tap/click opens or closes the dialog

- **Slider** (`WindowOptionsSlider`):
  - Role: Slider
  - Labels: Title label above describes the setting; caption label (right-aligned) announces current value
  - Keyboard: Left/Right arrow keys adjust value continuously
  - Announce: Caption updates as value changes, providing live feedback to screen readers via the label text property update

- **Toggle** (`WindowOptionsToggle`):
  - Role: Checkbox
  - Label: Checkbox title text
  - Keyboard: Space toggles state
  - State announcement: Checkbox state (on/off) announced by screen reader; custom accessibility ID can be set

- **Reset Button** (`WindowOptionsResetButton`):
  - Role: Button
  - Label: "Reset to Defaults"
  - Keyboard: Space or Enter activates
  - Action: Tapping resets all window options to defaults

- **Minimum tap target**: All interactive elements (gear button, slider, checkbox, reset button) MUST be at least 44×44pt to meet macOS Human Interface Guidelines minimum target size. Gear button is typically 16×16 symbol but sits in a 28pt title bar accessory. Checkbox and button are standard AppKit sizes (typically 16–20pt), meeting or exceeding 44pt when including surrounding spacing.

- **Accessibility Prefix**: Dialog rows use the prefix `"window.options"` for accessibility identifiers, ensuring unique and meaningful IDs when there are multiple window option dialogs.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| dialog-001 | must-present-modal | Call `present()` on `WindowOptionsDialog` | Dialog appears as app-modal; host window remains visible; typing is blocked; mouse events pass to host window |
| dialog-002 | must-center-on-screen | Open dialog on a screen; verify position | Dialog frame center matches screen visible frame center |
| dialog-003 | must-maintain-host-level | Host window at `.normal`, dialog open; change host to `.floating` | Dialog level changes to `.floating` while open |
| dialog-004 | must-build-controls-at-open-time | Create dialog with `makeControls` closure that reads current time; open, note time; close; reopen | Reopened dialog shows current time, not cached time from construction |
| dialog-005 | must-rebuild-on-title-change | Dialog open; change `title` property | Window title updates; `rebuildControls()` is called; controls reflect new state |
| dialog-006 | must-support-toggle | Dialog closed; call `toggle()` | Dialog opens; `isShown == true` |
| dialog-007 | must-support-toggle (close) | Dialog open; call `toggle()` | Dialog closes; `isShown == false` |
| dialog-008 | must-support-present-close | Dialog closed; call `present()`; then `close()` | Dialog opens then closes without re-entering the modal loop (using `beginDialog()` and `endDialog()` internally) |
| dialog-009 | must-track-shown-state | Check `isShown` before/after `present()` | `isShown == false` before, `isShown == true` after present, `isShown == false` after close |
| gear-010 | gear-button-must-be-borderless | Call `makeGearButton()`; inspect `isBordered` and `bezelStyle` | `isBordered == false`, `bezelStyle == .accessoryBarAction` |
| gear-011 | gear-button-must-use-gearshape-symbol | Call `makeGearButton()`; inspect image | Image symbol name is "gearshape", `imagePosition == .imageOnly` |
| gear-012 | gear-button-must-tint-secondary-text | Call `makeGearButton()` in light and dark themes | Content tint color matches `palette.nsColor(.secondaryText)` in each theme |
| gear-013 | gear-button-must-have-tooltip | Call `makeGearButton(tooltip: "Custom Tip")`; inspect `toolTip` | `toolTip == "Custom Tip"` |
| window-014 | dialog-window-must-have-titlebar-closable | Open dialog; inspect window | Window has `.titled` and `.closable` style; close button visible; window title == dialog title |
| window-015 | must-close-on-window-close-button | Dialog open; click window close button | Dialog closes, modal session ends, `isShown == false` |
| window-016 | must-support-configurable-width | Create dialog with `width: 400`; open | Dialog body width is 400pt |
| titlebar-017 | must-provide-titlebar-accessory-helper | Call `makeTitlebarAccessory(leading: [view1, view2])`; inspect result | Returns `NSTitlebarAccessoryViewController` with `.right` layout attribute; container has `minXMargin` autoresizing; gear button is rightmost; leading views are to its left |
| slider-018 | slider-must-update-caption-continuously | Create slider with range 0...100 and caption showing percentage; move slider | Caption updates in real time as slider moves; each position shows correct percentage |
| slider-019 | slider-must-constrain-value-to-range | Create slider with range 10...50; initialize with value 60 | Initial value clamped to 50 |
| slider-020 | slider-must-call-onchange | Create slider; move slider; verify callback | `onChange` called for each movement with new value |
| toggle-021 | toggle-must-update-state | Create toggle `isOn: false`; click checkbox | `isOn` becomes true, `onChange(true)` called |
| toggle-022 | toggle-isOn-must-be-settable | Toggle open; set `toggle.isOn = true` from outside | Checkbox displays checked state; `onChange` is NOT called |
| toggle-023 | toggle-must-support-accessibility-id | Create toggle; call `checkboxAccessibilityID("my-id")`; inspect checkbox | Checkbox accessibility identifier == "my-id", not the wrapper view |
| reset-024 | reset-button-must-have-standard-title | Create reset button; inspect title | Button title == `WindowOptionsResetButton.title` == "Reset to Defaults" |
| reset-025 | reset-button-must-call-onreset | Create reset button; click it | `onReset` callback is called |
| dialog-026 | must-not-reenter | Dialog open; call `beginDialog()` again | Returns `nil`, no second dialog created |
| dialog-027 | must-end-modal-session | Dialog open in modal session; call `close()` | `NSApp.stopModal()` called only once; modal session ends |

## Edge Cases

- **Dialog already open**: Calling `present()` when `isShown == true` is a no-op because the modal loop is already running. A second call to `beginDialog()` returns `nil`. Calling `toggle()` when open closes the dialog.

- **Close called when dialog is not open**: A no-op; no exception thrown. `close()` safely handles `dialogWindow == nil`.

- **Title changed while dialog open**: The dialog rebuilds controls via `rebuildControls()`, ensuring controls reflect state associated with the new title. This is necessary for windows whose title changes (e.g., a tab-like pane named by its content).

- **Host window level changes during modal session**: The dialog observes `NSWindow.didUpdateNotification` on the host and updates its own level on every event loop pass, ensuring the dialog stays in sync. This prevents the dialog from appearing behind its host when the host is raised to `.floating`.

- **Host window closed while dialog is open**: The host window reference (`gearButton.window`) becomes nil. The dialog remains open but subsequent calls to `hostLevel` or `position()` default to `NSScreen.main` or `window.center()`.

- **Dialog window moved to different screen**: The gear button's screen is sampled at the time of positioning. Subsequent calls to `position()` use the current screen if the host window moved.

- **Multiple dialogs in same window**: Each window can have multiple gear buttons with their own `WindowOptionsDialog` instances, each managing a separate modal dialog. The dialogs do not interfere if opened sequentially.

- **Concurrent modifications to title or controls**: All updates occur on `@MainActor`, so thread safety is managed by the actor isolation.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `title` | `String` | (required) | The dialog window's title, displayed in the title bar. Settable at runtime. |
| `tooltip` | `String` | `"Window appearance"` | Tooltip for the gear button, set on construction. |
| `width` | `CGFloat` | `OptionsDialogViewController.defaultWidth` | Width of the dialog's body, allowing hosts with wider controls to avoid cramping. |
| `makeControls` | `@MainActor () -> [NSView]` | (required) | Closure that returns an array of row views (sliders, toggles, etc.) to display in the dialog. Called at open time so controls read live state. |
| `gearButton` | `NSButton` (read-only public) | Auto-created | The button to be placed in the window's chrome, created and configured by the component. |
| `isShown` | `Bool` (read-only) | `false` initially | Whether the dialog is currently visible. |

## Deep Linking

Not applicable: The window options dialog is a window-local configuration panel, not a top-level navigation destination. Deep links do not target option dialogs; they target the window or view the dialog belongs to.

## Localization

| String Key | Default (en) | Context |
|-----------|-------------|---------|
| `"Window appearance"` | `"Window appearance"` | Gear button tooltip; would typically be localized per host app. |
| `"Reset to Defaults"` | `"Reset to Defaults"` | Reset button title; shared across all window option dialogs in the app. |

All other user-facing strings (control titles, captions) are supplied by the host via `makeControls()` and are the host's responsibility to localize.

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | Not applicable: The dialog itself has no animations. Host-supplied controls (sliders, toggles) SHOULD respect Reduce Motion if they animate state changes. |
| Increase Contrast | Not applicable: The dialog uses system colors (`palette.windowBackgroundColor`, `.secondaryText`). System color palettes adapt to Increase Contrast settings automatically. |
| Differentiate Without Color | Not applicable: The dialog does not rely on color alone to convey state. Checkboxes use checkmarks; sliders are labeled. |

## Feature Flags

Not applicable: The window options dialog is a core UI component without feature-flag control. A host application may guard the entire gear button/dialog behind an app-level feature flag if it chooses.

## Analytics

Not applicable: Analytics events are the responsibility of the host application, which owns the dialog's `makeControls()` closure and can instrument individual controls (sliders, toggles, reset button) as needed.

## Privacy

Not applicable: The window options dialog does not collect, store, or transmit any data. The host's `makeControls()` closure reads and writes the host's own settings, which are subject to the host app's privacy policy.

## Logging

Subsystem: (host-supplied, typically app bundle ID) | Category: `WindowOptionsDialog`

| Event | Level | Message |
|-------|-------|---------|
| Dialog opened | debug | `WindowOptionsDialog: dialog opened with title "{title}"` |
| Dialog closed | debug | `WindowOptionsDialog: dialog closed` |
| Controls rebuilt | debug | `WindowOptionsDialog: controls rebuilt for title "{title}"` |
| Host level changed | debug | `WindowOptionsDialog: host level changed from {old} to {new}` |

Logging is optional; the component does not emit these messages by default. A host may inject logging at the points described if needed for debugging.

## Platform Notes

- **Source Platform (Apple)**: Implemented in `packages/apple/AgenticDeveloperToolkit/SourcesUI/macOS/Chrome/WindowOptionsDialog.swift`. The component is AppKit-only (`@MainActor`, `NSObject`, `NSWindow`, `NSButton`, etc.) and targets macOS. `WindowOptionsSlider`, `WindowOptionsToggle`, and `WindowOptionsResetButton` are companion views for composing common dialog rows. The source relies on `OptionsDialogViewController` (not shown here) for the dialog body layout and `ThemePaletteObserver` for theme-aware colors.

- **SwiftUI**: Wrap `WindowOptionsDialog` in `NSViewControllerRepresentable` to present the modal dialog from SwiftUI. The `gearButton` property can be converted to a `Button` view via `SwiftUI.Button` with a system image `"gearshape"`. For controls, use `SwiftUI.Slider`, `SwiftUI.Toggle`, and a standard `Button` for reset, binding them to SwiftUI state and calling the `onChange` callbacks from the host's state updates.

- **Compose**: Use `AlertDialog` or a custom `Dialog` composable as the container. Replace `NSButton` with Material 3 `Button` (or `OutlinedButton` for secondary actions). Slider becomes `Slider` in Compose (with a `Text` label showing the current value). Toggle becomes `Checkbox` or `Switch`. Reset button is a standard `Button` with the same title. The dialog should be app-modal (via `Dialog`'s properties) and centered on screen. Window-level state synchronization is handled via Android `WindowManager` or Compose's `Dialog` composable positioning.

- **AppKit / UIKit**: On macOS, `WindowOptionsDialog` is directly usable as described. On iOS, the component would need significant adaptation: modal presentation replaces app-modal windows (`UIModalPresentationStyle`). The gear button becomes a standard `UIBarButtonItem` in the navigation bar. Sliders, toggles, and buttons use iOS standard sizes and spacing. Consider `UITableViewController` or `UICollectionViewController` for the dialog body to support scrolling on smaller screens. The "Reset to Defaults" button would be a full-width row at the bottom (possibly in a footer section).

- **WinUI 3**: Use `ContentDialog` as the modal container (`IsPrimaryButtonEnabled`, `SecondaryButtonText`, and `CloseButtonText` for control flow, or a custom content with buttons). The gear button becomes a `Button` with icon (use `Segoe MDL2 Assets` font symbol or a custom glyph equivalent to "gearshape", approximately U+E713 for the settings/gear icon). Dialog positioning: use `ContentDialogPlacementMode.InPlace` or custom positioning to center on the active screen's work area. Slider is `Slider` (WinUI) with a `TextBlock` label showing the caption. Toggle is `CheckBox` with inline label text. Reset button is a standard `Button` at the dialog footer. For window-level synchronization, hook the host window's level-change events and update the dialog's Z-order accordingly (via `AppWindow.SetPresenter()` or overlay state management).

## Design Decisions

- **App-modal dialog instead of popover**: A popover anchored to the gear button would move as the window resizes (sliders change size). An app-modal dialog centered on the screen remains stable during interactive adjustments, providing a better user experience when live slider adjustments change the window's dimensions.

- **Controls built at open time**: Building controls from a closure at dialog open time (not construction time) ensures they reflect live state, even if other UI or keyboard shortcuts have changed settings while the dialog was closed. This avoids stale UI and prevents the need for complex state synchronization.

- **Title settable at runtime**: Paned or tabbed windows may change their displayed name based on content. Allowing the title to be updated and triggering a control rebuild ensures the dialog's context remains correct.

- **Host window level tracking**: The dialog matches the host window's level so that options for a floating or docked window remain accessible. Without this, a dialog could appear behind its own window if the host's level changed, confusing the user.

- **Configurable dialog width**: Not all options are simple checkboxes and sliders. Some dialogs may need wider rows (e.g., a picker or a button row). Configurable width avoids over-constraining the layout and supports diverse use cases.

- **Static gear button factory**: `makeGearButton()` is a static method and independent of the dialog instance so that a host window without a full dialog (e.g., one that shows options in a menu instead) can still use the same, consistent gear button appearance.

- **Close button routes through dialog logic**: Letting the close button directly close the window would bypass the modal session end logic, leaving the app in a modal loop with no window on screen. Routing it through `close()` ensures clean teardown.

- **Reset button centered, not stretched**: Full-width reset button would visually group with the control rows above, making it look like another option rather than a separate action. Centering it distinguishes its role.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| [macOS target size](agenticdevelopercookbook://compliance/accessibility#touch-target-size) | passed | Accessibility |
| [macOS window management](agenticdevelopercookbook://compliance/platform-guidelines#macos-window-modal-dialog) | passed | Platform Guidelines |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation from WindowOptionsDialog.swift source |
