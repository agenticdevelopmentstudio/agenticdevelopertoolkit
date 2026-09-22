---
id: 526da033-2f0d-4bd7-b2c2-99faba4783a3
title: Category Rename Dialog
domain: agenticdevelopertoolkit://recipes/category-rename-dialog
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Modal dialog for renaming a single category with duplicate-name validation.
platforms:
- typescript
- web
tags:
- dialog
- rename
- form
- validation
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Category Rename Dialog

## Overview

A modal dialog that allows renaming a single category or item. The component validates the new name against existing items to prevent duplicates, accepts async rename operations, and provides error feedback when validation or the rename operation fails. It is used in contexts where a category rename is safe from anywhere (moves nothing, unfiles nothing) and a confirm step prevents accidental changes.

## Behavioral Requirements

- **must-display-when-open**: Component MUST display a modal dialog when `open` is `true`.
- **must-render-nothing-when-closed**: Component MUST render `null` when `open` is `false` and the component has never received a truthy `node` prop.
- **must-prefill-current-name**: Component MUST pre-fill the input field with the current node's name when the dialog opens.
- **must-require-non-empty-name**: Component MUST reject submission if the trimmed input is an empty string, displaying the error message: `A ${noun} needs a name.`
- **must-reject-unchanged-name**: Component MUST close without calling `onRename` if the trimmed input matches the original node name (case-sensitive comparison after trim).
- **must-validate-duplicate-names**: Component MUST reject submission if the trimmed input name matches any existing node name (case-insensitive), excluding the node being renamed, displaying the error message: `There is already a ${noun} called "${name}".`
- **must-validate-extra-names**: Component MUST check the `extraNames` array for duplicates (case-insensitive) and reject submission if a match is found (excluding the original node name itself).
- **must-accept-enter-key**: Component MUST trigger submission when the user presses Enter within the text input field.
- **must-show-loading-state**: Component MUST set `disabled={true}` on the input and show a loading state in the confirm button while `onRename` is executing.
- **must-clear-error-on-input**: Component MUST clear any error message when the user modifies the input text.
- **must-call-onrename**: Component MUST call `onRename(node, trimmedName)` with the trimmed input after all validation passes.
- **must-handle-async-rename**: Component MUST support async `onRename` (returns `Promise<void>`), display the error message if the promise rejects, and keep the dialog open on error.
- **must-call-onrenamed**: Component MUST call `onRenamed(node, trimmedName)` after a successful rename.
- **must-call-onclose-after-success**: Component MUST call `onClose()` after a successful rename.
- **must-prevent-close-while-busy**: Component MUST not close the dialog (via close button, escape key, or backdrop click) if a rename operation is in progress (`busy === true`).
- **must-disable-confirm-when-empty**: Component MUST set `disabled={true}` on the confirm button when the trimmed input is an empty string.
- **must-show-error-text**: Component MUST display validation and operation error messages in an error text component.

## Appearance

- **Corner radius**: Deferred to Dialog component implementation.
- **Padding**: Input field uses standard form spacing; error text is displayed inline below the input.
- **Font**: Uses system default input font; error text uses a distinct error-colored variant.
- **Background**: Dialog content uses light/dark mode theme from Dialog component.
- **Foreground/Text**: Input text is black (light mode) or white (dark mode); error text uses red/error color.
- **Border**: Input field uses standard form input border; dialog has no explicit border.
- **Shadow**: Dialog elevation/shadow deferred to Dialog component implementation.
- **Min/Max size**: Dialog content has `max-width: small` (typically 384px or similar).

## States

| State | Appearance change | Behavioral change |
|-------|------------------|-------------------|
| Closed | Dialog not rendered or hidden | Input value is not reset; only pre-filled on next open |
| Open (default) | Dialog visible, input focused | Ready for input; error message cleared |
| Focused | Input field has focus outline | User can type or press Enter to submit |
| Loading | Input disabled, confirm button shows loading indicator | All inputs disabled; dialog cannot close |
| Validation error | Error message displayed in red below input | Input remains enabled; confirm button disabled until error is fixed |
| Operation error | Error message displayed below input | Input enabled; user can edit and retry |

## Accessibility

