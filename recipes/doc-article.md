---
id: eb0b16a5-f27e-4b28-9517-12bedc892b7f
title: Doc Article
domain: agenticdevelopercookbook://ingredients/doc-article
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Renders pre-rendered document HTML with prose typography and scroll-linked
  heading anchors.
platforms:
- web
tags:
- prose
- content
- html-rendering
depends-on: []
related: []
references: []
---

# Doc Article

## Overview

DocArticle is a container component for rendering pre-rendered, trusted document HTML with Tailwind prose styling applied. It wraps build-time rendered content (e.g., markdown converted to HTML at build time) and applies consistent typography, scroll behavior, and semantic structure. The component is designed for static prose content only — the host is responsible for sanitizing and producing the HTML before passing it to the component.

## Behavioral Requirements

- **must-accept-html-prop**: Component MUST accept a required `html` string prop containing pre-rendered HTML markup.
- **must-render-with-dangerously-set-inner-html**: Component MUST render the provided HTML string using React's `dangerouslySetInnerHTML` without escaping or encoding.
- **must-apply-prose-typography**: Component MUST apply the class `prose max-w-none prose-headings:scroll-mt-20 prose-code:before:content-none prose-code:after:content-none` to structure prose typography.
- **must-support-semantic-element-selection**: Component MUST accept an `as` prop that allows rendering as `article`, `div`, or `section` element.
- **must-default-to-article-element**: Component MUST default to rendering as an `article` element when the `as` prop is not provided.
- **must-support-html-attributes**: Component MUST accept and spread standard HTML attributes (excluding `children` and `dangerouslySetInnerHTML`) via React's `HTMLAttributes<HTMLElement>`.
- **must-allow-class-name-override**: Component MUST accept a `className` prop that is merged with the prose class using a class merging utility.
- **must-remove-code-pseudo-content**: Component MUST remove `::before` and `::after` pseudo-elements from code blocks via the `prose-code:before:content-none prose-code:after:content-none` Tailwind classes.
- **must-set-heading-scroll-margin**: Component MUST set `scroll-margin-top: 5rem` (80px) on heading elements via the `prose-headings:scroll-mt-20` Tailwind class.
- **must-not-allow-children-prop**: Component MUST reject or ignore the `children` prop; HTML content MUST be passed exclusively via the `html` prop.

## Appearance

- **Typography**: Follows Tailwind prose classes for consistent document rendering (headings, paragraphs, lists, tables, code blocks inherit prose styling).
- **Heading scroll offset**: `scroll-margin-top: 5rem` applied to all heading elements to account for fixed UI above when anchor links jump to headings.
- **Code block styling**: Pseudo-elements (`::before`, `::after`) removed from inline and block code to prevent markdown render artifacts.
- **Width constraint**: `max-w-none` allows the component to fill its container width; prose is not constrained to a specific column width.
- **Padding and margin**: Inherited from prose classes; no additional padding or margin applied by the component itself.

## States

| State | Appearance change |
|-------|------------------|
| Default | Prose typography applied; headings have scroll offset; code blocks styled as prose |

## Accessibility

- **Semantic element selection**: The `as` prop allows the host to choose semantically appropriate elements (`article` for standalone documents, `div` for document fragments, `section` for sections within larger pages). This choice directly affects accessibility announcements and document structure.
- **Heading navigation**: Headings within the prose (rendered as `<h1>`–`<h6>` tags in the HTML) MUST be marked with proper heading levels and MUST be announced by screen readers.
- **Scroll offset for anchor navigation**: The `scroll-mt-20` class ensures that when an anchor link jumps a page to a heading, the heading is not obscured by fixed navigation bars above, preserving readability and accessibility for keyboard and screen reader users.
- **Code block clarity**: Removal of pseudo-content from code blocks ensures screen reader announcements of code are accurate and not cluttered with generated content.
- **Link semantics**: Links within the rendered HTML MUST be properly marked and MUST be navigable via keyboard and assistive technology (the host is responsible for this in the rendered HTML).
- **Image alternatives**: Any images in the rendered HTML MUST have alt text (the host is responsible for this in the rendered HTML).
- **Color contrast**: The prose classes inherit text and background colors from the document's theme; the host is responsible for ensuring color contrast meets WCAG standards.
- **Resize text**: Text and spacing within prose rendering SHOULD scale appropriately if the user enlarges text via browser or OS settings (inherited from prose classes and browser rendering).

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| doc-article-001 | must-accept-html-prop | `html="<p>Hello world</p>"` | Component renders without error; paragraph is displayed |
| doc-article-002 | must-render-with-dangerously-set-inner-html | `html="<strong>Bold text</strong>"` | Text appears bold in the rendered output (HTML is not escaped) |
| doc-article-003 | must-apply-prose-typography | `html="<h1>Heading</h1><p>Body</p>"` | Heading and paragraph receive prose typography styling |
| doc-article-004 | must-default-to-article-element | `html="<p>Content</p>"` (no `as` prop) | Component renders as `<article>` element in the DOM |
| doc-article-005 | must-support-semantic-element-selection | `as="div"` with `html="<p>Content</p>"` | Component renders as `<div>` element |
| doc-article-006 | must-support-semantic-element-selection | `as="section"` with `html="<p>Content</p>"` | Component renders as `<section>` element |
| doc-article-007 | must-support-html-attributes | `id="doc-1" data-test="value"` with `html="<p>Test</p>"` | Attributes are present on the rendered element |
| doc-article-008 | must-allow-class-name-override | `className="custom-class"` with `html="<p>Test</p>"` | Component has both prose class and custom class applied |
| doc-article-009 | must-set-heading-scroll-margin | `html="<h2>Section</h2>"` | Heading has `scroll-margin-top: 5rem` applied |
| doc-article-010 | must-remove-code-pseudo-content | `html="<code>const x = 1;</code>"` | Code block has no `::before` or `::after` pseudo-elements |
| doc-article-011 | must-not-allow-children-prop | `children="Ignored"` with `html="<p>From HTML</p>"` | Only the HTML prop content is rendered; children prop is ignored |

## Edge Cases

- **Empty HTML string**: If `html=""` is passed, the component renders an empty element with prose classes applied. Expected behavior: a visually empty container with no content.
- **HTML without semantic structure**: If `html` contains only inline text with no paragraph or heading tags, the text is rendered directly. Expected behavior: text appears unstyled (prose classes only style semantic elements).
- **Very large HTML documents**: Large documents with thousands of elements may impact rendering performance. No specific size limit is enforced; the browser's DOM rendering performance applies.
- **HTML with event handlers**: If the rendered HTML includes inline event handlers (e.g., `onclick`), they MUST NOT fire. Expected behavior: React's `dangerouslySetInnerHTML` does not execute inline scripts or event handlers; they are inert.
- **HTML with script tags**: If the rendered HTML includes `<script>` tags, they MUST NOT execute. Expected behavior: `dangerouslySetInnerHTML` renders script tags as DOM elements but does not execute them.
- **Nested prose containers**: If the rendered HTML contains another DocArticle component, no special behavior is defined. Expected behavior: nested components render normally.
- **Missing html prop**: If the `html` prop is omitted or `undefined`, the component renders an empty element. Expected behavior: TypeScript type checking should catch this at compile time; runtime behavior is undefined.
- **HTML with inline styles conflicting with prose**: If rendered HTML includes inline `style` attributes that conflict with prose classes (e.g., `<p style="color: red;">`), inline styles take precedence in CSS specificity. Expected behavior: inline styles override prose classes.

## Configuration

Not applicable: DocArticle does not expose configuration options. Behavior is determined entirely by the `html` and `as` props.

## Deep Linking

Not applicable: DocArticle does not implement deep linking. Link navigation within the rendered HTML is handled by the browser's default link behavior.

## Localization

Not applicable: DocArticle renders only the HTML provided by the host. Localization of content is the host's responsibility.

## Accessibility Options

- **Reduce Motion**: The prose classes and scroll behavior do not include animations or transitions affected by the `prefers-reduced-motion` media query. Expected behavior: no additional changes needed for reduced-motion users.
- **Increase Contrast**: Prose classes inherit text and background colors from the document's theme. If the theme respects `prefers-contrast`, prose rendering will reflect increased contrast.
- **Differentiate Without Color**: Prose classes do not rely on color alone for semantic meaning (e.g., links are underlined, not just colored). Expected behavior: content remains distinguishable without color cues.

## Feature Flags

Not applicable: DocArticle does not respond to feature flags.

## Analytics

Not applicable: DocArticle does not emit analytics events. The host is responsible for tracking user interactions with content.

## Privacy

Not applicable: DocArticle does not collect or transmit data. The component is a pure rendering layer for host-provided HTML.

## Logging

Not applicable: DocArticle does not produce debug or error logs.

## Platform Notes

- **React/Web**: Native implementation in `packages/web/packages/ui/src/blocks/doc-article.tsx`. Renders HTML with Tailwind prose classes. Exports `DOC_ARTICLE_PROSE_CLASS` constant for reuse in other prose contexts.
- **SwiftUI**: Start from SwiftUI's `WebView` (iOS 14.5+) or a third-party HTML rendering library. Apply equivalent Tailwind prose styling via CSS injected into the web view. Support semantic element choice via view modifier accepting `"article" | "div" | "section"`.
- **Compose**: Use Compose's `AndroidView` with Android's `WebView` control, or a third-party Markdown/HTML rendering library. Apply prose styling via CSS injected into the web view. Support semantic element selection via composable parameter.
- **AppKit / UIKit**: Use `WKWebView` on iOS or `WebView` on macOS. Inject CSS containing Tailwind prose classes and scroll behavior. Support `as` parameter to render the appropriate semantic element in the web view.
- **WinUI 3**: Use XAML `WebView2` control. Inject HTML with embedded or linked CSS for Tailwind prose styling and scroll-margin-top behavior. Support semantic element selection by rendering `<article>`, `<div>`, or `<section>` as the root in the injected HTML. Use `CoreWebView2.AddScriptToExecuteOnDocumentCreatedAsync()` to inject prose styles if needed.

## Design Decisions

- **dangerouslySetInnerHTML over children**: The component uses `dangerouslySetInnerHTML` instead of accepting pre-rendered React elements as children because the host needs to control the exact HTML string (for build-time markdown rendering, external content sources, etc.). This design pushes the responsibility for sanitization and trust onto the host, which is appropriate for build-time rendered content.
- **Scroll margin on headings**: The `scroll-mt-20` (5rem / 80px) scroll offset is applied to headings to account for fixed navigation or header UI that may be present above the document. This ensures anchor links to headings do not disappear under fixed UI. The 5rem value is a cross-platform default; hosts MAY override this via the `className` prop if their layout requires a different offset.
- **Removal of code pseudo-content**: The `prose-code:before:content-none prose-code:after:content-none` classes remove pseudo-elements from code blocks because markdown renderers may emit opening/closing quotes or other artifacts in `::before` and `::after` content. Removing them ensures clean code block rendering in the browser and accurate screen reader announcements.
- **No direct support for HTML sanitization**: The component does not sanitize or validate the `html` prop. The host MUST trust the HTML source and sanitize it before passing it to DocArticle. For user-submitted content, the host MUST use a sanitization library (e.g., `sanitize-html`, `DOMPurify`) before rendering.
- **HTMLAttributes spread**: The component extends `Omit<HTMLAttributes<HTMLElement>, "children" | "dangerouslySetInnerHTML">` to allow hosts to pass arbitrary HTML attributes (id, data-* attributes, aria-* attributes, event handlers if needed) while explicitly blocking misuse of `children` and `dangerouslySetInnerHTML`.

## Compliance

Not applicable: No compliance checks are defined for this component. Compliance depends on the HTML content provided by the host (e.g., GDPR compliance for data in the rendered content is the host's responsibility).

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | | Initial creation |
