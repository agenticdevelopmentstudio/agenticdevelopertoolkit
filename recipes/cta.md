---
id: f98e53f7-ac16-48b0-afa5-544d05bf3f70
title: Cta
domain: agenticdevelopertoolkit://recipes/cta
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Container for call-to-action button groups, typically positioned below hero
  or closer section taglines.
platforms:
- typescript
- web
tags:
- container
- layout
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Cta

## Overview

The Cta component is a layout container for grouping call-to-action buttons. It wraps button or link children in a semantic div element and applies consistent spacing and alignment through CSS class styling. Typically positioned below a Hero or Closer component's tagline to group primary and secondary actions.

## Behavioral Requirements

- **must-render-children**: Component MUST render all ReactNode children without modification.
- **must-apply-styling-class**: Component MUST apply the `lp-cta` CSS class to its container div.
- **must-preserve-child-props**: Component MUST NOT modify or filter props passed to children; all children render with their original props intact.

## Appearance

- **Container element**: `div` with class `lp-cta`
- **Layout**: Block-level container; children layout defined by `lp-cta` CSS class rules
- **Background**: Transparent (inherits parent)
- **Padding**: Defined by `lp-cta` CSS class
- **Border**: None (container only)
- **Shadow**: None (container only)

## States

Not applicable: This component is a static container with no interactive or visual states.

## Accessibility

- **Role**: Generic container (implicit `div` role)
- **Semantics**: The `lp-cta` class does not alter semantic meaning; children determine accessibility tree structure
- **Keyboard navigation**: Not applicable; container is not interactive; keyboard navigation depends on child elements (buttons, links)
- **Screen reader**: Children are exposed directly in the accessibility tree with their own labels and roles

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| cta-001 | must-render-children | Children: `<button>Sign Up</button>` | Output contains `<button>Sign Up</button>` |
| cta-002 | must-render-children | Children: multiple buttons, links | All children rendered in order |
| cta-003 | must-render-children | Children: null or undefined | Renders empty container |
| cta-004 | must-apply-styling-class | Any children | Rendered div has `className="lp-cta"` |
| cta-005 | must-preserve-child-props | Button child with `onClick` handler | Child onClick handler fires on click |

## Edge Cases

- **Empty children**: Component renders an empty `<div className="lp-cta"></div>` without error.
- **Null or undefined children**: Renders empty container (React renders nothing for null/undefined).
- **Multiple children**: All children are rendered in document order within the container.
- **Fragment children**: React.Fragment children are unwrapped; their children render in the container.
- **Text node children**: Plain text or string children render as text nodes within the container.
- **Deeply nested children**: Component does not traverse or modify nested component trees.

## Configuration

Not applicable: Component accepts only the standard `children` prop; no configuration options exist.

## Deep Linking

Not applicable: This component is a layout container without route or navigation semantics.

## Localization

Not applicable: The component renders no user-facing text and requires no localization.

## Accessibility Options

Not applicable: The component does not respond to platform accessibility display options; accessibility behavior is determined by child elements.

## Feature Flags

Not applicable: No feature flag controls this component's behavior.

## Analytics

Not applicable: The component is a container without user interaction. Child elements (buttons, links) trigger their own analytics events.

## Privacy

Not applicable: This component collects and stores no data.

## Logging

Not applicable: No diagnostic logging is implemented for this container component.

## Platform Notes

- **React/Web**: `packages/web/packages/landing/src/blocks/Cta.tsx` — a simple functional component accepting `children: ReactNode` prop; styling applied via `className="lp-cta"` CSS class defined in the landing package stylesheet.
- **SwiftUI**: Implement as a `VStack` or horizontal `HStack` with `Spacer()` views and alignment modifiers to match `lp-cta` layout; wrap child views (buttons, links) without introducing intermediate container semantics.
- **Compose**: Implement as a `Row` or `Column` with appropriate `Arrangement` and `Alignment` to replicate `lp-cta` spacing; use `Modifier.fillMaxWidth()` and padding composables to match CSS styling.
- **AppKit / UIKit**: Implement as `UIView` or `NSView` subclass using Auto Layout constraints; position child views (buttons, link views) according to `lp-cta` layout rules; use a stack view (`UIStackView` or `NSStackView`) for straightforward composition.
- **WinUI 3**: Implement as a `StackPanel` (horizontal or vertical orientation matching `lp-cta` layout) with appropriate `Spacing` and `Margin` properties; wrap child button or hyperlink controls without altering their properties or event handlers.

## Design Decisions

The component is a minimal layout wrapper with no logic, state, or conditional rendering. It serves as a semantic container to group related call-to-action elements and apply shared styling. The decision to use a generic `div` rather than a `<nav>` or `<section>` preserves flexibility for the parent component to determine semantic context.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| Accessible container | Passed | Accessibility |
| No conflicting ARIA | Passed | Accessibility |
| CSS class applied | Passed | Styling |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation from web source |
