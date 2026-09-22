---
id: afb50b48-af7a-4bc1-a13c-ae36759268c8
title: Markdown Preview Header
domain: agenticdevelopercookbook://ingredients/markdown-preview-header
type: ingredient
version: 1.0.0
status: review
language: en
created: 2026-09-22
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Metadata header for markdown preview displaying title, kind badge, author
  attribution, date, summary, and optional per-kind content.
platforms:
- typescript
- web
tags:
- markdown
- preview
- metadata
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Markdown Preview Header

## Overview

The markdown preview header is a metadata surface that displays the selected search hit's structured information: title, kind badge, author attribution, optional update date, frontmatter summary, and a per-kind extra section (e.g., research evaluation). It serves as the single metadata header for the preview, distinct from the body content rendered by the preview itself. The component conditionally renders an optional public-page link when a public route is available.

## Behavioral Requirements

- **must-render-title**: Component MUST render the hit's title. If title is empty or null, MUST render "Untitled" as fallback.
- **must-render-kind-badge**: Component MUST render a Badge component with variant and label from the per-kind renderer.
- **must-render-author**: Component MUST render author attribution in the format "by @slug" if displayName is empty or whitespace-only, or "by displayName" if displayName is present and non-empty after trimming.
- **must-render-optional-date**: Component MUST render "Updated [formatted-date]" only if updatedAt is present; MUST omit date entirely if updatedAt is null or undefined.
- **must-render-optional-summary**: Component MUST render the summary paragraph only if the summary is non-empty after trimming; MUST render nothing if summary is null, empty string, or whitespace-only.
- **must-render-optional-per-kind-extra**: Component MUST render the per-kind extra section from renderer.previewExtra(hit) only if it is truthy (non-null, non-undefined); implementations should null-guard this value.
- **must-render-optional-public-link**: Component MUST render "View full paper" link only if hit.publicRoute is truthy; MUST not render the link if publicRoute is null or undefined.
- **must-set-title-attribute**: The h3 heading MUST have a title attribute set to hit.title for tooltip display on hover.

## Appearance

- **Layout**: Vertical flex container with 8px gap between sections.
- **Title section**: Horizontal flex, space-between alignment with 12px gap; title uses min-width 0 to enable ellipsis.
- **Title styling**: text-sm, font-semibold, primary text color.
- **Badge section**: Horizontal flex wrap, x-gap 8px, y-gap 4px, text-xs, dimmed text color.
- **Author text**: Regular style with text-muted for the author value.
- **Summary section**: paragraph with text-xs, text-muted, summary label in medium weight with text-dim.
- **Public link**: text-xs, font-medium, gold accent color, underline on hover, outline-none, focus-visible ring with gold accent at 40% opacity, offset underline.
- **Link button styling**: inline-flex, min-height 6 units, shrink-0, items-center center, rounded-sm.

## States

| State | Appearance change |
|-------|------------------|
| Default | Title and metadata visible, public link underlined on hover if present |
| Public link hover | Public link text underlined |
| Public link focus | Public link has focus ring (gold accent, 40% opacity) |

## Accessibility

- **Role**: The h3 heading establishes document structure for the preview metadata.
- **Title attribute**: h3 title attribute contains full title text to support tooltip display.
- **Link semantics**: "View full paper" is a native anchor element and is keyboard accessible.
- **Focus management**: Link uses focus-visible for keyboard-only focus styling (ring appears on keyboard navigation, not on click).
- **Text alternatives**: All text is visible; no icons without labels.
- **Color not sole differentiator**: Author and metadata distinguished by text weight and position, not color alone.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| header-001 | must-render-title | hit.title = "Example Paper" | h3 displays "Example Paper" |
| header-002 | must-render-title | hit.title = "" | h3 displays "Untitled" |
| header-003 | must-render-title | hit.title = null | h3 displays "Untitled" |
| header-004 | must-render-kind-badge | hit.kind = "research", kindRendererFor returns {badge: {variant: "research", label: "Research"}} | Badge renders with variant "research" and label text "Research" |
| header-005 | must-render-author | hit.author = {displayName: "Alice Smith", slug: "alice"} | Text shows "by Alice Smith" |
| header-006 | must-render-author | hit.author = {displayName: "  ", slug: "bob"} | Text shows "by @bob" |
| header-007 | must-render-author | hit.author = {displayName: null, slug: "charlie"} | Text shows "by @charlie" |
| header-008 | must-render-optional-date | hit.updatedAt = "2026-09-20" (valid date) | Text displays "Updated [formatted-date]" |
| header-009 | must-render-optional-date | hit.updatedAt = null | Date text does not render |
| header-010 | must-render-optional-date | hit.updatedAt = undefined | Date text does not render |
| header-011 | must-render-optional-summary | hit.summary = "This is a summary" | Summary paragraph visible with "Summary: This is a summary" |
| header-012 | must-render-optional-summary | hit.summary = "" | Summary paragraph does not render |
| header-013 | must-render-optional-summary | hit.summary = "   " | Summary paragraph does not render |
| header-014 | must-render-optional-summary | hit.summary = null | Summary paragraph does not render |
| header-015 | must-render-optional-per-kind-extra | renderer.previewExtra(hit) returns a React element | Extra section renders that element |
| header-016 | must-render-optional-per-kind-extra | renderer.previewExtra(hit) returns null | Extra section does not render |
| header-017 | must-render-optional-public-link | hit.publicRoute = true, href = "https://example.com/paper" | Link visible with text "View full paper" and href attribute |
| header-018 | must-render-optional-public-link | hit.publicRoute = false | Link does not render |
| header-019 | must-render-optional-public-link | hit.publicRoute = null | Link does not render |
| header-020 | must-set-title-attribute | hit.title = "Long Paper Title Here" | h3 title attribute = "Long Paper Title Here" |

