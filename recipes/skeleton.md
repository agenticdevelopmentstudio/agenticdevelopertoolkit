---
id: 4a3761c5-5809-43c9-9a45-6f91fe82ae97
title: Skeleton
domain: agenticdevelopercookbook://ingredients/skeleton
type: ingredient
version: 1.0.1
status: review
language: en
created: 2026-09-22
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A loading placeholder component that displays a pulsing block to indicate
  content is loading.
platforms:
- typescript
- web
tags:
- loading
- placeholder
- animation
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Skeleton

## Overview

The Skeleton component is a loading placeholder that displays a pulsing block. It signals to users that content is being loaded. The component is a simple wrapper around a `<div>` that applies animation and styling via CSS classes. Size the skeleton by passing a `className` prop or using inline styles.

## Behavioral Requirements

- **must-render-as-div**: Component MUST render as a HTML `<div>` element.
- **must-apply-slot-attribute**: Component MUST render with `data-slot="skeleton"` attribute.
- **must-apply-pulsing-animation**: Component MUST apply the `animate-pulse` class to create a pulsing visual effect.
- **must-apply-rounded-corners**: Component MUST apply the `rounded-md` class for rounded corner radius.
- **must-apply-surface-background**: Component MUST apply the `bg-apt-surface-2` class for background color.
- **must-accept-className**: Component MUST accept and merge a `className` prop with built-in classes via a class composition utility (e.g., `cn()` in the source).
- **must-spread-html-props**: Component MUST accept and forward standard HTML `div` attributes (`id`, `style`, `aria-*`, etc.) to the rendered element.
- **may-be-sized-by-props**: Component MAY accept sizing through `className` prop or inline `style` prop, allowing consumers to define width and height.

## Appearance

- **Background**: `bg-apt-surface-2` (secondary surface color token)
- **Corner radius**: Medium rounded corners (`rounded-md`)
- **Animation**: Pulsing opacity animation (`animate-pulse`)
- **Padding**: None (appears to be a block-level element)
- **Border**: None
- **Shadow**: None
- **Min/Max size**: None (sized by consumer via `className` or inline styles)

## States

| State | Appearance change |
|-------|-------------------|
| Default | Pulsing opacity animation applied continuously |
| Loading (implied) | Same as default |

Not applicable: The Skeleton component is a static, non-interactive loading indicator with no focus, pressed, or disabled states.

## Accessibility

- **Role**: Implied as a non-semantic presentational element (a `<div>` used for layout/styling).
- **Label requirements**: Not applicable. This is a visual loading indicator with no interactive or informational semantics. The consuming application SHOULD provide context through sibling elements or page title updates to indicate content is loading.
- **Announce state changes**: Not applicable. The component does not have interactive or state-change semantics to announce.
- **Keyboard interaction**: Not applicable. This is a non-interactive element.

NEEDS REVIEW: Skeleton renders a plain `div` with no `aria-hidden`, `aria-busy`, or role attribute. A loading placeholder needs screen-reader announcement or suppression so assistive technology can communicate loading status or suppress stale content placeholders.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|-------|--------|-------|----------|
| skeleton-001 | must-render-as-div, must-apply-slot-attribute | Render `<Skeleton />` | Element in DOM with tag name `DIV` and `data-slot="skeleton"` attribute |
| skeleton-002 | must-apply-pulsing-animation, must-apply-rounded-corners, must-apply-surface-background | Render `<Skeleton />` and inspect computed styles | Computed class list includes `animate-pulse`, `rounded-md`, `bg-apt-surface-2` |
| skeleton-003 | must-accept-className, must-apply-pulsing-animation, must-apply-rounded-corners | Render `<Skeleton className="w-12 h-12" />` | Element contains both custom classes (`w-12`, `h-12`) and built-in classes (`animate-pulse`, `rounded-md`, `bg-apt-surface-2`) |
| skeleton-004 | must-spread-html-props | Render `<Skeleton id="loader" data-testid="skeleton-1" />` | Element has attributes `id="loader"` and `data-testid="skeleton-1"` |
| skeleton-005 | must-spread-html-props | Render `<Skeleton style={{ width: '100px', height: '100px' }} />` | Element has `style` attribute with specified width and height |
| skeleton-006 | must-apply-pulsing-animation | Render `<Skeleton />` and observe for 2+ seconds | Opacity animation cycles continuously |

