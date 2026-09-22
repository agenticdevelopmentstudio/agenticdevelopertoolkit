---
id: a8f66760-7db0-4a10-927e-856c2170dd4f
title: "ListHeader"
domain: agenticdevelopercookbook://recipes/list-header
type: ingredient
version: 1.1.0
status: review
language: en
created: 2026-07-10
modified: 2026-09-22
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: "The shared header above a list: title, filter text field, and right-aligned actions in the recessed ButtonBar strip."
platforms:
  - typescript
  - web
tags:
  - component
  - list
  - filter
  - toolbar
  - ui
depends-on: []
related:
  - agenticdevelopercookbook://recipes/list-with-details-pane
  - agenticdevelopercookbook://recipes/search-filter-bar
  - agenticdevelopercookbook://recipes/hierarchical-topic-detail
references: []
approved-by: ''
approved-date: ''
---

# ListHeader

## Overview

The one home for the "header above a list" pattern in `@agenticdevelopertoolkit/ui`
(`blocks/list-header.tsx`): a single row hosting an optional left-aligned title,
a filter text field (search icon, controlled value), a flexible space, and
right-aligned actions (e.g. a `+ New` button, Delete) — all inside the same
recessed `ButtonBar` strip every toolbar on the platform uses, so list headers
look identical everywhere.

Consumers:

- `ListWithDetailsPane` renders it above its `DataTable`.
- A `HierarchicalTopicDetail` level hosts it via the level's `headerSlot` (a
  pinned, non-scrolling strip between the level's title header and its rows), so
  entity lists inside the stack get the same filter + actions header.

Related, NOT absorbed: `SearchFilterBar` is the stacked search-plus-filter-axes
region (`role="search"`, `<select>` rows under the field) for full search pages;
`ListHeader` is the one-row list toolbar. They share the `Input` primitive.

## Behavioral Requirements

- **one-row-layout**: The header MUST render title (when set), filter field
  (when set), a flexible space, then actions, in one `ButtonBar` row.
- **controlled-filter**: The filter field MUST be fully controlled
  (`search.value` / `search.onChange` fired per keystroke) — the header never
  owns filter state.
- **optional-parts**: Title, filter, and actions MUST each be independently
  omittable; an absent part reserves no space.
- **accessible-names**: The bar MUST take an `ariaLabel`; the filter field's
  accessible name defaults to `"Filter"` and is overridable via `search.label`.
- **autofocus-remount**: When `search.autoFocus` is true, the filter field MUST
  receive focus on every remount (when the component attaches to the DOM); a
  re-render with the same ref identity MUST NOT steal focus.

## Appearance

```
┌──────────────────────────────────────────────────┐
│ Title  [🔍 Filter…        ]        [+ New] [Del] │  ButtonBar strip
└──────────────────────────────────────────────────┘
```

- **Container**: The strip is the shared `ButtonBar` (recessed, `border-b`).
- **Title**: mono font, `text-xs`, `text-apt-text-muted`, non-shrinking left section.
- **Filter field**: shared `Input` component with `type="search"`, leading `Search`
  icon (`text-apt-text-muted` colored), constrained to `max-w-xs` unless `grow` is true.
- **Flexible space**: Flex-fill spacer between filter and actions.
- **Actions**: Right-aligned content, no size constraint.
- **No raw hex colors**: All colors use `apt-*` design tokens.
- **No `!important` declarations**: Specificity is managed via composition.

## States

| State | Appearance change |
|---|---|
| Default | Filter placeholder (`"Filter…"` default) and no value |
| Filter focused | Shared Input focus ring applied |
| Filter with value | Text visible in field, `onChange` called per keystroke |
| No search supplied | Title (if set) and actions render; no search field at all |
| Search grows | Filter field flexes to fill available width when `grow={true}` |

## Accessibility

- **Toolbar role**: The strip inherits `ButtonBar`'s toolbar semantics via `ariaLabel`
  (required prop).
- **Search field**: Input is `type="search"` with an accessible name via `aria-label`
  (defaults to `"Filter"`, overridable via `search.label`).
- **Icon**: The Search icon is `aria-hidden="true"` (decorative, not focusable).
- **Keyboard navigation**: Users can tab to the filter field and type; `Enter` and
  `Escape` follow the `Input` component's behavior.
- **Touch target**: The filter field and any action buttons MUST meet the platform's
  minimum touch target size (44×44pt on iOS, 48×48dp on Android, per platform HIG).

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|---|---|---|---|
| T1 | one-row-layout, controlled-filter | `{ title: "Sites", search: { value: "", onChange }, actions: <Button> }` | All three parts render; typing in the field fires `onChange` with the new text |
| T2 | optional-parts | `{ title: "Sites", actions: <Button> }` (no `search`) | Title and actions render; no search field appears; flex space still fills |
| T3 | optional-parts | `{ search: { value: "", onChange } }` (no `title`, no `actions`) | Only the search field renders, filling available width (no grow prop needed) |
| T4 | optional-parts | `{ title: "Sites", search: { value: "", onChange }, actions: <Button>, search: { grow: true } }` | Filter field grows beyond `max-w-xs` when `grow={true}` |
| T5 | autofocus-remount | `{ search: { value: "", onChange, autoFocus: true } }` remounted | Input receives focus; re-renders (keystroke) do NOT steal focus again |
| T6 | accessible-names | Render with `ariaLabel="Filter list"` and `search.label="Search"` | Toolbar reports accessible name "Filter list"; input reports "Search" |

## Edge Cases

- **Long title**: A long title is shrink-0 and does not flex; if it exceeds available
  space with actions and filter both present, the filter field (which flexes within
  `max-w-xs`) shrinks first, then actions, preventing the title from wrapping.
- **Empty search value and no actions**: When `search.value` is empty and no `actions`
  are supplied, only the title and filter render; the flex spacer has no visible effect.
- **No consumer state**: The header renders no filter state of its own (no "no results"
  message, no counts). Filtering, result display, and empty-state handling are
  entirely the consumer's responsibility.
- **Uncontrolled usage**: Calling `onChange` is required; a consumer that ignores
  `onChange` will see a frozen field (React's controlled-component pattern).

## Configuration

| Option | Type | Default | Description |
|---|---|---|---|
| `title` | `React.ReactNode` | — | Left-aligned name of the list (e.g., `"Sites"`). Optional. |
| `search` | `ListHeaderSearch` | — | The controlled filter field. Optional. See below. |
| `search.value` | `string` | — | The current filter text (required if `search` is supplied). |
| `search.onChange` | `(value: string) => void` | — | Called with the new text on every keystroke (required if `search` is supplied). |
| `search.label` | `string` | `"Filter"` | Accessible name for the input. |
| `search.placeholder` | `string` | `"Filter…"` | Placeholder text when empty. |
| `search.autoFocus` | `boolean` | `false` | Focus the field when its `<input>` attaches — re-fires on every remount, unlike the native attribute. Re-renders never steal focus (stable ref identity). |
| `search.grow` | `boolean` | `false` | Let the field flex to fill remaining row width instead of capping at `max-w-xs` — for headers where filter is the only occupant (actions live elsewhere). |
| `actions` | `React.ReactNode` | — | Right-aligned actions (e.g., `+ New` button, Delete). Optional. |
| `ariaLabel` | `string` | — | Accessible name for the toolbar (required). |
| `className` | `string` | — | Extra CSS classes applied to the `ButtonBar` container. |

## Deep Linking

Not applicable: ListHeader is a presentational toolbar component with no deep-linkable
content or state. Consumers (e.g., `ListWithDetailsPane`, `HierarchicalTopicDetail`)
handle deep linking at the list or page level.

## Localization

Not applicable: The component has no end-user-facing text. All default strings
(`"Filter"`, `"Filter…"`) are hard-coded English in the source and intended to be
overridden by the consumer via `search.label` and `search.placeholder` props, which
are the consumer's responsibility to localize.

## Accessibility Options

- **Reduce Motion**: The component respects the inherited `Input` component's
  behavior; focus ring transitions MAY be disabled by the platform's motion
  preferences via CSS media query.
- **Increase Contrast**: The component uses `apt-text-muted` and `apt-text-default`
  tokens; if the active theme applies increased-contrast overrides to those tokens,
  the component inherits them automatically.
- **Differentiate Without Color**: The component MUST NOT rely solely on color to
  convey state. The focus ring (border or outline) and the filled vs. empty state
  of the input MUST be distinguishable without color.

## Feature Flags

Not applicable: ListHeader is a foundational UI component without feature-flag
control. Consumers that need to conditionally show or hide the header SHOULD manage
that at the consumer level.

## Analytics

Not applicable: ListHeader is a presentational toolbar. It emits no analytics events
of its own. Consumers that need to track filter changes or actions SHOULD attach
their own handlers to `onChange` and the action buttons' click events and emit
events at that level.

## Privacy

Not applicable: ListHeader does not collect, transmit, or store any user data.
Filter text remains in the caller's React state and is never persisted or sent
anywhere by the component itself.

## Logging

Not applicable: ListHeader is a presentational toolbar and emits no structured log
events. Consumers that need to log filter changes, debug re-renders, or monitor
performance SHOULD add their own logging at the consumer level.

## Platform Notes

- **React/Web**: Implemented in `packages/web/packages/ui/src/blocks/list-header.tsx`,
  exported from `@agenticdevelopertoolkit/ui/blocks`. Built on `ButtonBar` (toolbar
  container) and `Input` (search field); uses Lucide's `Search` icon. The autoFocus
  callback pattern (`ref={search.autoFocus ? focusOnAttach : undefined}`) ensures
  focus re-fires on remount but stable ref identity prevents focus theft on re-render.
- **SwiftUI**: A SwiftUI port would compose a `HStack` with `Text` for the title
  (monospace, small, secondary color), a `TextField` with a leading `Image(systemName: "magnifyingglass")`
  for the search field, a `Spacer()` for flex fill, and an `HStack` for actions,
  all wrapped in a toolbar container (e.g., `.background(Color.secondary.opacity(0.1))`
  with a bottom border). The `autoFocus` behavior maps to `.onAppear` + `responder`
  chains to manage focus on view appearance vs. re-render.
- **Compose**: A Compose port would use a `Row` (Modifier.fillMaxWidth()) with
  `Text` (mono style, small size, muted color) for the title, a `TextField` with
  a leading icon inside the text field's shape for the search, a `Spacer(Modifier.weight(1f))`
  for flex fill, and a `Row` for actions. The autoFocus maps to `LaunchedEffect(Unit)`
  calling `FocusRequester.requestFocus()`, which fires on recomposition but skipping
  re-renders that don't change the ref.
- **AppKit / UIKit**: A native port would use `NSStackView` (AppKit) or `UIStackView`
  (UIKit) with `fillProportionally` distribution; `NSTextField` (AppKit) or `UITextField`
  (UIKit) for the search field with a left-view icon; and a flexible spacer; all
  inside a recessed toolbar container (e.g., `NSAppearance` with a bottom separator).
  The autoFocus maps to `becomeFirstResponder()` called in `viewDidAppear()` but
  skipped on mere layout passes.
- **WinUI 3**: A WinUI 3 port would use a `Grid` with `ColumnDefinition` widths set
  to `Auto` (title), `*` (search flexes to fill within max-width), `*` (spacer),
  and `Auto` (actions). The `TextBox` for search (with `PlaceholderText`, `InputScope`
  set to `Search`) wraps in a `Grid` with leading `SymbolIcon("Search")`. The autoFocus
  maps to calling `Focus(FocusState.Programmatic)` in `Loaded` event, which re-fires
  on control remount but the stable ref identity prevents focus theft on re-measure
  or re-layout passes. The container applies `ControlBackgroundColor` and a bottom
  `Border`.

## Design Decisions

- **Built on ButtonBar, not beside it.** Every toolbar on the platform is the same
  recessed strip; the list header composes `ButtonBar` rather than re-rolling the
  chrome. `ListWithDetailsPane`'s inline toolbar was extracted into this block to
  establish a single source of truth for list headers.
- **SearchFilterBar left intact.** The stacked search-region (field over `<select>`
  axes) serves full search pages; merging the two would force each consumer to
  configure away the other's shape. They remain separate patterns.
- **autoFocus re-fires on remount.** Unlike the native HTML `autoFocus` attribute
  (which fires once at first mount), this implementation re-fires on every remount
  (e.g., when a topic level unmounts and remounts on re-enter). This accommodates
  navigation stacks where filters need to re-focus as users return to a list level.
- **No filter state ownership.** The header does not own or persist filter state.
  It is a controlled component; the consumer holds the filter text and calls
  `onChange` on every keystroke. This keeps the header stateless and composable.

## Compliance

No additional compliance categories apply to this presentational ingredient. Accessibility
conformance is specified in the Accessibility section above; it follows platform HIG
standards (Apple HIG, Material Design 3, Fluent 2, WCAG 2.1 AA for web).

## Change History

| Version | Date | Author | Summary |
|---|---|---|---|
| 1.1.0 | 2026-09-22 | Claude Haiku 4.5 | Expand to full ingredient template; correct domain to agenticdevelopercookbook; add all five Platform Notes bullets; complete Accessibility, Edge Cases, Conformance Test Vectors; mark not-applicable sections (Deep Linking, Localization, Feature Flags, Analytics, Privacy, Logging); add autofocus-remount requirement; add Configuration section with full prop definitions; set status to review. |
| 1.0.0 | 2026-07-10 | Mike Fullerton | Initial ingredient — extracted from ListWithDetailsPane's inline toolbar; HierarchicalTopicDetail `headerSlot` integration. |
