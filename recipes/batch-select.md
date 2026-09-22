---
id: 33aaba17-874f-43aa-8d70-4a5dab2081a1
title: Batch Select
domain: agenticdevelopercookbook://ingredients/batch-select
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Hook and button for toggling multi-select mode in lists, with automatic selection
  clearing when visible rows change.
platforms:
- web
tags:
- selection
- list-control
- multi-select
depends-on: []
related: []
references: []
---

# Batch Select

## Overview

Batch Select provides a mode for lists to enter multi-select behavior, distinct from the default single-select interaction. The hook (`useBatchSelect`) manages the state of active (batch mode on/off) and selected row IDs, with automatic clearing of selections when the visible rows change (via page, filter, or search). The button component (`BatchSelectButton`) toggles batch mode and reflects the current state with label changes.

## Behavioral Requirements

- **must-expose-active-state**: The hook MUST expose a boolean `active` property indicating whether batch mode is currently active.
- **must-expose-selected-ids**: The hook MUST expose a `selectedIds` property as a `Set<string>` of currently selected row identifiers.
- **must-provide-set-selected-ids**: The hook MUST provide a `setSelectedIds` function to update the selected row IDs, accepting a `Set<string>` parameter.
- **must-expose-toggle-active**: The hook MUST provide a `toggleActive` function that switches batch mode on and off.
- **must-clear-selection-on-toggle-exit**: When `toggleActive` is called to exit batch mode, the `selectedIds` MUST be cleared to an empty `Set<string>`.
- **must-clear-selection-on-toggle-entry**: When `toggleActive` is called to enter batch mode, the `selectedIds` MUST be cleared to an empty `Set<string>`.
- **must-provide-clear-function**: The hook MUST provide a `clear` function that empties `selectedIds` without changing the `active` state.
- **must-expose-count**: The hook MUST expose a `count` property equal to the size of `selectedIds`.
- **must-reset-on-reset-key-change**: When the `resetKey` option changes (as determined by `Object.is` comparison), the hook MUST reset `selectedIds` to an empty `Set<string>` synchronously during render.
- **must-never-reuse-set-reference**: Each call to `setSelectedIds` MUST create a new `Set<string>` instance; the returned `selectedIds` MUST NOT be the same object across renders unless unchanged.
- **must-button-render-label**: The `BatchSelectButton` MUST render a clickable element displaying either the `selectLabel` (when inactive) or `doneLabel` (when active).
- **must-button-toggle-on-click**: The `BatchSelectButton` MUST call `batch.toggleActive` when clicked.
- **must-button-announce-pressed-state**: The `BatchSelectButton` MUST set `aria-pressed` to reflect the `batch.active` state.
- **must-button-default-select-label**: If `selectLabel` is not provided, the button MUST render "Select".
- **must-button-default-done-label**: If `doneLabel` is not provided, the button MUST render "Done".

## Appearance

Not applicable: This is a state management hook and a generic button. Visual appearance is determined by the underlying Button component and the consuming application.

## States

| State | Appearance change |
|-------|------------------|
| active: true | Button displays `doneLabel` text; `aria-pressed="true"` |
| active: false | Button displays `selectLabel` text; `aria-pressed="false"` |

## Accessibility

- **role**: The `BatchSelectButton` MUST delegate its role to the underlying Button component, which provides button semantics.
- **pressed-state-announcement**: The `BatchSelectButton` MUST announce the pressed state via `aria-pressed` attribute, updating to reflect `batch.active` on each render.
- **label-provided-by-text**: The button text (`selectLabel` or `doneLabel`) MUST serve as the accessible label.
- **keyboard-navigable**: The underlying Button component MUST be keyboard navigable and activatable via Enter or Space keys.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| batch-select-001 | must-expose-active-state | `useBatchSelect()` | Returns object with `active: false` |
| batch-select-002 | must-expose-selected-ids | `useBatchSelect()` | Returns object with `selectedIds` as empty `Set<string>` |
| batch-select-003 | must-expose-toggle-active | `useBatchSelect()` | Returns object with `toggleActive` function |
| batch-select-004 | must-expose-count | `useBatchSelect()` with selections | `count` equals `selectedIds.size` |
| batch-select-005 | must-clear-selection-on-toggle-exit | active=true, selectedIds={id1, id2}, call toggleActive | active becomes false, selectedIds becomes empty Set |
| batch-select-006 | must-clear-selection-on-toggle-entry | active=false, selectedIds={}, call toggleActive | active becomes true, selectedIds remains empty Set |
| batch-select-007 | must-provide-clear-function | active=true, selectedIds={id1}, call clear | active stays true, selectedIds becomes empty Set |
| batch-select-008 | must-reset-on-reset-key-change | Render with resetKey=1, then resetKey=2, selectedIds={id1} | selectedIds cleared to empty Set during render of resetKey=2 |
| batch-select-009 | must-reset-on-reset-key-change | Render with resetKey="search:foo", then resetKey="search:foo" (same value) | selectedIds retained, no reset |
| batch-select-010 | must-never-reuse-set-reference | Set selectedIds, render, render again without change | selectedIds reference is the same object between unchanged renders |
| batch-select-011 | must-button-render-label | BatchSelectButton with active=false, selectLabel="Pick" | Button displays "Pick" |
| batch-select-012 | must-button-render-label | BatchSelectButton with active=true, doneLabel="Finish" | Button displays "Finish" |
| batch-select-013 | must-button-default-select-label | BatchSelectButton with active=false, no selectLabel | Button displays "Select" |
| batch-select-014 | must-button-default-done-label | BatchSelectButton with active=true, no doneLabel | Button displays "Done" |
| batch-select-015 | must-button-announce-pressed-state | BatchSelectButton with active=false | `aria-pressed="false"` on button element |
| batch-select-016 | must-button-announce-pressed-state | BatchSelectButton with active=true | `aria-pressed="true"` on button element |
| batch-select-017 | must-button-toggle-on-click | BatchSelectButton clicked while active=false | batch.toggleActive is called, active becomes true |

## Edge Cases

- **Rapid toggles**: If `toggleActive` is called multiple times in quick succession, each call MUST correctly flip the state and clear the selection; the final state MUST reflect the number of toggles applied.
- **resetKey as primitive wrapper**: If `resetKey` is an object or array (non-primitive) that is rebuilt each render, the selection MUST be cleared on every render even if the semantic value is unchanged, because `Object.is` compares reference identity, not deep equality.
- **selectedIds mutation**: If a caller mutates the returned `selectedIds` Set directly, the behavior is undefined. The contract requires that all updates go through `setSelectedIds`; direct mutation violates the contract.
- **Empty selection display**: When `selectedIds` is empty (size is 0), the button text and pressed state MUST still render correctly; there is no visual hiding or disabling of the button based on count.
- **Render-time reset vs effect**: The reset happens synchronously during render (not in an effect), so a commit with new `resetKey` will never execute pending actions with stale selection against new rows.

## Configuration

Not applicable: This hook does not accept configuration options beyond `resetKey`; it provides a fixed interface with no feature toggles or customization beyond label text on the button component.

## Deep Linking

Not applicable: Batch Select manages internal component state and does not implement deep linking.

## Localization

| String Key | Default (en) | Context |
|-----------|-------------|---------|
| `selectLabel` | "Select" | Label for BatchSelectButton when not in batch mode |
| `doneLabel` | "Done" | Label for BatchSelectButton when in batch mode |

## Accessibility Options

Not applicable: Batch Select does not respond to accessibility display options such as Reduce Motion, Increase Contrast, or Differentiate Without Color, as it has no motion or color-dependent behaviors beyond what the underlying Button component provides.

## Feature Flags

Not applicable: Batch Select is a foundational hook with no feature flag integration in the source code.

## Analytics

Not applicable: Batch Select does not emit analytics events directly; consuming applications MAY track interactions with BatchSelectButton separately if needed.

## Privacy

Not applicable: Batch Select stores only row identifiers in memory; no data is persisted, transmitted, or collected.

## Logging

Not applicable: Batch Select does not emit debug or informational logs.

## Platform Notes

- **React/Web**: Implemented as a custom hook (`useBatchSelect`) exported from `packages/web/packages/ui/src/blocks/batch-select.tsx`. The hook manages state with `React.useState` and `React.useCallback`, and performs render-time reset via `React.useRef`. `BatchSelectButton` wraps the shared Button component with `aria-pressed` binding. Source files: `batch-select.tsx`.
- **SwiftUI**: Start with a `@State` property for `active` and a `@State` property for `selectedIds` (as a `Set<String>`). Implement `toggleActive` and `clear` methods matching the hook interface. Perform reset checks in the view's body computation using a local state tracker for `resetKey`, clearing selection synchronously before rendering.
- **Compose**: Implement as a composable returning a data class mirroring `BatchSelect`. Use `remember { mutableStateOf(...) }` for `active` and `selectedIds`. Perform `resetKey` comparison in the composable body (not in an effect) to clear synchronously. `BatchSelectButton` should compose the Button with `toggleOnClick { batch.toggleActive() }` and bind `contentDescription` to reflect pressed state.
- **AppKit / UIKit**: Implement as a reference type (class) managing `active` and `selectedIds` properties with property observers. Store the last `resetKey` and check it on access to the hook, resetting synchronously if it changes. Provide `toggleActive()` and `clear()` methods. `BatchSelectButton` is a UIButton subclass or button factory that calls `toggleActive()` on tap and updates its `isSelected` / `UIControl.State.selected` to reflect active state.
- **WinUI 3**: Implement as a `BindableBase` or `ObservableObject` exposing `Active` (bool), `SelectedIds` (ObservableCollection<string>), `SetSelectedIds(IEnumerable<string>)`, `ToggleActive()`, and `Clear()` methods. Use a backing field for `ResetKey` and compare on property get to reset `SelectedIds` synchronously. `BatchSelectButton` is a `Button` subclass or data template binding the text to Active state, calling `ToggleActive()` on Click, and setting `AutomationProperties.AutomationId` to expose accessibility semantics.

## Design Decisions

**Selection must be cleared on both entry and exit:** Clearing on exit prevents invisible selection after toggling off. Clearing on entry ensures a fresh batch interaction does not inherit selections from prior single-select interactions. This prevents accidentally acting on rows a user has reason to believe were deselected.

**Reset happens during render, not in an effect:** An effect-based reset would allow one render to commit with stale selections against new rows (e.g., after filtering or paging). The render-time reset via `React.useRef` ensures that by the time `selectedIds` is visible to the caller, it already reflects the current `resetKey`.

**`resetKey` uses `Object.is` comparison:** This permits primitives (page number, search string) to be passed directly without rebuilding. Passing non-primitives (rebuilt objects or Sets) will cause reset on every render; this is a caller error, not a hook error.

**Selection clearing must use empty Set identity:** A shared `EMPTY_SELECTION` Set reference prevents caller effects and memos from being invalidated by render-time resets. If each reset created a new empty Set, consumers would see it as a new value and re-run memoized computations unnecessarily.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| [accessible-button-semantics](agenticdevelopercookbook://compliance/ui-interaction#accessible-button-semantics) | passed | UI Interaction |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation |
