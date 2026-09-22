---
id: 1be6e1bd-ee8c-4247-9020-c0d84356eb10
title: CategoryField
domain: agenticdevelopercookbook://ingredients/category-field
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Form row for selecting one category from a hierarchy, with inline rename
  from breadcrumb display.
platforms:
- typescript
- web
tags:
- form-control
- category-selection
- tree-navigation
depends-on: []
related:
- agenticdevelopercookbook://ingredients/tag-set-field
references: []
approved-by: ''
approved-date: ''
---

# CategoryField

## Overview

CategoryField is a form row component for selecting a single category from a hierarchy maintained by the owner. It combines autocomplete search (flat names) with a hierarchical browser, and displays the selected value as one or more breadcrumbs showing all filing paths when the category exists in multiple places in the hierarchy (DAG support). When a hierarchy is provided, breadcrumbs are interactive: clicking a breadcrumb crumb opens a modal to rename that category node in-place. The component adapts its terminology to the host's domain via the `noun` prop (e.g., "category", "topic", "tag class").

## Behavioral Requirements

- **must-render-combobox**: Component MUST render an autocomplete combobox input that accepts free-form text matching against the `options` list.
- **must-render-browser-button**: Component MUST render a "Choose…" button that opens an entity browser dialog to browse and create options.
- **must-update-value-on-combobox-change**: Component MUST call `onChange` with the new value when the combobox selection changes.
- **must-update-value-on-browser-select**: Component MUST call `onChange` with the new value when the entity browser dialog selects an option.
- **must-accept-value-not-in-options**: Component MUST allow `value` to hold a name not present in the `options` list (e.g., newly created or added by another surface), without requiring a pre-defined option.
- **must-display-breadcrumbs-when-nodes-provided**: Component MUST display one or more breadcrumb trails showing the filing path(s) of the selected value when a `nodes` hierarchy is provided and `value` resolves to a node.
- **must-show-all-filing-paths**: Component MUST display one breadcrumb trail per distinct filing path when a category node has multiple parents (DAG structure), allowing the user to see every place where the category is filed.
- **must-distinguish-aria-label-by-path-count**: Component MUST use `aria-label="<label> paths"` (plural) when multiple breadcrumb trails are displayed, and `aria-label="<label> path"` (singular) when one trail is displayed.
- **must-render-chevrons-between-breadcrumbs**: Component MUST display a 12px ChevronRight icon between each breadcrumb element in a trail to visually separate hierarchy levels.
- **must-hide-first-chevron**: Component MUST NOT render a chevron before the first breadcrumb in a trail.
- **must-style-leaf-breadcrumb-golden**: Component MUST render the final breadcrumb in each trail with `text-apt-gold` color to distinguish the selected node from its ancestors.
- **must-style-parent-breadcrumbs-muted**: Component MUST render non-leaf breadcrumbs with `text-apt-text-muted` color to de-emphasize ancestors.
- **must-truncate-long-breadcrumbs**: Component MUST truncate breadcrumb text with `truncate` class to prevent overflow on narrow viewports.
- **must-render-rename-button-when-onrename-provided**: Component MUST render each breadcrumb as a clickable button when `onRename` is provided and the component is not disabled.
- **must-render-static-breadcrumb-when-onrename-omitted**: Component MUST render breadcrumbs as static text spans when `onRename` is not provided.
- **must-render-static-breadcrumb-when-disabled**: Component MUST render breadcrumbs as static text spans when `disabled={true}`, regardless of whether `onRename` is provided.
- **must-label-rename-button-with-noun**: Component MUST set the rename button's `aria-label` to `"Rename <noun> <node.name>"` to announce the category name and action.
- **must-open-rename-dialog-on-crumb-click**: Component MUST open the CategoryRenameDialog modal when a breadcrumb button is clicked.
- **must-pass-node-to-rename-dialog**: Component MUST pass the clicked node, full `nodes` tree, current `value`, `noun`, and `onRename` callback to the CategoryRenameDialog.
- **must-close-rename-dialog-on-confirm-or-cancel**: Component MUST close the CategoryRenameDialog when the user confirms or cancels the rename action.
- **must-update-value-after-rename**: Component MUST call `onChange` with the new name when a rename succeeds and the renamed node is the currently selected node (`selected.id === renamed.id`), ensuring the field's value follows the node's new name.
- **must-NOT-update-value-after-rename-of-different-node**: Component MUST NOT call `onChange` if the renamed node is not the currently selected node.
- **must-respect-disabled-state**: Component MUST disable both combobox and entity chooser when `disabled={true}`, and MUST NOT allow rename button interaction when disabled.
- **must-accept-layout-prop**: Component MUST forward the `layout` prop ("stacked" or "inline") to the Field wrapper to control label positioning.
- **must-accept-custom-classname**: Component MUST apply the `className` prop to the Field wrapper for custom styling.
- **must-accept-hint-prop**: Component MUST render optional `hint` content passed to the Field wrapper.
- **must-hide-breadcrumbs-when-no-value**: Component MUST NOT render any breadcrumb trail when `value === ""` or when the `nodes` tree is empty.
- **must-hide-breadcrumbs-when-nodes-omitted**: Component MUST NOT render breadcrumb trails when `nodes` is omitted or empty, even if `value` is set.
- **must-set-combobox-placeholder-from-noun**: Component MUST set the combobox placeholder to `"Type a <noun>…"` using the `noun` prop.
- **must-set-browser-trigger-label-to-choose**: Component MUST set the entity chooser's trigger button label to `"Choose…"`.
- **must-pass-noun-to-browser-input-label**: Component MUST set the entity chooser's input label to `"Filter or add a <noun>"` and placeholder to `"Filter or add a <noun>…"` using the `noun` prop.
- **must-pass-noun-to-browser-aria-label**: Component MUST set the entity chooser's `ariaLabel` to `"Browse <label.toLowerCase()>"` to indicate the browsing action.

