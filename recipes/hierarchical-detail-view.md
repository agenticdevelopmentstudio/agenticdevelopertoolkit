---
id: 8ce108f2-b64b-4e01-8dbb-94ef3397b46a
title: Hierarchical Detail View
domain: agenticdevelopercookbook://ingredients/hierarchical-detail-view
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Context-driven switch between hierarchical menu and topic detail view implementations
platforms:
- typescript
- web
tags:
- layout
- navigation
- context
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Hierarchical Detail View

## Overview

Hierarchical Detail View is a context provider and routing component that selects between two hierarchical detail view implementations — a cascading menu view and a classic topic view — at the application level. It allows consumers throughout the component tree to render the same logical interface with different disclosure patterns by reading a context value, rather than threading a configuration prop through multiple layers.

The component consists of three exports: a provider component that establishes the context, a hook to read the current view choice, and a router component that consumers render in place of choosing between the two implementations directly.

## Behavioral Requirements

- **must-provide-context-value**: The `HierarchicalDetailViewProvider` MUST establish a React Context with the `menuDetail` boolean value provided via the `menuDetail` prop.
- **must-default-to-false**: When no `HierarchicalDetailViewProvider` is rendered, the context MUST default to `false` (classic topic view).
- **must-route-to-menu-detail**: When context value is `true`, `HierarchicalDetailView` MUST render the `HierarchicalMenuDetail` component and pass all props to it.
- **must-route-to-topic-detail**: When context value is `false`, `HierarchicalDetailView` MUST render the `HierarchicalTopicDetail` component.
- **must-map-cascading-style**: When `disclosureStyle: "cascading"` is passed and context value is `false`, `HierarchicalDetailView` MUST pass `disclosureStyle: "covered"` to `HierarchicalTopicDetail`.
- **must-ignore-cascade-only-props**: When context value is `false`, `HierarchicalDetailView` MUST not pass cascade-only props (`disclosureStyle: "cascading"` and `autoHideTopics`) to `HierarchicalTopicDetail`; these props MUST be filtered or reconciled.
- **must-preserve-other-props**: All props other than `disclosureStyle` MUST be passed unmodified to the rendered detail view component.
- **must-return-context-value**: The `useHierarchicalMenuDetailView()` hook MUST return the current context value (a boolean).

## Appearance

Not applicable: Hierarchical Detail View is a context provider and routing container with no visual rendering of its own. Visual appearance is determined entirely by the underlying detail view component selected.

## States

Not applicable: Hierarchical Detail View is a routing and context component with no interactive states or visual modes of its own.

## Accessibility

Not applicable: Accessibility is the responsibility of the detail view components (`HierarchicalMenuDetail` and `HierarchicalTopicDetail`) rendered by this router. This component does not introduce interactive controls or visual elements that require accessibility annotations.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| hdv-001 | must-provide-context-value | Render `HierarchicalDetailViewProvider` with `menuDetail={true}` | Context value is `true` |
| hdv-002 | must-default-to-false | Render `HierarchicalDetailView` without a provider | Context reads as `false` via `useHierarchicalMenuDetailView()` |
| hdv-003 | must-route-to-menu-detail | Render `HierarchicalDetailView` with context value `true` | Renders `HierarchicalMenuDetail` component |
| hdv-004 | must-route-to-topic-detail | Render `HierarchicalDetailView` with context value `false` | Renders `HierarchicalTopicDetail` component |
| hdv-005 | must-map-cascading-style | Pass `disclosureStyle: "cascading"` to `HierarchicalDetailView` with context value `false` | Underlying `HierarchicalTopicDetail` receives `disclosureStyle: "covered"` |
| hdv-006 | must-ignore-cascade-only-props | Pass `autoHideTopics={true}` to `HierarchicalDetailView` with context value `false` | Underlying `HierarchicalTopicDetail` does not receive `autoHideTopics` or ignores it |
| hdv-007 | must-preserve-other-props | Pass `levels={[...]}` and `detail={{...}}` to `HierarchicalDetailView` | Underlying view component receives these props unmodified |
| hdv-008 | must-return-context-value | Call `useHierarchicalMenuDetailView()` inside `HierarchicalDetailViewProvider` with `menuDetail={false}` | Hook returns `false` |

## Edge Cases

- **No provider mounted**: When `useHierarchicalMenuDetailView()` is called without a `HierarchicalDetailViewProvider` ancestor, the hook MUST return the default context value `false` without error.
- **Cascading prop without cascading context**: When a consumer passes `disclosureStyle: "cascading"` while context is `false`, the component MUST map it to `disclosureStyle: "covered"` to avoid passing an invalid prop to `HierarchicalTopicDetail`.
- **autoHideTopics in topic view**: When a consumer passes `autoHideTopics` while context is `false`, the underlying `HierarchicalTopicDetail` MUST either ignore the prop or it MUST be filtered out before rendering.
- **Superset prop compatibility**: Since `HierarchicalMenuDetail`'s prop interface is a superset of `HierarchicalTopicDetail`'s, all props valid for the topic view MUST also be valid when the menu view is active and MUST be passed through unmodified.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `menuDetail` | `boolean` | `false` | Passed to `HierarchicalDetailViewProvider` to select the cascading menu view (`true`) or classic topic view (`false`) |
| `children` | `ReactNode` | — | Child components to render within the provider context |

