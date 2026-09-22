---
id: 25816370-14ff-454a-83d4-ebd588a2ff01
title: Slider
domain: agenticdevelopercookbook://ingredients/slider
type: ingredient
version: 1.1.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Labeled range input control that allows users to select a numeric value within
  a defined minimum and maximum.
platforms:
- typescript
- web
tags:
- form-control
- input
- range
depends-on: []
related: []
references:
- https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input/range
- https://www.w3.org/TR/WCAG21/
approved-by: ''
approved-date: ''
---

# Slider

## Overview

A slider is a labeled range input control that allows users to select a numeric value by dragging a handle along a track. It supports a configurable minimum and maximum value, optional step increments, and can display a dynamic caption showing the current value. The component wraps the native HTML5 `<input type="range">` element with optional label, hint text, and caption.

## Behavioral Requirements

- **must-render-input**: Component MUST render an HTML5 `<input type="range">` element with the specified `value`, `min`, `max`, and `step` attributes.
- **must-accept-value**: Component MUST accept a controlled `value` prop (number) and reflect it in the input element.
- **must-call-on-change**: Component MUST call the `onChange` callback with the new numeric value when the user interacts with the range input.
- **must-support-label**: Component MUST render an optional `<label>` element when the `label` prop is provided; the label MUST have an `htmlFor` attribute pointing to the input's ID.
- **must-support-hint**: Component MUST render an optional hint text element when the `hint` prop is provided, positioned below the slider.
- **must-support-caption**: Component MUST render an optional caption element when the `caption` prop is provided; if `caption` is a function, the component MUST call it with the current `value` and render the result.
- **must-support-disabled**: Component MUST disable the input element when the `disabled` prop is `true`.
- **must-respect-min-default**: Component MUST use a default `min` value of `0` when the `min` prop is not provided.
- **must-respect-max-default**: Component MUST use a default `max` value of `100` when the `max` prop is not provided.
- **must-respect-step-default**: Component MUST use a default `step` value of `1` when the `step` prop is not provided.
- **must-generate-id**: Component MUST generate a unique ID for the input when the `id` prop is not provided, using React's `useId` hook.
- **must-associate-label**: Component MUST use the same ID (either provided or generated) for both the input's `id` attribute and the label's `htmlFor` attribute to ensure proper semantic association.
- **must-apply-classes**: Component MUST apply the CSS classes `aws-field` and `aws-field--slider` to the wrapper element, and MUST append any `className` prop provided.

## Appearance

The component's visual presentation is controlled entirely by CSS. The component itself establishes the following class structure:

- **Wrapper**: `aws-field aws-field--slider` (plus optional custom `className`)
- **Label**: `aws-field__label` — applied to the `<label>` element when present
- **Slider container**: `aws-slider`
- **Input**: `aws-slider__input` — applied to the range input
- **Caption**: `aws-slider__caption` — applied to the caption span

The actual appearance (colors, spacing, dimensions, border radius, shadows) is defined by CSS rules for these classes and is outside the scope of this component's implementation.

## States

| State | Appearance change | Behavioral change |
|-------|------------------|------------------|
| Default | Component rendered normally | User can interact with the range input |
| Disabled | Input element has `disabled` attribute; CSS may apply visual disabled styling | Range input does not respond to user interaction |

## Accessibility

- **Role**: The component uses the semantic HTML5 `<input type="range">` element, which has an implicit role of `slider`.
- **Label association**: When a `label` prop is provided, the component renders a `<label>` element with `htmlFor` pointing to the input's ID, creating a proper semantic association. The label is optional; when not provided, the component renders without a label element.
- **Min/Max exposure**: The `min`, `max`, and `step` attributes are directly set on the input element, making them available to assistive technologies.
- **Value announcements**: Assistive technologies will announce the current value and range based on the input's `value`, `min`, and `max` attributes.
- **Minimum tap/click target**: The HTML5 range input's size is browser-dependent and controlled by CSS. Per WCAG 2.1, interactive elements SHOULD have a minimum touch target of 44×44px; CSS must enforce this.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| slider-001 | must-render-input | value=50, min=0, max=100, step=1 | `<input type="range" value="50" min="0" max="100" step="1">` is rendered |
| slider-002 | must-accept-value | Controlled component with value=75 | Input element's `value` attribute equals `75` |
| slider-003 | must-call-on-change | User drags input to value 60 | `onChange` callback is invoked with `60` |
| slider-004 | must-support-label | label="Volume" | `<label htmlFor="{id}">Volume</label>` is rendered |
| slider-005 | must-support-hint | hint="Adjust volume from 0–100" | Hint text is rendered as `<p class="aws-field__hint">...</p>` below the slider |
| slider-006 | must-support-caption (static) | caption="Volume: 50" | Caption "Volume: 50" is rendered as `<span class="aws-slider__caption">...</span>` |
| slider-007 | must-support-caption (dynamic) | caption={(val) => `Level: ${val}`}, value=75 | Caption "Level: 75" is rendered (function called with current value) |
| slider-008 | must-support-disabled | disabled=true | Input has `disabled` attribute; user cannot interact with it |
| slider-009 | must-respect-min-default | min prop not provided | `min` attribute defaults to `0` |
| slider-010 | must-respect-max-default | max prop not provided | `max` attribute defaults to `100` |
| slider-011 | must-respect-step-default | step prop not provided | `step` attribute defaults to `1` |
| slider-012 | must-generate-id | id prop not provided | Component generates a unique ID using React's `useId`; label (if present) associates to this ID |
| slider-013 | must-associate-label | id="custom-slider", label="Value" | `<label htmlFor="custom-slider">` and `<input id="custom-slider">` both use the same ID |
| slider-014 | must-apply-classes | className="my-custom-class" | Wrapper has classes `aws-field aws-field--slider my-custom-class` |
| slider-015 | must-call-on-change (boundary) | User drags to min=0 | `onChange(0)` is called |
| slider-016 | must-call-on-change (boundary) | User drags to max=100 | `onChange(100)` is called |

## Edge Cases

- **Empty/null props**: When `label`, `hint`, and `caption` are undefined or null, the component does not render these elements; this is intentional and specified in the source code (`{label && ...}`, `{captionNode !== undefined && ...}`, `{hint && ...}`).
- **Caption as function with value change**: When `caption` is a function, it is re-evaluated on every value change; the component passes the current `value` to the function and renders the result. No memoization is applied; if expensive computation is needed, the caller should memoize the function.
- **Step value smaller than range**: If `step` is 1 and the range is 0–100, the user can select any integer in that range. The HTML5 input respects the `step` attribute; any interaction respects the step granularity.
- **Min equal to max**: If `min` and `max` are equal (e.g., both `50`), the range is effectively disabled by browser behavior; the value cannot change. The component does not validate this condition.
- **Custom className concatenation**: The `className` prop is concatenated to the base classes using `.filter(Boolean).join(' ')`, allowing conditional classes to be omitted if they are falsy.
- **Disabled state with existing value**: When the `disabled` prop changes from `false` to `true`, the value is not cleared; the current value is retained but the input becomes non-interactive.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `label` | `ReactNode` | `undefined` | Optional label text or element displayed above the input |
| `hint` | `ReactNode` | `undefined` | Optional hint text or element displayed below the slider |
| `value` | `number` | (required) | Current value of the slider; controlled by the parent component |
| `onChange` | `(value: number) => void` | (required) | Callback invoked when the user changes the slider value |
| `min` | `number` | `0` | Minimum value of the slider range |
| `max` | `number` | `100` | Maximum value of the slider range |
| `step` | `number` | `1` | Increment/decrement step when user adjusts the slider |
| `caption` | `ReactNode \| (value: number) => ReactNode` | `undefined` | Optional static content or function that returns dynamic content based on the current value |
| `disabled` | `boolean` | `false` | When `true`, disables the input and prevents user interaction |
| `className` | `string` | `undefined` | Optional additional CSS class name(s) to apply to the wrapper element |
| `id` | `string` | (auto-generated) | Optional ID for the input element; if not provided, a unique ID is generated using React's `useId` |

## Deep Linking

Not applicable: This component is a form control without built-in deep linking support. Deep linking would be implemented at the page or application level, not within the component.

## Localization

