---
id: d04eef56-2dbf-4148-964b-c095f242227f
title: "DataTable"
domain: agenticdevelopertoolkit://recipes/data-table
type: ingredient
version: 1.3.1
status: review
language: en
created: 2026-06-26
modified: 2026-09-22
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: "Controlled, selectable, optionally-sortable, optionally-reorderable generic table primitive with multi-row selection, inline editing, and column resizing."
platforms:
  - typescript
  - web
tags:
  - component
  - data-table
  - table
  - ui
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# DataTable

## Overview

A generic, selectable, optionally-sortable, optionally-reorderable table primitive in `@agenticdevelopertoolkit/ui`.
It is a **controlled** table: the caller owns `rows`, the `selectedIds` set, and
the optional `sort`. The component renders columns, handles pointer + keyboard
selection, and reports changes up. It is generic over the row type `T` and owns
the multi-row selection model (click / ⇧-click / ⌘-click / keyboard). It is the
foundation for `ListWithDetailsPane` and `AddUsersModal`.

## Behavioral Requirements

### Selection and Focus

- **click-selects-row**: On a plain click of a row, the component MUST set the selection to exactly `{id}` and set the internal anchor to that id.
- **shift-click-extends-range**: On ⇧-click of a row, the component MUST set the selection to the contiguous range from the anchor to the clicked id (in the current `rows` order) and MUST leave the anchor unchanged.
- **modifier-click-toggles**: On ⌘/Ctrl-click or ⌥/Alt-click of a row, the component MUST toggle that id in or out of the selection and MUST set the anchor to that id.
- **arrow-key-moves-selection**: When the grid is focused, ↑/↓ MUST set the selection to the previous/next row's id, set the anchor to it, and clamp at the first/last row.
- **shift-arrow-extends-range**: ⇧+↑/⇧+↓ MUST extend the selection one row from the anchor.
- **space-toggles-focused-row**: Space MUST toggle the focused row in or out of the selection.
- **selection-by-id**: The component MUST track selection by id (not row position) so it survives re-sorts and filters.
- **onselectionchange-new-set**: Every selection edit MUST be reported via `onSelectionChange` with a new `Set` instance (the set is owned by the caller).
- **pointer-no-focus-steal**: Pointer selection MUST NOT steal focus from an open editor elsewhere on the page.

### Sorting

- **no-internal-sort**: The component MUST NOT sort `rows` internally; it MUST report sort intent via `onSortChange` and render `rows` in the given order.
- **inert-sort-when-no-handler**: When `onSortChange` is omitted, sortable headers MUST render inert (no sort affordance fires).

### Row Activation

- **double-click-activates-row**: When `onRowActivate` is provided, double-clicking a row MUST invoke `onRowActivate` with that row's id, unless the click originated from an in-cell control.
- **enter-activates-focused-row**: When `onRowActivate` is provided and the table is selectable, pressing Enter MUST invoke `onRowActivate` with the currently focused row's id.

### Column Sizing (`autoSizeColumns`, opt-in)

- **must-size-columns-to-widest-cell**: With `autoSizeColumns`, a column with no declared `width` MUST be as wide as its WIDEST cell — measured across the header and every row, so all rows share one track and the columns LINE UP. A `max-content` track alone does NOT satisfy this: each row is its own grid (it must be, to carry the row's background/selection), so `max-content` would size every row independently and the header would not align with the body. The component therefore renders one pass at `max-content` (each cell at its natural width), measures the widest cell per column, and locks that in as an explicit px track — both passes BEFORE paint, so no misaligned frame is ever shown. It MUST re-measure when the rows or columns change.
- **must-resize-columns-by-drag**: With `autoSizeColumns`, each column (except one marked `resizable: false`) MUST offer a drag handle on its TRAILING border that sets an explicit width; DOUBLE-CLICKING the handle MUST clear it, springing the column back to fitting its content. A dragged width MUST win over the measured one, and MUST NOT go below a legible minimum (48px).
- **may-persist-column-widths**: Given `columnWidthsKey`, the dragged widths MUST persist (localStorage under key `data-table-cols:{columnWidthsKey}`) so a table remembers its layout across visits.
- **must-fill-slack-not-stretch**: Content-sized columns MUST pack to the leading edge — a trailing filler track absorbs any leftover width — rather than stretching to fill the table.
- **must-truncate-when-dragged-narrow**: A column dragged NARROWER than its content MUST ellipsise, never reflow (which would knock every row out of vertical alignment).

### Reordering (`reorder`, opt-in)

- **must-enable-row-drag-to-reorder**: When `reorder` is provided, rows MUST be draggable; releasing a row over the table MUST invoke `reorder.onDrop` with a `SortableDrop` object describing the new position.
- **must-respect-candrag-check**: When `reorder.canDrag` is provided, a row MUST NOT be draggable if `canDrag(id)` returns false.
- **must-announce-drag-state**: When a row is picked up, dragged, or dropped, the component MUST emit accessible announcements describing the row and the drop zone using `reorder.describeRow` (or the row's `describeRow` function, or a fallback description).
- **must-not-reorder-while-sorted**: Reordering SHOULD be omitted when a sort or filter is in force, as a dragged position would describe the view rather than the underlying list.

### Selection Checkboxes (`showSelectionCheckboxes`, opt-in)

- **must-add-leading-checkbox-column**: When `showSelectionCheckboxes` is true and the table is selectable, the component MUST add a leading checkbox column that displays one checkbox per row.
- **must-include-select-all**: The selection checkbox column header MUST include a "Select all" checkbox that toggles the selection state of every visible row (not other pages or filters).
- **must-label-checkboxes**: Each row's checkbox MUST have an accessible label derived from `describeRow(row)` if provided, or by looking for the first non-empty string field in the row that is not the id, or falling back to `row {id}`.
- **checkbox-click-not-select-row**: Clicking a selection checkbox MUST NOT trigger row selection via `onRowClick`; it MUST only toggle that row's checkbox.

### Inline-Editable Cells

- **must-not-hijack-cell-controls**: The selectable grid's keyboard/pointer machinery MUST ignore events that originate from a control INSIDE a cell (input / textarea / select / button / link / contenteditable / `[role='button']`). Its Arrow/Space handlers call `preventDefault`, which would swallow a space typed into an inline editor or a native select's keyboard use; and its mousedown-`preventDefault` would stop the control taking focus at all. Without this, selection and inline editing are mutually exclusive — a selectable table could not host an editable cell. A click on an in-cell control MUST still select its row (so a details pane follows the row being edited) while leaving the control's own click intact.

### Action-List Mode (Unselectable)

- **action-list-mode-when-unselectable**: When BOTH `selectedIds` and `onSelectionChange` are omitted, the component MUST render rows with no selection affordance — no `aria-selected`, no `data-selected`, no pointer cursor, and clicking a row MUST NOT select it — so in-cell controls (buttons, menus) own the interaction.

## Appearance

```
┌───────────────────────────────────────────────────┐
│ ☐ │ Name ▲     │ Email          │ Phone           │  ← sticky header (sortable = button + caret; ☐ = select-all)
├────┼────────────┼────────────────┼─────────────────┤
│ ☐  │ Ada        │ ada@x.io       │ +1 555 0100     │  ← row (aria-selected)
│ ☑  │ Grace      │ grace@x.io     │ +1 555 0101     │  ← selected row (bg-apt-gold/15)
└────┴────────────┴────────────────┴─────────────────┘
```

- Container: `border border-apt-border rounded-lg overflow-auto`.
- Header: `bg-apt-surface-2`, sticky (`position: sticky; top: 0`), `text-apt-text-muted`, mono caption style; a sortable header is a `<button>` with a `ChevronUp`/`ChevronDown` caret in `apt-text-muted`.
- Row: `text-apt-text`, hover `bg-apt-surface-2`, selected `bg-apt-gold/15`; divider `border-t border-apt-border`.
- Selection checkbox column: width `2.75rem`, not resizable.
- Column widths come from a CSS grid template built from each column's `width` — or, with `autoSizeColumns`, from the measured width of each column's widest cell, which the user may override by dragging the column's trailing border (`cursor-col-resize`, `hover:bg-apt-gold/40`, matching the topic list's rail handle).
- Resize handle: `absolute top-0 right-0 h-full w-1.5 translate-x-1/2` on the trailing border of each resizable column header.
- No raw hex; no `!important`.

## States

| State | Appearance change |
|---|---|
| Default row | `text-apt-text`, transparent background |
| Hover row | `bg-apt-surface-2` |
| Selected row | `bg-apt-gold/15`, `aria-selected="true"`, `data-selected` |
| Keyboard-focused row | roving `data-focused="true"`; `aria-activedescendant` points at it |
| Dragging row | row's transform reflects pointer position (dnd-kit) |
| Sortable header (active) | `aria-sort` set to "ascending" or "descending"; caret reflects direction |
| Loading | loading affordance shown in place of rows (status message) |
| Empty | `emptyLabel` (default "No items.") shown |

## Accessibility

- `role="grid"` (selectable) or `role="table"` (action-list) with `aria-label`; header is `role="row"` / `role="columnheader"` (sortable headers set `aria-sort` to "ascending" or "descending"); body rows are `role="row"` with `aria-selected` (selectable only); cells are `role="gridcell"` (selectable) or `role="cell"` (action-list).
- The grid is focusable (`tabIndex=0`) when selectable; a roving `data-focused` attribute tracks keyboard focus; `aria-activedescendant` points at it.
- Pointer selection does not steal focus from an open editor elsewhere.
- Selection checkboxes have accessible labels derived from row content (`Select Ada`, `Select Grace`).
- Sortable headers are buttons with `aria-sort` attributes.
- Column resize handles are separators with `aria-orientation="vertical"` and `aria-label="Resize column {key}"`.
- Drag operations emit accessible announcements via the dnd system (row name, drop zone name).
- Loading state uses `role="status"` for the affordance message.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|---|---|---|---|
| T1 | click-selects-row | click row Ada | selection = `{Ada}`, anchor = Ada |
| T2 | shift-click-extends-range | click Ada, ⇧-click Grace | selection = contiguous Ada…Grace |
| T3 | modifier-click-toggles | ⌘-click selected row | row removed from selection |
| T4 | arrow-key-moves-selection | focus grid, press ↓ | selection moves to next row, clamps at end |
| T5 | shift-arrow-extends-range | anchor set, ⇧+↓ | range extends one row from anchor |
| T6 | space-toggles-focused-row | focus row, press Space | focused row toggles |
| T7 | no-internal-sort, onselectionchange-new-set | click sortable header | `onSortChange` fires with toggled dir; `rows` unchanged by component |
| T8 | selection-by-id | reorder `rows` after selecting | selection preserved across reorder |
| T9 | inert-sort-when-no-handler | render without `onSortChange` | empty + loading states render; headers inert |
| T10 | action-list-mode-when-unselectable | render without `selectedIds`/`onSelectionChange`; click a row | rows carry no `aria-selected`/`data-selected`, no pointer cursor; the click selects nothing; in-cell buttons remain operable |
| T11 | double-click-activates-row | double-click row with `onRowActivate` | `onRowActivate(id)` fires |
| T12 | enter-activates-focused-row | focus row, press Enter with `onRowActivate` | `onRowActivate(id)` fires |
| T13 | must-size-columns-to-widest-cell | render with `autoSizeColumns: true` | header and body cells align; column is as wide as widest cell |
| T14 | must-resize-columns-by-drag | drag column header's trailing border | column width changes; width persists if `columnWidthsKey` set |
| T15 | must-truncate-when-dragged-narrow | drag column narrower than content | cell text ellipsises; row heights remain aligned |
| T16 | must-enable-row-drag-to-reorder | drag row with `reorder` prop | `reorder.onDrop` fires with new position |
| T17 | must-respect-candrag-check | drag row where `canDrag(id)` = false | row does not enter dragged state; `onDrop` does not fire |
| T18 | must-add-leading-checkbox-column | render with `showSelectionCheckboxes: true` | leading column added with checkbox per row |
| T19 | must-include-select-all | click "Select all" checkbox | all visible rows selected |
| T20 | checkbox-click-not-select-row | click row checkbox | checkbox toggles; `onSelectionChange` fires; row does not fire `onRowClick` |

## Edge Cases

- The ⇧-click range is computed over the **current visible order** of `rows`.
- Ids no longer present in `rows` are pruned by the caller, not the component.
- With `onSortChange` omitted, sortable headers are inert (no sorting offered).
- `loading` and an empty `rows` array each render their dedicated state; `loading` takes precedence.
- "Select all" checkbox toggles only the rows in the current `rows` array, preserving selections outside it (e.g., on other pages or filtered views).
- Column widths stored in localStorage are not validated; if corrupted, they are silently ignored and fall back to measured size.
- If localStorage is full or access is blocked, widths still apply for the session but are not persisted.
- A column dragged narrower than 48px is clamped to that minimum.
- Drag operations that originate from in-cell controls (buttons, inputs) do not select rows; the control's own interaction takes precedence.

## Configuration

| Option | Type | Default | Description |
|---|---|---|---|
| `columns` | `DataTableColumn<T>[]` | — | Column definitions. |
| `rows` | `T[]` | — | Rows already in display order. |
| `getRowId` | `(row: T) => string` | — | Stable id for a row. |
| `selectedIds` | `Set<string>?` | — | Caller-owned selection set. Omit (with `onSelectionChange`) for action-list mode. |
| `onSelectionChange` | `((ids: Set<string>) => void)?` | — | Fired with a new `Set` on every selection edit. Omitting it disables selection entirely (action-list mode). |
| `onRowActivate` | `((id: string) => void)?` | — | Fired when a row is double-clicked or Enter is pressed on the focused row (only when table is selectable). |
| `sort` | `{ key: string; dir: "asc" \| "desc" }`? | — | Current sort (caller reorders `rows`). |
| `onSortChange` | `(sort) => void`? | — | Sort intent; if omitted, headers are inert. |
| `emptyLabel` | `string` | `"No items."` | Shown when `rows` is empty. |
| `loading` | `boolean` | `false` | Renders the loading state. |
| `ariaLabel` | `string` | — | Required grid label. |
| `className` | `string` | — | Extra classes on the container. |
| `autoSizeColumns` | `boolean` | `false` | Size columns to widest cell and allow user resizing. |
| `columnWidthsKey` | `string?` | — | Persist dragged column widths under this localStorage key. |
| `reorder` | `DataTableReorder?` | — | Enable row reordering via drag-and-drop. |
| `showSelectionCheckboxes` | `boolean` | `false` | Show a leading checkbox column (only if selectable). |
| `describeRow` | `(row: T) => string`? | — | Accessible label for a row (used in checkboxes and drag announcements). |

Column fields: `key: string`, `header: React.ReactNode`, `render?: (row: T, ctx: DataTableRowContext) => React.ReactNode` (default `String(row[key])`), `sortable?: boolean`, `width?: string` (e.g. `"12rem"` / `"1fr"`), `align?: "start" | "end"`, `resizable?: boolean`.

## Deep Linking

Not applicable: DataTable is a presentational primitive with no routing or URL-based state.

## Localization

Not applicable: DataTable accepts all user-facing strings as props (`ariaLabel`, `emptyLabel`, column `header`, `describeRow` for labels) — localization is the caller's responsibility.

## Accessibility Options

Not applicable: DataTable does not respond to system accessibility settings (Reduce Motion, Increase Contrast, etc.) — it relies on platform defaults and the caller's styling layer for theme compliance.

## Feature Flags

Not applicable: DataTable is a foundational primitive with no feature-gated behavior; feature gates on features using the table belong in the consuming application.

## Analytics

Not applicable: DataTable is a presentational primitive; it emits no structured log events or analytics. Consumer applications instrument their own models when a row is activated or the selection changes.

## Privacy

Not applicable: DataTable does not collect, store, or transmit user data. Row content is entirely caller-owned and may be sanitized by the caller before rendering.

## Logging

Not applicable: DataTable is a presentational primitive; it emits no structured log events. Consumers log events of interest (row activation, selection changes) in their own handlers.

## Platform Notes

- **Web/React**: Source file is `packages/web/packages/ui/src/components/data-table.tsx` (exported via the `./components/*` wildcard). Uses CSS Grid for layout, dnd-kit for drag-and-drop (via `SortableItem`, `SortableSurface`, `SortableZone`), and lucide-react for sort carets (`ChevronUp`, `ChevronDown`). Checkbox cells use a separate `Checkbox` component from the same UI package. Storage is via localStorage for column widths.
- **SwiftUI**: Start from `Table` (iOS 17+) or a `List` with `.listStyle(.inset(grouped))` for earlier versions. Selection maps to a SwiftUI `@State` binding tracking `Set<ID>`. Sorting maps to a data-binding holding the current sort column and direction; the table does not reorder rows itself. Column resize and reorder are not native SwiftUI affordances; consider using `List` with custom drag-and-drop or adopting a third-party component for advanced column operations.
- **Compose**: Start from a `LazyColumn` or `Column` with a custom row layout per column definition. Selection uses a mutable state `Set<ID>` held at the caller level. Sorting is caller-driven via a state binding; the component renders `rows` as given. Column resize and reorder require custom Modifier-based drag-and-drop handlers; dnd-kit or a platform equivalent provides the gesture layer.
- **AppKit / UIKit**: macOS (AppKit): start from `NSTableView` with `NSTableColumn` per column; selection maps to `selectedRowIndexes` binding. iOS (UIKit): `UITableView` is single-column, so use `UICollectionView` with a custom `UICollectionViewCompositionalLayout` for multi-column grids. Selection uses `UICollectionViewDelegate.didSelectItemAt` and an index-to-id mapping; sorting is caller-driven. Column resize and reorder (iOS) are limited; macOS `NSTableView` offers native resize.
- **WinUI 3**: Start from `DataGrid` (Microsoft.UI.Xaml.Controls, CommunityToolkit) or `ItemsView` with `ItemsRepeater` rows. Selection: use `DataGrid.SelectionMode = "Multiple"` or bind `SelectedItems` to a collection; track by id via a data object. Sorting: use `DataGrid` built-in sorting or manage `SortDescription` in a `CollectionViewSource` wrapping `rows`. Column resize: `DataGrid` columns are natively resizable; set `CanUserResizeColumns="True"`. Reorder: `DataGrid` does not natively reorder rows; use `ItemsRepeater` with `DragItemsStartingEventArgs` / `DragItemsCompletedEventArgs` or wire an external reordering gesture handler.

## Design Decisions

- **Caller-owned sorting.** The component reports `onSortChange` and renders `rows` as given, keeping sorting policy with the data owner rather than duplicating it inside the table.
- **Selection is a capability, not a mandate.** Omitting the selection props turns the same grid into an action-list table (admin's users/flags/feedback/api-tokens lists), so sites never fork a second table for rows whose interaction lives in per-cell controls.
- **Internal anchor is private.** The anchor id used for range selection is internal state and is not part of the public API. It is not reported to the caller, but is used to compute shift-click ranges.
- **Row activation is separate from selection.** Click selects, double-click (or Enter) opens/activates. This allows a table to support both multi-select (for bulk actions) and row opening (for details view) without conflict.
- **Reordering is opt-in and separate from sorting.** Reordering should be omitted when a sort or filter is active, because a dragged row's new position would describe the filtered/sorted view, not the underlying data. The caller owns this constraint and omits the `reorder` prop when appropriate.
- **Inline editing works with selection.** The table does not hijack keyboard or mouse events from in-cell controls (inputs, selects, buttons, contenteditable). This allows a row to be selected (driving a details pane) while remaining inline-editable.
- **Column sizing requires two pre-paint passes.** With `autoSizeColumns: true`, the component renders once at `max-content` (measuring each cell), then locks in explicit widths for the second pass. This ensures the header aligns with the body despite each row being its own grid. Both passes complete before paint, so no misaligned frame is visible.
- **Supersedes an earlier placeholder-grade table.** An earlier metadata-driven list was single-purpose and had no selection model; DataTable exists to be the general-purpose replacement.

## Compliance

No additional compliance categories apply to this presentational primitive.

## Change History

| Version | Date | Author | Summary |
|---|---|---|---|
| 1.0.0 | 2026-06-26 | Mike Fullerton | Initial conversion from legacy UI spec. |
| 1.1.0 | 2026-07-03 | Mike Fullerton | Selection made optional: omitting selectedIds/onSelectionChange yields action-list mode (no aria-selected, inert rows, in-cell controls own interaction). |
| 1.2.0 | 2026-07-11 | Mike Fullerton | **Content-sized + user-resizable columns** (`autoSizeColumns`, `columnWidthsKey`, per-column `resizable`), and **selectable tables can now host inline editors**. Sizing: a `max-content` track cannot do this on its own, because each row is its own grid — it would size every row independently and the header would not line up with the body. So the table renders one pass at `max-content`, measures the widest cell per column, and locks that in as an explicit px track shared by every row (both passes pre-paint, so no misaligned frame is shown), re-measuring when rows/columns change. A drag handle on each column's trailing border overrides the measured width; double-click springs it back; widths optionally persist. Editing: the selectable grid's Arrow/Space handlers `preventDefault` and its row `mousedown` handler `preventDefault`s to avoid focus-stealing — which swallowed spaces typed into an in-cell editor and stopped in-cell controls taking focus at all, making selection and inline editing mutually exclusive. Both now ignore events originating inside a cell control, so a row can be selected (driving a details pane) AND edited in place. New requirements `must-size-columns-to-widest-cell`, `must-resize-columns-by-drag`, `may-persist-column-widths`, `must-fill-slack-not-stretch`, `must-truncate-when-dragged-narrow`, `must-not-hijack-cell-controls`. |
| 1.3.0 | 2026-09-22 | Mike Fullerton | **Row activation, reordering, and selection checkboxes** (`onRowActivate`, `reorder`, `showSelectionCheckboxes`). Activation: double-click and Enter open a row when handler is provided; reaches keyboard-only users. Reordering: `reorder` prop enables drag-and-drop row reordering with accessible announcements and `canDrag` guards; omit when sorted/filtered. Checkboxes: `showSelectionCheckboxes` adds a leading column with per-row and select-all checkboxes; row labels derive from `describeRow` or row content. New requirements `double-click-activates-row`, `enter-activates-focused-row`, `must-enable-row-drag-to-reorder`, `must-respect-candrag-check`, `must-announce-drag-state`, `must-not-reorder-while-sorted`, `must-add-leading-checkbox-column`, `must-include-select-all`, `must-label-checkboxes`, `checkbox-click-not-select-row`. Platform Notes section added. Deep Linking, Localization, Accessibility Options, Feature Flags, Analytics, Privacy, Logging sections added with not-applicable explanations. |
| 1.3.1 | 2026-09-22 | Mike Fullerton | Platform Notes expanded to five separate bullets (SwiftUI, Compose, AppKit/UIKit, WinUI 3) with concrete guidance on control selection, property mapping, and platform-specific constraints. WinUI 3 bullet specifies DataGrid vs. ItemsRepeater, SelectionMode binding, sorting via SortDescription or built-in, column resize handling, and row reorder patterns. |
