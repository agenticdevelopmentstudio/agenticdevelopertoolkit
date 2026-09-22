---
id: a3645ff4-19c2-4b30-a828-93a56191f656
title: TagSetField
domain: agenticdevelopercookbook://ingredients/tag-set-field
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A form control for editing a set of short labels from a growing vocabulary,
  combining autocomplete search and browse/create affordances.
platforms:
- web
tags:
- form-control
- tag-editing
- vocabulary-management
depends-on: []
related: []
references: []
---

# TagSetField

## Overview

A form control that manages a set of short labels (tags) drawn from a growing vocabulary. The component pairs an autocomplete search field for quick selection of known labels with a browse/create dialog for exploring the full vocabulary and minting new labels. Selected labels render as removable chips in a separate row below the controls, visually anchoring the component as a tag editor rather than two disconnected inputs.

This component extracts a pattern used consistently across features that manage tagged entities (e.g., research document tags and work item labels) so the interaction affordance and commit behavior remain uniform across the application.

## Behavioral Requirements

- **must-display-label**: Component MUST display the `label` prop as the field's caption, passed to the wrapping `Field` component.
- **must-display-hint**: Component MUST display the optional `hint` prop if provided, passed to the wrapping `Field` component.
- **must-render-combobox**: Component MUST render a `Combobox` control in the top row for autocomplete search.
- **must-render-entity-chooser**: Component MUST render an `EntityChooser` control in the top row to the right of the Combobox for browsing and creating labels.
- **must-show-filtered-suggestions**: Component MUST filter the `options` list to exclude any item already present in the `value` array and pass the filtered list to the Combobox.
- **must-accept-exact-match-in-combobox**: Component MUST add an item to `value` when the Combobox `onValueChange` receives an exact match against the `options` list that is not already in `value`.
- **must-clear-combobox-on-acceptance**: Component MUST clear the Combobox text field after adding an item via exact match.
- **must-not-create-on-combobox-enter**: Component MUST NOT add an item to `value` when the Combobox receives text that does not match any item in `options`, even if the user presses Enter; only the EntityChooser's `allowCreate` row creates new labels.
- **must-update-value-via-combobox**: Component MUST call `onChange` with the updated array when an exact match is accepted in the Combobox.
- **must-render-chips-row**: Component MUST render selected items as removable chips below the control row using `EntitySelectionChips`.
- **must-render-chips-from-value**: Component MUST render all items in the `value` array as chips, maintaining their order.
- **must-remove-chip-on-delete**: Component MUST remove an item from `value` and call `onChange` with the updated array when the user clicks the remove action on a chip.
- **must-hide-empty-chips-row**: Component MUST render the chips row but display no content when `value` is empty (no "No tags yet" label).
- **must-pass-label-to-chips**: Component MUST pass the `label` prop as the `ariaLabel` to `EntitySelectionChips`.
- **must-pass-label-to-chooser**: Component MUST pass the `label` prop as the `ariaLabel` to `EntityChooser`.
- **must-use-noun-in-placeholders**: Component MUST construct placeholder text for both Combobox and EntityChooser using the singular `noun` prop (e.g., "Add a {{noun}}…").
- **must-pass-disabled-to-controls**: Component MUST propagate the `disabled` prop to both Combobox and EntityChooser.
- **must-accept-layout-prop**: Component MUST pass the optional `layout` prop ("stacked" or "inline", default "stacked") to the wrapping `Field` component.
- **must-accept-classname-prop**: Component MUST pass the optional `className` prop to the wrapping `Field` component.
- **must-respect-options-as-suggestion**: Component MUST treat the `options` list as a suggestion list, not a closed set; items in `value` may exist outside `options` (newly created labels or additions from other surfaces).
- **must-maintain-value-order**: Component MUST preserve the order of items in the `value` array; no sorting or reordering is applied.

## Appearance

- **Layout**: Two rows within a flexbox container (`flex flex-col`). Top row (`flex w-full items-stretch gap-2`) contains Combobox (flex-1) and EntityChooser (w-44 shrink-0). Bottom row contains chips group spanning full width.
- **Gap between rows**: 8px (Tailwind `gap-2`).
- **Combobox width**: Flexible (flex-1); grows to fill available space after EntityChooser.
- **EntityChooser width**: 176px (Tailwind `w-44`), fixed width, no shrinking beyond flex-1 Combobox.
- **Chips row**: Spans full field width; renders nothing visually when `value` is empty.
- **Disabled state**: Both Combobox and EntityChooser receive `disabled` prop, rendering with platform-appropriate disabled styling.

## States

| State | Appearance change |
|-------|------------------|
| Default | Both controls enabled; Combobox text field empty or shows partial search text. |
| Active (Combobox focused) | Combobox shows focus ring; suggestion dropdown visible if text matches partial options. |
| Active (EntityChooser opened) | EntityChooser dialog open; Combobox in background. |
| Item added | Combobox text field cleared; chip appears in chips row. |
| Item removed | Chip removed from chips row; if last chip, row renders empty. |
| Disabled | Both Combobox and EntityChooser render disabled; no interaction possible. |

## Accessibility

- **Role**: The component is a grouped form control. The wrapping `Field` provides an accessible label via `label` prop. Each sub-control (Combobox, EntityChooser) provides its own accessible role and label.
- **Combobox label**: Set via `ariaLabel={`Add a ${noun}`}` to clearly indicate the control's purpose.
- **EntityChooser label**: Set via `ariaLabel={label}` (the field-level label) to associate it with the field.
- **Chips group label**: Set via `ariaLabel={label}` on `EntitySelectionChips` to announce the group.
- **Keyboard navigation**: Combobox and EntityChooser are individually keyboard-accessible. Users can tab through controls and use arrow keys for suggestion navigation within the Combobox.
- **Announce item addition**: Combobox text clears after acceptance, signaling to screen readers that the input has been consumed. The chip's appearance in the chips row provides visual confirmation.
- **Announce item removal**: Chip removal updates `value` and triggers `onChange`, which removes the chip from the DOM.
- **Minimum tap target**: Combobox input and EntityChooser trigger button SHOULD meet platform minimum touch target size (44×44pt on iOS, 48×48dp on Android, typically 44px on web).

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| tag-set-001 | must-render-combobox, must-render-entity-chooser, must-render-chips-row | Render with `label="Tags"`, `noun="tag"`, `options=["foo", "bar"]`, `value=[]` | Two controls render in top row; chips row renders below (empty). |
| tag-set-002 | must-show-filtered-suggestions | `options=["foo", "bar", "baz"]`, `value=["foo"]` | Combobox suggestions filtered to `["bar", "baz"]`; "foo" not offered. |
| tag-set-003 | must-accept-exact-match-in-combobox | User types "ba" in Combobox; "bar" appears in suggestions; user clicks or presses Enter on "bar". | `onChange` called with `["foo", "bar"]`. |
| tag-set-004 | must-clear-combobox-on-acceptance | User accepts exact match "bar" as in tag-set-003. | Combobox text field cleared to empty. |
| tag-set-005 | must-not-create-on-combobox-enter | User types "newlabel" (not in `options`); presses Enter. | `onChange` NOT called; Combobox text remains "newlabel". |
| tag-set-006 | must-render-chips-from-value | `value=["foo", "bar", "baz"]` | Three chips render in chips row in order "foo", "bar", "baz". |
| tag-set-007 | must-remove-chip-on-delete | User clicks remove on chip "bar" when `value=["foo", "bar", "baz"]`. | `onChange` called with `["foo", "baz"]`; "bar" chip removed. |
| tag-set-008 | must-hide-empty-chips-row | `value=[]` | Chips row renders (flex container present in DOM) but displays nothing. |
| tag-set-009 | must-use-noun-in-placeholders | `noun="label"` | Combobox placeholder reads "Add a label…"; EntityChooser input label reads "Filter or add a label…". |
| tag-set-010 | must-pass-disabled-to-controls | `disabled=true` | Both Combobox and EntityChooser receive `disabled={true}`. |
| tag-set-011 | must-accept-layout-prop | `layout="inline"` | Field component receives `layout="inline"`; caption renders beside controls instead of above. |
| tag-set-012 | must-respect-options-as-suggestion | `options=["foo", "bar"]`, `value=["foo", "baz"]` (baz not in options) | Combobox suggestions show only `["bar"]`; baz remains in value as a chip (newly created label). |
| tag-set-013 | must-maintain-value-order | `value=["third", "first", "second"]` (inserted in non-alphabetical order) | Chips render in order: "third", "first", "second" (no sorting applied). |
| tag-set-014 | must-display-label | `label="Field Caption"` | Field wrapper displays "Field Caption" as row caption. |
| tag-set-015 | must-display-hint | `hint="Help text"` | Field wrapper displays "Help text" below or beside the caption. |

