---
id: d9ad192e-a642-46a2-8b25-b8aac9d9f441
title: RecipientInput
domain: agenticdevelopercookbook://ingredients/recipient-input
type: ingredient
version: 1.2.0
status: review
language: en
created: 2026-06-26
modified: 2026-09-22
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: "A token input that collects recipients (email/phone/text) into removable chips with optional separate rendering modes and read-only display."
platforms:
  - typescript
  - web
tags:
  - input
  - chips
  - tokens
  - recipients
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# RecipientInput

## Overview

RecipientInput is a controlled token input component in `@agenticdevelopertoolkit/ui` that collects recipients via a text field and displays them as removable chips. It supports three input kinds (email, phone, text) with corresponding light validation, and offers two layout modes: fused (default, single container) and separate (two-part layout with stacked chips and input).

## Behavioral Requirements

- **must-tokenize-on-enter**: The component MUST add a new chip when the user presses Enter in the inline input, trimming whitespace and ignoring empty entries.
- **must-tokenize-on-comma**: The component MUST add a new chip when the user types a comma in the inline input, splitting comma-separated input into multiple chips and trimming each.
- **must-tokenize-on-blur**: The component MUST add a new chip when focus leaves the inline input (onBlur), trimming whitespace and ignoring empty entries.
- **must-dedup-case-insensitive-email**: When `kind="email"`, the component MUST reject duplicate entries case-insensitively; entries `Ada@x.io` and `ada@x.io` are treated as the same recipient.
- **must-dedup-exact-non-email**: When `kind` is not `"email"`, the component MUST reject duplicate entries using exact string comparison.
- **must-validate-email**: When `kind="email"`, the component MUST validate each chip against the pattern `/^[^\s@]+@[^\s@]+\.[^\s@]+$/`; invalid chips MUST still be added but MUST render with an error appearance and `aria-invalid="true"`.
- **must-validate-phone**: When `kind="phone"`, the component MUST validate each chip against the pattern `/^[+]?[\d\s().-]{7,}$/`; invalid chips MUST still be added but MUST render with an error appearance and `aria-invalid="true"`.
- **must-not-validate-text**: When `kind="text"`, the component MUST NOT apply validation; all entries are accepted.
- **must-remove-chip-on-dismiss**: The component MUST remove a chip from the value array when its remove affordance (×) is activated.
- **must-remove-last-on-backspace**: In default (fused) mode, the component MUST remove the last chip when Backspace is pressed with an empty inline input and chips present.
- **must-not-remove-on-backspace-when-separate**: In separate input mode, the component MUST NOT remove chips via Backspace when the inline input is empty.
- **must-set-input-mode-email**: When `kind="email"`, the component MUST set the inline input's `inputMode="email"`.
- **must-set-input-mode-phone**: When `kind="phone"`, the component MUST set the inline input's `inputMode="tel"`.
- **must-set-input-mode-text**: When `kind="text"`, the component MUST set the inline input's `inputMode="text"`.
- **must-support-separate-mode**: When `separateInput=true`, the component MUST render in two distinct parts: a read-only recipients box showing existing chips, and a separate text input below for adding new recipients.
- **must-support-readonly-mode**: When `readOnly=true`, the component MUST not render an input field; existing recipients MUST display as static, non-removable chips (Badge elements).
- **must-disable-all-interaction**: When `disabled=true`, the component MUST render in a disabled state (reduced opacity, pointer-events-none) and MUST NOT respond to user input or trigger `onChange`.

## Appearance

**Default (Fused) Mode:**
- Container: flexbox row-wrapping with `rounded-lg border border-apt-border bg-apt-bg px-2 py-1.5`; chips and input are co-located in one container.
- Chips: Badge component (`variant="neutral"` for valid, `variant="error"` for invalid) with a removable-chip wrapper adding an × button.
- Inline input: borderless `<input>` with `flex-1 bg-transparent outline-none text-apt-text`; placeholder shown only when the chip list is empty.

