---
id: 88dc87c9-8058-446d-9513-acfa618c950f
title: Search Dialog
domain: agenticdevelopercookbook://recipes/ui/search-dialog
type: ingredient
version: 1.1.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Modal dialog component for searching and selecting from indexed entries,
  with keyboard navigation and visual result preview.
platforms:
- typescript
- web
tags:
- search
- dialog
- modal
- form
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Search Dialog

## Overview

Search Dialog is a modal component that presents a full-screen search interface for discovering and selecting items from an indexed collection. It displays a text input field, live search results grouped by category, and supports both keyboard and pointer interaction. The component is designed for documentation and knowledge base search on the web platform.

## Behavioral Requirements

- **must-render-closed-by-default**: The component MUST NOT render to the DOM when `open` prop is `false`. The entire component tree MUST return `null`.
- **must-open-as-modal**: When `open` prop is `true`, the component MUST render as a modal dialog with `role="dialog"` and `aria-modal="true"` on the root container.
- **must-have-dismissible-backdrop**: The component MUST render a full-screen backdrop element. Clicking the backdrop MUST invoke the `onClose` callback.
- **must-focus-input-on-open**: When the `open` prop transitions from `false` to `true`, the input field MUST receive focus using `requestAnimationFrame` to defer until next paint.
- **must-reset-query-on-open**: When the `open` prop transitions from `false` to `true`, the component MUST reset the search state by calling `state.reset()`.
- **must-show-input-with-search-icon**: The input row MUST render as a form element with `role="search"`. It MUST display a search icon (magnifying glass SVG) and an input field with placeholder text.
- **must-render-escape-hint**: The input row MUST display a keyboard hint showing "Esc" to indicate the escape key can dismiss the dialog.
- **must-accept-placeholder-prop**: The component MUST accept an optional `placeholder` prop. If not provided, it MUST default to `"Search documentation..."`.
- **must-handle-escape-key**: When the user presses the Escape key in the input field, the component MUST immediately invoke `onClose()`.
- **must-handle-enter-key**: When the user presses Enter in the input field, if there is a selected result (by index), the component MUST invoke `onSelect()` with the selected entry and MUST NOT submit the form.
- **must-delegate-other-keys**: When the user presses any key other than Escape or Enter, the component MUST delegate handling to `state.handleKey(e)`.
- **must-update-query-on-input**: As the user types in the input field, the component MUST update the search state by calling `state.setQuery(e.target.value)` for each change event.
- **must-show-results-only-when-querying**: Results section MUST only render when `state.query` is truthy (non-empty string).
- **must-limit-results-to-twenty**: The component MUST slice results to display at most 20 entries from `state.results`.
- **must-group-results-by-section**: The component MUST group the top 20 results by `entry.section` property. Entries without a section MUST be grouped under `"other"`.
- **must-translate-section-labels**: For each section, the component MUST display the label from `sectionLabels[section]` if provided, otherwise MUST display the section key as-is.
- **must-render-empty-state**: When `state.query` is truthy but no results exist (top 20 is empty), the component MUST display "No results for "{query}"" message.
- **must-show-result-title-and-summary**: Each result MUST display the `entry.frontmatter.title`. If `entry.frontmatter.summary` exists, it MUST also be displayed below the title.
- **must-render-result-as-button**: Each result MUST be rendered as a `<button>` element with `type="button"`. Clicking a result MUST invoke `onSelect(entry)`.
- **must-highlight-selected-result**: The currently selected result (by `state.selectedIndex`) MUST be visually distinguished by applying the `awt-search-dialog__result--selected` CSS class modifier.
- **must-use-slug-as-result-key**: Each result button MUST use `entry.slug` as its React `key` prop.
- **must-prevent-form-submission**: The search form wrapper MUST have an `onSubmit` handler that calls `e.preventDefault()` to prevent page navigation on implicit form submission.
- **must-include-search-role**: The form element containing the input field MUST have `role="search"` to declare its semantic purpose.
- **must-apply-no-autofill-props**: The input field MUST apply the `noAutofillProps` to prevent browser autofill features.

## Appearance

- **Corner radius**: Not applicable — dialog uses platform default or stylesheet-driven radius; component does not hardcode corner values.
- **Padding**: Controlled via CSS classes (`awt-search-dialog__panel`, `awt-search-dialog__input-row`); not specified in source.
- **Font**: Controlled via CSS classes; not specified in source.
- **Background**: Controlled via CSS classes; source does not specify hardcoded values.
- **Foreground/Text**: Controlled via CSS classes; source does not specify hardcoded values.
- **Border**: Not specified in source code.
- **Shadow**: Not specified in source code.
- **Icon**: Search icon is rendered as inline SVG with `stroke="currentColor"` and `strokeWidth={2}`, allowing CSS-driven theming.

## States

| State | Appearance change |
|-------|------------------|
| Closed (`open: false`) | Component not rendered; does not appear in DOM. |
| Open (empty query) | Input field focused, results section not shown. |
| Open (with query, results found) | Results grouped by section are visible; selected result highlighted. |
| Open (with query, no results) | "No results for "{query}"" message displayed. |
| Result selected via keyboard | Result button receives `awt-search-dialog__result--selected` class. |
| Result hovered | Controlled by CSS; source does not specify hover behavior. |

## Accessibility

- **Role/trait**: Dialog (`role="dialog"`); form with search role (`role="search"`); results are buttons (`type="button"`).
- **Label requirements**: Input has `aria-label="Search"`. Section headings and result buttons derive meaning from text content; no explicit ARIA labels on results.
- **Announce state changes**: NEEDS REVIEW: Live region announcements not implemented. Component should announce result count and selected result changes to screen reader users as the user navigates results and performs searches. What evidence would settle this: implementation of `aria-live="polite"` regions or `aria-atomic` attributes on the results container to communicate dynamic content changes.
- **Minimum tap target**: Not specified in source. Result buttons and input field target sizes are stylesheet-driven and MUST meet platform guidelines (44×44pt minimum on iOS, 48×48dp on Android, 44px on web per WCAG).
- **Keyboard navigation**: Fully keyboard operable. Input accepts focus; arrow keys (via `state.handleKey`) navigate results; Enter selects; Escape dismisses.
- **Modal semantics**: `aria-modal="true"` signals focus trap; backdrop click and Escape dismiss.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| search-dialog-001 | must-render-closed-by-default | `open: false` | Component returns `null`; nothing renders. |
| search-dialog-002 | must-open-as-modal | `open: true` | Root div has `role="dialog"` and `aria-modal="true"`. |
| search-dialog-003 | must-have-dismissible-backdrop | `open: true`, click backdrop | `onClose()` callback is invoked. |
| search-dialog-004 | must-focus-input-on-open | `open: false` → `true` | Input field receives focus after paint (via `requestAnimationFrame`). |
| search-dialog-005 | must-reset-query-on-open | `open: false` → `true` | `state.reset()` is called (query state clears). |
| search-dialog-006 | must-show-input-with-search-icon | `open: true` | Form with `role="search"` renders; SVG search icon and input are visible. |
| search-dialog-007 | must-render-escape-hint | `open: true` | Keyboard hint element displaying "Esc" is rendered. |
| search-dialog-008 | must-accept-placeholder-prop | `open: true`, no `placeholder` prop | Input field displays "Search documentation..." placeholder. |
| search-dialog-009 | must-accept-placeholder-prop | `open: true`, `placeholder: "Find items"` | Input field displays "Find items" placeholder. |
| search-dialog-010 | must-handle-escape-key | `open: true`, user presses Escape in input | `onClose()` is invoked immediately. |
| search-dialog-011 | must-handle-enter-key | `open: true`, result selected, user presses Enter | `onSelect(selectedEntry)` is invoked; form does not submit. |
| search-dialog-012 | must-handle-enter-key | `open: true`, no result selected, user presses Enter | No action; form does not submit. |
| search-dialog-013 | must-delegate-other-keys | `open: true`, user presses ArrowDown | `state.handleKey(e)` is called with the keyboard event. |
| search-dialog-014 | must-update-query-on-input | `open: true`, user types "test" | `state.setQuery()` is called for each keystroke; input value updates. |
| search-dialog-015 | must-show-results-only-when-querying | `open: true`, `state.query: ""` | Results section is not rendered. |
| search-dialog-016 | must-show-results-only-when-querying | `open: true`, `state.query: "docs"` | Results section is rendered (or empty state if no results). |
| search-dialog-017 | must-limit-results-to-twenty | `open: true`, 50 results in `state.results` | Only top 20 results are processed and displayed. |
| search-dialog-018 | must-group-results-by-section | `open: true`, results with sections `["guides", "api", "api", "guides"]` | Results are grouped into two sections; order preserves first occurrence. |
| search-dialog-019 | must-group-results-by-section | `open: true`, result without section property | Result is grouped under `"other"`. |
| search-dialog-020 | must-translate-section-labels | `open: true`, `sectionLabels: { guides: "How-To Guides" }` | Section displays as "How-To Guides", not "guides". |
| search-dialog-021 | must-translate-section-labels | `open: true`, `sectionLabels: {}`, section is "api" | Section displays as "api" (no translation provided). |
| search-dialog-022 | must-render-empty-state | `open: true`, `state.query: "xyzabc"`, no results | Message displays: `No results for "xyzabc"`. |
| search-dialog-023 | must-show-result-title-and-summary | `open: true`, results present | Each result displays `entry.frontmatter.title`. |
| search-dialog-024 | must-show-result-title-and-summary | `open: true`, result with summary | Result displays both title and summary below it. |
| search-dialog-025 | must-show-result-title-and-summary | `open: true`, result without summary | Result displays title only; summary section not rendered. |
| search-dialog-026 | must-render-result-as-button | `open: true`, result visible | Result is a `<button type="button">` element. |
| search-dialog-027 | must-render-result-as-button | `open: true`, user clicks result | `onSelect(entry)` is invoked with that result's entry. |
| search-dialog-028 | must-highlight-selected-result | `open: true`, `state.selectedIndex: 2` | Third result (index 2) has class `awt-search-dialog__result--selected`. |
| search-dialog-029 | must-highlight-selected-result | `open: true`, `state.selectedIndex: 999` (out of range) | No result is highlighted; index-based selection may skip bounds check. |
| search-dialog-030 | must-use-slug-as-result-key | `open: true`, results rendered | Each result button has `key` prop set to `entry.slug`. |
| search-dialog-031 | must-prevent-form-submission | `open: true`, user presses Enter with form focused | Form's `onSubmit` prevents default; no page navigation. |
| search-dialog-032 | must-include-search-role | `open: true` | Form element has `role="search"`. |
| search-dialog-033 | must-apply-no-autofill-props | `open: true` | Input field has `noAutofillProps` applied (spread operator). |

## Edge Cases

- **Empty or null query**: When `state.query` is empty string or not set, results section does not render. Results are generated only when query is truthy. **MUST**.
- **Zero results from search**: When top 20 results array is empty but query is truthy, "No results" message is shown. **MUST**.
- **Large result set**: Component slices to top 20 results; remaining results are discarded and never rendered. Implementor should verify that `state.results` provides results in descending relevance order. **MUST**.
- **Out-of-bounds selectedIndex**: If `state.selectedIndex` is greater than the number of rendered results, no result is highlighted. Source does not bounds-check selection. Caller is responsible for keeping index in range. **MUST**.
- **Rapid open/close toggle**: Each `open: false → true` transition calls `state.reset()`. Multiple rapid toggles will reset state multiple times. Intended behavior per source comment. **MUST**.
- **Focus loss and regain**: When dialog closes and `open` prop changes to `false`, component returns `null`. Focus management on reopening is handled by `requestAnimationFrame` on the input ref. **MUST**.
- **Missing entry.slug**: Result rendering uses `entry.slug` as React `key`. If slug is missing or null, React warnings will occur. Caller MUST provide valid slug for each entry. **MUST**.
- **Missing entry.frontmatter.title**: Result displays `entry.frontmatter.title` without defensive checks. If title is missing, undefined or null renders as empty string. **MUST**.
- **Missing section property**: Entries without `entry.section` are grouped under `"other"`. This is explicit behavior per source code. **MUST**.
- **Simultaneous selection and key press**: If user clicks a result while pressing Enter, the Enter key event handler runs first (via `onKeyDown`), selects at current `selectedIndex`, and stops. Click handler does not fire. Order is: keydown → click in React's synthetic event ordering. **MUST**.
- **Input type not text**: Source hardcodes `type="text"` on the input element. Caller cannot override input type. **MUST**.
- **Null state object**: Source assumes `state` prop is always provided and calls methods on it without null checks. If state is null or undefined, component will throw. **MUST**.
- **Section label not a string**: `sectionLabels` values should be strings. If a value is an object or non-string, it will render via string coercion. Behavior is undefined for non-string values. **SHOULD** provide strings.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `open` | `boolean` | (required) | Controls whether the dialog is rendered and visible. |
| `onClose` | `() => void` | (required) | Callback invoked when user dismisses the dialog (Escape key or backdrop click). |
| `state` | `SearchState` | (required) | Mutable state object managing query, results, and selection. Must implement `reset()`, `setQuery(q)`, `handleKey(e)` methods. |
| `onSelect` | `(entry: SiteEntry) => void` | (required) | Callback invoked when user selects a result. |
| `sectionLabels` | `Record<string, string>` | `{}` | Optional mapping of section keys to display labels. Untranslated section keys appear as-is. |
| `placeholder` | `string` | `"Search documentation..."` | Placeholder text shown in the input field. |

## Deep Linking

Not applicable: component is a modal dialog overlay and does not define its own URL routes or deep links. Deep linking strategy is owned by the parent application that manages the `open` prop.

## Localization

| String Key | Default (en) | Context |
|-----------|-------------|---------|
| aria-label | `"Search"` | Accessible label for the input field. |
| placeholder | `"Search documentation..."` | Default placeholder text in input field; can be overridden by `placeholder` prop. |
| empty-state | `"No results for "{query}""` | Message shown when user has typed a query but no results are found. Includes user-entered query string. |
| escape-hint | `"Esc"` | Text displayed in keyboard hint showing how to close the dialog. |

Each string value is hardcoded in the component. To support multiple languages, wrap strings in a localization function at the call site or fork the component to accept a `strings` configuration prop.

## Accessibility Options

- **Reduce Motion**: Not applicable. Dialog appears immediately without fade-in or transition. If `prefers-reduced-motion` is desired, CSS media query can suppress animations. Component itself does not check the setting.
- **Increase Contrast**: Not applicable. Text color and background contrast are stylesheet-driven. Component does not expose a contrast mode setting. Stylesheet can provide high-contrast variant via CSS media query or theme class.
- **Differentiate Without Color**: Not applicable. Visual distinction of selected result is CSS-driven and may rely on color. Component does not implement a non-color marker (e.g., outline, checkmark) for selected state. Stylesheet SHOULD add non-color indicator.

## Feature Flags

Not applicable: component does not include conditional logic for feature flags. Enable/disable at the call site by controlling the `open` prop.

## Analytics

| Event | Properties | When |
|-------|-----------|------|
| `search-dialog.opened` | `{}` | Dialog `open` prop transitions from `false` to `true`. |
| `search-dialog.closed` | `{ reason: "escape" \| "backdrop" }` | Dialog closes via Escape or backdrop click. |
| `search-dialog.query_changed` | `{ query: string, length: number }` | User types in the input field; `state.setQuery()` is called. |
| `search-dialog.results_shown` | `{ result_count: number, top_k: number }` | Results are rendered (top 20 are sliced); triggered when query is truthy. |
| `search-dialog.result_selected` | `{ slug: string, section: string, index: number }` | User selects a result via click or Enter. |
| `search-dialog.selection_navigated` | `{ from_index: number, to_index: number }` | User presses arrow key and `state.handleKey()` changes `selectedIndex`. |

Analytics emission is not implemented in the component source. Call site MUST hook `onClose`, `onChange` (via state mutation observation), and `onSelect` to emit events. This is a data collection contract, not a component implementation.

## Privacy

- **Data collected**: Query strings entered by the user. Result titles and summaries selected or viewed.
- **Storage**: Query and selection data are ephemeral and stored only in React state (`SearchState` object). No persistence to storage, cookies, or local cache.
- **Transmission**: The `SearchState` object is responsible for making search queries to a backend or index. Component itself does not transmit data; `state.setQuery()` and `state.results` handle the exchange. Call site MUST ensure search backend is privacy-compliant.
- **Retention**: Search state is reset when the dialog opens (via `state.reset()`) and lost when the dialog closes (`open: false` unmounts the component). No historical log is kept.

Note: This component is a UI container. Privacy compliance depends entirely on the `SearchState` implementation and the backend search service. The component itself is privacy-neutral.

## Logging

Subsystem: `awt` | Category: `SearchDialog`

| Event | Level | Message |
|-------|-------|---------|
| Dialog opened | debug | `SearchDialog: Opened; query reset.` |
| Query changed | debug | `SearchDialog: Query set to "{query}" (length: {count}).` |
| Results fetched | debug | `SearchDialog: {result_count} results; top 20 grouped into {section_count} sections.` |
| Result selected | info | `SearchDialog: Result selected: {slug} (section: {section}, index: {index}).` |
| Keyboard navigation | debug | `SearchDialog: Arrow key navigation; selected index now {index}.` |
| Dialog dismissed | debug | `SearchDialog: Dialog dismissed via {reason} (escape/backdrop).` |

Logging is not implemented in the component source. Call site or wrapper MUST add logging hooks at event boundaries (open, setQuery, onSelect, onClose, state updates) to emit these messages.

## Platform Notes

- **Web/React**: Source code is a React functional component using `useEffect` and `useRef` hooks. The input ref is managed to ensure focus on open. Component uses synthetic events (onChange, onKeyDown, onClick). CSS classes (`awt-search-dialog__*`) drive all styling and layout; no inline styles. The form element prevents iOS Safari autofill by containing the input in a form of its own (documented in source comment). Key implementation details: backdrop click triggers onClose; open prop state change gates the useEffect reset; selectedIndex highlighting is CSS class-based; results are sliced to top 20 before grouping.

- **SwiftUI**: Adapt using SwiftUI's `.searchable()` modifier combined with a `Sheet` for modal presentation. Use `@FocusState` to manage input focus on open. Implement keyboard navigation via `.onKeyPress()` or `onSubmit()`. Group results using a `List` with `Section`. Adapt selection highlighting by binding `selectedIndex` to row state. Replace CSS class modifiers with conditional view properties (e.g., `.background()` conditional on selection).

- **Compose**: Adapt using Compose's `Dialog` composable with `Modifier.fillMaxSize()` for backdrop. Use `BasicTextField` with `Material3` styling for the input. Implement result grouping with `LazyColumn` and section headers via `stickyHeader`. Keyboard navigation is handled by Compose's focus system and `onKeyEvent`. Selected result highlighting uses Compose state (`selectedIndex`). Meet Material Design 3 minimum touch target of 48dp for results and input field. Use `Material3.Icon` for the search icon, sized to Material specifications.

- **AppKit / UIKit**: Adapt using `UISearchController` (UIKit) or `.searchable()` modifier (SwiftUI). SwiftUI's `SearchController` provides similar modal presentation with built-in backdrop and dismissal. Implement keyboard navigation via `UITableViewDelegate` arrow key handling. Group results using a sectioned list or table view with headers. Manage focus transition to search field on open using `becomeFirstResponder()`. Adapt the "No results" empty state to `ContentUnavailableView` or a custom placeholder. Replace CSS class modifiers with view state (isSelected flag on each row).

- **WinUI 3**: Adapt using `SearchBox` control for the input field; WinUI provides built-in search styling and icon. Render the backdrop using a semi-transparent `Canvas` or `Border` behind the dialog. Implement result grouping using `ListView.GroupStyle` with `CollectionViewSource` binding. Keyboard navigation is handled by WinUI's focus engine; Escape dismissal is automatic on modal dialogs. Selected result highlighting is data-driven via `SelectedItem` binding and a `ControlTemplate` with alternate style. Minimum touch target on WinUI is 40×40px; use `MinHeight="48"` and `MinWidth="48"` for results and input.

## Design Decisions

- **Top 20 results limit**: Results are sliced to the first 20 entries before grouping. This design balances display performance (avoiding massive lists) with relevance (assuming results are pre-sorted by rank). Implementors MUST ensure the backing search state provides results in descending relevance order. Rationale: prevents DOM explosion on large result sets and keeps interaction smooth.

- **Reset on open, not on close**: The component resets the search state (`state.reset()`) when `open` transitions to `false → true`, not on close. This allows state mutations during the dialog lifecycle to be observed if the dialog is reopened before being fully unmounted. Rationale: matches the documented comment that resetting on every state change would clobber user input mid-typing.

- **requestAnimationFrame for focus**: Input focus is deferred to `requestAnimationFrame()` rather than synchronous `.focus()` on open. This ensures focus occurs after the browser has painted the input to the DOM. Rationale: some browsers do not allow focus on display:none or off-screen elements; deferring to the next frame guarantees the input is renderable.

- **Form wrapper for autofill suppression**: The input is wrapped in a `<form>` element (not a div) to suppress iOS Safari's "AutoFill Contact" suggestion. The form has `role="search"` to maintain semantic intent and `onSubmit` handler to prevent navigation on implicit submission. Rationale: tested on iOS 26 against production chat inputs; this is the only reliable pattern to stop Safari's autofill menu from appearing.

- **Slug as React key**: Each result uses `entry.slug` as its `key` prop rather than the array index. This is safer for list reconciliation if results reorder or if the same results are displayed in different contexts. Rationale: slug is assumed to be a stable identifier for each entry.

- **Selected index highlighting via CSS class, not inline style**: The selected result applies the `awt-search-dialog__result--selected` class modifier via a ternary. No inline styles are used for selection appearance. Rationale: decouples visual design from component code; allows CSS to drive appearance and theme variation.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| Keyboard operable (Escape, Enter, arrow keys) | passed | Accessibility |
| Accessible modal semantics (role, aria-modal) | passed | Accessibility |
| Input has accessible label (aria-label) | passed | Accessibility |
| Supports search role on form | passed | Accessibility |
| No hardcoded colors; CSS-driven styling | passed | Theming |
| Autofill prevention on iOS | passed | Platform-specific quirk handling |
| Focus management on open/close | passed | User experience |
| Result grouping and localization | passed | UX |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.1.0 | 2026-09-22 | Mike Fullerton | Clarify review marker with evidence criteria; relabel Platform Notes Windows bullet to WinUI 3; clarify "Not applicable" sections; remove implementation-specific language from Accessibility Options |
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
