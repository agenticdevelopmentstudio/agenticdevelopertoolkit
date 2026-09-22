---
id: aaebd90e-991f-4133-a12d-0783586eae5a
title: Hierarchical Menu Detail
domain: agenticdevelopercookbook://ingredients/hierarchical-menu-detail
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A nested-menu framework rendering hierarchical lists with three disclosure
  styles and optional detail pane.
platforms:
- web
tags:
- menu
- navigation
- hierarchy
depends-on: []
related: []
references: []
---

# Hierarchical Menu Detail

## Overview

HierarchicalMenuDetail is a container for rendering cascading hierarchies of topic/detail rails where each level's selection scopes the next. A consumer passes a flat `levels` array; the component renders each as a side-by-side column (wide mode) or full-width pane (narrow mode), connecting selections via breadcrumb trail. Three disclosure styles control how ancestor lists yield room to the detail pane as the window narrows: minimized (icon strips then slide off), covered (stack under child), and cascading (vertical nested-menu).

## Behavioral Requirements

- **must-render-levels**: Component MUST render each level in `levels` as a distinct, scrollable list column with rows `items` for that level.
- **must-scope-by-selection**: Each level's visible items MUST be determined by the parent level's `selectedId`. A level with `selectedId == null` does not render.
- **must-show-breadcrumb**: When `showBreadcrumb` is true (default), component MUST display a breadcrumb trail with a root label (if provided) and a crumb for each level whose `selectedId` is non-null, reading from outermost to deepest.
- **must-navigate-breadcrumb**: When breadcrumb crumbs are interactive (`onNavigate` provided), clicking a crumb MUST call the level's `onClear()` for all levels deeper than the clicked crumb, leaving the clicked level's selection in place.
- **must-deselect-on-reclick**: Clicking a row whose `id` is already `selectedId` MUST call the level's `onClear()`.
- **must-support-three-styles**: Component MUST support three `disclosureStyle` values — "minimized", "covered", "cascading" — each controlling how ancestor lists are hidden or revealed when viewport narrowness prevents showing all columns.
- **must-apply-autohide**: When `autoHideTopics` is true (default), only the frontier level (deepest rendered) MUST remain disclosed; all ancestor lists MUST be hidden by their child, even when space permits. The root-level header MUST carry a toggle to flip this behavior.
- **must-honor-pins**: Per-level `«`/`»` toggle pins override autoHide: true (pinned hidden) MUST keep a list hidden; false (pinned disclosed) MUST keep it disclosed unless width pressure forbids it. Flipping autoHide MUST clear all pins.
- **must-support-manual-collapse**: When `manualCollapse` is true (default), each list header MUST carry a toggle (`«`/`»` icons) that can pin or unpin that list independently of autoHide, persisting across selections.
- **must-render-detail**: Component MUST render the `children` into a rightmost detail pane, below the list columns in wide mode or as the only visible pane in narrow mode.
- **must-render-toolbar**: When `toolbar` is provided, component MUST render it in a full-width strip above the breadcrumb, collapsing the strip if the toolbar slot is empty.
- **must-support-mindetailwidth**: When total width of list columns plus `minDetailWidth` exceeds the container, component MUST drill down (hide ancestor columns) to keep the detail pane at least `minDetailWidth` wide.
- **must-apply-default-select**: When a level appears with `defaultSelectedId` and no selection (`selectedId == null`), component MUST call the level's `onSelect(defaultSelectedId, { replace: true })` once per appearance, not re-firing if the selection is manually cleared.
- **must-guard-exit**: When `exitGuard` is provided (non-null), switching to a sibling at the deepest level, clicking a shallower row, or navigating breadcrumb-up while the guard's `isDirty` is true MUST show an unsaved-changes alert before proceeding.
- **must-support-cascading**: In cascading mode, only the root list spans full height; deeper lists open to the right of their parent, positioned just under the parent header, with height hugging their rows (capped at container bottom). The detail pane sits beside the root.
- **must-render-connectors**: When two or more levels are rendered in wide mode, component MUST draw a visual chain (selection connector) from each selected parent row to its selected child row, using a gold elbow path from parent to child.
- **must-support-narrow-mode**: When `layoutMode` is "narrow", or when "auto" and container width is less than one topic list plus `minDetailWidth`, or on a phone, component MUST render one full-width pane at a time, with Back buttons (minimized style only) to navigate up the hierarchy.
- **must-render-trailing-crumbs**: When `trailingCrumbs` is provided, component MUST append each as a non-interactive crumb after the level crumbs in the breadcrumb trail.
- **may-hide-offscreen**: Lists that do not fit in the visible viewport (after considering autoHide, pins, width pressure, and disclosure style) MAY be rendered but hidden via `aria-hidden` and pointer-events-none.
- **may-render-hover-reveal**: In covered and cascading modes, a pointer ENTER on a covered list row MAY reveal every on-screen ancestor list above it for the duration of the pointer's presence in the menu stack, re-hiding when the pointer exits.

## Appearance

- **Rail layout**: Each list column is a vertical stack with a header (level title + toggles) and a scrollable item list below.
- **Header height**: 2.15rem (approximately 34px at 16px base font).
- **List item styling**: Rows inherit from TopicRail; no fixed height specified in this component (delegated to item renderer).
- **Text styling**: List headers use monospace (`font-mono`), 0.8rem (12.8px), muted color. Breadcrumb uses the same monospace + 0.75rem.
- **Border**: 1px solid (apt-border color).
- **Background**: Lists use apt-nav background; detail pane uses apt-surface.
- **Spacing**: Breadcrumb has 4px–16px padding, 12px gaps between crumbs. Rails have no padding outside the item list (scrollable area consumes container).
- **Selection connector**: Gold (`apt-gold`) elbow path, 2px stroke, drawn over list area (pointer-events-none).
- **Toggle icons**: 16px lucide-react icons (PanelLeftOpen/PanelLeftClose for auto-hide, ChevronsLeft/ChevronsRight for immerse detail).
- **Focus indicator**: 2px ring (apt-gold/40) on keyboard focus for breadcrumb crumbs and header toggles.

## States

| State | Appearance change |
|-------|------------------|
| Default (list disclosed, not selected) | Rows visible in normal color (apt-text). |
| Row selected | Row highlighted with apt-gold text or background (delegated to TopicRail). Breadcrumb shows row's label. Selection connector draws to this row. |
| Hovered (pointer over row) | Hover state delegated to TopicRail item renderer. |
| Focused (keyboard on row) | Focus-visible ring applied to interactive row element. |
| List hidden by autoHide or width pressure | Column slid off-screen (0-width, aria-hidden, pointer-events-none) or shown as icon strip only. |
| List pinned hidden | Hidden despite autoHide being false; toggle shows pin state. |
| List pinned disclosed | Disclosed despite autoHide being true; toggle shows pin state. |
| Cascading mode — covered list | List rendered but indented/occluded by child list; header stays visible. |
| Cascading mode — revealed branch (hover) | All ancestor lists above hovered row expanded to full width for duration of pointer presence. |
| Narrow mode — alternate panes | One full-width pane visible; others hidden. Back button shows to navigate up. |
| Breadcrumb crumb hovered | Crumb color changes to lighter text (apt-text). |
| Breadcrumb crumb focused | Focus-visible ring applied. |
| Detail guard dirty | Unsaved-changes alert shown on exit attempt. |

## Accessibility

- **Role**: The root is a flex container wrapping nav (breadcrumb) and multiple aside-like sections (rail columns). Each list column is a scrollable region; the root `aria-label="Breadcrumb"` marks the navigation trail.
- **Breadcrumb navigation**: Semantic nav + ol/li structure. Current crumb marked with `aria-current="page"`. Crumb buttons use `aria-label` or visible text; chevron separators marked `aria-hidden`.
- **Column identification**: List columns use `data-htd-col` (internal tracking); selection within each marked with `aria-current="true"` on the selected row element.
- **Header toggles**: AutoHide toggle has `aria-label`, `aria-pressed` showing toggle state. Pin toggles have descriptive `aria-label` ("Auto-hide parent lists: on/off", "Expand/collapse this list").
- **Offscreen columns**: Hidden columns marked `aria-hidden="true"` and `pointer-events-none`.
- **Back button (narrow mode)**: Labeled `aria-label="Back"`, showing ChevronLeft icon + text.
- **Decorative elements**: Icons used as decoration (ChevronRight in breadcrumb, icon-only toggles) marked `aria-hidden`.
- **Selection connectors**: SVG path overlay marked `aria-hidden` and `pointer-events-none`.
- **Minimum touch target**: Header toggles and breadcrumb crumbs are click targets; recommended minimum 44×44px (met via padding + icon size + text).
- **Keyboard navigation**: All interactive elements (breadcrumb crumbs, toggles, list rows) receive focus and keyboard activation via standard controls (button, a, or clickable div with role="button"). Escape MAY close a revealed branch (not implemented in source; no explicit MUST).
- **Label clarity**: Breadcrumb uses visible text; toggles use `aria-label` + visible icon. Lists inherit labels from TopicRail.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| hmd-001 | must-render-levels | `levels` with 2 items, level 0 has 3 items, level 1 has 2 items | Both levels render as columns with correct item counts. |
| hmd-002 | must-scope-by-selection | Level 0 with `selectedId="a"`; level 1 with `selectedId=null` | Level 1 does not render (frontier is level 0). |
| hmd-003 | must-show-breadcrumb | `showBreadcrumb=true`, `rootLabel="Root"`, level 0 selected | Breadcrumb shows "Root" + selected item label. |
| hmd-004 | must-navigate-breadcrumb | Breadcrumb crumb clicked for level 0 | `onClear()` called for levels 1+; level 0 selection unchanged. |
| hmd-005 | must-deselect-on-reclick | Row with `id="x"` already selected, row clicked again | `onClear()` called for that level. |
| hmd-006 | must-support-three-styles | `disclosureStyle` set to each of "minimized", "covered", "cascading" | Each style renders lists with correct layout/hiding strategy. |
| hmd-007 | must-apply-autohide | `autoHideTopics=true`, 3 levels rendered | Only frontier (level 2) visible; levels 0–1 hidden. Root header toggle exists. |
| hmd-008 | must-honor-pins | `autoHideTopics=true`, level 0 pinned disclosed (`pins["level-0"]=false`) | Level 0 remains visible despite autoHide. |
| hmd-009 | must-support-manual-collapse | `manualCollapse=true`, list header clicked to toggle | List pin state flips; layout re-renders immediately. |
| hmd-010 | must-render-detail | `children` provided with text "Detail" | Text "Detail" appears in rightmost pane. |
| hmd-011 | must-render-toolbar | `toolbar` with a button | Button renders in strip above breadcrumb. |
| hmd-012 | must-support-mindetailwidth | `minDetailWidth="28rem"`, window width 32rem, 2 levels at 10rem each | Detail pane shows at 28rem; level 0 hidden off-screen. |
| hmd-013 | must-apply-default-select | Level 0 appears with `defaultSelectedId="x"` and `selectedId=null` | `onSelect("x", { replace: true })` called once. Subsequent renders do not re-fire. |
| hmd-014 | must-guard-exit | `exitGuard` with `isDirty=true`, breadcrumb crumb clicked | Unsaved-changes alert shown; navigation blocked until user confirms. |
| hmd-015 | must-support-cascading | `disclosureStyle="cascading"`, 2 levels selected | Root list spans full height; level 1 opens to right of root, below root header. |
| hmd-016 | must-render-connectors | Wide mode, 2 levels, both with selections | Gold elbow path drawn from level 0 selected row to level 1 selected row. |
| hmd-017 | must-support-narrow-mode | `layoutMode="narrow"` or "auto" on phone, 2 levels | One full-width pane visible; Back button shows to switch panes. |
| hmd-018 | must-render-trailing-crumbs | `trailingCrumbs=[{label:"Leaf"}]` | "Leaf" appears after level crumbs, non-interactive. |
| hmd-019 | must-support-hover-reveal | `disclosureStyle="covered"`, pointer ENTER on covered list row | Ancestor lists reveal at full width for pointer duration. |

## Edge Cases

- **Empty levels array**: Component MUST render without error (no columns, only toolbar and breadcrumb if provided).
- **No selection at any level**: Component renders only level 0 (frontier is 0) with all items visible. Breadcrumb shows only root label if provided.
- **Selection gap**: If `levels[0].selectedId != null` but `levels[1].selectedId == null`, frontier is level 1 and only levels 0–1 render.
- **defaultSelectedId not in items**: If a level's `defaultSelectedId` names an item not in `items`, the default is not applied and no error is raised.
- **Async item updates**: If `items` changes after a default has fired, the default does not re-fire. A manual `onSelect` can re-apply the selection.
- **Width below minDetailWidth**: If container width is less than `minDetailWidth`, detail pane shows at container width (no horizontal scroll); ancestor columns remain hidden.
- **exitGuard isDirty flip during alert**: If `exitGuard.isDirty` becomes false while the alert is shown, the alert MUST still block the pending action (the guard check happens once, not re-checked while rendering).
- **Pin state on hidden list**: A pinned-disclosed list that is later hidden by width pressure MUST remain pinned (the toggle preserves the intent); when space recovers, the list is re-disclosed.
- **Pointer exit during reveal**: If pointer leaves the menu area while a branch is revealed, the reveal MUST close and the stack MUST re-settle to the configured disclosure style on the next render.
- **Multiple levels with same defaultSelectedId**: Each level applies its own default independently; sharing the same `defaultSelectedId` is valid and not a conflict.

## Configuration

Not applicable: This component has no user-facing configuration options beyond its prop interface. Visual theming (colors, spacing, fonts) is controlled by CSS variables and Tailwind token names (`apt-border`, `apt-gold`, etc.) injected by the host.

## Deep Linking

Not applicable: Deep linking is managed by the host via the `selectedId` values passed to each level. The component renders what the host supplies; URL routing is the host's responsibility.

## Localization

Not applicable: All user-facing strings (button labels, aria-labels, breadcrumb text) are provided by the host as `label` properties in items, `rootLabel`, `trailingCrumbs`, `detailTitle`, and `help`. The component does not generate strings.

## Accessibility Options

Responds to platform accessibility preferences as inherited by React/Web:

| Option | Behavior |
|--------|----------|
| Reduce Motion | Animation transitions (list slides, breadcrumb changes) SHOULD respect `prefers-reduced-motion: reduce` CSS media query. Not implemented in source; requires host wrapping with motion-safe logic or Framer Motion check. |
| Increase Contrast | Focus rings and borders respect applied contrast theme (apt-gold, apt-border). Component does not override or adapt further. |
| Differentiate Without Color | Selection is marked with `aria-current` and text color change; not color-only. MUST pass WCAG 2.1 AA. |

## Feature Flags

Not applicable: No feature flags are present in source. Behavior is controlled entirely by props.

## Analytics

Not applicable: Component does not emit analytics events. The host's `onSelect` and `onClear` callbacks are where selection tracking belongs.

## Privacy

Not applicable: Component does not collect, store, or transmit data. It renders provided props and calls host callbacks.

## Logging

Not applicable: Source includes an internal debug log (cascade-log via `apt:debug:cascade-log` switch) for development; no production logging is implemented.

## Platform Notes

- **React/Web**: Implemented in TypeScript + React with Tailwind CSS (apt-* token colors). Imports lucide-react for icons. Tracks layout state in a module-scoped `Map` (surfaceStates) keyed by root level id to survive re-mounts from route changes. Selectors use `data-htd-col` and `aria-current` to find selected rows for connector paths. No framework-specific behavior beyond React hooks (useCallback, useState, useLayoutEffect, useReducer, useRef, useEffect).
- **Compose (Android)**: Compose equivalent would use a LazyRow for the level columns (or a single pane in narrow mode) with a Column for detail. A Modifier for selection state replaces `aria-current`. Manual state management replaces surfaceStates Map. Three layout modes map to different Arrangement strategies (Row vs Column vs overlay). No direct equivalent to CSS transforms/transitions; use Compose animations and LazyRow scroll + visibility state.
- **UIKit / AppKit (iOS/macOS)**: UIKit port would use a UICollectionView for each level (horizontal scroll, one column per level) or a UINavigationController for narrow mode. Stacking and hiding use views' `isHidden` + `alpha` or removal from hierarchy. Manual state store equivalent to surfaceStates. Selection state in UICollectionViewCell selection model. Accessibility via VoiceOver rotor + custom focus engine. AppKit is similar (NSView hierarchy, NSSplitView for columns).
- **SwiftUI**: SwiftUI would use a ScrollView per level, arranged in an HStack for wide mode or NavigationStack for narrow mode. State stored in a singleton or EnvironmentObject (replacing surfaceStates). Selection managed via @State and @Binding. Connectors drawn with Canvas or overlay Shape. Animations via .transition and .animation. Accessibility via accessibilityElement(children:) and custom accessibility labels.
- **WinUI 3**: WinUI 3 would render ListViews for each level in a horizontal ScrollView (or ContentPresenter for narrow mode). Disclosure styles map to Grid.Column Definitions (collapse/cover/cascade). Selection state via attached properties or a ViewModel (replacing surfaceStates). Visual connectors drawn with Polygon shapes in a Canvas. Theme colors (apt-* tokens) map to ThemeResource references. Keyboard navigation and focus management via Control.TabStop and Focus.FocusManager.

## Design Decisions

1. **Module-scoped state store (surfaceStates)**: Surface state (autoHide, pins, hover reveal, detail hold) outlives component re-mounts caused by route changes (selecting a row). Storing in component state would lose pins/hover/held detail on every selection. The state is keyed by root level id (stable across navigations) and is reset on page reload (correct: a fresh navigation is a fresh start).

2. **Three disclosure styles**: Minimized (icon strips), covered (layered stacks), and cascading (vertical menu nesting) serve different screen sizes and interaction patterns. Minimized suits phones with a Back button. Covered maximizes list visibility without Back. Cascading mimics native menu behavior (hover-reveal nesting).

3. **Manual collapse persists across selections**: Pins live in surfaceStates, not component state, because a select is a route change that re-mounts the component. This lets users keep a list pinned open/closed across multiple selections without fighting the UI.

4. **Default selection uses `{ replace: true }`**: A level's `defaultSelectedId` fires as `onSelect(id, { replace: true })` so the initial auto-selection does not add a history entry. Without `replace: true`, Back would land on the bare parent and immediately re-apply the default, requiring two Back presses to escape.

5. **Exit guard on any selection change**: The guard runs on breadcrumb-up (deselecting shallower levels), sibling swaps at the frontier, or row re-clicks. Any of these can trigger an unsaved-changes alert if the guard is armed.

6. **Lazy connector measurement**: Selection connectors (gold paths between parent and child rows) are measured on-demand via ResizeObserver and re-measured on a short loop while animations play (400ms default). This avoids computing paths that are off-screen or not rendered.

7. **Frontier = deepest rendered level**: The frontier is computed as the first level with no selection (or the last level if all have selections). Only the frontier and levels above it render; levels below the frontier are not rendered at all. This reduces render cost and simplifies the layout math.

## Compliance

Not applicable: No compliance checks are defined in source. Accessibility compliance is addressed in the Accessibility section above (WCAG 2.1 AA via semantic HTML, ARIA, and keyboard navigation).

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | | | Initial creation |
