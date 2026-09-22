---
id: 24f42d31-dd5f-4e1e-a95c-3327e136ad46
title: Settings Panel
domain: agenticdevelopercookbook://ingredients/settings-panel
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Multi-pane settings interface with sidebar navigation and grouped section
  support
platforms:
- web
tags:
- settings
- navigation
- tabbed-interface
depends-on: []
related: []
references: []
---

# Settings Panel

## Overview

The Settings Panel is a tabbed navigation component that presents multiple settings panes in a sidebar-and-detail layout. It organizes panes into optional sections, auto-manages pane selection, and supports both controlled (parent-managed state) and uncontrolled (component-managed state) modes. A typical use case is an application settings or preferences interface where users navigate between different setting categories.

## Behavioral Requirements

- **must-render-sidebar**: The component MUST render a navigation sidebar containing all provided panes as selectable items.
- **must-render-detail-area**: The component MUST render a detail area adjacent to the sidebar that displays the body content of the currently selected pane.
- **must-group-panes-by-section**: The component MUST group panes in the sidebar by their optional `section` property. Panes without a section MUST appear first, followed by grouped sections in insertion order.
- **must-render-section-headers**: The component MUST render a visible header for each non-null section name.
- **must-support-controlled-mode**: The component MUST accept a `selectedId` prop; when provided, this prop MUST control which pane is displayed, overriding internal state.
- **must-support-uncontrolled-mode**: The component MUST manage pane selection internally when `selectedId` is not provided.
- **must-auto-select-first-pane**: The component MUST automatically select the first enabled (non-disabled) pane if no pane is currently selected or if the currently selected pane is not in the pane list.
- **must-invoke-onselect-callback**: The component MUST invoke the `onSelect` callback with the pane id whenever a pane is selected, regardless of controlled or uncontrolled mode.
- **must-mark-selected-pane**: The component MUST mark the selected pane button with `aria-selected="true"` and apply a visual indicator (the `--selected` class).
- **must-support-disabled-panes**: The component MUST accept an `isDisabled` flag on each pane; disabled panes MUST NOT be selectable and MUST render with the `--disabled` class.
- **must-prevent-selecting-disabled**: The component MUST NOT allow selection of panes where `isDisabled` is true. Click handlers MUST guard against disabled state.
- **must-render-pane-icon**: The component MUST render an icon span if the pane provides an `icon` property; the icon content MUST come from the icon property as-is (JSX or ReactNode).
- **must-render-pane-title**: The component MUST render the pane `title` text as a label in the sidebar.
- **must-persist-selection**: If a `persistKey` prop is provided, the component MUST persist the selected pane id to `localStorage` under the key `aws-settings:${persistKey}` whenever a pane is selected.
- **must-restore-persisted-selection**: The component MUST restore and apply the persisted pane id from localStorage on mount if `persistKey` is provided and a stored value exists.
- **must-ignore-persist-failures**: The component MUST silently ignore any errors when reading from or writing to localStorage (e.g., due to quota exceeded or disabled storage).
- **must-support-pane-registration**: The component MUST provide a context that allows child `SettingsPanelPane` components to register and unregister themselves dynamically.
- **must-use-registered-panes**: When no explicit `panes` prop is provided, the component MUST use panes registered via the context to populate the sidebar.
- **must-render-children**: When in child-mode (no `panes` prop), the component MUST render children directly instead of generating a default sidebar and detail layout.
- **must-link-tab-to-panel**: Each tab button in the sidebar MUST have `aria-controls` set to the corresponding panel's id (`aws-pane-${paneId}`).
- **must-set-panel-labelledby**: Each detail panel MUST have `aria-labelledby` set to reference the corresponding tab.

## Appearance

