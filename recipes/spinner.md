---
id: c97bebaf-9e6d-49a7-a4bb-90e8e0ea0181
title: Spinner
domain: agenticdevelopercookbook://ingredients/spinner
type: ingredient
version: 1.0.0
status: review
language: en
created: 2026-09-22
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Indeterminate loading indicator that animates continuously to show async
  operations in progress.
platforms:
- web
tags:
- loading
- progress
- ui
depends-on: []
related: []
references: []
---

# Spinner

## Overview

The Spinner is an indeterminate loading indicator rendered as an animated icon. It communicates to users that an async operation is in progress without showing a specific completion percentage. The component wraps the Lucide `Loader2` icon and applies a continuous spin animation. Size and color are customizable via className; the component defaults to a 1rem (16px) icon with muted text color.

## Behavioral Requirements

- **must-render-icon**: Component MUST render the Lucide `Loader2` icon.
- **must-apply-spin-animation**: Component MUST apply a continuous spinning animation to the icon.
- **must-accept-classname**: Component MUST accept and apply a custom `className` prop that overrides or extends the default styling.
- **must-accept-props**: Component MUST accept and forward all valid React props accepted by the underlying Lucide `Loader2` component.
- **must-set-aria-label**: Component MUST set `aria-label="Loading"` to communicate the spinner's purpose to assistive technology.
- **must-set-role**: Component MUST set `role="status"` to indicate this is a live status region that announces loading state.
- **must-default-size**: Component MUST default to 1rem (16px) size when no `className` is provided.
- **must-default-color**: Component MUST default to muted text color (`text-apt-text-muted`) when no `className` is provided.

## Appearance

- **Size**: Default 1rem (16px); customizable via `size-*` Tailwind classes in `className`
- **Color**: Default muted text color (`text-apt-text-muted`); customizable via `text-*` Tailwind classes in `className`
- **Animation**: Continuous 360° rotation; no pause or reverse
- **Corner radius**: None (circular icon, no radius applied)
- **Padding**: None
- **Border**: None
- **Shadow**: None

## States

Not applicable: Spinner is a stateless loading indicator with no interactive states (pressed, disabled, focused). It is purely an animated visual indicator.

## Accessibility

- **Role**: `status` — identifies this as a live region for status updates
- **Label**: `aria-label="Loading"` — communicates the purpose to screen readers
- **Announce state**: No change announcements needed; aria-label is static throughout the component lifecycle
- **Keyboard interaction**: Not applicable; component is not interactive
- **Minimum tap target**: Not applicable; component is not interactive and should not be tappable (44×44pt minimum does not apply)

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| spinner-001 | must-render-icon | `<Spinner />` | Lucide `Loader2` icon visible on screen |
| spinner-002 | must-apply-spin-animation | `<Spinner />` | Icon continuously rotates 360° smoothly without pause |
| spinner-003 | must-accept-classname | `<Spinner className="size-8 text-red-500" />` | Icon renders 2rem (32px) in red color, overriding defaults |
| spinner-004 | must-accept-props | `<Spinner data-testid="loading-indicator" />` | `data-testid` attribute is present on rendered element and accessible via DOM queries |
| spinner-005 | must-set-aria-label | `<Spinner />` rendered in a page | Screen reader announces "Loading" when focus enters the spinner's region or the region is announced as live |
| spinner-006 | must-set-role | `<Spinner />` rendered in the DOM | Element has `role="status"` in its DOM attributes |
| spinner-007 | must-default-size | `<Spinner />` with no className | Icon renders at exactly 1rem (16px) width and height |
| spinner-008 | must-default-color | `<Spinner />` with no className | Icon color matches the design system's muted text token (`text-apt-text-muted`) |

## Edge Cases

- **Empty or undefined className**: When `className` is undefined, falsy, or empty string, defaults apply (1rem size, muted color). Behavior: MUST use defaults without error.
- **Multiple spin animations**: If a parent element or global CSS also defines a spin animation, the component's animation MUST take precedence via specificity. Behavior: MUST show the component's spin animation, not a competing animation.
- **Very large classname overrides**: When `className` includes extreme size values (e.g., `size-96`), the component MUST render at that size without clipping or overflow issues (layout depends on parent container). Behavior: MUST render without error; parent container is responsible for containing the size.
- **No animation support**: If a parent applies `prefers-reduced-motion: reduce`, the Tailwind `animate-spin` class SHOULD be removed or the animation SHOULD be disabled by external CSS media query override. Behavior: The component itself does not query `prefers-reduced-motion`; the animation is controlled via the Tailwind utility class (see Platform Notes for expected behavior).

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `className` | `string` | `undefined` | Additional or overriding Tailwind classes (e.g., `"size-8 text-green-500"`). Merged with default classes via `cn()` utility. |
| `...props` | `React.ComponentProps<Loader2>` | `undefined` | Any valid prop accepted by Lucide's `Loader2` component (e.g., `strokeWidth`, `data-*` attributes, event handlers). |

## Deep Linking

Not applicable: Spinner is a stateless UI component and does not represent a navigable screen or deep link target.

## Localization

