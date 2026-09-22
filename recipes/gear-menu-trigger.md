---
id: cebee4d7-3d01-440d-a35e-6220957c1603
title: Gear Menu Trigger
domain: agenticdevelopercookbook://ingredients/gear-menu-trigger
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A triggering button with a settings gear icon that opens a dropdown menu
  of actions on a list or collection.
platforms:
- typescript
- web
tags:
- ui
- menu
- trigger
- action
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Gear Menu Trigger

## Overview

A small, fixed-size icon button that triggers a dropdown menu. The component is a visual signal—used in rail headers or home bars—indicating that a list or collection has associated actions. The gear metaphor consistently marks action menus across the fleet, and this component ensures that sign remains visually identical everywhere it appears. The component is deliberately minimal: it renders only the trigger; the menu content and items are composed by the host.

## Behavioral Requirements

- **must-require-label**: The component MUST accept a `label` prop (non-empty string) that describes what the menu acts on, as a screen reader announces it (e.g., "Registry actions").
- **must-render-icon**: The component MUST render a settings gear icon (from Lucide React, `Settings` component) at 14px size.
- **must-render-trigger**: The component MUST render a `DropdownMenuTrigger` that opens an associated `DropdownMenuContent` when activated.
- **must-support-disabled-state**: The component MUST accept a `disabled` prop (boolean, defaults to `false`) that disables user interaction.
- **must-apply-disabled-opacity**: When `disabled` is `true`, the component MUST apply 40% opacity to the trigger.
- **must-hide-icon-from-screen-reader**: The component MUST render the settings icon with `aria-hidden` set to `true` so the icon does not announce redundantly.
- **must-set-aria-label**: The component MUST set the `aria-label` attribute of the trigger to the value of the `label` prop.
- **must-accept-class-override**: The component MUST accept an optional `className` prop that allows callers to override or extend the default styling using Tailwind class names.
- **must-render-outline-none**: The component MUST render with `outline-none` so the default browser outline is removed (focus is indicated only by the focus ring).

## Appearance

- **Size**: 24px × 24px (Tailwind `size-6`). Fixed; no resize.
- **Corner radius**: Small rounded corners (Tailwind `rounded`).
- **Icon size**: 14px (Lucide `Settings` component `size={14}`).
- **Default text color**: `text-apt-text-dim` (dimmed text token).
- **Hover text color**: `text-apt-text` (normal text token, shown on hover).
- **Focus ring**: 2px solid ring with `apt-gold/40` color (40% opacity gold), shown on `focus-visible`.
- **Disabled opacity**: 40% opacity (Tailwind `opacity-40`) when disabled.
- **Padding/spacing**: Icon is centered within the 24px square via flex centering.
- **Background**: Transparent (no background color set).
- **Border**: None.
- **Shadow**: None.

## States

| State | Appearance change |
|-------|------------------|
| Default | 24px square, dimmed text color, rounded corners, no outline |
| Hover | Text color changes to normal brightness |
| Focused (keyboard) | 2px gold/40 ring displayed around the trigger |
| Active/Pressed | (No distinct visual change specified; focus ring remains) |
| Disabled | Opacity reduced to 40%, interaction disabled |

## Accessibility

- **Role**: Button (implied by `DropdownMenuTrigger` semantic role).
- **Label**: REQUIRED. The `label` prop provides the accessible name via `aria-label`. It MUST describe what the menu acts on (e.g., "Registry actions", not just "Menu" or "Actions").
- **Icon announcement**: The icon is `aria-hidden` to avoid redundant announcements, since the `aria-label` fully describes the button's purpose.
- **Keyboard navigation**: The component is focusable and activatable via keyboard (Enter/Space) because it is a `DropdownMenuTrigger`.
- **Focus indicator**: A 2px gold/40 ring is displayed on keyboard focus, meeting visibility requirements for keyboard navigation.
- **Disabled state announcement**: When `disabled` is `true`, the native `disabled` attribute on the trigger conveys the disabled state to assistive technology; the visual opacity change provides visual feedback.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| gear-001 | must-render-icon, must-render-trigger | Render with `label="Test"` | Settings icon (14px) is rendered and is `aria-hidden`; component is a clickable/activatable trigger |
| gear-002 | must-set-aria-label | Render with `label="Registry actions"` | `aria-label="Registry actions"` is set on the trigger element |
| gear-003 | must-require-label | Attempt to render without `label` prop | TypeScript compiler error or runtime error (prop is required) |
| gear-004 | must-support-disabled-state, must-apply-disabled-opacity | Render with `disabled={true}` | Trigger element has `disabled` attribute; opacity is 40% |
| gear-005 | must-support-disabled-state | Render with `disabled={true}` and attempt to click/activate | Trigger does not respond to interaction (native `disabled` behavior) |
| gear-006 | must-accept-class-override | Render with `className="custom-class"` | Custom class is applied to the trigger element alongside default styles |
| gear-007 | must-hide-icon-from-screen-reader | Render and inspect icon element | Icon has `aria-hidden="true"` |
| gear-008 | must-render-outline-none | Render and inspect trigger element | `outline: none` is applied (no browser outline visible on focus) |
| gear-009 | Hover state appearance | Render and hover over trigger | Text color changes from `text-apt-text-dim` to `text-apt-text` |
| gear-010 | Focus state appearance | Render and focus via keyboard | 2px gold/40 focus ring is visible around the 24px square |

## Edge Cases

- **Empty or whitespace-only label**: The component does not validate or trim the `label` prop. If an empty string or whitespace-only string is passed, `aria-label` will be set to that value, and screen readers will announce it as empty or whitespace. The host is responsible for providing a non-empty label.
- **Very long label**: If `label` is a very long string, the `aria-label` will reflect that full string, but the visual trigger remains 24px and does not resize or wrap text. Screen readers announce the full label.
- **Disabled triggering dropdown**: When `disabled` is `true`, the trigger is inert and does not open the associated `DropdownMenuContent`. This is native browser behavior for a disabled button.
- **No DropdownMenuContent provided**: The component is the trigger only. If no `DropdownMenuContent` is composed as a sibling by the host, the trigger renders but has no effect when activated. The host MUST provide the menu content.
- **Multiple instances on same page**: Each instance is independent; the `label` prop distinguishes them for accessibility.
- **Rapid clicks when enabled**: If the trigger is rapidly clicked, the dropdown menu behavior is governed by the `DropdownMenuTrigger` component; repeated activations toggle or re-open the menu normally.

## Configuration

Not applicable. The component has no configuration options beyond its props (`label`, `disabled`, `className`).

## Deep Linking

Not applicable. This component is a UI trigger; it does not represent a navigable route or deep linkable state on its own. Deep linking applies to the menu's content and items, which are the host's responsibility.

## Localization

The `label` prop is a string that the host provides; the host is responsible for localization of the label. The component itself has no internal strings to localize.

## Accessibility Options

- **Reduce Motion**: Not applicable. The component is static and has no animations or transitions defined.
- **Increase Contrast**: Not applicable. The component relies on token-based colors (determined by the design system); contrast compliance is a property of the tokens themselves, not the component.
- **Differentiate Without Color**: Not applicable. The component uses a gear icon that conveys meaning through shape, and state changes via opacity and focus rings, not color alone.

## Feature Flags

Not applicable. The component has no feature flags.

## Analytics

Not applicable. The component is a trigger; analytics event capture for menu interactions is the host's responsibility when composing the `DropdownMenuContent`.

## Privacy

Not applicable. The component does not collect, store, transmit, or process any data.

## Logging

Not applicable. The component has no logging requirements.

## Platform Notes

- **React/Web**: Defined in `packages/web/packages/ui/src/blocks/gear-menu-trigger.tsx`. It is a React functional component that wraps `DropdownMenuTrigger` from the local component library. The Lucide React `Settings` icon is imported and rendered at 14px. Tailwind CSS provides all styling. The component is exported as a named export.
- **SwiftUI**: Start with SwiftUI's `Menu` view (which provides a dropdown/menu trigger pattern) or a custom `Button` with a `Menu` overlay. Render a `Settings`-like `Image` (or use an SF Symbol such as `"gear"` or `"ellipsis.circle"`). Size the button to 24×24pt, set the image to 14pt, apply the dimmed text color via `.foregroundColor(.gray)`, and add a hover effect using `.onHover` or SwiftUI's state-based modifiers. Use `accessibility(label:)` to set the accessible name to the `label` parameter. The disabled state is a standard `Button(role:disabled)` or `.disabled()` modifier applying 40% opacity via `.opacity(0.4)`.
- **Compose**: Use Compose's `IconButton` or `Button` composable sized to 24×24.dp. Render a Compose Material Icons or custom vector drawable for the settings icon at 14.dp. Apply the dimmed text color via a `Color` parameter. Use `enabled` parameter to manage disabled state and apply opacity via `.alpha(0.4f)` in the disabled state. Use `semantics { contentDescription = label }` to set the accessible label. The icon drawable is marked as `contentDescription = null` to hide it from screen readers.
- **AppKit / UIKit**: On iOS, use `UIButton` with a custom `UIImage` (or SF Symbol `UIImage(systemName: "gear")`) sized to 14pt. Wrap in a `UIView` sized to 24×24pt with center alignment. Set `setAccessibilityLabel()` to the `label` parameter. Apply `isEnabled` and use `alpha = 0.4` for disabled state. Apply `tintColor` for hover/normal state switching via touch tracking (`UIControlEventTouchDown`, etc.). On macOS with AppKit, use `NSButton` with similarly configured SF Symbol or custom image; use `stringValue` for accessibility and `isEnabled` for the disabled state.
- **WinUI 3**: Use a `Button` control with a custom `FontIcon` (or Segoe Fluent Icons `Symbol.Settings`) set to 14pt size. Set `Width` and `Height` to 24 (`ActualHeight`, `ActualWidth` for layout). Set the `Content` property to the icon. Use `Foreground` brush binding to switch between `TextDim` and `Text` tokens on pointer enter/exit (use `PointerEntered` and `PointerExited` events). Set `AutomationProperties.Name` to the `label` parameter. Use `IsEnabled` property to manage the disabled state, and bind `Opacity` to `0.4` when disabled. Apply a `CornerRadius` for rounded corners. For focus, apply a `FocusVisualMargin` and use `VisualStateManager` to show a 2px border or glow with the gold/40 color on the `Focused` visual state.

## Design Decisions

- **Fixed 24×24px size**: The component is intentionally sized as a small, compact icon button to fit in rail headers and home bars. It is not resizable to maintain visual consistency as a fleet-wide sign for "actions on this list." A developer who needs a different size should compose a custom trigger rather than parameterize this component.
- **Icon hidden from screen readers**: The `aria-hidden` attribute on the icon prevents redundant announcements. Since the `aria-label` describes the button's action ("Registry actions"), the icon itself adds no information and would clutter the screen reader output.
- **Trigger-only design**: The component deliberately excludes menu content (`DropdownMenuContent`, menu items) to keep it reusable. Every list or collection may have different actions; a one-size-fits-all menu would be unmaintainable. The host composes the trigger with its own content.
- **Disabled state via native attribute**: The `disabled` prop maps to the native `disabled` attribute on the trigger, ensuring that keyboard and assistive technology users receive the expected disabled state signal from the browser.

## Compliance

Not applicable. No compliance checks are defined for this component.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
