---
id: 6f5f455d-b744-425d-a21e-494fc18caaf2
title: Flow
domain: agenticdevelopercookbook://ingredients/flow
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A non-scrolling content container that holds sequential bands or sections
  without managing scroll behavior.
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

# Flow

## Overview

Flow is a container component that wraps sequential content sections (bands) in a page or view. It establishes the structural root for content without implementing scroll behavior — scrolling is delegated to the document or parent container. The component is focusable but not in the tab order, allowing click-based focus to remain within its children while keyboard navigation scrolls the nearest scrollable ancestor.

## Behavioral Requirements

- **must-render-main-element**: Flow MUST render a `<main>` HTML element as its root.
- **must-have-negative-tab-index**: Flow MUST set `tabIndex={-1}` on the root element to make it focusable but exclude it from the default tab order.
- **must-render-children**: Flow MUST render its `children` prop directly inside the main element.
- **must-apply-lp-flow-class**: Flow MUST apply the `lp-flow` CSS class to the root element.
- **must-support-custom-class**: Flow MUST accept an optional `className` prop and append it to the root element's class list when provided.
- **must-filter-empty-classes**: Flow MUST not render empty or undefined classes; only non-falsy class names MUST appear in the final class attribute.
- **must-not-manage-height-or-overflow**: Flow MUST NOT set explicit height or overflow properties on the root element; these are delegated to the parent or document.
- **must-not-scroll**: Flow MUST NOT implement scroll behavior itself; scrolling is the responsibility of the containing document or parent.

## Appearance

- **Element**: `<main>`
- **Default class**: `lp-flow`
- **Height**: Not constrained; height is determined by content and parent layout.
- **Overflow**: Not set; overflow is handled by the document or parent container.
- **Padding / Margin**: Not set; inherit from `lp-flow` class or parent styles.
- **Background**: Not set; inherit from `lp-flow` class or parent styles.

## States

Not applicable: Flow is a structural container with no interactive states. It does not respond to user input or change its appearance based on state.

## Accessibility

- **Role**: `main` — the `<main>` element provides the semantic role for the primary content of the document.
- **Focusability**: `tabIndex={-1}` makes the element focusable via click or programmatic focus, but excludes it from the default tab order. This ensures that clicking on content within Flow retains focus inside the element while keyboard navigation delegates scroll control to the nearest scrollable ancestor (typically the document).
- **No label**: Flow is a structural container and does not require a label.
- **Keyboard interaction**: Flow itself does not handle keyboard events; keyboard navigation (arrow keys, Page Up/Down) scroll the nearest scrollable ancestor.

## Conformance Test Vectors

| ID | Requirement | Input | Expected |
|-------|------|--------|----------|
| flow-001 | must-render-main-element | `<Flow><div>Content</div></Flow>` | Rendered as `<main tabIndex={-1} className="lp-flow"><div>Content</div></main>` |
| flow-002 | must-have-negative-tab-index | `<Flow><div>Content</div></Flow>` | `tabIndex={-1}` attribute is present on `<main>` element. Element is focusable but not in tab order when tested with Tab key. |
| flow-003 | must-render-children | `<Flow><p>Hello</p></Flow>` | `<p>Hello</p>` appears inside the `<main>` element exactly as passed. |
| flow-004 | must-apply-lp-flow-class | `<Flow><div>Content</div></Flow>` | `className="lp-flow"` is present on the `<main>` element. |
| flow-005 | must-support-custom-class | `<Flow className="custom"><div>Content</div></Flow>` | `className="lp-flow custom"` is present on the `<main>` element. |
| flow-006 | must-filter-empty-classes | `<Flow className={undefined}><div>Content</div></Flow>` | `className="lp-flow"` is present; no extra spaces or undefined values appear in the attribute. |
| flow-007 | must-not-manage-height-or-overflow | Inspect computed styles | No `height`, `max-height`, or `overflow` properties are set by Flow on the root element. |
| flow-008 | must-not-scroll | Render with scrollable content inside; scroll with arrow keys | Scrolling behavior is delegated to the document or parent container, not the Flow root. |

