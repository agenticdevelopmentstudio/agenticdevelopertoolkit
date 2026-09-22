---
id: 46e077a8-1171-4564-9781-7997ff76813a
title: Appearance Mode Toggle
domain: agenticdevelopercookbook://ingredients/appearance-mode-toggle
type: ingredient
version: 1.1.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A button control that cycles between auto, light, and dark appearance modes
  and displays the current state via icon and badge.
platforms:
- typescript
- web
tags:
- appearance
- theme
- toggle
- dark-mode
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Appearance Mode Toggle

## Overview

The Appearance Mode Toggle is a button component that allows users to cycle through three appearance modes: auto, light, and dark. The component reads the current appearance mode from the document element's `data-appearance-mode` attribute and the resolved appearance (whether dark mode is active) from the document element's class list. It displays an icon indicating the current resolved appearance (sun for light, moon for dark) and an optional badge indicator when in auto mode. Clicking the button dispatches a custom event to cycle to the next appearance mode.

## Behavioral Requirements

- **must-render-button**: Component MUST render as a `<button>` element with `type="button"`.
- **must-read-appearance-mode**: Component MUST read the appearance mode from `document.documentElement.dataset.appearanceMode` and treat any unrecognized value as 'auto'.
- **must-read-resolved-appearance**: Component MUST read the resolved appearance from whether the 'dark' class exists on `document.documentElement`, with 'dark' resolving to 'dark' and absence resolving to 'light'.
- **must-display-icon-based-on-resolved**: Component MUST display a moon icon when resolved appearance is 'dark' and a sun icon when resolved appearance is 'light'.
- **must-display-badge-in-auto-mode**: Component MUST display an auto badge element (span with nested SVG) when appearance mode is 'auto'.
- **must-dispatch-cycle-event-on-click**: Component MUST dispatch a custom event named 'awt:appearance-cycle' when the button is clicked.
- **must-listen-for-appearance-changed-event**: Component MUST listen for the 'awt:appearance-changed' custom event on the window and update its internal state when the event is received.
- **must-set-aria-label**: Component MUST set `aria-label` to a string that includes the current mode, resolved appearance, and next expected mode in human-readable language.
- **must-set-title-attribute**: Component MUST set the `title` attribute to the same value as `aria-label`.
- **must-accept-classname-prop**: Component MUST accept an optional `className` prop and merge it with the component's base class name 'awt-appearance-mode-toggle'.
- **must-render-hydration-safe**: Component MUST render safely during server-side rendering by reading from `document` only after mount, defaulting to 'auto' mode and 'light' resolved appearance before hydration is complete.

## Appearance

- **Corner radius**: Not specified by component; inherited from button styling.
- **Padding**: Not specified by component; inherited from button styling.
- **Font**: Not specified by component; inherited from button styling.
- **Background**: Not specified by component; inherited from button styling.
- **Foreground/Text**: Icon rendered inline, uses `currentColor` for stroke, inheriting text color from button.
- **Border**: Not specified by component; inherited from button styling.
- **Shadow**: Not specified by component; inherited from button styling.
- **Min/Max size**: Not specified by component; inherited from button styling. Icon has `viewBox="0 0 24 24"`. Badge size depends on parent button dimensions.

## States

| State | Appearance change |
|-------|------------------|
| Default (light mode) | Sun icon visible; no badge. |
| Default (dark mode) | Moon icon visible; no badge. |
| Default (auto mode) | Sun or moon icon depending on resolved appearance; auto badge visible. |
| Pressed | No appearance change specified by component; inherited from button styling. |
| Disabled | No appearance change specified by component; inherited from button styling. |
| Focused | No appearance change specified by component; inherited from button styling. |

## Accessibility

- **Role**: Button (implicit from semantic `<button>` element).
- **Label requirements**: MUST have an `aria-label` that conveys the current mode and next action. Label format: when in auto mode, "Appearance: Auto (currently [resolved]). Click to switch to dark." When in dark mode, "Dark mode — click for light". When in light mode, "Light mode — click for auto".
- **Icon accessibility**: Icons are marked with `aria-hidden="true"` to prevent screen reader announcement of the SVG markup; the button label alone communicates the control's purpose.
- **Badge accessibility**: Auto badge SVG is marked with `aria-hidden="true"`.
- **Announce state changes**: State changes are announced via updated `aria-label` and `title` attribute when the component re-renders in response to the 'awt:appearance-changed' event.
- **Minimum tap target**: NEEDS REVIEW: Component does not specify a minimum tap target size. The button's size depends on parent styling and context. Implementors MUST ensure the button meets platform minimum touch targets (44×44pt on iOS, 48×48dp on Android, 24×24px minimum on web per WCAG). Evidence needed: tap target requirement from platform design language or accessibility audit.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| toggle-001 | must-render-button | Component renders | Button element with `type="button"` exists in DOM |
| toggle-002 | must-read-appearance-mode | `document.documentElement.dataset.appearanceMode = 'dark'` | Component reads mode as 'dark' |
| toggle-003 | must-read-appearance-mode | `document.documentElement.dataset.appearanceMode = 'invalid'` | Component treats invalid mode as 'auto' |
| toggle-004 | must-read-resolved-appearance | `document.documentElement.classList.contains('dark') = true` | Component resolves appearance as 'dark' |
| toggle-005 | must-read-resolved-appearance | `document.documentElement.classList.contains('dark') = false` | Component resolves appearance as 'light' |
| toggle-006 | must-display-icon-based-on-resolved | Resolved appearance is 'dark' | Moon icon SVG is rendered and sun icon is not |
| toggle-007 | must-display-icon-based-on-resolved | Resolved appearance is 'light' | Sun icon SVG is rendered and moon icon is not |
| toggle-008 | must-display-badge-in-auto-mode | Mode is 'auto' | Badge span with nested SVG is rendered |
| toggle-009 | must-display-badge-in-auto-mode | Mode is 'light' or 'dark' | Badge is not rendered |
| toggle-010 | must-dispatch-cycle-event-on-click | User clicks button | Custom event 'awt:appearance-cycle' is dispatched on window object |
| toggle-011 | must-listen-for-appearance-changed-event | 'awt:appearance-changed' event fires on window | Component's internal state updates and component re-renders |
| toggle-012 | must-set-aria-label, must-set-title-attribute | Mode is 'auto', resolved is 'light' | aria-label and title both equal "Appearance: Auto (currently light). Click to switch to dark." |
| toggle-013 | must-set-aria-label, must-set-title-attribute | Mode is 'dark' | aria-label and title both equal "Dark mode — click for light" |
| toggle-014 | must-set-aria-label, must-set-title-attribute | Mode is 'light' | aria-label and title both equal "Light mode — click for auto" |
| toggle-015 | must-accept-classname-prop | `className="custom"` prop | Button element has class names including both 'awt-appearance-mode-toggle' and 'custom' |
| toggle-016 | must-render-hydration-safe | SSR/hydration scenario before event listener attached | Component renders without calling `document.addEventListener` before hydration |

## Edge Cases

- **Null or missing data-appearance-mode**: If `document.documentElement.dataset.appearanceMode` is undefined or null, the component MUST treat it as 'auto'. This is the hydration default and handles cases where the attribute has not yet been set.
- **Dark class toggled externally**: If an external process adds or removes the 'dark' class on the document element without dispatching the 'awt:appearance-changed' event, the component will not detect the change until that event fires. This is a consistency requirement: state changes MUST be communicated via the custom event, not by polling the class list.
- **Multiple instances**: Multiple AppearanceModeToggle components on the same page MUST all listen to the same 'awt:appearance-changed' event and update independently. Each component maintains its own React state.
- **Event listener lifecycle**: The event listener attached in `useEffect` MUST be cleaned up (removed) when the component unmounts. This prevents memory leaks in single-page applications.
- **Server-side rendering**: When rendering server-side, `typeof document === 'undefined'` returns true and the component MUST default to 'auto' mode with 'light' resolved appearance. No error is thrown.
- **Missing window object**: If `typeof window === 'undefined'` during click handling, the `handleClick` function returns early without dispatching the event. No error is thrown.

## Configuration

Not applicable: Component accepts only one optional prop (`className`) and has no configuration options table.

## Deep Linking

Not applicable: This component is a chrome element and does not correspond to a unique document route. Deep linking applies to pages and screens, not UI controls.

## Localization

Not applicable: Component generates all user-facing strings (aria-label, title) programmatically based on mode state. String templates are hardcoded in the component. A localization system would need to replace the label-generation logic; this is beyond the component's current scope.

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | Not implemented: Component has no animation or transition behavior specified. The badge and icon change are instant. |
| Increase Contrast | Not implemented: Component uses `currentColor` for icons and relies on parent button styling for contrast. Icon contrast depends on parent button's text color. |
| Differentiate Without Color | Not implemented: Component conveys mode state via icon shape (sun vs. moon) and badge presence, not color alone. Satisfies the principle; no additional implementation needed. |

## Feature Flags

Not applicable: Component has no feature flag integration.

## Analytics

| Event | Properties | When |
|-------|-----------|------|
| `appearance_mode_toggle.clicked` | `{ cycle_event_dispatched: true }` | Button is clicked and 'awt:appearance-cycle' event is dispatched |
| `appearance_mode_toggle.state_changed` | `{ mode: 'auto' | 'light' | 'dark', resolved: 'light' | 'dark' }` | Component's state updates in response to 'awt:appearance-changed' event |

## Privacy

- **Data collected**: None. Component does not collect, store, or transmit any user data. It only reads and dispatches events related to appearance preference.
- **Storage**: None. Component does not write to localStorage, cookies, or any persistent storage.
- **Transmission**: None. Component does not make network requests.
- **Retention**: Not applicable; no data is retained.

## Logging

Not applicable: Component does not emit log messages.

## Platform Notes

- **React/Web**: Source files: `packages/web/packages/controls/src/appearance-mode-toggle/AppearanceModeToggle.tsx`. Component exports `AppearanceModeToggle` function and `AppearanceModeToggleProps` type. Uses React hooks (`useState`, `useEffect`) for state management and event listening. Icons and badge are inline SVG elements. No external icon library dependency. Hydration-safe: reads from `document` only after mount.
- **SwiftUI**: Port would use `@State` for mode and resolved appearance. Read mode from `UserDefaults.standard.string(forKey:)` or a custom environment object. Listen for `NotificationCenter` notifications in place of window event listeners. Display conditional SF Symbols: `Image(systemName: resolved == .dark ? "moon.fill" : "sun.max.fill")`. Badge overlay in auto mode using `.overlay(alignment:)`. Button dispatches a `NotificationCenter.default.post()` on tap.
- **Compose**: Port would use `mutableStateOf` for appearance state. Read from `LocalContext.current.getResources().configuration.uiMode` (for system dark mode) and `Settings.Secure` or a data store for user preference. Listen using `LaunchedEffect` with a `BroadcastReceiver` or custom callback. Display conditional icons using `painterResource()` and conditional modifier for badge. Dispatch custom broadcast or callback on button click.
- **AppKit / UIKit**: Port would use `UIAppearance` or `NSAppearance` to read system dark mode. Store user preference in `UserDefaults`. Use `NSAppearanceNameDidChangeNotification` and custom notifications for state updates. Display conditional `UIImage` (SF Symbols) or `NSImage`. Badge as a small badge view overlaid on button. Button action dispatches custom notification or callback.
- **WinUI 3**: Port would use `UISettings` to read system appearance preference. Store user preference in `ApplicationData.Current.LocalSettings.Values`. Listen to `UISettings.ColorValuesChanged` event for system theme changes and custom application event for user-initiated cycles. Display conditional `FontIcon` using SF Symbols (or mapped Segoe MDL2 equivalents: sun icon → ``, moon icon → ``). Badge as a `Border` with `Opacity` overlay on `Button`. Button's `Click` event handler dispatches custom application event via a messaging/event service.

## Design Decisions

- **Three-mode cycle**: The component cycles through three modes (auto → light → dark → auto) because users may want to override the system preference (light/dark) or defer to it (auto). The explicit cycle order is auto → dark → light, established by the label generation logic and the custom event contract — consumers must implement this cycle order.
- **Event-driven state updates**: State does not poll `document` for changes; it listens for the 'awt:appearance-changed' event. This decouples the component from the mechanism that changes appearance and allows multiple components and external systems to stay in sync without tight coupling.
- **Aria-label format**: Labels include both current mode and next expected action because users in auto mode need to know what "currently" means (light or dark) to understand what will happen on click. The next-state hint (e.g., "click to switch to dark") helps predictability.
- **No built-in styling**: Component does not specify padding, corner radius, or colors. It accepts `className` to integrate with any CSS framework. Button size is delegated to parent or CSS, ensuring flexibility.
- **Hydration safety**: Component defaults to 'auto' and 'light' during SSR to avoid hydration mismatch. This is the safest default because auto mode defers to system preference and light is the most common resolved state at page load.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| [wcag-2.1-aa-button-accessible-name](https://www.w3.org/TR/WCAG21/#name-role-value) | passed | Accessibility: Component provides accessible name via aria-label and title. |
| [wcag-2.1-aa-icon-text-alternative](https://www.w3.org/TR/WCAG21/#non-text-content) | passed | Accessibility: SVG icons are marked `aria-hidden="true"` because the button label conveys their meaning. |
| [semantic-html-button](https://html.spec.whatwg.org/multipage/form-controls.html#the-button-element) | passed | HTML: Component uses native `<button>` element with correct `type` attribute. |
| [event-driven-architecture](agenticdevelopercookbook://compliance/component-design#event-driven-architecture) | passed | Architecture: Component listens for and dispatches custom events, enabling loose coupling. |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.1.0 | 2026-09-22 | Mike Fullerton | Remove the review marker from Localization (not applicable); retain tap target marker as genuine gap |
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
