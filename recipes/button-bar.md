---
id: 81db83fc-b30c-4ba3-b4d5-572dc8b4e335
title: Button Bar
domain: agenticdevelopercookbook://ingredients/button-bar
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A recessed editing toolbar that renders preset action buttons (New/Delete/Cancel/Save)
  or custom content.
platforms:
- typescript
- web
tags:
- toolbar
- editing-actions
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Button Bar

## Overview

The Button Bar is a recessed toolbar used for editing actions. It renders either a preset editing flow (Create/Delete/Cancel/Save) or arbitrary custom content (e.g., filters, selection actions). The component manages button enable/disable states based on draft validity and save progress, exposing control over visibility of the Create and Delete buttons to accommodate varying pane layouts.

## Behavioral Requirements

- **must-render-toolbar-role**: Component MUST render with `role="toolbar"`.
- **must-have-aria-label**: Component MUST accept and render an `ariaLabel` prop; the default MUST be `"Editing actions"`.
- **must-accept-children**: Component MUST accept a `children` prop to render arbitrary custom content, which takes precedence over preset actions.
- **must-support-preset-actions**: When `children` is not provided and `actions` is provided, the component MUST render the preset editing action flow.
- **must-render-create-button**: When rendering preset actions and `showCreate` is `true` and `actions.onCreate` is provided, the component MUST render a button with a Plus icon and a label (default `"New"`, or `actions.createLabel` if provided).
- **must-render-delete-button**: When rendering preset actions and `showDelete` is `true` and `actions.onDelete` is provided, the component MUST render a destructive-styled button with a Trash2 icon and the label `"Delete"`.
- **must-render-cancel-button**: When rendering preset actions and `actions` is provided, the component MUST render a button with an X icon and the label `"Cancel"`.
- **must-render-save-button**: When rendering preset actions and `actions` is provided, the component MUST render a button with a Check icon and the label `"Save"` or `"Saving…"` when `actions.saving` is `true`.
- **must-disable-cancel-by-flag**: The Cancel button MUST be disabled when `actions.canCancel` is `false` or `actions.saving` is `true`.
- **must-disable-save-by-flag**: The Save button MUST be disabled when `actions.canSave` is `false` or `actions.saving` is `true`.
- **must-disable-delete-by-flag**: The Delete button MUST be disabled when `actions.canDelete` is `false` or `actions.saving` is `true`.
- **must-disable-create-while-saving**: The Create button MUST be disabled when `actions.saving` is `true`.
- **must-apply-save-disabled-styling**: When the Save button is disabled, the component MUST apply a muted text color class (`text-apt-text-muted`).
- **must-render-vertical-separator**: When rendering preset actions and a Create button is present, the component MUST render a vertical separator (visual divider, marked `aria-hidden`) between Create and Delete/Cancel buttons.
- **must-render-spacer**: When rendering preset actions, the component MUST render a flexible spacer between Delete and Save/Cancel groups that expands to fill available horizontal space.
- **must-support-leading-content**: Component MUST accept a `leading` prop to render content before the action buttons or children.
- **must-accept-class-override**: Component MUST accept a `className` prop that is merged with the base styling.
- **must-invoke-callbacks**: The component MUST invoke `actions.onCreate()`, `actions.onCancel()`, `actions.onSave()`, or `actions.onDelete()` when the respective button is clicked.

## Appearance

- **Layout**: Horizontal flex layout, gap of 1 unit between children
- **Border**: Top and bottom borders (1px), using the `apt-border` color token
- **Background**: Recessed background using the `apt-bg` color token
- **Padding**: Horizontal (px-6 = 24px), Vertical (py-2 = 8px)
- **Button size**: Small (`sm`), as defined by the shared Button component
- **Text color (normal)**: Inherited from Button variant (default text color for ghost and default variants)
- **Text color (disabled Save)**: Muted text using `text-apt-text-muted` token
- **Icon placement**: Inline with text, at the start of the button label (via `data-icon="inline-start"`)
- **Separator width**: 1px, height 5 units (20px)
- **Separator color**: Uses `apt-border` color token

## States

| State | Appearance change |
|-------|------------------|
| Default (all enabled) | Buttons render in their normal variant (ghost for Cancel/Create/Delete, default for Save); text is not muted |
| Saving | Save button shows "Saving…" instead of "Save"; all buttons (Create, Delete, Cancel, Save) appear disabled with `disabled` attribute; Save text is muted |
| Cancel disabled | Cancel button appears grayed out / disabled |
| Save disabled (valid draft but no dirty changes) | Save button appears in ghost variant with muted text, does not accept clicks |
| Delete disabled | Delete button appears grayed out / disabled |
| Create disabled (while saving) | Create button appears grayed out / disabled |

