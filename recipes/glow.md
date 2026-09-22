---
id: b341dd02-fbcb-4da8-b2b6-897807b4ebbc
title: Glow
domain: agenticdevelopercookbook://ingredients/glow
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Decorative visual element that renders a glow effect; purely visual with
  no interaction or semantic meaning.
platforms:
- web
tags:
- visual
- decorative
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Glow

## Overview

The Glow component is a purely decorative visual element that renders a styled `<div>` with a glow effect. It is excluded from accessibility trees (`aria-hidden="true"`) and serves only as visual enhancement. Visual appearance is entirely managed through CSS classes (base class `lp-glow` plus optional additional classes), with positioning derived from the hero element's padding variables.

## Behavioral Requirements

- **must-render-div**: Component MUST render a `<div>` element.
- **must-set-aria-hidden**: Component MUST set `aria-hidden="true"` on the rendered element.
- **must-accept-classname-prop**: Component MUST accept an optional `className` prop (string or undefined).
- **must-apply-lp-glow-class**: Component MUST always apply the 'lp-glow' class to the rendered element.
- **must-combine-classnames**: Component MUST combine 'lp-glow' with the provided `className` if truthy, joining with a space and filtering falsy values.

## Appearance

- **Corner radius**: Defined by CSS class `lp-glow` (not specified in component)
- **Padding**: None (element has no padding)
- **Font**: Not applicable (element contains no text)
- **Background**: Defined by CSS class `lp-glow`
- **Foreground/Text**: Not applicable (element contains no text)
- **Border**: Defined by CSS class `lp-glow` (if applied)
- **Shadow**: Defined by CSS class `lp-glow` (if applied)
- **Min/Max size**: Defined by CSS class `lp-glow`; offset derived from hero element's padding variables

## States

Not applicable: This component is purely decorative and stateless; it does not enter any interactive states.

## Accessibility

Not applicable: The component is explicitly hidden from accessibility trees via `aria-hidden="true"` and carries no semantic role or purpose for assistive technologies.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| glow-001 | must-render-div | None | Component renders as HTML `<div>` element |
| glow-002 | must-set-aria-hidden | None | Rendered element includes `aria-hidden="true"` |
| glow-003 | must-apply-lp-glow-class | None | Rendered element has class 'lp-glow' |
| glow-004 | must-combine-classnames | `className="custom-glow"` | Rendered element has classes 'lp-glow' and 'custom-glow' |
| glow-005 | must-combine-classnames | `className=""` | Rendered element has class 'lp-glow' only (empty string filtered) |
| glow-006 | must-accept-classname-prop | `className={undefined}` | Rendered element has class 'lp-glow' only (undefined filtered) |
| glow-007 | must-combine-classnames | No className prop | Rendered element has class 'lp-glow' only |

## Edge Cases

- **Undefined or null className**: Falsy values are filtered from the combined class list; element renders with 'lp-glow' only.
- **Empty string className**: Empty string is falsy and filtered; element renders with 'lp-glow' only.
- **Whitespace-only className**: Whitespace is preserved in the string; if passed as className, it will be included in the rendered class attribute (behavior depends on HTML parser treatment of whitespace in class attribute).
- **Multiple spaces in className**: Multiple spaces are preserved; the combined result joins with a single space between base class and provided className.

## Configuration

Not applicable: The component accepts only an optional `className` prop; it has no configurable options or variants.

## Deep Linking

Not applicable: The component is a decorative visual element with no navigational or deep-linking capability.

## Localization

Not applicable: The component contains no text or user-facing strings.

## Accessibility Options

Not applicable: The component is explicitly hidden from accessibility trees and does not respond to accessibility display options.

## Feature Flags

Not applicable: No feature flags control the rendering or visibility of this component.

## Analytics

Not applicable: The component does not emit or track analytics events.

## Privacy

Not applicable: The component does not collect, store, or transmit data.

## Logging

Not applicable: The component does not emit diagnostic logs.

## Platform Notes

- **React/Web**: Implemented in `packages/web/packages/landing/src/deck/Glow.tsx` as a functional component. Exports a `Glow` function accepting `{ className?: string }`. Combines 'lp-glow' base class with the optional className prop using `[...].filter(Boolean).join(' ')`. The rendered `<div>` is always `aria-hidden`. Visual styling is delegated entirely to CSS classes in the application's stylesheet, with positioning offset derived from hero element padding variables.

- **SwiftUI**: Implement using a transparent `View` with a `RadialGradient` or layered `Canvas` to create the glow effect. Apply `.accessibility(hidden: true)` to exclude from VoiceOver. Use environment or view properties to apply styling derived from design tokens that match the web CSS definitions.

- **Compose**: Use a `Box` or `Canvas` composable with `Brush.radialGradient` or a `blur` modifier to produce the glow. Apply `Modifier.semantics { invisibleToUser() }` to hide from accessibility. Layer multiple elements with alpha blending if needed to achieve the visual effect.

- **AppKit / UIKit**: On macOS, create an `NSView` subclass with `CAGradientLayer` (radial) or custom drawing for the glow, set `alphaValue` as needed, and mark as non-interactive. On iOS, use `UIView` with `CAGradientLayer` or similar, set `isUserInteractionEnabled = false`, and mark as non-interactive. Exclude both from accessibility with appropriate `isAccessibilityElement` / view controller settings.

- **WinUI 3**: Render a `Border` or `Grid` with a `RadialGradientBrush` to create the glow effect. Set `IsHitTestVisible="False"` to prevent interaction. Apply `AutomationProperties.IsOffscreenBehavior="Offscreen"` to hide from accessibility tools. Use `Opacity` and `Effect` properties (e.g., `BlurEffect`) to refine the visual appearance.

## Design Decisions

The component is intentionally minimal and purely decorative; no configuration, interactivity, or semantic meaning is provided. Positioning offset is derived from the hero element's padding variables (referenced in the source comment) rather than a hardcoded constant, ensuring visual alignment and maintainability. The `aria-hidden` attribute is fixed and non-configurable because the component has no semantic purpose. CSS class-based styling (base class + optional additions) decouples visual design from component logic, allowing design changes without code modification.

## Compliance

Not applicable: This decorative element has no compliance requirements (no user data, no interactive controls, no accessibility exposure).

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | | Initial creation |
