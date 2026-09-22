---
id: d431934e-d64c-4dcf-bdab-b7c3465ee71b
title: Radio Group
domain: agenticdevelopercookbook://ingredients/radio-group
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A group of mutually exclusive radio button options where only one choice
  can be selected at a time.
platforms:
- web
tags:
- form-control
- radio-button
depends-on: []
related: []
references: []
---

# Radio Group

## Overview

A radio group component presents a set of mutually exclusive options from which the user MUST select exactly one. The component wraps native HTML radio inputs with semantic markup and supports optional labels, hints, and individual choice disabling. It is the appropriate control for binary or multiple-choice selections where only one answer is valid.

## Behavioral Requirements

- **must-render-choices**: The component MUST render each choice in the choices array as a distinct radio button option.
- **must-maintain-selection-state**: The component MUST maintain and reflect the currently selected value in the `value` prop, rendering that choice's radio input as checked.
- **must-handle-value-change**: The component MUST invoke the `onChange` callback with the new value when the user selects a different choice.
- **must-use-fieldset**: The component MUST render a `<fieldset>` element as the root container.
- **must-use-legend**: When a label prop is provided, the component MUST render it inside a `<legend>` element as the first child of the fieldset.
- **must-render-radiogroup-role**: The component MUST render a container element with `role="radiogroup"` that contains all radio button inputs.
- **must-support-choice-labels**: The component MUST display a label for each choice; the label MUST be associated with its corresponding radio input.
- **must-support-choice-hints**: When a choice has a hint property, the component MUST render that hint adjacent to the choice label.
- **must-support-field-hint**: When a hint prop is provided to the component, the component MUST render it as field-level guidance below all choices.
- **must-support-disabled-state**: When the disabled prop is true, the component MUST disable all radio inputs and prevent user interaction with the entire group.
- **must-support-individual-choice-disable**: When a choice has disabled: true, the component MUST disable only that specific radio input while allowing other choices to remain interactive.
- **must-accept-custom-classname**: The component MUST accept a className prop and apply it to the root fieldset element, allowing callers to customize appearance.
- **must-generate-group-name**: When the name prop is not provided, the component MUST generate a unique name for the radio group using a stable mechanism (e.g., useId).
- **must-accept-provided-name**: When the name prop is provided, the component MUST use that name for all radio inputs in the group.

## Appearance

- **Corner radius**: None (uses native input styling)
- **Padding**: Fieldset padding managed by CSS classes (aws-field)
- **Font**: Uses inherited font; choice labels rendered with aws-radio__label class
- **Background**: Transparent (fieldset background managed by aws-field class)
- **Foreground/Text**: Inherited text color for labels and hints
- **Border**: Fieldset may render border if aws-field class applies one
- **Shadow**: None
- **Min/Max size**: No explicit constraints; layout determined by CSS classes

## States

| State | Appearance change |
|-------|------------------|
| Default | All unselected choices render with empty indicator |
| Selected | Selected choice renders with filled/checked indicator and checked input attribute |
| Disabled (group) | All radio inputs and fieldset receive disabled attribute; text may render grayed out per CSS |
| Disabled (individual choice) | Individual radio input receives disabled attribute; that choice's option appears inactive |
| Focused | Native browser focus ring on the focused radio input |

## Accessibility

- **Role/trait**: Fieldset with legend for group label; each input is a native radio control with associated label
- **Label requirements**: Each radio input MUST have an associated label element; the group MUST have a legend when a label prop is provided; each choice MUST have a label rendered in its associated label element
- **Announce state changes**: When a choice is selected via keyboard or mouse, the input's checked state changes are announced by assistive technology automatically via the native checked attribute
- **Keyboard navigation**: Users MUST be able to navigate between choices using arrow keys (browser default for radio groups); the selected choice MUST be selectable with Enter or Space keys
- **Minimum tap target**: The clickable area (including the label text and indicator) SHOULD meet a minimum 44×44pt target on touch devices per WCAG guidelines

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| radio-group-001 | must-render-choices | choices=[{value:'a',label:'A'},{value:'b',label:'B'}] | Both choices rendered as radio options |
| radio-group-002 | must-maintain-selection-state | choices=[{value:'a',...},{value:'b',...}], value='b' | The choice with value='b' renders with checked=true |
| radio-group-003 | must-handle-value-change | User clicks choice with value='c' | onChange callback invoked with value='c' |
| radio-group-004 | must-use-fieldset | Component rendered | Root element is a fieldset |
| radio-group-005 | must-use-legend | label='Group Label' provided | Legend element renders with text 'Group Label' |
| radio-group-006 | must-render-radiogroup-role | Component rendered | Container element has role="radiogroup" |
| radio-group-007 | must-support-choice-labels | choices=[{value:'a',label:'Option A'}] | Text 'Option A' appears next to radio input |
| radio-group-008 | must-support-choice-hints | choices=[{value:'a',label:'A',hint:'Hint text'}] | 'Hint text' rendered adjacent to the choice |
| radio-group-009 | must-support-field-hint | hint='Field guidance' | Text 'Field guidance' rendered below the radio choices |
| radio-group-010 | must-support-disabled-state | disabled=true, choices=[{...},{...}] | All radio inputs have disabled attribute; fieldset has disabled attribute |
| radio-group-011 | must-support-individual-choice-disable | choices=[{value:'a',...},{value:'b',disabled:true}] | Choice 'b' radio input has disabled attribute; choice 'a' remains enabled |
| radio-group-012 | must-accept-custom-classname | className='custom-class' | Root fieldset renders with 'custom-class' in its class list |
| radio-group-013 | must-generate-group-name | name not provided | All radio inputs receive the same generated name value via useId |
| radio-group-014 | must-accept-provided-name | name='my-group' | All radio inputs have name="my-group" |

## Edge Cases

- **Empty choices array**: When choices is an empty array, the component MUST render a fieldset and radiogroup div but no radio options. This is a valid but typically undesired state; the component does not prevent it.
- **Null or undefined label**: When label is null or undefined, the component MUST NOT render a legend element.
- **Null or undefined hint**: When the component hint is null or undefined, no field-level hint element MUST be rendered.
- **Null or undefined choice hints**: When a choice hint is null or undefined, no hint element MUST be rendered for that choice.
- **Value not in choices**: When the value prop does not match any choice's value, no radio input will be checked. This is a valid state representing an unselected group (e.g., during initial render before a default is set).
- **Disabled group with onChange**: When disabled=true, the onChange callback MUST NOT be invoked even if the user attempts interaction (disabled by browser).
- **Changing choices array mid-interaction**: If the choices array changes while a choice is selected, the component MUST continue to render the current value as checked if it still exists in the new choices array; if the selected value no longer exists, no choice is checked until onChange updates the value.
- **Type T generics**: The component is generic over T (string | number). Values and onChange callback MUST maintain type consistency; the component does not enforce this at runtime but consumers must ensure type alignment.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| label | ReactNode | undefined | Optional label text rendered in a legend element |
| hint | ReactNode | undefined | Optional field-level guidance text rendered below choices |
| value | T (string \| number) | required | The currently selected choice value; MUST match one of the choice values |
| onChange | (value: T) => void | required | Callback invoked when the user selects a different choice |
| choices | Choice<T>[] | required | Array of choice objects, each with value, label, and optional disabled and hint properties |
| disabled | boolean | false | When true, disables all radio inputs and the fieldset |
| className | string | undefined | Optional CSS class string applied to the root fieldset element |
| name | string | undefined | Optional name attribute for all radio inputs; if omitted, a unique name is generated via useId |

## Deep Linking

Not applicable: The radio group component is a form control and does not support direct deep linking to a specific choice selection via URL or URI pattern.

## Localization

| String Key | Default (en) | Context |
|-----------|-------------|---------|
| N/A | N/A | The component does not emit any static strings; all text (label, hints, choice labels) comes from props and is caller's responsibility to localize. |

## Accessibility Options

