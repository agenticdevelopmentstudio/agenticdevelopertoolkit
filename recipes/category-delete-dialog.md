---
id: 0d85c3a1-c754-4d8b-8aab-6565dfee6100
title: Category Delete Dialog
domain: agenticdevelopertoolkit://recipes/category-delete-dialog
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Modal confirmation dialog for deleting a category, with warnings about orphaned
  subcategories.
platforms:
- typescript
- web
tags:
- dialog
- deletion
- confirmation
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Category Delete Dialog

## Overview

A modal confirmation dialog that appears when the user initiates deletion of a category from a hierarchical category tree. The dialog explains the semantics of category deletion — that the filing is deleted but filed items are not — and lists any subcategories that will be orphaned and also deleted as a result. The component renders nothing if no category is currently selected for deletion.

## Behavioral Requirements

- **must-render-dialog-when-open**: The component MUST render a modal dialog when `open` is `true` and `node` is not `null`.
- **must-not-render-when-node-null**: The component MUST render nothing (return `null`) when `node` is `null`, regardless of the `open` state.
- **must-display-category-name-in-title**: The dialog MUST display the category name in the title as `Delete "{node.name}"?`.
- **must-display-main-explanation**: The dialog MUST display text explaining that deletion deletes the category filing only, not items filed under it. The text MUST state "This deletes the category only. Any {itemNoun} filed under it are not deleted — they become uncategorized."
- **must-display-orphaned-names-when-present**: When `orphanedNames.length > 0`, the dialog MUST display the list of orphaned subcategory names as a comma-separated strong-formatted string.
- **must-pluralize-orphaned-message**: When one subcategory is orphaned (`orphanedNames.length === 1`), the message MUST read "This subcategory is filed nowhere else, so it is deleted too:". When more than one is orphaned (`orphanedNames.length > 1`), it MUST read "These subcategories are filed nowhere else, so they are deleted too:".
- **must-display-error-when-present**: When `error` is a non-null, non-empty string, the component MUST display the error text via `DialogErrorText`.
- **must-maintain-node-name-during-transition**: The component MUST maintain display of the node name even after the host clears the `node` prop to `null`, until the dialog's dismissal animation is complete. This is achieved via `useLastPresent`, which holds the previous non-null `node` value.
- **must-show-busy-indicator-when-true**: When `busy` is `true`, the dialog MUST show a loading or disabled indicator on the action buttons.
- **must-call-onconfirm-on-delete**: When the user clicks the "Delete" button, the component MUST call `onConfirm()`.
- **must-call-oncancel-on-cancel**: When the user clicks the "Cancel" button, the component MUST call `onCancel()`.
- **must-use-error-tone-styling**: The dialog MUST render with `tone="error"` styling from `AlertModal`.
- **must-mark-as-destructive**: The dialog MUST render with `destructive` flag set, signaling to the user that the action is irreversible.

## Appearance

Not applicable: The component delegates all visual styling to the `AlertModal` component, which owns appearance properties including corner radius, padding, font, colors, borders, shadows, and size constraints. The source code does not define appearance directly.

## States

| State | Appearance change |
|-------|------------------|
| Default | Dialog displayed with title, description, and action buttons visible |
| Busy | Action buttons disabled or show loading indicator while confirmation is processing |
| Error | Error text appended to description in red or error color token (per AlertModal styling) |
| Orphaned subcategories present | Additional message block inserted in description listing orphaned category names |
| Orphaned subcategories absent | Orphaned message block not rendered |

## Accessibility

- **role**: The component MUST render as a dialog with role `alertdialog` (via `AlertModal`).
- **description**: The component MUST provide an accessible description containing the main explanation text and orphaned warnings. The description MUST be associated via `DialogDescription`.
- **button-labels**: Action buttons MUST have explicit labels: "Delete" for the destructive action and "Cancel" for the dismissal action.
- **focus-management**: Focus MUST be managed by the `AlertModal` component — trapped within the dialog and returned to the trigger element on dismissal.
- **semantic-structure**: The description uses block-level `<span>` elements instead of `<p>` to avoid nesting violations inside `DialogDescription`, ensuring the full text is included in the accessible description.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| category-delete-001 | must-render-dialog-when-open | `open={true}`, `node={mockNode}` | Dialog modal appears on screen |
| category-delete-002 | must-not-render-when-node-null | `open={true}`, `node={null}` | Component returns `null`; nothing rendered |
| category-delete-003 | must-display-category-name-in-title | `node={{ name: "Projects" }}` | Dialog title shows `Delete "Projects"?` |
| category-delete-004 | must-display-main-explanation | `itemNoun="notes"` | Description includes "This deletes the category only. Any notes filed under it are not deleted — they become uncategorized." |
| category-delete-005 | must-display-orphaned-names-when-present | `orphanedNames={["Archived", "Draft"]}` | Description includes "Archived, Draft" as a strong string |
| category-delete-006 | must-pluralize-orphaned-message | `orphanedNames={["Archive"]}` (length 1) | Message reads "This subcategory is filed nowhere else, so it is deleted too:" |
| category-delete-007 | must-pluralize-orphaned-message | `orphanedNames={["Archive", "Draft"]}` (length > 1) | Message reads "These subcategories are filed nowhere else, so they are deleted too:" |
| category-delete-008 | must-display-error-when-present | `error="Network error"` | Error text appears in description via `DialogErrorText` |
| category-delete-009 | must-show-busy-indicator-when-true | `busy={true}` | Action buttons show disabled or loading state |
| category-delete-010 | must-call-onconfirm-on-delete | User clicks "Delete" button | `onConfirm()` callback is invoked |
| category-delete-011 | must-call-oncancel-on-cancel | User clicks "Cancel" button | `onCancel()` callback is invoked |
| category-delete-012 | must-maintain-node-name-during-transition | Host sets `node={null}` while dialog is closing | Title and description still show the previous node's name until animation completes |

## Edge Cases

- **Empty orphanedNames array**: When `orphanedNames` is an empty array (default), the orphaned subcategories message block MUST NOT be rendered. Only the main explanation appears.
- **Null node prop at open time**: If `open={true}` but `node={null}`, the component returns `null` and no dialog is rendered. This is correct behavior; the host MUST ensure node is non-null before opening.
- **Null error prop**: When `error` is `null` or not provided (default), no error text is displayed. The `DialogErrorText` component handles this gracefully.
- **Multiple orphaned names**: When `orphanedNames` contains more than two entries, all MUST be displayed as a comma-separated string. The component joins them via `orphanedNames.join(", ")` without truncation or ellipsis.
- **Busy state during cancellation**: If the user clicks "Cancel" while `busy={true}`, the `onCancel` callback MUST still be invoked. The host controls the `busy` prop and SHOULD clear it after the action completes.
- **Dialog closed externally**: If the host sets `open={false}` while the dialog is rendering, the `AlertModal` MUST trigger the dismissal animation. The `onCancel` callback is not automatically invoked by the component; the host MUST handle this if desired.
- **Very long category or subcategory names**: The component does not truncate or ellipsize names. Long names will wrap or overflow per the container's CSS constraints, delegated to `AlertModal` styling.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `open` | `boolean` | — | Controls whether the dialog is visible. REQUIRED. |
| `node` | `CategoryTreeNode \| null` | — | The category to delete. When `null`, component renders nothing. REQUIRED. |
| `orphanedNames` | `readonly string[]` | `[]` | Names of subcategories that will be orphaned by deletion. Optional; an empty array hides the orphaned message. |
| `itemNoun` | `string` | — | The plural, lowercase name of items filed in categories (e.g., "notes", "documents"). Inserted into the main explanation text. REQUIRED. |
| `error` | `string \| null` | `null` | Error message to display, or `null` if no error. Optional. |
| `busy` | `boolean` | `false` | Indicates an async action (e.g., API call) is in progress. Disables action buttons when `true`. Optional. |
| `onConfirm` | `() => void` | — | Callback invoked when the user clicks "Delete". REQUIRED. |
| `onCancel` | `() => void` | — | Callback invoked when the user clicks "Cancel". REQUIRED. |

## Deep Linking

Not applicable: This is a modal dialog component, not a routable view. It is triggered by parent state, not by deep links or URL parameters.

## Localization

| String Key | Default (en) | Context |
|-----------|-------------|---------|
| `dialog.title.delete` | `Delete "{categoryName}"?` | Dialog title; category name inserted via template string |
| `dialog.label.main` | `This deletes the category only. Any {itemNoun} filed under it are not deleted — they become uncategorized.` | Main explanation; `itemNoun` is dynamic per host |
| `dialog.label.orphaned.singular` | `This subcategory is filed nowhere else, so it is deleted too:` | Message when exactly one subcategory is orphaned |
| `dialog.label.orphaned.plural` | `These subcategories are filed nowhere else, so they are deleted too:` | Message when more than one subcategory is orphaned |
| `dialog.label.orphaned.items` | `Their {itemNoun} become uncategorized as well.` | Trailing sentence for orphaned section; `itemNoun` is dynamic |
| `dialog.button.delete` | `Delete` | Primary action button label |
| `dialog.button.cancel` | `Cancel` | Dismissal button label |