- **Role**: Dialog with role implicit from Dialog component; input field is a text input.
- **Labels**: Input field MUST have `aria-label="New ${noun} name"` for screen readers.
- **Dialog title**: Dialog header contains `<DialogTitle>Rename {noun}</DialogTitle>` for context.
- **Dialog description**: Dialog header contains `<DialogDescription>This renames it everywhere it is used.</DialogDescription>`.
- **Keyboard navigation**: Input auto-focuses on dialog open; Tab moves between input and buttons; Enter submits; Escape closes (if not busy).
- **Error announcement**: Error text SHOULD be announced to screen readers (typically via ErrorText component ARIA attributes).
- **Announce loading state**: While `busy` is `true`, the confirm button SHOULD indicate loading (e.g., via aria-busy or button text change).
- **Minimum touch target**: Dialog buttons (Confirm, Cancel) MUST have touch targets of at least 44×44pt.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| rename-001 | must-display-when-open | `open={true}`, `node={categoryNode}` | Dialog is visible |
| rename-002 | must-render-nothing-when-closed | `open={false}`, `node={null}` | Component returns `null` |
| rename-003 | must-prefill-current-name | `open={true}`, `node={categoryNode}` where `node.name="Inventory"` | Input field displays "Inventory" |
| rename-004 | must-require-non-empty-name | User leaves input empty, clicks Confirm | Error message: "A category needs a name." |
| rename-005 | must-reject-unchanged-name | Input shows original name "Inventory", user clicks Confirm | Dialog closes without calling `onRename` |
| rename-006 | must-validate-duplicate-names | Input: "Armory", `nodes` includes node with `name="Armory"` (different id) | Error: "There is already a category called "Armory"." |
| rename-007 | must-validate-extra-names | Input: "Taken", `extraNames=["Taken"]` | Error: "There is already a category called "Taken"." |
| rename-008 | must-accept-enter-key | Input focused with text "NewName", user presses Enter | `onRename` is called (validation passes) |
| rename-009 | must-show-loading-state | `onRename` is async and pending | Input is disabled; confirm button shows loading state |
| rename-010 | must-clear-error-on-input | Error displayed, user types in input | Error message is cleared |
| rename-011 | must-call-onrename | User enters valid name "NewCategory" and submits | `onRename(node, "NewCategory")` is called |
| rename-012 | must-handle-async-rename | `onRename` returns rejected promise | Dialog remains open; error message displays rejection reason |
| rename-013 | must-call-onrenamed | Rename succeeds | `onRenamed(node, newName)` is called |
| rename-014 | must-call-onclose-after-success | Rename succeeds | `onClose()` is called |
| rename-015 | must-prevent-close-while-busy | User presses Escape while `busy={true}` | Dialog remains open |
| rename-016 | must-disable-confirm-when-empty | Input value is "", no input has occurred | Confirm button is disabled |
| rename-017 | must-show-error-text | Validation fails | Error text component displays error message |

## Edge Cases

- **Empty name after trim**: If input is whitespace only (e.g., "   "), component trims to "" and rejects with "needs a name" error. MUST behavior per requirement.
- **Duplicate check is case-insensitive**: Input "inventory" matches existing node "Inventory". Comparison uses `.toLowerCase()`. MUST behavior per requirement.
- **Unchanged name with different casing**: Input "INVENTORY" when current is "inventory" — these are different case-sensitive strings, so `onRename` is called. MUST behavior per requirement.
- **Extra names and node name coincidence**: If `extraNames` contains the original node name, the duplicate check at line 1010 excludes it from the taken check, allowing the user to "rename" to the same name (which then closes per must-reject-unchanged-name). MUST behavior per requirement.
- **Async onRename rejection**: If `onRename` throws or rejects, the error is caught at line 1022–1023; if the error is an `Error` instance, its message is displayed; otherwise, a generic message is shown. MUST behavior per requirement.
- **Dialog close while busy**: The `onOpenChange` callback at line 1032–1034 prevents close if `busy === true`. Escape and backdrop click are blocked. MUST behavior per requirement.
- **Null node while promise pending**: The component holds `node` via `useLastPresent`, so it survives the host clearing `target`; this allows the exit animation to complete before unmounting. MUST behavior per requirement.
- **Input re-seeding on re-open**: The effect at line 987–992 seeding the input only triggers when `open` changes to `true` with a non-null `target`, so reopening on null does not restore stale text. MUST behavior per requirement.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `open` | boolean | (required) | Whether the dialog is visible. |
| `node` | CategoryTreeNode &#124; null | null | The category being renamed. `null` renders nothing; the host may keep the dialog mounted between opens. |
| `nodes` | readonly CategoryTreeNode[] | (required) | The full vocabulary for duplicate-name validation. |
| `extraNames` | readonly string[] | [] | Additional names to treat as taken (e.g., names known to the host but not yet in `nodes`). |
| `noun` | string | (required) | Singular, lowercase term for microcopy (e.g., "category", "folder"). Interpolated into error messages and dialog title. |
| `onRename` | (node, nextName) => void &#124; Promise<void> | (required) | Async or sync callback to persist the rename. Receives the node and trimmed new name. |
| `onRenamed` | (node, nextName) => void &#124; undefined | undefined | Optional callback invoked after successful rename with the node and new name. |
| `onClose` | () => void | (required) | Callback invoked when the dialog closes (success, cancel, or unchanged name). |

## Deep Linking

Not applicable: This component is a modal dialog without independent deep-linking behavior. It is shown/hidden by host state, not navigated to directly.

## Localization

| String Key | Default (en) | Context | Notes |
|-----------|-------------|---------|-------|
| dialog.title | `Rename {noun}` | Dialog header title. Interpolated with `noun` prop. | |
| dialog.description | `This renames it everywhere it is used.` | Dialog header description. | Describes consequence of rename. |
| input.label | `New ${noun} name` | Input aria-label. Interpolated with `noun` prop. | Screen reader only. |
| error.empty-name | `A ${noun} needs a name.` | Validation error for empty trimmed input. Interpolated with `noun` prop. | |
| error.duplicate | `There is already a ${noun} called "${nextName}".` | Validation error for duplicate name. Interpolated with `noun` and attempted name. | Case-insensitive comparison. |
| button.confirm | `Rename` | Confirm button label. | |
| button.cancel | `Cancel` | Cancel button label. | |
| error.fallback | `Could not rename the ${noun}.` | Fallback error message if `onRename` rejects without an Error. Interpolated with `noun` prop. | |

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | Dialog open/close transitions should respect `prefers-reduced-motion`. Implemented at Dialog component level. |
| Increase Contrast | Error text color should meet minimum contrast ratio (4.5:1) with background. Dialog component should adjust if theme supports. |
| Differentiate Without Color | Error state MUST NOT be conveyed by color alone; error text label or icon should accompany color change. |

## Feature Flags

Not applicable: Component has no feature flag integration in source code.

## Analytics

| Event | Properties | When |
|-------|-----------|------|
| `category_rename_dialog.opened` | `{}` | Dialog becomes visible (`open` changes to `true`). |
| `category_rename_dialog.renamed` | `{ noun: string, newName: string }` | Rename completes successfully. |
| `category_rename_dialog.cancelled` | `{}` | User closes dialog without renaming (cancel button or Escape). |
| `category_rename_dialog.error` | `{ reason: string, noun: string }` | Validation error or `onRename` rejection. |

## Privacy

- **Data collected**: Component does not collect any telemetry or analytics data independently. Host is responsible for any analytics instrumentation.
- **Storage**: Component stores only local state (input text, error message, busy flag) in React state, no localStorage or server storage.
- **Transmission**: Component does not transmit data directly. The `onRename` callback is invoked by the host to transmit renamed node data via host's API.
- **Retention**: Local state is discarded when component unmounts. No persistent data is retained.

## Logging

Not applicable: Component has no logging implementation in source code. Host is responsible for any error or event logging via callbacks.

## Platform Notes

- **React/Web**: The source (`category-rename-dialog.tsx`) uses Dialog, Input, and DialogActions from a shared UI component library. Customization points are the Dialog component's styling props (e.g., `className="max-w-sm"`), Input component behavior (autoFocus, disabled, aria-label), and ErrorText rendering. Validation logic is co-located with the component; duplicate checking happens in-memory before the async `onRename` call to prevent corrupting duplicates on the server.

- **SwiftUI**: Start with a `.sheet` or `.confirmationDialog` modifier controlling visibility via the `open` binding. Use a `TextField` for input with a `.onSubmit` handler for Enter key. Bind the input text to a `@State` variable. Implement duplicate validation before calling the async `onRename` closure. Use a `.disabled()` modifier on the TextField and confirm button while an async operation is pending. Display validation errors in a separate Text view styled with `.foregroundColor(.red)`.

- **Compose (Kotlin)**: Use a `Dialog` composable for the modal. Place a `TextField` (or `OutlinedTextField`) with `autofocus` enabled inside the dialog. Implement a `KeyEvent.Key.Enter` handler in the TextField's `onKeyEvent` lambda to trigger submission. Manage duplicate validation and async `onRename` in a ViewModel using coroutines. Disable the TextField and confirm button while the rename operation is in-flight (use a `LaunchedEffect` or `rememberCoroutineScope`). Display error messages in a `Text` composable below the input with red text color.

- **AppKit / UIKit**: Use `NSAlert` (macOS) or `UIAlertController` (iOS) for the modal. Add a single text field via `addTextField()` with placeholder text and keyboard return type set to `.done`. Implement a target-action handler for the return key (or use a text field delegate) to trigger validation and submission. Display validation errors by re-presenting the alert or updating an error label below the text field. Block the close button or escape key while an async operation is pending by managing the `NSAlert` button state or the controller's dismissal state.

- **WinUI 3**: Use `ContentDialog` for the modal. Place a `TextBox` control inside the dialog with `IsEnabled` binding to reflect the busy state. Handle the `KeyDown` event on the TextBox to detect Enter and trigger submission. Implement duplicate validation in code-behind or via a ViewModel (MVVM pattern). Disable the `IsPrimaryButtonEnabled` property on the dialog's primary button (Rename) while async operations are pending. Display validation errors in a `TextBlock` below the TextBox, styled with a `Foreground` color of `{StaticResource SystemControlErrorTextForeground}`.

## Design Decisions

- **Duplicate validation in-component, not server-side**: The duplicate check happens before `onRename` is called, preventing the server from creating duplicates via a generic CRUD update that has no uniqueness lock. Traceability: lines 1007–1015.

- **useLastPresent for exit animation**: The component holds `node` via `useLastPresent(target)` so the exit transition completes before the component unmounts. If unmounting happened immediately when `target` became null, the dialog's open-to-closed transition would be cut off. Traceability: lines 979–980.

- **Input seeding only on open**: The effect re-seeds the input only when `open` becomes `true` with a non-null `target`, not on every `target` change. This prevents reopening on null from restoring stale text. Traceability: lines 987–992.

- **Case-insensitive but display-preserving duplicates**: Duplicate checks use `.toLowerCase()` to ignore case (lines 1008, 1009–1010), but the error message displays the user's typed name as-is (line 1013), not a normalized version. This respects user intent while preventing case-only renames.

- **Enter submits, Escape closes**: Enter key (line 1053) commits; Escape is handled by the Dialog component itself (line 1032), not by the input. This is a common web dialog pattern.

- **Unchanged name closes silently**: If the user submits without changing the name, the dialog closes via `onClose()` without calling `onRename` (lines 1003–1005). This avoids a no-op server round-trip.

- **Error message includes attempted name**: The duplicate error message includes the user's attempted name in quotes (line 1013) so the user sees exactly what they tried to use.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| [must-have-keyboard-submit](agenticdevelopercookbook://compliance/accessibility#must-have-keyboard-submit) | passed | Accessibility — Enter key submits from the input field. |
| [must-have-escape-close](agenticdevelopercookbook://compliance/accessibility#must-have-escape-close) | passed | Accessibility — Escape key closes the dialog (unless busy). |
| [must-prevent-invalid-state](agenticdevelopercookbook://compliance/form-validation#must-prevent-invalid-state) | passed | Form Validation — Confirm button disabled when input is empty; duplicates rejected before submission. |
| [must-show-validation-error](agenticdevelopercookbook://compliance/form-validation#must-show-validation-error) | passed | Form Validation — Validation errors displayed inline below the input field. |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
