---
id: e0b59d60-0a56-4bf4-85cb-fb0e58170f8e
title: Band
domain: agenticdevelopertoolkit://recipes/band
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Horizontal section of a flow page layout with tone variation and optional
  diagonal seam.
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

# Band

## Overview

Band is a semantic section container that divides a flow page into horizontal regions. Each band is sized to its content and can adopt one of three tones (dark, soft, or paper) to create visual rhythm. An optional diagonal seam at the top creates a visual overlap with the band above. The seam uses CSS clip-path and negative margin to reveal the overlapped band's background rather than the page background.

## Behavioral Requirements

- **must-render-section**: Band MUST render as an HTML `<section>` element.
- **must-accept-id**: Band MUST accept an optional `id` prop that is forwarded to the rendered section.
- **must-support-three-tones**: Band MUST support three tone values: `'dark'`, `'soft'`, and `'paper'`.
- **must-default-dark-tone**: Band MUST default to tone `'dark'` if the `tone` prop is not specified.
- **must-accept-seam-prop**: Band MUST accept an optional `seam` prop that controls whether the diagonal cut is rendered.
- **must-default-seam-true**: Band MUST default to `seam: true` if the `seam` prop is not specified.
- **must-apply-seam-when-true**: When `seam` is `true`, Band MUST render the diagonal cut along the top edge using CSS clip-path and negative top margin derived from the `--lp-seam` CSS variable.
- **must-not-apply-seam-when-false**: When `seam` is `false`, Band MUST NOT apply the diagonal cut to the top edge.
- **must-wrap-children**: Band MUST wrap its children with the `Wrap` component.
- **must-accept-classname**: Band MUST accept an optional `className` prop.
- **must-apply-tone-class**: Band MUST apply a CSS class matching the pattern `lp-band--{tone}` corresponding to the tone prop.
- **must-apply-band-base-class**: Band MUST apply the CSS class `lp-band` to the section.
- **must-apply-seam-class-when-true**: When `seam` is `true`, Band MUST apply the CSS class `lp-band--seam` to the section.

## Appearance

- **Background**: Tone-dependent; `dark`, `soft`, and `paper` tones use distinct CSS color values defined by `lp-band--{tone}` classes.
- **Spacing**: Band height equals its content height; vertical padding is controlled by `Wrap` component. No predefined horizontal padding at band level.
- **Seam styling**: Diagonal cut uses CSS `clip-path` property with angle and depth determined by `--lp-seam` CSS variable. Negative top margin pulls band upward to overlap the band above.

## States

Not applicable: Band is a layout container without interactive states. The seam is a static visual property, not a state.

## Accessibility

- **Semantic role**: Band renders as a `<section>` element, providing semantic structure for assistive technology.
- **Heading hierarchy**: Content within Band should follow proper heading hierarchy starting with `<h2>` or lower (assuming a page-level `<h1>` exists).
- **No interactive content required**: Band itself has no interactive controls and requires no ARIA attributes beyond what its children provide.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| band-001 | must-render-section | Render `<Band />` | Output contains `<section>` element |
| band-002 | must-default-dark-tone | Render `<Band />` without tone prop | Rendered section includes class `lp-band--dark` |
| band-003 | must-accept-id | Render `<Band id="section-1" />` | Rendered section has `id="section-1"` |
| band-004 | must-support-three-tones, must-apply-tone-class | Render `<Band tone="soft" />` | Rendered section includes class `lp-band--soft` |
| band-005 | must-support-three-tones, must-apply-tone-class | Render `<Band tone="paper" />` | Rendered section includes class `lp-band--paper` |
| band-006 | must-default-seam-true, must-apply-seam-class-when-true | Render `<Band />` without seam prop | Rendered section includes class `lp-band--seam` |
| band-007 | must-not-apply-seam-when-false | Render `<Band seam={false} />` | Rendered section does not include class `lp-band--seam` |
| band-008 | must-apply-band-base-class | Render `<Band />` | Rendered section includes class `lp-band` |
| band-009 | must-accept-classname | Render `<Band className="custom-class" />` | Rendered section class list includes `custom-class` |
| band-010 | must-wrap-children | Render `<Band><p>Content</p></Band>` | Output contains `<Wrap>` wrapping the children |

## Edge Cases

- **Multiple classes**: When `seam`, `tone`, and `className` are all provided, all resulting classes (`lp-band`, `lp-band--{tone}`, `lp-band--seam`, and custom class) MUST be present in the section's class list.
- **Empty children**: Band MUST accept empty or no children and render without error. The `Wrap` component determines rendering behavior for empty content.
- **Falsy className**: If `className` is an empty string or falsy, it MUST NOT add extra spaces or broken classes to the section; filtering MUST remove it from the class list.
- **Tone with seam combinations**: All three tones (dark, soft, paper) MUST work with both `seam: true` and `seam: false` without conflict. On `tone="paper"`, the seam controls the top edge only; paper cuts its own foot regardless of the seam prop.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `id` | `string` | undefined | Optional HTML id attribute for the section |
| `tone` | `'dark' \| 'soft' \| 'paper'` | `'dark'` | Background tone and color scheme |
| `seam` | `boolean` | `true` | Whether to render the diagonal cut at the top edge |
| `className` | `string` | undefined | Additional CSS classes to apply to the section |
| `children` | `ReactNode` | (required) | Content to render inside the band, wrapped with Wrap |

## Deep Linking

Not applicable: Band is a layout container and does not support deep linking.

## Localization

Not applicable: Band has no user-facing strings.

## Accessibility Options

- **Reduce Motion**: Seam rendering does not involve animation; no motion reduction required.
- **Increase Contrast**: Tone backgrounds MUST maintain sufficient contrast ratios per WCAG 2.1 AA with text and controls rendered within. This is verified via the tone's CSS color values, not Band itself.
- **Differentiate Without Color**: Seam is a visual boundary; if seams are critical to page structure, content should include text or heading hierarchy so meaning is not conveyed by seam presence alone.

## Feature Flags

Not applicable: Band has no feature-gated behavior.

## Analytics

Not applicable: Band is a layout container with no user interaction.

## Privacy

Not applicable: Band does not collect, store, or transmit data.

## Logging

Not applicable: Band has no operational events to log.

## Platform Notes

- **TypeScript/Web**: Implemented in `packages/web/packages/landing/src/flow/Band.tsx`. Uses CSS classes `lp-band`, `lp-band--{tone}`, and `lp-band--seam` for styling. Seam uses CSS `clip-path` and negative top margin derived from `--lp-seam` CSS variable. Children are wrapped with the `Wrap` component, which handles horizontal padding and content alignment.

- **SwiftUI**: Port as a `VStack` or `ZStack` wrapping a vertical container. Map tones to distinct background colors using `background(_:)`. Implement seam as an overlay shape with clip-path effect; use negative padding/offset to pull the band upward into the overlap region. Use `@ViewBuilder` for children to match Band's flexible content.

- **Compose**: Implement as a `Box` or `Column` with tone-mapped background. Use `Modifier.clip()` with a custom shape or `Brush` for the diagonal seam effect. Apply negative margin or offset via `Modifier.offset()` to achieve the overlap. Wrap children in a horizontal padding/margin wrapper equivalent to `Wrap`.

- **AppKit / UIKit**: On iOS, use `UIView` subclass with `CAShapeLayer` for clip-path; set `clipsToBounds: true`. On macOS, use `NSView` with `CAShapeLayer` for clipping. Map tone to `backgroundColor` or gradient. Implement seam as a shape layer with negative frame offset. Wrap children in a container view that applies horizontal padding.

- **WinUI 3**: Implement as a `Grid` or `StackPanel` (Vertical orientation). Set `Background` to a `SolidColorBrush` or `LinearGradientBrush` mapped to the tone. For the seam, use `Geometry` and `ClipGeometry` or `Canvas` to render the diagonal shape; apply negative `Margin` to offset upward. Wrap children in a `Viewbox` or inner `StackPanel` with `Padding` for horizontal spacing equivalent to Wrap.

## Design Decisions

- **Content height**: Band is sized to its content, not to a fixed height or viewport unit. This distinguishes it from a full-screen container and allows bands to flex based on content.
- **Seam mechanics**: The seam uses clip-path and negative margin together. Both are derived from the same `--lp-seam` CSS variable to prevent visual drift. The seam is not animated; it is a static visual property toggled by the boolean `seam` prop.
- **Tone naming**: Tones are named by their visual role (`dark`, `soft`, `paper`), not by semantic meaning (e.g., not "primary", "secondary"), to remain flexible as design systems evolve.
- **Paper tone behavior**: `tone="paper"` always cuts its own foot (bottom edge), regardless of the `seam` prop. The `seam` prop controls only the top edge. This is a design convention captured in the JSDoc but not enforced at the component level.
- **Wrap dependency**: Band always wraps children with `Wrap` to ensure consistent horizontal padding and alignment across all bands. This is non-configurable; developers cannot override Wrap's behavior per Band instance.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| WCAG 2.1 AA Contrast | requires-verification | Accessibility |
| Semantic HTML | passed | Accessibility |
| Keyboard Navigation | not-applicable | Accessibility |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Generated | Initial creation from source |
