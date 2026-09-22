---
id: 31a21ecf-cf6a-42d8-bae5-3b482f8d554d
title: Window Drawer
domain: agenticdevelopercookbook://ingredients/window-drawer
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A tabbed drawer that slides out beside a window's trailing edge, providing
  lazy-loaded tab content without reflow.
platforms:
- swift
tags:
- drawer
- window-chrome
- navigation
depends-on: []
related: []
references: []
---

# Window Drawer

## Overview

A tabbed drawer that slides out beside a window's trailing edge, leaving the window's content unaffected. The drawer lazily loads tab content, renders with the theme's window background color, and allows the user to drag the outer edge to resize horizontally. Designed to present optional, contextual content (help, settings, details) without reflow or visual discontinuity.

## Behavioral Requirements

- **must-open-and-close**: Component MUST support `open()` and `close()` methods to show and hide the drawer.
- **must-open-with-tab-selection**: Component MUST accept an optional tab ID in `open(selecting:)` to select a specific tab before opening.
- **must-toggle-state**: Component MUST support `toggle(selecting:)` to open on a tab if closed, or close if already open on that tab.
- **must-lazy-load-tabs**: Component MUST create a tab's view only on first access via `view(forTab:)`, and retain it thereafter. MUST cache views so repeated access returns the same instance.
- **must-track-open-state**: Component MUST expose `isOpen` boolean property that reflects whether drawer state is `openState` or `openingState`.
- **must-track-selected-tab**: Component MUST expose `selectedTabID` property that identifies which tab is currently shown.
- **must-announce-visibility-changes**: Component MUST invoke `onVisibilityChange` callback after open, close, or drag events; callback caller MUST make it idempotent.
- **must-honor-dragged-close**: Component MUST detect when user drags drawer closed at the outer edge (not programmatic close) via `closeIsAttributableToTheReader` property.
- **must-clamp-content-width**: Component MUST accept content width in the range 220–520 points; values outside this range MUST be clamped to the nearest bound. NaN and infinite values MUST fall back to the default width (300 points).
- **must-expose-content-width**: Component MUST expose `contentWidth` property as a getter and setter, allowing caller to read and persist the width the user dragged it to.
- **must-hide-single-tab-strip**: Component MUST hide the tab strip control when fewer than two tabs are present; MUST unhide it if tabs are added later.
- **must-use-tab-symbols**: Component MUST display a system symbol image for each tab in the strip, paired with the tab title.
- **must-use-theme-colors**: Component MUST paint drawer background using the theme's `windowBackground` role, and MUST paint the AppKit-drawn border overlay in the same role to prevent system/app theme mismatch (white rim on dark drawer).
- **must-sync-height-at-open**: Component MUST re-read parent window height at `open()` time to accommodate windows assembled before toolbar growth or frame restoration.
- **must-reapply-remembered-state-on-window-key**: Component MUST call `reapplyVisibility` callback when parent window becomes key or main, to open a remembered drawer that was dropped during `init`.
- **must-have-accessibility-prefixed-ids**: Component MUST accept `accessibilityPrefix` and namespace all accessibility identifiers: `<prefix>` for container, `<prefix>.tabs` for strip, `<prefix>.tab.<id>` for body.
- **must-clear-delegate-in-deinit**: Component MUST clear the NSDrawer delegate pointer in `deinit` because NSDrawer holds a reference and uses `unowned(unsafe)` semantics; failure to clear leaves a dangling pointer.

## Appearance

- **Corner radius**: None; drawer inherits NSDrawer's system-drawn frame.
- **Padding**: Tab strip: 8pt top margin, centered horizontally. Body: 32pt top (when strip shown) or 0pt (when hidden), fill remaining drawer space.
- **Font**: Tab titles use system font; symbol images are system symbols scaled by AppKit's NSSegmentedControl.
- **Background**: Theme's `windowBackground` role for container and bezel overlay.
- **Foreground/Text**: Theme text color via ThemedBackgroundView.
- **Border**: AppKit draws NSDrawerFrame border; bezel overlay repaints it in theme color to avoid system-appearance rim.
- **Shadow**: None; NSDrawer's frame provides system shadow.
- **Min/Max size**: Width draggable between 220–520 points (default 300). Height is window height; locked (not draggable).

## States

| State | Appearance Change |
|-------|------------------|
| Closed | Drawer is hidden; no drawer frame or bezel visible. |
| Opening | Drawer slides into view; opacity transitions. |
| Open | Drawer fully visible; edge is draggable. |
| Dragging | Cursor changes to resize indicator; drawer width follows mouse horizontally, clamped to bounds. |

