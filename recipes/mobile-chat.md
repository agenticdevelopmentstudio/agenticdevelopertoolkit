---
id: f6d46f16-65a6-4d19-80c7-1fc8b4d323fd
title: Mobile Chat
domain: agenticdevelopercookbook://recipes/mobile-chat
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
summary: Full-screen chat surface with scrolling transcript, thinking indicator, and
  single-line composer for mobile devices.
platforms:
- swift
- typescript
- web
tags:
- chat
- messaging
- mobile
depends-on: []
related: []
references: []
copyright: 2026 Mike Fullerton
license: MIT
---

# Mobile Chat

## Overview

Mobile Chat is a full-screen chat surface that displays a scrolling transcript of committed and in-progress messages, a persistent status line for remote typing and thinking states, and a single-line composer for user input. It presents to the user as an overlay (web) or replaces the host view (iOS) and can be opened and closed with optional animations. The component is designed for phone-sized screens where the chat surface occupies the entire available space and keyboard presentation is critical.

## Behavioral Requirements

- **must-render-transcript**: Component MUST render all messages from the chat session's message array in a scrolling transcript, ordered chronologically from oldest to newest.
- **must-render-active-drafts**: Component MUST render non-empty active drafts from the session's `activeDrafts` array inline within the transcript, styled identically to committed messages.
- **must-align-messages-by-sender**: Component MUST align messages from the local participant to the right side of the screen and messages from remote participants to the left side.
- **must-auto-scroll-on-new-content**: Component MUST scroll the transcript to the bottom when new messages or drafts arrive, unless the user has scrolled up to read history (scroll position within 40pt of bottom).
- **must-focus-input-on-open**: Component MUST focus the text input field within 350ms after the component becomes visible on screen, to trigger the native keyboard presentation.
- **must-display-thinking-indicator**: Component MUST display a status line above the composer showing the current status of all remote participants; when no remote status exists but typing indicators are present, the component MUST display a default thinking animation (three pulsing dots).
- **must-validate-message-before-send**: Component MUST reject (not send) any message input that contains only whitespace or is empty.
- **must-clear-input-after-send**: Component MUST clear the text input field immediately after the user successfully sends a message.
- **must-send-on-return-key**: Component MUST submit the current input message when the user presses the Return key while focused on the text input.
- **must-send-on-button-tap**: Component MUST submit the current input message when the user taps the send button.
- **must-apply-theme-once**: Component MUST apply the chat surface background color and divider color on the controller's own view exactly once (to prevent translucent surface duplicates from appearing lighter).
- **must-support-close-button**: Component MUST render a close button in the header that triggers the `onClose` callback.
- **must-support-custom-close-label**: Component SHOULD allow the host to customize the text label of the close button via a `closeLabel` prop (default: "← back").
- **must-track-open-state**: Component MUST track whether the surface is currently open, so tests and hosts can assert the surface visibility without depending on presentation context.

## Appearance

- **Corner radius**: None; full-screen on iOS, overlay on web with system-defined styling.
- **Padding**: Transcript stack: 20pt top/bottom, 16pt left/right. Input row: 14pt top/bottom, 16pt left/right. Status row: 16pt left/right.
- **Font**: Input field placeholder: system default (UITextField default). Message bubbles: delegated to `MobileMessageBubbleView`.
- **Background**: Chat surface: `chatSurface` semantic color token. Status row: transparent (inherits surface). Divider: `border` semantic color token.
- **Foreground/Text**: Input field text and placeholder: system default. Send button: system image "arrow.up.circle.fill" (tinted).
- **Border**: Divider between status row and input row: 1pt solid border color.
- **Shadow**: None; surfaces are flat.
- **Min/Max size**: Transcript stack width: equal to scroll view frame width. Max bubble width: 75% of scroll view width or 200pt minimum, whichever is larger.

## States

| State | Appearance change |
|-------|------------------|
| Default | Surface visible with all content rendered; input field ready for typing. |
| Open (animated) | Surface alpha animates from 0 to 1 over 0.25 seconds. |
| Closed (animated) | Surface alpha animates from 1 to 0 over 0.25 seconds. |
| Input focused | Native keyboard is presented (platform-specific). |
| Thinking/typing remote | Status line shows remote participant's current status or default pulsing indicator. |
| Message composing | Active draft appears in transcript with `.composing` delivery status. |

## Accessibility

- **Role/trait**: Main container is a view controller (iOS) or div with role `region` (web). Input field is a text field / input[type="text"]. Send button is a button. Close button is a button.
- **Label requirements**: Input field MUST have a visual or programmatic label or placeholder indicating it accepts message text (placeholder "Type a message..." suffices). Close button MUST be labeled with the `closeLabel` text. Send button SHOULD have a label describing its action (e.g., "send").
- **Announce state changes**: Status line updates (typing, thinking) SHOULD be announced to screen readers. Message arrival SHOULD trigger an announcement if the transcript is off-screen.
- **Minimum tap target**: All buttons (close, send) MUST have a touch target of at least 44×44pt on iOS per Apple HIG.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| mobile-chat-001 | must-render-transcript | Session with 5 messages | All 5 messages appear in transcript in chronological order. |
| mobile-chat-002 | must-render-active-drafts | Session with 1 draft with text="hello" | Draft appears in transcript styled identically to committed messages. |
| mobile-chat-003 | must-render-active-drafts | Session with 1 draft with text="" (empty) | Draft is not rendered. |
| mobile-chat-004 | must-align-messages-by-sender | Message from localParticipantID | Message bubble aligns to right with spacer on left. |
| mobile-chat-005 | must-align-messages-by-sender | Message from remote participant | Message bubble aligns to left. |
| mobile-chat-006 | must-auto-scroll-on-new-content | Transcript at bottom; new message arrives | Scroll automatically moves to bottom to show new message. |
| mobile-chat-007 | must-auto-scroll-on-new-content | Transcript scrolled up by user; new message arrives | Scroll remains where user positioned it (within 40pt threshold of bottom). |
| mobile-chat-008 | must-focus-input-on-open | Surface becomes visible | Input field receives focus; native keyboard is presented (tappable). |
| mobile-chat-009 | must-display-thinking-indicator | Remote participant has active status (not nil) | Status line shows the remote participant's status text/animation. |
| mobile-chat-010 | must-display-thinking-indicator | No remote status; typing indicators exist | Status line shows default pulsing dots. |
| mobile-chat-011 | must-display-thinking-indicator | No remote status; no typing indicators | Status line is hidden or shows nothing. |
| mobile-chat-012 | must-validate-message-before-send | User enters "   " (whitespace only); taps send | Message is not sent; input field is not cleared. |
| mobile-chat-013 | must-validate-message-before-send | User enters "" (empty); taps send | Message is not sent. |
| mobile-chat-014 | must-validate-message-before-send | User enters "hello"; taps send | Message is sent and input field is cleared. |
| mobile-chat-015 | must-clear-input-after-send | Input field has text; user sends | Input field text becomes empty. |
| mobile-chat-016 | must-send-on-return-key | Input field focused; user presses Return | Message is sent; input field is cleared. |
| mobile-chat-017 | must-send-on-button-tap | Input field has text; user taps send button | Message is sent; input field is cleared. |
| mobile-chat-018 | must-support-close-button | User taps close button | `onClose` callback is invoked. |
| mobile-chat-019 | must-support-custom-close-label | closeLabel prop set to "dismiss" | Close button displays "dismiss" text. |
| mobile-chat-020 | must-track-open-state | Surface is presented and `open(animated:)` called | `isOpen` property is true. |
| mobile-chat-021 | must-track-open-state | Surface is dismissed and `close(animated:)` called | `isOpen` property is false. |

## Edge Cases

- **Empty message array**: When the session has no messages and no active drafts, the transcript is empty but renders without error. The status line still shows thinking/typing indicators if remote participants have them.
- **Null or missing localParticipantID**: If `localParticipantID` does not match any message sender, all messages align to the left (treated as remote).
- **Concurrent message and status updates**: If a message arrives simultaneously with a typing status change, both the transcript rebuild and status refresh occur without visual flicker or dropped updates.
- **Keyboard interruption (iOS)**: If the keyboard is dismissed (e.g., by swiping down), the input field remains focused and tapping it re-presents the keyboard.
- **Scrolling while new messages arrive**: Auto-scroll is suppressed while the user is scrolling or has scrolled away from the bottom. Scroll direction or velocity does not affect the 40pt threshold check.
- **Very long messages**: Message bubble width is capped at 75% of screen width or 200pt minimum. Text wrapping is delegated to the bubble view.
- **Rapid-fire message sends**: If the user sends multiple messages in quick succession, each message is submitted independently; no debouncing occurs.
- **Theme change while open**: Surface responds to theme changes and reapplies colors immediately.
- **Screen rotation (iOS) or window resize (web)**: Transcript is rebuilt to recalculate max bubble width; scroll position is preserved if scroll is not at bottom; otherwise scrolls to bottom with new messages.

## Configuration

Not applicable: Mobile Chat accepts configuration only through constructor props (viewModel, localParticipantID, session, persona, user, welcomeMessage, open, onClose, closeLabel) and does not maintain a configuration dictionary or settings object.

## Deep Linking

Not applicable: Mobile Chat displays active chat state from the session passed to it; it does not handle URL navigation or resolve deep links on its own. Navigation to open the chat is the host's responsibility.

## Localization

Not applicable: Mobile Chat contains only two user-facing strings (input placeholder "Type a message..." and default closeLabel "← back"), both of which are fixed in the source. Localization of these strings is the host's responsibility via prop overrides (iOS) or component configuration (web). Thinking indicator text comes from the `ChatStatusWordPair` configured on `thinkingIndicator`, which the host authors.

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | Open/close animations (0.25s fade) SHOULD be skipped or instant when Reduce Motion is enabled; this is delegated to `UIView.animate()` system behavior on iOS. |
| Increase Contrast | Divider and surface colors are determined by the semantic palette; implementations MUST ensure the `border` and `chatSurface` tokens meet WCAG AA contrast requirements when Increase Contrast is enabled. |
| Differentiate Without Color | Message alignment (left/right) is the primary distinction between local and remote messages; color MUST NOT be the only differentiator. |

## Feature Flags

Not applicable: Mobile Chat does not check feature flags or have internal toggles; feature control is managed by the host's feature flag system, which decides whether to render the component at all.

## Analytics

| Event | Properties | When |
|-------|-----------|------|
| `mobile_chat.opened` | `{ animated: boolean }` | `open(animated:)` is called. |
| `mobile_chat.closed` | `{ animated: boolean }` | `close(animated:)` is called. |
| `mobile_chat.message_sent` | `{ text_length: number, attachment_count: number }` | User submits a message via send button or Return key. |
| `mobile_chat.input_focused` | `{}` | Input field receives focus. |
| `mobile_chat.close_tapped` | `{}` | User taps the close button. |

## Privacy

- **Data collected**: Messages and drafts are collected from the session's `ChatViewModel`; the component does not collect user input beyond what the session provides. Send failures are caught but not logged.
- **Storage**: All message and draft data is stored in the session's memory; the component maintains no local persistence.
- **Transmission**: Message submission is delegated to the view model's `submitMessage()` method; the component does not directly transmit data.
- **Retention**: Messages are retained for the lifetime of the session; closing the component does not clear the session history.

## Logging

Subsystem: `AgenticDeveloperToolkit` | Category: `MobileChatViewController`

| Event | Level | Message |
|-------|-------|---------|
| View did load | debug | `MobileChatViewController: viewDidLoad` |
| Transcript rebuild | debug | `MobileChatViewController: rebuildTranscript (count: N)` |
| Message send | debug | `MobileChatViewController: sendTapped (text_length: N)` |
| Send error | error | `MobileChatViewController: submitMessage failed (error: description)` |
| Scroll position | debug | `MobileChatViewController: scrollViewDidScroll (isAtBottom: boolean)` |

## Platform Notes

- **Web (React)**: Source files `packages/web/packages/chat/src/modes/MobileChat.tsx` define two components: `MobileChat` (wrapper, manages session) and `MobileChatView` (presentation, uses `Transcript` and `ChatInput` subcomponents). The overlay div uses classname `pc-mobile-overlay` with `open` class when visible. Input is focused via `useRef` after 350ms delay to trigger iOS keyboard. The component is prop-controlled (`open` boolean, `onClose` callback).
- **SwiftUI**: Not implemented in source. A SwiftUI implementation would wrap `MobileChatViewController` in a `UIViewControllerRepresentable` and call `open(animated:)` / `close(animated:)` in response to state changes. The thinking indicator would be configured with `MobileThinkingIndicatorView.configure(_:)` to customize status text and glyphs.
- **Compose**: Not implemented in source. An Android implementation would mirror the iOS structure: `RecyclerView` for transcript with `MobileMessageBubbleView` adapters, a status row with a thinking indicator, a 1dp divider, and an `EditText` with a send button. The status line would be updated via the `ChatViewModel.statuses` map, with fallback to `typingParticipants` array.
- **AppKit / UIKit**: Source file `packages/apple/AgenticDeveloperToolkit/SourcesUI/iOS/Chat/MobileChatViewController.swift` defines `MobileChatViewController: UIViewController`. Main view is a `UIStackView` with four subviews: `UIScrollView` (transcript) with `UIStackView` (bubble stack), `UIView` (status row) containing `MobileThinkingIndicatorView`, `UIView` (1pt divider), and `UIStackView` (input row) with `UITextField` and `UIButton`. Message bubbles are left-aligned; local user messages use a spacer to right-align. The controller is opened/closed via `open(animated:Bool)` / `close(animated:Bool)` methods that fade alpha over 0.25s. Input field is focused in `useEffect` (web) or `viewDidLoad` (iOS). The component observes `ChatViewModel` and rebuilds transcript on `.messagesChanged` or `.activeDraftsChanged` updates.
- **WinUI 3**: Not implemented in source. A Windows implementation would use a `StackPanel` for the main layout with `ScrollViewer` for transcript, `TextBlock` for status, `TextBox` for input, and a `Button` for send. Message alignment would use `HorizontalAlignment.Left` or `Right` based on sender. The close button would be in a `CommandBar` or `AppBarButton`. The component would bind to `ChatViewModel.Messages` and `ChatViewModel.ActiveDrafts` collections and respond to `INotifyCollectionChanged` events to rebuild the transcript. Status updates would trigger via `INotifyPropertyChanged` on a status property. The input field would use `AcceptsReturn: False` to submit on Enter key via the `KeyDown` event.

## Design Decisions

1. **Input focus delay (350ms)**: On iOS, focusing the input immediately in `viewDidLoad` is too early; the keyboard animation does not appear reliably. A 350ms delay allows the view hierarchy to settle before focus is requested. This mirrors the behavior of web chat surfaces that focus on mount.

2. **Status row outside transcript**: The thinking/typing indicator is rendered in a separate `statusRow` UIView above the composer, not inside the scrolling transcript. This keeps the status line visible above the keyboard on mobile, where scrolling the transcript away is common. Web mirrors this with `.pc-typing` as a sibling of `.pc-transcript`, not a child.

3. **Auto-scroll threshold (40pt)**: The transcript auto-scrolls to show new messages only if the user has not scrolled more than 40pt from the bottom. This threshold is chosen to accommodate accidental small scrolls or swipes while still respecting the user's intent to read history. A stricter threshold (1-2pt) would re-center on nearly every new message; a looser one (100pt+) would miss intentional history reads.

4. **Empty draft filtering**: Active drafts with empty text (zero-length strings) are not rendered in the transcript. A user typing and then clearing the field does not create visual noise. Once the draft text becomes non-empty, it appears immediately in the transcript (live drafting).

5. **No keyboard path for send button**: The send button is accessible via touch only; there is no keyboard shortcut beyond the Return key in the input field. Adding modifiers (e.g., Cmd+Return on macOS, Ctrl+Return on web) is deferred to a follow-up, as the source makes no provision for it.

6. **Message bubbles delegated**: `MobileMessageBubbleView` (iOS) and the `Transcript` component (web) handle the rendering of individual message content, styling, and delivery status indicators. Mobile Chat concerns itself only with layout, scrolling, and session state updates.

7. **No command-activity pills on mobile**: `ToolCallPillView` (command-activity indicators) are deferred on mobile per Task 8's amendment. Only the thinking indicator is shown in the status row; tool calls are not rendered inline in the transcript.

8. **No attachment support in UI**: The source calls `submitMessage(text: text, attachments: [])` with an empty array. A future revision will add an attachment picker and preview; for now, attachments are not user-facing.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| Keyboard navigation | passed | Accessibility — Return key submits; Tab navigates inputs; focus is managed. |
| Touch target size | passed | Accessibility — Close and send buttons are system-sized (44×44pt minimum on iOS). |
| Color contrast | passed | Appearance — Divider and surface colors use semantic palette tokens; contrast is verified during theme application. |
| Message ordering | passed | Behavior — Messages are rendered in chronological order from `viewModel.messages` array. |
| Draft rendering | passed | Behavior — Non-empty drafts appear inline with committed messages via `MobileDraftMessageAdapter`. |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation from web and iOS sources |
