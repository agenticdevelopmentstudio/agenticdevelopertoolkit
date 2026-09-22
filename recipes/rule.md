---
id: 4cd07922-a00d-4029-8cb5-2307463129cc
title: Rule
domain: agenticdevelopercookbook://ingredients/rule
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Renders a definition list of term-detail pairs, typically for displaying
  rules or structured text-based content.
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

# Rule

## Overview

Rule renders a semantic definition list (`<dl>`) of term-detail pairs. Each pair consists of a term (the label) and a detail (the explanation). The component accepts an array of step objects and renders them in order, delegating all visual styling to CSS. Use this component to display structured textual content such as oversight rules, definitions, guidelines, or any term-definition pattern where the source material is genuine text, not a screenshot.

## Behavioral Requirements

- **must-accept-steps-array**: Component MUST accept a `steps` prop containing an array of `RuleStep` objects.
- **must-render-steps-in-order**: Component MUST render steps in the order provided in the array.
- **must-render-term-and-detail**: Each step MUST render both a `term` and a `detail` from the `RuleStep` object.
- **must-accept-react-nodes**: The `term` and `detail` fields MUST accept `ReactNode` values (strings, React elements, fragments, or other valid React content).
- **must-use-semantic-markup**: Component MUST render as a `<dl>` (definition list) element containing `<dt>` (term) and `<dd>` (detail) child elements.
- **must-apply-lp-rule-class**: Component MUST apply the CSS class `lp-rule` to the root `<dl>` element.

## Appearance

- **CSS class**: `lp-rule` applied to the root `<dl>` element; all visual styling is delegated to external CSS.
- **Semantic structure**: Markup uses `<dl>`, `<dt>`, and `<dd>` elements; appearance is determined by CSS, not the component.
- **No inline styles**: Component applies no inline styles or className overrides beyond the `lp-rule` class.

## States

Not applicable: Rule is a static, non-interactive component and has no state variations (default, pressed, disabled, focused, loading, etc.).

## Accessibility

- **Semantic markup**: The component uses the semantic `<dl>`, `<dt>`, and `<dd>` elements, which are properly interpreted by screen readers as a definition list structure.
- **Content accessibility**: The accessibility of the term and detail content depends on what is passed as `ReactNode` values. If terms and details contain text, they are announced by screen readers. If they contain interactive elements or images, those elements' own accessibility properties apply.
- **No labels or roles required**: The component itself requires no additional ARIA attributes, roles, or labels; semantic HTML provides sufficient structure.
- **Minimum tap target**: Not applicable — Rule contains no interactive controls and thus no touch targets.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|----|----|----|
| rule-001 | must-accept-steps-array, must-render-steps-in-order | `steps={[{term: "A", detail: "First"}, {term: "B", detail: "Second"}]}` | Component renders without error; DOM contains two `<dt>` and two `<dd>` elements in order |
| rule-002 | must-render-term-and-detail, must-accept-react-nodes | `steps={[{term: <strong>Bold</strong>, detail: <em>Italic</em>}]}` | Component renders the React elements correctly; both `<strong>` and `<em>` appear in the DOM |
| rule-003 | must-use-semantic-markup | Any valid steps array | Root element is `<dl>`; direct children are `<dt>` and `<dd>` elements |
| rule-004 | must-apply-lp-rule-class | Any valid steps array | Root `<dl>` element has the class `lp-rule` |
| rule-005 | must-accept-steps-array | `steps={[]}` | Component renders an empty `<dl>` element without error |

## Edge Cases

- **Empty steps array**: When `steps` is an empty array, the component MUST render an empty `<dl>` element (no child elements).
- **Single step**: When `steps` contains one step, the component MUST render one `<dt>` and one `<dd>` pair.
- **Large step arrays**: The component MUST handle arrays with many steps (100+) without performance degradation; rendering is linear in the number of steps.
- **Null or undefined steps**: `steps` is a required `RuleStep[]` prop, so the type contract excludes `null` and `undefined` and the component adds no runtime guard. A translation with a weaker type system (or one accepting untyped JSON) MUST treat a missing array as empty rather than crash.
- **Null or undefined term/detail**: If a step's `term` or `detail` is `null` or `undefined`, React renders nothing for that content; the corresponding `<dt>` or `<dd>` element is rendered but empty.
- **Non-ReactNode values**: If a non-ReactNode value (e.g., a number, boolean, object) is passed as `term` or `detail`, React will throw an error or render unexpectedly depending on the type.

## Configuration

Not applicable: Rule accepts only the `steps` prop with no configuration options or optional settings.

## Deep Linking

Not applicable: Rule is a static presentational component with no navigation or deep-link capability.

## Localization

Not applicable: Rule contains no hardcoded strings; all text content is passed via the `term` and `detail` fields of the steps array.

## Accessibility Options

- **Reduce Motion**: Not applicable — Rule is a static component with no animation or motion; Reduce Motion preferences do not apply.
- **Increase Contrast**: Not applicable — Rule applies no colors or contrast logic; visual appearance is entirely determined by external CSS.
- **Differentiate Without Color**: Not applicable — Rule applies no color-based distinctions; styling is external.

## Feature Flags

Not applicable: Rule contains no feature-flag logic or conditionally gated behavior.

## Analytics

Not applicable: Rule contains no analytics tracking, event firing, or instrumentation.

## Privacy

Not applicable: Rule collects, transmits, and stores no data.

## Logging

Not applicable: Rule performs no logging or debug output.

## Platform Notes

- **TypeScript / React (Web)**: The source is a functional React component (`Rule`) exported from `packages/web/packages/landing/src/blocks/Rule.tsx`. It accepts a single prop `{ steps: RuleStep[] }`, where `RuleStep` is an interface with `term: ReactNode` and `detail: ReactNode` fields. The component renders a `<dl>` element with class `lp-rule` and maps over the steps array to render each step as a `<dt>` (term) and `<dd>` (detail) pair. Styling is applied via the `lp-rule` CSS class.

- **SwiftUI**: Implement using a `List` with sections or a `VStack` of custom row views. Each row contains two `Text` (or more generally, `View`) elements laid out vertically or horizontally according to the design. Use semantic font weights and spacing to distinguish the term (label) from the detail (explanation). Map over the steps array and render a row for each step.

- **Compose (Kotlin)**: Use a `Column` or `LazyColumn` for a scrollable list of steps. For each step, render a row layout (e.g., `Row` or `Column`) containing the term and detail `Text` (or composable content). Apply the appropriate typography and spacing via `Text(text = step.term, ...)` and `Text(text = step.detail, ...)`. If steps become large, use `LazyColumn` to defer rendering.

- **AppKit / UIKit**: On macOS, implement using `NSTableView` or a custom `NSStackView` layout. On iOS, use `UITableViewController` with custom `UITableViewCell` subclasses that contain labels for term and detail. Bind the steps array as a data source and update the view when steps change. Ensure sufficient vertical spacing between rows for readability.

- **WinUI 3**: Implement using `ItemsControl` bound to the steps array. For each step, define a `DataTemplate` with a `StackPanel` (vertical orientation) or `Grid` containing `TextBlock` elements for the term and detail. Bind the `TextBlock.Text` properties to the corresponding `RuleStep` fields. Apply margin, padding, and font properties via `TextBlock.Margin` and `TextBlock.FontSize` to match the design language.

## Design Decisions

- **Semantic HTML over generic divs**: The component uses `<dl>`, `<dt>`, and `<dd>` elements to leverage semantic HTML and provide out-of-the-box accessibility for screen readers and assistive technology.
- **ReactNode flexibility**: The `term` and `detail` fields accept `ReactNode` to allow consumers to pass not just text but also styled elements, images, links, or other React components. This trades compile-time type safety (no per-field validation) for runtime flexibility.
- **CSS delegation**: All visual styling is delegated to the `lp-rule` CSS class. The component applies no inline styles, colors, fonts, or sizes. This keeps the component pure and styling concerns in the stylesheet.
- **No prop validation or guards**: The component does not validate the `steps` prop or guard against null, undefined, or malformed input. Consumers are responsible for ensuring `steps` is a valid array of `RuleStep` objects.

## Compliance

Not applicable: Rule is a semantic HTML component that conforms to W3C standards for definition lists (`<dl>`, `<dt>`, `<dd>`).

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation from source code |
