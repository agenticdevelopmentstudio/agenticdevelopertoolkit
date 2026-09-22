---
id: 25de0c8f-b6cb-4e9f-ba30-38afca642232
title: Dropdown Menu
domain: agenticdevelopertoolkit://recipes/dropdown-menu
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Positioned menu triggered by a button or link, with support for nested submenus,
  checkbox, and radio items.
platforms:
- typescript
- web
tags: []
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Dropdown Menu

## Overview

A dropdown menu is a positioned overlay component that displays a list of actions or options. Triggered by a button, link, or other interactive element, the menu appears adjacent to the trigger and closes when the user selects an item, clicks outside, or presses Escape. The component supports nested submenus, multi-select checkbox items, single-select radio items, labels, and visual separators.

## Behavioral Requirements

- **must-render-trigger**: The component MUST render a trigger element (button, link, or other control) that opens the menu.
- **must-render-content**: The component MUST render a positioned popup containing menu items.
- **must-close-on-item-select**: The component MUST close the menu when a user selects a standard menu item (unless `closeOnClick` is explicitly set to false).
- **must-close-on-link-select**: DropdownMenuLinkItem MUST close the menu after the link click handler fires, preserving browser link semantics (middle-click, Cmd+click for new tabs).
- **must-close-on-escape**: The component MUST close the menu when the user presses Escape.
- **must-close-on-outside-click**: The component MUST close the menu when the user clicks outside the menu and trigger.
- **must-support-checkbox-items**: Checkbox items MUST support a `checked` state and MUST render a checkmark icon when checked.
- **must-support-radio-items**: Radio items MUST support a single-selected value within a RadioGroup and MUST render a circle indicator when selected.
- **must-support-submenus**: SubmenuRoot items MUST open a nested menu positioned relative to the parent menu, and MUST close when the user moves focus away from the submenu.
- **must-position-with-offset**: DropdownMenuContent MUST accept `side`, `sideOffset`, `align`, and `alignOffset` props to control menu positioning. Default `sideOffset` is 4px.
- **must-support-semantic-classes**: All menu elements MUST apply semantic CSS class names prefixed with `adh-dropdown-menu__` to enable consistent theming.
- **must-support-inset-items**: Menu items and labels MUST support an `inset` prop that adds the `adh-dropdown-menu__item--inset` class for visual indentation.
- **must-support-accent-items**: Menu items MUST support an `accent` prop that applies gold highlight on hover/focus via the `adh-dropdown-menu__item--accent` class.
- **should-close-checkbox-on-click**: CheckboxItem SHOULD close the menu on click by default (`closeOnClick` defaults to true).
- **should-close-radio-on-click**: RadioItem SHOULD close the menu on click by default (`closeOnClick` defaults to true).
- **should-close-link-on-click**: LinkItem SHOULD close the menu on click by default (`closeOnClick` defaults to true).

## Appearance

- **Positioning**: Positioned via Base UI Positioner (side, sideOffset, align, alignOffset); z-index 50.
- **Item padding**: Applied via semantic `adh-dropdown-menu__item` class.
- **Item inset**: When `inset={true}`, applies `adh-dropdown-menu__item--inset` class for additional horizontal padding.
- **Item accent**: When `accent={true}`, applies `adh-dropdown-menu__item--accent` class for gold highlight on hover/focus.
- **Checkbox icon**: Check icon from lucide-react rendered when CheckboxItem is checked, styled via `adh-dropdown-menu__indicator-check` class.
- **Radio icon**: Circle icon from lucide-react rendered when RadioItem is selected, styled via `adh-dropdown-menu__indicator-dot` class.
- **Submenu chevron**: ChevronRight icon from lucide-react rendered on SubmenuTrigger, styled via `adh-dropdown-menu__sub-trigger-chevron` class.
- **Separator**: Rendered via MenuPrimitive.Separator with class `adh-dropdown-menu__separator`.
- **Label**: Plain styled div with class `adh-dropdown-menu__label`, supports `inset` prop.

## States

