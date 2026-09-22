---
id: ff445185-2322-4c94-ad9d-3ad27a50677d
title: App Tabs
domain: agenticdevelopertoolkit://recipes/app-tabs
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A controlled tab bar component for app-wide navigation with optional icons
  and a right-aligned action item.
platforms:
- typescript
- web
tags:
- navigation
- tabs
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# App Tabs

## Overview

AppTabs is a controlled tab navigation component used as the top tab bar in the signed-in app. It renders a horizontal list of tabs with optional icons, marking one tab as active based on the `value` prop. It supports an optional `endItem` that appears at the right edge, commonly used for user settings or other app-level actions. The component uses semantic button elements styled with a shared tab grammar to achieve an underline-mono appearance.

## Behavioral Requirements

- **must-render-items**: The component MUST render each item in the `items` array as an interactive tab.
- **must-mark-active-tab**: The component MUST mark the tab matching the `value` prop as active, setting `aria-selected="true"` and `data-active` attribute on that tab only.
- **must-render-icon-if-provided**: If an `AppTab` in `items` has an `icon` property, the component MUST render it within the tab.
- **must-render-label**: The component MUST render the `label` ReactNode for each tab.
- **must-invoke-callback-on-click**: When a user clicks a tab, the component MUST call `onValueChange` (if provided) with the tab's `id`.
- **must-render-endItem-if-provided**: If `endItem` is provided, the component MUST render it at the right edge of the tab bar.
- **must-respect-endItem-active-state**: The `endItem` tab MUST use its own `active` property independently of the `value` prop; it MUST NOT be marked active based on `value` matching its `id`.
- **must-apply-role-tablist**: The root container MUST have `role="tablist"`.
- **must-apply-role-tab-to-items**: Each rendered tab button MUST have `role="tab"`.
- **must-apply-className**: The component MUST apply the `className` prop to the root container if provided.
- **must-render-plain-buttons**: The component MUST render tabs as plain `<button>` elements with `type="button"`, not as a Base UI `<Tabs>` component or abstracted tab control.

## Appearance

Tabs use the shared tab styling defined by `tabItemClass` and `tabListClass` from `components/tabs`. The following appearance properties are managed by these shared classes:

- **Corner radius**: Defined by shared tab grammar.
- **Padding**: Defined by shared tab grammar.
- **Font**: Defined by shared tab grammar (weight and size).
- **Background**: Defined by shared tab grammar.
- **Foreground/Text**: Defined by shared tab grammar.
- **Border**: Defined by shared tab grammar; underline-mono style is applied by shared classes.
- **Shadow**: No shadow; defined by shared tab grammar.
- **Min/Max size**: No explicit constraints; size is driven by content and shared tab grammar.

## States

| State | Appearance change |
|-------|------------------|
| Default | Tab renders with no active indicator. `aria-selected="false"`. `data-active` attribute is absent. |
| Active | Tab renders with active indicator (underline per shared tab grammar). `aria-selected="true"`. `data-active` attribute is present (value is undefined, presence is the signal). |
| Focused | Managed by browser focus styles and shared tab grammar. |
| Disabled | Not implemented in source. Behavior undefined. |

## Accessibility

- **Role**: Tabs are rendered as `<button>` elements with `role="tab"`. The root container has `role="tablist"`.
- **State communication**: Active state is conveyed via `aria-selected` attribute (true or false).
- **Label**: Each tab's label is rendered as visible text content within the button. No additional `aria-label` is present in source; labels are the visible text.
- **Icon handling**: Icons are rendered as visual content within the tab; they are not decorated with `aria-hidden` or labeled in source.
- **Keyboard interaction**: Handled by browser default button keyboard support (Space/Enter to activate). No custom keyboard navigation (arrow keys) is implemented in source.
- **Minimum tap target**: Defined by shared tab grammar via `tabItemClass`. Platform-specific sizing (iOS 44×44pt, Android 48×48dp) is applied through shared classes.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| app-tabs-001 | must-render-items | `items=[{id:"tab1", label:"Tab 1"}, {id:"tab2", label:"Tab 2"}]` | Both tabs render as buttons; text content matches labels. |
| app-tabs-002 | must-mark-active-tab | `items=[{id:"tab1", label:"T1"}, {id:"tab2", label:"T2"}]`, `value="tab1"` | Tab with id="tab1" has `aria-selected="true"` and `data-active` attribute; tab with id="tab2" has `aria-selected="false"` and no `data-active` attribute. |
| app-tabs-003 | must-render-icon-if-provided | `items=[{id:"tab1", label:"Tab", icon:<IconComponent />}]` | Icon is rendered inside the tab button alongside the label. |
| app-tabs-004 | must-invoke-callback-on-click | `items=[{id:"tab1", label:"T1"}]`, `onValueChange={spy}` | Clicking the tab invokes `onValueChange("tab1")`. |
| app-tabs-005 | must-render-endItem-if-provided | `endItem={id:"settings", label:"Settings"}` | EndItem renders as a button at the right edge of the tab bar (positioned via `ml-auto` class). |
| app-tabs-006 | must-respect-endItem-active-state | `items=[{id:"tab1", label:"Tab"}]`, `value="tab1"`, `endItem={id:"settings", label:"Settings", active: true}` | Tab 1 is active per `value`; endItem is active per its own `active` property; they are independently active. |
| app-tabs-007 | must-apply-role-tablist | Any valid props | Root `<div>` has `role="tablist"`. |
| app-tabs-008 | must-apply-role-tab-to-items | Any valid props | Every rendered button has `role="tab"`. |
| app-tabs-009 | must-apply-className | `className="custom-class"` | Root container has class `custom-class` applied (merged with existing classes via `cn()`). |
| app-tabs-010 | must-render-plain-buttons | Any valid props | All tabs are `<button>` elements with `type="button"`, not Base UI components. |

## Edge Cases

- **Empty items array**: If `items` is an empty array, the component renders the tab list container but no tab buttons. EndItem (if provided) still renders.
- **Value not in items**: If `value` does not match any `id` in `items`, no tab is marked active (all have `aria-selected="false"`). This is valid; the component does not error.
- **Missing onValueChange**: If `onValueChange` is undefined, clicking a tab calls `undefined(id)`, which is a no-op. The tab remains interactive; the component does not guard against this.
- **Items array mutation**: The component uses `.map()` over `items` on each render. If `items` is mutated (not replaced), the component reflects the current array state on next render.
- **EndItem with no active property**: If `endItem` is provided without an `active` property, it renders with `aria-selected` derived from `!!undefined`, which is false. The endItem tab is not active.
- **Icon is falsy**: If `icon` is `null`, `undefined`, or `false`, nothing is rendered for that slot; the label still renders.

## Configuration

Not applicable: AppTabs is a controlled component. Configuration is entirely through props (`items`, `value`, `onValueChange`, `endItem`, `className`); no separate configuration object or external settings apply.

## Deep Linking

Not applicable: AppTabs is a navigation component that drives app-wide routing via `onValueChange`; deep linking is handled by the consuming app logic, not within the component.

## Localization

Not applicable: Tab labels and the endItem label are passed as ReactNode; the component does not generate text. Localization is the responsibility of the consumer providing the labels.

## Accessibility Options

Not implemented in source. The component does not respond to accessibility display options such as Reduce Motion, Increase Contrast, or Differentiate Without Color. These concerns are delegated to the shared tab styling classes.

## Feature Flags

Not applicable: No feature flags or conditional behavior is present in source.

## Analytics

Not implemented in source. The component does not emit analytics events; event tracking is the responsibility of the consuming app via `onValueChange` callback.

## Privacy

Not applicable: AppTabs does not collect, store, or transmit any user data. It is a pure presentational component.

## Logging

Not applicable: No logging is implemented in the component source.

## Platform Notes

- **React/Web**: Defined in `packages/web/packages/ui/src/blocks/app-tabs.tsx`. Exported as `AppTabs`. Renders plain `<button>` elements styled with `tabItemClass` and `tabListClass` from shared components. Uses React's `onClick` for tab selection and managed `value` prop for active state control.
- **SwiftUI**: Translate to `TabView` or a custom tab bar using `Picker` with segmented style. Render tabs as buttons in a `HStack`, applying the shared tab styling equivalent. The `endItem` property would translate to a trailing `Spacer()` followed by the settings/action button.
- **Compose**: Translate to a Row containing Buttons, with the active state managed via a mutable state. Use `Modifier.clickable()` for click handling. The `endItem` property would be placed after a `Spacer(Modifier.weight(1f))` for right alignment.
- **UIKit / AppKit**: Create a custom view or use `NSSegmentedControl` if appropriate. Render tabs as buttons in a horizontal stack (UIStackView on iOS, NSStackView on macOS). Manage active state via a data property and update UI on value changes. The `endItem` property would be positioned at the trailing edge with a spacer.
- **WinUI 3**: Use a `TabView` control with `TabViewItem` elements for each tab, or implement a custom tab bar using a `StackPanel` (Horizontal) with Buttons. Set `IsSelected` binding for active state management. Apply Fluent 2 underline-mono styling via control templates. For the `endItem`, add it as a trailing element outside the main tab list, positioned with `HorizontalAlignment="Right"`.

## Design Decisions

The component renders plain buttons instead of a Base UI `<Tabs>` component because these are navigation-style tabs with no associated panels. The `endItem` has independent active state to allow app-level actions (e.g., Settings) that are visually styled as tabs but logically independent of the main tab selection. The callback pattern (`onValueChange`) is used instead of internal state to keep the component fully controlled, allowing the parent app to orchestrate navigation and state synchronization.

## Compliance

Not applicable: No compliance checks are defined for this component.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation from source. |
