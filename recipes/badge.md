---
id: 245c45fe-4724-4a8c-bfef-0049e09c18e1
title: Badge
domain: agenticdevelopercookbook://ingredients/badge
type: ingredient
version: 1.0.1
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: 'Small pill-shaped status/tone label rendered as a span with six color variants:
  neutral, accent, orange, blue, success, error.'
platforms:
- web
tags:
- ui
- badge
- status-indicator
depends-on: []
related: []
references: []
---

# Badge

## Overview

Badge is a small, non-interactive status/tone label rendered as an inline
`<span>`. Per the source comment, it is "a 1:1 match of the deployed header
badge (`.adh-header__badge`)": a pill-shaped, mono-spaced, uppercase chip
with a 1px border, sized to sit inline with surrounding text or controls.
Callers select one of six color variants; the component itself carries no
semantic meaning beyond the variant name.

## Behavioral Requirements

- **must-render-as-span**: Badge MUST render its root element as a `<span>`.
- **must-set-data-slot-attribute**: Badge MUST set a `data-slot` attribute
  with the value `"badge"` on its root element.
- **must-support-six-variants**: Badge MUST support exactly six `variant`
  values: `neutral`, `accent`, `orange`, `blue`, `success`, `error`.
- **must-default-to-neutral-variant**: Badge MUST use the `neutral` variant
  when no `variant` prop is supplied.
- **must-render-pill-shape**: Badge MUST render with fully rounded
  (pill-shaped) corners.
- **must-render-transparent-background**: Badge MUST render with a
  transparent background.
- **must-render-bordered**: Badge MUST render with a visible border on all
  sides.
- **must-share-tone-color-between-border-and-text**: For a given variant,
  Badge MUST render its border color and its text color using the same
  tone color.
- **must-uppercase-text**: Badge MUST render its text content transformed to
  uppercase.
- **must-prevent-text-wrapping**: Badge MUST prevent its content from
  wrapping onto multiple lines.
- **must-apply-inline-child-spacing**: Badge MUST apply a fixed gap between
  its inline children (e.g., an icon and a label).
- **must-size-nested-icons**: Badge MUST render any nested SVG element at a
  fixed size and MUST prevent that SVG from shrinking below that size.
- **must-forward-span-props**: Badge MUST forward all props other than
  `className` and `variant` to the underlying `<span>` element.
- **must-merge-caller-classname**: Badge MUST merge a caller-supplied
  `className` with its own computed classes rather than replacing them.
- **may-render-without-children**: Badge MAY be rendered with no children.
- **may-include-icon-content**: Badge MAY contain an icon (SVG) alongside or
  instead of text content.

## Appearance

- **Corner radius**: Fully rounded (pill) — `rounded-full`.
- **Padding**: 0.15rem vertical × 0.45rem horizontal.
- **Font**: Monospace family, weight 500 (medium), size 0.6rem, line-height
  1.4, letter-spacing 0.08em, text transformed to uppercase.
- **Background**: Transparent.
- **Foreground/Text**: Variant tone color (see table below).
- **Border**: 1px (default border width), color equal to the variant's tone
  color.
- **Shadow**: None. No shadow classes are applied by the source.
- **Min/Max size**: None specified. The component is `inline-flex` with no
  explicit width or height constraints; it sizes to its content.
- **Layout**: `inline-flex`, children vertically centered
  (`items-center`), 0.25rem gap between children (`gap-1`), content does not
  wrap (`whitespace-nowrap`).
- **Nested icon sizing**: Any descendant `<svg>` is rendered at 0.75rem
  (`size-3`) and does not shrink (`shrink-0`).

**Variant tone colors:**

| Variant | Border / text color token |
|---------|---------------------------|
| `neutral` (default) | `apt-border` (border) / `apt-text-dim` (text) |
| `accent` | `apt-gold` |
| `orange` | `apt-orange` |
| `blue` | `apt-blue` |
| `success` | `apt-green` |
| `error` | `apt-red` |

## States

Not applicable: Badge is a static, non-interactive presentational component
with no pressed, disabled, focused, or loading states.

## Accessibility

