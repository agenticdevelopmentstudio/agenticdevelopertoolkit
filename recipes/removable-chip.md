---
id: 9191eade-c18a-4899-b802-f000a1905c80
title: RemovableChip
domain: agenticdevelopercookbook://ingredients/removable-chip
type: ingredient
version: 1.2.0
status: review
language: en
created: '2026-07-03'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: "A Badge with a trailing ✕ remove button — the one home for the removable-chip treatment; the ✕ is a real button named removeLabel for AT."
platforms:
- typescript
- web
tags:
- component
- chip
- badge
- removable
- ui
depends-on: []
related:
- agenticdevelopercookbook://ingredients/badge
references: []
approved-by: ''
approved-date: ''
---

# RemovableChip

## Overview

The shared `RemovableChip` in `@agenticdevelopertoolkit/ui` — a `Badge` with a trailing ✕ remove
affordance. It is the one home for the "removable chip" treatment (recipient chips,
tag/category chips): rather than each caller re-inventing a badge-plus-✕, they render
this element. It is consumed by `RecipientInput` and `EntityChooser`.

The chip body is the shared `Badge` (so it inherits the badge tone `variant`s and the
mono/uppercase pill styling); the ✕ is a **real `<button>`** carrying `removeLabel`
as its accessible name, so a chip reads to assistive technology as
"`<value>`, Remove `<value>`". Clicking the ✕ invokes the consumer-supplied
`onRemove` callback — the component is stateless, so the consumer owns the list and
decides what removal does (typically filtering the value out of its state).

A single export ships from `@agenticdevelopertoolkit/ui/components/removable-chip`: the
`RemovableChip` component.

## Behavioral Requirements

- **renders-badge-body**: The component MUST render its `children` inside a `Badge` so the chip inherits the badge tone and pill styling.
- **renders-remove-button**: The component MUST render the ✕ affordance as a real `<button type="button">`, not a bare icon or a `<span>`.
- **remove-button-named**: The remove button MUST carry `removeLabel` as its accessible name (`aria-label`).
- **invokes-onremove-on-click**: Clicking the enabled remove button MUST invoke the `onRemove` callback.
- **stateless-removal**: The component MUST NOT mutate or remove itself; it only signals `onRemove`, leaving list state to the consumer.
- **applies-badge-variant**: The component MUST pass its `variant` through to the `Badge` (default `neutral`), so callers MAY tone the chip.
- **disabled-blocks-remove**: When `disabled`, the remove button MUST be disabled and MUST NOT invoke `onRemove` (`pointer-events-none`).
- **remove-icon-decorative**: The ✕ glyph itself MUST be hidden from AT (`aria-hidden`), leaving the button's `aria-label` as the sole accessible name.
- **forwards-chip-props**: The component MUST forward arbitrary span props (`className`, `id`, `data-*`) onto the `Badge` body.

## Appearance

```
┌──────────────────────┐
│  design-review   ✕   │   ← Badge body + trailing ✕ button
└──────────────────────┘
   value            remove
```

- Body: the shared `Badge` with `flex items-center gap-1` merged in, so the label and
  ✕ sit inline with a small gap; the badge supplies the pill (mono, uppercase,
  bordered) and the tone.
- Remove button: `text-apt-text-muted hover:text-apt-text`, `disabled:pointer-events-none`;
  contains a lucide `X` icon sized `11`, marked `aria-hidden`.
- Tone follows the `variant` prop (`neutral` default; also `accent`/`orange`/`blue`/
  `success`/`error`) resolved by `Badge`.
- No raw hex; no `!important`.

## States

| State | Appearance change |
|---|---|
| Rest | Badge in its `variant` tone; ✕ muted (`text-apt-text-muted`) |
| ✕ hover | ✕ brightens to `text-apt-text` |
| ✕ focus-visible | Native button focus indicator on the ✕ |
| Disabled | ✕ disabled + `pointer-events-none` (does not fire `onRemove`) |

## Accessibility

- The ✕ is a **real `<button type="button">`**, so it is focusable and keyboard-operable
  (Enter/Space) natively — removal is not pointer-only.
- The button's accessible name is `removeLabel` (`aria-label`), which callers set to
  `Remove ${value}` (the demo passes `` `Remove ${v}` ``). Combined with the badge
  body, each chip reads as "`<value>`, Remove `<value>`" to AT.