- **Sidebar width**: Not specified in source; platform-dependent.
- **Sidebar background**: Not specified in source; platform-dependent.
- **Detail area background**: Not specified in source; platform-dependent.
- **Pane item padding**: Not specified in source; platform-dependent.
- **Font**: Not specified in source; platform-dependent.
- **Icon spacing**: Icon rendered inline in a `aws-panel__sidebar-icon` span adjacent to label text.
- **Section header styling**: Rendered as a div with class `aws-panel__sidebar-section-title`; no default styling specified.
- **Selected state indicator**: Applied via `aws-panel__sidebar-row--selected` class; visual appearance is CSS-driven.
- **Disabled state styling**: Applied via `aws-panel__sidebar-row--disabled` class; platform-specific rendering.

## States

| State | Appearance change |
|-------|------------------|
| Default (unselected) | Rendered without `--selected` class; `aria-selected="false"` |
| Selected | Rendered with `--selected` class; `aria-selected="true"` |
| Disabled | Rendered with `--disabled` class; button has `disabled` attribute; click handler blocked |
| Grouped in section | Rendered within a section container with section header |
| Unsectioned | Rendered before all sectioned panes without a section header |

## Accessibility

- **Role**: The sidebar is a `<nav>` with `aria-label="Settings sections"`. Each pane item is a `<button>` with `role="tab"`. Each detail area is a `<div>` with `role="tabpanel"`.
- **Label requirements**: Each tab button MUST have visible text via the pane `title`. The nav MUST have an `aria-label`. Each tabpanel MUST have an `aria-labelledby` reference to its controlling tab.
- **Keyboard navigation**: Users can tab to each tab button and activate with Enter/Space. Disabled buttons are skipped by tab order.
- **Announce selected state**: Screen readers announce `aria-selected="true"` when a pane is selected.
- **Minimum touch target**: Not specified in source. Platform guidelines MUST be followed (44×44pt on iOS, 48×48dp on Android, 40×40px on web per WCAG).
- **Icon semantics**: Icons MUST NOT be the only indicator of pane purpose. A visible `title` label MUST always be present.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| panel-001 | must-render-sidebar | `panes=[{id:'a',title:'A'}]` | Sidebar renders with one selectable item labeled 'A' |
| panel-002 | must-render-detail-area | `panes=[{id:'a',title:'A',body:'Content'}]` with selection='a' | Detail area renders with text 'Content' |
| panel-003 | must-group-panes-by-section | `panes=[{id:'a',title:'A',section:null},{id:'b',title:'B',section:'Group1'}]` | Pane 'A' appears first; 'B' appears under 'Group1' header |
| panel-004 | must-support-controlled-mode | `panes=[...], selectedId='b', onSelect=jest.fn()` | When user clicks pane 'b', `onSelect('b')` is called |
| panel-005 | must-support-uncontrolled-mode | `panes=[...]` without `selectedId` | Component manages internal state; first pane auto-selected |
| panel-006 | must-auto-select-first-pane | `panes=[{id:'a',isDisabled:true},{id:'b',isDisabled:false}]` | Pane 'b' is auto-selected, not 'a' |
| panel-007 | must-mark-selected-pane | Selection is pane 'a' | Button for pane 'a' has `aria-selected="true"` and `--selected` class |
| panel-008 | must-support-disabled-panes | `panes=[{id:'a',isDisabled:true}]`, user clicks pane 'a' | Pane 'a' not selected; selection unchanged |
| panel-009 | must-persist-selection | `persistKey='my-settings', selectedId='a'` | localStorage contains `aws-settings:my-settings='a'` |
| panel-010 | must-restore-persisted-selection | localStorage has `aws-settings:my-settings='b'`, `panes=[{id:'a'},{id:'b'}]` | On mount, pane 'b' is selected |
| panel-011 | must-ignore-persist-failures | localStorage.getItem throws or quota exceeded | Component still renders and functions; no error thrown |
| panel-012 | must-support-pane-registration | Child `SettingsPanelPane` mounts and registers | Pane appears in sidebar immediately |
| panel-013 | must-render-children | `children=<div>Custom</div>` without `panes` | Custom div is rendered; default sidebar/detail not rendered |
| panel-014 | must-link-tab-to-panel | Pane with id='a' selected | Tab button has `aria-controls="aws-pane-a"`, panel has `id="aws-pane-a"` |
| panel-015 | must-invoke-onselect-callback | User selects pane 'b' | `onSelect('b')` is called exactly once |

