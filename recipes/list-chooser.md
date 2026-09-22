---
id: 40827b84-406e-4091-951b-9498b2f78253
title: ListChooser
domain: agenticdevelopercookbook://recipes/list-chooser
type: ingredient
version: 1.1.0
status: review
language: en
created: 2026-06-26
modified: 2026-09-22
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: "Disclosed chooser whose single field filters a list and adds new entries, with arrow-keyed highlight, OK/Cancel, and full keyboard control."
platforms:
- typescript
- web
tags:
  - component
  - list-chooser
  - chooser
  - ui
  - form-control
depends-on:
  - agenticdevelopercookbook://recipes/option-menu
related:
  - agenticdevelopercookbook://recipes/combobox
  - agenticdevelopercookbook://recipes/option-menu
references: []
approved-by: ''
approved-date: ''
---

# ListChooser

## Overview

`ListChooser` is a single-select "pick from a list, or add a new one" control. A trigger button discloses a popover containing one text field plus a filtered list and an OK / Cancel button bar. The field does double duty: typing narrows the list to case-insensitive substring matches, and text that matches no item can be accepted as a brand-new entry (when `allowCreate`). Arrow keys move a roving highlight through the filtered list and preview the highlighted label in the field; Enter / OK accept the current selection or entry; Esc / Cancel close without committing.

It is the keyboard-and-mouse foundation for "choose or create" pickers (first use: the research category/tag UI). It is built by composing the same primitives as `OptionMenu` — `Popover` (surface), `Input` (the field), `Button` (OK / Cancel) — with a hand-managed roving selection, rather than forking `OptionMenu`: that control has a fixed list with a separate editable "Other" row at the bottom, while this control's single field _is_ both the filter and the add-new field. It differs from `Combobox` (`@agenticdevelopertoolkit/ui/components/combobox`), an inline free-text input with a typeahead dropdown and no trigger, list, or OK/Cancel commit step.

## Behavioral Requirements

- **trigger-opens-surface**: Activating the trigger (click, Enter, or Space) MUST open the popover.
- **opens-with-field-focused**: On open, the filter/add field MUST receive focus so the user can type immediately.
- **type-narrows-list**: Typing in the field MUST narrow the list to items whose label contains the typed text as a case-insensitive substring.
- **arrow-roves-highlight**: ArrowDown / ArrowUp MUST move a roving highlight through the filtered list (and the create row when present), clamped at the ends with no wrap.
- **highlight-syncs-into-field**: While a list item is highlighted, the field MUST display that item's label (the highlight is previewed in the field); typing again replaces the preview with the typed text and clears the highlight.
- **enter-accepts-highlighted-item**: When a list item is highlighted, Enter MUST accept it via `onChange` with `isNew:false`, then close.
- **enter-accepts-typed-entry**: When nothing is highlighted, the trimmed text is non-empty and matches no item, and `allowCreate` is set, Enter MUST accept the trimmed text via `onChange` with `isNew:true`, then close.
- **typed-text-resolves-to-exact-item**: When nothing is highlighted and the trimmed text equals an item label (case-insensitive), accept MUST resolve to that item with `isNew:false`, never a new entry.
- **create-unavailable-when-disabled**: When `allowCreate` is false, text matching no item MUST NOT be acceptable — no create row, OK disabled, Enter a no-op.
- **escape-cancels**: Esc MUST close the surface without firing `onChange`.
- **ok-mirrors-enter**: The OK button MUST be equivalent to Enter and MUST be disabled whenever nothing is acceptable.
- **cancel-mirrors-escape**: The Cancel button MUST be equivalent to Esc.
- **pointer-click-commits**: A pointer click on a list row (or the create row) MUST accept it immediately and close.
- **focus-returns-on-close**: On any close, focus MUST return to the trigger.
- **empty-message-when-no-match**: When no item matches and creation is unavailable, the list MUST show the empty message.
- **shift-enter-dismiss-in-keep-open-mode**: When `keepOpenOnCommit` is true, Shift+Enter MUST close the popover; plain Enter still accepts and keeps the popup open.
- **focused-state-styling**: The trigger MUST show a distinct visual style when focused (per Apple HIG, Material Design 3, Fluent 2, or WCAG 2.1 AA focus-visible semantics).

## Appearance

Closed:

```
┌─────────────────────────────┐
│ Choose a framework…      ▾  │   ← trigger button (committed label or placeholder) + chevron
└─────────────────────────────┘
```

Open:

```
┌─────────────────────────────┐
│ [ sv|                     ]  │   ← filter/add field — focused on open
├─────────────────────────────┤
│   SvelteKit                 │   ← filtered list (narrowed by the field text)
│ + Add "sv"                  │   ← create row, shown when text matches no item
├─────────────────────────────┤
│              Cancel    OK   │   ← button bar; OK disabled until something is acceptable
└─────────────────────────────┘
```

- **Trigger**: Same visual language as `Select` / `Input` — `apt-border`, `apt-bg` background, `focus-visible` ring `apt-gold/25`, `ChevronsUpDown` glyph in `apt-text-muted`. Height 36px (9 units at 4px scale). Text is `apt-text`, truncated if long. On disabled state, opacity is reduced to 50% and cursor becomes `not-allowed`.
- **Surface**: `Popover` content with 8px padding (2 units). Minimum width 256px (64 units). The filter/add field uses the shared `Input` component styling. List rows use dropdown row treatment — keyboard highlight `bg-apt-highlight/15`, pointer hover `bg-apt-highlight/10`, text `apt-text`, corner radius `md` (6px). The committed row's check icon is `apt-gold`, all other icons are `apt-text-muted`. Row padding is vertical 6px × horizontal 8px (1.5 units × 2 units).
- **Create row**: A `Plus` glyph (14px, `apt-text-muted`) plus the `createLabel(text)` text, using the same row treatment as filtered items.
- **Button bar**: Separated from the list by an `apt-border` top rule (1px). Uses shared `Button` component — Cancel `variant="ghost"`, OK `variant="default"` (gold background). Buttons are small size, 32px height. Flex layout with gap 8px (2 units), justified to the end. Padding top 8px (2 units).
- **Empty message**: Shown when no items match and creation is unavailable. Text is `apt-text-muted`, 14px font size, padding 8px × 2 units.
- **Max list height**: 240px (60 units); overflow-y auto beyond that.
- **No raw hex; no `!important`**.

## States

| State | Appearance change |
|---|---|
| Trigger closed | Label = committed value (item label or free text) or `triggerPlaceholder`; chevron always shown |
| Trigger focused | `focus-visible` ring 2px `apt-gold/25`, border color unchanged |
| Trigger disabled | Opacity 50%, cursor `not-allowed`, non-interactive |
| Trigger hover | Border color `apt-border-strong` (on enabled trigger only) |
| Open, no highlight | Field shows the typed text; no row highlighted |
| Open, item highlighted | `bg-apt-highlight/15` on the roving row; field previews its label; `aria-activedescendant` points to that option |
| Open, committed row visible | ✓ (Check) icon shown in `apt-gold` on the committed item's row; `aria-selected="true"` on that option |
| Filter matches nothing, `allowCreate` | Only the create row shows; OK is enabled if text is non-empty after trim |
| Filter matches nothing, no create | Empty message ("No matches") shown; OK disabled |
| Nothing acceptable | OK button disabled, Cancel always enabled |
| Listbox max height exceeded | Vertical scroll enabled on list container |

The control is synchronous over the in-memory `items` prop, so it has no intrinsic loading or error state; a caller fetching items owns those and passes the resolved array (mirroring `OptionMenu` / `RecipientInput`).

## Accessibility

