---
id: 76eee228-2fd5-4524-a84e-d221c2e4c8ad
title: Category Gear Menu
domain: agenticdevelopertoolkit://recipes/category-gear-menu
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: 'Dropdown menu for managing category actions: add, rename, move, file, and
  delete.'
platforms:
- typescript
- web
tags:
- menu
- dropdown
- category-management
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Category Gear Menu

## Overview

A dropdown menu triggered by a gear icon that presents five actions for managing categories in a hierarchical list. The menu dynamically disables actions based on whether a user has selected an editable target. "Add" is always enabled and creates a new category at the list level. "Rename", "Move", "File", and "Delete" are enabled only when a valid target is selected. Menu items are labeled with the target name when available, so the user reads what will be acted upon.

## Behavioral Requirements

- **must-render-trigger**: Component MUST render a gear icon trigger labeled with "{Noun} actions" (noun is singular and capitalized; defaults to "Category actions").
- **must-render-five-items**: Component MUST render five dropdown items corresponding to the actions: "Add {noun}…", "Rename…", "Move…", "Also file… in", and "Delete".
- **must-show-target-in-labels**: Component MUST include the target name in menu item labels when `targetName` is not null and `canEditTarget` is true. Label format is "{Verb} \"{targetName}\"…" or "{Verb} \"{targetName}\"… in" for the file action.
- **must-disable-target-actions-when-no-target**: Component MUST disable "Rename", "Move", "File", and "Delete" menu items when `canEditTarget` is false.
- **must-enable-add-always**: Component MUST keep the "Add {noun}…" item enabled regardless of `canEditTarget`.
- **must-render-separators**: Component MUST render a visual separator (DropdownMenuSeparator) between "Add" and the target actions, and another separator between "File" and "Delete".
- **must-invoke-callback-on-action**: Component MUST invoke the `onAction` callback with the action type ("add", "rename", "move", "file", or "delete") when a menu item is clicked.
- **must-respect-disabled-prop**: Component MUST render the trigger as disabled when the `disabled` prop is true.
- **must-style-delete-red**: Component MUST apply red text styling to the "Delete" menu item.
- **must-align-to-end**: Component MUST align the dropdown menu content to the end (right) of the trigger.

## Appearance

- **Trigger**: Uses `GearMenuTrigger` component (styling is delegated to that component; source shows only className pass-through and disabled flag).
- **Menu items**: Standard dropdown menu item appearance, inherited from `DropdownMenuItem` component.
- **Delete item**: Text color is red (className `text-apt-red`).
- **Separators**: Visual dividers rendered by `DropdownMenuSeparator` component.

## States

| State | Appearance change | Trigger behavior |
|-------|------------------|------------------|
| Default | All items visible; "Rename", "Move", "File", "Delete" enabled | User can click trigger to open menu |
| No target selected | "Rename", "Move", "File", "Delete" visually disabled (grayed) | Add is the only functional action |
| Disabled | Trigger appears disabled (visual state depends on GearMenuTrigger) | Trigger does not respond to click |
| Menu open | Dropdown content displays below or adjacent to trigger | User can click any enabled item |

## Accessibility

- **Role**: Trigger element MUST have a button role; menu MUST have a menu role and menu items MUST have menuitem role (provided by DropdownMenu and DropdownMenuItem components).
- **Label**: Trigger MUST be labeled "{Noun} actions" to describe its purpose to assistive technology users.
- **Disabled state announcement**: Disabled menu items MUST be announced as disabled to assistive technology.
- **Touch target**: GearMenuTrigger MUST provide a minimum 44×44pt touch target on touch devices.
- **Keyboard navigation**: Menu MUST support arrow keys and Enter/Space to select items (delegated to DropdownMenu component).

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| cgm-001 | must-render-trigger | Default render | Trigger displays labeled "Category actions" |
| cgm-002 | must-render-five-items | Menu opened | Five items are visible: "Add category…", "Rename…", "Move…", "Also file… in", "Delete" |
| cgm-003 | must-show-target-in-labels | targetName="Q3", canEditTarget=true | "Rename "Q3"…", "Move "Q3"…", "Also file "Q3"… in", "Delete "Q3"…" |
| cgm-004 | must-disable-target-actions-when-no-target | canEditTarget=false | "Rename", "Move", "File", "Delete" items are disabled; "Add" is enabled |
| cgm-005 | must-enable-add-always | canEditTarget=false, no target | "Add category…" is enabled and clickable |
| cgm-006 | must-render-separators | Menu opened | Two visual separators present: one after "Add", one before "Delete" |
| cgm-007 | must-invoke-callback-on-action | Click "Add category…" | onAction("add") is called |
| cgm-008 | must-invoke-callback-on-action | Click "Delete "Q3"…" with canEditTarget=true | onAction("delete") is called |
| cgm-009 | must-respect-disabled-prop | disabled=true | Trigger is visually disabled and does not open menu |
| cgm-010 | must-style-delete-red | Menu opened | "Delete" item text is red |
| cgm-011 | must-align-to-end | Menu opened | Menu content aligns to the right (end) of trigger |
| cgm-012 | must-show-target-in-labels | noun="item" | Labels use "Item" capitalized (e.g., "Rename "Q3" Item…") |

## Edge Cases

- **Null targetName**: When targetName is null (no selection), labels use the bare verb form without a target name reference (e.g., "Rename…" instead of "Rename \"{name}\"…").
- **Empty noun**: When noun prop is not provided, the component defaults to "category" (lowercase for labels, capitalized as "Category" for trigger label).
- **Custom noun**: When noun is provided (e.g., "tag", "note"), labels and trigger are updated accordingly (e.g., trigger reads "Tag actions", add reads "Add tag…").
- **Disabled with no target**: When both disabled=true and canEditTarget=false, the trigger is disabled and all target-specific actions are also disabled in the UI.
- **Rapid clicking**: If a menu item is clicked multiple times before the menu closes, onAction callback is invoked once per click (no debouncing in source).
- **Dynamic targetName change**: If targetName prop changes while menu is open, labels reflect the new target immediately (React re-render).

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| targetName | string &#124; null | null | The name of the selected category row to display in action labels. When null, labels do not include a target. |
| canEditTarget | boolean | false | Whether the target-specific actions (rename, move, file, delete) are available. Controls the disabled state of four menu items. |
| noun | string | "category" | Singular, lowercase noun used in labels and trigger title. E.g., "tag", "item", "note". Capitalized in trigger label. |
| onAction | (action: CategoryGearAction) => void | (required) | Callback invoked when any menu item is clicked. Receives the action type: "add", "rename", "move", "file", or "delete". |
| disabled | boolean | false | When true, the trigger is disabled and the menu cannot be opened. |
| className | string | undefined | Optional CSS class to apply to the trigger element (passed to GearMenuTrigger). |

## Deep Linking

Not applicable: This is a UI component block for inline menu rendering, not a routable feature. Deep linking is managed by the host application.

## Localization

Not applicable: Action labels are generated dynamically from function logic and the noun prop; no static string keys are defined in the component.

## Accessibility Options

Not applicable: The source code does not check or respond to accessibility display options such as Reduce Motion or Increase Contrast. Implementations SHOULD respect platform accessibility display options at the host level.

## Feature Flags

Not applicable: No feature flags are defined in the component source.

## Analytics

Not applicable: The component does not emit analytics events. Event tracking is the responsibility of the host application that calls the onAction callback.

## Privacy

Not applicable: The component does not collect, store, or transmit any data.

## Logging

Not applicable: No logging is implemented in the component.

## Platform Notes

- **React/Web**: Use the `DropdownMenu`, `DropdownMenuContent`, `DropdownMenuItem`, and `DropdownMenuSeparator` components from the `../components/dropdown-menu` module (from Radix UI or similar primitive library). The `GearMenuTrigger` component provides the icon trigger. Render the menu content with `align="end"` to position it at the right edge of the trigger. Apply `className="text-apt-red"` to the delete item for red text styling.
- **SwiftUI**: Start with SwiftUI's `Menu` control, using a gear icon from `Image(systemName: "gearshape.fill")` as the trigger. Render menu items conditionally based on the `canEditTarget` boolean. Use `@Environment(\.colorScheme)` to determine whether red styling applies in light or dark mode. Include the target name in action labels using string interpolation when available.
- **Compose**: Build from Compose's `DropdownMenu` and `DropdownMenuItem` composables. Use Material Design 3 Menu specs for spacing and elevation. Apply conditional enabled states based on `canEditTarget`. Use Compose's `Color.Red` or the app's error color token for the delete item text. Icon rendering uses Compose Material Icons (gear icon).
- **AppKit / UIKit**: On macOS (AppKit), use `NSMenu` with `NSMenuItem` for each action; set the target and action for each item. On iOS (UIKit), use `UIMenu` and `UIAction` to build the menu items conditionally. Apply `UIColor.red` or the app's error color to the delete action. The gear icon comes from `UIImage(systemName: "gearshape.fill")`.
- **WinUI 3**: Use `MenuFlyout` with `MenuFlyoutItem` controls. Bind the enabled state of "Rename", "Move", "File", and "Delete" items to the `canEditTarget` property. Use a `MenuFlyoutSeparator` between logical groups. Set `Foreground` to red for the delete item using `Foreground="{ThemeResource SystemErrorTextColorPrimary}"` or the app's error color resource. Position the menu at the end of the trigger using `Placement="Bottom"` and ensure horizontal alignment respects RTL layouts.

## Design Decisions

**Move vs. File distinction**: The component presents two separate verbs, Move and File, not because one rewrites an existing filing and the other adds a new one — though the source comments explain that difference precisely. The reason this menu needs both is architectural: without a File action, this hierarchical UI would appear to enforce a tree structure, making the DAG's second-filing capability invisible to users. The two verbs must be distinct and unambiguous in the menu; labeling one as "Duplicate filing" would obscure what it does.

**Dumb component pattern**: The component is intentionally stateless and makes no decisions about what is editable, when dialogs open, or what data is valid. All logic lives in the host. This design matters because the host tracks the current selection and can update the target independently from menu visibility — if the host relied on the menu to store or infer the target, a rename operation would leave the menu acting on stale data after the rename completes.

**Add is always enabled**: The "Add" action creates a new category at the list's own level (a new root in the root list). It does not depend on whether a row is selected; the selection cannot answer the question "what is the list's own category?" Therefore, Add remains enabled even when canEditTarget is false.

**Labels name the target**: When a target is available, action labels include its name (e.g., "Rename "Q3"…"). This is not a nicety — it resolves ambiguity. The header in which this menu sits is not the selection; without the name, a bare "Rename…" leaves the user guessing whether the action applies to the header, the selected row, or something else.

## Compliance

Not applicable: The component is a structural UI building block with no security, data persistence, or regulatory concerns of its own. Compliance requirements fall to the host application.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
