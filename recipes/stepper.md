---
id: 0eaf03a3-c00b-4f3a-81d7-5bd0560a5274
title: Stepper
domain: agenticdevelopercookbook://ingredients/stepper
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Number input control with increment and decrement buttons for adjusting numeric
  values within min/max bounds.
platforms:
- typescript
- web
tags:
- form-input
- numeric-control
depends-on: []
related: []
references: []
---

# Stepper

## Overview

A stepper is a numeric input component that allows users to adjust a number by incrementing or decrementing with dedicated buttons, or by directly entering a value. It enforces minimum and maximum bounds and prevents operations that would violate those bounds.

## Behavioral Requirements

- **must-accept-numeric-value**: Component MUST accept an initial numeric value via the `value` prop.
- **must-call-onchange-handler**: Component MUST invoke the provided `onChange` handler with the new numeric value when the user increments, decrements, or directly edits the input.
- **must-clamp-to-bounds**: Component MUST clamp all values to the specified `min` and `max` bounds; values outside the range MUST be automatically adjusted to the nearest boundary.
- **must-respect-step-size**: Component MUST increment and decrement by the specified `step` amount (default 1).
- **must-disable-decrement-at-min**: Decrement button MUST be disabled when the current value is less than or equal to `min`.
- **must-disable-increment-at-max**: Increment button MUST be disabled when the current value is greater than or equal to `max`.
- **must-disable-all-controls-when-disabled**: When the `disabled` prop is `true`, all interactive elements (buttons and input) MUST be disabled and MUST NOT respond to user interaction.
- **must-support-direct-input**: Component MUST accept direct numeric input via an input field; non-numeric entries MUST be rejected or ignored.
- **must-support-optional-label**: Component MUST render an optional label element associated with the input field via `htmlFor` attribute when `label` prop is provided.
- **must-support-optional-hint**: Component MUST render an optional hint or help text below the control when `hint` prop is provided.
- **may-accept-custom-classname**: Component MAY accept a custom CSS class name via the `className` prop for styling overrides.
- **may-accept-custom-id**: Component MAY accept a custom element ID via the `id` prop; if not provided, a unique ID MUST be generated automatically.

## Appearance

- **Corner radius**: 4px (control-specific borders, varies by platform design system)
- **Padding**: Buttons and input inherit field padding from AWS design system (typically 8px vertical × 12px horizontal)
- **Font**: 14px regular weight for input value
- **Background**: White or system background color for input; button backgrounds inherit from AWS field styling
- **Foreground/Text**: #0F1419 (dark text) or system text color
- **Border**: 1px solid #D5DBEA (light gray) or system border color; focus state applies blue outline
- **Shadow**: None (flat design)
- **Min/Max size**: Minimum width determined by button size and input width; no maximum enforced

## States

| State | Appearance change |
|-------|------------------|
| Default | Input visible with both buttons enabled; neutral colors |
| Value at min | Decrement button appears disabled (opacity/color change); increment button enabled |
| Value at max | Increment button appears disabled (opacity/color change); decrement button enabled |
| Disabled | All controls (input, both buttons) appear disabled; text color dimmed; interaction disabled |
| Focused (input) | Blue outline or focus ring applied to input field per platform standards |
| Focused (button) | Blue outline or focus ring applied to focused button |

## Accessibility

