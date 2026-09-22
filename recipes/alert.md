---
id: a56695f3-0205-4c9b-b724-53be608de2f0
title: Alert
domain: agenticdevelopercookbook://ingredients/alert
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: 'Inline, non-modal callout — a bordered, tonal box with an optional icon,
  title, and description; five color variants: default, info, success, error, accent.'
platforms:
- web
tags:
- ui
- alert
- feedback
depends-on: []
related: []
references: []
---

# Alert

## Overview

Alert (`packages/web/packages/ui/src/components/alert.tsx`) is an inline,
non-modal callout: a bordered, tonal box with an optional leading icon, a
title, and a description. Per the source comment, it is themed entirely from
`apt-*` status tokens. The module exports four names: `Alert` (the root
container), `AlertTitle` and `AlertDescription` (two positioned text
sub-components), and `alertVariants` (the standalone `cva` styling function).
Layout is CSS grid: the root reserves a first column for an optional icon and
a second column (`col-start-2`) for `AlertTitle`/`AlertDescription`; the
column layout only widens to make room for an icon when a direct `<svg>`
child is present.

## Behavioral Requirements

- **must-set-alert-role**: Alert MUST render its root element with
  `role="alert"`.
- **must-set-alert-data-slot**: Alert MUST render its root element with
  `data-slot="alert"`.
- **must-default-to-default-variant**: Alert MUST apply the `default`
  variant's styling when no `variant` prop is supplied.
- **must-support-five-variants**: Alert MUST support exactly five `variant`
  values: `default`, `info`, `success`, `error`, `accent`.
- **must-merge-caller-classname-alert**: Alert MUST merge a caller-supplied
  `className` with the selected variant's base classes rather than
  replacing them.
- **must-forward-div-props-alert**: Alert MUST forward all received props
  other than `variant` and `className` to its root `<div>`.
- **must-widen-grid-when-icon-present**: When Alert has a direct `<svg>`
  child, Alert MUST change its grid-template-columns from `0 1fr` to
  `1.25rem 1fr` and MUST add a column gap between them.
- **must-size-icon-child**: Alert MUST render any direct `<svg>` child at a
  fixed size of `1rem` × `1rem` and MUST offset it `0.125rem` downward from
  its row's top edge.
- **must-place-title-column-two**: AlertTitle MUST render in the grid's
  second column (`col-start-2`).
- **must-style-title-medium-weight**: AlertTitle MUST render its text with
  medium font weight.
- **must-merge-caller-classname-title**: AlertTitle MUST merge a
  caller-supplied `className` with its base classes rather than replacing
  them.
- **must-forward-div-props-title**: AlertTitle MUST forward all received
  props other than `className` to its root `<div>`.
- **must-place-description-column-two**: AlertDescription MUST render in
  the grid's second column (`col-start-2`).
- **must-style-description-small-muted**: AlertDescription MUST render its
  text at the `text-sm` size in the muted text color.
- **must-merge-caller-classname-description**: AlertDescription MUST merge
  a caller-supplied `className` with its base classes rather than
  replacing them.
- **must-forward-div-props-description**: AlertDescription MUST forward
  all received props other than `className` to its root `<div>`.
- **must-export-alert-variants**: The module MUST export `alertVariants` as
  a function usable independently of the `Alert` component.
- **should-compose-title-and-description-as-children**: Alert SHOULD be
  composed with `AlertTitle` and/or `AlertDescription` as children so their
  content aligns in the shared second grid column alongside an optional
  icon (see Design Decisions for rationale and the conditions under which a
  caller may deviate).
- **may-render-without-icon-title-or-description**: Alert MAY be rendered
  with no icon, no `AlertTitle`, and no `AlertDescription`; the root
  element places no constraint on child type or count.
- **may-accept-any-icon-element**: Alert MAY receive any element that
  renders as a literal `<svg>` tag as a leading child to trigger the
  icon-aware grid/sizing behavior; the component does not restrict which
  icon library produces that `<svg>`.

## Appearance

- **Corner radius**: `rounded-lg` (design-token corner radius; exact px
  value comes from the project's Tailwind theme, which is not part of this
  source file).
- **Padding**: `py-3 px-4` — 0.75rem vertical × 1rem horizontal.
- **Font**: Alert body text `text-sm` (0.875rem); `AlertTitle` adds
  `font-medium`; `AlertDescription` is also `text-sm`.
- **Background**: variant-dependent — `bg-apt-surface` (default),
  `bg-apt-blue/10` (info), `bg-apt-green/10` (success), `bg-apt-red/10`
  (error), `bg-apt-gold/10` (accent). Resolved colors are defined by the
  `apt-*` design tokens, not by this source file.
- **Foreground/Text**: `text-apt-text` for every variant (the text color
  class does not change per variant); `AlertDescription` specifically uses
  `text-apt-text-muted`. The icon color does vary per variant (see Border,
  below).
- **Border**: `border` (1px, Tailwind's default border width), color
  variant-dependent — `border-apt-border` (default), `border-apt-blue/40`
  (info), `border-apt-green/40` (success), `border-apt-red/40` (error),
  `border-apt-gold/40` (accent). The same color token also tints the
  variant's icon (`[&>svg]:text-apt-*`), except `default`, whose icon uses
  `text-apt-text-muted` instead of a status color.
- **Shadow**: None. No `shadow-*` class appears in `alertVariants`.
- **Min/Max size**: `w-full` (100% of container width); no explicit
  min/max height or width beyond that.
- **Layout**: `grid`, `items-start`, `gap-y-0.5` (0.125rem) between grid
  rows; `grid-cols-[0_1fr]` by default, widening to
  `grid-cols-[1.25rem_1fr]` with `gap-x-3` (0.75rem) when a direct `<svg>`
  child is present (`has-[>svg]:...`).

## States

| State | Appearance change |
|-------|------------------|
| Default | The variant's static appearance (see Appearance). This is the component's only state. |

Not applicable: Alert is a static, non-interactive presentational component; pressed, disabled, focused, and loading states do not apply.

## Accessibility

- Role/trait: `role="alert"` on the root element, for every variant.
  `AlertTitle` and `AlertDescription` carry no ARIA role of their own — they
  are plain `<div>`s identified only by their `data-slot` attribute.
- Label requirements: Not applicable: AlertTitle and AlertDescription are unstyled, positioned grid cells; callers provide content and manage any labeling strategy independently.
- Announce state changes: `role="alert"` makes the root an implicit ARIA
  live region (assertive, atomic, per the ARIA specification), so
  assistive technology announces the element's text content when it is
  inserted into the DOM or when that content changes. `alert.tsx` adds no
  further state-change handling beyond this native role behavior (no
  `aria-live` override, no imperative announce call).
- Minimum tap target: Not applicable: Alert is a non-interactive presentational container with no interactive controls or tap targets of its own.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| alert-001 | must-set-alert-role | `<Alert>Text</Alert>` | Rendered root node has attribute `role="alert"`. |
| alert-002 | must-set-alert-data-slot | `<Alert>Text</Alert>` | Rendered root node has attribute `data-slot="alert"`. |
| alert-003 | must-default-to-default-variant | `<Alert>Text</Alert>` (no `variant` prop) | Root node's class list includes `border-apt-border` and `bg-apt-surface`. |
| alert-004 | must-support-five-variants | Render with `variant` set to each of `default`, `info`, `success`, `error`, `accent` in turn | Each render succeeds; root node's class list includes the corresponding tone classes (e.g. `border-apt-red/40 bg-apt-red/10` for `error`). |
| alert-005 | must-merge-caller-classname-alert | `<Alert className="custom">Text</Alert>` | Root node's class list includes both `custom` and the variant's base classes (e.g. `rounded-lg`). |
| alert-006 | must-forward-div-props-alert | `<Alert id="my-alert" aria-live="polite">Text</Alert>` | Root node has attributes `id="my-alert"` and `aria-live="polite"`. |
| alert-007 | must-widen-grid-when-icon-present | `<Alert><svg data-testid="icon" />Text</Alert>` | Root node's resolved `grid-template-columns` is `1.25rem 1fr` and its class list includes `has-[>svg]:gap-x-3`. |
| alert-008 | must-size-icon-child | `<Alert><svg data-testid="icon" /></Alert>` | Root node's class list includes `[&>svg]:size-4` and `[&>svg]:translate-y-0.5`, applied to the direct `svg` child. |
| alert-009 | must-place-title-column-two | `<AlertTitle>Title</AlertTitle>` | Rendered node's class list includes `col-start-2`. |
| alert-010 | must-style-title-medium-weight | `<AlertTitle>Title</AlertTitle>` | Rendered node's class list includes `font-medium`. |
| alert-011 | must-merge-caller-classname-title | `<AlertTitle className="custom">Title</AlertTitle>` | Rendered node's class list includes both `custom` and `col-start-2`. |
| alert-012 | must-forward-div-props-title | `<AlertTitle id="t1">Title</AlertTitle>` | Rendered node has attribute `id="t1"`. |
| alert-013 | must-place-description-column-two | `<AlertDescription>Desc</AlertDescription>` | Rendered node's class list includes `col-start-2`. |
| alert-014 | must-style-description-small-muted | `<AlertDescription>Desc</AlertDescription>` | Rendered node's class list includes `text-sm` and `text-apt-text-muted`. |
| alert-015 | must-merge-caller-classname-description | `<AlertDescription className="custom">Desc</AlertDescription>` | Rendered node's class list includes both `custom` and `col-start-2`. |
| alert-016 | must-forward-div-props-description | `<AlertDescription id="d1">Desc</AlertDescription>` | Rendered node has attribute `id="d1"`. |
| alert-017 | must-export-alert-variants | Import `alertVariants` and call `alertVariants({ variant: "success" })` without rendering `<Alert>` | Returns a class string that includes `border-apt-green/40` and `bg-apt-green/10`. |
| alert-018 | should-compose-title-and-description-as-children | `<Alert><AlertTitle>T</AlertTitle><AlertDescription>D</AlertDescription></Alert>` | Both children render inside the same root grid container, each with `col-start-2`, stacked with `gap-y-0.5` between them. |

## Edge Cases

- **Null and empty input**: `<Alert />` with no children MUST render an
  empty, bordered/padded `<div role="alert">` without throwing — `children`
  is not required by `React.ComponentProps<"div">`. `variant={undefined}`
  MUST behave identically to omitting the prop (falls back to `default`
  per **must-default-to-default-variant**).
- **Boundary values**: A `variant` value outside the five accepted
  literals (only reachable by bypassing the `VariantProps` TypeScript
  type, e.g. from untyped/unchecked data): behavior is determined by the
  `class-variance-authority` library. An unrecognized variant key returns
  an empty class string or the default variant's classes, per the cva
  configuration (per the source, no explicit fallback is specified beyond
  the `defaultVariants: { variant: "default" }` option).
- **Concurrent access**: Not applicable. `Alert`, `AlertTitle`, and
  `AlertDescription` are stateless, side-effect-free function components
  with no internal state, refs, or shared mutable resources.
- **Error states**: Alert performs no fallible operation (no network
  call, no parsing, no file/database I/O) and contains no `try`/`catch` or
  error-boundary logic. Any rendering failure surfaces as a standard React
  rendering error, not Alert-specific behavior.
- **Offline or disconnected state**: Not applicable. Alert performs no
  network communication.
- **Attribute-override quirk**: If a caller explicitly passes a `role` or
  `data-slot` prop, that value overrides the component's own
  `role="alert"` / `data-slot="alert"` attributes, because `{...props}` is
  spread in JSX after those two attributes on the root `<div>` — JSX's
  last-attribute-wins rule applies, so the default can be silently
  replaced.
- **Icon detection is structural, not type-based**: The icon-aware grid
  change (`has-[>svg]:...`) is a pure CSS `:has()` selector keyed on any
  direct `<svg>` descendant. Any element that renders as a literal `<svg>`
  tag (from any icon library) triggers the wider grid layout; an icon
  implemented as, e.g., an `<img>` or a CSS background image does NOT
  trigger it.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `variant` | enum: `default` \| `info` \| `success` \| `error` \| `accent` | `default` | Selects the tone (border/background/icon color) of the alert. |
| `className` | `string` | none | Additional classes merged with the component's computed classes. Available on `Alert`, `AlertTitle`, and `AlertDescription` independently. |
| `...props` | `React.ComponentProps<"div">` | none | Any other native `<div>` attribute or event handler; forwarded to the root element of `Alert`, `AlertTitle`, or `AlertDescription`. |

## Deep Linking

Not applicable: Alert is a non-navigable presentational primitive with no routing or deep-linking capability.

## Localization

| String Key | Default (en) | Context |
|-----------|-------------|---------|

Alert defines no string constants of its own. All text content (title,
description, and any other content) is supplied by the caller as children;
there are no localization keys owned by this component.

## Accessibility Options

Not applicable: Alert is a static presentation component with no animations or responsive feature-toggle behavior; accessibility display options do not affect its appearance.

## Feature Flags

Not applicable: Alert.tsx contains no feature-flag or conditional-rendering logic.

## Analytics

Not applicable: Alert is a non-interactive presentational component with no analytics instrumentation in the source.

## Privacy

- **Data collected**: None. The component contains no data collection,
  storage, or transmission logic.
- **Storage**: None. No storage mechanism is present in the source.
- **Transmission**: None. No network or data-transmission logic is
  present in the source.
- **Retention**: Not applicable. No data is collected or retained.

## Logging

Not applicable: Alert.tsx contains no logging or console calls.

## Platform Notes

- **SwiftUI**: Use a `VStack` or custom container to compose the alert. Apply borders and background colors using `.border()` and `.background()` modifiers. Set `.accessibilityRole(.alert)` and use `.accessibilityElement(children: .combine)` for a11y.
- **Compose**: Use a `Box` or `Surface` composable for the container with `.border()` and `.background()` modifiers for styling. Stack title and description content vertically inside. Apply `semantics { role = Role.Alert }` for accessibility.
- **React/Web**: Implemented exactly as shown in source: a `<div>` styled with Tailwind utility classes composed via `class-variance-authority` (`cva`), a CSS grid layout that widens via a `:has(>svg)` selector when an icon is present, and `default` as the `cva` `defaultVariants` value. `AlertTitle`/`AlertDescription` are separate `<div>`s placed in the grid's second column.
- **AppKit / UIKit**: Use a custom `NSView` (macOS) or `UIView` (iOS) subclass or a `NSStackView`/`UIStackView` for layout. Apply a border via `layer.borderWidth` and `layer.borderColor`. Set `accessibilityRole` to `.alert` and compose title/description views vertically. No native inline-alert control exists; `NSAlert` is modal-only.
- **WinUI 3**: Fluent 2's `InfoBar` control is the closest conformant starting point — it is the built-in inline, non-modal notification control, with a `Severity` property (`Informational`/`Success`/`Warning`/`Error`) that drives its icon and tint, plus built-in `Title` and `Message` properties occupying roughly the role of `AlertTitle`/`AlertDescription`. This differs from the source in three ways: (1) `InfoBar` ships a built-in close button (`IsClosable`) and open/close state, while the web `Alert` is always-visible with no dismiss affordance at all; (2) `InfoBar`'s four `Severity` values map onto `info`/`success`/`error`, but there is no `Severity` equivalent for the source's `default` (neutral) or `accent` (gold) variants — those two would need a custom `Style` rather than a built-in `Severity`; (3) the source's icon-aware grid reflow (present only when a caller supplies an `<svg>` child) has no equivalent in `InfoBar`, which always reserves icon space based on `Severity`/`IconSource`, not on child presence.

## Design Decisions

- **Icon detection via CSS `:has()`, not an `icon` prop.** `alert.tsx` has
  no dedicated icon prop; its icon-aware grid widening and icon sizing are
  driven entirely by a `has-[>svg]` selector matching any direct `<svg>`
  child. This is why `AlertTitle`/`AlertDescription` are plain `col-start-2`
  siblings rather than named slots — the whole layout is structural
  (presence/absence of an `<svg>` child), not prop-driven.
- **Color-only variant differentiation** (see Accessibility Options >
  Differentiate Without Color): across `default`/`info`/`success`/`error`/
  `accent`, the source's only differentiator besides an optional
  caller-supplied icon is the border/background/icon tone color; the body
  text color (`text-apt-text`) is identical for every variant. An
  icon-less alert therefore communicates its severity through color
  alone, with no secondary non-color cue.
- **Attribute-override quirk is recorded, not fixed.** Because
  `{...props}` is spread after `role`/`data-slot` in the root `<div>`'s
  JSX (see Edge Cases), a caller can silently override either attribute.
  This recipe documents the source's actual behavior rather than the
  behavior a defensive implementation would have.
- **Rationale for should-compose-title-and-description-as-children.**
  `AlertTitle`/`AlertDescription` exist solely to place text in the grid's
  second column alongside an optional icon; using them is not enforced —
  `Alert` accepts arbitrary children — but a caller who deviates (e.g. a
  raw `<p>` instead of `AlertDescription`) must add `col-start-2` manually
  to stay aligned with an icon, since `Alert` itself applies no column
  placement to unrecognized children.
- **Naming collision with an unrelated recipe.** This cookbook also
  contains an `alert-and-dialog` recipe describing a *different*, modal
  confirm-dialog component that happens to share the word "Alert." The
  `Alert` documented here is the inline, non-modal callout from
  `alert.tsx`; the two are unrelated implementations.

## Compliance

Not applicable: Alert is a foundational UI primitive with no security, data-handling, or compliance-specific concerns in the source.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | | | Initial creation |
