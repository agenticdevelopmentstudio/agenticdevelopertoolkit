---
id: fb3a0db4-691e-4025-a391-2853908248b5
title: Tabs
domain: agenticdevelopercookbook://ingredients/tabs
type: ingredient
version: 1.0.0
status: review
language: en
created: 2026-09-22
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Tabbed interface component for organizing content into labeled sections with
  keyboard and mouse navigation.
platforms:
- web
tags:
- tabs
- navigation
- interface
depends-on: []
related: []
references: []
---

# Tabs

## Overview

Tabs component provides a tabbed interface for organizing related content into labeled sections. A single tab list contains multiple tab buttons; only one tab is active at a time and displays its associated panel. Users can switch between tabs using mouse click, keyboard navigation (arrow keys), or programmatic control. Built as a composition of four primitives: `Tabs` (root container), `TabsList` (tab button container), `TabsTab` (individual tab button), and `TabsPanel` (content panel).

## Behavioral Requirements

- **must-render-tab-list**: Component MUST render a container for tab buttons with a bottom border line separating tabs from content.
- **must-render-tabs**: Component MUST render individual clickable tab buttons within the tab list.
- **must-render-panels**: Component MUST render content panels that display content associated with each tab.
- **must-support-defaultValue**: Component MUST accept a `defaultValue` prop to specify which tab is active on initial render.
- **must-show-active-indicator**: Component MUST render a gold horizontal line (2px border) at the bottom of the active tab to indicate selection state.
- **must-support-disabled-tabs**: Component MUST respect a `disabled` attribute on individual tabs to prevent interaction and reduce visual prominence.
- **must-handle-click-selection**: Component MUST change the active tab when a user clicks any non-disabled tab button.
- **must-use-base-ui**: Component MUST use Base UI Tabs primitive for core tab management and ARIA semantics.
- **should-respond-hover**: Component tabs SHOULD change text color on hover to indicate interactivity (from muted to full contrast).
- **should-show-focus**: Component tabs SHOULD display focus indicator when navigated to via keyboard (outline-none maintained by component).
- **must-support-className**: Component MUST accept a `className` prop for CSS class customization on the root container and individual subcomponents.

## Appearance

- **Corner radius**: 0 (no rounding)
- **Padding—Tabs root**: flex column with 5px gap
- **Padding—TabsList**: bottom padding 0, inline elements with 4px gap horizontally
- **Padding—TabsTab**: 2px vertical, 0.25rem (4px) horizontal (px-1 py-2)
- **Font—TabsTab**: monospace, 0.8rem (12.8px), weight 400 (normal), tracking-wide (letter-spacing increased)
- **Background**: transparent (no fill)
- **Foreground—inactive**: muted gray text (apt-text-muted)
- **Foreground—active**: full contrast text (apt-text), gold underline (apt-gold)
- **Foreground—hover**: full contrast text (apt-text)
- **Foreground—disabled**: full opacity with opacity reduced to 50%
- **Border—TabsList**: 1px bottom border in neutral border color (apt-border)
- **Border—active tab**: 2px bottom border in gold (apt-gold), positioned at bottom of tab (negative margin -1px to overlap list border)
- **Shadow**: none
- **Min/Max size**: no size constraints on Tabs root; TabsTab has minimum implicit height from line-height and padding

## States

| State | Appearance change |
|-------|------------------|
| Default | Text muted gray, no underline (transparent 2px border), bottom border on list visible |
| Active | Text full contrast, gold 2px bottom border, border overrides list border |
| Hover | Text full contrast, no change to border (border state unchanged) |
| Focused | Text full contrast (via focus-visible), no distinctive focus ring (outline-none) |
| Disabled | Text full contrast but opacity 50%, pointer-events-none disables all interaction |

## Accessibility