## Deep Linking

Not applicable: Hierarchical Detail View is a context provider and routing component with no URL patterns or navigation destinations of its own. Deep linking is handled by the detail view components it routes to.

## Localization

Not applicable: Hierarchical Detail View does not render user-facing strings and introduces no localizable content.

## Accessibility Options

Not applicable: Hierarchical Detail View is a routing and context component that does not render interactive controls or visual elements that respond to accessibility display options. Accessibility concerns are delegated to the detail view components it routes to.

## Feature Flags

| Flag Key | Default | Description |
|----------|---------|-------------|
| `use_hierarchical_menu_details_view` | `false` | Applications MAY wire this feature flag to the `menuDetail` prop of `HierarchicalDetailViewProvider` to enable the cascading menu view for A/B testing or gradual rollout |

## Analytics

Not applicable: Hierarchical Detail View is a routing and context component with no user interactions or events of its own. Analytics events are generated by the detail view components it selects.

## Privacy

Not applicable: Hierarchical Detail View does not collect, store, or transmit any data.

## Logging

Not applicable: Hierarchical Detail View is a routing and context component with no internal state changes, error conditions, or operations requiring logs.

## Platform Notes

- **React/Web**: Implemented in `packages/web/packages/ui/src/blocks/hierarchical-detail-view.tsx` using React Context API (`createContext`, `useContext`). The provider establishes the context value; `HierarchicalDetailView` consumes it with `useHierarchicalMenuDetailView()` and conditionally renders the two detail components. Prop mapping for `disclosureStyle` and filtering of cascade-only props occurs within the component's render logic.
- **Compose**: Similar to React, Kotlin Compose provides a CompositionLocal API for context-like behavior. Implement a CompositionLocal to store the boolean view choice, provide it via a Composable provider function, and create a composable that reads the local to conditionally render the menu or topic detail composable. Map and filter props at the composition level.
- **SwiftUI**: Implement using SwiftUI's EnvironmentKey protocol to create a custom environment value for the view choice boolean. Create a ViewModifier or custom modifier to provide this value to descendants. The main view reads the environment value and conditionally renders the two detail views. Handle prop mapping and filtering via view builder logic or separate functions.
- **AppKit / UIKit**: Implement as a container view controller or custom view that reads the view choice from NSUserDefaults, a singleton app state object, or a custom delegate. Use conditional view controller/view presentation to render the appropriate detail view. Handle prop mapping and filtering in the delegation or initialization logic.
- **WinUI 3**: Implement as a custom UserControl that reads a view choice boolean from an attached property, application resources, or a view model bound to the control. Use conditional rendering (if/else in code-behind or binding converters in XAML) to conditionally instantiate the menu detail or topic detail control and bind all props to the selected control. Handle disclosureStyle mapping and autoHideTopics filtering via a value converter or helper method before binding props.

## Design Decisions

- **Context over props:** Configuration is read from React Context rather than passed as props because many hierarchical detail stacks are rendered by internal components (ResourceExplorer, CrudDataBrowser, ApiBrowser, persona sections) several layers below application code. Threading a boolean through all intermediate layers would require changes at every call site and defeat the purpose of centralizing the choice. The context approach centralizes the decision at the provider level and makes it transparent to consumers.

- **Default to false:** The context defaults to `false` (classic topic view) to preserve backward compatibility. Existing applications that mount no provider continue to render the classic view, and the menu view is activated only by deliberately mounting a provider or wiring a feature flag. This ensures the toolkit remains flag-agnostic and does not change behavior for existing users.

- **Cascading-to-covered mapping:** When a consumer passes `disclosureStyle: "cascading"` to the router component and the context is `false`, the component maps it to `disclosureStyle: "covered"`. This graceful degradation prevents passing an invalid prop to `HierarchicalTopicDetail` and provides a reasonable fallback: the covered style borrows the cascade's rules for covering, pins, and hover reveal, so it approximates the cascade's visual behavior without the vertical step unique to the menu view.

- **autoHideTopics ignored in topic view:** The `autoHideTopics` prop is cascade-only and has no meaning in the classic topic view. When the context is `false`, this prop is carried along in the destructured rest props but `HierarchicalTopicDetail` simply ignores unknown props rather than throwing an error. This allows consumers to pass superset props without conditional logic.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| No review markers. | Passed | Recipe Quality |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation |
