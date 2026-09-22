---
id: 01947259-4883-44e1-a047-6b4e463cb422
title: Landing Card
domain: agenticdevelopercookbook://ingredients/landing-card
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: 'A single tile in a landing page card grid: optional kicker label, required
  title heading, and prose content.'
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

# Landing Card

## Overview

A landing page card presents a discrete piece of information in a grid layout. It consists of three stacked layers: an optional kicker (small contextual label), a required title heading, and required prose or content. The component is semantic HTML and class-based styling; styling and layout are handled by the container (`Cards` grid) and the card's own CSS classes.

## Behavioral Requirements

- **must-render-title**: Component MUST render the `title` prop as an `<h3>` heading.
- **must-render-children**: Component MUST render the `children` prop as the card's content, immediately after the title.
- **must-support-optional-kicker**: Component MUST accept an optional `kicker` prop and render it only when defined (not `undefined`).
- **must-render-kicker-before-title**: When `kicker` is provided, it MUST render before the `<h3>` title in the DOM.
- **must-use-card-class**: The root element MUST have the class name `lp-card`.
- **must-use-kicker-class**: When rendered, the kicker element MUST have the class name `lp-card__kicker`.
- **must-accept-react-nodes**: The `kicker`, `title`, and `children` props MUST accept any React `ReactNode` (elements, strings, numbers, fragments, etc.), not only strings.

## Appearance

- **Root element**: `<div>` with class `lp-card`
- **Kicker element**: `<span>` with class `lp-card__kicker` (conditional)
- **Title element**: `<h3>` (semantic heading, no class)
- **Content**: Direct children rendered after the title
- **Spacing and styling**: Controlled by CSS classes `lp-card` and `lp-card__kicker`; this recipe does not specify colors, typography, padding, or visual hierarchy (those are stylesheet concerns)

## States

| State | Appearance change |
|-------|------------------|
| Default (kicker undefined) | Kicker element absent from DOM |
| Default (kicker defined) | Kicker element rendered |
| Loading | Not applicable: component is static presentation; content loading is the parent's concern |
| Disabled | Not applicable: component is not interactive |

## Accessibility

- **Role**: The root is a generic container (`<div>`); the `<h3>` title establishes semantic structure for screen readers.
- **Heading level**: Title is always an `<h3>`. The consumer is responsible for ensuring this fits the document's heading hierarchy; if the card is used in a context where `<h4>` or another level is appropriate, that adjustment MUST happen at the consumer level.
- **Label requirements**: Title text MUST be meaningful and describe the card's subject. If `title` is an icon or symbol, it MUST be accompanied by accessible text (either in the prop or wrapping element).
- **Kicker labeling**: Kicker text SHOULD provide context (e.g., "Preview", "Latest", "23 specialists"). Screen readers will encounter it before the title due to DOM order. If kicker is interactive content (a link), the consumer MUST ensure the kicker and title together form a descriptive label.
- **Content accessibility**: Content (`children`) MUST be accessible HTML; this component imposes no restrictions but does not enhance accessibility for complex children — responsibility remains with the consumer.
- **Minimum tap target**: Not applicable: component is not interactive; if children contain interactive elements, those MUST meet 44×44pt (iOS) / 48×48dp (Android) / 44×44px (web) minimum tap targets per platform guidelines.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| landing-card-001 | must-render-title | `title="Explore Stories"` | Output contains `<h3>Explore Stories</h3>` |
| landing-card-002 | must-render-children | `children="Browse our collection"` | Output contains text node "Browse our collection" after the title |
| landing-card-003 | must-support-optional-kicker, must-render-kicker-before-title | `kicker="Preview"` | Output contains `<span class="lp-card__kicker">Preview</span>` before the `<h3>` |
| landing-card-004 | must-support-optional-kicker | `kicker={undefined}` (or omitted) | Kicker `<span>` absent from DOM |
| landing-card-005 | must-use-card-class | Any props | Root `<div>` has class `lp-card` |
| landing-card-006 | must-use-kicker-class | `kicker="Label"` | Kicker span has class `lp-card__kicker` |
| landing-card-007 | must-accept-react-nodes | `title={<em>Dynamic</em>}` | Title renders the React element inside the `<h3>` |
| landing-card-008 | must-accept-react-nodes | `children={<ul><li>Item</li></ul>}` | Children render the list elements after the title |

## Edge Cases

