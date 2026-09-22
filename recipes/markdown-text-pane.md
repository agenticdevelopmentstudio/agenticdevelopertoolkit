---
id: 61f589a9-d32f-4e9b-85db-1f9aa0eee009
title: Markdown Text Pane
domain: agenticdevelopercookbook://recipes/ui/markdown-text-pane
type: ingredient
version: 1.1.0
status: review
language: en
created: 2026-09-22
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A scrollable plain-text editor pane with theme support and unified macOS/iOS
  API.
platforms:
- swift
tags:
- text-input
- editor
- markdown
depends-on: []
related: []
references: []
---

# Markdown Text Pane

## Overview

The Markdown Text Pane is a lightweight container that wraps platform-native text editing controls (`NSTextView` on macOS, `UITextView` on iOS) with a unified API. It hosts plain-text editing with undo support, optional find/search capability, and theme application via semantic color palettes. The component is designed for document surfaces that remain in focus for extended reading and editing sessions, as opposed to inline or transient input fields.

## Behavioral Requirements

- **must-initialize-with-editability**: The component MUST initialize with an `editable` parameter that determines whether text editing is allowed (true = editable, false = read-only).
- **must-provide-editability-property**: The component MUST provide an `isEditable` property that reads and modifies the underlying text view's edit mode at runtime.
- **must-report-text-changes**: The component MUST fire the `onTextChange` callback with the current plain-text content whenever the user edits the text. The callback receives the complete current string, not a delta.
- **must-not-fire-change-on-programmatic-set**: Setting the `text` property MUST NOT trigger the `onTextChange` callback. Programmatic text assignment exists to enable controllers that render from `onTextChange` to update the pane without re-entrancy loops.
- **must-provide-text-property**: The component MUST provide a `text` property that reads and sets the pane's plain-text content. Reading returns the complete string; empty panes return an empty string (never null).
- **must-support-attributed-text**: The component MUST support reading and setting attributed (styled) text via `attributedText` (read-only) and `setAttributedText(_:)` (write).
- **must-support-focus**: The component MUST provide a `focus()` method that moves keyboard focus to the underlying text view and returns a boolean indicating success. A pane without focus does not receive keystrokes because the internal text view is private.
- **must-support-theme**: The component MUST accept a `SemanticPalette` via `applyTheme(_:)` to customize colors and font. Theme application MUST update: background, text foreground, cursor color, and code font (not body font).
- **must-disable-smart-substitutions-ios**: On iOS, the component MUST disable `autocorrectionType`, `smartQuotesType`, and `smartDashesType` to prevent automatic text transformations inappropriate for code/markdown content.
- **must-disable-smart-substitutions-macos**: On macOS, the component MUST disable automatic quote substitution, dash substitution, spelling correction, and text replacement to prevent automatic text transformations.
- **must-allow-undo-macos**: On macOS, the component MUST support the undo system (`allowsUndo = true` on the text view).
- **must-use-plain-text-mode**: The component MUST operate in plain-text mode. Rich text editing, markdown parsing, and styled rendering are explicitly not in scope.
- **must-scroll-vertically**: The component MUST support vertical scrolling. On macOS, the scroll view provides this; on iOS, the text view provides built-in scrolling.
- **must-hide-scrollers-macos**: On macOS, the scroll view MUST use overlay scrollers that auto-hide when not in use. The scroll view MUST have no visible border.
- **must-bounce-vertically-ios**: On iOS, the text view MUST bounce when scrolled past the content end.
- **must-use-8pt-insets**: The component MUST apply 8pt insets (edges) around the text content, matching the document-surface intent rather than the tighter 6pt used by scratch/quick-note style inputs.

## Appearance

- **Corner radius**: None; square edges
- **Padding (insets)**: 8pt on all edges (top, left, bottom, right)
- **Font**: Semantic code font from the applied theme (via `applyTheme(palette.font(.code))`)
- **Background**: Window background semantic color from the applied theme
- **Foreground/Text**: Primary text semantic color from the applied theme
- **Border**: None
- **Shadow**: None
- **Min/Max size**: No enforced constraints; size is determined by the parent container

## States

| State | Appearance change |
|-------|------------------|
| Default | Text view displays with active cursor visible |
| Read-only (not editable) | Cursor hidden; selection still visible; text still scrollable |
| Focused | Cursor blinks and accepts keyboard input |
| Unfocused | Cursor hidden; text and selection remain visible |
| Themed | Background, text color, and cursor color updated per palette |

## Accessibility

- **Role/trait**: Text area / rich text input (depending on platform accessibility framework)
- **Label requirements**: The pane itself has no built-in label. The parent controller or container is responsible for providing an accessible label for the text area via standard platform mechanisms (e.g., `UIAccessibility` label on iOS, `NSAccessibility` title on macOS).
- **Announce state changes**: The read-only state transition (toggling `isEditable`) is not automatically announced. The parent is responsible for signaling mode changes to accessibility systems if needed.
- **Minimum tap target**: On iOS, the text view itself is the touch target; its size is determined by its container. The 44×44pt minimum SHOULD be respected by the parent container.
- **Keyboard navigation**: The text view supports standard keyboard navigation (arrows, home/end, page up/down, etc.) on both platforms.
- **Selection and copy**: Text selection and copy/paste are supported on both platforms via standard gestures and keyboard shortcuts.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| mtpane-001 | must-initialize-with-editability | `MarkdownTextPane(editable: true)` | Pane is created and text editing is enabled |
| mtpane-002 | must-initialize-with-editability | `MarkdownTextPane(editable: false)` | Pane is created and text editing is disabled |
| mtpane-003 | must-provide-editability-property | Set `pane.isEditable = true` on a read-only pane | Text editing becomes enabled; user can edit |
| mtpane-004 | must-provide-editability-property | Set `pane.isEditable = false` on an editable pane | Text editing becomes disabled; user cannot edit |
| mtpane-005 | must-report-text-changes | User types "Hello" into an editable pane | `onTextChange` is called with "Hello" |
| mtpane-006 | must-not-fire-change-on-programmatic-set | Set `pane.text = "Programmatic"` directly | `onTextChange` is not called |
| mtpane-007 | must-provide-text-property | Set `pane.text = "Sample text"` then read `pane.text` | Returns "Sample text" exactly |
| mtpane-008 | must-provide-text-property | Create pane without setting text, read `pane.text` | Returns empty string "" (not nil) |
| mtpane-009 | must-support-attributed-text | Set `pane.setAttributedText(styled)` where styled includes bold/italic attributes | Read `pane.attributedText` returns the styled text with attributes preserved |
| mtpane-010 | must-support-focus | Call `pane.focus()` on an onscreen pane | Returns true; keyboard focus moves to text view; user keystrokes are received |
| mtpane-011 | must-support-focus | Call `pane.focus()` on a pane without a window | Returns false; no focus change occurs |
| mtpane-012 | must-support-theme | Call `applyTheme(palette)` with a palette defining windowBackground, primaryText, cursor, and code font | Text view background, text color, insertion point color, and font are updated |
| mtpane-013 | must-disable-smart-substitutions-ios | On iOS, user types a quote character | No smart quote substitution occurs |
| mtpane-014 | must-disable-smart-substitutions-ios | On iOS, user types two hyphens | No smart dash substitution occurs |
| mtpane-015 | must-disable-smart-substitutions-macos | On macOS, user types a quote character | No smart quote substitution occurs |
| mtpane-016 | must-allow-undo-macos | On macOS, user edits text then presses Cmd+Z | Text reverts to prior state; undo is available |
| mtpane-017 | must-use-plain-text-mode | Paste rich formatted text into the pane | Text is pasted as plain text; formatting is stripped |
| mtpane-018 | must-scroll-vertically | Pane contains content taller than its bounds | Vertical scrolling is available to reveal off-screen content |
| mtpane-019 | must-hide-scrollers-macos | On macOS, scroll a large document and then remain still | Scroll indicator appears momentarily and then auto-hides |
| mtpane-020 | must-bounce-vertically-ios | On iOS, scroll vertically past content end | Text view bounces back to content boundary |
| mtpane-021 | must-use-8pt-insets | Pane contains text; measure distance from content edge to text baseline | Insets on all sides are 8pt |

