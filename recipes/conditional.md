---
id: f361ebe1-69b9-4089-8079-94f4b26a37d3
title: Conditional
domain: agenticdevelopercookbook://ingredients/conditional
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Renders one of two content branches based on a boolean condition.
platforms:
- web
- kotlin
- swift
- typescript
tags:
- conditional
- branching
- rendering
depends-on: []
related: []
references: []
---

# Conditional

## Overview

The Conditional component renders either its `children` or `fallback` content based on the value of the `when` boolean prop. It is a simple, stateless branching component that wraps React's fragment syntax to conditionally display content. Use this component when you need inline conditional rendering without creating an extra DOM node or wrapper element.

## Behavioral Requirements

- **render-children-when-true**: Component MUST render the `children` prop when the `when` prop is `true`.
- **render-fallback-when-false**: Component MUST render the `fallback` prop when the `when` prop is `false`.
- **fallback-defaults-to-null**: Component MUST default `fallback` to `null` when the `fallback` prop is not provided.
- **no-wrapper-element**: Component MUST NOT introduce an additional wrapper element; content MUST be rendered in a React fragment.

## Appearance

Not applicable: Conditional is a utility component that does not render any visual styling. It passes through its content unchanged.

## States

Not applicable: Conditional does not have visual states. Its behavior is determined entirely by the boolean value of the `when` prop.

## Accessibility

Not applicable: Conditional does not add any accessibility features or roles itself. Content rendered within Conditional inherits the accessibility properties of the `children` and `fallback` components. Implementors MUST ensure that both branches meet accessibility requirements independently.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| conditional-001 | render-children-when-true | `when={true}`, `children="Hello"`, `fallback="Goodbye"` | Renders "Hello" |
| conditional-002 | render-fallback-when-false | `when={false}`, `children="Hello"`, `fallback="Goodbye"` | Renders "Goodbye" |
| conditional-003 | fallback-defaults-to-null | `when={false}`, `children="Hello"` (no fallback prop) | Renders nothing (null) |
| conditional-004 | render-children-when-true | `when={true}`, `children={<Component />}`, `fallback={<Other />}` | Renders Component, not Other |
| conditional-005 | no-wrapper-element | `when={true}`, `children=[<span>A</span>, <span>B</span>]` | Both children render without a parent wrapper |

## Edge Cases

- **Null children**: When `children` is `null` or `undefined` and `when` is `true`, the component MUST render `null` (no content).
- **Falsy children values**: When `children` is a falsy value (e.g., `0`, `false`, empty string) and `when` is `true`, the component MUST render that falsy value as React normally would (not as no content).
- **Empty fallback**: When `when` is `false` and `fallback` is not provided (defaults to `null`), the component MUST render nothing.
- **Array children**: When `children` is an array of React elements and `when` is `true`, the component MUST render all elements without wrapping them.
- **ReactNode with mixed types**: When `children` contains mixed content (strings, elements, fragments) and `when` is `true`, all content MUST be rendered in order.

## Configuration

Not applicable: Conditional accepts no configuration options beyond its three props: `when`, `children`, and `fallback`.

## Deep Linking

Not applicable: Conditional is a utility component and does not define routes or support deep linking.

## Localization

Not applicable: Conditional does not render any user-facing text. Text content is provided by `children` or `fallback` and MUST be localized at the component level by the caller.

## Accessibility Options

Not applicable: Conditional does not implement accessibility display options. Assistive technology handling is delegated to the rendered `children` and `fallback` components.

## Feature Flags

Not applicable: Conditional does not have feature-flag-gated behavior.

## Analytics

Not applicable: Conditional does not emit any analytics events.

## Privacy

Not applicable: Conditional does not collect, store, or transmit data.

## Logging

Not applicable: Conditional does not emit log messages.

## Platform Notes

- **React/Web**: Implement using the native ternary operator with a React fragment, as shown in the reference source. Return `<>{when ? children : fallback}</>`. This approach produces no extra DOM nodes and allows sibling elements to render at the same nesting level.
- **SwiftUI**: Use the native `if` statement within the view hierarchy or implement a custom `@ViewBuilder` that conditionally includes content: `if when { children } else { fallback }`. SwiftUI's view builders naturally support conditional rendering without wrapper views.
- **Compose (Android/Kotlin)**: Use Kotlin's `if` expression within a `@Composable` function: `if (when) { children() } else { fallback() }`. Pass content as lambdas (composable blocks) for lazy evaluation.
- **AppKit / UIKit (Swift)**: In view-based code, conditionally add subviews to a container or return different view hierarchies. In SwiftUI, use the pattern described above. For imperative UIKit, create both branches and toggle visibility with `isHidden` or conditionally add to the view hierarchy.
- **WinUI 3**: Use C# conditional expressions (`when ? children : fallback`) within XAML's code-behind or data binding with `x:Bind` converters. For more complex scenarios, use `VisualStateManager` to toggle visibility of pre-laid-out branches, or bind element visibility to the condition with a `BoolToVisibilityConverter`.

## Design Decisions

The component defaults `fallback` to `null` rather than requiring it explicitly to simplify the common case where no fallback content is needed. This design allows callers to omit the prop when rendering conditionally is sufficient to hide content entirely. The component uses a fragment (`<>...</>`) rather than a `<div>` or other wrapper to avoid introducing an extra DOM node that would affect styling and layout. This follows React best practices for utility components that should be transparent to the component tree.

## Compliance

Not applicable: Conditional does not implement features that require compliance verification.

## Change History

