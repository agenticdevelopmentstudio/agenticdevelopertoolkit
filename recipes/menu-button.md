---
id: e82102a9-a60c-4498-aba3-7cd5a33ade3c
title: Menu Button
domain: agenticdevelopercookbook://ingredients/menu-button
type: ingredient
version: 1.1.0
status: review
language: en
created: 2026-09-22
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A button that toggles between a hamburger menu icon and a close icon, with
  accessible label.
platforms:
- web
tags:
- ui
- button
- navigation
depends-on: []
related: []
references: []
---

# Menu Button

## Overview

A button that displays and toggles between a hamburger menu icon (three stacked bars) and a close icon (two bars crossed). The icon state is controlled by a prop; the bars are rendered as plain DOM elements rather than SVG, allowing them to animate and inherit the button's text color. The component requires an accessible name and extends standard HTML button attributes.

## Behavioral Requirements

- **must-render-button-element**: Component MUST render as an HTML `<button>` element with `type="button"`.
- **must-accept-label-prop**: Component MUST accept a required `label` prop that is used as the button's accessible name via `aria-label`.
- **must-display-menu-icon-by-default**: Component MUST display three bars (hamburger icon) when no `icon` prop is provided or when `icon="menu"`.
- **must-display-close-icon-variant**: Component MUST display two bars crossed (close icon) when `icon="close"`.
- **must-support-html-button-attributes**: Component MUST pass through all standard `HTMLButtonElement` attributes (e.g., `disabled`, `onClick`, `className`, `data-*` attributes).
- **must-apply-menu-button-class**: Component MUST apply the CSS class `menu-button` to the button element.
- **must-apply-close-variant-class**: Component MUST apply the CSS class `menu-button--close` to the button element when `icon="close"`.
- **must-allow-custom-classname**: Component MUST allow custom CSS classes to be added via a `className` prop and combine them with the component's internal classes.
- **must-render-bars-as-plain-elements**: Component MUST render bars as plain `<span>` elements with class `mb-bar` rather than as an SVG, to enable animation and color inheritance.
- **must-support-icon-toggle**: Component MUST support toggling the icon state by changing the `icon` prop between `'menu'` and `'close'`.

## Appearance

- **Bar rendering**: Bars are plain HTML elements (`<span>`) with class `mb-bar`, not SVG.
- **Bar quantity**: Three bars in menu state, two bars in close state.
- **Bar dimensions**: Each bar MUST be 16px wide (`--menu-bar-width`) and 3px thick (`--menu-bar-thickness`), with fully rounded ends (`border-radius: 999px`). Bars MUST be spaced with a 3px gap (`--menu-bar-gap`), giving a 6px pitch (thickness + gap); thickness, gap, and pitch MUST all be whole-number CSS pixels so every bar rounds to the same device-pixel thickness regardless of device-pixel ratio or the button's fractional position. The icon occupies a 32×32px box (`--menu-size`).
- **Bar colour**: Bars MUST use `background: currentColor`, taking the button's `color` so a consumer themes the icon by setting `color` on the button.
- **Bar transition**: Bars MUST apply `transition: 0.25s` (all properties), which animates the `rotate()` transform applied to the first and last bar when toggling to the close state.
- **Color**: Bars inherit the button's text `color` CSS property.
- **Pixel alignment**: Bars are designed to land on whole device pixels; this is enforced by the thickness and pitch values in the accompanying CSS.
- **Close icon derivation**: In close state, the close icon (X shape) is derived from the two bars via CSS rotation/transform; the component does not render separate markup for the X.
- **Background**: No background specified in component; inherits from button styling context.
- **Border**: No border specified in component; inherits from button styling context.
- **Shadow**: No shadow specified in component; inherits from button styling context.

## States

| State | Appearance change |
|-------|------------------|
| Default (menu) | Three stacked bars |
| Close | Two bars crossed (via CSS transform) |
| Disabled | Standard HTML button disabled styling (subject to CSS) |
| Focused | Standard HTML button focus styling (subject to CSS) |
| Pressed/Active | Standard HTML button active styling (subject to CSS) |

## Accessibility

- **Role**: Button (implicit from `<button>` element).
- **Accessible name**: MUST be provided via the required `label` prop, which is applied as `aria-label`. The button has no visible text, so an accessible name is required.
- **Icon symbol**: Hamburger menu and close icons are purely visual; the accessible name provided by `label` replaces them functionally (e.g., "Menu" or "Close menu").
- **Keyboard navigation**: Button is fully keyboard accessible via standard `<button>` element behavior; may be activated via Space or Enter keys.
- **Assistive technology**: Screen readers will announce the button's accessible name and role; icon state changes should be conveyed through context or state changes announced by the parent component.
- **Minimum tap target**: The button's visible icon box is 32×32px (`--menu-size`), but the button MUST expose a 44×44px hit area via an absolutely positioned `::after` pseudo-element (`--menu-hit: 44px`) centred on the button and sized independently of `--menu-size`. This meets the 44×44pt minimum tap target guideline.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| menu-button-001 | must-render-button-element | Render with default props | Button element with `type="button"` is rendered |
| menu-button-002 | must-accept-label-prop | `label="Menu"` | `aria-label="Menu"` is present on button element |
| menu-button-003 | must-display-menu-icon-by-default | No `icon` prop | Three `<span class="mb-bar">` elements render |
| menu-button-004 | must-display-close-icon-variant | `icon="close"` | Two `<span class="mb-bar">` elements render |
| menu-button-005 | must-apply-menu-button-class | Default render | Button has class `menu-button` |
| menu-button-006 | must-apply-close-variant-class | `icon="close"` | Button has classes `menu-button` and `menu-button--close` |
| menu-button-007 | must-allow-custom-classname | `className="custom-class"` | Button includes `custom-class` in its class list |
| menu-button-008 | must-support-html-button-attributes | `onClick={handler}` | Handler is invoked on button click |
| menu-button-009 | must-support-html-button-attributes | `disabled={true}` | Button is disabled (behavior subject to browser/CSS) |
| menu-button-010 | must-support-icon-toggle | Toggle `icon` prop from `'menu'` to `'close'` | Bar count changes from three to two; classes update accordingly |

## Edge Cases

- **No label prop**: Component requires `label` prop; not providing it results in an inaccessible button with no accessible name. MUST NOT render if label is not provided (or should fail at type-check level in TypeScript).
- **Icon prop invalid value**: Component expects `icon` to be `'menu'` or `'close'`. Providing any other value (e.g., `icon="hamburger"`) will render with the default menu icon since the close state is checked explicitly.
- **Empty string label**: An empty `label=""` satisfies the type requirement but results in an inaccessible button with no meaningful name. The component accepts this but the caller SHOULD provide a meaningful label.
- **Disabled state interaction**: When disabled, the button MUST NOT respond to clicks; this is standard HTML button behavior and does not depend on component logic.
- **Multiple class combinations**: Component combines `menu-button`, the conditional `menu-button--close`, and any custom `className` prop. Classes are filtered and joined with spaces; empty strings are removed.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `icon` | `'menu' \| 'close'` | `'menu'` | Controls which icon is displayed: `'menu'` for three bars or `'close'` for two bars |
| `label` | `string` | (required) | Accessible name for the button; used as `aria-label` |
| `className` | `string` | (optional) | Custom CSS class(es) to add to the button element |
| `...rest` | `HTMLButtonElement` attributes | N/A | All standard button attributes (e.g., `disabled`, `onClick`, `data-*`) are passed through |

## Deep Linking

Not applicable: This is a UI control with no deep-linking semantics. Deep linking is handled by the page or component that contains the menu button.

## Localization

Not applicable: The component accepts the `label` string from the caller, so localization is the responsibility of the consuming application. The component itself contains no user-facing strings.

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | SHOULD respect `prefers-reduced-motion` media query when animating bar rotation (close icon derivation). This is enforced in the accompanying CSS (`css/base.css`), not in the component logic. |
| Increase Contrast | SHOULD respond to `prefers-contrast` media query for bar color if defined in CSS. |
| Differentiate Without Color | Not applicable: The icon is purely visual and the accessible name is always provided via `aria-label`. |

## Feature Flags

Not applicable: Component contains no feature flag logic.

## Analytics

Not applicable: Component emits no analytics events. Analytics instrumentation is the responsibility of the consuming application via `onClick` or other event handlers.

## Privacy

Not applicable: Component stores and transmits no personal data. The `label` string is provided by the caller and is a UI string only.

## Logging

Not applicable: Component performs no logging.

## Platform Notes

- **Web**: Implemented in React as a functional component. Bars are `<span>` elements with class `mb-bar`; the close icon is derived from the bars via CSS transform (rotation). Styling is external to the component and defined in accompanying stylesheets (referenced as `css/base.css`). The component accepts all standard `HTMLButtonElement` attributes via prop spread.
- **SwiftUI**: Translate to a `Button` with a custom `Label` containing a `VStack` of three horizontal `Divider` elements for menu state, or two rotated `Divider` elements for close state. Use `.foregroundColor()` to apply the button's text color to the bars. Respect `@Environment(\.isEnabled)` for disabled state. Bind icon state to a `@State` variable or accept it as a parameter.
- **Compose**: Implement as an `IconButton` or `Button` with a custom `painter` or `content` lambda containing three `Box` elements stacked vertically for menu state. For close state, render two boxes with rotation transforms applied. Use `LocalContentColor` to inherit the button's text color. Respect Compose's `enabled` state. Accept icon and label parameters.
- **AppKit / UIKit**: Implement as a `UIButton` (UIKit) or `NSButton` (AppKit) with a custom view subclass or view controller containing three `UIView` or `NSView` elements as bars. Apply `CABasicAnimation` to rotate the bars when toggling to close state. Use `tintColor` to apply the button's color. Handle `isEnabled` and `isHighlighted` states. Accept icon state and label (for accessibility via `accessibilityLabel`).
- **WinUI 3**: Implement as a `Button` control with a custom `ContentTemplate` containing a `StackPanel` (vertical) of three `Rectangle` elements for the bars (menu state). For close state, use `RotateTransform` on a `Canvas` or apply transforms to the rectangles to create the crossed-bars effect. Bind the visibility or transform of elements to a state variable controlling the icon. Use `Foreground` property to inherit button's text color. Set `AutomationProperties.Name` for accessibility. Respect `IsEnabled` property for disabled state.

## Design Decisions

1. **Bars as plain elements, not SVG**: The source uses `<span>` elements instead of SVG to enable pixel-perfect alignment, color inheritance from the button's text color, and simpler animation via CSS transforms. SVG would require additional coordinate transformation logic and would not automatically inherit the button's color.

2. **Close icon derived from bars via CSS**: Rather than render separate markup for the close icon, the two bars in close state are rotated via CSS to form an X. This keeps the component's JSX simpler and ensures that any change to bar geometry (thickness, spacing) automatically updates both the menu and close icons consistently.

3. **Bars rendered conditionally**: Menu state renders three bars; close state renders two bars (the third is conditionally omitted). This is simpler than rendering three bars in both states and using CSS to hide one, and it matches the semantic difference between the two icons.

4. **No animation logic in component**: The component itself renders static markup. Animations (bars rotating to form an X) are purely CSS concerns and are defined in the accompanying stylesheet. This keeps the component lightweight and makes animations easy to customize or disable (e.g., for `prefers-reduced-motion`).

5. **Accessible name required**: The component's `label` prop is required (no default value) because the button has no visible text. An accessible name is necessary for the component to be usable by assistive technologies.

## Compliance

Not applicable: No specific compliance checks are defined in source. Standard HTML button and ARIA label compliance is assumed.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.1.0 | 2026-09-22 | | Resolve NEEDS REVIEW markers: bar dimensions and tap target sourced from css/base.css |
| 1.0.0 | 2026-09-22 | | Initial creation from MenuButton.tsx source |
