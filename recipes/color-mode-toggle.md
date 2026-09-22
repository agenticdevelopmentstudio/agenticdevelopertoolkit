---
id: 7b54db6e-755d-4665-a091-d34cfcaac146
title: Color Mode Toggle
domain: agenticdevelopercookbook://ingredients/color-mode-toggle
type: ingredient
version: 1.1.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A controlled toggle button that cycles between light, dark, and automatic
  (system) color modes.
platforms:
- typescript
- web
tags:
- theme
- appearance
- toggle
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Color Mode Toggle

## Overview

The Color Mode Toggle is a button component that allows users to cycle between three color modes: **auto** (follow system preference), **dark**, and **light**. The component is presentation-only — it accepts the current mode as a prop and notifies the parent via a callback when the user requests a change. This design allows the component to be used in any context where color mode preference needs to be controlled, regardless of where that preference is stored (user account, localStorage, application state).

The component visually indicates the current mode with three icon states (Sun for light, Moon for dark, RefreshCw refresh icon for auto). When the mode is "auto", the component queries the system's `prefers-color-scheme` to determine and display the currently active effective mode.

## Behavioral Requirements

- **must-render-button**: Component MUST render as a `<button>` element with `type="button"`.
- **must-render-three-icons**: Component MUST render three SVG icons (Sun, Moon, and RefreshCw refresh) simultaneously, with CSS controlling visibility based on mode.
- **must-accept-mode-prop**: Component MUST accept a `mode` prop with value "auto", "dark", or "light".
- **must-accept-onChange-callback**: Component MUST accept an `onChange` callback prop that receives the next mode in the cycle when the button is pressed.
- **must-cycle-modes**: Component MUST cycle modes in order: auto → dark → light → auto when clicked.
- **must-support-className**: Component MUST accept an optional `className` prop to apply custom styling (e.g., host button identity).
- **must-read-system-dark-preference**: When `mode` is "auto", component MUST query `window.matchMedia("(prefers-color-scheme: dark)")` to determine the effective mode.
- **must-listen-to-system-changes**: Component MUST subscribe to changes in the system dark mode preference and update the displayed effective mode without requiring props to change.
- **must-provide-aria-label**: Component MUST set an `aria-label` attribute that includes the current mode and the next mode in cycle, provided after client hydration.
- **must-provide-title-attribute**: Component MUST set a `title` attribute (tooltip) that describes the current mode and how to switch, provided after client hydration.
- **must-defer-label-until-mounted**: Component MUST NOT set `aria-label` or `title` on server-side rendering; these attributes MUST only be populated after client mounting.
- **must-handle-missing-matchMedia**: When `window.matchMedia` is unavailable (server-side rendering or older browsers), component MUST treat system dark mode as false.

## Appearance

- **Icon size**: 24×24px (via strokeWidth 2 for Sun/Moon, strokeWidth 3 for RefreshCw badge)
- **Color**: Icons inherit the text color of the button's scope; determined by CSS based on `data-color-mode` or `.dark` class on document root
- **Padding**: None — component is a bare icon button with no internal spacing
- **Background**: None by default — host application supplies button styling via className
- **Border**: None by default
- **Corner radius**: None
- **Shadow**: None
- **Visibility logic**: CSS rules (`.adh-color-mode-toggle__*` selectors) determine which icon is visible based on the `data-color-mode` attribute on `<html>` and presence of `.dark` class

## States

| State | Appearance change | Trigger |
|-------|------------------|---------|
| Default (no interaction) | All three icons present in DOM; CSS determines which is visible based on mode | Initial render |
| Hover | Depends on host button styling (passed via className) | User moves pointer over button |
| Pressed/Active | Depends on host button styling (passed via className) | User clicks button |
| Focused | Depends on host button styling (passed via className) | User tabs to button or clicks it |
| Disabled | Not supported by component | N/A |

## Accessibility

- **Role**: Button (implicit from `<button>` element)
- **Label requirement**: `aria-label` MUST communicate the current mode and available action. Before hydration, label reads "Theme". After hydration, label reads "Theme: [mode]. Click to switch to [next mode]." If mode is "auto", the current effective mode (light or dark) is included in parentheses.
- **Title**: Tooltip text MUST be populated after client mount. Text reads "Following system (light|dark)" for auto mode, or "[Dark|Light] mode — click for [light|auto]" for explicit modes.
- **Touch target size**: The component itself is an icon button and relies on the host's button styling to meet platform touch target minimums (44×44pt on iOS, 48×48dp on Android, platform-appropriate for web).
- **Keyboard navigation**: Button MUST be keyboard accessible and focusable (inherent from `<button>` element).
- **Announcement of state**: The `aria-label` changes when mode changes, and assistive technologies MUST announce the new label on next interaction.
- **No color-only information**: The three different icons (Sun, Moon, RefreshCw) serve as distinct visual indicators, not relying on color alone.

## Conformance Test Vectors

