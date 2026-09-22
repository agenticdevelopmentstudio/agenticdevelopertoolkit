---
id: 1a044d34-d585-46b4-b703-dea3fb9b9642
title: StatusDot
domain: agenticdevelopertoolkit://recipes/status-dot
type: ingredient
version: 1.1.0
status: review
language: en
created: '2026-07-03'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: "A glowing status dot — one cva tone class drives both fill and soft glow via currentColor; px-sized, labeled → role=img, unlabeled → decorative."
platforms:
- typescript
- web
tags:
- component
- status
- indicator
- ui
depends-on: []
related:
- agenticdevelopertoolkit://recipes/stat-card
references: []
approved-by: ''
approved-date: ''
---

# StatusDot

## Overview

The shared `StatusDot` in `@agenticdevelopertoolkit/ui` — the family's "live light": a small
round dot whose **fill and soft glow both derive from one tone class**. The tone
class sets `currentColor` (`text-apt-green`, `text-apt-red`, …); the fill is
`background: currentColor` and the glow is a `box-shadow` whose color is a
`color-mix` of that same `currentColor`, so a single class drives the entire
treatment and no per-tone shadow is hand-written.

It is sized in **px** (`size`, default `10`) rather than a scale step, because it
must optically align with mono text at many sizes — a status word beside it, a
row label, a hero figure. The glow radius scales with the dot
(`max(6, round(size * 0.55))` px) so a large dot still reads as a soft light
rather than a flat disc.

Accessibility is driven by `label`: pass the status word and the dot becomes an
accessible image (`role="img"` + `aria-label`); omit it — the common case, where
visible text already carries the meaning — and the dot is `aria-hidden`
decoration. A single export ships from
`@agenticdevelopertoolkit/ui/components/status-dot`: the `StatusDot` component. It is a pure
presentational span with no internal state and no `"use client"` directive.

## Behavioral Requirements

- **derives-fill-from-currentcolor**: The component MUST fill the dot with `background: currentColor` so the tone class alone sets the fill color.
- **derives-glow-from-currentcolor**: The component MUST render a soft `box-shadow` glow whose color is a `color-mix` of the same `currentColor`, so one tone class drives both fill and glow.
- **tone-sets-currentcolor**: The component MUST map each `tone` to an `apt-*` text-color class (`neutral`→`apt-text-muted`, `muted`→`apt-text-dim`, `accent`→`apt-gold`, `blue`→`apt-blue`, `orange`→`apt-orange`, `success`→`apt-green`, `error`→`apt-red`).
- **defaults-to-neutral-tone**: With no `tone`, the component MUST use the `neutral` tone (`apt-text-muted`).
- **sizes-in-px**: The component MUST render the dot at `size` px square (default `10`) via inline `width`/`height`.
- **scales-glow-with-size**: The component MUST set the glow radius to `max(6, round(size * 0.55))` px so the glow grows with the dot but never falls below 6 px.
- **labeled-is-accessible-image**: Given a `label`, the component MUST expose `role="img"` and `aria-label` set to that label.
- **unlabeled-is-decorative**: With no `label`, the component MUST render `aria-hidden="true"` and no `role`, so it is skipped by assistive technology.
- **merges-classname**: The component MUST merge any `className` after the tone class via `cn()`, so a consumer MAY add layout classes without losing the tone.

## Appearance

```
tone=success   ●  (apt-green fill + green glow halo)
tone=error     ●  (apt-red fill + red glow halo)
tone=accent    ●  (apt-gold fill + gold glow halo)

size=8   ·      size=12   ●      size=18   ⬤   (glow radius grows with size)
```

- Base: `inline-block shrink-0 rounded-full` — a shrink-proof inline circle that
  sits on the text baseline beside a label.
- Fill: `background: currentColor` (inline style), where `currentColor` comes
  from the tone's `text-apt-*` class.
- Glow: `boxShadow: 0 0 {glow}px color-mix(in srgb, currentColor 40%, transparent)`
  — a 40%-opacity halo of the same color, radius `max(6, round(size * 0.55))`.
- Size: inline `width` / `height` in px (default 10), so it aligns optically
  with adjacent mono text at any size.
- Fully token-driven (`apt-*` tones); no raw hex, no `!important`.

## States

| State | Appearance change |
|---|---|
| Default (`neutral`) | `apt-text-muted` fill + muted glow |
| Tinted (`success`/`error`/`accent`/`blue`/`orange`/`muted`) | Fill and glow both recolor to the tone's `apt-*` color |
| Small (`size` ≤ ~11) | Dot shrinks; glow clamps to a 6 px floor so it stays visible |
| Large (`size` big) | Dot grows; glow radius scales to `round(size * 0.55)` px |
| Labeled | Announced as an image named `label` (`role="img"`) |
| Decorative (no `label`) | `aria-hidden`; ignored by AT |

## Accessibility

- **Labeled = image.** With a `label`, the dot carries `role="img"` and
  `aria-label={label}`, so a standalone dot (e.g. the only status affordance in a
  cell) announces its status word to AT.
- **Unlabeled = decorative.** Without a `label`, the dot is `aria-hidden="true"`
  and has no role — the intended pattern when visible text ("healthy", "down")
  already names the status and a labeled dot would be a redundant announcement.
- Not focusable and not interactive; it is a pure indicator.
- Color is never the *only* signal in the family's compositions: the dot pairs
  with a visible status word (see the demo and StatCard), so it does not rely on
  hue alone to convey meaning.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|---|---|---|---|
| T1 | unlabeled-is-decorative, derives-fill-from-currentcolor | render `<StatusDot tone="success" />` | span has `aria-hidden="true"`; inline `background` is `currentcolor` |
| T2 | labeled-is-accessible-image, tone-sets-currentcolor | `<StatusDot tone="error" size={20} label="down" />` | element found by `role="img"` name `down`; className contains `text-apt-red` |
| T3 | scales-glow-with-size, derives-glow-from-currentcolor | `size={20}` | inline `boxShadow` contains `11px` (round(20 × 0.55)) and a `color-mix` of `currentColor` |
| T4 | labeled-is-accessible-image | `label="down"` | no element matches `[aria-hidden="true"]` |
| T5 | scales-glow-with-size | `size={8}` | glow radius clamps to `6px` (max(6, round(8 × 0.55)=4)) |
| T6 | defaults-to-neutral-tone | render `<StatusDot />` (no tone) | className contains `text-apt-text-muted` |
| T7 | sizes-in-px | `size={18}` | inline `width` and `height` are `18px` |
| T8 | merges-classname | `className="ml-1"` | className contains both `ml-1` and the tone class |

## Edge Cases

- **Tiny sizes.** For `size` ≤ ~10, `round(size * 0.55)` is below 6, so the glow
  clamps to the 6 px floor — a small dot still shows a visible halo rather than
  vanishing to a flat point.
- **Fractional size.** `size` is applied verbatim to `width`/`height`; only the
  glow radius is rounded, so a fractional `size` renders a fractional dot with an
  integer glow.
- **Empty-string label.** `label=""` is falsy, so the dot falls back to the
  decorative (`aria-hidden`) branch rather than announcing an empty image name.
- **No visible text.** A dot used alone with no adjacent label SHOULD pass
  `label` so its status is not lost to AT (color alone is inaccessible).
- **Glow on light surfaces.** The glow is a 40%-opacity `color-mix` with
  `transparent`, so it blends over any surface token without a hard edge.

## Configuration

| Option | Type | Default | Description |
|---|---|---|---|
| `tone` | `"neutral" \| "muted" \| "accent" \| "blue" \| "orange" \| "success" \| "error"` | `"neutral"` | Selects the `apt-*` color that drives both fill and glow. |
| `size` | `number` | `10` | Diameter in px; the glow radius scales with it (`max(6, round(size*0.55))`). |
| `label` | `string` | — | Accessible name. Present → `role="img"` + `aria-label`; omitted → `aria-hidden` decoration. |
| `className` | `string` | — | Extra classes merged after the tone class via `cn()` (e.g. layout/margins). |

## Deep Linking

Not applicable: StatusDot is a pure presentational component with no navigation semantics.

## Localization

Not applicable: StatusDot contains no text or UI strings; the `label` prop is provided by the consumer and is a fully localized value.

## Accessibility Options

Not applicable: StatusDot is a bare visual indicator. Motion, contrast, and color-differentiation preferences are managed by the tone system and inherited from the parent container's accessibility context, not by the component itself.

## Feature Flags

Not applicable: StatusDot is a primitive library component published as a reusable ingredient; feature flagging is the responsibility of consuming applications.

## Analytics

Not applicable: StatusDot is a presentational indicator with no internal state or event generation. The meaning of a status change and any telemetry around it belong to the consumer computing the tone, not the component.

## Privacy

Not applicable: StatusDot collects, stores, and transmits no data.

## Logging

No logging. `StatusDot` is a presentational indicator; the meaning of a status
and any telemetry around a health change belong to the consumer computing the
tone, not the dot.

## Platform Notes

- **Web/TypeScript**: File `packages/web/packages/ui/src/components/status-dot.tsx`. React functional component, memoized for re-render prevention. No `"use client"` directive — it is a stateless span with inline style and renders in server components. Uses CSS `color-mix(in srgb, …)` for the glow; supported by evergreen browsers. The `cn()` utility for className merging comes from `../lib/utils`.
- **SwiftUI**: Start from a capsule shape with a computed shadow modifier. Map `tone` to SwiftUI's color system (equivalent to the `apt-*` palette). Use `max(6, round(size * 0.55))` for shadow blur radius. The `label` parameter determines whether the capsule carries `accessibilityElement(children: .ignore)` + `accessibilityLabel()` (labeled) or `.hidden` (unlabeled).
- **Compose**: Use a `Canvas` composable or `Box` with `Modifier.shadow()`. The `tone` maps to the Material 3 color system or custom palette. Glow radius scales identically. Semantics: with `label`, add `semantics { contentDescription = label }` and mark as an image; without, mark as `decorative`.
- **AppKit / UIKit**: Use `NSView`/`UIView` with `CALayer` shadow. Fill is `layer.backgroundColor = UIColor(named: "apt-<tone>")`. Glow is `layer.shadowColor` and `layer.shadowRadius` using `max(6, round(size * 0.55))`. `label` drives accessibility: if present, set `accessibilityRole = .image` + `accessibilityLabel`; if absent, set `isAccessibilityElement = false`.
- **WinUI 3**: A `Border` with `CornerRadius="<size>"` and `Background` bound to a tone-based brush. Use a `ThemeShadow` with computed blur radius (`max(6, round(size * 0.55))`) and 40%-opacity color derived from the brush. Automation ID from the `label` parameter: set `AutomationProperties.Name` if present, otherwise omit. Pair with a `ContentPresenter` or inline text for the status word; color alone is insufficient.

## Design Decisions

- **One class, whole treatment.** Both the fill (`background: currentColor`) and
  the glow (`color-mix` of `currentColor`) derive from the tone's text color, so
  a single `text-apt-*` class recolors the entire dot. This avoids a parallel set
  of per-tone shadow classes that could drift out of sync with the fill.
- **Sized in px, not a scale step.** A status dot must optically match mono text
  at whatever size it appears next to (row label, hero figure, inline word), so
  `size` is a raw px number rather than a `sm/md/lg` token — the caller tunes it
  to the neighbouring text.
- **Glow floor at 6 px.** `max(6, round(size*0.55))` keeps small dots from losing
  their halo entirely, preserving the "soft light" read even at `size={8}`.
- **Label toggles the a11y role.** Rather than always announcing, the dot is
  decorative by default and becomes a `role="img"` only when given a `label` —
  matching the common case where visible text already carries the status and a
  second announcement would be noise.

## Compliance

| Check | Status | Category |
|---|---|---|
| No raw hex / arbitrary colors / `!important` (tones are `apt-*`, glow is `color-mix` of `currentColor`) | pass | project-guidelines UI |
| Components sourced from `@agenticdevelopertoolkit` (no bespoke UI) | pass | project-guidelines UI |
| Standalone indicator can carry an accessible name (`label` → `role=img`) | pass | accessibility |
| Decorative-by-default avoids redundant AT announcements | pass | accessibility |

## Change History

| Version | Date | Author | Summary |
|---|---|---|---|
| 1.1.0 | 2026-09-22 | Mike Fullerton | Revise: fix domain (cookbook), add missing "not applicable" sections, complete Platform Notes for all platforms, set status to review. |
| 1.0.0 | 2026-07-03 | Mike Fullerton | Initial recipe; documents the currentColor-driven glowing StatusDot. |