## Accessibility

- **Role**: Toolbar, signaled via `role="toolbar"`
- **Label**: Toolbar MUST have a descriptive `aria-label`; default is `"Editing actions"`
- **Button labels**: Each button (Create, Cancel, Save, Delete) MUST have visible text; icons are decorative (`data-icon="inline-start"` indicates icon placement)
- **Disabled state**: Disabled buttons MUST have the `disabled` HTML attribute set
- **Separator**: Visual separators between button groups MUST be marked `aria-hidden="true"` to prevent screen reader announcements
- **Loading indicator**: When `actions.saving` is `true`, the Save button text changes to `"Saving…"` to provide feedback; this is the accessible indicator of the saving state (not an aria-live region)
- **Keyboard interaction**: Buttons MUST be keyboard accessible and focusable per the shared Button component's implementation
- **Touch target**: Buttons inherit minimum touch target size from the shared Button component (`sm` size); verify this meets at least 44×44pt per platform HIG
- **Semantic structure**: No `aria-pressed`, `aria-checked`, or other state attributes beyond `disabled`; the button text change ("Save" → "Saving…") is the state indicator

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| button-bar-001 | must-render-toolbar-role | Render ButtonBar with default props | Element has `role="toolbar"` |
| button-bar-002 | must-have-aria-label | Render ButtonBar with default props | Element has `aria-label="Editing actions"` |
| button-bar-003 | must-have-aria-label | Render ButtonBar with `ariaLabel="Custom"` | Element has `aria-label="Custom"` |
| button-bar-004 | must-accept-children | Render with `children={<div>Custom</div>}` | Custom content appears inside toolbar; preset actions are not rendered |
| button-bar-005 | must-support-preset-actions, must-render-create-button | Render with `actions={{ onCreate: fn, ... }}` and `showCreate={true}` and `actions.onCreate` is defined | Create button with Plus icon and "New" label renders |
| button-bar-006 | must-render-create-button | Render with `actions={{ onCreate: fn, createLabel: "Add" }}` and `showCreate={true}` | Create button renders with label "Add" |
| button-bar-007 | must-render-create-button | Render with `showCreate={false}` | Create button does not render |
| button-bar-008 | must-render-delete-button | Render with `actions={{ onDelete: fn, ... }}` and `showDelete={true}` and `actions.onDelete` is defined | Delete button with Trash2 icon and "Delete" label renders with destructive-ghost variant |
| button-bar-009 | must-render-delete-button | Render with `showDelete={false}` | Delete button does not render |
| button-bar-010 | must-render-cancel-button | Render with `actions={{ onCancel: fn, ... }}` | Cancel button with X icon and "Cancel" label renders |
| button-bar-011 | must-render-save-button | Render with `actions={{ onSave: fn, ... }}` and `saving={false}` | Save button with Check icon and "Save" label renders |
| button-bar-012 | must-render-save-button | Render with `actions={{ onSave: fn, ... }}` and `saving={true}` | Save button with Check icon and "Saving…" label renders |
| button-bar-013 | must-disable-cancel-by-flag | Render with `actions={{ canCancel: false, ... }}` | Cancel button has `disabled` attribute |
| button-bar-014 | must-disable-cancel-by-flag | Render with `actions={{ canCancel: true, saving: true }}` | Cancel button has `disabled` attribute |
| button-bar-015 | must-disable-save-by-flag | Render with `actions={{ canSave: false, ... }}` | Save button has `disabled` attribute |
| button-bar-016 | must-disable-save-by-flag | Render with `actions={{ canSave: false, ... }}` | Save button has `text-apt-text-muted` class |
| button-bar-017 | must-disable-save-by-flag | Render with `actions={{ canSave: true, saving: true }}` | Save button has `disabled` attribute |
| button-bar-018 | must-disable-delete-by-flag | Render with `actions={{ canDelete: false, ... }}` | Delete button has `disabled` attribute |
| button-bar-019 | must-disable-delete-by-flag | Render with `actions={{ canDelete: false, ... }}` and `actions.onDelete` is defined | Delete button has `disabled` attribute |
| button-bar-020 | must-disable-delete-by-flag | Render with `actions={{ canDelete: true, saving: true }}` | Delete button has `disabled` attribute |
| button-bar-021 | must-disable-create-while-saving | Render with `actions={{ onCreate: fn, saving: true }}` and `showCreate={true}` | Create button has `disabled` attribute |
| button-bar-022 | must-apply-save-disabled-styling | Render with `actions={{ canSave: false }}` | Save button renders with `text-apt-text-muted` class and ghost variant |
| button-bar-023 | must-invoke-callbacks | User clicks Create button | `actions.onCreate()` is invoked |
| button-bar-024 | must-invoke-callbacks | User clicks Cancel button | `actions.onCancel()` is invoked |
| button-bar-025 | must-invoke-callbacks | User clicks Save button while `canSave={true}` and `saving={false}` | `actions.onSave()` is invoked |
| button-bar-026 | must-invoke-callbacks | User clicks Delete button | `actions.onDelete()` is invoked |
| button-bar-027 | must-support-leading-content | Render with `leading={<span>Title</span>}` | Leading content renders before action buttons |
| button-bar-028 | must-accept-class-override | Render with `className="custom-class"` | Custom class is applied to the toolbar element alongside base classes |

## Edge Cases

- **Missing `actions` and no `children`**: If neither `actions` nor `children` is provided, the toolbar renders with only the border, background, and padding applied; no buttons or content. This is not an error state; it is a valid composition for a pane that implements its own button logic elsewhere. Behavior: MUST render an empty recessed bar.
- **Both `actions` and `children` provided**: When both are present, `children` takes precedence and `actions` is ignored. Behavior: MUST render only the custom children and suppress the preset action flow.
- **`onCreate` not provided but `showCreate={true}`**: The Create button MUST NOT render (checked by the guard `showCreate && onCreate && (...)` in the source). Behavior: MUST skip the Create button and separator.
- **`onDelete` not provided but `showDelete={true}`**: The Delete button MUST NOT render (same guard logic). Behavior: MUST skip the Delete button.
- **`canDelete` not provided**: The Delete button defaults to `undefined`, which is falsy in the context of `!canDelete`. Behavior: MUST render the Delete button as disabled if `onDelete` is provided and `showDelete` is true.
- **`saving` not provided**: Defaults to `false`. Buttons do not appear disabled due to saving state. Behavior: MUST treat as no save in progress.
- **Click while `disabled={true}`**: Native HTML `disabled` attribute prevents click events from firing. Behavior: MUST not invoke the callback.
- **Rapid clicks while saving**: Once `saving={true}`, the Save button is disabled. If the user clicks very quickly before the parent updates `saving={false}`, the second click does not fire because the button is disabled. Behavior: MUST rely on the HTML `disabled` attribute for race condition protection.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `actions` | `ButtonBarActions` (optional) | `undefined` | Preset editing actions object. When provided and `children` is not provided, the preset action flow renders. |
| `showCreate` | `boolean` | `true` | Controls visibility of the Create button when rendering preset actions. |
| `showDelete` | `boolean` | `true` | Controls visibility of the Delete button when rendering preset actions. |
| `leading` | `ReactNode` | `undefined` | Content to render before action buttons or children (e.g., a pane title). |
| `children` | `ReactNode` | `undefined` | Arbitrary content that overrides preset actions when provided. |
| `ariaLabel` | `string` | `"Editing actions"` | Accessible label for the toolbar. |
| `className` | `string` | `undefined` | Additional CSS classes merged with base styling. |

## Deep Linking

Not applicable: This component is an editing toolbar with no independent deep-linking semantics. Navigation is the responsibility of the buttons' click handlers and the parent page logic.

## Localization

| String Key | Default (en) | Context |
|-----------|-------------|---------|
| `button_bar.create_label` | "New" | Label for the Create button; `actions.createLabel` in code |
| `button_bar.cancel_label` | "Cancel" | Label for the Cancel button (hardcoded in code) |
| `button_bar.save_label` | "Save" | Label for the Save button when not saving |
| `button_bar.saving_label` | "Saving…" | Label for the Save button while a save is in flight |
| `button_bar.delete_label` | "Delete" | Label for the Delete button (hardcoded in code) |
| `button_bar.toolbar_label` | "Editing actions" | Default aria-label for the toolbar |

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | Buttons inherit Reduce Motion behavior from the shared Button component. Behavior MUST NOT include animated transitions when this option is active. The text change from "Save" to "Saving…" does not require animation and is compliant. |
| Increase Contrast | Buttons inherit Increase Contrast behavior from the shared Button component. The muted text color (`text-apt-text-muted`) for disabled Save button MUST maintain sufficient contrast when Increase Contrast is enabled. |
| Differentiate Without Color | Buttons MUST be distinguishable without relying on color alone; the disabled state is indicated by both color and the HTML `disabled` attribute. The destructive-ghost variant for Delete MUST be distinguishable via shape, icon, or other non-color properties. |

## Feature Flags

Not applicable: This is a presentational UI component with no feature-flag integration in the source code. Feature flags are the responsibility of the parent component logic that calls ButtonBar.

## Analytics

Not applicable: This component does not fire analytics events. Analytics instrumentation is the responsibility of the callbacks provided in the `actions` prop (`onCreate`, `onCancel`, `onSave`, `onDelete`); the parent page logic MUST wrap these callbacks with analytics tracking if needed.

## Privacy

Not applicable: This component does not collect, store, or transmit personal data. It is a stateless presentation component.

## Logging

Not applicable: The component does not emit logs. Logging (if needed) is the responsibility of the callbacks provided by the parent component.

## Platform Notes

- **Web/React**: The component is defined in `packages/web/packages/ui/src/blocks/button-bar.tsx`. It composes the shared Button component with Lucide React icons (Plus, Trash2, X, Check). The styling uses Tailwind utility classes with design tokens (`apt-bg`, `apt-border`, `apt-text-muted`). The toolbar role and aria-label are applied via the root `div`. The separator is a 1px × 20px div with `aria-hidden="true"`.

- **SwiftUI**: Compose a HStack with equal spacing and a Divider. Use a separate struct for EditingActions. The Save button background should transition to an accent color when enabled; when saving, show a ProgressView overlay and disable interaction. The Cancel and Save buttons MUST respond to keyboard shortcuts (e.g., Esc for Cancel). Use AccessibilityElement with role "toolbar" and label on the parent VStack.

- **Compose**: Build with Row and Spacer. Create a composable EditingActions that renders the buttons in order: Create (if shown) | Divider | Delete (if shown) | Spacer | Cancel + Save. The Save button MUST transition to a primary/accent tint when enabled and show a loading indicator (CircularProgressIndicator or similar) when saving. Use the Material 3 Button variants (Filled, Outlined, Tonal) aligned to the design system. Apply semantics { contentDescription = "Editing actions" } to the root Row.

- **AppKit / UIKit**: For iOS, use a toolbar at the bottom with UIBarButtonItems or a custom view built from UIButton. The Save button MUST be tinted with an accent color when enabled and MUST show a UIActivityIndicatorView when saving. For macOS, use NSToolbar or an NSView with NSButton instances, respecting window-level toolbars and the recessed appearance. Buttons MUST support keyboard shortcuts and respond to space/Enter for activation. Accessibility: set `accessibilityRole = .toolbar` and provide a label via `accessibilityLabel`.

- **WinUI 3**: Implement using a Grid with ColumnSpacings and a SolidColorBrush for the recessed background. Use the Button control with Style set to a custom theme for "ghost" and "default" variants. The separator is a Rectangle with a thin stroke. The Save button MUST have a different fill or border color when enabled (accent color) and MUST disable all buttons when a save operation is in flight. For keyboard support, bind Enter key to the Save button and Escape to Cancel (using KeyboardAcceleratorPlacement). Apply AutomationProperties.Name = "Editing actions" and AutomationProperties.AutomationId = "ButtonBar" to the root Grid for UI Automation accessibility.

## Design Decisions

The component derives its single inert-ness state from one source of truth: `saveDisabled = !canSave || saving`. This single derivation ensures that the button's visual variant, disabled state, and text label are all consistent: a button that reads "Saving…" is guaranteed to have `disabled={true}`, and a disabled Save button is guaranteed to show muted text and the ghost variant. This prevents the visual inconsistency of a "gold, enabled-looking button" that reads "Saving…" and ignores clicks.

The preset editing action flow (Create/Delete/Cancel/Save) is optional and composable. Consumers can either use the preset flow by passing `actions`, or implement their own button logic by passing `children`. This design accommodates both simple panes (single-record editors with no Create/Delete) and complex list toolbars (filters, selection actions). The separator between Create and Delete is rendered only when Create is shown; this prevents orphaned visual dividers when Create is hidden.

The `ariaLabel` defaults to `"Editing actions"` rather than leaving it empty or undefined. This ensures that the toolbar is always accessible and labeled, even if the consumer forgets to set it. The `saving` boolean is optional and defaults to `false`; this reduces boilerplate for the simple case (panes that do not have async save logic). The `canDelete` flag is optional and defaults to `undefined`, which is treated as falsy; this allows consumers to omit `canDelete` entirely if delete is never available.

## Compliance

Not applicable: No platform-wide security, compliance, or data-protection concerns apply to this presentational UI component.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation from web implementation |
