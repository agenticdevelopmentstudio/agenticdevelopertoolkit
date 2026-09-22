---
id: c2f89e6b-6e86-449b-9955-5bb0da929de3
title: Header
domain: agenticdevelopercookbook://ingredients/header
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A semantic heading wrapper that renders an h2 element with optional CSS class
  composition.
platforms:
- typescript
- web
tags:
- heading
- typography
depends-on: []
related: []
references:
- https://developer.mozilla.org/en-US/docs/Web/HTML/Element/h2
- https://www.w3.org/TR/html-aria/
approved-by: ''
approved-date: ''
---

# Header

## Overview

The Header component is a semantic HTML heading wrapper that renders a level-2 heading (`<h2>`) element. It accepts optional content and CSS classes, combining a default `aws-header` class with any user-provided classes. This component is used to display section headings and page subdivisions with proper semantic meaning for accessibility.

## Behavioral Requirements

- **must-render-h2-element**: Component MUST render a semantic `<h2>` HTML element.
- **must-include-aws-header-class**: Component MUST always include the `aws-header` CSS class on the rendered element.
- **must-compose-classname**: Component MUST combine the `aws-header` class with any `className` prop provided, filtering out falsy values before joining.
- **must-render-children**: Component MUST render the content passed via the `children` prop (if any) inside the heading element.
- **should-support-optional-classname**: Component SHOULD accept an optional `className` prop to allow consumer-supplied CSS classes to be applied alongside the default class.
- **may-support-optional-children**: Component MAY accept optional `children` of type `ReactNode` for flexible content.

## Appearance

- **Element type**: `<h2>` semantic heading element
- **Default class**: `aws-header`
- **Class composition**: User-supplied `className` prop is conditionally combined with `aws-header` using a space separator; falsy class names are filtered out
- **Font**: Inherits from parent styling context; specific font weight, size, and color are controlled by CSS class definitions (not the component)
- **Background**: Inherits from parent; no inline styles applied
- **Padding/Margin**: Controlled by CSS classes, not the component
- **Border**: None by default; can be applied via CSS classes
- **Shadow**: None by default; can be applied via CSS classes

## States

| State | Behavior |
|-------|----------|
| Default | Component renders with `aws-header` class and any user-supplied classes; content is visible. |

The Header component is a static, non-interactive element and does not have pressed, disabled, focused, or loading states.

## Accessibility

- **Role**: Implicit `heading` role via native `<h2>` element (heading level 2).
- **Label**: Content passed via `children` prop serves as the heading label; it MUST be meaningful and descriptive of the section it introduces.
- **Semantic structure**: By rendering a native `<h2>` element, the component provides proper outline nesting for screen readers and document outline tools.
- **Announcements**: Screen readers automatically announce this element as a heading at level 2; no additional state announcement is needed.
- **Keyboard navigation**: Not applicable; the component is non-interactive and does not receive focus.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|-------|-------------|-------|----------|
| header-001 | must-render-h2-element | Render `<Header>Test</Header>` | DOM contains `<h2>...</h2>` element. |
| header-002 | must-include-aws-header-class | Render `<Header>Test</Header>` | Rendered `<h2>` has `aws-header` class. |
| header-003 | must-compose-classname | Render `<Header className="custom">Test</Header>` | Rendered `<h2>` has both `aws-header` and `custom` classes. |
| header-004 | must-render-children | Render `<Header><span>Child</span></Header>` | Rendered `<h2>` contains the child element. |
| header-005 | must-compose-classname (filter falsy) | Render `<Header className={null}>Test</Header>` | Rendered `<h2>` has only `aws-header` class; `null` is filtered out. |
| header-006 | must-compose-classname (empty string) | Render `<Header className="">Test</Header>` | Rendered `<h2>` has only `aws-header` class; empty string is filtered out. |

## Edge Cases

- **Null or undefined children**: If `children` is `undefined` or `null`, the heading renders empty but still displays the `<h2>` element with the `aws-header` class. MUST render successfully without error.
- **Empty className**: If `className` is an empty string or `undefined`, only the `aws-header` class is applied. MUST not produce duplicate spaces or malformed class attributes.
- **Multiple className values**: If `className` contains multiple space-separated class names (e.g., `"class1 class2"`), the component MUST preserve all of them when composing with `aws-header`.
- **Special characters in className**: If `className` contains special characters or unusual values, the component MUST pass them through to the DOM without sanitization (delegating to React's default behavior).
- **Non-string children**: If `children` is a React component, element, or other `ReactNode`, the component MUST render it as-is without type checking.

## Configuration

Not applicable: The Header component does not expose configuration options beyond props. All styling is controlled via CSS classes.

## Deep Linking

Not applicable: The Header component is a presentational element without deep linking semantics.

## Localization

Not applicable: The Header component does not render any UI strings of its own. Text content is provided via the `children` prop and is the consumer's responsibility to localize.

## Accessibility Options

Not applicable: The Header component is a static heading and does not respond to platform-specific accessibility display options such as Reduce Motion, Increase Contrast, or Differentiate Without Color.

## Feature Flags

Not applicable: The Header component does not implement feature flags or conditional behavior based on feature flags.

## Analytics

Not applicable: The Header component is non-interactive and does not emit analytics events. If analytics tracking is needed, consumers can instrument their use of the component at a higher level.

## Privacy

Not applicable: The Header component does not collect, store, transmit, or process any user data or sensitive information.

## Logging

Not applicable: The Header component does not perform logging or diagnostic operations.

## Platform Notes

- **React/Web**: Component is implemented in React using JSX, rendering the native `<h2>` HTML element with conditional class composition. Source file: `packages/web/packages/controls/src/user-settings/components/Header.tsx`. The component uses array filter and join pattern to safely compose class names, dropping falsy values.
- **SwiftUI**: Implement using `VStack` or a custom view wrapper around the primary text element with an `.headline` or level-2 font style. Apply equivalent semantic metadata (e.g., accessibility heading trait) to signal to assistive technologies that this is a heading element. Use SwiftUI's view modifiers to apply the equivalent of the `aws-header` class styling.
- **Compose**: Implement using a `Text` composable with `style = HeadingStyle.H2` or equivalent typography preset. Wrap it in a custom composable to encapsulate the default styling and allow class-like composition via modifier chains. Android's Material Design 3 heading semantics map to `HeadlineSmall` or `HeadlineMedium` depending on visual hierarchy needs.
- **AppKit / UIKit**: Implement using `NSTextField` (macOS) or `UILabel` (iOS) with appropriate font weight and size (system font, heading style). Set the `accessibilityTraits` to `.header` (iOS) or equivalent header trait (macOS) to communicate the semantic role to VoiceOver. Apply frame constraints and view modifiers to compose the equivalent of the `aws-header` class styling.
- **WinUI 3**: Implement using `TextBlock` with `FontSize` and `FontWeight` properties set to heading level 2 (typically 18–22pt, semibold). Set `AutomationProperties.AutomationId = "Header"` and `AutomationProperties.HeadingLevel = AutomationHeadingLevel.Level2` for accessibility. Handle class composition via XAML `ControlTemplate` or code-behind template application to layer default `aws-header` styling with caller-supplied styles via `Style` binding.

## Design Decisions

1. **Semantic HTML heading element**: The component renders `<h2>` rather than a generic `<div>` to ensure proper document outline and accessibility. Consumers who need a different heading level should wrap or use a different component; the fixed level-2 choice reflects the component's intended use in specific page contexts.

2. **Fixed `aws-header` class**: The component always includes the `aws-header` class to ensure a consistent baseline of styling. This class is not user-removable because it represents the component's identity; additional classes are composed alongside it to allow customization without losing the base style.

3. **Class composition pattern**: The component uses a simple array-filter-and-join pattern (`['aws-header', className].filter(Boolean).join(' ')`) rather than conditional rendering or CSS-in-JS libraries. This keeps the component lightweight and compatible with plain CSS, CSS Modules, and other styling systems. The filter pattern prevents double spaces when `className` is falsy.

4. **No TypeScript strict children prop**: The `HeaderProps` interface defines `children?: ReactNode`, which permits any React-renderable content including fragments, components, and strings. This flexibility allows the component to be used in many contexts without modification.

## Compliance

Not applicable: The Header component does not fall under a specific compliance audit category. It is a simple presentational element that depends on consumer responsibility for content legality, accessibility of content text, and proper heading hierarchy in the page structure.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