Not applicable: Badge is a static, non-interactive presentational component
rendered as a `<span>`. It carries no semantic content beyond what the caller
provides as text children; accessibility requirements (keyboard navigation,
screen reader announcements, focus states) apply only when Badge wraps
interactive content supplied by its caller.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| badge-001 | must-render-as-span | `<Badge>Text</Badge>` | Rendered root DOM node's tag name is `span`. |
| badge-002 | must-set-data-slot-attribute | `<Badge>Text</Badge>` | Rendered root node has attribute `data-slot="badge"`. |
| badge-003 | must-support-six-variants | Render with `variant` set to each of `neutral`, `accent`, `orange`, `blue`, `success`, `error` in turn | Each render succeeds and the root node's class list includes the corresponding tone classes (e.g. `border-apt-gold text-apt-gold` for `accent`). |
| badge-004 | must-default-to-neutral-variant | `<Badge>Text</Badge>` (no `variant` prop) | Rendered root node's class list includes `border-apt-border` and `text-apt-text-dim`. |
| badge-005 | must-render-pill-shape | `<Badge>Text</Badge>` | Rendered root node's class list includes `rounded-full`. |
| badge-006 | must-render-transparent-background | `<Badge>Text</Badge>` | Rendered root node's class list includes `bg-transparent`. |
| badge-007 | must-render-bordered | `<Badge>Text</Badge>` | Rendered root node's class list includes `border`. |
| badge-008 | must-share-tone-color-between-border-and-text | `<Badge variant="error">Text</Badge>` | Rendered root node's class list includes both `border-apt-red` and `text-apt-red`. |
| badge-009 | must-uppercase-text | `<Badge>text</Badge>` | Rendered root node's class list includes `uppercase`. |
| badge-010 | must-prevent-text-wrapping | `<Badge>A very long label</Badge>` | Rendered root node's class list includes `whitespace-nowrap`. |
| badge-011 | must-apply-inline-child-spacing | `<Badge><svg data-testid="icon" />Label</Badge>` | Rendered root node's class list includes `gap-1`. |
| badge-012 | must-size-nested-icons | `<Badge><svg data-testid="icon" /></Badge>` | Rendered `<svg>` element's class list includes `size-3` and `shrink-0`. |
| badge-013 | must-forward-span-props | `<Badge id="my-badge" title="tip">Text</Badge>` | Rendered root node has attributes `id="my-badge"` and `title="tip"`. |
| badge-014 | must-merge-caller-classname | `<Badge className="custom-class">Text</Badge>` | Rendered root node's class list includes both `custom-class` and the component's computed classes (e.g. `rounded-full`). |

## Edge Cases

- **Null and empty input**: `<Badge />` with no children MUST render an
  empty `<span>` without throwing; the source performs no required-children
  validation. Passing `variant={undefined}` MUST behave identically to
  omitting the prop (falls back to `neutral` per `must-default-to-neutral-variant`).
- **Boundary values**: A `variant` value outside the six accepted literals
  (only reachable by bypassing the `VariantProps` TypeScript type, e.g. from
  untyped/unchecked data) is resolved by the `class-variance-authority`
  library, whose implementation is not part of `badge.tsx`. Passing an
  unrecognized variant key results in no variant classes being applied to the
  root element.
- **Concurrent access**: Not applicable. Badge is a stateless,
  side-effect-free presentational function component with no internal
  state, refs, or shared mutable resources.
- **Error states**: Badge performs no fallible operations (no network
  calls, no parsing, no file/database I/O) and contains no `try`/`catch` or
  error-boundary logic. Any rendering failure would surface as a standard
  React rendering error, not Badge-specific behavior.
- **Offline or disconnected state**: Not applicable. Badge performs no
  network communication.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `variant` | enum: `neutral` \| `accent` \| `orange` \| `blue` \| `success` \| `error` | `neutral` | Selects the tone (border/text color) of the badge. |
| `className` | `string` | none | Additional CSS classes merged with the component's computed classes. |
| `...props` | `React.ComponentProps<"span">` | none | Any other native `<span>` attribute or event handler; forwarded to the root element. |

## Deep Linking

Not applicable: Badge is a non-navigable presentational primitive with no
routing or deep-link logic.

## Localization

Badge defines no string constants of its own. All text content is supplied
by the caller as `children`; there are no localization keys owned by this
component.

## Accessibility Options

Not applicable: Badge is a static presentational component with no animations,
dynamic behavior, or color-dependent patterns that require platform accessibility
options like reduced motion, increased contrast, or color differentiation.

## Feature Flags

Not applicable: Badge is a foundational UI primitive with no feature-flag
references in the source.

## Analytics

Not applicable: Badge is a foundational presentational component with no user
interaction or telemetry instrumentation.

## Privacy

Badge collects no data. The component contains no data collection, storage,
transmission, or retention logic. All content and behavior is determined by
the caller's supplied children and props.

## Logging

Not applicable: Badge is a foundational presentational component with no
logging or diagnostic instrumentation.

## Platform Notes

- **SwiftUI**: Start from a `Text` view with a `.padding` and `.border` modifier
  to achieve the pill shape and tone-color border. Use a `@State`-driven conditional
  modifier chain or a custom `ViewModifier` to apply the six tone variants as
  distinct color sets on `.foregroundColor` and `.border`. SwiftUI has no built-in
  `cva`-like composition library; variant selection must be explicitly mapped via
  a switch or dictionary lookup on the variant parameter.

- **Compose**: Use a `Surface` or `Box` composable with `shape = RoundedCornerShape(100)`
  for the pill outline, `border = BorderStroke(1.dp, color)` for the 1px tone-colored
  border, and `background = Color.Transparent`. Nest a `Text` with `fontFamily = FontFamily.Monospace`,
  `fontSize = 9.6sp`, `fontWeight = FontWeight.Medium`, and `textTransform = TextTransform.Uppercase`.
  Compose layout composables (`Row`, `Box`) provide the spacing and sizing equivalent
  to the web component's inline-flex and gap properties.

- **React/Web**: Implemented exactly as shown in `packages/web/packages/ui/src/components/badge.tsx`:
  a `<span>` styled with Tailwind utility classes composed via `class-variance-authority`
  (`cva`), with `variant` selecting one of six predefined class sets and `neutral` as
  the `cva` `defaultVariants` value. The root element is `inline-flex` with
  `items-center`, `gap-1`, and `whitespace-nowrap` for layout; nested SVGs are sized
  with `[&_svg]:size-3 [&_svg]:shrink-0`.

- **AppKit / UIKit**: Use an `NSStackView` (macOS) or `UIStackView` (iOS) in
  horizontal axis, with `alignment = .center` and `spacing = 4pt` (equivalent to the web
  component's `gap-1`). Set `layer.cornerRadius` to half the frame height for the pill
  shape, `layer.borderColor` to the tone color, and `layer.borderWidth = 1`. Nest an `NSTextField`
  or `UILabel` for the text, setting `font = .monospacedSystemFont(ofSize: 9.6, weight: .medium)`,
  `textColor = toneColor`, and applying `uppercaseString` transformation. Variant selection
  is a switch on a variant property that binds the six tone colors (`neutral`/`accent`/`orange`/`blue`/`success`/`error`)
  to the view's border and text colors.

- **WinUI 3**: No conformant `Badge` control ships in WinUI 3. The closest
  starting point is a `Border` (for the pill shape via `CornerRadius`, 1px `BorderBrush`,
  and transparent `Background`) wrapping a `TextBlock` (for the mono, letter-spaced,
  uppercase label). Unlike the source's `cva`-driven variant system, WinUI 3 has no
  built-in multi-variant style composition, so the six tone variants would need a custom
  `Style` per tone (or a converter bound to a `variant` property) rather than a single
  reusable class list. Set `TextBlock.CharacterSpacing` to `80` (equivalent to 0.08em)
  and `TextBlock.Text = text.ToUpperInvariant()` for uppercase rendering. Use a `StackPanel`
  in horizontal orientation with `Spacing = 4` to nest an optional icon alongside text.

## Design Decisions

- The `variant` names are color/tone names (`neutral`, `accent`, `orange`,
  `blue`, `success`, `error`), not semantic status names. The source
  comment records that in the deployed header this badge matches, `orange`
  is used for "Development Preview" and `blue` for "Coming Soon" — but
  `badge.tsx` itself has no awareness of that mapping. Any semantic
  meaning attached to a given tone is the caller's convention, not a
  guarantee of this component.

- Border color and text color are deliberately identical per variant (see
  **must-share-tone-color-between-border-and-text**) so the badge reads as
  a single-tone outline chip rather than a filled badge; this is a direct,
  unconditional mapping in the source's `cva` variant table, not a
  configurable option.

- "Differentiate Without Color" (see Accessibility Options) is not
  addressed by the source: variant identity is communicated solely through
  the border/text tone color (e.g. `border-apt-gold`/`text-apt-gold` for
  `accent`), with no secondary non-color cue (icon, pattern, or label
  difference) distinguishing one variant from another.

## Compliance

Not applicable: Badge is a foundational UI primitive requiring no regulatory
compliance checks.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.1 | 2026-09-22 | | Apply completeness rules; replace over-used review markers with "Not applicable" statements and provide platform translation guidance |
| 1.0.0 | | | Initial creation |
