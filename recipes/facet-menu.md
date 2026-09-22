---
id: 60a907a2-2cc8-4c0c-bb54-3b0516d280b6
title: Facet Menu
domain: agenticdevelopercookbook://ingredients/facet-menu
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Multi-select filter menu with count badge and quick-select actions.
platforms:
- typescript
- web
tags:
- filter
- multi-select
- menu
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Facet Menu

## Overview

A facet menu is a multi-select filter control presented as a button with a dropdown menu. The trigger button displays the filter label and a count of selected values. The menu provides checkboxes for each option, along with quick-select "All" and "None" actions. This component is used to narrow result sets in lists or tables without removing the visual indication of active filters.

## Behavioral Requirements

- **must-render-trigger**: The component MUST render a button trigger displaying the label text and a count of selected items in parentheses (e.g., "Category (3)") when one or more items are selected.
- **must-omit-count-when-empty**: The component MUST NOT display the count when zero items are selected; only the label text MUST be shown in the trigger.
- **must-disable-trigger**: The component MUST disable the trigger button when the options list is empty.
- **must-show-chevron**: The component MUST display a chevron-down icon in the trigger, marked as decorative (`aria-hidden="true"`).
- **must-render-popover**: The component MUST display a popover menu when the trigger is clicked, containing the option list and quick-select buttons.
- **must-render-options**: The component MUST render each option as a checkbox with an associated label, derived from the options array.
- **must-support-label-transform**: The component MAY accept a `labelOf` function to transform option values into display labels; if not provided, the option value MUST be displayed as-is.
- **must-toggle-on-checkbox-click**: The component MUST add or remove an option from the selection when its checkbox is clicked, invoking the `onChange` callback with the updated selection.
- **must-render-all-button**: The component MUST render an "All" quick-select button that selects every option and invokes `onChange`.
- **must-disable-all-button**: The component MUST disable the "All" button when all options are already selected.
- **must-render-none-button**: The component MUST render a "None" quick-select button that clears all selections and invokes `onChange`.
- **must-disable-none-button**: The component MUST disable the "None" button when zero items are currently selected.
- **must-handle-overflow**: The component MUST allow the option list to scroll vertically when the number of options exceeds available space (max-height 16rem, vertical scrolling enabled).
- **must-preserve-selection-state**: The component MUST NOT alter the selection when the menu is opened or closed.

## Appearance

- **Trigger Button**:
  - Variant: ghost (low prominence)
  - Size: small
  - Text: label, followed by count in parentheses (when count > 0)
  - Icon: ChevronDown, 14×14px, margin-left 4px
  - Background: transparent in default state, platform-standard hover/pressed backgrounds
  - Foreground: inherit from button component

- **Popover Menu**:
  - Width: 14rem (224px)
  - Background: platform-standard panel background
  - Alignment: start (left-aligned to trigger)
  - Padding: 8px

- **Quick-Select Buttons** ("All" and "None"):
  - Variant: ghost
  - Size: small
  - Arranged horizontally
  - Gap: 4px
  - Row gap: 8px below buttons to option list

- **Option Checkboxes**:
  - Checkbox: 16×16px
  - Label text: text-sm (14px equivalent), rendered inline with checkbox
  - Row gap: 8px between checkbox and label
  - Row padding: 4px vertical (0.5rem)
  - Cursor: pointer on label (entire row is clickable)

## States

| State | Appearance Change |
|-------|------------------|
| Trigger Default | Ghost button, chevron down, no count if selection empty |
| Trigger Disabled | Opacity reduced, pointer-events disabled (when options.length === 0) |
| Trigger Hover | Platform-standard ghost button hover (if enabled) |
| Trigger Pressed | Platform-standard ghost button pressed |
| Menu Open | Popover visible, stacked "All"/"None" buttons above scrollable option list |
| Menu Closed | Popover hidden |
| "All" Button Enabled | Clickable, standard ghost appearance |
| "All" Button Disabled | Opacity reduced (all options already selected) |
| "None" Button Enabled | Clickable, standard ghost appearance |
| "None" Button Disabled | Opacity reduced (selection already empty) |
| Checkbox Checked | Checkmark visible, aria-checked="true" |
| Checkbox Unchecked | No checkmark, aria-checked="false" |

## Accessibility

- **Role**: The trigger MUST be a button (`<button>` or `role="button"`).
- **Label**: The trigger MUST have accessible text from its label content (e.g., "Category").
- **Count Semantics**: The count in the trigger (e.g., "(3)") MUST be included in the accessible label to convey how many filters are active.
- **Chevron Icon**: The chevron-down icon MUST be marked `aria-hidden="true"` because the button's accessible label already conveys that the menu is collapsible.
- **Checkbox Labels**: Each checkbox MUST have an associated label via `<label>` wrapping or `aria-labelledby`. The label text is derived from the option value or the `labelOf` function.
- **Checkbox State**: Each checkbox MUST have `aria-checked` set to match the checked state.
- **Popover Accessibility**: The popover menu MUST be properly announced as a dialog or popup when opened; focus SHOULD move to the first interactive element in the popover (per platform conventions).
- **Keyboard Navigation**: The popover menu MUST be navigable by keyboard (Tab moves between checkboxes and buttons; Enter or Space toggles a checkbox); the Escape key or clicking outside SHOULD close the menu.
- **Touch Target**: All interactive elements (trigger button, checkboxes, quick-select buttons) MUST have a touch target of at least 44×44px on touch-enabled platforms; on web with mouse/pointer input, 16×16px is acceptable for checkboxes if the associated label is large enough to encompass a 44×44px target.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| facet-001 | must-render-trigger, must-omit-count-when-empty | options: ["A", "B"], selected: empty | Trigger displays "Label" only, no count |
| facet-002 | must-render-trigger, must-omit-count-when-empty | options: ["A", "B"], selected: {"A"} | Trigger displays "Label (1)" |
| facet-003 | must-disable-trigger | options: [], selected: empty | Trigger button is disabled (pointer-events: none or disabled attribute) |
| facet-004 | must-show-chevron | options: ["A", "B"], selected: empty | ChevronDown icon is visible and aria-hidden="true" |
| facet-005 | must-render-popover | options: ["A", "B"], trigger clicked | Popover opens, displaying "All", "None", and checkbox list |
| facet-006 | must-render-options | options: ["Apple", "Banana"], selected: empty | Checkboxes labeled "Apple" and "Banana" are rendered |
| facet-007 | must-support-label-transform | options: ["a", "b"], labelOf: (v) => v.toUpperCase(), selected: empty | Checkboxes labeled "A" and "B" are rendered |
| facet-008 | must-toggle-on-checkbox-click | options: ["A", "B"], selected: {"A"}, click checkbox "B" | onChange called with {"A", "B"} |
| facet-009 | must-render-all-button | options: ["A", "B", "C"], selected: empty | "All" button is rendered and clickable |
| facet-010 | must-disable-all-button | options: ["A", "B"], selected: {"A", "B"} | "All" button is disabled |
| facet-011 | must-render-none-button | options: ["A"], selected: {"A"} | "None" button is rendered and clickable |
| facet-012 | must-disable-none-button | options: ["A"], selected: empty | "None" button is disabled |
| facet-013 | must-handle-overflow | options: [40 items], selected: empty | Option list scrolls vertically when menu is open |
| facet-014 | must-preserve-selection-state | options: ["A", "B"], selected: {"A"}, open and close menu | Selection remains {"A"} |

## Edge Cases

- **Empty options array**: When `options.length === 0`, the trigger MUST be disabled and the menu MUST NOT open. The selection is unchanged (even if it was previously populated).
- **Selected items not in options**: If the `selected` set contains a value not present in the current `options` array, that value MUST remain in the selection but MUST NOT be rendered as a checkbox in the menu. (This can occur if options are dynamically filtered and a selected value is removed from the list.)
- **All selected after filtering**: If options are filtered and all remaining options become selected, the "All" button MUST be disabled.
- **Rapid onChange calls**: Multiple rapid checkbox clicks MUST result in multiple separate `onChange` calls; no debouncing or coalescing is performed by the component.
- **LabelOf function returns empty string**: If `labelOf(option)` returns an empty string, the checkbox is rendered with no visible label text (the label container is still present for accessibility but empty).
- **Very long option labels**: Long labels MUST wrap or truncate gracefully within the popover width; no minimum or maximum label length is enforced.

## Configuration

Not applicable: FacetMenu is a controlled component with a fixed prop interface (`label`, `options`, `selected`, `onChange`, `labelOf`); no runtime configuration options exist.

## Deep Linking

Not applicable: FacetMenu is a UI component without navigation semantics; it does not participate in deep linking.

## Localization

| String Key | Default (en) | Context |
|-----------|-------------|---------|
| `facet.all` | "All" | Quick-select button to select all options |
| `facet.none` | "None" | Quick-select button to clear all selections |

