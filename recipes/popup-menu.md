---
id: bf49f12b-61cd-4e34-b395-0b6e5fe715a2
title: Popup Menu
domain: agenticdevelopercookbook://ingredients/popup-menu
type: ingredient
version: 1.0.1
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A focused-item selector dropdown menu with optional All and New entry points.
platforms:
- typescript
- web
tags:
- menu
- dropdown
- selector
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Popup Menu

## Overview

A dropdown menu for selecting from a list of items, with an optional "All" state representing no focused item and an optional "New…" entry for creating new items. Commonly used as a focused-item selector in a rail UI. The component decouples selection logic from routing; the caller owns the deep link navigation.

## Behavioral Requirements

- **must-accept-items**: The component MUST accept an array of `PopupMenuItem` objects, each with `id` (string) and `label` (string).
- **must-accept-selected-id**: The component MUST accept `selectedId` as a string or null; null represents the "All" (nothing focused) state.
- **must-call-select-callback**: When an item is selected in the dropdown, the component MUST invoke the `onSelect` callback with the item's id (or null for "All").
- **must-render-all-row-when-enabled**: When `allLabel` is not null, the component MUST render an "All" row in the dropdown as the first item, with the provided label.
- **must-omit-all-row-when-disabled**: When `allLabel` is null, the component MUST omit the "All" row entirely.
- **must-render-new-row-when-callback-present**: When the `onNew` callback is provided, the component MUST render a "New…" row at the bottom of the dropdown, separated from items by a divider, and invoke `onNew` when selected.
- **must-omit-new-row-when-no-callback**: When `onNew` is not provided, the component MUST omit the "New…" row and divider entirely.
- **must-display-selected-label-on-trigger**: The trigger MUST display the label of the currently selected item, or the `allLabel` if `selectedId` is null, or an empty string if no "All" label is configured.
- **must-use-radio-items-for-selection**: Items in the dropdown MUST be rendered as radio items (single-selection semantics), with the currently selected item marked as checked.
- **must-truncate-long-trigger-labels**: Long labels on the trigger MUST be truncated with an ellipsis to fit within the trigger's width; text overflow is invisible (overflow: hidden).
- **must-accept-aria-label**: The component MUST accept an `ariaLabel` prop and apply it to the trigger element for assistive technology.
- **must-hide-icon-from-accessibility**: The default icon (ChevronsUpDown or custom icon) MUST be marked `aria-hidden` so it is not announced by screen readers.
- **must-default-to-chevron-icon**: When no custom `icon` prop is provided, the component MUST render a ChevronsUpDown icon (13px size) to indicate the dropdown affordance.
- **must-accept-custom-icon**: The component MUST accept a custom `icon` prop (ReactNode) and render it in place of the default chevron.
- **must-accept-trigger-className**: The component MUST accept a `className` prop and merge it with the trigger's built-in classes using `cn()`; consumer classes override defaults.
- **must-warn-on-sentinel-collision**: If any item in the `items` array has an id of `"__all__"`, the component MUST log a warning: `PopupMenu: item id "__all__" collides with the All sentinel`.
- **must-render-items-as-radio-group**: All `PopupMenuItem` entries MUST be rendered within a `DropdownMenuRadioGroup` to ensure mutually exclusive selection.

## Appearance

- **Corner radius**: `rounded-md` (approximately 6–8px default on web)
- **Padding**: vertical `py-[0.4rem]` (approximately 6.4px), horizontal `px-[0.6rem]` (approximately 9.6px)
- **Font**: `text-[0.8rem]` (approximately 12.8px), weight not explicitly specified (inherits; typically 400 regular)
- **Background (trigger)**: `bg-apt-surface` (semantic color token)
- **Background (dropdown)**: `bg-apt-surface-2` (secondary surface token)
- **Foreground/Text**: `text-apt-text` (semantic text token)
- **Border**: width 1px, color `apt-border` (default), `apt-border-strong` on hover, `apt-gold` on focus
- **Shadow**: none
- **Gap between label and icon**: `gap-2` (approximately 8px)
- **Min/Max size**: dropdown has minimum width `min-w-[12rem]` (approximately 192px)

## States

