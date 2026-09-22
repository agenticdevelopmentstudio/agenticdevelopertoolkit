---
id: 79f7ed30-3193-49bc-856b-d7dd01303baa
title: EntityChooser
domain: agenticdevelopertoolkit://recipes/entity-chooser
type: ingredient
version: 1.1.0
status: review
language: en
created: '2026-06-26'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: "Browse/filter/select/add surface for account categories or tags — a single-value picker or a multi-select chip set, composed over ListChooser."
platforms:
  - typescript
  - web
tags:
  - component
  - entity-chooser
  - chooser
  - tags
  - ui
depends-on:
  - agenticdevelopertoolkit://recipes/list-chooser
related:
  - agenticdevelopertoolkit://recipes/list-chooser
  - agenticdevelopertoolkit://recipes/combobox
  - agenticdevelopertoolkit://recipes/recipient-input
references:
  - agenticdevelopercookbook://guidelines/cookbook/ui/platform-design-languages
approved-by: ''
approved-date: ''
---

# EntityChooser

## Overview

`EntityChooser` is a browse / filter / select / add surface for a list of string
entities — the account's categories or tags. It is a thin composition over
`ListChooser` (`@agenticdevelopertoolkit/ui/components/list-chooser`), which supplies the
disclosed, text-filtered list with a roving keyboard highlight and an "add a new
one" affordance. `EntityChooser` adds only the **selection semantics** on top:

- **single** mode is a one-value picker — selecting (or creating) replaces the
  value, exposed through a unified `string | null` callback.
- **multi** mode maintains an ordered **set**, rendered as removable chips beside a
  `Choose…` trigger that adds one entry per open. Already-selected options are
  hidden from the browser, so a member can't be added twice.

It never re-implements the list or keyboard logic — that lives in `ListChooser`. It
is the editor half of the `[Combobox autocomplete] [Choose…]` field pattern (first
use: the research category + tag fields), where a `Combobox` does inline typeahead
and `EntityChooser`'s trigger opens the full browse/add surface over the same
options. It differs from `RecipientInput` (a free-text chip input with no backing
option list or filtered browser) and from `ListChooser` (single-value only, no chip
set, value-bearing trigger).

## Behavioral Requirements

- **must-accept-single-value**: In single mode, accepting an option or a created entry MUST report it through `onChange(next)` as the new value, replacing any prior one.
- **must-show-trigger-label-single-when-null**: In single mode, when the value is `null` the trigger MUST show the configured trigger label.
- **must-add-to-set-multi**: In multi mode, accepting an option or a created entry MUST append it to the set via `onChange([...value, entry])`.
- **must-prevent-duplicates-multi**: In multi mode, an entry already in the set MUST NOT be added again — no duplicate and no `onChange`.
- **must-hide-selected-options-multi**: In multi mode, options already in the set MUST be omitted from the browser's list so they cannot be re-offered.
- **must-render-removable-chips-multi**: In multi mode, the current set MUST render as chips, each with a control labelled `Remove <value>` that removes that entry via `onChange`.
- **must-show-empty-hint-multi**: In multi mode, when the set is empty the chip area MUST show the empty-selection hint instead of chips.
- **must-delegate-list-behavior**: Filtering, the roving-keyboard highlight, OK/Cancel, and add-new MUST be delegated to the embedded `ListChooser`, not re-implemented.
- **must-forward-allow-create**: When `allowCreate` is false, typed text matching no option MUST NOT be acceptable (no create row); the setting is forwarded to `ListChooser`.
- **must-respect-disabled**: When `disabled`, the trigger and every chip-remove control MUST be non-interactive.

## Appearance

Single (closed):

```
┌─────────────────────────────┐
│ architecture            ▾   │   ← trigger: the chosen value, or the trigger label
└─────────────────────────────┘
```

Multi:

```
┌──────────┐ ┌──────────┐ ┌───────────┐
│ vision ✕ │ │ rlhf  ✕  │ │ Choose… ▾ │   ← chips (removable) + the add trigger, inline
└──────────┘ └──────────┘ └───────────┘
```

Open (both modes) — the embedded `ListChooser` surface:

```
┌─────────────────────────────┐
│ [ att|                    ]  │   ← filter/add field (focused on open)
├─────────────────────────────┤
│   attention                 │   ← filtered list (selected options omitted in multi)
│ + Add “att”                 │   ← create row, when text matches no option
├─────────────────────────────┤
│              Cancel    OK   │
└─────────────────────────────┘
```

- Trigger, surface, list rows, create row, and button bar are entirely `ListChooser`'s treatment (`apt-border`/`apt-bg`, `apt-gold` highlight + check, `ChevronsUpDown`).
- Chips are the shared `RemovableChip` component with text content and a trailing remove button.
- Multi lays chips and the `Choose…` trigger in one `flex-wrap` row; the trigger is auto-width (`w-auto`) so it sits after the chips rather than filling the row.
- All color via `apt-*` tokens; no raw hex; no `!important`.

## States

| State | Appearance change |
|---|---|
| Single, value set | trigger shows the value; the matching list row shows ✓ when open |
| Single, value null | trigger shows the trigger label (e.g. "Choose…") |
| Multi, empty set | empty-selection hint (e.g. "No tags yet") + the Choose trigger |
| Multi, non-empty set | one chip per entry + the Choose trigger |
| Browser open | `ListChooser` popover: focused field, filtered list, OK/Cancel |
| `allowCreate` off, no match | no create row; OK disabled; Enter a no-op |
| Disabled | trigger + chip-remove controls dimmed and non-interactive |

The control is synchronous over the in-memory `options` prop — loading/error states
belong to the caller that fetches the options (mirroring `ListChooser` /
`RecipientInput`).

## Accessibility

- The embedded `ListChooser` provides the combobox/listbox semantics: trigger `aria-haspopup="listbox"` + `aria-expanded`, the filter field `role="combobox"` with `aria-controls` / `aria-activedescendant`, and `role="listbox"` / `role="option"` rows. Focus moves to the field on open and returns to the trigger on close.
- The trigger is labelled by `ariaLabel`; the filter/add field by `inputLabel` (falling back to `ariaLabel`).
- Multi mode wraps the chips + trigger in a `role="group"` labelled by `ariaLabel`; each chip's remove control is a `<button>` with `aria-label="Remove <value>"`.
- Keyboard operability (arrows, Enter, Esc, OK/Cancel) is inherited unchanged from `ListChooser`.
- Minimum touch target size for trigger and chip-remove controls is 44×44pt (per platform guidelines).

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|---|---|---|---|
| T1 | must-accept-single-value, must-delegate-list-behavior | single, open, click "engineering" | `onChange("engineering")`; browser closes |
| T2 | must-accept-single-value, must-forward-allow-create | single, type "design", Enter | `onChange("design")`; browser closes |
| T3 | must-forward-allow-create | single, `allowCreate=false`, type "nope", Enter | no `onChange`; no create row shown |
| T4 | must-show-trigger-label-single-when-null | single, `value="research"` | trigger shows "research" |
| T5 | must-render-removable-chips-multi, must-show-empty-hint-multi | multi, `value=[]` then `["vision"]` | empty hint shown; then "vision" chip shown |
| T6 | must-add-to-set-multi | multi, `value=["vision"]`, open, click "attention" | `onChange(["vision","attention"])`; browser stays open |
| T7 | must-hide-selected-options-multi | multi, `value=["vision"]`, open | "vision" option absent; "attention" and others present |
| T8 | must-render-removable-chips-multi | multi, `value=["vision","attention"]`, click "Remove vision" | `onChange(["attention"])` |
| T9 | must-prevent-duplicates-multi | multi, `value=["vision"]`, type "vision", Enter | no `onChange` |
| T10 | must-respect-disabled | `disabled=true` | trigger non-interactive; chip remove buttons non-interactive |

## Edge Cases

- **Created multi entry already present.** A typed entry equal to an existing member is rejected by the dedupe guard even though it's hidden from the list, so a stale type can't duplicate it.
- **Single free text vs. option.** A single `value` that matches no option still shows on the trigger as free text (inherited from `ListChooser`'s value resolution).
- **Empty options.** With no options, an empty filter shows `ListChooser`'s empty message; typing surfaces the create row when `allowCreate`.
- **Trigger label vs. value.** In multi mode the trigger always reads the trigger label (the inner `ListChooser` value is held at `null`); in single mode it reflects the chosen value.
- **Multi selectionPlacement host mode.** When `selectionPlacement="host"`, the chooser renders only the trigger (`w-auto` removed, `className` applied to trigger); the caller owns rendering `EntitySelectionChips` alongside and manages the selected values independently.

## Configuration

| Option | Type | Default | Description |
|---|---|---|---|
| `options` | `readonly string[]` | — | The selectable entities (e.g. the account's categories or tags). |
| `multiple` | `boolean` | `false` | Discriminates single-value vs. multi-select-set mode. |
| `value` | `string \| null` (single) / `string[]` (multi) | — | The current selection. |
| `onChange` | `(next: string \| null) => void` (single) / `(next: string[]) => void` (multi) | — | Fired with the new selection. |
| `ariaLabel` | `string` | — | Required; labels the trigger, the listbox, and (multi) the chip group. |
| `triggerLabel` | `string` | `"Choose…"` | Trigger text (and the placeholder shown when a single value is null). |
| `inputLabel` | `string` | `ariaLabel` | Accessible label for the filter/add field. |
| `placeholder` | `string` | `ListChooser` default | Placeholder for the filter/add field. |
| `allowCreate` | `boolean` | `true` | Whether text matching no option can be accepted as a new entry. |
| `createLabel` | `(text: string) => string` | `ListChooser` default | Builds the create-row label. |
| `emptyLabel` | `string` | `ListChooser` default | Browser "no matches" message. |
| `emptySelectionLabel` | `string` (multi) | `"Nothing selected yet"` | Hint shown when the set is empty. |
| `selectionPlacement` | `"inline" \| "host"` (multi) | `"inline"` | Whether chips render inline with the trigger or are managed by the host component. |
| `disabled` | `boolean` | `false` | Disables the control. |
| `className` | `string` | — | Extra classes (single: the trigger; multi with inline: the chip+trigger group; multi with host: the trigger). |

## Deep Linking

Not applicable: `EntityChooser` is a presentational form control with no deep-link targets. Navigation is owned by consuming pages.

## Localization

Not applicable: `EntityChooser` renders user-provided `options` as-is and uses only caller-provided labels (`ariaLabel`, `triggerLabel`, `inputLabel`, `placeholder`, `emptySelectionLabel`, `createLabel`, `emptyLabel`). No hardcoded user-facing strings.

## Accessibility Options

Not applicable: `EntityChooser` inherits all accessibility behavior from `ListChooser` and does not add platform-specific accessibility display options (Reduce Motion, Increase Contrast, Differentiate Without Color) of its own; these are handled by the embedded control and its dependencies.

## Feature Flags

Not applicable: `EntityChooser` is an unconditional component with no feature flags in the source code.

## Analytics

Not applicable: `EntityChooser` is a presentational form control; it emits no structured analytics events. Event tracking is the responsibility of the caller.

## Privacy

Not applicable: `EntityChooser` does not collect, store, transmit, or retain user data. It passes through user selections to a caller-provided `onChange` callback; no data is persisted or logged by the component.

## Logging

Not applicable: `EntityChooser` emits no structured log events. Logging of user selections is the responsibility of the caller.

## Platform Notes

- **React/Web (TypeScript)**: Source is `packages/web/packages/ui/src/components/entity-chooser.tsx`. The component exports `EntityChooser` (the main control) and `EntitySelectionChips` (a companion for rendering the multi-mode selection outside the chooser when `selectionPlacement="host"`). Both are React functional components using hooks for state management. Import from `@agenticdevelopertoolkit/ui/components/entity-chooser`.
- **SwiftUI**: Start with `Picker` or a custom presentation wrapping `List` with a search/filter field. Mirror the dual-mode dispatch: single uses a standard picker binding, multi uses a `State` set that appends on selection and omits selected values from the list. Render selected items as removable chips using `HStack` with a trailing `Image(systemName: "xmark.circle.fill")` per item. On watchOS or compact layouts, consider full-screen modality instead of inline chips.
- **Compose (Kotlin)**: Build on `LazyColumn` for the filtered list with `TextField` for the search input. Single mode: update a mutable state holder; multi mode: maintain a mutable set, append on accept, filter the list to exclude already-selected items. Use Compose `Chip` from Material 3 with a trailing close icon for removable chips. Handle focus transitions (focus to input on open, return focus to trigger on close) via `FocusRequester`.
- **UIKit / AppKit**: On iOS, use `UISearchController` to manage the filtered list within a `UITableViewController` popover. Present modally for consistency with navigation. On macOS, use an `NSSearchField` + `NSTableView` in a popover or sheet. Single mode stores the selection as a string; multi mode as a `Set<String>` or array. Render chips with removable `NSButton` subviews in a wrapping `NSStackView` (NSView-based) or `UIStackView` (UIKit).
- **WinUI 3 (C#)**: Use `AutoSuggestBox` with a custom `ItemsControl` list that filters as the user types. For multi mode, bind to an `ObservableCollection<string>` for the selected set and render each as a `StackPanel` containing a `TextBlock` and a `Button` with `SymbolIcon` (XMarkSymbol) for removal. Position the popup using `Popup` and set `IsLightDismissEnabled="true"`. Apply the `AppBarButtonStyle` to remove buttons for visual consistency. Leverage data binding and `INotifyCollectionChanged` to keep the list and chip rendering in sync.

## Design Decisions

- **Compose `ListChooser`, don't fork it.** All list, filter, roving-keyboard, and add-new behavior is `ListChooser`'s; `EntityChooser` only layers selection semantics (single value vs. set + chips). One authoritative home for the list/keyboard logic; the chooser stays disposable.
- **Multi = repeated single-add, not a bespoke multi-select.** Rather than re-writing `ListChooser` to keep its popover open and toggle rows (a different keyboard model), multi mode reuses the single-accept engine: each open adds one entry, the set lives in the parent, and selected options are hidden so the browser never re-offers them. Simpler, fully accessible, zero duplication of keyboard logic.
- **Chips reuse `RemovableChip` component** so tag editing looks and reads the same everywhere the component is used.
- **`value=null` on the inner `ListChooser` in multi mode** keeps the trigger reading "Choose…" (an add affordance) rather than echoing a single committed value.
- **`selectionPlacement="host"` option for layout flexibility.** When the chip set is rendered inline with the trigger, a wrapping multi-line group cannot keep a fixed column width. Handing the chips to the host lets the host draw them in a separate area (e.g., a different row or column) and keep the trigger's width stable and aligned with fields above/below.
- **No built-in async state.** `options` is a controlled in-memory prop; the caller owns fetching/loading/error — consistent with the sibling form controls.

## Compliance

| Check | Status | Category |
|---|---|---|
| [Touch Target Size](agenticdevelopercookbook://guidelines/cookbook/ui/platform-design-languages) | passed | Accessibility |

## Change History

| Version | Date | Author | Summary |
|---|---|---|---|
| 1.1.0 | 2026-09-22 | Mike Fullerton | Revise recipe: fix domain URI, add missing test vectors, document selectionPlacement host mode, clarify Platform Notes with all five platforms, add Edge Cases entry for host mode, refine Behavioral Requirements naming. |
| 1.0.0 | 2026-06-26 | Mike Fullerton | Initial component + recipe. |
