---
id: 17433dd1-f3db-4d7b-9f58-997996a2b92e
title: Filtered List
domain: agenticdevelopercookbook://ingredients/filtered-list
type: ingredient
version: 1.1.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Searchable list component with keyboard navigation and item highlighting.
platforms:
- web
tags:
- list
- filtering
- search
- keyboard-navigation
depends-on: []
related: []
references: []
---

# Filtered List

## Overview

FilteredList is a searchable list component that renders a text input field above a list of items. It filters items based on the input query, supports keyboard navigation with arrow keys and Enter for selection, and maintains a highlight state for the currently focused item. The component is accessible via combobox and listbox ARIA roles and supports custom rendering through callback functions.

## Behavioral Requirements

- **must-render-input-field**: Component MUST render a text input field with an optional placeholder that defaults to "Filter…".
- **must-filter-items**: Component MUST filter the visible items based on the query text entered by the user (filtering logic is delegated to useFilteredList hook).
- **must-support-arrow-down**: When the user presses ArrowDown and visible items exist, component MUST move the highlight to the next item in the visible list, or to the first item if no item is currently highlighted.
- **must-support-arrow-up**: When the user presses ArrowUp and visible items exist, component MUST move the highlight to the previous item, or clear the highlight if the first item is highlighted.
- **must-support-enter-selection**: When the user presses Enter and an item is highlighted, component MUST call the onSelect callback with the highlighted item and prevent the default form submission.
- **must-support-escape**: When the user presses Escape and an item is highlighted, component MUST clear the highlight by setting highlightedIndex to -1 and prevent the default action.
- **must-reset-highlight-on-input-change**: When the user types in the input field, component MUST reset the highlighted item index to -1.
- **must-clamp-highlight-when-visible-shrinks**: When the visible items list shrinks and the currently highlighted index exceeds the new length, component MUST adjust the highlight to the last item in the visible list, or to -1 if the list is now empty.
- **must-render-item-list**: Component MUST render all visible items as `<li>` elements within a `<ul>` list with role="listbox".
- **must-render-each-item-with-title**: Each item MUST render its title via the getTitle callback or the title field in renderItem.
- **must-render-each-item-with-subtitle-if-present**: If getSubtitle is provided and returns a value for an item, component MUST render the subtitle.
- **must-render-each-item-with-details-if-present**: If getDetails is provided and returns a value for an item, component MUST render the details.
- **must-support-custom-render**: If renderItem is provided, component MUST call it instead of rendering title/subtitle/details directly.
- **must-make-items-clickable-when-onselect-provided**: When onSelect is provided, each visible item MUST be rendered as a button that calls onSelect when clicked.
- **must-support-mouse-highlight**: When the user moves the mouse over an item, component MUST highlight that item.
- **must-scroll-active-item-into-view**: When the highlight changes to a new item, component MUST call scrollIntoView with `{ block: 'nearest' }` on the corresponding list item element.
- **must-update-input-value-when-highlighted**: When an item is highlighted, the input field MUST display the title of that item instead of the query text.
- **must-set-combobox-aria-expanded**: The input field MUST have aria-expanded set to true when visible items exist, false otherwise.
- **must-set-combobox-aria-activedescendant**: The input field MUST have aria-activedescendant set to the ID of the currently highlighted item, or undefined if no item is highlighted.
- **must-assign-unique-ids-to-items**: Each list item MUST have a unique ID constructed as `{listId}-{getId(item)}`.
- **must-set-option-aria-selected**: Each item MUST have aria-selected="true" when highlighted, "false" otherwise.
- **must-call-onhighlight-callback**: When the highlighted item changes, component MUST call the onHighlightChange callback with the new highlighted item or null if no item is highlighted.
- **must-show-empty-state-when-no-items**: When total === 0, component MUST display "No items." instead of the list.
- **must-support-custom-empty-content**: If emptyContent is provided and the list is empty after filtering, component MUST render emptyContent instead of the default message.
- **must-render-footer**: If footer is provided, component MUST render it as the last list item.
- **must-wrap-input-in-form**: Component MUST wrap the input field in a `<form role="search">` element to prevent Safari autofill misclassification.
- **must-prevent-submit-on-form**: The form MUST prevent default submission on submit event.
- **must-apply-autofill-prevention**: Component MUST apply noAutofillProps to the input to disable browser autofill.
- **must-support-autofocus**: Component MUST focus the input on mount when autoFocus is true.
- **must-not-prevent-default-arrow-keys-when-no-items**: Component MUST NOT prevent the default behavior for arrow keys if no visible items exist.

## Appearance

- **Corner radius**: Not specified in source; uses CSS classes (fl-input, fl-item, etc.)
- **Padding**: Not specified in source; controlled by CSS classes
- **Font**: Not specified in source; controlled by CSS classes
- **Background**: Not specified in source; controlled by CSS classes
- **Foreground/Text**: Not specified in source; controlled by CSS classes
- **Border**: Not specified in source; controlled by CSS classes
- **Shadow**: Not specified in source; controlled by CSS classes
- **Min/Max size**: Input is width: 100%; list items are full-width within the root container
- **CSS class structure**:
  - `fl-root`: Root container wrapper
  - `fl-input`: Text input field
  - `fl-list`: Unordered list element
  - `fl-item`: List item element
  - `fl-item--active`: Applied to active/highlighted item
  - `fl-item--clickable`: Applied to items when onSelect is provided
  - `fl-item-button`: Button wrapper around item content when clickable
  - `fl-title`: Title text within an item
  - `fl-subtitle`: Subtitle text within an item
  - `fl-details`: Details text within an item
  - `fl-empty`: Empty state message element
  - `fl-footer`: Footer element

## States

| State | Appearance change | Trigger |
|-------|------------------|---------|
| Default | No item highlighted, input shows query text | Initial state |
| Highlighted | Item has fl-item--active class, input shows item title, aria-selected="true" | Arrow keys, mouse hover |
| Filtered | List shows only matching items, empty state shown if no matches | User types in input |
| Disabled/Empty | "No items." message shown, list not rendered | total === 0 |
| Focused | Input has keyboard focus | User clicks input or autoFocus=true |

## Accessibility

- **Input role**: MUST be `combobox` with aria-controls pointing to the list ID and aria-expanded indicating whether the list has items.
- **Input aria-activedescendant**: MUST point to the currently highlighted item's ID, or be undefined if no item is highlighted.
- **List role**: MUST be `listbox` with a unique id.
- **Item role**: Each item MUST have role="option" and aria-selected reflecting highlight state.
- **Form role**: MUST be `role="search"` for semantic meaning.
- **Keyboard navigation**: MUST support ArrowUp, ArrowDown, Enter, and Escape keys as specified in Behavioral Requirements.
- **Focus management**: MUST allow focus to move between input and list items via keyboard.
- **Label for input**: NEEDS REVIEW: Component lacks built-in label element rendering. Relies on parent-provided aria-label or placeholder text for accessible labeling. Evidence: whether consuming code consistently provides aria-label, or component should support a label prop.
- **Minimum touch target size**: Not applicable; this component targets web and provides clickable buttons that meet 44×44px minimum (per source line 1076).

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| filtered-list-001 | must-render-input-field | Initial render | Text input field with placeholder "Filter…" is rendered |
| filtered-list-002 | must-filter-items | Query "apple" entered | Only items matching "apple" are visible in the list |
| filtered-list-003 | must-support-arrow-down | No highlight + ArrowDown pressed | First item becomes highlighted |
| filtered-list-004 | must-support-arrow-down | First item highlighted + ArrowDown pressed | Second item becomes highlighted |
| filtered-list-005 | must-support-arrow-down | Last item highlighted + ArrowDown pressed | Highlight remains on last item |
| filtered-list-006 | must-support-arrow-up | First item highlighted + ArrowUp pressed | Highlight is cleared (index = -1) |
| filtered-list-007 | must-support-arrow-up | Second item highlighted + ArrowUp pressed | First item becomes highlighted |
| filtered-list-008 | must-support-enter-selection | Item highlighted + Enter pressed | onSelect callback is called with highlighted item |
| filtered-list-009 | must-support-escape | Item highlighted + Escape pressed | Highlight is cleared |
| filtered-list-010 | must-reset-highlight-on-input-change | Item highlighted + user types in input | Highlight is reset to -1 |
| filtered-list-011 | must-clamp-highlight-when-visible-shrinks | Highlight on item 5, query changes to show 3 items | Highlight moves to item 3 (last visible) |
| filtered-list-012 | must-render-item-list | Items provided via props | All visible items render as `<li>` with role="option" |
| filtered-list-013 | must-render-each-item-with-title | Item with getTitle callback | Title is rendered in fl-title element |
| filtered-list-014 | must-render-each-item-with-subtitle-if-present | Item with getSubtitle callback | Subtitle is rendered in fl-subtitle element |
| filtered-list-015 | must-make-items-clickable-when-onselect-provided | onSelect callback provided | Each item wraps its content in a button element |
| filtered-list-016 | must-support-mouse-highlight | User moves mouse over item | Item becomes highlighted, aria-selected="true" |
| filtered-list-017 | must-scroll-active-item-into-view | Highlight moves to off-screen item | List container scrolls to show the highlighted item |
| filtered-list-018 | must-update-input-value-when-highlighted | Item highlighted | Input value shows item title instead of query |
| filtered-list-019 | must-set-combobox-aria-expanded | Visible items exist | Input has aria-expanded="true" |
| filtered-list-020 | must-set-combobox-aria-expanded | No visible items | Input has aria-expanded="false" |
| filtered-list-021 | must-set-combobox-aria-activedescendant | Item highlighted | Input aria-activedescendant matches item ID |
| filtered-list-022 | must-assign-unique-ids-to-items | Multiple items rendered | Each item has unique id: `{listId}-{itemId}` |
| filtered-list-023 | must-set-option-aria-selected | Item highlighted | Item has aria-selected="true" |
| filtered-list-024 | must-set-option-aria-selected | Item not highlighted | Item has aria-selected="false" |
| filtered-list-025 | must-call-onhighlight-callback | Highlight changes | onHighlightChange callback is invoked with new item or null |
| filtered-list-026 | must-show-empty-state-when-no-items | total === 0 | "No items." message is displayed instead of list |
| filtered-list-027 | must-support-custom-empty-content | emptyContent provided + empty after filter | Custom emptyContent is rendered |
| filtered-list-028 | must-render-footer | footer prop provided | Footer is rendered as last list item |
| filtered-list-029 | must-wrap-input-in-form | Initial render | Input is wrapped in `<form role="search">` |
| filtered-list-030 | must-prevent-submit-on-form | User presses Enter on input | Form submission is prevented, onSelect is called instead |
| filtered-list-031 | must-apply-autofill-prevention | Input rendered | noAutofillProps applied to prevent browser autofill |
| filtered-list-032 | must-support-autofocus | autoFocus={true} prop | Input receives focus on mount |

## Edge Cases

- **Empty item list** (total === 0): Component displays "No items." text and does not render the list element. No keyboard navigation occurs.
- **No visible items after filter**: Empty state message is displayed with custom emptyContent if provided, otherwise default "No matches for 'query'." message.
- **Query is empty string or only whitespace**: Filtering is cleared; all items are visible. Input shows the filtered query, not a highlighted item's title, until an item is highlighted via keyboard.
- **Highlight index exceeds visible array**: When visible.length shrinks, highlightedIndex is automatically clamped to the last visible index or -1 if empty.
- **Keyboard navigation with no visible items**: Arrow keys, Enter, and Escape do nothing; the function returns early.
- **Mouse hover while item is already highlighted via keyboard**: Hover changes highlight to the hovered item; onHighlightChange is called.
- **Escape when no item is highlighted**: No action; default is not prevented.
- **Enter when no item is highlighted**: No action; default is not prevented, but form submission is still prevented by the form wrapper.
- **Rapid query changes**: onHighlightChange is debounced by ref tracking; callback is only invoked when the actual highlighted item reference changes, not on every render.
- **scrollIntoView unavailable**: Component checks `typeof el.scrollIntoView === 'function'` before calling; if unavailable, the item is not scrolled into view but navigation continues.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `placeholder` | string | "Filter…" | Placeholder text for the input field |
| `className` | string | undefined | Optional CSS class name to apply to the root element (appended to "fl-root") |
| `autoFocus` | boolean | false | Whether the input field should receive focus on mount |
| `renderItem` | function | undefined | Optional custom render function for item content; if provided, overrides title/subtitle/details rendering |
| `onSelect` | function | undefined | Callback invoked when an item is selected via Enter or click; makes items clickable buttons if provided |
| `onHighlightChange` | function | undefined | Callback invoked when the highlighted item changes; receives the highlighted item or null |
| `footer` | ReactNode | undefined | Optional element to render as the last list item |
| `emptyContent` | ReactNode | undefined | Optional custom empty state message; defaults to "No matches for …" or "No items." |
| `getId` | function | required | Callback to get unique ID for each item |
| `getTitle` | function | required | Callback to get title text for each item |
| `getSubtitle` | function | undefined | Callback to get subtitle text for each item |
| `getDetails` | function | undefined | Callback to get details text for each item |
| (all other props) | passed to useFilteredList | — | Filtering configuration passed to the useFilteredList hook |

## Deep Linking

Not applicable: FilteredList is a form-like UI component without a standalone URL or navigation pattern. Deep linking is handled by the consuming application if needed.

## Localization

| String Key | Default (en) | Context |
|-----------|-------------|---------|
| `placeholder` | "Filter…" | Input field placeholder; customizable via props |
| `empty.no-items` | "No items." | Shown when total === 0 |
| `empty.no-matches` | "No matches for "{query}"." | Shown when filter returns zero results; customizable via emptyContent prop |

## Accessibility Options

- **Reduce Motion**: When the user has enabled reduce-motion preferences, scrollIntoView behavior SHOULD respect prefers-reduced-motion and avoid scroll animations. Component calls scrollIntoView with `{ block: 'nearest' }`; modern browsers handle prefers-reduced-motion by default.
- **Increase Contrast**: Component inherits contrast from CSS classes (fl-input, fl-item--active, etc.); no specific component-level support.
- **Differentiate Without Color**: Component uses aria-selected and classes (fl-item--active) to indicate state; CSS implementation should not rely on color alone per WCAG 2.1 AA.

## Feature Flags

Not implemented in source. Component does not have feature flag support.

## Analytics

Not implemented in source. Component does not emit analytics events; tracking is the responsibility of the consuming application via callbacks (onSelect, onHighlightChange).

## Privacy

- **Data collected**: None. Component does not collect, store, or transmit user data.
- **Storage**: No data is persisted by this component.
- **Transmission**: No data is transmitted beyond the host application's own analytics or backend systems (if connected by the consumer).
- **Retention**: Not applicable; no data is retained by this component.

## Logging

Not implemented in source. Component does not emit log messages; logging is the responsibility of the consuming application.

## Platform Notes

- **React/Web**: Component is implemented as a React functional component using hooks (useState, useEffect, useLayoutEffect, useId, useRef). The filtering logic is delegated to the custom `useFilteredList` hook. Styling is applied via CSS class names (fl-*). Component is marked `'use client'` for Next.js client-side rendering. See `/packages/web/packages/controls/src/filtered-list/FilteredList.tsx` and `/useFilteredList.ts` for implementation.
- **SwiftUI**: Start from a TextField and List composition. Use a @State property for the query string and @State for the highlighted index. Implement keyboard event handling via onKeyDown and a custom KeyboardShortcuts modifier. Use List's selection binding to manage highlighted state. Implement filtering by applying .filter on the data array. Use ScrollViewReader and scrollTo to implement scroll-into-view behavior. Use @Environment(\.sizeCategory) to respect Accessibility font size preferences.
- **Compose**: Start from TextField and LazyColumn composition. Use mutableStateOf for query and highlighted index. Implement keyboard navigation via KeyEvent handling and Key.DirectionUp/Down. Use LazyListState with layoutInfo to implement scroll-into-view behavior. Use Modifier.semantics to set ARIA-like roles and state. Apply Material Design 3 spacing and typography tokens from the theme for appearance.
- **AppKit / UIKit**: For AppKit, use NSSearchField for the input and NSTableView or NSOutlineView for the list. Bind the search field's stringValue to filter the table's datasource. Implement keyboard navigation via NSResponder's keyDown override. For UIKit (iOS), use UISearchController or a custom UISearchBar with UITableViewController. Use UITableViewDelegate methods (didSelectRowAt, didHighlightRowAt) to manage highlight state. Use UITableView's scrollToRow(at:at:animated:) for scroll-into-view. Apply UIAccessibilityElement role for accessibility.
- **WinUI 3**: Use TextBox for the input field and ItemsRepeater or ListView for the list. Bind the TextBox Text property to a backing property that triggers filtering. Implement keyboard navigation via PreviewKeyDown event handler, checking for Key.Up and Key.Down. Use ListView's SelectedIndex to track the highlighted item. Use FrameworkElement.UpdateLayout and ScrollIntoView for scrolling. Apply AutomationProperties (Name, ControlledBy, ItemStatus) to set ARIA roles and aria-selected state. Consider using ComboBox control instead for built-in accessibility and keyboard handling semantics.

## Design Decisions

**Form wrapper for Safari autofill prevention**: The input is wrapped in a `<form role="search">` to address a Safari iOS 26 autofill scoping issue. Without the form ancestor, Safari classifies an orphan input field against the entire document and offers the user's contact card as an autofill suggestion, which is undesired. The form is a visual block (flex column) and has no visual impact on layout. The onSubmit handler prevents form submission since Enter is already handled by the input's onKeyDown.

**Highlight tracking by reference**: The onHighlightChange callback is wrapped in a ref to prevent re-firing when the callback itself changes between renders. The highlighted item is tracked by reference comparison, not by index, so the callback fires only when the actual item reference changes, not on every render cycle. This reduces unnecessary callback invocations when consumers pass inline callback functions.

**Arrow-up clears highlight instead of wrapping**: When the user presses ArrowUp on the first item, the highlight is cleared (index = -1) rather than wrapping to the last item. This allows the user to escape the list via keyboard and return focus to the input field.

**Highlight scope**: The highlight state (highlightedIndex) is local to the component. The highlighted item's title is reflected in the input field to provide immediate visual feedback, replacing the query text. This makes it clear which item would be selected if Enter is pressed.

**Filtering delegation**: The component delegates all filtering logic to the useFilteredList hook, which manages the visible items array. The component is responsible only for UI rendering, keyboard handling, and highlight management.

**Click vs. keyboard selection**: Items are clickable only when onSelect is provided. When onSelect is not provided, items are static list items without button wrapping. This allows consumers to use the component for display-only scenarios where selection is not needed.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| [wcag-2.1-aa-keyboard-navigation](agenticdevelopercookbook://compliance/wcag#keyboard-navigation) | passed | Accessibility |
| [wcag-2.1-aa-aria-roles](agenticdevelopercookbook://compliance/wcag#aria-roles) | passed | Accessibility |
| [wcag-2.1-aa-focus-visible](agenticdevelopercookbook://compliance/wcag#focus-visible) | passed | Accessibility |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.1.0 | 2026-09-22 | Claude Haiku 4.5 | Fix Reduce Motion accessibility guidance; keep label accessibility gap marker |
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation from React source |