Not applicable: The component renders no built-in strings. All visible text (label, hint, caption) is provided by the parent component as props, allowing the parent to handle localization.

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | Not explicitly implemented in source. CSS may apply reduced motion via media queries (e.g., `@media (prefers-reduced-motion: reduce)`), but the component does not detect or respond to this setting in JavaScript. |
| Increase Contrast | Not explicitly implemented in source. Contrast is controlled by CSS; the component does not detect or respond to `prefers-contrast`. |
| Differentiate Without Color | Not explicitly implemented in source. The component uses semantic HTML and CSS classes; visual differentiation is the responsibility of CSS rules. |

## Feature Flags

Not applicable: The component does not include conditional logic or feature-gating; no feature flags are present in the source code.

## Analytics

Not applicable: The component does not emit analytics events. Event tracking would be implemented by the parent component using the `onChange` callback.

## Privacy

Not applicable: The component processes only the numeric value of the slider; it does not collect, store, or transmit any personal data or sensitive information.

## Logging

Not applicable: The component does not include any logging or debugging output.

## Platform Notes

- **React/Web**: Implemented in Slider.tsx using React hooks (`useId`). The component wraps the native HTML5 `<input type="range">` with optional label, hint, and caption elements. CSS classes (`aws-field`, `aws-slider`) control visual presentation. The component is exported as both `Slider` and `CaptionedSlider` (aliases).

- **SwiftUI**: On iOS, start with SwiftUI's native `Slider` view. The equivalent ingredient would wrap it with optional `Label`, hint text below, and a caption view that updates based on the slider's `value`. SwiftUI's slider does not natively support custom captions or external labels in the same way; these would be separate views in a `VStack`.

- **Compose**: On Android, start with `Slider` from Material Design 3 Compose library. Material Design sliders support labels through `Slider` parameters and custom value label slots. Adapt the hint and caption as separate `Text` composables below the slider. Handle `onValueChange` callback and manage state at the parent level.

- **AppKit / UIKit**: On macOS, use `NSSlider` (AppKit) or `UISlider` (UIKit). Both require manual layout of labels and captions as separate UI elements. AppKit's `NSSlider` has limited built-in label support; use adjacent `NSTextField` for the label. UIKit requires programmatic constraints or SwiftUI wrapping. Neither provides native dynamic caption binding; update the caption view imperatively when the value changes.

- **WinUI 3**: On Windows, use the `Slider` control from the WinUI 3 library (Windows.UI.Xaml.Controls namespace). WinUI sliders support a `Header` property for labels and can host child elements for captions. Bind the `Value` property to your data model using two-way binding. Use a `TextBlock` below for hints. The slider's visual style respects system contrast and motion settings through `ThemeResource` tokens; no explicit Accessibility Options handling is required at the component level.

## Design Decisions

- **HTML5 `<input type="range">`**: The component uses the native browser range input rather than a custom-built slider. This provides built-in accessibility (semantic role and keyboard support) and cross-browser consistency, but limits visual customization to CSS.
  
- **Controlled component pattern**: The slider is a controlled component — its value is managed entirely by the parent component via the `value` prop and `onChange` callback. This aligns with React's unidirectional data flow and allows the parent to compose validation, formatting, or multi-step workflows.

- **Optional label with `htmlFor` association**: The label is optional, but when provided, it is properly associated to the input via `htmlFor`. This supports both labeled and unlabeled use cases while maintaining accessibility when labels are present.

- **Caption as function or static node**: The caption supports both static content and dynamic content (via a function). This allows flexible display of the current value or other state-dependent information without requiring the parent to manage a separate derived state.

- **Default values for min, max, step**: Defaults of `min=0`, `max=100`, `step=1` provide a useful out-of-the-box range (0–100 with integer increments). These are common in UI contexts and can be overridden if a different range is needed.

- **CSS-driven appearance**: All visual styling is delegated to CSS classes. The component does not hard-code colors, sizes, or spacing, allowing styling to be managed consistently across the application.

## Compliance

Not applicable: Component compliance depends on CSS implementation and parent component context. At the HTML level, the component uses semantic HTML5 elements and proper label association, supporting WCAG 2.1 guidelines. Specific accessibility compliance (contrast ratios, touch target sizes) is enforced via CSS, not the component.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.1.0 | 2026-09-22 | Mike Fullerton | Resolved label accessibility marker: labels are optional as per source code |
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
