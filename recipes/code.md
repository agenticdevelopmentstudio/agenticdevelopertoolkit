---
id: 335f37a4-cd9e-4575-a78a-8717b34e5a2d
title: Code
domain: agenticdevelopertoolkit://recipes/code
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A block of literal text in monospace, displaying shell transcripts, invocations,
  or config fragments with horizontal scrolling and no text wrapping.
platforms:
- typescript
- web
tags:
- code-display
- monospace
- text-block
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Code

## Overview

The Code component displays literal text in a monospace (mono) typeface without interpretation, wrapping, or markup. It is designed for shell transcripts, command invocations, configuration fragments, and other content where exact formatting and readability are essential. The component scrolls horizontally rather than wrapping long lines, preserving the structure of the original text.

## Behavioral Requirements

- **must-render-as-preformatted**: The component MUST render text with preserved whitespace and line breaks exactly as provided in the `text` prop.
- **must-not-wrap**: The component MUST NOT wrap text to fit the container width; it MUST scroll horizontally when content exceeds the available width.
- **must-accept-string-prop**: The component MUST accept a single `text` prop of type `string` containing the literal content to display.
- **must-not-interpret-markup**: The component MUST NOT interpret, parse, or render any markup (HTML, markdown, JSX, or other syntax) within the `text` prop; the entire string MUST be rendered as literal text.
- **must-use-monospace-font**: The component MUST render text in a monospace typeface appropriate to the deck's design system.

## Appearance

- **Font**: Monospace (deck-defined mono face)
- **Background**: Deck's code block background color
- **Foreground/Text**: Deck's code block text color
- **Padding**: Deck-defined spacing around the code block (typically 12–16px on all sides)
- **Corner radius**: Deck-defined, typically 4–8px
- **Border**: Deck-defined (typically a subtle border or none)
- **Shadow**: Deck-defined (typically none or a subtle drop shadow)
- **Min/Max size**: No enforced constraints; width grows with content (horizontal scroll as needed); height determined by line count and line-height
- **Overflow**: Horizontal overflow MUST scroll; vertical overflow MUST be visible or scroll as needed

## States

| State | Appearance change |
|-------|------------------|
| Default | Content is displayed in monospace with deck-defined colors and spacing |
| User selects text | Text selection styling follows deck's text selection color and appearance |
| User scrolls horizontally | Horizontal scrollbar appears (or deck-defined scroll behavior) |

## Accessibility

- **Role/Trait**: The component MUST render as a `<pre>` element (preformatted text block). The `<code>` child indicates the content is code.
- **Label requirements**: A parent heading or caption MUST precede the code block to provide context; the code block itself does not require an `aria-label` if the context is clear from surrounding content.
- **Announce state changes**: Not applicable; this is a static, read-only component with no interactive state changes.
- **Keyboard navigation**: The code block MUST be focusable if its width exceeds the container (to enable keyboard scrolling of horizontally scrollable content on platforms that support it).
- **Minimum tap target**: Not applicable; the code block is read-only and not directly interactive.
- **Semantic structure**: The `<pre><code>` nesting MUST be preserved to indicate preformatted code to assistive technologies.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| code-001 | must-render-as-preformatted | `text: "line1\nline2\n  indented"` | Output preserves newlines and leading spaces; renders as three lines with the third indented |
| code-002 | must-not-wrap | `text: "a very long command that exceeds container width"` | Text does not break into multiple lines; horizontal scroll is available |
| code-003 | must-accept-string-prop | `text: "$ echo hello"` | Component renders without error; text appears as `$ echo hello` |
| code-004 | must-not-interpret-markup | `text: "# Heading\n**bold** <html>"` | Output renders literally as `# Heading\n**bold** <html>` with no markdown or HTML interpretation |
| code-005 | must-use-monospace-font | `text: "code"` | Text renders in the deck's monospace typeface (visually distinguishable from body text) |

## Edge Cases

- **Empty string**: If `text` is an empty string, the component MUST render an empty `<pre><code>` block with no height collapse; the block SHOULD be visible to prevent layout shift.
- **Whitespace-only input**: If `text` contains only whitespace (spaces, tabs, newlines), the component MUST render and preserve all whitespace exactly as provided.
- **Very long lines**: If a single line exceeds the container width significantly, the component MUST provide horizontal scrolling without breaking the line.
- **Tabs and special characters**: The component MUST preserve tabs, multiple spaces, and other whitespace characters exactly as provided; rendering behavior follows CSS `white-space: pre`.
- **Unicode and non-ASCII characters**: The component MUST render all valid Unicode characters, including emoji and international text, as literal characters without transformation.

## Configuration

Not applicable: the Code component accepts only a single `text` prop and has no configuration options.

## Deep Linking

Not applicable: the Code component is a static display element without associated navigation or state that would warrant a deep link.

## Localization

Not applicable: the Code component does not contain any translatable strings; the `text` prop content is user-provided and localization is the responsibility of the content provider.

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | Not applicable; the component does not animate |
| Increase Contrast | The component SHOULD respect the deck's increased-contrast theme if available, rendering text and background with higher contrast ratios |
| Differentiate Without Color | Not applicable; the component does not rely on color alone to convey information |

## Feature Flags

Not applicable: the Code component has no optional features or feature flags.

## Analytics

Not applicable: the Code component is a passive display element with no user interactions to track.

## Privacy

Not applicable: the Code component does not collect, store, or transmit any data beyond displaying the provided text.

## Logging

Not applicable: the Code component does not perform any operations that warrant logging.

## Platform Notes

- **React/Web**: Implemented as `<pre className="lp-code"><code>{text}</code></pre>`. The `lp-code` class applies deck-specific styling (monospace font, background, padding, and border radius). The component is a pure presentational component with no state or lifecycle.

- **SwiftUI**: Use `Text(text).font(.system(.body, design: .monospaced))` wrapped in a `ScrollView(.horizontal)` within a container styled with the equivalent of the web `lp-code` class (padding, background, corner radius). Preserve whitespace using `.lineLimit(nil)` and a fixed-width monospace font family.

- **Compose**: Use `Text(text = text, fontFamily = FontFamily.Monospace, modifier = Modifier.padding(12.dp).background(codeBlockBackground).clip(RoundedCornerShape(8.dp)).horizontalScroll(rememberScrollState()))`. Ensure `text` parameter is of type `String` and whitespace is preserved by using `Arrangement.Start` (no word wrapping).

- **AppKit / UIKit**: On AppKit, use `NSTextView` with `NSFont.monospacedSystemFont(ofSize: 13)` and disable word wrapping (`isRichText = false`, `textContainer.widthTracksTextView = false`). On UIKit, use `UITextView` with `.monospacedSystemFont(ofSize: 13)` and disable text editing (`isEditable = false`). Apply background color and corner radius via the view's layer or `backgroundColor` and `cornerRadius` properties.

- **WinUI 3**: Use `TextBlock` with `FontFamily="Consolas"` or `"Courier New"` and `TextWrapping="NoWrap"`. Place it in a `ScrollViewer` with `HorizontalScrollBarVisibility="Auto"` to enable horizontal scrolling. Apply background color via the `TextBlock`'s containing control (e.g., a `Grid` or `Border` with `Background` property). Set `Foreground` to the appropriate text color from the theme.

## Design Decisions

The `text` prop is intentionally a string rather than `children` (ReactNode). This design choice prevents hosts from passing markup that would render as code, ensuring the entire content is treated as literal text. This is essential for displaying shell commands, configuration files, and other content where embedded formatting would be incorrect or misleading. A host that requires formatted content within code should use a separate component or structure.

The component does not wrap text. Wrapped code is a different command (e.g., a wrapped shell invocation is no longer the same command), so horizontal scrolling is the correct behavior rather than visual truncation or wrapping.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| Accessible text role | passed | Accessibility |
| Semantic HTML structure | passed | Semantics |
| No text wrapping by design | passed | Correctness |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation |
