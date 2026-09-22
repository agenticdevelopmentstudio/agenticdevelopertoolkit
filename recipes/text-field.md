---
id: dc548100-af44-4d93-9cb9-93c35546e08c
title: Text Field
domain: agenticdevelopercookbook://ingredients/text-field
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Single-line and multi-line text input field with label, hint, and autofill
  support.
platforms:
- web
tags:
- form
- input
depends-on: []
related: []
references: []
---

# Text Field

## Overview

A text input field component for web that supports single-line text input, multi-line textarea, labels, helper text (hints), and configurable autofill behavior. The component wraps native HTML `<input>` and `<textarea>` elements and manages their interaction with browser autofill mechanisms. Two variants are provided: `TextField` for general text input and `SecureTextField` for password and sensitive token storage.

## Behavioral Requirements

- **must-render-input-element**: The component MUST render either an HTML `<input>` element (when `multiline` is `false` or omitted) or an HTML `<textarea>` element (when `multiline` is `true`).
- **must-bind-value**: The component MUST bind the `value` prop to the input element's `value` attribute and reflect all changes back through the `onChange` callback.
- **must-call-on-change**: The component MUST invoke the `onChange` callback with the current input value (string) whenever the user types into the field.
- **must-render-label**: When a `label` prop is provided, the component MUST render an HTML `<label>` element with `htmlFor` attribute matching the input element's `id`.
- **must-generate-id**: When no `id` prop is supplied, the component MUST generate a unique ID using React's `useId` hook and apply it to the input element.
- **must-accept-placeholder**: The component MUST pass the `placeholder` prop to the input element.
- **must-respect-disabled**: The component MUST apply the `disabled` attribute to the input element when the `disabled` prop is `true`.
- **must-render-hint**: When a `hint` prop is provided, the component MUST render a `<p>` element containing the hint text after the input element.
- **must-apply-classname**: The component MUST accept a `className` prop and append it to its root element's class list.
- **must-support-text-types**: The `TextField` component MUST support `type` values of `'text'`, `'email'`, `'url'`, and `'tel'`, with `'text'` as the default.
- **must-handle-multiline**: When `multiline` is `true`, the component MUST render a `<textarea>` element with `rows="4"` instead of an `<input>` element.
- **must-apply-autofill-token**: When the `autoComplete` prop is a valid autofill token (e.g., `'email'`, `'tel'`, `'url'`, `'name'`), the component MUST pass it to the input element's `autoComplete` attribute and MUST NOT apply autofill prevention attributes.
- **must-prevent-autofill-default**: When `autoComplete` is `undefined` or `'off'`, the component MUST apply autofill prevention attributes via the `noAutofillPropsFor` helper.
- **must-always-prevent-password-manager**: The `SecureTextField` component MUST always apply autofill prevention attributes via `noAutofillProps` and MUST NOT accept an `autoComplete` prop.
- **must-mask-password-input**: The `SecureTextField` component MUST render an `<input type="password">` to visually mask the input value on screen.
- **must-apply-semantic-css-classes**: The component MUST apply CSS classes to structure the component: `'aws-field'` on the root, `'aws-field--text'` for both variants, `'aws-field--secure'` additionally for `SecureTextField`, `'aws-field__label'` on the label, `'aws-field__input'` and `'aws-field__textarea'` on input/textarea respectively, and `'aws-field__hint'` on the hint paragraph.

## Appearance

- **Corner radius**: Defined by CSS class `.aws-field__input` (not specified in component source; styling via external stylesheet).
- **Padding**: Defined by CSS classes; vertical and horizontal padding applied via `.aws-field__input` and `.aws-field__textarea`.
- **Font**: Inherited from parent or defined by CSS class `.aws-field__input`; no font properties directly set in component.
- **Background**: Defined by CSS class `.aws-field__input`; component does not set inline background styles.
- **Foreground/Text**: Inherited from parent or defined by CSS class `.aws-field__input`.
- **Border**: Defined by CSS class `.aws-field__input`; component does not set inline border styles.
- **Shadow**: Not applicable; the component does not apply shadow effects.
- **Min/Max size**: Textarea uses fixed `rows={4}`; no explicit width constraints set in component.

## States

| State | Appearance change |
|-------|------------------|
| Default | Input or textarea rendered normally with base styling applied via `.aws-field__input` or `.aws-field__textarea`. |
| Disabled | `disabled` attribute applied to input/textarea; disabled state styling is defined by `.aws-field__input[disabled]` CSS rule. |
| Focused | Focus styling is defined by CSS class `.aws-field__input:focus` or similar focus state selectors; component does not apply inline focus styles. |
| Placeholder visible | When `placeholder` prop is provided and input is empty, browser renders the placeholder text. |
| With label | When `label` prop is provided, a `<label>` element is rendered above the input. |
| With hint | When `hint` prop is provided, hint text is rendered below the input in a `<p>` element. |
| Multiline | Textarea element with `rows={4}` rendered instead of input element when `multiline` is `true`. |
| SecureTextField | Additional `'aws-field--secure'` class applied; input type is always `'password'`; autofill always prevented. |

## Accessibility

- **Role/Trait**: The component renders a native HTML `<input>` or `<textarea>` element, which have implicit `textbox` role. When a `<label>` is present, it is associated via `htmlFor` attribute matching the input's `id`.
- **Label requirements**: A `label` prop MAY be provided and is rendered as a `<label>` element associated to the input via `htmlFor`. No label is rendered if the `label` prop is omitted or falsy; callers MUST provide an accessible label via other means (e.g., `aria-label`, `aria-labelledby`).
- **Announce state changes**: The `disabled` state is communicated to assistive technologies via the `disabled` attribute on the input element; no additional ARIA attributes are set by the component.
- **Minimum tap target**: Target size is defined by CSS; component does not enforce a minimum size. Per WCAG 2.1, interactive targets SHOULD be at least 44×44px; CSS styling MUST ensure this.
- **Hint association**: Hint text is rendered in a `<p>` element but is not explicitly associated to the input via `aria-describedby`. Callers requiring explicit association MUST implement this themselves.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| text-field-001 | must-render-input-element, must-bind-value, must-call-on-change | `<TextField value="hello" onChange={...} multiline={false} />` | Component renders an `<input>` element with `value="hello"`. |
| text-field-002 | must-call-on-change | User types "world" into the input. | `onChange` callback is invoked with `"helloworld"` as the argument. |
| text-field-003 | must-render-label, must-generate-id | `<TextField label="Name" value="" onChange={...} />` | Component renders `<label htmlFor="[generated-id]">Name</label>` and `<input id="[generated-id]" />`. |
| text-field-004 | must-accept-placeholder | `<TextField placeholder="Enter text" value="" onChange={...} />` | Component renders `<input placeholder="Enter text" />`. |
| text-field-005 | must-respect-disabled | `<TextField value="" onChange={...} disabled={true} />` | Component renders `<input disabled />`. |
| text-field-006 | must-render-hint | `<TextField value="" onChange={...} hint="Helper text" />` | Component renders `<p>Helper text</p>` after the input. |
| text-field-007 | must-handle-multiline | `<TextField value="" onChange={...} multiline={true} />` | Component renders `<textarea rows={4} />` instead of `<input />`. |
| text-field-008 | must-support-text-types | `<TextField value="" onChange={...} type="email" />` | Component renders `<input type="email" />`. |
| text-field-009 | must-handle-autofill-token | `<TextField value="" onChange={...} autoComplete="email" />` | Component renders `<input autoComplete="email" />` without autofill prevention attributes. |
| text-field-010 | must-prevent-autofill-default | `<TextField value="" onChange={...} />` (no autoComplete) | Component applies autofill prevention attributes via `noAutofillPropsFor()`. |
| text-field-011 | must-always-prevent-password-manager | `<SecureTextField value="" onChange={...} />` | Component renders `<input type="password" />` with autofill prevention attributes applied. |
| text-field-012 | must-apply-semantic-css-classes | `<TextField value="" onChange={...} />` | Component renders with classes: `aws-field aws-field--text aws-field__input`. |
| text-field-013 | must-apply-semantic-css-classes | `<SecureTextField value="" onChange={...} />` | Component renders with classes: `aws-field aws-field--text aws-field--secure aws-field__input`. |
| text-field-014 | must-apply-classname | `<TextField value="" onChange={...} className="custom" />` | Component root element includes `custom` in its class list. |

## Edge Cases

- **Empty string input**: When `value` is an empty string, the component MUST render the input element with an empty value and display any provided `placeholder` text.
- **Null or undefined label**: When `label` is `null`, `undefined`, or falsy, no `<label>` element is rendered.
- **Null or undefined hint**: When `hint` is `null`, `undefined`, or falsy, no hint `<p>` element is rendered.
- **Large text input**: When `value` contains many characters (e.g., >10,000), the component MUST display all of them without truncation; overflow behavior (scrolling, wrapping) is controlled by CSS.
- **Multiline with many rows**: When `multiline` is `true` and `value` contains many lines, the textarea MUST display all lines; it has a fixed `rows={4}` and SHOULD scroll vertically if content exceeds visible height (CSS-controlled).
- **Rapid onChange calls**: When the user types quickly, `onChange` callbacks MUST be invoked in sequence for each keystroke; no debouncing or throttling is performed by the component.
- **Disabled input interaction**: When `disabled` is `true`, user interactions (typing, focus) with the input MUST be blocked by the browser's native input element behavior.
- **AutoComplete and password fields**: SecureTextField MUST always prevent autofill to avoid password managers saving API keys or tokens as the site password; this behavior is not configurable.
- **ID collision with external labels**: When an external `<label>` exists with the same `htmlFor` as the generated or provided `id`, both labels will reference the same input; callers MUST avoid duplicate labels.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `label` | `ReactNode` | `undefined` | Optional label text or node displayed above the input. |
| `hint` | `ReactNode` | `undefined` | Optional helper text or node displayed below the input. |
| `value` | `string` | (required) | Current text value; controlled by caller. |
| `onChange` | `(value: string) => void` | (required) | Callback invoked when input value changes. |
| `placeholder` | `string` | `undefined` | Placeholder text shown when input is empty. |
| `multiline` | `boolean` | `false` | When `true`, renders a `<textarea>` instead of `<input>`. |
| `disabled` | `boolean` | `false` | When `true`, input is disabled and user cannot interact with it. |
| `className` | `string` | `undefined` | Optional CSS class name(s) to append to root element. |
| `id` | `string` | (auto-generated) | Optional ID for the input element; generated via `useId()` if omitted. |
| `type` (TextField only) | `'text' \| 'email' \| 'url' \| 'tel'` | `'text'` | Input type for single-line TextField. |
| `autoComplete` (TextField only) | `string` | `undefined` | Autofill token (e.g., `'email'`, `'tel'`) to enable password manager integration; omit or use `'off'` to prevent autofill. |

## Deep Linking

Not applicable: This is a foundational form component without its own deep link targets. Deep linking is handled by the page or view that embeds this component.

## Localization

Not applicable: The component renders user-provided `label` and `hint` content; localization of these strings is the caller's responsibility. The component itself contains no hard-coded user-facing strings.

## Accessibility Options

Not applicable: The component does not directly respond to platform accessibility display options (reduce motion, increase contrast, differentiate without color). These are handled by the CSS styling layer (`.aws-field__input` class) and the browser's native input element behavior.

## Feature Flags

Not applicable: The component does not check or respond to feature flags. Feature-flagging of this component, if needed, is handled by the caller.

## Analytics

Not applicable: The component does not emit analytics events. Callers are responsible for instrumenting user interactions (focus, blur, input) if analytics are needed.

## Privacy

Not applicable: TextField is a generic form input that does not collect, store, or transmit data on its own. Callers using this component for sensitive data (passwords, API keys, personal information) are responsible for secure handling, transmission, and storage per their privacy and security requirements.

## Logging

Not applicable: The component does not emit diagnostic logs. Logging of user input or field state, if needed, is the caller's responsibility.

## Platform Notes

- **Web (React)**: Implemented in TypeScript/React; exports `TextField` (text input with configurable type) and `SecureTextField` (password-masked input). Uses React's `useId` hook for ID generation, semantic HTML (native `<input>` and `<textarea>`), and CSS class-based styling. Autofill handling via `noAutofillProps` and `noAutofillPropsFor` helpers to control browser behavior.
- **SwiftUI**: Start from `TextField` or `SecureField` in SwiftUI. TextField supports standard modifiers (`.disabled()`, `.onChange()`, `.placeholder()`). SecureField provides password masking. Apply equivalent CSS class names via modifiers or environment values. Implement `@FocusState` to manage focus state analogous to `:focus` CSS. Handle autofill via iOS keyboard type and secure text entry attributes.
- **Compose (Android)**: Use `BasicTextField` or `OutlinedTextField` from Compose Material 3. Provide label, hint (helper text), input type, and keyboard configuration via `keyboardOptions`. Apply disabled state via `enabled` parameter. Handle input changes via `onValueChange` callback. Implement autofill via `keyboardOptions.keyboardType` and IME hints (e.g., `KeyboardType.Email`, `KeyboardType.Password`). Compose automatically manages touch target sizes per Material 3.
- **AppKit / UIKit**: Start from `NSTextField` (macOS) or `UITextField` (iOS). Apply label and hint via adjacent UI elements (NSTextView/UILabel for hints). Use `NSTextView` for multiline (AppKit) or `UITextView` for iOS multiline. Implement autofill via `textContentType` property (`UITextContentType.emailAddress`, `.telephoneNumber`, `.password`). Bind value via target-action or KVO. Apply disabled state via `isEditable = false` and `isSelectable = false`. Handle styling via `font`, `backgroundColor`, `textColor` properties.
- **WinUI 3**: Use `TextBox` control from WinUI 3 for single-line input and `TextBox` with `AcceptsReturn="true"` and `TextWrapping="Wrap"` for multiline. Set `Header` property for labels and `PlaceholderText` for placeholder. Bind `Text` property to view model via two-way binding. Implement disable state via `IsEnabled` property. Handle input changes via `TextChanged` event or `Text` property binding. Use `InputScope` enum (`Email`, `TelephoneNumber`, `Url`) to hint at input type for software keyboard on touch devices. Apply CSS class equivalents via `Margin`, `Padding`, `BorderBrush`, `BorderThickness`, and `CornerRadius` properties.

## Design Decisions

- **Controlled Component**: TextField is a fully controlled component; the caller MUST manage the `value` state and invoke `onChange` to update it. This pattern requires more boilerplate but provides explicit control and integrates cleanly with form libraries and state management.
- **Auto-generated IDs**: When no `id` is provided, React's `useId` hook generates a unique ID per render. This ensures label-input association works without caller intervention, but generated IDs are not stable across server and client renders (relevant only in SSR contexts).
- **Autofill Handling**: The component uses a helper function (`noAutofillPropsFor`) to conditionally apply autofill-prevention attributes. This preserves password manager integration when a valid autofill token is passed but prevents unwanted autofill in generic search or filter fields. This requires careful naming of the `autoComplete` prop to be meaningful to the caller.
- **SecureTextField Non-Configurable**: SecureTextField does not accept an `autoComplete` prop because password managers should never save settings secrets (API keys, tokens) as the website's password. The `type="password"` and autofill prevention are always applied; this is a security-first design decision.
- **Multiline via Boolean**: The component uses a boolean `multiline` prop rather than a separate `TextArea` component. This reduces component count and makes the two variants feel like a single configurable entity, though it does add a branching render path.
- **Fixed Textarea Rows**: When multiline is true, the textarea has a hardcoded `rows={4}`. This provides a reasonable default but may not suit all use cases; callers can override via CSS (setting `height` property).
- **Hint as Unassociated Text**: The hint is rendered as a plain `<p>` element without explicit ARIA association (e.g., `aria-describedby`). Callers MUST add this association if the hint is critical to understanding the input's purpose for users of assistive technologies.

## Compliance

Not applicable: Compliance checks (WCAG, HIPAA, GDPR, etc.) are determined by the context in which the component is used, not by the component itself. Callers are responsible for ensuring the component's use complies with applicable regulations and standards.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation from web source. |