## Edge Cases

- **Empty className prop**: When `className` is `undefined`, `null`, or an empty string, the component SHOULD apply only built-in classes (`animate-pulse rounded-md bg-apt-surface-2`).
- **Invalid CSS class names in className**: The component MUST accept any string in the `className` prop without validation or error handling. Invalid class names are silently passed through; rendering behavior depends on whether the CSS classes exist.
- **Very large dimensions**: No minimum or maximum size constraints exist. The component renders at any size specified via `className` or `style`.
- **Rendering in disabled or read-only contexts**: Not applicable. The component is not interactive.
- **Animation performance**: The `animate-pulse` animation runs continuously. On devices with low performance or reduced-motion preferences, rendering behavior is undefined by the component itself; it depends on CSS media query support (e.g., `prefers-reduced-motion`).

## Configuration

Not applicable: The Skeleton component accepts no configuration options beyond `className` and standard HTML attributes.

## Deep Linking

Not applicable: The Skeleton component is a presentational UI element with no navigation or deep-linking semantics.

## Localization

Not applicable: The Skeleton component renders no text and does not require localization.

## Accessibility Options

The source does not read `prefers-reduced-motion`. Tailwind's `animate-pulse` does not disable itself under the user's reduce-motion preference, so the pulsing animation plays continuously regardless of this accessibility setting.

## Feature Flags

Not applicable: The Skeleton component uses no feature flags or conditional rendering.

## Analytics

Not applicable: The Skeleton component triggers no analytics events.

## Privacy

Not applicable: The Skeleton component collects, stores, or transmits no user data.

## Logging

Not applicable: The Skeleton component produces no logging output.

## Platform Notes

- **React/Web**: Implemented in `packages/web/packages/ui/src/components/skeleton.tsx`. Renders a `<div>` with Tailwind CSS classes (`animate-pulse`, `rounded-md`, `bg-apt-surface-2`). Accepts `className` prop and spreads remaining HTML attributes. Uses class composition utility `cn()` (likely `clsx` or similar) to merge custom and built-in classes.
- **SwiftUI**: No implementation provided. Start with a `RoundedRectangle` or `ZStack` for the shape, apply a `.redacted(reason: .placeholder)` modifier or custom opacity animation to create the pulsing effect. Consider using SwiftUI's native `.shimmering()` or `.redacted()` for accessibility support.
- **Compose**: No implementation provided. Start with a `Box` composable, apply `Modifier.animateContentSize()` and a custom `infiniteTransition` to pulse opacity. Reference Material Design 3 skeleton guidance for color and animation timing.
- **AppKit / UIKit**: No implementation provided. Start with `NSView` (AppKit) or `UIView` (UIKit). Apply a `CABasicAnimation` on the opacity property with infinite repeat and appropriate timing. Use system colors or design tokens for the background.
- **WinUI 3**: No implementation provided. Create a `Border` or `Rectangle` with `CornerRadius` property. Apply a `DoubleAnimation` on the `Opacity` property with `RepeatBehavior.Forever` to achieve the pulsing effect. Reference Fluent 2 token colors for the surface background.

## Design Decisions

1. **Pulsing opacity over other animation approaches**: The component uses CSS `animate-pulse` for continuous opacity animation rather than background color shifts or position changes. This is a simple, performant animation that does not distort layout.

2. **No built-in sizing**: The component intentionally provides no width or height constraints. Consumers must size the skeleton via `className` or inline styles, allowing flexible layouts (e.g., a small avatar skeleton vs. a large content block).

3. **No ARIA role assigned**: The component does not set an ARIA role. It delegates accessibility semantics to the consuming application, which SHOULD provide context (e.g., "Loading..." text or `aria-busy="true"` on a parent).

## Compliance

Not applicable: No compliance checks are specified in the source code.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.1 | 2026-09-22 | Claude Haiku 4.5 | Fix Reduce Motion marker; clarify screen-reader gap |
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation from source code |
