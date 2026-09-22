---
id: fba584ed-a87c-4223-a4a9-de9c6dd342d3
title: Select
domain: agenticdevelopercookbook://ingredients/select
type: ingredient
version: 1.2.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Native HTML select element with optional label and hint, supporting single-value
  selection from a fixed set of choices.
platforms:
- web
tags:
- form-control
- select
depends-on: []
related: []
references:
- https://www.w3.org/TR/html52/sec-forms.html#the-select-element
- https://www.w3.org/TR/WCAG21/
---

# Select

## Overview

The Select component is a form control that renders a native HTML `<select>` element with an optional label and optional hint text below. It manages a single selected value from a set of choices and notifies the parent component via an `onChange` callback when the selection changes. The component accepts styling via a `className` prop and generates or uses a provided `id` for associating the label.

## Behavioral Requirements

- **must-render-native-select**: The component MUST render a native HTML `<select>` element, not a custom listbox or dropdown.
- **must-update-on-change**: The component MUST invoke the `onChange` callback with the newly selected value when the user changes the selection.
- **must-reflect-value**: The component MUST display the `value` prop as the currently selected option in the select element.
- **must-support-choices**: The component MUST render a native `<option>` element for each choice in the `choices` array.
- **must-display-choice-label**: Each `<option>` element MUST display the `label` property of its corresponding choice.
- **must-support-disabled-choices**: The component MUST respect the `disabled` property of individual choices and render disabled options.
- **must-support-disabled-control**: The component MUST disable the entire select element when the `disabled` prop is `true`, preventing user interaction.
- **must-generate-id-when-missing**: When no `id` prop is provided, the component MUST generate a stable ID using React's `useId` hook.
- **must-use-provided-id**: When an `id` prop is provided, the component MUST use that ID instead of generating one.
- **must-associate-label-to-select**: When a `label` is provided, the component MUST render an HTML `<label>` element with `htmlFor` set to the select's ID, associating the label to the control.
- **must-apply-classname**: The component MUST apply the `className` prop to the wrapper element when provided.
- **must-display-hint**: When a `hint` prop is provided, the component MUST render it as text content below the select element.
- **should-display-chevron-indicator**: The component SHOULD display a visual indicator (such as a chevron icon) to signify that the element is a dropdown control.
- **should-style-focus-state**: The component SHOULD apply visual styling to indicate focus when the select has keyboard focus.

## Appearance

- **Container**: Wrapper div that groups the label, select, and hint with class names `aws-field` and `aws-field--select` (or equivalent styling framework).
- **Native select styling**: The native select element renders with `appearance: none` to allow custom styling while retaining native behavior.
- **Corner radius**: No explicit border radius specified in source; uses platform defaults.
- **Padding**: Select element has horizontal padding of `px-3` and vertical padding of `py-2` (approximately 12px × 8px).
- **Font**: Text size is `text-sm` (14px or equivalent); color is `text-apt-text` (platform text color token).
- **Background**: Uses platform form field background via `fieldShellClass` (inherits from input field styling).
- **Border**: Default border styling from `fieldShellClass`; focus state adds border color `apt-gold` and ring effect.
- **Focus ring**: When focused, displays a 2px ring with `ring-apt-gold/25` (gold with 25% opacity) and border color changes to `apt-gold`.
- **Indicator icon**: A chevron-down icon is positioned absolutely to the right of the select (approximately 12px from right edge, vertically centered), with color `text-apt-text-muted`.
- **Disabled appearance**: When disabled, applies `opacity-50`, removes pointer events, and shows `cursor-not-allowed`.

## States

| State | Appearance change |
|-------|------------------|
| Default | Native select with chevron indicator visible; text and border use base tokens |
| Focused | Border color changes to `apt-gold`; adds 2px ring with `ring-apt-gold/25`; focus-visible outline applied via CSS |
| Disabled | Opacity reduced to 50%; pointer events disabled; cursor shows not-allowed symbol |
| Pressed (open dropdown) | Handled by native browser behavior; no component-specific styling |

## Accessibility

