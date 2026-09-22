---
id: fcd5062f-05c2-4877-adfb-9b77c75c6076
title: Editable List
domain: agenticdevelopercookbook://ingredients/editable-list
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Table-and-bar list with search, filters, sorting, selection, and optional
  details pane.
platforms:
- typescript
- web
tags:
- list
- table
- data-grid
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Editable List

## Overview

A configurable list/table component combining a button bar (with search, text filters, and facet menus), a data table (with sortable and resizable columns), row selection via checkboxes, and an optional details pane for viewing one selected row in full. Rows do not carry their own action buttons; actions operate on the selection and are supplied via the bar. The component never paginates; the full matching set is on screen and scrolls.

## Behavioral Requirements

- **must-render-search**: The component MUST render a search input in the bar that filters rows by matching the `list.search` property against row content.
- **must-update-search**: The component MUST update `list.search` when the user types in the search input.
- **must-render-text-filters**: The component MUST render text filter inputs (from `list.textFilters`) in the bar, with placeholders and widths from filter metadata.
- **must-update-text-filter-values**: The component MUST update filter values via `list.setTextFilterValue()` when the user types in a text filter input.
- **must-render-facet-menus**: The component MUST render facet dropdown menus (from `list.facets`) in the bar with options and selected state from controller.
- **must-update-facet-selection**: The component MUST update facet selection via `list.setFacetSelection()` when the user selects options in a facet menu.
- **must-render-table**: The component MUST render a data table with rows from `list.rows` and columns from `list.columns`.
- **must-render-column-headers**: Each column MUST render a header (from column metadata) and cell content (from `column.value` or `column.render`).
- **must-support-sorting**: The component MUST render sortable columns and call `list.setSort()` when the user clicks a sortable header.
- **must-preserve-sort-state**: The component MUST display the current sort state (from `list.sort`) on the active column header.
- **must-support-column-resizing**: The component MUST allow users to resize columns and persist widths under the key provided by `columnWidthsKey`.
- **must-render-selection-checkboxes**: When `selectable` is true, the component MUST render checkboxes for each row and a select-all header checkbox.
- **must-update-selection**: The component MUST update row selection via `list.setSelectedIds()` when the user checks or unchecks a row checkbox or the select-all header.
- **must-show-selection-count**: When rows are selected and `selectable` is true, the component MUST display a count button showing the number of selected rows.
- **must-show-hidden-selected-count**: When `selectable` is true and the filter hides selected rows, the component MUST display a count of how many selected rows are not visible (highlighted in a distinct color).
- **must-provide-clear-selection-button**: The count button MUST be clickable and MUST call `list.clearSelection()` to deselect all rows.
- **must-render-actions**: The component MUST render any action nodes passed via the `actions` prop in the bar to the right of filters.
- **must-support-row-activation**: When `onRowActivate` is provided, the component MUST call it with the row's ID when the user double-clicks a row or presses Enter on a focused row.
- **must-render-empty-state**: When the list is empty (no rows) and no filter is active, the component MUST display the text from `emptyLabel`.
- **must-render-filtered-empty-state**: When the list is empty due to filtering, the component MUST display the text from `emptyFilteredLabel`.
- **must-render-loading-state**: When `loading` is true, the component MUST display a loading indicator in the table.
- **must-handle-error-no-rows**: When an error is present and no rows exist, the component MUST replace the entire list with an error alert (not render the bar or table).
- **must-handle-error-with-rows**: When an error is present but rows exist (e.g., a refetch failed), the component MUST display an error alert above the table without removing the rows.
- **must-render-truncation-notice**: When `truncationNotice` is provided, the component MUST display it as an alert above the table.
- **must-render-details-pane**: When `details` is provided, the component MUST render a resizable split with the table on top and details pane on bottom.
- **must-show-single-row-details**: The details pane MUST render the details for exactly one row when one row is selected, calling `details.render()` with that row.
- **must-show-details-empty-message**: The details pane MUST display `details.emptyLabel` when no row is selected.
- **must-show-details-many-message**: The details pane MUST display `details.manyLabel` when more than one row is selected.
- **must-render-details-header**: The details pane header bar MUST display the row name (from `describeRow` if provided, or the pane label) and any header actions (from `details.actions`).
- **must-render-details-actions**: Header actions MUST be called with the single selected row when one row is selected, or with `null` when zero or multiple rows are selected.
- **must-render-footer**: When `footer` is provided, the component MUST render it below the table or details pane.
- **must-render-null-values**: The component MUST render an em dash (—) for null or empty string cell values to distinguish them from failed loads.
- **must-preserve-selection-across-filter-changes**: Row selection MUST persist when the filter changes, allowing the selection to contain rows not currently visible.
- **must-describe-rows-for-accessibility**: When `describeRow` is provided, the component MUST use it to name each row's checkbox. If omitted, the component SHOULD guess the row name from the first non-empty string field that is not the row's ID.

## Appearance

- **Container**: Flex column with configurable `className`.
- **Button bar**: Dark background with rounded top corners, left and right borders; contains search input, filter inputs, facet menus, action nodes, and selection count button.
- **Search input**: Height 8px (Tailwind `h-8`), max-width `20rem`, search type with label.
- **Text filter inputs**: Height 8px, width from filter metadata or 14rem default, search type.
- **Facet menu buttons**: Dark variant, size small.
- **Table**: Rows are one line tall; columns are resizable and sortable. When inside details pane, rounded top corners removed and border-top removed. When standalone, max height from `maxHeightClass` prop (default `max-h-[60vh]`).
- **Selection count button**: Ghost variant, size small, height 7px, text size extra-small, shows count and optional hidden count in gold color.
- **Error alerts**: Dark variant with triangle alert icon, positioned above table (if rows exist) or replacing entire list (if no rows).
- **Truncation alert**: Accent variant with triangle alert icon, positioned above table.
- **Details pane**: Resizable split with divider; takes height from `details.heightClass` or `60vh` default. Header bar shows row name/pane label on left and header actions on right. Bottom pane shows row details or empty/many message.
- **Cell values**: Normal text, with dim color (text-apt-text-dim) for em dash placeholders.

## States

| State | Appearance change |
|-------|------------------|
| Default | Standard table layout with bar and rows visible |
| Loading | Loading indicator displayed in table |
| Error (no rows) | Entire list replaced with error alert |
| Error (with rows) | Error alert rendered above table, rows remain visible |
| Empty (no filter) | Table displays empty message, bar and filters visible |
| Empty (filtered) | Table displays filtered-empty message, current filters visible |
| Rows selected | Selection count button appears in bar, highlighted row(s) in table |
| Hidden selected rows | Selection count button shows hidden count in gold next to main count |
| Details pane shown | Split view with table on top, details pane on bottom |
| Details pane - no selection | Details pane shows empty message |
| Details pane - many selected | Details pane shows many-selection message |
| Details pane - single row | Details pane shows row details and header actions enabled |

## Accessibility

