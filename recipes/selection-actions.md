---
id: 86aedf2f-b353-4770-a6dd-9e29b3d9b76a
title: Selection Actions
domain: agenticdevelopercookbook://ingredients/selection-actions
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A toolbar strip of action buttons that operate on selected items, with a
  destructive Delete behind confirmation.
platforms:
- typescript
- web
tags:
- selection
- toolbar
- actions
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Selection Actions

## Overview

Selection Actions is a toolbar component that renders a configurable strip of action buttons for operating on selected items from a list. Each action is a button that receives the array of currently selected item IDs. The component optionally includes a destructive Delete button that requires user confirmation via a modal before executing the delete callback. Actions without selection requirements (such as "New" actions) remain enabled when no items are selected; actions with selection requirements become disabled. Dividers can visually group related actions.

The component renders no container of its own — it is designed to be placed in a toolbar context such as a `ListHeader`'s `actions` slot, which provides the visual styling and layout.

## Behavioral Requirements

- **must-render-action-buttons**: The component MUST render each provided action as a `Button` element.
- **must-pass-selected-ids-on-action**: When an action button is clicked, the component MUST call the action's `onClick` callback with the array of currently selected IDs.
- **must-disable-selection-required-actions**: Actions with `requiresSelection: true` MUST be disabled when the `selectedIds` array is empty.
- **must-keep-standalone-actions-enabled**: Actions without `requiresSelection` or with `requiresSelection: false` MUST remain enabled regardless of selection state.
- **must-use-ghost-variant-by-default**: Each action button MUST use the `ghost` variant unless the action specifies a different variant.
- **must-render-divider-before-action**: If an action has `dividerBefore: true`, the component MUST render a vertical separator before that action.
- **must-render-delete-button-conditionally**: The Delete button MUST render only if the `onDelete` callback is provided.
- **must-disable-delete-when-no-selection**: The Delete button MUST be disabled when the `selectedIds` array is empty.
- **must-use-destructive-ghost-delete-variant**: The Delete button MUST use the `destructive-ghost` variant.
- **must-include-trash-icon-on-delete**: The Delete button MUST display a Trash2 icon with the label "Delete".
- **must-show-delete-confirmation-modal**: When the Delete button is clicked, the component MUST display a confirmation modal before calling the `onDelete` callback.
- **must-call-ondelete-only-after-confirm**: The `onDelete` callback MUST be called only after the user confirms deletion in the modal.
- **must-use-default-delete-message**: If `deleteConfirm` is not provided, the modal MUST display the default title "Delete selected?".
- **must-use-custom-delete-message**: If `deleteConfirm` is provided with a `title` and optional `description`, the modal MUST use those values instead of the defaults.
- **must-close-modal-on-cancel**: When the user cancels the delete confirmation modal, the component MUST close the modal without calling `onDelete`.
- **must-render-divider-as-separator-role**: Dividers MUST use the ARIA `separator` role with `aria-orientation="vertical"` to communicate grouping to assistive technology.

## Appearance

- **Button size**: `sm` — small button size consistent with toolbar context
- **Action button variant**: `ghost` (default) or custom variant from action definition
- **Delete button variant**: `destructive-ghost`
- **Divider styling**: 1px width, height 5 units (20px at 16px base), background `apt-border` color, 4px horizontal margin (`mx-1`)
- **Divider orientation**: Vertical
- **Icon**: Trash2 icon (from lucide-react), positioned inline before text with `data-icon="inline-start"`
- **No container**: The component renders only buttons, dividers, and the modal — no wrapper element.

## States

| State | Appearance change |
|-------|------------------|
| Default | Action or Delete button is enabled and clickable |
| Disabled (selection-required action, no selection) | Action button is greyed out and non-interactive |
| Disabled (Delete, no selection) | Delete button is greyed out and non-interactive |
| Deleting (confirmation modal open) | Modal overlay appears with destructive styling |

## Accessibility

- Role: Buttons are standard `<button>` elements with implicit button role.
- Labels: Each action button uses the text from `action.label` (can be React node). Delete button uses the hardcoded label "Delete".
- Dividers: Separators use ARIA `role="separator"` with `aria-orientation="vertical"` to communicate structural grouping to screen reader users.
- State announcement: Disabled state is implicit in the button's `disabled` attribute; browser and assistive technology automatically announce disabled buttons.
- Touch target: Buttons follow the small size (`sm`) from the Button component, which MUST meet platform minimum touch target requirements (44×44pt on iOS, 48×48dp on Android, 44px on web per WCAG).
- Modal accessibility: The AlertModal component MUST provide its own focus management, role attributes, and keyboard dismissal (Escape key).

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| selection-actions-001 | must-render-action-buttons | actions=[{id:"a1", label:"Archive"}] | Button with text "Archive" is rendered |
| selection-actions-002 | must-pass-selected-ids-on-action | actions=[{id:"a1", label:"Archive", onClick}], selectedIds=["row1","row2"], user clicks Archive | onClick is called with ["row1","row2"] |
| selection-actions-003 | must-disable-selection-required-actions | actions=[{id:"a1", label:"Archive", requiresSelection:true}], selectedIds=[] | Archive button is disabled (disabled attribute set) |
| selection-actions-004 | must-keep-standalone-actions-enabled | actions=[{id:"a1", label:"New", requiresSelection:false}], selectedIds=[] | New button is enabled and clickable |
| selection-actions-005 | must-use-ghost-variant-by-default | actions=[{id:"a1", label:"Archive"}] | Archive button uses ghost variant |
| selection-actions-006 | must-render-divider-before-action | actions=[{id:"a1", label:"Archive", dividerBefore:true}] | Vertical separator (div with role="separator") is rendered before Archive button |
| selection-actions-007 | must-render-delete-button-conditionally | onDelete undefined | Delete button is not rendered |
| selection-actions-008 | must-render-delete-button-conditionally | onDelete provided | Delete button is rendered |
| selection-actions-009 | must-disable-delete-when-no-selection | onDelete provided, selectedIds=[] | Delete button is disabled |
| selection-actions-010 | must-disable-delete-when-no-selection | onDelete provided, selectedIds=["row1"] | Delete button is enabled |
| selection-actions-011 | must-use-destructive-ghost-delete-variant | onDelete provided | Delete button uses destructive-ghost variant |
| selection-actions-012 | must-include-trash-icon-on-delete | onDelete provided | Delete button contains Trash2 icon and text "Delete" |
| selection-actions-013 | must-show-delete-confirmation-modal | onDelete provided, user clicks Delete | AlertModal appears with destructive styling |
| selection-actions-014 | must-use-default-delete-message | onDelete provided, deleteConfirm undefined, user clicks Delete | Modal title is "Delete selected?" |
| selection-actions-015 | must-use-custom-delete-message | onDelete provided, deleteConfirm={title:"Remove items?"}, user clicks Delete | Modal title is "Remove items?" |
| selection-actions-016 | must-call-ondelete-only-after-confirm | onDelete provided, selectedIds=["row1"], user clicks Delete then confirms | onDelete is called with ["row1"] |
| selection-actions-017 | must-close-modal-on-cancel | onDelete provided, user clicks Delete then clicks Cancel | Modal closes, onDelete is not called |
| selection-actions-018 | must-render-divider-as-separator-role | actions=[{dividerBefore:true}] | Divider has role="separator" and aria-orientation="vertical" |

## Edge Cases

- **No actions provided**: When `actions` is an empty array, no action buttons are rendered (only the Delete button if `onDelete` is provided).
- **No delete callback**: When `onDelete` is undefined, the Delete button does not render at all. The component functions with only custom actions.
- **Empty selected IDs**: When `selectedIds` is an empty array, all selection-required actions are disabled and the Delete button is disabled, but standalone actions remain enabled.
- **Multiple simultaneous selections**: The component receives an array of IDs and passes all of them to action handlers. No limit is enforced on the array length.
- **Rapid action clicks**: Each action handler is called independently when its button is clicked. No debouncing or click prevention is implemented; it is the action handler's responsibility to manage race conditions or duplicate invocations.
- **Modal already visible**: If the user clicks Delete while the confirmation modal is open, no additional modal is created (React state prevents re-rendering multiple modals).
- **Custom action variant**: An action can override the default `ghost` variant by specifying a `variant` property matching Button's variant prop.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `selectedIds` | `string[]` | (required) | Array of IDs of currently selected rows. The caller is responsible for pruning IDs that have left the list. |
| `actions` | `ListAction[]` | `[]` | Array of action definitions. Each action defines an `id`, `label`, and `onClick` handler. Actions may optionally specify `requiresSelection`, `dividerBefore`, and `variant`. |
| `onDelete` | `(selectedIds: string[]) => void` | undefined | Callback invoked after the user confirms deletion. If undefined, the Delete button does not render. |
| `deleteConfirm` | `{ title: string; description?: ReactNode }` | undefined | Custom modal message for the delete confirmation. If undefined, the default title "Delete selected?" is used. |

## Deep Linking

Not applicable: Selection Actions is a toolbar component that operates on state within the current view. It does not navigate to a new destination and does not support deep linking.

## Localization

Not applicable: The component's only hardcoded strings are "Delete selected?" (default modal title) and "Delete" (button label). Localization of these strings is the responsibility of the parent application via the `deleteConfirm` prop and action `label` definitions.

## Accessibility Options

- **Reduce Motion**: The component itself does not define motion; animation handling is delegated to the Button and AlertModal components. It SHOULD respond to prefers-reduced-motion if those components do.
- **Increase Contrast**: The Button component's styling MUST meet Increase Contrast requirements; Selection Actions adds no additional styling that would interfere.
- **Differentiate Without Color**: Disabled state MUST be communicated via the button's disabled attribute (browser default), not by color alone. Dividers use color; their separating function is structural and announced via ARIA role, not color-dependent.

## Feature Flags

Not applicable: Selection Actions is a stateless component that has no conditional features or runtime toggles.

## Analytics

- **action.clicked**: When the user clicks any action button, the parent application MAY emit an analytics event naming the action and selection state. Selection Actions does not emit events internally.
- **delete.initiated**: When the Delete button is clicked, the confirmation modal appears. The parent application MAY track this as an intent-to-delete event.
- **delete.confirmed**: When the user confirms deletion in the modal, the parent application MAY emit an event after `onDelete` is called.
- **delete.cancelled**: When the user cancels the delete confirmation, the parent application MAY track this if needed.

Analytics implementation is the responsibility of the parent application and action handlers; Selection Actions provides no built-in analytics.

## Privacy

Not applicable: Selection Actions does not collect, store, or transmit any data. It operates solely on data provided by the caller (`selectedIds` and `actions`) and passes selection state to action handlers.

## Logging

Not applicable: Selection Actions does not emit logs. Logging of action invocations and delete operations is the responsibility of the parent application and the handlers it provides.

## Platform Notes

- **React/Web**: Selection Actions is implemented as a React functional component (`SelectionActions`) that returns a fragment with Button elements from the shared ui/button component, Trash2 icon from lucide-react, and an AlertModal from the shared ui/components/alert-modal. The component uses standard DOM elements (div for dividers with ARIA roles). All styling is applied via Tailwind CSS classes (`mx-1 h-5 w-px bg-apt-border`). See `packages/web/packages/ui/src/blocks/selection-actions.tsx`.
- **SwiftUI**: Start from a `HStack` or `ToolbarItemGroup` in the toolbar placement. Render action buttons using SwiftUI's `Button` with `.ghost` style variant. Implement selection-required actions by binding their `disabled` state to `selectedIds.isEmpty`. For the Delete button, bind its `disabled` state to `selectedIds.isEmpty` and use a `.destructive` style. Handle the confirmation with a `.confirmationDialog` that appears when a `@State var confirming: Bool` is true. Pass the selected IDs array to each action closure.
- **Compose (Kotlin)**: Start with a `Row` modifier on a toolbar lambda. Render action buttons using Compose's `Button` composable with content color from the ghost theme (typically inverse of primary). Use `enabled` parameter bound to selection state for requiresSelection actions. For Delete, use a destructive button style and show a confirmation dialog (AlertDialog) when the user taps it. Pass selected IDs to each lambda callback.
- **AppKit / UIKit**: On macOS (AppKit), use `NSToolbar` with custom `NSToolbarItem` instances for each action, implemented as `NSButton` with `.ghost` bezel style. On iOS (UIKit), implement as a `UIView` containing `UIButton` subviews arranged horizontally in a `UIStackView`. Bind button enabled state to the selection array's isEmpty property. For the Delete button, use the system red/destructive appearance and present a `UIAlertController` confirmation dialog.
- **WinUI 3**: Implement as a `StackPanel` with `Orientation="Horizontal"` containing `Button` elements. Use the `Secondary` style for action buttons and `Accent` style with a red brush for the Delete button (or use the built-in `ErrorButton` style if available). Bind button `IsEnabled` to a converter evaluating `SelectedIds.Count == 0 && RequiresSelection`. Show the delete confirmation using `ContentDialog` with `IsPrimaryButtonEnabled="True"` and `IsSecondaryButtonEnabled="True"` for Confirm and Cancel.

## Design Decisions

1. **No container element**: The component renders only its children (buttons and dividers) in a Fragment and relies on the parent (ListHeader's actions slot) to provide layout and styling context. This keeps the component flexible and prevents nesting issues in toolbar contexts.

2. **Selection-required as opt-in**: The `requiresSelection` property defaults to `false` (or is omitted), meaning actions are enabled by default. This allows "New" and other standalone actions to work without requiring a selection. Actions that genuinely need a selection must explicitly declare `requiresSelection: true`.

3. **Delete as required confirmation**: Delete is always behind a confirmation modal, never immediate. This reflects the destructive nature of deletion and aligns with common UX patterns for irreversible actions.

4. **Divider as ARIA separator**: Dividers use the ARIA `separator` role rather than being purely visual, ensuring users of assistive technology understand the structural grouping of action buttons.

5. **Callback responsibility**: The component does not manage retry, undo, or error handling for action callbacks. Each action handler (and the `onDelete` callback) is fully responsible for managing its own error states, async operations, and side effects. This keeps Selection Actions lightweight and composable.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| WCAG 2.1 Level AA button roles and labels | passed | Accessibility |
| ARIA separator role for dividers | passed | Accessibility |
| Touch target size (delegated to Button component) | passed | Accessibility |
| No data collection or transmission | passed | Privacy |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
