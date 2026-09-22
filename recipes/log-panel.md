---
id: 57e33900-ca06-474e-abb1-d904c27a6336
title: Log Panel
domain: agenticdevelopercookbook://ingredients/log-panel
type: ingredient
version: 1.1.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A scrollable, column-based display for structured log lines with configurable
  columns, follow-tail behavior, and interactive cells.
platforms:
- web
tags:
- logging
- display
- data-table
depends-on: []
related: []
references: []
---

# Log Panel

## Overview

The Log Panel component displays structured log data as rows and columns in a scrollable container. Each row represents a log entry with values in multiple columns. The component supports configurable column definitions, automatic follow-tail scrolling to the bottom when new entries arrive, limiting the visible row count, and optional click handlers on individual cells. It is designed for real-time data inspection, debugging output, and activity logs.

## Behavioral Requirements

- **must-render-columns**: Component MUST display all columns defined in the `columns` prop, rendering column headers when `showHeader` is true.
- **must-render-rows**: Component MUST render all visible log lines as rows with cell values keyed by column id from the `lines` prop.
- **must-show-empty-state**: Component MUST display the `emptyMessage` (default: `"(no events)"`) when `lines` is empty or no rows are visible.
- **must-enforce-max-lines**: Component MUST limit visible rows to the count specified in `maxLines` by retaining only the most recent entries, discarding older ones.
- **must-follow-tail-by-default**: Component MUST scroll to the bottom when new lines are added, if `followTail` is true (default).
- **must-honor-follow-tail-toggle**: Component MUST stop scrolling to the bottom when `followTail` is set to false, and resume scrolling when `followTail` is set back to true.
- **must-detect-user-scroll**: Component MUST detect when the user has scrolled away from the bottom and stop following the tail until they scroll back to near the bottom (slack of 4 pixels).
- **must-handle-cell-click**: Component MUST invoke `column.onCellClick` when a cell is clicked, passing the entire `LogLine` object, if the handler is defined.
- **must-handle-cell-double-click**: Component MUST invoke `column.onCellDoubleClick` when a cell is double-clicked, passing the entire `LogLine` object, if the handler is defined.
- **must-apply-column-widths**: Component MUST apply the width from `column.width` to each column as a CSS grid track size, using the format `${width}px` for numeric values and the string value directly for other formats.
- **must-apply-default-column-width**: Component MUST use `minmax(120px, 1fr)` as the default grid track size for columns that do not specify a width.
- **must-apply-cell-text-alignment**: Component MUST align cell text according to `column.align` (e.g., `start`, `center`, `end`), defaulting to `start`.
- **must-apply-cell-level-color**: Component MUST apply the color for the log level from `LEVEL_VAR` if `cell.level` or `column.defaultLevel` is set, using CSS variable fallbacks to platform colors.
- **must-apply-cell-custom-color**: Component MUST apply `cell.color` as the CSS color value if provided, overriding level-based colors.
- **must-apply-cell-mono-font**: Component MUST apply monospace font (CSS variable `--font-mono` or fallback to system monospace) if `cell.mono` or `column.defaultMono` is true.
- **must-apply-cell-strong-weight**: Component MUST apply font-weight of 600 if `cell.strong` is true.
- **must-apply-cell-link-styling**: Component MUST add the CSS class `lp-cell--link` if `cell.link` is true, allowing stylistic differentiation (e.g., underline, color change).
- **must-show-interactive-indicator**: Component MUST add the CSS class `lp-cell--interactive` to cells if `column.isClickable`, `cell.link`, or `column.onCellClick` is defined.
- **must-apply-cell-title-attribute**: Component MUST set the HTML `title` attribute on each cell to the cell's text content for tooltip display on hover.
- **must-support-max-height**: Component MUST apply the `maxHeight` style to the scrollable body container if `maxHeight` is provided.
- **must-support-custom-class**: Component MUST apply the `className` prop to the root container, prefixing it with `lp-root` and combining both classes if a className is provided.
- **must-apply-grid-layout**: Component MUST use CSS Grid with the grid-template-columns derived from all column widths for both the header and each row.
- **must-include-aria-roles**: Component MUST include ARIA roles: `row` on header and each row, `columnheader` on header cells, `cell` on body cells, and `rowgroup` on the rows list.
- **must-stop-event-propagation**: Component MUST call `stopPropagation()` on click and double-click events to prevent bubbling up from cells.

## Appearance

- **Container**: Grid-based layout with header and scrollable body sections
- **Column header cells**: Display column title; text alignment per column.align; default is left-aligned (start)
- **Body cells**: Display cell text; font, color, and weight applied per cell and column properties
- **Empty state**: Centered, gray text message when no rows are visible
- **Scrollbar**: Native to the OS; appears when content exceeds maxHeight
- **Cell background**: Transparent by default; cell text inherits color from level or custom color
- **Cell padding**: Not specified in source; stylesheet is expected to define via CSS classes
- **Monospace font**: Applied via CSS variable `--font-mono` or system fallback `ui-monospace, SFMono-Regular, monospace`
- **Level colors**: Text color is determined by `LEVEL_VAR` mapping (info, warn, error, success, debug, dim, accent) using CSS variables with platform fallbacks

## States

| State | Appearance change |
|-------|---|
| Default | Rows display with configured colors and fonts |
| Empty | Empty message text is shown; rows are hidden |
| Interactive cell hovered | CSS class `lp-cell--link` or `lp-cell--interactive` applied for visual feedback |
| User scrolled away from tail | Component stops auto-scrolling; no visual change to rows themselves |
| followTail disabled | Component does not scroll on new content; no visual change |

## Accessibility

- **Role**: The root container is a grid-based table-like structure; ARIA roles are applied: `row` for header and data rows, `columnheader` for header cells, `cell` for body cells, `rowgroup` for the rows list.
- **Labels**: Column headers serve as labels for columns; each header cell has role `columnheader` and displays the column title text.
- **Interactive cells**: Cells with click handlers or `isClickable` flag are marked with `lp-cell--interactive` class, signaling interactivity to assistive technologies.
- **Title attribute**: Each cell includes a `title` attribute with its text content, providing a tooltip and accessible text for screen readers.
- **Text alternatives**: Text content is displayed directly; no icons or images require alt text in the component itself.
- **Keyboard navigation**: NEEDS REVIEW: Keyboard navigation is not implemented in source. What keyboard interactions should be supported (e.g., arrow keys to navigate cells, Enter or Space to activate on interactive cells) and how should focus management (tabindex, focus indicators) be implemented?
- **Minimum tap target**: Not applicable: Cell dimensions and tap target sizes are controlled by CSS styling, not by the component; consumers must ensure minimum tap/click targets (44×44pt on mobile, per WCAG and platform guidelines) via stylesheet implementation.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|---|---|---|
| log-panel-001 | must-render-columns | columns=[{id:'level',title:'Level'},{id:'msg',title:'Message'}], showHeader=true | Header displays two cells with text 'Level' and 'Message' |
| log-panel-002 | must-render-rows | lines=[{id:'1',values:{level:{text:'info'},msg:{text:'Started'}}}], columns=[...] | One row with two cells displaying 'info' and 'Started' |
| log-panel-003 | must-show-empty-state | lines=[], emptyMessage='No logs' | Container displays text 'No logs' |
| log-panel-004 | must-enforce-max-lines | lines=[{id:'1',...},{id:'2',...},{id:'3',...}], maxLines=2 | Only rows with id '2' and '3' are visible; row id '1' is hidden |
| log-panel-005 | must-follow-tail-by-default | followTail=true (default), lines appended | scrollTop is set to scrollHeight after new lines render |
| log-panel-006 | must-honor-follow-tail-toggle | followTail=true, user appends line, then followTail=false, user appends second line | First append scrolls to bottom; second append does not scroll |
| log-panel-007 | must-detect-user-scroll | followTail=true, user manually scrolls up (scrollHeight - scrollTop > clientHeight + 4) | pinnedRef becomes false; auto-scroll stops |
| log-panel-008 | must-handle-cell-click | column={..., onCellClick: jest.fn()}, click cell | onCellClick is called with the LogLine object |
| log-panel-009 | must-handle-cell-double-click | column={..., onCellDoubleClick: jest.fn()}, double-click cell | onCellDoubleClick is called with the LogLine object |
| log-panel-010 | must-apply-column-widths | columns=[{id:'a', width:200}, {id:'b', width:'1fr'}] | gridTemplateColumns is '200px 1fr' |
| log-panel-011 | must-apply-default-column-width | columns=[{id:'a'} (no width specified)] | gridTemplateColumns includes 'minmax(120px, 1fr)' for that column |
| log-panel-012 | must-apply-cell-text-alignment | column={align:'center'}, cell text 'Centered' | CSS textAlign is set to 'center' |
| log-panel-013 | must-apply-cell-level-color | cell={level:'error'}, column={defaultLevel:'info'} | Cell color is LEVEL_VAR['error'] |
| log-panel-014 | must-apply-cell-custom-color | cell={color:'#ff0000'} | CSS color is '#ff0000' (overrides level color) |
| log-panel-015 | must-apply-cell-mono-font | cell={mono:true} | fontFamily is 'var(--font-mono, ui-monospace, SFMono-Regular, monospace)' |
| log-panel-016 | must-apply-cell-strong-weight | cell={strong:true} | fontWeight is 600 |
| log-panel-017 | must-apply-cell-link-styling | cell={link:true} | CSS class 'lp-cell--link' is present |
| log-panel-018 | must-show-interactive-indicator | column={onCellClick: () => {}}, cell | CSS class 'lp-cell--interactive' is present |
| log-panel-019 | must-apply-cell-title-attribute | cell={text:'Error message'} | title attribute on cell div is 'Error message' |
| log-panel-020 | must-support-max-height | maxHeight='500px' | Body container has CSS maxHeight: '500px' |
| log-panel-021 | must-support-custom-class | className='custom-log' | Root container has class 'lp-root custom-log' |
| log-panel-022 | must-apply-grid-layout | columns with widths=[200, '1fr', 100] | gridTemplateColumns is '200px 1fr 100px' on both header and rows |
| log-panel-023 | must-include-aria-roles | Standard render | Header has role='row', columns have role='columnheader', rows have role='row', cells have role='cell', rows list has role='rowgroup' |
| log-panel-024 | must-stop-event-propagation | Click/double-click on cell | stopPropagation() called on event |

## Edge Cases

- **Empty columns array**: If `columns` is an empty array, the component renders a header (if showHeader=true) with no cells and a body with no visible cells. Rows exist but display no content.
- **Empty lines array**: Component displays the empty message instead of rows; no error occurs.
- **maxLines less than visible rows**: Component retains only the last `maxLines` entries; older entries are completely removed from the visible set.
- **maxLines equals 0**: Component displays no rows (visible.length becomes 0); empty message is shown.
- **maxLines is undefined or not a number**: Component displays all lines without truncation.
- **Undefined cell values**: normalize() returns `{text: ''}` for undefined values; empty cells are rendered without error.
- **String cell values**: normalize() converts string values to `{text: value}`, applying default appearance only.
- **Column width as string**: trackSize() returns the string directly (e.g., '1fr', '50%') as the grid track size.
- **Column width as number**: trackSize() returns `${width}px` (e.g., 200 becomes '200px').
- **Column width undefined**: trackSize() returns default 'minmax(120px, 1fr)'.
- **followTail flips from false to true**: useEffect resets pinnedRef to true so the next append snaps to bottom.
- **scrollerRef is null**: All scroll-related logic is guarded by `if (!el) return`; no errors occur.
- **New lines added while scrolled up**: pinnedRef remains false; component does not auto-scroll until slack condition is met.
- **Very long cell text**: Cell displays full text with title attribute for tooltip; no truncation or overflow behavior is enforced by the component (stylesheet responsibility).
- **Special characters or HTML in cell text**: Cell text is rendered as plain text via textContent equivalent; no HTML parsing occurs.
- **Large maxLines value**: No performance check in component; rendering many rows is deferred to stylesheet/browser rendering performance.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| columns | LogColumn[] | (required) | Array of column definitions, each with id, title, and optional width, align, defaultLevel, defaultMono, isClickable, onCellClick, onCellDoubleClick |
| lines | LogLine[] | (required) | Array of log line entries, each with id and values object keyed by column id |
| followTail | boolean | true | Automatically scroll to bottom when new lines are added |
| maxLines | number \| undefined | undefined | Maximum number of visible rows; older rows are discarded when limit is exceeded |
| emptyMessage | string | "(no events)" | Message displayed when no rows are visible |
| showHeader | boolean | true | Display column header row |
| className | string | undefined | Additional CSS class(es) to apply to the root container |
| maxHeight | string \| number \| undefined | undefined | CSS max-height value for the scrollable body container |

## Deep Linking

Not applicable: Log Panel is a data display component without URL-based navigation or deep linking support.

## Localization

Not applicable: The component has no UI text other than the `emptyMessage` prop (which is provided by the consumer) and column titles (which are provided in the `columns` prop).

## Accessibility Options

Not applicable: The component does not respond to system accessibility settings like reduced motion or increased contrast. Such behavior, if desired, would be implemented by the consumer via conditional CSS or prop adjustments.

## Feature Flags

Not applicable: The component has no internal feature flags or toggle points.

## Analytics

Not applicable: The component does not emit events or track user interactions; click handlers are delegated to consumers via `onCellClick` and `onCellDoubleClick` callbacks.

## Privacy

Not applicable: The component displays data provided by the consumer; it does not collect, store, or transmit any data independently.

## Logging

Not applicable: The component does not emit logs or diagnostic output.

## Platform Notes

- **React/Web**: The component is implemented in TypeScript/React using hooks (useRef, useEffect, useLayoutEffect, useMemo). It uses CSS Grid for layout and relies on stylesheet rules for visual appearance (colors, spacing, fonts). Key files: LogPanel.tsx, types.ts (defines LogPanelProps, LogLine, LogColumn, LogLevel, LogCellValue). Styling is applied via CSS class names (lp-root, lp-header, lp-body, lp-row, lp-cell, lp-cell--interactive, lp-cell--link, lp-empty) and inline styles for layout (gridTemplateColumns) and level-based colors (LEVEL_VAR). The component communicates interactivity via ARIA roles and data attributes.

- **SwiftUI**: Implement as a SwiftUI view using List or ScrollView with LazyVStack for rows. Use @State for scroll offset tracking and pinning logic. Apply Text or HStack cells with font and color modifiers matching the log level. Use .onTapGesture or Button for clickable cells. Implement scroll detection via ScrollViewReader and onChange closure to detect when the user scrolls away from the bottom.

- **Compose**: Implement as a Composable using LazyColumn for virtualized row rendering. Track scroll offset via rememberLazyListState() and use LazyListState.isScrolledToTheEnd() to implement follow-tail logic. Apply Text and Row composables for cells with color and font styles. Use clickable modifier for interactive cells. Map log levels to Material 3 color palette.

- **AppKit/UIKit**: Implement as a UITableView (UITableViewController) or NSTableView with dynamic row height. Use NSTableColumn or UITableViewColumn to represent columns. Implement scroll tracking via UIScrollViewDelegate (scrollViewDidScroll:) to detect pinning. Apply NSAttributedString or UIFont with colors matching the log level. Use UITableViewDelegate for tap and double-tap handling. For accessibility, set accessibilityRole to .cell and accessibilityLabel to the cell text content.

- **WinUI 3**: Implement as a DataGrid or a custom ListView with Grid layout. Use WinUI's DataGridColumn for columns with configurable width and alignment. Bind ItemsSource to the rows collection; use INotifyCollectionChanged to trigger follow-tail scrolling via ScrollViewer.ChangeView(). Apply Brush colors from the log level color mapping. Use Tapped and DoubleTapped events for cell interactions. Use AutomationProperties.Name for ARIA-like labeling. For monospace font, use SymbolThemeFontFamily or a system monospace font family.

## Design Decisions

- **Follow-tail default enabled**: The default behavior is to scroll to the bottom when new lines arrive (`followTail: true`). This is appropriate for real-time log inspection but can be disabled by consumers who wish to preserve the user's scroll position.
- **4-pixel slack for pinning detection**: The scroll detection uses a 4-pixel slack (`const slack = 4`) rather than strict equality to account for rounding errors and sub-pixel rendering. This threshold was chosen to balance user intent (scrolled near the bottom) with responsiveness.
- **Visible rows computed via useMemo**: The visible row set is memoized by `[lines, maxLines]` to avoid recomputing the slice on every render. This optimization assumes that `lines` and `maxLines` are the only factors affecting visibility.
- **Level-based colors via CSS variables**: Colors are applied through CSS variables with fallbacks, allowing consumers to override log level colors at the stylesheet level without modifying the component code. This is more flexible than hard-coded color values.
- **Title attribute for cell tooltips**: Rather than rendering a separate tooltip element, the component uses the HTML `title` attribute to provide accessible text. This relies on native browser tooltip behavior and requires no additional markup.
- **Grid-based layout over table elements**: The component uses semantic HTML roles (row, columnheader, cell) but does not use HTML `<table>`, `<thead>`, `<tbody>` elements. This allows CSS Grid to handle the layout while maintaining accessibility roles for assistive technology.
- **Event propagation stopped at the cell level**: Click and double-click events are stopped at the cell to prevent bubbling to parent elements, ensuring that cell callbacks are the only handlers invoked.
- **Null/empty string normalization**: Undefined cell values are normalized to empty strings (`{text: ''}`), ensuring no rendering errors when a row is missing values for a column.

## Compliance

Not applicable: The component is a UI display component without security, authentication, or compliance-specific requirements. Compliance concerns (WCAG accessibility, data privacy) are delegated to the consumer's stylesheet and data-handling layer.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.1.0 | 2026-09-22 | Mike Fullerton | Revise accessibility guidance; clarify keyboard navigation gap and tap target responsibility |
| 1.0.0 | 2026-09-22 | | Initial creation |
