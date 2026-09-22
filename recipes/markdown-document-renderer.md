---
id: 840b5a7a-921a-4770-8dea-5ffbf9a2ee6c
title: Markdown Document Renderer
domain: agenticdevelopercookbook://ingredients/markdown-document-renderer
type: ingredient
version: 1.0.1
status: review
language: en
created: 2026-09-22
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Renders complete markdown documents with GitHub alert callouts, task lists,
  and semantic coloring.
platforms:
- swift
tags:
- markdown
- document-rendering
- text-rendering
depends-on: []
related: []
references: []
---

# Markdown Document Renderer

## Overview

Renders a complete markdown document as an `NSAttributedString`. Distinguishes itself from fragment renderers by handling three document-specific concerns: frontmatter removal, GitHub-style alert blockquotes with semantic role-based coloring, and GitHub Flavored Markdown task list rendering with Unicode checkbox characters. The component accepts an optional code highlighter for syntax highlighting in fenced code blocks.

## Behavioral Requirements

- **must-accept-markdown-string**: Component MUST accept a markdown string as input.
- **must-remove-frontmatter**: Component MUST strip YAML frontmatter from the beginning of the document before rendering (content between leading `---` delimiter and closing `---`).
- **must-detect-alert-blockquotes**: Component MUST detect GitHub alert blockquotes formatted as `> [!TYPE]` where TYPE is one of: NOTE, TIP, IMPORTANT, WARNING, or CAUTION. Detection MUST occur on the source string before markdown parsing, not on the rendered output.
- **must-require-alert-tag-on-first-line**: Alert blockquotes MUST have the tag (`[!TYPE]`) alone on the first line of the quote block. Tags appearing on subsequent lines or in continuation quotes MUST NOT trigger alert styling.
- **must-color-alerts-by-role**: Detected alerts MUST be colored according to their mapped semantic role: NOTE→info, TIP→success, IMPORTANT→accent, WARNING→warning, CAUTION→danger.
- **must-preserve-alert-styling-across-blockquote**: Alert coloring MUST apply to the entire blockquote block, including all lines the blockquote contains, not just until the first blank line.
- **must-render-task-list-unchecked**: Unchecked task list items formatted as `- [ ]` in GFM MUST be rendered with a Unicode open checkbox character (U+2610, ☐).
- **must-render-task-list-checked**: Checked task list items formatted as `- [x]` or `- [X]` in GFM MUST be rendered with a Unicode ballot box with check character (U+2611, ☑).
- **must-exclude-fenced-code-from-processing**: Lines within fenced code blocks MUST NOT be processed for alert detection, task list rewriting, or quote line hardening.
- **must-normalize-line-endings**: Line endings MUST be normalized to LF (U+000A) in the rendered output. CRLF line endings in source MUST be converted.
- **must-harden-blockquote-breaks**: Consecutive blockquote lines MUST have hard breaks inserted (two trailing spaces or backslash) to preserve line separation, unless the line already terminates with a hard break.
- **must-accept-optional-highlighter**: Component MUST accept an optional code highlighter instance for syntax highlighting in fenced code blocks and MUST NOT require one.
- **must-return-attributed-string**: Component MUST return an `NSAttributedString` with all formatting applied (colors, typography, emphasis).

## Appearance

Not applicable: This component is a text-rendering primitive that returns styled text; appearance is determined by the rendering host (view or text system) and the semantic palette passed at render time.

## States

Not applicable: The component is stateless. Rendering is a pure function of input markdown, palette, and text color.

## Accessibility

- **must-preserve-text-semantic-structure**: Component MUST preserve markdown semantic structure (headings, lists, emphasis) in the rendered output so assistive technologies can interpret document hierarchy.
- **must-map-alerts-to-color-and-label**: Alert blockquotes MUST be visually distinguished by both color (semantic role) and text label (NOTE, TIP, IMPORTANT, WARNING, CAUTION in uppercase). Color alone MUST NOT be the only distinguishing factor.
- **must-render-checkboxes-as-text**: Task list checkboxes MUST render as Unicode text characters (☐, ☑) so assistive technologies can announce them as text, not as interactive controls (task list items are not interactive in a static document).

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| mdr-001 | must-remove-frontmatter | `"---\ntitle: Test\n---\n# Heading"` | Rendered output begins with "Heading", no frontmatter |
| mdr-002 | must-detect-alert-blockquotes | `"> [!NOTE]\n> This is a note"` | Alert detected, colored with info role |
| mdr-003 | must-color-alerts-by-role | `"> [!WARNING]\n> Danger"`, `"> [!TIP]\n> Good idea"` | WARNING block colored with warning role, TIP with success role |
| mdr-004 | must-require-alert-tag-on-first-line | `"> Regular quote\n> [!NOTE]"` | No alert styling applied (tag not on first line) |
| mdr-005 | must-preserve-alert-styling-across-blockquote | `"> [!CAUTION]\n> Line 1\n> Line 2\n> Line 3"` | All lines in blockquote colored with danger role |
| mdr-006 | must-render-task-list-unchecked | `"- [ ] Unchecked task"` | Renders with ☐ character |
| mdr-007 | must-render-task-list-checked | `"- [x] Completed task"` | Renders with ☑ character (lowercase x) |
| mdr-008 | must-render-task-list-checked-uppercase | `"- [X] Completed task"` | Renders with ☑ character (uppercase X) |
| mdr-009 | must-exclude-fenced-code-from-processing | `` "```\n> [!NOTE]\n```" `` | Blockquote markers inside fence rendered as literal text, no alert |
| mdr-010 | must-harden-blockquote-breaks | `"> Line 1\n> Line 2"` | Two-line blockquote preserves line break (hard break inserted if needed) |
| mdr-011 | must-normalize-line-endings | `"Heading\r\nParagraph"` (CRLF input) | Output uses LF only |
| mdr-012 | must-accept-optional-highlighter | Component initialized without highlighter | Rendering succeeds, no syntax highlighting in code blocks |
| mdr-013 | must-accept-optional-highlighter-with-value | Component initialized with highlighter | Code blocks receive syntax highlighting |
| mdr-014 | must-return-attributed-string | Any valid markdown input | Output is NSAttributedString with formatting attributes |

## Edge Cases

- **Null or empty input**: An empty string MUST render as an empty `NSAttributedString`. A nil input is not possible in Swift's type system; the API requires a non-nil String.
- **No frontmatter**: A document with no leading `---` delimiter MUST render without modification to the content.
- **Malformed frontmatter**: A leading `---` without a closing `---` on a subsequent line MUST be treated as the start of content, not frontmatter (renders literally).
- **Multiple alerts in one document**: Multiple distinct alert blockquotes MUST each be detected and colored independently.
- **Nested blockquotes**: When one blockquote line references another with multiple `>` symbols (e.g., `> > nested`), only the outermost blockquote identity is used to determine the coloring span.
- **Alert tag not alone on first line**: `> [!NOTE] extra text after tag` MUST be treated as a regular blockquote (tag is not alone).
- **Task list outside list context**: A string matching the task list pattern outside a list item MUST NOT be rewritten (pattern matching is restricted to list item lines).
- **Already hard-broken quote lines**: A quote line that already ends with `\` or two spaces MUST NOT have another hard break appended, to avoid doubling the break.
- **Fenced code containing alert or task markers**: All content inside fenced code blocks (delimited by ` ``` ` or `~~~`) MUST be rendered as literal text; alert detection, task list rewriting, and quote hardening MUST NOT apply.
- **Private-use sentinel collision**: The component uses private-use Unicode code points (U+E000, U+E001) as sentinels during rendering. Author-written content containing these code points is extremely unlikely but MUST NOT interfere with alert detection (the sentinel is placed only after alert tags are confirmed and fenced content is excluded).

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| highlighter | CodeHighlighter? | nil | Optional syntax highlighter for code blocks. If provided, applied to code fences during rendering. |

## Deep Linking

Not applicable: This component is a rendering primitive, not a document view or navigation target.

## Localization

| String Key | Default (en) | Context |
|-----------|-------------|---------|
| (none) | — | Alert labels (NOTE, TIP, IMPORTANT, WARNING, CAUTION) are derived from the MarkdownAlert enum's `label` property, which returns the uppercased alert type name. Localization of alert labels is not currently supported and would require a theme or locale parameter. |

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | Not applicable: This component is a text renderer, not an animation. No motion is produced. |
| Increase Contrast | Not applicable: Contrast is controlled by the `SemanticPalette` and host view's text styling, not by the component. |
| Differentiate Without Color | Component MUST use both color and text label for alerts, so differentiation is not color-only. Task list checkboxes (☐, ☑) are text, not color-coded. |

## Feature Flags

| Flag Key | Default | Description |
|----------|---------|-------------|
| (none) | — | No feature flags are defined for this component. |

## Analytics

Not applicable: This component is a text-rendering primitive with no user interaction or lifecycle events to track.

## Privacy

Not applicable: The component processes markdown text without collecting, storing, or transmitting any data beyond the rendered output.

## Logging

Subsystem: Component does not emit logs. Processing happens in the render synchronously; errors are not explicitly logged.

## Platform Notes

- **SwiftUI**: Render using the `AttributedString` initializer from the returned `NSAttributedString` (SwiftUI 3.0+). Use `Text(AttributedString(attributedString))` to display. If using `Link` or `NavigationLink` on text, note that the NSAttributedString attachment points and link attributes are preserved.
- **Compose**: Build the same pipeline over `buildAnnotatedString`: run the markdown transformations, then emit `SpanStyle` runs for emphasis and code, `ParagraphStyle` for headings and block quotes, and `LinkAnnotation.Url` for links. Alert blocks become a `Row` with a leading icon and a tinted `Surface`; task-list items become a `Checkbox` plus `Text`. Display with `Text(annotatedString)` inside a `SelectionContainer`.
- **React/Web**: Use a JavaScript markdown parser (remark or markdown-it) with plugins for GitHub alerts and task lists, rendering to DOM elements or a React tree; the alert palette maps to CSS custom properties on the alert container.
- **AppKit / UIKit**: Use `NSTextView` or `UITextView` with `attributedText` property set to the returned `NSAttributedString`. For macOS, set the text view's delegate to handle any selection or editing. For iOS, ensure the text view is not editable unless document editing is required (use `isEditable = false` for display-only documents).
- **WinUI 3**: Run the same markdown transformations, then render into a read-only `RichTextBlock`: one `Paragraph` per block, `Run` / `Bold` / `Italic` / `Hyperlink` inlines, a monospace `Run` with `FontFamily="Consolas"` for code, and `Paragraph.Margin` for spacing. Alert blocks become a `Border` with `Background` bound to the semantic brushes (`SystemFillColorCautionBackgroundBrush`, `SystemFillColorAttentionBackgroundBrush`, `SystemFillColorSuccessBackgroundBrush`, `SystemFillColorCriticalBackgroundBrush`) holding an icon and a nested `RichTextBlock`; task-list items become a `CheckBox` with `IsEnabled="False"` beside the item text. Use `RichEditBox` only when the document must be editable.

## Design Decisions

**Alert detection on source, not rendered output.** Early versions attempted to detect alerts by searching for the tag text in the rendered markdown output. This approach failed in three ways: (1) a code fence documenting `[!NOTE]` would match and suppress all subsequent real alerts because the exclusion list was computed once before rendering; (2) the exclusion list used text-based ranges that drifted as alerts were rewritten and the string shortened; (3) the alert's colored run was delimited by the first `\n\n` (paragraph break), which is not a block boundary in markdown—this painted parts of tables and other adjacent blocks. Detection now occurs on the source string before parsing, using `FenceScanner.classify` to skip fenced lines, eliminating all three failure modes.

**Sentinels are private-use code points.** The component marks each detected alert with a sentinel (U+E000 and U+E001 surrounding the alert index) that survives the markdown parser as inert text. This allows the color pass to locate the exact alert block by searching for the sentinel, rather than inferring it from label text. The private-use range ensures no collision with author-written content.

**Blockquote line breaks are hardened before rendering.** The markdown parser treats a single newline inside a blockquote as a soft break (collapsed to a space). To preserve line structure in multi-line blockquotes, the component inserts a trailing hard break (two spaces or backslash) on every quote line that is followed by another quote line, unless it already has one. This is a CommonMark feature and must happen on the source before parsing, not after.

**Task list markers are rewritten on source, not on rendered output.** GFM `[ ]` and `[x]` syntax are literal text in `NSAttributedString(markdown:)`; the markdown parser does not interpret them. The component rewrites them to Unicode checkbox characters on the source, so the parser leaves them in place. After rendering, a simple string replacement collapses the resulting `•\t☐ ` (bullet, tab, checkbox, space) pattern to `☐\t` (checkbox, tab), matching the layout of other list markers.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| Not evaluated | — | — |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation from source code |
| 1.0.1 | 2026-09-22 | Mike Fullerton | Platform Notes: replaced not-applicable bullets with Compose, web and WinUI 3 translation guidance |