## Accessibility Options

Not applicable: The component does not expose or respond to display accessibility options such as Reduce Motion, Increase Contrast, or Differentiate Without Color. These are handled by the host application's global settings and the `AlertModal` component's implementation.

## Feature Flags

Not applicable: The component is not gated behind feature flags. It is rendered unconditionally by the host based on the `open` prop.

## Analytics

Not applicable: The component does not emit analytics events directly. Event tracking is the responsibility of the host application, which should track user interactions (`onConfirm`, `onCancel`, error states) via its analytics service.

## Privacy

Not applicable: The component does not collect, store, transmit, or retain any user data. It displays user-provided data (category name, orphaned subcategory names, error messages) without modification or logging.

## Logging

Not applicable: The component does not emit structured logs or debug messages. Debugging and error logging are the responsibility of the host application or the `AlertModal` and `DialogErrorText` component implementations.

## Platform Notes

- **React/Web**: Use `AlertModal` from the UI component library, which wraps Base UI's Dialog with error styling. Pass `tone="error"` and `destructive={true}` to style the dialog as a destructive action. The description is rendered as a fragment of block-level `<span>` elements to avoid `<p>` nesting violations inside `DialogDescription`. The component integrates with `useLastPresent` hook to retain the node name during the dismissal animation.
- **SwiftUI**: Implement as a `Sheet` or `Alert` presented modally with a red/error tint. Use the native confirmation dialog pattern (`confirmationDialog` modifier with a `destructive` button role for the delete action). SwiftUI's `@State` can replace `useLastPresent` by storing the previous non-null node in a separate state variable that updates on a slight delay during dismissal.
- **Compose**: Build as a Material `AlertDialog` with `confirmButton` styled as a destructive red button and `dismissButton` as the cancel action. Use Compose state hoisting (`remember`) to retain the node name during animation. The orphaned subcategory message is conditionally rendered with `if (orphanedNames.isNotEmpty())`.
- **AppKit / UIKit**: Use `UIAlertController(style: .alert)` for iOS or `NSAlert` for macOS. The title is formatted as `Delete "{name}"?`. Present the description as a formatted `NSAttributedString` with bold emphasis on the orphaned category names and the strong phrases. Manage the retained node name using a property that persists across the dismiss animation.
- **WinUI 3**: Implement as a `ContentDialog` with `Title = Delete "{name}"?` and `PrimaryButtonText = "Delete"` / `SecondaryButtonText = "Cancel"`. Set `IsPrimaryButtonEnabled = !busy` and `IsSecondaryButtonEnabled = !busy`. The description uses `RichTextBlock` or multiple `TextBlock` elements to achieve bold formatting on key phrases and category names. The `PrimaryButtonClick` event invokes `onConfirm`; `SecondaryButtonClick` invokes `onCancel`. Use a local retained variable to hold the node name for the duration of the dismiss animation, similar to `useLastPresent`.

## Design Decisions

- **No translation of the main explanation**: The component relies on the host to provide `itemNoun` (e.g., "notes", "documents") but does not translate the structure of the explanation sentence. This allows hosts in different contexts (task management, note-taking) to use the same component with domain-appropriate vocabulary.
- **Block-level spans instead of paragraphs**: The description uses `<span className="block">` rather than `<p>` elements because `AlertModal` wraps the entire description fragment in a `DialogDescription` (`<p>`). Nesting `<p>` inside `<p>` is invalid HTML, causing the browser to close the outer `<p>` and re-parent the inner content outside the accessible description. This would break the dialog's accessible name. Block-level spans preserve line breaks without violating HTML structure.
- **Retained node name during transition**: The `useLastPresent` hook holds the previous non-null `node` value after the host clears it. This allows the dialog to fade out while still showing the name of the category being deleted, rather than showing empty or a fallback label. This UX choice prioritizes clarity during the dismissal animation.
- **No automatic error recovery**: The component does not retry or clear errors automatically. Error state is entirely host-controlled via the `error` prop. The host MUST manage error display logic and clear the error when appropriate.
- **Orphaned subcategories computed by host**: The `orphanedNames` array is computed by the host, not by the component. This ensures the warning matches the exact state of the category tree the user is viewing, even if the tree is displayed in multiple places (e.g., a sidebar).

## Compliance

Not applicable: No compliance checks are defined for this component. Compliance with data protection, accessibility standards, or platform policies is the responsibility of the host application integrating this dialog.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
