---
id: 17398d3a-df67-44c6-89c5-0edfc09bff7c
title: Dismissible Hint
domain: agenticdevelopercookbook://ingredients/dismissible-hint
type: ingredient
version: 1.1.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A hint component with persistent dismissal state stored in localStorage.
platforms:
- web
tags: []
depends-on: []
related: []
references: []
---

# Dismissible Hint

## Overview

A dismissible hint displays contextual information to the user with a close button. The dismissal state persists across sessions in browser local storage. When the user closes the hint, it is hidden and its dismissed state is remembered by unique identifier.

## Behavioral Requirements

- **must-accept-id-prop**: Component MUST accept a required string `id` prop that uniquely identifies this hint instance.
- **must-render-children**: Component MUST render the `children` prop as the hint's text content.
- **must-render-close-button**: Component MUST render a close button that, when clicked, dismisses the hint and persists the dismissal state.
- **must-persist-dismissal-state**: Component MUST persist dismissal state to browser localStorage with the key `aws-hint-dismissed:<id>` set to the value `1`.
- **must-load-dismissal-state-on-mount**: Component MUST load dismissal state from localStorage on mount using the hint's `id` and set initial visibility accordingly.
- **must-not-render-when-dismissed**: Component MUST render as `null` if the dismissal state in localStorage indicates the hint has been previously dismissed.
- **must-handle-missing-localstorage**: Component MUST silently treat any localStorage read or write error as a failure and continue without throwing. On read error, the component MUST treat the hint as not dismissed. On write error, the component MUST not update the in-memory dismissed state.
- **must-accept-classname-prop**: Component MUST accept an optional `className` prop and apply it to the container element, merged with the base class `aws-hint`.
- **must-apply-note-role**: Component MUST render the container with `role="note"` for semantic accessibility.
- **must-label-close-button**: Component MUST render the close button with `aria-label="Dismiss"`.

## Appearance

Not applicable: Component styling is entirely CSS-driven; the source code provides no hardcoded visual specifications. The component outputs class names (`aws-hint`, `aws-hint__text`, `aws-hint__close`) that are styled by external CSS.

## States

| State | Appearance change |
|-------|------------------|
| Shown (initial or first visit) | Hint container and text visible; close button visible |
| Dismissed (user clicked close or dismissal state loaded) | Container renders as null; element removed from DOM |

## Accessibility

- Role: `note` — semantic container for informational content.
- Close button label: `aria-label="Dismiss"` — announces button purpose to screen readers.
- Minimum tap target: Screen readers navigate the close button via semantic role and label; visual tap target size is determined by CSS and MUST meet platform accessibility guidelines (44×44pt minimum on iOS/macOS, 48×48dp on Android).
- Keyboard navigation: The close button MUST be keyboard-navigable as a standard `<button>` element; user can Tab to it and press Enter or Space to dismiss.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|----|----|----|
| dismissible-hint-001 | must-accept-id-prop, must-render-children | `<DismissibleHint id="test-hint">Example hint text</DismissibleHint>` | Container with `role="note"` renders; text "Example hint text" is visible |
| dismissible-hint-002 | must-render-close-button, must-label-close-button | Render with close button visible | Button with `aria-label="Dismiss"` and text content "×" is present |
| dismissible-hint-003 | must-persist-dismissal-state | Click close button; inspect localStorage | Entry `aws-hint-dismissed:test-hint=1` exists in localStorage |
| dismissible-hint-004 | must-load-dismissal-state-on-mount | localStorage already contains `aws-hint-dismissed:test-hint=1`; mount component | Component renders as null; nothing displayed |
| dismissible-hint-005 | must-not-render-when-dismissed | Dismiss hint; remount component with same `id` | Component renders as null on remount |
| dismissible-hint-006 | must-accept-classname-prop | `<DismissibleHint id="test" className="custom-class">text</DismissibleHint>` | Container has class list containing both `aws-hint` and `custom-class` |
| dismissible-hint-007 | must-handle-missing-localstorage | localStorage.getItem raises exception during read | Component treats hint as not dismissed; renders normally |
| dismissible-hint-008 | must-handle-missing-localstorage | localStorage.setItem raises exception on close button click | Component's in-memory state updates (local state shows as dismissed) but localStorage write silently fails |
| dismissible-hint-009 | must-apply-note-role | Render component | Container div has `role="note"` |

## Edge Cases

- **localStorage unavailable (private browsing, quota exceeded, or access denied)**: Reading throws exception → component treats as not dismissed and renders. Writing throws exception → in-memory state updates so the hint appears dismissed in the current session, but state is not persisted. User will see the hint again on page reload or next session.
- **SSR context (window undefined)**: `readDismissed` returns false and `writeDismissed` returns early. Component renders on server as not dismissed; on client hydration, reads dismissal state and may re-render as dismissed.
- **Empty or missing children**: Component renders container and close button with no text content (children is optional). Display depends on CSS.
- **Missing or empty id prop**: Behavior is undefined; localStorage key will be `aws-hint-dismissed:` (empty suffix). This is a configuration error. In typed implementations (TypeScript), the `id` prop is type-checked as required via the `DismissibleHintProps` interface; omitting it will fail type checking.
- **Multiple instances with same id**: All instances share the same dismissal state in localStorage. Dismissing one will cause all others with the same id to not render on reload.
- **id changed after mount**: The effect re-runs and reads the new id's dismissal state. If the old id was dismissed, the component will re-render if the new id is not dismissed.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| id | string | (required) | Unique identifier for this hint instance; used as suffix for localStorage key. |
| children | ReactNode | undefined | Hint text or content to display. |
| className | string | undefined | Additional CSS class to merge with `aws-hint` base class. |

## Deep Linking

Not applicable: Dismissible hints are not navigation endpoints; they are informational UI elements without associated URLs or deep linking patterns.

## Localization

Not applicable: The component renders no user-facing strings except the close button symbol "×". The `aria-label="Dismiss"` is hardcoded in English and not configurable. Localization of this string is a Design Decision (see below).

## Accessibility Options

- **Reduce Motion**: The component does not animate and is not affected by prefers-reduced-motion. No change in behavior.
- **Increase Contrast**: The component provides no built-in contrast-aware styling. Contrast is managed by CSS; implementations SHOULD ensure the close button and text meet WCAG AA contrast requirements on light and dark backgrounds.
- **Differentiate Without Color**: The close button uses a visible "×" symbol, not color alone, to indicate its function. The aria-label provides text for screen readers.

## Feature Flags

Not applicable: Component has no runtime feature flag configuration in the source code.

## Analytics

Not applicable: Component generates no analytics events.

## Privacy

- **Data collected**: Dismissal state (boolean) stored with a unique hint id as localStorage key.
- **Storage**: Browser localStorage, local to the device and origin.
- **Transmission**: No data leaves the device; localStorage is not sent to a server.
- **Retention**: Dismissal state persists in localStorage until the user clears browser data or the site's storage is manually deleted by the user.

## Logging

Not applicable: Component logs no diagnostic messages.

## Platform Notes

- **SwiftUI**: Use `@State` to track dismissed state. Persist to `UserDefaults` using the hint id as the key. Load on appear and save on dismiss button tap. Use `deprecatedAction` or `Environment(\.dismiss)` for the close button. Render `EmptyView()` when dismissed.
- **Compose**: Use `remember { mutableStateOf(false) }` for dismissed state. Persist to `SharedPreferences` using `PreferenceManager.getDefaultSharedPreferences(context)` with the hint id as key. Use `LaunchedEffect(id)` to load state on composition. Emit nothing when dismissed.
- **React/Web**: This is the source implementation. See source code in packages/web/packages/controls/src/user-settings/components/DismissibleHint.tsx. Uses React hooks (useState, useEffect) and browser localStorage.
- **AppKit / UIKit**: Use `@Published` or `@State` (SwiftUI) or `NSViewController` with stored properties (AppKit, UIKit). Persist to `UserDefaults.standard` with hint id as key. Use `NSButton` (AppKit) or `UIButton` (UIKit) for the close button. Return `nil` or set `isHidden = true` when dismissed.
- **WinUI 3**: Use `ObservableObject` pattern with a backing field for dismissed state. Persist to `ApplicationData.Current.LocalSettings.Values` using the hint id as key. Use a `Button` control with `Content="×"` and `AutomationProperties.Name="Dismiss"`. Bind visibility via `Visibility` converter: `dismissed ? Visibility.Collapsed : Visibility.Visible`.

## Design Decisions

- **Silent failure on localStorage errors**: The component silently ignores localStorage read/write failures. This prioritizes resilience over error reporting. In an inaccessible environment (private browsing, quota exceeded), the hint will appear on every visit. Alternatives would be to log errors to a telemetry service or provide a fallback in-memory store, but the source code chose silent degradation.
- **"×" symbol for close button**: The close button renders a literal "×" character rather than an icon or "Close" text label. This is a visual convention for dismissible UI. Implementations on other platforms MAY use a platform-idiomatic close affordance (e.g., iOS system close symbol, Material Design close icon) while preserving the semantic `aria-label="Dismiss"`.
- **Hardcoded English aria-label**: The aria-label is not configurable or localized. Implementations SHOULD make the aria-label prop optional and defaulting to a localized string.
- **Single-char localStorage value**: Dismissal is stored as the string `"1"` (not a boolean or JSON). This is a minimal storage choice. The comparison `getItem(...) === '1'` treats any missing or mismatched value as "not dismissed."

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| Keyboard navigable | passed | Accessibility |
| Semantic role present | passed | Accessibility |
| ARIA labels present | passed | Accessibility |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.1.0 | 2026-09-22 | Mike Fullerton | Fix marker on id prop: state type safety behavior from source |
| 1.0.0 | 2026-09-22 | | Initial creation |
