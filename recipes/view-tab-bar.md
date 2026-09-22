---
id: 826184eb-23f0-4ff7-b5f3-dc583fbc8496
title: View Tab Bar
domain: agenticdevelopertoolkit://recipes/view-tab-bar
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A content-area tab strip combining client-state buttons and route navigation
  links in a unified, horizontally-scrollable row.
platforms:
- typescript
- web
tags:
- tabs
- navigation
- client-state
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# View Tab Bar

## Overview

A flexible tab bar component that renders a horizontal strip combining two independent navigation modes: client-state buttons (triggering state callbacks without navigation) and route links (navigating to external views). The component shares visual styling with the Tabs underline idiom (gold bottom border on the active tab via `tabItemClass`), making mixed compositions read as a unified system. Tabs and links are rendered in separate semantic sections — tabs in a `role="tablist"` and links in a `<nav>` — to maintain correct screen reader hierarchy while preserving visual uniformity through consistent gap spacing and alignment.

## Behavioral Requirements

- **must-render-tabs**: Component MUST render a `role="tablist"` when the `tabs` array has length > 0.
- **must-render-nav-links**: Component MUST render a `<nav aria-label="views">` when the `links` array has length > 0.
- **must-not-render-empty-tablist**: Component MUST NOT render a `role="tablist"` when the `tabs` array is empty.
- **must-not-render-empty-nav**: Component MUST NOT render a `<nav>` when the `links` array is empty.
- **must-mark-active-tab**: Component MUST set `aria-selected="true"` on the tab whose `value` matches the current `value` prop; all other tabs MUST have `aria-selected="false"`.
- **must-trigger-on-tab-click**: Component MUST call the `onChange` callback with the tab's `value` when a tab button is clicked.
- **must-mark-active-link**: Component MUST set `aria-current="page"` on the link whose `active` prop is `true`; other links MUST NOT have this attribute.
- **must-apply-active-style-attribute**: Component MUST set `data-active=""` (empty string) on both tab buttons and links when they are in the active state; the attribute MUST NOT be present on inactive items.
- **must-use-tab-role**: Component MUST render each tab button with `role="tab"`.
- **must-use-aria-label-for-icon-tabs**: Component MUST apply the `title` prop as both the `aria-label` and `title` HTML attribute on each tab button to provide accessible labels when the visible label is an icon.
- **must-respect-container-class**: Component MUST accept a `className` prop and apply it to the outermost container element via the `cn()` utility.
- **must-apply-layout-spacing**: Component MUST apply `flex items-end gap-4` layout to both the inner tablist row and the nav row; the outer container MUST apply `px-4` horizontal padding.
- **must-apply-item-styling**: Component MUST apply `tabItemClass` to every tab button and link element for consistent visual styling.
- **must-accept-reactnode-labels**: Component MUST accept `ReactNode` for both tab and link labels, supporting text, icons, or composed elements.

## Appearance

- **Container padding**: Horizontal padding `px-4` (typically 16px on the x-axis)
- **Layout**: Flex row with `items-end` alignment and `gap-4` (typically 16px) spacing between items
- **Tab/Link styling**: Applies `tabItemClass` from the Tabs component (shared underline idiom with gold bottom border on active state)
- **Active indicator**: `data-active=""` attribute (empty string) applied to active tabs and links; styling via CSS attribute selector `[data-active]`
- **Font**: Inherits from `tabItemClass` definition (typically mono labels per the underline idiom)
- **No visible disabled state**: Component does not render disabled tabs
- **Min/Max size**: No explicit constraints; tabs and links flex to accommodate content within the flex row

## States

| State | Tab Appearance | Link Appearance |
|-------|----------------|-----------------|
| Active | `data-active=""`, `aria-selected="true"`, gold bottom border via `tabItemClass` | `data-active=""`, `aria-current="page"`, gold bottom border via `tabItemClass` |
| Inactive | No `data-active` attribute, `aria-selected="false"`, underline not visible | No `data-active` attribute, no `aria-current`, underline not visible |
| Focused | Inherits focus styling from `tabItemClass` definition | Inherits focus styling from `tabItemClass` definition |