- **Role**: The component has no single role; the table is a `<table>` with ARIA role appropriate to a data grid, the bar is a container for controls, and the details pane has a label for assistive tech.
- **Search input label**: `aria-label="Filter [ariaLabel]"` (e.g., "Filter Users").
- **Text filter input labels**: `aria-label={filter.placeholder}` from filter metadata.
- **Facet menu labels**: Named from `facet.label`.
- **Selection count button**: `aria-live="polite"` to announce selection changes; includes `<span class="sr-only">` for "Clear selection" action.
- **Table aria-label**: Passed from component prop `ariaLabel` (required).
- **Row descriptions**: Checkboxes are named using `describeRow` callback or auto-guessed from first non-empty string field (not ID).
- **Details pane label**: Passed to `ResizableSplit` as `bottomLabel` for assistive tech.
- **Selection state changes**: The count button updates with `aria-live="polite"` to announce new selection counts.
- **Keyboard navigation**: Table supports keyboard navigation and row activation via Enter key (when `onRowActivate` is provided). Select-all checkbox in header allows keyboard selection.
- **Minimum touch target**: Selection count button is `h-7` with padding; checkboxes in table follow table's target sizing (inherits from DataTable component).

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| editable-list-001 | must-render-search | Component rendered with list prop | Search input visible in bar with label "Filter [ariaLabel]" |
| editable-list-002 | must-update-search | User types "abc" in search input | `list.setSearch("abc")` called; list.search updated; table re-renders with filtered rows |
| editable-list-003 | must-render-text-filters | list.textFilters contains one filter with id="status", placeholder="Status" | Text input visible in bar with placeholder "Status" |
| editable-list-004 | must-update-text-filter-values | User types "active" in text filter input | `list.setTextFilterValue("status", "active")` called |
| editable-list-005 | must-render-facet-menus | list.facets contains one facet with id="role", label="Role", options ["Admin", "User"] | Dropdown menu visible with label "Role" and options shown on click |
| editable-list-006 | must-update-facet-selection | User selects "Admin" in role facet | `list.setFacetSelection("role", new Set(["Admin"]))` called |
| editable-list-007 | must-render-table | list.rows contains 3 rows; list.columns defined | Data table renders with 3 rows |
| editable-list-008 | must-render-column-headers | Column has header="Name" and value=(row) => row.name | Table header shows "Name"; cells show row.name values |
| editable-list-009 | must-support-sorting | Column has sortable=true; user clicks header | `list.setSort()` called with sort direction and column key |
| editable-list-010 | must-preserve-sort-state | list.sort = { key: "name", direction: "asc" } | Table header shows sort indicator on "Name" column pointing up |
| editable-list-011 | must-support-column-resizing | columnWidthsKey="users_table" provided; user drags column border | Column resizes; width persisted under key "users_table" |
| editable-list-012 | must-render-selection-checkboxes | selectable=true; list.rows contains 2 rows | Checkbox in header and checkbox in each of 2 rows visible |
| editable-list-013 | must-update-selection | User checks checkbox on row 1 | `list.setSelectedIds(new Set([row1_id]))` called; row1 highlighted |
| editable-list-014 | must-show-selection-count | selectable=true; 2 rows selected | Count button shows "2 selected" |
| editable-list-015 | must-show-hidden-selected-count | selectable=true; 3 rows selected but filter hides 1 | Count button shows "3 selected (1 not shown)" with hidden count in gold |
| editable-list-016 | must-provide-clear-selection-button | Count button displayed with 2 rows selected; user clicks button | `list.clearSelection()` called; all rows deselected; count button hidden |
| editable-list-017 | must-render-actions | actions=`<button>Delete</button>` | Delete button visible in bar to right of filters |
| editable-list-018 | must-support-row-activation | onRowActivate=(id) => {...}; user double-clicks row with id="row123" | `onRowActivate("row123")` called |
| editable-list-019 | must-render-empty-state | list.rows is empty, no filter applied, emptyLabel="No data" | Table shows "No data" message; bar and filters still visible |
| editable-list-020 | must-render-filtered-empty-state | list.rows is empty due to filter, emptyFilteredLabel="No matches" | Table shows "No matches" message |
| editable-list-021 | must-render-loading-state | loading=true | Table shows loading indicator |
| editable-list-022 | must-handle-error-no-rows | error={new Error("API failed")}, list.allRows=[] | Entire list replaced with error alert; bar and table not shown |
| editable-list-023 | must-handle-error-with-rows | error={new Error("Refetch failed")}, list.allRows contains 3 rows | Error alert shown above table; table and all 3 rows still visible |
| editable-list-024 | must-render-truncation-notice | truncationNotice="Showing 500 of 1000+" | Alert with truncation message shown above table |
| editable-list-025 | must-render-details-pane | details={render: (row) => <div>{row.name}</div>} | Split view rendered with table on top, details pane on bottom |
| editable-list-026 | must-show-single-row-details | details provided; 1 row selected with data {id: "1", name: "Alice"} | Details pane calls `render({id: "1", name: "Alice"})`; output shown in bottom pane |
| editable-list-027 | must-show-details-empty-message | details provided with emptyLabel="Select a row"; 0 rows selected | Details pane shows "Select a row" |
| editable-list-028 | must-show-details-many-message | details provided with manyLabel="Select one"; 2 rows selected | Details pane shows "Select one" |
| editable-list-029 | must-render-details-header | details provided; 1 row selected; describeRow=(row) => row.name | Details header shows row's name |
| editable-list-030 | must-render-details-actions | details.actions=(row) => row ? <button>Edit</button> : null; 1 row selected | Header shows Edit button; passed the selected row object |
| editable-list-031 | must-render-details-actions | details.actions=(row) => row ? <button>Edit</button> : null; 0 or 2+ rows selected | Header actions button not shown; passed null to actions() |
| editable-list-032 | must-render-footer | footer=`<div>Total: 100</div>` | Footer rendered below table |
| editable-list-033 | must-render-null-values | Column with value=(row) => row.optional (null value); row rendered | Cell displays em dash (—) in dim color |
| editable-list-034 | must-preserve-selection-across-filter-changes | 2 rows selected; search filter applied hiding 1 selected row | Selection still includes both row IDs; count shows "2 selected (1 not shown)" |
| editable-list-035 | must-describe-rows-for-accessibility | describeRow=(row) => row.email; row1 has email="alice@example.com" | Checkbox has aria-label containing "alice@example.com" |

## Edge Cases

- **Null or empty search**: Search input defaults to empty; component renders all rows until user types.
- **Empty list with no filter**: Component displays empty message; bar, search, and filters remain interactive.
- **Filter that matches zero rows**: Component displays filtered-empty message; selection survives the filter but hidden count is shown.
- **Selection survives filter**: Selected row IDs are not cleared when a filter is applied; selected row that becomes hidden shows in the hidden count.
- **Selection cleared by external change**: If `list.setSelectedIds()` is called externally (e.g., by parent component), the count updates and hidden count recalculates.
- **Row ID collision**: If a row's ID (from `list.getRowId(row)`) is duplicated, behavior is undefined in the table's selection logic.
- **Column with no render and no value**: Column is skipped (no cell content rendered).
- **Column value is empty string**: Renders as em dash (—) to distinguish from undefined/null.
- **Multiple sorts attempted**: Only one sort is active; `list.sort` is a single sort state, not multi-column sort.
- **Column resize persists across page reload**: Column widths are stored in browser storage under `columnWidthsKey`; if storage is cleared, columns return to default size.
- **Details pane selection changes**: If single-row selection changes (e.g., user clicks another row), pane immediately re-renders with new row's details. Selection that leaves the pane empty or multi-selected shows appropriate message.
- **Details pane divider position**: Divider position is persisted under `details.storageKey` if provided; otherwise position resets on remount.
- **Error state during loading**: If `loading=true` and `error` is also present, the error is shown (not the loading indicator).
- **Error title missing**: If `error` is present but `errorTitle` is not, component generates title from `ariaLabel` ("Couldn't load [ariaLabel]").
- **Row activation with no details pane**: `onRowActivate` can be used independently of `details` pane; row double-click or Enter key calls the callback.
- **Facet with no options**: Facet menu renders with empty options list.
- **Text filter with no width**: Text filter input uses default width of 14rem.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `list` | EditableListController<T> | — | Required. Controller managing rows, selection, search, filters, sorting. |
| `ariaLabel` | string | — | Required. Name of the list for assistive tech (e.g., "Users", "Templates"). |
| `onRowActivate` | (id: string) => void | undefined | Optional. Callback when user double-clicks a row or presses Enter on focused row. |
| `actions` | ReactNode | undefined | Optional. Action button nodes to render in the bar. |
| `selectable` | boolean | true | Optional. Whether to show selection checkboxes and count. |
| `searchPlaceholder` | string | "Filter" | Optional. Placeholder text for search input. |
| `emptyLabel` | string | "Nothing here." | Optional. Message when list is empty with no filter. |
| `emptyFilteredLabel` | string | "Nothing matches these filters." | Optional. Message when list is empty due to filter. |
| `loading` | boolean | false | Optional. Whether to show loading indicator in table. |
| `columnWidthsKey` | string | — | Required. Storage key for persisting column widths. |
| `maxHeightClass` | string | "max-h-[60vh]" | Optional. Tailwind class for table max height (ignored if details pane present). |
| `details` | EditableListDetails<T> | undefined | Optional. Configuration for details pane showing single-row details. |
| `footer` | ReactNode | undefined | Optional. Content to render below table or details pane. |
| `describeRow` | (row: T) => string | undefined | Optional. Function to name each row for accessibility. If omitted, component guesses from first non-empty string field. |
| `error` | unknown | undefined | Optional. Error object; if present and no rows, list is replaced with error alert; if present with rows, error alert shown above table. |
| `errorTitle` | string | undefined | Optional. Custom error title. Defaults to "Couldn't load [ariaLabel]". |
| `truncationNotice` | ReactNode | undefined | Optional. Message about list being capped (e.g., "Showing 500 of more"). |
| `className` | string | undefined | Optional. CSS class for root container. |

## Deep Linking

Not applicable: This component is not designed to participate in deep linking. Its rows and state (selection, filters, sort) are managed by the parent component and controller, which is responsible for routing and URL state management.

## Localization

| String Key | Default (en) | Context |
|-----------|-------------|---------|
| search.placeholder | "Filter" | Placeholder for search input (from `searchPlaceholder` prop) |
| search.aria-label | "Filter [ariaLabel]" | Accessibility label for search input |
| empty.no-filter | "Nothing here." | Message when list is empty with no active filter |
| empty.filtered | "Nothing matches these filters." | Message when list is empty due to active filters |
| selection.count | "{count} selected" | Selection count button text |
| selection.hidden | "({count} not shown)" | Hidden selection count (appended in gold color) |
| selection.clear | "Clear selection" | Screen-reader label for clear-selection button |
| table.error | "Couldn't load {ariaLabel}" | Error alert title (default, overridable via `errorTitle` prop) |
| table.error.with-rows | "— showing the last rows that loaded." | Error alert description when rows exist |
| details.label | "Details" | Default label for details pane header |
| details.empty | "Select a row to see its details." | Message when details pane has no selection |
| details.many | "Select a single row to see its details." | Message when details pane has multiple selections |
| button-bar.aria-label | "{ariaLabel} actions" | Accessibility label for button bar |

All text defaults are passed as component props; externalization depends on the application's localization strategy.

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | The ResizableSplit divider should respect `prefers-reduced-motion` and disable drag animations if the setting is enabled. (Behavior depends on ResizableSplit component implementation.) |
| Increase Contrast | The selection count button and hidden count text (gold color) should adapt to higher-contrast color tokens if the setting is enabled. Error and truncation alerts should use high-contrast colors. |
| Differentiate Without Color | The hidden selection count is shown in gold color; alternative text representation ("(X not shown)") is also present, so color alone does not convey the information. Sort indicators should use glyphs or icons in addition to any color coding. |

## Feature Flags

Not applicable: This component does not implement feature flags. Feature flagging is the responsibility of the parent component or controller that conditionally renders or enables filtering and details features based on application-level flags.

## Analytics

| Event | Properties | When |
|-------|-----------|------|
| `editable_list.loaded` | `{ ariaLabel: string, row_count: number, filter_active: boolean }` | Component finishes rendering with initial rows (on first render or after successful refetch) |
| `editable_list.searched` | `{ ariaLabel: string, query: string, result_count: number }` | User types in search input and results update |
| `editable_list.filtered` | `{ ariaLabel: string, filter_type: string (text/facet), filter_id: string, result_count: number }` | User applies or changes a text filter or facet selection |
| `editable_list.sorted` | `{ ariaLabel: string, column_key: string, direction: string (asc/desc) }` | User clicks a sortable column header |
| `editable_list.column_resized` | `{ ariaLabel: string, column_key: string, width_px: number }` | User finishes dragging a column divider |
| `editable_list.selection_changed` | `{ ariaLabel: string, count: number, hidden_count: number }` | User checks/unchecks a row checkbox or clears selection |
| `editable_list.row_activated` | `{ ariaLabel: string, row_id: string }` | User double-clicks a row or presses Enter on focused row |
| `editable_list.details_pane_opened` | `{ ariaLabel: string, row_id: string }` | User selects a single row with details pane enabled |
| `editable_list.error_shown` | `{ ariaLabel: string, error_type: string, has_rows: boolean }` | Error occurs (no-rows or with-rows variant) |

Analytics implementations should be added by the parent component or a custom hook that wraps the controller's methods.

## Privacy

- **Data collected**: None by the component itself. The component does not collect, log, or transmit any user data beyond what the controller and parent application explicitly define (e.g., search queries, selected row IDs).
- **Storage**: Column widths and details pane divider position are persisted to browser storage (localStorage or equivalent) under keys provided by the parent (`columnWidthsKey`, `details.storageKey`). Selection state, search queries, and filter values are not persisted unless the controller or parent component explicitly implements persistence.
- **Transmission**: The component does not transmit data. Network requests (data fetching, filtering, sorting) are handled by the parent component and controller.
- **Retention**: Persisted storage (column widths, divider position) is retained until explicitly cleared by the application or user action (e.g., browser storage clear).

## Logging

Subsystem: `agenticdevelopertoolkit.ui.blocks` | Category: `EditableList`

