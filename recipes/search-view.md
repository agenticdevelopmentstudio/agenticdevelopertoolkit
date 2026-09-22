---
id: fed0a111-253c-427b-89c0-14f729657a7d
title: SearchView
domain: agenticdevelopercookbook://ingredients/search-view
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A document search interface combining query input, facet filters, result
  listing with keyboard navigation, and a collapsible preview dock.
platforms:
- typescript
- web
tags:
- search
- document-search
- result-listing
- keyboard-navigation
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# SearchView

## Overview

SearchView is a configurable, composable document-search interface for web applications. It combines a search query input, multi-facet filtering (category and tag), a scrollable result list with roving keyboard focus, and a collapsible preview dock below. The component is driven by three injected seams: a search scope (endpoint and parameters), a document-type configuration (result rendering and preview), and a link builder. It fetches results on-demand (debounced query and facet changes, plus instant-on-Enter), renders results through a supplied row component, previews the selected result through a supplied preview component, and synchronizes filter state to the URL for shareability. Until a query or facet filter is active, it shows a prompt instead of fetching or displaying results.

## Behavioral Requirements

- **must-accept-search-source**: Component MUST accept a `source` prop defining the API endpoint, base URL, and request parameter map for document search.
- **must-accept-document-type**: Component MUST accept a `documentType` prop containing a result row renderer, a preview component, a preview header renderer, and two extractors (`getId`, `getTitle`).
- **must-accept-document-href**: Component MUST accept a `documentHref` function prop that returns the public-page URL for a hit; this is the primary link seam and has no default.
- **must-render-search-filter-bar**: Component MUST render a SearchFilterBar with a text query input, a category dropdown filter, and a tag dropdown filter; all three are always mounted.
- **must-render-filter-chips**: Component MUST render a chip for each active facet filter (category, tag); each chip MUST have a remove button; a "Clear filters" button MUST appear when any facet is active.
- **must-not-auto-fetch**: Component MUST NOT fetch results until a query or facet filter becomes active; until then it MUST display a prompt (EmptyState).
- **must-debounce-search**: Component MUST debounce search and filter changes by the `debounceMs` prop (default 250ms) before fetching.
- **must-fetch-on-enter**: Component MUST fetch immediately (flushing the debounce) when Enter is pressed in the search input.
- **must-render-result-count**: Once results have settled, component MUST render a live result count above the list (e.g. "3 results" or "No results").
- **must-render-result-list**: Component MUST render the result list as a `<ul>` with one `<li>` per hit; each hit MUST be rendered through the supplied ResultRow component with `hit`, `href`, `query`, `selected` (boolean), `active` (boolean), `controlRef`, and `onSelect` props.
- **must-support-roving-focus**: Result list MUST implement roving tabindex: only one row is a Tab stop at any time; ArrowUp/ArrowDown move focus; Home/End jump to first/last; Enter/Space activate the focused row (left to the ResultRow's native handler).
- **must-track-active-index**: Component MUST track an internal active index (cursor position) distinct from selectedId; the cursor moves with arrow keys, Enter on the cursor opens the selected row into the preview.
- **must-clamp-cursor-on-resize**: When results are requeried and the result set shrinks, component MUST clamp the active index to the new item count to prevent out-of-bounds access.
- **must-render-loading-skeleton**: During the initial fetch (while no results have settled), component MUST render 3 placeholder skeleton bars with `aria-busy="true"` and `aria-label="Loading results"`.
- **must-render-zero-results**: When results settle with an empty list and no error, component MUST render a "No matching documents" message; if facets are active, include a hint to remove filters.
- **must-render-hard-error**: When a fetch error occurs and no results are cached, component MUST render a full error block with the error message and a Retry button.
- **must-render-stale-error**: When a fetch error occurs while results are cached (re-query failure), component MUST render a compact error strip above the list with the error message and a Retry button.
- **must-support-preview-dock**: Component MUST render a collapsible preview dock below the result list; the dock has a minimal header bar (title, collapse toggle) when collapsed, and expands to show the full preview header and rendered content when disclosed.
- **must-render-split-divider**: When the preview dock is disclosed, component MUST render a horizontal SplitDivider above it that is draggable (mouse) and keyboard-operable to resize the list/preview ratio; the divider MUST NOT render when the dock is collapsed.
- **must-manage-preview-disclosure**: Component MUST manage preview disclosure state independently of selection; selecting a result both opens the dock (discloses it) and moves focus into the preview content region (labeled "Document preview content").
- **must-handle-escape-in-list**: While focus is in the result list, Escape MUST collapse the preview dock (if a result is selected) without moving focus.
- **must-handle-escape-in-preview**: While focus is in the preview dock (header or content), Escape MUST collapse the dock and return focus to the row that opened it.
- **must-support-url-sync**: Component MUST synchronize `q`, `tag`, and `category` filters to the URL query string (if `urlSync` prop is true, the default); the synchronization MUST be SSR-safe and framework-agnostic, allowing results to be shared and back/forward to re-sync state.
- **must-label-search-region**: The search and filter bar MUST sit inside a `role="search"` landmark with an accessible label (`searchLandmarkLabel` prop, default "Document search"); the label MUST be distinct when multiple search regions render on a page.
- **must-label-search-input**: The search input MUST have an accessible label (`searchLabel` prop, default "Search documents").
- **must-label-result-list**: The result list `<ul>` MUST have `aria-label="Search results"`.
- **must-label-preview-region**: The preview dock section MUST have `aria-label="Document preview"` and the preview content region MUST have `aria-label="Document preview content"`.
- **must-announce-result-count**: The result count MUST have `role="status"` and `aria-live="polite"` to announce count changes to screen readers.
- **must-announce-loading**: The loading skeleton list MUST have `aria-busy="true"` and `aria-label="Loading results"`.
- **must-announce-loading-container**: The outer container holding the list MUST have `aria-busy` set to true while in the loading phase.
- **must-focus-preview-on-select**: When a result is selected, component MUST programmatically focus the preview content region (a `<div tabIndex={-1}>`) so keyboard users land on the opened preview.
- **must-not-refocus-on-unrelated-render**: Focus movement into the preview MUST only occur on user selection, not on unrelated re-renders or header-toggle disclosure changes; this is gated by an internal flag.
- **must-trim-category-dropdown-label**: The category dropdown label is "Filter by category" (static, always the same).
- **must-trim-tag-dropdown-label**: The tag dropdown label is "Filter by tag" (static, always the same).
- **must-accept-optional-props**: Component MUST accept optional props: `searchPlaceholder` (default "Search…"), `debounceMs` (default 250), `timeoutMs` (optional, passed to data-fetching hooks), `urlSync` (default true), `className` (extra classes on root).
- **must-clear-facets-only**: The "Clear filters" button MUST clear only active facets (category and tag), NOT the query string.
- **must-accept-hit-id-extraction**: Component MUST use the supplied `getId` function from documentType to extract the hit identifier.
- **must-accept-hit-title-extraction**: Component MUST use the supplied `getTitle` function from documentType to extract the hit title for display in the preview dock header.
- **must-render-preview-title-collapsed**: When the preview dock is collapsed, the minimal header bar MUST show the selected hit's title or "Preview" if nothing is selected.
- **must-render-preview-metadata-disclosed**: When the preview dock is disclosed and a hit is selected, the full metadata header from the type's `PreviewHeader` component MUST render in the header region; if nothing is selected while disclosed, the header renders nothing and the body's EmptyState is the sole "Select a result…" text.
- **must-route-escape-from-outer-section**: Escape handling MUST sit on the outer preview section so it fires from header controls (toggle, view-full-paper link) as well as the body, collapsing the dock uniformly.
- **must-sync-browser-back-forward**: URL synchronization MUST allow browser back/forward buttons to re-sync filter state to the view.

## Appearance

- **Corner radius**: The preview dock and all error/empty-state cards use `rounded-lg` (Tailwind; 0.5rem) or `rounded-xl` for the dock (0.75rem).
- **Padding**: Search region: 4px gap between components (Tailwind `gap-4`). Filter chips: `gap-2` (0.5rem) between chips. Preview dock header: `px-3 py-2` (0.75rem × 0.5rem). Result list: `gap-3` (0.75rem) between items. Preview list container: right padding `pr-1` to accommodate internal scrollbar.
- **Font**: Result count label: `text-xs` (0.75rem) weight not specified in source; chip labels: inherit from Badge; preview title (collapsed): `text-sm font-medium` (0.875rem, medium weight); preview subtitle: `text-xs` (0.75rem); error/empty-state labels: `text-sm` (0.875rem) to `text-xs` (0.75rem).
- **Background**: Preview dock: `bg-apt-surface` (primary surface color). Error blocks: `bg-apt-red/5` (red with 5% opacity). Loading skeleton: `bg-apt-surface-2` (secondary surface). Chip hover: `hover:bg-apt-surface-2`.
- **Foreground/Text**: Result count: `text-apt-text-dim` (muted text). Chip text: default (inherits from Badge). Chip hover: `hover:text-apt-text`. Preview subtitle: `text-apt-text-muted`. Error text: `text-apt-red`. Empty-state labels: `text-apt-text-muted` to `text-apt-text-dim`.
- **Border**: Borders use `border-apt-border` (primary border color). Error blocks: `border-apt-red/40` (red with 40% opacity). Loading skeleton: `border-apt-border`. Preview dock: `rounded-xl border border-apt-border`. Divider above preview content: `border-t border-apt-border`. Dashed border on empty-state: `border-dashed border-apt-border`.
- **Shadow**: None specified in source.
- **Min/Max size**: Result list container: `min-h-0` (flex layout prevents overflow), `h-[65vh]` on small viewports (65 viewport-height) with `min-h-[320px]` floor; on `sm:` and up: `h-[70vh]` with `min-h-[420px]` floor. Single item height: not constrained; rows scroll internally. Preview preview dock: disclosed state has `min-h-0` to allow scrolling.

## States

| State | Appearance change |
|-------|------------------|
| Default | —  |
| Loading | Loading skeleton: 3 placeholder bars with `animate-pulse` and `bg-apt-surface-2`. Container has `aria-busy="true"`. |
| Inactive (no query/facet) | EmptyState prompt displayed; no list or fetch occurs. |
| Empty results | "No matching documents" message with optional "remove filters" hint. |
| Hard error (error, no cache) | Full error block (min-height 160px) centered, with error message and Retry button. |
| Stale error (error, cached results) | Compact error strip above cached results; no min-height, self-start Retry button. |
| Preview collapsed | Preview dock shows minimal header: collapse toggle, title (or "Preview"), subtitle hint. No body region. |
| Preview disclosed | Preview dock expands to fill its flex ratio; metadata header and rendered body visible; SplitDivider above the dock appears. |

## Accessibility

- **Role/trait**: Root is a generic `<div>`. Search region is a landmark with `role="search"` and `aria-label`. Result list is a `<ul>` with `aria-label="Search results"`. Each result is a `<li>`. Preview dock is a `<section>` with `aria-label="Document preview"`. Preview content is a focusable `<div tabIndex={-1}>` with `aria-label="Document preview content"`. Chip removers are `<button type="button">`. Clear filters is a Button component. Result count has `role="status"` and `aria-live="polite"`. Error blocks have `role="alert"`. Loading list has `aria-busy="true"` and `aria-label="Loading results"`. List container has `aria-busy` true while loading.
- **Label requirements**: Search input has `label` prop; category and tag filters have labels. Result count is announced via aria-live. Chip remover buttons have descriptive aria-labels (e.g. "Remove Category filter: Science"). Collapse toggle has descriptive labels ("Collapse preview" / "Expand preview") and `aria-controls` pointing to the content region.
- **Announce state changes**: Loading state is communicated via `aria-busy` and aria-label on the list. Result count changes are announced via `aria-live="polite"`. Error state is communicated via `role="alert"` on the error block. Preview disclosure is communicated via `aria-expanded` on the CollapseToggle.
- **Minimum tap target**: Chip remove buttons use an invisible `::after` overlay (24×24 CSS px) over a visible 16px icon to meet WCAG 2.2 SC 2.5.8. Collapse toggle on the preview dock and other button controls inherit minimum touch targets from the Button and CollapseToggle components (see their recipes).
- **Keyboard navigation**: Search input accepts Enter to commit the search. Result list supports ArrowUp/ArrowDown (move focus), Home/End (jump to bounds), Enter/Space (activate focused row via ResultRow's handler). Escape in the list collapses the preview; Escape in the preview collapses and returns focus to the row. Tab navigation is managed by roving tabindex: only the active row is a Tab stop; arrows move focus without Tab.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| search-view-001 | must-not-auto-fetch | Component mounted with empty query and no facet filters | No fetch occurs; EmptyState prompt is displayed |
| search-view-002 | must-debounce-search | User types in the search field | Fetch is debounced by the `debounceMs` prop (default 250ms) before firing |
| search-view-003 | must-fetch-on-enter | User types "foo" and presses Enter | Fetch fires immediately, flushing any pending debounce |
| search-view-004 | must-render-loading-skeleton | A query becomes active | 3 skeleton placeholder bars render with `aria-busy="true"` |
| search-view-005 | must-render-result-count | Results settle (no error) | A live result count appears above the list (e.g. "3 results") |
| search-view-006 | must-support-roving-focus | Focus is in the result list; user presses ArrowDown | Focus moves to the next row; active index increments |
| search-view-007 | must-support-roving-focus | Focus is on the last row; user presses ArrowDown | Focus stays on the last row; active index does not change |
| search-view-008 | must-support-roving-focus | Focus is in the list; user presses Home | Focus moves to the first row; active index resets to 0 |
| search-view-009 | must-support-roving-focus | Focus is in the list; user presses End | Focus moves to the last row; active index equals item count − 1 |
| search-view-010 | must-render-zero-results | A query settles with 0 results and no error | "No matching documents" message displays; Retry does not appear |
| search-view-011 | must-render-hard-error | A fetch error occurs with no cached results | Full error block (min-height 160px) with error message and Retry button displays |
| search-view-012 | must-render-stale-error | A fetch error occurs while results are cached | Compact error strip appears above the list; Retry button is present |
| search-view-013 | must-render-filter-chips | A category filter is active | A removable chip displays the category name; a "Clear filters" button appears |
| search-view-014 | must-render-filter-chips | A tag filter is active | A removable chip displays the tag name; a "Clear filters" button appears |
| search-view-015 | must-clear-facets-only | "Clear filters" button is clicked | Category and tag filters are cleared; the query string is NOT cleared |
| search-view-016 | must-support-preview-dock | A result is selected | The preview dock discloses (expands); the preview content region receives focus |
| search-view-017 | must-handle-escape-in-preview | Focus is in the preview content region; Escape is pressed | The dock collapses; focus returns to the row that opened it |
| search-view-018 | must-focus-preview-on-select | A result is selected via click/Enter | The preview content `<div>` (tabIndex={-1}) receives programmatic focus |
| search-view-019 | must-render-split-divider | The preview dock is disclosed | A SplitDivider appears above the dock; it is draggable and keyboard-operable |
| search-view-020 | must-render-split-divider | The preview dock is collapsed | No SplitDivider is rendered |
| search-view-021 | must-support-url-sync | `urlSync` is true (default) and filters change | `q`, `tag`, and `category` are written to the URL query string |
| search-view-022 | must-support-url-sync | Browser back/forward buttons are used | Filter state re-syncs from the URL; results view updates |
| search-view-023 | must-label-result-list | Component renders the result list | The `<ul>` has `aria-label="Search results"` |
| search-view-024 | must-announce-result-count | Results settle and the count changes | The count element has `role="status"` and `aria-live="polite"` |
| search-view-025 | must-accept-optional-props | Component is mounted without `searchPlaceholder` prop | The search input uses the default placeholder "Search…" |
| search-view-026 | must-accept-optional-props | Component is mounted with `debounceMs={500}` | Search debounce uses 500ms instead of the default 250ms |
| search-view-027 | must-support-roving-focus | Results are requeried and the set shrinks; active index was 5 but only 2 results remain | Active index is clamped to 1 (item count − 1) |

## Edge Cases

- **Empty query, no facets**: No fetch occurs; a prompt ("Search research documents…") is shown. This remains until the user enters a query or selects a facet.
- **Query with no results and no error**: A "No matching documents" message is displayed. If facets are active, a hint "Try a different search or remove filters" appears; if no facets, only "Try a different search."
- **Fetch error with no cached results**: A full error block (centered, min-height 160px) displays the error message and a Retry button. The view is blocked; no partial results are shown.
- **Fetch error while results are cached**: A compact error strip appears above the cached result list. The list remains visible and scrollable. The user can browse cached results or click Retry to re-fetch.
- **Result set shrinks mid-navigation**: If the active index exceeds the new item count, it is clamped to `Math.min(activeIndex, itemCount - 1)` to prevent out-of-bounds access.
- **Selecting an already-selected result**: If the preview is already disclosed and the same result is selected again, focus moves into the preview without re-opening it. If the preview is collapsed, selecting the same result opens it (discloses) and moves focus.
- **Pressing Escape with no selection**: Escape in the list has no effect if no result is selected (no preview is open).
- **Chip removal**: Clicking a chip's remove button clears only that facet (category or tag), not others. The query persists; only the facet is cleared.
- **Multiple facet filters active**: Both category and tag can be active simultaneously. Each has its own removable chip. "Clear filters" clears both.
- **Filtering with no results**: The chips remain visible (as feedback that filters are active), and the "No matching documents" message is shown. The user can remove filters via the chips or the "Clear filters" button.

## Configuration

Not applicable: SearchView has no configuration table. Its behavior is fully controlled by props passed at mount time (source, documentType, documentHref, and optional settings like debounceMs and urlSync).

## Deep Linking

Not applicable: SearchView does not define deep-link paths. The documentHref prop is the seam through which the host provides document links; navigation is handled by the host's router, not the component.

## Localization

| String Key | Default (en) | Context |
|-----------|-------------|---------|
| `searchLabel` (prop) | "Search documents" | Accessible label for the search input |
| `searchPlaceholder` (prop) | "Search…" | Placeholder text in the search input |
| `searchLandmarkLabel` (prop) | "Document search" | Accessible name for the search region landmark |
| `Search research documents to get started.` | Hardcoded title in the inactive EmptyState | Prompt when no query or facet is active |
| `Type a query above, or pick a category or tag, to search across every researcher.` | Hardcoded description in the inactive EmptyState | Prompt description |
| `No results` / `{n} result` / `{n} results` | Plural/singular result count labels | Rendered by resultCountLabel helper |
| `No matching documents` | Hardcoded in the zero-results state | Message when query matches no results |
| `Try a different search or remove filters.` | Hardcoded in the zero-results state if facets are active | Hint when filters are applied but no results match |
| `Try a different search.` | Hardcoded in the zero-results state if no facets | Hint when no filters are applied |
| `Filter by category` | Hardcoded label for the category dropdown | Category filter label |
| `All categories` | Hardcoded allLabel for the category dropdown | Category dropdown "all" option |
| `Filter by tag` | Hardcoded label for the tag dropdown | Tag filter label |
| `All tags` | Hardcoded allLabel for the tag dropdown | Tag dropdown "all" option |
| `Category` / `Tag` | Hardcoded in chip labels | Prefix for chip labels (e.g. "Category: Science") |
| `Clear filters` | Hardcoded button label | Button that clears all active facets |
| `Active filters` (aria-label) | Hardcoded | Accessible label for the filter chips container |
| `Remove {label} filter {value}` | Template for chip remove button aria-labels | E.g. "Remove Category filter: Science" |
| `preview` (label) | Hardcoded in CollapseToggle | Toggle disclosure control label (prefix for "Collapse preview" / "Expand preview") |
| `Document preview` (aria-label) | Hardcoded on the section | Accessible label for the preview dock section |
| `Resize preview` | Hardcoded SplitDivider label | Accessible label for the resize divider |
| `Enlarge preview` (growBottomLabel) | Hardcoded | SplitDivider label for growing the preview pane |
| `Enlarge results` (growTopLabel) | Hardcoded | SplitDivider label for growing the results pane |
| `Preview` | Fallback title in collapsed dock when nothing is selected | Collapsed header text if no hit is selected |
| `Collapsed — expand to preview` | Hardcoded subtitle in collapsed dock | Hint text when dock is collapsed |
| `Select a result to preview it.` | Hardcoded subtitle and empty-state title | Shown when dock is collapsed with no selection, and as body when nothing is selected |
| `Document preview content` (aria-label) | Hardcoded on the preview content region | Accessible label for the preview body |
| `Loading results` (aria-label) | Hardcoded on the loading skeleton list | Accessible label during the loading state |
| `Search results` (aria-label) | Hardcoded on the result list `<ul>` | Accessible label for the result list |
| `Something went wrong loading results.` | Fallback error message if none is supplied | Default error message in ErrorState |
| `Retry` | Hardcoded button label in ErrorState | Button to retry a failed fetch |

## Accessibility Options

- **Reduce Motion**: The loading skeleton uses `animate-pulse` (a CSS animation). On `prefers-reduced-motion: reduce`, this animation SHOULD be removed or replaced with a static appearance. This is a style concern, not specific to SearchView's behavior, so it defers to the host's style implementation.
- **Increase Contrast**: All text colors (`text-apt-*`) and backgrounds inherit from the design system's apt-* tokens. The host's design system is responsible for providing high-contrast variants; SearchView does not handle this.
- **Differentiate Without Color**: Error state is communicated by a red background and text color; the component does not use color alone, as error chips have text labels and the error message is always present.

## Feature Flags

Not applicable: SearchView has no feature flags defined in the source.

## Analytics

Not applicable: SearchView does not emit analytics events directly. Analytics are the responsibility of the host application or the data-fetching hooks (useDocumentSearch, useUrlFilters, useFacets).

## Privacy

- **Data collected**: SearchView itself collects no data. The search query, filters, and selected result are held in local state and passed to the host's data-fetching layer and link builder.
- **Storage**: Filters are written to the URL query string if `urlSync` is true. No other persistent storage is used by the component.
- **Transmission**: All data transmission is delegated to the host via the `source` prop and the data-fetching hooks. SearchView does not make fetch calls directly.
- **Retention**: Filter state (q, tag, category) persists in the URL for the session; no data is retained after the user leaves the page or closes the tab.

## Logging

Not applicable: SearchView does not define logging events in the source.

## Platform Notes

- **TypeScript/Web**: Source files: `packages/web/packages/search/src/components/SearchView.tsx` and related modules. Uses React hooks (useState, useEffect, useCallback, useRef, useId), event handlers (KeyboardEvent), and Tailwind CSS for styling. Data fetching is delegated to custom hooks (useDocumentSearch, useUrlFilters, useFacets). The component is SSR-safe; filter state is synced bidirectionally with the URL.
- **SwiftUI**: A SearchView equivalent on iOS/macOS would use SwiftUI's `@State` and `@ObservedObject` for state management. Use a `VStack` for the layout (filter bar, chips, list, divider, preview dock). Implement keyboard navigation via `.onKeyDown()` modifiers. Use `List` with roving focus via `.focusable()` and programmatic focus management with `FocusState`. Manage the collapsible preview with a disclosure indicator (chevron) and animated height/opacity changes. Synchronize state with URLComponents or AppStorage. Touch targets meet Apple HIG minimums (44×44pt).
- **Compose**: A Compose version would use `MutableState` for filter and selection state. Layout as a `Column` with the SearchFilterBar, chips, a scrollable `LazyColumn` for results, and a collapsible `Surface` below for the preview. Implement roving keyboard focus via `Modifier.onPreviewKeyEvent()` and `FocusRequester`. Use `animateContentSize()` for the collapsible preview. Render the divider as a draggable `Box` with `pointerInput()`. Material Design 3 defines touch targets at 48×48dp; implement via padding and `minimumInteractiveComponentSize`.
- **AppKit / UIKit**: On macOS, use `NSView` or SwiftUI. On iOS, use `UIViewController` with a `UITableView` for the result list (implementing `UITableViewDelegate` for keyboard navigation and roving focus). Use `UITextField` for the search input and `UIControl` subclasses for filters and buttons. Implement the collapsible preview dock via a `UISplitViewController` or custom container with animated height changes. Handle keyboard events via `UIKeyCommand`. Touch targets on iOS meet Apple HIG (44×44pt). macOS supports keyboard-only navigation natively.
- **WinUI 3**: Use `StackPanel` (vertical) for the layout. Implement the search bar with `TextBox` (query) and `ComboBox` (filters). Use `ItemsRepeater` or `ListView` for the result list with `KeyDown` event handlers for arrow navigation. Manage focus via `Focus.TryFocus()` and `UIElement.Focus()`. Render the collapsible preview with a `Grid` and `RowDefinition` Height binding; animate disclosure via `Storyboard` or `ThicknessAnimation`. Implement the resize divider as a `Thumb` inside a `Grid.Splitter` (Telerik Xaml Controls) or a custom draggable control. Fluent 2 Design System defines touch targets at 40×40px minimum (40×44px on touch devices); use `Padding` to meet the target.

## Design Decisions

- **Separate active index from selected ID**: The component tracks both `activeIndex` (roving focus cursor) and `selectedId` (the previewed row). This allows keyboard navigation to move focus independently of the preview, preventing arrow keys from forcing a preview open on every keystroke. Only Enter or an explicit selection opens the preview.
- **Escape collapses, does not close**: Pressing Escape collapses the preview dock to its minimal header but does not deselect the hit. This preserves the user's selection for quick re-opening and allows quick preview toggles without re-fetching or re-navigating the list.
- **"Clear filters" clears facets only**: The button clears category and tag but NOT the query. A query entered by the user should not be erased when they remove a facet; this preserves intent and allows quick filter refinement.
- **No fetch until active**: Until a query or facet filter is present, the component shows a prompt instead of fetching an empty corpus. This avoids expensive initial fetches and improves perceived performance on page load.
- **Debounce + Enter**: Debounced search (default 250ms) allows smooth typing without hammering the server. Enter commits immediately, letting the user force a search if the debounce feels slow. This balances responsiveness with backend load.
- **URL sync by default**: `urlSync: true` is the default because shareability is a primary use case for search results. Users expect to copy a results URL and share it; disabling this requires explicit opt-out.
- **Preview disclosure independent of selection**: The dock can be collapsed even while a hit is selected. This allows the user to keep the same result selected but hide its preview temporarily (e.g., to focus on the list). Re-expanding the dock re-shows the preview without re-selection.
- **No chip remove on list empty**: Chips remain visible even when results are empty after filtering. This provides feedback that filters are active and guides the user to remove them. A duplicate "Clear filters" button in the empty state (as a separate control) would be confusing—the chips already show the active filters.
- **Roving tabindex is list-only**: Only the result list implements roving focus; buttons and the collapse toggle outside the list are standard Tab stops. This keeps focus management simple and aligns with ARIA practices for lists.
- **Focus movement gated by flag**: After a user selects a result, focus moves into the preview. This is gated by an internal flag (`focusPreviewRef`) to prevent focus from moving on unrelated re-renders (e.g., header toggle without selection change). This avoids disorienting focus jumps.
- **SplitDivider only when disclosed**: The resize divider only renders when the preview is open. When collapsed, there is nothing to resize (the dock is its natural header height). Omitting the divider when not needed reduces visual clutter and removes a non-functional control.

## Compliance

Not applicable: SearchView does not cite specific compliance checks. Compliance is verified by the implementing platform's design system and accessibility tooling.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | | Initial creation |
