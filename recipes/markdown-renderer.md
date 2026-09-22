---
id: 316aed50-a6cb-4ece-977c-8d6dacb2186b
title: Markdown Renderer
domain: agenticdevelopercookbook://ingredients/markdown-renderer
type: ingredient
version: 1.1.0
status: review
language: en
created: 2026-09-22
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Converts markdown content to formatted output with syntax-highlighted code
  blocks and semantic palette theming.
platforms:
- apple
- web
tags:
- markdown
- text-rendering
- syntax-highlighting
depends-on: []
related: []
references: []
---

# Markdown Renderer

## Overview

The Markdown Renderer converts raw markdown strings to formatted output suitable for display. On Apple platforms, it produces `NSAttributedString` with semantic palette styling; on web platforms, it produces sanitized HTML with theme-aware CSS variables. Both implementations support full CommonMark syntax including headers, lists, blockquotes, tables, code blocks with optional syntax highlighting, and inline formatting. Parsing is resilient: partial markdown is rendered as far as parsing succeeds rather than failing entirely. Code block syntax highlighting is optional and delegated to an injected highlighter on Apple platforms or Shiki on web platforms.

## Behavioral Requirements

- **must-render-markdown**: MUST parse and render valid CommonMark markdown including headers (levels 1–6), unordered and ordered lists, blockquotes, thematic breaks, code blocks, tables, and inline formatting (bold, italic, strikethrough, code spans, links).
- **must-parse-resilient**: MUST render partial markdown when parsing encounters syntax errors or incomplete input; degradation MUST be to plaintext, never to empty output or loss of readable content.
- **must-support-extended-attributes**: MUST process and apply extended markdown attributes (per `AttributedString` parsing options).
- **must-respect-code-language**: MUST preserve the language hint from fenced code blocks and provide it to the syntax highlighter.
- **must-apply-palette-styling**: MUST apply semantic palette styling including font roles (title, heading, body, code), color roles (text, secondaryText, accent, divider, controlBackground), and paragraph indentation for nested structures.
- **must-preserve-block-boundaries**: MUST report or track block boundaries with correct separation: blank line between top-level blocks, single newline between list items or table rows within the same structure, tabs between table cells.
- **must-quote-identity**: MUST preserve the identity and nesting of blockquotes so that color styling can be applied to entire quote regions without leaking into adjacent quotes.
- **must-table-identity**: MUST preserve table identity across row sequences so that row indices do not collide when two tables are adjacent.
- **must-handle-missing-highlighter**: MUST fall back to unstyled monospaced code when syntax highlighter is unavailable or returns nil.
- **must-handle-trailing-newline**: MUST remove trailing newlines from code blocks to prevent double blank lines in output.
- **must-embed-inline-styles**: MUST apply inline formatting (bold, italic, strikethrough, underline for links, color for inline code and links) without emitting a separate link or style dictionary.
- **must-sanitize-html**: (Web) MUST pass rendered HTML through rehype-sanitize or equivalent XSS prevention before output.
- **should-mark-loading-state**: (Web) SHOULD indicate rendering phase with an accessible loading indicator (`aria-busy="true"`, `aria-live="polite"`).
- **should-emit-error-pane**: (Web) SHOULD render an error pane on pipeline failure rather than injecting unsanitized or partial HTML.

## Appearance

- **Font styling**:
  - Headers: title font (level 1, bold), heading font (level 2, bold), heading font (level 3), body font with bold (levels 4–6)
  - Body text: semantic body font
  - Code spans and code blocks: semantic code font (monospaced)
  - Table headers: semantic body font with bold
- **Colors**:
  - Primary text: supplied textColor parameter or theme primary text
  - Blockquote text: secondary text color
  - Code block background: controlBackground color
  - Link text: accent color with underline
  - Thematic break rule: divider color
- **Spacing**:
  - List indentation: one indent step per nesting level (e.g., `MarkdownBlockMetrics.indentStep`)
  - Blockquote indentation: one indent step per nesting level
  - Table columns: evenly spaced across available width (e.g., `MarkdownBlockMetrics.tableColumnCount` columns, `MarkdownBlockMetrics.tableColumnWidth` per column)
  - Paragraph indentation: applied via `NSParagraphStyle` (headIndent, firstLineHeadIndent) or CSS margin/padding
  - Tab stops for list markers: one indent step beyond list indentation for text alignment
- **Min/Max size**: No intrinsic minimum or maximum; renders to the width of its container.

## States

| State | Appearance change |
|-------|------------------|
| Default | Content rendered with full styling |
| Rendering | (Web) Subtle inline "Rendering…" indicator |
| Error | (Web) Centered error pane with explanation |
| Highlighted code block | Code block uses syntax highlighter output if available; monospaced fallback otherwise |
| Unhighlighted code block | Code block rendered in monospaced code font with controlBackground |

## Accessibility

- **Role/trait**: Semantic HTML or `NSAttributedString` with role information preserved from markdown (headers carry h1–h6 role equivalence via font size/weight; links carry link role via `NSAttributedString.Key.link` attribute or HTML `<a>` tag).
- **Label requirements**: Headings MUST be emitted with their semantic level to preserve document structure for screen readers. Links MUST retain their href and alt text.
- **Announce state changes**: (Web) Loading state MUST be announced via `aria-live="polite"` and `aria-busy="true"`. Error state MUST use `role="alert"`.
- **Minimum tap target**: Links rendered in text MUST meet minimum contrast (WCAG AA) via palette colors; no additional tap-target requirement for inline links.
- **Keyboard navigation**: (Web) Links MUST be keyboard-navigable via tab and Enter. Tables MUST preserve tab ordering.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| markdown-renderer-001 | must-render-markdown | `"# Heading 1\n## Heading 2"` | Output with semantic heading styles (title font for h1, heading font for h2) |
| markdown-renderer-002 | must-render-markdown | `"- Item 1\n- Item 2\n  - Nested"` | Unordered list with bullet markers, indented nesting, newline between items |
| markdown-renderer-003 | must-render-markdown | `"1. First\n2. Second"` | Ordered list with numeric markers (1., 2.), newline between items |
| markdown-renderer-004 | must-render-markdown | `"> Quote\n> More"` | Blockquote text in secondaryText color, indented, single quote identity for entire block |
| markdown-renderer-005 | must-render-markdown | `"---"` | Thematic break rendered as divider-colored rule string |
| markdown-renderer-006 | must-render-markdown | `` "```swift\nprint(\"hi\")\n```" `` | Code block in code font with controlBackground; language hint "swift" provided to highlighter |
| markdown-renderer-007 | must-render-markdown | `"**bold** *italic* ~~strike~~ `code` [link](http://example.com)"` | Bold and italic applying font weight/style, strikethrough via NSStrikethroughStyle, code in code font with background, link in accent color with underline |
| markdown-renderer-008 | must-render-markdown | `"\| a \| b \|\n\|---\|---\|\n\| c \| d \|"` | Table with header row (bold), body rows, cells separated by tabs, rows separated by newlines, table identity preserved |
| markdown-renderer-009 | must-parse-resilient | `"# Heading\nIncomplete **bold"` | Heading rendered correctly, incomplete bold parsed as far as possible and rendered as text |
| markdown-renderer-010 | must-handle-missing-highlighter | `` "```js\nvar x = 1\n```" `` (no highlighter) | Code block rendered in monospaced font with controlBackground, no syntax colors |
| markdown-renderer-011 | must-handle-trailing-newline | `` "```\ncode\n```" `` | Code output with trailing newline removed, no double blank line before next block |
| markdown-renderer-012 | must-sanitize-html | (Web) Raw markdown with `<script>` tag | Output HTML with script tag removed or escaped, never executed |
| markdown-renderer-013 | should-mark-loading-state | (Web) Initial render | Loading state with `aria-busy="true"` and `aria-live="polite"` |
| markdown-renderer-014 | should-emit-error-pane | (Web) Pipeline failure (bad shiki config, etc.) | Error pane rendered via React (not `dangerouslySetInnerHTML`), `role="alert"` applied |

