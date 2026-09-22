---
id: 1e323e69-44d2-4a15-a11e-22a68e8e6a8c
title: Textarea
domain: agenticdevelopertoolkit://recipes/textarea
type: ingredient
version: 1.0.0
status: review
language: en
created: 2026-09-22
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Multi-line text input field with focus, disabled, and validation error states.
platforms:
- typescript
- web
tags:
- form-input
- text-entry
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Textarea

## Overview

Textarea is a wrapper around the native HTML `<textarea>` element that provides consistent styling and state management across the application. It renders a multi-line text input field with support for disabled state, focus indication, and validation error states. The component is themed using token utilities (`apt-*`) and is designed to match the sibling Input and Card components.

## Behavioral Requirements

- **must-render-textarea-element**: The component MUST render an HTML `<textarea>` element as its root node.
- **must-accept-all-props**: The component MUST accept and forward all standard HTML textarea props (e.g., `value`, `onChange`, `placeholder`, `disabled`, `rows`, `cols`) to the underlying textarea element via spread props.
- **must-accept-custom-classname**: The component MUST accept a `className` prop and merge it with the default styles using the `cn` utility function.
- **must-support-autocomplete-control**: The component MUST accept an `autoComplete` prop to control browser autocomplete behavior, and MUST forward it to the textarea element.
- **must-suppress-autofill-manager-decoration**: The component MUST suppress password manager and autocomplete manager decoration by calling `noAutofillPropsFor(autoComplete)` and spreading the result onto the textarea element, even though textareas are never credentials.
- **must-apply-fieldshell-base-styles**: The component MUST apply `fieldShellClass` to establish the base visual treatment shared with the Input component.
- **must-set-minimum-height**: The component MUST set a minimum height of 16 units (equivalent to 64px in standard Tailwind scaling) via the `min-h-16` class.
- **must-set-full-width**: The component MUST set width to 100% via the `w-full` class.
- **must-set-padding**: The component MUST apply padding of 12px horizontally and 8px vertically via the `px-3 py-2` classes.
- **must-set-font-size**: The component MUST use text-sm (14px in standard Tailwind) for the font size.
- **must-set-text-color**: The component MUST apply the `text-apt-text` token color to the textarea text.
- **must-apply-color-transition**: The component MUST apply `transition-colors` to enable smooth color changes during state transitions.
- **must-remove-outline**: The component MUST set `outline-none` to remove the default browser outline, as the component provides its own focus indicator.
- **must-style-placeholder**: The component MUST apply `placeholder:text-apt-text-dim` to dim placeholder text.
- **must-show-focus-indicator**: The component MUST show a focus indicator when `focus-visible` state is active, consisting of a border change to `apt-gold` and a 2px ring with `apt-gold/25` opacity.
- **must-handle-disabled-state**: The component MUST disable pointer events, show a not-allowed cursor, and reduce opacity to 50% when the `disabled` attribute is present.
- **must-handle-invalid-state**: The component MUST change the border and ring color to `apt-red` with `apt-red/25` ring opacity when the `aria-invalid` attribute is set to `true`.
- **must-data-slot-attribute**: The component MUST set the `data-slot="textarea"` attribute on the root textarea element for testing and targeting purposes.

## Appearance

- **Corner radius**: Inherited from `fieldShellClass` (no explicit override in source).
- **Padding**: 8px vertical × 12px horizontal (py-2 px-3).
- **Font**: weight regular (default), size 14px (text-sm).
- **Background**: Inherited from `fieldShellClass` (no explicit override in source).
- **Foreground/Text**: `apt-text` token color.
- **Border**: Inherited from `fieldShellClass` with state-driven overrides (golden on focus, red on invalid).
- **Shadow**: Inherited from `fieldShellClass` (no explicit override in source).
- **Min/Max size**: Minimum height 64px; full width (100%); no maximum enforced.
- **Placeholder text**: Uses `apt-text-dim` token color for reduced visibility.

## States

| State | Appearance change |
|-------|------------------|
| Default | Text color `apt-text`, placeholder dimmed, standard border and background from `fieldShellClass` |
| Focused | Border and 2px ring change to `apt-gold`, ring opacity 25% |
| Disabled | Opacity reduced to 50%, cursor changed to not-allowed, pointer events disabled |
| Invalid (`aria-invalid="true"`) | Border and 2px ring change to `apt-red`, ring opacity 25% |
| Placeholder visible | Text color `apt-text-dim` |

