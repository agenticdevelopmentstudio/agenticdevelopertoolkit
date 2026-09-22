---
id: c9e70ad4-89c9-4c44-a2d6-a64da32a64af
title: Error Text
domain: agenticdevelopertoolkit://recipes/error-text
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Canonical inline error display component for validation and alert messages
platforms:
- typescript
- web
tags:
- error-text
- alerts
- form-validation
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Error Text

## Overview

Error Text is the single, canonical component for displaying inline error messages and validation failures across all surfaces in the web platform. Every validation message, form error, and thrown message renders using this component to ensure consistent styling, accessibility, and behavior. The component conditionally renders only when an error is present. Two variants are provided: `ErrorText` renders as a paragraph for most contexts, and `DialogErrorText` renders as a block-displayed span for use inside dialog descriptions where paragraph nesting is not permitted.

## Behavioral Requirements

- **must-render-when-error-present**: The component MUST render an element with `role="alert"` when the `error` prop is a non-empty string.
- **must-not-render-when-error-absent**: The component MUST return `null` and render nothing when the `error` prop is `null`, `undefined`, or an empty string.
- **must-set-alert-role**: The component MUST set `role="alert"` on the rendered element to signal to assistive technologies that the content is a time-sensitive alert or error message.
- **must-include-error-text-content**: The component MUST render the exact text from the `error` prop as the element's text content.
- **must-apply-error-color-and-size**: The component MUST apply both `text-sm` (14px) and `text-apt-red` (error red color token) classes to the rendered element.
- **must-support-className-prop**: The component MUST accept an optional `className` prop and merge it with the default classes using the `cn()` utility function.
- **error-text-must-render-as-paragraph**: The `ErrorText` variant MUST render the alert as a `<p>` element.
- **dialog-error-text-must-render-as-span**: The `DialogErrorText` variant MUST render the alert as a `<span>` element with `block` display class to create a line-break effect without nesting `<p>` inside `<p>`.
- **dialog-error-text-must-apply-top-margin**: The `DialogErrorText` variant MUST apply the `mt-2` (top margin) class to provide vertical spacing from the dialog description text.
- **dialog-error-text-must-match-treatment**: The `DialogErrorText` variant MUST use the same `text-sm` text size and `text-apt-red` color classes as the standard `ErrorText` variant to ensure visual consistency across all error displays.

## Appearance

- **Element Type**: `ErrorText` renders as `<p>`; `DialogErrorText` renders as `<span class="block">`
- **Text Size**: `text-sm` (14px or equivalent per Tailwind design system)
- **Text Color**: `text-apt-red` (error color token from design system)
- **Spacing**: No padding applied by component. `DialogErrorText` applies `mt-2` (top margin). Outer spacing is controlled by the caller via the `className` prop.
- **Display**: `block` display applied only to `DialogErrorText`; `ErrorText` uses default paragraph block behavior
- **Font Weight**: Inherits from system (not specified)
- **Line Height**: Inherits from system (not specified)
- **Background**: Transparent
- **Border**: None
- **Shadow**: None

## States

Not applicable: Error Text is a static, non-interactive display element with no internal state management. It renders when an error is present and returns null when absent; there are no pressed, focused, loading, or disabled states.

## Accessibility

- **Role**: The component sets `role="alert"` to signal to screen readers that the content is an alert or error message that requires immediate attention.
- **Text Content as Label**: The error message itself is the accessible label; no additional `aria-label` or `aria-labelledby` is required because the text is visible and announced.
- **Screen Reader Announcement**: When an error appears, screen readers announce it as an alert. When the error is dismissed (component returns null), the text is no longer present in the DOM.
- **Keyboard Interaction**: Error Text is not keyboard-interactive; it is a passive text display. Focus management and form submission behavior are the responsibility of the containing form or surface.
- **Color and Meaning**: The message is communicated both by the red color (`text-apt-red`) and the text content. The text content provides a redundant signal for users with color vision deficiency and ensures the message is not color-dependent.

## Conformance Test Vectors

