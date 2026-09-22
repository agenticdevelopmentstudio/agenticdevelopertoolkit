---
id: 98e78d31-2c3a-47dc-a156-435a5732a29f
title: Transcript
domain: agenticdevelopercookbook://ingredients/transcript
type: ingredient
version: 1.0.0
status: review
language: en
created: 2026-09-22
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A scrollable container that renders a sequence of chat messages with optional
  typing indicator and fade-to-transparent gradient for older messages.
platforms:
- typescript
- web
tags:
- chat
- messaging
- transcript
- scroll
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Transcript

## Overview

Transcript is a scrollable message container component that displays a linear sequence of chat messages (rendered via MessageBubble), an in-progress typing indicator, and optional decorative elements (message popovers, detail arrows, fade gradient). It maintains scroll position at the bottom as messages arrive and automatically handles focus management for keyboard navigation.

## Behavioral Requirements

- **must-render-messages**: Component MUST render all messages in the `messages` array, with each message passed to a `MessageBubble` child component.
- **must-scroll-to-bottom-on-message-arrival**: Component MUST automatically scroll to the bottom of the container when the message count changes.
- **must-scroll-to-bottom-on-typing-start**: Component MUST automatically scroll to the bottom when `isTyping` transitions from `false` to `true`.
- **must-render-typing-indicator**: Component MUST render a `TypingIndicator` child component when `isTyping` is `true`, unless suppressed by the `suppressTypingIndicator` prop.
- **must-be-keyboard-focusable**: Component container MUST accept keyboard focus via `tabIndex={0}` to enable arrow-key scrolling when no visible scrollbar affordance is present.
- **must-announce-as-region**: Component container MUST have `role="region"` and a non-empty `aria-label` to announce the scrollback area as a named landmark.
- **must-accept-label-prop**: Component MUST accept an optional `label` prop that sets the container's `aria-label`; if omitted, MUST default to `"Conversation transcript"`.
- **must-support-message-selection**: Component MUST pass the `isSelected` flag to each `MessageBubble` based on whether the message's index matches the optional `selectedIndex` prop.
- **must-pass-click-callback-to-bubble**: Component MUST pass the `onMessageClick` callback to `MessageBubble` if provided; if not provided, `MessageBubble` receives `undefined`.
- **must-render-popovers-conditionally**: Component MUST render the result of `renderPopover(message)` immediately after the corresponding `MessageBubble` if both `renderPopover` and `message.popover` are truthy.
- **must-support-detail-arrows**: Component MUST pass the `showDetailArrows` flag and corresponding `onDetailArrowClick` callback to each `MessageBubble` when provided.
- **must-support-thinking-indicator-labels**: Component MUST pass the `thinkingLabels` prop to the `TypingIndicator`; if not provided, `TypingIndicator` renders a default dot pattern.
- **must-support-thinking-animation-frames**: Component MUST pass the `thinkingFrames` prop to the `TypingIndicator`; if not provided, `TypingIndicator` renders its default animation.
- **must-support-thinking-done-glyph**: Component MUST pass the `thinkingDoneGlyph` prop to the `TypingIndicator`; if not provided, `TypingIndicator` uses its default settled glyph.
- **must-support-thinking-colorful-mode**: Component MUST pass the `thinkingColorful` prop to the `TypingIndicator`; when `true`, the indicator flashes random non-green colors.
- **must-support-thinking-tint-spec**: Component MUST pass the `thinkingTint` prop to the `TypingIndicator` to control whether tint is applied to the glyph, words, or both.
- **should-apply-fade-gradient**: Component SHOULD apply a CSS fade gradient via the `pc-transcript--fade` class when `fadeOlder` is `true`; the gradient MUST anchor to the viewport bottom, keeping the newest (lowest) message fully opaque while older messages become increasingly transparent as they rise, but scrolling any message back into the readable zone MUST restore full opacity.
- **must-accept-custom-class**: Component MUST append the `className` prop to the class list if provided, allowing external style overrides.
- **must-use-unique-message-keys**: Component MUST render each message with `key={message.id}` to maintain DOM identity across re-renders.

## Appearance

- **Container height**: fills available space; typically a fixed-height or flex-layout container within a larger chat UI.
- **Overflow**: vertical scroll only; horizontal scroll not expected.
- **Message spacing**: determined by `MessageBubble` styling; Transcript does not add extra padding between messages.
- **Fade gradient** (when `fadeOlder` is true): viewport-anchored linear gradient from fully transparent at the top to fully opaque at the bottom; older messages approach transparency as they scroll toward the top; no explicit duration specified for the fade transition (governed by scroll behavior, not animation timing).
- **Typing indicator spacing**: rendered below all messages with standard line height; inherits typography from `TypingIndicator`.

## States

| State | Appearance change |
|-------|------------------|
| Default (messages, no typing) | All messages visible at full opacity; no typing indicator; scrolled to bottom. |
| Typing | All messages visible; TypingIndicator rendered below messages; scrolled to bottom. |
| Typing suppressed | Messages visible; no typing indicator even though `isTyping` is true (via `suppressTypingIndicator` prop). |
| Message selected | Corresponding MessageBubble receives `isSelected={true}` and applies its selected-state styling. |
| Fade mode active | Older messages progressively fade toward top; bottom messages remain opaque; fade is viewport-anchored, not message-relative. |
| Empty messages array | Container renders with no child bubbles; typing indicator may still be visible if `isTyping` is true. |

## Accessibility

- **Role**: `region` — marks the container as a named landmark so screen reader users can navigate to the scrollback area.
- **Label**: aria-label set to the `label` prop value (or default "Conversation transcript"); allows the region to announce its purpose.
- **Focus management**: `tabIndex={0}` enables keyboard focus on the scroll container so arrow keys can scroll without a visible scrollbar. If the UI hides the scrollbar (e.g., a theme that uses a fade gradient instead), this focus trap ensures keyboard users are not locked out of scrollback.
- **Message bubbles**: each MessageBubble is responsible for its own semantics (e.g., button roles, labels for interactive elements); Transcript does not add semantic roles to individual messages.
- **Typing indicator**: TypingIndicator is responsible for announcing its own state; Transcript does not manage screen-reader announcements for typing.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|----|----|----|
| transcript-001 | must-render-messages | `messages=[{id: "1", ...}, {id: "2", ...}]` | Both messages render as MessageBubble children in order. |
| transcript-002 | must-scroll-to-bottom-on-message-arrival | Initial render with 3 messages, then append a 4th message. | Scroll position moves to bottom; new message is in view. |
| transcript-003 | must-scroll-to-bottom-on-typing-start | 5 messages rendered, `isTyping` changes from `false` to `true`. | Scroll position moves to bottom; TypingIndicator becomes visible. |
| transcript-004 | must-render-typing-indicator | `isTyping={true}`, `suppressTypingIndicator={false}` | TypingIndicator is rendered in the DOM. |
| transcript-005 | must-render-typing-indicator | `isTyping={true}`, `suppressTypingIndicator={true}` | TypingIndicator is not rendered in the DOM. |
| transcript-006 | must-be-keyboard-focusable | User presses Tab to navigate; transcript container is in tab order. | Container receives focus; outline or focus indicator appears. |
| transcript-007 | must-announce-as-region | Container renders; screen reader reads the DOM. | Screen reader announces region with `aria-label` text. |
| transcript-008 | must-accept-label-prop | `label` prop not provided. | Default label "Conversation transcript" is set on aria-label. |
| transcript-009 | must-accept-label-prop | `label="Chat history"` | aria-label is set to "Chat history". |
| transcript-010 | must-support-message-selection | `selectedIndex={1}`, messages array has 3 items. | MessageBubble at index 1 receives `isSelected={true}`; others receive `isSelected={false}`. |
| transcript-011 | must-pass-click-callback-to-bubble | `onMessageClick={callback}` provided. | Click events on MessageBubbles are passed to the callback with the message index. |
| transcript-012 | must-pass-click-callback-to-bubble | `onMessageClick` not provided. | MessageBubble receives `onClick={undefined}`; clicks have no effect. |
| transcript-013 | must-render-popovers-conditionally | Message has `popover` truthy and `renderPopover` provided. | Popover is rendered immediately after the MessageBubble. |
| transcript-014 | must-render-popovers-conditionally | Message has `popover` falsy or `renderPopover` not provided. | No popover is rendered. |
| transcript-015 | must-support-detail-arrows | `showDetailArrows={true}`, message has `popover` truthy. | MessageBubble receives `showDetailArrow={true}` and detail arrow is visible. |
| transcript-016 | must-support-detail-arrows | `showDetailArrows={false}` or message has no `popover`. | MessageBubble receives `showDetailArrow={false}`. |
| transcript-017 | must-support-thinking-indicator-labels | `thinkingLabels` array provided. | TypingIndicator receives the labels and renders them instead of default dots. |
| transcript-018 | must-support-thinking-animation-frames | `thinkingFrames` array provided. | TypingIndicator receives the frames and cycles through them for animation. |
| transcript-019 | must-support-thinking-done-glyph | `thinkingDoneGlyph` string provided. | TypingIndicator uses the glyph when `isTyping` becomes false. |
| transcript-020 | must-support-thinking-colorful-mode | `thinkingColorful={true}` and `isTyping={true}` | TypingIndicator flashes non-green colors during thinking. |
| transcript-021 | must-support-thinking-tint-spec | `thinkingTint` object provided. | TypingIndicator applies tint to the specified elements (glyph, words, or both). |
| transcript-022 | should-apply-fade-gradient | `fadeOlder={true}`, messages visible in viewport. | CSS class `pc-transcript--fade` is applied; older messages are progressively transparent. |
| transcript-023 | should-apply-fade-gradient | `fadeOlder={false}` | CSS class `pc-transcript--fade` is not applied; all messages render at full opacity. |
| transcript-024 | must-accept-custom-class | `className="custom-class"` | The container includes `custom-class` in its class list. |
| transcript-025 | must-use-unique-message-keys | Messages re-render with same IDs. | Each message retains its DOM node identity via the `key` prop. |

## Edge Cases

- **Empty messages array**: Component renders the container and typing indicator (if not suppressed) even with no messages. The scrollback area is empty but focusable and keyboard-navigable.
- **selectedIndex out of range**: If `selectedIndex` is greater than or equal to the messages array length, no message receives `isSelected={true}` (all receive `isSelected={false}`). Component does not error.
- **selectedIndex is -1**: No message receives `isSelected={true}`. This is the default when the prop is omitted.
- **isTyping true with empty messages array**: Typing indicator renders at the top of an otherwise empty container. Scroll position is at the bottom (no content to scroll to, so it is naturally at bottom).
- **Rapid message arrivals**: If messages arrive faster than scroll-to-bottom can complete, the container remains scrolled to bottom (the dependency array re-triggers on every message count change, so it updates on each new message).
- **fadeOlder with single message**: Single message remains at full opacity; fade gradient has no effect (no older messages to fade).
- **fadeOlder and scroll to top**: User scrolls to the top of the transcript to read the oldest message. That message transitions from faded to fully opaque as it enters the readable zone; no jarring opacity shift (CSS mask gradient governs visibility, not a discrete state change).
- **suppressTypingIndicator with isTyping true**: TypingIndicator is not rendered even though the component is aware typing is in progress; scroll-to-bottom still occurs on `isTyping` changes.
- **renderPopover returns null or undefined**: If renderPopover is called but returns null or undefined, nothing is rendered after the MessageBubble (React skips falsy children).
- **message.popover is falsy but renderPopover is provided**: No popover is rendered; renderPopover is not called.
- **onDetailArrowClick on message with no popover**: MessageBubble receives `showDetailArrow={false}` even if `showDetailArrows={true}`, so the detail arrow is not rendered and the callback is not set.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `messages` | `ChatMessage[]` | required | Array of message objects to render. |
| `isTyping` | `boolean` | required | Whether the remote participant is currently typing. |
| `selectedIndex` | `number` | `-1` | Index of the message to mark as selected; optional. |
| `onMessageClick` | `(index: number) => void` | `undefined` | Callback fired when a message is clicked; optional. |
| `renderPopover` | `(message: ChatMessage) => ReactNode` | `undefined` | Function to render a popover for each message; optional. |
| `showDetailArrows` | `boolean` | `false` | Whether to show detail arrows on messages that have a popover. |
| `onDetailArrowClick` | `(index: number) => void` | `undefined` | Callback fired when a detail arrow is clicked; optional. |
| `className` | `string` | `undefined` | Custom CSS class to append to the container. |
| `thinkingLabels` | `readonly StatusWordPair[]` | `undefined` | Word pairs for the typing indicator (falls back to dots if not provided). |
| `thinkingFrames` | `readonly string[]` | `undefined` | Animation frames for the typing indicator glyph. |
| `thinkingDoneGlyph` | `string` | `undefined` | Settled glyph to render when typing completes. |
| `thinkingColorful` | `boolean` | `false` | Whether to flash random non-green colors while typing. |
| `thinkingTint` | `StatusTintSpec` | `undefined` | Specification for which elements (glyph, words, both) receive tint while typing. |
| `suppressTypingIndicator` | `boolean` | `false` | If `true`, do not render the typing indicator even when `isTyping` is true. |
| `label` | `string` | `"Conversation transcript"` | Accessible name for the scroll region. |
| `fadeOlder` | `boolean` | `false` | Whether to apply a viewport-anchored fade gradient to older messages. |

## Deep Linking

Not applicable: Transcript is a message container component, not a top-level view. Deep linking is handled by the containing chat application, not by this component.

## Localization

Not applicable: Transcript has no user-facing strings. The `label` prop and `thinkingLabels` prop are provided by the parent application and are assumed to be pre-localized.

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | `fadeOlder` fade transitions SHOULD respect `prefers-reduced-motion` media query; the fade MUST still be applied (for readability), but opacity changes during scroll SHOULD not use animation timing functions that imply motion. Component does not currently implement this check; parent theme or CSS media query SHOULD handle it. |
| Increase Contrast | `fadeOlder` gradient endpoint colors SHOULD be adjusted to meet contrast requirements for text legibility when faded; current implementation relies on the theme's color choices. |
| Differentiate Without Color | Not applicable; Transcript does not use color alone to convey meaning. Typing status is announced via the TypingIndicator's content and `aria-label`, not color. |

## Feature Flags

Not applicable: Transcript has no built-in feature flags. A parent application may conditionally render or configure the component, but Transcript itself does not gate any behavior.

## Analytics

Not applicable: Transcript does not emit analytics events. Click events and arrow-click events are delegated to parent-provided callbacks (`onMessageClick`, `onDetailArrowClick`). The parent application is responsible for logging and analytics.

## Privacy

Not applicable: Transcript does not collect, store, transmit, or log user data. It is a stateless view component that renders data provided by the parent application.

## Logging

Not applicable: Transcript has no logging. It does not emit debug, info, warn, or error messages.

## Platform Notes

- **Source platform (Web/React)**: Component is implemented in `packages/web/packages/chat/src/components/Transcript.tsx`. It uses React hooks (`useRef`, `useScrollToBottom`) to manage scroll position and combines styled `MessageBubble` and `TypingIndicator` children. CSS class names follow the `pc-*` convention (e.g., `pc-transcript`, `pc-transcript--fade`).
- **SwiftUI**: Implement as a `ScrollViewReader` containing a `VStack` of message views. Use `onChange` modifier on the message count to scroll to the bottom message ID. Apply a `LinearGradient` mask with `opacity` ramping from 0.0 at the top to 1.0 at the bottom when `fadeOlder` is true; the gradient anchor must be relative to the scroll container's visible bounds, not the message stack's bounds. Expose the same prop interface (converted to Swift types: e.g., `@Binding var isTyping: Bool`).
- **Compose (Android)**: Implement as a `LazyColumn` with `state.animateScrollToItem()` called when `messages.size` changes or `isTyping` changes. For `fadeOlder`, apply a `Modifier.graphicsLayer` with `alpha` interpolated based on the item's position relative to the viewport. Each message is a `Composable` equivalent of `MessageBubble`. Typing indicator is rendered as a `Composable` when `isTyping` is true (unless suppressed).
- **AppKit / UIKit**: Implement as a `UIScrollView` containing a `UIStackView` (vertical, filling width). Use `scrollRectToVisible` to scroll to the bottom `CGRect` on message arrival or typing state change. For `fadeOlder`, apply a `CAGradientLayer` as a mask on the scroll view's `layer`, anchored to the scroll view's bounds (use `CADisplayLink` or `scrollViewDidScroll` to update the mask position as the user scrolls). Each message is a `UIView` equivalent of `MessageBubble`; typing indicator is a subview of the stack that is added/removed based on `isTyping` and `suppressTypingIndicator`.
- **WinUI 3**: Implement as a `ScrollViewer` with a `StackPanel` (`Orientation="Vertical"`) inside. On `messages` or `isTyping` changes, call `ScrollViewer.ChangeView(null, scrollViewer.ExtentHeight, null)` to scroll to bottom. For `fadeOlder`, apply a `BitmapCache` with a `LinearGradientBrush` opacity mask to the scroll content; update the mask's bounds in `SizeChanged` and `ViewChanged` events to keep the gradient anchored to the viewport. Render each message as a custom control equivalent to `MessageBubble` (typically a `UserControl` with XAML and C# code-behind). Use a `ConditionalVisibility` converter or code-behind to show/hide the typing indicator based on the `IsTyping` and `SuppressTypingIndicator` properties.

## Design Decisions

- **role="region" over role="log"**: The component does not use `role="log"` with `aria-live="polite"` because live region announcements fire on every token-level mutation as replies stream in. Using `role="region"` without live updates allows users to navigate the transcript on their own terms and read messages at their own pace; the typing indicator signals that new content is coming without verbosely re-announcing the same sentence for each character added.
- **tabIndex={0} for keyboard scroll access**: The scroll container must be focusable to allow arrow-key scrolling on platforms or themes that hide the visual scrollbar affordance. Without focus, keyboard-only users have no way to scroll the transcript and are locked out of reading older messages.
- **Fade gradient viewport-anchored**: The fade gradient is anchored to the bottom of the visible viewport, not to the bottom of the message stack. This ensures older messages fade as they scroll toward the top edge, improving readability by directing visual focus to new/current messages at the bottom. A message-stack-anchored fade would keep the bottom-most message always opaque, which defeats the readability goal when the user scrolls to view older messages.
- **selectedIndex is optional and defaults to -1**: Not all use cases require message selection. When selection is not needed, the prop can be omitted; no MessageBubble receives `isSelected={true}`, and selection state does not interfere with other interactions.
- **thinkingColorful and thinkingTint are separate props**: Colorfulness (flashing random non-green colors) is a distinct visual behavior from tint (applying a specific color tone to specific elements). These are separated to allow independent control: an application can choose to flash colors without tinting, or apply a tint without color flashing.
- **Popover rendered inline after MessageBubble**: The `renderPopover` prop returns a ReactNode that is rendered as a sibling of the MessageBubble, not nested inside it. This keeps the message structure flat and allows the parent application to control popover layout (e.g., positioning, sizing, animation).

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| Accessible name for scroll region | passed | Accessibility |
| Keyboard navigation via tabIndex | passed | Accessibility |
| Not using role="log" for non-live content | passed | Accessibility |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation from web source |