| ID | Requirements | Input | Expected | Notes |
|----|-------------|-------|----------|-------|
| cmt-001 | must-render-button | Render component with mode="light" | HTML contains `<button type="button">` element | |
| cmt-002 | must-render-three-icons | Render component | Three SVG icons present in DOM (Moon, Sun, RefreshCw) | CSS controls which is visible |
| cmt-003 | must-accept-mode-prop | mode="auto" | Component accepts and does not throw | |
| cmt-004 | must-accept-mode-prop | mode="dark" | Component accepts and does not throw | |
| cmt-005 | must-accept-mode-prop | mode="light" | Component accepts and does not throw | |
| cmt-006 | must-cycle-modes | mode="auto" clicked once | onChange called with "dark" | |
| cmt-007 | must-cycle-modes | mode="dark" clicked once | onChange called with "light" | |
| cmt-008 | must-cycle-modes | mode="light" clicked once | onChange called with "auto" | |
| cmt-009 | must-support-className | className="my-custom-class" passed | Element has class "my-custom-class" applied | |
| cmt-010 | must-read-system-dark-preference | mode="auto" and system prefers dark | Effective mode is "dark" | Via matchMedia query |
| cmt-011 | must-read-system-dark-preference | mode="auto" and system prefers light | Effective mode is "light" | Via matchMedia query |
| cmt-012 | must-listen-to-system-changes | mode="auto" and system changes from light to dark | aria-label updates to reflect new effective mode | Should reflect change without prop change |
| cmt-013 | must-provide-aria-label | After client mount with mode="light" | aria-label contains "Light mode" | |
| cmt-014 | must-provide-aria-label | After client mount with mode="auto" | aria-label contains "Auto (currently light)" or "Auto (currently dark)" | Based on system preference |
| cmt-015 | must-provide-title-attribute | After client mount with mode="light" | title contains "Light mode — click for auto" | Tooltip text |
| cmt-016 | must-provide-title-attribute | After client mount with mode="dark" | title contains "Dark mode — click for light" | Tooltip text |
| cmt-017 | must-provide-title-attribute | After client mount with mode="auto" | title contains "Following system (light)" or "Following system (dark)" | Based on system preference |
| cmt-018 | must-defer-label-until-mounted | Server-side render mode="light" | aria-label is "Theme" only | No specific mode in SSR HTML |
| cmt-019 | must-defer-label-until-mounted | After hydration mode="light" | aria-label becomes "Theme: light. Click to switch to auto." | Updated after mount |
| cmt-020 | must-handle-missing-matchMedia | mode="auto" in environment without matchMedia | Component does not throw; treats system as light mode | |

## Edge Cases

- **Null mode or missing prop**: Not applicable. Component interface requires `mode` to be one of three specific values; type safety enforces this in TypeScript.
- **Null onChange or missing prop**: Not applicable. Component interface requires `onChange` to be a callback function; the component must be used with both props provided.
- **System preference changes during auto mode**: When mode is "auto", component MUST subscribe to the `change` event on the matchMedia query and update the resolved effective mode. No prop change from parent is required; the update happens internally via `useSyncExternalStore`.
- **matchMedia not available (SSR/server context)**: Component MUST treat system dark mode as `false` and must not throw. The `getServerSystemDark()` function returns false on server.
- **matchMedia available but event support missing (legacy Safari < 14)**: Component MUST proactively check for `addEventListener` support on the MediaQueryList object. If unavailable, the component MUST return an empty unsubscribe function and continue rendering.
- **Rapid successive clicks**: Each click calls `onChange` with the next mode in the cycle. The parent is responsible for debouncing or managing state; the component imposes no rate limits.
- **Component unmounts while system preference listener is active**: The `useSyncExternalStore` subscription cleanup (returned unsubscribe function) MUST properly remove the event listener.
- **Hydration mismatch**: The component uses `mounted` state to prevent hydration mismatches. Server-side, `aria-label` and `title` are omitted or set to placeholder values. After hydration, the real labels populate without re-rendering the HTML structure.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `mode` | "auto" \| "dark" \| "light" | (required) | The current color mode preference. Parent must provide this; not stored in component state. |
| `onChange` | (next: ColorMode) => void | (required) | Callback invoked when user clicks button. Receives the next mode in the cycle. |
| `className` | string | undefined | Optional CSS class name to apply to the button element. Used to integrate the button's styling with the host application's button identity. |

## Deep Linking

Not applicable. The Color Mode Toggle is a control component that does not itself navigate or manage routes.

## Localization

Not applicable. All user-facing text (aria-label, title tooltip) is hardcoded in English and derived from the mode values. A parent application wishing to localize this text would need to wrap the component or use a custom implementation.

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | Not applicable: Component does not apply transitions on mode change; mode changes are instantaneous. |
| Increase Contrast | Not applicable: Component is an unstyled icon button relying on host application styling via `className` prop. Contrast adjustments are the host's responsibility. |
| Differentiate Without Color | Component uses three distinct icon shapes (Sun for light, Moon for dark, RefreshCw for auto) as the primary visual indicator, plus complete text labels in `aria-label` and `title` attributes, ensuring mode is communicated without relying solely on color. |