| Event | Level | Message |
|-------|-------|---------|
| Render | debug | `EditableList rendered: ${ariaLabel}, rows: ${list.rows.length}, filtered: ${list.filtered}, selected: ${list.selectedIds.size}` |
| Error | error | `EditableList error: ${error.message}, ariaLabel: ${ariaLabel}, rows: ${list.allRows.length}` |
| Column resize | debug | `EditableList column resized: column=${column.key}, stored under key=${columnWidthsKey}` |
| Sort change | debug | `EditableList sort changed: key=${sort.key}, direction=${sort.direction}` |
| Selection change | debug | `EditableList selection changed: selected=${list.selectedIds.size}, hidden=${hiddenSelected}` |

## Platform Notes

- **React/Web**: Source implementation in `packages/web/packages/ui/src/blocks/editable-list.tsx`. Component uses React 18 `"use client"` directive, hooks (useState, useMemo, useCallback), and re-exports from sibling components (DataTable, Button, Input, Alert, ResizableSplit, FacetMenu, ButtonBar). Column resize persistence uses a storage key passed as a prop. Selection state survives filter changes by design — selected IDs are not cleared when filters update. Details pane state is local to the component; pane content is rendered via callback to support custom row details layouts.
- **SwiftUI**: Analogous list composition would use a `List` or `Table` view (iOS 16+) with a `SearchField` in a toolbar. Selection would use `@State` for `selectedIds: Set<ID>`. Filter inputs would be custom views in the toolbar. The details pane would be a `NavigationSplitView` or manual two-pane layout. Sorting and column resizing are not native to SwiftUI Table; custom gesture and state management would be required.
- **Compose**: Analogous composition would use a `LazyColumn` for rows with an `OutlinedTextField` for search above. Selection would track `selectedIds: Set<ID>` via `rememberSaveable`. Filter inputs would be additional `OutlinedTextField` rows. Facet menus would use `DropdownMenu`. Details pane would use a custom side-by-side or bottom-sheet layout. Column resizing is not native to list compositions; gesture handling and state management required.
- **AppKit / UIKit**: Analogous composition would use `NSTableView` (macOS) or `UITableViewController` (iOS) with a search controller and text field filters in a toolbar. Selection would track row IDs via delegate methods. Details view would be a split view controller (macOS) or a detail view controller pushed/presented on tap. Column resizing is native to NSTableView on macOS; iOS tables do not resize columns.
- **WinUI 3**: Analogous composition would use `DataGrid` (from WinUI 3 or community toolkit) with search and filter `TextBox` controls in a `CommandBar` above it. Selection would use the grid's `SelectionMode` property and `SelectedItems` binding. Details pane would be a `SplitView` with the grid on top and custom XAML detail layout on bottom. `DataGrid` natively supports column resizing and multi-column sorting; column widths can be persisted via application settings or local storage. Facet menus would be `ComboBox` or `DropDownButton` controls with multi-select dropdown behavior.

## Design Decisions

- **Selection persists across filter changes**: Row selection is not cleared when filters are applied. This preserves operator intent — a bulk delete targeting three users remains valid even if a search filter temporarily hides one of them. The hidden count informs the operator and the clear-selection button offers a one-press undo.
- **Details pane shows one row only**: A pane is a view of a record; there is no "details of three rows." The user is prompted to select one row if zero or multiple are selected. This avoids the ambiguity of "which row's details?" and keeps the pane's data source clear.
- **Rows carry no action buttons**: Actions belong to the bar and operate on the selection. Per-row buttons duplicate the bar's actions and create confusion about whether an action applies to one row or the selection. Exceptions (role menu, membership chip) are supplied as columns by the parent, not by the component.
- **No pagination**: The full matching set is on screen and scrolls. Pagination plus filtering creates two ways to not see a row; a filter that matches 40 items and a pager showing 25 hides 15 behind a control most operators never press.
- **Error behavior depends on row count**: If the list fails to load and no rows exist, the component replaces the entire UI with an error alert. If the list fails to REFETCH (after initial success), rows remain visible — they are real, just older than expected — and an error alert sits above them. This distinction prevents a transient network failure from blanking out rows the operator just acted on.
- **Search input never uses controlled pattern within the button bar**: The search input is a controlled input (value and onChange are wired to the controller), but the component does not clear it on selection or filter changes. The search persists as an independent dimension of the list state.

## Compliance

Not applicable: This component implements no specific compliance requirements. Compliance audit checklists (accessibility, privacy, security) are the responsibility of the application using the component and its controller implementation.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
