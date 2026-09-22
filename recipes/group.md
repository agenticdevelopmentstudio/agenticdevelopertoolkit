---
id: c9bdfe9a-6c8f-44c4-957e-757ecfa2e658
title: Group
domain: agenticdevelopercookbook://ingredients/group
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A semantic section component that groups related content with optional title
  and hint.
platforms:
- typescript
- web
tags:
- layout
- grouping
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Group

## Overview

The Group component is a semantic section wrapper for organizing related content. It renders a `<section>` element and optionally displays a title as an h3 heading and a hint as descriptive text, with arbitrary children rendered in a body container. Group is a purely presentational component—it has no interactive states, does not respond to user input, and exists to structure and semantically mark content.

## Behavioral Requirements

- **must-render-section-element**: Component MUST render a `<section>` HTML element as its root.
- **must-render-title-when-provided**: When a `title` prop is provided, component MUST render it inside an `<h3>` element with the class `aws-group__title`.
- **must-not-render-title-when-omitted**: When the `title` prop is not provided or is falsy, component MUST NOT render a title element.
- **must-render-hint-when-provided**: When a `hint` prop is provided, component MUST render it inside a `<p>` element with the class `aws-group__hint`.
- **must-not-render-hint-when-omitted**: When the `hint` prop is not provided or is falsy, component MUST NOT render a hint element.
- **must-render-children-in-body**: Children content MUST be rendered inside a `<div>` element with the class `aws-group__body`.
- **must-apply-base-class**: Component MUST apply the class `aws-group` to the root `<section>` element.
- **must-accept-custom-class**: Component MUST accept a `className` prop and apply it to the root element, combined with the base class.
- **must-filter-empty-classes**: When combining classes, empty or falsy class values MUST be filtered out before joining.

## Appearance

- **Corner radius**: None (depends on CSS styling)
- **Padding**: Determined by CSS classes `aws-group`, `aws-group__title`, `aws-group__hint`, `aws-group__body`
- **Font**: Title renders as `<h3>` (semantic heading); hint renders as `<p>` (semantic paragraph); styling determined by CSS
- **Background**: Not specified in component; controlled by CSS
- **Foreground/Text**: Not specified in component; controlled by CSS
- **Border**: Not specified in component; controlled by CSS
- **Shadow**: Not specified in component; controlled by CSS
- **Min/Max size**: No constraints defined in component

## States

Not applicable: Group is a static, presentational component. It does not have interactive states such as pressed, focused, disabled, or loading. State changes are managed by the content rendered within its children.

## Accessibility

- **Role/trait**: The root element is a semantic `<section>`, which establishes a content section in the document outline.
- **Title heading**: When rendered, the title element is an `<h3>` heading, which contributes to page structure and screenreader navigation.
- **Hint text**: The hint is rendered as a `<p>` paragraph and is exposed to assistive technology.
- **No ARIA required**: Group does not require explicit ARIA attributes because it relies on semantic HTML. Screenreaders will announce the section, heading, and paragraph elements according to platform conventions.
- **Content accessibility**: Accessibility of Group content depends on the accessibility of its children. Group does not modify or wrap child content in ways that would degrade accessibility.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| group-001 | must-render-section-element | Render with default props | Root element is `<section>` with class `aws-group` |
| group-002 | must-render-title-when-provided | `title="My Title"` | Renders `<h3 class="aws-group__title">My Title</h3>` |
| group-003 | must-not-render-title-when-omitted | No title prop | No h3 element present |
| group-004 | must-render-hint-when-provided | `hint="Descriptive text"` | Renders `<p class="aws-group__hint">Descriptive text</p>` |
| group-005 | must-not-render-hint-when-omitted | No hint prop | No p element present |
| group-006 | must-render-children-in-body | `children="Content"` | Renders `<div class="aws-group__body">Content</div>` |
| group-007 | must-apply-base-class | Default render | Root element has class `aws-group` |
| group-008 | must-accept-custom-class | `className="custom-class"` | Root element has both `aws-group` and `custom-class` |
| group-009 | must-filter-empty-classes | `className=""` (empty string) | Root element renders only `aws-group`, empty string filtered out |
| group-010 | must-render-title-when-provided, must-render-hint-when-provided, must-render-children-in-body | `title="Title" hint="Hint" children="Body"` | All three elements rendered in correct order: h3, p, div |

## Edge Cases

