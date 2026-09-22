---
id: 059093ee-8776-4e6a-b2a2-3fe1e20c2ee9
title: Command Palette
domain: agenticdevelopercookbook://ingredients/command-palette
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Transient overlay dialog for keyboard-driven command execution over grouped
  items without internal filtering.
platforms:
- web
tags:
- command-palette
- keyboard-navigation
- dialog
depends-on: []
related: []
references: []
---

# Command Palette

## Overview

The Command Palette is a transient overlay dialog that presents a keyboard-navigable list of grouped commands. A user types in a search field to filter results (filtering is performed by the host, not the component), then navigates and selects items via keyboard or mouse. The palette does not persist state — it closes immediately after an item is selected, and reopening resumes no previous search. It is designed to answer the interaction "I know what I want by name, not by location."

## Behavioral Requirements

- **must-accept-open-prop**: Component MUST render the dialog when the `open` prop is `true`, and hide it when `open` is `false`.
- **must-call-onOpenChange-on-close**: Component MUST call `onOpenChange(false)` when the user dismisses the dialog (via Escape or by selecting an item).
- **must-display-query**: Component MUST display the value of the `query` prop in the search input field.
- **must-call-onQueryChange**: Component MUST call `onQueryChange(value)` when the user types in the search input field.
- **must-display-groups-in-order**: Component MUST render groups in the order provided, dropping any group with zero items.
- **must-render-group-heading-when-not-empty**: Component MUST render a group's heading only when the group contains one or more items.
- **must-render-items-in-group-order**: Component MUST render items within each group in the order provided.
- **must-preselect-first-item-initially**: Component MUST highlight the first item in the flattened list (across all groups) when the dialog opens or when the list of items changes.
- **must-preselect-first-item-on-groups-change**: Component MUST reset the highlight to the first item whenever the set of displayed items changes (measured by comparing item IDs across all groups).
- **must-support-arrow-navigation**: Component MUST move the highlight up (ArrowUp) and down (ArrowDown) through the flattened list of items, wrapping around at the ends.
- **must-support-home-end**: Component MUST move the highlight to the first item on Home and to the last item on End.
- **must-run-on-enter**: Component MUST run the highlighted item's `onSelect` callback and close the dialog when Enter is pressed.
- **must-run-on-click**: Component MUST run an item's `onSelect` callback and close the dialog when the item is clicked.
- **must-update-highlight-on-hover**: Component MUST move the highlight to an item when the user hovers over it.
- **must-scroll-highlighted-item-into-view**: Component MUST scroll the highlighted item into view using the nearest scrolling behavior when it is off-screen.
- **must-close-on-escape**: Component MUST close the dialog when Escape is pressed (delegated to Dialog primitive).
- **must-display-loading-state**: Component MUST display a loading indicator and "Searching…" text below the item list when `loading` is `true`, without clearing the item list.
- **must-display-error-message**: Component MUST display the `error` prop as inline error text in the list area when `error` is not `null`.
- **must-display-empty-state**: Component MUST display the `emptyLabel` (default "No matches") when all groups are empty, the list is not loading, and `error` is `null`.
- **must-render-footer-when-provided**: Component MUST render the `footer` prop in a footer strip separated by a top border when `footer` is not `undefined`.
- **must-not-filter**: Component MUST NOT filter the groups or items provided; filtering is the host's responsibility.
- **must-reset-active-on-reopen**: Component MUST reset the highlight to the first item when the dialog transitions from `open: false` to `open: true`.
- **should-use-placeholder**: Component SHOULD display the `placeholder` prop (default "Search…") as the input field's placeholder text.

## Appearance

- **Corner radius**: 6px (from Tailwind's `rounded-md` on item buttons)
- **Padding**: Dialog content has no padding; internal sections own their own (input section: 12px vertical, 10px right, 12px left; item list: 8px; footer: 8px vertical, 12px horizontal)
- **Font**: Item text is 14px (text-sm), section labels are text-sm, footer is 12px (text-xs)
- **Background**: Dialog uses default modal overlay; item list background inherits from container; highlighted items show `apt-highlight/15` overlay; hover shows `apt-highlight/10`
- **Foreground/Text**: Primary text `apt-text`, muted text `apt-text-muted`, dimmed text `apt-text-dim`, section labels use muted color
- **Border**: Top border on input section (1px `apt-border`), top border on footer section (1px `apt-border`)
- **Shadow**: Delegated to Dialog primitive
- **Min/Max size**: Dialog max-width is 448px (max-w-xl); positioned at 12% from top; list max-height is 50vh with vertical scroll overflow; input uses padding-left 36px to accommodate leading icon

## States

| State | Appearance change |
|-------|------------------|
| Default | First item highlighted with semi-transparent highlight background; hover tint shows on mouse enter |
| Highlighted | Current item shows `apt-highlight/15` background; other items show default |
| Hover | Non-highlighted item shows `apt-highlight/10` background on mouse enter; does not change highlight until click |
| Loading | Loading indicator (spinner) and "Searching…" text appear below the item list; existing items remain visible |
| Error | Error message text appears in the list area with error styling |
| Empty | Empty state text (default "No matches") appears when no items are shown and not loading |

## Accessibility

- **Role**: Dialog contains a combobox input (the search field) with role "combobox" and a listbox (role "listbox") containing options.
- **Label requirements**: The `ariaLabel` prop MUST be provided; it labels both the dialog (`DialogTitle` with `sr-only` class) and the combobox input (`aria-label`). Group headings are provided via `aria-label` on the group container, visible only to assistive tech. Item labels are the button text content.
- **Keyboard support**: All keyboard interactions (ArrowUp, ArrowDown, Home, End, Enter, Escape) are fully supported.
- **Announce state changes**: The combobox's `aria-activedescendant` attribute tracks the currently highlighted option, announcing it to screen readers. The `aria-expanded` attribute is present on the input. The input's `aria-controls` connects it to the listbox.
- **Minimum tap target**: Items are buttons with padding `py-1.5 px-2` (approximately 24px tall × full width), meeting the 44×44pt minimum for web interactive targets.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| cp-001 | must-accept-open-prop | `open: false` | Dialog is not rendered or is hidden |
| cp-002 | must-accept-open-prop | `open: true` | Dialog is visible and input receives focus |
| cp-003 | must-call-onOpenChange-on-close | User presses Escape | `onOpenChange(false)` is called |
| cp-004 | must-call-onOpenChange-on-close | User selects an item via Enter | `onOpenChange(false)` is called, then item's `onSelect()` is called |
| cp-005 | must-display-query | `query: "test"` | Input field shows "test" |
| cp-006 | must-call-onQueryChange | User types "foo" in input | `onQueryChange("foo")` is called for each keystroke |
| cp-007 | must-display-groups-in-order | `groups: [{id: "g1", …}, {id: "g2", …}]` | Group headings appear in order g1, then g2 |
| cp-008 | must-display-groups-in-order | `groups: [{id: "g1", items: []}, {id: "g2", items: [{…}]}]` | Only g2 heading is rendered; g1 is dropped |
| cp-009 | must-render-group-heading-when-not-empty | Group with 0 items | Group heading is not rendered |
| cp-010 | must-render-group-heading-when-not-empty | Group with 1+ items | Group heading is rendered |
| cp-011 | must-preselect-first-item-initially | Dialog opens with 3 items | First item is highlighted |
| cp-012 | must-preselect-first-item-on-groups-change | Item list changes from [A, B, C] to [X, Y] | Highlight moves to X (first of new list) |
| cp-013 | must-support-arrow-navigation | Highlight on item 1 of 3, press ArrowDown | Highlight moves to item 2 |
| cp-014 | must-support-arrow-navigation | Highlight on item 3 of 3, press ArrowDown | Highlight wraps to item 1 |
| cp-015 | must-support-arrow-navigation | Highlight on item 1 of 3, press ArrowUp | Highlight wraps to item 3 |
| cp-016 | must-support-home-end | Highlight on item 2, press Home | Highlight moves to item 1 |
| cp-017 | must-support-home-end | Highlight on item 1, press End | Highlight moves to item 3 |
| cp-018 | must-run-on-enter | Highlight on item with `onSelect`, press Enter | `onSelect()` is called and dialog closes |
| cp-019 | must-run-on-click | Item is visible and user clicks it | `onSelect()` is called and dialog closes |
| cp-020 | must-update-highlight-on-hover | Highlight on item 1, user hovers item 2 | Highlight moves to item 2 |
| cp-021 | must-scroll-highlighted-item-into-view | Highlight on item outside viewport | Item scrolls into view with nearest block align |
| cp-022 | must-display-loading-state | `loading: true`, items list populated | Spinner and "Searching…" appear below items; items remain visible |
| cp-023 | must-display-error-message | `error: "Network error"` | Error message displays in list area |
| cp-024 | must-display-empty-state | `groups: []`, `loading: false`, `error: null` | "No matches" (or custom `emptyLabel`) displays |
| cp-025 | must-render-footer-when-provided | `footer: <div>Help text</div>` | Footer strip renders at bottom with top border |
| cp-026 | must-not-filter | `query: "xyz"`, groups and items unchanged | No filtering occurs; host is responsible for filtering |
| cp-027 | must-reset-active-on-reopen | `open: true`, user selects item (closes), `open: true` again | Highlight resets to first item |

## Edge Cases

- **Empty groups list**: When `groups: []`, the list displays the empty state. This is a MUST behavior.
- **All groups empty**: When every group has zero items, the list displays the empty state and the heading row is never rendered. This is a MUST.
- **Single item**: When exactly one item exists, ArrowUp and ArrowDown both wrap to the same item. This is a MUST.
- **Loading with items**: When `loading: true` and items are present, both the items and the loading indicator are visible. The items are NOT replaced. This is a MUST.
- **Error with items**: When `error` is set and items are present, both are visible. This is a MUST.
- **Error and loading together**: When both `error` and `loading` are truthy, the error is displayed (and the loading indicator). This is a MUST, following the render order of the source.
- **Null error state**: When `error` is explicitly `null`, no error text renders. When `error` is `undefined`, it defaults to `null` and no error renders. This is a MUST.
- **Query with no matching items**: If the host does not filter the groups and provides `query: "xyz"` with `groups: []`, the empty state appears. This is a MUST (source behavior, not component responsibility).
- **Very long labels**: Item labels and descriptions are truncated with CSS (`truncate`). This is a MUST.
- **Icon or badge absent**: When `icon` or `badge` are undefined, no space is reserved for them. This is a MUST.
- **Reopening resets query state**: When `open` transitions from `true` to `false` to `true`, the highlight resets to the first item, but `query` remains as the host left it (not cleared by the component). This is a MUST.

## Configuration

Not applicable: CommandPalette receives all configuration through props (`CommandPaletteProps`) and does not have external configuration options.

## Deep Linking

Not applicable: CommandPalette is an overlay component without its own route or deep-link URI. Deep linking to a command would be the host's responsibility (routing to the appropriate section of the app and triggering the selected command).

## Localization

| String Key | Default (en) | Context |
|-----------|-------------|---------|
| placeholder | "Search…" | Input field placeholder when query is empty |
| emptyLabel | "No matches" | Empty state message when no items are shown |
| loadingLabel | "Searching…" | Loading indicator label; hardcoded in source |

These strings are passed as props or have hardcoded defaults in the source. Localization is the host's responsibility.

## Accessibility Options

- **Reduce Motion**: Not applicable; CommandPalette does not use transitions or animations that respond to prefers-reduced-motion.
- **Increase Contrast**: Not applicable; CommandPalette does not have a built-in contrast mode; host may apply custom CSS to meet contrast requirements.
- **Differentiate Without Color**: Not applicable; CommandPalette does not rely on color alone to convey state; highlight is shown via background color AND aria-selected attribute.

## Feature Flags

Not applicable: CommandPalette does not gate its functionality behind feature flags. All features are always active.

## Analytics

Not applicable: CommandPalette does not emit analytics events. The host is responsible for tracking when items are selected or when the palette is opened/closed.

## Privacy

Not applicable: CommandPalette does not collect, store, or transmit user data. The query string is a controlled prop passed by the host and is the host's responsibility to manage.

## Logging

Not applicable: CommandPalette does not emit logs. Debugging is delegated to host-level instrumentation or React DevTools inspection.

## Platform Notes

- **SwiftUI**: Use a ZStack with a semi-transparent overlay (`.background(.black.opacity(0.2))`) behind a VStack for the input and list. Implement keyboard navigation using `.onKeyPress()` or `.keyboardShortcut()`. Use `List` with `@State var activeIndex` tracking the highlighted row. Horizontal list groups require explicit `Section` headers; only render when the section has items. Implement scrolling with `.scrollPosition(id:anchor:)` and `ScrollReader`. No native combobox role; approximate with `@accessible` annotations.
- **Compose**: Use an `AlertDialog` or `Dialog` with a `TextField` for input and a `LazyColumn` for the list. Implement highlight tracking with `var activeIndex by remember { mutableStateOf(0) }`. Use `focusRequester` and `FocusManager` to manage keyboard focus and ArrowUp/Down navigation. Render group headers as `item()` entries with conditional visibility. Implement scroll-into-view with `LazyListState.scrollToItem()`.
- **React/Web**: This is the source platform. See source implementation in `/packages/web/packages/ui/src/blocks/command-palette.tsx`. Uses React Hooks for state management (`useState`, `useRef`, `useId`, `useEffect`), Dialog primitive, controlled input, and `scrollIntoView()` for auto-scrolling. Keyboard handling via `onKeyDown` on the input. Listbox and option ARIA roles for accessibility.
- **AppKit / UIKit**: For macOS (AppKit), use `NSPanel` with a search field (`NSSearchField`) and a table view (`NSTableView`) or outline view. Implement keyboard navigation with `keyDown(_:)`. Use `NSAccessibility` attributes to mark the search field as a combobox and table rows as options. For iOS (UIKit), the overlay would be a `UIViewController` presented modally with a `UISearchBar` and a `UITableViewController`, though command palettes are less common on mobile.
- **WinUI 3**: Use a `ContentDialog` with a `TextBox` for the search input and an `ItemsRepeater` or `ListView` for the command list. Implement keyboard navigation in `KeyDown` event handlers on the TextBox, moving selection through the list using `SelectedIndex`. Render group headers as template items with conditional visibility (binding to `group.Items.Count > 0`). Use `BringIntoViewRequested` to scroll the selected item into view. Set `IsDialog` mode on the ContentDialog to block background interaction. Bind `TextBox.Text` to query state; bind list selection to highlight state.

## Design Decisions

1. **Query is a controlled prop, not internal state**: The component does not manage its own search query; it is always controlled by the host. This decoupling allows the host to integrate server-side search (remote results) without the component's local filter silently discarding matches. The host may use the exported `filterCommandItems` function to filter local groups or leave the filtering to a server.

2. **First item is always preselected**: Rather than starting with no selection, the first item is highlighted by default. This shortens the interaction to three keystrokes: "type, press Enter" — the most common palette interaction.

3. **Preselection resets on both list change AND reopen**: The signature-based reset (keyed on item IDs) ensures the highlight doesn't drift to an unintended item when the list updates mid-interaction. The separate open-triggered reset ensures reopening the palette doesn't resume the previous selection, avoiding accidental re-runs of the last selected command.

4. **Loading state does not replace the list**: Results that are stale are more useful than an empty pane. The loading indicator sits below the current results, signaling that more are coming without hiding what the user has.

5. **Groups are rendered in order only if non-empty**: Empty groups are silently dropped. This allows hosts to declare groups unconditionally without cluttering the UI with empty sections.

6. **Escape closes via Dialog primitive, not duplicated**: The Dialog primitive already handles Escape closure, so the component does not duplicate this handler.

7. **ScrollIntoView is guarded for test environments**: `scrollIntoView()` is called with optional chaining because jsdom (used in test suites) does not implement it. An unguarded call would throw in every host's test suite. Optional calling makes the scroll behavior a cosmetic nicety absent in tests rather than a test blocker.

8. **Wrapping on arrow navigation**: ArrowDown at the end of the list wraps to the first item. This is more useful than "nothing happens," allowing users to cycle through short lists without reaching for the mouse.

## Compliance

Not applicable: CommandPalette contains no security-sensitive features, no authentication, no data persistence, and no external API communication. Host-level compliance (e.g., analytics, privacy) is the host's responsibility.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation |
