---
id: f8b8792e-12f2-4ca1-80a8-9ae7f2c5b31d
title: Color Picker
domain: agenticdevelopertoolkit://recipes/color-picker
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A controlled form field component that allows users to select a color using
  the native color picker and displays the hex value.
platforms:
- typescript
- web
tags: []
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Color Picker

## Overview

The Color Picker is a form field component that wraps the native HTML5 `<input type="color">` element. It presents a native color picker interface to the user and displays the selected color's hex value. The component accepts a controlled `value` prop and fires an `onChange` callback when the user selects a new color. An optional label and hint text provide context and guidance.

## Behavioral Requirements

- **must-render-label**: The component MUST render a label element associated to the input when a `label` prop is provided.
- **must-accept-value**: The component MUST accept a `value` prop containing a valid hex color string (e.g., `#FF0000`).
- **must-fire-change**: The component MUST invoke the `onChange` callback with the new hex color string when the user selects a color from the picker.
- **must-render-hex-display**: The component MUST display the current hex color value as text adjacent to the picker.
- **must-support-disabled**: The component MUST respect a `disabled` prop and prevent interaction when `true`.
- **must-render-hint**: The component MUST render hint text when a `hint` prop is provided.
- **must-generate-id**: The component MUST generate a unique `id` for the color input if no `id` prop is provided.
- **must-hide-hex-from-assistive-tech**: The component MUST mark the hex value display with `aria-hidden="true"` to prevent duplicate announcements by screen readers.
- **may-accept-classname**: The component MAY accept a `className` prop to allow custom CSS classes to be applied to the field container.

## Appearance

- **Corner radius**: Determined by user agent native color input styling
- **Padding**: Controlled by CSS class `.aws-field` and `.aws-color`
- **Font**: Hex display uses inherited font from `.aws-color__hex` class
- **Background**: Native color input background; hex display background inherited
- **Foreground/Text**: Hex value text color controlled by `.aws-color__hex` class
- **Border**: Native color input border styling
- **Shadow**: None by default
- **Min/Max size**: Native color input dimensions; container may constrain width via CSS class

## States

| State | Appearance change |
|-------|------------------|
| Default | Color input displays current value; hex value shown as text |
| Disabled | Color input visually disabled; text input interaction blocked |
| Focused | Native input focus ring displayed (user agent dependent) |

## Accessibility

- **Role**: The input element has implicit role `"textbox"` for the native color input; label is properly associated via `htmlFor`.
- **Label requirements**: When a `label` prop is provided, it MUST be associated to the input via `htmlFor` matching the input's `id`.
- **Hex value announcement**: The hex value display MUST be marked `aria-hidden="true"` since the value is part of the input's accessible description and should not be announced twice.
- **Minimum tap target**: The native color input button itself has user-agent-defined sizing; the label and hint text are not interactive tap targets.
- **Keyboard navigation**: The native HTML color input supports standard keyboard interaction (Tab to focus, Enter/Space to open picker on supporting browsers).

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| color-001 | must-render-label | label="Choose Color" | Label element rendered with matching htmlFor |
| color-002 | must-accept-value | value="#FF0000" | Input value set to #FF0000 |
| color-003 | must-fire-change | User selects #00FF00 | onChange callback invoked with "#00FF00" |
| color-004 | must-render-hex-display | value="#FF0000" | Hex text "#FF0000" displayed next to picker |
| color-005 | must-support-disabled | disabled={true} | Input is disabled and not interactive |
| color-006 | must-render-hint | hint="Select brand color" | Hint text rendered below color picker |
| color-007 | must-generate-id | No id prop supplied | Unique id generated and applied to input |
| color-008 | must-hide-hex-from-assistive-tech | Any state | Hex display has aria-hidden="true" |
| color-009 | may-accept-classname | className="custom-class" | Custom class applied to container div |

## Edge Cases

- **Empty value**: If `value` prop is an empty string or not a valid hex color, the native input may render with a default color or indicate an error state (user agent dependent).
- **Null or undefined label/hint**: Component gracefully skips rendering label or hint if props are not provided; no error or empty placeholder is shown.
- **Disabled with active focus**: On some platforms, a disabled input may retain focus; the browser's native input handles this state.
- **Invalid hex string**: If the `value` is not a valid color string, the browser's color input behavior is user-agent dependent; the component does not validate or coerce the value.
- **Rapid value changes**: Multiple onChange calls in quick succession (e.g., from drag in the picker) are all propagated immediately; the component does not debounce.

