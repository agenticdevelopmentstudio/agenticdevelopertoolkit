---
id: 4c3c4287-95bd-47f5-9a07-2382e0db523b
title: PanelStack
domain: agenticdevelopercookbook://ingredients/panel-stack
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Container component that renders a collection of detail panes for visible
  topics.
platforms:
- typescript
- web
tags:
- layout
- container
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# PanelStack

## Overview

PanelStack is a container component that renders multiple DetailPane components based on a set of visible topic indexes. It serves as a layout wrapper for displaying detail views in a multi-pane interface. The component forwards a ref to its root div element to allow parent components to interact with the container directly.

## Behavioral Requirements

- **must-render-visible-panes**: Component MUST render a DetailPane for each index in the `visibleTopicIndexes` array.
- **must-pass-topic-data**: Component MUST pass the topic object from the `topics` array to each rendered DetailPane.
- **must-pass-image-load-callback**: Component MUST pass the `onImageLoad` callback to each DetailPane instance.
- **must-skip-missing-topics**: Component MUST skip rendering when a topic index does not exist in the topics array.
- **must-mark-visible-state**: Component MUST pass `visible={true}` to each DetailPane.
- **must-use-message-index-as-key**: Component MUST use the topic's `messageIndex` as the React key when rendering each DetailPane.
- **must-forward-ref**: Component MUST forward a ref to the root div element.
- **must-apply-class-name**: Component MUST apply the CSS class name `pc-panel-stack` to the root div.

## Appearance

- **Container**: Renders as a `div` element with class `pc-panel-stack`
- **Layout**: Component applies no direct layout styles; layout is determined by CSS class or parent container
- **Rendering model**: Vertical stack of DetailPane components (layout determined by CSS)

## States

| State | Appearance change |
|-------|------------------|
| Default | All visible panes rendered as DetailPane components |
| Empty | Empty div element when visibleTopicIndexes is empty or contains no valid indexes |

## Accessibility

Not applicable: Component is a container that renders child DetailPane components; accessibility concerns are handled by child components and their content.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| panel-stack-001 | must-render-visible-panes | `topics=[{messageIndex: 0}, {messageIndex: 1}]`, `visibleTopicIndexes=[0, 1]` | Two DetailPane components rendered in order |
| panel-stack-002 | must-pass-topic-data | `topics=[{messageIndex: 5, title: "Test"}]`, `visibleTopicIndexes=[0]` | DetailPane receives topic prop with messageIndex: 5 and title: "Test" |
| panel-stack-003 | must-pass-image-load-callback | `onImageLoad={mockFn}`, any visible panes | Each DetailPane receives onImageLoad callback |
| panel-stack-004 | must-skip-missing-topics | `topics=[{messageIndex: 0}]`, `visibleTopicIndexes=[0, 5, 10]` | Only first DetailPane renders; indexes 5 and 10 render nothing |
| panel-stack-005 | must-use-message-index-as-key | `topics=[{messageIndex: 3}, {messageIndex: 7}]`, `visibleTopicIndexes=[0, 1]` | React key for first pane is 3, second pane is 7 |
| panel-stack-006 | must-forward-ref | forwardRef attached to component | Ref resolves to root div element |
| panel-stack-007 | must-apply-class-name | any valid props | Root div has className `pc-panel-stack` |
| panel-stack-008 | must-skip-missing-topics | `topics=[{messageIndex: 0}]`, `visibleTopicIndexes=[5]` | Component renders empty div (no DetailPane rendered) |

## Edge Cases

- **Empty topics array**: When `topics` is empty and `visibleTopicIndexes` contains indexes, component MUST render empty panes (null entries are skipped silently).
- **Empty visibleTopicIndexes array**: When `visibleTopicIndexes` is empty, component MUST render only the div container with no child DetailPane components.
- **Out-of-bounds indexes**: When `visibleTopicIndexes` contains indexes greater than or equal to `topics.length`, component MUST skip those indexes and render nothing for them.
- **Undefined topic**: When a topic at a given index is undefined or null, component MUST render nothing (null return from map function).
- **Duplicate indexes**: When `visibleTopicIndexes` contains the same index multiple times, component MUST render multiple DetailPane instances for that topic (one per appearance in the array).

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `topics` | `TopicData[]` | Required | Array of topic objects to be rendered. Each topic is passed to a DetailPane component. |
| `visibleTopicIndexes` | `number[]` | Required | Array of indexes into the `topics` array indicating which topics should be rendered. |
| `onImageLoad` | `() => void` | Required | Callback function invoked when images in DetailPane components complete loading. |
| `ref` | `React.Ref<HTMLDivElement>` | Optional | Ref object forwarded to the root div element. |

## Deep Linking

Not applicable: Component is a layout container without a navigable destination. Deep linking is handled by the DetailPane components it renders.

## Localization

Not applicable: Component renders no user-facing text or labels.

## Accessibility Options

Not applicable: Component is a non-interactive container. Accessibility options (reduce motion, increase contrast, differentiate without color) are handled by DetailPane components and content.

## Feature Flags

Not applicable: Component is a simple container with no conditional behavior or optional features.

## Analytics

Not applicable: Component is a container with no interactive behavior or state changes to track.

## Privacy

Not applicable: Component processes no user data and collects no information.

## Logging

Not applicable: Component has no lifecycle events, errors, or state transitions requiring logging.

## Platform Notes

- **SwiftUI**: Use a `VStack` or custom container view to manage multiple child views matching the DetailPane equivalent. Forward the container to the parent using a binding or environment variable for ref-like access.
- **Compose**: Use a `Column` (or `LazyColumn` for large lists) composable that iterates over `visibleTopicIndexes`, conditionally rendering the DetailPane equivalent for each valid index. Use the topic's unique identifier as a key parameter.
- **React/Web**: Forward a ref to the root `div` element with `forwardRef`. The component is defined in `packages/web/packages/chat/src/modes/three-pane/PanelStack.tsx`. Map over `visibleTopicIndexes` and render a DetailPane for each valid index, using `messageIndex` as the React key.
- **AppKit / UIKit**: Create a container view (`NSView` or `UIView`) that manages child views corresponding to each visible topic. Use the topic's unique identifier to key child views for efficient updates. Provide a way for parent controllers to reference the container via a property or delegate.
- **WinUI 3**: Use a `StackPanel` with `Orientation="Vertical"` or a `Grid` with dynamic rows. Bind the `Children` collection to the visible topic indexes and create a child element for each index (equivalent to DetailPane). Use the topic's unique identifier to manage child element keys for updates.

## Design Decisions

- **Key strategy**: Uses `messageIndex` as the React key instead of the array index. This ensures DetailPane instances are preserved across reorders of `visibleTopicIndexes`, maintaining focus and internal state.
- **Silent null handling**: When a topic does not exist at a given index, the component renders nothing (null) rather than an error placeholder. This allows parent components to control error handling and prevents cascading errors if index arrays become stale.
- **Ref forwarding**: The component exposes the root div ref to allow parent components to measure, scroll, or manipulate the container directly.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| No compliance checks defined | N/A | N/A |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation from source analysis |