- **Role**: The input MUST have `role="spinbutton"` or be a native `<input type="number">` element (preferred). Buttons MUST have `role="button"`.
- **Label**: When a label is provided, the input MUST be associated via `<label htmlFor>` attribute. If no label is provided but hint or context exists, the input SHOULD have an `aria-label` or `aria-labelledby`.
- **Button labels**: Decrement and increment buttons MUST have clear, descriptive `aria-label` attributes ("Decrement", "Increment").
- **Announce disabled state**: When a button is disabled, its `disabled` attribute MUST be set; screen readers announce this state automatically.
- **Minimum tap target**: Buttons MUST be at least 44×44pt on iOS and 48×48dp on Android; web buttons SHOULD be at least 44×44px.
- **Keyboard navigation**: Input MUST accept focus and allow direct number entry via keyboard. Buttons MUST accept focus and respond to Enter or Space key presses (native `<button>` behavior).

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| stepper-001 | must-accept-numeric-value | value=5 | Input displays "5" |
| stepper-002 | must-call-onchange-handler | User clicks increment button, value=5, step=1 | onChange called with 6 |
| stepper-003 | must-call-onchange-handler | User clicks decrement button, value=5, step=1 | onChange called with 4 |
| stepper-004 | must-clamp-to-bounds | onChange(15), min=0, max=10 | Value clamped to 10; onChange called with 10 |
| stepper-005 | must-clamp-to-bounds | onChange(-5), min=0, max=10 | Value clamped to 0; onChange called with 0 |
| stepper-006 | must-respect-step-size | User increments, value=0, step=5, max=20 | onChange called with 5 |
| stepper-007 | must-respect-step-size | User decrements, value=10, step=3, min=0 | onChange called with 7 |
| stepper-008 | must-disable-decrement-at-min | value=0, min=0 | Decrement button disabled |
| stepper-009 | must-disable-increment-at-max | value=10, max=10 | Increment button disabled |
| stepper-010 | must-disable-all-controls-when-disabled | disabled=true | Input, decrement button, increment button all disabled |
| stepper-011 | must-support-direct-input | User types "42" in input, min=0, max=100 | onChange called with 42 |
| stepper-012 | must-support-direct-input | User types "abc" in input | Input ignores non-numeric input; value unchanged |
| stepper-013 | must-support-optional-label | label="Quantity" | Label element rendered and associated with input |
| stepper-014 | must-support-optional-hint | hint="Enter a value between 1 and 10" | Hint text displayed below stepper |
| stepper-015 | may-accept-custom-classname | className="my-stepper" | Custom class applied to wrapper element |
| stepper-016 | may-accept-custom-id | id="order-qty" | Input element has id="order-qty"; label htmlFor="order-qty" |
| stepper-017 | must-clamp-to-bounds | User types "25" in input, max=20 | Value clamped to 20; onChange called with 20 |

## Edge Cases

- **Null or undefined min/max**: When `min` or `max` is not provided, the component treats them as -Infinity and +Infinity respectively. Clamping with infinite bounds works correctly.
- **Step smaller than 1**: The component supports fractional steps (e.g., step=0.5). Values MUST be clamped correctly; direct input MUST accept decimals matching the step size.
- **Step larger than range**: If step size is larger than (max - min), incrementing from min jumps to or beyond max, triggering the max-bounds behavior. This is correct per clamping logic.
- **Direct input of boundary values**: User enters exactly min or max value. Component MUST accept it and MUST NOT reject valid boundary entries.
- **Direct input while at boundary**: User is at max value, types a new number below max, and increments. New value MUST respect the typed entry and the increment; the most recent operation (typed value) takes precedence in the set() function.
- **Disabled state with valid/invalid values**: When disabled=true, the component MUST NOT respond to button clicks or input changes regardless of the current value or bounds.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `value` | number | required | Current numeric value |
| `onChange` | (value: number) => void | required | Callback invoked when value changes |
| `min` | number | -Infinity | Minimum allowed value |
| `max` | number | +Infinity | Maximum allowed value |
| `step` | number | 1 | Increment/decrement step size |
| `disabled` | boolean | false | Disables all controls |
| `label` | ReactNode | undefined | Optional label text or element |
| `hint` | ReactNode | undefined | Optional hint or help text |
| `className` | string | undefined | Optional custom CSS class |
| `id` | string | auto-generated | Optional custom element ID |

## Deep Linking

Not applicable: Stepper is a form control component with no standalone URL routing behavior.

## Localization

| String Key | Default (en) | Context |
|-----------|-------------|---------|
| `stepper.decrement` | "Decrement" | aria-label for decrement button |
| `stepper.increment` | "Increment" | aria-label for increment button |

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | No motion or transitions applied in the component; button and input state changes occur instantly |
| Increase Contrast | Border color and text color SHOULD increase to meet AAA contrast requirements (7:1 minimum); disabled state text SHOULD remain distinguishable |
| Differentiate Without Color | Disabled buttons MUST indicate disabled state by text label ("Decrement", "Increment") and `disabled` attribute, not color alone |

## Feature Flags

Not applicable: Stepper is a core form component with no feature flag requirements.

## Analytics

| Event | Properties | When |
|-------|-----------|------|
| `stepper.incremented` | `{ value: number, prev_value: number, step: number }` | User clicks increment button |
| `stepper.decremented` | `{ value: number, prev_value: number, step: number }` | User clicks decrement button |
| `stepper.input_changed` | `{ value: number, prev_value: number }` | User edits input field directly |

## Privacy

- **Data collected**: The current numeric value only (no sensitive metadata).
- **Storage**: Value is maintained in component state during the session; not persisted by the component itself.
- **Transmission**: No data is transmitted by the component; the consumer (`onChange` handler) determines what is done with the value.
- **Retention**: Value is ephemeral within the component lifecycle; retention depends on the consuming application.

## Logging

Subsystem: `com.aws.controls` | Category: `Stepper`

| Event | Level | Message |
|-------|-------|---------|
| Value increment | debug | `Stepper: incremented value from {prev} to {next}` |
| Value decrement | debug | `Stepper: decremented value from {prev} to {next}` |
| Value clamped | debug | `Stepper: clamped value {original} to {clamped} (bounds: {min}–{max})` |

## Platform Notes

- **SwiftUI**: Use `Stepper(value:in:step:)` or a custom composition with `Button` + `TextField` + `HStack` layout. Bind `value` to a `@State` property; the framework handles clamping. Stepper in SwiftUI does not display the numeric value directly—pair it with a Text view or TextField if the value must be visible. For a visible value and manual increment/decrement, compose with `VStack` containing a TextField for direct input and HStack buttons for increment/decrement.

- **Compose**: Implement using `Row` with `IconButton` (decrement/increment) flanking a `TextField`. Use `value` state and `onValueChange` callback. Apply bounds checking with `coerceIn(min, max)`. Set button enabled state conditionally based on current value vs. min/max. Use `BasicTextField` or `OutlinedTextField` for the value display.

- **React/Web**: The source uses native `<input type="number">` with `<button>` elements. The component renders in a flex container with buttons flanking the input. CSS classes (aws-field, aws-stepper) apply styling. The `noAutofillProps` object prevents browser autofill on the input field. Direct platform implementation matches the provided source code exactly.

- **AppKit / UIKit**: Use `NSStepper` on macOS or `UIStepper` on iOS. Both provide increment/decrement buttons and value management. `UIStepper` does not display the numeric value by default—pair it with a UITextField or UILabel to show the current value. Configure `minimumValue`, `maximumValue`, and `stepValue` properties. Bind target-action or delegation to capture value changes.

- **WinUI 3**: Implement using `NumberBox` control with `Value`, `Minimum`, `Maximum`, and `SmallChange` (step) properties. NumberBox renders spin buttons (increment/decrement) inline with a text input by default. Set `IsEnabled` to manage the disabled state. Handle `ValueChanged` event to invoke the onChange callback. SpinButtonPlacementMode can be set to `Compact` or `Inline` to control button placement.

## Design Decisions

- **Clamping behavior**: All numeric values are clamped to [min, max] bounds after any change (button click or direct input). This prevents out-of-range values from being passed to the consumer and avoids state inconsistency.
- **Infinite defaults for min/max**: When min or max is not provided, they default to -Infinity and +Infinity respectively. This allows unconstrained ranges while simplifying the API (no separate "unbounded" mode).
- **Button disabling logic**: Buttons are disabled when an operation would exceed bounds (value <= min disables decrement; value >= max disables increment). This prevents repeated clicks from attempting invalid operations and provides clear affordance to users.
- **Direct input acceptance of non-numeric**: Non-numeric input is silently ignored via `Number.isNaN()` check; the input value does not change. This provides lenient error handling without error states.
- **aria-label over aria-describedby**: Buttons use aria-label for concise, standalone labels ("Decrement", "Increment") rather than aria-describedby, as the action is self-contained and descriptive.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| [wcag-keyboard-accessible](https://www.w3.org/TR/WCAG21/#keyboard-accessible) | passed | Keyboard Navigation |
| [wcag-use-of-color](https://www.w3.org/TR/WCAG21/#use-of-color) | passed | Accessibility |
| [wcag-non-text-content](https://www.w3.org/TR/WCAG21/#non-text-content) | passed | Accessibility |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | | Initial creation from React/Web source |