## Edge Cases

- **Empty options list**: If `options=[]` and `value=[]`, component renders with both controls enabled. Combobox shows no suggestions; EntityChooser browse list is empty (but `allowCreate` remains available if EntityChooser supports it).
- **Empty value array**: If `value=[]`, chips row is present in DOM but renders nothing. Component ready to accept new selections.
- **Value contains items not in options**: If `value=["custom"]` and `custom` is not in `options`, component displays the chip anyway (label was created outside this component or by another surface). Combobox continues to filter `options` normally.
- **Large value array**: No explicit limit defined in source; component maintains all items and renders all chips. Performance depends on parent's render optimization and EntitySelectionChips implementation.
- **Duplicate item attempted via Combobox**: If `value=["foo"]` and user attempts to re-add "foo" via Combobox, `must-show-filtered-suggestions` removes "foo" from suggestions, preventing duplicate selection.
- **Rapid add/remove cycles**: Component responds to each `onChange` callback; no debouncing or batching applied. If parent re-renders with a new `options` list before a Combobox `onValueChange` event fires, the suggestions list is recalculated immediately.
- **Very long label text**: Component delegates text truncation and overflow behavior to Combobox and EntitySelectionChips sub-components; no truncation is applied at the TagSetField level.
- **Disabled while EntityChooser dialog open**: If `disabled` changes to true while dialog is open, component propagates the change to EntityChooser, which handles state (likely closes or disables the dialog).
- **Combobox partial text + blur**: If user enters partial text "fo" in Combobox and blurs the field without selecting a match, text remains; no auto-acceptance occurs.
- **None** — Concurrent access is not applicable; this is a single-threaded UI component controlled by React's render loop and event handler serialization.
- **None** — Offline/disconnected state is not applicable; component manages local state only and does not make network requests.

## Configuration

Not applicable: TagSetField is a presentational component with no configurable runtime options. The `options`, `value`, `onChange`, and textual props (`label`, `noun`, `hint`) define the component's state and behavior; no configuration file or feature flag is required.

## Deep Linking

Not applicable: TagSetField is a form control within a larger page and is not independently navigable via deep links. Deep linking targets the containing page/form, not the component itself.

## Localization

| String Key | Default (en) | Context |
|-----------|-------------|---------|
| (constructed from props) | `Add a {{noun}}…` | Combobox placeholder; `noun` is provided by parent. |
| (constructed from props) | `Filter or add a {{noun}}…` | EntityChooser input label and placeholder; `noun` is provided by parent. |
| (from Field) | (parent-provided) | `label` and `hint` are provided by parent and are not localized by this component. |

The component constructs microcopy dynamically from the `noun` prop and does not maintain a separate string catalog. All user-facing text originates from parent props.

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | Component does not apply motion within its own render. Sub-components (Combobox, EntityChooser, EntitySelectionChips) are responsible for respecting OS reduce-motion preferences. |
| Increase Contrast | Component does not apply contrast changes; sub-components handle contrast adjustments. |
| Differentiate Without Color | Component uses text and icons provided by sub-components; no color-only differentiation is introduced by TagSetField. |

## Feature Flags

Not applicable: Component does not check feature flags or conditional logic based on flags. Enabling/disabling the component is the parent's responsibility.

## Analytics

Not applicable: Component does not emit analytics events. Parent forms that use TagSetField are responsible for tracking user interactions (e.g., tag added, tag removed) if needed.

## Privacy

Not applicable: Component does not collect, store, or transmit data. Tag labels are managed by the parent and passed as props; no sensitive data is processed or logged by TagSetField itself.

## Logging

Not applicable: Component does not emit debug or error logs. Logging is delegated to parent forms and sub-components (Combobox, EntityChooser).

## Platform Notes

- **React/Web**: Implemented in `packages/web/packages/ui/src/blocks/tag-set-field.tsx` as a functional component. Uses Tailwind CSS for flexbox layout (`flex`, `w-full`, `flex-col`, `items-stretch`, `gap-2`, `w-44`, `shrink-0`). State is local (`text`); suggestions are computed via `useMemo`. Combobox autocomplete fires `onValueChange` on both keystroke (partial text) and selection (exact match); the component distinguishes by checking `options.includes(next)`. Sub-components (Field, Combobox, EntityChooser, EntitySelectionChips) are imported from the same UI package and are responsible for their own styling and accessibility.

- **SwiftUI**: Implement as a SwiftUI `View` that combines a `TextField` with a `.searchable()` modifier and a secondary browser sheet (using `.sheet(isPresented:)` for entity chooser). Suggested tag items are a `@State` computed property that filters input options to exclude selected values. Accept text changes via `.onChange()` and only add to the selection when exact match is confirmed. Selected tags render as a `FlowLayout` or `VStack` of removable tag capsules below the search field. Pass `disabled` via `.disabled()` to both text input and button. The component corresponds to iOS and macOS patterns where search and selection dialogs are separated affordances.

- **Compose**: Implement using `LazyColumn` or `Column` with `TextField` for search and a `Button` triggering a selection dialog. Compute filtered suggestions using `remember { derivedStateOf { ... } }` to exclude selected items. Filter for exact matches on text change and add to selection only on explicit confirmation (e.g., click/Enter on a suggestion or via the dialog). Render selected tags as a `FlowRow` of `AssistChip` components with onDismiss callbacks that update the selection. Propagate `enabled` parameter to both input and dialog trigger. Corresponds to Material Design 3's chip and text input patterns.

- **AppKit / UIKit**: Implement as a `UIStackView` (iOS) or `NSStackView` (macOS) arranging a search field above a custom tag row view. The search field uses a `UISearchController` or `NSSearchController` bound to a suggestion list. Exact matches are detected in the search controller's result updater; on confirmation, the match is appended to the selection. Selected tags render in a horizontal wrapping container (custom or using a library) with removable chips. The disabled state disables the search field and add button; chips row may remain visible or hide depending on selection state. Corresponds to iOS and macOS native patterns for tag management (e.g., Mail app recipient field, but simpler — no address lookup or validation).

- **WinUI 3**: Implement using a `StackPanel` (Vertical) with a `TextBox` (for search) and `AutoSuggestBox` (for suggestions) side-by-side in a `StackPanel` (Horizontal). Bind the suggestions to the filtered options list via `ItemsSource`. Hook `TextChanged` event to detect exact matches against options and update the selection only on match confirmation. Bind selected tags to an `ItemsControl` or `GridView` below that renders tag items as `Button` controls with close icons. Set `IsEnabled` on both input controls and the add button when disabled state is true. The layout uses `Thickness` and `HorizontalAlignment` to size the add button (e.g., 176 device-independent pixels) and allow the search field to grow. Corresponds to Fluent 2 text input and tag patterns used in forms.

## Design Decisions

1. **Separation of Combobox and EntityChooser**: The component does not combine autocomplete and browse into a single control because they answer different user questions. Autocomplete serves users who know the label name; the entity chooser serves users who are browsing. Separating them avoids cognitive load of choosing a mode within a single input and allows the chooser to offer creation affordances without conflating "I typed something new" with "I want to create it."

2. **No auto-creation on Enter in Combobox**: The source explicitly checks for exact match in `options` before adding. Typing a label name not in the vocabulary and pressing Enter does not create it; users must use the entity chooser's `allowCreate` row. This avoids accidentally creating labels from typos and ensures creation intent is explicit.

3. **Chips in separate row**: Chips are a sibling of the control row, not nested within the EntityChooser column, because nesting caused layout wrap and misalignment with other form controls (e.g., categories). The separate row spans the full field width, preserving alignment across form rows and allowing the trigger button to remain a fixed width in every selection state.

4. **Vocabulary as suggestion, not constraint**: The `options` list is a suggestion list, not a closed set. Items in `value` may exist outside `options` because labels are created by the EntityChooser or by other surfaces in the application. This allows consistent tag management across the application without requiring the local component to sync or reload the vocabulary.

5. **Noun prop for microcopy**: The `noun` parameter (singular, lowercase) is used in all placeholder and aria-label text instead of hardcoding "tag." This allows the component to be reused for other entity types (e.g., "label", "keyword", "category") without code changes, making the interaction pattern reusable.

6. **No sorting or reordering**: The `value` array's order is preserved exactly as provided by the parent. No sorting or canonical reordering is applied. This allows the parent to control tag order (e.g., by insertion time, custom ranking, or external system).

## Compliance

Not applicable: Component compliance depends on the containing form's security, accessibility, and data-handling practices. TagSetField itself is a stateless presentation component that delegates concerns to sub-components (Combobox, EntityChooser, EntitySelectionChips) and the parent form.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation from web source |
