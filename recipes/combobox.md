---
id: 43c55f5e-d9b3-430b-9026-d0af510fda15
title: Combobox
domain: agenticdevelopercookbook://ingredients/combobox
type: ingredient
version: 1.1.0
status: review
language: en
created: '2026-06-26'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: "Free-text input that reveals matching suggestions as you type — keyboard-selectable, with correct combobox ARIA. Replaces the native datalist."
platforms:
- typescript
- web
tags:
- component
- combobox
- autocomplete
- input
- ui
depends-on: []
related:
- agenticdevelopercookbook://ingredients/list-chooser
- agenticdevelopercookbook://ingredients/option-menu
references:
- https://base-ui.com/react/components/autocomplete
approved-by: ''
approved-date: ''
---

# Combobox

## Overview

`Combobox` is a free-text input that reveals a popup of matching suggestions as
the user types. The input's text is the value; the suggestions are hints the user
may pick with the keyboard (Up/Down to move, Enter to pick, Esc to close) or the
pointer. It is the accessible replacement for the native `<datalist>` pattern used
ad hoc across sites, giving every site one styled, keyboard-correct autocomplete.

It wraps Base UI's headless `Autocomplete` primitive (`@base-ui/react/autocomplete`)
rather than hand-rolling the keyboard and ARIA: Base UI renders the input with
`role="combobox"` and manages `aria-expanded`, `aria-controls`, and
`aria-activedescendant`, case-insensitive substring filtering, and the floating
popup. The wrapper's job is purely to theme those parts with `apt-*` tokens and
expose a small controlled `value` / `onValueChange` API. It differs from
`ListChooser`, which is a disclosed chooser with a trigger, an always-visible list,
an add-new affordance, and an OK/Cancel commit step.

## Behavioral Requirements

- **renders-combobox-role**: The text input MUST expose `role="combobox"` and, while collapsed, `aria-expanded="false"`.
- **type-reveals-suggestions**: Typing MUST open the popup and show only the suggestions whose text contains the query as a case-insensitive substring.
- **empty-shows-message**: When the query matches no suggestion, the popup MUST show the empty message rather than an empty box.
- **arrow-moves-active**: ArrowDown / ArrowUp MUST move the active suggestion, reflected via `aria-activedescendant` on the input.
- **enter-picks-active**: Enter MUST pick the active suggestion, filling the input with its text via `onValueChange`, and close the popup.
- **escape-closes**: Esc MUST close the popup without changing the committed text.
- **pointer-pick**: A pointer click on a suggestion MUST pick it (fill the input) and close.
- **controlled-value**: The input MUST reflect the `value` prop and report every edit through `onValueChange`.
- **aria-controls-listbox**: While open, the input's `aria-controls` MUST reference the rendered listbox element.
- **disabled-inert**: When `disabled`, the input MUST be non-interactive and MUST NOT open the popup.

## Appearance

```
┌─────────────────────────────┐
│ ap|                         │   ← text input (role="combobox")
└─────────────────────────────┘
┌─────────────────────────────┐
│ ✓ Apple                     │   ← suggestion popup (filtered, anchored to the input)
│   Apricot                   │   ← active row highlighted as you arrow through
└─────────────────────────────┘
```

- Input: the shared `Input` visual language — `apt-border`, `apt-bg` background, `apt-text`, `placeholder:text-apt-text-dim`, `focus-visible` ring `apt-gold/25`.
- Popup: `apt-surface` background, `apt-border`, `shadow-lg`, anchored under the input at the input's width (`--anchor-width`), capped by `--available-height`, scrolls when long.
- Rows: dropdown row treatment — active row `bg-apt-gold/15`; a check (`apt-gold`) marks the row equal to the current value.
- Empty: muted `apt-text-muted` message.
- No raw hex; no `!important`.

## States

| State | Appearance change |
|---|---|
| Idle / collapsed | input only; `aria-expanded="false"` |
| Focused | `focus-visible` ring `apt-gold/25` |
| Typing, matches | popup open with filtered suggestions |
| Typing, no match | popup open with the empty message |
| Active suggestion | `bg-apt-gold/15` on the active row; `aria-activedescendant` set |
| Disabled | dimmed; non-interactive; popup cannot open |

The control filters the in-memory `items` prop synchronously, so it owns no
intrinsic loading or error state; a caller fetching suggestions passes the resolved
array (an async caller can show its own spinner alongside).

## Accessibility

- Input: `role="combobox"` with `aria-expanded`, `aria-controls` (the listbox), and `aria-activedescendant` (the active option) — all supplied by Base UI's `Autocomplete.Input`. The wrapper sets `aria-label` from `ariaLabel` (or pairs with an external `<label htmlFor>` via `id`).
- Popup list: `role="listbox"`; each suggestion `role="option"` with `data-highlighted` on the active row.
- Keyboard: ArrowDown / ArrowUp move the active option, Enter picks it, Esc closes — handled by the primitive.
- Focus stays in the input throughout (the active option is tracked via `aria-activedescendant`, not DOM focus).

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|---|---|---|---|
| T1 | renders-combobox-role | render | input has `role="combobox"`, `aria-expanded="false"` |
| T2 | type-reveals-suggestions | set query "Vu", open | only "Vue" shown; non-matches absent |
| T3 | aria-controls-listbox | open | input `aria-controls` equals the listbox id |
| T4 | arrow-moves-active, enter-picks-active | open "S", ArrowDown, Enter | `aria-activedescendant` → "Svelte"; value becomes "Svelte"; popup closes |
| T5 | escape-closes | open "V", Esc | `aria-expanded="false"` |
| T6 | empty-shows-message | set query "zzz", open | empty message shown; no options |
| T7 | controlled-value | edit text | `onValueChange` fires with the new text |