| State | Appearance change |
|-------|------------------|
| Default | Border `apt-border`, background `apt-surface`, text `apt-text` |
| Hover | Border strengthens to `apt-border-strong` |
| Focus (keyboard) | Border becomes `apt-gold`, outline removed (`outline-none`) |
| Open (dropdown visible) | Dropdown menu renders with background `apt-surface-2`, border `apt-border` |
| Selected item (in dropdown) | Radio item is marked checked (styling varies by dropdown implementation) |

## Accessibility

- **Role**: Trigger is a button (`DropdownMenuTrigger`); dropdown uses ARIA combobox pattern.
- **Label**: `ariaLabel` prop is required and MUST be provided by the caller; it is applied directly to the trigger.
- **Icon accessibility**: The icon (default chevron or custom) MUST have `aria-hidden` attribute to prevent redundant announcement.
- **State announcement**: Changes in selection (e.g., item marked as selected) are announced by the dropdown menu's native ARIA attributes.
- **Minimum tap target**: Trigger dimensions are approximately 25.6px tall (12.8px text + 6.4px top padding + 6.4px bottom padding), which falls short of the Apple HIG recommended minimum of 44pt. This smaller size is explicit in the source design.
- **Keyboard navigation**: Trigger is focusable via keyboard; dropdown menu handles arrow keys and Enter/Escape per ARIA practices.
- **Label for items**: Each item rendered via `DropdownMenuRadioItem` displays its `label` prop as visible text; no additional accessible labels are required.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| popup-001 | must-accept-items | `items=[{id:"a", label:"Item A"}, {id:"b", label:"Item B"}]` | Both items appear in dropdown |
| popup-002 | must-accept-selected-id, must-display-selected-label-on-trigger | `selectedId="a"`, item A has label "Item A" | Trigger displays "Item A" |
| popup-003 | must-accept-selected-id, must-display-selected-label-on-trigger | `selectedId=null`, `allLabel="All"` | Trigger displays "All" |
| popup-004 | must-call-select-callback | User clicks item with `id="x"` | `onSelect("x")` is called |
| popup-005 | must-call-select-callback | User clicks "All" row | `onSelect(null)` is called |
| popup-006 | must-render-all-row-when-enabled | `allLabel="All"` | "All" row appears as first item in dropdown |
| popup-007 | must-omit-all-row-when-disabled | `allLabel=null` | No "All" row in dropdown |
| popup-008 | must-display-selected-label-on-trigger | `selectedId=null`, `allLabel=null` | Trigger displays empty string |
| popup-009 | must-render-new-row-when-callback-present | `onNew` callback provided | "New…" row appears below divider in dropdown |
| popup-010 | must-omit-new-row-when-no-callback | `onNew` not provided | No "New…" row in dropdown |
| popup-011 | must-call-select-callback | User clicks "New…" row | `onNew()` is called |
| popup-012 | must-use-radio-items-for-selection | `selectedId="a"` in a radio group | Item A is marked as checked/selected in radio group |
| popup-013 | must-truncate-long-trigger-labels | Label exceeds trigger width | Label is truncated with overflow hidden (ellipsis rendering depends on CSS) |
| popup-014 | must-accept-aria-label | `ariaLabel="Select focus"` | Trigger has `aria-label="Select focus"` |
| popup-015 | must-default-to-chevron-icon | No `icon` prop | ChevronsUpDown icon (13px) is rendered on trigger |
| popup-016 | must-accept-custom-icon | `icon={<CustomIcon />}` | Custom icon is rendered instead of chevron |
| popup-017 | must-accept-trigger-className | `className="w-auto"` | Trigger merges custom class; `w-auto` overrides default `w-full` |
| popup-018 | must-hide-icon-from-accessibility | Default or custom icon present | Icon has `aria-hidden` attribute |
| popup-019 | must-warn-on-sentinel-collision | `items=[{id:"__all__", label:"Item"}]` | Console warning logged: `PopupMenu: item id "__all__" collides with the All sentinel` |

## Edge Cases

- **Empty items array**: When `items` is empty, the dropdown renders no selectable items (only "All" and/or "New…" if configured). Behavior is valid; the menu remains functional for "All" or "New" selection.
- **Null selectedId with allLabel omitted**: `selectedId=null` and `allLabel=null` results in trigger displaying an empty string. This is intentional for a plain switcher where one item is always selected; the caller MUST ensure one item is always selected in this mode.
- **Custom className merge behavior**: The `className` prop is merged using `cn()`, which means utility classes in the prop override the component's built-in classes (e.g., `className="w-auto"` overrides `w-full`). This is a feature enabling flexible trigger sizing.
- **onNew without allLabel=null**: Both "All" and "New…" can coexist; selecting "All" (null) followed by "New" calls `onNew()` independently.
- **Rapid selection changes**: If `selectedId` changes between render cycles, the radio group updates; the new `selectedId` becomes the checked item.
- **ariaLabel is required**: The `ariaLabel` parameter is a required TypeScript function parameter with no default or optional marker; TypeScript enforces this at compile time, preventing callers from omitting it.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `items` | `PopupMenuItem[]` | (required) | Array of selectable items; each must have unique `id` and a `label`. |
| `selectedId` | `string \| null` | (required) | The currently selected item's id, or null for "All" (nothing focused). |
| `onSelect` | `(id: string \| null) => void` | (required) | Callback invoked when an item or "All" is selected. |
| `allLabel` | `string \| null` | `"All"` | Label for the "All" (nothing focused) row; omits the row if null. |
| `onNew` | `() => void` | (optional) | Callback invoked when "New…" is selected; if not provided, the row is omitted. |
| `newLabel` | `string` | `"New…"` | Label for the "New…" entry (shown only if `onNew` is provided). |
| `ariaLabel` | `string` | (required) | Accessible label for the trigger button. |
| `icon` | `ReactNode` | (optional) | Custom icon to display on the trigger; defaults to ChevronsUpDown. |
| `className` | `string` | (optional) | Extra CSS classes for the trigger, merged with built-in classes via `cn()`. |

## Deep Linking

Not applicable: This component handles selection logic only; the caller owns routing and deep linking behavior.

## Localization

| String Key | Default (en) | Context | Notes |
|-----------|-------------|---------|-------|
| `allLabel` | `"All"` | "All" row label (configurable per instance; no global key). | Caller passes localized string directly. |
| `newLabel` | `"New…"` | "New…" row label (configurable per instance; no global key). | Caller passes localized string directly. Ellipsis character is Unicode U+2026 (preferred) or three dots "..." depending on localization. |
| `ariaLabel` | (caller-provided) | Accessible label for trigger. | Caller must provide localized aria label. |

## Accessibility Options

- **Reduce Motion**: Not explicitly handled in the component; dropdown menu implementation (from radix-ui or equivalent) may respond to `prefers-reduced-motion`. Component inherits behavior from DropdownMenu primitives.
- **Increase Contrast**: Not explicitly handled. Component uses semantic color tokens (`apt-border`, `apt-gold`, etc.), so contrast is deferred to the design system's token definitions.
- **Differentiate Without Color**: Not explicitly handled. The radio group items and selection state rely on visual styling; no additional haptic or non-color affordances are provided by PopupMenu itself.

## Feature Flags

Not present in component. Caller may wrap the component in conditional logic to gate its availability.

## Analytics

Not present in component. Caller may wrap `onSelect` and `onNew` callbacks to emit analytics events.

## Privacy

Not applicable: Component handles no personal data; it is a UI control for selection.

## Logging

| Event | Level | Message |
|-------|-------|---------|
| Sentinel collision detected | warn | `PopupMenu: item id "__all__" collides with the All sentinel` |

Subsystem: implicit (browser console); no explicit logger configured in component.

## Platform Notes

- **React/Web (source)**: Implemented in `packages/web/packages/ui/src/blocks/popup-menu.tsx` using React hooks, radix-ui DropdownMenu primitives, lucide-react icons, and Tailwind CSS utility classes. Trigger uses semantic color tokens (`apt-*`) and includes focus/hover state styling. Radio items ensure single-selection semantics. The component is a faithful port of the Adaptive Homepages resource selector.