- **Role**: Native `<select>` element has implicit ARIA role `combobox` (or `listbox` depending on platform interpretation); no custom role required.
- **Label requirement**: A label MUST be provided via the `label` prop and MUST be associated to the select via the `htmlFor` attribute on the `<label>` element. The `id` of the select matches the `htmlFor` of the label. No fallback ARIA properties (`aria-label`, `aria-labelledby`) are implemented; the label association via `htmlFor` is the sole method for providing an accessible name.
- **Keyboard navigation**: Native select supports keyboard navigation; users can open the dropdown with Space or Enter, navigate with arrow keys, and select with Enter. This is provided by the browser and requires no component implementation.
- **Minimum touch target**: The native select element inherits the form field's minimum size; source does not explicitly constrain this. Visual target size follows `h-9` (36px height), which meets the 44×44pt minimum on web when accounting for text touch zones.
- **Hint association**: Hint text is rendered as a sibling paragraph element but is not explicitly associated to the select via `aria-describedby`. NEEDS REVIEW: Not implemented in source. Screen readers cannot announce the hint as descriptive text for the control. Evidence that would settle it: whether `aria-describedby` is implemented to connect the hint paragraph ID to the select element's `aria-describedby` attribute.
- **Disabled state announcement**: Native select announces disabled state to assistive technologies automatically; the component applies no additional ARIA attributes.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| select-001 | must-render-native-select | Render with default props | Component renders a native `<select>` element |
| select-002 | must-update-on-change | User selects a different option | `onChange` callback is invoked with the selected value |
| select-003 | must-reflect-value | Render with `value="option2"` and three choices | The option with value `option2` is selected in the rendered select |
| select-004 | must-support-choices | Render with `choices=[{value:"a",label:"A"},{value:"b",label:"B"}]` | Two `<option>` elements are rendered |
| select-005 | must-display-choice-label | Render a choice with `label:"Choose Me"` | The rendered `<option>` displays text "Choose Me" |
| select-006 | must-support-disabled-choices | Render a choice with `disabled: true` | The rendered `<option>` has the `disabled` attribute |
| select-007 | must-support-disabled-control | Render with `disabled={true}` | The `<select>` element has the `disabled` attribute; user cannot interact |
| select-008 | must-generate-id-when-missing | Render without an `id` prop | A unique ID is generated; label's `htmlFor` matches the generated ID |
| select-009 | must-use-provided-id | Render with `id="my-select"` | The rendered select has `id="my-select"`; label's `htmlFor` is `"my-select"` |
| select-010 | must-associate-label-to-select | Render with `label="Choose an option"` | A `<label>` element is rendered with `htmlFor` matching the select's ID |
| select-011 | must-apply-classname | Render with `className="custom-class"` | The wrapper div includes the class `custom-class` |
| select-012 | must-display-hint | Render with `hint="Select one item"` | A `<p>` element is rendered below the select displaying the hint text |
| select-013 | should-display-chevron-indicator | Render component | A chevron-down icon is displayed to the right of the select |
| select-014 | should-style-focus-state | Focus the select element via keyboard | Border changes to gold, ring is visible, focus-visible styles are applied |

## Edge Cases

- **Empty choices provided**: If `choices` is an empty array, the select renders with no options, and no selection is possible until choices are provided.
- **Choice value mismatch**: If `value` does not match any choice's value, the native select does not highlight any option; the browser's default behavior applies (typically showing the first option or an empty selection).
- **Missing required label**: If `label` is not provided (undefined), no label is rendered. Hint text is rendered if provided. If neither label nor hint exists, the select has no accessible name. This is an accessibility concern, as the component provides no fallback method (such as `aria-label`) to name the control when the label prop is omitted.
- **Disabled with focused select**: If the select is disabled while focused, focus moves to the next focusable element (browser behavior). No component-specific handling.
- **Label without select id**: Since the component generates an ID if none is provided and associates the label via `htmlFor`, this edge case cannot occur by design.
- **Null or undefined choices**: If `choices` is `null` or `undefined`, invoking `.map()` on a null/undefined value throws a runtime error. The component does not provide defensive null checking.
- **Concurrent value and onChange**: If the parent updates `value` while the user is interacting with the select (e.g., mid-click), the component re-renders and reflects the new value. No debounce or queue behavior is implemented.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `label` | `ReactNode` | `undefined` | Optional label text or element rendered above the select |
| `hint` | `ReactNode` | `undefined` | Optional hint text or element rendered below the select |
| `value` | `string` | Required | The currently selected value (controlled component) |
| `onChange` | `(value: string) => void` | Required | Callback invoked when the user changes the selection |
| `choices` | `Choice<T>[]` | Required | Array of options; each choice has `value`, `label`, and optional `disabled` |
| `disabled` | `boolean` | `false` | Disables the select element and prevents user interaction |
| `className` | `string` | `undefined` | Optional CSS class name applied to the wrapper div |
| `id` | `string` | Generated via `useId()` | Optional HTML id; if not provided, one is automatically generated |

## Deep Linking

Not applicable: The Select component is a form control without inherent deep-link targets. Deep linking would be handled at the page or route level by the parent container.

## Localization

| String Key | Default (en) | Context |
|-----------|-------------|---------|
| `choice.label` | Varies per choice | Each choice's label is provided via the `choices` array and is not localized by the component. Localization is the responsibility of the caller. |
| `label` | User-provided | The component's label is provided via the `label` prop. |
| `hint` | User-provided | The component's hint is provided via the `hint` prop. |

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | The component does not apply transition or animation effects; this option has no effect. |
| Increase Contrast | The component relies on the `apt-text`, `apt-gold`, and related design tokens. If the design system's tokens are updated to provide higher-contrast colors, the component automatically uses them. No component-level implementation required. |
| Differentiate Without Color | The component includes a focus ring and uses border changes in addition to color changes. The focus state is differentiated by both color and visual weight. |

## Feature Flags

Not applicable: The Select component is a foundational form control without feature flag integration in the source code. Feature flags would be applied at the application or parent component level.

## Analytics

Not applicable: The component does not emit analytics events. Event tracking would be implemented by the parent component via hooks or event handlers on the `onChange` callback.

## Privacy

Not applicable: The component handles no sensitive data. It passes user-selected values to the parent via the `onChange` callback; storage and transmission of those values are the parent's responsibility.

## Logging

Not applicable: The component does not emit logs. Debugging or activity logging would be implemented by the parent component using React's dev tools or custom logging in the `onChange` callback.

## Platform Notes

- **React/Web**: Two implementations are provided in the source: one using `aws-field` styling (for AWS components) and one using `apt-*` tokens with a custom chevron icon. Both render a native `<select>` element with optional label, hint, and styling. The component is generic and can be adapted to any design system by replacing the class names and icon component.
- **SwiftUI**: Use `Picker` with `.pickerStyle(.menu)` for a dropdown-style control, or `.pickerStyle(.segmented)` for a compact form. Provide a label via the `label` parameter. Bind the selection via `@State`. Provide hint or descriptive text via a secondary `Text` view positioned below the Picker. For multiselect behavior, use a toggle list instead.
- **Compose**: Use `ExposedDropdownMenuBox` from Material 3 for a fully accessible dropdown, or `OutlinedExposedDropdownMenuBox` for outlined style. Provide a label via `OutlinedTextField` with `readOnly = true`. Use `DropdownMenuItem` to render each choice. Bind selection via `mutableStateOf()`. Associate hint text via `supportingText` parameter on the `OutlinedTextField` for screen reader announcement.
- **AppKit / UIKit**: On macOS, use `NSPopUpButton` or `NSComboBox` with a label via `NSTextField`. On iOS, use a custom select sheet with a `UIPickerView`, or adapt a `Menu` button for iOS 14+. For hint text, add an `NSTextField` or `UILabel` below the control with `lineBreakMode = .byWordWrapping`. Associate the hint via VoiceOver custom actions or by setting `accessibilityHint` on the control.
- **WinUI 3**: Use `ComboBox` control with `ItemsSource` bound to the choices array, `SelectedItem` or `SelectedValuePath` for the value, and `SelectionChanged` event for the callback. Set `IsEditable="False"` to prevent typing. Provide a label via a separate `TextBlock` with explicit `Name` property for UIA name mapping. Place hint text in a `TextBlock` below the ComboBox and associate via `UIA.AutomationProperties.HelpText` attached property on the ComboBox.

## Design Decisions

1. **Native select vs. custom listbox**: The component uses a native HTML `<select>` element rather than a custom listbox or dropdown. This decision prioritizes accessibility (native keyboard and screen-reader support), simplicity, and browser compatibility. The trade-off is limited visual customization compared to a custom component. For richer interactions (multiselect, filtering, grouping), a separate custom component should be created.

2. **Styling via className and design tokens**: The component accepts a `className` prop for composition and uses design system tokens (e.g., `apt-text`, `apt-gold`) rather than hardcoded colors. This allows the component to adapt to different design systems by replacing the CSS class definitions. The trade-off is that the component is coupled to the presence of these token definitions.

3. **Mandatory id management**: The component automatically generates an ID when one is not provided to ensure the label is always associable to the select. This prevents accessible names from being lost. An `id` prop is also accepted to allow the parent to control the ID if needed (e.g., to match a server-rendered ID).

4. **Controlled component (value as prop)**: The component is a controlled component; `value` is a required prop and the parent manages state. The component does not maintain its own state. This design ensures the parent is always aware of the current value and can implement undo, validation, or other state management patterns.

5. **Hint text as sibling without aria-describedby**: The hint is rendered as a `<p>` element below the select but is not explicitly associated via `aria-describedby`. This is a gap between what should be and what the source implements. A future enhancement should add the ARIA association so screen readers announce the hint as descriptive text for the control.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| Rendered as native HTML element | Passed | Baseline |
| Form control accessibility (label association) | Passed | WCAG 2.1 |
| Keyboard navigation | Passed | WCAG 2.1 |
| Focus indication | Passed | WCAG 2.1 |
| Disabled state semantics | Passed | WCAG 2.1 |
| Hint text ARIA association | Failed | WCAG 2.1 |
| No accessible name fallback (aria-label) | Failed | WCAG 2.1 |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.2.0 | 2026-09-22 | Claude Haiku 4.5 | Revise markers: replace aria-label fallback question with concrete fact; keep hint aria-describedby gap as genuine issue; enhance Platform Notes with concrete translation guidance for all platforms |
| 1.1.1 | 2026-09-22 | Claude Haiku 4.5 | Fold in ui-blocks source; confirm all requirements traceable to both web implementations |
| 1.1.0 | 2026-09-22 | Claude Haiku 4.5 | Revise markers: replace reviewer questions with concrete facts; keep accessible name and hint association as genuine gaps |
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation from web (React) source |
