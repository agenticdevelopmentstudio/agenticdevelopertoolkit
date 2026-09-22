---
id: 07c437af-a291-4356-bd83-c896bd4facde
title: Screen
domain: agenticdevelopertoolkit://recipes/screen
type: ingredient
version: 1.0.0
status: review
language: en
created: 2026-09-22
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Full-viewport-height container for deck slides with optional background glow
  and content alignment.
platforms:
- typescript
- web
tags:
- deck
- layout
- viewport
depends-on: []
related: []
references:
- https://developer.mozilla.org/en-US/docs/Web/HTML/Element/section
- https://developer.mozilla.org/en-US/docs/Web/CSS/vh
approved-by: ''
approved-date: ''
---

# Screen

## Overview

Screen is a full-viewport-height container component for use in a scrollable or snap-scrolled deck of slides. Each screen serves as a snap point and can hold arbitrary content. The component supports optional background glow and flexible vertical alignment of content within the viewport height.

## Behavioral Requirements

- **must-render-children**: Component MUST render its children.
- **must-render-semantic-element**: Component MUST render as either `<section>` (landmark) or `<div>` (non-landmark) based on the `as` prop.
- **must-apply-base-class**: Component MUST apply the `lp-screen` class to the root element.
- **must-center-alignment**: Component MUST apply the `lp-screen--center` class when `align` is set to `'center'`.
- **must-merge-classname**: Component MUST merge the optional `className` prop with base classes without duplicating or removing the base class.
- **may-render-glow**: Component MAY render a `<Glow />` component as the first child when `glow` is `true`.
- **may-accept-id**: Component MAY accept and apply an optional `id` attribute to the root element.

## Appearance

Component applies layout and styling through CSS classes (`lp-screen`, `lp-screen--center`). Visual appearance is defined in the CSS layer and depends on host stylesheet. Component itself does not prescribe:

- Corner radius
- Padding
- Typography
- Colors
- Borders
- Shadows
- Size constraints

These are all delegated to the host's CSS implementation.

## States

Not applicable: Screen is a static container with no interactive states.

## Accessibility

- **Semantic role**: When rendered as `<section>`, conveys landmark semantics; when rendered as `<div>`, has no implicit role. Role depends on `as` prop and host stylesheet.
- **Label requirement**: If rendered as a landmark (`<section>`), host SHOULD provide an accessible label via `aria-label` or `aria-labelledby` prop passed to Screen.
- **Content accessibility**: Screen does not define accessibility for its children; child components are responsible for their own accessible implementation.

## Conformance Test Vectors

| ID | Requirement | Input | Expected |
|----|-------------|-------|----------|
| screen-001 | must-render-children | `children: <p>Content</p>` | Element tree includes the `<p>` element |
| screen-002 | must-render-semantic-element | `as: 'section'` | Root element is `<section>` |
| screen-003 | must-render-semantic-element | `as: 'div'` or omitted | Root element is `<div>` |
| screen-004 | must-apply-base-class | Any props | Root element has `lp-screen` in its class list |
| screen-005 | must-center-alignment | `align: 'center'` | Root element has both `lp-screen` and `lp-screen--center` in class list |
| screen-006 | must-center-alignment | `align: 'top'` or omitted | Root element has `lp-screen` class but not `lp-screen--center` |
| screen-007 | must-merge-classname | `className: 'custom-class'` | Root element has `lp-screen` and `custom-class` in class list |
| screen-008 | may-render-glow | `glow: true` | First child of root element is the Glow component |
| screen-009 | may-render-glow | `glow: false` or omitted | No Glow component is rendered |
| screen-010 | may-accept-id | `id: 'slide-1'` | Root element has `id="slide-1"` |

## Edge Cases

