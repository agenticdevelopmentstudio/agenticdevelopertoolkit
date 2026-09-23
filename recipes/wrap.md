---
id: 51d3b1ba-ced7-4c08-8a63-c83094d91299
title: Wrap
domain: agenticdevelopertoolkit://recipes/wrap
type: ingredient
version: 1.1.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Layout wrapper that constrains content width while allowing full-width backgrounds
  on the screen.
platforms:
- typescript
- web
tags:
- layout
- container
- landing
- content-column
depends-on: []
related:
- agenticdevelopertoolkit://recipes/screen
- agenticdevelopertoolkit://recipes/deck
references: []
approved-by: ''
approved-date: ''
---

# Wrap

## Overview

Wrap is a presentational layout component that renders a `div` element containing child content. It applies a consistent CSS class (`lp-wrap`) and optionally accepts additional CSS classes, filtering out falsy values. The component enables a screen to paint edge-to-edge while constraining the logical content to a single centered column.

## Behavioral Requirements

- **render-children**: Component MUST render all child elements unchanged.
- **apply-lp-wrap-class**: Component MUST apply the class `lp-wrap` to the rendered div element.
- **class-composition**: Component MUST combine `lp-wrap` with an optional `className` prop, filtering out falsy values and joining the result with a space separator.
- **constrains-width**: Component MUST constrain its content to the smaller of the available width minus a fixed `2.5rem` gutter and the `--lp-measure` custom property (default `70rem`).
- **centers-horizontally**: Component MUST center itself horizontally within its containing block via `margin-inline: auto`.

## Appearance

Wrap itself accepts no appearance-related props, but it is not stylistically inert: it ships the `.lp-wrap` class as part of the landing package's own stylesheet, not the consuming application's. The rule lives at `packages/web/packages/landing/src/css/base.css:271`:

```css
.lp-wrap {
  width: min(100% - 2.5rem, var(--lp-measure, 70rem));
  margin-inline: auto;
}
```

This caps content at `--lp-measure` (default `70rem`) minus a `2.5rem` gutter, and centers it horizontally with `margin-inline: auto`.

## States

Not applicable: Wrap is a static, non-interactive container with no state-dependent behavior.

## Accessibility

Not applicable: Wrap is a transparent layout container that passes all content through to the DOM. Accessibility roles and labels are determined by the child elements it contains, not by Wrap itself.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| wrap-001 | render-children | `<Wrap><span>Hello</span></Wrap>` | Rendered output includes `<span>Hello</span>` |
| wrap-002 | apply-lp-wrap-class | `<Wrap><div></div></Wrap>` | Rendered div has class `lp-wrap` |
| wrap-003 | class-composition | `<Wrap className={undefined}><div></div></Wrap>` | Rendered div has only the `lp-wrap` class, no `undefined` token in the class attribute |
| wrap-004 | class-composition | `<Wrap className=""><div></div></Wrap>` | Rendered div has only the `lp-wrap` class |
| wrap-005 | class-composition | `<Wrap className="custom"><div></div></Wrap>` | Class attribute reads exactly `lp-wrap custom` |
| wrap-006 | constrains-width | `<Wrap><div></div></Wrap>` rendered in a 1200px-wide block with `--lp-measure` unset | Computed width is `min(100% - 2.5rem, 70rem)` — `70rem` (1120px at a 16px root) rather than the full 1200px |
| wrap-007 | centers-horizontally | `<Wrap><div></div></Wrap>` rendered in a block wider than `--lp-measure` | Computed `margin-inline-start` equals computed `margin-inline-end` |

## Edge Cases

