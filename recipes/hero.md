---
id: fae23662-e69b-4472-9c7d-049feadf1211
title: Hero
domain: agenticdevelopercookbook://ingredients/hero
type: ingredient
version: 1.0.0
status: review
language: en
created: 2026-09-22
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Landing page hero block with mark, headline, tagline, and call-to-action
  slots.
platforms:
- typescript
- web
tags:
- landing
- hero
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Hero

## Overview

The Hero component is a centered landing screen containing a mark (brand image), headline, tagline, and optional child content (CTA buttons, trust badges, status pills). It is the sole centered screen on a landing page and is used to make a single value proposition claim to the visitor.

## Behavioral Requirements

- **must-render-headline**: Component MUST render the `headline` prop as the primary claim statement within an `<h1>` element.
- **must-render-tagline**: Component MUST render the `tagline` prop as supporting text within a `<p>` element with class `lp-tag`.
- **must-accept-mark**: Component MUST accept an optional `mark` prop as a `ReactNode`, allowing the host to supply its own `<Image>` or `<img>` element before the headline.
- **must-accept-children**: Component MUST accept optional `children` as a `ReactNode` to compose call-to-action, trust, and status pill components below the tagline.
- **must-support-glow**: Component MUST support a `glow` prop (default `true`) that controls the glow effect on the Screen container.
- **must-support-id**: Component MUST accept an optional `id` prop to set the HTML `id` attribute for semantic identification.
- **must-center-content**: Component MUST center all content horizontally and render as a centered Screen (align="center").
- **must-render-as-div**: Component MUST render the Screen container with `as="div"` to output semantic HTML.

## Appearance

- **Corner radius**: Inherited from Screen component; no additional radius applied
- **Padding**: Inherited from Screen component and `lp-hero` CSS class
- **Font**: Headline uses `<h1>` default; tagline uses `<p>` default with `lp-tag` class styling
- **Background**: Inherited from Screen component (centred screen exception, per `css/blocks.css` comment)
- **Foreground/Text**: Headline color and tagline color defined by `lp-tag` class in `css/blocks.css`
- **Border**: None
- **Shadow**: Glow effect applied via Screen component when `glow={true}` (default)
- **Min/Max size**: No explicit constraints; inherits Screen sizing

## States

| State | Appearance change |
|-------|------------------|
| Default (glow enabled) | Screen renders with glow effect on Screen component |
| Glow disabled | Screen renders without glow effect when `glow={false}` |

## Accessibility

- **Role**: Section landmark (div with implicit section role; should be wrapped in semantic landmark by host if needed)
- **Label requirements**: Headline (`<h1>`) serves as the primary heading; tagline (`<p>`) provides context
- **Announce state changes**: Not applicable; Hero is a static presentation component with no interactive state changes
- **Minimum tap target**: Not applicable; Hero contains no interactive controls directly. Child components (CTA buttons, etc.) MUST meet 44×44pt minimum touch target size
- **Keyboard navigation**: Not applicable; Hero is non-interactive. Child components MUST be keyboard navigable

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|----|----|----|
| hero-001 | must-render-headline | `headline="Claim"` | `<h1>Claim</h1>` rendered in output |
| hero-002 | must-render-tagline | `tagline="Supporting text"` | `<p class="lp-tag">Supporting text</p>` rendered in output |
| hero-003 | must-accept-mark | `mark={<img src="logo.svg" />}` | Mark element renders before h1 |
| hero-004 | must-accept-children | `children={<button>CTA</button>}` | CTA button renders after tagline |
| hero-005 | must-support-glow | `glow={true}` | Screen component receives `glow={true}` |
| hero-006 | must-support-glow | `glow={false}` | Screen component receives `glow={false}` |
| hero-007 | must-support-id | `id="hero-section"` | Output div has `id="hero-section"` |
| hero-008 | must-center-content | Any props | Screen component receives `align="center"` and `className="lp-hero"` |
| hero-009 | must-render-as-div | Any props | Screen component receives `as="div"` |

## Edge Cases

