---
id: 2d27892d-a3df-4e7d-ba47-dfd6c45b4c6d
title: Three Pane Chat
domain: agenticdevelopertoolkit://recipes/three-pane-chat
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Multi-pane chat layout displaying transcript, topics list, and detail pane
  with visual connectors.
platforms:
- typescript
- web
- swift
- macos
tags:
- chat-ui
- layout
- pane
- topic
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Three Pane Chat

## Overview

The Three Pane Chat component orchestrates a sophisticated multi-pane chat layout designed for exploratory, structured conversations. It displays three vertically stacked regions: an optional topics pane (left), a chat transcript pane (center), and a collapsible detail pane (right). Messages that include popover metadata automatically generate selectable topics, which when activated display their associated details in the detail pane. SVG connectors visually link selected topics to their corresponding messages and message details, providing navigation context. The component manages focus, keyboard navigation, and responsive layout recalculation to adapt to viewport changes and content updates.

## Behavioral Requirements

- **must-derive-topics-from-messages**: Component MUST derive a list of topics from messages that contain popover metadata. Each message with popover data (title and description) generates one topic entry.
- **must-track-active-topic**: Component MUST maintain which topic is currently active (selected). Only one topic MAY be active at a time.
- **must-show-detail-pane-for-active-topic**: When a topic is active, its corresponding detail pane (containing title, description, links, and images) MUST be displayed and positioned in the detail pane region.
- **must-append-visible-topic-on-selection**: When a topic becomes active, Component MUST append it to a visible topics stack if not already present, allowing stacked navigation history.
- **must-respond-to-arrow-key-navigation**: Component MUST allow navigation between visible topics using arrow up and arrow down keys when focus is not in an input field.
- **must-cycle-topics-with-arrow-keys**: When arrow key navigation occurs, Component MUST move to the next or previous topic in the visible stack, wrapping if necessary and keeping focus on the current active topic.
- **must-respond-to-input-focus-keystroke**: When a single-character keystroke (not ctrl/meta/alt modified) is pressed and focus is not in an input or textarea, Component MUST automatically focus the chat input field.
- **must-draw-connectors-between-panes**: Component MUST render SVG connectors that visually link: (1) active topics to their source message in transcript, and (2) messages to their corresponding detail panels when visible.
- **must-recalculate-layout-on-image-load**: Component MUST recalculate the three-pane layout dimensions when images in the detail pane finish loading to account for dimension changes.
- **must-respond-to-topic-selection-click**: When a user clicks a topic in the topics pane, Component MUST activate that topic and select its corresponding message in the transcript.
- **must-respond-to-message-click-from-transcript**: When a user clicks a message in the transcript, Component MUST select that message. If the message has an associated topic, Component MUST activate that topic.
- **should-show-detail-arrow-in-transcript**: Component SHOULD display an indicator (detail arrow) on messages that have associated topics to signal that detail is available.

## Appearance

- **Corner radius**: 0 (rectangular panes)
- **Padding**: none at component level; sub-panes (topics, transcript, detail) manage internal spacing
- **Font**: inherited from message and topic content
- **Background**: three panes with distinct background colors per platform theme
- **Foreground/Text**: inherited from content
- **Border**: thin separator between panes (1px)
- **Shadow**: none
- **Min/Max size**: Component fills available container; responsively adjusts pane widths based on viewport and content

## States

| State | Appearance change |
|-------|------------------|
| Default | Topics pane visible (if layout permits), transcript centered, detail pane empty/collapsed |
| Topic Active | Selected topic highlighted in topics pane, detail pane expands with topic content, connectors drawn |
| No Topics | Topics pane hidden, transcript and detail panes remain, full width available to transcript |
| Image Loading | Detail pane height recalculates when images finish loading |
| Keyboard Focus | Input field focused (chat input gains focus indicator), topics pane navigation active (arrow keys enabled) |

## Accessibility

