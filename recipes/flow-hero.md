---
id: f8cbc576-a5ef-4e8c-90a0-7d0712b24b72
title: FlowHero
domain: agenticdevelopercookbook://ingredients/flow-hero
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Landing page hero section with centered composition, headline, subheading,
  actions, metadata, and supporting image.
platforms:
- typescript
- web
tags:
- landing-page
- hero
- composition
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# FlowHero

## Overview

FlowHero is a landing page hero section component that presents a centered composition with a mark (image), headline (claim of what the product does), subheading, optional call-to-action buttons, optional metadata, and an optional supporting image below. The component uses semantic HTML and is structured as a `<div>` to avoid creating an unlabeled region in screen reader outlines.

## Behavioral Requirements

- **must-render-headline**: Component MUST render the `headline` prop as an `<h1>` element.
- **must-render-subheading**: Component MUST render the `sub` prop as a `<p>` element with class `lp-hero-sub`.
- **must-render-mark**: Component MUST render the `mark` prop (a ReactNode) without modification, allowing the host to supply its own `<Image>` or `<img>` element.
- **must-render-actions-when-children-provided**: Component MUST render `children` prop wrapped in a `<div>` with class `lp-hero-actions` when `children` is not undefined.
- **must-not-render-actions-when-children-undefined**: Component MUST NOT render the actions container when `children` is undefined.
- **must-render-metadata-when-provided**: Component MUST render the `meta` prop as a `<p>` element with class `lp-hero-meta` when `meta` is not undefined.
- **must-not-render-metadata-when-undefined**: Component MUST NOT render the metadata paragraph when `meta` is undefined.
- **must-render-shot-when-provided**: Component MUST render the `shot` prop within a `<div>` with class `lp-hero-shot` wrapped in a Wrap component when `shot` is not undefined.
- **must-not-render-shot-when-undefined**: Component MUST NOT render the shot container when `shot` is undefined.
- **must-support-optional-id**: Component MUST accept and render an optional `id` prop on the root `<div>`.
- **must-render-root-element**: Component MUST render a root `<div>` element with class `lp-hero-flow`.

## Appearance

- **Layout**: Centered vertical stack composition, with child elements constrained within a Wrap container
- **Background**: Warm ground (managed by CSS class `lp-hero-flow`)
- **Typography**:
  - Headline: `<h1>` semantic heading
  - Subheading: `<p>` with class `lp-hero-sub`
  - Metadata: `<p>` with class `lp-hero-meta`, uppercased by stylesheet
- **Spacing**: Managed by CSS classes (`lp-hero-actions`, `lp-hero-shot`)
- **Mark container**: Rendered as provided (no styling applied by component)

## States

| State | Appearance change |
|-------|------------------|
| Default | — |
| Children provided | Actions container visible below subheading |
| Children undefined | Actions container hidden |
| Metadata provided | Metadata paragraph visible below actions |
| Metadata undefined | Metadata paragraph hidden |
| Shot provided | Shot image container visible below metadata |
| Shot undefined | Shot image container hidden |

## Accessibility

- **Semantic structure**: Uses `<h1>` for headline (main page heading) and `<p>` for subheading and metadata. The root is a `<div>`, not a `<section>`, to avoid creating an unlabeled landmark region in screen reader outlines.
- **Headline labeling**: The `<h1>` must contain meaningful text that describes the product's claim or purpose.
- **Subheading relationship**: The `<p>` with class `lp-hero-sub` provides supplementary information; position immediately after the headline creates a logical reading order.
- **Action buttons**: `children` should contain properly labeled `<button>` elements; the parent `<div class="lp-hero-actions">` is a non-semantic container for layout only.
- **Image alt text**: The `mark` prop is supplied as a ReactNode by the host; the host is responsible for providing appropriate alt text if the mark contains an image.
- **Metadata styling**: Text is uppercased by CSS; if the content includes a product name that must not be all-caps (per Apple guidelines), the host must opt out of the uppercase transform via inline styles.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| flow-hero-001 | must-render-headline | `{ headline: "Find your adventure" }` | `<h1>Find your adventure</h1>` rendered in component |
| flow-hero-002 | must-render-subheading | `{ sub: "Play classic interactive fiction" }` | `<p class="lp-hero-sub">Play classic interactive fiction</p>` rendered in component |
| flow-hero-003 | must-render-mark | `{ mark: <img src="logo.png" alt="Logo" /> }` | Image element rendered without modification |
| flow-hero-004 | must-render-actions-when-children-provided | `{ children: [<Btn>Get Started</Btn>] }` | `<div class="lp-hero-actions">` wraps children and is visible |
| flow-hero-005 | must-not-render-actions-when-children-undefined | `{ children: undefined }` | `<div class="lp-hero-actions">` is not rendered |
| flow-hero-006 | must-render-metadata-when-provided | `{ meta: "Available on iOS and macOS" }` | `<p class="lp-hero-meta">Available on iOS and macOS</p>` rendered in component |
| flow-hero-007 | must-not-render-metadata-when-undefined | `{ meta: undefined }` | Metadata paragraph is not rendered |
| flow-hero-008 | must-render-shot-when-provided | `{ shot: <img src="screenshot.png" /> }` | Shot image wrapped in `<div class="lp-hero-shot">` and is visible |
| flow-hero-009 | must-not-render-shot-when-undefined | `{ shot: undefined }` | Shot container is not rendered |
| flow-hero-010 | must-support-optional-id | `{ id: "hero-section" }` | Root `<div>` has `id="hero-section"` attribute |
| flow-hero-011 | must-render-root-element | `{}` (all required props provided) | Root element is `<div class="lp-hero-flow">` |

## Edge Cases

