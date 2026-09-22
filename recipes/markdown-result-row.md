---
id: abd8ebe3-468d-4dda-8da2-cb00a97ae84c
title: Markdown Result Row
domain: agenticdevelopercookbook://ingredients/markdown-result-row
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A search result row displaying markdown document metadata with per-kind variants,
  highlighting, and expanded touch targets.
platforms:
- typescript
- web
tags:
- search-results
- markdown-documents
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Markdown Result Row

## Overview

The Markdown Result Row is a specialized search result component designed to display indexed markdown documents (papers, research, articles) within a search results list. It combines universal scaffolding with per-kind customization: the layout, spacing, and interaction model remain constant, while visual indicators (badge variant and subtitle source) adapt to the document kind via a renderer registry. The component integrates into roving-tabindex-managed lists where exactly one row is the active keyboard stop, and also supports standalone rendering outside list context.

## Behavioral Requirements

- **must-render-title**: Component MUST render the document title from `hit.title`, defaulting to the string "Untitled" when the title is null or empty.
- **must-highlight-title**: Component MUST wrap query-matching terms in the title with `<mark>` elements styled as search highlights; exact match boundaries are determined by `splitHighlightSegments(text, query)`.
- **must-render-per-kind-badge**: Component MUST render a Badge component using the variant and label supplied by `kindRendererFor(hit.kind).badge`; a missing or unrecognized `hit.kind` MUST fall back to a default renderer and MUST NOT throw.
- **must-render-snippet**: Component MUST render a snippet (or subtitle) derived from `kindRendererFor(hit.kind).rowSnippet(hit)`, trimmed of leading and trailing whitespace; the snippet MUST be highlighted with `<mark>` elements for matching query terms.
- **must-limit-snippet-lines**: Component MUST clamp snippet display to a maximum of 2 lines using CSS line clamping; line overflow MUST be indicated by ellipsis.
- **must-render-tags**: Component MUST render all tags in `hit.tags` as a comma-separated list prefixed with `#` symbols; if `hit.tags` is empty, the tags section MUST NOT be rendered.
- **must-render-category**: Component MUST render the `hit.category` as an optional uppercase label; if `hit.category` is null or empty, the category section MUST NOT be rendered.
- **must-render-author-display**: Component MUST display author attribution as "by [displayName]" when `hit.author.displayName` is a non-empty string; if displayName is null or empty after trimming, MUST fall back to "@[slug]".
- **must-render-updated-date**: Component MUST display the updated date in human-readable format when `hit.updatedAt` is present, using `formatDate(hit.updatedAt)`; if `hit.updatedAt` is absent, the date MUST NOT be rendered.
- **must-bind-select-callback**: Component MUST invoke `onSelect(hit)` when the button is clicked, passing the entire hit object.
- **must-highlight-selected-state**: Component MUST render a visually distinct border state when `selected` is true; the selected state MUST use the accent color (`apt-gold`) for the border; when false, borders MUST use a neutral color and MAY show a hover state.
- **must-indicate-pressed-state**: Component MUST set the `aria-pressed` attribute to the value of `selected`, correctly indicating to assistive technology whether the row is selected.
- **must-implement-roving-tabindex**: Component MUST support roving tabindex for list integration: when `active` is true, `tabIndex` MUST be 0; when `active` is false, `tabIndex` MUST be -1; when `active` is undefined, the native tab order MUST be used (no tabindex attribute).
- **must-forward-ref-to-button**: Component MUST forward the `controlRef` to the internal button element, enabling external focus management by the containing list.
- **must-manage-link-tabindex**: Component MUST apply the same roving-tabindex logic to the "View paper" link as the select button; both elements MUST share the same tabindex value (`rovingTab`).
- **must-enlarge-link-touch-target**: Component MUST render an invisible overlay (using CSS `::after` pseudo-element) centered vertically with a height of 24px, covering the full width of the "View paper" link; this overlay MUST make the clickable target at least 24 CSS px in height per WCAG 2.2 SC 2.5.8.
- **must-set-link-href**: Component MUST render the "View paper" link with `href` set to the prop value, allowing navigation to the public paper page.
- **must-escape-content**: Component MUST render title and snippet content as React nodes (never `dangerouslySetInnerHTML`), ensuring user-controlled text is escaped by React's default behavior.
- **must-render-rounded-corners**: Component MUST apply consistent rounded corners to the root article, badges, and interactive focus rings as defined by the design token system.

