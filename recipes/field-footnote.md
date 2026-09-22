---
id: e9504a52-046c-4777-9704-20f611cf76f7
title: FieldFootnote
domain: agenticdevelopertoolkit://recipes/field-footnote
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Display line under a form control showing either a validation error or hint
  text, with error taking precedence.
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

# FieldFootnote

## Overview

FieldFootnote is a display component that renders validation feedback or supplemental information below a form control. It occupies a single line in the layout and shows either an error message (when validation fails) or a hint message (when validation passes or no validation has occurred). The component exists independently so that controls which cannot use the standard Field wrapper (such as checkboxes with custom row layouts) can still display feedback in a consistent position using the same styling.

## Behavioral Requirements

- **must-show-error-when-present**: When `error` prop is set to a truthy value, the component MUST render that value in the error presentation (red, monospace, small text).
- **must-prioritize-error-over-hint**: When both `error` and `hint` props are truthy, the component MUST show only the error, not the hint.
- **must-show-hint-when-no-error**: When `error` prop is not set or is falsy, and `hint` prop is truthy, the component MUST render the hint in the hint presentation (dim text, monospace, small text).
- **must-return-null-when-empty**: When both `error` and `hint` props are falsy or undefined, the component MUST return null (render nothing).
- **must-apply-error-id-when-present**: When `errorId` prop is provided, the component MUST apply that value as the `id` attribute on the error span element.
- **must-apply-error-id-only-to-error**: When `errorId` prop is provided, the `id` attribute MUST be applied only to the error span, never to the hint span.
- **must-apply-class-name**: When `className` prop is provided, the component MUST merge it with the default classes using the `cn` utility function (Tailwind class merger).
- **must-support-react-node-content**: The component MUST accept any valid React node (string, number, element, or fragment) in both `hint` and `error` props.

## Appearance

- **Font**: Monospace (FontFamily.Monospace or platform equivalent), size 0.7rem (5.6 points / ~11 twips)
- **Error color**: `text-apt-red` (Tailwind token, typically a red hue used for validation errors)
- **Hint color**: `text-apt-text-dim` (Tailwind token, typically a muted gray used for supporting text)
- **Line height**: Inherits default; no custom line-height specified
- **Padding**: No explicit padding; inherits from ancestor or uses browser default inline span padding (typically zero)
- **Border**: None
- **Shadow**: None
- **Min/Max size**: None; width is determined by content

## States

| State | Appearance change |
|-------|------------------|
| Showing error | Red, monospace, text-[0.7rem] |
| Showing hint | Dim text, monospace, text-[0.7rem] |
| Empty (no error, no hint) | Rendered as null; no DOM element |

## Accessibility

- **Role**: No explicit ARIA role applied. The component is a passive display element and does not interact with the user.
- **Error identification**: The error span carries an optional `id` attribute (via `errorId` prop) so that a form control can reference it with `aria-describedby`, allowing screen readers to announce the error message when the control is focused.
- **Hint handling**: Hints are not assigned an `id` and are not referenced via `aria-describedby`; hints belong in the control's accessible name via the `<Label>` component in the standard Field wrapper.
- **Semantics**: The component uses a generic `<span>` element; no `role="alert"` or `role="status"` is applied. The error line is not automatically announced on appearance; screen readers announce it when the control with `aria-describedby` is focused.
- **Color dependence**: Both error (red) and hint (dim) are distinguished by color. The component assumes sufficient contrast will be provided by the color tokens; it does not add additional visual markers (e.g., icons) to distinguish error from hint.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| field-footnote-001 | must-show-error-when-present | `error="This field is required"`, `hint={undefined}` | Renders `<span id={undefined} class="font-mono text-[0.7rem] text-apt-red">This field is required</span>` |
| field-footnote-002 | must-prioritize-error-over-hint | `error="Error occurred"`, `hint="Hint text"` | Renders error span only; hint is not rendered |
| field-footnote-003 | must-show-hint-when-no-error | `error={undefined}`, `hint="Type at least 8 characters"` | Renders `<span class="font-mono text-[0.7rem] text-apt-text-dim">Type at least 8 characters</span>` |
| field-footnote-004 | must-return-null-when-empty | `error={undefined}`, `hint={undefined}` | Returns null; nothing is rendered |
| field-footnote-005 | must-apply-error-id-when-present | `error="Error"`, `errorId="email-error"` | Renders error span with `id="email-error"` |
| field-footnote-006 | must-apply-error-id-only-to-error | `hint="Hint"`, `errorId="some-id"` | Renders hint span without `id` attribute |
| field-footnote-007 | must-apply-class-name | `error="Error"`, `className="custom-class"` | Renders error span with merged classes including `custom-class` |
| field-footnote-008 | must-support-react-node-content | `error={<strong>Bold error</strong>}` | Renders error span containing the strong element |

## Edge Cases

- **Empty string error**: `error=""` (falsy) is treated as no error; hint is shown if present. Empty strings are falsy in JavaScript.
- **Empty string hint**: `hint=""` (falsy) is treated as no hint; nothing is rendered if error is also absent.
- **Zero or false**: `error={0}` or `error={false}` are falsy and treated as no error; same for hint.
- **Null/undefined**: Both are falsy and result in no error or hint being shown.
- **className merging collision**: If `className` contains a utility class that conflicts with default classes (e.g., `text-apt-red` when default is `text-apt-red`), the `cn` utility deduplicates and the later class takes precedence per Tailwind's specificity rules.

## Configuration

Not applicable: FieldFootnote has no configuration options. It is a stateless presentation component; all behavior is determined by its props.

## Deep Linking

Not applicable: FieldFootnote is a non-interactive display component with no user navigation or link targets.

## Localization

Not applicable: The component does not define or localize any strings of its own. All text content (error and hint messages) is provided by the caller via props.

## Accessibility Options

Not applicable: FieldFootnote does not respond to accessibility display preferences (Reduce Motion, Increase Contrast, Differentiate Without Color) and does not expose configurable accessibility options.

## Feature Flags

Not applicable: The component has no feature flag logic and is always enabled when imported.

## Analytics

Not applicable: FieldFootnote does not emit or track any analytics events. It is a stateless display component.

## Privacy

Not applicable: FieldFootnote does not collect, store, or transmit any user data. It renders text provided by its caller.

## Logging

Not applicable: The component does not emit debug logs or instrumentation.

## Platform Notes

- **React/Web**: Implemented using React functional component with `ReactNode` type for content props. Uses the `cn` utility (Tailwind classname merger from `lib/utils`) to safely merge custom classes with default utilities. Text size is `text-[0.7rem]` (arbitrary Tailwind value equivalent to 0.7rem or ~11px). Error and hint colors reference Tailwind design tokens `text-apt-red` and `text-apt-text-dim`.
- **SwiftUI**: Implement using `Text` view with `.font(.system(size: 9.8, weight: .regular, design: .monospaced))` for error and hint. Use `Color` tokens equivalent to the web red and dim gray. Render conditionally: show error if present, else show hint if present, else return `EmptyView()`.
- **Compose**: Implement using `Text` composable with `fontSize = 5.6.sp`, `fontFamily = FontFamily.Monospace`, and `fontWeight = FontWeight.Normal`. Apply color tokens for error (red) and hint (dim). Render conditionally: if error is not null show it in red, else if hint is not null show it in dim color, else render nothing.
- **AppKit/UIKit**: On macOS, use `NSTextField` or `NSTextView` (read-only) with `.monospacedSystemFont(ofSize: 9.8, weight: .regular)`. On iOS, use `UILabel` with `.monospacedSystemFont(ofSize: 9.8, weight: .regular)`. Apply `UIColor` tokens for red and dim text. Render conditionally; update layout when error/hint changes.
- **WinUI 3**: Implement using `TextBlock` with `FontFamily="Courier New"`, `FontSize="9.8"`, and `FontWeight="Normal"`. Bind `Foreground` to a color brush that switches between error red and hint dim gray based on whether error or hint is present. Render conditionally using `Visibility` property: `Visible` if content exists, `Collapsed` otherwise.

## Design Decisions

The component deliberately avoids the standard `ErrorText` component (which uses `text-sm` and `role="alert"`) because the metrics of `text-sm` differ significantly from the hint text size (`text-[0.7rem]`). When an error swaps in for a hint, layout shift occurs if the two have different line heights or text sizes. FieldFootnote solves this by making error and hint visually identical in size and metric, differing only in color. This is a deliberate trade-off: the component sacrifices automatic screen reader alerts on error (`role="alert"` behavior) for layout stability. Consumers must wire the error span's `errorId` to a control's `aria-describedby` to ensure errors are announced.

The component also stands alone rather than living inside `Field` wrapper because some form controls (notably checkboxes) cannot use `Field`'s label structure and must build their own row layout. To prevent duplication and divergence of error/hint logic, FieldFootnote is exported as a reusable primitive so both `Field`-wrapped controls and custom-row controls use the same implementation.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| Accessible error feedback via aria-describedby | passed | Accessibility |
| Monospace font for error and hint | passed | Visual Consistency |
| Error takes precedence over hint | passed | Behavior |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation from field-footnote.tsx source |