## Configuration

Not applicable. The component accepts configuration through its props (`label`, `hint`, `value`, `onChange`, `disabled`, `className`, `id`); no separate configuration object is used.

## Deep Linking

Not applicable. This is a form field component within a larger form or dialog; deep linking is not a relevant use case.

## Localization

The component itself contains no hardcoded strings. The `label` and `hint` props are ReactNode and can be localized strings passed by the parent. The hex value display is language-neutral (hex format is universal).

## Accessibility Options

- **Reduce Motion**: Not applicable. The component does not use motion or animations; it relies on the native color input's behavior, which respects system motion preferences via the user agent.
- **Increase Contrast**: Not applicable. The component inherits contrast from the `.aws-color__hex` and `.aws-field` CSS classes, which should follow platform contrast guidelines.
- **Differentiate Without Color**: Not applicable. The component does not use color alone to convey state; the disabled state is enforced by the native input's disabled attribute.

## Feature Flags

Not applicable. The component has no feature flag guards; it is always available.

## Analytics

Not applicable. The component itself does not emit analytics events; the parent form or application layer is responsible for tracking color selection if needed.

## Privacy

- **Data collected**: None directly by the component. The `value` prop and `onChange` callback are controlled by the parent; any data retention or transmission is the responsibility of the parent application.
- **Storage**: Not applicable.
- **Transmission**: Not applicable.
- **Retention**: Not applicable.

## Logging

Not applicable. The component does not emit diagnostic logs; browser DevTools and the native color input's behavior provide visibility into state.

## Platform Notes

- **SwiftUI**: On iOS and macOS, use `ColorPicker` from SwiftUI (`ColorPicker(_ label:, selection:)`) to wrap SwiftUI's native color picker. Bind the selection to a `@State` variable and handle `onChange` semantics via SwiftUI's reactive model. Label and value are natively supported.
- **Compose**: On Android with Compose, use `ColorPickerDialog` or build with `Box` + custom composition for the color picker. Jetpack Compose does not have a native color picker; implement using a third-party color picker library or a custom color wheel component. Bind state via `remember { mutableStateOf(...) }` and pass an `onValueChange` callback.
- **React/Web**: The web implementation uses the native HTML5 `<input type="color">` in `packages/web/packages/controls/src/user-settings/components/ColorPicker.tsx`. The component is a controlled React component; it renders `.aws-field` and `.aws-color` container classes, associates the label via `htmlFor`, and displays the hex value in `.aws-color__hex`. CSS classes are applied from the `aws-*` namespace (AgenticWebStack design system).
- **AppKit / UIKit**: On macOS with AppKit, use `NSColorWell` (deprecated) or `NSColorPanel` for system color picking; on iOS with UIKit, a custom color picker view or third-party library is required since UIKit does not provide a built-in color picker. Present modally or inline depending on the UX pattern. Implement the label and value display in custom views.
- **WinUI 3**: On Windows with WinUI 3, use `ColorPicker` control from the WinUI library or build with `Grid` + `Rectangle` + `Slider` controls for RGB sliders. The native `ColorPicker` is available in `Microsoft.UI.Xaml.Controls`. Bind the `Color` property to a two-way binding, handle the `ColorChanged` event for `onChange` semantics, and display the hex value in a separate `TextBlock`. Apply Fluent 2 design system styling via theme resources.

## Design Decisions

- **Hex-only display**: The component displays the hex value (not RGB) for familiarity and brevity in the form. Hex is the standard representation for web colors and matches developer expectations.
- **aria-hidden on hex display**: The hex value is marked `aria-hidden` because screen readers will already announce the value when the color input is focused and its value changes; duplicating the announcement would be redundant.
- **Native HTML input**: The implementation uses the native `<input type="color">` rather than a custom color picker UI to leverage user-agent-provided UX, reduce bundle size, and ensure consistent behavior across browsers.
- **Controlled component pattern**: The component requires both `value` and `onChange` props, making it a controlled component in React terms. This pattern ensures the parent retains full control over the color state and allows for validation, side effects, and multi-field coordination.

## Compliance

Not applicable. No specific compliance audits or external standards (e.g., WCAG, ISO) are referenced; the component relies on the native HTML input's built-in accessibility and the parent application's compliance posture.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