## Edge Cases

- **Null or empty input**: Empty string MUST render as empty output. Null input (if applicable per language) MUST be treated as empty string or raise a caught error.
- **Boundary values**: Deeply nested structures (10+ levels of list or blockquote nesting) MUST render with proper indentation. Single-character markdown (e.g., "#") MUST degrade gracefully or render as text if incomplete.
- **Concurrent access**: Components are immutable (Apple Sendable, Web stateless render). Multiple concurrent render calls with different content MUST not interfere; state is maintained per-component instance (Apple) or per-render (Web).
- **Error states**: Parser that encounters syntax errors MUST degrade to plaintext, not crash or omit content. Highlighter that returns nil MUST fall back to unstyled monospaced code. (Web) Pipeline failure MUST display error pane, not expose error in output HTML.
- **Offline or disconnected state**: (Web) If highlighter init or processing fails, fallback to unstyled output; no network retry required.
- **Adjacent blockquotes**: Two adjacent blockquote blocks MUST carry distinct identities so color styling does not bleed between them.
- **Adjacent tables**: Two consecutive tables with different row counts MUST not be joined into one; table identity preserves the boundary.
- **Frontmatter**: (Web) Raw markdown may include YAML frontmatter; it MUST be stripped before processing.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `highlighter` | `(CodeHighlighter)?` / `undefined` | `nil` / not provided | (Apple) Optional injected syntax highlighter for fenced code blocks. If nil, code blocks render in unstyled monospaced font. (Web) Shiki highlighter is initialized internally; no configuration exposed. |
| `palette` | `SemanticPalette` | Required | (Apple) Semantic color and font palette providing platform-appropriate styling. |
| `textColor` | `PlatformColor` | Required | (Apple) Base text color for the rendered output. |
| `content` | `string` | Required | (Web) Raw markdown string (frontmatter stripped by component). |

## Deep Linking

Not applicable: Markdown Renderer is a content-display component, not a navigation target. Individual document sections (headers) may support deep linking at the container level.

## Localization

Not applicable: Markdown Renderer renders user-supplied content; localization is the responsibility of the content source, not the renderer.

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | Code highlighting and rendering do not use animation; no change required. |
| Increase Contrast | (Web) CSS variables supplied by theme should honor contrast requirements; renderer uses them as-is. (Apple) SemanticPalette colors should meet contrast requirements; renderer applies them as supplied. |
| Differentiate Without Color | Links and code are differentiated by underline (links) and background (code) in addition to color. Blockquotes use indentation in addition to color. |

## Feature Flags

Not applicable: Markdown Renderer has no feature-flag-gated behavior.

## Analytics

Not applicable: Markdown Renderer is a stateless rendering component; analytics is the responsibility of the container that invokes it.

## Privacy

Not applicable: Markdown Renderer processes content supplied by the container and produces display output. No data is collected, transmitted, or retained.

## Logging

Not applicable: Markdown Renderer does not emit logging by design. Highlighter failures or parse degradations are silent; the component never raises exceptions or logs errors. Debug output (if needed) is the responsibility of the injected highlighter or calling code.

## Platform Notes

- **SwiftUI**: Wrap `NSAttributedString` output in `Text(AttributedString(nsAttributedString))` or use a custom `NSAttributedString` view wrapper. The struct is `Sendable` for use in `@Observable` or async contexts. Palette and textColor are passed as parameters; no direct SwiftUI view styling is needed.
- **Compose**: Build a composable that accepts the markdown string plus a palette parameter (mirroring `palette`/`textColor`), walks the same block/run structure, and maps it to a Jetpack Compose `Text` with `AnnotatedString`. Use `SpanStyle` for bold, italic, strikethrough, code spans, and links, and `ParagraphStyle` for list and blockquote indentation per nesting level. Material `ColorScheme` roles substitute for `SemanticPalette` colors (e.g. `onSurface`/`onSurfaceVariant`/`surfaceVariant` for primary text, blockquote text, and code block background). Fenced code blocks render in `FontFamily.Monospace`, using an injected highlighter's styled spans when available and falling back to unstyled monospaced text otherwise, matching the source's fallback behavior.
- **React/Web**: Use the `MarkdownRenderer` component exported from the package. Pass raw markdown as the `content` prop. Rendering is async; initial state shows "Rendering…" with appropriate ARIA attributes. On error, an error pane is displayed. CSS variables are emitted by the processor for theme switching without re-render.
- **AppKit / UIKit**: Call `MarkdownRenderer.render(_:palette:textColor:)` to produce `NSAttributedString`, then display via `NSTextView` (macOS) or `UITextView` (iOS). Optionally inject a `CodeHighlighter` for syntax highlighting. The method is thread-safe (Swift concurrency `Sendable`).
- **WinUI 3**: Use `RichTextBlock` with `Paragraph` blocks and `Run`/`Bold`/`Italic`/`Hyperlink` inlines, or drive the same output from a Markdown-to-XAML mapping that walks the renderer's block/run structure. `Run.Foreground` and `TextElement.FontFamily`/`FontWeight` carry the palette's text, heading, and code colors and fonts; `Paragraph.Margin` carries list and blockquote indentation per nesting level; `Hyperlink.Foreground` plus its default underline carry link styling. Fenced code blocks render inside a `Paragraph` with a monospaced `Run` and a `Border` background for `controlBackground`, with syntax highlighting delegated to a highlighting service analogous to Apple's `CodeHighlighter` protocol and falling back to unstyled monospaced text when no highlighter is supplied.

## Design Decisions

1. **Partial parse fallback**: The parser uses `failurePolicy: .returnPartiallyParsedIfPossible` to degrade incomplete or malformed markdown to plaintext. This ensures that streaming edits and user input errors do not result in empty or corrupted output. A parse failure is never fatal.

2. **Block identity tracking**: Blockquote and table identities are tracked separately to allow per-block styling (e.g., coloring an entire blockquote) without ambiguity when structures are adjacent. This is essential for correct rendering of complex nested and adjacent structures.

3. **Injected highlighter pattern**: Syntax highlighting is optional and supplied by the host application via the `CodeHighlighter` protocol (Apple) or Shiki (web). This avoids shipping a large grammar stack in the framework and allows the host to provide custom highlighting behavior.

4. **Platform-appropriate output**: Apple produces `NSAttributedString` (native to UIKit/AppKit rendering); web produces HTML (native to DOM rendering). Both apply semantic palette styling, but the output format is optimized for the platform.

5. **Sanitization on web**: HTML output is always passed through rehype-sanitize before injection into the DOM. The component never exposes unsanitized HTML to `dangerouslySetInnerHTML`.

6. **Header level mapping**: Headers level 1–2 use display roles (title and heading) from the palette. Level 3 uses the heading role at its default weight. Levels 4–6 use body font with bold weight, as the palette has no smaller heading role and an invented one would diverge from the toolkit's type scale.

7. **No re-render on theme switch (web)**: Code highlighting colors are emitted as CSS variables, allowing the reading theme to repaint via CSS without re-processing the markdown. This eliminates flashing or "Rendering…" state on theme change.

## Compliance

Not applicable: Markdown Renderer conforms to CommonMark specification and applies semantic palette styling as supplied; no specific compliance checks apply beyond source-code fidelity.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.1.0 | 2026-09-22 | | Replace NEEDS REVIEW markers on the Compose and WinUI 3 Platform Notes bullets with concrete translation guidance |
| 1.0.0 | 2026-09-22 | | Initial creation |