Not applicable: Spinner does not expose user-facing strings to localize. The `aria-label="Loading"` is a fixed English label intended for assistive technology, not end-user display text.

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | The `animate-spin` Tailwind class respects CSS `prefers-reduced-motion: reduce` and will not animate when the user's OS or browser accessibility setting enables motion reduction. The spinner remains visible but still; it is not hidden. This behavior is provided by the Tailwind CSS framework, not by explicit code in the component. |
| Increase Contrast | Not directly implemented in component. Foreground and background contrast depends on the parent container's background and the `text-apt-text-muted` color token; teams using the component SHOULD ensure the muted text color meets WCAG AA 4.5:1 contrast ratio against the background. Custom `className` overrides (e.g., `text-black` or `text-white`) can be used to achieve higher contrast if needed. |
| Differentiate Without Color | Not applicable. The component conveys loading state via motion (spin animation) and the aria-label, not by color alone. |

## Feature Flags

Not applicable: Component has no feature flags in the source code. Enablement is controlled by conditional rendering at the call site.

## Analytics

Not applicable: Component does not instrument analytics events. Callers are responsible for tracking loading state events if needed.

## Privacy

Not applicable: Component does not collect, store, or transmit any data.

## Logging

Not applicable: Component does not perform any logging. Callers may add logging around the component's lifecycle if needed for debugging.

## Platform Notes

- **React/Web**: Rendered via Lucide's `Loader2` icon component (the primary platform). Accepts all React and Lucide props. Animation is provided by Tailwind CSS's `animate-spin` utility. The `cn()` utility (likely from `clsx` or similar) merges default and custom classnames with proper precedence. No framework-specific state or hooks are used internally; the component is a pure presentational wrapper.

- **SwiftUI**: Start from SwiftUI's native `ProgressView(label: "Loading") { }` with `.progressViewStyle(.circular)`. To match the React behavior, disable the indefinite-duration animation, apply the same muted text color token, and size it to 16pt by default. The component would need to accept a `@ViewBuilder` modifier chain to support the web component's `...props` flexibility. No equivalent to React's `className` prop exists in SwiftUI; instead, use environment modifiers (`.foregroundColor()`, `.font()`, `.scaleEffect()`).

- **Compose** (Kotlin/Android): Start from `CircularProgressIndicator()` with default size and color. Set `modifier = Modifier.size(16.dp)` and `.tint(Color.Unspecified.copy(alpha = 0.6f))` (or the muted text color token). Compose's animation timing is built-in to `CircularProgressIndicator` and respects `LocalAnimationTimeMillis`. To support custom properties like the web component, accept a `Modifier` parameter and compose it with the defaults (similar to the web component's `className` merging).

- **AppKit / UIKit** (macOS/iOS): Use `NSProgressIndicator(frame: NSRect(x: 0, y: 0, width: 16, height: 16))` (macOS) or `UIActivityIndicatorView(style: .medium)` (iOS). Set `startAnimating()` to begin the spin. Size defaults to 16pt; color defaults to the muted text color token. No direct equivalent to React's `className` or `...props` forwarding; instead, create a wrapper that exposes individual properties (`size`, `color`, `isAnimating`) and applies them via settable view properties.

- **WinUI 3** (Windows): Use `ProgressRing` with `IsIndeterminate="True"`. Size it to 16×16 DIP (device-independent pixels, roughly equivalent to 16px on 96 DPI). Set `Foreground` to the muted text color token. `ProgressRing` does not expose a spin animation property directly; animation is automatic when `IsIndeterminate` is true. To support custom styling, expose a `Style` property that consumers can override via XAML or code-behind; this provides the equivalent of the React component's `className` flexibility.

## Design Decisions

- **Indeterminate vs. determinate**: The component renders an indeterminate spinner (no progress percentage) because the source code and comment explicitly state "Indeterminate loading spinner." A determinate progress bar serves a different use case (showing completion percentage) and is not in scope.

- **No wrapper div**: The component renders the Lucide icon directly without wrapping it in a `<div>` or other container. This keeps the DOM minimal and allows the caller to control layout and spacing via parent container styling.

- **className merging via cn()**: The default classes are passed to `cn()` along with the custom `className`. The `cn()` utility ensures Tailwind class precedence is correct (custom classes override defaults). This design allows callers to customize size and color without needing to know the default class names.

- **Forwarding all Loader2 props**: The component uses `{...props}` to forward any additional React props to the underlying `Loader2` component. This allows callers to add event handlers (if `Loader2` supports them), data attributes, or other HTML attributes without the Spinner component needing to explicitly whitelist each one. This provides extensibility similar to the `className` customization.

- **Fixed aria-label**: The `aria-label` is hardcoded to "Loading" because the source code does not expose it as a prop. Callers who need a different label (e.g., for translations) would need to use a different approach (e.g., render the Loader2 icon directly with a custom label) or would need this component to be enhanced to accept an `ariaLabel` prop.

## Compliance

Not applicable: Component does not involve security-sensitive data handling, user authentication, or regulated workflows. Standard web accessibility (WCAG 2.1) is addressed in the Accessibility section.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | | Initial creation from React source |