- **Null headline or sub**: The component requires both `headline` and `sub` as mandatory props (not optional in the type signature); passing null or undefined violates the type contract. Behavior is undefined if coerced to render.
- **Empty content slots**: When `children`, `meta`, or `shot` are empty strings or empty arrays, they should be treated as falsy and not render their containers. Verify that conditional rendering (`!== undefined`) correctly excludes empty strings.
- **Nested components in mark**: The `mark` prop is rendered as-is; if the host provides complex nested React elements, they render without modification. No validation is performed on the mark's content or structure.
- **Very long text**: Headline and subheading text that exceeds single-line length will wrap per CSS (managed by stylesheet). The component imposes no text truncation or ellipsis.
- **Rich content in headline and sub**: Both `headline` and `sub` accept ReactNode, allowing the host to embed spans, links, or other elements. The component renders them as-is without sanitization.
- **Accessibility opt-out for uppercase meta**: The `meta` text is uppercased by stylesheet CSS. Hosts cannot opt out at the component level; opt-out requires inline style overrides on the `<p>` element (outside the component's control).

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `id` | `string \| undefined` | `undefined` | Optional HTML id attribute on the root `<div>` for linking or styling |
| `mark` | `ReactNode | undefined` | `undefined` | Optional mark/logo element (host supplies its own `<Image>` or `<img>`) |
| `headline` | `ReactNode` | — | Required: a claim describing what the product does, rendered as `<h1>` |
| `sub` | `ReactNode` | — | Required: one-line subheading under the headline, rendered as `<p class="lp-hero-sub">` |
| `children` | `ReactNode | undefined` | `undefined` | Optional action buttons (bare `Btn` elements in host's order, wrapped in `<div class="lp-hero-actions">`) |
| `meta` | `ReactNode | undefined` | `undefined` | Optional metadata line (price, platform floor, availability), rendered as `<p class="lp-hero-meta">` and uppercased by stylesheet |
| `shot` | `ReactNode | undefined` | `undefined` | Optional supporting image below the composition (typically wrapped in `Bleed` by the host) |

## Deep Linking

Not applicable: FlowHero is a pure composition component and does not handle navigation or deep linking. Deep linking is the responsibility of child elements (buttons) and the host page.

## Localization

| String Key | Default (en) | Context |
|-----------|-------------|---------|
| — | — | All content is supplied by the host via props; the component renders no hardcoded strings. |

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | No animation is generated by the component; motion is CSS-only and respects `prefers-reduced-motion` at the stylesheet level. |
| Increase Contrast | Component does not manage contrast; this is managed by the stylesheet and design tokens applied via CSS classes. |
| Differentiate Without Color | Color differentiation is managed by the stylesheet; the component does not rely on color alone for information. |

## Feature Flags

| Flag Key | Default | Description |
|----------|---------|-------------|
| — | — | No feature flags are implemented in this component. |

## Analytics

Not applicable: FlowHero is a composition component with no interactive behavior of its own. Analytics events are the responsibility of child elements (e.g., buttons within `children`).

## Privacy

Not applicable: FlowHero does not collect, store, or transmit any data.

## Logging

Not applicable: FlowHero does not perform logging.

## Platform Notes

- **TypeScript/React**: Source is `packages/web/packages/landing/src/flow/FlowHero.tsx`. The component is a function component that accepts a `FlowHeroProps` interface and returns a `ReactElement`. All props are rendered as ReactNodes to allow the host full control over element structure. The component uses conditional rendering (`{prop !== undefined && <...>}`) to show/hide optional sections.

- **SwiftUI**: Translate to a `VStack` composition with optional sections. The headline would be a `Text` or `VStack` containing a large heading, subheading below it (smaller text), optional buttons in an `HStack` below the text, optional metadata text at bottom of the primary section, and an optional image container below. Use `@ViewBuilder` to conditionally include optional elements. Maintain semantic structure by grouping headline and subheading together visually.

- **Compose**: Implement as a `Column` with vertically stacked elements. Use `CompositionLocal` or default parameters to allow optional sections to be omitted. The headline would be a large `Text`, subheading below it, optional `Row` containing buttons, optional metadata `Text`, and optional image. Conditional rendering in Compose uses the standard `if (condition)` syntax within the composition lambda.

- **AppKit / UIKit**: Use a `UIStackView` (vertical axis) containing: a `UIImageView` for the optional mark, a `UILabel` configured as a heading for the headline, a subtitle `UILabel` for the subheading, an optional horizontal `UIStackView` for buttons, an optional metadata `UILabel`, and an optional `UIImageView` or container for the shot. On macOS, use `NSStackView`; on iOS, build the hierarchy manually or use `UIStackView` with appropriate spacing and layout guides.

- **WinUI 3**: Build the composition using a `StackPanel` (Vertical orientation) containing: optional `Image` for the mark, a `TextBlock` with large font size for the headline (role="heading"), a `TextBlock` with smaller size for the subheading, an optional horizontal `StackPanel` for buttons, an optional `TextBlock` for metadata (with `TextTransform="UpperCase"` applied), and an optional `Image` or container for the shot. Use `Visibility="Collapsed"` for conditional sections rather than removing elements from the tree.

## Design Decisions

- **No section element**: The component renders a `<div>` instead of `<section>`. This avoids creating an unlabeled landmark region; the bands below the hero are the page's semantic landmarks. This aligns with the deck's `Hero` component design rationale.
- **Mark as ReactNode, not Image**: The mark is supplied as a ReactNode (not an `<img>` tag) so the host can provide its own image element with full control over alt text, sizing, and optimization. This decouples the component from image rendering logic.
- **Conditional rendering of optional sections**: Optional props are checked with `!== undefined` before rendering their containers. This allows hosts to pass `null` or omit the prop entirely to hide sections. Empty strings will still render; hosts should use `undefined` to suppress rendering.
- **No Cta wrapper around children**: The `children` are bare `Btn` elements, not wrapped in a `Cta` component. The `.lp-hero-actions` class is already the centered, wrapping flex row; a nested `Cta` would create conflicting spacing (0.75rem gap in `Cta` wins over the hero's own spacing), leaving the hero's layout inert.
- **Metadata uppercase by stylesheet**: The `meta` text is uppercased via CSS transform, not JavaScript. Hosts can opt out per-instance by overriding the transform with inline styles if needed (e.g., for product names that must not be all-caps per brand guidelines).

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| Semantic HTML | passed | Accessibility |
| Required props enforced | passed | Type Safety |
| Conditional rendering | passed | Performance |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation from source analysis |
