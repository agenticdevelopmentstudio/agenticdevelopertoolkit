---
id: e7060a14-3f66-429a-9ea5-288f1fe5a76f
title: Roadmap
domain: agenticdevelopercookbook://ingredients/roadmap
type: ingredient
version: 1.0.0
status: review
language: en
created: 2026-09-22
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Container separating planned features visually from shipped ones, with optional
  label.
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

# Roadmap

## Overview

A layout container that visually separates a roadmap section (planned or future features) from other content. The component wraps an eyebrow label and child content in a dedicated container, ensuring structural separation rather than relying on prose caveats. The eyebrow label is optional; when absent, no span element is rendered to avoid empty markup and unintended visual spacing.

## Behavioral Requirements

- **must-render-container**: Component MUST render a div with class `lp-roadmap` as the root element.
- **must-render-eyebrow-when-present**: Component MUST render a span with class `lp-eyebrow` containing the eyebrow prop when eyebrow is not undefined.
- **must-not-render-eyebrow-span-when-absent**: Component MUST NOT render an eyebrow span element when the eyebrow prop is undefined or not provided.
- **must-render-children**: Component MUST render all child content within the root container.

## Appearance

- **Container class**: `lp-roadmap` — styling applied via CSS class
- **Eyebrow class**: `lp-eyebrow` — applied to optional label span when rendered
- **Spacing**: Managed by stylesheet; no inline padding or margin specified in component

## States

Not applicable: Roadmap is a static layout container with no interactive states or internal state transitions.

## Accessibility

- **Role**: Container (implicit `div` semantics) — no explicit role required for a layout wrapper.
- **Eyebrow label**: When eyebrow is rendered, it functions as a visual heading for the section; it SHOULD be text content or an accessible ReactNode.
- **Child content**: Component does not impose accessibility requirements on children; children remain independently accessible.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| roadmap-001 | must-render-container | No props (only children) | Root div with class `lp-roadmap` rendered |
| roadmap-002 | must-render-eyebrow-when-present | eyebrow="Planned Agents" | Span with class `lp-eyebrow` containing "Planned Agents" rendered inside container |
| roadmap-003 | must-not-render-eyebrow-span-when-absent | eyebrow={undefined} or eyebrow prop omitted | No span element rendered; container div rendered directly with children |
| roadmap-004 | must-render-children | children={<span>Test content</span>} | Span containing "Test content" rendered inside roadmap container |
| roadmap-005 | must-render-eyebrow-when-present, must-render-children | eyebrow="Planned", children={<div>List</div>} | Eyebrow span rendered first, then children div, all inside roadmap container |

## Edge Cases

- **Undefined eyebrow**: When eyebrow is undefined, no span is rendered. This prevents empty markup and unwanted spacing caused by an empty `<span className="lp-eyebrow"></span>`.
- **Null eyebrow**: When eyebrow is null, behavior matches undefined; no span is rendered.
- **Empty eyebrow**: When eyebrow is an empty string or ReactNode, the span is still rendered (non-undefined). The span will contain no visible content but occupies markup and applies styling.
- **Multiple or complex children**: Component renders all children as-is; no validation or transformation is applied.
- **No children**: Component renders the container and optional eyebrow with no child content inside.

## Configuration

Not applicable: Component accepts no configurable options; behavior is determined entirely by props (eyebrow and children).

## Deep Linking

Not applicable: Roadmap is a layout container, not a navigable destination or page section that would require deep linking support.

## Localization

Not applicable: Component contains no user-facing strings; text content is provided via the eyebrow prop and child nodes by the parent.

## Accessibility Options

Not applicable: Component is a static layout container with no animated transitions, motion-dependent interactions, color-dependent indicators, or interactive state feedback that would require Reduce Motion, Increase Contrast, or Differentiate Without Color support.

## Feature Flags

Not applicable: Component has no feature flag gating; it is always available when imported.

## Analytics

Not applicable: Component is a container with no user interaction or state changes to track.

## Privacy

Not applicable: Component stores no data, makes no network requests, and transmits no information.

## Logging

Not applicable: Component has no internal state, lifecycle events, or error conditions that would warrant logging.

## Platform Notes

- **TypeScript/React/Web**: Files `packages/web/packages/landing/src/blocks/Roadmap.tsx`. Renders a `div` with class `lp-roadmap` and conditionally renders an optional `span` with class `lp-eyebrow`. When eyebrow prop is undefined, the span element is omitted entirely rather than rendered empty to avoid unintended layout gaps.
- **SwiftUI**: Use a `VStack` with optional top section containing a `Text` view styled as an eyebrow label. Use `@ViewBuilder` or conditional rendering (`if eyebrow != nil { ... }`) to omit the label section entirely when no eyebrow is provided, preserving layout spacing.
- **Compose**: Use a `Column` with optional top `Text` composable for the eyebrow, conditionally rendered. Omit the eyebrow composable entirely when not provided to prevent layout shifts from empty slots.
- **AppKit / UIKit**: Use `NSStackView` (AppKit, vertical axis) or `UIStackView` (UIKit, vertical axis). Add an optional `NSTextField` (AppKit) or `UILabel` (UIKit) for the eyebrow label as the first arranged view, removing it from the stack when no eyebrow is provided rather than hiding it invisibly.
- **WinUI 3**: Use a `StackPanel` with vertical orientation. Add an optional `TextBlock` at the top for the eyebrow label, removing it entirely from the panel's Children when no eyebrow is provided to avoid vertical spacing artifacts from an empty element.

## Design Decisions

The eyebrow label is omitted from markup entirely when undefined, rather than rendering an empty element. This design choice reflects the layout principle that structural separation should be visible and intentional: a reader who sees the eyebrow knows the section is labeled; absence means there is no label. An invisible empty span would create a layout gap the HTML source cannot explain, making the component harder to debug and test.

The component does not validate or transform child content; it simply wraps it. Parent components are responsible for ensuring children are appropriate for a roadmap section.

## Compliance

Not applicable: Component is a simple layout container with no security, compliance, or regulatory concerns.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |

