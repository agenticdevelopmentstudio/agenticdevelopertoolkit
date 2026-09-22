---
id: 9f87b4cd-f3a0-482b-830d-c1482ed51bbe
title: Create Resource Dialog
domain: agenticdevelopercookbook://ingredients/create-resource-dialog
type: ingredient
version: 1.1.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Modal dialog for creating resources with form validation, unsaved-changes
  guard, and async error handling.
platforms:
- typescript
- web
tags:
- dialog
- form
- modal
- create
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Create Resource Dialog

## Overview

A reusable modal dialog component for creating new resources. The dialog renders a form via a callback, validates input on save, invokes an async creation function, and guards against accidental data loss via an unsaved-changes alert. The dialog is portal-rendered to the document body to avoid stacking context issues from ancestor overflow constraints or inert state.

## Behavioral Requirements

- **must-render-modal-dialog**: Component MUST render a modal dialog with `role="dialog"` and `aria-modal="true"` that portals to `document.body`.
- **must-render-heading**: Component MUST render the provided `heading` prop as an h2 element.
- **must-render-form-content**: Component MUST render the form via the `renderForm` callback, passing current draft state, onChange handler, and current error message.
- **must-render-close-button**: Component MUST render a close button (×) labeled "Close" in the top-right corner of the dialog header.
- **must-render-cancel-button**: Component MUST render a "Cancel" button in the footer.
- **must-render-save-button**: Component MUST render a "Save" button in the footer that displays "Saving..." text while an async create operation is in progress.
- **must-disable-save-when-pristine**: Component MUST disable the Save button when the draft state is identical to the blank (pristine) initial state.
- **must-validate-on-save**: Component MUST call the `validate` callback when Save is clicked and MUST display the validation error message inline if validation fails.
- **must-prevent-save-when-invalid**: Component MUST NOT invoke the `create` callback if `validate` returns a non-null error.
- **must-invoke-create-on-save**: Component MUST invoke the `create` callback with the validated draft when Save is clicked and validation passes.
- **must-disable-buttons-while-saving**: Component MUST disable both Cancel and Save buttons while the `create` operation is in progress.
- **must-invoke-oncreated-on-success**: Component MUST invoke the `onCreated` callback with the result of `create` when the operation succeeds.
- **must-display-create-error**: Component MUST display the error message inline when `create` throws an exception; the message MUST be derived from the Error's message property or a default string if the error is not an Error instance.
- **must-invoke-onsaveerror-on-create-failure**: Component MUST invoke the `onSaveError` callback with the exception when `create` fails, if the callback is provided.
- **must-guard-close-on-dirty**: Component MUST show the `UnsavedChangesAlert` component when the user attempts to close (via Cancel, ×, or Escape) and the draft has unsaved changes.
- **must-not-close-on-backdrop-click**: Component MUST NOT close when the backdrop (overlay background) is clicked.
- **must-route-escape-through-guard**: Component MUST route Escape key presses through the same close guard as Cancel and ×, respecting the unsaved-changes alert state.
- **must-support-optional-save-gate**: Component MUST respect the optional `saveEnabled` callback and disable Save if it returns false, in addition to the pristine-state check.
- **must-render-only-on-client**: Component MUST NOT render on the server; it MUST return `null` when `document` is undefined.
- **must-use-aria-label**: Component MUST apply the `ariaLabel` prop to the dialog container as `aria-label`.

## Appearance

- **Overlay background**: Black with 70% opacity (`bg-black/70`)
- **Overlay layout**: Fixed position, full screen, flex center top with auto scroll (`fixed inset-0 z-50 flex items-start justify-center overflow-y-auto p-6`)
- **Dialog container**: Rounded corners (12px), border, surface background, shadow, relative positioning, max width 3xl, centered vertically with 8px margin top
- **Dialog padding**: 24px (p-6)
- **Header spacing**: Flex row, space-between alignment, 16px gap (gap-4) between heading and close button
- **Heading**: h2 element, base font size (16px), font-semibold weight, text color
- **Form section**: Rendered via `renderForm` callback
- **Footer**: Flex row, justify-end alignment, 8px gap (gap-2) between Cancel and Save buttons
- **Buttons**: Ghost variant for Cancel, primary variant for Save; both icon-sm size for close button

## States

| State | Appearance change |
|-------|------------------|
| Default | Form is empty (pristine), Save button is disabled, no error message visible |
| Dirty | Form has been edited, Save button is enabled (unless saveEnabled returns false), no error message |
| Focused | Keyboard focus is visible on any interactive control (button, form field) |
| Validating (implied) | User clicked Save; inline validation runs synchronously before async operation |
| Saving | Both Cancel and Save buttons are disabled; Save button text changes to "Saving..." |
| Error | An error message is displayed inline above the footer; both buttons remain in disabled state while saving, enabled state once saving completes |
| Confirming | UnsavedChangesAlert is displayed as a sibling overlay; dialog remains visible but interaction is focused on the alert |
| Server-side (implied) | Component returns null when document is undefined (SSR context) |

## Accessibility

- **Dialog role**: Component uses `role="dialog"` and `aria-modal="true"` to signal a modal dialog to assistive technology.
- **Accessible label**: Component applies `aria-label` from the `ariaLabel` prop to the dialog container.
- **Heading**: The heading is rendered as an h2 element to provide semantic structure.
- **Close button label**: Close button has `aria-label="Close"` to describe its purpose to screen readers.
- **Form labels**: Responsibility for form field labeling and accessibility is delegated to the `renderForm` callback.
- **Error announcement**: Error messages are displayed inline; the component does not use ARIA live regions or explicit announcements.
- **Keyboard navigation**: Tab order flows through Cancel, Save, and form fields; Escape key is handled to close the dialog.
- **Focus management**: The source calls no focus API. It neither moves focus into the dialog on open, confines Tab within it while open, nor restores focus to the invoking control on close. NEEDS REVIEW: Not implemented in source. Behavior undefined. What is missing is the focus contract for a container that declares `role="dialog"` and `aria-modal="true"`: which element receives focus on open, whether focus is confined for the dialog's lifetime, and where focus returns after Save, Cancel, ×, or Escape. The source cannot settle it because it assigns the responsibility to neither the dialog nor its host; the evidence that would settle it is a recorded decision assessed against the WAI-ARIA Authoring Practices dialog pattern and WCAG 2.1 SC 2.4.3 (Focus Order), naming the owning layer.
- **Backdrop interaction**: Backdrop click is intentionally non-interactive to prevent accidental dismissal; this is accessible since keyboard and explicit buttons provide alternatives.
- **Minimum touch target**: Button sizes are assumed to meet platform standards (typically 44×44pt minimum); specific sizing is delegated to the Button component.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|----|---|---|
| create-resource-001 | must-render-modal-dialog | Component is mounted | Modal dialog renders with `role="dialog"` and `aria-modal="true"` in document.body |
| create-resource-002 | must-render-heading | heading="New Product" | h2 element renders with text "New Product" |
| create-resource-003 | must-render-close-button | Component is mounted | Close button (×) is rendered in dialog header with aria-label="Close" |
| create-resource-004 | must-render-cancel-button | Component is mounted | Cancel button is rendered in footer |
| create-resource-005 | must-render-save-button | Component is mounted | Save button is rendered in footer with text "Save" |
| create-resource-006 | must-disable-save-when-pristine | Draft state equals blank state | Save button has disabled attribute |
| create-resource-007 | must-disable-save-when-pristine | User edits form (draft differs from blank) | Save button is enabled |
| create-resource-008 | must-validate-on-save | User clicks Save; validate returns "Name is required" | Error message "Name is required" displays inline |
| create-resource-009 | must-prevent-save-when-invalid | User clicks Save; validate returns non-null error | Create callback is not invoked |
| create-resource-010 | must-invoke-create-on-save | User clicks Save; validate returns null | Create callback is invoked with current draft |
| create-resource-011 | must-disable-buttons-while-saving | Create callback is in progress | Both Cancel and Save buttons have disabled attribute |
| create-resource-012 | must-render-save-button | Create operation is in progress | Save button text is "Saving..." |
| create-resource-013 | must-invoke-oncreated-on-success | Create callback resolves successfully | onCreated callback is invoked with result; component closes without showing alert |
| create-resource-014 | must-display-create-error | Create callback throws Error("Network timeout") | Error message "Network timeout" displays inline; buttons remain enabled for retry |
| create-resource-015 | must-display-create-error | Create callback throws non-Error object | Error message "Failed to create." displays inline |
| create-resource-016 | must-invoke-onsaveerror-on-create-failure | Create callback throws; onSaveError is provided | onSaveError callback is invoked with the exception |
| create-resource-017 | must-guard-close-on-dirty | User clicks Cancel; draft is dirty | UnsavedChangesAlert is shown; dialog is not closed |
| create-resource-018 | must-guard-close-on-dirty | User clicks ×; draft is pristine | Dialog closes immediately without showing alert |
| create-resource-019 | must-not-close-on-backdrop-click | User clicks overlay background | Dialog remains open |
| create-resource-020 | must-route-escape-through-guard | User presses Escape; draft is dirty | UnsavedChangesAlert is shown |
| create-resource-021 | must-route-escape-through-guard | User presses Escape while alert is open | Alert is dismissed (mapped to Stay); dialog remains open |
| create-resource-022 | must-route-escape-through-guard | User presses Escape; draft is pristine | Dialog closes without showing alert |
| create-resource-023 | must-support-optional-save-gate | saveEnabled returns false | Save button is disabled even if draft is dirty |
| create-resource-024 | must-support-optional-save-gate | saveEnabled returns true and draft is dirty | Save button is enabled |
| create-resource-025 | must-render-only-on-client | Component is rendered on server (document is undefined) | Component returns null |

## Edge Cases

- **Blank state is taken as given**: `blank` is passed as the lazy initializer to both `useState<TInput>(blank)` and the `pristine` baseline. The component MUST accept whatever it returns — including `null`, `undefined`, or an empty object — without inspecting, validating, or sanitizing it. Supplying a usable initial draft is the host's contract, and an unusable one surfaces only through `renderForm` or `validate`.
- **`validate` throws**: `save()` calls `validate(draft)` before and outside the `try` block, which wraps only `create`. An exception thrown by `validate` therefore propagates out of the Save click handler uncaught: no inline error is set, `setSaving(true)` is never reached, `onSaveError` is not called, and the dialog stays open with the draft intact. Implementations MUST NOT throw from `validate`; the contract is to return an error string or `null`.
- **Async error handling**: The `create` callback may throw; the component catches any exception and displays its message. If the error is not an Error instance, a default message is shown.
- **Empty error from validate**: If `validate` returns an empty string or null, it is treated as success. An empty string is falsy in JavaScript and will not trigger the error display.
- **Rapid successive saves**: If the user clicks Save while a create operation is in progress, the button is disabled, preventing a second invocation.
- **Memory cleanup**: The Escape key listener is added via `useEffect` and removed on unmount; if the component unmounts while an operation is in progress, the promise will complete but `setSaving` will not be called (React's useState cleanup).
- **Draft state mutations**: The component uses `useState` and JSON.stringify for dirty checking; if draft mutations are nested objects, shallow equality is not used, so all nested changes are detected.
- **Callback identity**: `validate`, `create`, `onClose`, `onCreated`, and `renderForm` are captured in closures; if they change on re-render, the old closures are used until the component re-renders.
- **Portal target unavailable**: If `document.body` is not yet available, the portal will fail silently (React createPortal behavior).
- **Non-deterministic `blank`**: `blank` is invoked twice — once for `draft` and once for the `pristine` baseline — and `dirty` compares the two results with `JSON.stringify`. A `blank` that returns a fresh identifier, timestamp, or other varying value on each call MUST be avoided: the two initial values differ, so the dialog reports itself dirty at mount, Save is enabled before any edit, and the Discard/Stay alert is raised on the first close.
- **Focus on open and close**: The source calls no focus API, so focus stays on whatever element opened the dialog, Tab can leave the dialog for content behind the overlay, and nothing restores focus when the dialog closes. This gap is recorded once, in Accessibility.

## Configuration

| Option | Type | Required | Default | Description |
|--------|------|----------|---------|-------------|
| `ariaLabel` | string | Yes | — | Accessibility label for the dialog container |
| `heading` | string | Yes | — | Dialog heading/title rendered as h2 |
| `blank` | () => TInput | Yes | — | Factory function that returns the initial pristine state for the form |
| `validate` | (draft: TInput) => string \| null | Yes | — | Validation function; returns null if valid, error message string if invalid |
| `create` | (draft: TInput) => Promise<TResult> | Yes | — | Async resource creation function; throws on error |
| `onClose` | () => void | Yes | — | Callback invoked when the user closes the dialog without saving |
| `onCreated` | (result: TResult) => void | Yes | — | Callback invoked when create succeeds |
| `renderForm` | (draft: TInput, onChange: (next: TInput) => void, error: string \| null) => ReactNode | Yes | — | Render function for form fields; receives draft state, onChange handler, and error message |
| `saveEnabled` | (draft: TInput) => boolean | No | undefined | Optional gate function; returns true to enable Save beyond the pristine check, false to disable |
| `onSaveError` | (err: unknown) => void | No | undefined | Optional telemetry callback invoked when create fails; the error is also displayed inline |

## Deep Linking

Not applicable: This component is a reusable container for form creation and does not define its own deep-linking routes. Deep linking is the responsibility of the host application.

## Localization

| String Key | Default (en) | Context |
|-----------|-------------|---------|
| `button.cancel` | "Cancel" | Cancel button label |
| `button.save` | "Save" | Save button label (default state) |
| `button.saving` | "Saving..." | Save button label while async operation is in progress |
| `button.close` | "Close" | Close button aria-label |

The `heading` prop is application-provided and not localized by the component.

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | No transition or animation is applied. The overlay and the dialog card carry only static layout, color, and shadow classes — no `transition-*`, `animate-*`, or keyframe class appears on either — so the dialog appears and disappears instantly. Nothing to disable under Reduce Motion. |
| Increase Contrast | No explicit contrast requirements are defined in the source. Component styling defers to theme tokens (apt-text, apt-surface, apt-border); theme implementation is responsible for contrast ratios. |
| Differentiate Without Color | No color-only differentiators are used; buttons are labeled and error messages are text-based. |

## Feature Flags

Not implemented: Component behavior is fully enabled; no feature flags gate functionality.

## Analytics

Not implemented: Component does not emit analytics events; telemetry for creation failures is handled via the `onSaveError` callback, which is the responsibility of the host application.

## Privacy

Not applicable: Component does not collect, store, or transmit data. It renders a form and passes the draft to the `create` callback; all data handling is the responsibility of the host.

## Logging

Not implemented: Component does not emit logs. Errors from `create` are surfaced inline to the user and optionally passed to `onSaveError`.

## Platform Notes

- **SwiftUI**: Start from `.sheet(isPresented:)` on macOS or `.fullScreenCover(isPresented:)` on iOS, with the dialog body built from a `@ViewBuilder` closure standing in for `renderForm`. Hold `draft`, `pristine`, `error`, `saving`, and `confirming` in `@State` on the presented view, and drive Save's `.disabled(saving || !canSave)` from the same `dirty && saveEnabled` expression. Run `create` from a `Task` and catch into the inline error text. Express the Discard/Stay guard with `.confirmationDialog` carrying a `.destructive` Discard button and a `.cancel` Stay button. What differs from the source: SwiftUI has no portal, and a sheet already presents outside the host's view hierarchy, so there is no stacking-context or `inert` ancestor problem to escape; and SwiftUI dismisses a sheet on Escape and on the interactive swipe-down by default, so set `.interactiveDismissDisabled(true)` and route Escape yourself through a button carrying `.keyboardShortcut(.cancelAction)` to preserve the rule that only Save, Cancel, or × dismisses.

- **Compose**: Start from `Dialog` with `DialogProperties(dismissOnClickOutside = false, dismissOnBackPress = false)` — both set false is what reproduces the source's inert backdrop and guarded Escape — wrapping a `Surface(shape = RoundedCornerShape(12.dp))` that holds a title `Text` styled `MaterialTheme.typography.titleMedium`, the caller's `@Composable` form slot, and a `Row(horizontalArrangement = Arrangement.End)` of `TextButton("Cancel")` and `Button("Save")`. Keep `draft`, `error`, `saving`, and `confirming` in `remember { mutableStateOf(...) }`, and launch `create` from `rememberCoroutineScope().launch` with try/catch. Show the Discard/Stay guard as a second `AlertDialog` composed as a sibling of the first, not nested inside it. What differs from the source: hardware Back is the Escape analogue, so intercept it with `BackHandler(enabled = true) { requestClose() }`; and `Dialog` renders into its own window already, so no portal equivalent is needed.

- **React/Web**: This is the source platform. `packages/web/packages/ui/src/blocks/create-resource-dialog.tsx` is a client component (`"use client"`) built on `useState`, `useEffect`, and `createPortal` into `document.body`; `../components/button` supplies Cancel, Save, and the `icon-sm` ghost ×, and `../components/unsaved-changes-alert` supplies the Discard/Stay alert. Specific to this file: the portal target is `document.body` and nothing narrower, because a `fixed` overlay left inside the pane that opened it inherits that pane's `inert` and `aria-hidden` in narrow mode as well as any ancestor stacking context or `overflow: hidden`; `UnsavedChangesAlert` is rendered as a sibling of the overlay rather than nested inside it, for the same reason; the window-level `keydown` listener exists because `UnsavedChangesAlert` is `destructive` and blocks Escape itself; and the `typeof document === "undefined"` guard returns `null` so the component is inert during SSR. Styling is Tailwind utilities over the `apt-border`, `apt-surface`, and `apt-text` theme tokens.

- **AppKit / UIKit**: On macOS start from an `NSPanel` run as a sheet via `beginSheet(_:completionHandler:)` on the document window; on iOS start from a `UIViewController` presented with `modalPresentationStyle = .formSheet`. Put the form in a child view controller supplied by the caller, and the Cancel/Save pair in a trailing-aligned `UIStackView`. Reproduce the guard on iOS by setting `isModalInPresentation = true` so pull-to-dismiss cannot discard a dirty draft, and implementing `presentationControllerDidAttemptToDismiss` to raise a `UIAlertController` with a `.destructive` Discard action and a `.cancel` Stay action; on macOS gate `endSheet(_:)` behind the same alert. What differs from the source: Escape arrives through the responder chain — `cancel(_:)` on macOS, a `UIKeyCommand` bound to `UIKeyCommand.inputEscape` on iOS — rather than a global `keydown` listener, and both frameworks confine focus within a modal presentation automatically, which the web source does not do.

- **WinUI 3**: Start from `ContentDialog` with `PrimaryButtonText="Save"`, `CloseButtonText="Cancel"`, `DefaultButton="Primary"`, and a `Grid` in its `Content` holding the form. Bind `IsPrimaryButtonEnabled` with `x:Bind CanSave, Mode=OneWay` to a view-model property computed as `IsDirty && (SaveGate?.Invoke(Draft) ?? true)`. Reproduce the guarded close by handling `Closing`: take the `ContentDialogClosingDeferral`, and while `IsDirty` is true set `args.Cancel = true` and show a second `ContentDialog` carrying the Discard/Stay choice, completing the deferral only on Discard — this is what stops the Cancel button and the built-in Escape from discarding a half-filled form. Reproduce the async Save by handling `PrimaryButtonClick`: set `args.Cancel = true`, take a `ContentDialogButtonClickDeferral`, await the create call, and `Hide()` only on success; on failure set an `ErrorMessage` property bound to an `InfoBar` with `Severity="Error"` inside the dialog content and leave the dialog open. Drive the "Saving…" label and both disabled buttons from an `IsSaving` property, and express the Default, Dirty, Saving, and Error appearances as `VisualState` entries in a `VisualStateGroup` on the content root. Set `XamlRoot` from the invoking element: this is WinUI's equivalent of the source's portal, attaching the dialog to the window's popup root rather than the invoking element's subtree, so no ancestor clipping or stacking context applies. Map the `apt-border`, `apt-surface`, and `apt-text` token values to `ThemeResource` entries under `ResourceDictionary.ThemeDictionaries` so light and dark both resolve.

## Design Decisions

**Portal to document.body**: The component portals to `document.body` rather than rendering inline. This is necessary because ancestors of the open button may have `overflow: hidden`, `overflow: auto`, or own a stacking context that clips or hides content outside their bounds. A `fixed` positioned dialog that is a descendant of such an ancestor will be clipped. Additionally, in the hierarchical pane stack where this component is used, ancestors above the focused pane are marked `inert` and `aria-hidden` in narrow mode, which would prevent keyboard and screen reader interaction if the dialog remained a descendant. Portaling to the body escapes both constraints.

**Focus is not managed**: The source implements no focus behavior — no initial focus, no confinement, and no restoration on close — and records no rationale for the omission. It is documented here as an unresolved gap rather than a decision; the Focus management entry in Accessibility states what would settle it. Escape, Cancel, and × do give keyboard users an unambiguous close path, which is why the omission does not leave the dialog unreachable by keyboard.

**Dirty state via JSON.stringify**: Draft state is compared to pristine state using `JSON.stringify` serialization. This approach is simple and handles nested objects and arrays. The trade-off is performance: large drafts may incur serialization overhead on every state change. A future optimization could use a structural comparison library or a custom dirty-flag pattern.

**Unsaved-changes guard only on close**: The unsaved-changes check is triggered only on close (Cancel, ×, Escape), not on Save. This means validation failure does not show the alert; only explicit close actions do. This prevents modal churn when the user corrects validation errors and retries.

**Synchronous validation, then async creation**: Validation is synchronous and must complete before creation. This allows immediate feedback for client-side errors (empty fields, format violations). Server-side checks (uniqueness, availability) are deferred to the `create` callback, which is async. The `saveEnabled` optional gate allows async pre-checks to gate the Save button before the user even attempts save.

**Optional onSaveError hook**: The `onSaveError` callback is optional and intended for telemetry/logging. Its absence does not prevent error handling or display; errors are shown inline regardless. This allows implementations that do not need telemetry to omit the callback.

**renderForm as pure composition**: The `renderForm` callback receives draft, onChange, and error. It is responsible for rendering all form fields and is not constrained to a specific form library or field structure. This allows maximum flexibility for different domain forms.

## Compliance

Not applicable: Component compliance is the responsibility of implementations that use it.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.1.0 | 2026-09-22 | Mike Fullerton | Answer the blank-state, validate-throw, and Reduce Motion questions from the source; keep modal focus management as the one open gap; rewrite Platform Notes to the template's five bullets with concrete per-platform guidance |
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