- **Mark omitted**: When `mark` is undefined, no image element renders; headline and tagline render as expected.
- **Children omitted**: When `children` is undefined, CTA/trust/status sections are not rendered; headline and tagline render as expected.
- **Empty headline or tagline**: No validation in component; empty or whitespace-only strings render as empty h1/p elements. Host is responsible for providing non-empty content.
- **Headline with ReactNode children**: Headline accepts ReactNode, allowing nested elements (emphasis, links, etc.); host is responsible for semantic correctness.
- **Multiple CTA/trust/status children**: Children prop accepts any ReactNode; host may compose multiple CTA, Trust, and StatusPill components in any order.
- **glow omitted**: Defaults to `true`; glow effect is enabled unless explicitly set to `false`.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `id` | string (optional) | undefined | HTML id attribute for the root div |
| `mark` | ReactNode (optional) | undefined | Mark/logo image element supplied by host |
| `headline` | ReactNode | required | Primary value proposition claim |
| `tagline` | ReactNode | required | Supporting claim text |
| `children` | ReactNode (optional) | undefined | CTA, Trust, StatusPill components |
| `glow` | boolean | `true` | Enable/disable glow effect on Screen |

## Deep Linking

Not applicable: Hero is a presentation component and does not define deep linking patterns. Host application is responsible for linking if needed.

## Localization

Not applicable: Hero accepts ReactNode props for headline, tagline, and children. The host is responsible for providing localized content.

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | Nothing in the hero animates: the glow is a static radial gradient (`.lp-glow` in base.css), not a keyframe animation. base.css also carries a `prefers-reduced-motion` reset that sets `animation: none` and `transition: none` on every element of a deck or flow page, so any host-added motion inside the hero stops too. |
| Increase Contrast | Not implemented in source. Behavior undefined. |
| Differentiate Without Color | Not applicable; Hero uses no color-only differentiation. |

## Feature Flags

Not applicable: Hero component has no feature flags. Host application may control visibility via conditional rendering.

## Analytics

Not applicable: Hero component is non-interactive and does not emit analytics events directly.

## Privacy

Not applicable: Hero is a presentation component and does not collect, store, or transmit user data.

## Logging

Not applicable: Hero component has no logging.

## Platform Notes

- **TypeScript/Web**: Defined in `packages/web/packages/landing/src/blocks/Hero.tsx`. Renders a `Screen` component with `align="center"` and `className="lp-hero"`. The component never supplies its own `<Image>` or `<img>` element; the host provides mark via `ReactNode` to avoid a top-level `next/image` dependency.
- **SwiftUI**: Use a VStack with `alignment: .center` and spacing controlled by a custom modifier. Render the mark (image), headline (Text with large font weight), tagline (Text with smaller font), and child views in vertical order. Apply a glow modifier conditionally based on the glow parameter.
- **Compose**: Use a Column with `horizontalAlignment: Alignment.CenterHorizontally` and `modifier: Modifier.fillMaxWidth()`. Render the mark (Image composable), headline (Text with `style: MaterialTheme.typography.headlineLarge`), tagline (Text with `style: MaterialTheme.typography.bodyLarge`), and child composables. Apply a conditional shadow or glow effect.
- **AppKit / UIKit**: Use a vertical UIStackView or SwiftUI VStack with `alignment: .center`. Render the mark (UIImageView or Image), headline (UILabel or Text with large font), tagline (UILabel or Text with secondary styling), and child views. Apply a conditional shadow effect via CALayer for glow.
- **WinUI 3**: Use a StackPanel with `Orientation: Vertical` and `HorizontalAlignment: Center`. Bind the mark (Image control), headline (TextBlock with `FontSize: 32` and `FontWeight: Bold`), tagline (TextBlock with secondary foreground), and child controls. Apply a ThemeShadow or DropShadowPanel for glow effect based on a glow boolean property.

## Design Decisions

- Hero accepts `mark` as a ReactNode rather than a file path or URL to defer image loading and styling to the host, avoiding a hard dependency on `next/image`.
- The component renders as a bare `<div>` (via `Screen as="div"`) rather than a `<section>`, allowing the host to wrap it in appropriate semantic landmarks if needed.
- Glow defaults to `true` to match the expected landing page behavior; host can disable it for alternative layouts.
- No validation or error handling is performed on headline or tagline; host is responsible for providing meaningful content.

## Compliance

Not applicable: No security, WCAG, or platform compliance checks apply to a static presentation component.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
