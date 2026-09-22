---
id: 6f7c9bb6-b6fe-479a-9dbc-3ff174f7fed2
title: Choice Slider
domain: agenticdevelopercookbook://ingredients/choice-slider
type: ingredient
version: 1.2.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A slider control that selects from a discrete set of labeled choices.
platforms:
- swift
- kotlin
- typescript
- web
tags:
- form-input
- selection-control
depends-on: []
related: []
references: []
---

# Choice Slider

## Overview

A choice slider is a slider control that lets users select one value from a discrete set of labeled options. It's useful when presenting 3–7 mutually exclusive choices where the options have a natural order and occupy limited space. Unlike a dropdown or radio buttons, the slider makes all choices immediately visible and suggests progression or spectrum. The component combines an HTML range input with a label, caption showing the current selection, and optional hint text.

## Behavioral Requirements

- **must-accept-choice-array**: Component MUST accept an array of `Choice<T>` objects, each with a `value` property (string or number) and a `label` property (ReactNode or equivalent).
- **must-maintain-value-in-range**: When the `value` prop is passed, the component MUST find the matching choice by value and position the slider at its index. If no match is found, it MUST default to the first choice (index 0).
- **must-fire-change-callback**: When the user moves the slider, the component MUST call the `onChange` callback with the `value` property of the newly selected choice, not the index.
- **must-display-current-label**: The component MUST display the `label` of the currently selected choice.
- **must-render-html-range-input**: The component MUST render an HTML `<input type="range">` element with `min="0"`, `max` equal to the number of choices minus 1, and `step="1"`.
- **must-respect-disabled-state**: When the `disabled` prop is true, the range input MUST be disabled, preventing user interaction.
- **may-render-label**: If a `label` prop is provided, the component MAY render it in a `<label>` element associated with the range input via `htmlFor`.
- **may-render-hint**: If a `hint` prop is provided, the component MAY render it as additional descriptive text below the slider.
- **may-apply-custom-classname**: The component MAY accept a `className` prop and apply it to the root container alongside the required `aws-field` and `aws-field--choice-slider` classes.
- **may-accept-custom-id**: If an `id` prop is provided, the component MAY use it for the range input. Otherwise, it MUST generate a unique ID internally.

## Appearance

- **Container**: Uses class `aws-field` and `aws-field--choice-slider`. A `div` wrapping label, slider, caption, and hint.
- **Label**: When present, styled with class `aws-field__label`. Inline text color and size inherit from `<label>` defaults.
- **Slider wrapper**: Uses class `aws-slider`. Contains the range input and caption.
- **Range input**: Uses class `aws-slider__input`. Standard HTML range input styling; appearance varies by browser and platform.
- **Caption**: Uses class `aws-slider__caption`. Displays the selected choice's label. Positioned adjacent to or below the range input (layout depends on CSS not specified in source).
- **Hint**: Uses class `aws-field__hint`. Positioned below the slider when present. Styled as paragraph element.

## States

| State | Appearance change |
|-------|------------------|
| Default | Range input is interactive; caption displays current choice label. |
| Disabled | Range input has `disabled` attribute; pointer interaction disabled (browser default styling applied). |
| Focused | Range input receives keyboard focus; browser default focus indicator visible. |

## Accessibility

- **Role**: The range input has the implicit ARIA role `slider`.
- **Labeling**: If a `label` prop is provided, it MUST be associated with the range input via `<label htmlFor={fieldId}>`, where `fieldId` is the `id` prop or the `useId()` fallback. The `label` prop is optional, and when it is omitted the source sets no `aria-label`, no `aria-labelledby` and no `title` on the input, so the slider renders with no accessible name at all. NEEDS REVIEW: Not implemented in source. Behavior undefined. Missing is any fallback accessible name for the label-less case; the gap is settled by a decision from the design/accessibility owner on whether `label` becomes a required prop or an `aria-label` prop is added, confirmed by an accessibility audit of a rendering with `label` omitted.
- **Keyboard support**: The range input MUST support arrow key navigation (left/right to decrease/increase value) per HTML range input spec. No additional keyboard handling required.
- **Screen reader announcement**: The source sets no `aria-valuetext` on the range input, so assistive technology announces the raw numeric value — the choice index, `0` through `choices.length - 1` — and never the choice label. The `aws-slider__caption` span that carries the label is a sibling of the input and is not referenced by `aria-describedby`, `aria-labelledby` or any other relation, so it is not announced with the value either. NEEDS REVIEW: Not implemented in source. Behavior undefined. Missing is any announced textual value for the selected choice; the gap is settled by a VoiceOver/NVDA pass confirming that only the index is spoken, plus a decision to map each index to `aria-valuetext`.
- **Touch target size**: The source sets no thumb size. `styles.css` gives `.aws-slider__input` only `flex: 1`, `min-width: 0`, `cursor: pointer` and `accent-color: var(--aws-accent)`, and declares no `::-webkit-slider-thumb`, `::-moz-range-thumb`, `height` or `width` rule anywhere, so the thumb is the user agent's native range thumb at its default size, tinted by the `--aws-accent` token. An implementation MUST keep the platform's native range thumb rather than substituting a custom one, and MUST tint it using the `--aws-accent` token.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| choice-slider-001 | must-accept-choice-array | choices = [{value: "a", label: "Option A"}, {value: "b", label: "Option B"}] | Component renders without error and accepts the array |
| choice-slider-002 | must-maintain-value-in-range | value = "b", choices = [{value: "a", label: "A"}, {value: "b", label: "B"}, {value: "c", label: "C"}] | Slider positioned at index 1; caption displays "B" |
| choice-slider-003 | must-maintain-value-in-range | value = "unknown", choices = [{value: "a", label: "A"}, {value: "b", label: "B"}] | Slider positioned at index 0; caption displays "A" (first choice is default) |
| choice-slider-004 | must-fire-change-callback | Slider moved from index 0 to index 1, choices = [{value: "opt-1", ...}, {value: "opt-2", ...}] | onChange called once with argument "opt-2" |
| choice-slider-005 | must-display-current-label | value = "c", choices = [{value: "a", label: "Label A"}, {value: "b", label: "Label B"}, {value: "c", label: "Label C"}] | Caption element displays text "Label C" |
| choice-slider-006 | must-render-html-range-input | choices.length = 5 | Range input has min="0", max="4", step="1" |
| choice-slider-007 | must-respect-disabled-state | disabled = true | Range input element has disabled attribute; user cannot interact with slider |
| choice-slider-008 | may-render-label | label = "Select preference" | Label element rendered with htmlFor pointing to range input id |
| choice-slider-009 | may-render-hint | hint = "Choose your preferred option" | Hint text rendered in paragraph with class aws-field__hint |
| choice-slider-010 | may-accept-custom-id | id = "my-slider" | Range input has id="my-slider" |

## Edge Cases

- **Empty choices array**: `choices: Choice<T>[]` accepts an empty array and the source adds no guard, so the path is reachable — and every step of it is defined. `findIndex` returns `-1`, `Math.max(0, -1)` yields index `0`, `choices[0] ?? choices[0]` is `undefined`, and `current?.label` short-circuits, so the caption renders empty instead of throwing. `max` evaluates to `Math.max(0, -1)` = `0`, so the range input renders inert with `min="0"` and `max="0"`, and `onChange` can never fire because `choices[Number(e.target.value)]` is `undefined` and the `if (next)` guard rejects it. An implementation MUST render an inert range input with an empty caption for an empty `choices` array, MUST NOT throw, and MUST NOT invoke `onChange`.
- **Single choice**: If `choices.length === 1`, the range input has `max="0"`, preventing any slider movement. The single choice is always selected and displayed. This is valid but may confuse users; no error state defined.
- **Null or undefined value prop**: When `value` is undefined, `findIndex` returns -1, and `Math.max(0, -1)` yields 0, selecting the first choice by default. This is a safe fallback.
- **Null or undefined label or hint**: If `label` is falsy, the label element is not rendered (conditional render). If `hint` is falsy, hint paragraph is not rendered. This is correct.
- **Number vs. string values**: The component compares `c.value === value` without type conversion. If choices contain numeric values but `value` is a string (or vice versa), the comparison fails and the first choice is selected. No type coercion is performed.
- **onChange called during render**: The `onChange` callback is only called in response to the `input` event on the range element. It is not called during render or on prop changes.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `label` | ReactNode | undefined | Optional label text or element displayed above the slider. |
| `hint` | ReactNode | undefined | Optional hint text or element displayed below the slider. |
| `value` | string \| number | (required) | The currently selected choice value. MUST match one of the choice values. |
| `onChange` | function | (required) | Callback invoked with the selected choice's value when the slider moves. |
| `choices` | Choice<T>[] | (required) | Array of selectable options. Each choice has a `value` and `label`. |
| `disabled` | boolean | false | When true, slider interaction is disabled. |
| `className` | string | undefined | Optional additional CSS class(es) to apply to the root container. |
| `id` | string | (auto-generated) | Optional custom ID for the range input. If omitted, a unique ID is generated via `useId()`. |

## Deep Linking

Not applicable: Component is a form field, not a routable page.

## Localization

Not applicable: Component does not manage translatable strings. The `label`, `hint`, and choice `label` properties are provided by the consumer; localization is the consumer's responsibility.

## Accessibility Options

The component responds to accessibility display options through browser defaults and CSS framework styling:

- **Reduce Motion**: The browser's range input may use default animations for thumb movement. The source component adds no custom animation; browser and CSS framework Reduce Motion handling applies to the range input and caption.
- **Increase Contrast**: The browser's range input appearance and the CSS framework (via `aws-slider__input` and `aws-slider__caption` classes) respond to platform contrast settings. The component does not apply specific contrast overrides beyond framework defaults.
- **Differentiate Without Color**: Selection is conveyed via the slider thumb position and the visible caption label text, not color alone. The caption provides text-based indication independent of visual position.

## Feature Flags

Not applicable: Component is a library ingredient, not a feature behind a flag.

## Analytics

Not applicable: Component does not emit analytics events. Event tracking is the consumer's responsibility via the `onChange` callback.

## Privacy

Not applicable: Component does not collect, store, or transmit user data.

## Logging

Not applicable: Component does not perform logging. Debugging is handled via React DevTools.

## Platform Notes

- **SwiftUI**: Implement using `Slider` with an `.onEditingChanged` modifier to track thumb movement. Map the slider's continuous `value` (0 to choices.count - 1) to discrete choice indices via `Int(value)`. Render the current choice's label in a `Text` view below or adjacent to the slider. Use `Text("Label") + Spacer()` to achieve label + hint layout. Disabled state via `.disabled(isDisabled)` modifier.

- **Compose**: Use `Slider` composable with `value`, `onValueChange`, `valueRange = 0f..(choices.size - 1)`, and `steps = choices.size - 2` to enforce discrete steps. Convert the `value` to `Int` to index into the choices array. Render the current choice label in a `Text` composable. Apply `enabled` parameter to the slider for the disabled state. Use `Modifier.padding()` and `Modifier.fillMaxWidth()` for spacing and layout.

- **React/Web**: Implement as in the source using an HTML `<input type="range">` element wrapped in a container. Bind `value={currentIndex}`, `min="0"`, `max={choices.length - 1}`, and `step="1"`. Call `onChange` with `choices[newIndex].value`. Style using CSS classes (e.g., `aws-field`, `aws-slider`). Use `useId()` for auto-generated IDs. Support `label` and `hint` ReactNode props for flexibility.

- **AppKit / UIKit**: On macOS, use `NSSlider` with `minValue = 0`, `maxValue = choices.count - 1`, and `numberOfTickMarks = choices.count`. Use `isIntegral = true` and `allowsTickMarkValuesOnly = true` to enforce discrete steps. Add a `NSTextField` to display the current choice label. On iOS, `UISlider` does not support discrete steps natively; use `gestureRecognizer` with `discrete` rounding in the `valueChanged` event or consider using a custom `UIControl` subclass. For iOS, a segmented control (`UISegmentedControl`) may be more appropriate if screen space permits.

- **WinUI 3**: Use `Slider` control with `Minimum = 0`, `Maximum = choices.Count - 1`, `StepFrequency = 1`, and `SnapsTo = SnapPointsType.MandatoryWithinRange` to enforce discrete stepping. Bind the slider's `Value` to an index variable. Use a `TextBlock` to display the current choice's label. Apply `IsEnabled` binding for the disabled state. Use `StackPanel` for layout (label, slider, caption, hint). Leverage `x:Uid` or RESX files for localization if the consumer provides localized labels.

## Design Decisions

- **Index-based slider with value-based callback**: The component uses the HTML range input's inherent index-based positioning (0 to choices.length - 1) but exposes the selected choice's `value` in the callback. This decouples the choice order from its identity, allowing reordering without breaking callers. However, it adds a layer of indirection (index → value) that is not explicit in the prop types; consumers must understand this behavior.

- **Default to first choice on value mismatch**: When `value` does not match any choice, the component silently selects the first choice. This is a "fail safe" approach that prevents undefined rendering but masks a programming error (passing an invalid value). An alternative would be to throw an error or require controlled behavior. The current behavior is permissive but could hide bugs.

- **No type-coercing equality check**: The component uses strict equality (`===`) to match `value` against `choice.value`. If the choice array contains numbers and `value` is a string (or vice versa), no match occurs. This is intentional to preserve type safety but can be surprising if the consumer mixes types. No automatic type conversion is performed.

- **Disabled state disables only the input, not the label**: When `disabled` is true, the HTML range input is marked with the `disabled` attribute. The label and hint remain interactive (clickable/focusable). This matches standard HTML form behavior but means clicking the label does not focus the now-disabled input; clarify expected behavior in implementation.

- **No announcement of choice label to screen readers**: The range input announces its numeric value (index) to screen readers. The choice's label is visual-only and not included in `aria-valuetext` or read aloud. For full accessibility, consumers should pair this component with an additional description or label. This is a gap in the source implementation.

## Compliance

Not applicable: No specific compliance checks are defined for this ingredient.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.2.0 | 2026-09-22 | Claude Opus 5 | Thumb sizing and empty-choices behavior restated as fact from `styles.css` and the source; two accessibility gaps retained |
| 1.1.0 | 2026-09-22 | Claude Haiku 4.5 | Revision pass Phase 1: gap triage across Accessibility and Edge Cases |
| 1.0.0 | 2026-09-22 | (cookbook update) | Initial creation |