- **Empty children**: Wrap MUST render an empty div when children is undefined, null, or an empty array. The `lp-wrap` class is still applied.
- **Undefined or empty-string className**: TypeScript's `className?: string` signature restricts the prop to `string | undefined`, so only these two falsy shapes can reach `.filter(Boolean)`; both are dropped, leaving only `lp-wrap` (see **class-composition**).
- **Direct child of a non-centered Screen**: When Wrap is a direct child of `.lp-screen` (excluding `.lp-screen--center`), it additionally receives `min-height: max(0px, calc(100vh / 3 - var(--lp-screen-pad-top, ...)))` and `align-content: safe center` (`base.css:306`). This is Screen's rule reaching into its Wrap child, not a property of Wrap in isolation. The `safe` keyword falls back to start alignment when the content is taller than that band, so overflow pushes content down into view rather than up and out of reach behind the fixed header.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `--lp-measure` | CSS custom property (length) | `70rem` | Maximum content width Wrap caps its children at. |
| gutter | fixed, not configurable | `2.5rem` | Space reserved on each side before the `--lp-measure` cap applies (`100% - 2.5rem`). |

## Deep Linking

Not applicable: Wrap is a layout container with no semantic URL representation or deep-linking capability.

## Localization

Not applicable: Wrap contains no user-facing strings or localization concerns.

## Accessibility Options

Not applicable: Wrap is a transparent container that does not respond to accessibility display options.

## Feature Flags

Not applicable: Wrap is a foundational layout component with no feature flag gates.

## Analytics

Not applicable: Wrap is a non-interactive container that produces no user interaction events.

## Privacy

Not applicable: Wrap does not collect, store, or transmit any data.

## Logging

Not applicable: Wrap is a simple presentational component with no noteworthy lifecycle or state change events to log.

## Platform Notes

- **TypeScript / Web**: React functional component in `packages/web/packages/landing/src/deck/Wrap.tsx`. Accepts `children: ReactNode` and `className?: string`, combined via `['lp-wrap', className].filter(Boolean).join(' ')`. Width and centering come from `.lp-wrap` in `packages/web/packages/landing/src/css/base.css:271` (`width: min(100% - 2.5rem, var(--lp-measure, 70rem)); margin-inline: auto`).
- **SwiftUI**: `.frame(maxWidth: measure).padding(.horizontal)` on the content, inside a container that centers it horizontally, where `measure` mirrors `--lp-measure` (default `70rem`) and the horizontal padding stands in for the `2.5rem` gutter.
- **Compose**: a horizontally centered `Box` whose child carries `Modifier.widthIn(max = measure).padding(horizontal = gutter)`, capping width at `measure` and insetting it by the gutter before centering.
- **AppKit / UIKit**: constrain the content to a `layoutMarginsGuide` (or an explicit readable-width constraint) capped at `measure` and centered in its superview, rather than subclassing `NSView` / `UIView`.
- **WinUI 3**: a `ContentControl` (or a `Border` with a single `Child`) with `MaxWidth` set to `measure`, `HorizontalAlignment="Center"`, and `Padding` for the gutter. Wrap holds one content tree, not a collection, so no `VisualStateManager` or visibility converters are needed.

## Design Decisions

**Decision**: Compose the div's class list with `['lp-wrap', className].filter(Boolean).join(' ')` rather than a conditional ternary.
**Rationale**: `.filter(Boolean)` handles `className` being `undefined` or an empty string uniformly, without an explicit type guard, even though the `className?: string` signature already restricts the prop to those two falsy shapes at compile time.
**Approved**: pending

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| [dynamic-type-support](agenticdevelopercookbook://compliance/accessibility#dynamic-type-support) | passed | Accessibility |
| [semantic-markup](agenticdevelopercookbook://compliance/accessibility#semantic-markup) | passed | Accessibility |

Both rest on `base.css:271`: the cap and gutter are expressed in `rem`, so they scale with root font-size / type-size settings, and Wrap renders a plain `div` with no ARIA roles or attributes of its own to misuse.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.1.0 | 2026-09-22 | Mike Fullerton | Lint pass: renamed requirements to subject-only kebab-case and merged the className ones into class-composition; added constrains-width and centers-horizontally with vectors; corrected Appearance to cite the package stylesheet; documented --lp-measure and the gutter under Configuration; fixed Platform Notes for SwiftUI, Compose, AppKit/UIKit, and WinUI 3; reformatted Design Decisions and replaced Compliance with a checks table; added tags, related entries, and the Screen band/safe-center edge case |
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
