---
id: 05930e64-fa82-49ef-b50d-22d87fa7d182
title: Deck
domain: agenticdevelopercookbook://ingredients/deck
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A flow container wrapper that holds screen content without scrolling, enabling
  document-level scroll control.
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

# Deck

## Overview

Deck is a layout wrapper component that serves as the root container for screen content in a flow-based UI. It does not scroll itself — the browser document handles scrolling — so it carries no height or overflow constraints. Deck is always a `<div>` element with the class `lp-deck` and maintains internal focus without entering the tab order, allowing keyboard navigation to scroll the document instead of being trapped within the component.

## Behavioral Requirements

- **must-render-children**: Deck MUST render its `children` prop as direct descendants.
- **must-apply-lp-deck-class**: Deck MUST apply the CSS class `lp-deck` to its root element.
- **must-merge-classnames**: Deck MUST merge the `lp-deck` class with any optional `className` prop, filtering out falsy values before joining.
- **must-be-focusable-div**: Deck MUST render as a `<div>` element with `tabIndex={-1}`, making it focusable without participating in the tab order.
- **must-not-be-main-landmark**: Deck MUST NOT render as a `<main>` element, as it is designed to be placed inside a host shell that may already provide the page's main landmark.

## Appearance

Not applicable: Deck is an unstyled structural container. Visual appearance is defined by CSS rules applied to the `.lp-deck` class or to its children.

## States

Not applicable: Deck is a static container with no interactive states (default, pressed, disabled, focused, loading).

## Accessibility

- **Focus management**: Deck's `tabIndex={-1}` keeps it focusable for programmatic focus control while excluding it from keyboard tab navigation. This allows click-based focus to remain inside the content, letting subsequent keyboard events scroll the document.
- **No semantic role**: Deck is a structural container with no accessible role. Its element type (`<div>`) must not be changed in a way that introduces an unintended semantic role.
- **Not a landmark**: Deck is not a landmark element. The page's `<main>` landmark, if present, MUST be provided by the host shell outside the Deck to avoid nested main elements.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| deck-001 | must-render-children | `<Deck><span>Content</span></Deck>` | The span is rendered as a child of the div |
| deck-002 | must-apply-lp-deck-class | `<Deck/>` | The rendered div has class `lp-deck` |
| deck-003 | must-merge-classnames | `<Deck className="custom-class"/>` | The rendered div has both classes: `lp-deck custom-class` |
| deck-004 | must-merge-classnames | `<Deck className={undefined}/>` | The rendered div has only `lp-deck`; undefined className is filtered out |
| deck-005 | must-be-focusable-div | `<Deck/>` | The rendered element is a div with `tabIndex={-1}` |
| deck-006 | must-not-be-main-landmark | `<Deck/>` | The rendered element is `<div>`, not `<main>` |

## Edge Cases

- **Empty children**: Deck MUST render successfully when `children` is empty, null, or undefined.
- **Falsy classNames**: Deck MUST filter out falsy classNames (null, undefined, false, empty string) before concatenating.
- **Multiple className strings**: If `className` contains multiple space-separated class names, Deck MUST preserve all of them when merging with `lp-deck`.
- **No className prop**: Deck MUST render with only the `lp-deck` class when the `className` prop is not provided.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `children` | `ReactNode` | required | The content to render inside the Deck |
| `className` | `string` | `undefined` | Additional CSS class names to apply to the root div |

## Deep Linking

Not applicable: Deck is a layout container, not a routable screen or page.

## Localization

Not applicable: Deck contains no user-facing text or locale-specific content.

## Accessibility Options

Not applicable: Deck is a structural container with no visual styling or interactive elements that respond to accessibility display options (Reduce Motion, Increase Contrast, Differentiate Without Color).

## Feature Flags

Not applicable: Deck is foundational infrastructure, not a user-facing feature subject to feature flag gating.

## Analytics

Not applicable: Deck is a container with no user interaction to track.

## Privacy

Not applicable: Deck does not collect, store, or transmit any data.

## Logging

Not applicable: No logging is implemented in Deck.

## Platform Notes

- **TypeScript/Web**: Implemented in `packages/web/packages/landing/src/deck/Deck.tsx`. The component accepts `children` (ReactNode) and optional `className` (string) props. Class names are filtered and merged using `['lp-deck', className].filter(Boolean).join(' ')`. The element has `tabIndex={-1}` to enable focus control without entering the tab order.

- **SwiftUI**: Use a `VStack(spacing: 0)` or zero-spacing container as the equivalent. Assign the view the accessibility identifier `"deck"` and ensure no scroll behavior is applied to the container itself — let the document or outer scroll view handle scrolling.

- **Compose**: Use a `Box` or `Column` with `modifier = Modifier.focusable()` to create a focusable container. The equivalent of `tabIndex={-1}` is achieved through Compose's focus management system; the container should be focusable but not part of the default tab order.

- **AppKit / UIKit**: For macOS, use `NSView` or `NSStackView` as the container. For iOS, use `UIView` or `UIStackView`. Neither should have scroll enabled; scrolling is handled by the document or enclosing scroll view. Set the accessibility element's role to exclude any semantic landmark to prevent nesting issues.

- **WinUI 3**: Use a `Grid` or `StackPanel` (with orientation `Vertical` and spacing `0`) as the root container. Set `IsTabStop="false"` on the panel and `TabIndex="-1"` if programmatic focus is needed. Ensure the parent window or page provides any required semantic roles (like `AutomationProperties.LandmarkType="Main"`) outside the Deck container to avoid nesting conflicts.

## Design Decisions

**Why Deck is a `<div>` and not `<main>`**: The component was initially rendered as a `<main>` element but shipped that way in a consumer that rendered Deck inside a host shell that already provides a page `<main>`. This resulted in two `<main>` landmarks nested, violating HTML validity and confusing screen reader users with multiple "main" landmarks offering no way to disambiguate which is the page's actual main content. Deck is now a `<div>` to avoid landmark duplication. Hosts that do not provide their own main landmark can apply the landmark from outside Deck, which is the only context that knows whether one already exists.

**Why Deck has `tabIndex={-1}`**: The `tabIndex={-1}` attribute keeps Deck focusable for programmatic focus (e.g., clicking on the page) without placing it in the keyboard tab order. When focus is programmatically set to Deck or one of its descendants via click, subsequent keyboard events (arrow keys, Page Down, etc.) navigate within the focused content and scroll the document. This avoids trapping focus within Deck and allows the document to act as the natural scroll container.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| No semantic role conflict | passed | Accessibility |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation |
