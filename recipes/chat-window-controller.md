---
id: 91114bf5-ad41-4cbd-b91b-c49bba9625d5
title: ChatWindowController
domain: agenticdevelopertoolkit://recipes/chat-window-controller
type: ingredient
version: 1.0.0
status: review
language: en
created: 2026-09-22
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A macOS window controller that displays a chat interface with no title bar,
  transparent background, and appearance settings gear.
platforms:
- swift
- macos
tags:
- chat
- window
- macos
- appkit
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# ChatWindowController

## Overview

ChatWindowController is an AppKit window controller that presents a chat interface in a floating window. The window has no title bar, uses a transparent background to respect the theme's alpha values, and provides appearance controls (text size, transparency, optional backdrop animation) via a gear icon at the trailing edge. It manages window frame persistence, input focus, and integrates with a host application's chat view model and backend. Subclass it to add host-specific behavior such as connection rituals or status items.

## Behavioral Requirements

- **must-own-chat-view**: The controller MUST own and display an `InlineChatView` instance, accessible via the `chatView` property.
- **must-own-appearance-controller**: The controller MUST own a `ChatWindowAppearanceController` instance, accessible via the `appearance` property.
- **must-configure-from-struct**: The controller MUST be initialized with a `ChatWindowConfiguration` struct that supplies title, defaults namespace, appearance title, initial content size, chrome style, and backdrop toggle label.
- **must-accept-view-model**: The controller MUST accept an `ObservableChatViewModel` instance and a local participant ID string during initialization.
- **must-accept-optional-backdrop**: The controller MUST accept an optional `NSView` backdrop that is passed to the `InlineChatView`.
- **must-hide-title-bar**: The window MUST have `titleVisibility` set to `.hidden` and `titlebarAppearsTransparent` set to `true`, removing all title-bar furniture (close, miniaturize, zoom buttons).
- **must-be-movable-by-background**: The window MUST set `isMovableByWindowBackground` to `true` so the chat surface itself serves as the drag handle.
- **must-be-translucent**: The window MUST set `isOpaque` to `false` and `backgroundColor` to `.clear`, allowing the theme's alpha values in the view to be visible.
- **must-use-full-size-content-view**: The window MUST include `.fullSizeContentView` in its style mask, extending content to the top edge.
- **must-size-window-correctly**: The window MUST open at the size specified in `ChatWindowConfiguration.contentSize`, not shrink-wrap to the view's minimum width. The `ChatContentViewController` MUST set the content view controller's `preferredContentSize`.
- **must-disable-autoresizing-mask**: The window's content view MUST have an empty autoresizing mask (`[]`) to prevent the layout engine from treating it as a flexible mask and shrinking the window.
- **must-set-window-title**: The window MUST set its title from `ChatWindowConfiguration.title`. The title is hidden from the title bar but used by the Window menu, Mission Control, and the accessibility tree.
- **must-restore-frame**: The controller MUST restore the saved window frame using `setFrameUsingName(_:)` with a namespaced frame name constructed from `ChatWindowConfiguration.defaultsNamespace`. If no frame is saved, the window MUST center on screen.
- **must-autosave-frame**: The controller MUST set `windowFrameAutosaveName` to enable AppKit's automatic frame persistence on every move and resize.
- **must-use-content-view-controller**: The `InlineChatView` MUST be contained within a `ChatContentViewController` (not assigned directly to `contentView`) to ensure the window correctly sizes the chat view to the requested size rather than shrink-wrapping it.
- **must-install-appearance**: The controller MUST call `appearance.install()` during initialization to activate the appearance controller.
- **must-focus-input-on-show**: When `showWindow(_:)` is called, the controller MUST call `focusInput()` to place focus in the composer field.
- **must-focus-input-on-key**: The controller MUST observe `NSWindow.didBecomeKeyNotification` and call `focusInput()` only if the window's first responder is still the window itself. This ensures the composer is ready for typing without overriding an existing selection in the transcript.
- **must-find-first-editable-field**: The `focusInput()` method MUST walk the view hierarchy to locate the first editable `NSTextField` (the composer) and make it the first responder.
- **must-prohibit-nib-init**: The controller MUST prohibit initialization from a nib by implementing `required init?(coder:)` with `fatalError`.
- **must-be-main-actor**: All public API and view-related logic MUST be annotated with `@MainActor`.
- **must-allow-subclassing**: The class MUST be declared `open` to allow subclasses to add host-specific behavior.

## Appearance

- **Title bar**: Hidden (`.titleVisibility = .hidden`, `titlebarAppearsTransparent = true`)
- **Background**: Transparent (`.isOpaque = false`, `backgroundColor = .clear`)
- **Drag handle**: Window background (movable by window background; `.isMovableByWindowBackground = true`)
- **Default window size**: 460 points wide × 620 points tall (from `ChatWindowConfiguration.contentSize` default)
- **Gear/appearance control**: Trailing edge, managed by `ChatWindowAppearanceController`
- **Chat view**: Fills window content area, respects theme alpha and styling

## States

| State | Appearance change |
|-------|------------------|
| Default | Window centered on screen, chat ready for input |
| Restored | Window positioned and sized at last saved frame |
| Key (active) | First responder set to composer field for immediate typing |
| Not key | Window remains visible; input focus retained until switched away |

## Accessibility

- **Window role**: Standard window with title accessible to the accessibility tree (title bar hidden but title retained for screen readers, Mission Control, and the Window menu).
- **Chat view and composer**: Accessibility provided by `InlineChatView` and the contained text field; the controller does not impose additional barriers.
- **Keyboard navigation**: First responder management ensures the composer field receives keyboard focus when the window becomes key, enabling immediate text input without requiring Tab navigation.
- **Minimum interaction target**: Not applicable. This component manages the window and focus; interactive elements (buttons, fields) are owned by `InlineChatView` and governed by their own specifications.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| cwc-001 | must-own-chat-view | Initialize with valid view model | `controller.chatView` returns non-nil `InlineChatView` |
| cwc-002 | must-own-appearance-controller | Initialize with valid configuration | `controller.appearance` returns non-nil `ChatWindowAppearanceController` |
| cwc-003 | must-configure-from-struct | Create `ChatWindowConfiguration` and pass to init | Controller stores all configuration values and passes them to window and appearance controller |
| cwc-004 | must-hide-title-bar | Initialize and inspect window | Window's `titleVisibility` is `.hidden`, `titlebarAppearsTransparent` is `true`, and close/miniaturize/zoom buttons are hidden |
| cwc-005 | must-be-translucent | Initialize and inspect window | Window's `isOpaque` is `false`, `backgroundColor` is `.clear` |
| cwc-006 | must-size-window-correctly | Initialize with `contentSize = NSSize(width: 500, height: 700)` | Window opens at approximately 500×700 (exact dimensions account for frame decorations) |
| cwc-007 | must-restore-frame | Initialize, move/resize window, call `setFrameUsingName`, deinit, reinitialize with same namespace | Window restores to saved position and size on second initialization |
| cwc-008 | must-autosave-frame | Initialize, move window, wait for autosave | Window's subsequent position is saved and restored on reopen |
| cwc-009 | must-focus-input-on-show | Call `showWindow(nil)` | Composer field receives first responder focus |
| cwc-010 | must-focus-input-on-key | Window with text selection, click away, click back to window | Selection is preserved; `focusInput()` is not called because first responder is not the window |
| cwc-011 | must-find-first-editable-field | Call `focusInput()` with hierarchy containing multiple text fields (only one editable) | First editable `NSTextField` is located and made first responder |
| cwc-012 | must-prohibit-nib-init | Attempt to initialize from nib (e.g., via `NSKeyedUnarchiver`) | `init(coder:)` raises `fatalError` |
| cwc-013 | must-be-movable-by-background | Initialize and inspect window | Window's `isMovableByWindowBackground` is `true`; user can drag window by clicking anywhere on chat surface |

## Edge Cases

- **Null backdrop**: A nil backdrop is acceptable; the chat view renders without a background animation.
- **Empty view model**: The controller accepts the view model but delegates all chat display to `InlineChatView`; an empty or uninitialized view model is a concern for the view model, not the controller.
- **First responder already set**: If `focusInput()` is called when another view already has first responder status, the method attempts to set the composer as first responder; the window or other views may retain focus if they refuse to release it (e.g., during a drag operation).
- **Frame restoration failure**: If `setFrameUsingName(_:)` returns `false` (no saved frame), the window centers on screen; subsequent moves and resizes update the saved frame.
- **Window becoming key during text selection**: The `windowBecameKey` observer checks if the current first responder is the window itself before calling `focusInput()`. If a transcript selection or other view holds first responder, `focusInput()` is not called, preserving the selection.
- **Multiple ChatWindowController instances**: Each controller with a different `defaultsNamespace` maintains separate frame and appearance settings. Controllers with the same namespace share settings.
- **Window close/deinit**: The controller removes itself from `NotificationCenter` in `deinit` to avoid dangling observer references.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `title` | `String` | Required | Window title, hidden in title bar but used by Window menu and accessibility |
| `defaultsNamespace` | `String` | Required | Prefix for saved appearance settings; namespaces allow multiple windows to maintain independent settings |
| `appearanceTitle` | `String` | Required | Caption for the appearance control panel, localized to the reader's language |
| `contentSize` | `NSSize` | `(460, 620)` | Initial width and height of the window's content area |
| `chrome` | `InlineChatChrome` | Default instance | Chat view styling (stock look or terminal theme) |
| `backdropToggleTitle` | `String` | `"Background animation"` | Label for the backdrop animation toggle in the appearance panel; e.g., `"Rain"` for a window with rain backdrop |

## Deep Linking

Not applicable: ChatWindowController is a window container, not a user-navigable destination. Deep linking into a chat is a concern for the host application and the view model it supplies.

## Localization

| String Key | Default (en) | Context |
|-----------|-------------|---------|
| Not applicable | — | The controller uses no user-facing strings; `appearanceTitle` and `backdropToggleTitle` are supplied by the host via `ChatWindowConfiguration` |

## Accessibility Options

Not applicable: The controller does not directly render text or interactive elements. Text size, transparency adjustments, and other accessibility features are managed by `ChatWindowAppearanceController` and `InlineChatView`.

## Feature Flags

| Flag Key | Default | Description |
|----------|---------|-------------|
| Not applicable | — | The controller has no runtime feature flags; it is always active when instantiated |

## Analytics

| Event | Properties | When |
|-------|-----------|------|
| Not applicable | — | Event tracking is handled by `ChatWindowAppearanceController` and `InlineChatView`, not the controller itself |

## Privacy

- **Data collected**: ChatWindowController collects no user data. Frame position and size are persisted to `NSUserDefaults` under the namespace supplied in `ChatWindowConfiguration.defaultsNamespace`.
- **Storage**: Window frame and appearance settings are stored in `NSUserDefaults` (per the `WindowAppearanceDefaults` key namespace); these are local to the device.
- **Transmission**: No data transmission occurs.
- **Retention**: Frame and settings are retained indefinitely until the host application or user deletes them or clears user defaults.

## Logging

Subsystem: Determined by host application | Category: ChatWindowController

| Event | Level | Message |
|-------|-------|---------|
| Not applicable | — | The controller itself does not emit log messages; diagnostic logging is the host's responsibility |

## Platform Notes

- **Apple (source)**: `ChatWindowController` in `packages/apple/AgenticDeveloperToolkit/SourcesUI/macOS/Chat/ChatWindowController.swift`. An AppKit `NSWindowController` subclass that manages a window with no title bar, transparent background, and frame persistence. Uses `ChatWindowConfiguration` as a value type to support multiple windows with independent settings. Delegates chat display to `InlineChatView` and appearance controls to `ChatWindowAppearanceController`. The `ChatContentViewController` wrapper ensures the content view scales to the requested size rather than shrink-wrapping.
- **SwiftUI**: SwiftUI does not provide a direct equivalent to AppKit's `NSWindowController` and `NSWindow`. To present a chat window in SwiftUI on macOS, wrap `ChatWindowController` in an `NSViewControllerRepresentable` or use it as the window delegate in a custom `@main` app entry point. SwiftUI's `@Environment(\.openWindow)` can trigger the window's display.
- **Compose**: Android does not have a single-window model; Chat UI is typically displayed full-screen or in a modal dialog. Equivalent behavior would be a modal `Dialog` or `ModalBottomSheet` with a `TopAppBar` containing appearance controls and a text input field for the composer.
- **AppKit / UIKit**: On iOS, present a chat interface in a modal `UIViewController` or navigate to a dedicated chat screen in a navigation stack. iOS does not support hidden title bars or transparent window backgrounds in the same way; use `navigationBarTitleDisplayMode(.inline)` or custom header views to achieve a minimal title presentation. Frame restoration is handled by `UIApplication.supportsMultipleScenes` and `SceneDelegate` state persistence.
- **WinUI 3**: On Windows, create a chat window using `Microsoft.UI.Xaml.Window` with a minimal title bar (hide standard chrome using `ExtendsContentIntoTitleBar`). Use `Grid` with two columns: one for `InlineChatView` (or its WinUI equivalent) and one for the appearance gear button. Store window position and size in `ApplicationData.Current.LocalSettings`. Bind the `IsMovableByWindowBackground` behavior to a `Canvas` or background rectangle with a pointer-entered handler. Set `RequestedTheme` to `ElementTheme.Dark` or data-bind to a theme setting for transparency support.

## Design Decisions

- **No title bar with title retained**: The window title is hidden from the title bar but retained because it appears in the Window menu, Mission Control, and the accessibility tree. This balances visual minimalism with platform discoverability.
- **Transparent background**: The window is translucent (`isOpaque = false`, `backgroundColor = .clear`) so that the theme's alpha values in the view layer are visible. An opaque window would composite its background first, obscuring theme transparency.
- **Content view controller wrapper**: The `InlineChatView` is not assigned directly to `contentView` but wrapped in a `ChatContentViewController`. AppKit sizes a direct content view to its minimum unless explicitly constrained; the wrapper ensures the window's `preferredContentSize` determines the initial size.
- **Empty autoresizing mask**: The content view's autoresizing mask is set to `[]` to break the default flexible mask that would cause the window to shrink-wrap the view's width. A fixed mask causes AppKit to derive `width == frame.width`, keeping the window resizable without shrinking.
- **Conditional input focus on key**: The `windowBecameKey` observer calls `focusInput()` only if the first responder is the window itself. This prevents clobbering an active text selection in the transcript when the window is re-fronted via a status bar item or ⌘\` switcher.
- **Namespaced frame persistence**: The frame autosave name is prefixed with the `defaultsNamespace` from `ChatWindowConfiguration`, allowing multiple chat windows to maintain independent positions and sizes. Each window remembers where it was left.
- **Public chat view and appearance controller**: Both `chatView` and `appearance` are public properties so that host applications can drive the view directly (e.g., display a placeholder during connection) and access appearance state if needed.
- **Subclassing for host behavior**: The class is declared `open` and the initializer is not marked final, allowing hosts to subclass and add connection rituals, status item management, or other application-specific behavior without forking the controller.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| Not applicable | — | Cookbook compliance checks are handled by upstream components (`InlineChatView`, `ChatWindowAppearanceController`) and the host application |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