- **Role**: Component uses Base UI which applies `role="tablist"` to `TabsList`, `role="tab"` to each `TabsTab`, and `role="tabpanel"` to each `TabsPanel`.
- **Labels**: Tab buttons MUST contain visible text that describes the panel content (no aria-label unless text is insufficient).
- **Focus management**: Keyboard navigation (arrow keys) is handled by Base UI; focus moves between tabs via standard tab order.
- **State announcement**: Base UI applies `aria-selected="true"` to the active tab and `aria-selected="false"` to inactive tabs; screen readers announce selection state.
- **Disabled state**: Disabled tabs MUST have `disabled` attribute set; Base UI applies `aria-disabled="true"`.
- **Minimum touch target**: Tab buttons MUST have a minimum height of 44px on touch platforms; current padding (2px vertical) yields ~32px height; implementations on touch platforms SHOULD increase vertical padding or add touch-specific sizing.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| tabs-001 | must-render-tab-list | Render `<Tabs><TabsList>...</TabsList></Tabs>` | TabsList renders as flexbox container with bottom border |
| tabs-002 | must-render-tabs | Render `<TabsTab value="a">Label A</TabsTab>` | Tab renders as clickable button with text |
| tabs-003 | must-render-panels | Render `<TabsPanel value="a">Content</TabsPanel>` | Panel renders with content visible when tab "a" active |
| tabs-004 | must-support-defaultValue | Render `<Tabs defaultValue="b">` with two tabs | Tab "b" is active on initial render, not tab "a" |
| tabs-005 | must-show-active-indicator | Activate a tab by click or prop | Active tab shows gold 2px bottom border, inactive tabs show transparent border |
| tabs-006 | must-support-disabled-tabs | Render `<TabsTab value="x" disabled>` and click it | Tab does not change active state; cursor not-allowed if pointer events blocked |
| tabs-007 | must-handle-click-selection | Click a non-disabled tab | Active state changes to that tab; associated panel content displays |
| tabs-008 | must-use-base-ui | Inspect rendered DOM | Component uses `@base-ui/react/tabs` TabsPrimitive primitives; ARIA roles present |
| tabs-009 | should-respond-hover | Hover over an inactive tab | Text color changes from apt-text-muted to apt-text; border unchanged |
| tabs-010 | should-show-focus | Tab to a tab via keyboard | Tab receives focus (outline-none means no ring, but focus-visible pseudo-class applies color change) |
| tabs-011 | must-support-className | Pass `className="custom-class"` to Tabs/TabsList/TabsTab | Custom class appended to element via `cn()` utility (Tailwind class merging) |

## Edge Cases

- **Empty tabs**: If no `TabsTab` children are provided, `TabsList` renders empty. Base UI allows this; no content displays. Behavior is a MUST per Base UI contract.
- **Single tab**: A single tab with no alternative choice may be confusing to users. Component MUST still render and function correctly; design SHOULD consider whether a single tab adds value.
- **No defaultValue**: If `defaultValue` prop is omitted, Base UI selects the first tab by default. This is a MUST per Base UI contract.
- **Disabled all tabs**: If all tabs are disabled, no tab can be activated. The component MUST render but no content displays. This is an edge case the implementor SHOULD avoid via design; component behavior is correct per requirements.
- **Very long tab labels**: Tab text that exceeds container width may wrap or truncate depending on parent width. Component has no word-wrap or text-overflow rule; MUST render as-is. Implementor SHOULD manage parent width constraints.
- **Rapid tab switching**: Clicking multiple tabs in quick succession MUST change the active state to the most recent click; Base UI queues state updates. No debouncing is performed.
- **Null or undefined panel content**: If a `TabsPanel` has no children, it renders as an empty container. Component MUST display this without error.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `defaultValue` | `string` | first tab | Specifies which tab is active on initial render via Base UI |
| `className` | `string` | `undefined` | Additional CSS classes merged into the root Tabs element via `cn()` |
| `disabled` | `boolean` | `false` | Applied per-tab to prevent interaction; not a root-level prop |

## Deep Linking

Not applicable: Tabs component is a UI primitive without built-in deep linking support. URL routing and tab state synchronization SHOULD be implemented at the page or application layer.

## Localization

| String Key | Default (en) | Context |
|-----------|-------------|---------|
| Tab labels | User-provided | Each `<TabsTab>` child is user-provided text; no built-in localization |

## Accessibility Options

- **Reduce Motion**: Not applicable; component has no animations (transition-colors is applied but is CSS-driven and respects `prefers-reduced-motion` via Tailwind configuration).
- **Increase Contrast**: Component text and borders use CSS custom properties (apt-text, apt-gold, apt-border) which SHOULD be overridden in high-contrast themes. Not a component responsibility.
- **Differentiate Without Color**: Component uses both color (gold) and position (border underline) to indicate active state; active state is distinguishable without color alone.

## Feature Flags

Not applicable: Tabs component is a base UI primitive with no feature flag control in source code.

## Analytics

Not applicable: Component emits no built-in analytics events. Analytics instrumentation is the responsibility of the consuming application.

## Privacy

Not applicable: Component processes no user data beyond interaction events (click, focus) which are local to the browser and not transmitted.

## Logging

Not applicable: Component performs no internal logging.

## Platform Notes

- **React/Web**: Component wraps `@base-ui/react/tabs` primitives. Files: `packages/web/packages/ui/src/components/tabs.tsx`. Uses Tailwind CSS utilities for styling. Active state is indicated via `data-[active]` attribute selector applied by Base UI; styling keys off this attribute. The `cn()` utility merges additional className props.

- **SwiftUI**: Native `TabView` control provides tabbed interface. Styling differs: use `tabViewStyle(.automatic)` or `.segmented` for alternative appearance. Active tab is controlled via `@State` binding. Disabled state via `.disabled(true)`. No gold color by default; map `apt-gold` to appropriate SwiftUI Color.

- **Compose**: Android `Compose` provides `Tab` composable within a `TabRow`. Active tab is managed via `selectedTabIndex: Int` state. Disabled tabs via `enabled` parameter. Styling uses Material Design tokens by default; customize via `indicatorContent` (underline) and `modifier`. No monospace font by default; apply `FontFamily.Monospace`.

- **AppKit / UIKit**: Native `NSTabView` (macOS) or custom `UIView` composition (iOS) provides tabbed interface. iOS typically uses `UISegmentedControl` or custom button stack. Underline indicator requires custom implementation via `CALayer` or view positioning. Disabled state via `isEnabled` property. Focus management via `becomeFirstResponder()`.

- **WinUI 3**: Native `TabView` control in XAML provides tabbed interface. Structure: `<TabView><TabViewItem Header="Tab 1"><ContentControl/></TabViewItem>…</TabView>`. Active tab via `SelectedIndex` property. Disabled tab via `IsEnabled="False"`. Underline/indicator customization via `TabViewItemHeaderBackground` brush and `Foreground` properties. Styling uses Fluent 2 design tokens; map `apt-gold` to `AccentFillColorBrush` or custom brush.

## Design Decisions

- **Gold underline for active state**: Rather than a filled pill or box background, an underline style is used to maintain minimal visual weight and distinguish the active tab while keeping focus on content. This matches the referenced hub design.

- **Monospace font for all tabs**: Monospace (`font-mono`) and tracking-wide (increased letter-spacing) gives technical appearance and improves readability of tab labels, especially when labels are short identifiers or status codes.

- **Flex layout with gap**: `flex flex-col gap-5` on root and `flex items-end gap-4` on TabsList provides predictable spacing and alignment without hard-coded margins.

- **Negative margin on tab border**: The active tab uses `-mb-px` to shift its gold underline down by 1px, allowing the 2px gold border to overlap and replace the TabsList's 1px border visually. This creates a seamless transition from list border to tab underline.

- **opacity-50 for disabled**: Rather than a strikethrough or separate disabled color, 50% opacity is applied to disabled tabs. This indicates disabled state while preserving the visual structure.

- **Base UI dependency**: Using Base UI Tabs ensures ARIA compliance, keyboard navigation (arrow keys, Home/End), and focus management are handled correctly. Building from a headless primitive is more maintainable than rolling custom tab logic.

## Compliance

Not applicable: No compliance checks are defined in source. Cookbook compliance with accessibility and keyboard navigation guidelines is ensured via Base UI dependency and the Accessibility section above.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | | Initial creation from web source |
