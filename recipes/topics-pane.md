---
id: dcf1a793-0a47-466b-8b09-0bcf091fd55a
title: Topics Pane
domain: agenticdevelopertoolkit://recipes/topics-pane
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A pane displaying a list of selectable topics with active state indication
  and visibility control.
platforms:
- typescript
- web
tags:
- ui-container
- list
- navigation
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Topics Pane

## Overview

The Topics Pane is a container component that displays a list of topic items as selectable buttons within a labeled pane. It provides visibility toggling and active state selection, used in multi-pane layouts to navigate between topics or discussion threads. Each topic is rendered with its title and an associated connector anchor for visual linking in complex layouts.

## Behavioral Requirements

- **must-render-header**: Component MUST render a header section displaying the text "Topics".
- **must-render-topic-list**: Component MUST render all topics provided in the topics array as a list of button elements.
- **must-display-topic-title**: Component MUST display the `title` property of each topic within its button.
- **must-accept-topic-selection**: Component MUST accept a topic index via the `onSelectTopic` callback when a topic button is clicked.
- **must-indicate-active-topic**: Component MUST visually indicate which topic is currently active by comparing its index to the `activeIndex` prop and applying an "active" class when they match.
- **must-respect-visibility-state**: Component MUST apply a visibility class that changes between "pc-pane-visible" and "pc-pane-hidden" based on the `visible` prop.
- **must-render-connector-anchor**: Component MUST render a `ConnectorAnchor` child element within each topic button with an id attribute derived from the topic's `messageIndex` property.

## Appearance

- **Container**: Full-width pane with CSS classes `pc-topics-pane` and visibility modifier class
- **Header**: Styled section with CSS class `pc-panel-header` containing the text "Topics"
- **List**: Unordered list with CSS class `pc-topic-list` containing list items
- **Topic Item**: Button element with CSS class `pc-topic-item` and optional "active" class modifier
- **Connector Anchor**: Child component within each button with CSS class `pc-connector-anchor-out`
- **Active State**: Visually distinguished via "active" class when topic index matches `activeIndex`

## States

| State | Appearance Change |
|-------|------------------|
| Visible | Container displays with "pc-pane-visible" class applied |
| Hidden | Container displays with "pc-pane-hidden" class applied |
| Topic Default | Button rendered without "active" class |
| Topic Active | Button rendered with "active" class modifier |

## Accessibility

- Role: Container with a header and list of buttons for topic selection
- Label: The "Topics" header text serves as the pane label
- Button elements: Each topic button SHOULD have an accessible label from its `title` text
- Active state: The "active" class on the selected topic button SHOULD be announced to screen readers or conveyed through semantic HTML attributes
- Keyboard navigation: Topic buttons SHOULD be keyboard accessible and focusable in tab order
- Minimum tap target: Topic buttons SHOULD maintain at least 44×44pt touch targets per platform accessibility guidelines

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| topics-001 | must-render-header | topics=[], visible=true | Header element displays "Topics" text |
| topics-002 | must-render-topic-list | topics=[{title: "Topic 1", messageIndex: 1}], visible=true | Single list item with button containing "Topic 1" |
| topics-003 | must-display-topic-title | topics=[{title: "First", messageIndex: 1}, {title: "Second", messageIndex: 2}], visible=true | Both topic titles displayed in respective buttons |
| topics-004 | must-accept-topic-selection | topics=[{title: "Topic", messageIndex: 1}], user clicks button | onSelectTopic callback invoked with index 0 |
| topics-005 | must-indicate-active-topic | topics=[{title: "A", messageIndex: 1}, {title: "B", messageIndex: 2}], activeIndex=1, visible=true | Second button has "active" class; first button does not |
| topics-006 | must-respect-visibility-state | topics=[], visible=true | Root div has "pc-pane-visible" class |
| topics-007 | must-respect-visibility-state | topics=[], visible=false | Root div has "pc-pane-hidden" class |
| topics-008 | must-render-connector-anchor | topics=[{title: "Topic", messageIndex: 5}] | ConnectorAnchor component rendered with id="topic-5" and className="pc-connector-anchor-out" |
| topics-009 | must-indicate-active-topic | topics=[{title: "First", messageIndex: 1}], activeIndex=0 | Button contains "active" class |
| topics-010 | must-accept-topic-selection | topics=[{title: "A", messageIndex: 1}, {title: "B", messageIndex: 2}, {title: "C", messageIndex: 3}], user clicks second button | onSelectTopic callback invoked with index 1 |

## Edge Cases

- **Empty topics array**: Component renders header and empty list when `topics` is an empty array. No buttons are rendered.
- **Negative or out-of-bounds activeIndex**: Component renders all topics without active class when `activeIndex` does not match any valid array index (e.g., activeIndex = -1 or activeIndex >= topics.length).
- **Large topic list**: Component renders all topics provided; no pagination or virtualization is implemented. Scrolling is handled by CSS/container layout.
- **Missing or undefined title**: Component renders the button but title content is undefined; the button may appear empty or with undefined text depending on React's behavior.
- **Visibility toggle**: Switching `visible` between true and false updates only the CSS class; underlying DOM elements remain in the tree, affecting accessibility and layout reflow.
- **Rapid selection changes**: Multiple rapid calls to `onSelectTopic` are processed sequentially; no debouncing or race condition handling is present in the component.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| topics | TopicData[] | [] | Array of topic objects to display; each must have `title` and `messageIndex` properties |
| activeIndex | number | undefined | Zero-based index of the currently active/selected topic |
| onSelectTopic | (index: number) => void | required | Callback fired when a topic button is clicked with the selected topic's index |
| visible | boolean | true | Controls visibility state; true applies "pc-pane-visible", false applies "pc-pane-hidden" |

## Deep Linking

| Platform | Applicable |
|----------|-----------|
| Apple | Not applicable: This is a web component without native platform equivalents |
| Android | Not applicable: This is a web component without native platform equivalents |
| Web | Deep linking is not implemented in the component; URL routing is handled by the consuming application |

## Localization

| String Key | Default (en) | Context |
|-----------|-------------|---------|
| pane.header.topics | "Topics" | Header text for the topics pane |

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | Not implemented in source. Component does not respond to prefers-reduced-motion; CSS transitions applied by stylesheet may still animate |
| Increase Contrast | Not implemented in source. No adaptive color contrast logic in component |
| Differentiate Without Color | Not implemented in source. Active state is conveyed via "active" class; implementation details left to stylesheet |

## Feature Flags

| Flag Key | Default | Description |
|----------|---------|-------------|
| topics_pane.enabled | true | Feature flag to enable/disable the topics pane component |

## Analytics

| Event | Properties | When |
|-------|-----------|------|
| topics_pane.displayed | { visible: boolean } | Component renders with visible state |
| topics_pane.topic_selected | { topicIndex: number } | User clicks a topic button |

## Privacy

- **Data collected**: Topic title text and selection index. No personal data is collected by the component itself.
- **Storage**: No data is persisted by the component; selections are passed to parent via callback.
- **Transmission**: Selections are passed to parent component; data transmission depends on parent implementation.
- **Retention**: No data is retained by the component.

## Logging

Subsystem: `chat.topics-pane` | Category: `TopicsPane`

| Event | Level | Message |
|-------|-------|---------|
| Component render | debug | `TopicsPane: rendered with ${topics.length} topics, activeIndex=${activeIndex}, visible=${visible}` |
| Topic selected | debug | `TopicsPane: topic selected, index=${index}` |

## Platform Notes

- **Web**: Source implementation uses React functional component with CSS class-based styling. Topics rendered as semantic `<button>` elements within `<ul><li>` structure. Visibility toggled via CSS classes `pc-pane-visible` and `pc-pane-hidden`.
- **SwiftUI**: Implement as a ScrollView containing a VStack of Button elements. Use @State for active selection. Apply opacity or visibility modifier based on visible prop. Render a Text header above the list.
- **Compose**: Use a Column containing a Text header and a LazyColumn of Button composables. Track selection state with mutableStateOf. Apply alpha or visibility based on visible prop.
- **AppKit / UIKit**: Implement as an NSView or UIView containing an NSTableView/UITableView or NSCollectionView/UICollectionView displaying topics as cells. Apply NSView.isHidden or UIView.alpha based on visible prop. Highlight selected row with background color.
- **WinUI 3**: Implement as a Grid or StackPanel containing a TextBlock header and an ItemsControl or ListView displaying topics as Button elements. Use IsEnabled property for visibility state. Apply visual state or highlight to selected item via ItemContainerStyle.

## Design Decisions

- **CSS class-based styling**: The component applies visibility and active state via CSS classes rather than inline styles, delegating appearance control to stylesheets. This supports theme switching and design system consistency.
- **Array index for selection**: Active topic is identified by array index rather than object identity or unique key property, keeping selection state simple and coupling it to list order.
- **ConnectorAnchor inclusion**: Each topic includes a ConnectorAnchor child, indicating this component is part of a visual linking or diagramming system where topics are connected to other pane elements.
- **No default active selection**: activeIndex can be undefined or out-of-bounds, leaving default selection to parent component logic.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| [semantic-buttons](agenticdevelopercookbook://compliance/accessibility#semantic-buttons) | passed | Accessibility |
| [keyboard-navigation](agenticdevelopercookbook://compliance/accessibility#keyboard-navigation) | conditional | Accessibility — depends on parent focus management |
| [list-structure](agenticdevelopercookbook://compliance/html#list-structure) | passed | HTML |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation from source code analysis |