## Edge Cases

- **Empty or all-whitespace title**: Fallback to "Untitled" ensures the component always displays a title.
- **Null or undefined author fields**: Author slug is always available as fallback; if displayName is null or empty after trim, fallback to slug with @ prefix.
- **Null or missing updatedAt**: Date section is entirely omitted when updatedAt is null or undefined; no placeholder or default date is shown.
- **Truncated title**: Component uses min-width 0 on h3 to enable text ellipsis within the flex container when title exceeds available space; full title is available via title attribute.
- **Per-kind renderer fallback**: kindRendererFor returns a neutral default renderer for unknown kinds; previewExtra may return null or undefined for kinds without extra content.
- **Missing public route**: Link is not rendered if publicRoute is falsy; href and route values are independent (href may be a well-formed string even if route is falsy).

## Configuration

Not applicable: This component receives all configuration via props (hit, href) and the per-kind renderer map. No configuration options are exposed.

## Deep Linking

Not applicable: This component is a nested metadata surface within a preview dock; it does not handle or receive deep link routing.

## Localization

| String Key | Default (en) | Context |
|-----------|-------------|---------|
| `paper.view-full` | "View full paper" | Label for public page link |
| `paper.by` | "by" | Preposition for author attribution |
| `paper.updated` | "Updated" | Prefix for update date |
| `paper.summary` | "Summary:" | Label for summary section |
| `paper.untitled` | "Untitled" | Fallback title for missing title |

## Accessibility Options

- **Reduce Motion**: Not applicable: this component does not animate or transition; only static focus-visible styling on the link applies.
- **Increase Contrast**: Focus ring on link uses focus-visible; implementations should ensure focus-visible ring color meets 3:1 contrast with background.
- **Differentiate Without Color**: Component relies on text weight, position, and structure; author attribution is distinguished by preceding text label "by", not color alone.

## Feature Flags

Not applicable: This component has no optional behaviors guarded by feature flags. Rendering is determined entirely by the input data (presence of date, summary, public route, etc.).

## Analytics

Not applicable: This component does not emit analytics events. Analytics for public link clicks or preview interactions should be implemented at a higher level (parent preview dock).

## Privacy

Not applicable: This component renders structured metadata from the input hit object; it does not collect, transmit, or store user data.

## Logging

Not applicable: This component performs no async operations, external calls, or error conditions that require logging.

## Platform Notes

- **Source (TypeScript/Web)**: Implemented in `packages/web/packages/search/src/components/markdown/MarkdownPreviewHeader.tsx` as a React functional component using inline Tailwind CSS classes. Styled with `apt-*` design tokens (apt-text, apt-gold, apt-text-dim, apt-text-muted). Integrates Badge from `@agenticdevelopertoolkit/ui/components/badge` and uses `kindRendererFor` map for per-kind customization.
- **SwiftUI**: Implement as a view composition using a VStack for vertical layout and HStack for the title row. Use @State to manage author and date formatting. The per-kind badge becomes a SwiftUI view parameter. Conditional rendering with `if` statements for optional date, summary, and public link. Text styling via .font, .foregroundColor modifiers.
- **Compose**: Implement as a Composable function using Column for vertical layout and Row for the title section. Use Modifier for layout constraints (min-width of 0 for title ellipsis). Conditional composition with if statements for optional content. Badge is an imported Composable. Text styling via Text() and Modifier.
- **AppKit / UIKit**: Implement with NSStackView (AppKit) or UIStackView (UIKit) for vertical layout. Title uses NSTextField (AppKit) or UILabel (UIKit) with truncation to ellipsis. Public link as NSButton (AppKit) or UIButton (UIKit) with underline on hover (AppKit) or no underline (UIKit with system semantics). Author formatting via NSAttributedString (AppKit) or NSMutableAttributedString (UIKit).
- **WinUI 3**: Implement as a StackPanel with Orientation="Vertical" and Spacing="8". Title in a TextBlock with TextTrimming="CharacterEllipsis" and ToolTip binding to hit.title. Public link as a HyperlinkButton styled with Underline on PointerOver state, custom focus ring with VisualState. Badge as a UserControl or custom template. Author attribution in a TextBlock with Foreground bound to theme brush for dimmed text.

## Design Decisions

- **Optional public link**: The component renders the link only if publicRoute is truthy, guarding against routes that do not resolve to a public page. The href prop is always passed (may be a string even if no route), so the route check prevents rendering a broken or invalid link.
- **Per-kind extensibility**: The per-kind badge and extra section are sourced from kindRendererFor, allowing new kinds to be added via map entry without modifying this component. Unknown kinds fall back to a neutral default renderer.
- **Title fallback**: "Untitled" is rendered for empty or missing titles to ensure the header always has a displayed title, improving UX when metadata is incomplete.
- **Author display**: displayName is preferred over slug for readability; slug is used only as fallback (with @ prefix for visual distinction) when displayName is absent or empty.
- **Summary trimming**: Summary is null-guarded via nonEmpty() helper to exclude whitespace-only strings, preventing empty summary paragraphs.
- **Focus styling**: focus-visible ring is used for link focus to show focus only on keyboard navigation, not on click, following web accessibility best practices.

## Compliance

Not applicable: Component adheres to web accessibility standards (keyboard focus, semantic HTML, color contrast). Platform-specific accessibility requirements are addressed in platform-specific implementations (Section 508 / WCAG 2.1 AA for web via focus-visible styling and semantic link element).

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
