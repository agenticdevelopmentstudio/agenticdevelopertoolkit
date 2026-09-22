---
id: c044fa91-11c6-46e9-b64a-bd890535acae
title: Focused Topic Detail
domain: agenticdevelopercookbook://ingredients/focused-topic-detail
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Layout component composing a selectable popup menu and topic-detail rail
  into a two-pane focused/all-items view.
platforms:
- typescript
- web
tags:
- layout
- composition
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Focused Topic Detail

## Overview

A two-pane layout composition that presents items via a popup menu and either focused detail content or an all-items card grid, depending on focus state. Used in hubs and resource dashboards where users drill from a list into topic-scoped details. Composes `PopupMenu`, `TopicDetail`, `SectionHeader`, and `ResourceCard` blocks.

## Behavioral Requirements

- **must-render-popup-menu**: Component MUST render a `PopupMenu` with items and selections in the rail slot of `TopicDetail`.
- **must-support-focus-selection**: Component MUST invoke `onFocus` callback when a popup menu item is selected, passing the item's `id`.
- **must-render-focused-title**: Component MUST render a `SectionHeader` with the focused view's title when a focused item exists AND `focusedTitle` is truthy.
- **must-render-focused-content**: Component MUST render the `children` prop in the detail pane when an item is focused.
- **must-render-all-items-header**: Component MUST render a `SectionHeader` with `allTitle` text in the detail pane when no item is focused.
- **must-render-card-grid**: Component MUST render items as a `ResourceCard` grid in the detail pane when no item is focused and items array is not empty.
- **must-render-empty-state**: Component MUST render the `allEmptyLabel` text in a paragraph when no item is focused and items array is empty.
- **must-disable-topics-unfocused**: Component MUST pass `disabled: true` to all topic items in the `TopicDetail` when no item is focused.
- **must-enable-topics-focused**: Component MUST pass `disabled: false` to non-disabled topic items when an item is focused.
- **must-pass-topic-selection**: Component MUST invoke `onTopicSelect` callback when a topic item is selected, passing the item's `id`.
- **must-derive-focused-title**: Component MUST construct the focused title as `"{topicLabel} ({focusedItemLabel} {nameSuffix})"` when an item is focused, a topic is selected, and both `nameSuffix` and matching topic exist.
- **must-honor-explicit-title**: Component MUST use the `title` prop as `focusedTitle` when provided, overriding derived title.
- **must-rekey-pane-content**: Component MUST use `focusedId` as the React key on pane content when focused, forcing remount on focus change.
- **must-fallback-stale-focus**: Component MUST return to all-items view (set `focusedTitle` to undefined) when `focusedId` does not match any item in the items array.
- **must-support-new-action**: Component MUST render a "New" entry in the popup menu when `onNew` prop is provided.
- **must-set-new-label**: Component MUST display `newLabel` text on the "New" entry when provided.
- **must-display-card-title**: Component MUST render each item's `label` as the card title via `ResourceCard`'s `title` prop.
- **must-display-card-identifier**: Component MUST render each item's `sublabel` as the card identifier via `ResourceCard`'s `identifier` prop when present.
- **must-display-card-description**: Component MUST render each item's `description` as the card body text via `ResourceCard`'s `description` prop when present.
- **must-display-card-meta**: Component MUST render each item's `meta` as the card meta row via `ResourceCard`'s `meta` prop when present.
- **must-focus-card-onclick**: Component MUST invoke `onFocus` with the card's item `id` when the card is clicked.
- **must-set-rail-slot-active**: Component MUST set `railSlotActive={false}` when focused, `railSlotActive={true}` when unfocused.
- **should-display-focused-help**: Component SHOULD render the `help` prop in the focused `SectionHeader` when provided and focused.
- **should-display-all-help**: Component SHOULD render the `allHelp` prop in the all-items `SectionHeader` when provided and unfocused.

## Appearance

- **Corner radius**: Inherited from child components (`PopupMenu`, `ResourceCard`, `SectionHeader`).
- **Padding**: Rail section header: 1.5rem horizontal, 1rem top / 0.5rem bottom. All-items section header: 1.5rem horizontal, 1rem top / 0.5rem bottom. Card grid: 1.5rem horizontal, 0.5rem top / 1.5rem bottom.
- **Font**: Inherited from `SectionHeader` and `ResourceCard` children.
- **Background**: No background applied to the layout itself; inherited from `TopicDetail`.
- **Foreground/Text**: All-empty label text uses `text-sm text-apt-text-muted` (small, muted color).
- **Border**: None on layout; inherited from child components.
- **Shadow**: None on layout; inherited from child components.
- **Min/Max size**: Card grid uses responsive columns: 1 column mobile, 2 columns at sm breakpoint, 3 columns at xl breakpoint. Grid gap: 1rem.
- **Card hover state**: When unfocused, cards in the grid MUST have `hover:border-apt-gold/60 hover:bg-apt-surface` applied (gold border with slight surface color on hover).

## States

| State | Appearance change |
|-------|-------------------|
| Focused | Popup menu shows selected item highlighted; topic rail is enabled; detail pane shows focused content with derived or explicit title; popup menu is not full-width. |
| Unfocused/All-items | Popup menu shows no selection; topic rail is disabled (all items grayed); detail pane shows card grid with all items (or empty state if no items); gold bar appears on popup row. |
| Empty items | When items array is empty and view is unfocused, card grid is hidden; empty state label is shown instead. |

## Accessibility

- **Role**: The layout is a composition; no single role applies. `PopupMenu` exposes its own role (button/menu). `ResourceCard` elements should be buttons or clickable containers with appropriate roles.
- **Label requirements**: PopupMenu MUST receive an `ariaLabel` prop for screen readers. SectionHeaders render text that serves as the pane label. Topic items in the rail should have descriptive labels via TopicDetail.
- **Announce state changes**: Focus state change SHOULD trigger announcement of the new title and content scope. Unfocused → focused state change SHOULD announce the newly focused item's label.
- **Minimum tap target**: ResourceCard click targets SHOULD be at least 44×44pt (inherited from ResourceCard implementation). PopupMenu items MUST meet touch target standards.
- **Keyboard navigation**: PopupMenu MUST support keyboard navigation. ResourceCards MUST be keyboard-accessible (focusable, activatable via Enter/Space). Topic rail MUST support arrow keys for topic selection when focused.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| focused-topic-detail-001 | must-render-popup-menu, must-support-focus-selection | items=`[{id:'a',label:'Item A'}]`, focusedId=null, onFocus=callback | PopupMenu renders with items; clicking item 'a' invokes onFocus('a') |
| focused-topic-detail-002 | must-render-focused-title | focusedId='a', focusedItem found, title='Explicit Title' | SectionHeader renders 'Explicit Title' |
| focused-topic-detail-003 | must-derive-focused-title | focusedId='a', focusedItem.label='Item A', activeTopicId='t1', topicLabel='Topic 1', nameSuffix='Suffix' | SectionHeader renders 'Topic 1 (Item A Suffix)' |
| focused-topic-detail-004 | must-fallback-stale-focus | focusedId='stale', items has no matching id | All-items view renders; card grid or empty state shown |
| focused-topic-detail-005 | must-render-all-items-header | focusedId=null, allTitle='All Items' | SectionHeader renders 'All Items' |
| focused-topic-detail-006 | must-render-card-grid | focusedId=null, items=`[{id:'a',label:'A',sublabel:'sub'},{id:'b',label:'B'}]` | Grid renders 2 ResourceCard components; both receive title, identifier props |
| focused-topic-detail-007 | must-render-empty-state | focusedId=null, items=[], allEmptyLabel='Nothing' | Paragraph renders 'Nothing' with muted text class |
| focused-topic-detail-008 | must-disable-topics-unfocused | focusedId=null, topics=`[{id:'t1'},{id:'t2'}]` | TopicDetail receives items with `disabled: true` for all |
| focused-topic-detail-009 | must-enable-topics-focused | focusedId='a', topics=`[{id:'t1'},{id:'t2'}]` | TopicDetail receives items with `disabled: false` for all non-disabled topics |
| focused-topic-detail-010 | must-rekey-pane-content | focusedId changes from 'a' to 'b' | Pane content remounts (Fragment key changes) |
| focused-topic-detail-011 | must-support-new-action | onNew=callback, newLabel='New Item' | PopupMenu renders 'New Item' entry; clicking invokes onNew() |
| focused-topic-detail-012 | must-focus-card-onclick | Unfocused; items=`[{id:'x'}]` | Clicking ResourceCard invokes onFocus('x') |
| focused-topic-detail-013 | must-display-card-description | Unfocused; items=`[{id:'a',description:'Desc text'}]` | ResourceCard receives description='Desc text' |
| focused-topic-detail-014 | must-display-card-meta | Unfocused; items=`[{id:'a',meta:<span>Meta</span>}]` | ResourceCard receives meta=<span>Meta</span> |
| focused-topic-detail-015 | should-display-focused-help | Focused, help='Help text' | SectionHeader receives help='Help text' |
| focused-topic-detail-016 | should-display-all-help | Unfocused, allHelp='All Help' | SectionHeader receives allHelp='All Help' |

