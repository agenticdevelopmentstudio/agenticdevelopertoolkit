---
id: e626a6fc-0d60-4ba5-a42a-d1849d7e1506
title: Search Dialog Connected
domain: agenticdevelopercookbook://ingredients/search-dialog-connected
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Connected wrapper that binds SearchDialog to the current site's search index,
  navigation, and site config.
platforms:
- typescript
- web
tags:
- search
- dialog
- connected-component
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Search Dialog Connected

## Overview

SearchDialogConnected is a connected wrapper component that provides a SearchDialog instance with data from the application's content, site configuration, and routing context. It derives the search state from a search index, maps section labels from site navigation, and handles selection by navigating to the chosen entry's URL slug and closing the dialog. Use this component to render a fully wired search dialog without manual state management.

## Behavioral Requirements

- **must-accept-forwarded-props**: Component MUST accept and forward all SearchDialogProps except `state`, `onSelect`, and `sectionLabels` as specified by SearchDialogConnectedProps.
- **must-derive-search-state**: Component MUST compute search state by calling `useSearchState(searchIndex)` where searchIndex is obtained from `useContent()`.
- **must-map-section-labels**: Component MUST compute a mapping from section key to section label by iterating `nav.sections` from `useSiteConfig()`.
- **must-handle-selection-with-navigation**: Component MUST handle selection by calling `navigate(entry.slug)` (from `useCurrentRoute()`) and then calling the forwarded `onClose` callback.
- **must-render-search-dialog**: Component MUST render the SearchDialog component with all computed values and forwarded props, passing computed state, mapped sectionLabels, and the selection handler.

## Appearance

Not applicable: SearchDialogConnected is a connected wrapper component that does not define visual appearance. All visual rendering is delegated to the SearchDialog component.

## States

Not applicable: SearchDialogConnected is a stateless connected component that derives all state from hooks. State management is delegated to SearchDialog and the useSearchState hook.

## Accessibility

Not applicable: SearchDialogConnected is a data-connection layer that does not define UI elements. All accessibility concerns are the responsibility of the SearchDialog component that it wraps.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| search-dialog-connected-001 | must-accept-forwarded-props | SearchDialogConnectedProps with custom onClose handler | Component renders SearchDialog with all forwarded props intact |
| search-dialog-connected-002 | must-derive-search-state | Content context provides searchIndex | useSearchState is called with searchIndex and result is passed to SearchDialog as state prop |
| search-dialog-connected-003 | must-map-section-labels | useSiteConfig returns nav with three sections: {key: 'guides', label: 'Guides'}, {key: 'api', label: 'API Reference'}, {key: 'examples', label: 'Examples'} | sectionLabels prop passed to SearchDialog contains {'guides': 'Guides', 'api': 'API Reference', 'examples': 'Examples'} |
| search-dialog-connected-004 | must-handle-selection-with-navigation | User selects entry with slug 'my-page' and component has onClose prop | navigate('my-page') is called, then onClose() is called in sequence |

## Edge Cases

- **Empty sections array**: When nav.sections is empty, sectionLabels MUST be an empty object; SearchDialog receives valid (empty) sectionLabels and renders without error.
- **Null or undefined searchIndex**: When useContent().searchIndex is null or undefined, useSearchState MUST handle the missing index gracefully and component MUST still render SearchDialog without crashing.
- **Missing entry.slug on selection**: This case cannot occur in normal operation because SearchDialog only emits entries from the search state. If the entry object lacks a slug property, navigate() receives undefined and behavior depends on useCurrentRoute implementation.

## Configuration

Not applicable: SearchDialogConnected accepts only pass-through props forwarded to SearchDialog; it does not define its own configuration options.

## Deep Linking

Not applicable: SearchDialogConnected does not handle deep linking directly. Navigation is delegated to the navigate() function from useCurrentRoute(), which is responsible for deep link handling.

## Localization

Not applicable: SearchDialogConnected does not define localized strings. Section labels are sourced from site configuration (nav.sections), and all other text is delegated to SearchDialog.

## Accessibility Options

Not applicable: SearchDialogConnected is a wrapper component with no direct UI elements. All accessibility option handling is delegated to the SearchDialog component.

## Feature Flags

Not applicable: The source code contains no feature flag logic or conditional rendering.

## Analytics

Not applicable: The source code contains no analytics event tracking or telemetry.

## Privacy

Not applicable: SearchDialogConnected is a data-connection component that does not collect, store, or transmit data. Data handling is the responsibility of useSearchState and useContent().

## Logging

Not applicable: The source code contains no logging or debug output.

## Platform Notes

- **React/Web**: SearchDialogConnected is defined in `packages/web/packages/controls/src/search-dialog/SearchDialogConnected.tsx`. It is a client component ('use client'). It uses four hooks from @agenticdevelopertoolkit/model: useContent (for searchIndex), useSiteConfig (for nav.sections), useCurrentRoute (for navigate), and useSearchState (for search state derivation). The sectionLabels are computed once via useMemo to avoid recalculation on every render.
- **SwiftUI**: Start with a view that holds computed @State properties for search state and section labels, similar to a Redux container. Use @State properties for searchIndex and nav.sections obtained from the environment or dependency injection, then derive state using a custom search algorithm and section mapping. Connect the SearchDialog view with these computed values and handle selection by calling a route change function and dismissing the dialog.
- **Compose**: Start with a stateful composable that retrieves searchIndex from a ViewModel or repository via dependency injection, and nav.sections from a SiteConfigRepository. Derive search state and section labels as composables' local state or Composable-cached values. Compose SearchDialog into this container with the computed values. Handle selection by navigating via a provided NavController and dismissing via a mutable state variable.
- **AppKit / UIKit**: Create a view controller or coordinator that manages NSSearchController (macOS) or UISearchController (iOS). Retrieve searchIndex and nav.sections from dependency-injected services. Compute search state and section labels in init() or a setup method. Configure the search results controller delegate to handle selection, then navigate using a provided router and dismiss the dialog.
- **WinUI 3**: Start with an IContentDialog or Dialog subclass that wraps a SearchControl or custom search UI. Use an ObservableCollection for section labels populated from configuration. Bind the search results to an ItemsControl or ListView. Handle the SelectionChanged event to extract the selected item's slug, navigate via a provided INavigationService, and call the dialog's Close() method.

## Design Decisions

The component follows the "connected component" pattern: a presentational SearchDialog component receives all data and callbacks as props, while SearchDialogConnected handles data retrieval and derivation. This separation allows SearchDialog to be reused with different data sources (for testing, alternative content, etc.), while SearchDialogConnected orchestrates the integration with the application's standard data layer. The sectionLabels mapping is computed using useMemo to avoid recalculation when unrelated props change, but is not memoized outside useMemo because the parent may not be memoized. Selection handling calls navigate() before onClose() to ensure navigation state is updated before the dialog disappears.

## Compliance

Not applicable: SearchDialogConnected is a wrapper component for application-level data connection and does not define security, privacy, or compliance-specific behavior.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