## Edge Cases

- **No children**: Flow accepts zero children. When rendered without children, it produces an empty `<main tabIndex={-1} className="lp-flow"></main>` element. This is valid and used to establish the structural root even when content is added dynamically.
- **Empty className**: When `className` is an empty string, it MUST be filtered out. The resulting `className` MUST be `lp-flow` only, not `lp-flow `.
- **Multiple class names in className prop**: Flow MUST append the entire `className` prop value unchanged. If `className="foo bar baz"`, the result MUST be `className="lp-flow foo bar baz"`.
- **Focus behavior with non-scrollable content**: When the viewport is not larger than content, tabIndex={-1} keeps focus within Flow while arrow keys scroll the document (the nearest scrollable ancestor).
- **Focus behavior on empty Flow**: When rendered with no children and thus no interactive elements, clicking on Flow sets focus on the `<main>` element itself.

## Configuration

Not applicable: Flow has no configuration options. Its behavior is fully determined by its `children` and optional `className` props.

## Deep Linking

Not applicable: Flow is a structural container and does not define or handle deep linking behavior.

## Localization

Not applicable: Flow renders no user-facing strings.

## Accessibility Options

Not applicable: Flow provides no accessibility display options (reduce motion, increase contrast, etc.).

## Feature Flags

Not applicable: Flow has no feature flag control in the source.

## Analytics

Not applicable: Flow does not emit analytics events in the source.

## Privacy

Not applicable: Flow does not collect, transmit, or store any user data.

## Logging

Not applicable: Flow does not emit logging statements in the source.

## Platform Notes

- **TypeScript/Web**: Flow is implemented in `packages/web/packages/landing/src/flow/Flow.tsx`. The component accepts `children` (ReactNode) and optional `className` (string) props, renders a `<main>` element with `tabIndex={-1}`, applies the `lp-flow` class and any custom class names, and delegates all scroll behavior to the document. Styling details (colors, padding, spacing) are defined in the corresponding CSS module for the `lp-flow` class, not in the component itself.
- **SwiftUI**: Flow maps to a `VStack` or `ZStack` root view that does not manage scroll behavior itself. Set `tabIndex` equivalent via accessibility modifiers to keep the container focusable without capturing tab navigation. Delegate scrolling to a parent `ScrollView` or the view hierarchy.
- **Compose**: Flow maps to a `Box` or `Column` composable at the root of the content hierarchy. Do not set `scrollable()` on the Flow root; instead, wrap the entire hierarchy in a parent `Column` with `Modifier.verticalScroll()` if scrolling is needed. The Box/Column should not specify explicit height or overflow constraints.
- **AppKit / UIKit**: Flow maps to `NSView` or `UIView` used as the content root. Do not configure scroll behavior on the Flow view itself; use a `NSScrollView` or `UIScrollView` as the parent if scrolling is required. Set `canBecomeKeyView` or equivalent to true and manage tab order separately from the Flow view. The Flow view itself should not specify fixed height or clipping behavior.
- **WinUI 3**: Flow maps to a `Grid` or `StackPanel` root element in XAML. Set `TabIndex="-1"` on the root control to make it focusable but exclude it from the default tab order. Apply the flow's default class or styling through a `Style` targeting the control type, not through inline properties. Do not set `Height`, `MaxHeight`, or `Overflow` on the Flow root; delegate scrolling to a parent `ScrollViewer` or the page's scroll context.

## Design Decisions

Flow's `tabIndex={-1}` is the key decision distinguishing it from a passive container. The value makes the element focusable (so clicks set focus inside) while excluding it from keyboard tab order. This allows keyboard navigation to scroll the nearest scrollable ancestor (the document or a parent with explicit scroll) rather than stopping at the Flow root. This design supports the intended use case where Flow is the content container of a page and scrolling is managed by the document itself, not by Flow. Every platform implementation MUST preserve this characteristic.

## Compliance

Not applicable: Flow is a structural component with no specific compliance requirements beyond platform accessibility standards (which are addressed in the Accessibility section).

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation |
