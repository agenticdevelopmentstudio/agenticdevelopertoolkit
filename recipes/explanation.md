---
id: eeb45f5b-e482-4bea-8827-74f80a1fd21b
title: Explanation
domain: agenticdevelopercookbook://ingredients/explanation
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A semantic paragraph wrapper that applies a default style class and accepts
  optional additional CSS classes.
platforms:
- web
tags:
- text
- typography
- container
depends-on: []
related: []
references: []
---

# Explanation

## Overview

The Explanation component renders explanatory or descriptive text within a semantic paragraph element. It provides a consistent, styled wrapper for text content by applying a default CSS class (`aws-explanation`) and allows consumers to add supplementary styles via an optional `className` prop. This component is used to present contextual information, help text, or clarifying descriptions in user interfaces.

## Behavioral Requirements

- **must-render-paragraph**: Component MUST render a `<p>` HTML element.
- **must-apply-default-class**: Component MUST apply the class name `aws-explanation` to the rendered element.
- **must-render-children**: Component MUST render all provided `children` content inside the paragraph element.
- **must-accept-optional-classname**: Component MAY accept an optional `className` prop.
- **must-combine-classnames**: Component MUST combine the default class name with the optional `className` prop, separated by a space, if `className` is provided.
- **must-filter-falsy-classnames**: Component MUST filter out falsy or empty class name values before rendering to prevent invalid class attributes.

## Appearance

Visual styling is determined entirely by CSS classes applied to the element. The component applies:

- **Default class**: `aws-explanation` (from AWS Amplify UI design system)
- **Custom classes**: Additional classes from the `className` prop are applied alongside the default

Appearance properties such as font size, color, line-height, and spacing are defined in the CSS stylesheet referenced by the `aws-explanation` class.

## States

Not applicable: Explanation is a non-interactive presentational component and does not have interactive states such as pressed, focused, or disabled.

## Accessibility

- **Semantic element**: Component MUST use the `<p>` element to maintain semantic meaning for screen readers and document structure.
- **Content accessibility**: Text content rendered as children inherits the default font properties defined by the `aws-explanation` class, which SHOULD meet WCAG 2.1 AA contrast requirements as defined by the AWS Amplify UI design system.
- **Label inheritance**: The paragraph element does not require an explicit label; the rendered text content serves as the semantic label.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| explanation-001 | must-render-paragraph | `<Explanation>Hello</Explanation>` | Renders as `<p class="aws-explanation">Hello</p>` |
| explanation-002 | must-apply-default-class | Any props | Rendered element contains class `aws-explanation` |
| explanation-003 | must-render-children | `<Explanation>Text content</Explanation>` | Text content appears inside the paragraph |
| explanation-004 | must-accept-optional-classname | `<Explanation className="custom-class">Text</Explanation>` | Rendered element has both `aws-explanation` and `custom-class` |
| explanation-005 | must-combine-classnames | `<Explanation className="extra">Content</Explanation>` | Rendered class attribute is `"aws-explanation extra"` |
| explanation-006 | must-filter-falsy-classnames | `<Explanation className="">Text</Explanation>` | Rendered class attribute is `"aws-explanation"` (empty string filtered out) |
| explanation-007 | must-render-children | `<Explanation><span>Rich</span> content</Explanation>` | React children (including JSX elements) render correctly inside paragraph |

## Edge Cases

- **Null or undefined children**: Component MUST render an empty paragraph element with class `aws-explanation` when children is null or undefined.
- **Empty children**: Component MUST render an empty paragraph element with class `aws-explanation` when children is an empty string or empty array.
- **Undefined className**: Component MUST treat undefined `className` as absent and render only the default class name.
- **Empty string className**: Component MUST filter out empty string `className` values and render only the default class name.
- **Whitespace-only className**: Component SHOULD filter or trim whitespace-only class names; if whitespace is preserved, resulting class attribute MUST contain the default class followed by whitespace.
- **Multiple spaces in className**: Component MUST preserve spacing between multiple classes provided in the `className` prop (e.g., `"class1 class2"` renders as `"aws-explanation class1 class2"`).
- **False and null className**: Component MUST treat `false` and `null` values for `className` as absent and render only the default class name.

## Configuration

Not applicable: Explanation has no configuration options beyond React props (`children` and `className`).

## Deep Linking

Not applicable: Explanation is a text presentation component and does not participate in deep linking or URL routing.

## Localization

Not applicable: Explanation does not contain hard-coded strings. All text content is provided by consumers via `children`.

## Accessibility Options

Not applicable: Explanation does not respond to platform accessibility display options. It delegates accessible rendering to the semantic `<p>` element and relies on CSS classes to respect user-level accessibility preferences (e.g., `prefers-reduced-motion`).

## Feature Flags

Not applicable: Explanation has no feature flags. It is always available and has no conditional behavior.

## Analytics

Not applicable: Explanation is a presentational component and does not emit analytics events on its own.

## Privacy

Not applicable: Explanation does not collect, store, or transmit any user data. It renders content provided by consumers without side effects.

## Logging

Not applicable: Explanation does not perform logging or error tracking.

## Platform Notes

- **React/Web**: Source implementation uses JSX with TypeScript. Export the `Explanation` function component with `ExplanationProps` interface defining `children?: ReactNode` and `className?: string`. Combine classes using array filter-and-join pattern to handle falsy values. Reference source file: `packages/web/packages/controls/src/user-settings/components/Explanation.tsx`.
- **SwiftUI**: Implement using a `Text` view or `VStack` containing styled text content. Apply a default modifier set (equivalent to `aws-explanation` CSS class) to set font, color, and spacing. Accept an optional `@ViewBuilder` for content and optional modifier overrides. Use SwiftUI's composition model rather than class-based styling.
- **Compose**: Implement using a `Text` composable or a wrapper composable that accepts content as a `@Composable` lambda. Apply Material Design 3 text styling by default and accept optional modifiers. Use Compose's `Modifier` composition to combine default styles with consumer-provided modifications.
- **AppKit / UIKit**: Implement as a `UILabel` (UIKit) or `NSTextField` (AppKit) subclass, or as a view controller that wraps a text view. Apply default typography and color from the platform's design system. Accept optional styling overrides through properties or initializer parameters.
- **WinUI 3**: Implement using a `TextBlock` XAML element with default `Style` applied (equivalent to `aws-explanation`). Define the style in the app's resource dictionary to set `FontSize`, `Foreground`, `FontWeight`, and other properties. Accept optional `Style` property override to layer additional styling. Use XAML data binding to render content from a backing property.

## Design Decisions

- **Class name filtering**: The implementation uses an array filter-and-join pattern to remove falsy class names. This prevents invalid HTML class attributes (e.g., `class="aws-explanation  "` with multiple spaces) while maintaining readability of the implementation.
- **Semantic element choice**: A `<p>` element was chosen to maintain semantic meaning in the document outline and to ensure screen reader compatibility. Alternatives like `<div>` or `<span>` would lose semantic information.
- **Default class name**: The `aws-explanation` class is part of the AWS Amplify UI design system and defines visual consistency across AWS product interfaces. This default is not configurable per instance to maintain design system integrity.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| [semantic-markup](agenticdevelopercookbook://compliance/accessibility#semantic-markup) | passed | Accessibility |
| [contrast-ratio](agenticdevelopercookbook://compliance/accessibility#contrast-ratio) | passed | Accessibility |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | | Initial creation |
