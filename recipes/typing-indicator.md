---
id: 7d2b41f0-63aa-47d1-94f8-19a06caedc6a
title: Typing Indicator
domain: agenticdevelopercookbook://ingredients/typing-indicator
type: ingredient
version: 1.0.0
status: review
language: en
created: 2026-09-22
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A visual indicator showing that a persona is composing a response, with support
  for animated status words and phase-driven transitions.
platforms:
- typescript
- web
- swift
- macos
- ios
tags:
- chat
- indicator
- animation
- status
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Typing Indicator

## Overview

The typing indicator displays an active typing or thinking status during persona response generation. It has two rendering paths: a fallback three-dot pulsing animation when no custom status words are configured, or a phase-driven animated line with rotating braille glyphs, status words, and elapsed-time feedback when vocabulary is provided. The component is themed from the active semantic palette and repaints live on theme change.

## Behavioral Requirements

- **must-support-two-rendering-paths**: The component MUST support two distinct rendering paths selected by whether status words are configured. When no words are provided (empty or default configuration), it MUST render a three-dot pulsing animation. When words are configured, it MUST render a phase-driven line with an animating glyph and rotating status word.

- **must-render-dots-pulse-when-inactive**: In the three-dot rendering path, when the typing status is inactive (false or null), the component MUST NOT render any visual indicator.

- **must-render-dots-pulse-when-active**: In the three-dot rendering path, when the typing status is active (true or non-null), the component MUST render three circular dots that animate sequentially by fading to full opacity while others fade to 30% opacity on a 0.35-second cycle.

- **must-cycle-through-status-words**: When status words are configured, the component MUST cycle through the provided word list using draw-without-replacement (each word in the vocabulary is shown once before any word repeats). The transition to a new word MUST occur on the `labelMs` interval (default 1800ms).

- **must-animate-glyph**: The component MUST animate a rotating glyph character on the `frameMs` interval (default 260ms). The glyph cycles through the provided frame array in order.

- **must-support-phase-machine**: The component MUST drive phase transitions (idle, thinking, utterance, done) using a shared phase machine that tracks when a turn begins and ends, manages word bag state, and calculates elapsed time.

- **must-show-active-line-while-typing**: When the phase is "thinking" (during active response generation), the component MUST display the current glyph followed by a space and the current status word with an ellipsis (e.g., "⠙ thinking…"). The text MUST use the `.personaName` color by default.

- **must-show-utterance-when-provided**: When an utterance is provided (caller-set transient text), the component MUST display it immediately with the animating glyph, overriding any phase-driven content. The utterance MUST persist only until explicitly cleared by the caller.

- **must-show-settled-line-when-done**: When the phase is "done" (the active turn has ended), the component MUST display the done glyph followed by a space, the past-tense form of the last status word, and elapsed seconds in the format "[glyph] [past word] for [N]s". This line MUST use the `.thinkingDoneText` color and MUST NOT be tinted by the `colorful` or `tint` configuration options.

- **must-show-idle-phrase-when-configured**: When an idle phrase is configured and the phase is "idle" (before the first turn), the component MUST display the idle phrase with the done glyph and an ellipsis using `.thinkingIdleText` color.

- **must-not-show-idle-phrase-when-not-configured**: When no idle phrase is configured, the component MUST render no visual indicator during the idle phase.

- **must-reset-idle-on-first-turn**: The idle phrase, when shown, MUST yield to the thinking state on the first turn transition and never return.

- **must-support-frame-configuration**: The component MUST accept a frame array containing character strings that form a rotating animation. The default frame array is the ten-character braille spinner sequence: ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'].

- **must-support-done-glyph-configuration**: The component MUST accept a single character to display as the settled/done glyph. The default is '✱'.

- **must-support-frame-interval-configuration**: The component MUST accept a frame interval duration in milliseconds (default 260ms) controlling how often the glyph animation advances.

- **must-support-word-interval-configuration**: The component MUST accept a word interval duration in milliseconds (default 1800ms) controlling how often the status word rotates.

- **must-support-colorful-mode**: When `colorful` is enabled, the component MUST flash vivid random non-green hues while thinking or uttering. A non-green hue is one that skips the hue band approximately 75°–165° (greens). The color MUST be generated at HSL 85% saturation and 62% lightness. The color MUST change on a 1-second cycle during active phases and MUST NOT be applied to the settled line.

- **must-support-tint-configuration**: The component MUST accept an optional tint specification that colors the glyph, words, or both while thinking or uttering. The tint MUST NOT be applied to the settled line when done.

- **must-support-utterance-clear**: The component MUST provide a mechanism for the caller to clear a transient utterance, causing the indicator to resume showing phase-driven content.

- **must-announce-status-changes**: The component MUST post accessibility announcements when the phase changes (entering thinking, settling to done, or a fresh utterance) or when status words are rotated in thinking phase. Announcements MUST NOT occur on every frame tick — only on phase transitions and word rotations.

- **must-respond-to-theme-changes**: The component MUST listen for theme/palette changes and repaint immediately to reflect new semantic colors without requiring component restart.

- **must-maintain-glyph-box-width**: In platform representations that separate the glyph from the word text (e.g., AppKit/macOS), the glyph MUST occupy a fixed-width box that does not change based on the current frame. The box MUST be wide enough to accommodate the widest frame character in the configured font.

- **must-handle-empty-frame-array**: If the frame array is empty (malformed configuration), the component MUST render an empty string for the glyph and not crash.

- **must-handle-empty-word-bag**: If status words are configured but the array is empty, the component MUST fall back to the three-dot animation path.

## Appearance

- **Dot pulse (fallback path)**:
  - Dots: Three circular shapes, 7×7 points/pixels each
  - Dot spacing: 4 points/pixels horizontal
  - Dot corners: Rounded (50% border radius = 3.5 radius)
  - Dot color: Semantic palette `.secondaryText`
  - Dot opacity: 30% (idle), 100% (active)
  - Animation: Sequential fade, 0.2s transition time per dot, 0.35s cycle interval
  - Minimum component size: 48 × 28 points/pixels

- **Phase-driven line (words-enabled path)**:
  - Font: Semantic palette caption font
  - Text color (active/thinking): `.personaName`
  - Text color (done): `.thinkingDoneText`
  - Text color (idle): `.thinkingIdleText`
  - Glyph box width (macOS/AppKit): Calculated as the maximum of (`1.6ch` where `ch` is the width of the `0` character in the caption font) and the widest glyph character in the configured frames and done glyph. Box is centered.
  - Gap between glyph and words (macOS/AppKit): `0.45em` (45% of caption font point size, rounded)
  - Baseline alignment (macOS/AppKit): Both glyph and word text align to first baseline
  - Line wrapping: Words may truncate at tail if space is constrained
  - Minimum component size: 48 × 28 points/pixels
  - Horizontal padding: 4 points/pixels leading and trailing
  - No background fill or border

- **Colorful mode**:
  - When active, glyph and word colors shift to the randomly generated non-green HSL hue
  - Color cycle interval: 1000ms during thinking or utterance phases
  - Color does NOT apply to settled/done line

- **Tint mode**:
  - Tint color and apply scope (icons/words/both) MUST NOT apply to settled/done line

## States

| State | Appearance change |
|-------|------------------|
| Idle | No dots visible (unless idle phrase configured). If idle phrase present: grey done glyph with "waiting" phrase and ellipsis. |
| Thinking | Three dots pulsing (fallback), or animating glyph + rotating status word + ellipsis. Text color is `.personaName` (or tinted/colorful override). |
| Utterance | Animating glyph + caller-provided utterance text (overrides phase). Text color is `.personaName` (or tinted/colorful override). Glyph animates, color cycles if colorful. |
| Done | Three dots invisible (fallback), or grey done glyph + past-tense word + "for Ns". Text color is `.thinkingDoneText` (never tinted or colorful). No animation. |

## Accessibility

- Role/trait: The component is a status indicator and does NOT require interactive controls.
- Label requirements: The indicator's content (status words, elapsed time, idle phrase) MUST be accessible to assistive technologies via a live region or announcement mechanism.
- Announce state changes: MUST announce via accessibility API when the phase changes or when a fresh utterance is provided. These announcements MUST be announced at medium or polite priority. Announcing every frame or every word rotation MUST NOT occur.
- Visual hidden text for screen readers: On web, an `aria-live` region holding the current phase announcement (separate from the visual DOM) MUST be present and updated only on phase transitions, not on every glyph frame.
- Minimum tap target: Not applicable; this component is a status display, not an interactive control.
- Color contrast: The status words and done text MUST meet WCAG AA contrast ratio requirements against their backgrounds when rendered in any theme.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| ti-001 | must-render-dots-pulse-when-inactive | isTyping=false, no words configured | No visual indicator rendered |
| ti-002 | must-render-dots-pulse-when-active | isTyping=true, no words configured | Three dots animating, cycling through opacity 0.3 → 1.0 on 0.35s cycle |
| ti-003 | must-show-active-line-while-typing | isTyping=true, words=[{present: "thinking", past: "thought"}] | Glyph animates on 260ms cycle, word "thinking" displays, ellipsis appended |
| ti-004 | must-cycle-through-status-words | words=[{present: "a", past: "a"}, {present: "b", past: "b"}], labelMs=100 | First render shows word "a"; after 100ms word "b" appears; after 200ms word "a" appears again (no duplicates in between) |
| ti-005 | must-show-settled-line-when-done | Turn begins and ends, words=[{present: "thinking", past: "thought"}], elapsed=8s | Final render shows "✱ thought for 8s" in `.thinkingDoneText` color, no animation |
| ti-006 | must-show-idle-phrase-when-configured | idlePhrase="waiting", phase before first turn | Idle phrase renders as "✱ waiting…" in `.thinkingIdleText` color |
| ti-007 | must-reset-idle-on-first-turn | idlePhrase configured, first isTyping→true transition | Idle phrase disappears and thinking state displays |
| ti-008 | must-show-utterance-when-provided | utterance="yes!", phase=thinking | Glyph and "yes!" render, overriding status word |
| ti-009 | must-support-utterance-clear | utterance="yes!" then clearUtterance() called | Thinking state resumes with status word instead of utterance |
| ti-010 | must-support-colorful-mode | colorful=true, thinking phase | Non-green HSL hue applied; color shifts every 1s until done phase reached |
| ti-011 | must-not-show-idle-phrase-when-not-configured | No idlePhrase configured, idle phase | No visual indicator rendered |
| ti-012 | must-announce-status-changes | Phase transitions from idle→thinking→done | Accessibility announcement posted at each transition (thinking, done) |
| ti-013 | must-respond-to-theme-changes | Component rendered, theme changes | Component repaints with new palette colors immediately |
| ti-014 | must-handle-empty-frame-array | frames=[], glyph rendering attempted | Empty string rendered as glyph, no crash |
| ti-015 | must-handle-empty-word-bag | words=[], isTyping=true | Falls back to three-dot pulsing animation |
| ti-016 | must-maintain-glyph-box-width | Platform with glyph box (macOS), frame changes | Box width remains constant across all frame transitions |

## Edge Cases

- **Null or empty status words**: If words array is null or empty, the component MUST render the three-dot fallback animation regardless of other configuration. This fallback is the documented behavior and requires no phase machine.

- **Rapid configuration changes**: If the status word vocabulary is swapped (e.g., persona changes mid-turn), the component MUST rebuild the draw-without-replacement bag immediately and reset the word index. The phase MUST remain unchanged if the active status does not change. Keying on the content of the words array (not its object identity) MUST prevent unnecessary bag rebuilds when the vocabulary is semantically identical but newly created.

- **Concurrent phase machine operations**: The component's phase machine is actor-isolated (Swift) or main-thread-only (UIKit/AppKit/web). Concurrent writes from multiple threads/tasks are not applicable; all operations on the phase machine MUST serialize through the UI thread.

- **Turn transitions during utterance**: If an utterance is set and the turn status changes (isTyping goes false), the component MUST show the utterance until explicitly cleared by the caller; the turn ending does not auto-clear utterances.

- **Colorful mode without utterance/thinking**: The `colorful` flag MUST only affect the active (thinking/utterance) phases. During idle or done phases, colorful has no effect.

- **Tint on settled line**: If a tint is configured and the component enters the done phase, the tint MUST NOT be applied to the settled line. The tint only colors the active and utterance phases.

- **Empty frame array**: If frames is an empty array, the component MUST render an empty glyph string and not crash. The word text (if any) continues to display normally.

- **Idle phrase with no words configured**: If idlePhrase is set but no words are configured, the idle phrase MUST NOT render. The three-dot fallback path does not support idle phrases.

- **Theme palette unavailable**: If the semantic palette cannot be resolved, the component MUST use safe fallback colors (system text colors). The component MUST NOT crash due to missing theme.

- **Elapsed time calculation at edge**: When the turn settles, elapsed time MUST be calculated as `max(1, round((now - startTime) / 1000))`, ensuring the minimum reported time is 1 second and the result is rounded to the nearest whole second.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `isTyping` / `active` / `status` | boolean / ChatStatus? | — | Whether a turn is currently in flight. Drives phase transitions. |
| `words` / `labels` | `[ChatStatusWordPair]` or `StatusWordPair[]` | `[]` (empty) | Vocabulary for status words in present and past tense. Empty = three-dot fallback. |
| `frames` | `[String]` or `string[]` | `['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏']` | Frame characters for the rotating glyph animation. |
| `doneGlyph` | `String` or `string` | `'✱'` | Character displayed in the settled "done" line. |
| `frameMs` / `frameInterval` | milliseconds (number) / Duration | `260` ms | Interval between glyph animation frames. |
| `labelMs` / `wordInterval` | milliseconds (number) / Duration | `1800` ms | Interval between status word rotations. |
| `colorful` | boolean | `false` | When true, flash random non-green hues while thinking or uttering. |
| `tint` / `tint` | `ThinkingTint?` / `StatusTintSpec?` | `nil` / `undefined` | Optional color and apply scope (icons/words/both) for the active line. |
| `idlePhrase` | `String?` or `string?` | `nil` / `undefined` | Text to display before the first turn begins (settles to grey). Yields on first turn. |
| `utterance` | `String?` or `string?` or `null` | `nil` / `undefined` / `null` | Transient utterance text (caller-cleared) that overrides phase content. |

## Deep Linking

Not applicable: The typing indicator is a transient status display within a chat interface and does not support deep linking to a specific state.

## Localization

Not applicable: The component displays caller-provided status words and utterances (fully localized by the caller's data layer), not internal strings. The elapsed-time format "for Ns" is caller-controlled via word pair configuration.

## Accessibility Options

Not applicable: The component does not respond to platform accessibility display options (reduce motion, increase contrast, differentiate without color). It renders status text in semantic palette colors and announces phase changes via live regions/announcements, conforming to WCAG guidelines without option-specific behavior.

## Feature Flags

Not applicable: The component is not gated by feature flags in the sources provided. The two rendering paths (three-dot vs. phase-driven) are determined solely by the presence or absence of configured status words.

## Analytics

Not applicable: The component does not generate or fire analytics events. Analytics integration, if needed, belongs in the caller's chat surface logic that consumes the indicator's phase and utterance props.

## Privacy

Not applicable: The component renders caller-provided status words and utterances but does not collect, store, or transmit any user data beyond what is passed in its configuration.

## Logging

Not applicable: The component does not emit log messages. Platform-specific logging of phase transitions or performance metrics, if needed, belongs to the caller or a higher-level chat orchestrator.

## Platform Notes

- **Web (React)**: The source is `TypingIndicator.tsx` and `ThinkingStatus.tsx` in `packages/chat/src/components/`. The component accepts `TypingIndicatorProps`, returns early from the main `TypingIndicator` function if `labels` is empty/falsy (rendering classic three-dot dots), otherwise mounts the `ThinkingStatus` sub-component which drives phases, word rotation, colorful hue cycling, and utterance handling. Use the exported `TypingIndicator` component directly; `ThinkingStatus` and `statusWordPair` are internal. Styling is via CSS classes (`.pc-thinking`, `.pc-thinking-glyph`, `.pc-thinking-label`, `.pc-thinking-ellipsis`, `.pc-thinking--done`, `.pc-thinking-for`). Accessibility is via an `aria-live="polite"` region (`.pc-status-announce`) that holds phase announcements. The component uses React hooks (`useState`, `useEffect`, `useMemo`, `useRef`) and a `ShuffleBag` utility for draw-without-replacement word selection.

- **SwiftUI**: Not implemented in source. Behavior undefined. A SwiftUI wrapper around the macOS or iOS UIKit/AppKit views would be required for SwiftUI integration, or a native SwiftUI implementation (using `.timer` modifier for animations, `@State` for phase tracking, and `AccessibilityRepresentation` for announcements) would need to mirror the behavioral requirements.

- **Compose (Android/Kotlin)**: Not implemented in source. Behavior undefined. A Compose implementation would use `LaunchedEffect` for animation timers, `remember` for phase state and word bag, and `Modifier.semantics()` with accessibility announcements. The visual appearance would mirror iOS: dots for the fallback path, glyph + word text for the phase-driven path.

- **AppKit / UIKit (macOS/iOS)**: The sources are `ThinkingIndicatorView.swift` (macOS/AppKit) and `MobileThinkingIndicatorView.swift` (iOS/UIKit). Both inherit from `NSView`/`UIView`, conform to `Themeable`, and share the same configuration (`ThinkingIndicatorConfiguration`/`MobileThinkingIndicatorConfiguration`) and phase machine (`ThinkingPhase.Machine`). Initialization is via `init()` or `init(frame:)`. Configuration is installed via `configure(_:)` method; status updates via `update(status:)` method (accepts `ChatStatus?`); utterances via `say(_:)` and `clearUtterance()` methods. Animation uses `Timer` scheduled on `MainActor` for both dot pulse (0.35s cycle, `UIView.animate`/`NSAnimationContext` for opacity transitions) and phase-driven glyph ticking (260ms default). Theme changes via `Themeable` protocol and `ThemePaletteObserver`. Accessibility via `UIAccessibility.post(notification:argument:)` (iOS) or `NSAccessibility.post(element:notification:userInfo:)` (macOS). The macOS version maintains a separate glyph box (`.glyphLabel`) with a fixed-width constraint to prevent text layout shift as glyphs change.

- **WinUI 3**: Not implemented in source. Behavior undefined. A WinUI 3 implementation would start from `Grid` or `StackPanel` for layout. The three-dot fallback could use three animated `Ellipse` shapes with `Storyboard` for opacity animation. The phase-driven path would use `TextBlock` for glyph and words, `DispatcherTimer` for frame/word cycling, and `VisualStateManager` or custom property animations for phase transitions. Semantic colors would map to XAML `ThemeResource` tokens (e.g., `SecondaryTextBrush`, `AccentTextFillColorPrimaryBrush`). Accessibility would use `AutomationProperties.Name` and `LiveSetting` on a live-region text block. The glyph box width calculation would use `TextBlock.ActualWidth` measurement of rendered frames.

## Design Decisions

**Two-path rendering**: The component provides a three-dot pulse fallback when no status words are configured. This preserves backward compatibility with existing consumers and avoids the overhead of the phase machine when custom word vocabularies are not in use. The fallback is the documented default behavior and requires no configuration change.

**Draw-without-replacement word selection**: The `ShuffleBag` utility ensures each word in the vocabulary is shown once before any word repeats. This prevents a four-word persona from showing "thinking thinking zipping thinking" and creates a more balanced rotation. The bag is keyed on the semantic content of the word array (not its object identity) so vocabulary changes mid-turn trigger a rebuild without losing the phase state.

**Colorful mode avoids green**: The non-green hue band (approximately 75°–165°) is excluded to prevent the active thinking line from rendering in a color typically associated with "done" or "success". The vivid colors (85% saturation, 62% lightness) are bright enough to distinguish from the grey settled line while remaining readable on typical dark chat backgrounds.

**Settled line is never tinted**: The done/settled line uses only `.thinkingDoneText` color and ignores `colorful` and `tint` configuration. This creates a visual distinction between the active (possibly vivid/tinted) thinking line and the final settled line, signaling to the user that the turn has completed.

**Idle phrase yields to first turn**: Once the first turn begins, the idle phrase is replaced permanently and never re-shown even if a subsequent turn ends. This prevents the idle state from flickering back during rapid turn transitions.

**Glyph box maintains fixed width**: In platform representations where the glyph is a separate visual element (AppKit/macOS), the box containing the glyph has a fixed width that does not change as the animation cycles. This prevents the word text from shifting left and right as braille characters of varying widths are displayed. The box width accommodates the widest possible glyph (measured at render time) and centers the glyph within it.

**No phase machine in dot fallback**: The three-dot rendering path (when no words are configured) does not instantiate or run the phase machine. It is a pure visual animation driven by `isTyping` boolean, keeping memory and CPU overhead minimal for consumers who do not use status vocabularies.

**Phase announcements only**: Accessibility announcements are posted only when the phase changes (entering thinking, settling, utterance set), not on every frame or word rotation. This provides necessary feedback without overwhelming screen readers with constant updates.

## Compliance

Not applicable. The component conforms to WCAG 2.1 AA contrast and accessibility announcement requirements through its use of semantic palette colors and `aria-live` / `NSAccessibility` announcements, but is not a conformance-gate-triggering artifact.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation |
