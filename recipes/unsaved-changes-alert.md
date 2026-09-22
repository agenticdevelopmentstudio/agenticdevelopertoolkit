---
id: 9e36a0ef-67ef-485d-8ace-68886add841c
title: Unsaved Changes Alert
domain: agenticdevelopertoolkit://recipes/unsaved-changes-alert
type: ingredient
version: 1.0.0
status: review
language: en
created: 2026-09-22
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Modal alert that prompts the user before discarding unsaved edits, with a
  customizable description of what is at risk.
platforms:
- typescript
- web
tags:
- dialog
- modal
- destructive-action
- form-management
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Unsaved Changes Alert

## Overview

The Unsaved Changes Alert is a modal dialog that blocks interaction and prompts the user before discarding unsaved edits. It is the canonical prompt for all editable surfaces that risk data loss on exit or dismissal. The component enforces consistency by fixing the title ("Discard unsaved changes?") and button labels ("Discard" and "Stay") — only the description text may be customized when the surface can specifically name what is at risk. The component never saves; the user must return to the surface and save there, keeping the component free of persistence dependencies.

## Behavioral Requirements

- **must-show-modal-when-open**: Component MUST display a modal dialog when `open` is `true`, blocking all interaction outside the modal until dismissed.
- **must-hide-modal-when-closed**: Component MUST not display when `open` is `false`.
- **must-use-fixed-title**: Component MUST display the title "Discard unsaved changes?" and MUST NOT accept a title prop.
- **must-use-fixed-button-labels**: Component MUST display "Discard" as the destructive action label and "Stay" as the cancel label, and MUST NOT accept customizable button labels.
- **must-render-description**: Component MUST render the description text in the modal body.
- **must-use-default-description**: Component MUST use "Your unsaved changes will be lost." as the description when the `description` prop is not provided.
- **must-accept-custom-description**: Component MUST accept an optional `description` prop to override the default description for surfaces that can name what is at risk.
- **must-invoke-ondiscard-callback**: Component MUST call the `onDiscard` callback function when the user confirms the destructive action (taps or clicks "Discard").
- **must-invoke-onstay-callback**: Component MUST call the `onStay` callback function when the user cancels the action (taps or clicks "Stay" or dismisses the modal).
- **must-force-deliberate-action**: Component MUST set the underlying AlertModal's `destructive` prop to force `keyboard: "none"` and `initialFocus: "cancel"`, ensuring that neither Enter nor Escape can trigger the destructive action; Discard requires an explicit click or tap.
- **must-not-persist**: Component MUST NOT persist data; it returns control to the caller to handle persistence on the editing surface.

## Appearance

Not applicable: The component is a wrapper around AlertModal and does not define appearance directly. Visual appearance, spacing, colors, typography, and shadow are delegated to the underlying AlertModal component and inherit its design tokens.

## States

| State | Appearance change |
|-------|-------------------|
| Open | Modal displayed, overlay active, focus trapped inside modal |
| Closed | Modal not displayed |

## Accessibility

- **role**: Role is `alertdialog` (inherited from AlertModal).
- **label-requirement**: The modal's accessible name is its title, "Discard unsaved changes?".
- **description-requirement**: The description prop provides the accessible description of what will be lost. Implementations MUST associate the description text with the modal using `aria-describedby` or equivalent.
- **keyboard-navigation**: Focus MUST be managed by AlertModal, which MUST trap focus inside the modal and MUST NOT allow Escape or Enter to trigger the destructive action when `destructive` is set.
- **button-labels**: Both buttons MUST have accessible labels; "Discard" and "Stay" are the required labels per source code.
- **minimum-touch-target**: Per [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/) and platform standards, both buttons MUST have a touch target of at least 44×44 pt (iOS) or 48×48 dp (Android).

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| unsaved-001 | must-show-modal-when-open | `open={true}` | Modal dialog is visible; overlay blocks interaction outside the modal |
| unsaved-002 | must-hide-modal-when-closed | `open={false}` | Modal dialog is not rendered or is hidden |
| unsaved-003 | must-use-fixed-title | Any props | Modal title displays "Discard unsaved changes?" |
| unsaved-004 | must-use-fixed-button-labels | Any props | Destructive button is labeled "Discard"; cancel button is labeled "Stay" |
| unsaved-005 | must-render-description | `description="Staged users will not be saved."` | Description text "Staged users will not be saved." appears in modal body |
| unsaved-006 | must-use-default-description | No `description` prop | Description text "Your unsaved changes will be lost." appears in modal body |
| unsaved-007 | must-accept-custom-description | `description="Composed invitation cannot be sent."` | Description is overridden with "Composed invitation cannot be sent." |
| unsaved-008 | must-invoke-ondiscard-callback | User clicks "Discard" button | `onDiscard` callback is invoked once; modal remains open until `open` prop is set to `false` by parent |
| unsaved-009 | must-invoke-onstay-callback | User clicks "Stay" button | `onStay` callback is invoked once |
| unsaved-010 | must-force-deliberate-action | User presses Escape key while modal is open | Nothing happens; Escape does not dismiss the modal or invoke `onDiscard` |
| unsaved-011 | must-force-deliberate-action | User presses Enter key while modal is open | Nothing happens; Enter does not invoke `onDiscard` |
| unsaved-012 | must-not-persist | Either callback invoked | No network request or persistence operation occurs; caller retains responsibility for persistence |

## Edge Cases