## Accessibility

- **Semantic structure**: Tabs MUST be wrapped in `role="tablist"`; links MUST be wrapped in `<nav aria-label="views">` to distinguish navigation type and avoid mixing tabs and links in the same tablist.
- **Tab role and state**: Each tab button MUST have `role="tab"` and `aria-selected` reflecting its active state.
- **Link semantics**: Links MUST be rendered as `<a>` elements with `aria-current="page"` on the active link to indicate current page/location.
- **Icon label fallback**: When a tab's visible label is an icon, the `title` prop MUST be provided to populate both `aria-label` and `title` attributes.
- **Keyboard navigation**: Tabs and links MUST be navigable via Tab key (rendered as interactive elements `<button>` and `<a>`) and active tab/link MUST be indicated by `aria-selected` and `aria-current` respectively.
- **Screen reader announcement**: The distinction between tabs (client-state buttons) and links (navigation) is preserved in the DOM structure (separate `role="tablist"` and `<nav>`), enabling screen readers to announce the navigation mode correctly.
- **Minimum touch target**: No explicit touch target size constraint in component; implementors MUST ensure tab and link elements meet platform minimum (44×44pt on iOS per Human Interface Guidelines, 48×48dp on Android per Material Design 3, 44×44px on web per WCAG guidance).

## Conformance Test Vectors

| ID | Requirement | Input | Expected |
|----|-------------|-------|----------|
| view-tab-bar-001 | must-render-tabs | `tabs=[{value:"a",label:"Tab A"}]`, `value="a"`, `onChange=()=>{}` | Rendered `<div role="tablist">` containing one `<button role="tab">` |
| view-tab-bar-002 | must-not-render-empty-tablist | `tabs=[]`, `links=[]` | No `role="tablist"` element in output |
| view-tab-bar-003 | must-render-nav-links | `tabs=[]`, `links=[{href:"/a",label:"Link A"}]` | Rendered `<nav aria-label="views">` containing one `<a href="/a">` |
| view-tab-bar-004 | must-not-render-empty-nav | `tabs=[{value:"a",label:"Tab A"}]`, `links=[]` | No `<nav>` element in output |
| view-tab-bar-005 | must-mark-active-tab | `tabs=[{value:"a",label:"A"},{value:"b",label:"B"}]`, `value="a"` | First tab has `aria-selected="true"`, second has `aria-selected="false"` |
| view-tab-bar-006 | must-trigger-on-tab-click | `tabs=[{value:"a",label:"A"}]`, `onChange` spy attached | `onChange("a")` called when tab button is clicked |
| view-tab-bar-007 | must-mark-active-link | `links=[{href:"/a",label:"A",active:true},{href:"/b",label:"B",active:false}]` | First link has `aria-current="page"`, second does not |
| view-tab-bar-008 | must-apply-active-style-attribute | `tabs=[{value:"a",label:"A"}]`, `value="a"` | Tab button has `data-active=""` attribute |
| view-tab-bar-009 | must-apply-active-style-attribute | `tabs=[{value:"a",label:"A"}]`, `value="b"` | Tab button does NOT have `data-active` attribute |
| view-tab-bar-010 | must-use-tab-role | `tabs=[{value:"a",label:"A"}]` | Each tab button has `role="tab"` attribute |
| view-tab-bar-011 | must-use-aria-label-for-icon-tabs | `tabs=[{value:"a",label:<Icon/>,title:"Icon Label"}]` | Tab button has both `aria-label="Icon Label"` and `title="Icon Label"` attributes |
| view-tab-bar-012 | must-respect-container-class | `className="custom-class"` | Outermost container div has class `custom-class` applied (via `cn()`) |
| view-tab-bar-013 | must-apply-layout-spacing | Any valid props | Rendered output has `flex items-end gap-4` on tablist and nav rows; outer container has `px-4` |
| view-tab-bar-014 | must-apply-item-styling | Any valid tabs or links | Each tab button and link element has `tabItemClass` applied |
| view-tab-bar-015 | must-accept-reactnode-labels | `tabs=[{value:"a",label:<span>Custom</span>}]` | Tab renders ReactNode label content correctly |

## Edge Cases

- **Empty tabs and empty links**: When both `tabs` and `links` arrays are empty, the component renders only the outer container with the specified `className` and `px-4` padding; no tablist or nav is rendered. This is valid but produces an empty visual bar.
- **Single tab or link**: A single-item array (one tab or one link) renders correctly; the lone item becomes the active default if its value/active property matches.
- **Icon-only labels without title**: If a tab's `label` is an icon and no `title` prop is provided, the tab will not have an accessible aria-label; this is a conformance gap that MUST be caught in testing. The component does not validate or warn about this condition.
- **onChange not provided**: If the `onChange` callback is not provided or is undefined, tab clicks will not trigger errors but will silently fail to update state (caller's responsibility to provide the callback).
- **Duplicate tab values**: If the `tabs` array contains two items with the same `value`, the first active match wins for styling purposes. React warnings may appear in development due to non-unique keys in the map; source uses `t.value` as the key, which prevents duplicates if values are unique strings.
- **Very long labels**: Labels that exceed the flex row width will cause the row to overflow horizontally unless the parent container has overflow handling or responsive truncation. The component does not constrain label width.
- **Mixed valid and invalid links**: If a link has an invalid `href` (e.g., null or undefined), the component will render an `<a>` tag with that href; the browser's default behavior applies (typically no navigation). This is not validated by the component.

## Configuration

| Option | Type | Default | Required | Description |
|--------|------|---------|----------|-------------|
| `tabs` | `ViewTabItem[]` | — | Yes | Array of tab items, each with `value`, `label`, and optional `title` |
| `value` | `string` | — | Yes | The currently active tab value; MUST match one of the `tabs[].value` entries |
| `onChange` | `(value: string) => void` | — | Yes | Callback invoked when a tab button is clicked, receiving the clicked tab's value |
| `links` | `ViewTabLink[]` | `[]` | No | Array of link items, each with `href`, `label`, and optional `active` boolean |
| `className` | `string` | — | No | Additional CSS class(es) to apply to the outer container via `cn()` |

## Deep Linking

Route links in the component support standard `href` navigation:

| Platform | Behavior |
|----------|----------|
| Web | Links render as `<a href>` elements; clicking navigates via browser default behavior or client-side router if configured. The component does not handle routing; it passes through the `href` as provided. |

## Localization

Labels are provided as `ReactNode` props (text, icons, or composed elements). The component does not perform any string localization. Callers MUST provide locale-specific labels via the `label` prop.

| String Key | Source | Context |
|-----------|--------|---------|
| N/A | Caller-provided `tabs[].label` and `links[].label` | User-facing tab and link text |
| `aria-label="views"` | Hardcoded in component | Semantic label for the navigation section |

## Accessibility Options

The component uses standard ARIA attributes and does not detect or respond to platform accessibility settings (Rule 15).

| Option | Behavior |
|--------|----------|
| Reduce Motion | Not implemented in source. Component does not apply `prefers-reduced-motion`; animation behavior depends on `tabItemClass` styling (caller's responsibility). |
| Increase Contrast | Not implemented in source. Contrast is determined by `tabItemClass` styling (caller's responsibility to ensure WCAG AA compliance). |
| Differentiate Without Color | Not implemented in source. Active state is indicated by `data-active` attribute and `aria-selected`/`aria-current`; visual styling via `tabItemClass` (caller's responsibility). |

## Feature Flags

Not implemented in source. No feature flags control the component's availability or behavior.

## Analytics

Not implemented in source. The component does not emit analytics events; callers MUST attach event handlers or wrap `onChange` to emit analytics if needed.

## Privacy

The component collects no data. The `onChange` callback and link `href` are controlled by the caller. The component stores no internal state beyond rendering.

## Logging

Not implemented in source. No logging or debug output is emitted.

## Platform Notes

- **React/Web**: Use this component as provided. Tabs are rendered as `<button role="tab">` elements with `aria-selected` state; links are rendered as `<a>` elements within `<nav aria-label="views">`. The outer container applies `flex items-end gap-4` layout with `px-4` padding. Import `tabListClass` and `tabItemClass` from the shared Tabs component to ensure visual consistency. The source is in `packages/web/packages/ui/src/blocks/view-tab-bar.tsx`.

- **Swift/SwiftUI**: Start with an `HStack` with `.alignment(.bottom)` to match the `items-end` behavior. Create a `Tabs` view with `role = "tablist"` for the button tabs, using `.onTapGesture` to call the equivalent of `onChange`. Create a separate navigation section (e.g., via `Link` elements) with `role = "navigation"` and `accessibilityLabel = "views"`. Apply consistent padding (16pt horizontal) and spacing (gap-4 equivalent, 16pt) via `.padding(.horizontal, 16)` and `.spacing(16)`. Use `tabItemClass` styling (or its SwiftUI equivalent) for active state indication via `data-active` equivalent (e.g., a conditional border or underline).

- **Kotlin/Compose**: Use `Row` with `verticalAlignment = Alignment.Bottom` and `horizontalArrangement = Arrangement.spacedBy(16.dp)`. Render tabs as `Button` composables with `role = "tab"` semantics (via `Modifier.semantics { role = Role.Button }`). Use a separate `Row` for links via `BasicText` or `Text` with `role = "navigation"`. Apply consistent padding and spacing (16.dp horizontal padding on the container, 16.dp gap). Use `LazyRow` if the tab/link list is long. For active state, apply `tabItemClass` styling (or equivalent underline/border color based on `active` state).

- **AppKit / UIKit**: On AppKit, use `NSTabView` to render the client-state tabs; migrate link navigation to a separate navigation bar or toolbar section with `NSButtonCell` items. On UIKit, use `UISegmentedControl` for the tab buttons or build a custom `UIScrollView` with tap handlers calling a delegate method equivalent to `onChange`. For links, add `UIButton` items with `UIControlEventTouchUpInside` triggering navigation. Both platforms should maintain visual consistency with the `tabItemClass` underline/border styling and apply `.bottom` alignment to all elements in the row.

- **WinUI 3**: Use the `TabView` control with `TabViewItem` elements for client-state tabs, wiring each tab's `SelectionChanged` event to the equivalent of `onChange`. For route links, add a parallel `NavigationView` or a secondary row of `HyperlinkButton` elements. Apply `Orientation="Horizontal"` and `VerticalAlignment="Bottom"` to match the flex row layout. Use `Spacing = 16` for the gap and `Padding = "16,0"` for the horizontal padding. Style the active tab with the `tabItemClass` equivalent (gold bottom border, set via `ControlTemplate` or a data-driven visual state).

## Design Decisions

- **Separation of tabs and links in distinct ARIA sections**: Tabs are wrapped in `role="tablist"` and links in `<nav>` because tabs are interactive controls that change application state without navigation, while links perform navigation. Screen readers must distinguish between these two interaction modes. The visual gap-4 spacing and flex alignment make both groups appear as one unified row despite their semantic separation.

- **Optional `title` prop for icon-only tabs**: Icons are common in tab bars, and providing accessible labels for icon-only tabs requires an `aria-label`. The `title` prop is optional because not all tabs are icon-only, but callers MUST provide it for any tab with an icon label to maintain accessibility compliance.

- **data-active attribute for styling**: The component uses `data-active=""` (empty string) rather than `data-active="true"` to match a common CSS convention where the presence of the attribute (regardless of value) indicates the active state. This is consistent with the pattern used in the rest of the Tabs component family.

- **No internal state management**: The component is a controlled component; callers MUST manage the `value` state externally and call `onChange` to update it. This design allows the parent to manage complex logic (e.g., unsaved Config drafts that must survive a tab switch) without the component imposing its own state model.

- **Links array is optional**: Links are an optional feature (defaults to empty array) because not all tab bars include route navigation. Some use cases may have tabs only or links only.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| Accessibility via ARIA roles and attributes | Passed | UI/Accessibility |
| Semantic HTML structure (role="tablist", role="tab", <nav>) | Passed | UI/Accessibility |
| Controlled component pattern (value + onChange) | Passed | React Patterns |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