- **Null title**: When `title` is `null` or `undefined`, the component treats it as falsy and does not render a title element.
- **Empty title**: When `title` is an empty string `""`, it is falsy and does not render a title element.
- **Falsy hint**: When `hint` is `null`, `undefined`, `false`, `0`, or empty string `""`, the component does not render a hint element.
- **No children**: When `children` is not provided, `undefined`, or `null`, the body div is rendered empty but still present.
- **React node children**: The `title`, `hint`, and `children` props accept `ReactNode`, which may be strings, numbers, elements, fragments, arrays, or null. All valid React node types MUST render correctly.
- **Multiple children**: When `children` is an array (list of React elements), all items MUST render within the body div without modification.
- **Custom className combinations**: When `className` contains multiple space-separated classes, all MUST be preserved and applied to the root element.
- **Null/empty custom className**: When `className` is `null`, `undefined`, or empty string `""`, it MUST be filtered out and not added to the element.

## Configuration

Not applicable: Group has no configuration options beyond its props. It does not expose settings, feature toggles, or runtime configuration.

## Deep Linking

Not applicable: Group is a presentational component with no navigation or deep-linking concerns. Deep linking is managed by the consuming application.

## Localization

Not applicable: Group does not render any static text or UI strings of its own. All user-facing text—title, hint, and children content—is provided by the parent component and may be localized by the application.

## Accessibility Options

Not applicable: Group does not respond to platform accessibility display options such as Reduce Motion or Increase Contrast. It relies on CSS styling controlled by the application theme.

## Feature Flags

Not applicable: Group has no feature flags. It is always enabled and has no conditional rendering based on runtime configuration.

## Analytics

Not applicable: Group is a presentational component and does not emit analytics events. Analytic instrumentation is the responsibility of parent components that use Group.

## Privacy

Not applicable: Group does not collect, store, or transmit any data. It is a stateless presentation layer.

## Logging

Not applicable: Group does not perform any logging. It is a purely presentational component.

## Platform Notes

- **React/Web**: Source file is `packages/web/packages/controls/src/user-settings/components/Group.tsx`. Renders a semantic `<section>` with class `aws-group`. Optional title and hint render as `<h3 class="aws-group__title">` and `<p class="aws-group__hint">`. Children render in `<div class="aws-group__body">`. Supports custom `className` prop merged with base class. Styling is CSS-driven via class names; no inline styles.
- **SwiftUI**: Start with a `VStack` or `Section` (if supported) to group content vertically. Render an optional `Text` for title styled as a heading, an optional text caption for hint, and arrange child views below. Differences from web: SwiftUI uses `Section` for semantic grouping instead of `<section>`, text styling is controlled by font modifiers rather than CSS, and layout is vertical-first.
- **Compose**: Use a `Column` or `Surface` to group content. Render optional `Text` for title with heading style, optional text for hint, and render child composables. Differences: Compose lacks a direct semantic grouping equivalent; use container composition. Layout is column-based. Styling via Material Design tokens.
- **AppKit / UIKit**: Use `NSStackView` (AppKit) or `UIStackView` (UIKit) to group views. Render optional `NSTextField` / `UILabel` for title with heading style, optional text field for hint, and arrange subviews. Differences: Use native stack views for layout; no CSS classes. Accessibility comes from native accessibility APIs on each view.
- **WinUI 3**: Use `StackPanel` with `Orientation="Vertical"` as the root to group content. Render optional `TextBlock` for title with `Style="{StaticResource HeadingTextBlockStyle}"` or similar, optional `TextBlock` for hint text. Place child `UIElement` instances in the stack panel. Differences: WinUI uses XAML-defined brushes and styles instead of CSS classes; layout is managed by `StackPanel` properties like `Spacing`; semantic grouping is implicit via panel composition rather than a `<section>` element.

## Design Decisions

Group is a minimal, semantically-correct wrapper for grouping content. It does not impose visual styling—all appearance is controlled by CSS. This keeps the component flexible and reusable across different design contexts. The base class `aws-group` and sub-classes (`__title`, `__hint`, `__body`) follow BEM naming to make styling clear and maintainable. The component accepts and merges custom `className` props to allow consumers to apply additional styling without reimplementing the component.

## Compliance

Not applicable: Group is a foundational layout component that does not involve sensitive data, network requests, complex state, or platform-specific permissions. Compliance checks would be performed at the application level, not at the component level.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation from web source |
