---
id: 1794948f-2bb2-4f25-b9b5-72b1e6306ea1
title: Inline Chat
domain: agenticdevelopercookbook://recipes/ui/inline-chat
type: ingredient
version: 1.0.0
status: review
language: en
created: 2026-09-22
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Scrolling message transcript with typing indicator and single-line composer
  for inline chat interactions.
platforms:
- typescript
- web
- swift
- macos
tags:
- chat
- messaging
- transcript
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Inline Chat

## Overview

An inline chat surface that displays a transcript of committed and in-flight messages, a typing/thinking indicator, and a single-line text input with send affordance. The component sits in a fixed or resizable container, supports engagement-driven sizing (expanding on focus, collapsing when idle), and renders participants' messages on opposite sides (local user on the right, remote on the left). Web source: `packages/web/packages/chat/src/modes/InlineChat.tsx`. Apple source: `packages/apple/AgenticDeveloperToolkit/SourcesUI/macOS/Chat/InlineChatView.swift`.

## Behavioral Requirements

- **must-render-messages**: Component MUST render an ordered list of committed messages with their full text, preserving order and vertical spacing of 12pt (Apple) or frame default (web).
- **must-render-drafts**: Component MUST render in-flight drafts (active message compositions) inline with committed messages using the same bubble styling.
- **must-align-by-participant**: Component MUST render local participant's messages aligned to the right with a leading spacer (≥60pt on Apple); remote participants' messages aligned to the left.
- **must-render-thinking-indicator**: Component MUST display a thinking indicator above the input field while any remote participant has an active status or `isTyping` is true.
- **must-render-input-field**: Component MUST display a single-line text input field with a send affordance (button or shortcut) that clears on successful submission.
- **must-submit-on-return**: Component MUST submit the input text when the user presses Return (web Enter, Apple ⏎).
- **must-trim-whitespace**: Component MUST reject submission of input containing only whitespace and newlines.
- **must-scroll-to-bottom**: Component MUST auto-scroll the transcript to the bottom when a new message arrives, unless the user has scrolled up (Apple tracks `isAtBottom` with 40pt threshold).
- **must-track-scroll-position**: Component MUST maintain an `isAtBottom` flag, setting it false when the transcript scrolls >40pt away from the bottom and true when within 40pt of bottom.
- **must-support-sizing-behavior**: Component MUST accept a sizing configuration defining active and optional inactive height behaviors (`fixed`, `content-hugging`, `minimal`), applied immediately and retained across rebuilds.
- **must-animate-sizing-transitions**: When `sizing.transition` is `animated`, component MUST apply 0.2s duration sizing transitions between active and inactive states; when `none`, apply instantly.
- **must-track-engagement**: Component MUST track an internal `engaged` state: true when the input field has focus, false on Escape or click outside the view (web `focusin`/`pointerdown`/`Escape` triad; Apple focus/click/Escape).
- **must-apply-engaged-sizing**: Component MUST apply `sizing.active` when `engaged` is true and `sizing.inactive` when false (defaulting to `active` if `inactive` is omitted, reproducing fixed sizing).
- **must-collapse-to-minimal**: When `inactive` sizing is `{ mode: 'minimal' }`, component MUST hide the transcript and display only the input row on disengage; re-expand to active size on re-engage.
- **must-hide-transcript-when-minimal**: When resolved sizing behavior is `.minimal`, component MUST set the transcript height constraint to exactly 0 and hide the scroll view.
- **must-respect-max-width**: Component MUST constrain message bubbles to 75% of the transcript scroll view width, with a minimum of 200pt (Apple).
- **must-render-think-status**: Component MUST display thinking indicator text as configured via `thinkingLabels` (web) or `thinkingIndicator.configure(_:)` (Apple), or fall back to three pulsing dots if not configured.
- **must-render-think-glyph**: When `thinkingFrames` or `thinkingDoneGlyph` are provided, component MUST render the rotating glyph animation (think phase) and settled glyph (done phase) from those frames.
- **must-support-status-utterance**: Component MUST display `statusUtterance` (web) or `status.utterance` (Apple) as a transient override of the current thinking indicator text.
- **must-support-idle-phrase**: Component MUST display `idlePhrase` when no remote participant is active and no `statusUtterance` is set.
- **must-stream-while-thinking**: When `statusWhileStreaming` is true, component MUST keep the thinking indicator animating while a reply is streaming in (not only while awaiting first token).
- **should-fade-older**: Component SHOULD dim each older message proportionally less bright than the one below it when `fadeOlder` is true; dimming is optional if not set.
- **must-disable-input**: When `inputDisabled` is true, component MUST render the input field but prevent typing and submission (web `disabled` prop; Apple `inputField.isEnabled = false`).
- **must-support-placeholder**: Component MUST display an optional placeholder string in the input field (web prop, Apple via `chrome.inputPlaceholder`).
- **must-support-custom-prompt**: Component MUST render an optional prompt glyph before the input (web `❯`, Apple via `chrome.promptGlyph`).
- **must-support-custom-send-glyph**: Component MUST render an optional custom send glyph/button text (web N/A; Apple via `chrome.sendGlyph`), falling back to SF symbol `arrow.up.circle.fill`.
- **should-render-input-divider**: Component SHOULD render a divider (1pt line) between the typing indicator row and input row when configured (Apple `chrome.showsDivider`).
- **must-support-backdrop**: Component MUST accept an optional backdrop view (Apple `backdrop` property) pinned to all edges, positioned below all other content, and hidden/shown without cost when `showsBackdrop` toggles.
- **must-start-stop-animated-backdrop**: If a backdrop conforms to `AnimatedBackdrop`, component MUST start its animation when `showsBackdrop` becomes true and stop it when false.
- **must-support-surface-transparency**: Component MUST apply `surfaceTransparency` (0–100) as a multiplier on the theme's surface color alpha, thinning the surface fill without affecting text or chrome (Apple).
- **must-support-text-scale**: Component MUST respond to ⌘+, ⌘−, and ⌘0 keyboard events (Apple only) and fire `onTextScaleNudge` callback with +1, −1, or 0 (Apple); scaling applies only to the chat's own `themeScope`, not globally.
- **must-text-scale-require-focus**: Text scale shortcuts MUST only work when the input field is enabled and has focus.
- **must-render-theme-scope**: Component MUST resolve its color palette through a dedicated `themeScope` instance separate from the window's, allowing independent text-size control per chat instance.
- **must-render-command-activity**: Component MUST render command activity (tool invocations) as `ToolCallPillView` rows below the transcript, above the thinking indicator, in invocation order (Apple).
- **should-handle-send-errors**: Component SHOULD catch and handle errors from `submitMessage` without crashing or surfacing the error (Apple: silently ignored); web behavior undefined from source.

## Appearance

- **Transcript container**: Transparent background (Apple `drawsBackground = false`), vertical NSStackView with 12pt line spacing (Apple) or CSS gap default.
- **Transcript insets**: 20pt vertical, 16pt horizontal (Apple edges `NSEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)`).
- **Transcript scrollbar**: Vertical scrollbar shown (Apple `hasVerticalScroller = true`); style per platform default.
- **Message bubbles**: Bubble views use `MessageBubbleView` (Apple) or `Transcript` component (web); max width 75% of scroll container (min 200pt); aligned right for local user, left for remote.
- **Bubble spacing**: 12pt vertical gap between consecutive bubbles (Apple `transcriptStack.spacing = 12`).
- **Bubble side inset**: 16pt left and right margin outside bubble (Apple `Self.bubbleSideInset = 16`).
- **Thinking indicator**: Single row above input, inset 12pt left and right (Apple); text and animation per `ThinkingIndicatorView`.
- **Typing indicator animation**: Three pulsing dots (default) or custom glyph rotation.
- **Input row height**: Minimum 44pt touch target (Apple send button 18pt SF symbol + padding).
- **Input row insets**: 14pt vertical, 16pt horizontal (Apple `NSEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)`).
- **Input field**: Single-line text view with optional corner radius (Apple `chrome.inputCornerRadius`), optional 1pt border (Apple `chrome.showsInputBorder`), block or bar caret per `blinksCaret` setting.
- **Input field placeholder**: Text and color per input styling; default `placeholder` prop value.
- **Prompt glyph**: "❯" (U+276F) by default (Apple), positioned left of input with baseline-drop alignment to center glyph ink on text center; hidden if not configured (Apple `chrome.promptGlyph == nil`).
- **Prompt text color**: User text color from palette (Apple `palette.nsColor(.userText)`).
- **Send button**: Icon `arrow.up.circle.fill` (18pt regular, Apple) or custom glyph; tint per `palette.nsColor(.sendButton)`.
- **Divider**: 1pt line between typing row and input row (Apple `ThemedSeparatorView`); hidden if not configured (Apple `chrome.showsDivider`).
- **Surface fill**: Opaque background color from theme palette (Apple `palette.nsColor(.chatSurface)`), thinned by `surfaceTransparency` multiplier.
- **Backdrop**: Optional NSView behind surface, click-through, pinned to all edges.
- **Min content width**: 432pt (Apple `minBubbleWidth 200 + 2×bubbleSideInset 16 = 232`... recalc: `200 + 2*16 = 232`. Source says `minContentWidth = minBubbleWidth + bubbleSideInset * 2 = 200 + 16*2 = 232pt`).