## Appearance

- **Container**: Rounded article element with flex column layout, 8px gaps between sections, 4px corner radius, 1px border, 16px padding
- **Background**: Neutral background color (`apt-bg`); selected state uses accent border color (`apt-gold`)
- **Border**: 1px width; neutral color (`apt-border`) in default state; accent color (`apt-gold`) when selected; hover state shows strong border (`apt-border-strong`)
- **Button (select control)**: Flex column, 8px gap, text-left alignment, no default outline, rounded focus ring (2px) in accent color with 25% opacity
- **Badge**: Per-kind variant from renderer; self-aligned to start
- **Title (h3)**: Base font size (16px), semibold weight, text color (`apt-text`)
- **Highlight mark**: Gold background at 25% opacity (`apt-gold/25`), small rounded corners, horizontal padding (0.125rem), text color matches body (`apt-text`)
- **Category label**: 1px border, neutral border color, 8px horizontal padding, 4px vertical padding, monospace font, 12px size, uppercase, letter-spacing 0.08em, dim text color (`apt-text-dim`)
- **Snippet**: 14px size, muted text color (`apt-text-muted`), maximum 2 lines with ellipsis clamp
- **Tags**: List with 4px gaps, 12px font size, muted text color
- **Footer (author + date)**: Flex wrap with justified spacing, 12px gap (horizontal and vertical), 12px font size, dim text color; author name in muted text; "View paper" link in accent color with underline offset (8px) and hover underline
- **Link touch target overlay**: Invisible pseudo-element, full width, 24px height, centered vertically (using `top: 50%` and `-translate-y-1/2`)

## States

| State | Appearance change |
|-------|------------------|
| Default (unselected) | Neutral border, no accent styling |
| Selected | Gold border, visual emphasis |
| Hover (unselected) | Border transitions to strong neutral color (`apt-border-strong`) |
| Focused (button) | 2px focus ring in accent color with 25% opacity |
| Focused (link) | 2px focus ring in accent color with 40% opacity |
| Active (roving tabindex) | Button and link are keyboard-accessible (tabIndex = 0) |
| Inactive (roving tabindex) | Button and link are keyboard-skipped (tabIndex = -1) |

## Accessibility

- **Role**: Article landmark containing a button (select control) and an anchor (view paper link); button has `aria-pressed` attribute
- **Button label**: The button's entire content (badge, title, snippet, tags) acts as its label; no explicit aria-label is added
- **Link text**: "View paper" provides the link's accessible label
- **Keyboard navigation**: Button and link participate in roving tabindex when `active` is defined; Tab navigation skips inactive rows (tabIndex = -1) in list context; Standalone renders (active = undefined) use natural tab order
- **Focus indicators**: Visible focus ring (2px, 25% opacity on button, 40% opacity on link) with accent color
- **Touch target size**: Link touch target is enlarged to 24px height via invisible overlay per WCAG 2.2 SC 2.5.8 (Target Size, Minimum); button has full-width touch area inherited from flex layout
- **Mark highlights**: `<mark>` elements are semantic and not styled to remove contrast; highlight styling (gold background, 25% opacity) maintains sufficient contrast with text
- **Color not sole indicator**: Selection state uses both border color and visual containment; not conveyed by color alone

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| mrr-001 | must-render-title | `hit.title = "My Document"` | Renders h3 with text "My Document" |
| mrr-002 | must-render-title | `hit.title = null` or empty string | Renders h3 with text "Untitled" |
| mrr-003 | must-highlight-title | `hit.title = "Search results", query = "search"` | Title renders with "Search" wrapped in `<mark>` element |
| mrr-004 | must-highlight-title | `hit.title = "No match", query = "xyz"` | Title renders with no `<mark>` elements |
| mrr-005 | must-render-per-kind-badge | `hit.kind = "paper"` with registered renderer | Badge renders with variant and label from renderer.badge |
| mrr-006 | must-render-per-kind-badge | `hit.kind = "unknown"` or unregistered | Component does not throw; renders with default renderer badge |
| mrr-007 | must-render-snippet | `renderer.rowSnippet(hit) = "  Some text  "` | Snippet renders as "Some text" (trimmed) |
| mrr-008 | must-render-snippet | `renderer.rowSnippet(hit) = ""` (empty after trim) | Snippet section is not rendered |
| mrr-009 | must-highlight-snippet | `snippet = "Find results fast", query = "results"` | Snippet renders with "results" wrapped in `<mark>` |
| mrr-010 | must-limit-snippet-lines | Snippet contains 4+ lines of text | CSS clamp limits visible lines to 2; overflow indicated by ellipsis |
| mrr-011 | must-render-tags | `hit.tags = ["tag1", "tag2"]` | Renders "#tag1 #tag2" (or equivalent list format) |
| mrr-012 | must-render-tags | `hit.tags = []` | Tags section is not rendered |
| mrr-013 | must-render-category | `hit.category = "Research"` | Renders uppercase label "RESEARCH" in styled capsule |
| mrr-014 | must-render-category | `hit.category = null` or empty string | Category section is not rendered |
| mrr-015 | must-render-author-display | `hit.author.displayName = "Jane Doe"` | Renders "by Jane Doe" |
| mrr-016 | must-render-author-display | `hit.author.displayName = ""` or null | Renders "by @slug" using author.slug |
| mrr-017 | must-render-updated-date | `hit.updatedAt = ISO 8601 date string` | Renders formatted date after "Updated" label |
| mrr-018 | must-render-updated-date | `hit.updatedAt = null` or undefined | Date portion of footer is not rendered |
| mrr-019 | must-bind-select-callback | User clicks the button | `onSelect(hit)` is called with the hit object |
| mrr-020 | must-highlight-selected-state | `selected = true` | Border color is accent (`apt-gold`) |
| mrr-021 | must-highlight-selected-state | `selected = false` | Border color is neutral; hover state applies strong border |
| mrr-022 | must-indicate-pressed-state | `selected = true` | `aria-pressed="true"` on button element |
| mrr-023 | must-indicate-pressed-state | `selected = false` | `aria-pressed="false"` on button element |
| mrr-024 | must-implement-roving-tabindex | `active = true` | Button and link have `tabIndex={0}` |
| mrr-025 | must-implement-roving-tabindex | `active = false` | Button and link have `tabIndex={-1}` |
| mrr-026 | must-implement-roving-tabindex | `active = undefined` | No tabindex attribute set; natural tab order applies |
| mrr-027 | must-forward-ref-to-button | `controlRef` is a React ref object | `controlRef.current` points to the button DOM element |
| mrr-028 | must-manage-link-tabindex | `active = true` and `rovingTab = 0` | Link element has `tabIndex={0}` |
| mrr-029 | must-enlarge-link-touch-target | "View paper" link is rendered | Invisible `::after` overlay covers full link width with 24px height |
| mrr-030 | must-enlarge-link-touch-target | User touches link near but outside text bounds | Touch target is activated if within the 24px overlay zone |
| mrr-031 | must-set-link-href | `href = "/paper/123"` | Link element has `href="/paper/123"` |
| mrr-032 | must-escape-content | `hit.title` contains `<script>alert('xss')</script>` | Content is rendered as text, script is not executed |
| mrr-033 | must-render-rounded-corners | Component is rendered | Article, badge, and focus rings display consistent rounded corners |

## Edge Cases

- **Empty title and null title**: Component defaults to "Untitled"; no visual distinction between the two.
- **Empty query string**: `splitHighlightSegments("text", "")` returns the full text with no marks; title and snippet render without highlights.
- **Null hit.category**: Category section is not rendered; layout does not reserve space for it.
- **Empty hit.tags array**: Tags section is not rendered; footer layout adapts.
- **Very long title or snippet**: Title and snippet are wrapped and truncated by Tailwind classes (title is unclamped, snippet is clamped to 2 lines); text overflow is handled by browser line-breaking.
- **Very long author displayName or slug**: Author text may wrap within its footer area; no ellipsis applied (browser wraps).
- **Missing hit.author.displayName and hit.author.slug**: Component renders "@undefined" or similar; no error handling for missing author fields.
- **Very long category name**: Category capsule text may overflow; rendering depends on browser and container width (Tailwind's `whitespace-nowrap` is not applied to category, allowing wrap).
- **Future-dated hit.updatedAt**: `formatDate` is called as-is; output depends on the formatter's handling of future dates (no special case defined in component).
- **Roving tabindex with active = undefined and list context**: Component renders with natural tab order; if embedded in a roving-tabindex list, the list manager's tabindex logic may override.

## Configuration

Not applicable: Component is a presentation-only element with no configuration options. All visual and behavioral variation is driven by props and the per-kind renderer registry.

## Deep Linking

Not applicable: Component does not handle deep linking. Navigation to the paper is driven by the `href` prop passed by the parent; the "View paper" link delegates to the browser's standard link navigation.

## Localization

| String Key | Default (en) | Context |
|-----------|-------------|---------|
| "Untitled" | English | Fallback title when document title is missing |
| "by" | English | Prefix for author attribution |
| "Updated" | English | Prefix for updated-at date (rendered as " · Updated [date]") |
| "View paper" | English | Text label for the public link |

All other text (title, snippet, tags, category, author name) is sourced from the data object (`hit`) and not localized by the component. Localization of data content is the responsibility of the backend or indexing layer.

## Accessibility Options

- **Reduce Motion**: Not applicable. Component is static; no animations are defined (transitions in the Tailwind `transition-colors` class are applied to the border color on state change, but no explicit animation keyframes are used). Reduce Motion preferences do not require special handling.
- **Increase Contrast**: Not applicable. Component uses design tokens from the `apt-*` system; contrast requirements are managed at the token level, not within this component.
- **Differentiate Without Color**: Not applicable. Selection state is indicated by both color (border) and structural change (visual containment); color is not the sole indicator.

## Feature Flags

Not applicable: Component has no feature flags. All rendering is conditional on data props; no feature gates are used.

## Analytics

Not applicable: Component does not emit or track analytics events. Event tracking (view, interaction) is the responsibility of the parent container or list manager.

## Privacy

- **Data collected**: None. Component is a pure presentation layer.
- **Storage**: No data is stored.
- **Transmission**: No data is transmitted by the component. The `href` prop is set by the parent; navigation is handled by the browser.
- **Retention**: No data retention considerations.

## Logging

Not applicable: Component does not emit log messages. Logging of search result interactions is the responsibility of the parent container.

## Platform Notes

- **React/Web** (TypeScript source): The component is rendered as an `<article>` with a nested `<button>` and `<a>` sibling for interactive controls (preserving valid and accessible DOM structure); styling uses Tailwind utility classes scoped to the `apt-*` design token system. The `Highlighted` helper function uses `splitHighlightSegments` utility to locate query matches and wraps them in `<mark>` elements; React's default escaping prevents XSS. Per-kind customization is pluggable via `kindRendererFor(hit.kind)` registry. Roving tabindex is managed externally by the list container; this component respects the `active` prop to set `tabIndex` accordingly. The link's touch target is enlarged via CSS `::after` pseudo-element (invisible overlay), implementing WCAG 2.2 SC 2.5.8 without changing the visual layout.
- **SwiftUI**: A SwiftUI equivalent would use a `VStack` with sections for badge, title, snippet, tags, category, and footer. The per-kind badge variant and subtitle source would map to SwiftUI view parameters; a `@State` or bound property would track the selected state. Roving focus would be managed by SwiftUI's `.focusable()` and `FocusState` mechanisms. The enlarged link touch target would be implemented as a larger transparent overlay frame behind the link text, or by increasing the native button frame size. Title and snippet highlighting would require attributed strings or custom text rendering to apply inline styling (background highlight color, rounded corners) to matched segments.
- **Compose** (Android): A Compose equivalent would use a `Column` with `Row` layouts for header (badge + title), category, snippet, tags, footer. Per-kind customization would be factored into a composable parameter block (badge variant, snippet source). Selected state would modify border color and stroking; state would be held in a `MutableState` or via ViewModel. Roving tab/focus would use Compose's `FocusRequester` and `focusModifier()`. The link's touch target would be enlarged by padding the clickable `Modifier.clickable()` area or by wrapping in a larger `Box`. Highlighted text segments in title and snippet would use `AnnotatedString` with `SpanStyle` for background highlights and rounding.
- **AppKit / UIKit**: A UIKit/AppKit equivalent would use `UIStackView` (iOS) or `NSStackView` (macOS) with `UIView`/`NSView` subviews for badge, title, snippet, tags, category, and footer. Per-kind badge variant would be a delegate or registry lookup. Selected state would modify the border (using a `CAShapeLayer` or `UIBezierPath` for rounded borders) and background. Keyboard focus (roving tabindex simulation) would use `UIView.canBecomeFocused`, `setNeedsFocus()`, or `becomeFirstResponder()` on relevant subviews. The link's touch target would be enlarged by overriding `hitTest(_:with:)` or by applying a larger `UIButton` frame. Text highlighting for matched query terms would use `NSMutableAttributedString` with background color and paragraph style attributes applied to specific ranges.
- **WinUI 3**: A WinUI 3 equivalent would be an `ItemsControl` or custom `UserControl` with a `StackPanel` (vertical). Per-kind badge variant would use a `ComboBox` or similar lookup bound to the kind. Selected state would modify the `BorderBrush` and `BorderThickness` properties of a `Border` element wrapping the content. Keyboard focus (roving tabindex) would be managed by setting `Focus()` on the selected row's button or by manipulating `TabIndex` on each row's button and link; the parent list manager would coordinate roving focus. The link's touch target would be enlarged by applying a `Padding` thickness to the link's parent layout or by using `PointerEntered`/`PointerExited` hit-testing with a custom clickable overlay area. Text highlighting for matched query terms in title and snippet would use a `RichTextBlock` with `Run` elements styled with `Foreground` and `Background` properties, or by implementing a custom `TextBlock` subclass with inline rendering logic.

## Design Decisions

- **Roving tabindex support with optional activation**: The `active` prop supports three states (true, false, undefined), allowing the component to integrate seamlessly into managed lists (where active controls the tabindex) and also render standalone (where undefined preserves natural tab order). This avoids forcing list context on every use case.
- **Per-kind extensibility via registry**: Rather than hard-coding badge variants and snippet sources, the component delegates to `kindRendererFor(hit.kind)` registry. This allows new document kinds to be added by registering a renderer without modifying the component itself.
- **Escaped content and `<mark>` for highlights**: Highlights are applied via semantic `<mark>` elements and React's node children (never `dangerouslySetInnerHTML`), ensuring that user-controlled text from `hit.title`, `snippet`, and `hit.tags` cannot introduce XSS vulnerabilities.
- **Enlarged link touch target via pseudo-element**: The link text itself is kept at 12px (small, readable) while the clickable area is enlarged to 24px using an invisible `::after` overlay. This preserves visual design while meeting WCAG 2.2 SC 2.5.8 and follows the idiom already used by the active-filter chip × button.
- **Siblings, not nesting**: The select button and "View paper" link are rendered as sibling elements (button followed by link in the footer), not nested. This preserves valid DOM structure and allows independent keyboard focus and interaction, avoiding the complexity of nested interactive controls.
- **Trim snippet before rendering**: `kindRendererFor(hit.kind).rowSnippet(hit).trim()` is called to remove leading/trailing whitespace from the per-kind snippet, ensuring consistent rendering regardless of formatter output.
- **Fallback to "Untitled"**: When `hit.title` is null or empty, the component renders "Untitled" as a fallback label. This ensures that every row has a visible title, making the list navigable even for documents with missing or empty titles.

## Compliance

Not applicable: Component does not implement compliance checks. Compliance with WCAG 2.1 AA (web accessibility) and other standards is ensured by the implementation's design (focus indicators, semantic HTML, roving tabindex support, enlarged touch targets, color + structural indicators for state changes). Compliance audits are external to the component itself.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