## Appearance

- **Container**: Vertical flex layout (`flex-col`) with 2rem gap between combobox/chooser row and breadcrumbs.
- **Breadcrumb row**: Horizontal flex layout, wrappable with `flex-wrap`, `items-center`, 0.25rem horizontal gap (`gap-x-1`), 0.125rem vertical gap (`gap-y-0.5`).
- **List items**: Flex row with 0.25rem gap (`gap-1`), `items-center`, `min-w-0` to allow truncation.
- **Chevrons**: 12px size, `shrink-0` (no flex), `text-apt-text-dim` color.
- **Breadcrumb text**: Font monospace, 12px size (`text-xs`), 2% letter spacing (`tracking-[0.02em]`), truncated.
- **Parent breadcrumbs**: `text-apt-text-muted` color.
- **Leaf breadcrumbs**: `text-apt-gold` color.
- **Rename button**: Rounded (`rounded`), monospace font, 12px, 2% letter spacing, no outline, hover brightens to `text-apt-text`, focus shows 2px ring of `apt-gold` at 40% opacity.
- **Input row**: Horizontal flex, `items-stretch`, 0.5rem gap.
- **Combobox wrapper**: `flex-1` to expand.
- **Entity chooser**: `w-44 shrink-0` (fixed width, no flex shrinking).
- **Field wrapper**: Passes through `layout` prop ("stacked" or "inline") for label positioning.

## States

| State | Appearance change | When |
|-------|------------------|------|
| Default | Combobox and chooser inputs are editable, breadcrumbs (if any) are static or interactive buttons. | Initial state when `disabled={false}` and no value or hierarchy conditions inhibit interactivity. |
| Disabled | Combobox and chooser are disabled (grayed out, non-interactive), breadcrumbs render as static text spans. | When `disabled={true}`. |
| No value | Breadcrumb section is hidden; combobox and chooser are visible and focused. | When `value === ""`. |
| No hierarchy | Breadcrumb section is hidden even if `value` is set; combobox and chooser are visible. | When `nodes` is omitted or empty. |
| Renaming | CategoryRenameDialog modal is open and centered over the component; combobox and chooser remain visible but input is not focused. | When user clicks a breadcrumb button and `onRename` is defined. |
| Rename success | Dialog closes, breadcrumbs update if the renamed node was selected; combobox value may update to follow the new name. | After `onRename` callback resolves successfully and `onRenamed` is called. |
| Rename error | Dialog remains open, displaying error message from the `onRename` rejection. | When `onRename` callback rejects or throws. |
| Multi-path | Multiple breadcrumb trails are displayed vertically. | When the selected category node has multiple parents in the hierarchy. |

## Accessibility

- **Role**: The breadcrumb section is a navigation landmark (`<nav>` element) with `aria-label` to describe the number and type of paths.
- **Breadcrumb list**: Each trail is a `<ol>` (ordered list) to convey hierarchy structure.
- **Rename button**: Type `button`, has `aria-label="Rename <noun> <node.name>"` to announce the action and the node being renamed.
- **Focus visible**: Rename buttons show `focus-visible:ring-2 focus-visible:ring-apt-gold/40` to provide a visible focus indicator.
- **Chevron separator**: Marked `aria-hidden` because it is decorative and not essential to understanding the structure.
- **Combobox**: Receives `ariaLabel={label}` from the Field's label to identify the control purpose.
- **Entity chooser**: Receives `ariaLabel="Browse <label.toLowerCase()>"` to announce the browsing intent.
- **Semantic structure**: Breadcrumbs use list structure (`<ol>`, `<li>`) to convey hierarchy; this is announced by assistive technology.
- **Label association**: The component is wrapped in a Field that associates the label with the input via `htmlFor` or an external label pattern.
- **Minimum tap target**: Not applicable; this is a form component composed of existing inputs (Combobox, EntityChooser, button) that each meet their own 44×44pt minimum.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| category-field-001 | must-render-combobox | Render with default props. | Combobox input is visible and accepts text input. |
| category-field-002 | must-render-browser-button | Render with default props. | "Choose…" button is visible and clickable. |
| category-field-003 | must-update-value-on-combobox-change | Type "test" in combobox and select from dropdown (assuming "test" is in options). | `onChange` is called with "test"; component's `value` prop becomes "test" on next render. |
| category-field-004 | must-update-value-on-browser-select | Click "Choose…", search/select an option in entity chooser, confirm selection. | `onChange` is called with selected option name; component re-renders with new value. |
| category-field-005 | must-accept-value-not-in-options | Render with `value="custom-name"` where "custom-name" is not in `options` list. | Component displays "custom-name" in combobox without error; breadcrumbs show it if `nodes` includes it. |
| category-field-006 | must-display-breadcrumbs-when-nodes-provided | Render with `value="leaf"`, `nodes` containing a tree with "leaf" at the end of a trail. | One breadcrumb trail is displayed with ancestors leading to "leaf". |
| category-field-007 | must-show-all-filing-paths | Render with `value="shared"` where "shared" node has two parents in `nodes`. | Two breadcrumb trails are displayed, each showing a different path to "shared". |
| category-field-008 | must-distinguish-aria-label-by-path-count | Render with one trail; then render with two trails. | `aria-label="<label> path"` (singular) for one trail; `aria-label="<label> paths"` (plural) for two or more trails. |
| category-field-009 | must-render-chevrons-between-breadcrumbs | Render breadcrumb trail with three nodes. | Two ChevronRight icons (12px) are visible between the three breadcrumbs, not before the first. |
| category-field-010 | must-hide-first-chevron | Render breadcrumb trail with two nodes. | No chevron appears before the first breadcrumb. |
| category-field-011 | must-style-leaf-breadcrumb-golden | Render breadcrumb trail with ancestor and leaf. | Leaf breadcrumb has `text-apt-gold`; ancestor has `text-apt-text-muted`. |
| category-field-012 | must-style-parent-breadcrumbs-muted | Render breadcrumb trail with three nodes. | First two nodes have `text-apt-text-muted`; third (leaf) has `text-apt-gold`. |
| category-field-013 | must-truncate-long-breadcrumbs | Render breadcrumb with very long node name in narrow container. | Text is truncated with ellipsis; no overflow occurs. |
| category-field-014 | must-render-rename-button-when-onrename-provided | Render with `onRename` callback and `disabled={false}`. | Each breadcrumb is a `<button>` element. |
| category-field-015 | must-render-static-breadcrumb-when-onrename-omitted | Render without `onRename` callback. | Breadcrumbs are `<span>` elements, not buttons. |
| category-field-016 | must-render-static-breadcrumb-when-disabled | Render with `onRename` callback but `disabled={true}`. | Breadcrumbs are `<span>` elements, not buttons. |
| category-field-017 | must-label-rename-button-with-noun | Render breadcrumb button with `noun="category"` and `node.name="taxonomy"`. | Button's `aria-label` is "Rename category taxonomy". |
| category-field-018 | must-open-rename-dialog-on-crumb-click | Render with `onRename` callback; click a breadcrumb button. | CategoryRenameDialog opens with `open={true}`. |
| category-field-019 | must-pass-node-to-rename-dialog | Click a breadcrumb to open rename dialog. | Dialog receives the clicked node via `node` prop and the `nodes` tree. |
| category-field-020 | must-close-rename-dialog-on-confirm-or-cancel | Rename dialog is open; user confirms or cancels. | Dialog closes (`renaming` state becomes `null`). |
| category-field-021 | must-update-value-after-rename | Selected node is renamed from "old" to "new"; confirm rename. | `onChange("new")` is called; next render shows breadcrumbs with "new" instead of "old". |
| category-field-022 | must-NOT-update-value-after-rename-of-different-node | Rename a node that is not the currently selected node; confirm. | `onChange` is NOT called; component's value remains unchanged. |
| category-field-023 | must-respect-disabled-state | Render with `disabled={true}`. | Both combobox and chooser have `disabled={true}` attribute; breadcrumbs are static text, rename buttons are inactive. |
| category-field-024 | must-accept-layout-prop | Render with `layout="inline"`. | Field passes layout to its internal label positioning logic; label and input appear side-by-side (or as configured). |
| category-field-025 | must-accept-custom-classname | Render with `className="custom-class"`. | Field wrapper receives the class; component is rendered with custom styling applied. |
| category-field-026 | must-accept-hint-prop | Render with `hint="Select a category from the list"`. | Hint text is displayed below the label (Field behavior). |
| category-field-027 | must-hide-breadcrumbs-when-no-value | Render with `value=""` and `nodes` provided. | Breadcrumb `<nav>` section is not rendered. |
| category-field-028 | must-hide-breadcrumbs-when-nodes-omitted | Render with `value="something"` but no `nodes` prop. | Breadcrumb `<nav>` section is not rendered. |
| category-field-029 | must-set-combobox-placeholder-from-noun | Render with `noun="topic"`. | Combobox placeholder is "Type a topic…". |
| category-field-030 | must-set-browser-trigger-label-to-choose | Render with default props. | Entity chooser trigger button label is "Choose…". |
| category-field-031 | must-pass-noun-to-browser-input-label | Render with `noun="skill"`. | Entity chooser input label is "Filter or add a skill"; placeholder is "Filter or add a skill…". |
| category-field-032 | must-pass-noun-to-browser-aria-label | Render with `label="Skills"`. | Entity chooser `ariaLabel` is "Browse skills". |

## Edge Cases

- **Empty `value` with `nodes` provided**: When `value === ""`, breadcrumbs do not render because `nodeForName` returns `null` and `categoryTrails` returns an empty array. MUST hide breadcrumb section.
- **`value` not found in `nodes`**: When `value` does not match any node in the tree, `nodeForName` returns `null` and breadcrumbs do not render. Component is still usable; the combobox and chooser remain active. MUST allow continued interaction.
- **`options` list and `nodes` tree are disconnected**: The autocomplete suggestions and the hierarchy are independent; a name may exist in `options` but not in `nodes`, or vice versa. MUST not enforce consistency between the two; this allows flexibility for incomplete hierarchies or names that exist elsewhere.
- **Category with multiple parents (DAG)**: When a category node has multiple parents, `categoryTrails` returns multiple trails. MUST display one `<ol>` per trail, each showing the distinct path to the leaf node. The user sees all filing locations at once.
- **Category renamed while form is in focus**: If `onRename` is called and succeeds, the dialog closes and `onRenamed` is invoked. If the renamed node is selected, the component calls `onChange` with the new name. MUST ensure the breadcrumbs reflect the new name; downstream handlers (e.g., form state) update accordingly. If the renamed node is not selected, the rename does not affect the current value. MUST not trigger unnecessary re-renders or loss of focus.
- **Rename cancelled by user**: When the user closes the rename dialog without confirming, `onClose` is called and `renaming` state is set to `null`. MUST close the dialog without modifying the component's value or breadcrumbs.
- **Rename rejected by callback**: If `onRename` callback rejects (throws or returns a rejected promise), the dialog remains open and displays an error message. MUST allow the user to retry or cancel. Component's value does not change.
- **Combobox with no matching options**: User types a string that does not match any option in the list. Combobox behavior is determined by the Combobox component; this component passes the typed value through `onChange` when confirmed. MUST allow free-form input.
- **Very long category names**: Category names longer than the viewport width will be truncated by the `truncate` class. MUST prevent text overflow; readability is preserved by focusing on the leaf node name (golden color draws attention).
- **Narrow viewport with multiple filings**: When breadcrumb trails wrap due to viewport width, the `flex-wrap` class allows trails to stack vertically. MUST display all trails; the component remains usable and accessible.
- **Disabled state interrupts rename flow**: If the component is disabled while a rename dialog is open (e.g., parent form disables the field), the dialog should close to prevent further interaction. SHOULD treat this as an edge case; the current implementation does not explicitly handle this scenario, relying on the host to manage state consistently.
- **Rapid successive renames**: If the user renames the same node multiple times in quick succession, each call to `onRename` is awaited. MUST queue or serialize calls to avoid race conditions (this is handled by the modal's single-open constraint and the callback pattern).

## Configuration

Not applicable: CategoryField is a form component that does not expose configuration options beyond its props (label, noun, options, nodes, value, callbacks, layout, disabled, className). Behavior is fully specified by props; no runtime configuration is needed.

## Deep Linking

Not applicable: CategoryField is a form control, not a navigational component. Deep linking is handled by the host application, not by the component itself.

## Localization

Not applicable: All user-facing text is provided by the host via props. The `label` prop is the row's caption; the `noun` prop is used to build microcopy ("Type a <noun>…", "Filter or add a <noun>"). The host is responsible for localizing these strings before passing them to the component. Category node names come from the hierarchy (nodes), which are also the host's responsibility to manage and localize.

## Accessibility Options

Not applicable: CategoryField does not directly respond to system-level accessibility options like Reduce Motion or Increase Contrast. It delegates to its child components (Combobox, EntityChooser, Field, CategoryRenameDialog), which handle their own accessibility feature support. The host and those child components are responsible for implementing motion, contrast, and other accessibility preferences.

## Feature Flags

Not applicable: CategoryField does not use feature flags. It is always present and functional when rendered.

## Analytics

Not applicable: CategoryField does not emit analytics events. The host is responsible for instrumentation. If the host needs to track category selection, rename actions, or browse-dialog usage, they must wire callbacks at the host level (onChange, onRename callbacks) to their analytics service.

## Privacy

Not applicable: CategoryField is a stateless form component. It does not collect, transmit, or store data beyond what the host passes in and receives via callbacks. Data privacy is the host's responsibility.

## Logging

Not applicable: CategoryField does not perform logging. Debug or diagnostic logging is the host's responsibility.

## Platform Notes

- **React/Web**: The implementation is in `packages/web/packages/ui/src/blocks/category-field.tsx`. Uses React hooks (`useState`) for rename modal state, re-exports `categoryTrails` and `CategoryTreeNode` from `category-tree.ts` for composability, delegates to `Field`, `Combobox`, `EntityChooser`, and `CategoryRenameDialog` components. Breadcrumbs are rendered as semantic lists (`<nav>`, `<ol>`, `<li>`) with proper ARIA roles and labels. Focus management and keyboard interaction are handled by child components.

- **SwiftUI**: Native equivalent would compose a Form section with a Picker or selection control for the autocomplete, a button to open the browsing interface, and a List or VStack to display breadcrumb trails. Implement the rename interaction via a Sheet or modal presentation. Use SwiftUI's focus and accessibility modifiers to provide keyboard and VoiceOver support. Consider using a @State variable to manage the rename sheet's open state.

- **Compose**: Implement as a Column containing a Row of Combobox and button inputs, followed by a LazyColumn for breadcrumb trails (each trail is a Row of Text elements separated by icons). Use Compose's `Modifier.clip(RoundedCornerShape(...))` for button styling. Manage rename dialog state with MutableState and display it via Dialog or custom Modal composable. Provide content descriptions for all interactive elements.

- **Kotlin**: Use Android's native Spinner or AutoCompleteTextView for autocomplete (or third-party library like Material Design 3's ExposedDropdownMenuBox). Implement breadcrumb display with a RecyclerView or Flow layout (FlexboxLayout) to handle multi-line trails. The rename dialog can use AlertDialog or a custom Dialog. Ensure all interactive elements have minimum 48×48dp tap targets and descriptive content descriptions.

- **WinUI 3**: Use ComboBox control bound to the options list for autocomplete, a Button for the browser ("Choose…"), and ItemsRepeater or ListView for breadcrumb trails. Each trail is a horizontal StackPanel of TextBlocks and Separator elements. The rename interaction is a ContentDialog modal. Implement focus visuals using FocusVisualPrimaryBrush and FocusVisualSecondaryBrush to provide keyboard focus indication consistent with Fluent 2 (typically a 2px outline). Ensure AutomationProperties.Name is set on all controls for accessibility.

## Design Decisions

- **Flat picker, hierarchical display**: The combobox and entity chooser present a flat list of category names, not a tree walk, because names are unique per owner across the entire hierarchy. A developer types three characters to find a category faster than navigating a nested tree. Breadcrumbs reveal the hierarchy afterwards, making the flat pick legible and showing the user all places where a multi-filed category sits.

- **Rename from breadcrumb, not separate management screen**: Clicking a breadcrumb to rename the category node directly (via modal) keeps the hierarchy edit co-located with the form. This is faster than switching to a separate management screen. The modal confirm step is essential: without it, a stray click on a breadcrumb could rename a category everywhere it is used, causing unintended side effects.

- **Modal rename, not inline edit**: Inline editing of a breadcrumb would require managing edit state, blur/focus behavior, and validation within the component. A modal dialog (CategoryRenameDialog) centralizes this complexity, provides a dedicated space for error messages and retry, and keeps the interaction explicit (open, edit, confirm or cancel).

- **All filing paths displayed at once**: When a category has multiple parents (DAG), showing every path in separate breadcrumb trails answers the question "where is this category filed?" without requiri navigation or a separate view. This is more discoverable than hiding all but one path.

- **Breadcrumb color contrast**: Leaf nodes are golden (apt-gold) to draw attention to the selected category; parent nodes are muted (apt-text-muted) to visually de-emphasize the hierarchy. This follows a common pattern in breadcrumb navigation and aids scanning.

## Compliance

Not applicable: CategoryField is a general-purpose form component without security, privacy, or compliance-specific requirements. It does not handle authentication, authorization, sensitive data, or regulatory concerns. The host is responsible for implementing security and compliance controls around category data (e.g., access control, data retention, audit logging).

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation from web source code |