- **Role/trait**: Composite container with semantically structured panes; topics pane is a list of selectable items, transcript is a scrollable region, detail pane is a dynamic content region.
- **Label requirements**: Topics MUST have accessible labels (title and description); messages MUST have accessible content (text or aria-label); detail pane MUST announce its active topic when it updates.
- **Announce state changes**: When a topic is activated, the accessibility tree MUST be updated to reflect the active topic and detail pane content. When connectors render, their presence MUST not interfere with text reader navigation.
- **Keyboard navigation**: Arrow up/down MUST navigate between visible topics. Single-character keystrokes (without modifiers) MUST focus the chat input. Tab MUST navigate between focusable regions (topics list, transcript, input, detail pane links).
- **Minimum tap target**: Topics list items and messages MUST have a minimum touch target of 44×44pt on mobile platforms, 48×48dp on Android.
- **Assistive technology**: Screen readers MUST announce the count and titles of topics. Connectors are visual only and MUST NOT clutter the accessible tree.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| three-pane-001 | must-derive-topics-from-messages | Messages array with 3 messages, 2 with popover metadata | Topics list contains 2 entries with titles and descriptions from popover data |
| three-pane-002 | must-track-active-topic | User selects first topic | activeTopicIndex updates to 0; only one topic is marked active |
| three-pane-003 | must-show-detail-pane-for-active-topic | Topic 1 is active | Detail pane displays title, description, links, and images from topic 1 |
| three-pane-004 | must-append-visible-topic-on-selection | User selects topic 2 while topic 1 is visible | visibleTopicIndexes includes both 0 and 1; back-stack is preserved |
| three-pane-005 | must-respond-to-arrow-key-navigation | visibleTopicIndexes = [0, 1, 2], activeTopicIndex = 1; user presses arrow down | activeTopicIndex updates to 2; component does not scroll if out of bounds |
| three-pane-006 | must-respond-to-arrow-key-navigation | visibleTopicIndexes = [0, 1], activeTopicIndex = 1; user presses arrow down | activeTopicIndex wraps to 0 (or stays at max, depending on design) |
| three-pane-007 | must-respond-to-input-focus-keystroke | Focus is on topics pane; user presses 'a' key (no modifiers) | Chat input field receives focus; keystroke is not inserted into input |
| three-pane-008 | must-respond-to-input-focus-keystroke | Focus is already in chat input; user presses 'a' key | Keystroke is inserted into input; focus remains in input |
| three-pane-009 | must-draw-connectors-between-panes | activeTopicIndex = 0; topics[0].messageIndex = 2 | SVG connector drawn from topic-0 node to msg-2-out; from msg-2-out to panel-2-in |
| three-pane-010 | must-recalculate-layout-on-image-load | User loads a detail pane with images | onImageLoad callback triggers recalcHeight; layout dimensions update |
| three-pane-011 | must-respond-to-topic-selection-click | User clicks topic in topics pane | Active topic updates; message at topic.messageIndex is selected in transcript |
| three-pane-012 | must-respond-to-message-click-from-transcript | User clicks message with associated topic | Message is selected; activeTopicIndex updates to the topic's index |
| three-pane-013 | must-respond-to-message-click-from-transcript | User clicks message without associated topic | Message is selected; activeTopicIndex is not updated or set to -1 |
| three-pane-014 | must-derive-topics-from-messages | Messages array is updated to remove a message with popover data | Topics list is recalculated; removed topic is removed from topics array |
| three-pane-015 | should-show-detail-arrow-in-transcript | Message 2 has an associated topic | Transcript renders a detail arrow indicator on message 2 |

## Edge Cases

- **Empty or null input**: If the messages array is empty or null, the topics array MUST be initialized as empty and the topics pane MUST be hidden or show an empty state. No crash occurs.
- **Messages without popover data**: Messages without popover metadata MUST be ignored when deriving topics. They appear in transcript but do not generate topic entries.
- **Active topic index out of bounds**: If activeTopicIndex is set to an index that does not exist in topics, it MUST be treated as no active topic (activeTopicIndex = -1) and the detail pane MUST be cleared.
- **Visible topics stack out of bounds**: If visibleTopicIndexes contains indices that no longer exist after topics are recalculated, those invalid indices MUST be removed from the stack.
- **Keyboard navigation with empty topics**: If visibleTopicIndexes is empty, arrow key events MUST be ignored; no navigation occurs.
- **Layout recalculation during scroll**: If recalcHeight is called while the user is scrolling, the layout MUST update without interrupting scroll position or selecting a different topic.
- **Image loading errors**: If an image in the detail pane fails to load, onImageLoad MUST still fire (with appropriate error state) and recalcHeight MUST still be triggered to maintain layout correctness.
- **Multiple connector updates**: If topics or visibleTopicIndexes change rapidly, the connectorPairs array MUST be recalculated for each change without rendering stale connectors. SVG rendering MUST be consistent with the current state.
- **Topic selection during typing**: If a user presses a topic selection keystroke while typing in the chat input (focus inside input), the keystroke MUST be inserted into input, not redirect to topic navigation.
- **Rapid topic switching**: If activeTopicIndex is changed multiple times in rapid succession, each change MUST be processed; visibleTopicIndexes MUST accumulate selections; no topics are skipped.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `session` | `ChatSession` (ref) | required | Chat session object containing messages, isTyping, sendMessage, selectedIndex, selectMessage |
| `className` | `string` | `""` | CSS class name applied to the top-level frame and chat pane for styling |

