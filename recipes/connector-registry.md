---
id: e5b8e26f-2869-4a09-8d8e-0bb68ece805d
title: Connector Registry
domain: agenticdevelopertoolkit://recipes/connector-registry
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Registry for tracking and querying HTML element instances by unique identifier
  within a React application.
platforms:
- typescript
- web
tags:
- context-provider
- registry
- react
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Connector Registry

## Overview

The Connector Registry is a React context-based store for managing references to DOM elements within a component tree. It allows any descendant component to register and query element instances by string identifier, with automatic notification of subscribers when the registry changes. This enables coordination between components that need to discover or reference each other's elements at runtime without direct coupling.

## Behavioral Requirements

- **must-provide-context**: The registry MUST be provided to descendant components via React Context (`ConnectorRegistryProvider`).
- **must-register-elements**: The registry MUST accept registration of an HTML element with a unique string identifier via the `register(id, element)` method.
- **must-return-unregister-function**: The `register()` method MUST return a function that unregisters the element when called.
- **must-prevent-duplicate-registration**: If an element with the same id is registered a second time with the identical element reference, the method MUST return an empty function that performs no action on invocation.
- **must-update-registry-on-change**: Registering or unregistering an element MUST notify all active subscribers immediately.
- **must-provide-snapshot**: The registry MUST provide a `snapshot()` method that returns a current `RegistrySnapshot` object containing the full registry state.
- **must-implement-subscription**: The registry MUST support subscription to changes via the `subscribe(listener)` method, which MUST return an unsubscribe function.
- **must-expose-has-method**: A `RegistrySnapshot` MUST provide a `has(id)` method that returns a boolean indicating whether an id exists in the registry.
- **must-expose-get-method**: A `RegistrySnapshot` MUST provide a `get(id)` method that returns the registered element or `undefined` if the id is not present.
- **must-expose-ids-method**: A `RegistrySnapshot` MUST provide an `ids()` method that returns an array of all registered identifiers in the registry.
- **must-throw-without-provider**: The `useConnectorRegistry()` hook MUST throw an error if called outside the scope of a `ConnectorRegistryProvider`.
- **must-provide-optional-hook**: A `useConnectorRegistryOptional()` hook MUST be available that returns the registry handle or `null` if no provider is present.
- **must-provide-snapshot-hook**: A `useRegistrySnapshot()` hook MUST be available that returns the current snapshot and MUST automatically subscribe to updates, re-rendering the component on registry changes.

## Appearance

Not applicable: This ingredient is a functional context provider with no visual representation.

## States

Not applicable: The registry is a stateful container but does not model user-facing states (default, pressed, etc.).

## Accessibility

Not applicable: The registry is a programmatic utility layer with no direct user interaction or accessible UI elements.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| registry-001 | must-provide-context, must-register-elements | Render ConnectorRegistryProvider; register element with id="btn1" and an HTMLElement | Element is stored in registry with id "btn1" |
| registry-002 | must-return-unregister-function | Call register("btn1", element); invoke the returned function | Element is removed from registry; subsequent get("btn1") returns undefined |
| registry-003 | must-prevent-duplicate-registration | Call register("btn1", el); call register("btn1", el) again with same reference | Second call returns function that does nothing; registry state unchanged |
| registry-004 | must-update-registry-on-change | Register element; pass subscriber to subscribe() | Subscriber is called immediately after registration and again after unregistration |
| registry-005 | must-provide-snapshot | Call snapshot() immediately after registering element with id="btn1" | snapshot.has("btn1") returns true; snapshot.get("btn1") returns the element |
| registry-006 | must-expose-ids-method | Register elements with ids "btn1" and "btn2"; call snapshot().ids() | Returns array containing both "btn1" and "btn2" |
| registry-007 | must-throw-without-provider | Call useConnectorRegistry() in a component not wrapped by ConnectorRegistryProvider | Hook throws error with message containing "ConnectorRegistryProvider" |
| registry-008 | must-provide-optional-hook | Call useConnectorRegistryOptional() outside provider; call again inside provider | First call returns null; second call returns the registry handle |
| registry-009 | must-provide-snapshot-hook | Use useRegistrySnapshot() inside provider and subscribe to its changes | Hook returns current snapshot; component re-renders when registry changes |