- **SwiftUI**: Build using a Menu button (or custom dropdown) with a Picker (single-selection). Wrap items in a ForEach; add an "All" option using `if allLabel != nil { Picker option }`. Render "New…" below a Divider if the `onNew` callback exists. Apply focus styling via `.focused()` or `.focusEffectDisabled()`. Use `.accessibilityLabel()` for `ariaLabel`.

- **Compose (Android)**: Use MaterialDropdownMenu or a custom DropdownMenu composable with LazyColumn for items. Render items as RadioButton entries within a SingleSelectionItem framework. For "All" and "New…", conditionally include Divider and MenuItem composables. Apply Modifier styling (padding, border, background) and respond to `selected` state. Use `semantics { contentDescription = ariaLabel }` for accessibility.

- **UIKit / AppKit**: Use NSMenu (macOS) or UIMenu (iOS 15+) as the dropdown container. Render menu items as NSMenuItem or UIAction. For "All" and "New…", insert NSMenuSeparator and conditionally add items. Set accessibilityLabel via the trigger button's accessibility properties. On macOS, apply focus ring styling; on iOS, use `.accessibilityElement()` and `.accessibilityLabel()`.

- **WinUI 3**: Build using MenuBar or a DropDownButton (XAML). Use ItemsControl or a manually constructed StackPanel for items, each as a RadioButton or ToggleButton. For "All" and "New…", conditionally render MenuFlyoutSeparator and MenuFlyoutItem. Apply VisualStateManager for Hover, Pressed, and Focused states (border color and background). Set AutomationProperties.Name for the trigger's accessible label.

## Design Decisions

- **"All" as null, not an item**: The component represents the "All" (nothing focused) state as `selectedId: null` rather than as a literal item with a special id. This decouples "All" from the item array and simplifies caller logic (e.g., API filter: `itemId ?? 'all'`). The tradeoff is that the "All" row is conditionally rendered, and the radio group maps null to a sentinel string (`"__all__"`) internally.

- **Sentinel collision warning, not error**: When an item id collides with the internal `"__all__"` sentinel, the component logs a warning but continues to render. This is a fail-soft design: catching errors at runtime is better than silently selecting the wrong item, but throwing would be overly strict for development. A stricter pattern (TypeScript discrimination or validation at the type level) would prevent this at compile time but adds complexity to the API.

- **Custom className merge via `cn()`**: The component allows the caller to pass extra classes that override built-in defaults (e.g., `className="w-auto"`). This provides layout flexibility without prop explosion. The tradeoff is that destructive overrides (e.g., removing `focus-visible:border-apt-gold`) can break accessibility if the caller is not careful.

- **Icon always present, never omitted**: The default icon (chevron) and optional custom icon are always rendered. The icon is marked `aria-hidden` to avoid redundant announcements. A design decision to allow icon hiding via a prop was rejected to keep the API simpler and the affordance consistent.

- **newLabel as a string, not a React node**: The "New…" entry's label is a string prop (`newLabel`), not a ReactNode like `icon`. This keeps the API surface smaller and avoids nested component complexity. If the caller needs richer content in the "New…" row, a separate MenuItem render prop would be required.

- **onNew as a callback, not a selection**: Selecting "New…" does not add an item to the list or change `selectedId`; it invokes the `onNew` callback only. The caller owns the logic to create a new item and update the state. This separation of concerns keeps the component focused on selection and routing.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| [RFC 2119 keywords](agenticdevelopercookbook://guidelines/cookbook/recipe-quality/behavioral-requirements#rfc-2119-keyword-usage) | passed | Behavioral Requirements |
| [Testability](agenticdevelopercookbook://guidelines/cookbook/recipe-quality/behavioral-requirements#testability) | passed | Behavioral Requirements |
| [Accessibility coverage](agenticdevelopercookbook://guidelines/cookbook/recipe-quality/cookbook-compliance#ui-and-accessibility) | passed (with note) | Cookbook Compliance |
| [Touch target size](agenticdevelopercookbook://guidelines/cookbook/recipe-quality/cookbook-compliance#ui-and-accessibility) | attention | Accessibility (see Appearance) |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.1 | 2026-09-22 | Claude Haiku 4.5 | Resolve review markers: confirm ariaLabel enforcement and document actual trigger dimensions |
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation from web source |
