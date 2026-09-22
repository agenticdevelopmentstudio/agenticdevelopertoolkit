---
id: 8d76adce-493b-4e44-9b15-826c4899d3cd
title: ConnectorAnchor
domain: agenticdevelopercookbook://ingredients/connector-anchor
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Registration point for visual connectors in multi-pane layouts; invisible
  to end users.
platforms:
- web
tags: []
depends-on: []
related: []
references: []
---

# ConnectorAnchor

## Overview

ConnectorAnchor is a registration anchor for visual connectors that link UI elements across a three-pane or multi-pane layout. The component renders as an invisible span that registers its DOM reference with a shared connector registry, enabling external connector logic to query anchor positions and draw lines or other visual connections between designated points. The component is not visible to end users or assistive technologies.

## Behavioral Requirements

- **must-render-as-span**: Component MUST render as an HTML `<span>` element.
- **must-accept-id**: Component MUST accept a required string `id` prop that uniquely identifies the anchor point.
- **must-register-with-registry**: Component MUST register its DOM reference with the connector registry using the provided `id` when the component mounts.
- **must-return-null-if-no-registry**: Component MUST render nothing (return null) when the connector registry is not available.
- **must-set-data-connector-anchor**: Component MUST set a `data-connector-anchor` HTML attribute with the value of the `id` prop.
- **must-be-aria-hidden**: Component MUST set `aria-hidden="true"` on the rendered element to hide it from assistive technologies.
- **should-accept-classname**: Component SHOULD accept an optional `className` prop to allow consumers to apply additional CSS classes.
- **should-support-class-composition**: Component SHOULD concatenate the base class `pc-connector-anchor` with any provided `className` when both are present.
- **must-unregister-on-unmount**: Component MUST unregister from the connector registry when the component unmounts or when dependencies change, if the registry provides an unregister or cleanup mechanism.
- **must-re-register-on-id-change**: Component MUST re-register with the connector registry when the `id` prop changes.

## Appearance

- **Display**: Invisible; no visual rendering beyond DOM element creation.
- **Element**: Inline `<span>` element with no default width, height, padding, margin, or border.
- **Background**: Transparent (no background color applied).
- **Text content**: None; element is empty.
- **CSS class**: Base class `pc-connector-anchor` is always applied; additional classes from `className` prop are appended.

## States

| State | Appearance change |
|-------|------------------|
| Default | Invisible span with data attribute and aria-hidden. |
| Registry unavailable | Component is not rendered (returns null). |

## Accessibility

Not applicable: This component is explicitly hidden from assistive technologies via `aria-hidden="true"` and serves as an internal layout anchor, not as a user-facing control.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| connector-anchor-001 | must-render-as-span | Component rendered with id="point-a", registry available | DOM contains `<span>` element. |
| connector-anchor-002 | must-accept-id | id="my-anchor" | Component's `id` state matches "my-anchor". |
| connector-anchor-003 | must-register-with-registry | Component mounted with id="test", registry available | Registry's register method called with id="test" and the span's DOM reference. |
| connector-anchor-004 | must-return-null-if-no-registry | Component mounted, registry unavailable (hook returns null) | Component renders nothing; no DOM elements created. |
| connector-anchor-005 | must-set-data-connector-anchor | id="anchor-1" | Rendered span has attribute `data-connector-anchor="anchor-1"`. |
| connector-anchor-006 | must-be-aria-hidden | Component rendered | Rendered span has attribute `aria-hidden="true"`. |
| connector-anchor-007 | should-accept-classname | className="custom-class" | Component accepts the prop without error. |
| connector-anchor-008 | should-support-class-composition | className="custom-class" | Rendered span's class attribute is "pc-connector-anchor custom-class". |
| connector-anchor-009 | should-support-class-composition | className undefined | Rendered span's class attribute is "pc-connector-anchor". |
| connector-anchor-010 | must-re-register-on-id-change | id changes from "old-id" to "new-id" | Registry's register method called with "new-id" when id prop updates. |
| connector-anchor-011 | must-return-null-if-no-registry | First render, registry unavailable; then registry becomes available | Component returns null initially; does not re-render when registry becomes available within same component instance lifecycle. |

## Edge Cases

- **No registry available on mount**: Component returns null and renders nothing. No error is thrown.
- **Registry available but ref is not ready**: The effect checks `!ref.current` and returns early; no registration occurs until ref is available.
- **Registry dependency changes while registry is null**: Component re-evaluates effect but continues returning null.
- **id prop is empty string**: Component will register with an empty string id. The behavior of duplicate or empty ids is undefined; the source does not validate id uniqueness or non-emptiness.
- **className is empty string**: Component appends the empty string; class attribute becomes "pc-connector-anchor ".
- **className is whitespace**: Component concatenates whitespace; multiple spaces may appear in the class string.
- **Component unmounts immediately after mount**: If registration provides a cleanup function (via return value of `reg.register()`), that function is called on unmount.
- **Rapid id changes**: Effect re-runs for each id change; multiple register calls may occur with different ids if changes happen before the first registration completes.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `id` | string | required | The unique identifier for this anchor point; used to register with and query from the connector registry. |
| `className` | string | optional | Additional CSS classes to append to the base `pc-connector-anchor` class. |

## Deep Linking

Not applicable: ConnectorAnchor is an internal anchor point used for layout calculations and does not correspond to a navigable route or deep-linkable destination.

## Localization

Not applicable: ConnectorAnchor renders no user-visible text and has no localized strings.

## Accessibility Options

Not applicable: ConnectorAnchor is hidden from assistive technologies and does not respond to accessibility display options.

## Feature Flags

Not applicable: The source code contains no feature flag conditionals.

## Analytics

Not applicable: The source code contains no analytics event emission.

## Privacy

Not applicable: ConnectorAnchor does not collect, store, or transmit personal or user data; it is a layout anchor only.

## Logging

Not applicable: The source code contains no logging statements.

## Platform Notes

- **Web (React)**: Implement using the React `<span>` element. Use `useRef` to capture the DOM reference and `useEffect` with dependency array `[id, reg]` to register when both become available. Use optional chaining or conditional checks to guard against null registry. Render nothing (return null) when registry is unavailable. Apply classes by string concatenation; no CSS-in-JS framework is required. The `useConnectorRegistryOptional` hook is the registry provider — ensure it is available in scope.

- **SwiftUI**: Implement as a lightweight view (ZStack or plain View) that registers itself with an environment-injected connector registry on appear. Use an `@Environment` property to access the registry; if unavailable, render `EmptyView()`. Store the view's frame using `GeometryReader` and pass it to the registry's register method. Unregister on disappear or when the `id` changes.

- **Compose**: Implement as a composable that accepts `id` and optional `Modifier`. Use `LaunchedEffect(id, registry)` to register with the registry on composition. Access the registry via `LocalConnectorRegistry.current`; if unavailable, render nothing. Store the composable's position using `onGloballyPositioned` and pass the coordinates to the registry. Unregister via cleanup in `LaunchedEffect`.

- **AppKit / UIKit**: Implement as a view (NSView or UIView subclass) that registers its frame with a shared connector registry on initialization or `viewDidAppear`. Store the registry as a weak property or access it via a shared singleton. If the registry is unavailable, initialize the view but do not render visibly. Store the view's bounds or center coordinates and pass them to the registry's register method. Clean up on `deinit` or `viewWillDisappear`.

- **WinUI 3**: Implement as a XAML-less code-behind control (C#) that inherits from `UserControl` or `FrameworkElement`. Accept `Id` (string) and optional `Style` properties via DependencyProperty. In `OnApplyTemplate` or `Loaded` event, query `ConnectorRegistry.Current` and call its `Register(id, element)` method, passing the control itself. If registry is unavailable, the control remains loaded but inactive. Unregister in the `Unloaded` event. Arrange as zero-size or minimal-size to avoid occupying layout space; use `Visibility.Collapsed` if visual rendering is undesired.

## Design Decisions

The component returns null when the registry is unavailable rather than rendering an empty span. This prevents anchor points from being created in contexts where the connector registry is not available, ensuring a hard error or visible absence rather than silent registration failure. The registration is side-effect based (via `useEffect`) rather than declarative, matching React's functional component patterns. The effect dependency array `[id, reg]` causes re-registration when either changes, which matches the source code's implementation.

## Compliance

Not applicable: No compliance checks are defined for this component at this time.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | | Initial creation |