## Feature Flags

Not applicable. The component has no feature flags or toggles. It is always enabled and always cycles through all three modes.

## Analytics

Not applicable. The component does not emit any analytics events. The parent application is responsible for tracking user interactions with this component if desired.

## Privacy

Not applicable. The component does not collect, store, transmit, or retain any user data. It only reads the system's `prefers-color-scheme` setting, which is a public browser API call.

## Logging

Not applicable. The component does not emit any log messages.

## Platform Notes

- **React/Web**: Implementation provided in `packages/web/packages/ui/src/components/color-mode-toggle.tsx`. Uses `useState` for client-only `mounted` gate, `useEffect` for mount detection, and `useSyncExternalStore` to subscribe to `prefers-color-scheme` media query without causing hydration mismatches. Icons imported from `lucide-react`. CSS classes `.adh-color-mode-toggle` and `.adh-color-mode-toggle__*` are applied; visual rendering delegated to `styles/components.css`. Component is a client-side rendered button (`"use client"` directive).

- **SwiftUI**: A SwiftUI equivalent would use `@State` for the mode preference and `@Environment(\.colorScheme)` or `AppKit`/`UIKit` equivalents to read system appearance. The component would render three Image views with conditional visibility based on mode. Accessibility would use `.accessibilityLabel()` and `.accessibilityValue()` modifiers.

- **Compose (Android/Kotlin)**: A Compose equivalent would use a MutableState for the mode, and `LocalConfiguration.current` or Android's system color-scheme detection to read system preference. Three Icon composables would be rendered with conditional visibility. Accessibility would use `Modifier.semantics {}` with role and contentDescription.

- **AppKit / UIKit**: An AppKit NSButton or UIButton subclass would render three NSImageView or UIImageView subviews, toggling visibility based on mode. UIAppearance or NSAppearance APIs would detect system preference. Accessibility would use `NSAccessibility` (AppKit) or `UIAccessibility` (UIKit) protocols to set accessible labels and values.

- **WinUI 3**: A WinUI 3 implementation would use a Button with three FontIcon children, binding visibility to the mode state via converters or code-behind. System dark mode would be detected via `UISettings` class listening to the `ColorValuesChanged` event. Accessibility would use `AutomationProperties.Name` and `AutomationProperties.HelpText` attached properties. The component would inherit from `Button` or be a custom control template that cycles mode on click.

## Design Decisions

1. **Controlled component, not a store**: The component is intentionally divorced from any specific state management or storage layer. It is a **control** that receives the current mode from a parent and emits change events. This allows it to be used in header chrome, sidebars, settings panels, or anywhere a mode toggle is needed, and to integrate with any parent state system (local storage, user account, Redux, Zustand, etc.). The comment in the source code explicitly warns against baking in a dependency on a specific theme context.

2. **Cycle direction is fixed**: The cycle order (auto → dark → light → auto) is a deliberate design choice. Users expect a single toggle button to cycle through a fixed sequence; the cycle is not configurable. This is encoded in the `NEXT_MODE` map rather than an array walked with modular arithmetic, making every mode's successor total and explicit.

3. **Server-side rendering safety via `mounted` gate**: The `aria-label` and `title` attributes are omitted on server-side rendering and only populated after the component mounts on the client. This prevents hydration mismatches when the server does not have access to the mode value or the user's system preference. The component uses `useSyncExternalStore` to ensure the system preference is read before the first render, preventing a render flash.

4. **System preference subscription via `useSyncExternalStore`**: The component uses React's `useSyncExternalStore` hook to subscribe to `prefers-color-scheme` changes. This is the correct pattern for integrating with external stores (browser APIs, event listeners) that are not controlled by React. It ensures the first render already has the correct system preference value, rather than rendering wrong and correcting in an effect.

5. **No visual styling in the component**: All visual rendering — which icon is visible, colors, sizing — is delegated to CSS. The component does not import or apply any styles directly. This allows the host application to fully style the button and its icons without re-implementing the component for each design system. The source comments note that the button's identity comes from the `className` prop (e.g., `"adh-header__icon-button"`), not from the component.

6. **Media query fallback for legacy browsers**: The component proactively checks for `addEventListener` support on the MediaQueryList object. Safari < 14 shipped with only the legacy `addListener` method. If the check fails, the component returns an empty unsubscribe function and continues rendering, gracefully degrading to the mode value alone without system preference tracking.

## Compliance

Not applicable. The component has no platform-specific compliance requirements (WCAG, GDPR, etc.) beyond standard web accessibility guidelines, which are covered in the Accessibility section.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.1.0 | 2026-09-22 | Claude Haiku 4.5 | Revise Accessibility Options: convert to table format; clarify Reduce Motion as not applicable (no transitions applied); add guidance on Increase Contrast and Differentiate Without Color |
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation from web source code |