- **Reduce Motion**: The component does not animate; no changes required.
- **Increase Contrast**: The component relies on native input styling and CSS classes; callers applying high-contrast CSS must ensure radio indicators and labels remain distinguishable.
- **Differentiate Without Color**: The component must not rely on color alone to indicate selection state; the checked input attribute and native browser rendering already provide non-color distinction (e.g., filled vs. empty indicator).

## Feature Flags

Not applicable: The component is a foundational form control with no feature-flag-gated behavior.

## Analytics

Not applicable: The component does not emit any analytics events; consumers implementing this component are responsible for tracking selection changes via the onChange callback if analytics instrumentation is desired.

## Privacy

Not applicable: The component does not collect, transmit, or retain user data; it is a stateless UI control that only holds the selected value in its parent's state.

## Logging

Not applicable: The component does not emit any log messages.

## Platform Notes

- **Web (React)**: Implemented using native HTML `<fieldset>` and `<input type="radio">` elements with semantic `<legend>` and `role="radiogroup"` for full accessibility. React's `useId` hook generates stable unique names when none is provided. CSS classes (aws-field, aws-radio, etc.) provide styling hooks; consumers must provide the corresponding stylesheets.

- **iOS (SwiftUI)**: Implement using SwiftUI's `Picker` with `pickerStyle(.segmented)` or a custom VStack of `Toggle` bindings, or build a custom view wrapping native `UIPickerView` or a stack of `UIButton` elements styled as radio indicators. SwiftUI's Picker does not natively expose radio-button styling, so a custom implementation using manual state management and custom styling is typical. The `@Binding` pattern replaces the onChange callback.

- **Android (Compose)**: Implement using Compose's `RadioButton` composable within a `LazyColumn` or `Column`, manually managing state via `mutableStateOf`. Each RadioButton has a `selected` property and `onClick` lambda; the containing layout should wrap them in a semantically grouped container. Compose provides no automatic grouping like HTML fieldset; the developer must manually ensure only one selection and apply visual grouping via layout and styling.

- **macOS (AppKit)**: Implement using a container view (NSBox or NSStackView) with multiple `NSButton` instances configured as `.radio` button type. Set all buttons to share the same target/action to manage mutual exclusivity, or implement manual state tracking via KVO/bindings. The title property provides the label; create separate NSTextField for hints if needed.

- **Windows (WinUI 3)**: Implement using the `RadioButton` control within a `StackPanel`. Each RadioButton has an `IsChecked` property and `Checked` routed event. Set the `GroupName` property on all buttons in a group to ensure mutual exclusivity automatically. Use `Content` property for the label and add a separate `TextBlock` for hints. Wrap in a `Border` or custom control to provide fieldset-like visual grouping and handle disabled state via the `IsEnabled` property on the container.

## Design Decisions

1. **Native HTML inputs over custom styled elements**: The recipe specifies native `<input type="radio">` elements rather than styled divs with custom click handlers. This decision prioritizes accessibility and browser compatibility; native inputs work correctly with all assistive technologies and require no JavaScript event handling to achieve keyboard interaction.

2. **Fieldset and legend for semantic structure**: The component wraps the radiogroup in a fieldset and renders the label in a legend. This follows HTML standards for form grouping and is the correct semantic structure for grouped form inputs. Screen readers announce the legend as the group's accessible name.

3. **Optional field-level hint separate from choice hints**: The component supports both per-choice hints (for additional information about a specific option) and a field-level hint (for overall group guidance). This allows flexible UX patterns where a group has both field instructions and choice-specific guidance.

4. **Generated unique names via useId**: When no name prop is provided, the component uses React's `useId` hook to generate a unique, stable identifier for the radio group. This prevents multiple RadioGroup instances on the same page from interfering with each other's selection state, which would happen if all used the same hardcoded name.

5. **Support for type-generic values**: The component is generic over T (string | number) to support both string and numeric choice values, allowing consumers to work with their own type systems without additional conversion.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| Semantic HTML | passed | Accessibility |
| WCAG 2.1 Level AA keyboard navigation | passed | Accessibility |
| Native input usage | passed | Accessibility |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation from web source |
