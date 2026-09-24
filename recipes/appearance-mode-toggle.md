---
id: 46e077a8-1171-4564-9781-7997ff76813a
title: Appearance Mode Toggle
domain: agenticdevelopertoolkit://recipes/appearance-mode-toggle
type: ingredient
version: 1.2.1
status: review
language: en
created: '2026-09-22'
modified: '2026-09-24'
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

- **render-button**: Component MUST render as a `<button>` element with `type="button"`.
- **read-appearance-mode**: Component MUST read the appearance mode from `document.documentElement.dataset.appearanceMode` and treat any unrecognized value as 'auto'.
- **read-resolved-appearance**: Component MUST read the resolved appearance from whether the 'dark' class exists on `document.documentElement`, with 'dark' resolving to 'dark' and absence resolving to 'light'.
- **display-icon-based-on-resolved**: Component MUST display a moon icon when resolved appearance is 'dark' and a sun icon when resolved appearance is 'light'.
- **display-badge-in-auto-mode**: Component MUST display an auto badge element (span with nested SVG) when appearance mode is 'auto'.
- **dispatch-cycle-event-on-click**: Component MUST dispatch a custom event named 'awt:appearance-cycle' on `window` when the button is clicked, with no `detail` payload. The component does not change the mode itself — see **External appearance controller** in Design Decisions.
- **listen-for-appearance-changed-event**: Component MUST listen for the 'awt:appearance-changed' custom event on `window` (no `detail` payload is read) and re-read the appearance mode and resolved appearance from `document.documentElement` when the event is received.
- **set-aria-label**: Component MUST set `aria-label` to one of three templates, chosen by mode and resolved appearance: when mode is 'auto', `"Appearance: Auto (currently {resolved}). Click to switch to dark."`; when mode is 'dark', `"Dark mode — click for light"`; when mode is 'light', `"Light mode — click for auto"`.
- **set-title-attribute**: Component MUST set the `title` attribute to the same value as `aria-label`.
- **accept-classname-prop**: Component MUST accept an optional `className` prop and merge it with the component's base class name 'awt-appearance-mode-toggle'.
- **render-hydration-safe**: Component MUST render safely during server-side rendering by reading from `document` only after mount, defaulting to 'auto' mode and 'light' resolved appearance before hydration is complete.

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
| Focused | No appearance change specified by component; inherited from button styling. |

## Accessibility

- **Role**: Button (implicit from semantic `<button>` element).
- **Label requirements**: MUST have an `aria-label` that conveys the current mode and next action. Label format: when in auto mode, "Appearance: Auto (currently [resolved]). Click to switch to dark." When in dark mode, "Dark mode — click for light". When in light mode, "Light mode — click for auto".
- **Icon accessibility**: Icons are marked with `aria-hidden="true"` to prevent screen reader announcement of the SVG markup; the button label alone communicates the control's purpose.
- **Badge accessibility**: Auto badge SVG is marked with `aria-hidden="true"`.
- **Announce state changes**: State changes are announced via updated `aria-label` and `title` attribute when the component re-renders in response to the 'awt:appearance-changed' event.
- **minimum-tap-target**: NEEDS REVIEW: Not implemented in source. `AppearanceModeToggle.tsx` sets no size on the button; its optional default stylesheet (`appearance-mode-toggle.css`: 0.5rem padding plus a 1.25rem icon, ~36×36px) is not enforced by the component and can be overridden, so whether the effective size in a given host layout clears the 44×44pt iOS / 48×48dp Android minimums needs a human judging the rendered button in context.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| toggle-001 | render-button | Component renders | Button element with `type="button"` exists in DOM |
| toggle-002 | read-appearance-mode | `document.documentElement.dataset.appearanceMode = 'dark'` | Component reads mode as 'dark' |
| toggle-003 | read-appearance-mode | `document.documentElement.dataset.appearanceMode = 'invalid'` | Component treats invalid mode as 'auto' |
| toggle-004 | read-resolved-appearance | `document.documentElement.classList.contains('dark') = true` | Component resolves appearance as 'dark' |
| toggle-005 | read-resolved-appearance | `document.documentElement.classList.contains('dark') = false` | Component resolves appearance as 'light' |
| toggle-006 | display-icon-based-on-resolved | Resolved appearance is 'dark' | Moon icon SVG is rendered and sun icon is not |
| toggle-007 | display-icon-based-on-resolved | Resolved appearance is 'light' | Sun icon SVG is rendered and moon icon is not |
| toggle-008 | display-badge-in-auto-mode | Mode is 'auto' | Badge span with nested SVG is rendered |
| toggle-009 | display-badge-in-auto-mode | Mode is 'light' or 'dark' | Badge is not rendered |
| toggle-010 | dispatch-cycle-event-on-click | User clicks button | Custom event 'awt:appearance-cycle' is dispatched on window object |
| toggle-011 | listen-for-appearance-changed-event | 'awt:appearance-changed' event fires on window | Component's internal state updates and component re-renders |
| toggle-012 | set-aria-label, set-title-attribute | Mode is 'auto', resolved is 'light' | aria-label and title both equal "Appearance: Auto (currently light). Click to switch to dark." |
| toggle-013 | set-aria-label, set-title-attribute | Mode is 'dark' | aria-label and title both equal "Dark mode — click for light" |
| toggle-014 | set-aria-label, set-title-attribute | Mode is 'light' | aria-label and title both equal "Light mode — click for auto" |
| toggle-015 | accept-classname-prop | `className="custom"` prop | Button element has class names including both 'awt-appearance-mode-toggle' and 'custom' |
| toggle-016 | render-hydration-safe | SSR/hydration scenario before event listener attached | No access to `document` or `window` during server render; initial output is auto/light |

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

Component generates all user-facing strings (`aria-label`, `title`) from three hardcoded English templates — see **set-aria-label** — with no localization resource lookup or string-injection mechanism. These strings are read aloud by screen readers and shown as a browser tooltip, so they are user-facing text, not internal-only text; the `no-hardcoded-strings` and `string-externalization` checks in Compliance fail on this basis. A consumer that needs localized labels must fork the component or wrap it with its own label-generation logic; the source has no seam for supplying alternative templates.

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | Not implemented: Component has no animation or transition behavior specified. The badge and icon change are instant. |
| Increase Contrast | Not implemented: Component uses `currentColor` for icons and relies on parent button styling for contrast. Icon contrast depends on parent button's text color. |
| Differentiate Without Color | Satisfied: Component conveys mode state via icon shape (sun vs. moon) and badge presence, not color alone. No additional implementation needed. |

## Feature Flags

Not applicable: Component has no feature flag integration.

## Analytics

Not applicable: component emits no analytics.

## Privacy

- **Data collected**: None. Component does not collect, store, or transmit any user data. It only reads and dispatches events related to appearance preference.
- **Storage**: None. Component does not write to localStorage, cookies, or any persistent storage.
- **Transmission**: None. Component does not make network requests.
- **Retention**: Not applicable; no data is retained.

## Logging

Not applicable: Component does not emit log messages.

## Platform Notes

- **React/Web**: Source files: `packages/web/packages/controls/src/appearance-mode-toggle/AppearanceModeToggle.tsx`. Component exports `AppearanceModeToggle` function and `AppearanceModeToggleProps` type. Uses React hooks (`useState`, `useEffect`) for state management and event listening. Icons and badge are inline SVG elements. No external icon library dependency. Hydration-safe: reads from `document` only after mount.
- **SwiftUI**: Read the system's resolved appearance via `@Environment(\.colorScheme)`, and persist the user's chosen mode with `@AppStorage`, backed by the toolkit's existing `UserDefaultsThemeStorage` (`packages/apple/AgenticDeveloperToolkit/Sources/Theme/UserDefaultsThemeStorage.swift`) rather than a fresh UserDefaults key. Display conditional SF Symbols: `Image(systemName: resolved == .dark ? "moon.fill" : "sun.max.fill")`. Badge overlay in auto mode using `.overlay(alignment:)`. Button action hands the cycle to whatever object owns mode state, per **External appearance controller** in Design Decisions.
- **Compose**: Read the system value with `isSystemInDarkTheme()`, not `getResources().configuration`. Persist the user's chosen mode in a `DataStore<Preferences>`, not `Settings.Secure`. Use `mutableStateOf` for the in-memory appearance state, observed via `LaunchedEffect` against the DataStore flow. Display conditional icons using `painterResource()` and a conditional modifier for the badge. Button click hands the cycle to whatever object owns mode state, per **External appearance controller** in Design Decisions.
- **AppKit / UIKit**: `UIAppearance` does not report dark mode, and `NSAppearanceNameDidChangeNotification` does not exist. Read system appearance changes via `traitCollection.userInterfaceStyle` or `registerForTraitChanges` (UIKit), and via KVO on `NSApp.effectiveAppearance` (AppKit). Persist the user's chosen mode with the toolkit's existing `UserDefaultsThemeStorage` (`Sources/Theme/UserDefaultsThemeStorage.swift`) rather than a fresh preference key — `AppKitAppearanceDriver` / `UIKitAppearanceDriver` (`SourcesUI/macOS/Theme/`, `SourcesUI/iOS/Theme/`) already apply light/dark/auto app-wide once the mode changes. Display conditional `UIImage`/`NSImage` (SF Symbols). Badge as a small badge view overlaid on the button.
- **WinUI 3**: Port would use `UISettings` to read system appearance preference. Store user preference in `ApplicationData.Current.LocalSettings.Values`. Listen to `UISettings.ColorValuesChanged` event for system theme changes and a custom application event for user-initiated cycles. Display conditional `FontIcon` using Segoe Fluent Icons glyphs, written out explicitly since glyph names alone render as empty characters and Segoe Fluent Icons are not SF Symbols (for example `` for sun and `` for moon). Badge as a `Border` with `Opacity` overlay on `Button`. Button's `Click` event handler dispatches a custom application event via a messaging/event service.

## Design Decisions

**Three-mode cycle**

**Decision**: The component cycles through three appearance modes in the fixed order auto → dark → light → auto.
**Rationale**: Users may want to override the system preference (light or dark) or defer to it (auto). This order is fixed by the label generation logic (see **set-aria-label**) and by the event contract described in External appearance controller below — the external controller that owns mode state MUST advance through this same order when it receives the cycle event.
**Approved**: pending

**External appearance controller**

**Decision**: The component does not manage appearance state itself. It dispatches an `awt:appearance-cycle` `CustomEvent` on `window` (no `detail` payload) when clicked, and listens for an `awt:appearance-changed` `CustomEvent` on `window` (also no `detail` payload) to know when to re-read `document.documentElement`.
**Rationale**: This keeps the toggle decoupled from any specific state-storage mechanism, so any controller that writes `data-appearance-mode` and the `dark` class and honors this event contract can drive it — for example `ColorModeProvider`/`useColorMode` in `packages/web/packages/themes/src/colorMode.tsx`, which implements this exact contract for a different toggle in this toolkit.
**Approved**: pending

**Event-driven state updates**

**Decision**: State does not poll `document` for changes; it listens for the `awt:appearance-changed` event described in External appearance controller above.
**Rationale**: This decouples the component from the mechanism that changes appearance and allows multiple components and external systems to stay in sync without tight coupling.
**Approved**: pending

**Aria-label format**

**Decision**: Labels include both the current mode and the next expected action.
**Rationale**: Users in auto mode need to know what "currently" means (light or dark) to understand what will happen on click. The next-state hint (e.g., "click to switch to dark") helps predictability.
**Approved**: pending

**No built-in styling**

**Decision**: Component does not specify padding, corner radius, or colors; it accepts `className` to integrate with any CSS framework.
**Rationale**: Button size is delegated to parent or CSS, ensuring flexibility across consuming applications.
**Approved**: pending

**Hydration safety**

**Decision**: Component defaults to `auto` mode and `light` resolved appearance during server-side rendering.
**Rationale**: The server has no access to `document`, so it cannot know the real mode or resolved appearance; rendering any other combination risks a mismatch between server-rendered and client-rendered markup on first paint. `auto`/`light` is simply the fixed, deterministic fallback the source uses before mount, not a claim about which state is most common among users.
**Approved**: pending

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| [screen-reader-support](agenticdevelopercookbook://compliance/accessibility#screen-reader-support) | passed | Accessibility |
| [semantic-markup](agenticdevelopercookbook://compliance/accessibility#semantic-markup) | passed | Accessibility |
| [keyboard-navigable](agenticdevelopercookbook://compliance/accessibility#keyboard-navigable) | passed | Accessibility |
| [touch-target-size](agenticdevelopercookbook://compliance/accessibility#touch-target-size) | partial | Accessibility |
| [contrast-ratio](agenticdevelopercookbook://compliance/accessibility#contrast-ratio) | partial | Accessibility |
| [no-hardcoded-strings](agenticdevelopercookbook://compliance/internationalization#no-hardcoded-strings) | failed | Internationalization |
| [string-externalization](agenticdevelopercookbook://compliance/internationalization#string-externalization) | failed | Internationalization |

The passed and partial statuses rest on the `<button type="button">` element, the always-present `aria-label`/`title`, the `aria-hidden="true"` icons, and the `currentColor`-based, parent-delegated styling in `AppearanceModeToggle.tsx`; the two failed internationalization checks rest on that same file's three hardcoded English label templates, which the source has no mechanism to override.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.2.0 | 2026-09-22 | Mike Fullerton | Lint pass: renamed requirements to subject-only kebab-case and folded the label templates into set-aria-label; documented the external appearance-controller event contract (payload, target); resolved the cycle-order and hydration-rationale contradictions in Design Decisions; corrected Localization from a false not-applicable to a described gap; replaced invented/external Compliance links with real catalog checks; marked Analytics not-applicable; fixed toggle-016's document/window assertion; resolved the Differentiate-Without-Color contradiction; removed the unsupported Disabled state; corrected the Compose, AppKit/UIKit, SwiftUI, and WinUI 3 platform notes |
| 1.1.0 | 2026-09-22 | Mike Fullerton | Remove the review marker from Localization (not applicable); retain tap target marker as genuine gap |
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
| 1.2.1 | 2026-09-24 | Mike Fullerton | Phase 6 lint: re-audited open-question markers against the marker rules; kept markers are one-line named bullets. |