| State | Appearance change |
|-------|------------------|
| Default | Menu hidden, trigger rendered in default state |
| Open | Menu popup visible at positioned location, trigger may display open state |
| Item hovered | Item background changes (neutral surface or gold for accent items) |
| Item focused | Item background changes, focus outline visible |
| Item disabled | Item appearance dimmed or greyed (if disabled prop is passed) |
| Checkbox checked | Checkmark icon rendered inside indicator slot |
| Radio selected | Circle indicator rendered inside indicator slot |
| Submenu open | Nested menu appears positioned relative to parent |

## Accessibility

- **Role**: Menu items MUST have the `menuitem` role (provided by Base UI MenuPrimitive).
- **Label requirement**: Menu items MUST have accessible text content or an aria-label.
- **Keyboard navigation**: Menu MUST support arrow key navigation (up/down to move focus, left/right to open/close submenus).
- **Escape key**: Menu MUST close on Escape, returning focus to the trigger.
- **Focus management**: Focus MUST return to the trigger when the menu closes.
- **Checkbox state announcement**: Checkbox items MUST announce checked state to assistive technology via aria-checked.
- **Radio state announcement**: Radio items MUST announce selected state to assistive technology via aria-checked.
- **Disabled state announcement**: Disabled items MUST announce disabled state via aria-disabled.
- **Submenu indication**: Submenu triggers MUST indicate they open a submenu (via ChevronRight icon and aria-haspopup).
- **Minimum target size**: Menu items SHOULD have a minimum touch/click target size of 44×44px (per mobile platform guidelines).

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| dropdown-001 | must-render-trigger, must-render-content | Render DropdownMenu with Trigger and Content | Trigger element renders; clicking trigger shows menu content |
| dropdown-002 | must-close-on-item-select | Render MenuItem inside open menu; click it | Menu closes after click |
| dropdown-003 | must-close-on-link-select | Render LinkItem inside open menu; click it | Menu closes; browser link semantics preserved (middle-click opens new tab) |
| dropdown-004 | must-close-on-escape | Open menu; press Escape key | Menu closes; focus returns to trigger |
| dropdown-005 | must-close-on-outside-click | Open menu; click outside | Menu closes |
| dropdown-006 | must-support-checkbox-items | Render CheckboxItem with checked={true} | Checkmark icon appears in indicator slot |
| dropdown-007 | must-support-checkbox-items | Render CheckboxItem with checked={false} | Indicator slot is empty |
| dropdown-008 | must-support-radio-items | Render RadioGroup with RadioItem selected | Circle indicator appears in indicator slot |
| dropdown-009 | must-support-radio-items | Render RadioGroup with RadioItem unselected | Indicator slot is empty |
| dropdown-010 | must-support-submenus | Render SubmenuRoot with SubmenuTrigger inside open parent menu | Submenu opens; ChevronRight icon renders on trigger |
| dropdown-011 | must-position-with-offset | Render DropdownMenuContent with side="bottom" sideOffset={8} | Content positioned 8px below trigger |
| dropdown-012 | must-position-with-offset | Render DropdownMenuContent with default sideOffset | Content positioned 4px from trigger (default) |
| dropdown-013 | must-support-semantic-classes | Render MenuItem | MenuItem renders with class adh-dropdown-menu__item |
| dropdown-014 | must-support-inset-items | Render MenuItem with inset={true} | MenuItem renders with classes adh-dropdown-menu__item adh-dropdown-menu__item--inset |
| dropdown-015 | must-support-accent-items | Render MenuItem with accent={true} | MenuItem renders with classes adh-dropdown-menu__item adh-dropdown-menu__item--accent |
| dropdown-016 | should-close-checkbox-on-click | Render open menu with CheckboxItem; click it | Menu closes (closeOnClick defaults to true) |
| dropdown-017 | should-close-radio-on-click | Render open menu with RadioItem; click it | Menu closes (closeOnClick defaults to true) |
| dropdown-018 | should-close-link-on-click | Render open menu with LinkItem; click it | Menu closes (closeOnClick defaults to true) |

## Edge Cases

- **Empty menu**: Menu with no items still renders and positions correctly; no minimum height constraint forces item rendering.
- **Very long item text**: Item text that exceeds available width SHOULD wrap or truncate; behavior depends on CSS styling via semantic classes.
- **Disabled items**: Items with a `disabled` prop render in disabled state and do not respond to click events.
- **No trigger provided**: MenuPrimitive.Root renders; behavior is undefined if no Trigger child is provided (Base UI does not enforce this).
- **Multiple submenus**: Nested submenus at depth >1 position relative to their parent submenu; no depth limit enforced by component.
- **Rapid item clicks**: Clicking multiple items rapidly before menu closes closes menu on first click; subsequent clicks do not interact with menu items if menu is already closed.
- **Focus on disabled item**: Keyboard navigation skips disabled items; focus cannot be moved to a disabled item.
- **Menu with only separators**: Menu renders separators without error; visually appears as empty menu with dividers.
- **Checkbox item without checked prop**: CheckboxItem without explicit `checked` prop behaves as unchecked (no indicator icon shown).
- **Radio item without value**: RadioItem in RadioGroup without a `value` prop does not participate in group selection; behavior is undefined by the component.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `side` | "top" \| "bottom" \| "right" \| "left" \| "inline-start" \| "inline-end" | undefined | Position of menu relative to trigger (DropdownMenuContent / DropdownMenuSubContent) |
| `sideOffset` | number | 4 (for DropdownMenuContent); undefined (for DropdownMenuSubContent) | Distance in pixels between menu and trigger edge (DropdownMenuContent / DropdownMenuSubContent) |
| `align` | "start" \| "center" \| "end" | undefined | Alignment of menu along the perpendicular axis to `side` |
| `alignOffset` | number | undefined | Additional offset along the alignment axis |
| `inset` | boolean | false | Add visual indentation to MenuItem, DropdownMenuLabel, DropdownMenuSubTrigger |
| `accent` | boolean | false | Apply gold highlight style on MenuItem, CheckboxItem, RadioItem, DropdownMenuSubTrigger |
| `closeOnClick` | boolean | true (for LinkItem, CheckboxItem, RadioItem); undefined (for MenuItem) | Close menu when item is clicked |
| `checked` | boolean | undefined | Checked state for CheckboxItem |
| `children` | ReactNode | undefined | Content rendered inside component (text, icons, elements) |
| `className` | string | undefined | Additional CSS classes to merge with semantic classes |

## Deep Linking

Not applicable: Dropdown menus are overlay components with no document-level or app-level navigation identity. Individual menu items may navigate (via DropdownMenuLinkItem), but the menu itself has no persistent URL state.

## Localization

Not applicable: Dropdown menu components render no internal text strings. Localization is the responsibility of the consuming application's menu item labels and text content.

## Accessibility Options

Not applicable: Base UI MenuPrimitive handles keyboard and assistive technology interaction natively; the wrapper does not add specific support for Reduce Motion, Increase Contrast, or Differentiate Without Color. Accessibility response depends on downstream CSS styling via semantic `adh-dropdown-menu__*` classes.

## Feature Flags

Not applicable: The dropdown menu component does not implement feature flags. Feature flagging is the responsibility of consuming code that conditionally renders menu items or the menu itself.

## Analytics

Not applicable: The dropdown menu component does not implement analytics events. Event tracking is the responsibility of consuming code that attaches click handlers or change handlers to menu items.

## Privacy

Not applicable: The dropdown menu component does not collect, store, or transmit user data. No sensitive information is handled.

## Logging

Not applicable: The dropdown menu component does not implement logging. Consuming code may attach event handlers or side effects to menu interactions for debugging or monitoring.

## Platform Notes

