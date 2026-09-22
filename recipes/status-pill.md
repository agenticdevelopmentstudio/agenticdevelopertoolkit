---
id: ba2377b1-f831-4ef8-bf2c-d8393e5eb2c1
title: Status Pill
domain: agenticdevelopertoolkit://recipes/status-pill
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A small pill-shaped badge displaying a status label, optionally accented
  to highlight a free tier or special status.
platforms:
- typescript
- web
tags:
- status
- badge
- indicator
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Status Pill

## Overview

StatusPill is a presentational component that renders a status label as a small pill-shaped badge. It accepts text content and an optional `free` boolean prop that applies accent styling to highlight a complimentary or special status. The component is commonly used to display shipping status on product cards or to indicate a model provider tier in a chip list.

## Behavioral Requirements

- **must-accept-children**: Component MUST accept and render any ReactNode as children content.
- **must-apply-base-class**: Component MUST apply the CSS class `lp-status` to the root element.
- **must-apply-free-class**: When the `free` prop is explicitly `true`, the component MUST add the CSS class `lp-status--free` to apply accent styling.
- **must-not-apply-free-class-by-default**: When the `free` prop is absent or falsy, the component MUST NOT apply the `lp-status--free` class.

## Appearance

- **Corner radius**: Defined by `lp-status` CSS class (typically rounded pill shape).
- **Padding**: Defined by `lp-status` CSS class.
- **Font**: Defined by `lp-status` CSS class.
- **Background**: Default theme color from `--lp-accent-dim` token when `free={true}`; otherwise base background from `lp-status`.
- **Border**: `--lp-status-free-border` when `free={true}`; otherwise base border from `lp-status`.
- **Foreground/Text**: Inherited from parent text color or `lp-status` class.
- **Shadow**: None (as defined in source).
- **Min/Max size**: No constraints enforced by component; sizing determined by content and CSS.

## States

| State | Appearance change |
|-------|------------------|
| Default | Base `lp-status` styling |
| Free (free={true}) | Applies `lp-status--free` class with accent border and dim background |

## Accessibility

Not applicable: StatusPill is a presentational wrapper for text content with no interactive behavior. Accessibility of the content is the responsibility of the parent context and the text rendered as children. The component renders as a `<p>` element, which is semantically neutral; the containing context SHOULD use appropriate heading hierarchy or ARIA roles if the status conveys structural meaning.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| status-pill-001 | must-accept-children | `<StatusPill>Active</StatusPill>` | Component renders the text "Active" within the pill |
| status-pill-002 | must-apply-base-class | `<StatusPill>Free</StatusPill>` | Root element has CSS class `lp-status` |
| status-pill-003 | must-apply-free-class | `<StatusPill free={true}>Free Plan</StatusPill>` | Root element has both classes `lp-status` and `lp-status--free` |
| status-pill-004 | must-not-apply-free-class-by-default | `<StatusPill>Standard</StatusPill>` | Root element has class `lp-status` only; `lp-status--free` is absent |
| status-pill-005 | must-not-apply-free-class-by-default | `<StatusPill free={false}>Standard</StatusPill>` | Root element has class `lp-status` only; `lp-status--free` is absent |

## Edge Cases

- **Empty children**: When children is an empty string or empty ReactNode, the component renders an empty pill with only the CSS classes applied. Behavior is MUST.
- **Undefined or null children**: When children is `undefined` or `null`, the component renders nothing within the pill (React renders no content). Behavior is MUST.
- **Multiple children elements**: When children contains multiple ReactNode elements (e.g., text mixed with inline elements), all children are rendered within the pill in order. Behavior is MUST.
- **free prop omitted**: When the `free` prop is not provided, it defaults to `undefined` (falsy), and `lp-status--free` class is not applied. Behavior is MUST.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| children | ReactNode | required | Content to render inside the pill |
| free | boolean \| undefined | undefined | When `true`, applies accent styling via `lp-status--free` class |

## Deep Linking

Not applicable: StatusPill is a presentational component with no navigation or deep-link behavior.

## Localization

Not applicable: StatusPill is a content-agnostic wrapper; localization is the responsibility of text provided by the parent.

## Accessibility Options

Not applicable: StatusPill has no interactive states or motion, and is a presentational wrapper only.

## Feature Flags

Not applicable: No feature flag behavior is implemented in the source.

## Analytics

Not applicable: StatusPill does not emit analytics events; event tracking is the responsibility of the parent component.

## Privacy

Not applicable: StatusPill does not collect, store, or transmit data.

## Logging

Not applicable: No logging is implemented in the source.

## Platform Notes

- **TypeScript/React**: Component is defined in `packages/web/packages/landing/src/blocks/StatusPill.tsx`. Renders a `<p>` element with conditional CSS class application via template-literal string filtering. Props are `children: ReactNode` and optional `free?: boolean`. CSS classes are applied via inline className binding.

- **SwiftUI**: Implement as a `Text` view with a custom modifier or as a `Label` with fixed styling. Apply the pill corner radius via `.clipShape(Capsule())` and border/background conditional on an optional `isFree` Boolean parameter. Text styling (font, foreground color) should match the source CSS tokens.

- **Compose**: Implement using a `Text` composable wrapped in a `Box` or `Surface` with conditional styling. Apply rounded corners via `shape = RoundedCornerShape(percent = 50)` and use `background()` and `border()` modifiers to apply the free-tier styling conditionally on a Boolean `free` parameter.

- **AppKit / UIKit**: Implement as a `UILabel` (UIKit) or `NSTextField` (AppKit) with custom background view and border. Apply pill shape via corner radius (`layer.cornerRadius = bounds.height / 2`) and conditionally apply the accent-colored border and dim background via subclass property or external styling. A common pattern is a small `UIView` subclass that handles the styling based on an `isFree` property.

- **WinUI 3**: Implement as a `TextBlock` inside a `Border` element with rounded corners (`CornerRadius` property). Conditionally apply `Background` and `BorderBrush` resources based on a `Free` dependency property or XAML binding. Use `VerticalAlignment="Center"` and `HorizontalAlignment="Center"` with padding via `Margin` and `Padding` properties to match the pill appearance.

## Design Decisions

The component deliberately uses a `<p>` element rather than a `<span>` or generic `<div>`. This choice trades semantic neutrality for a block-level default layout; consumers typically override display to inline or inline-block via CSS. The `free` prop is optional and defaults to `undefined` (falsy) to allow simple usage without explicit `free={false}`. CSS class names are filtered via `.filter(Boolean).join(' ')` rather than using a class-name library; this keeps the component lightweight and dependency-free.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| Text content accessibility | passed | Accessibility — parent responsibility |
| Touch target (web: not applicable) | passed | Web component is not interactive |
| Contrast (delegated to CSS) | passed | Appearance — CSS token responsibility |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation |
