---
id: 46e0a509-8eac-460a-b24a-d39a8b71b02c
title: Message Bubble
domain: agenticdevelopercookbook://ingredients/message-bubble
type: ingredient
version: 1.0.0
status: review
language: en
created: 2026-09-22
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A themed chat message display for a single message with text, metadata, delivery
  state, and optional rich content.
platforms:
- swift
- typescript
- web
tags:
- chat
- messaging
- ui-component
depends-on: []
related: []
references: []
---

# Message Bubble

## Overview

A display component for a single chat message. Renders the sender's name (accessibility only), message text as markdown, timestamp, delivery status, and optionally rich content and tool-call indicators. The bubble's appearance (fill, border, text color) is determined by semantic theme roles: user vs. persona. Supports streaming (composing) and failed delivery states. On platforms with theme support, repaints live on theme change.

## Behavioral Requirements

- **must-render-sender-name**: The component MUST include the sender's name in the accessibility tree, even if it is not visually displayed.
- **must-render-text**: The component MUST render the message's text content.
- **must-display-timestamp**: The component MUST display the message's timestamp in the locale's preferred hour cycle and ordering, zero-padded to two digits.
- **must-show-composing-caret**: When `deliveryStatus` is `.composing`, the component MUST append a streaming caret character (U+258B) to the text.
- **must-show-failed-state**: When `deliveryStatus` is `.failed`, the component MUST display the failure reason and apply a failure border (1pt, danger color) to the bubble.
- **must-theme-by-sender-role**: The component MUST apply the appropriate semantic theme colors based on whether the sender is the local user or a persona.
- **must-size-to-content**: The component MUST measure its text content and size the bubble to fit without horizontal overflow at the maximum width constraint.
- **must-respect-theme-fill**: When a theme provides no fill (alpha ≤ 0.001), the component MUST render as a flat line (no background, no padding, no corner radius).
- **must-support-optional-border**: When a theme declares a bubble border role with visible alpha, the component MUST apply a 1pt border in the declared color.
- **may-render-rich-content**: The component MAY render rich content items (images, etc.) inline after the text.
- **may-show-detail-indicator**: The component MAY display an optional detail indicator (e.g., arrow) controlled by the caller.

## Appearance

- **Corner radius**: 12pt (when themed with fill; 0 when flat)
- **Padding**: 8pt vertical × 12pt horizontal (when themed with fill; 0 when flat)
- **Font**: Message text uses the theme's body font; timestamp uses caption font
- **Background**: Determined by theme (user bubble vs. persona bubble role)
- **Foreground/Text**: Determined by theme (user text vs. persona text role)
- **Border**: Optional, 1pt, declared by theme bubble border role; or 1pt danger color when failed
- **Shadow**: None in source
- **Min/Max size**: Bubble width constrained to a caller-provided maximum

## States

| State | Appearance change |
|-------|------------------|
| Default | Themed background, text in theme color, no border (unless theme declares one) |
| Streaming (composing) | Caret appended to text; on macOS, opacity does not change; streaming is a transient state |
| Failed | 1pt danger border; failure reason appended below text in caption font, danger color |
| Flat theme | No background fill, no padding, no corner radius; text sits flush with message container edge |
| Selected (web only) | `.pc-message-selected` class applied; appearance determined by theme CSS |

## Accessibility