## Edge Cases

- **No panes provided**: When `panes` array is empty or not provided and no child panes register, the component renders an empty sidebar and no detail area. No error is thrown.
- **All panes disabled**: When all panes have `isDisabled: true`, no pane is auto-selected. Attempting to click any pane has no effect.
- **Current selection no longer exists**: When `panes` changes and the currently selected pane id is not in the new list, the first enabled pane is auto-selected.
- **Controlled mode with missing pane**: When `selectedId` references a pane that does not exist, no pane is displayed. The detail area is empty but still rendered.
- **localStorage unavailable**: In SSR or private browsing contexts where localStorage access throws, errors are silently caught. Persistence is skipped but the component functions normally.
- **Null section name**: Panes with `section: null` or `section: undefined` are treated identically as unsectioned and grouped together at the start.
- **Empty section name**: Panes with `section: ''` (empty string) are treated as a named section with an empty header displayed.
- **Pane without icon**: When a pane does not provide an `icon` property, the icon span is not rendered. Only the label is shown.
- **Rapid selection changes**: When `selectPane` is called multiple times in quick succession, each call invokes `onSelect` and updates `localStorage`. The most recent call wins.
- **Child Pane re-registration**: When a child `SettingsPanelPane` component re-registers with different props (e.g., title changes), the pane is removed and re-added to maintain uniqueness.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `panes` | `SettingsPaneEntry[]` | `undefined` | Array of pane descriptors for data-driven mode. Each entry has `id`, `title`, `icon?`, `section?`, `isDisabled?`, `body?`. Mutually exclusive with child-mode. |
| `defaultPaneId` | `string` | `undefined` | The pane id to select on mount if no persisted selection exists and not in controlled mode. |
| `selectedId` | `string` | `undefined` | The controlled pane id. When provided, overrides internal state and auto-selection. |
| `onSelect` | `(id: string) => void` | `undefined` | Callback invoked whenever a pane is selected, in both controlled and uncontrolled modes. |
| `persistKey` | `string` | `undefined` | If provided, the selected pane id is persisted to `localStorage` under `aws-settings:${persistKey}`. |
| `className` | `string` | `undefined` | Additional CSS class to add to the root element alongside the base `aws-panel` class. |
| `sidebarTitle` | `string` | `undefined` | Optional title displayed at the top of the sidebar. Can be overridden per render via `SettingsPanelSidebar`'s `title` prop. |

## Deep Linking

Not applicable: This component is a UI shell that does not intrinsically handle deep linking. Applications using this component MUST implement their own URL-to-pane-selection mapping by listening to `onSelect` and storing/restoring state as needed.

## Localization

| String Key | Default (en) | Context |
|-----------|-------------|---------|
| (nav aria-label) | `"Settings sections"` | Accessible label for the sidebar navigation |
| (pane title) | (user-provided) | Each pane `title` property is user-provided and should be localized by the caller |
| (sidebar title) | (user-provided) | The `sidebarTitle` prop is user-provided and should be localized by the caller |
| (section name) | (user-provided) | Each pane `section` property is user-provided and should be localized by the caller |

## Accessibility Options

- **Reduce Motion**: Not applicable. This component does not animate state transitions; selection changes are instantaneous visual updates.
- **Increase Contrast**: Not applicable. The component does not define color tokens; styling is CSS-driven and must follow platform contrast guidelines.
- **Differentiate Without Color**: Not applicable. Selection is indicated by both color (via `--selected` class) and the `aria-selected` attribute; visual distinction does not rely on color alone.

## Feature Flags

| Flag Key | Default | Description |
|----------|---------|-------------|
| (none specified in source) | — | This component does not check feature flags; flag control is the caller's responsibility. |

## Analytics

| Event | Properties | When |
|-------|-----------|------|
| (not implemented) | — | The component does not emit analytics events; event tracking is the caller's responsibility via the `onSelect` callback. |

## Privacy

- **Data collected**: None. The component does not collect user data.
- **Storage**: Selection persistence (if `persistKey` is provided) is written to the browser's localStorage as a plain string (the pane id).
- **Transmission**: No data is transmitted. Selection state remains on-device only.
- **Retention**: Persisted selection remains in localStorage indefinitely until explicitly cleared or the user clears browser storage.

## Logging

Subsystem: (not specified in source) | Category: (not specified in source)

Not applicable: This component does not emit log messages. Application code integrating this component may add logging via the `onSelect` callback.

## Platform Notes

- **React/Web**: The source is a React functional component using hooks (`useState`, `useContext`, `useCallback`, `useMemo`, `useRef`, `useEffect`). It provides a compound component pattern via `Object.assign`, with `SettingsPanel.Sidebar` and `SettingsPanel.Pane` as sub-components. Styling is class-based (`aws-panel`, `aws-panel__sidebar`, etc.); CSS must be provided separately. Context (`SettingsPanelContext`) is used for state sharing between root, sidebar, and child panes.
- **SwiftUI**: An equivalent implementation would use a `@State` property for selected pane id, a `@StateObject` to manage pane registration, and SwiftUI's `List` or `Form` with `Picker` or `NavigationStack` for the tabbed sidebar-detail pattern. Persistence would use `@AppStorage` for localStorage equivalence.
- **Compose**: An equivalent would use `rememberSaveable` for persistent selection state, a `mutableStateListOf` for pane registration, and `LazyColumn` for the sidebar list. Grouping by section would be handled by grouping the pane list before rendering. Selected state would drive `NavigationRail` or a custom sidebar composable.
- **AppKit / UIKit**: An equivalent would use `NSViewController` hierarchy with a split view controller (macOS) or container view controller (iOS) managing a sidebar and detail view. Selection state would be tracked as a published property in a view model. Pane registration would use a delegate or observer pattern for dynamic panes. Persistence would use `UserDefaults` keyed to the persist key.
- **WinUI 3**: An equivalent would use a XAML split pane control (`SplitView`) or a two-column `Grid` layout. The sidebar would be a `ListView` or `NavigationView` with pane items bound via a collection view model. Selection state would be a property in the code-behind or ViewModel. Grouping by section would be handled via `CollectionViewSource` with grouping enabled. Persistence would use `ApplicationData.Current.LocalSettings` or `StorageFile`. The detail area would be a `Frame` or `ContentPresenter` bound to the selected pane's body content.

## Design Decisions

1. **Auto-selection of first enabled pane**: The component automatically selects the first non-disabled pane when no selection exists or the current selection is gone. This prevents a state where no content is displayed, ensuring a valid state is always active. This behavior applies in both controlled and uncontrolled modes.

2. **Unsectioned panes appear first**: Panes without a section are grouped at the start of the sidebar, followed by named sections in insertion order. This prioritizes ungrouped content and provides a consistent structure for sidebar organization.

3. **Silent localStorage failures**: Read and write operations to localStorage are wrapped in try-catch blocks. Errors (quota exceeded, access denied, private browsing) are silently ignored. This ensures the component remains functional even when persistence is unavailable, rather than throwing and breaking the UI.

4. **Pane uniqueness by id**: The `registerPane` function filters out any existing pane with the same id before adding a new one. This allows child panes to re-register with updated props (e.g., title change) without duplication.

5. **Controlled mode takes precedence**: When `selectedId` is provided, it overrides internal state and auto-selection. The component does not update `internalSelected` in controlled mode. This ensures parent control is predictable and reliable.

6. **Callback always invoked**: The `onSelect` callback is invoked on every pane selection, regardless of controlled or uncontrolled mode. This allows parents to track selection changes and is essential for analytics and external state synchronization.

7. **aria-controls link**: Each tab button explicitly links to its corresponding panel via `aria-controls` and the panel sets `aria-labelledby` to establish a semantic relationship. This provides assistive technology with clear tab-panel associations.

## Compliance

Not applicable: This component has no security, authentication, or compliance requirements. Its use context (settings management) does not involve sensitive data handling or regulatory constraints by default.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | (pending) | Initial creation from React SettingsPanelRoot source |