| ID | Requirements | Input | Action | Expected |
|----|-------------|-------|--------|----------|
| error-text-001 | must-render-when-error-present, error-text-must-render-as-paragraph | `error="Username is required"`, variant: `ErrorText` | Render component | A `<p role="alert">` element appears with text "Username is required" |
| error-text-002 | must-not-render-when-error-absent | `error={null}` | Render component | Component returns `null`; no element is rendered |
| error-text-003 | must-not-render-when-error-absent | `error={undefined}` | Render component | Component returns `null`; no element is rendered |
| error-text-004 | must-not-render-when-error-absent | `error=""` | Render component | Component returns `null`; no element is rendered |
| error-text-005 | must-include-error-text-content | `error="Invalid email format"` | Render component; inspect text | Text content of the element is exactly "Invalid email format" |
| error-text-006 | must-apply-error-color-and-size | `error="Error message"` | Render component; inspect classList | The element includes both `text-sm` and `text-apt-red` classes in its class attribute |
| error-text-007 | must-set-alert-role | `error="Error"` | Render component; inspect attributes | The element has `role="alert"` attribute |
| error-text-008 | must-support-className-prop | `error="Error"`, `className="px-4"` | Render component; inspect classList | The element includes `px-4` in its class attribute, merged with the default classes via `cn()` |
| error-text-009 | dialog-error-text-must-render-as-span | `error="Error"`, variant: `DialogErrorText` | Render component; inspect element type | A `<span>` element is rendered, not `<p>` |
| error-text-010 | dialog-error-text-must-apply-top-margin, dialog-error-text-must-match-treatment | `error="Error"`, variant: `DialogErrorText` | Render component; inspect classList | The span includes `mt-2`, `block`, `text-sm`, and `text-apt-red` classes |
| error-text-011 | must-not-render-when-error-absent | `error={null}`, variant: `DialogErrorText` | Render component | Component returns `null`; no element is rendered |

## Edge Cases

- **Null or undefined error**: When `error` is `null` or `undefined`, the component returns `null` and renders nothing. No error is thrown. (MUST)
- **Empty string error**: When `error` is an empty string (`""`), the component returns `null` because empty string is falsy in JavaScript. This prevents rendering an empty, invisible alert element. (MUST)
- **Whitespace-only error**: If `error` is a string containing only whitespace (e.g., `" "` or `"\n"`), the component renders the whitespace as text content. Callers SHOULD trim error messages at the call site to avoid empty-appearing alerts; this is a data validation issue, not a component issue. (SHOULD)
- **Very long error text**: The component renders the full error text without truncation. Text wrapping and overflow are determined by the container's CSS and dimensions, which the caller controls. (MUST)
- **HTML markup in error text**: If `error` contains HTML markup (e.g., `<b>error</b>`), the component treats it as literal text, not as HTML, because JSX renders it as text content, not with `dangerouslySetInnerHTML`. Special characters are automatically escaped by React. (MUST)
- **Special characters**: Characters like `&`, `<`, `>`, and `"` are safely rendered because React automatically escapes them in text content. (MUST)
- **className override of text size**: When `className="text-xs"` is passed, the `cn()` utility merges it with default classes. CSS specificity and class ordering determine which size class is applied visually; both classes are present in the DOM. Callers MUST test that the resulting text size is acceptable in their layout. (SHOULD)
- **Paragraph nesting error**: The standard `ErrorText` renders a `<p>` tag. It MUST NOT be used as a child of another `<p>` tag because HTML does not permit nested paragraphs; the browser will auto-close the outer paragraph. Use `DialogErrorText` in dialog descriptions or other `<p>` contexts. (MUST)
- **Zero-width or hidden parent container**: If the parent container has `display: none` or `visibility: hidden`, the error text is not visible. However, it is still present in the DOM and will be announced by screen readers when the container becomes visible, which is correct behavior. (MUST)

## Configuration

Not applicable: Error Text has no configuration options beyond the two required props (`error` and optional `className`). There are no feature flags, toggles, or runtime configuration.

## Deep Linking

Not applicable: Error Text is a display primitive component with no deep linking capability or URL patterns. It is rendered as part of other surfaces.

## Localization

Not applicable: Error Text does not contain any user-facing strings that require localization. The error message text is provided by the caller and is assumed to be already localized at the point of use.

## Accessibility Options

Not applicable: Error Text does not respond to system-level accessibility display options such as Reduce Motion, Increase Contrast, or Differentiate Without Color. It is a static text display that inherits styling from the design system's color and type tokens.

## Feature Flags

Not applicable: Error Text has no feature flags. It is always enabled and available for use in any context.

## Analytics

Not applicable: Error Text does not emit analytics events. It is a passive, stateless display component. Analytics for error frequency, types, and user interactions is the responsibility of the form or surface that produces the error.

## Privacy

Not applicable: Error Text does not collect, store, or transmit data. The error text is provided by the caller and is rendered and destroyed within the component lifecycle; no data is persisted.

## Logging

Not applicable: Error Text does not perform any logging. Diagnostic or debugging logs for errors are the responsibility of the calling code.

## Platform Notes

- **React/Web (TypeScript)**: The source implementation is a React functional component with TypeScript prop types. Uses the `cn()` utility (Clsx-style class merger) to combine Tailwind classes. `ErrorText` renders `<p role="alert">` with classes `text-sm text-apt-red` plus any caller-provided overrides. `DialogErrorText` renders `<span role="alert">` with classes `block mt-2 text-sm text-apt-red` plus overrides. Both return `null` when `error` is falsy. (Files: `packages/web/packages/ui/src/components/error-text.tsx`)
- **SwiftUI (Apple)**: An equivalent component would render a Text view with red color (mapping `text-apt-red` to SwiftUI's Color system). Apply `.accessibilityLabel()` and `.accessibilityAddTraits(.updatesFrequently)` or equivalent semantics to signal an alert. For dialog contexts, consider Text inside a VStack with top padding to mimic the span layout.
- **Compose (Kotlin/Android)**: A Compose equivalent would render a Text composable with red color from the design system palette. Apply `Modifier.semantics { role = Role.Alert }` to set the alert role. For dialog contexts, use Text inside a Column with `Modifier.padding(top = 8.dp)` (or equivalent to `mt-2`) and `Modifier.fillMaxWidth()` for block layout.
- **AppKit / UIKit (Apple)**: On macOS/iOS, render a UILabel or NSTextField with red text color. Set `accessibilityTraits = .updatesFrequently` or use `accessibilityRole` API to signal an alert role to VoiceOver. For dialog contexts, use a UIStackView or NSStackView with appropriate vertical spacing and layout constraints.
- **WinUI 3**: Render a TextBlock with red Foreground color from the design system. Set `AutomationProperties.Name` to the error text and apply `AutomationProperties.AutomationId` for screen reader support. Use `AutomationProperties.LiveSetting = AutomationLiveSetting.Assertive` to signal an alert. For dialog contexts, place the TextBlock in a StackPanel with Margin `0,8,0,0` (top margin equivalent to `mt-2`) and HorizontalAlignment set to `Stretch` for block-like layout.

## Design Decisions

1. **Canonical home for error styling**: Error Text is the single authoritative component for all inline error and validation messages across the platform. Styling (color and text size), the alert role, and the conditional render logic live in exactly one place to prevent drift and ensure consistency. If a surface needs a different visual treatment for errors, that signals a need to review whether Error Text should be extended or whether the surface genuinely requires a different component.

2. **Two variants, one treatment**: `ErrorText` and `DialogErrorText` are visually identical in color and text size (`text-apt-red`, `text-sm`) to preserve consistency across all error displays. The only difference is the element type (`<p>` vs `<span class="block">`) because HTML structure forbids nested paragraphs. This structural difference is a technical constraint, not a design choice.

3. **className allows layout flexibility without compromising treatment**: The `className` prop permits callers to add padding, margin, and adjust text size in dense layouts (e.g., `text-xs` in the DM composer or notification inbox) without requiring a new component variant. The `cn()` utility merges caller classes with defaults, allowing metric overrides while preserving the core color and role that define "error text treatment."

4. **Color and role are non-negotiable**: While technically the `cn()` utility could merge an override of `text-apt-red`, doing so would break the canonical treatment. If a message requires a different color (e.g., yellow for warning, blue for info), that message is not an error and should use a different component. This pattern is enforced by design and documented in Design Decisions, not by code-level constraints.

5. **Null return over empty element**: When no error is present, the component returns `null` rather than rendering an empty, invisible alert element. This reduces DOM noise and prevents screen reader users from encountering empty alerts.

6. **Span variant for dialogs**: HTML 5 forbids nested `<p>` tags; the browser auto-closes an outer paragraph if a `<p>` is started inside it. Dialog descriptions are typically rendered as `<p>` tags (per Base UI convention), so `DialogErrorText` uses a `<span>` with `block` display to maintain the same visual line-by-line layout while respecting HTML structure. The `mt-2` margin provides visual separation from the description.

7. **role="alert" for screen reader announcement**: The `role="alert"` attribute signals to screen readers that the content is time-sensitive and should be announced immediately. In dialogs, this is critical because error text changes dynamically under a focus trap without other visual affordances, and the alert role is the only reliable way to notify screen reader users of the failure.

## Compliance

Not applicable: Error Text is a low-level UI primitive. Compliance with WCAG 2.1 AA and platform-specific accessibility standards is achieved through correct use by the containing form or surface, which MUST ensure proper label association, keyboard navigation, and focus management around the error display.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation from web implementation |