- **React/Web**: Implemented in `packages/web/packages/ui/src/components/dropdown-menu.tsx` using Base UI's `Menu` primitive (`@base-ui/react/menu`). Trigger, Content, MenuItem, CheckboxItem, RadioItem, SubmenuTrigger, SubmenuRoot, SubmenuContent, Positioner, and Portal are pass-through wrappers around MenuPrimitive components. Icons (Check, ChevronRight, Circle) are from lucide-react. Semantic CSS classes (`adh-dropdown-menu__*`) are applied to support theming via a public surface in `../styles/components.css`.
- **SwiftUI**: Start from a SwiftUI Menu or use a custom popover-based menu component. Differences: SwiftUI Menu does not support arbitrary positioning (side/sideOffset/align); use a popover with custom positioning logic. Implement CheckboxItem and RadioItem as menu items with custom indicators. Semantic class mapping is not applicable; use SwiftUI native styling instead. Support `inset` and `accent` via SwiftUI padding and foreground color modifiers.
- **Compose**: Start from Material Design's DropdownMenu or build a custom menu composition. Differences: Material DropdownMenu has limited positioning control; use a Popup or Dialog for full side/offset control. Checkbox and RadioItem support is available via native Compose components. No semantic CSS classes; use Compose's Material theming system. Map `inset` to padding and `accent` to color overrides.
- **AppKit / UIKit**: Use NSMenu on macOS or UIMenu on iOS (iOS 13+). Differences: NSMenu and UIMenu do not support custom positioning props (side/sideOffset/align); positioning is determined by the platform. CheckboxItem and RadioItem state is supported via NSMenuItem/UIAction state. No semantic CSS classes; use native platform styling. `inset` and `accent` map to platform menu item attributes and custom appearance if needed.
- **WinUI 3**: Use the MenuFlyout control with MenuFlyoutItem children. Positioning is controlled via Placement property (equivalent to `side`). Offset is set via MenuFlyout.VerticalOffset / HorizontalOffset (equivalent to `sideOffset` + `alignOffset`). Checkbox items use ToggleMenuFlyoutItem; radio items use RadioMenuFlyoutItem (or implement with custom state). Semantic class names do not apply to WinUI; use native visual state customization via ControlTemplate. Implement `inset` via MenuFlyoutItem Padding override; `accent` via Background brush override. Submenu support via nested MenuFlyout and MenuFlyoutSubItem.

## Design Decisions

- **Semantic CSS class names**: All components apply stable `adh-dropdown-menu__*` class names to the DOM to provide a public theming surface. This design enables theme editors and user CSS overrides to target dropdown menu elements without relying on implementation details. The class names are committed to backward compatibility.

- **closeOnClick default flips for checkbox, radio, and link items**: Base UI's CheckboxItem and RadioItem default to `closeOnClick: false` to keep the menu open when toggling state. This wrapper inverts the default to `true` for checkbox and radio items to match typical dropdown menu behavior where selecting an option closes the menu. LinkItem is also defaulted to `true` for the same reason: in this codebase, `render={<Link/>}` navigates client-side without unmounting the header, so the menu would remain open after navigation unless explicitly closed. This design decision is traced to Base UI's documentation and the code comments at lines 1074–1086 (LinkItem) and 1112–1115 (CheckboxItem).

- **Submenu positioning defaults**: DropdownMenuSubContent does not set positioning defaults; Base UI's Positioner already defaults to `side="inline-end"` (right in LTR) and `align="start"` (top), which produces the classic submenu flyout behavior. Explicit positioning overrides are available via props.

- **SubmenuTrigger includes ChevronRight icon**: The ChevronRight icon is always rendered as a visual indicator that the item opens a submenu. This is not conditionally renderable; consuming code cannot hide it.

- **Label component not bound to Group**: DropdownMenuLabel is intentionally a plain styled `<div>`, not Base UI's MenuPrimitive.GroupLabel, because it is used both inside and outside Menu.Group (e.g., as a standalone heading in the DebugMenu). This flexibility comes at the cost of no built-in ARIA relationship to a group.

## Compliance

Not applicable: No compliance checks are defined in the source code or component behavior. Compliance is determined by consuming code and the semantic CSS theming layer.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