## Accessibility

- **Role**: Container is a group; tab strip is a button group (NSSegmentedControl); each tab is a button-like segment.
- **Label requirements**: Each segment is labeled with its tab title (from `DrawerTab.title`). System symbol images include `accessibilityDescription` (title) for screen readers.
- **Announce state changes**: Tab selection change MUST update the body's accessibility ID to `<prefix>.tab.<id>` so screen readers track the active pane. Visibility changes do not require additional announcement (caller handles state memory).
- **Minimum tap target**: Tab strip segments MUST be at least 44×44 points (NSSegmentedControl default is 24–28pt tall; layout padding increases clickable area).
- **Keyboard navigation**: Tab selection MUST be operable via arrow keys and Return (NSSegmentedControl standard behavior); drawer open/close MUST be programmatic or draggable, not keyboard-initiated.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|----|-------|---------|
| drawer-001 | must-open-and-close | Call `open()` on closed drawer. | `isOpen` becomes true; drawer frame is visible. |
| drawer-002 | must-open-and-close | Call `close()` on open drawer. | `isOpen` becomes false; drawer frame is hidden. |
| drawer-003 | must-open-with-tab-selection | Call `open(selecting: "help")` with tab ID "help" present. | Drawer opens and body shows "help" tab content. |
| drawer-004 | must-open-with-tab-selection | Call `open(selecting: "nonexistent")`. | Drawer opens and shows first tab (invalid ID ignored). |
| drawer-005 | must-toggle-state | Call `toggle()` on closed drawer. | Drawer opens on currently selected tab. |
| drawer-006 | must-toggle-state | Call `toggle()` on open drawer. | Drawer closes. |
| drawer-007 | must-toggle-state | Call `toggle(selecting: "other")` while open on "help". | Drawer remains open and switches to "other" tab. |
| drawer-008 | must-toggle-state | Call `toggle(selecting: "help")` while open on "help". | Drawer closes. |
| drawer-009 | must-lazy-load-tabs | Call `view(forTab: "tab1")` once; call again. | Both calls return the same NSView instance (not newly created). |
| drawer-010 | must-lazy-load-tabs | Call `view(forTab: "missing")`. | Returns nil; no view is cached. |
| drawer-011 | must-track-open-state | Observe `isOpen` before and after `open()`. | Returns false initially, true after `open()` completes. |
| drawer-012 | must-track-selected-tab | Initialize with tabs `[tab1, tab2]`. | `selectedTabID` is "tab1" (first tab). |
| drawer-013 | must-track-selected-tab | Call `open(selecting: "tab2")`. | `selectedTabID` becomes "tab2". |
| drawer-014 | must-announce-visibility-changes | Set `onVisibilityChange` callback; call `open()`. | Callback is invoked exactly once (from `open()`) or twice (from `open()` and `drawerDidOpen`); caller MUST make it idempotent. |
| drawer-015 | must-announce-visibility-changes | Open drawer; user drags outer edge closed by hand. | Callback is invoked; `closeIsAttributableToTheReader` is true. |
| drawer-016 | must-honor-dragged-close | Open drawer; call `close()` programmatically. | `closeIsAttributableToTheReader` is false. |
| drawer-017 | must-honor-dragged-close | Minimize parent window (drawer auto-closes). | `closeIsAttributableToTheReader` is false. |
| drawer-018 | must-honor-dragged-close | Parent window deallocates. | `closeIsAttributableToTheReader` is false (weak `parentWindow` becomes nil). |
| drawer-019 | must-clamp-content-width | Set `contentWidth = 150` (below min 220). | `contentWidth` is clamped to 220. |
| drawer-020 | must-clamp-content-width | Set `contentWidth = 600` (above max 520). | `contentWidth` is clamped to 520. |
| drawer-021 | must-clamp-content-width | Set `contentWidth = .nan`. | `contentWidth` falls back to default 300. |
| drawer-022 | must-clamp-content-width | Set `contentWidth = .infinity`. | `contentWidth` falls back to default 300. |
| drawer-023 | must-expose-content-width | Read `contentWidth` after initialization with default. | Returns 300.0. |
| drawer-024 | must-expose-content-width | Set `contentWidth = 400`; read it back. | Returns 400.0. |
| drawer-025 | must-hide-single-tab-strip | Initialize with 1 tab. | `tabStrip.isHidden` is true; `tabStripIsHidden` returns true. |
| drawer-026 | must-hide-single-tab-strip | Initialize with 2+ tabs. | `tabStrip.isHidden` is false. |
| drawer-027 | must-use-tab-symbols | Initialize with tabs specifying SF symbol names. | Each segment displays the symbol image; image is non-nil. |
| drawer-028 | must-use-theme-colors | Observe bezel subview role. | Role is `windowBackground` (not `.surface`); no contrast gap at drawer edge. |
| drawer-029 | must-sync-height-at-open | Initialize drawer while parent window frame height is 0; later set frame height to 800. Call `open()`. | `contentHeight` reflects 800 (not 0). |
| drawer-030 | must-reapply-remembered-state-on-window-key | Set `reapplyVisibility` callback to call `open()`. Initialize drawer; window not yet on-screen. Window becomes key. | Callback is invoked; drawer opens. |
| drawer-031 | must-have-accessibility-prefixed-ids | Initialize with `accessibilityPrefix = "help"`; select tab "settings". | Container ID is "help"; strip ID is "help.tabs"; body ID is "help.tab.settings". |
| drawer-032 | must-clear-delegate-in-deinit | Initialize drawer (deinit called). | NSDrawer delegate is nil; no dangling pointer. |