## Edge Cases

- **Null focusedId**: When `focusedId` is null, the component MUST show the all-items card view and disable all topic items. This is the default state.
- **Unknown/stale focusedId**: When `focusedId` does not match any item in the array (e.g., the focused item was deleted after the parent cached the id), the component MUST treat it as null and show the all-items view. The fallback ensures the UI remains consistent and does not show a half-focused, broken state.
- **Empty items array**: When items.length === 0, the component MUST render the empty state label (`allEmptyLabel`) instead of an empty card grid. The card grid MUST NOT render if there are no items.
- **Missing topic**: When a topic matching `activeTopicId` does not exist in the topics array, the component MUST not render a derived title (topicLabel becomes undefined).
- **No nameSuffix**: When the `nameSuffix` prop is not provided, the component MUST not derive a title; only an explicit `title` prop will show a focused header.
- **Card click while focused**: When a card is clicked while the view is already focused on a different item, the component MUST invoke `onFocus` with the card's id, allowing the parent to re-focus. The pane content remounts (keyed by focusedId).
- **Rapid focus changes**: When focusedId changes multiple times in quick succession, each change remounts the pane content (Fragment key updates), ensuring state is not carried over between focused items.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| items | FocusedTopicDetailItem[] | (required) | Array of focusable items; drives popup menu and all-items card grid. |
| focusedId | string \| null | (required) | The currently focused item id, or null for all-items view. |
| onFocus | (id: string \| null) => void | (required) | Callback fired when an item is selected (focused) or deselected (null). |
| topics | TopicDetailItem[] | (required) | Array of topic/detail items scoped to the focused item. |
| activeTopicId | string \| null | (required) | The currently selected topic id. |
| onTopicSelect | (id: string) => void | (required) | Callback fired when a topic is selected. |
| title | ReactNode | undefined | Explicit focused-view title; overrides derived title. |
| nameSuffix | string | undefined | Suffix appended to derived title: "{topic} ({item} {suffix})". |
| help | ReactNode | undefined | Help text rendered in the focused SectionHeader. |
| allTitle | string | "All items" | Title for the all-items card view. |
| allHelp | ReactNode | undefined | Help text rendered in the all-items SectionHeader. |
| allEmptyLabel | string | "Nothing here yet." | Text shown when items is empty and view is unfocused. |
| onNew | () => void | undefined | Optional callback for a "New" action in the popup menu. |
| newLabel | string | undefined | Label for the "New" popup entry (shown if onNew is provided). |
| popupAriaLabel | string | (required) | Accessible label for the popup menu. |
| children | ReactNode | (required) | Content rendered in the detail pane when focused. |

## Deep Linking

Not applicable: Focused Topic Detail is a layout component that composes other blocks. Deep linking is handled by the consumer application based on the focused item id and active topic id.

## Localization

| String Key | Default (en) | Context |
|-----------|-------------|---------|
| allTitle | "All items" | Label for the all-items card grid view section. |
| allEmptyLabel | "Nothing here yet." | Message shown when no items exist. |
| newLabel | (varies) | Label for the optional "New" popup entry; provided by consumer. |

## Accessibility Options

Not applicable: Focused Topic Detail does not directly implement accessibility display options. Accessibility options are handled by child components (`PopupMenu`, `ResourceCard`, `TopicDetail`, `SectionHeader`) and the consumer's text/content.

## Feature Flags

Not applicable: This is a UI composition component with no feature-flag control. Feature control is delegated to consumers and child components.

## Analytics

Not applicable: Analytics instrumentation is delegated to consumers and child components. The component itself does not emit analytics events; the parent application defines what focus changes, topic selections, or card clicks mean in product terms.

## Privacy

Not applicable: Focused Topic Detail does not collect, store, or transmit data. It is a stateless presentation component that renders user-provided content.

## Logging

Not applicable: The component does not emit structured logs. Debug output, if needed, is the responsibility of the parent consumer or the child components.

## Platform Notes

- **React/Web**: Source is `packages/web/packages/ui/src/blocks/focused-topic-detail.tsx`. Uses Tailwind CSS classes for padding, grid layout, hover states (`hover:border-apt-gold/60 hover:bg-apt-surface`). Responsive grid via `sm:` and `xl:` breakpoints. Fragment keying forces remount on focus change. Composed from `PopupMenu`, `TopicDetail`, `SectionHeader`, `ResourceCard`. No platform-specific DOM elements; uses semantic divs and conditional rendering. Text color tokens: `text-apt-text-muted` for empty state.
- **SwiftUI**: Use a two-pane NavigationSplitView with a List (sidebar) showing popup menu items and a detail pane with either a topic-scoped section or a ScrollView of cards. Implement focus state via a @State binding. Disable topic rail items conditionally with `.disabled()`. For card hover, apply a dynamic foreground or background modifier. Remount detail content with `.id()` on the pane to trigger state reset on focus change.
- **Compose**: Build with a Row composable: left is a Menu or SelectionContainer for popup; right is a Column with conditional LazyVerticalGrid (unfocused) or focused detail content. Use `enabled` state on topic items. Apply hover ripple and background color change for cards. Use `key()` on detail pane composable to force recomposition on focus change.
- **AppKit / UIKit**: Implement as a split view controller (NSSplitViewController on macOS, a custom container on iOS). Sidebar is a table or collection view (popup menu). Detail pane is a scroll view hosting either a topic rail + detail content or a collection view of cards. Disable topic items via a data model flag. Apply hover effects and tap handling to cards. On macOS, use NSSplitViewItem to manage pane visibility and sizing.
- **WinUI 3**: Build as a Grid with two columns: left column hosts an ItemsControl or ComboBox for popup menu selection; right column conditionally renders either a detail pane (focused) or a GridView of cards (unfocused). Use VisualStateManager to handle Focused and Unfocused visual states (border and background colors for cards). Disable topic items via IsEnabled binding. Apply hover effects via pointer events or implicit styles. Key the detail pane with a custom attached property to trigger remount on focus id change.

## Design Decisions

- **Derived title construction**: The title is derived only when all three inputs (topicLabel, focusedItem, nameSuffix) are present, following the hub's ResourceTab titleFor pattern. An explicit `title` prop overrides the derived title, allowing consumers to customize for specific cases.
- **Fallback to all-items on stale focusedId**: Rather than rendering a broken half-focused state when the focused item has been deleted, the component silently returns to all-items view. This ensures the UI is always consistent and usable, matching the hub's ResourceTab knownId check pattern.
- **Fragment keying by focusedId**: Pane content is wrapped in a Fragment with `key={focusedId}` to force React to remount children when the focused item changes. This clears form state, draft text, and other ephemeral pane state when the user switches focus, matching the hub's pattern.
- **railSlotActive state**: The `railSlotActive` prop controls whether the popup menu is displayed full-width (unfocused, true) or in the rail slot (focused, false). This visual shift reinforces the focus state change.
- **No negative-margin hacks**: The component sets `panePadding={false}` on TopicDetail so the pane is edge-to-edge. Child content (e.g., ButtonBar) brings its own padding, eliminating the need for negative margins. This keeps CSS predictable and composable.
- **Sublabel as mono identifier**: The `sublabel` field is rendered as a mono-spaced identifier line (e.g., reverse-domain id) on ResourceCards, distinct from the label and description.
- **Card click targeting focused item**: Clicking a card invokes `onFocus` with that card's id. If the card is already focused, the parent app will likely ignore the no-op focus call or use it to refresh details.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| [behavioral-requirements](agenticdevelopercookbook://guidelines/cookbook/recipe-quality/behavioral-requirements) | passed | Recipe Quality |
| [completeness](agenticdevelopercookbook://guidelines/cookbook/recipe-quality/completeness) | passed | Recipe Quality |
| [cookbook-compliance](agenticdevelopercookbook://guidelines/cookbook/recipe-quality/cookbook-compliance) | passed | Recipe Quality |
| [cross-recipe-consistency](agenticdevelopercookbook://guidelines/cookbook/recipe-quality/cross-recipe-consistency) | passed | Recipe Quality |
| [source-fidelity](agenticdevelopercookbook://guidelines/cookbook/recipe-quality/source-fidelity) | passed | Recipe Quality |
| [template-conformance](agenticdevelopercookbook://guidelines/cookbook/recipe-quality/template-conformance) | passed | Recipe Quality |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation from web source |