**Separate Input Mode:**
- Recipients box: separate container with `fieldShellClass rounded-lg border border-apt-border bg-apt-bg px-2 py-1.5`, `min-h-[2.25rem]`, wrapping chips. Placeholder text "No recipients yet" shown when empty.
- Input element: separate below the recipients box, using the Input primitive component with `h-auto px-2 py-1.5`.

**Read-Only Mode:**
- No input field is rendered.
- Recipients display as static Badge chips (`variant="neutral"` for valid, `variant="error"` for invalid) without removable affordances.

**Focus and Disabled:**
- Default mode: container has `focus-within:border-apt-gold focus-within:ring-2 focus-within:ring-apt-gold/25` when any child is focused.
- Separate mode: input has its own focus treatment via the Input component.
- Disabled state applies `pointer-events-none opacity-50` to the entire component.

## States

| State | Appearance Change | Mode | Notes |
|-------|-------------------|------|-------|
| Default | `border-apt-border`; no ring | Both | Container in default (fused) mode or recipients box in separate mode |
| Focus-within | `border-apt-gold` + `ring-2 ring-apt-gold/25` | Default (fused) | Applied when any child element receives focus |
| Focused (input) | Depends on Input component | Separate | Separate input uses Input component's focus styling |
| Disabled | `pointer-events-none opacity-50` | Both | All chips and input non-interactive |
| Chip (valid) | Badge `variant="neutral"` | Both | No validation error |
| Chip (invalid) | Badge `variant="error"` + `aria-invalid="true"` | Both | Validation failed; still added to the value array |
| Empty recipients | Placeholder text "No recipients yet" (separate) or hidden (default) | Separate | Separate mode shows explicit placeholder |

## Accessibility

- Container: `role="group"` with `aria-label` from the `ariaLabel` prop.
- Inline input: `aria-label={`Add to ${ariaLabel}`}` to label the entry field.
- Invalid chips: carry `aria-invalid="true"` attribute.
- Removable chips: include a remove affordance with a descriptive label (via RemovableChip component).
- Input type hints: `inputMode` reflects the `kind` prop to guide mobile keyboards.

## Conformance Test Vectors

| ID | Requirement | Input | Expected |
|----|-------------|-------|----------|
| T1 | must-tokenize-on-enter | Type `ada@x.io` and press Enter in default mode | Neutral Badge chip `ada@x.io` added to value; input clears |
| T2 | must-tokenize-on-comma | Type `ada@x.io, grace@x.io` and a comma is typed | Two chips added; input clears |
| T3 | must-tokenize-on-blur | Type `  ada@x.io  ` and blur the input | Trimmed chip `ada@x.io` added; input clears |
| T4 | must-dedup-case-insensitive-email | `kind="email"`: add `Ada@x.io` then attempt to add `ada@x.io` | Second entry rejected; one chip remains |
| T5 | must-dedup-exact-non-email | `kind="text"`: add `Ada` then attempt to add `ada` | Both chips added (exact match required) |
| T6 | must-validate-email | `kind="email"`: add `bad@` | Chip rendered with error appearance + `aria-invalid="true"` but still in value |
| T7 | must-validate-phone | `kind="phone"`: add `12345` (too short) | Chip rendered with error appearance + `aria-invalid="true"` but still in value |
| T8 | must-validate-phone | `kind="phone"`: add `+1 (555) 123-4567` | Valid; chip rendered neutral |
| T9 | must-not-validate-text | `kind="text"`: add `@#$%^` | No validation error; chip neutral |
| T10 | must-remove-chip-on-dismiss | Default mode with chips present; click × on a chip | That chip removed from value |
| T11 | must-remove-last-on-backspace | Default mode with chips and empty input; press Backspace | Last chip removed |
| T12 | must-not-remove-on-backspace-when-separate | Separate mode with chips and empty input; press Backspace | Input text behavior only; no chip removed |
| T13 | must-set-input-mode-email | `kind="email"` | Inline input has `inputMode="email"` |
| T14 | must-set-input-mode-phone | `kind="phone"` | Inline input has `inputMode="tel"` |
| T15 | must-support-separate-mode | `separateInput=true` | Component renders recipients box and separate input below |
| T16 | must-support-readonly-mode | `readOnly=true` with existing recipients | Recipients display as static Badge chips; no input field shown |
| T17 | must-disable-all-interaction | `disabled=true` | Component appears grayed out; no input, no chip removal |

## Edge Cases

- **Empty or whitespace-only input on tokenization**: An entry consisting only of spaces is trimmed to an empty string and ignored; no chip is added.
- **Backspace behavior in separate mode**: Backspace while input is non-empty edits the text; it does not remove chips. Only in default mode does Backspace with empty input remove the last chip.
- **Validation does not block addition**: Invalid chips are still added to the value array; the component marks them as invalid via appearance and `aria-invalid` but does not reject them. The consuming feature (e.g., an invitation modal) decides whether to block send.
- **Duplicate detection scope**: De-duplication is performed case-insensitively for email and exact for other kinds; it compares the input entry against all existing chips in `value`.
- **Disabled state under readOnly**: When `disabled=true` and `readOnly=true`, chips are grayed out and not interactive (they are not removable even if not read-only).
- **Placeholder behavior in fused mode**: The placeholder text is shown only when the chip list is empty. Once at least one chip is present, the placeholder is hidden.
- **Focus behavior in separate mode**: Each part (recipients box and input) can be styled independently; the recipients box has no focus ring of its own; focus styling applies to the separate Input element.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `value` | `string[]` | — (required) | Controlled array of recipient strings. The component does not modify this directly; changes flow through `onChange`. |
| `onChange` | `(next: string[]) => void` | — (required) | Called with the updated recipient array on any add or remove. Not called in `readOnly` mode. |
| `kind` | `"email" \| "phone" \| "text"` | `"text"` | Validation mode and input type hints. `"email"` and `"phone"` apply regex validation; `"text"` skips validation. |
| `placeholder` | `string` | `"Add email…"`, `"Add phone…"`, or `"Add…"` (depends on `kind`) | Placeholder text for the inline input. If not provided, a default matching `kind` is used. In separate mode, placeholder is applied to the separate Input. In fused mode, placeholder is shown only when chips list is empty. |
| `ariaLabel` | `string` | — (required) | Accessible label for the container group. Input field label is derived as `Add to ${ariaLabel}`. |
| `disabled` | `boolean` | `false` | When true, all interaction is disabled: chips cannot be removed, input cannot be typed, `onChange` is not called. |
| `className` | `string` | — | Additional CSS classes applied to the root container. |
| `separateInput` | `boolean` | `false` | When true, renders the recipients box and input as two visually distinct stacked elements instead of one fused container. |
| `readOnly` | `boolean` | `false` | When true, recipients display as static, non-removable Badge chips and no input field is rendered. Useful for displaying fixed recipient lists from the server. `onChange` is never called in this mode. |

## Deep Linking

Not applicable: RecipientInput is a controlled form component without independent routing or deep-linking requirements.

## Localization

Not applicable: All user-facing strings are defined locally within the component (e.g., "Remove X", "Add email…", "Add phone…", "Add…", "No recipients yet"). Currently no localization strings are externalized from the component source.

## Accessibility Options

Not applicable: RecipientInput is a basic text input component that does not respond to system accessibility display options such as Reduce Motion or Differentiate Without Color.

## Feature Flags

Not applicable: RecipientInput is a foundational UI component with no feature-flag gating or opt-in behavior.

## Analytics

Not applicable: RecipientInput is a presentational component that does not emit its own analytics events. Consuming features (e.g., invitation modals) handle logging of user actions and submission outcomes.

## Privacy

Not applicable: RecipientInput is a controlled input component that does not collect, store, transmit, or persist data independently. It is a stateless pass-through; data persistence and transmission are the responsibility of the consuming feature.

## Logging

Not applicable: RecipientInput is a presentational component that does not emit structured logging events. Tokenization, validation outcomes, and submission are logged by consuming features, not by the input component itself.

## Platform Notes

- **React / Web (TypeScript)**: Component implemented at `packages/web/packages/ui/src/components/recipient-input.tsx`. Built from native HTML `<div>`, `<input>`, and composed UI primitives (Badge, RemovableChip, Input). Integrates with Tailwind CSS for styling. Export: `RecipientInput(props: RecipientInputProps): React.ReactElement`.

- **SwiftUI**: On iOS, use `UITextField` with custom `UIView` composition to replicate token-removal behavior, or evaluate a third-party multifield picker. Consider using a `VStack` of `TextField` and a wrapping `FlowLayout` or `MultilineTextField` alternative for chip display.

- **Compose (Android Kotlin)**: On Android, use `OutlinedTextField` with `LazyRow` for tokens and `IconButton` for removal, or a specialized multi-field input library. Layout tokens in a wrapping container using `FlowRow` or a custom `LayoutScope` arrangement; validate input according to `kind` and update the state via `onValueChange`.

- **AppKit / UIKit (macOS, iOS native)**: Native implementations would use `NSTextField` (macOS) or `UITextField` (iOS) with `UIView` for token layout and removal controls. Arrange tokens in a `UIStackView` (vertical or horizontal, as needed) above or alongside the text field; attach gesture recognizers to token buttons for removal. Apply border and focus styling via `NSBorderTextField` attributes or custom layer rendering.

- **WinUI 3**: A WinUI equivalent would start from `TextBox` for input and `ItemsRepeater` or `GridView` for tokens, with `AppBarButton` or `SymbolIcon` for removal controls. Focus ring and validation styling would use WinUI's `VisualState` theming. Bind the `TextBox` value to state; on validation trigger (Enter, comma, blur), parse and update a bound token list; remove tokens via button taps on `ItemsRepeater` items.

## Design Decisions

- **Invalid chips are still added**: Validation is advisory, not blocking. Invalid chips are added to the value array and marked visually and with `aria-invalid`, allowing the consumer to decide whether to block send. This keeps the input dumb and reusable across different validation rules the consumer may enforce.

- **Email de-duplication is case-insensitive; other kinds use exact match**: Email addresses are case-insensitive in practical routing (`Ada@x.io` and `ada@x.io` are the same recipient). Other input kinds (phone, text) use exact string comparison to preserve user intent.

- **Two layout modes (fused and separate)**: The default fused layout mimics the Input primitive for consistency. The separate mode allows designs that need to visually emphasize the existing recipient list (e.g., invitation interfaces that show seeded recipients separately from new entries). Both modes share tokenization and validation logic.

- **Read-only mode disables input and uses Badge instead of RemovableChip**: Read-only mode is designed for displaying fixed recipient lists (e.g., backend-seeded selections) without presenting an editable interface. Using Badge instead of RemovableChip signals to users that removal is not available, reducing accidental interaction attempts.

- **Backspace-to-remove only in default mode**: Backspace removal is a convenience for compact fused layouts. In separate input mode, the recipients box is not focused, so Backspace is applied to the input text, not to tokens. This avoids accidental deletion in two-part layouts.

- **Container reuses Input primitive styles**: The component applies the same border, background, padding, and focus-ring treatment as the Input primitive for visual consistency and predictable behavior for users familiar with other input controls in the same design system.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| Artifact formatting (ingredient) | passed | artifact-formatting |
| UI guidelines — no raw hex, no `!important` | passed | adh-ui-guidelines |
| Accessibility — role, labels, aria-invalid | passed | a11y-requirements |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.2.0 | 2026-09-22 | Mike Fullerton | Remove "Not applicable" phrasing from Platform Notes non-web bullets; sharpen native platform guidance; relabel Windows bullet to `**WinUI 3**`. |
| 1.1.0 | 2026-09-22 | Mike Fullerton | Document `separateInput` and `readOnly` modes; expand behavioral requirements; add missing sections (Deep Linking, Localization, etc.); update Platform Notes to cover all five platforms; fix domain URI. |
| 1.0.0 | 2026-06-26 | Mike Fullerton | Initial conversion from legacy UI spec. |
