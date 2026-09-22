---
id: 6acd3c5f-7bb5-4d6d-8c8d-141e1909cf73
title: "ListWithDetailsPane"
domain: agenticdevelopertoolkit://recipes/list-with-details-pane
type: recipe
version: 2.1.0
status: review
language: en
created: 2026-06-26
modified: 2026-09-22
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: "A master/detail block: a shared ListHeader (filter + actions) over a multi-select DataTable over a details pane whose divider is its always-visible header bar; list and details are peers."
platforms:
  - typescript
  - web
tags:
  - master-detail
  - table
  - layout
  - selection
ingredients:
  - agenticdevelopertoolkit://recipes/list-header
  - agenticdevelopertoolkit://recipes/data-table
  - agenticdevelopertoolkit://recipes/resizable-split
  - agenticdevelopertoolkit://recipes/alert-and-dialog
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# ListWithDetailsPane

## Overview

A master/detail block in `@agenticdevelopertoolkit/ui`: the shared `ListHeader`
(filter + actions + delete) over a `DataTable`, over a details pane. The list
and the details pane are PEERS in the column — the details never overlays the
list — and the divider between them renders as the details pane's always-visible
header bar (`ResizableSplit`'s header-bar variant, titled by `detailsLabel`). It
composes `ListHeader` + `DataTable` + `ResizableSplit` + `AlertModal` + `Button`.

It owns the selection state and filter; it renders rows in a `DataTable`
(clicking a row selects it; ↑/↓ move the selection — DataTable's keyboard nav),
and a bottom details pane that reflects the single selected row. It is generic
over row type `T`. Selection can be driven internally or mirrored to a URL
parameter for deep-linking (when `paramKey` is provided).

## Ingredients

| Name | Domain | Role | Required | Configuration |
|---|---|---|---|---|
| DataTable | agenticdevelopertoolkit://recipes/data-table | Renders filtered, multi-select rows | yes | `columns`, `rows`, `getRowId`, selection, `loading`, `emptyLabel`, `autoSizeColumns`, `columnWidthsKey`, `reorder` |
| ListHeader | agenticdevelopertoolkit://recipes/list-header | The filter + actions bar above the table | yes | `search` from `filterText`/`onFilterTextChange`; `actions` from `actions` + Delete |
| ResizableSplit | agenticdevelopertoolkit://recipes/resizable-split | Top/bottom split: table on top, details below its header-bar divider (`header={detailsLabel}`) | yes | `storageKey` forwarded from props; persists split bar position |
| AlertAndDialog | agenticdevelopertoolkit://recipes/alert-and-dialog | Destructive confirm shown before delete | yes | `destructive` tone; copy from `deleteConfirm` |

Composed shared primitives without their own recipe domains: `Button` (toolbar
actions + Delete), `Input` (filter box), and `Separator` (`dividerBefore`).

## Integration Requirements

- **must-own-selection**: The ListWithDetailsPane MUST own the selection state as
  a `Set<string>` and pass it to `DataTable`; selection MUST survive filter
  changes and MUST be pruned only when a row id leaves the `rows` prop.
- **must-filter-rows**: The ListWithDetailsPane MUST filter rows by `filterRow`
  (default: case-insensitive substring over the columns' rendered/scalar text)
  before the table, using the controlled `filterText`/`onFilterTextChange` when
  provided and internal state otherwise.
- **must-disable-selection-actions**: Action buttons with `requiresSelection` and
  the Delete button MUST be `disabled` whenever the selection is empty.
- **must-confirm-delete**: When Delete is activated and `onDelete` is set, the
  ListWithDetailsPane MUST open an `AlertModal` (`destructive`, copy from
  `deleteConfirm`) before calling `onDelete(selectedIds)`, and on confirm MUST
  clear the deleted ids from the selection.
- **must-render-detail-states**: The details pane (the `ResizableSplit` bottom)
  MUST render `emptyDetail` (default "Select a row to see details.") when 0 rows
  are selected, `renderDetail(row)` when exactly 1 row is selected, and the hint
  "Select a single row to see details." when more than 1 row is selected.
- **must-render-divider-before-action**: A `ListAction` with `dividerBefore: true`
  MUST render a `Separator` immediately before its button in the toolbar.
- **must-use-list-header**: The toolbar MUST be the shared `ListHeader` (filter
  field left, actions right) so every list header on the platform matches.
- **must-render-details-header-bar**: The split's divider MUST render as the
  details pane's header bar (`ResizableSplit` `header={detailsLabel}`, default
  `"Details"`): always visible, drag anywhere on it, disclosure chevron far
  right, animated collapse, reveal-to-fit on expand.
- **keyboard-moves-selection**: With the table focused, ↑/↓ MUST move the
  selection (DataTable's keyboard navigation).
- **must-support-url-driven-selection**: When `paramKey` is provided, the
  component MUST mirror the single selected row's id into `?<paramKey>=<id>` via
  `history.replaceState` (selecting a row neither remounts the route nor spams
  the history stack) and MUST seed initial selection from the URL parameter on
  mount; a 0-or-many selection clears the URL parameter.
- **must-persist-column-widths**: When `columnWidthsKey` is provided, the
  component MUST persist the user's dragged column widths under that key (via
  `DataTable`); this is distinct from `storageKey` which persists only the
  split-bar position.
- **must-support-column-reordering**: When `reorder` is provided (a
  `DataTableReorder` config), the component MUST forward it to `DataTable` to
  allow rows to be dragged into a new order; withhold reordering when the filter
  is non-empty (because filtered rows are a selection, not a position in the list).
- **must-restore-stale-deep-link**: When a URL-seeded selection points to a row
  id that no longer exists in `rows` (deleted/renamed), the component MUST clear
  that id from both state and the URL, so a stale link fails safe to "nothing
  open" rather than blank screen.

## Layout

```
┌ ListHeader ─────────────────────────────────────────────────────────┐
│ [ 🔍 filter… ]                           [ …actions… ] | [ Delete ]  │
├─────────────────────────────────────────────────────────────────────┤
│  DataTable (filtered, multi-select)                        ▲ top     │
├ Details ──────── (drag anywhere on the bar) ─────────────────── ⌄ ──┤
│  details:                                                  ▼ bottom  │
│    0 selected → emptyDetail ("Select a row to see details.")         │
│    1 selected → renderDetail(row)                                    │
│   >1 selected → "Select a single row to see details."                │
└─────────────────────────────────────────────────────────────────────┘
```

- Toolbar: the shared `ListHeader` (recessed ButtonBar strip); filter `Input`
  with search icon; spacer `flex-1`; actions right-aligned.
- Details pane: `p-4 text-sm text-apt-text`; hints in `apt-text-muted`.
- The split wrapper uses `min-h-[16rem] flex-1`: `flex-1` claims the remaining
  column height, and the floor prevents the split from collapsing to 0 when the
  container is over-full (ensuring table rows remain hit-testable).
- The bottom pane is draggable + collapsible (disclosure) per `ResizableSplit`.
- No raw hex; no `!important`.

## Shared State

| State | Source | Consumer | Direction | Mechanism |
|---|---|---|---|---|
| selection (`Set<string>`) | ListWithDetailsPane | DataTable, toolbar action + Delete buttons, URL parameter | Down & Up | Component state + prop drilling + `history.replaceState` (when `paramKey` provided) |
| filterText | Caller (controlled) or internal state | Row filter → DataTable | Down | Controlled prop `filterText`/`onFilterTextChange` or internal state |
| rows (`T[]`) | Caller | DataTable, details pane, stale-link pruning | Down | Prop |
| deleteConfirm open | ListWithDetailsPane | AlertAndDialog (AlertModal) | Down | Boolean state |
| selectedIds on delete | ListWithDetailsPane | Caller `onDelete` | Up | Callback |
| split bar position | ListWithDetailsPane | ResizableSplit | Down | localStorage via `storageKey` |
| column widths | User (drag) | DataTable | Down | localStorage via `columnWidthsKey` |

## Integration Test Vectors

| ID | Requirements | Input | Expected |
|---|---|---|---|
| T1 | must-filter-rows | Type `ada` in the filter | Table narrows to rows matching `ada` |
| T2 | must-own-selection | Select rows, then change the filter | Selection persists across filtering |
| T3 | must-disable-selection-actions | 0 rows selected | Delete and `requiresSelection` actions are disabled |
| T4 | must-disable-selection-actions | ≥1 row selected | Delete and `requiresSelection` actions are enabled |
| T5 | must-confirm-delete | Click Delete with rows selected, confirm | `AlertModal` opens; on confirm `onDelete(selectedIds)` is called and removed ids leave the selection |
| T6 | must-render-detail-states | Select 0 / 1 / >1 rows | Details pane shows `emptyDetail` / `renderDetail(row)` / the multi-select hint |
| T7 | must-render-divider-before-action | An action with `dividerBefore: true` | A `Separator` renders before that action's button |
| T8 | must-support-url-driven-selection | Provide `paramKey="id"`, select a row | URL updates to `?id=<rowId>` without remounting; reload restores selection |
| T9 | must-restore-stale-deep-link | URL has `?id=deleted-id`, rows load without that id | URL parameter is cleared, selection is empty |
| T10 | must-persist-column-widths | Provide `columnWidthsKey`, drag a column wider, reload | Column width persists across reload |
| T11 | must-support-column-reordering | Provide `reorder` config, filter is empty | Rows are draggable to reorder; reorder is disabled when filter is active |

## Edge Cases

- 0 selected → `emptyDetail`; exactly 1 → `renderDetail`; >1 → the multi-select
  hint.
- A filter matching no rows shows the table's `emptyLabel`, while the selection
  of rows no longer visible is retained (ids are pruned only when a row leaves
  `rows`).
- `loading` → the `DataTable` loading state; empty data → `emptyLabel`.
- After the caller removes rows on delete-confirm, the component clears the
  removed ids from its selection (and the URL parameter, if `paramKey` is set).
- When `onDelete` is not provided, no Delete button is rendered.
- When `paramKey` is provided but the URL parameter points to a row no longer in
  `rows`, the parameter is cleared and selection is empty (fail-safe to
  "nothing open").
- When both `paramKey` and a controlled `filterText` are provided, the initial
  URL-seeded selection is restored before the external filter is applied.
- The layout floor (`min-h-[16rem]`) ensures that when a container is
  over-constrained, the page's own scroll takes overflow and rows remain
  hit-testable (without the floor, the split compresses to 0 and rows become
  unclickable despite appearing in layout).

## Platform Notes

- **React / Web (TypeScript):** Block at `packages/web/packages/ui/src/blocks/list-with-details-pane.tsx` (exported via `./blocks/*`). Composes `DataTable`, `ResizableSplit`, `AlertModal`, `Button`, `Input`, `Separator`. Core responsibilities: filter state (controlled-or-internal), multi-select state as `Set<string>`, URL parameter sync (when `paramKey` provided), stale-link pruning on row changes, split bar and column width persistence via localStorage. Consumed by admin "Invitations" topics and admin-notes modal.
- **SwiftUI:** Start with a `@State` var for selection (`Set<String>`), a `List` for the rows (or a custom table if columns are needed), an `@ViewBuilder` for the detail pane, and a `Divider` between them. Adapt the controlled-or-internal filter pattern using `@State` for internal state and a binding for controlled. The URL parameter pattern (`URLComponents`, `history.replaceState` equivalent) requires reading/writing `NavigationPath` or the app's own route state. Stale-link pruning happens on every rows change (in `onChange` of the list selection or a `.task` tracking rows). Column width and split position persistence use `@AppStorage` or `UserDefaults`. No equivalent to `AlertModal` builtin; compose `Alert` or `ConfirmationDialog`. Master/detail layout uses `NavigationSplitView` (iPad) or conditional `.sheet` (iPhone).
- **Compose:** Build with `Column` wrapping a `TextField` (filter), a `LazyColumn` for rows (with selection state as `MutableState<Set<String>>`), and a divider + details pane below. Adapt the controlled-or-internal filter pattern with `mutableStateOf()` for internal and a lambda callback for controlled. URL parameter sync (if needed) maps to reading/writing a route state managed by the app's navigation. Stale-link pruning is a `LaunchedEffect` tracking rows. Column width and split position use `SharedPreferences` or a data store. No builtin confirm dialog; use `AlertDialog` or Material's `Dialog`. Master/detail split uses `BoxWithConstraints` to decide portrait/landscape layout — iPad in landscape is side-by-side, phone is stacked (overflow scrolls).
- **AppKit / UIKit:** Start with a view controller or SwiftUI `View` (UIKit is legacy; SwiftUI is preferred). Use `NSTableView` (AppKit) or `UITableViewController` (UIKit, legacy) for the table, or compose list-like views if a true table isn't needed. Selection state is a property (mutable set or array). Filter uses a text field and a predicate applied to rows before the table. Stale-link pruning on rows changes (KVO or didSet). Split position via `NSSplitViewController` (AppKit) or manually constraining two views with a draggable divider (UIKit). URL parameter sync (if needed) uses `URLComponents` and reads/writes app state (no `history.replaceState` in native apps; this is web-specific). Persistence uses `UserDefaults` or `NSCoding`. Confirm dialogs use `NSAlert` (AppKit) or `UIAlertController` (UIKit). Not applicable to shipped Apple products in M1 scope (only web and TypeScript shipped); a port is planned in M6.
- **WinUI 3:** Build using `Grid` rows: top row is a toolbar (`CommandBar` or `StackPanel` of `Button` + `TextBox` for filter), middle row is `DataGrid` (bound to rows, selection via `SelectedItemsChanged` event), bottom row is a details pane (a `ScrollViewer` with a `StackPanel` of detail content). Selection state is a C# property (`ObservableCollection<T>` or `HashSet<string>`). Filter uses a `TextBox.TextChanged` event to apply a predicate. Stale-link pruning is a property change handler on rows. Split position (draggable divider) uses `Grid.RowDefinition` with `*` (flex) sizing and a `GridSplitter` between rows; persist via `ApplicationData.Current.LocalSettings`. URL parameter sync (`paramKey` feature) is web-specific and not applicable to WinUI 3. Confirm dialog uses `ContentDialog`. Column width persistence: `DataGrid` columns expose a `Width` property; save/restore in app settings.

API (`@agenticdevelopertoolkit/ui/blocks/list-with-details-pane`):

```ts
interface ListAction {
  id: string
  label: React.ReactNode
  onClick: (selectedIds: string[]) => void
  requiresSelection?: boolean        // disabled when 0 selected
  dividerBefore?: boolean            // visual separator before this action
  variant?: Button["variant"]        // default "outline"
}
interface ListWithDetailsPaneProps<T> {
  columns: DataTableColumn<T>[]
  rows: T[]
  getRowId: (row: T) => string
  renderDetail: (row: T) => React.ReactNode
  emptyDetail?: React.ReactNode      // default "Select a row to see details."
  filterText?: string                // controlled; internal state if omitted
  onFilterTextChange?: (t: string) => void
  filterPlaceholder?: string         // default "Filter…"
  filterRow?: (row: T, query: string) => boolean   // default: stringify visible columns, case-insensitive contains
  onDelete?: (selectedIds: string[]) => void
  deleteConfirm?: { title: string; description?: React.ReactNode }  // AlertModal copy
  actions?: ListAction[]
  storageKey?: string                // forwarded to ResizableSplit, persists split bar position
  paramKey?: string                  // opt-in URL-driven selection (deep-linkable detail row): mirror single selected row to ?<paramKey>=<id>
  loading?: boolean
  emptyLabel?: string                // table empty text
  autoSizeColumns?: boolean           // size each column to its widest cell, user can drag to override
  columnWidthsKey?: string            // persist dragged column widths under this key (distinct from storageKey)
  reorder?: DataTableReorder          // allow rows to be dragged into a new order; withhold when filter is non-empty
  detailsLabel?: string              // title on the details pane's header bar (default "Details")
  ariaLabel: string                  // toolbar label
  className?: string
}
export function ListWithDetailsPane<T>(props: ListWithDetailsPaneProps<T>): React.ReactElement
```

Accessibility: the toolbar is `role="toolbar"` + `aria-label`; Delete/action
buttons have labels and their `disabled` reflects the selection. The delete
`AlertModal` traps focus and is keyboard-dismissable (its own contract).

## Design Decisions

- **Decision**: The block owns selection as a `Set<string>` rather than the table
  owning it. **Rationale**: Selection must survive filtering and feed the toolbar
  actions and details pane.
- **Decision**: Generic over row type `T`. **Rationale**: Reusable platform-wide
  for any "Invitations"-style master/detail view.
- **Decision**: Delete always routes through a destructive `AlertModal` confirm.
  **Rationale**: Deletion is destructive; a confirm prevents accidental loss.
- **Decision**: Filter is controlled-or-internal. **Rationale**: Callers can drive
  or observe the query when needed, but the common case requires no wiring.
- **Decision**: URL-driven selection is opt-in via `paramKey`. **Rationale**:
  Deep-linking (via URL parameter) is a web pattern and not all use cases need
  it; omitting `paramKey` preserves the legacy internal-state-only behavior
  byte-for-byte. When provided, selecting a row mirrors the id to the URL and
  reloading or sharing the link restores the open row without remounting.
- **Decision**: `storageKey` persists split bar position only, not selection.
  **Rationale**: Selection is ephemeral (the user opened a row to read it, not
  to remember it forever); the split position is a layout preference worth
  retaining. A separate `columnWidthsKey` persists column widths, orthogonal to
  split position.

## Compliance

| Check | Status | Category |
|---|---|---|
| Artifact formatting (recipe) | passed | artifact-formatting |
| UI guidelines — no raw hex, no `!important` | passed | adh-ui-guidelines |

## Change History

| Version | Date | Author | Summary |
|---|---|---|---|
| 2.1.0 | 2026-09-22 | Mike Fullerton | Add URL-driven selection (`paramKey`), column width persistence (`columnWidthsKey`), row reordering (`reorder`), and auto-sizing (`autoSizeColumns`); expand Platform Notes to cover all five platforms with implementation guidance; document responsive layout floor (`min-h-[16rem]`); add new integration requirements and test vectors. |
| 2.0.0 | 2026-07-10 | Mike Fullerton | Toolbar extracted into the shared ListHeader; divider renders as the details pane's always-visible header bar (`detailsLabel`); list/details peer layout + keyboard selection made explicit. |
| 1.0.0 | 2026-06-26 | Mike Fullerton | Initial conversion from legacy UI spec. |