- The ✕ glyph is `aria-hidden`, so the icon does not add a second, redundant label —
  the button's `aria-label` is the single accessible name.
- The chip body is a `Badge` (`<span>`); it is not itself interactive, keeping one
  clear action (remove) per chip.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|---|---|---|---|
| T1 | renders-badge-body, forwards-chip-props | `<RemovableChip removeLabel="Remove x" onRemove={fn} id="c1">x</RemovableChip>` | a `data-slot="badge"` element containing "x" and carrying `id="c1"` |
| T2 | renders-remove-button, remove-button-named | same as T1 | a `<button type="button">` with `aria-label="Remove x"` |
| T3 | invokes-onremove-on-click | click the remove button | `onRemove` called once |
| T4 | stateless-removal | after T3 without consumer re-render | the chip is still in the DOM (removal is the consumer's job) |
| T5 | applies-badge-variant | `variant="success"` | the `Badge` resolves the `success` tone classes |
| T6 | disabled-blocks-remove | `disabled` then click the ✕ | button is `disabled`; `onRemove` NOT called |
| T7 | remove-icon-decorative | inspect the `X` glyph | the icon carries `aria-hidden` |
| T8 | remove-button-named (Playwright) | query by role `button` name "Remove x" | the ✕ is found by its accessible name and is keyboard-activatable |

## Edge Cases

- **Removal is the consumer's job.** The chip never removes itself; it only calls
  `onRemove`. The demo filters the value out of its `items` state, and re-adds via a
  Reset button — the chip is stateless.
- **Disabled chip:** the ✕ is disabled and `pointer-events-none`, so `onRemove` cannot
  fire; the chip stays put.
- **Missing accessible name:** `removeLabel` is required by the type; callers pass a
  value-specific label (`Remove ${value}`) so multiple chips have distinct button names.
- **Rich children:** `children` may be more than text (e.g. an avatar + name); it all
  renders inside the badge body inline with the ✕.
- **Empty list:** the chip renders nothing special when a list empties — the consumer
  shows its own empty state (the demo shows "All removed.").

## Configuration

| Option | Type | Default | Description |
|---|---|---|---|
| `children` | `React.ReactNode` | — | The chip label/content shown in the badge body. |
| `onRemove` | `() => void` | — | Called when the ✕ button is activated. Required. |
| `removeLabel` | `string` | — | Accessible name for the ✕ button (e.g. `Remove ${value}`). Required. |
| `variant` | `"neutral" \| "accent" \| "orange" \| "blue" \| "success" \| "error"` | `"neutral"` | Badge tone. |
| `disabled` | `boolean` | `false` | Disables the ✕ button. |
| `className` | `string` | — | Extra classes for the badge body; merged via `cn()`. |
| `...props` | `Omit<React.ComponentProps<"span">, "children">` | — | Native span props forwarded onto the `Badge`. |

## Deep Linking

Not applicable: RemovableChip is a presentational component with no navigation behavior.

## Localization

Not applicable: RemovableChip renders only the `children` content supplied by the caller; localization is the caller's responsibility.

## Accessibility Options

Not applicable: RemovableChip is a simple presentational element composed of a Badge and a button; it does not respond to platform accessibility display options like Reduce Motion or Increase Contrast.

## Feature Flags

Not applicable: RemovableChip is a foundational UI component with no conditional behavior or feature gates.

## Analytics

Not applicable: RemovableChip is a stateless presentational element; the consumer's `onRemove` handler owns any telemetry or event tracking.

## Privacy

Not applicable: RemovableChip collects no data and transmits nothing; it is a presentational component.

## Logging

No logging. `RemovableChip` is a presentational element; what removal means and any
telemetry belong to the consumer's `onRemove` handler, not the chip.

## Platform Notes

- **React/Web**: File: `packages/web/packages/ui/src/components/removable-chip.tsx`. Composes the shared `Badge` (`./badge`) for the body and a lucide `X` icon for the affordance; carries `"use client"`.
- **SwiftUI**: Compose a `HStack` containing the badge body (background + rounded corner pill using `.background()` and `.clipShape(Capsule())`) and a `Button` with an `Image(systemName: "xmark")`. Apply `.buttonStyle(.plain)` to strip button styling from the remove button. Set `.disabled(disabled)` on the button. Wrap the remove button in an accessibility container with `.accessibilityLabel(removeLabel)` and `.accessibilityRemoveAction()`. On hover or focus, brighten the icon color and apply the visual states for pressed and disabled.
- **Kotlin (Compose)**: Build a `Row` with `Modifier.border(1.dp, color)` and `Modifier.clip(RoundedCornerShape(8.dp))` for the pill shape. Render content as `Text`, then a `Button` with `Modifier.size(24.dp)` containing an `Icon` (Material Design `Icons.Default.Close`). Set `enabled = !disabled` on the button. Bind the button's `onClick` to the remove callback. Apply `Modifier.semantics { contentDescription = removeLabel }` for accessibility. Style icon color as muted by default, brightened on hover/pressed.
- **AppKit / UIKit**: On **AppKit**, create an `NSBox` with `boxType = .custom`, `cornerRadius = 12`, and `borderColor` from the variant tone. Nest an `NSStackView` (horizontal, spacing `4`) inside it containing `NSTextField` (read-only, for content) and `NSButton` (image button, with close glyph `⊗` or Font Awesome's `xmark`). Bind the button's `action` to the remove callback. On **UIKit**, create a `UIView` container with `layer.cornerRadius = 12` and `layer.borderColor`; nest a `UIStackView` (horizontal, spacing `4`) with `UILabel` and `UIButton`. Configure the button with `setImage(_:for:)` using a close glyph (system `image(named: "xmark.circle.fill")` or similar), and bind `UIControlEventTouchUpInside` to the remove callback. Set `button.isEnabled = !disabled` in both. Apply visual states for hover (brightness), pressed (opacity), and disabled (gray out).
- **WinUI 3**: Create a `Border` with `CornerRadius` set to match the pill styling, wrapping a horizontal `StackPanel` (`Orientation = Horizontal`, `Spacing = 4`). Inside the `StackPanel`, render a `TextBlock` for the content and a `Button` with a `FontIcon` using the glyph `&#xE711;` (WinUI "Cancel" icon) for the remove affordance. Map the button's `Click` event to invoke the source's remove callback. Set `Button.IsEnabled = !disabled`. Use `AutomationProperties.Name` on the button to set the accessible label to `removeLabel`. Define visual states for hover (highlight background brightens), pressed (scale down slightly), and disabled (foreground grays out, cursor becomes `Arrow`).

## Design Decisions

- **A real button for the ✕, not a clickable icon.** Making the remove affordance a
  `<button type="button">` with an `aria-label` gives keyboard operability and a clear
  accessible name for free — a bare icon with an `onClick` would be invisible to AT and
  keyboard users.
- **Reuse `Badge`, don't restyle.** The chip body is the shared `Badge`, so it inherits
  every tone and the established pill styling; the recipe adds only `flex items-center
  gap-1` and the trailing button, keeping one source of truth for chip appearance.
- **Stateless by design.** The chip signals `onRemove` and nothing else; the consumer
  owns the list. This keeps the element reusable across recipient inputs, tag pickers,
  and entity choosers without baking in any list model.
- **One home for the treatment.** Centralizing the badge-plus-✕ here means
  `RecipientInput`, `EntityChooser`, and future callers share identical removal
  semantics and a11y rather than each re-deriving them.

## Compliance

| Check | Status | Category |
|---|---|---|
| No raw hex / arbitrary colors / `!important` | pass | project-guidelines UI |
| Components sourced from `@agenticdevelopertoolkit` (no bespoke UI) | pass | project-guidelines UI |
| Remove affordance is a real, named, keyboard-operable button | pass | accessibility |

## Change History

| Version | Date | Author | Summary |
|---|---|---|---|
| 1.2.0 | 2026-09-22 | Claude Haiku 4.5 | Revise Platform Notes: replace "Not applicable" bullets with concrete translation guidance for SwiftUI, Kotlin, AppKit/UIKit, and WinUI 3. |
| 1.1.0 | 2026-09-22 | Claude Haiku 4.5 | Add Deep Linking, Localization, Accessibility Options, Feature Flags, Analytics, and Privacy sections as "Not applicable"; fix domain to agenticdevelopercookbook; update status to review. |
| 1.0.0 | 2026-07-03 | Mike Fullerton | Initial recipe; documents the Badge-plus-✕ removable chip and its named remove button. |
