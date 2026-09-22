---
id: 0f5b7167-b375-4f44-977b-566f720a453d
title: Input
domain: agenticdevelopercookbook://ingredients/input
type: ingredient
version: 1.1.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Single-line text input field with theme support, autofill handling, and validation
  state display.
platforms:
- web
tags:
- form-control
- input
depends-on: []
related: []
references: []
---

# Input

## Overview

A single-line text input field component that serves as the basic text capture element in forms. It supports multiple input types (text, email, password, etc.), themed colors via Material Design 3 tokens, focus and validation states, and accessibility features including aria-invalid support. The component enforces consistent styling across all text-based input fields in the application.

## Behavioral Requirements

- **must-accept-input-type**: Component MUST support the `type` prop to specify input type (text, email, password, number, etc.) and pass it directly to the underlying HTML input element.
- **must-handle-placeholder**: Component MUST display placeholder text when the field is empty, styled with reduced opacity via `text-apt-text-dim` token.
- **must-handle-autofill-tokens**: Component MUST accept an `autoComplete` prop and apply autofill prevention rules through `noAutofillPropsFor()` helper when no valid autofill token is provided.
- **must-support-selection-styling**: Component MUST style text selection with `bg-apt-gold/30` background color.
- **must-forward-dom-props**: Component MUST accept and forward all standard HTML input element props (value, onChange, onBlur, etc.) via the spread operator.
- **must-apply-base-styling**: Component MUST apply consistent field shell styling (rounded corners, border, background) via `fieldShellClass` constant shared with sibling field controls.
- **must-constrain-width**: Component MUST use `w-full` and `min-w-0` classes to fill its container while preventing flex/grid overflow of long content.
- **must-merge-classnames**: Component MUST accept a `className` prop and merge it with internal classes using the `cn()` utility function, with user classes taking precedence.

## Appearance

- **Corner radius**: 8px (lg), defined by `rounded-lg` class on fieldShellClass
- **Padding**: 8px vertical × 12px horizontal (py-2 px-3), adjusted for 36px total height with text-sm
- **Font**: 400 weight, 14px size, inherits family from page defaults (text-sm)
- **Background**: `apt-bg` token (light/dark adapted via theme)
- **Foreground/Text**: `apt-text` token (light/dark adapted via theme)
- **Border**: 1px solid `apt-border` token (light/dark adapted via theme)
- **Shadow**: None
- **Min/Max size**: Minimum height 36px (h-9); width constrained by container (w-full, min-w-0)

## States

| State | Appearance change |
|-------|------------------|
| Default | Border: `apt-border`, background: `apt-bg`, text: `apt-text` |
| Focus (focus-visible) | Border and ring: `apt-gold`, ring width 2px with `apt-gold/25` inner shadow for depth |
| Disabled | Opacity reduced to 50%, cursor becomes "not-allowed", pointer events disabled |
| Invalid (aria-invalid) | Border and ring: `apt-red`, ring width 2px with `apt-red/25` inner shadow |
| Placeholder (text absent) | Text color: `apt-text-dim` for reduced visual weight |

## Accessibility