## Edge Cases

- **Empty text**: Reading `text` when the pane is empty returns an empty string (never nil). Setting `text = ""` clears all content without firing `onTextChange`.
- **Null/nil text**: The API surface does not expose nil values. `UITextView.text` and `NSTextView.string` are always safe-unwrapped in the implementation, so read operations never return null.
- **Rapid successive edits**: User performs multiple edits in quick succession. Each edit fires `onTextChange` independently; no debouncing or throttling is performed. The caller is responsible for debouncing if needed.
- **Very large text**: Pane contains megabytes of text. The implementation uses native text views without pagination or virtual scrolling, so rendering performance depends on platform capabilities. No explicit size limits are enforced.
- **Programmatic text set while user is editing**: Caller sets `text` programmatically while the user is actively editing. The text immediately updates without firing `onTextChange`, potentially discarding in-flight edits. This is the expected behavior per the re-entrancy safeguard design.
- **Theme change mid-edit**: `applyTheme()` is called while text is being edited. Colors and font update immediately; the text view remains editable with no interruption.
- **Focus request off-screen**: User calls `focus()` on a pane that is not in the visible window hierarchy. On iOS, the behavior depends on whether the view is rendered at all. On macOS, `window?.makeFirstResponder()` returns false if the window is nil.
- **Read-only to editable transition during selection**: User selects text, then the pane transitions to read-only. Selection remains visible. Transitioning back to editable preserves the selection. User can type to replace it.
- **Attributed text with no attributes**: Read `attributedText` when `text` is plain with no styling applied. Returns an `NSAttributedString` with no attributes attached to the characters.

## Configuration

Not applicable: Markdown Text Pane has no configuration options beyond the `editable` parameter passed at initialization and the subsequent `isEditable` property.

## Deep Linking

Not applicable: Markdown Text Pane is a container component with no deep-linking support. Deep linking, if needed, is the responsibility of the controller that hosts this pane.

## Localization

Not applicable: Markdown Text Pane displays user-supplied text and system UI elements (e.g., cursor, selection highlighting) that are inherently localized by the platform. The component itself contains no user-facing strings.

## Accessibility Options

- **Reduce Motion**: Platform text views respect the system reduce-motion setting automatically. The cursor blinks only when reduce-motion is not enabled. No special handling is required.
- **Increase Contrast**: The parent controller is responsible for choosing a high-contrast palette when applying the theme. The pane respects whatever foreground and background colors are provided.
- **Differentiate Without Color**: Not applicable. Color is the primary (and only) visual indicator in this component; text selection is also visible via a selection highlight color and transparent overlay.

## Feature Flags

Not applicable: Markdown Text Pane is a low-level container component with no feature flags.

## Analytics

Not applicable: Markdown Text Pane is a presentational component with no built-in analytics. The parent controller is responsible for logging user interactions (e.g., open, edit, save) as appropriate for the application.

## Privacy

Not applicable: Markdown Text Pane does not collect, store, or transmit data. It operates entirely on text provided by the caller and fires no network requests.

## Logging

Not applicable: Markdown Text Pane performs no logging of its own. Platform text views may emit internal debug logs for text input handling, but these are not controlled by this component.

## Platform Notes

- **Apple (source platform)**: `MarkdownTextPane.swift` exists in two variants — one in `SourcesUI/macOS/Markdown/` (wraps `NSTextView` in `NSScrollView`) and one in `SourcesUI/iOS/Markdown/` (wraps `UITextView` directly). Both export an identical API with the same property names, callback signature, and init parameter. The macOS variant enables the find bar (`usesFindBar = true`, `isIncrementalSearchingEnabled = true`); the iOS variant does not. Both apply a fixed 8pt inset around content.

- **SwiftUI**: SwiftUI does not wrap `NSTextView` or `UITextView` directly with a single bridge component. To integrate `MarkdownTextPane` in SwiftUI, create a view modifier wrapping the UIViewRepresentable (iOS) or NSViewRepresentable (macOS) protocols, exposing the text, onTextChange, isEditable, and focus() API as SwiftUI state and callbacks. Use `@Binding` for text and `@State` for onTextChange.

- **Compose (Android)**: The Android equivalent starts with `BasicTextField` or `TextField` from Compose, which provides a similar unbounded text editing surface. Configure it with `keyboardOptions = KeyboardOptions(autoCorrect = false, capitalization = KeyboardCapitalization.None)`, disable smart quote substitution in platform IME settings, apply a 8dp padding, and expose callbacks for text changes and focus via Compose state management. The scroll behavior is automatic in `LazyColumn` or `Column` with `verticalScroll()`.

- **AppKit / UIKit**: On macOS, start from `NSTextView` and wrap it in `NSScrollView` with `autohidesScrollers = true` and `borderType = .noBorder`. On iOS, use `UITextView` directly with `alwaysBounceVertical = true` and `autocorrectionType = .no`. Both require setting `isRichText = false` (or equivalently, plain-text mode) and `isSelectable = true`. Inset the text container by 8pt. Attach a delegate to capture text changes and fire the callback, taking care not to recurse on programmatic text assignment.

- **WinUI 3**: Start with `TextBox` or `RichEditBox` from the `Microsoft.UI.Xaml.Controls` namespace. Use `TextBox` for plain text to match the source platform's plain-text commitment. Disable autocorrect with `IsSpellCheckEnabled = false`, `IsTextPredictionEnabled = false`, and set `ScrollViewer.VerticalScrollBarVisibility = ScrollBarVisibility.Auto`. Apply an 8-unit Margin to the text box. Bind the `Text` property to a ViewModel property; use the `TextChanged` event to fire the equivalent of `onTextChange`. Implement an `IsEditable` dependency property that mirrors the source's public property. Wrap the text box in a `ScrollViewer` if vertical scrolling is not automatic for your target WinUI 3 version.

## Design Decisions

- **8pt insets instead of 6pt**: The component uses 8pt insets rather than the 6pt used by Apple's Quick Note and similar scratch fields. This wider gutter signals that the pane is a document surface intended for longer reading/editing sessions, not an ephemeral note. The decision is visually intentional and MUST NOT be "fixed" to match other components.

- **Plain text only**: The component does not support rich text, markdown parsing, or styled rendering. This constraint simplifies the API, reduces platform-specific rendering complexity, and aligns with the use case of hosting markdown source files, which are plain text. Styled rendering and markdown preview are the responsibility of parent controllers.

- **No re-entry on programmatic text set**: The `text` setter does not fire `onTextChange`. This is a load-bearing design decision for controllers that re-render from text changes. A controller that receives `onTextChange`, processes it, and writes the result back via `text =` must not re-enter its own callback. Without this safeguard, feedback loops are inevitable.

- **Focus as an explicit method, not automatic first responder**: The pane does not automatically become first responder on initialization. Callers must invoke `focus()` explicitly. This prevents unwanted keyboard display (especially on iOS) and gives the parent window/modal control over focus order.

- **Find bar enabled on macOS only**: The macOS variant enables `NSTextView`'s built-in find bar (`usesFindBar = true`, `isIncrementalSearchingEnabled = true`). The iOS variant does not expose find, relying instead on the platform's standard text selection and copy flow. This difference reflects platform UX conventions and is intentional.

- **Undo support on macOS only**: The macOS variant enables `allowsUndo = true`, integrating with the system undo stack. The iOS variant inherits whatever undo behavior `UITextView` provides by default, which is typically application-level only. The asymmetry reflects platform capabilities and macOS's deeper undo integration.

## Compliance

NEEDS REVIEW: No accessible name. `textView` is `private` in both variants, and the public API (`text`, `attributedText`, `isEditable`, `focus()`, `applyTheme(_:)`) exposes no label-setting member, so a caller has no way to give the pane an accessible name — `UITextView`/`NSTextView` still supply their native role (text view/text area) and read their content back as the value, but not a name. Settled by a decision to add a label-forwarding property to the public API, or a cookbook rule requiring the host to set one once such a property exists.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.1.0 | 2026-09-22 | | Compliance: narrowed the accessibility NEEDS REVIEW marker to the missing fact (no accessible name, `textView` is private with no label-forwarding member) and what would settle it |
| 1.0.0 | 2026-09-22 | | Initial creation |