- **Trigger**: `<button>` with `aria-haspopup="listbox"`, `aria-expanded={open}`, `aria-label={ariaLabel}`. Must be keyboard accessible (Enter, Space to open).
- **Filter/Add field**: `<input>` with `role="combobox"` (completes WAI-ARIA combobox pattern). Labeled by `aria-label={inputLabel ?? ariaLabel}`. Has `aria-controls={listId}` pointing to the list container, `aria-autocomplete="list"`, and `aria-activedescendant` pointing to the currently highlighted option (or undefined if no highlight).
- **List container**: `<div role="listbox">` with `aria-label={ariaLabel}`. Scrollable area with `max-height` constraint.
- **List rows**: Each row is a `<button role="option">`. Has `aria-selected="true"` on the committed row (when its value matches), `aria-selected="false"` on all others. The roving highlight is not expressed via `aria-selected`, only via `aria-activedescendant` on the combobox field. Create row is also `role="option"` with `aria-selected="false"`.
- **Focus management**: Focus moves to the field on open (via `requestAnimationFrame`). On close, focus returns to the trigger via `Popover`'s base focus management.
- **Minimum touch target**: Rows and buttons MUST have a minimum 44×44pt target size (20×20 units or 10×10 units + padding). Current implementation achieves 36px height on trigger and 36px (approx) on rows with padding.
- **Keyboard paths**: All interactions (open, filter, navigate, accept, dismiss) are fully keyboard-accessible without requiring a mouse.
- **Icon labeling**: Decorative icons (chevrons, check, plus) have `aria-hidden="true"`.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|---|---|---|---|
| T1 | type-narrows-list | open, type "sv" | only "SvelteKit" remains; others removed from visible list |
| T2 | empty-message-when-no-match | `allowCreate=false`, type "zzz" | no options; empty message ("No matches") shown |
| T3 | arrow-roves-highlight, highlight-syncs-into-field | open, ArrowDown ×2, ArrowUp ×1 | `aria-activedescendant` tracks the highlighted option; field shows the highlighted item's label |
| T4 | enter-accepts-highlighted-item | open, ArrowDown ×1, Enter | `onChange(itemValue, { isNew:false })` fired; popover closes |
| T5 | escape-cancels | open, type "test", Esc | no `onChange` fired; listbox closes |
| T6 | enter-accepts-typed-entry | open, type "  Angular  ", Enter | `onChange("Angular", { isNew:true })` fired (text trimmed); popover closes |
| T7 | pointer-click-commits | open, type "Solid", click create row | `onChange("Solid", { isNew:true })` fired; popover closes |
| T8 | typed-text-resolves-to-exact-item | open, type "react" (exact match exists), Enter | `onChange("react", { isNew:false })` fired (resolves to item, not new) |
| T9 | create-unavailable-when-disabled | `allowCreate=false`, type "Nope", Enter | no `onChange` fired; nothing happens |
| T10 | ok-mirrors-enter | open, type "Vue", click OK | `onChange("Vue", { isNew:true })` fired; popover closes |
| T11 | cancel-mirrors-escape | open, type "test", click Cancel | no `onChange` fired; popover closes |
| T12 | trigger-opens-surface | click trigger | popover opens |
| T13 | opens-with-field-focused | click trigger | field receives focus (can type immediately) |
| T14 | focused-state-styling | trigger has focus | focus-visible ring visible (`apt-gold/25` ring) |
| T15 | shift-enter-dismiss-in-keep-open-mode | `keepOpenOnCommit=true`, ArrowDown, Enter, then Shift+Enter | first Enter accepts and keeps popover open; field resets; Shift+Enter closes popover |
| T16 | ok-mirrors-enter, ok-disabled-when-nothing-acceptable | open, no filter, no item highlighted | OK button is disabled (no acceptable value yet) |

## Edge Cases

