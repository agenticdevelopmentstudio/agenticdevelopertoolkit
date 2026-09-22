---
id: 6d2dc0d3-e373-448c-81c9-76b2e5c03057
title: Unsaved Changes Guard
domain: agenticdevelopercookbook://ingredients/unsaved-changes-guard
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Blocks navigation and page unload while unsaved changes exist, prompting
  user confirmation before discard.
platforms:
- typescript
- web
tags:
- navigation-guard
- forms
- unsaved-changes
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Unsaved Changes Guard

## Overview

A navigation guard that prevents accidental data loss by blocking page navigation and unload events when the guard is armed (`when` is true). It intercepts four classes of navigation: hard navigation (reload, tab close, external link), in-app anchor clicks, programmatic router navigation, and browser Back/Forward button presses. When a blocked navigation is triggered, the guard displays a confirmation modal; the user must explicitly choose to discard changes or stay on the page.

## Behavioral Requirements

- **must-block-beforeunload**: The guard MUST prevent `beforeunload` events from unloading the page when `when` is true and no navigation has been approved via `approveNavigation()`.
- **must-prompt-anchor-navigation**: The guard MUST intercept same-origin anchor clicks with left button, no modifier keys, and no `download` attribute, displaying a confirmation prompt instead of navigating.
- **must-skip-marked-anchors**: The guard MUST NOT intercept anchors bearing the `GUARDED_NAV_ATTR` attribute (those anchors' own handlers consult `confirmNavigation()` directly).
- **must-skip-same-page-links**: The guard MUST NOT block same-page navigations (same pathname and search; hash-only changes are allowed through).
- **must-skip-cross-origin**: The guard MUST NOT intercept cross-origin anchor navigations (they unload the page and `beforeunload` already covers them).
- **must-guard-back-button**: The guard MUST intercept browser Back/Forward via a same-URL history sentinel; only the primary guard in a multi-guard registry arms the sentinel.
- **must-register-with-guide**: The guard MUST register itself with the navigation-guard registry so programmatic navigation via `router.push()` awaits confirmation.
- **must-call-onNavigate**: When the user confirms discard on an anchor navigation, the guard MUST call `onNavigate(href)` if provided; otherwise fall back to `window.location.assign(href)`.
- **must-approve-briefly**: After the user confirms, the guard MUST set an internal approval flag that prevents `beforeunload` from re-prompting during the navigation itself, expiring after 1000ms.
- **must-coalesce-multiple-guards**: When multiple guards are armed, the registry's first-registered guard is primary; only the primary answers `confirmNavigation()` and arms the sentinel. Non-primary guards' `beforeunload` listeners coalesce into the browser's native prompt.
- **must-not-prompt-after-approval**: The guard MUST NOT display a confirmation prompt if a prior guard has already approved the navigation via `approveNavigation()` (called just before a successful save).
- **must-prevent-default**: The guard MUST call `e.preventDefault()` on intercepted clicks (allowing other handlers like analytics and menu close-on-select to still run).
- **must-clear-sentinel-on-back**: The guard MUST set the stored sentinel URL to null when Back consumes it, so re-arming at the same URL pushes a fresh sentinel.
- **should-update-sentinel-on-rearm**: The guard SHOULD re-arm the Back sentinel whenever primary status changes, in case a prior primary disarmed and this guard inherits the role.

## Appearance

Not applicable: This component is a guard with no visible UI. The `UnsavedChangesAlert` child component renders the confirmation modal.

## States

Not applicable: The guard has no visual states. It maintains internal state (confirm pending, approval flag, sentinel URL) but these are not user-facing states.

## Accessibility

Not applicable: Accessibility is handled by the `UnsavedChangesAlert` component that renders the confirmation modal.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| guard-001 | must-block-beforeunload | Guard armed (`when=true`); user presses Cmd+R or closes tab | Browser's native "Leave site?" prompt appears; page does not reload |
| guard-002 | must-prompt-anchor-navigation | Guard armed; user left-clicks an anchor to `/other?foo=bar` on same origin | `UnsavedChangesAlert` opens; page stays at current URL until user chooses |
| guard-003 | must-skip-marked-anchors | Guard armed; anchor has `GUARDED_NAV_ATTR` attribute | No confirmation from guard; anchor's own handler runs uninterrupted |
| guard-004 | must-skip-same-page-links | Guard armed; user clicks `href="#section"` on same page | Navigation completes without confirmation; hash changes |
| guard-005 | must-skip-cross-origin | Guard armed; user clicks anchor to `https://example.com` | No confirmation from guard; browser handles cross-origin unload via `beforeunload` |
| guard-006 | must-guard-back-button | Guard armed as primary; user presses browser Back button | Sentinel same-URL history entry is consumed; `UnsavedChangesAlert` opens |
| guard-007 | must-call-onNavigate | Guard armed; user confirms discard on anchor to `/next`; `onNavigate` is provided | `onNavigate("/next")` is called with the target href |
| guard-008 | must-call-onNavigate default | Guard armed; user confirms discard on anchor to `/next`; `onNavigate` is not provided | `window.location.assign("/next")` is called |
| guard-009 | must-approve-briefly | User confirms navigation; page stays mounted with dirty state | `beforeunload` does not prompt during the 1000ms approval window |
| guard-010 | must-not-prompt-after-approval | `approveNavigation()` called (prior guard); guard with `when=true` sees a navigation | No confirmation is raised; navigation proceeds |
| guard-011 | must-prevent-default | Guard armed; user clicks anchor | `e.preventDefault()` is called; other click handlers still execute |
| guard-012 | must-prevent-default on popstate | User presses Back while primary guard is armed | Click listener bails on `defaultPrevented` if a parent already intercepted; only primary's popstate handler fires |
| guard-013 | must-clear-sentinel-on-back | Primary guard armed; user presses Back (consumes sentinel); confirm discard | `sentinelRef.current` is set to null after popstate |
| guard-014 | must-update-sentinel-on-rearm | Secondary guard armed; primary guard disarms; subscription fires re-arm | `sentinelRef.current` updates if this guard is now primary and at a new URL |

## Edge Cases

- **Navigation after mount disarm**: If `when` transitions from true to false before any navigation event fires, all listeners clean up and no state persists.
- **Multiple confirms pending**: A popstate fires while an anchor click's confirm is open. Only one confirm can be pending at a time; `setConfirm` overwrites the prior one. The prior resolver never fires.
- **Disarm mid-navigation**: If `when` becomes false while a confirm is displayed, the alert closes (no confirm pending) and user cannot proceed. The navigation is abandoned.
- **Sentinel URL changes before re-arm**: Page navigates to a new URL while guard is still armed. The stored sentinel URL no longer matches `window.location.href`, so the next re-arm pushes a fresh sentinel.
- **beforeunload with no approval and no registry approval**: Guard is armed and no `approveNavigation()` has been called. The beforeunload handler must return immediately without prompting if another guard (the primary, or external approval) already handled it.
- **Click with modifiers**: User Cmd+clicks an anchor (new tab). Guard does not intercept (modifier key check exits). Browser opens the link in a new tab without confirmation.
- **Anchor target="_blank" or target="_other"**: Guard does not intercept (non-`_self` target check exits). Browser opens in specified target.
- **Unparseable anchor href**: Anchor's `href` attribute is not a valid URL. Try/catch on `new URL()` silently returns; no confirmation is raised.
- **Anchor with hash-only href change from current location**: Anchor href is `#section` when page is already at `/path?q=1#other`. Same pathname and search match; guard does not prompt.

## Configuration

| Option | Type | Required | Default | Description |
|--------|------|----------|---------|-------------|
| `when` | boolean | yes | — | Activates the guard; when true, navigation is blocked until approved or discarded |
| `onNavigate` | `(href: string) => void` | no | `window.location.assign` | Custom handler for confirmed anchor navigations; if not provided, uses full-page load |

## Deep Linking

Not applicable: The guard is a container component, not a route or page destination.

## Localization

Not applicable: The guard passes control to `UnsavedChangesAlert`, which handles localized confirmation strings.

## Accessibility Options

Not applicable: Accessibility concerns are delegated to `UnsavedChangesAlert` (keyboard focus, `aria` roles, dismissal by Escape key).

## Feature Flags

Not applicable: The guard's visibility and behavior are controlled by the parent component via the `when` prop.

## Analytics

Not applicable: Analytics events (if any) are emitted by `UnsavedChangesAlert` when the user chooses discard or stay.

## Privacy

Not applicable: The guard stores no user data, collects no analytics, and transmits no information.

## Logging

Not applicable: Internal state changes (confirm pending, approval flag, sentinel URL) are not logged; they are private to the component.

## Platform Notes

- **SwiftUI**: Create a navigation modifier that monitors an `@State` flag (equivalent to `when`). Intercept `NavigationLink` destinations via `navigationDestination` and present a confirmation alert. Handle system-level navigation (app backgrounding) via `scenePhase`. There is no browser `beforeunload` equivalent; rely on `scenePhase` changes and explicit navigation interception. Back/Forward gesture handling is platform-controlled; use `navigationDestination` with a state machine to intercept.
- **Compose**: Use a `BackHandler` callback registered conditionally on the `when` flag. Intercept navigation via custom `NavController` wrappers or navigation compose destination interceptors. No `beforeunload` equivalent; use `onPause` or lifecycle callbacks for app-level exit handling. The registry pattern maps to a centralized `CompositionLocal` holding the active guard state.
- **React/Web**: Source implementation in `packages/web/packages/ui/src/components/unsaved-changes-guard.tsx`. The component listens to `beforeunload`, intercepts anchor clicks via a document capture-phase listener, and manages browser history via `pushState` for Back button interception. See `lib/navigation-guard.ts` for the registry pattern that coalesces multiple guards into one primary.
- **AppKit / UIKit**: Intercept navigation via `WKWebView` delegate methods (`webView:decidePolicyForNavigationAction:`) for web content, or `UIViewController` transitions for native navigation. Detect unload-like events via `AppDelegate` or `SceneDelegate` lifecycle methods. Back/Forward navigation is not applicable in native UI; route stack management is explicit and can be guarded via custom transition controllers.
- **WinUI 3**: Intercept navigation via the `Frame.NavigationFailed` and `Frame.Navigating` events (set `e.Cancel = true` to block). For web content in `WebView2`, attach a `WebResourceRequested` handler to intercept navigation. Implement a `BackRequested` handler in the `SystemNavigationManager` to guard the Back button. Store a confirmation dialog state in a view-model property and bind it to a XAML `ContentDialog`.

## Design Decisions

- **Sentinel over state flag**: Rather than a boolean flag tracking "Back interposed", the guard stores the URL a sentinel was pushed for. This allows re-arming at different URLs without stacking multiple sentinels. A long-lived mount (e.g., hub workspace chrome) may cycle through many routes; re-arming at a route it has already armed must not push a second sentinel.
- **1000ms approval window**: The window is long enough for `beforeunload` to fire (synchronous or near-synchronous), but short enough that a client-side `router.push()` with no unload re-arms the guard while the page stays mounted and dirty. This prevents races where the page unloads (approval expires) just before reaching the next route.
- **Primary guard pattern**: Multiple guards coexist (e.g., hub root layout + settings overlay). Only the primary answers `confirmNavigation()` to prevent N confirmation prompts. Non-primary guards still block `beforeunload`, coalescing into the browser's single native prompt. If the primary disarms, the first non-primary takes over dynamically (registered in library order, not creation order).
- **Capture-phase click listener**: The guard attaches to `document` in the capture phase, not on individual anchors. This intercepts clicks before the framework's router handler fires. If the handler cancels the event (via `preventDefault`), the guard bails; if the anchor has `GUARDED_NAV_ATTR`, the anchor's own handler is responsible for consulting `confirmNavigation()` directly.
- **Discard -> resolve true, stay -> resolve false**: The `confirm` resolver returns `true` for discard and `false` for stay. The primary popstate handler then re-issues `window.history.back()` on discard or re-pushes the sentinel on stay.

## Compliance

Not applicable: This is a guard component with no security, privacy, or compliance-specific behavior beyond the no-data-loss goal, which the component achieves by design.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
