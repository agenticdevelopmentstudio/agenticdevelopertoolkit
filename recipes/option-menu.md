---
id: 4d0e04ff-39eb-472c-93a0-8070f1b64a6a
title: "OptionMenu"
domain: agenticdevelopertoolkit://recipes/option-menu
type: ingredient
version: 1.0.1
status: review
language: en
created: 2026-06-26
modified: 2026-09-22
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: "Single-select popup menu with full keyboard navigation and an optional editable Other free-text item."
platforms:
  - typescript
  - web
tags:
  - component
  - option-menu
  - menu
  - ui
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# OptionMenu

## Overview

`OptionMenu` is a single-select "popup menu": a trigger button that discloses a
list of choices with full keyboard navigation, plus an optional editable
**"Other"** item as the last entry. It is the standard ADH popup menu for forms
(first use: the invitation modal's "How did you hear about the Hub?" field). It
is built by composing existing primitives — `Popover` (surface), `Input` (the
Other field), `Button` (the OK affordance) — with a hand-managed roving
**selection** so the keyboard model below is exact. It deliberately does **not**
build on `DropdownMenu` / Base-UI menu: menu roles hijack typeahead and focus and
fight an embedded text input. It is distinct from the rail filter `PopupMenu`
block (`@agenticdevelopertoolkit/ui/blocks/popup-menu`), which keeps its own `allLabel`/`onNew`
filter semantics and is unchanged.

## Behavioral Requirements

- **trigger-opens-on-activation**: When the trigger is focused, Enter / Space / ArrowDown MUST open the surface.
- **open-initializes-selection**: On open, the selection MUST initialize to the committed item if any, else to the first item.
- **arrow-nav-clamps**: When open, ArrowDown / ArrowUp MUST move the selection down/up, clamped at the ends (no wrap).
- **enter-commits-list-item**: When a list item is selected, Enter MUST commit it via `onChange` with `isOther:false`, then close and return focus to the trigger.
- **pointer-click-commits**: A pointer click on a row MUST commit that row immediately and close.
- **escape-closes-without-commit**: Esc MUST close the surface without firing `onChange`.
- **focus-returns-on-close**: On any close, focus MUST return to the trigger.
- **selection-not-commit**: Changing the roving selection MUST NOT fire `onChange`; only a commit (Enter, OK, or row click) fires it.
- **check-marks-committed-value**: While open, the check (✓) MUST mark the committed value.
- **other-input-focused-on-open**: When `allowOther`, the Other input MUST receive focus immediately on open (caret ready to type).
- **typing-moves-check-to-other**: Typing in the Other input MUST set the selection to Other and move the check to Other live, before commit.
- **ok-enabled-when-nonempty**: The OK button MUST be enabled iff the Other input is non-empty after trim.
- **arrowup-from-other-moves-to-list**: ArrowUp from the Other input MUST move the selection to the last list item above Other and blur the input.
- **arrowdown-from-last-item-to-other**: ArrowDown from the last list item MUST return the selection to Other and re-focus the input.
- **enter-commits-other-when-nonempty**: When Other is the active selection and its input is non-empty, Enter MUST commit the trimmed text via `onChange` with `isOther:true`, then close.
- **enter-noop-when-other-empty**: When Other is active but the input is empty, Enter MUST be a no-op (matching the disabled OK).
- **ok-equals-enter-for-other**: Clicking OK MUST be equivalent to Enter while Other is active with non-empty input.

## Appearance

Closed:

```
┌─────────────────────────────┐
│ Search engine            ▾  │   ← trigger button (label = current value or placeholder) + chevron
└─────────────────────────────┘
```

Open, no "Other":

```
┌─────────────────────────────┐
│ Search engine            ▴  │
├─────────────────────────────┤
│ ✓ Search engine             │   ← checkmark = committed value
│   Social media              │   ← highlighted row = roving selection
│   Blog post                 │
│   Newsletter                │
└─────────────────────────────┘
```

Open, with editable "Other" as the last item:

```
┌─────────────────────────────┐
│   Search engine             │
│   …                         │
│   Word of mouth             │
│ ✓ Other                     │   ← check moves here once the user types
│   [                      ]  │   ← text input — focused on open
│   [          OK          ]  │   ← disabled until the input is non-empty
└─────────────────────────────┘
```

- Trigger: same visual language as `Select`/`Input` — `apt-border`, `apt-surface` background, `focus-visible` ring `apt-gold/25`, chevron (`ChevronsUpDown` or `ChevronDown`) in `apt-text-muted`.
- Surface: `Popover` content; rows use the dropdown row treatment — highlight `bg-apt-gold/15`, text `apt-text`, check icon `apt-gold`.
- Other input: shared `Input`. OK: shared `Button` (`size="sm"`, `variant="default"` = gold), full width of the surface, `disabled` when empty.
- Spacing from the `--space-*` scale; corners `--shape-corner-small`. No raw hex; no `!important`.

## States

| State | Appearance change |
|---|---|
| Trigger closed | label = committed value or placeholder; chevron down |
| Trigger focused | `focus-visible` ring `apt-gold/25` |
| Trigger disabled | dimmed; non-interactive |
| Open, no selection committed | no row checked; first row highlighted |
| Open, row highlighted | `bg-apt-gold/15` on the roving row |
| Open, committed row | ✓ on the committed row |
| Other empty | OK disabled |
| Other non-empty | OK enabled; ✓ on Other |

## Accessibility

- Trigger: `<button>` with `aria-haspopup="listbox"`, `aria-expanded`, `aria-label={ariaLabel}`.
- Surface: `role="listbox"`; rows `role="option"` with `aria-selected` on the committed row and `data-highlighted` on the selection.
- Other input: a labeled `<input>` (`aria-label` from `otherLabel`); the OK button's `aria-disabled` mirrors `disabled`.
- Focus returns to the trigger on close; the selection is announced via `aria-activedescendant` pointing at the highlighted option.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|---|---|---|---|
| T1 | arrow-nav-clamps, enter-commits-list-item | open, ArrowDown ×2, Enter | the right item commits, surface closes |
| T2 | escape-closes-without-commit | open, Esc | no `onChange`; trigger refocused |
| T3 | pointer-click-commits | click a row | that row commits, closes |
| T4 | other-input-focused-on-open | open with `allowOther` | Other input is focused |
| T5 | ok-enabled-when-nonempty | type into Other | OK enabled; empty → disabled |
| T6 | typing-moves-check-to-other | type into Other | check moves to Other |
| T7 | enter-commits-other-when-nonempty | type "Foo", Enter | commits "Foo" with `isOther:true` |
| T8 | arrowup-from-other-moves-to-list | ArrowUp from Other input | selection to last list item; input blurred |
| T9 | open-initializes-selection | controlled `value` = an item | that item resolves checked |
| T10 | check-marks-committed-value | controlled `value` = Other free text | Other checked, input prefilled |

## Edge Cases

- **Value resolution.** If `value` equals some `items[i].value`, that item is the committed/checked row. Else if `allowOther` and `value` is non-null, Other is the committed row and its input prefills with `value`. Else nothing is checked.
- Free text identical to an item value resolves to the item; callers needing to distinguish should avoid colliding labels.
- `value = null` → nothing is checked.
- `allowOther = false` with no matching item → nothing is checked.

## Configuration

| Option | Type | Default | Description |
|---|---|---|---|
| `items` | `OptionMenuItem[]` | — | The selectable items (`{ value, label }`). |
| `value` | `string \| null` | — | Committed value: an item value, free text (when `allowOther`), or null. |
| `onChange` | `(value: string, meta: { isOther: boolean }) => void` | — | Fired on commit; `isOther` true when from the Other input. |
| `allowOther` | `boolean` | `false` | Enables the editable Other row. |
| `otherLabel` | `string` | `"Other"` | Label for the Other row. |
| `otherPlaceholder` | `string` | — | Placeholder for the Other input. |
| `placeholder` | `string` | — | Trigger text when `value` is null. |
| `ariaLabel` | `string` | — | Required; labels the trigger + listbox. |
| `disabled` | `boolean` | `false` | Disables the control. |
| `className` | `string` | — | Extra classes. |

## Deep Linking

Not applicable: This is a UI component, not a full application feature that requires deep linking.

## Localization

Not applicable: All user-facing strings are passed via props (`ariaLabel`, `otherLabel`, `placeholder`, `otherPlaceholder`), allowing callers to localize at point of use.

## Accessibility Options

Not applicable: This component uses no animations that respond to accessibility preferences.

## Feature Flags

Not applicable: This is a library component with no feature-flag gating.

## Analytics

Not applicable: This is a presentational form control that does not emit analytics events.

## Privacy

Not applicable: This component handles no sensitive data and emits no telemetry.

## Logging

No logging. OptionMenu is a presentational form control; it emits no structured log events.

## Platform Notes

- **React/Web**: Implemented in `packages/web/packages/ui/src/components/option-menu.tsx`. Uses a hand-managed roving tabindex selection model (tracked in component state) rather than menu roles, to allow an embedded text input in the "Other" row without focus/keyboard conflicts. The component composes `Popover`, `Input`, and `Button` primitives and manages focus via `useRef` and `requestAnimationFrame` to ensure surface focus after arrow navigation. Start from the source and build platform equivalents using the selection model described in Design Decisions.
- **SwiftUI**: Start with a native `Menu` control for the list, but replace with a custom disclosure pattern (e.g., `.popover` modifier) to support the embedded text input in "Other". Hand-manage keyboard navigation via `onKeyPress` callbacks. Use `@FocusState` to track which element should have focus after each navigation action. The roving selection pattern is the same as web: track highlighted index in state, separate from what is committed.
- **Compose**: Start with `DropdownMenu` for the list, but switch to a custom `Box` with a popover surface for the embedded text input. Implement keyboard navigation via `KeyEventQueue` or a custom state machine tracking roving selection. Use `FocusRequester` to move focus between the input and the list after arrow keys. Match the web component's separation of selection (transient highlight) from commitment (firing `onChange`).
- **AppKit / UIKit**: On iOS, use `UIMenu` as the menu overlay, but compose a custom `UIViewController` or a SwiftUI overlay to support the "Other" text input. On macOS, consider a popover-based approach with `NSPopover` containing the list and input. Manage focus and keyboard events via responder chain and `UIKeyCommand`. The critical invariant is the same across all platforms: selection moves independently of commit, and only commit fires the `onChange` callback.
- **WinUI 3**: Use a `Flyout` or `MenuFlyout` for the list surface. For the "Other" input, embed a `TextBox` in the flyout with a `Button` for OK. Implement keyboard navigation via `PreviewKeyDown` events on the flyout, tracking selection in app state. Ensure focus management transitions focus between list items and the input as appropriate. The selection/commitment model must match the source: roving highlight never fires `onChange`, only user intent (Enter, click, or OK click) does.

## Design Decisions

- **Hand-managed roving selection, not a menu role.** Selection (the highlighted row) is tracked in component state independent of DOM focus, so arrow keys work whether focus is on a row or in the Other input. Building on `DropdownMenu` / Base-UI menu was rejected because menu roles hijack typeahead and focus and fight an embedded text input.
- **Selection vs. commit are distinct.** Selection is a transient highlight that never fires `onChange`; only a commit (Enter, OK, row click) fires `onChange` and closes.

## Compliance

No additional compliance categories apply to this presentational control.

## Change History

| Version | Date | Author | Summary |
|---|---|---|---|
| 1.0.1 | 2026-09-22 | Mike Fullerton | Add full optional sections (marked Not applicable where appropriate), fix domain URI to use agenticdevelopercookbook, and expand Platform Notes with translation guidance for all platforms. |
| 1.0.0 | 2026-06-26 | Mike Fullerton | Initial conversion from legacy UI spec. |