- **Role**: Generic container (not a button or interactive control; the component itself is not focusable)
- **Label**: Sender name is provided via a visually-hidden span so screen readers announce who sent the message before reading the text
- **State announcement**: On platforms with theme repainting, delivery status changes (streaming, failed) are not announced; visual cues in text and border are the sole indicators
- **Minimum tap target**: Not applicable; this component is a display-only container, not an interactive control. Optional detail indicators provided by the caller SHOULD meet platform tap-target minimums
- **Color dependence**: Sender role (user vs. persona) is distinguished by color; themes that lack sufficient contrast or declare no fill may make the distinction unavailable to color-blind users. The component itself does not provide alternative cues (e.g., icon, position). Web implementation uses CSS classes that themes can override; Apple implementation checks theme's declared colors and geometry

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| bubble-001 | must-render-sender-name | Message with sender name "Alice" | Sender name appears in accessibility tree (screen reader announces "Alice:") |
| bubble-002 | must-render-text | Message text "Hello, world" | Text content appears in bubble |
| bubble-003 | must-display-timestamp | Message timestamp 2026-09-22T14:30:00 in en_US locale | Displays as "2:30 PM" (or equivalent in locale's preferred format) |
| bubble-004 | must-display-timestamp | Message timestamp 2026-09-22T09:05:00 in en_US locale | Displays as "9:05 AM" with zero-padded hour |
| bubble-005 | must-show-composing-caret | Message with deliveryStatus .composing | Caret U+258B appended to text |
| bubble-006 | must-show-failed-state | Message with deliveryStatus .failed("Network error") | 1pt danger border on bubble; failure reason appears below text in caption font |
| bubble-007 | must-theme-by-sender-role | Message from local user | Bubble uses userBubble theme role; text uses userText role |
| bubble-008 | must-theme-by-sender-role | Message from persona | Bubble uses personaBubble theme role; text uses personaText role |
| bubble-009 | must-size-to-content | Long message text that wraps at maxWidth 300pt | Bubble width is ≤ 300pt; text wraps without overflow |
| bubble-010 | must-respect-theme-fill | Theme with personaBubble.alpha ≤ 0.001 | No background fill, no padding, no corner radius |
| bubble-011 | must-support-optional-border | Theme declares personaBubbleBorder with alpha > 0.001 | 1pt border in declared color appears on bubble |
| bubble-012 | must-support-optional-border | Theme does not declare bubble border role | No border (or default transparent) |
| bubble-013 | may-render-rich-content | Message with content array [image1, image2] | Rich content items appear after text |
| bubble-014 | may-render-rich-content | Message with empty content array | No rich content rendered |

## Edge Cases

- **Empty text**: Message with empty or nil text still renders the sender name, timestamp, and any rich content or failure reason.
- **Missing timestamp**: Message with nil timestamp omits the timestamp line; bubble still renders text and other content.
- **Long text**: Text that exceeds maxWidth wraps and the bubble expands vertically; measurement ensures bubble is never wider than maxWidth.
- **Very short text**: Single character or emoji render at minimum bubble width; padding is applied normally.
- **Theme change during rendering**: On platforms with live theme repainting (Apple), the bubble repaints synchronously; caller is responsible for triggering repaints when theme changes.
- **Flat theme transition**: When a theme's fill alpha transitions from > 0.001 to ≤ 0.001 (or vice versa), padding and corner radius update; no animation in source.
- **Multiple delivery statuses**: Component handles one status per render; if a message transitions from composing to failed, the bubble must be re-rendered with the new status.
- **Rich content load delay**: Web implementation returns nil (does not render) until all images in rich content are loaded; callers must handle the case where the component is not yet mounted.
- **Avatar/sender mark**: Avatar div is always rendered but may be empty when sender has no avatar; themes can use `.pc-avatar:empty` to style the empty case.

## Configuration

Not applicable: This is a display component with no configurable options. Appearance and behavior are determined by the caller-provided message data and active theme.

## Deep Linking

Not applicable: Message bubbles are display elements within a conversation view, not standalone deep-linkable destinations.

## Localization

| String Key | Default (en) | Context |
|-----------|-------------|---------|
| Detail button label (web) | "Show details" | Aria label for optional detail arrow button |
| Failure label (web, macOS, iOS) | None; reason text is provided by caller | Failure reason is embedded in message.deliveryStatus; no localized template |

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | Streaming caret and state transitions are not animated in source; no change needed |
| Increase Contrast | Component respects theme colors; themes that support high-contrast modes will render at increased contrast automatically. Caller is responsible for ensuring theme provides sufficient contrast |
| Differentiate Without Color | Component uses color to distinguish user vs. persona; themes that support this mode must provide additional visual cues (position, icon, typography). Component does not enforce this |

## Feature Flags

Not applicable: Component has no feature flags in source.

## Analytics

Not applicable: Component is display-only with no user interaction. Optional interactive elements (detail arrow) are left to the caller to track.

## Privacy

Not applicable: Component renders data provided by caller; it does not collect, transmit, or store any data.

## Logging

Not applicable: Component has no logging in source.

## Platform Notes

- **Web** (React/TypeScript): `MessageBubble.tsx` uses semantic HTML (`div`, `button`, `span`) with CSS classes for styling. Avatar and visually-hidden sender name are wrapped separately. Tool call pills are rendered inline. Detail arrow is a button with `aria-label`. Timestamp is inline in caption font. Failure reason is in a `div role="alert"`. Rich content and connector anchors are conditionally rendered. All styling deferred to CSS in `base.css` and theme files.

- **SwiftUI**: No source provided. Start from SwiftUI's `VStack` or similar container. Use `@Themeable` protocol (Apple sources pattern) to observe theme changes and repaint. Measure text with SwiftUI's text layout APIs or adapt the AppKit measurement strategy. Support `.composing` and `.failed` delivery statuses with appended attributed text. Render sender name in an accessibility modifier (`.accessibilityElement(children: .combine)` or label-only). Optionally support flat themes by conditionally applying padding and corner radius.

- **Compose** (Android/Kotlin): No source provided. Start from a `Surface` or `Card` composable for the bubble container. Use Material Design 3 color roles and typography. Support streaming and failed states by composing state-specific text modifiers. Measure text with `TextMeasurer` or similar. Render sender name in `Semantics` modifier for accessibility. Respect theme palette changes via `LocalCompositionLocals` or similar composition local. Consider supporting flat themes by conditionally omitting `Surface` background and padding.

- **AppKit / UIKit** (macOS/iOS): Source `MessageBubbleView` (macOS) and `MobileMessageBubbleView` (iOS) use `NSView` / `UIView` with theme observer pattern. Both measure text at `applyTheme` time and apply measurement as layout constraint constants. macOS uses `NSTextView` for selectable text; iOS uses `UILabel`. Timestamp on macOS spans a new line with right-alignment for user, left for persona; iOS inlines it with two-space separator and hard-coded "HH:mm" format (not locale-aware). Both use `NSAttributedString` to build themed text with markdown renderer. Streaming caret and failure reason are appended to the attributed string. Failure border is 1pt on `layer`. Flat themes are detected by checking theme's fill alpha; padding and corner radius are zeroed when flat.

- **WinUI 3** (Windows): Start from a `StackPanel` (vertical) or nested grid for layout. Use WinUI's `TextBlock` for sender name (set `Visibility="Collapsed"` and add automation properties for accessibility). Use `RichTextBlock` or `TextBlock` for message text (wrap enabled). Add a `TextBlock` for timestamp below text. For failed state, add a `Border` element around the bubble with `BorderBrush` bound to a danger color theme resource; append a `TextBlock` for the failure reason. For streaming state, append the caret character to the text. Apply `CornerRadius` to the bubble container (StackPanel or Grid wrapped in a Border). Support theme changes by binding `Background`, `Foreground`, and `BorderBrush` to theme resource dictionaries; update bindings when theme changes. Measure text width using `TextBlock.ActualWidth` after layout pass or use `TextRenderingCore` APIs if available.

## Design Decisions

**Streaming caret character (U+258B ▋)**: Chosen as a non-animated, easily measured block that fits inline with text. No animation is applied; the caret is static in the current implementation. Provides visual feedback that the message is still being composed without requiring animated state changes.

**Timestamp formatting**: macOS uses locale-aware `DateFormatter` with pattern derivation to respect the locale's preferred hour cycle and separator; iOS uses hard-coded "HH:mm" (24-hour). Web uses `toLocaleTimeString` with 2-digit hour and minute, also locale-aware. This disparity is a source quirk; implementations MAY unify to locale-aware formatting.

**Failure reason**: Rendered as appended text rather than a separate element or icon. Provides context (what went wrong) beyond the visual border cue. Reason is caller-provided via `deliveryStatus.failed(reason)`.

**Flat themes**: Themes that provide no fill (alpha ≤ 0.001) are treated as "no bubble" — padding and corner radius are zeroed to render a flat transcript line. This is intentional to avoid invisible boxes in themes like `terminal` or `crt-monitor` that deliberately omit bubble styling.

**Avatar and sender name placement**: Avatar is always rendered (even if empty) to maintain consistent left-edge alignment across messages. Sender name is visually hidden but available to accessibility tree. This avoids the alignment problem of conditionally showing/hiding the avatar div.

**Rich content loading**: Web implementation defers rendering until all images are loaded (returns nil if not loaded). This is a source quirk; callers must handle the case where the component is unmounted while loading.

**Bubble border**: Optional border (distinct from failure border) is supported by checking if the theme *declares* a border role, not merely if resolving it produces a visible color. This avoids hairline borders in themes that did not explicitly declare one.

## Compliance

Not applicable: Component does not implement security-critical operations, authentication, or compliance-specific behaviors. Accessibility is addressed in the Accessibility section.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation from web, macOS, and iOS sources |