## States

| State | Appearance change |
|-------|------------------|
| Default (idle, not engaged) | Transcript at active height, input visible, no focus ring. |
| Engaged (focused, interacting) | Input field has focus ring (platform-dependent); if `inactive` sizing set, transcript expands to active height with 0.2s animation (or instant if `transition: 'none'`). |
| Thinking (remote typing/status) | Thinking indicator animates (dots or custom glyph rotation). |
| Streaming (reply incoming) | If `statusWhileStreaming`, thinking indicator continues animating while transcript updates. |
| Minimal (collapsed, inactive) | Transcript height exactly 0 and hidden; input row remains visible and enabled. |
| Input disabled | Input field renders but does not accept input or send; visual state per platform disabled appearance. |
| Backdrop shown/hidden | Backdrop view visible or hidden; if animated, animation runs or stops. |

## Accessibility

- **Role**: Chat interface / message list. Apple: NSView with `ChatStateObserver` and focus tracking; web: generic div with role deferred to children.
- **Keyboard navigation**: Tab navigates to send button; Return submits from input field; Escape disengages (Apple only).
- **Focus indicators**: Input field displays focus ring when active (platform default).
- **Labels**: Placeholder text in input field conveys purpose; send button has accessibility description (Apple "Send").
- **Screen reader**: Thinking indicator announces "Thinking" or configured status text; message bubbles read via child components (`MessageBubbleView` on Apple, `Transcript` on web).
- **Participant side**: Bubbles are visually separated by side (right = local, left = remote); no explicit role mapping.
- **Minimum tap target**: Send button 18pt (Apple SF symbol, >44×44pt); input field assumed ≥44pt height.
- **Status announcement**: Typing indicator state changes (appears/disappears, text updates) should be announced; implementation deferred to `ThinkingIndicatorView`.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| inline-chat-001 | must-render-messages | Add 3 committed messages to session | All 3 render in order in transcript, spaced 12pt apart |
| inline-chat-002 | must-render-drafts | Add 1 draft with text and 1 committed message | Draft and message both render as bubbles; draft shows composing state |
| inline-chat-003 | must-align-by-participant | 1 local message, 1 remote message | Local on right with spacer, remote on left |
| inline-chat-004 | must-render-thinking-indicator | Set remote participant typing=true | Thinking indicator appears above input with animation |
| inline-chat-005 | must-render-input-field | Render component | Input field and send button visible, input accepts text |
| inline-chat-006 | must-submit-on-return | Type "hello" in input, press Return | Message sent, input cleared |
| inline-chat-007 | must-trim-whitespace | Type "   " (spaces/newlines), press Return | Submission rejected, input not cleared |
| inline-chat-008 | must-scroll-to-bottom | Scroll to top, add new message | Transcript auto-scrolls to show new message |
| inline-chat-009 | must-track-scroll-position | User scrolls 50pt from bottom | isAtBottom = false |
| inline-chat-010 | must-support-sizing-behavior | Set sizing.active to fixed(200pt), sizing.inactive to minimal | On engage, fixed applied; on disengage, minimal applied |
| inline-chat-011 | must-animate-sizing-transitions | Set transition to animated, disengage | Sizing change animates over 0.2s |
| inline-chat-012 | must-track-engagement | Click input field | engaged = true |
| inline-chat-013 | must-track-engagement | Click outside view | engaged = false |
| inline-chat-014 | must-track-engagement | Press Escape | engaged = false |
| inline-chat-015 | must-apply-engaged-sizing | Set inactive, disengage | Sizing transitions to inactive |
| inline-chat-016 | must-collapse-to-minimal | Set inactive to minimal, disengage | Transcript height = 0, hidden |
| inline-chat-017 | must-respect-max-width | Set scroll width to 600pt, add long message | Bubble capped at 450pt (75% of 600) |
| inline-chat-018 | must-render-think-status | Set thinkingLabels to [("think", "🤔")] | Indicator displays "🤔 think" |
| inline-chat-019 | must-render-think-glyph | Provide thinkingFrames = [glyph1, glyph2] | Glyphs rotate in thinking indicator |
| inline-chat-020 | must-support-status-utterance | Set statusUtterance to "Generating..." | Indicator displays "Generating..." (overrides think text) |
| inline-chat-021 | must-support-idle-phrase | Set idlePhrase to "Ready", no remote activity | Indicator displays "Ready" |
| inline-chat-022 | must-stream-while-thinking | Set statusWhileStreaming=true, reply streaming | Thinking indicator continues animating during reply |
| inline-chat-023 | should-fade-older | Set fadeOlder=true, add 3 messages | Messages progressively dimmer from bottom to top |
| inline-chat-024 | must-disable-input | Set inputDisabled=true | Input renders but does not accept text or send |
| inline-chat-025 | must-support-placeholder | Set placeholder="Ask anything..." | Input displays placeholder text when empty |
| inline-chat-026 | must-support-custom-prompt | Set chrome.promptGlyph to "›" | Prompt displays "›" before input |
| inline-chat-027 | must-support-custom-send-glyph | Set chrome.sendGlyph to "✉️" | Send button displays "✉️" |
| inline-chat-028 | should-render-input-divider | Set chrome.showsDivider=true | 1pt line visible between thinking row and input row |
| inline-chat-029 | must-support-backdrop | Set backdrop to NSView | Backdrop visible behind content |
| inline-chat-030 | must-start-stop-animated-backdrop | Set backdrop to animated view, toggle showsBackdrop | Animation runs when shown, stops when hidden |
| inline-chat-031 | must-support-surface-transparency | Set surfaceTransparency=50 | Surface fill alpha = theme alpha × 0.5 |
| inline-chat-032 | must-support-text-scale | Press ⌘+ while input focused (Apple) | onTextScaleNudge fires with +1 |
| inline-chat-033 | must-text-scale-require-focus | Press ⌘+ without input focus (Apple) | onTextScaleNudge not fired |
| inline-chat-034 | must-render-theme-scope | Set chat text scale to 150%, open another chat | Only this chat is 150%; other chat unchanged |
| inline-chat-035 | must-render-command-activity | Add tool invocation to commandActivity | ToolCallPillView renders below transcript |

## Edge Cases

- **Empty messages list**: Component renders transcript container with no bubbles; only typing indicator and input visible.
- **Very long messages**: Bubbles respect max width (75% or 200pt floor) and wrap or truncate per `MessageBubbleView` behavior.
- **Rapid message arrivals**: Multiple messages added in single update trigger one `rebuildTranscript()` pass, auto-scroll once to final bottom.
- **Concurrent local and remote typing**: Thinking indicator prioritizes remote participant statuses (sorted by ID) over local typing flag.
- **Draft with no text**: Drafts with empty `text` are filtered out and not rendered (Apple: `where !draft.text.isEmpty`).
- **Window resize during engagement**: Transcript width change triggers rebuild on next layout pass; `lastTranscriptWidth` comparison prevents redundant rebuilds.
- **Click outside while composing**: Escape key disengages immediately; click outside (Apple) disengages only if `engaged=true` and click lands outside view bounds.
- **Text scale nudge without handler**: If `onTextScaleNudge` is nil, shortcuts are passed to parent responder chain (Apple).
- **Backdrop added/removed**: Old backdrop unsubscribed from animation, constraints removed; new backdrop positioned and optionally animated.
- **Missing viewport measurements**: Apple's `capHeight` method returns 0 if `bounds.height` is still zero (initialization), preventing negative constraints; web sizing deferred until layout.
- **Focus moving to transcript**: Apple's `shouldStayEngaged` check prevents disengagement if click lands in scrollable transcript (stays engaged while reading).
- **Offline status updates**: Status changes from `nil` to a `ChatStatus` or vice versa trigger `refreshStatus()` only, not full rebuild (performance optimization).

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `session` / `viewModel` | ChatSession / ChatViewModel | required | Active chat session or view model binding |
| `sizing` | InlineChatSizing | `{ active: { mode: 'fixed' } }` | Size behavior active/inactive and transition |
| `placeholder` | string | none | Placeholder text in input field |
| `thinkingLabels` | StatusWordPair[] | dots | Custom words and icons for thinking indicator phases |
| `thinkingFrames` | string[] | none | Glyph frames for rotating thinking animation |
| `thinkingDoneGlyph` | string | none | Settled glyph shown after thinking completes |
| `thinkingColorful` | boolean | false | Rotate through random non-green colors while thinking (Apple) |
| `thinkingTint` | StatusTintSpec | none | Which elements (glyph/words/both) are tinted |
| `statusWhileStreaming` | boolean | false | Keep thinking indicator animating during reply stream |
| `idlePhrase` | string | none | Status text shown when no remote activity |
| `statusUtterance` | string \| null | none | Transient status override (takes precedence) |
| `inputDisabled` | boolean | false | Render input but block typing and sending |
| `fadeOlder` | boolean | false | Dim older messages proportionally (web only) |
| `chrome` | InlineChatChrome | defaults | Prompt glyph, send glyph, divider, caret style, border, corner radius, placeholder (Apple) |
| `blinksCaret` | boolean | true | Block caret blinks or stays solid (Apple) |
| `backdrop` | NSView | none | Optional animated or static backdrop (Apple) |
| `showsBackdrop` | boolean | true | Backdrop visibility toggle (Apple) |
| `surfaceTransparency` | number | 0 | Surface opacity reduction 0–100% (Apple) |
| `onTextScaleNudge` | (Int) → Void | none | Callback for ⌘+/−/0 text scale adjustments (Apple) |
| `localParticipantID` | string | required | Participant ID for local user to determine bubble side (Apple) |

## Deep Linking

Not applicable: Component has no deep-linking protocol or URL routing requirements.

## Localization

Not applicable: Component renders only user-provided text (messages, placeholders, status words); no built-in strings requiring translation.

## Accessibility Options

Not applicable: Component does not implement platform accessibility display options (Reduce Motion, Increase Contrast, Differentiate Without Color); these are expected to be handled by the underlying theme palette and component library (Apple's `ThemeScope`, web's CSS framework).

## Feature Flags

Not applicable: Component is always enabled; feature flags are application-level concerns, not component-level.

## Analytics

Not applicable: Component does not emit analytics events; analytics instrumentation is delegated to the session/view-model layer and application observability stack.

## Privacy

Not applicable: Component displays user-provided message content and typing activity; no data collection, transmission, or storage is performed by the component itself.

## Logging

Not applicable: Component does not perform logging; the Swift source includes detailed comments indicating debug points (e.g., engagement triad, sizing behavior, text-scale nudges) that could be instrumented by wrapping code, and web version is similarly transparent to caller logging.

## Platform Notes

- **Web**: Renders via `InlineChatView` and `InlineChat` React components. Sizing behavior managed by `useChatSizing` hook. Transcript scrolling via CSS `overflow-y: auto`. Input is standard `<input>` or `<textarea>` with `onKeyDown` for Return. Thinking indicator uses SVG or CSS animation for rotating glyph; web does not implement status-while-streaming, input-disabled styling, or text-scale shortcuts—those are application-level concerns.
- **SwiftUI**: No direct SwiftUI implementation present in source. A SwiftUI binding would wrap the AppKit `InlineChatView` via `NSViewRepresentable`, passing `@ObservedObject viewModel: ChatViewModel` and `@State var sizing`, or use SwiftUI's native component set if one exists. Custom styling via SwiftUI `.modifier()`.
- **Compose**: No Compose implementation present in source. On Android, analogous component would use `LazyColumn` for transcript with `Message` composables, `TextField` for input, `Spacer(Modifier.weight(1f))` for bottom-align behavior. Sizing transitions via `animateContentSize()` modifier. Thinking indicator animation via `AnimatedVisibility` and `Animatable`.
- **AppKit / UIKit**: Apple source provides AppKit (`NSView`, `NSStackView`, `NSTextField`, `NSScrollView`). For iOS/UIKit, replace `NSView` → `UIView`, `NSStackView` → vertical `UIStackView`, `NSScrollView` → `UIScrollView`, `NSTextField` → `UITextView` or `UISearchBar`. Layout via `NSLayoutAnchor`/`NSLayoutConstraint` (AppKit) or `NSLayoutAnchor` (UIKit iOS 9+). Text scale shortcuts not available on iOS; implement via pinch gesture or buttons instead. Engagement tracking: replace `NSEvent.addLocalMonitor` with `UIGestureRecognizer` (tap outside) and responder chain (Escape via `UIKeyCommand`).
- **WinUI 3**: Use `Microsoft.UI.Xaml.Controls.ListView` for transcript with `ItemsSource` binding to messages. Implement sizing transitions via `Storyboard` animation with 0.2s duration. Input via `TextBox` with `AcceptsReturn="False"` and `KeyDown` event handler for submission. Thinking indicator via custom control with `DispatcherTimer`-driven glyph animation. Message bubbles as templated `ListViewItem`s with conditional alignment via `HorizontalAlignment` (participant ID → Right/Left). Command pills as `ItemsControl` rows below transcript.

## Design Decisions

- **One surface fill painted once**: The chat surface (`palette.nsColor(.chatSurface)`) is rendered exactly once at the root view level (Apple `applyTheme`), not repeated by sub-containers. This prevents stacking opacity when the surface is translucent and ensures `surfaceTransparency` multiplier applies to a single layer.
- **Engagement-driven sizing is opt-in**: The component defaults to fixed sizing (today's behavior: `>= 200pt` minimum height). Engagement tracking and dynamic sizing only activate when `sizing.inactive` is explicitly set; this preserves backward compatibility for call sites that do not need collapsing behavior.
- **Minimal mode uses exact zero, not `isHidden`**: The transcript height constraint is set to exactly 0 (not `greaterThanOrEqualToConstant: 0`) because `isHidden` alone leaves constraints active, causing the transcript to retain its old height behind the hidden view.
- **Block caret blinking is separate from chrome**: `blinksCaret` is a user-preference setting (per-reader), not a theme opinion. `chrome.usesBlockCaret` is a design-system choice (per-theme). This separation allows a theme to prefer block carets while the reader disables blinking.
- **Status prioritizes remote statuses over typing flag**: When multiple participants are active, `refreshStatus()` sorts remotes by ID and uses the first status value. The local participant's `isTyping` flag becomes a fallback only if no remote has an explicit status—this avoids echoing the user's own activity back at them (web design pattern).
- **Click-outside detection uses local monitor**: Apple's `NSEvent.addLocalMonitorForEvents(matching: .leftMouseDown)` is used instead of a global monitor because the component belongs to a specific window and should not disrupt the rest of the application.
- **Prompt baseline drop is computed, not hard-coded**: The prompt glyph (❯) and composed text have different font families and widths, so centering on a shared baseline does not center the ink. The `PromptGlyphAlignment.baselineDrop()` method derives the constant per font at every theme and text-scale change.
- **Drafts render through same bubble as messages**: In-flight `ActiveDraft`s are adapted to the `Message` protocol (`DraftMessageAdapter`) so they reuse the same `MessageBubbleView` styling logic, reducing duplication and keeping draft appearance in sync with messages.
- **Auto-scroll tolerance is 40pt**: The `isAtBottom` threshold is 40pt (Apple) to allow minor scroll bounce and interaction without triggering false "scrolled away" state while still stopping auto-scroll if the user deliberately scrolls to read history.
- **Thinking indicator is not in scrolling transcript**: The status row (typing indicator) sits between the transcript scroll view and the input row—not inside the transcript. This keeps the status line always visible at eye level where the user is typing, even on a long conversation.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| [touch-click-targets](agenticdevelopercookbook://guidelines/implementing/ui/touch-click-targets) | passed | Accessibility |
| [keyboard-navigation](agenticdevelopercookbook://guidelines/implementing/ui/keyboard-navigation) | partial | Accessibility—web keyboard navigation not fully specified in source |
| [screen-reader-support](agenticdevelopercookbook://guidelines/implementing/ui/screen-reader-support) | partial | Accessibility—delegated to child components and theme scope |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation from web and Apple sources |
