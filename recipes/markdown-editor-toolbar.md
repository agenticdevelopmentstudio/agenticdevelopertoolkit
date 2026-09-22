---
id: 3600088a-a9f6-42ca-81db-43f0eb6ddd79
title: Markdown Editor Toolbar
domain: agenticdevelopercookbook://recipes/ui/markdown-editor-toolbar
type: ingredient
version: 1.1.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Horizontal toolbar for switching between markdown editor modes and accessing
  help and file import functions.
platforms:
- ios
- macos
tags:
- editor
- toolbar
- markdown
depends-on: []
related: []
references: []
---

# Markdown Editor Toolbar

## Overview

The Markdown Editor Toolbar is a horizontal chrome bar that hosts mode selection, help access, and file import controls for a markdown editor. The toolbar adapts its height and presentation style per platform (44pt on iOS, 32pt on macOS) and supports toggling individual button visibility, configurable editor modes, and theme application. A host that provides its own help or import UI can suppress the corresponding buttons.

## Behavioral Requirements

- **must-render-mode-selector**: The component MUST render a segmented control displaying all modes in `availableModes`.
- **must-hide-mode-selector-when-single-mode**: The component MUST hide the segmented control when `availableModes` contains fewer than 2 entries.
- **must-build-empty-mode-control-when-no-modes**: When `availableModes` is empty, the component MUST build the segmented control with zero segments (`rebuildModeControl` iterates the empty array and adds none) and MUST hide it under the fewer-than-2 rule above.
- **must-render-help-button**: The component MUST render a help button labeled "?" by default.
- **must-support-help-button-visibility**: The component MUST respect the `showsHelpButton` property and hide the button when set to false.
- **must-render-import-button**: The component MUST render an import button labeled "Open…" by default.
- **must-support-import-button-visibility**: The component MUST respect the `showsImportButton` property and hide the button when set to false.
- **must-fire-mode-change-callback**: The component MUST call `onModeChange` with the newly selected mode when the user taps a different mode segment.
- **must-sync-selection-on-mode-property-change**: The component MUST update the segmented control's selected segment when the `mode` property changes programmatically.
- **must-fire-help-callback**: The component MUST call `onSyntaxHelpRequested` when the user taps the help button.
- **must-fire-import-callback**: The component MUST call `onImport` when the user taps the import button.
- **must-apply-theme-background**: The component MUST apply the `elevatedSurface` color from a `SemanticPalette` to its background when `applyTheme(_:)` is called.
- **must-apply-theme-button-tint**: The component MUST apply the `accent` color from a `SemanticPalette` to the help and import buttons' tint color when `applyTheme(_:)` is called.

## Appearance

- **Height**: 44pt (iOS), 32pt (macOS)
- **Layout**: Horizontal stack
- **Spacing**: 8pt between items
- **Padding**: 4pt vertical, 8pt horizontal (applied to stack edges)
- **Background**: Semantic palette `elevatedSurface` color
- **Mode control width**: Intrinsic (segment widths determined by mode label text)
- **Button size**: System button size (intrinsic height constrained by stack alignment to center)
- **Mode control segments**: System segmented control styling (texturedRounded on macOS)
- **Buttons**: System button styling (rounded bezel on macOS, system type on iOS)
- **Spacer**: Flexible space between mode control and buttons, expands to fill available width

## States

| State | Appearance change |
|-------|------------------|
| Default | All controls rendered; colors from applied theme |
| Help button hidden | Help button and adjacent space removed; other controls unchanged |
| Import button hidden | Import button and adjacent space removed; other controls unchanged |
| Mode selector hidden | Mode control and spacing removed; buttons remain visible |
| Mode control with single item | Mode control hidden; buttons visible |
| No modes available | Segmented control built with zero segments (empty group), hidden via the fewer-than-2 rule; selected segment set to no-segment (iOS `UISegmentedControl.noSegment`) / -1 (macOS) |

## Accessibility

- **Mode control role**: Segmented control; MUST be labeled "Editor Mode" (macOS) or accessible via context.
- **Mode control accessibility ID** (macOS): "markdown-editor.mode"
- **Help button role**: Button; MUST be labeled "Markdown Syntax Help" (not just "?") on macOS.
- **Help button accessibility ID** (macOS): "markdown-editor.help"
- **Import button role**: Button; MUST be labeled "Open Markdown File" on macOS.
- **Import button accessibility ID** (macOS): "markdown-editor.import"
- **Minimum touch target size** (iOS): 44×44pt per Apple HIG.
- **Keyboard navigation**: All buttons MUST be keyboard-focusable and activatable via Return/Space (platform default).
- **Announcements**: Mode changes MUST be announced to assistive technology when the segmented control selection updates.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| toolbar-001 | must-render-mode-selector | availableModes = [.split, .raw] | Segmented control visible with two segments labeled "Split" and "Raw" |
| toolbar-002 | must-hide-mode-selector-when-single-mode | availableModes = [.split] | Segmented control hidden |
| toolbar-003 | must-render-help-button | No special config | Help button ("?") visible |
| toolbar-004 | must-support-help-button-visibility | showsHelpButton = false | Help button hidden |
| toolbar-005 | must-render-import-button | No special config | Import button ("Open…") visible |
| toolbar-006 | must-support-import-button-visibility | showsImportButton = false | Import button hidden |
| toolbar-007 | must-fire-mode-change-callback | User taps second mode segment | onModeChange callback fired with new mode |
| toolbar-008 | must-sync-selection-on-mode-property-change | mode = .raw (programmatically) | Segmented control's selected segment updates to match |
| toolbar-009 | must-fire-help-callback | User taps help button | onSyntaxHelpRequested callback fired |
| toolbar-010 | must-fire-import-callback | User taps import button | onImport callback fired |
| toolbar-011 | must-apply-theme-background | applyTheme(palette) called | Background color matches palette.elevatedSurface |
| toolbar-012 | must-apply-theme-button-tint | applyTheme(palette) called | Help and import button tint colors match palette.accent |

## Edge Cases

- **Empty availableModes**: `rebuildModeControl` builds a segmented control with zero segments (the `for` loop over an empty array adds none) and hides it via the same `availableModes.count < 2` check used for the single-mode case. `syncSelection` finds no match for `mode` in the empty array, so the selected segment is set to no-segment (iOS `UISegmentedControl.noSegment`) / -1 (macOS). The help and import buttons are unaffected.
- **Mode not in availableModes**: When `mode` is set to a value not present in `availableModes`, the segmented control's selected segment is set to "no segment" (UISegmentedControl.noSegment / -1). The modeControl does not update unless the selection index is within availableModes.indices.
- **Mode change during presentation**: On iOS, help is presented with `modalPresentationStyle = .formSheet`, a modal presentation that blocks interaction with the presenting view; the mode control cannot be tapped while the sheet is showing, so a mode change during presentation cannot occur. On macOS, `popover.behavior = .transient`, and no code path in `modeChanged()` touches `popover` — tapping the mode control is an interaction outside the popover, which AppKit's transient behavior closes automatically as a side effect of the click; the mode change itself proceeds unaffected.
- **Theme applied before toolbar added to window** (macOS): The `presentSyntaxHelp` method guards against calling `NSPopover.show(relativeTo:of:)` when the help button has no window. If theme is applied before the toolbar is added to a window hierarchy, the background color layer will be created but may not render until the window is established.
- **Multiple theme applications**: If `applyTheme(_:)` is called multiple times, each call updates the background color and button tint colors without side effects.
- **Null callbacks**: Callbacks (`onModeChange`, `onImport`, `onSyntaxHelpRequested`) are optional and default to nil. Tapping a button when the callback is nil results in no action.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| availableModes | [MarkdownEditorMode] | MarkdownEditorMode.allCases | Array of modes the user can select from |
| mode | MarkdownEditorMode | .split | Currently selected editor mode |
| showsHelpButton | Bool | true | Whether the help button is visible |
| showsImportButton | Bool | true | Whether the import button is visible |
| onModeChange | ((MarkdownEditorMode) -> Void)? | nil | Callback fired when mode selection changes |
| onImport | (() -> Void)? | nil | Callback fired when import button is tapped |
| onSyntaxHelpRequested | (() -> Void)? | nil | Callback fired when help button is tapped |

## Deep Linking

Not applicable: The toolbar does not respond to deep links; it is a sub-component that receives its state from a parent editor or container.

## Localization

| String Key | Default (en) | Context |
|-----------|-------------|---------|
| markdown-editor.mode-label | (derived from MarkdownEditorMode enum) | Segmented control segment labels for each mode |
| markdown-editor.help-label | "Markdown Syntax Help" | Accessibility label for help button (macOS) |
| markdown-editor.import-label | "Open Markdown File" | Accessibility label for import button (macOS) |

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | No animations are used by the toolbar itself; presentation of help content respects the presenter's motion preferences. |
| Increase Contrast | Not applicable: The toolbar uses semantic colors from the palette; the host environment applies high-contrast palettes. |
| Differentiate Without Color | Not applicable: All controls are differentiated by label and role, not color alone. |

## Feature Flags

Not applicable: The toolbar is not gated by feature flags.

## Analytics

Not applicable: The toolbar does not fire analytics events directly; hosts that embed it are responsible for logging user interactions if needed.

## Privacy

- **Data collected**: None. The toolbar does not collect, store, or transmit any user data.

## Logging

Not applicable: The toolbar does not emit logging output in its current implementation.

## Platform Notes

- **Source platform (UIKit/AppKit)**: Separate implementations in `packages/apple/AgenticDeveloperToolkit/SourcesUI/iOS/Markdown/MarkdownEditorToolbar.swift` (UIView) and `packages/apple/AgenticDeveloperToolkit/SourcesUI/macOS/Markdown/MarkdownEditorToolbar.swift` (NSView). Both expose the same property and callback API; presentSyntaxHelp differs by platform (UIViewController.present on iOS, NSPopover on macOS).
- **SwiftUI**: A SwiftUI wrapper around the UIView/NSView would use `UIViewRepresentable` (iOS) or `NSViewRepresentable` (macOS) to embed the native toolbar. Callbacks are mapped to SwiftUI state updates via `@State` or parent-driven properties.
- **Compose (Android)**: Start with a `Row` layout containing a `SegmentedButton` group for modes, a `Spacer` modifier with `Modifier.weight(1f)`, and `IconButton` or `Button` composables for help and import. Mode changes call a callback passed as a lambda. Visibility controlled by simple conditional rendering.
- **AppKit / UIKit**: Directly use the NSView/UIView classes provided. Apply theme via `applyTheme(_:)` after initialization. Wire callbacks to your presentation logic.
- **WinUI 3**: Build from `RadioButtons` control (UWP RadioButton style alternative) or a custom segmented button group for mode selection, followed by a flexible spacer and `AppBarButton` controls for help and import. Handle mode changes via `SelectionChanged` events. Apply theme colors via `Resources` (theme overrides) or direct property assignment. Help presentation uses a `ContentDialog` or `TeachingTip` instead of NSPopover.

## Design Decisions

- **Fixed height per platform**: iOS uses 44pt (Apple HIG standard button height) and macOS uses 32pt (macOS toolbar standard). Different heights reflect platform conventions, not functional differences.
- **Segmented control hidden when single mode**: When only one mode is available, hiding the control reduces visual clutter and simplifies the toolbar. The mode value is still tracked internally and can be changed programmatically.
- **Spacer for right-alignment**: A flexible spacer between the mode control and buttons ensures buttons align to the right edge, following common toolbar patterns.
- **Accessibility labels on macOS**: The "?" symbol is ambiguous for screen readers; macOS implementations set explicit accessibility labels. iOS relies on button title inference by the system or must be similarly labeled in a real implementation.
- **Popover vs. modal for help**: macOS uses a transient NSPopover for contextual help (dismisses on blur), while iOS uses a modal sheet. This reflects platform norms for supplementary information windows.
- **Optional callbacks**: Callbacks are not required; a host can ignore mode changes by not setting `onModeChange`, or suppress the help button entirely via `showsHelpButton = false`.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| Accessibility labels present (macOS) | passed | Accessibility |
| Minimum touch target (iOS 44×44) | passed | Accessibility |
| Keyboard navigation support | passed | Accessibility |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation from macOS and iOS source |
| 1.1.0 | 2026-09-22 | Claude Sonnet 5 | Settled the three open review points from source: empty availableModes builds a hidden zero-segment control (traced to rebuildModeControl/syncSelection), and mode changes cannot occur during iOS's modal help sheet and only incidentally close macOS's transient popover |