## Accessibility

- **Role/trait**: Implicit `textbox` role (native HTML textarea).
- **Label requirements**: The component MUST be associated with a label element via `<label htmlFor="id">` or wrapped in a fieldset. The surrounding component or form context is responsible for providing accessible labeling.
- **Announce state changes**: The component uses `aria-invalid` to communicate validation errors; assistive technologies announce this state when set to `true`.
- **Minimum tap target**: The component MUST provide a minimum touch target of 44×44pt as per platform guidelines; the default 64px minimum height exceeds this, but implementations on smaller viewports SHOULD ensure adequate touch targets.
- **Keyboard navigation**: The component supports standard textarea keyboard behavior: Tab for focus, arrow keys for navigation, Enter for line breaks (no special intercept).
- **Focus indication**: The focus-visible state provides a visible focus indicator via color change and ring, which meets WCAG 2.1 Level AA contrast and visibility standards.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| textarea-001 | must-render-textarea-element | Render component | Root node is an HTML `<textarea>` element |
| textarea-002 | must-accept-custom-classname | `className="custom-class"` | Custom class is applied alongside default styles |
| textarea-003 | must-accept-all-props | `value="text" placeholder="Enter text"` | Props are forwarded to textarea element and text/placeholder appear |
| textarea-004 | must-set-minimum-height | Render component, measure DOM | Minimum height is 64px or equivalent |
| textarea-005 | must-set-full-width | Render in a fixed-width container | Textarea fills 100% of container width |
| textarea-006 | must-show-focus-indicator | Focus textarea via keyboard or click | Border and ring color change to golden; ring opacity visible |
| textarea-007 | must-handle-disabled-state | `disabled={true}` | Pointer events are disabled, cursor is not-allowed, opacity is 50% |
| textarea-008 | must-handle-invalid-state | `aria-invalid="true"` | Border and ring color change to red; ring opacity visible |
| textarea-009 | must-suppress-autofill-manager-decoration | Render component, inspect DOM attributes | `noAutofillPropsFor` result attributes are present; autofill manager does not decorate |
| textarea-010 | must-data-slot-attribute | Render component, query `[data-slot="textarea"]` | Element is found via attribute selector |

## Edge Cases