- **Highlight preview vs. filter**: Filtering uses the typed text, not the previewed highlight, so arrow-navigating a single match does not collapse the list; typing again replaces the preview and re-filters. Changing the query resets highlight to -1.
- **Value resolution on the trigger**: If `value` equals an `items[i].value`, the trigger shows that item's label. Else if `allowCreate` and `value` is non-null string, the trigger shows the free text. Else it shows `triggerPlaceholder`. Falsy values (empty string, null) are treated as "no committed value", showing the placeholder.
- **Whitespace handling**: The typed text is trimmed before matching (`text.trim().toLowerCase()`) and before being accepted as a new entry. Whitespace-only text (e.g., "   ") is not acceptable for new entries.
- **Empty `items` array**: With no items and an empty filter, the empty message shows (if `allowCreate` is false) or only the create row shows (if `allowCreate` is true). Typing surfaces the create row when `allowCreate` and text is non-empty after trim.
- **Clamping at list boundaries**: ArrowUp at the top (highlight = -1) moves to index 0 on next ArrowDown. ArrowDown at the bottom (highlight = `navCount - 1`) holds position. No wrapping.
- **Case-insensitive substring matching**: The filter compares `query.trim().toLowerCase()` against `item.label.toLowerCase().includes(...)`. A query "Ve" matches "Vue", "Svelte", "Vector", etc.
- **Exact-match resolution**: When the user types text that exactly matches (case-insensitive) an item's label, pressing Enter accepts that item with `isNew:false`, not a new entry. Matching is done on the trimmed, lowercased text.
- **Committed value with allowCreate**: When `allowCreate` is true and `value` is a non-null string that does not match any item value, the trigger shows the free text and `isCommittedNew` is true. The `value` is still committed, allowing the parent to track new entries across renders.
- **Creating when a filter is active**: When `allowCreate` is true and the filter matches no items, the create row appears with the `createLabel(text)` label (using the current trimmed, non-filtered text). Clicking or accepting it commits the typed text.
- **keepOpenOnCommit mode**: When `keepOpenOnCommit` is true, an accept (Enter, OK, or row click) does not close the popover; instead, it calls `onChange`, resets the query and highlight to their initial state (as if the popover just opened), and keeps focus in the field. Shift+Enter is the only keyboard way to dismiss; Esc and Cancel still close as usual. The parent is responsible for removing the committed item from `items` if desired.
- **Disabling the component**: When `disabled` is true, the trigger button is non-interactive, `aria-expanded` is not managed (stays false), and `handleOpenChange` returns early without opening.
- **Focus return behavior**: When the popover closes (via Esc, Cancel, or an accept when `keepOpenOnCommit` is false), the `Popover` component (Base UI) automatically returns focus to the trigger button.

## Configuration

| Option | Type | Default | Description |
|---|---|---|---|
| `items` | `ListChooserItem[]` | — | The selectable items array (`{ value: string, label: string }`). Must not contain duplicate `value` fields. |
| `value` | `string \| null` | — | Committed value: an item's `value`, free text (when `allowCreate`), or null (nothing chosen). This is a controlled prop; changes must come via `onChange`. |
| `onChange` | `(value: string, meta: { isNew: boolean }) => void` | — | Fired when the user accepts a selection. `isNew` is true when the value is typed text, false when it is an item. |
| `allowCreate` | `boolean` | `true` | Whether text matching no item can be accepted as a new entry. When false, only items in the list are acceptable. |
| `ariaLabel` | `string` | — | Required. Labels the trigger button and the listbox for assistive technology. |
| `inputLabel` | `string` | `ariaLabel` | Accessible label for the filter/add field. Falls back to `ariaLabel` if not provided. |
| `placeholder` | `string` | `"Filter or add…"` | Placeholder text shown in the filter field when it is empty. |
| `triggerPlaceholder` | `string` | `"Select…"` | Text shown on the trigger when `value` is null (nothing committed). |
| `okLabel` | `string` | `"OK"` | Accept button label. |
| `cancelLabel` | `string` | `"Cancel"` | Cancel / dismiss button label. |
| `createLabel` | `(text: string) => string` | `` `Add "${text}"` `` | Function that builds the create-row label from the typed text. Example: `(text) => `Add "${text}"` becomes "Add "React"" when text is "React". |
| `emptyLabel` | `string` | `"No matches"` | Message shown when no item matches the filter and creation is unavailable. |
| `keepOpenOnCommit` | `boolean` | `false` | When true, accepting a selection keeps the popover open for adding multiple entries; Shift+Enter or Esc/Cancel closes. When false, any accept closes the popover. |
| `disabled` | `boolean` | `false` | When true, the trigger is non-interactive and the component cannot be opened. |
| `className` | `string` | — | Extra CSS class(es) applied to the trigger button for custom styling. |

## Deep Linking

Not applicable: ListChooser is a form control component without inherent URL semantics. Deep linking to a chooser state (open/closed, highlighted item, filter text) is handled by the parent page/screen, not the component itself.

## Localization

Not applicable: All text strings (labels, placeholders, messages) are passed as props, allowing the parent to provide localized strings for any language. The component does not embed any fixed text.

## Accessibility Options

Not applicable: ListChooser is a presentational control without intrinsic support for platform accessibility display options (Reduce Motion, Increase Contrast, Differentiate Without Color). The parent component or design system MAY apply these settings to the underlying `Button`, `Input`, and `Popover` primitives.

## Feature Flags

Not applicable: ListChooser is a presentational UI control, not a feature that requires gating or conditional delivery. Feature flags belong to the parent application or feature set.

## Analytics

Not applicable: ListChooser is a presentational form control. Analytics instrumentation (event tracking, property logging) is the parent component's responsibility. The component emits no structured event data.

## Privacy

Not applicable: ListChooser does not collect, store, or transmit any data. All values, including free-text entries, are controlled via props and callbacks. The parent is responsible for handling any privacy or consent concerns related to the data it provides or collects via the component.

## Logging

No structured logging. ListChooser is a presentational form control; it emits no log events. Diagnostic logging (if needed) belongs to the parent or consuming application.

## Platform Notes

- **React/Web (`packages/web/packages/ui/src/components/list-chooser.tsx`)**: A React hook-based component using `Popover`, `Input`, and `Button` primitives from the same package. The roving selection is hand-managed via state (`highlight` index). Uses `aria-activedescendant` to express the highlighted option. The field has `role="combobox"` per WAI-ARIA combobox pattern. Base UI `Popover` handles focus management on open/close. Filtering is synchronous substring matching over the in-memory `items` array; no async behavior.

- **SwiftUI (iOS/macOS)**: Start from `Menu` + `TextField` for the trigger and dropdown surface. Use a `@State` for the roving highlight (similar to web), a `List` (or `VStack` with scroll view) for the filtered items, and separate `Button` views for OK/Cancel. The field should be focused on open via `focused()` or `@FocusState`. For the combobox pattern, a custom `AccessibilityElement` with `rolesAndAdjustedCharacteristics` may be needed to replicate the WAI-ARIA `role="combobox"` and `aria-activedescendant` semantics. Keyboard navigation (arrow keys, Enter, Escape) is handled via `onKeyDown` on the field or via `UIKeyboardType` + custom gesture handling. Filter case-insensitive substrings using `String.localizedCaseInsensitiveContains()`. The create row is a separate conditional button or row in the list.

- **Kotlin/Jetpack Compose (Android)**: Start from `OutlinedTextField` (trigger when closed) + `Popup` or `DropdownMenu` (surface). Use a `LazyColumn` for the filtered items. State management mirrors web: `highlightedIndex`, `query`, `isOpen`. Use `MutableState` or `ViewModel` for state. `ArrowUp` / `ArrowDown` key handling via `KeyEvent` in the field's `onKeyEvent` callback. The roving highlight can be expressed via `Modifier.semantics` with a custom semantic property or via Compose's testing semantics. Focus the field on open with `.focusRequester().requestFocus()`. The create row is a separate `DropdownMenuItem` or composable button. Filter strings using `contains(ignoreCase = true)`. Button bar uses `Row` with `Button` composables for OK/Cancel.

- **WinUI 3 / C# (.NET)**: Start from `ComboBox` control, but customize heavily since standard `ComboBox` does not support the "choose or create" dual-mode filtering. Build with `TextBox` (the filter/add field), `ListView` or `ItemsControl` (the list), and `StackPanel` with `Button` controls (OK/Cancel) in a `ContentDialog` or custom `Popup`. State management uses `INotifyPropertyChanged` or `ObservableCollection`. Bind the `Items` collection to a `CollectionViewSource` with a `Filter` predicate that implements case-insensitive substring matching (use `StringComparison.OrdinalIgnoreCase` or `CultureInfo.CurrentCulture.CompareInfo.IndexOf`). Arrow-key navigation and roving highlight are handled by a custom `SelectionModel` or via `ListViewItem` focus management (`Focus()`, `FocusManager`). The `TextBox` should auto-focus when the popup opens (`Popup.IsOpen = true`). Create row is conditionally shown in the list based on `AllowCreate && text != ""`. The `ComboBox` pattern in WinUI does not map directly; instead, build this as a custom composite control or a page-level pattern with a `TextBox`, `ListView`, and button bar in a `Popup`.

## Design Decisions

- **Compose `OptionMenu`'s primitives, don't fork it.** The roving selection, `aria-activedescendant`, and Popover-with-trigger shape are shared, but the single field that both filters and creates is a distinct interaction. Subclassing `OptionMenu` (fixed list + bottom "Other" row) would have entangled two models; composing the same primitives keeps each control single-responsibility.

- **Filter on typed text, preview the highlight.** Keeping the filter query separate from the previewed highlight label means arrow-navigation never re-filters the list out from under the user. Users can arrow through matches without the list collapsing, and typing again replaces the preview and re-filters.

- **Selection vs. commit are distinct.** Moving the highlight never fires `onChange`; only an accept (Enter, OK, or row click) commits. This allows users to explore the list without side effects, matching standard form control behavior.

- **No built-in async state.** `items` is a controlled in-memory prop, so loading/error belong to the caller — consistent with sibling form controls like `OptionMenu` and `RecipientInput`. This keeps the component presentational and predictable.

- **Shift+Enter for dismiss in keep-open mode.** In multi-select ("collect a set") mode, users can press Enter to add another entry without closing. Shift+Enter is the keyboard way to signal "I'm done"; it mirrors the Escape key and Cancel button, completing the keyboard accessibility matrix.

- **Exact-match text resolution.** If the trimmed, lowercased user input exactly matches an item's label, it resolves to that item with `isNew:false`, not a new free-text entry. This prevents accidental duplication when a user types an existing item's full name.

## Compliance

No additional compliance categories apply to this presentational control beyond the accessibility and keyboard navigation requirements stated in the Accessibility section, which align with WCAG 2.1 AA and platform design guidelines (Apple HIG, Material Design 3, Fluent 2).

## Change History

| Version | Date | Author | Summary |
|---|---|---|---|
| 1.1.0 | 2026-09-22 | Claude Haiku 4.5 | Expand platform notes with guidance for Swift, Kotlin, and WinUI 3 implementations; add missing template sections (Deep Linking, Localization, Accessibility Options, Feature Flags, Analytics, Privacy); clarify appearance specs with specific measurements and color tokens; add focused-state-styling requirement and T14, T15, T16 test vectors; document Shift+Enter behavior in keep-open mode. |
| 1.0.0 | 2026-06-26 | Mike Fullerton | Initial component + recipe. |