- **Role/trait**: HTML input element with role="textbox" (implicit); supports type attribute for specialized roles (search, password)
- **Label requirements**: MUST be associated with an external `<label>` element using matching `id` and `for` attributes; the component itself does not provide a label
- **Announce state changes**: Component supports `aria-invalid="true"` attribute to signal validation errors to screen readers; invalid state MUST be applied at the form/page level alongside visual indicator
- **Announce disabled state**: Native HTML disabled attribute automatically communicated by assistive technology
- **Minimum tap target**: 36px height (h-9) meets Android minimum; iOS/web users benefit from larger touch target when possible
- **Keyboard support**: Native HTML input keyboard navigation; focus indicator visible via `focus-visible:ring` and border color change

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| input-001 | must-accept-input-type | `type="email"` | HTML input element has type="email" attribute |
| input-002 | must-accept-input-type | `type="password"` | HTML input element has type="password" attribute |
| input-003 | must-handle-placeholder | `placeholder="Enter name"` | Placeholder text visible when field empty, styled with `text-apt-text-dim` |
| input-004 | must-handle-autofill-tokens | `autoComplete="email"` | Autofill token applied; password managers can detect field |
| input-005 | must-handle-autofill-tokens | `autoComplete={undefined}` | `noAutofillPropsFor()` returns off-attribute set; password managers blocked |
| input-006 | must-support-selection-styling | Text highlighted by user | Selected text background: `apt-gold/30` (30% opaque gold) |
| input-007 | must-forward-dom-props | `value="test"` onChange={handleChange} | value prop passed through; onChange callback fires on input |
| input-008 | must-apply-base-styling | Rendered on page | Field has rounded corners (8px), 1px border, and `apt-bg` background |
| input-009 | must-constrain-width | Within 200px container | Field width matches container (100%), does not overflow |
| input-010 | must-merge-classnames | `className="custom-class"` | Both default classes and custom-class applied to element |
| input-011 | (states) focus-visible | User tabs to field or clicks | Border color changes to `apt-gold`, 2px ring visible with `apt-gold/25` inner shadow |
| input-012 | (states) disabled | `disabled={true}` | Opacity 50%, cursor not-allowed, no pointer events |
| input-013 | (states) aria-invalid | `aria-invalid="true"` | Border color: `apt-red`, 2px ring with `apt-red/25` inner shadow |

## Edge Cases

- **Empty or null input value**: Component renders with empty field; placeholder text visible if provided; no error state unless `aria-invalid="true"` is set externally
- **Very long input text**: Component uses `min-w-0` to prevent flex/grid overflow; text scrolls horizontally within field rather than pushing container
- **Autofill with undefined token**: `autoComplete={undefined}` is destructured and not spread, then `noAutofillPropsFor(undefined)` returns the off-attribute set to prevent password manager intrusion; this is the correct behavior for fields that should not autofill
- **Autofill with explicit token (e.g., "email")**: Helper returns nothing to overwrite; explicit token written before spread wins; password managers can detect and populate
- **Disabled state combined with other states**: Disabled MUST override all other interactive states; focus ring and hover are not visible when disabled
- **Disabled state with aria-invalid**: Both classes applied; visual indicators show both states; disabled state takes precedence in user interaction

## Configuration

Not applicable: Input component does not expose configuration options. Its appearance and behavior are determined entirely by HTML attributes (type, autoComplete, disabled, value, etc.) and CSS classes applied by the component implementation.

## Deep Linking

Not applicable: Input component is a form control with no independent deep-link target. Navigation to an input field is handled by the page/form containing it, using the field's id attribute in URL hash (e.g., `#field-name`).

## Localization

Not applicable: Input component does not emit localizable text. Placeholder text, labels, and validation messages are provided by the parent form and are the responsibility of the consuming application to localize.

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | Not explicitly handled in component; focus ring animation deferred to browser/OS defaults |
| Increase Contrast | Inherits higher-contrast token values through M3 theme tokens (`apt-border`, `apt-gold`, `apt-red`); no additional component logic needed |
| Differentiate Without Color | Relies on border and ring to indicate states (not color alone); focus indicator includes both ring and border color change |

## Feature Flags

Not applicable: Input component does not have feature flag logic. Feature flagging of form submissions or validation behavior belongs at the form level, not at the individual field component.

## Analytics

Not applicable: Input component does not emit analytics events. Event tracking for user input, form submission, and validation errors is the responsibility of the consuming form component.

## Privacy

Not applicable: Input component does not collect, store, or transmit data. It is a presentational form control. Data handling, encryption, and transmission are the responsibility of the consuming application and form handler.

## Logging

Not applicable: Input component does not perform logging. Debug logging for input values, state changes, or autofill behavior is the responsibility of the consuming application and form component.

## Platform Notes

- **React/Web**: The component is implemented as a functional component using React hooks. It uses Tailwind CSS for styling, M3 token utilities for theming (via `apt-*` classes mapped to CSS variables injected by `<AdhThemeStyle/>`), and the `cn()` utility for class merging (likely from `clsx` or similar). The `noAutofillPropsFor()` helper enforces autofill rules by applying browser autofill prevention attributes when no explicit autofill token is provided. Source: `packages/web/packages/ui/src/components/input.tsx`.
- **SwiftUI**: Start from SwiftUI's native `TextField` or `SecureField` (for password input). Apply Material Design 3 token colors for border (using `.border()` modifier with `Color(token: "apt-border")`), background (`.background(Color(token: "apt-bg"))`), and text (`.foreground(Color(token: "apt-text"))`). Implement focus state with `.focused($isFocused)` modifier to apply gold border and ring. For autofill behavior, iOS handles password autofill natively via `textContentType(.password)` — no additional prevention logic needed unless implementing custom autofill blocking.
- **Compose (Android)**: Start from Material Design 3 `OutlinedTextField` or `BasicTextField`. Apply M3 theme colors for container, border, text, and placeholder. Implement focus state using `FocusRequester` and visual indicators (border color, elevation). For autofill behavior, use `Modifier.autofill()` with `AutofillType.Password` or `AutofillType.EmailAddress` where applicable; Compose handles autofill integration with Android autofill service automatically. Differs from web by not requiring manual autofill blocking logic.
- **AppKit / UIKit**: For macOS (AppKit), use `NSTextField` with custom cell styling to apply M3 token colors and rounded borders. For iOS (UIKit), use `UITextField` with `UITextFieldDelegate` for focus handling and custom `UIView` subclass for border/background styling to match M3 tokens. Implement focus state via `UITextFieldDelegate.textFieldDidBeginEditing()` to apply gold border. iOS handles password autofill natively via `textContentType` property — no manual autofill prevention needed.
- **WinUI 3**: Start from `TextBox` control in the `Microsoft.UI.Xaml.Controls` namespace. Apply M3 token colors via `Foreground`, `Background`, and `BorderBrush` properties. Implement focus state using `PointerEntered` and `GotFocus` events to apply gold border and ring (via `BorderBrush` and `BorderThickness`). Use `AutomationProperties.Name` for accessibility labeling. For disabled state, set `IsEnabled="false"`. WinUI does not have direct autofill prevention equivalent to web; rely on field context and form validation to manage input restrictions. The `CornerRadius` property applies corner rounding (set to 8px to match web).

## Design Decisions

1. **Autofill prevention via destructuring and spread**: The component destructures `autoComplete` to prevent it from being overwritten by the spread operator when an undefined value is explicitly passed. This ensures that `noAutofillPropsFor(autoComplete)` returns the prevention attributes cleanly without conflict. This approach is more explicit and safer than conditional logic, as it handles the edge case where a caller explicitly passes `autoComplete={undefined}` versus omitting it entirely.

2. **Shared fieldShellClass constant**: The component uses a shared `fieldShellClass` constant (border, rounded corners, background) that is also used by sibling field components (Textarea, Select, Card). This ensures visual consistency across all field-shaped controls and centralizes styling maintenance. A change to the field shell appearance updates all consuming components automatically.

3. **M3 token theming via utility classes**: The component uses `apt-*` Tailwind utility classes that are mapped to Material Design 3 role variables injected by `<AdhThemeStyle/>`. This design allows light/dark theme adaptation and token updates without changing component code, and aligns with the Material Design 3 system's color role-based approach.

4. **min-w-0 for flex/grid overflow prevention**: The component uses `min-w-0` to override the default `min-width: auto` in flex/grid contexts. Without this, long text or wide content would overflow the container. This is a necessary constraint for predictable layout behavior in complex forms.

5. **Focus ring with dual indicator (border + ring)**: The component applies both a border color change and a ring shadow on focus-visible state. This dual indicator serves multiple purposes: it is redundant (focus visible even without color), it provides visual depth (ring shadow), and it meets higher accessibility standards for users with color vision deficiency.

## Compliance

Not applicable: Compliance checks are determined at the application level, not defined in the component source.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.1.0 | 2026-09-22 | Mike Fullerton | Remove review marker from Compliance section; replace with concrete "Not applicable" statement |
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