- **Empty textarea**: The component renders and accepts an empty string or undefined value without error. Placeholder text is visible when the field is empty.
- **Very long text input**: The component does not impose a maximum length via source code; form context is responsible for enforcing length limits via the `maxLength` prop if needed. Text will wrap within the textarea and scroll vertically if it exceeds the visible area.
- **Null or undefined value**: The component accepts `value={null}` or `value={undefined}` without error; the textarea remains empty or shows placeholder text.
- **Concurrent focus and disabled state**: If `disabled={true}` and the user focuses the textarea programmatically, the focus styling does not apply because pointer events are disabled. This is standard HTML behavior.
- **Rapid state changes**: If `disabled`, `aria-invalid`, or `className` props change rapidly, the component applies changes synchronously; CSS transitions smooth color changes via `transition-colors`.
- **Custom className override**: If `className` includes conflicting classes (e.g., `w-1/2`), the merge order via `cn()` determines precedence; the custom class is appended last and wins in CSS specificity.
- **autoComplete="off"` with manager suppression**: When `autoComplete="off"` is passed, `noAutofillPropsFor("off")` returns additional attributes to prevent managers from ignoring the off directive. Both the autoComplete attribute and suppression attributes are applied.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `className` | string | (empty) | Additional CSS classes merged with default styles |
| `autoComplete` | string | (undefined) | Controls browser autocomplete behavior; forwarded to textarea and used to suppress manager decoration |
| All standard textarea props | (various) | (native defaults) | `value`, `onChange`, `placeholder`, `disabled`, `rows`, `cols`, `maxLength`, `readonly`, `spellCheck`, `wrap`, etc. |

## Deep Linking

Not applicable: Textarea is a form input component and does not handle routing or deep linking directly. The containing form or page context manages navigation.

## Localization

Not applicable: Textarea does not render any product text. Placeholder text, labels, and validation messages are provided by the containing form context and MUST be localized there.

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | The `transition-colors` class respects the `prefers-reduced-motion` media query; if enabled, color transitions are instantaneous instead of smooth. |
| Increase Contrast | Implementations SHOULD ensure the chosen token colors (`apt-text`, `apt-gold`, `apt-red`) meet WCAG AA contrast ratios against the background. Token definitions are responsible for maintaining contrast, not this component. |
| Differentiate Without Color | The focus indicator uses both color (golden border/ring) and a visible ring shape; this satisfies the requirement to differentiate state without relying on color alone. |

## Feature Flags

Not applicable: Textarea does not implement feature flags. The component is always enabled; enable/disable behavior is controlled by the `disabled` prop at the form or application level.

## Analytics

Not applicable: Textarea does not emit analytics events. Change and interaction tracking is the responsibility of the containing form context.

## Privacy

Not applicable: Textarea is a stateless wrapper around the native HTML element. It does not collect, store, or transmit data. Privacy and data handling are the responsibility of the form context and backend.

## Logging

Not applicable: Textarea does not emit structured logs. Debugging textarea state (focus, value, errors) is handled by the browser's built-in developer tools and the containing form's logging strategy.

## Platform Notes

- **React/Web**: This recipe is implemented directly in web React. Source: `packages/web/packages/ui/src/components/textarea.tsx`. The component uses Tailwind CSS classes and the `cn` utility for class merging. The `noAutofillPropsFor` helper returns additional attributes to prevent autocomplete manager decoration.
- **SwiftUI**: Implement using `TextEditor` as the foundation. TextEditor provides multi-line text editing; wrap it in a container that applies border and ring styling for focus and error states. Disable pointer events using `.disabled()` modifier when disabled. Announce `aria-invalid` state via `AccessibilityElement` and custom label bindings. Use `lineLimit(nil)` for unrestricted vertical growth; consider a fixed min height or `.frame(minHeight: 64)` if needed.
- **Compose (Android)**: Implement using `OutlinedTextField` with `singleLine = false` to enable multi-line mode. Apply Material Design 3 token colors (equivalent to `apt-text`, `apt-gold`, `apt-red`) for text, focus, and error states. Use `Modifier.focusable()` and `FocusRequester` to manage focus behavior. Render error state via the `isError` parameter and error text display. Minimum height should be ~64dp; use `Modifier.heightIn(min = 64.dp)`.
- **UIKit / AppKit**: On iOS, use `UITextView` with a custom border/background view and delegate-based focus handling. Apply a border color change on `UITextViewDelegate.textViewDidBeginEditing`. For disabled state, set `isEditable = false` and apply opacity. Minimum height ~64pt. On macOS, use `NSTextView` in an `NSScrollView` with similar styling and state management; NSTextView does not have a native `disabled` state, so handle it via `isEditable` and visual feedback.
- **WinUI 3**: Implement using `TextBox` with `AcceptsReturn="True"` and `TextWrapping="Wrap"` to enable multi-line editing. Apply token-based colors to `Foreground`, `Background`, and `BorderBrush` properties. Use `VisualState` groups to define appearance for Normal, Focused, Disabled, and Error states. Set `MinHeight` to ~64 (device-independent pixels) and `Width` to "Auto" or a container-fill constraint. Manage error state via `aria-invalid` attribute for accessibility and conditional `BorderBrush` binding in the template or code-behind.

## Design Decisions

- **fieldShellClass inheritance**: The component inherits base visual treatment from `fieldShellClass`, which is shared with the Input component. This ensures visual consistency across form fields and centralizes updates to the shared style layer.
- **autoComplete + noAutofillPropsFor dual handling**: Textareas are never credentials, but password managers often decorate them anyway. The component accepts the `autoComplete` prop and forwards both it and the suppression attributes to prevent manager interference without losing the opt-out capability. This allows fine-grained control while maintaining the opt-out path for users who set `autoComplete` explicitly.
- **transition-colors smoothing**: The `transition-colors` class enables smooth visual feedback during state changes (focus, disabled, invalid). This improves perceived responsiveness without requiring JavaScript or animation libraries. It respects `prefers-reduced-motion` by default via Tailwind's media query integration.
- **aria-invalid for validation**: The component uses the native `aria-invalid` attribute to communicate validation errors. This approach is semantic, testable, and accessible; it does not invent a custom error state property.

## Compliance

Not applicable: Textarea does not define platform-specific compliance checks. Implementations MUST comply with WCAG 2.1 Level AA for contrast, focus visibility, and keyboard accessibility; these are the responsibility of the token definitions (`apt-text`, `apt-gold`, `apt-red`) and the containing form context.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