- **Null or undefined children**: Component MUST NOT render if `children` is null or undefined. This is consistent with React semantics; the component renders children as-is.
- **Empty children array**: Component MUST render an empty container when `children` is an empty array.
- **Invalid align value**: If `align` is set to a value other than `'top'` or `'center'`, the component defaults to `'top'` behavior (no `lp-screen--center` class applied).
- **Invalid as value**: If `as` is set to a value other than `'section'` or `'div'`, the component defaults to `'section'`.
- **Glow with no children**: Component MUST render Glow component even if children are empty or null, provided `glow: true`.
- **Multiple class collisions**: If `className` prop contains `lp-screen` or `lp-screen--center`, the component's merge logic concatenates all classes; host stylesheet SHOULD use CSS cascade to manage conflicts.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `align` | `'top' \| 'center'` | `'top'` | Vertical alignment of content within the viewport. |
| `as` | `'section' \| 'div'` | `'section'` | Semantic element type for the root. |
| `className` | `string` | — | Additional CSS class to merge with base classes. |
| `glow` | `boolean` | `false` | Whether to render a Glow component behind the content. |
| `id` | `string` | — | Optional HTML id attribute for the root element. |
| `children` | `ReactNode` | — | Required content to render inside the screen. |

## Deep Linking

Not applicable: Screen is a container component with no built-in route or deep linking support. Deep linking behavior is the responsibility of the host application and the content within each screen.

## Localization

Not applicable: Screen is a structural container with no user-facing text or strings.

## Accessibility Options

Not applicable: Screen does not animate and does not respond to motion preferences.

## Feature Flags

Not applicable: Screen does not implement feature flags.

## Analytics

Not applicable: Screen does not emit or track events.

## Privacy

Not applicable: Screen does not collect, store, or transmit user data.

## Logging

Not applicable: Screen does not implement logging.

## Platform Notes

- **React/Web** (source): Screen is a functional component that conditionally renders a semantic element (`<section>` or `<div>`) based on the `as` prop. It applies BEM-style classes (`lp-screen`, `lp-screen--center`) for styling and optionally renders the Glow component as the first child. Layout and visual appearance are entirely CSS-driven, defined in a separate stylesheet (`css/base.css` per the source comment).

- **SwiftUI**: Use a `ZStack` or `VStack` with `.ignoresSafeArea()` and a frame matching the viewport height. Conditionally prepend a background glow view (using `.background()` modifier or a custom shape) when the glow property is true. Apply conditional padding or alignment modifiers to implement the center vs. top alignment behavior.

- **Compose**: Use a `Box` composable with `Modifier.fillMaxHeight()` and optional `Modifier.fillMaxWidth()`. Conditionally render a canvas-based glow in the background using `drawBehind { }`. Use `contentAlignment` parameter to position children at the top or center of the box.

- **AppKit / UIKit**: Subclass `NSView` (AppKit) or `UIView` (UIKit) with `translatesAutoresizingMaskIntoConstraints: false`. Set constraints to fill the view controller's view. Optionally add a background glow CALayer or custom drawing. Use auto layout constraints or `UIStackView` to position child views according to the alignment property.

- **WinUI 3**: Use a `Grid` control with `Height="*"` (star sizing) to fill available vertical space. Optionally render a canvas or rectangle with a glow effect (`BlurEffect` or custom XAML storyboard animation) behind the content. Use `VerticalAlignment` property to position child elements at the top (`Top`) or center (`Center`).

## Design Decisions

- **CSS-driven styling**: Visual appearance is deliberately delegated to a separate stylesheet. This keeps the component logic minimal and allows host applications to customize styling without modifying the component code.
- **Glow as optional prop**: The glow prop exists so component ordering is automatic; the host does not need to worry about placing a Glow component before or after Screen. Default is `false` because a deck where every screen glows is a host-level design decision, not a component default.
- **Semantic element choice**: The `as` prop allows Screen to act either as a landmark (`<section>`) or as a generic container (`<div>`), giving the host control over information architecture without requiring wrapper elements.

## Compliance

Not applicable: No specific compliance checks are defined in the source.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | — | Initial creation |