The component does not provide i18n keys for option labels; label strings come from the `options` array or the `labelOf` function, which are the responsibility of the host application to localize.

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | Popover opening/closing animation SHOULD be disabled or simplified; checkbox state changes SHOULD not animate. Popover positioning SHOULD occur instantly. |
| Increase Contrast | Button and checkbox backgrounds and borders SHOULD use increased contrast colors per platform guidelines. Label and value text MUST meet WCAG AA contrast ratio (4.5:1 for normal text, 3:1 for large text). |
| Differentiate Without Color | State distinctions (checked vs. unchecked, enabled vs. disabled) MUST NOT rely on color alone; checkboxes MUST use a checkmark or fill pattern to indicate state. |

## Feature Flags

Not applicable: FacetMenu is a foundational UI component with no feature flags. It is always enabled.

## Analytics

Not applicable: FacetMenu does not generate analytics events. The host application is responsible for instrumenting selection changes via the `onChange` callback if analytics are desired.

## Privacy

Not applicable: FacetMenu does not collect, store, or transmit user data. It is a stateless UI component that emits selection state changes to the host application via the `onChange` callback.

## Logging

Not applicable: FacetMenu is a UI component and does not perform logging. Errors in the `onChange` callback or `labelOf` function are the responsibility of the host application to handle and log.

## Platform Notes

- **SwiftUI**: Implement using SwiftUI's `Menu` button with a toggle for each option. The trigger button displays the label and count as computed properties. Use `.disabled()` modifier when options are empty. The "All" and "None" buttons can be rendered as additional menu items or as separate buttons in the menu header. Scrollable content requires a `ScrollView` within the menu.

- **Compose**: Implement using Material Design's `ExposedDropdownMenuBox` (or custom `MenuButton` if more control is needed). The trigger renders as a `Button` with a trailing chevron icon. Checkboxes are rendered in a scrollable column within the menu. "All" and "None" buttons are rendered as additional menu items or as separate buttons above the scrollable option list. Use `modifier.heightIn(max = 256.dp)` for overflow handling.

- **React/Web**: Implement using the provided Popover, Button, and Checkbox components. The source code demonstrates the implementation: trigger is a Button with ghost variant, popover uses PopoverTrigger/PopoverContent, options are checkboxes in a scrollable container. Use Tailwind classes (max-h-64, overflow-auto) or CSS to constrain the option list height.

- **AppKit / UIKit**: Implement using `NSPopupButton` (macOS) or `UIMenu` + `UIButton` (iOS). For macOS, use `NSMenu` with checkbox items. For iOS 13+, use `UIAction` with attributes for checkmarks. The trigger button displays the label and count. The "All" and "None" actions can be menu items or separate buttons depending on the platform and available space. Overflow is handled by the system menu presentation.

- **WinUI 3**: Implement using `ComboBox` with `IsEditable="False"` or `MenuFlyout` attached to a `Button`. Render checkboxes in the flyout or dropdown. The trigger button displays the label and count. "All" and "None" actions can be buttons in the flyout header. Use `MaxDropDownHeight` or wrap the option list in a `ScrollViewer` with a height constraint (e.g., 256dp) to handle overflow. Alternatively, use `InfoBar` or a custom control if a more compact or distinct presentation is desired.

## Design Decisions

- **Count in trigger is not decoration**: The count displayed in the trigger (e.g., "Category (3)") is essential information, not a visual flourish. Operators rely on this count to verify that filters are active without opening the menu. Hidden filters can lead to incorrect actions (e.g., deleting the "wrong" set when a filter is invisibly active).

- **"All" and "None" are not redundant**: Both selecting all options and clearing all selections result in the same final row set (when all options are present, an empty selection and a full selection show the same rows). However, they serve different interaction purposes. "All" is the starting point for excluding a single option ("everything except this"), and it requires the boxes to be checked to represent that intent. "None" is the way to return to no active filter. The count in the trigger distinguishes between the two states (N vs. 0), so they are semantically distinct operations.

- **Checkboxes in labels (not aria-label)**: Checkboxes do NOT carry individual `aria-label` attributes. Each checkbox is wrapped in a `<label>` element with text content, and screen readers announce the label via `aria-labelledby` (set by the base checkbox component). Adding an `aria-label` to the checkbox would cause screen readers to announce the label text twice, creating a poor experience.

- **Overflow handling**: The option list is constrained to a maximum height (16rem / 256px) with vertical scrolling enabled. This ensures the menu does not exceed the visible viewport on small screens and is consistent across platforms. Horizontal scrolling is not enabled; long labels are expected to wrap or be truncated by the host container.

## Compliance

Not applicable: FacetMenu is a UI component without data, network, or security implications. It complies with platform accessibility guidelines (Apple HIG, Material Design 3, WCAG 2.1) by providing semantic structure and keyboard navigation.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
