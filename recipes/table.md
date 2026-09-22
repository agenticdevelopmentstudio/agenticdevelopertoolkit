---
id: b0ce8cbb-31ac-425a-889c-68e699d24578
title: Table
domain: agenticdevelopercookbook://ingredients/table
type: ingredient
version: 1.0.0
status: review
language: en
created: 2026-09-22
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A semantic table for displaying rows of data under labeled columns, with
  a required caption identifying the data and optional visual caption display.
platforms:
- typescript
- web
tags: []
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Table

## Overview

A data-presentation component that renders HTML semantic table structure with labeled columns, data rows, and a required caption. The caption is always provided but visually hidden by default to avoid redundancy with surrounding prose while remaining available to screen readers. Rows are validated at render time to ensure they match the column count, preventing silent misalignment of cells into wrong columns.

## Behavioral Requirements

- **must-accept-caption**: Component MUST accept a required `caption` prop (ReactNode) that identifies the data population represented by the table rows.
- **must-validate-row-width**: Component MUST throw an error if any row has a length that does not match the `columns` array length, reporting the offending row index and cell counts.
- **must-render-caption-hidden**: Component MUST render the caption element and hide it from visual display by default (via `lp-sr-only` class), ensuring screen reader access to the caption.
- **must-provide-visual-caption-option**: Component MUST accept an optional `showCaption` boolean prop that, when true, renders the caption visibly on the page (removing the `lp-sr-only` class).
- **must-render-thead-with-scope**: Component MUST render a `<thead>` containing a single row of column headers, each wrapped in a `<th>` element with `scope="col"` attribute.
- **must-render-tbody**: Component MUST render a `<tbody>` containing one row per entry in the `rows` prop, with each cell rendered as a `<td>` element.
- **must-accept-columns-array**: Component MUST accept a required `columns` array prop (ReactNode[]) that defines the header labels and establishes the table width.
- **must-accept-rows-array**: Component MUST accept a required `rows` array prop (ReactNode[][]) that defines the data cells, organized as rows.
- **must-wrap-with-scroll-container**: Component MUST wrap the table in a div element with class `lp-table-scroll` to enable horizontal scrolling on narrow viewports.
- **must-apply-table-class**: Component MUST apply the `lp-table` class to the `<table>` element.

## Appearance

- **Container**: Div wrapper with class `lp-table-scroll` provides horizontal scroll context.
- **Table**: `<table>` element with class `lp-table`.
- **Headers**: `<th>` elements within `<thead>` render column labels (ReactNode content).
- **Cells**: `<td>` elements within `<tbody>` render row data (ReactNode content).
- **Caption**: `<caption>` element; visually hidden via `lp-sr-only` class unless `showCaption` is true.

Not applicable: Styling (font, color, spacing, shadows) is defined via CSS classes and is not specified by the component.

## States

Not applicable: This component is a static data container with no interactive or loading states. It either renders successfully or throws a validation error at render time.

## Accessibility

- **Semantic table structure**: Component uses native `<table>`, `<thead>`, `<tbody>`, `<th>`, `<td>`, and `<caption>` elements, providing structural semantics to assistive technology.
- **Column headers**: Each column header in `<th>` has `scope="col"` attribute, associating cells with their column.
- **Caption requirement**: The caption prop is required and always rendered, ensuring screen readers announce what data the table represents.
- **Caption visibility toggle**: The `showCaption` prop allows the caption to be displayed visually when the surrounding context does not already identify the table's purpose.
- **Screen reader only class**: The `lp-sr-only` class hides the caption from sighted users by default while preserving it for screen readers.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| table-001 | must-accept-caption, must-accept-columns-array, must-accept-rows-array | `caption="Run Results"`, `columns=["Date", "Status"]`, `rows=[["2026-09-22", "Pass"], ["2026-09-21", "Fail"]]` | Table renders with caption "Run Results" hidden from visual display and two rows of data |
| table-002 | must-render-thead-with-scope | `columns=["Name", "Role"]` | `<thead>` contains `<tr>` with two `<th scope="col">` elements containing "Name" and "Role" respectively |
| table-003 | must-render-tbody | `rows=[["Alice", "Engineer"], ["Bob", "Designer"]]` | `<tbody>` contains two `<tr>` elements, each with two `<td>` elements containing the correct data |
| table-004 | must-validate-row-width | `columns=["A", "B"]`, `rows=[["1", "2"], ["3"]]` (second row has 1 cell, columns has 2) | Component throws error: `Table: row 1 has 1 cells but there are 2 columns` |
| table-005 | must-render-caption-hidden | `caption="Revenue"`, `showCaption` not provided or false | Caption element renders with `class="lp-sr-only"` |
| table-006 | must-provide-visual-caption-option | `caption="Revenue"`, `showCaption={true}` | Caption element renders without `lp-sr-only` class and is visible on page |
| table-007 | must-wrap-with-scroll-container, must-apply-table-class | Any valid input | Outermost div has `class="lp-table-scroll"`, inner table has `class="lp-table"` |
| table-008 | must-validate-row-width | `columns=["X", "Y", "Z"]`, `rows=[["1", "2", "3"]]` (row length matches) | No error is thrown; row renders correctly |

## Edge Cases

- **Empty columns array**: If `columns` is an empty array, the table renders with no header cells and no validation error on rows (rows must also be empty or each row must have zero cells). MUST render without error if rows are also empty; throws error if rows contain non-empty sub-arrays.
- **Empty rows array**: If `rows` is an empty array, the table renders with headers but no body rows. MUST render without error.
- **Null or undefined cells**: If a cell value is `null`, `undefined`, or a falsy ReactNode, it renders as an empty cell. MUST render without error and display the cell visually empty.
- **ReactNode content in cells**: Cells accept ReactNode values (strings, numbers, React elements, fragments). MUST render without error regardless of ReactNode type.
- **First row validation triggers for all rows**: The error check finds the first mismatched row and reports its index. MUST report the row that is incorrect, not assume only the first row is valid.

## Configuration

Not applicable: This component takes only required props (`caption`, `columns`, `rows`) and an optional boolean (`showCaption`). No additional configuration options are provided.

## Deep Linking

Not applicable: This component is a data presentation element used within a page and does not define its own deep linking behavior.

## Localization

Not applicable: The component itself does not emit any static strings; all text content (column headers, cell values, caption) is provided by the caller via props. Localization is the caller's responsibility.

## Accessibility Options

- **Reduce Motion**: Not applicable. This component does not animate; static layout requires no motion reduction.
- **Increase Contrast**: Not applicable. Text and background contrast is controlled by the CSS classes (`lp-table`, `lp-sr-only`) and is not a component responsibility.
- **Differentiate Without Color**: Not applicable. The component does not use color as the sole means of distinction; it relies on semantic HTML structure and cell content.

## Feature Flags

Not applicable: This component provides no feature flags or conditional behavior based on feature toggles.

## Analytics

Not applicable: This component is a static data container and does not emit events or analytics data.

## Privacy

Not applicable: The component does not collect, store, or transmit data. It renders data provided by the caller.

## Logging

Not applicable: The component logs a validation error to the console (via `throw new Error`) when a row width mismatch is detected, but this is a runtime error, not a structured logging interface.

## Platform Notes

- **React/Web**: Defined in `packages/web/packages/landing/src/blocks/Table.tsx`. Uses native HTML `<table>`, `<thead>`, `<tbody>`, `<th>`, `<td>`, `<caption>` elements with CSS classes `lp-table`, `lp-table-scroll`, and `lp-sr-only` for styling and screen-reader-only visibility. Row width validation occurs at render time and throws an error if mismatched.
- **SwiftUI**: Start with a SwiftUI `Table` (iOS 16.4+) or a custom list-based layout using `List` and `HStack` to simulate columns. Render column headers via a custom header row view. Implement row width validation in a computed property or during data initialization, throwing an error or logging a warning if row counts mismatch column count. Use `AccessibilityLabel` and `AccessibilityElement` to associate cells with column headers.
- **Compose**: Use `LazyColumn` to render rows and `Row` (or `HorizontalScrollableComposable`) for each row's cells. Define column widths using `Modifier.weight()` or fixed widths. Render column headers as a sticky header row at the top. Implement row width validation in a `LaunchedEffect` or during data initialization. Use `contentDescription` and `semantics` to associate cells with columns.
- **AppKit / UIKit**: Use `UITableViewController` (UIKit) or `NSTableView` (AppKit) for table rendering. Implement `UITableViewDataSource` methods to provide column headers and row data. AppKit's `NSTableView` offers native column-header support via `NSTableColumn` objects. Validate row widths in the datasource initialization or in a precondition check before rendering. Use `UIAccessibility` labels to associate cells with column scope information.
- **WinUI 3**: Use `Microsoft.UI.Xaml.Controls.DataGrid` or construct a custom table using `Grid` with `ColumnDefinition` elements for column headers and rows of `TextBlock` elements for cells. Bind column count to the GridDefinitions collection and validate row counts in the view model or code-behind. Set `AutomationProperties.Name` on the container and `ColumnHeadersHeightProperty` to ensure headers are announced by screen readers. For narrow viewports, implement horizontal scrolling using `ScrollViewer` with `HorizontalScrollBarVisibility="Auto"`.

## Design Decisions

The caption is required and always rendered because it is the only element that identifies the data population the table represents. Omitting it silently risks presenting a partial sample (e.g., three of ten runs) as complete, misleading readers. The default visual hiding preserves the caption's accessibility benefit while allowing callers to avoid redundancy with surrounding prose. When surrounding context already identifies the table's purpose, `showCaption={false}` is the default; when the caption adds necessary context, `showCaption={true}` makes it visible.

Row width validation occurs at render time and throws a synchronous error. This fail-fast behavior prevents silent data misalignment (the kind that reads as a typo rather than a bug) and makes the error obvious during development. A validation framework could instead return a validation result prop; this implementation prioritizes immediate visibility over graceful error recovery.

The component uses semantic HTML (`<table>`, `<th scope="col">`, `<caption>`) to delegate accessibility responsibility to browser defaults rather than requiring custom ARIA roles. This approach reduces implementation burden and aligns with platform-design guidance on semantic HTML over custom accessibility markup.

## Compliance

Not applicable: Compliance checks are deferred to the hosting context and CSS framework. The component itself emits no data, makes no external requests, and imposes no cross-cutting compliance requirements beyond semantic HTML structure.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