## Edge Cases

- **Empty registry**: An initial `snapshot().ids()` on a fresh provider MUST return an empty array; `has(id)` and `get(id)` MUST return false and undefined respectively.
- **Unregister with mismatched reference**: If `register("btn1", elA)` is called, then the returned function is stored and later invoked after `register("btn1", elB)` is called with a different element, the function MUST NOT unregister elB (it should only unregister if the current element still matches elA).
- **Subscribe after registry populated**: A subscriber added after elements are already registered MUST be called once immediately (to sync state), then on all subsequent changes.
- **Unsubscribe during notification**: If a listener unsubscribes itself while a notification is in progress, the unsubscription MUST be honored for the next notification cycle.
- **Multiple registrations with null or undefined id**: The source does not explicitly validate id values; behavior with falsy ids (null, undefined, empty string) is not documented in the source and MUST be tested by implementors.
- **Null or undefined element reference**: The source accepts any HTMLElement reference; behavior when passing null or undefined is not validated by the source.

## Configuration

Not applicable: The registry is instantiated by the provider with no configuration options.

## Deep Linking

Not applicable: The registry is a programmatic utility with no URL-based navigation.

## Localization

Not applicable: The registry contains only HTML element references and id strings; no user-facing strings require localization.

## Accessibility Options

Not applicable: The registry is a functional utility layer with no response to platform accessibility display options.

## Feature Flags

Not applicable: The registry is a core utility component with no feature flag gating in the source.

## Analytics

Not applicable: The source code contains no analytics instrumentation or event emission.

## Privacy

Not applicable: The registry stores only references to DOM elements already present in the application; it does not collect, transmit, or retain personal data.

## Logging

Not applicable: The source code contains no logging statements or diagnostic output.

## Platform Notes

- **Source platform (web, React)**: Implemented in `packages/web/packages/chat/src/modes/three-pane/connectors/ConnectorRegistry.tsx` as a context provider using React hooks (`useRef`, `useContext`, `useMemo`, `useSyncExternalStore`), a `Map` to store id-to-element mappings, and a `Set` to track listeners.
- **SwiftUI**: Implement as an `@StateObject` or environment object providing a class with `register()`, `snapshot()`, and `subscribe()` methods; use `@Published` for reactive updates or `Combine`'s `PassthroughSubject` for subscriber notifications.
- **Compose**: Implement as a `CompositionLocal` providing a registry class with thread-safe access (kotlin.synchronized or Mutex); emit recomposition signals via `SnapshotMutationPolicy` or Compose's state observation.
- **AppKit / UIKit**: Implement as a singleton or `NSObject` subclass with delegate pattern or closure callbacks for notifications; use `NSMapTable` or `Dictionary` for id-to-view storage; integrate with view lifecycle to auto-unregister on view deallocation.
- **WinUI 3**: Implement as a static class or DependencyObject with a `Dictionary<string, UIElement>` backing store; use `INotifyPropertyChanged` or event-based notifications for subscribers; expose methods `Register(id, element)` and `GetSnapshot()` returning a read-only snapshot; bind to XAML via attached behavior or custom panel if needed.

## Design Decisions

- **Snapshot pattern**: The registry returns an immutable snapshot of its state rather than a live reference to the underlying Map. This prevents external mutation of the registry state and ensures that subscriber notifications reflect a consistent view. The snapshot is rebuilt on every state change.
- **Re-registration idempotency**: If the same element reference is registered with the same id twice, the second registration is a no-op and returns an empty function. This prevents unnecessary subscriber notifications when a component re-registers itself unnecessarily.
- **Subscriber notification order**: Subscribers are notified synchronously immediately after state changes. The snapshot is computed before listeners are called, ensuring all listeners see the same snapshot state.
- **useSyncExternalStore hook**: `useRegistrySnapshot()` uses React's `useSyncExternalStore` to integrate the external registry store with React's rendering cycle, ensuring hydration safety and consistent snapshots across concurrent rendering.

## Compliance

Not applicable: No external compliance standards (WCAG, etc.) apply to a programmatic utility component.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation |
