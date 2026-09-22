---
id: e1859aa2-d0c4-4d9a-b926-203dd5fbbca3
title: "AddUsersModal"
domain: agenticdevelopertoolkit://recipes/add-users-modal
type: recipe
version: 1.0.1
status: review
language: en
created: 2026-06-26
modified: 2026-09-22
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: "A controlled dialog that stages users in a growing DataTable via an inline entry row, then hands the collected rows to an onAdd callback."
platforms:
  - typescript
  - web
tags:
  - modal
  - dialog
  - table
  - users
ingredients:
  - agenticdevelopertoolkit://recipes/data-table
  - agenticdevelopertoolkit://recipes/alert-and-dialog
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# AddUsersModal

## Overview

A modal in `@agenticdevelopertoolkit/ui` for building a list of users to add. It composes
`Dialog` + `DataTable` + `Input` + `AlertModal` + `Button`. Each "Add" appends
the entry row to a table above; the dialog's final "Add" hands the rows to a
caller callback (`onAdd`).

It is a controlled dialog: a growing `DataTable` of staged users on top, an
inline entry row (name / email / phone / admin note) below it with an **Add**
button, and a footer (Cancel / Add).

## Ingredients

| Name | Domain | Role | Required | Configuration |
|---|---|---|---|---|
| DataTable | agenticdevelopertoolkit://recipes/data-table | Growing table of staged `DraftUser` rows | yes | columns Name · Email · Phone · Admin note; selection; empty label |
| AlertAndDialog | agenticdevelopertoolkit://recipes/alert-and-dialog | The modal `Dialog` shell (`DialogContent max-w-2xl`) + the discard-confirm `AlertModal` | yes | modal semantics; discard-confirm copy |

Composed shared primitives without their own recipe domains: `Input` and `Field`
(the entry row inputs) and `Button` (entry Add + footer Cancel/Add).

## Integration Requirements

- **must-add-row-on-enter-or-button**: The AddUsersModal MUST append a `DraftUser`
  to the staged `DataTable`, clear the entry fields, and refocus the Name input
  when Enter is pressed in any entry field or the entry **Add** button is
  activated.
- **must-ignore-blank-entry**: The AddUsersModal MUST treat a fully blank entry
  (no name and no contact — email/phone) as a no-op and MUST NOT append a row,
  mirroring the invitation contact rule.
- **must-keep-tab-order**: The entry row MUST follow tab order Name → Email →
  Phone → Note → **Add**, with the Add button reached as the next tab stop after
  Note via a flexible spacer.
- **must-disable-footer-add-when-empty**: The footer **Add** button MUST be
  `disabled` while the staged `DataTable` contains no rows.
- **must-disable-footer-add-when-busy**: The footer **Add** button MUST be
  `disabled` when `busy` is true.
- **must-call-onadd-and-close**: Activating the footer **Add** MUST call
  `onAdd(stagedRows)` and close the dialog.
- **must-confirm-cancel-when-dirty**: Cancel, Esc, or a backdrop click MUST open a
  discard-confirm `AlertModal` when the staged table has rows OR the entry row has
  content; otherwise it MUST close immediately. State resets on close.

## Layout

```
┌ Add users ─────────────────────────────────────────────────────┐
│  DataTable: Name · Email · Phone · Admin note                   │  staged rows
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Ada     │ ada@x.io   │ +1 555 0100 │ priority             │  │
│  └──────────────────────────────────────────────────────────┘  │
│  [ name ][ email ][ phone ][ admin note ]        ……    [ Add ]  │  entry row
│                                                                 │
│                                       [ Cancel ]   [ Add ]      │  footer
└─────────────────────────────────────────────────────────────────┘
```

- `DialogContent` (`max-w-2xl` — the table needs width); the staged `DataTable`
  above; the entry row a `flex items-end gap-2` of `Field`-wrapped `Input`s + a
  `flex-1` spacer + the Add `Button`. Footer right-justified `[ Cancel ][ Add ]`.
- The staged table supports `DataTable` selection; staged rows can be removed (a
  per-row `×` or a Remove affordance) — optional, but at minimum the table shows
  what is queued.
- No raw hex; no `!important`.

## Shared State

| State | Source | Consumer | Direction | Mechanism |
|---|---|---|---|---|
| stagedRows (`DraftUser[]`) | AddUsersModal | DataTable, footer Add (enabled state), `onAdd` | Down / Up | Component state + prop; `onAdd` callback |
| entryFields {name, email, phone, note} | AddUsersModal | Entry `Input`s | Down / Up | Component state + input `onChange` |
| discardConfirm open | AddUsersModal | AlertAndDialog (AlertModal) | Down | Boolean state |
| busy | Caller | Footer Add | Down | Prop |
| open | Caller | Dialog | Down | Prop (`open`); `onClose` callback up |

## Integration Test Vectors

| ID | Requirements | Input | Expected |
|---|---|---|---|
| T1 | must-add-row-on-enter-or-button | Type a name, press Enter in a field | Row appended to staged table; entry cleared; Name refocused |
| T2 | must-ignore-blank-entry | Empty entry, press Enter / activate Add | No row added (no-op) |
| T3 | must-disable-footer-add-when-empty | 0 staged rows | Footer Add disabled |
| T4 | must-disable-footer-add-when-empty | ≥1 staged row | Footer Add enabled |
| T5 | must-disable-footer-add-when-busy | `busy=true` | Footer Add disabled |
| T6 | must-call-onadd-and-close | Footer Add with staged rows | `onAdd(stagedRows)` called; dialog closes |
| T7 | must-confirm-cancel-when-dirty | Cancel with staged rows or entry content | Discard-confirm `AlertModal` opens |
| T8 | must-confirm-cancel-when-dirty | Cancel with empty table and empty entry | Closes immediately, no confirm |
| T9 | must-keep-tab-order | Tab from Note | Focus lands on the Add button |

## Edge Cases

- A fully blank entry is a no-op; a row needs at least a name OR a contact
  (email/phone) to be added.
- Footer Add is disabled at 0 staged rows; an empty staged table shows the
  `DataTable` empty label.
- `busy` disables the footer Add button to prevent multiple submissions; user can
  still dismiss via Cancel or Esc if there are unsaved changes.
- Cancel / Esc / backdrop with a dirty state (rows or entry content) opens the
  discard confirm; with a clean state it closes immediately.
- State resets on close, so reopening starts with an empty entry row and table.

## Platform Notes

- **SwiftUI**: Start from a modal presentation using `.sheet()` or an overlay container. Compose with a List or LazyVStack for staged rows, TextFields for input, and Buttons for actions. Differs: SwiftUI state binding and @State management patterns; TextField validation and keyboard handling; native modal dismissal semantics with `.interactiveDismissibilityDisabled()` when dirty.
- **Compose**: Start from a Dialog composable with a LazyColumn for the user list, TextField composables for input fields, and Row/Column for layout. Differs: Compose's state hoisting pattern; Material Design 3 theming and elevation; TextField focus and keyboard handling via Compose's Focus API; back-button handling via LocalBackPressedDispatcher.
- **React/Web**: Implementation at `packages/web/packages/ui/src/blocks/add-users-modal.tsx`. Composes Dialog*, DataTable, Input, Field, Button, and UnsavedChangesAlert components. Uses Tailwind for layout and spacing; focus management via useRef and requestAnimationFrame for post-render refocus on entry Name field.
- **AppKit / UIKit**: On iOS, use a sheet presentation controller with UITableViewController for staged rows and UITextFields for input. On macOS, use a sheet or window-modal presentation. Differs: UIControl delegate patterns for input handling; platform keyboard lifecycle management; safe area insets and view controller transitions; UITableView cell reuse patterns.
- **WinUI 3**: Use ContentDialog with a DataGrid control for staged rows and TextBox controls for input fields. Layout with StackPanel; use Button controls with Command bindings. Differs: XAML markup for UI definition; ItemsSource binding for grid data; TextBox TextChanged events vs React onChange; ContentDialog command patterns; grid column definitions via DataGridTextColumn.

## API

`@agenticdevelopertoolkit/ui/blocks/add-users-modal`:

```ts
interface DraftUser { name: string; email: string; phone: string; note: string }
interface AddUsersModalProps {
  open: boolean
  onAdd: (users: DraftUser[]) => void
  onClose: () => void
  busy?: boolean
  title?: string        // default "Add users"
}
export function AddUsersModal(props: AddUsersModalProps): React.ReactElement
```

## Accessibility

`Dialog` modal semantics with focus trap and restore; entry inputs are
labeled via `Field`. Tab order is explicit and natural: Name → Email →
Phone → Note → Add button (via `flex-1` spacer), then Close (Esc). Enter-to-add
keeps focus flowing back to Name for fast repeated entry. The empty staged table
displays the `DataTable` empty label.

## Design Decisions

- **Decision**: A row needs at least a name or a contact to be added; a blank
  entry is a no-op. **Rationale**: Mirrors the invitation contact rule and avoids
  staging empty rows.
- **Decision**: Enter-to-add refocuses Name. **Rationale**: Enables fast repeated
  keyboard entry.
- **Decision**: Explicit tab order ends on Add after Note via a flexible spacer.
  **Rationale**: Predictable keyboard flow to the primary entry action.
- **Decision**: Cancel confirms only when dirty. **Rationale**: Avoids nagging the
  user when there is nothing to lose.
- **Decision**: `busy` disables the footer Add button only; does not block Esc or
  Cancel. **Rationale**: Prevents accidental duplicate submissions while allowing
  users to abandon unsaved work if needed.

## Compliance

| Check | Status | Category |
|---|---|---|
| Artifact formatting (recipe) | passed | artifact-formatting |
| UI guidelines — no raw hex, no `!important` | passed | adh-ui-guidelines |

## Change History

| Version | Date | Author | Summary |
|---|---|---|---|
| 1.0.1 | 2026-09-22 | Claude | Restructure Platform Notes with all five platform guidance bullets; correct `busy` behavior to match source; update domain URIs from agenticdeveloperhub to agenticdevelopercookbook; refine requirements for source fidelity. |
| 1.0.0 | 2026-06-26 | Mike Fullerton | Initial conversion from legacy UI spec. |