- **Null or undefined title**: Title is marked REQUIRED in the prop type; no test is needed for omission, but implementations MUST NOT crash if a consumer provides `title={undefined}` or `title={null}`. Outcome: title renders as empty `<h3></h3>`.
- **Empty string kicker**: If `kicker=""` (empty string), it is truthy to the conditional check. The kicker span renders with empty content. Outcome: `<span class="lp-card__kicker"></span>` appears in the DOM.
- **Null or undefined children**: Children is marked REQUIRED. No test for omission is needed, but implementations MUST NOT crash if a consumer provides `children={undefined}` or `children={null}`. Outcome: Card renders title and an empty content area.
- **Whitespace-only children**: If `children="   "` (whitespace only), it renders as-is; no trimming occurs. Outcome: Whitespace appears as content.
- **Very long title or kicker text**: No line-breaking or truncation is defined at the component level; layout is CSS-driven. Outcome: Text overflows or wraps per the `lp-card` stylesheet rules.
- **Interactive content in title or children**: A consumer MAY place links, buttons, or form fields inside the card. The component MUST NOT prevent or restrict this. Outcome: Interactive elements are rendered and functional.
- **React Fragment as children**: If `children={<>Item 1<Item 2></>}` (Fragment), React renders the fragment's children directly. Outcome: Both items appear after the title.

## Configuration

Not applicable: Component accepts only `kicker`, `title`, and `children` props. There are no feature flags, configuration options, or env-var-controlled behavior.

## Deep Linking

Not applicable: Landing Card is a presentation component on a landing page, not a navigable view. Deep linking is a page-level concern.

## Localization

Not applicable: Component renders user-provided content as-is; localization of the kicker, title, and children is the consumer's responsibility.

## Accessibility Options

Not applicable: Component is static presentation and does not respond to system accessibility options (Reduce Motion, Increase Contrast, etc.). Consumers providing interactive or animated children are responsible for honoring these options.

## Feature Flags

Not applicable: Component has no feature-flagged behavior or optional functionality.

## Analytics

Not applicable: Component is not interactive and does not emit events. Analytics for user interaction with card content (if children include links or buttons) is the consumer's responsibility.

## Privacy

Not applicable: Component does not collect, store, or transmit any data.

## Logging

Not applicable: Component performs no operations that warrant logging.

## Platform Notes

- **TypeScript / Web (React)**: Component is `Card.tsx` in `packages/web/packages/landing/src/blocks/`. Render as a semantic `<div>` with class `lp-card`, optional `<span class="lp-card__kicker">`, `<h3>` for title, and children. Styling is CSS-driven via `lp-card` and `lp-card__kicker` classes.
- **SwiftUI**: Start with a `VStack` to layer kicker, title, and content. Use `Text` for kicker (if present, apply smaller font and secondary color), `Text` with `.font(.title3)` for title (matching `<h3>` semantic weight), and a placeholder for content. Apply a Card style or custom `.background()` modifier. No class-based styling; use SwiftUI's modifier system for appearance.
- **Compose**: Use a `Column` to stack elements. Render a `Text` for optional kicker (if present, styled smaller and secondary), a `Text` for title with `style = MaterialTheme.typography.headlineSmall`, and content composable(s) after. Apply Material Design 3 card styling using `Card` or `Surface` with appropriate padding and elevation.
- **AppKit / UIKit**: For AppKit, use an `NSView` with vertical `NSStackView` layout; for UIKit, use `UIView` with vertical `UIStackView`. Add optional `NSTextView`/`UILabel` for kicker (if present, small font), `NSTextView`/`UILabel` with heading weight for title, and a content view. Apply background color and border per design. No class-based styling; use native layout and appearance APIs.
- **WinUI 3**: Use a `Grid` with single column and auto-sized rows. Add optional `TextBlock` with `FontSize="12"` and `Foreground` set to secondary color for kicker (if present). Add `TextBlock` with `FontSize="18"` and `FontWeight="Bold"` for title. Add content control(s) below. Apply `CornerRadius` and `Background` to the root Grid or a `Border` wrapper. Bind kicker visibility to a converter that collapses it when `null`.

## Design Decisions

- **Kicker rendered as a `<span>` not a `<div>`**: Kicker is a small inline label, so `<span>` is more semantic than `<div>`. It does not start a new block-level section.
- **Title is always `<h3>`**: Card title is a tertiary heading (after page and section titles). Consumers may adjust heading levels at a higher level if the card hierarchy requires it, but the component itself uses `<h3>` to establish a consistent baseline.
- **Optional kicker design**: Kicker is omitted entirely when `undefined`, not rendered with empty content. This avoids empty DOM nodes and simplifies CSS selectors. The conditional `{kicker === undefined ? null : ...}` ensures no render when absent.
- **No styling concerns in component**: Styling (colors, padding, font sizes, shadows, borders) is delegated to the `lp-card` and `lp-card__kicker` CSS classes. This keeps the component focused on structure and props, making it reusable across design systems.
- **Children rendered directly**: No wrapper, no assumptions about content type. This maximizes flexibility; consumers control the layout and styling of prose, images, or other content.

## Compliance

Not applicable: Component is a basic presentational element with no security, privacy, compliance, or regulatory concerns. Consumers are responsible for compliance of any interactive or data-handling features they add as children.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation from Card.tsx source |