## Edge Cases

- **Free text with no match.** The typed text remains the value; the popup shows the empty message. The input is not forced to a suggestion.
- **Duplicate suggestion strings.** `items` should be de-duplicated by the caller; identical strings render as separate rows keyed by value.
- **Long lists.** The popup scrolls within `--available-height`; the active row scrolls into view via the primitive.
- **Picking equals current text.** Re-picking the row already equal to the value is a no-op edit.
- **Opening method.** In a real browser the popup opens as the user types; programmatic tests open it with an ArrowDown keydown (the first ArrowDown opens, the next highlights).

## Configuration

| Option | Type | Default | Description |
|---|---|---|---|
| `items` | `readonly string[]` | — | Suggestions, filtered case-insensitively as the user types. |
| `value` | `string` | — | Controlled input text. |
| `onValueChange` | `(value: string) => void` | — | Fired on every edit and on pick. |
| `ariaLabel` | `string` | — | Required; labels the input. |
| `placeholder` | `string` | — | Input placeholder. |
| `emptyLabel` | `string` | `"No matches"` | Popup text when nothing matches. |
| `disabled` | `boolean` | `false` | Disables the control. |
| `className` | `string` | — | Extra classes for the input. |
| `id` | `string` | — | Optional input id (to pair with an external `<label htmlFor>`). |

## Deep Linking

Not applicable: Combobox is a form control embedded in a page, not a routable destination, so deep linking does not apply.

## Localization

Not applicable: All localizable strings (`ariaLabel`, `placeholder`, `emptyLabel`) are passed as component props by the caller, giving full control over localization.

## Accessibility Options

Not applicable: This component is a form control with no internal state or display preferences that respond to system accessibility settings such as reduce motion or increase contrast.

## Feature Flags

Not applicable: Combobox is a presentational component with no feature toggles or runtime configuration flags.

## Analytics

Not applicable: This component is a presentational form control that emits no structured analytics events.

## Privacy

Not applicable: Combobox is a presentational form control; it does not collect, store, or transmit user data.

## Logging

No logging. Combobox is a presentational form control; it emits no structured log events.

## Platform Notes

- **Web (React)**: New file `packages/web/packages/ui/src/components/combobox.tsx`. Wraps Base UI's headless `Autocomplete` primitive. Export covered by the existing `./components/*` wildcard in `packages/web/packages/ui/package.json`. Dependency on `@base-ui/react/autocomplete` already present in `@agenticdevelopertoolkit/ui`. Responsive design verified via Playwright at 375 / 768 / 1440 widths; both keyboard-only and pointer flows tested at each breakpoint.
- **SwiftUI**: Start with SwiftUI's native `Menu` combined with a `TextField` that filters a list; bind the text to the input value and handle arrow keys via key press event modifiers. Replicate Base UI's `aria-activedescendant` pattern with a local state variable tracking the highlighted item index.
- **Compose**: Use `OutlinedTextField` paired with a `DropdownMenu`; filter suggestions on text change and dismiss the menu when the user picks or presses Escape. Handle arrow navigation with `KeyEvent` callbacks on the text field.
- **AppKit / UIKit**: On AppKit, pair `NSTextField` with a table view in a popover; on UIKit, use `UITextField` with a table view controller presented in a `UIPopoverPresentationController`. Both platforms require manual keyboard event handling for arrow navigation and ARIA equivalent attribute bridging.
- **WinUI 3**: Use `AutoSuggestBox` control with its built-in filtering and suggestion list; set `IsSuggestionEnabled` to true, bind `SuggestedItemsSource` to the filtered items, and set `UpdateTextOnSelect` to control value synchronization on pick. Handle `ItemSelected` event to fire the equivalent of `onValueChange`. Verify keyboard navigation (Up/Down, Enter, Escape) via WinUI 3's built-in roving focus.

## Design Decisions

- **Wrap the native primitive, don't hand-roll.** Combobox ARIA (`role`, `aria-expanded`, `aria-controls`, `aria-activedescendant`), roving activation, filtering, and floating-popup positioning are exactly what Base UI's `Autocomplete` provides; reimplementing them would be error-prone and inconsistent with the rest of `@agenticdevelopertoolkit/ui`, which already composes Base UI primitives.
- **Autocomplete, not Combobox/Select.** The value is the free text the user types (datalist semantics), so Base UI `Autocomplete` is the right primitive rather than the selection-oriented `Combobox`.
- **Strings, not `{value,label}`.** Suggestions are plain strings to mirror the `<datalist>` it replaces; richer item shapes belong to `ListChooser` / `OptionMenu`.
- **Theme only.** The wrapper adds no behavior beyond styling and the controlled `value`/`onValueChange` surface, keeping it disposable and easy to track against upstream.

## Compliance

No additional compliance categories apply to this presentational control.

## Change History

| Version | Date | Author | Summary |
|---|---|---|---|
| 1.1.0 | 2026-09-22 | Mike Fullerton | Add missing template sections (Deep Linking, Localization, Accessibility Options, Feature Flags, Analytics, Privacy) as not applicable; fix domain URI to use agenticdevelopercookbook scheme; expand Platform Notes with cross-platform guidance. |
| 1.0.0 | 2026-06-26 | Mike Fullerton | Initial component + recipe. |