- **Empty description**: When `description=""` (empty string), the modal MUST still render and MUST display an empty description area; behavior is the same as providing an empty string.
- **Null or undefined description**: When `description` is not provided or is `undefined`, the component MUST use the default description "Your unsaved changes will be lost."
- **Very long description**: When `description` exceeds the modal's content width, the text SHOULD wrap or scroll within the modal body without breaking layout.
- **Callbacks not provided**: If `onDiscard` or `onStay` are not provided or are `undefined`, the component MUST NOT crash; clicking either button MUST still attempt to invoke the callback (no-op if undefined).
- **Rapid re-opens**: When the modal is closed (`open={false}`) and immediately re-opened (`open={true}`), the modal MUST display correctly with focus reset to the "Stay" button (per `initialFocus: "cancel"`).
- **Open toggle during interaction**: While the user is interacting with the modal, if the `open` prop is externally toggled to `false`, the modal MUST close and all pending interaction MUST be cancelled (no callbacks fire).

## Configuration

Not applicable: The component accepts only three props (`open`, `onDiscard`, `onStay`, `description`) and has no configuration options or environment variables.

## Deep Linking

Not applicable: This is a modal dialog component with no page-level URL or navigation semantics. Deep linking is not applicable.

## Localization

| String Key | Default (en) | Context |
|-----------|-------------|---------|
| title | Discard unsaved changes? | Modal title; fixed, not customizable |
| confirmLabel | Discard | Destructive action button; fixed, not customizable |
| cancelLabel | Stay | Cancel action button; fixed, not customizable |
| defaultDescription | Your unsaved changes will be lost. | Default modal description when not overridden |

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | AlertModal SHOULD respect `prefers-reduced-motion`; any open/close animation SHOULD be disabled or simplified when this preference is active |
| Increase Contrast | Button text and modal border SHOULD increase contrast to meet WCAG AAA (7:1) when this preference is active |
| Differentiate Without Color | If the destructive button uses color alone to signal destructiveness, an additional visual indicator (e.g., icon or text) SHOULD be present |

## Feature Flags

Not applicable: The component is a standard UI element with no feature flag gating or conditional behavior.

## Analytics

Not applicable: The component does not emit analytics events; parent surfaces are responsible for tracking modal interactions if needed.

## Privacy

- **Data collected**: None; the component collects no personal or sensitive data.
- **Storage**: No data is stored by this component.
- **Transmission**: No data is transmitted.
- **Retention**: N/A.

## Logging

Not applicable: The component does not perform logging; parent error handling or debugging is the responsibility of the caller.

## Platform Notes

- **React/Web**: The component is implemented in React using the Next.js `"use client"` directive. The source is `packages/web/packages/ui/src/components/unsaved-changes-alert.tsx`. It wraps the `AlertModal` component from the same package, passing `destructive={true}` to force the keyboard and focus constraints. The `description` prop directly overrides AlertModal's `description` prop; all other props are fixed in the source code.
- **SwiftUI**: Use SwiftUI's `Alert` or custom `View` with a modal presentation. Set the alert's buttons to include a destructive "Discard" action and a cancel "Stay" action. Use `@State` to manage `isPresented` (equivalent to `open`), and call the appropriate callback on button tap. Title is fixed to "Discard unsaved changes?"; description may be customized via a binding or state parameter.
- **UIKit**: Use `UIAlertController` with `preferredStyle: .alert`. Add two `UIAlertAction` buttons: one with `style: .destructive` labeled "Discard" and one with `style: .cancel` labeled "Stay". Present modally with `present(_:animated:completion:)`. Manage visibility via a view controller property or presentation controller.
- **Compose**: Use Compose's `AlertDialog` composable or a custom modal. Set the title to a fixed `Text("Discard unsaved changes?")` and the description to a customizable parameter. Define two buttons as `AlertDialog` actions or custom `Button` composables. Handle state via a mutable `Boolean` for `open`. Ensure the destructive action button has a destructive style (e.g., red text or `Color.Red`).
- **WinUI 3**: Use the `ContentDialog` control in XAML. Set `Title` to `"Discard unsaved changes?"` (as a string resource if localizing) and `Content` to the description text (customizable via binding or parameter). Define two buttons as `PrimaryButtonText="Discard"` and `SecondaryButtonText="Stay"` or use `Button` controls in a `StackPanel`. Bind the `IsOpen` property to a ViewModel `INotifyPropertyChanged` property for state management. Set the primary button's `Background` to a destructive color (e.g., red). Handle `PrimaryButtonClick` and `SecondaryButtonClick` events to invoke the `onDiscard` and `onStay` callbacks respectively.

## Design Decisions

1. **Fixed title and button labels**: The title "Discard unsaved changes?" and labels "Discard" and "Stay" are not customizable. This is a consistency guarantee across all surfaces using this component — every editable surface asks the same question in the same words. This prevents fragmentation of the user experience and makes it familiar to the user.

2. **Only description is customizable**: The `description` prop is the single exception to the fixed-text rule. This allows surfaces to be specific about what is at risk (e.g., "Staged users will not be saved" vs. "Composed invitation cannot be sent") while maintaining a consistent question and answer structure. Surfaces with nothing specific to say pass no description prop and receive the default.

3. **No persistence in the component**: The component never saves. This keeps it decoupled from any specific persistence mechanism (localStorage, server API, IndexedDB, etc.) and allows it to be reused across surfaces with different storage strategies. The responsibility for persisting changes belongs to the surface, not the alert.

4. **Destructive flag forces deliberate action**: Setting `destructive={true}` on the underlying AlertModal enforces `keyboard: "none"` and `initialFocus: "cancel"`, preventing accidental dismissal via Escape or Enter. This is intentional: losing edits must be a deliberate click or tap, not a keyboard accident.

5. **Modal blocks all interaction**: The alert is a modal dialog that traps focus and blocks interaction outside itself. This ensures the user cannot make further changes while the prompt is open — the choice is binary and immediate.

## Compliance

Not applicable: No specific compliance checks are defined for this component at this time. Accessibility compliance is covered by the Accessibility section (WCAG 2.1 AA via platform guidelines).

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
