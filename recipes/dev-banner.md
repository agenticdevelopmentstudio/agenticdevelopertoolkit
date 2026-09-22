---
id: 1cdd9485-95e5-47dd-9346-224b43ce8ab9
title: DevBanner
domain: agenticdevelopercookbook://ingredients/dev-banner
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Displays a fixed or static development preview banner with customizable message.
platforms:
- web
tags:
- banner
- notification
- development
depends-on: []
related: []
references: []
---

# DevBanner

## Overview

DevBanner is a simple notification component that displays a development-stage message to users. It renders as a full-width banner positioned either as a fixed overlay or as part of the document flow. The component is hidden from assistive technology via `aria-hidden` and serves as a visual indicator only.

## Behavioral Requirements

- **must-render-message**: Component MUST render the message text provided via the `message` prop, or the default message `'Development Preview — Coming Soon!'` if not provided.
- **must-apply-position-class**: Component MUST apply a CSS class reflecting the `position` prop value (`'fixed'` or `'static'`) to the container element.
- **must-support-classname-prop**: Component MUST accept and apply a `className` prop, which is appended to the component's CSS classes.
- **must-hide-from-assistive-tech**: Component MUST set `aria-hidden="true"` on the root element.

## Appearance

- **Container**: Block-level element (div) with class prefix `awt-dev-banner`
- **Dynamic positioning class**: `awt-dev-banner--{position}` where `{position}` is either `'fixed'` or `'static'`
- **Custom classes**: Applied via the `className` prop and appended to the class list
- **Text content**: Renders the message string directly as text node within the container

## States

Not applicable: DevBanner is a non-interactive, static presentation component and does not have interactive states such as pressed, disabled, focused, or loading.

## Accessibility

The component is intentionally hidden from assistive technology via `aria-hidden="true"`. This means screen readers will not announce the banner text. Text is visible to sighted users only.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| dev-banner-001 | must-render-message | `message="Custom Alert"` | Rendered text equals `"Custom Alert"` |
| dev-banner-002 | must-render-message | No message prop provided | Rendered text equals `'Development Preview — Coming Soon!'` |
| dev-banner-003 | must-apply-position-class | `position="fixed"` | Container has class `awt-dev-banner--fixed` |
| dev-banner-004 | must-apply-position-class | `position="static"` | Container has class `awt-dev-banner--static` |
| dev-banner-005 | must-apply-position-class | No position prop provided | Container has class `awt-dev-banner--fixed` (default) |
| dev-banner-006 | must-support-classname-prop | `className="my-custom-class"` | Container class list includes `my-custom-class` |
| dev-banner-007 | must-support-classname-prop | `className=""` (empty string) | Empty string is filtered out; not added to class list |
| dev-banner-008 | must-hide-from-assistive-tech | Any props | Root element has attribute `aria-hidden="true"` |

## Edge Cases

- **Empty message**: If `message=""` is passed, the component renders an empty container with no text content.
- **Null or undefined message**: Treated as missing and default message is used per source behavior.
- **Null className**: Filtered out of class string via `.filter(Boolean)` and does not appear in rendered class list.
- **Whitespace in message**: Leading and trailing whitespace in the message string is preserved and rendered as-is.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `message` | `string \| undefined` | `'Development Preview — Coming Soon!'` | Text content displayed in the banner |
| `position` | `'fixed' \| 'static' \| undefined` | `'fixed'` | Controls CSS positioning behavior via class name |
| `className` | `string \| undefined` | `undefined` | Additional CSS classes applied to the root element |

## Deep Linking

Not applicable: DevBanner is a standalone notification banner and is not designed as a navigation target or deep-linkable resource.

## Localization

Not applicable: The component accepts localized text via the `message` prop but defines no built-in string keys. Localization is the responsibility of the consuming application.

## Accessibility Options

Not applicable: DevBanner is intentionally hidden from assistive technology via `aria-hidden="true"` and does not respond to accessibility display options.

## Feature Flags

Not applicable: No feature flags are defined in the source code.

## Analytics

Not applicable: The component does not emit analytics events.

## Privacy

Not applicable: The component does not collect, store, or transmit any user data.

## Logging

Not applicable: The component does not emit log events.

## Platform Notes

- **React/Web**: Files `packages/web/packages/controls/src/dev-banner/DevBanner.tsx`. Renders a `<div>` with dynamically constructed class names and `aria-hidden="true"`. Accepts a text message prop and two positional/styling props (`position`, `className`). Uses client-side directive (`'use client'`) for Next.js App Router.
- **SwiftUI**: Create a custom `DeveloperBannerModifier` using `@ViewBuilder` that overlays or embeds a `Text` view. Use `ZStack` for fixed positioning (via `.ignoresSafeArea()` + absolute frame) or standard layout for static. Wrap in `.accessibilityHidden(true)` to match web behavior.
- **Compose**: Implement as a composable `DevBanner` that measures viewport or parent constraints. Use `Box` with `Modifier.fillMaxWidth()` and `position: Absolute` (or `Relative`) to match `fixed`/`static`. Apply `.semantics { contentDescription = null }` to achieve `aria-hidden` parity.
- **AppKit / UIKit**: For AppKit, use `NSView` subclass with layer-backed rendering and `CGRect` positioning (absolute or relative). For UIKit, use `UIView` with `frame`/`constraints` and set `isAccessibilityElement = false` to exclude from VoiceOver. On iOS, ensure it does not obscure safe area unless `position: 'fixed'`.
- **WinUI 3**: Implement as a `UserControl` or custom `Panel`. For fixed positioning, use `Canvas` with `Canvas.Left` and `Canvas.Top` attached properties; for static, use `StackPanel` or `Grid`. Set `AutomationProperties.IsOffscreen = true` (UIA equivalent of `aria-hidden`) on the root element or container. Text content binds to a dependency property mirroring the `message` parameter.

## Design Decisions

The component is hidden from assistive technology by design, indicating it serves a visual-only notice function rather than critical information that users relying on screen readers must access. If the development status is semantically important to all users, this design choice should be revisited and the `aria-hidden` attribute removed, with an appropriate role (e.g., `role="status"`) added instead.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| No security-sensitive data | passed | Security |
| `aria-hidden` intentional | passed | Accessibility |
| No external dependencies | passed | Dependencies |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation from web source |