## Deep Linking

Not applicable: Three Pane Chat is a composite container rendered within a chat application, not a standalone route or page.

## Localization

Not applicable: Three Pane Chat does not render user-facing strings. Topic titles, descriptions, and messages are provided by the session and chat backend and are localized at their source.

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | When enabled, SVG connector animations and pane transitions SHOULD be disabled or simplified to static rendering. |
| Increase Contrast | Topic and message selection highlights SHOULD use higher-contrast colors to meet WCAG AA standards. |
| Differentiate Without Color | Topic and message selection SHOULD be communicated via both color and additional visual indicators (e.g., bold text, borders, icons) to avoid color-only differentiation. |

## Feature Flags

Not applicable: Three Pane Chat is an intrinsic component of the chat mode system and is not gated by feature flags in the source.

## Analytics

| Event | Properties | When |
|-------|-----------|------|
| `three_pane_chat.topic_selected` | `{ topicIndex: number, messageIndex: number }` | User selects a topic in the topics pane |
| `three_pane_chat.message_clicked` | `{ messageIndex: number, hasAssociatedTopic: boolean }` | User clicks a message in the transcript |
| `three_pane_chat.keyboard_navigation` | `{ direction: "up" \| "down", fromTopicIndex: number, toTopicIndex: number }` | User navigates between topics using arrow keys |
| `three_pane_chat.input_focus_keystroke` | `{ keystroke: string }` | User presses a keystroke that auto-focuses the chat input |

## Privacy

Not applicable: Three Pane Chat does not collect, store, or transmit user data beyond rendering the session's existing message and topic data.

## Logging

Subsystem: application (inherited from AgenticDeveloperToolkit) | Category: `ThreePaneChatView`

| Event | Level | Message |
|-------|-------|---------|
| topics_recalculated | debug | `ThreePaneChatView: Topics recalculated. Count: {count}, Active: {activeIndex}` |
| layout_recalculated | debug | `ThreePaneChatView: Layout recalculated. Show topics: {showTopics}, Height: {height}` |
| connector_pairs_updated | debug | `ThreePaneChatView: Connector pairs updated. Pairs: {count}` |
| keyboard_navigation | debug | `ThreePaneChatView: Keyboard navigation: {direction}, Active topic now: {index}` |

## Platform Notes

- **Web (React)**: Source implementation in `packages/web/packages/chat/src/modes/ThreePaneChat.tsx`. Renders a frame div with class `pc-three-pane-frame` containing an inline ConnectorSVG, a TopicsPane subcomponent (conditionally shown), a chat pane with Transcript and ChatInput, and a PanelStack subcomponent for detail panels. Uses React hooks (useState, useRef, useCallback, useEffect, useMemo) to manage state. Layout visibility is driven by the `useThreePaneLayout` hook which calculates available space and determines whether the topics pane should be shown. Keyboard handling is set up in a useEffect that listens for keydown events and manages focus and navigation. Topics are derived from message popovers on every messages change.

- **SwiftUI**: Implement as a container view that lays out three child views: a topics list (List or ScrollView with topic items), a transcript region (ScrollView or custom scroll container with message cells), and a detail pane (dynamic content area). Use @State properties to track activeTopicIndex and visibleTopicIndexes; derive topics in a computed property from the session's messages. Wrap keyboard handling in a .onKeyPress or custom gesture handler to capture arrow keys and route single-character keystrokes to a focused input field. Use a GeometryReader and EnvironmentObject to pass layout information (showTopics, available height) to subviews. Render visual connectors as an overlay Canvas or ZStack with Path drawing to connect pane nodes.

- **Compose**: Implement as a composable function that manages topics state with remember { mutableStateOf(emptyList()) }. Use a Row or Spacer-based layout (or a custom layout with Layout composable) to position the topics LazyColumn, a transcript Column/LazyColumn, and a detail Pane. Track activeTopicIndex and visibleTopicIndexes with mutableStateOf. Derive topics in a LaunchedEffect(messages) block. Handle keyboard input with a KeyEvent callback or FocusRequester to route navigation and input focus. Use Canvas to draw connectors between composables by querying their layout coordinates via LocalDensity and LayoutCoordinates observers. Animate connector appearance with transition and updateTransition.

- **AppKit / UIKit**: Implement as an NSView (macOS) or UIView (iOS) subclass that manages three child views: a topics table view (NSTableView or UITableView), a transcript scroll view with custom message cells, and a detail pane view (UIView or NSView). Use Auto Layout constraints to position the three panes and adjust their widths/visibility based on layout calculations. Store activeTopicIndex and visibleTopicIndexes as @Published properties (if wrapped in an ObservableObject ViewModel). Derive topics from messages in a method called on each messages change. Add a keyboard event handler (via NSView.keyDown on macOS or UIView.inputView on iOS) to capture arrow keys and keystroke routing. Draw connectors using CAShapeLayer with UIBezierPath (iOS) or NSBezierPath (macOS), querying frame positions of the panes. Note: The current source stub (ThreePaneChatView.swift) defers implementation and renders InlineChatView instead; full implementation is pending.

- **WinUI 3**: Implement as a UserControl containing a Grid with three columns (topics column, transcript column, detail column) or a custom Panel layout. Use a ListBox or ItemsControl for the topics pane. Use a ScrollViewer for the transcript region. Bind to a ViewModel's Topics (ObservableCollection<TopicData>), ActiveTopicIndex, and VisibleTopicIndexes properties. Derive topics in the ViewModel using LINQ transformations on the messages collection. Handle keyboard input by attaching a KeyDown event handler to the root UserControl; use e.Key to detect arrow keys and route single-character keystrokes to the input field. Draw connectors using a custom Control with OnRender override, querying the layout rect of each pane and drawing lines using DrawingContext. Use Storyboard animations for smooth connector transitions.

## Design Decisions

- **Topics derived from popovers, not separate input**: Topics are automatically extracted from message popover metadata rather than passed as a separate prop. This keeps the component stateless with respect to topics and ensures topics always reflect the current message set. Tradeoff: the message format must include popover data for topics to appear.

- **Visible topics stack accumulates history**: The visibleTopicIndexes array preserves visited topics rather than replacing the view. This supports back-navigation and context stacking, allowing users to maintain multiple active exploration threads. Tradeoff: users must explicitly manage (pop/remove) topics from the stack if they want to "close" a detail pane.

- **Single active topic at a time**: Only one topic can be active (selected), even though multiple topics are visible. This simplifies focus management and connector rendering. Tradeoff: viewing multiple detail panes simultaneously requires a different pattern or component.

- **Arrow keys for navigation, not tab**: Arrow up/down navigate between topics; Tab navigates regions. This reserves arrow keys for topic-scoped navigation while keeping Tab for region-scoped navigation. Traceability: keyboard handling code in ThreePaneChatView.tsx lines 1025–1052.

- **Keystroke-to-input-focus heuristic**: Single-character keystrokes (not ctrl/meta/alt) auto-focus the chat input. This supports rapid-fire text input without explicit focus clicks, common in chat UX. Traceability: keyboard handling code in ThreePaneChatView.tsx lines 1043–1048. Caveat: if the topics pane is keyboard-navigable (arrow keys), a user pressing a letter to search topics will instead focus the input and lose topic search functionality. Design decision: topics pane does not support letter search; use arrow keys only.

- **Connectors drawn by index pairs, not DOM nodes**: The ConnectorSVG component takes an array of `ConnectorPair` objects (from/to IDs), not direct node references. This decouples connector rendering from pane element structure and allows connector updates without querying the DOM. Traceability: connector derivation in ThreePaneChatView.tsx lines 1054–1066.

- **Layout recalculation deferred to parent hook**: The component delegates layout visibility (showTopics) and height recalculation to the useThreePaneLayout hook, which measures the frame and available space. This keeps the component focused on state and user interaction while delegating layout logic to a specialized hook.

## Compliance

Not applicable: Component does not interact with security, identity, or compliance-scoped subsystems.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