## Edge Cases

- **Single tab, no user action**: Drawer with one tab hides the strip and renders cleanly; second tab can be added and strip unhidden without layout shift.
- **Width clamped at init**: Initialize with `contentWidth: -50` or `999`. Value is clamped before NSDrawer receives it; user can drag within clamped range.
- **NaN width from string parsing**: If width is parsed from user defaults as `Double("nan")` or `Double("inf")`, fallback to 300 prevents invisible drawer.
- **Window closes while drawer open**: Weak reference to parent window prevents dangling pointer; drawer is cleaned up by NSWindow.
- **Window minimized**: Drawer auto-closes; `isOpen` becomes false; `closeIsAttributableToTheReader` is false (not attributed to user action).
- **Drawer edge flipped at screen boundary**: AppKit automatically flips drawer to opposite edge; no logic needed; caller receives same object with edge flipped.
- **Open called while opening**: AppKit's NSDrawer state machine handles overlapping calls; open is idempotent if drawer is already opening.
- **Tab ID invalid during select**: Invalid ID is silently ignored; drawer keeps showing current tab (fail-safe behavior to prevent blank drawer).
- **Parent window height = 0 at init**: Height is not cached from init; re-read at `open()` time, so construction order does not matter.
- **Bezel needs reinstall after NSDrawer rebuilds**: NSDrawer rebuilds NSDrawerFrame when edge changes or contentView is reassigned; `installBezelIfNeeded()` idempotently reattaches bezel to the current frame.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `parentWindow` | NSWindow | (required) | The window the drawer is attached to. |
| `accessibilityPrefix` | String | (required) | Namespace for accessibility IDs; e.g., "help" produces IDs like "help.tabs" and "help.tab.settings". |
| `tabs` | [DrawerTab] | (required) | Array of tab definitions; each has `id`, `title`, `symbolName`, and lazy view factory. |
| `contentWidth` | CGFloat | 300 | Initial width in points; clamped to 220–520 on init and on setter. |

## Deep Linking

Not applicable: AppKit drawers are window-internal views and do not support URL routing. Deep linking is caller's responsibility if the app implements URL schemes that should open specific tabs.

## Localization

Not applicable: Tab titles and accessibility labels are provided by the caller via `DrawerTab.title` and symbol accessibility descriptions; the component does not define any strings.

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | NSSegmentedControl animation is system-controlled; AppKit honors system motion settings automatically. NSDrawer slide animation respects system reduce-motion preference. |
| Increase Contrast | Tab strip uses NSSegmentedControl system styling; increased contrast is handled by AppKit's theme system. Bezel uses theme's `windowBackground` role, which respects contrast settings. |
| Differentiate Without Color | Segments are labeled with text and images; selection is shown by both color and a filled segment state (not color alone). |

## Feature Flags

Not applicable: Component has no internal feature flags. Enablement is caller's responsibility.

## Analytics

Not applicable: Component does not emit analytics events. Caller may instrument `onVisibilityChange` and tab selection to track user behavior.

## Privacy

Not applicable: Component does not collect, store, or transmit any user data.

## Logging

Not applicable: Component produces no internal logging. Caller may log visibility changes and tab selections as needed for debugging.

## Platform Notes

- **Swift (AppKit source)**: Use `NSDrawer` directly or wrap with `WindowDrawer`. The wrapper provides tabbed interface, lazy loading, and theme integration. Key files: `WindowDrawer.swift` (main class), `DrawerTab` struct (tab definition), `MouseTransparentView` (hit-test bypass for bezel overlay). Notably, `NSDrawer` is deprecated since macOS 10.13 but remains functional; the deprecation attribute allows wrapper to use NSDrawer without compiler warnings bleeding into caller code.

- **SwiftUI**: There is no native SwiftUI equivalent to NSDrawer; it must be wrapped via `NSViewControllerRepresentable` or exposed through a view modifier. A SwiftUI wrapper would need to own the underlying `WindowDrawer` instance and bridge tab view builders to `DrawerTab` closures. Consider wrapping as: `struct WindowDrawerModifier: ViewModifier { let tabs: [DrawerTab] }` applied to `Window` in an `App` scene.

- **Jetpack Compose (Android)**: Use `ModalNavigationDrawer` or custom `BottomDrawerScaffold` starting from Material Design 3. Content should lazily load `Composable` functions similar to `DrawerTab.makeView`. Accessibility prefixes map to `testTag()` modifiers for each drawer region. Width is not draggable on Android; preset width or allow drawer to fill a percentage of screen.

- **AppKit / UIKit (native)**: On macOS, use `NSDrawer` directly or the `WindowDrawer` wrapper. On iOS/iPadOS, use `UISplitViewController` or a custom modal drawer, as `NSDrawer` is macOS-only. Width dragging must be implemented via a custom gesture recognizer on iOS. Tab strip maps to `UISegmentedControl` or `UITabBarController`. Accessibility IDs map to `accessibilityIdentifier` on UIKit.

- **WinUI 3**: Use `NavigationView` with `PaneDisplayMode.LeftMinCompact` or `.LeftCompact`, or create a custom `UserControl` with a `Frame` beside the main content. For a trailing-edge drawer, flip the pane to the right via container layout order. Tab strip maps to `NavigationViewItem` or a separate `RadioButton` group. Width dragging uses a `GridSplitter` between the main content and drawer pane; set `MinWidth="220"` and `MaxWidth="520"` on the drawer's `Grid.Column`. Theme colors use `x:ThemeResource` XAML bindings to system brushes (e.g., `SystemControlBackgroundChromeMediumBrush` for window background equivalent). Bezel overlay is handled via the pane's built-in border rendering.

## Design Decisions

**Lazy tab loading**: Tabs are views created on demand by a factory closure, not eagerly. This allows windows with many possible tabs to avoid upfront cost and memory bloat. A tab never opened costs nothing. Views are retained once made, avoiding repeated allocation if the user switches tabs multiple times.

**Idempotent visibility callbacks**: `onVisibilityChange` may be called multiple times for a single open or close (once from the programmatic call, once from NSDrawer's delegate callback). Callers MUST make their callbacks idempotent. This design avoids losing information: if the callback were called only once, a programmatic open made while the drawer is still animating would not notify, and an app that persists state would miss the change.

**Width handling at init**: Width is clamped at initialization, before NSDrawer receives it, so a bad remembered value (from a previous version or corrupt storage) cannot create an undraggable drawer. NaN and infinity are rejected rather than clamped to a bound, because they carry no meaningful data; the default is safer than a guess.

**Height re-read at open**: Height is not cached from init because drawers are often built before their windows are fully assembled (before toolbar, before frame restoration). Reading height at open time makes construction order irrelevant; the drawer adapts to its window's final size automatically.

**Bezel overlay for theme border**: AppKit's NSDrawerFrame draws its border opaquely in the *system* appearance, which can produce a white rim around a dark theme drawer. The bezel (a mouse-transparent `ThemedBackgroundView` overlay) repaints that border in the theme's window background color. It is mouse-transparent so the user's drag on the frame's outer edge still works for resizing.

**closeIsAttributableToTheReader**: A drawer closes for three reasons: programmatic `close()`, user drag, or window shutdown. Only the drag is attributable to the user's choice. An app that persists "drawer open" must know the difference: a drag close means "remember closed," a programmatic close during teardown means "ignore this," and window minimize means "ignore this." The property lets the app answer the question "was this the user?" without guessing.

**AccessibilityPrefix**: All accessibility IDs are namespaced under a prefix so multiple drawers in the same app (e.g., one per window) do not collide in test automation or assistive technology. The prefix is required, not optional, to enforce namespace discipline.

## Compliance

Not applicable: Component has no compliance checks at the ingredient level; compliance is determined by how tabs are implemented and used.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation from WindowDrawer.swift |
