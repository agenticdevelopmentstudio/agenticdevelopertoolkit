---
id: b3a92adc-a28e-4a33-8120-c33f8f0abdf6
title: Progress
domain: agenticdevelopertoolkit://recipes/progress
type: ingredient
version: 1.2.0
status: review
language: en
created: '2026-07-03'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: "A determinate progress bar — an accessible track with a token-styled fill clamped to 0–100, tintable via indicatorClassName (amber building, green done)."
platforms:
- typescript
- web
tags:
- component
- progress
- feedback
- ui
depends-on: []
related:
- agenticdevelopertoolkit://recipes/progress-modal
references: []
approved-by: ''
approved-date: ''
---

# Progress

## Overview

The shared `Progress` in `@agenticdevelopertoolkit/ui` — a determinate progress bar rendered as
a rounded track with an indicator filled to `value` (a percentage, 0–100). It is a
self-contained accessible element (`role="progressbar"` carrying
`aria-valuenow`/`aria-valuemin`/`aria-valuemax`) rather than a wrapper around a
primitive, so it needs no extra runtime dependency.

The fill is a full-width indicator translated horizontally so that a `value` of 0
hides it entirely (`translateX(-100%)`) and a `value` of 100 reveals it fully
(`translateX(-0%)`); the transform animates smoothly. The track uses the
`apt-surface-2` token and the fill defaults to `apt-gold`, but the fill is meant to
be re-tinted per context via `indicatorClassName` — e.g. amber while a job is
building, green once it completes.

A single export ships from `@agenticdevelopertoolkit/ui/components/progress`: the `Progress`
component. It carries `"use client"` (it renders an inline `style` transform) but
holds no internal state — `value` is fully controlled by the consumer.

## Behavioral Requirements

- **renders-progressbar-role**: The component MUST render an element with `role="progressbar"`.
- **reflects-value-in-valuenow**: The component MUST expose the current percentage as `aria-valuenow`, rounded to an integer.
- **fixed-value-bounds**: The component MUST report `aria-valuemin` as 0 and `aria-valuemax` as 100.
- **clamps-below-zero**: Given a `value` below 0, the component MUST clamp it to 0 and render an empty fill.
- **clamps-above-hundred**: Given a `value` above 100, the component MUST clamp it to 100 and render a full fill.
- **defaults-to-zero**: With no `value` prop, the component MUST render at 0 with an empty fill.
- **fill-tracks-value**: The component MUST size the visible fill proportionally to the clamped value, from empty at 0 to full at 100.
- **indicator-class-tints-fill**: The component MUST apply any `indicatorClassName` to the fill element so a consumer MAY override its color.
- **forwards-track-props**: The component MUST forward arbitrary props (`className`, `aria-label`, `id`, `data-*`) onto the track element.
- **requires-accessible-name**: The consumer MUST supply an accessible name (`aria-label` or `aria-labelledby`) via the forwarded track props; an unnamed `progressbar` fails WCAG 4.1.2 (Name, Role, Value).
- **pairs-tint-with-text-status**: When a consumer uses `indicatorClassName` to encode semantic status (e.g., amber while building, green once complete), the consumer MUST also convey that status via text or `aria-valuetext`, forwarded through the track props, rather than via color alone.
- **honors-shared-reduce-motion**: The fill's transition MUST be expressed as an ordinary class-based `transition`/`duration` utility, never an inline `style` or `!important` override, so the shared `accessibility.css` reduce-motion rule (`html[data-reduce-motion="on"] *`, or the `prefers-reduced-motion` media query when the setting is "auto") can zero its duration without any change to this component.

## Appearance

```
value = 0        ├───────────────────────────────┤   (empty track)
value = 35       ██████████·······················    (gold fill, 35%)
value = 100      ███████████████████████████████     (full fill)
```

- Track: `relative h-2 w-full overflow-hidden rounded-full bg-apt-surface-2`; extra
  classes merge via `cn()` through `className`.
- Indicator: `h-full w-full rounded-full bg-apt-gold` with
  `transition-transform duration-[calc(300ms*var(--apt-anim-scale,1))] ease-out`
  (a nominal 300ms, scaled by the shared dev-only slow-motion switch); positioned
  by an inline `transform: translateX(-{100 - pct}%)`.
- Fill color is token-based (`apt-gold` by default) and overridable through
  `indicatorClassName` (e.g. `bg-apt-green` for complete).
- No raw hex; no `!important`.

## States

| State | Appearance change |
|---|---|
| Empty (`value` ≤ 0) | Indicator fully translated out (`translateX(-100%)`); `aria-valuenow` = 0 |
| Partial (0 < `value` < 100) | Indicator revealed proportionally; `aria-valuenow` = rounded value |
| Full (`value` ≥ 100) | Indicator fully revealed (`translateX(-0%)`); `aria-valuenow` = 100 |
| Transitioning | Fill animates between positions via `transition-transform` (300ms ease-out) |
| Tinted (`indicatorClassName`) | Fill color overridden (e.g. amber while building, green when done) |

## Accessibility

- Renders `role="progressbar"` with `aria-valuemin` 0, `aria-valuemax` 100, and
  `aria-valuenow` set to the rounded, clamped percentage — so assistive technology
  announces determinate progress.
- It is a determinate bar only; there is no indeterminate mode.
- The component carries no built-in visible or accessible label. Consumers MUST
  pass an `aria-label` (or `aria-labelledby`) — the demo labels each bar
  ("Build progress", "Complete") — since an unnamed `progressbar` fails WCAG
  4.1.2 (Name, Role, Value); see **requires-accessible-name** and T8.
- Purely presentational otherwise: not focusable and not interactive; progress is
  driven by the consumer's `value`.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|---|---|---|---|
| T1 | renders-progressbar-role, fixed-value-bounds | render `<Progress value={35} />` | element has `role="progressbar"`, `aria-valuemin="0"`, `aria-valuemax="100"` |
| T2 | reflects-value-in-valuenow, fill-tracks-value | `value={35}` | `aria-valuenow="35"`; indicator transform `translateX(-65%)` |
| T3 | defaults-to-zero | render `<Progress />` (no `value`) | `aria-valuenow="0"`; indicator transform `translateX(-100%)` |
| T4 | clamps-below-zero | `value={-40}` | `aria-valuenow="0"`; transform `translateX(-100%)` |
| T5 | clamps-above-hundred | `value={140}` | `aria-valuenow="100"`; transform `translateX(-0%)` |
| T6 | reflects-value-in-valuenow | `value={35.6}` | `aria-valuenow="36"` (rounded) |
| T7 | indicator-class-tints-fill | `value={100} indicatorClassName="bg-apt-green"` | fill element carries `bg-apt-green` and NOT `bg-apt-gold` (`cn()` runs `tailwind-merge`, which drops the conflicting `bg-*` utility) |
| T8 | forwards-track-props, requires-accessible-name | `aria-label="Sync" id="p1"` | track element carries `aria-label="Sync"` and `id="p1"` |
| T9 | honors-shared-reduce-motion | render `<Progress value={35} />` under `html[data-reduce-motion="on"]` | computed `transition-duration` on the indicator resolves to `0.001ms` (the shared `accessibility.css` override), superseding the nominal `calc(300ms*var(--apt-anim-scale,1))` duration |
| T10 | clamps-below-zero, clamps-above-hundred (see **non-finite-value-handling** under Edge Cases) | `value={NaN}` | `aria-valuenow="NaN"`; transform `translateX(-NaN%)` — `Math.min`/`Math.max` pass `NaN` through unclamped |
| T11 | pairs-tint-with-text-status | `value={100} indicatorClassName="bg-apt-green" aria-valuetext="Complete"` | fill element carries `bg-apt-green`; track element carries `aria-valuetext="Complete"`, conveying the status alongside the color tint rather than through color alone |

## Edge Cases

- `value` below 0 or above 100 is clamped, never overflowing the track; `aria-valuenow`
  reflects the clamped value.
- Omitting `value` renders an empty (0%) bar rather than erroring.
- Fractional values are allowed for the fill width, but `aria-valuenow` is rounded to
  an integer, so `35.6` announces as `36`.
- There is no indeterminate state — a value is always supplied, defaulting to 0.
- `indicatorClassName` that also sets a background token overrides the default gold
  fill; a class that only tweaks other properties leaves the gold in place.
- **non-finite-value-handling** — A non-finite `value` (`NaN`, `Infinity`) is not
  caught by the `Math.min`/`Math.max` clamp — it passes straight through to
  `aria-valuenow` and the fill's `transform` (see T10). The
  **clamps-below-zero**/**clamps-above-hundred** guarantees cover finite
  out-of-range numbers only; the source does not decide what a non-finite
  value should mean, so it propagates unchanged.

## Configuration

| Option | Type | Default | Description |
|---|---|---|---|
| `value` | `number` | `0` | Percentage complete, 0–100; clamped to that range. |
| `indicatorClassName` | `string` | — | Extra classes for the fill element (e.g. `bg-apt-green`); merged via `cn()`. |
| `className` | `string` | — | Extra classes for the track element; merged via `cn()`. |
| `...props` | `React.ComponentProps<"div">` | — | Any native div props (incl. `aria-label`, `id`, `data-*`) are forwarded onto the track. |

## Deep Linking

Not applicable: Progress is a presentational primitive with no deep-linking semantics or navigation behavior.

## Localization

Not applicable: Progress has no user-facing strings to localize; all content is supplied by the consumer.

## Accessibility Options

| Option | Behavior |
|---|---|
| Reduce Motion | Not driven by `--apt-anim-scale` — that CSS custom property is a dev-only 10x-slow-motion debug switch, unrelated to accessibility. The fill's transition is an ordinary class-based utility (see **honors-shared-reduce-motion**), so the shared `accessibility.css` reduce-motion rule (`html[data-reduce-motion="on"] *`, or the OS `prefers-reduced-motion` media query when the setting is "auto") overrides its duration to near-zero without any change to this component (T9). |
| Increase Contrast | The Increase Contrast setting overrides `--color-on-surface`/`--color-outline*`/the focus-ring width (`accessibility.css`) — it does not touch `apt-gold`/`apt-surface-2`, so this component's colors are unaffected by that setting either way. Every shipped theme (`adh.css` and its siblings) resolves `apt-gold`/`apt-surface-2` to the same `#c4a35a` on `#1c1c24`, a measured ratio of ~7.0:1 — well above the WCAG 1.4.11 non-text 3:1 minimum. That measured ratio covers only the default `apt-gold`/`apt-surface-2` pairing; when a consumer re-tints the fill via `indicatorClassName`, meeting the 3:1 non-text contrast minimum against the track is the consumer's responsibility, since `progress.tsx` applies whatever class it is given without checking its contrast. |
| Differentiate Without Color | The progress amount itself is conveyed via fill width and horizontal translation, not color alone. When `indicatorClassName` is used to encode semantic status (amber while building, green once complete), that status MUST also be conveyed via text or `aria-valuetext` — see **pairs-tint-with-text-status**. |

## Feature Flags

Not applicable: Progress is a stateless primitive shipped without feature gate requirements.

## Analytics

Not applicable: Progress is a presentational primitive with no internal events. Analytics around progress tracking belong to the consumer component.

## Privacy

Not applicable: Progress stores no user data and collects no information.

## Logging

No logging. `Progress` is a presentational primitive; the meaning of a value and any
telemetry around a job's progress belong to the consumer, not the bar.

## Platform Notes

- **Web/TypeScript**: File `packages/web/packages/ui/src/components/progress.tsx`. Carries `"use client"` because it renders an inline `style` transform, but holds no internal state — `value` is fully controlled by the consumer. Demo in `ui-showcase` Topic `progress` (regenerate `sources.generated.ts` after source changes via `gen-sources.py`).
- **SwiftUI**: Start from `ProgressView(value: clampedValue, total: 100)` with the `.linear` `progressViewStyle` (or a custom `ProgressViewStyle` only if the track/fill need token colors the default style doesn't expose); clamp the incoming value to 0–100 before computing `clampedValue`, mirroring `#requirements/clamps-below-zero` and `#requirements/clamps-above-hundred`, and round it the same way as `#requirements/reflects-value-in-valuenow` before exposing it through `accessibilityValue`. `ProgressView` already draws and animates its own fill — no compositor translation modifier is needed; tint via `.tint(_:)` or the style's tint color.
- **Compose**: Clamp the incoming value to 0–100 first, mirroring `#requirements/clamps-below-zero` and `#requirements/clamps-above-hundred`, then use `LinearProgressIndicator` with `progress = clampedValue / 100f` (the composable takes a 0–1 `Float`, not 0–100); round that same clamped value the way `#requirements/reflects-value-in-valuenow` does before exposing it through `Modifier.semantics { progressBarRangeInfo = ... }`. Tint via the `color`/`trackColor` parameters. `LinearProgressIndicator` already draws and animates its own fill — no `Modifier.graphicsLayer()` translation is needed.
- **AppKit / UIKit**: `NSProgressIndicator` (AppKit) defaults to `isIndeterminate = true` — set it to `false` (and `style = .bar`) to get a determinate bar. `UIProgressView` (UIKit) is determinate-only by default, no flag needed. Clamp the incoming value to 0–100 before setting `doubleValue` (AppKit) or the 0–1 `progress` (UIKit), mirroring `#requirements/clamps-below-zero` and `#requirements/clamps-above-hundred`, and round it the same way as `#requirements/reflects-value-in-valuenow` before exposing it via `accessibilityValue`. Configure either with a custom tint and animate progress updates on the main thread.
- **WinUI 3**: Use `ProgressBar` with `Maximum=100`, `Value=clampedValue`; clamp the incoming value to that 0–100 range before assigning `Value`, mirroring `#requirements/clamps-below-zero` and `#requirements/clamps-above-hundred`, and round it the same way as `#requirements/reflects-value-in-valuenow` before exposing it through the automation peer's `RangeValuePattern`. Tint the fill by setting the `Foreground` brush (not `ProgressBarTemplate`/`TemplateBinding`, which isn't how `ProgressBar` fill color works). `ProgressBar` already animates value changes on its own — no custom `Storyboard`/`DoubleAnimation` is needed.

## Design Decisions

**Decision**: The bar owns its own `role="progressbar"` + `aria-value*` attributes
rather than wrapping a headless progress primitive.
**Rationale**: Progress is simple enough that the ARIA is trivial, and avoiding
an extra runtime dependency keeps the shared bundle lean.
**Approved**: pending

**Decision**: The indicator is a full-width element translated with
`translateX(-{100 - pct}%)` rather than animated via a width change.
**Rationale**: The fill animates on the compositor (`transition-transform`) and
stays crisp on its rounded ends.
**Approved**: pending

**Decision**: `value` is clamped to 0–100 inside the component.
**Rationale**: An out-of-range value from a consumer can never overflow the
track or produce a nonsensical `aria-valuenow`.
**Approved**: pending

**Decision**: The fill defaults to the `apt-gold` token but exposes
`indicatorClassName` as a dedicated recoloring hook.
**Rationale**: Context can recolor the fill (amber building → green done)
without a variant explosion.
**Approved**: pending

## Compliance

| Check | Status | Category |
|---|---|---|
| [semantic-markup](agenticdevelopercookbook://compliance/accessibility#semantic-markup) | passed | Accessibility |
| [reduced-motion](agenticdevelopercookbook://compliance/accessibility#reduced-motion) | passed | Accessibility |
| [contrast-ratio](agenticdevelopercookbook://compliance/accessibility#contrast-ratio) | passed | Accessibility |

All three rest on `progress.tsx`: the `role="progressbar"` + `aria-valuemin`/
`aria-valuemax`/`aria-valuenow` attributes; the class-based (non-inline,
non-`!important`) `transition`/`duration` utility that lets the shared
`accessibility.css` reduce-motion rule zero its duration; and the shared theme
stylesheets (`adh.css` and its siblings), which all resolve `apt-gold`/
`apt-surface-2` to `#c4a35a`/`#1c1c24` — a measured ~7.0:1 ratio, above the
WCAG 1.4.11 non-text 3:1 minimum.

## Change History

| Version | Date | Author | Summary |
|---|---|---|---|
| 1.2.0 | 2026-09-22 | Mike Fullerton | Lint pass: corrected the Reduce Motion/Increase Contrast claims and cited the measured contrast ratio; fixed the SwiftUI/Compose/AppKit/WinUI 3 platform notes to use each platform's native progress control and API correctly; documented the unclamped non-finite `value` edge case; raised the accessible-name guidance from SHOULD to MUST; rebuilt the Compliance table with canonical linked checks; reformatted Design Decisions to the Decision/Rationale/Approved form; added `progress-modal` to `related`; fixed the States/T5 transform string mismatch; added test vectors for reduce motion, non-finite input, and the tailwind-merge fill override; corrected the 1.1.0 Change History entry's wording and author; scoped the measured contrast ratio to the default token pairing and made re-tinted contrast a consumer responsibility; added a requirement (and test vector) that a color-only status tint be paired with text or `aria-valuetext`; mapped each non-web platform's clamping and rounding onto the shared clamp/round/valuenow requirements. |
| 1.1.0 | 2026-09-22 | Mike Fullerton | Add missing template sections (Deep Linking, Localization, Accessibility Options, Feature Flags, Analytics, Privacy); update platform notes to cover all target platforms; correct domain URI. Drafted by Claude Haiku 4.5. |
| 1.0.0 | 2026-07-03 | Mike Fullerton | Initial ingredient; documents the self-contained determinate Progress bar. |
