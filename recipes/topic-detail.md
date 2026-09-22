---
id: 8fa7aaae-df62-44ea-b10c-182f3094ed9f
title: Topic Detail
domain: agenticdevelopercookbook://recipes/topic-detail
type: ingredient
version: 1.5.0
status: review
language: en
created: '2026-06-26'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: "The reusable two-pane primitive: a selectable topic list (left rail) beside a detail pane (right) — the adh.com/home rail|content split."
platforms:
  - typescript
  - web
tags:
  - topic-detail
  - master-detail
  - two-pane
  - navigation
depends-on: []
related: []
references: []
---

# Topic Detail

## Overview

**TopicDetail** is the reusable two-pane primitive — a selectable topic list on the left rail beside a detail pane on the right, exactly the adh.com/home rail|content split. It is *only* the split: no title row and no action bar — those are composed around it by the consumer. It is a faithful port of the hub's settings rail (CSS → utilities with `apt-*` tokens) so home and the shared library render identically. It fills its container, so give it a height.

The topic list is always collapsible (a core part of the site design, not a config flag): a desktop collapse toggle shrinks the rail to a thin icon-only strip for more pane room. Every topic stays clickable as its icon, the active icon keeps the gold selection bar, and the header affordances stay put. On mobile (≤768px) the rail becomes a horizontal wrap with the selection bar on the bottom edge.

## Behavioral Requirements

- **must-render-two-panes**: The component MUST render a left topic-list rail beside a right detail pane that fills the container.
- **must-mark-selected**: The list item whose `id` equals `selectedId` MUST be marked active (gold selection bar + `aria-current="true"`).
- **must-report-selection**: Clicking a non-disabled, non-covered-already-selected item MUST call `onSelect` with that item's `id`.
- **must-skip-disabled**: A `disabled` item MUST be dimmed and non-interactive (no `onSelect`, no delete button, no hover affordance).
- **must-render-label**: Each item MUST render its `label` as the primary text.
- **must-render-label-suffix**: An item with `labelSuffix` MUST render it on the same line as the label, distinct from `sublabel` (both are name components, not metadata).
- **must-render-inline-sublabel**: An item with `inlineSublabel=true` and a `sublabel` MUST render the sublabel on the SAME line as the label (dim), the label keeping layout priority (grows + truncates first) and the sublabel shrinking + truncating after it — instead of the default stacked second line. The inlineSublabel MUST have no effect in the collapsed/covered icon-only strip (which hides the label entirely).
- **must-render-stacked-sublabel**: An item with `sublabel` but no `inlineSublabel` MUST render the sublabel as a second line (dim, smaller text).
- **must-render-preview**: An item with `preview` text and `previewLines > 0` MUST render the preview as a third line block (dim, smaller text, clamped to the specified number of lines, preserving source line breaks).
- **must-clamp-preview**: Preview lines MUST be clamped to 0-4, with 0 rendering no preview at all (allowing consumers to keep passing `preview` and toggle display via the `previewLines` number alone).
- **must-render-icon**: Each item MUST render a 16px leading icon; a neutral ring icon MUST fill in when `icon` is omitted.
- **must-hide-label-when-collapsed**: When the rail is collapsed to an icon-only strip, labels MUST be hidden and the item's `label` MUST be carried as an `aria-label` on the button element and shown in a right-side tooltip on hover/focus.
- **must-render-empty-label**: With no items, the rail MUST show `emptyLabel`.
- **must-support-rail-slot**: When `railSlot` is provided it MUST render in a leading slot above the topics, reserved at a fixed height so the first topic row sits at the same vertical position whether or not a slot is present. When `railSlotActive`, the selection bar MUST move onto that slot. A `(collapsed: boolean) => ReactNode` render-prop form MUST receive the rail's collapsed state so the slot can shrink (e.g., to an icon-only `+` when undisclosed).
- **must-render-divider-after**: An item with `dividerAfter=true` MUST render a separator line after it (visible in expanded list only, not in collapsed/covered icon strips).
- **must-render-spacer-after**: An item with `spacerAfter=true` MUST render a flexible spacer after it that pushes all following items to the rail's bottom edge (e.g., a bottom-pinned Settings) — in the full expanded rail AND in the collapsed/covered icon strips alike.
- **must-respond-mobile**: At viewport width ≤768px the rail MUST become a horizontal wrap below the detail pane with a bottom selection bar instead of a left bar.
- **must-collapse-rail**: The rail is always collapsible — the component MUST offer a top-right desktop toggle (hidden on mobile ≤768px) that collapses the rail to a COLLAPSED_RAIL-width (48px) icon-only strip and expands it again. Collapsibility is intrinsic, not configurable.
- **must-support-controlled-collapse**: When `collapsed` + `onCollapsedChange` props are provided the collapse state MUST be controlled from outside; otherwise it MUST self-manage from `defaultCollapsed` (default false).
- **must-support-drag-resize**: When `onResize` is provided the component MUST render a drag handle on the rail's trailing edge (desktop only) that reports the column's new width. Dragging narrower than a third of the full width MUST snap the rail to collapsed; dragging out of the collapsed range or past the full width MUST snap back to full width.
- **must-transition-collapse**: Rail width changes MUST animate via CSS transition (respecting the user's `prefers-reduced-motion` OS setting); transition MUST be suppressed during active dragging.
- **must-support-trailing-accessory**: An item with `trailing` content MUST render it right-justified in the expanded list (hidden in collapsed/covered icon strips).
- **must-support-delete-action**: An item with `onDelete` callback MUST render a hover/focus-revealed trash button in the expanded list; clicking it MUST open a confirmation dialog. When confirmed (action button), the `onDelete` callback MUST run (may be async — dialog shows spinner until settled). Dialog is destructive (red action, initial focus on Cancel). When `onDelete` throws, dialog MUST remain open without spinner so the user can retry or cancel. Trash button MUST not render in collapsed/covered icon strips or on disabled rows.
- **must-support-delete-label**: A deletable item with `deleteLabel` MUST use it as the accessible name for the trash button and the subject in the confirmation dialog title; otherwise default to the item's `label`.
- **must-support-delete-confirm**: A deletable item with `deleteConfirm` MUST render it as the confirmation dialog's body copy; otherwise default to "This action can't be undone."
- **must-render-blocked-marker**: An item with `blocked=true` MUST render an amber dot on the icon (visible in expanded, collapsed, and covered layouts — exactly where a user hunting for a greyed-out Save button needs to see it) and append a screen-reader-only ", needs attention" announcement to the row's accessible name. The marker MUST carry `data-blocked="true"` for programmatic selection.
- **must-support-leading-slot**: When `railSlot` is provided as a function it MUST receive the `collapsed` state so it can adapt (e.g., drop visual labels when collapsed).
- **must-support-header-slot**: When `headerSlot` is provided it MUST render as a full-width strip below the titled header (hidden while collapsed); this hosts the shared ListHeader (filter + actions) for entity lists in the stack.
- **must-support-titled-header**: When `title` is provided the rail MUST render a titled header row with: the title left-justified (aligned to the row-label column), a fixed control slot (16px, where row icons sit), optional `titleActions` right-justified before the toggle, a create affordance `+` right-justified (fires `onNew`), and a collapsible desktop toggle (`«`/`»`).
- **must-support-create-affordance**: When `onNew` is provided the rail MUST render a right-justified `+` button in the header (in titled or untitled headers). The button MUST tint gold when `newActive=true` (signalling in-progress create with nothing selected). Button MUST carry `aria-label` and tooltip with `newLabel` (default "New").
- **must-show-busy-indicator**: When `busy=true` the rail MUST show a small spinning indicator — immediately before the title (if titled) or in the top-right of the untitled header. The indicator MUST be present even on mobile (a read is worth announcing on mobile too), and MUST be paired with an `aria-live="polite"` announcement that says "Loading" when busy.
- **must-support-back-slot**: When `backSlot` is provided it MUST render in the top-left of the untitled header (e.g., a "Back" button).
- **must-support-left-control**: When `leftControl` is provided it MUST render in place of the top-left header content (e.g., a covered style's `«`/`»` cover toggle); mutually exclusive with `showToggle` (should pass `showToggle=false` when providing `leftControl`).
- **must-support-footer**: When `footer` is provided it MUST render as a pinned strip at the bottom of the rail (with a top border) — e.g., a "New…" affordance.
- **must-support-close-button**: When `onClose` is provided the rail MUST render a right-justified close button (✕) in the header — used by hierarchical stacks to dismiss child menus. Button MUST carry `aria-label` and tooltip with `closeLabel` (default "Close").
- **must-support-row-disclosure**: When `rowDisclosure=true` the component MUST render a right-justified chevron (ChevronRight, 14px) on every non-disabled selectable row in the expanded list (hidden in collapsed/covered and on disabled rows), signalling that picking it discloses another pane (narrow/nav-stack layout affordance).
- **must-support-covered-shadow**: When `coveredShadow=true` the rail MUST cast a subtle left drop-shadow (used by hierarchical stack to show physical layering of a child rail peeking over a covered parent).
- **must-support-covered-style**: When `covered=true` the rail MUST render rows as a left-aligned icon-only strip (icons centered, no labels or accessories). Clicking a covered row MUST never toggle/unselect — selecting simply changes the selection; clicking an already-selected row in covered style is a no-op.
- **must-support-marker-selection**: When `selectionStyle="marker"` the component MUST mark the selected row with a full-height left dash (root only) and parent→child connector line (drawn by hierarchical overlay), not the classic gold bar. Root rows get the dash; non-root rows are marked by the connector line alone.
- **must-support-hover-bar**: When `hoverBar=false` the component MUST NOT render a left bar on hover of unselected rows (used by cascade menus where hover is conveyed by row un-dimming and a bar would be noise).
- **must-hide-row-icons**: When `hideItemIcons=true` the component MUST drop the leading icon from every row in the expanded list (for identity-less lists like documents; collapsed/covered strips ignore this, they are always icon-only).
- **must-support-prefetch**: When `onPrefetch` is provided the component MUST call it with the row's `id` once pointer or keyboard focus has rested on that row for 100ms (fire-and-forget, no UI). Never arm on the already-selected row (its data is already loaded). Disarm on pointer/focus leave.
- **must-support-batch-mode**: When `checkable=true` the component MUST render a checkbox on every row in the expanded list (hidden in icon-only), allowing multiple selection independent of the active row selection. The active row's single selection behavior is preserved underneath — ticking a box is not selecting a row.
- **must-manage-batch-checked**: When `checkedIds` is provided the component MUST reflect its contents in the checkboxes (read-only from the component's side). Checking/unchecking a box MUST call `onToggleChecked` with that item's `id`; the owner writes back.
- **must-fit-width**: When `onFit` is provided the component MUST report the intrinsic width (`max-content`) of the rail's rows, clamped to [MIN_FIT_RAIL, MAX_FIT_RAIL] (150–420px default), immediately before paint and again when web fonts load (in px). Never report when collapsed (icon strip has a fixed width by definition). Used by hierarchical stack to auto-size the rail.
- **must-support-pan-padding**: When `panePadding=true` (default) the detail pane MUST add standard content inset (`gap-6 px-6 py-4`). When false, content is edge-to-edge so consumers can compose rows with their own insets.
- **must-be-fill-container**: The component MUST fill its container height and width — give it an explicit container height or a `flex-1` parent.

## Appearance

Grid layout: `md:grid-cols-[240px_minmax(0,1fr)]` (full rail 240px, collapsed 48px). Rail uses `bg-apt-nav` with `border-r` on desktop / `border-b` on mobile (≤768px). Rail items are monospace `text-[0.8rem]` tracking `0.02em` with a left selection bar (`border-l-2`): active = `border-l-apt-gold text-apt-gold`, hover = `border-l-apt-text`, disabled = `text-apt-text-dim`. At ≤768px items wrap horizontally and the bar moves to `border-b-2`. The detail pane is `bg-apt-surface`; with `panePadding` it adds `gap-6 px-6 py-4`. Dividers use `bg-apt-border`. Blocked marker: amber `bg-apt-orange`. Header: `border-b border-apt-border`. Drag handle: `cursor-col-resize`, `hover:bg-apt-gold/40`. Create button + close button: `text-apt-text-muted` default, `hover:text-apt-text`, focused `ring-apt-gold/40`. Busy spinner: `text-apt-text-muted`, `animate-spin`. Delete button: `bg-apt-nav text-apt-text-dim`, `hover:text-apt-red`, focused `ring-apt-red/40`. No raw hex; no `!important`.

## States

| State | Appearance change |
|---|---|
| no selection | no active item (bar may sit on an active rail slot) |
| item active | gold left bar + gold text + `aria-current="true"` |
| item hover | text-colored left bar (if `hoverBar=true`) |
| item disabled | dimmed text, non-clickable |
| item blocked | amber dot on icon + sr-only announcement |
| rail collapsed | thin strip (48px) with `»` expand control |
| rail dragging | transition suppressed, tracks pointer live |
| delete pending | confirmation dialog open, spinner during async delete |
| batch: checkbox checked | box shows check mark |
| batch: checkbox unchecked | box empty |
| covered style | icon-only left-aligned strip |
| ≤768px | horizontal wrap; selection bar on bottom edge; collapse toggle hidden |
| `busy=true` | spinner visible in header / top-right of untitled header |
| `railSlot` active | gold bar on the slot (when nothing in list is selected) |
| selection style "marker" | full-height left dash (root) + connector line (hierarchical) instead of bar |

## Accessibility

Items are real `<button>` elements (keyboard focus + activation); the active item carries `aria-current="true"` and disabled items are native `disabled` buttons. Icon-only rows carry the item's `label` as `aria-label`. Divider rows use `role="separator"`. The collapse toggle carries `aria-label` ("topic list" by default, or `railLabel` for override). Delete button: `aria-label="Delete {deleteLabel}"`. Create button: `aria-label="{newLabel}"` (default "New"). Close button: `aria-label="{closeLabel}"` (default "Close"). Resize handle: `role="separator"`, `aria-orientation="vertical"`, `aria-label="Resize topic list"`. Blocked state: `aria-label` includes ", needs attention" + decorative amber dot. Batch checkbox: `aria-label="{itemLabel}"`. Busy indicator: paired with `aria-live="polite" role="status"` region (text says "Loading" when busy, blank when not). Prefetch is fire-and-forget with no UI. Delete confirmation dialog is destructive (keyboard shortcuts off, initial focus on Cancel).

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|---|---|---|---|
| T1 | must-render-two-panes | `items` + `children` | rail and pane both render, rail on left (desktop) |
| T2 | must-mark-selected | `selectedId="x"` | item x shows the gold bar + `aria-current="true"` |
| T3 | must-report-selection | click item "y" | `onSelect("y")` fires |
| T4 | must-skip-disabled | click a `disabled: true` item | no `onSelect` fires; item text dimmed; no hover bar |
| T5 | must-render-empty-label | `items=[]` | `emptyLabel` shown in the rail |
| T6 | must-support-rail-slot | `railSlot={(c)=>…}` + `railSlotActive: true`, collapsed | slot above topics; gold bar on the slot; render-prop gets `collapsed: true` → icon-only `+` |
| T7 | must-render-label | `items=[{id: "x", label: "A"}]` | text "A" shown on the row |
| T8 | must-render-label-suffix | `{label: "A", labelSuffix: "v2"}` | text "A v2" on the row (suffix distinct) |
| T9 | must-render-inline-sublabel | `{label: "A", sublabel: "b.com", inlineSublabel: true}` | single line: "A" (full width) "b.com" (dim, shrinks) |
| T10 | must-render-stacked-sublabel | `{label: "A", sublabel: "b.com"}` (no inlineSublabel) | two lines: "A" then "b.com" (dim, smaller) |
| T11 | must-render-preview | `{preview: "My note", previewLines: 2}` | three lines: label, sublabel (if set), preview (dim, 2-line clamp) |
| T12 | must-clamp-preview | `{preview: "Text", previewLines: 0}` | no preview shown (label/sublabel only) |
| T13 | must-render-icon | `{icon: <ChevronRight />}` | 16px icon rendered |
| T14 | must-render-icon | item with no `icon` prop | neutral ring icon (16px) fills in |
| T15 | must-hide-label-when-collapsed | `collapsed: true` | row shows only icon, label in `aria-label`, tooltip on hover/focus |
| T16 | must-render-divider-after | `{dividerAfter: true}` | separator line below the item (expanded list only) |
| T17 | must-render-spacer-after | `{spacerAfter: true}` at position 2 in 5-item list | items 3–5 sit at the rail's bottom edge |
| T18 | must-respond-mobile | viewport 375px width | rail wraps horizontally below pane; rows have bottom bar (`border-b`) |
| T19 | must-collapse-rail | click the `«` toggle (desktop ≤768px hidden) | rail narrows to 48px icon strip; icons keep gold bar; toggle becomes `»` |
| T20 | must-support-controlled-collapse | `collapsed: true`, `onCollapsedChange` set | toggling calls `onCollapsedChange(false)`; rail follows `collapsed` prop |
| T21 | must-support-drag-resize | drag trailing edge to 100px then 50px | `onResize(100)` fired; then snap to collapsed (48px) when crossing threshold |
| T22 | must-render-blocked-marker | `{blocked: true}` | amber dot on icon; `aria-label` says ", needs attention"; `data-blocked="true"` on row |
| T23 | must-support-delete-action | `{onDelete: async () => { … }}` | hover reveals trash button; click opens confirm dialog; confirm runs `onDelete` |
| T24 | must-support-delete-label | `{onDelete: () => {}, deleteLabel: "Workspace"}` | trash button `aria-label="Delete Workspace"`; dialog title `"Delete Workspace?"` |
| T25 | must-support-delete-confirm | `{onDelete: () => {}, deleteConfirm: "Permanent loss."}` | dialog body says "Permanent loss." |
| T26 | must-support-trailing-accessory | `{trailing: <Badge count={3} />}` | badge right-justified in expanded list (hidden when collapsed) |
| T27 | must-support-header-slot | `headerSlot={<Filter />}`, `title: "Users"` | filter strip below titled header (hidden when collapsed) |
| T28 | must-support-titled-header | `title: "Topics"` | titled header with divider, title left-aligned, `+` and toggle right-justified |
| T29 | must-support-create-affordance | `onNew: () => {}, newLabel: "New Topic"` | `+` button in header; `aria-label="New Topic"`; tints gold when `newActive: true` |
| T30 | must-show-busy-indicator | `busy: true` | spinner visible in header / top-right; `aria-live` region says "Loading" |
| T31 | must-support-back-slot | `backSlot={<Back />}` (untitled) | Back button top-left of header |
| T32 | must-support-left-control | `leftControl={<Toggle />}`, `showToggle: false` | Toggle top-left; desktop collapse toggle hidden |
| T33 | must-support-footer | `footer={<Stats />}` | Stats strip pinned at rail bottom (with top border) |
| T34 | must-support-close-button | `onClose: () => {}, closeLabel: "Dismiss"` | ✕ button top-right of header; `aria-label="Dismiss"` |
| T35 | must-support-row-disclosure | `rowDisclosure: true` | ChevronRight (14px) on every non-disabled row (expanded list only) |
| T36 | must-support-covered-style | `covered: true` | rows left-aligned icon strip; click already-selected row is no-op |
| T37 | must-support-marker-selection | `selectionStyle: "marker"`, `isRoot: true` | selected root row shows full-height left dash instead of bar |
| T38 | must-support-hover-bar | `hoverBar: false` | no left bar appears on row hover |
| T39 | must-hide-row-icons | `hideItemIcons: true` | leading icon hidden in expanded list (collapsed/covered unaffected) |
| T40 | must-support-prefetch | `onPrefetch: (id) => { … }`, hover row "x" for 100ms | `onPrefetch("x")` fires once after dwell |
| T41 | must-support-batch-mode | `checkable: true` | checkbox on every expanded-list row; unchecked by default |
| T42 | must-manage-batch-checked | `checkedIds: new Set(["x"])` | checkbox on item x is checked |
| T43 | must-fit-width | `onFit: (w) => {}` | `onFit` called with row width in px (clamped to 150–420) before paint |
| T44 | must-support-pan-padding | `panePadding: false` | pane content is edge-to-edge (no inset) |

## Edge Cases

- **Empty list**: when `items.length === 0` the rail shows `emptyLabel` text in a `<p>` (no list structure).
- **No selection**: when `selectedId === null` or not matched, no row is marked active (unless `railSlotActive: true`).
- **Icon-less rows**: when `icon` is omitted or falsy (including `false` from conditional rendering), a fallback neutral ring icon fills in — every row is guaranteed a leading icon so the collapsed icon-only strip never has a blank slot.
- **Preview text handling**: `preview?.trim()` is called; if the result is empty string no preview block renders even if `previewLines > 0`. Preview text preserves source line breaks (`whitespace-pre-line`).
- **Preview line clamping**: `previewLines` is clamped to `Math.max(0, Math.min(4, Math.trunc(…)))` — values outside 0-4 are invalid and produce no clamp class (silent fallback to full text).
- **Covered list selection**: in covered style, clicking an already-selected row is a no-op (pure select, never toggles). Non-covered lists keep the toggle behavior (re-click to deselect).
- **Prefetch timing**: dwell timer is per-list, not per-row — moving focus from row to row arms the new row (old timer cleared). Never arms on the already-selected row; disarm handlers stay unconditional to cancel any armed timer.
- **Delete error handling**: when `onDelete()` throws, the dialog stays open without spinner, allowing the user to retry or cancel; the error is the consumer's responsibility to surface.
- **Batch mode in icon-only**: checkboxes do not render in collapsed or covered layouts (no room for a 16px box in a 40px peek); `checkable=true` is ignored in those layouts.
- **Collapsed rail measurement**: `onFit` never reports while `collapsed=true` — the icon strip has a fixed width by definition (COLLAPSED_RAIL = 48px).
- **Rail width drag threshold**: dragging narrower than `railWidthProp / 3` (default 80px) triggers snap-to-collapsed; dragging wider than `railWidthProp` snaps back to full.
- **Font loading**: measurement happens before paint and re-runs when web fonts load (document.fonts.ready), so the reported width accounts for the actual font face.
- **SSR environment**: `rootFontPx()` returns 16 when `document` is undefined (SSR); first client measurement corrects layout before paint.
- **Drag suppresses transition**: while actively dragging (`onPointerMove`), the rail's width transition is disabled so it tracks the pointer live; transition re-enables on `onPointerUp`.
- **Mobile collapse toggle**: the desktop collapse toggle (`«`/`»`) is hidden on mobile (≤768px) via `max-md:hidden`; mobile layout is horizontal wrap with no toggle.
- **Divider and spacer rendering**: dividers and spacers only render in expanded layout (`!iconOnly`); they are not included in collapsed/covered icon strips.
- **Row delete animation**: the delete confirmation dialog retains the last target through its close animation (via `lastDeleteRef`) so the title doesn't blank.
- **Header control slot alignment**: the leading control slot is a fixed `w-4` so item icons sit concentric with header controls; the title's leading edge lands on the same column as row labels (consistently aligned across cascades).
- **Trash button reveal**: the trash button is absolutely positioned in the right padding (`pr-9` on the row, positioned `right-[3px]`), so it never causes text to wrap and can break a hierarchical connector line.

## Configuration

**TopicDetail props:**
- `items: TopicDetailItem[]` — list of row objects (required)
- `selectedId: string | null` — the currently selected item's id
- `onSelect: (id: string) => void` — called when a non-disabled row is clicked
- `emptyLabel?: ReactNode` — text shown when `items` is empty (default "Nothing here yet.")
- `railSlot?: RailSlot` — optional leading row above topics (a function can receive collapsed state)
- `railSlotActive?: boolean` — move the gold bar onto the rail slot (nothing selected in list)
- `onNew?: () => void` — create affordance; fires when the `+` button is clicked
- `newLabel?: string` — accessible name + tooltip for the `+` (default "New")
- `newActive?: boolean` — tint the `+` gold (create in progress, nothing selected)
- `hideItemIcons?: boolean` — drop the leading icon from rows in expanded list only
- `panePadding?: boolean` — add standard inset to pane (default true)
- `collapsed?: boolean` — controlled collapse state (omit for self-managed)
- `onCollapsedChange?: (collapsed: boolean) => void` — called when collapse state changes
- `defaultCollapsed?: boolean` — initial collapse state in uncontrolled mode (default false)
- `railWidth?: number` — the rail's full width in px (default 240)
- `children: ReactNode` — the detail pane content

**TopicRail props** (internal wrapper, exposed for hierarchical stack):
- All TopicDetail props, plus:
- `title?: string` — render a titled header with this text
- `titleActions?: ReactNode` — extra controls in titled header, right-justified before toggle
- `headerSlot?: ReactNode` — pinned strip below titled header (filter + actions)
- `onResize?: (widthPx: number) => void` — drag handle fires with new width
- `onResizeStart?: () => void`, `onResizeEnd?: () => void` — drag lifecycle
- `footer?: ReactNode` — pinned strip at rail bottom
- `backSlot?: ReactNode` — optional back button top-left
- `leftControl?: ReactNode` — optional control replacing top-left (e.g., covered `«`/`»`)
- `showToggle?: boolean` — show desktop collapse toggle (default true)
- `coveredShadow?: boolean` — cast left drop-shadow (default false)
- `covered?: boolean` — render as icon-only left-aligned strip
- `isRoot?: boolean` — this is the root list (marker-style root dash)
- `selectionStyle?: "bar" | "marker"` — how to mark selection
- `rowDisclosure?: boolean` — show chevron on rows
- `onClose?: () => void` — close button fires
- `closeLabel?: string` — accessible name for close button (default "Close")
- `denseBottom?: boolean` — tighten bottom padding
- `hoverBar?: boolean` — show bar on hover (default true)
- `onPrefetch?: (id: string) => void` — prefetch callback
- `checkable?: boolean` — show checkboxes in batch mode
- `checkedIds?: ReadonlySet<string>` — which rows are checked
- `onToggleChecked?: (id: string) => void` — checkbox toggle fires
- `onFit?: (widthPx: number) => void` — report intrinsic row width
- `railLabel?: string` — accessible name for the `<aside>` (default "Topic list")
- `busy?: boolean` — show loading spinner
- `className?: string` — extra classes on the rail root

**TopicDetailItem shape:**
```
{
  id: string;                           // unique identifier (required)
  label: string;                        // primary text (required)
  labelSuffix?: ReactNode;              // additional text on label's line (name component)
  sublabel?: string;                    // secondary line or inline text (metadata)
  inlineSublabel?: boolean;             // render sublabel on label's line (label-priority)
  preview?: string;                     // content preview (clamped to previewLines)
  previewLines?: number;                // 0-4 lines (default 1)
  description?: string;                 // NOT rendered by this component (legacy, for other surfaces)
  icon?: ReactNode;                     // 16px icon (neutral ring fills in when omitted)
  leadsTo?: "list" | "detail";          // where this row leads (default "detail")
  dividerAfter?: boolean;               // render separator after item
  spacerAfter?: boolean;                // render flexible spacer after item
  disabled?: boolean;                   // dimmed, non-clickable
  trailing?: ReactNode;                 // right-justified accessory (expanded only)
  onDelete?: () => void | Promise<void>; // async delete handler
  deleteLabel?: string;                 // accessible name for delete (defaults to label)
  deleteConfirm?: ReactNode;            // confirmation dialog body (default "This action can't be undone.")
  blocked?: boolean;                    // amber dot + sr-only "needs attention"
}
```

**Exported types and constants:**
- `TopicDetail`, `TopicRail`, `TopicList`, `TopicDetailItem`, `RailSlot` (component/types)
- `FULL_RAIL = 240` (full rail width in px)
- `COLLAPSED_RAIL = 48` (collapsed icon-only strip width)
- `MIN_FIT_RAIL = 150`, `MAX_FIT_RAIL = 420` (auto-fit clamping range)
- `rootFontPx()`, `railPx(designPx)` (utility functions for font-relative sizing)

## Deep Linking

Not applicable: this component is a presentational primitive with no internal navigation. Deep linking is the responsibility of consumers that compose the component into a routing context.

## Localization

Not applicable: this component renders no user-facing copy other than prop-provided content (labels, slots, dialog titles from consumers). All hardcoded strings (button tooltips, aria-labels) are in English and use the default English platform labels as fallback values, overridable via props (`newLabel`, `closeLabel`, `railLabel`, `deleteLabel`, `deleteConfirm`).

## Accessibility Options

Not applicable: this component does not respond to platform accessibility display options (Reduce Motion, Increase Contrast, Differentiate Without Color). Accessibility concerns are built into the design: color alone never signals state (blocked dot is paired with sr-only text, selection bar is paired with `aria-current`), and motion respects the user's `prefers-reduced-motion` OS setting via global CSS (`var(--apt-anim-scale)`).

## Feature Flags

Not applicable: this component has no feature-flag controls. It is always-on and always exposes its full API.

## Analytics

Not applicable: this is a presentational block. Callers own any selection, creation, or deletion telemetry.

## Privacy

Not applicable: this component does not collect, store, or transmit data. All data (items, selection, checkboxes, blobs) is caller-owned and caller-managed.

## Logging

Not applicable: this component performs no logging. It is a presentation layer.

## Platform Notes

- **SwiftUI**: Not applicable: this is a web-only React component. A SwiftUI port would start from `NavigationStack` + `NavigationSplitView` or a custom `HStack` column layout, adapting the two-pane master-detail pattern to SwiftUI's navigation model and state management (no imperative `collapsed` state prop; instead derive from `NavigationPath` depth or a custom environment binding).
- **Compose**: Not applicable: this is a web-only React component. An Android/Compose port would start from `NavigationRail` + `MasterDetailPaneScaffold` (or a custom grid), adapting collapse behavior to Compose's `WindowWidthSizeClass` and state architecture (`mutableStateOf` for collapse, not controlled props).
- **React/Web (TypeScript)**: Source: `packages/web/packages/ui/src/blocks/topic-detail.tsx`. The component is a `"use client"` export (Next.js). Utilities with `apt-*` design tokens (no raw hex). Tailwind classes, no `!important`. Uses Lucide React icons (16px: `Circle`, `ChevronRight`, `Plus`, `Trash2`, `X`; `Loader2` for spinner). Responsive grid with `md:` breakpoint (≤768px wraps horizontal). Drag handle via `onPointerDown`/`onPointerMove`/`onPointerUp` pointer events. `useLayoutEffect` for width measurement (before paint). Font size from `document.documentElement` (or 16px fallback in SSR). Reusable `TopicRail`, `TopicList` subcomponents; `TopicDetail` composes `TopicRail` + `<section>` pane.
- **AppKit / UIKit**: Not applicable: this is a web-only React component. A native iOS/macOS port would start from `NavigationView` (iOS 15), `NavigationStack` (iOS 16+), or `NSSplitViewController` (macOS), adapting the two-pane master-detail pattern to Cocoa's view controller lifecycle and `UIControlEvents` / `NSResponder` event model (no synthetic event pooling like React).
- **WinUI 3**: A WinUI 3 port would start from `Microsoft.UI.Xaml.Controls.NavigationView` with `PaneDisplayMode="Left"` (desktop) or `Top` (mobile), or a custom `Grid` with two columns (`240*` and `1*`). Key considerations: (1) **Collapse**: use `NavigationView.IsPaneOpen` binding or custom `VisualStateManager` state for the expand/collapse toggle, animating `PaneWidth` from 240 to 48px via `Storyboard`. (2) **Row items**: bind a `ListViewBase` with `ItemsSource="{Binding Items}"`, each item a `Button` subclass or `ListViewItem` with customized `ControlTemplate` (icon 16px, label, sublabel with `TextTrimming="CharacterEllipsis"`, preview lines via custom `TextBlock` with `MaxLines`). (3) **Selection styling**: active item uses `SolidColorBrush` gold text + left `Border` (width 2px, gold), hover uses text-colored border via `PointerOver` `VisualState`. (4) **States**: `CommonStates` (`Normal`, `PointerOver`, `Pressed`, `Disabled`) + custom states (`Blocked`, `Loading`). (5) **Responsive**: at narrow widths use `VisualStateManager` to switch to horizontal `StackPanel` with bottom `Border` bar instead of left. (6) **Delete**: hover-reveal trash button via `VisualState`, show `ContentDialog` (destructive, async confirmation with spinner). (7) **Drag resize**: `PointerPressed`/`PointerMoved`/`PointerReleased` on trailing edge, `Margin` or `Canvas.Left` for position. (8) **Accessories**: `CheckBox` for batch mode (hidden in collapsed), `ProgressRing` for busy spinner, `Button` for `+` (New), `✕` (Close), and chevron disclosure (14px `FontIcon`). (9) **Binding**: bind `selected` row to `SelectedItem`, collapse state to `IsPaneOpen`, checked set to `CheckBox.IsChecked` (two-way). (10) **Resources**: define gold color token (`#FFAA6200`), dimmed text (`#FF666666`), nav background (`#FFF3F3F3`), surface background (`#FFFFFFFF`), borders/dividers (`#FFE0E0E0`), orange blocked marker (`#FFF0B000`), red delete (`#FFD13438`). (11) **Animation scale**: respect `UISettings.AnimationsEnabled` (Windows 11+) or `UISettings.ScreenReaderEnabled` to suppress/reduce transitions. (12) **Keyboard**: `IsTabStop=true` on items, `KeyDown` event for Enter/Space activation, Shift+Tab for reverse focus navigation. (13) **Semantic**: `AutomationProperties.Name` for labels, `AutomationProperties.HelpText` for aria-like hints, `ControlType.List` for the rail container.

## Design Decisions

- **Only the split.** Title and action chrome compose around it, keeping the primitive reusable and focused (separation of concerns). Consumers decide on headers, toolbars, and framing.
- **Always collapsible.** Collapse is intrinsic, not a config flag. The site design treats it as a core gesture to make room for the detail pane on desktop, and it is always available. No `collapsible=true/false` prop.
- **Controlled and uncontrolled collapse.** The component supports both patterns: pass `collapsed` + `onCollapsedChange` for external control (hierarchical stack auto-minimizes ancestors), or omit them and let the component self-manage.
- **Rail measures itself.** Only the component knows the full row anatomy (icon, label, sublabel, preview, trailing, delete button). `onFit` lets the parent ask "how wide do you want to be?" instead of guessing from characters or a fixed number. Measurement is intrinsic (`max-content`), clamped, and independent of the width the parent gives back — no oscillation.
- **Drag suppresses transition.** While actively dragging the trailing edge, the rail's width transition is disabled so it tracks the pointer live. This prevents janky visual lag and makes the resize feel responsive; transition re-enables on release.
- **Icon-only strip is fixed width.** The collapsed icon-only layout is always `COLLAPSED_RAIL` (48px) — no measurement. Accessibility + simplicity: icon buttons have a target size, rows are predictable, no computation.
- **Fallback icon for every row.** Ensuring every row has a leading icon (fallback circle when omitted) keeps the collapsed icon-only strip readable: no blank slots, consistent visual rhythm.
- **Preview preserves line breaks.** `whitespace-pre-line` on preview text respects the source's own line breaks. A note displayed as one run-on paragraph reads nothing like the original.
- **Inline sublabel is label-priority.** When `inlineSublabel=true`, the label grows and truncates first; the sublabel shrinks and truncates after. This keeps the identifier visible when space is tight; metadata gets hidden first.
- **Batch mode is independent.** Checking a box is separate from selecting a row. The row's single-selection behavior is preserved underneath — ticking a fourth item doesn't clear the open detail pane. This is the whole point of batch mode.
- **Covered style is pure-select.** Clicking an already-selected row in covered style is a no-op (select only, never toggle). Non-covered lists keep the toggle behavior. This distinction reflects the visual difference: covered rows are peeking siblings without a dismiss affordance, so re-clicking is a selection reset, not a toggle.
- **Prefetch never arms on open row.** A prefetch is a guess about where the user is going. The already-open item's data is already loaded; warming it again re-reads it behind the pane the user is looking at, causing visible lag and re-spinning the list. Disarm handlers stay unconditional to cancel any prior armed timer.
- **Delete error leaves dialog open.** When `onDelete()` throws, the dialog stays open without spinner. The consumer owns the error message; leaving the dialog open lets the user retry or cancel without dismissing and re-opening. This is different from success (dialog closes).
- **Blocked marker is always visible.** The amber dot rides the icon, not a trailing slot. Trailing slots are hidden in collapsed/covered layouts — exactly where a user hunting for a greyed-out Save button most needs to see which topic is holding the save down. The marker appears everywhere the icon does.
- **`panePadding` toggle.** Lets consumers opt into edge-to-edge rows without negative-margin hacks. The pane carries the padding, not each row — simpler CSS, less duplication.
- **1:1 port of hub settings rail.** CSS translated to utilities with `apt-*` tokens, so home and the shared library render identically. Any visual divergence is unintended drift, not a feature/platform difference.

## Compliance

| Check | Status | Category |
|---|---|---|
| Artifact formatting (ingredient) | passed | artifact-formatting |
| UI guidelines — `apt-*` tokens, no raw hex, no `!important` | passed | adh-ui-guidelines |
| RFC 2119 keywords used normatively (MUST, SHOULD, MAY) | passed | behavioral-requirements |
| All requirements are independently testable | passed | behavioral-requirements |
| No platform-specific API references (recipe-neutral) | passed | behavioral-requirements |
| Source fidelity: every requirement traced to source code | passed | source-fidelity |
| Section completeness: all sections filled or explicitly not-applicable | passed | completeness |
| Platform Notes: all five platforms addressed with translation guidance | passed | cross-recipe-consistency |
| Test vectors cover all MUST requirements | passed | completeness |
| Design Decisions explain non-obvious constraints | passed | completeness |

## Change History

| Version | Date | Author | Summary |
|---|---|---|---|
| 1.5.0 | 2026-09-22 | Mike Fullerton | Comprehensive revision: expand behavioral requirements to cover all API surface (batch mode, prefetch, delete confirmation, blocked state, covered style, selection styles, row disclosure, etc.); detail all appearance properties and state transitions; verify all edge cases against source implementation; complete Platform Notes with all five platforms and concrete WinUI 3 guidance; document all props and exported types; add 44 test vectors covering every MUST requirement and major features; set status to review. |
| 1.4.0 | 2026-07-14 | Mike Fullerton | `inlineSublabel` on `TopicDetailItem`: render `sublabel` on the label's line (dim, label-priority truncation) for dense single-line entity rows (sites / groups / platforms / users). New requirement `must-render-inline-sublabel`. |
| 1.3.0 | 2026-07-10 | Mike Fullerton | TopicRail `headerSlot`: pinned strip under the titled header for the shared ListHeader (filter + actions). |
| 1.2.0 | 2026-07-03 | Mike Fullerton | `spacerAfter` on `TopicDetailItem`: a flexible spacer after the item pins the following items to the rail's bottom edge (e.g. a bottom Settings), in the full rail and the collapsed/covered icon strips alike. New requirement `must-render-spacer-after`. |
| 1.1.0 | 2026-06-30 | Mike Fullerton | Collapse-aware `railSlot` render-prop (→ `+` when undisclosed); always-reserved leading slot (first-row alignment); controllable collapse (`collapsed`/`onCollapsedChange`/`defaultCollapsed`). |
| 1.0.0 | 2026-06-26 | Mike Fullerton | Initial draft |
