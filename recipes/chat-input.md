---
id: 0ae70642-28e7-436a-b934-0b445652ac09
title: Chat Input
domain: agenticdevelopercookbook://ingredients/chat-input
type: ingredient
version: 1.0.0
status: review
language: en
created: 2026-09-22
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Single-line text input field for composing and sending chat messages.
platforms:
- typescript
- web
- swift
- macos
tags:
- chat
- input
- form
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Chat Input

## Overview

A single-line text input field designed for composing and sending chat messages. The component accepts user text input, validates that the message is not empty, and triggers a send action via an associated send button or Enter key. It supports theming, customizable placeholder text, optional disable state, and platform-specific affordances for send actions. The component explicitly opts out of password manager autofill and iOS contact autofill to prevent unintended mutations of the input field.

## Behavioral Requirements

- **must-render-input-field**: The component MUST render a text input field that accepts character input from the user.
- **must-accept-placeholder**: The component MUST accept and display a placeholder string when the input is empty. The default placeholder MUST be "Type a message...".
- **must-accept-custom-placeholder**: The component MUST allow the placeholder text to be customized via a configuration option.
- **must-disable-on-empty**: The send button MUST be disabled when the input contains only whitespace or is empty.
- **must-enable-on-text**: The send button MUST be enabled when the input contains at least one non-whitespace character.
- **must-send-on-enter**: The component MUST send the message when the user presses Enter (without Shift), and MUST NOT send when Shift+Enter is pressed.
- **must-trim-whitespace**: The component MUST trim leading and trailing whitespace from the message text before sending.
- **must-clear-on-send**: The component MUST clear the input field after a message is sent.
- **must-invoke-callback**: The component MUST invoke the `onSend` callback with the trimmed message text when a send action occurs.
- **must-reject-empty-send**: The component MUST NOT invoke `onSend` if the trimmed message text is empty.
- **must-support-disabled-state**: The component MUST support a disabled state that prevents typing and sending.
- **must-show-send-button**: The component MUST render a send button that is visually associated with the input field.
- **must-receive-autofocus**: The component MUST support an autoFocus option to automatically focus the input field on mount.
- **must-opt-out-password-manager**: The component MUST set autofill opt-out attributes to prevent password managers from injecting autofill metadata into the input field and form.
- **must-opt-out-ios-autofill**: The component MUST use a form container with no name or autocomplete attributes, and MUST set `data-form-type="other"`, to prevent iOS from offering contact autofill.
- **must-provide-aria-label**: The component MUST provide an accessible label for the input field via `aria-label="Message"` or equivalent platform mechanism.
- **must-support-external-ref**: The component MUST allow the caller to provide an external ref to access the input element directly.

## Appearance

- **Corner radius**: 6px on standard themes; 0px (squared off) on terminal/retro themes
- **Padding**: 5pt vertical × 8pt horizontal (inset)
- **Font**: Body font from theme palette (size and weight determined by theme; defaults to platform system body)
- **Background**: `chatInputBackground` semantic color (theme-driven; falls back to platform default surface color)
- **Foreground/Text**: `userText` semantic color (theme-driven; typically a light gray on dark theme)
- **Border**: 1px solid, color is `chatInputBorder` by default; `chatInputFocus` when focused (theme-driven; hidden on terminal themes)
- **Shadow**: None
- **Placeholder color**: `timestampText` semantic color (theme-driven; typically a dimmer gray than user text)
- **Min/Max size**: Single-line height determined by font metrics; width expands to fill container; no maximum width constraint

## States

| State | Appearance change |
|-------|------------------|
| Default | Standard background, border color is `chatInputBorder`, text color is `userText`, placeholder is visible if input is empty |
| Focused | Border color changes to `chatInputFocus`, caret visible (platform-specific: bar on web/iOS/UIKit, block on macOS, system bar on Android) |
| Disabled | Input field is not editable, send button is disabled, visual indication of disabled state (opacity or color dimming per platform) |
| With Text | Send button is enabled |
| Empty/No Text | Send button is disabled, placeholder text visible |
| Block Caret (macOS only) | Character-cell block cursor instead of blinking bar; block can be solid or blinking (configurable per terminal theme) |

## Accessibility

- **Role**: Text input field (semantic role)
- **Label**: MUST have an accessible label "Message" via `aria-label` (web) or equivalent native mechanism (AppKit/UIKit)
- **Keyboard navigation**: Input MUST be focusable via Tab key. Send button MUST be keyboard-accessible (Enter triggers send on focused input, or Tab+Space on the button)
- **Announce state changes**: When input transitions to empty → disabled or disabled → enabled, the disabled state of the send button SHOULD be announced to screen readers
- **Touch/Click target**: Minimum 44×44pt on iOS; 48×48dp on Android. Send button MUST meet this minimum
- **Color contrast**: Text MUST have sufficient contrast against background per WCAG AA (minimum 4.5:1 for normal text)
- **Don't rely on color alone**: State changes (focused, disabled) MUST use both color and other visual properties (border, opacity) per "Differentiate Without Color" accessibility guidelines

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| chat-input-001 | must-render-input-field | Component mounts | Input element is rendered and visible |
| chat-input-002 | must-accept-placeholder | No custom placeholder provided | Input shows default "Type a message..." |
| chat-input-003 | must-accept-custom-placeholder | Placeholder prop set to "Ask me anything" | Input displays "Ask me anything" when empty |
| chat-input-004 | must-disable-on-empty | Input is empty | Send button is disabled |
| chat-input-005 | must-enable-on-text | User types "Hello" | Send button is enabled |
| chat-input-006 | must-enable-on-text | User types "   " (spaces only) | Send button is disabled |
| chat-input-007 | must-send-on-enter | User types "Test" and presses Enter | onSend is called with "Test", input is cleared |
| chat-input-008 | must-send-on-enter | User types "Test", presses Shift+Enter | onSend is NOT called, message remains in input |
| chat-input-009 | must-trim-whitespace | User types "  Hello  " and presses Enter | onSend is called with "Hello" (trimmed) |
| chat-input-010 | must-clear-on-send | Message is sent | Input field is empty, send button is disabled |
| chat-input-011 | must-reject-empty-send | User types "   " and presses Enter | onSend is NOT called, input is NOT cleared |
| chat-input-012 | must-support-disabled-state | disabled prop is true | Input cannot be focused or edited, send button is disabled |
| chat-input-013 | must-show-send-button | Component mounts | Send button is rendered adjacent to input |
| chat-input-014 | must-receive-autofocus | autoFocus prop is true | Input is focused on mount |
| chat-input-015 | must-receive-autofocus | autoFocus prop is false (default) | Input is not focused on mount |
| chat-input-016 | must-opt-out-password-manager | Component renders (web) | Form has `data-form-type="other"`, input has `autocomplete="off"` and password-manager opt-out data attributes |
| chat-input-017 | must-opt-out-ios-autofill | Component renders on iOS (web) | Form has no name attribute, input has no semantic autocomplete hints; iOS does not offer contact autofill |
| chat-input-018 | must-provide-aria-label | Component renders (web) or mounts (AppKit) | Input has `aria-label="Message"` (web) or equivalent accessible label (AppKit) |
| chat-input-019 | must-support-external-ref | inputRef prop provided to component | External ref can access and interact with input element |

## Edge Cases

- **Empty input with whitespace-only entry**: User enters spaces, tabs, or newlines and presses Enter. Expected: onSend is NOT called, input is NOT cleared, send button remains disabled. Behavior: MUST.
- **Rapid successive sends**: User sends a message, input clears, user immediately types and sends again. Expected: Each send is independent, messages are not conflated. Behavior: MUST.
- **Focus loss during typing**: User types a message, then clicks elsewhere without sending. Expected: Message text is retained in the field (not lost on blur), can be resumed. Behavior: MUST.
- **Disabled state toggle**: Component is disabled while user is typing. Expected: Input becomes read-only, pending text is not lost, send button is disabled. Behavior: MUST.
- **External ref access**: Caller obtains ref to input element and directly modifies `.value` property. Expected: Component state updates reflect the direct modification (onChange fires, send button state updates). Behavior: MUST.
- **Shift+Enter on different platforms**: Behavior may vary by platform (some may interpret as "new line" in a multi-line field). Expected: On single-line fields, Shift+Enter MUST NOT send. Behavior: MUST.
- **Password manager attribute injection**: Password manager (Dashlane, 1Password, Bitwarden, Proton Pass) scans the DOM before React hydration. Expected: opt-out attributes prevent injection of autofill metadata. Behavior: MUST.
- **Very long message text**: User enters a message much longer than field width. Expected: Text scrolls horizontally within the input; caret follows the text; no character loss. Behavior: MUST.
- **Theme change during focus**: Theme palette changes (dark → light, or theme swap) while input is focused. Expected: Focus state is retained, border and text colors update immediately, caret appearance updates. Behavior: MUST.
- **Block caret with truncated text** (macOS only): Text overflows and is truncated by field width; block caret is visible. Expected: Caret stays within field bounds, does not render outside clipping region. Behavior: MUST.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| onSend | (text: string) => void | (required) | Callback invoked when a message is sent; receives trimmed message text |
| placeholder | string | "Type a message..." | Text displayed in input when empty |
| autoFocus | boolean | false | Whether to automatically focus the input on mount |
| inputRef | RefObject\<HTMLInputElement \| null\> | undefined | External ref to access the underlying input element (web) or NSTextField (AppKit) |
| disabled | boolean | false | Whether the input is disabled and send is blocked |
| cornerRadius | CGFloat | 6 | (macOS AppKit only) Corner radius of input field in points; 0 for terminal themes |
| showsBorder | boolean | true | (macOS AppKit only) Whether to draw the one-pixel border; false for terminal themes |
| usesBlockCaret | boolean | false | (macOS AppKit only) Whether to use a block caret (terminal style) instead of blinking bar |
| caretBlinks | boolean | true | (macOS AppKit only) Whether the caret (block or bar) blinks or remains solid |

## Deep Linking

Not applicable: Chat Input is a form control, not a navigable view. It does not handle deep links or URL scheme routing.

## Localization

The placeholder text is user-facing and MUST be localizable. All other text ("Message" label, send button label) SHOULD be provided by the caller or through a localization framework.

| String Key | Default (en) | Context |
|-----------|-------------|---------|
| chat_input_placeholder | "Type a message..." | Placeholder text shown in empty input |
| aria_label_message_input | "Message" | Accessible label for input field |
| aria_label_send_button | "Send" | Accessible label for send button |

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | (iOS/macOS/web) Block caret should blink less frequently or not at all when Reduce Motion is enabled; standard bar caret is not animated |
| Increase Contrast | (iOS/macOS/web) Focus border and interactive state colors SHOULD be more saturated; text contrast ratio SHOULD exceed 7:1 |
| Differentiate Without Color | (iOS/macOS/web) Focus state MUST be indicated by border thickness or pattern change in addition to color; disabled state MUST use opacity or pattern, not color alone |

## Feature Flags

Not implemented in source: No feature flags are used to enable or disable this component.

## Analytics

Not implemented in source: The component does not emit analytics events. Callers MAY wrap the onSend callback to track send actions independently.

## Privacy

- **Data collected**: The message text itself is not collected by the component; it is passed to the onSend callback. The caller is responsible for handling the text (sending, storing, etc.).
- **Storage**: No data is stored persistently by the component. Text in the input field is held in memory only.
- **Transmission**: No data is transmitted by the component itself. The caller determines whether and how to send the message.
- **Retention**: Text is cleared from the input field after send. No logs or history are maintained by the component.

## Logging

Subsystem: `agenticdevelopertoolkit` | Category: `ChatInput`

| Event | Level | Message |
|-------|-------|---------|
| Send initiated | debug | `ChatInput: send initiated, text length = {length}` |
| Empty send rejected | debug | `ChatInput: send rejected, input is empty after trim` |
| Input cleared | debug | `ChatInput: input cleared after send` |

## Platform Notes

- **SwiftUI**: Start from `TextField` with a custom `_ViewModifier` to apply semantic colors (background, focus border) from the theme palette. SwiftUI's TextField does not expose the insertion point caret for customization, so a block caret requires wrapping an `NSViewRepresentable` containing the AppKit `ChatInputField` class below. For macOS apps prioritizing terminal aesthetics, the `NSViewRepresentable` route is necessary.
- **Compose**: Start from `BasicTextField` (Compose Foundation) or Material's `OutlinedTextField` with a custom `focusedBorderColor` that maps to the theme palette. Compose's text input does not support a block caret natively; if a terminal theme requires one, implement a custom caret overlay using a `Modifier` and `Brush` drawing. For standard themes, the platform's blinking bar caret is sufficient.
- **React/Web**: Start from an HTML `<input type="text">` element. The component MUST use a form container (not a plain div) to scope autofill classifiers in Safari/iOS. Password manager opt-out is handled via data attributes (`data-form-type="other"`, `data-1p-ignore`, `data-lpignore`, `data-bwignore`, `data-protonpass-ignore`) and the `autocomplete="off"` attribute. The send button is a form submit button (`type="submit"`) so that Enter and the button both trigger the same code path.
- **AppKit / UIKit**: AppKit uses `NSTextField` with custom `NSTextFieldCell` padding (8pt horizontal, 5pt vertical inset) and a custom block caret layer (`CALayer`) that is positioned and animated independently. UIKit (iOS) uses `UITextField` with a standard keyboard and send button; the block caret feature is macOS-specific and not used on iOS. Both platforms apply theme-driven colors via a `Themeable` protocol observer.
- **WinUI 3**: Start from `TextBox` (for single-line input) with a custom `ControlTemplate` that applies the theme colors to the background, border, and text. The `CharacterReceived` event is used to intercept Enter (avoid sending on Shift+Enter). A `Button` with `PrimaryCommandBar` styling serves as the send button. The block caret is not part of WinUI 3's standard TextBox and would require custom drawing in an inherited control, so use the platform's default blinking bar caret. The `IsEnabled` property controls the disabled state for both TextBox and Button.

## Design Decisions

1. **Form wrapper for autofill scoping**: The web component wraps the input in a `<form>` element to prevent iOS Safari from classifying a lone input field against the entire document for autofill purposes. This was necessary because a bare input without a form is scoped globally and can trigger contact autofill if the page contains other contact-related content.

2. **Single send path via form submit**: The Enter key handler and the send button both trigger form submission, ensuring one code path for send logic. This prevents divergence between keyboard and button sends.

3. **Trimming before send, not display**: Whitespace is trimmed only at the point of send, not as the user types. The input field shows exactly what the user typed, including leading/trailing spaces, so the user can see what they are about to send.

4. **Password manager opt-out attributes**: Multiple opt-out attributes are set (`data-1p-ignore`, `data-lpignore`, `data-bwignore`, `data-protonpass-ignore`) because each password manager reads its own ignore signal and ignores others. This ensures broad compatibility without relying on a single standard.

5. **Block caret as macOS-specific affordance**: The terminal themes (old-school-terminal, etc.) use a block caret to match CRT aesthetics. This is implemented on AppKit (macOS) via a custom `CALayer` drawn on top of the text field. Other platforms use their native carets.

6. **Placeholder as weak label, name + aria-label for strong label**: The placeholder is not a substitute for an accessible label on web. The input has both a `name` attribute (for form submission context) and an `aria-label` (for screen readers). This ensures the field is always properly labeled.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| Keyboard navigation | passed | Accessibility |
| ARIA labels present | passed | Accessibility |
| Touch target size (iOS) | passed | Accessibility |
| Touch target size (Android) | passed | Accessibility |
| Focus visible | passed | Accessibility |
| Color contrast (WCAG AA) | passed | Accessibility |
| Placeholder is not label | passed | Accessibility |
| Empty send blocked | passed | Correctness |
| Shift+Enter does not send | passed | Correctness |
| Trimming applied | passed | Correctness |
| Password manager opt-out | passed | Privacy |
| iOS autofill avoidance | passed | Privacy |
| Theme-driven colors | passed | Theming |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
