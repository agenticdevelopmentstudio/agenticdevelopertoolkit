---
id: afb50b48-af7a-4bc1-a13c-ae36759268c8
title: Markdown Preview Header
domain: agenticdevelopertoolkit://recipes/markdown-preview-header
type: ingredient
version: 1.1.0
status: review
language: en
created: 2026-09-22
modified: 2026-09-22
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
depends-on:
- agenticdevelopertoolkit://recipes/badge
related:
- agenticdevelopertoolkit://recipes/markdown-preview
references: []
approved-by: ''
approved-date: ''
---

# Markdown Preview Header

## Overview

The markdown preview header is a metadata surface that displays the selected search hit's structured information: title, kind badge, author attribution, optional update date, frontmatter summary, and a per-kind extra section (e.g., research evaluation). It serves as the single metadata header for the preview, distinct from the body content rendered by the preview itself. The component conditionally renders an optional public-page link when a public route is available.

## Behavioral Requirements

- **title-fallback**: Component MUST render the hit's title text, falling back to the localized "Untitled" string whenever `hit.title` is falsy (empty string, `null`, or `undefined`). This is a falsy check only, not a trim — an all-whitespace title is truthy and renders as literal whitespace. See **title-attribute** for the separate rule governing the heading's `title` attribute in the fallback case.
- **title-attribute**: The h3 heading MUST have a `title` attribute for tooltip display on hover. The attribute always carries the raw `hit.title` value — it is never replaced by the "Untitled" fallback, so a missing title produces an empty tooltip attribute alongside the "Untitled" visible text.
- **kind-badge**: Component MUST render a Badge component with variant and label from the per-kind renderer.
- **author-attribution**: Component MUST render author attribution in the format "by @slug" if displayName is empty, whitespace-only, `null`, or `undefined`, or "by displayName" if displayName is present and non-empty after trimming.
- **optional-date**: Component MUST render "Updated [formatted-date]" only if `hit.updatedAt` is present (non-empty); MUST omit the date entirely if updatedAt is `null`, `undefined`, or an empty string. The date is formatted via the shared `formatDate` helper, which is NOT locale-aware — it always formats using the `en-US` locale (e.g. "Sep 20, 2026") regardless of the active UI locale.
- **optional-summary**: Component MUST render the summary paragraph only if the summary is non-empty after trimming; MUST render nothing if summary is null, empty string, or whitespace-only.
- **summary-label**: When the summary paragraph renders, it MUST be prefixed with a "Summary:" label in a distinct (medium-weight, dimmed) style, immediately followed by the summary text in a muted style.
- **metadata-row-order**: The kind badge, author attribution, and optional update date MUST render together in a single wrapping row, in that fixed order: badge, then author, then date.
- **per-kind-extra**: Component MUST render the per-kind extra section from `renderer.previewExtra(hit)` only if it is truthy (non-null, non-undefined); implementations SHOULD null-guard this value.
- **public-link**: Component MUST render a "View full paper" link only if `hit.publicRoute` (a string) is non-empty (truthy); the component MUST NOT render the link when `publicRoute` is an empty string. The link's `href` is always the separately supplied `href` prop — its value is independent of `publicRoute` and does not affect whether the link renders.

## Appearance

- **Layout**: Vertical stack with 8pt gap between sections (title row, metadata row, summary, per-kind extra).
- **Title row**: Horizontal stack, space-between alignment, 12pt gap; the title is allowed to shrink below its content width so it can truncate with an ellipsis.
- **Title text**: Small text size, semibold weight, primary text color.
- **Metadata row**: Horizontal stack that wraps, 8pt horizontal / 4pt vertical gap, small text size, dimmed secondary text color. Contains the kind badge, author attribution, then the optional update date, in that fixed order (see **metadata-row-order**).
- **Author text**: Regular weight; the author value itself uses a muted text color.
- **Summary**: Small text, muted text color; the "Summary:" label is medium weight in a dimmed secondary color (see **summary-label**).
- **Public link**: Small text, medium weight, accent color, underlines on hover, no visible default outline, and shows a focus ring in the accent color at 40% opacity with an offset underline when focused via keyboard.
- **Link hit target**: Inline-flex, minimum height of 24pt (6 spacing units), does not shrink within its row, center-aligned content, small corner radius.

Concrete Tailwind classes and `apt-*` design tokens for this layout are given in **Platform Notes → Source (TypeScript/Web)**.

## States

| State | Appearance change |
|-------|------------------|
| Default | Title and metadata visible; public link (if present) shown without underline |
| Public link hover | Public link text underlined |
| Public link focus | Public link has focus ring (accent color, 40% opacity) |

## Accessibility

- **Role**: The h3 heading establishes document structure for the preview metadata.
- **Heading level**: Fixed at `h3` rather than exposed as a prop. This is correct because the header is always rendered exactly once, in the same position, by the preview dock (the single metadata header for the selected hit — see Overview) — it never appears at a variable depth in the document outline, so no configurable heading level is needed.
- **Title attribute**: h3 `title` attribute contains the raw title text (see **title-attribute**) to support tooltip display.
- **Link semantics**: "View full paper" is a native anchor element and is keyboard accessible.
- **Focus management**: Link uses focus-visible for keyboard-only focus styling (ring appears on keyboard navigation, not on click).
- **Text alternatives**: All text is visible; no icons without labels.
- **Color not sole differentiator**: Author and metadata distinguished by text weight and position, not color alone.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| header-001 | title-fallback | hit.title = "Example Paper" | h3 displays "Example Paper" |
| header-002 | title-fallback, title-attribute | hit.title = "" | h3 text displays "Untitled"; h3 title attribute = "" |
| header-003 | title-fallback, title-attribute | hit.title = null | h3 text displays "Untitled"; h3 title attribute = "" |
| header-004 | title-fallback | hit.title = undefined | h3 text displays "Untitled" |
| header-005 | title-fallback | hit.title = "   " (whitespace only) | h3 text displays "   " literally — not "Untitled", since the fallback is a falsy check, not a trim |
| header-006 | title-attribute | hit.title = "Long Paper Title Here" | h3 title attribute = "Long Paper Title Here" |
| header-007 | kind-badge | hit.kind = "research", kindRendererFor returns {badge: {variant: "research", label: "Research"}} | Badge renders with variant "research" and label text "Research" |
| header-008 | author-attribution | hit.author = {displayName: "Alice Smith", slug: "alice"} | Text shows "by Alice Smith" |
| header-009 | author-attribution | hit.author = {displayName: "  ", slug: "bob"} | Text shows "by @bob" |
| header-010 | author-attribution | hit.author = {displayName: null, slug: "charlie"} | Text shows "by @charlie" |
| header-011 | author-attribution | hit.author = {displayName: undefined, slug: "dave"} | Text shows "by @dave" |
| header-012 | optional-date | hit.updatedAt = "2026-09-20" | Text displays "Updated Sep 20, 2026" (formatDate's en-US short-month format) |
| header-013 | optional-date | hit.updatedAt = null | Date text does not render |
| header-014 | optional-date | hit.updatedAt = undefined | Date text does not render |
| header-015 | optional-date | hit.updatedAt = "" | Date text does not render |
| header-016 | optional-summary | hit.summary = "This is a summary" | Summary paragraph visible |
| header-017 | optional-summary, summary-label | hit.summary = "This is a summary" | Paragraph text reads "Summary: This is a summary" |
| header-018 | optional-summary | hit.summary = "" | Summary paragraph does not render |
| header-019 | optional-summary | hit.summary = "   " | Summary paragraph does not render |
| header-020 | optional-summary | hit.summary = null | Summary paragraph does not render |
| header-021 | per-kind-extra | renderer.previewExtra(hit) returns a React element | Extra section renders that element |
| header-022 | per-kind-extra | renderer.previewExtra(hit) returns null | Extra section does not render |
| header-023 | per-kind-extra | renderer.previewExtra(hit) returns undefined | Extra section does not render |
| header-024 | public-link | hit.publicRoute = "/papers/example" (non-empty string), href = "https://example.com/paper" | Link visible with text "View full paper" and href="https://example.com/paper" |
| header-025 | public-link | hit.publicRoute = "" | Link does not render |
| header-026 | public-link | hit.publicRoute = "", href = "https://example.com/paper" (well-formed) | Link does not render, regardless of href's value |
| header-027 | metadata-row-order | hit with kind badge, author, and updatedAt all present | Badge, author text, and date text appear in that order within one wrapping row |

## Edge Cases

- **Empty or missing title**: Falls back to "Untitled" for a falsy `hit.title` (empty string, `null`, or `undefined`); this is a falsy check, not a trim, so an all-whitespace title is truthy and renders as literal whitespace instead of falling back.
- **Title attribute vs. displayed text**: The h3 `title` attribute always mirrors the raw `hit.title` value, even when the visible text has fallen back to "Untitled" — a missing title therefore produces an empty tooltip attribute alongside the fallback text.
- **Null or undefined author fields**: Author slug is always available as fallback; if displayName is null, undefined, or empty/whitespace after trim, fallback to slug with @ prefix.
- **Null, undefined, or empty updatedAt**: Date section is entirely omitted; no placeholder or default date is shown.
- **Truncated title**: The h3 is allowed to shrink below its content width within the flex container, enabling text ellipsis when title exceeds available space; the full (raw) title remains available via the title attribute.
- **Per-kind renderer fallback**: kindRendererFor returns a neutral default renderer for unknown kinds; previewExtra may return null or undefined for kinds without extra content — both render nothing.
- **Missing public route**: Link is not rendered when `hit.publicRoute` (a string) is empty; href and route values are independent — href may be a well-formed string even when route is empty.
- **Non-locale-aware date formatting**: `formatDate` always renders dates using `en-US` formatting regardless of the active UI locale (see Compliance: locale-aware-formatting).

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

The source currently hardcodes each of these strings directly in the JSX rather than resolving them through a localization system — the table above describes the target localization contract, not the source's current implementation (see Compliance: string-externalization, no-hardcoded-strings). Date formatting is also not currently locale-aware: `formatDate` always uses the `en-US` locale (see Compliance: locale-aware-formatting).

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

- **Source (TypeScript/Web)**: Implemented in `packages/web/packages/search/src/components/markdown/MarkdownPreviewHeader.tsx` as a React functional component using inline Tailwind CSS classes (`flex flex-col gap-2` root, `flex items-start justify-between gap-3` title row, `flex flex-wrap items-center gap-x-2 gap-y-1` metadata row, `min-h-6 shrink-0 rounded-sm` on the link hit target). Styled with `apt-*` design tokens (`apt-text`, `apt-gold`, `apt-text-dim`, `apt-text-muted`). Integrates Badge from `@agenticdevelopertoolkit/ui/components/badge` and uses `kindRendererFor` from the search package's per-kind registry for per-kind customization.
- **SwiftUI**: Implement as a view composition using a VStack for vertical layout and HStack for the title row. Author and date-formatted text are computed properties (derived from `hit`, e.g. a computed `var` or a value derived at `init`), not `@State` — they hold no independent mutable state. The per-kind badge becomes a SwiftUI view parameter. Conditional rendering with `if` statements for optional date, summary, and public link. Text styling via `.font`, `.foregroundColor` modifiers.
- **Compose**: Implement as a Composable function using Column for vertical layout and Row for the title section. Author and date-formatted text are plain computed values derived from `hit` (no `remember`/mutable state needed). Use `Modifier` for layout constraints (allowing the title to shrink for ellipsis). Conditional composition with `if` statements for optional content. Badge is an imported Composable. Text styling via `Text()` and `Modifier`.
- **AppKit / UIKit**: Implement with `NSStackView` (AppKit) or `UIStackView` (UIKit) for vertical layout. Title uses `NSTextField` (AppKit) or `UILabel` (UIKit) with truncation to ellipsis. The public link should be a real link, not a generic button: an `NSAttributedString` run carrying a `.link` attribute inside a clickable `NSTextField`/`NSTextView` (AppKit), or a `UIButton` configured with a `.plain()` `UIButton.Configuration` and an underlined attributed title (UIKit) — underline-on-hover only exists as a concept on AppKit (via link cursor tracking); UIKit has no hover state, so omit it there and rely on system link semantics instead. Author and summary-label formatting via `NSAttributedString`, which is a Foundation type available identically on both AppKit and UIKit, not a UIKit-only type.
- **WinUI 3**: Implement as a StackPanel with Orientation="Vertical" and Spacing="8". Title in a TextBlock with TextTrimming="CharacterEllipsis" and ToolTip binding to hit.title. Public link as a HyperlinkButton styled with Underline on PointerOver state, custom focus ring with VisualState. Badge as a UserControl or custom template. Author attribution in a TextBlock with Foreground bound to theme brush for dimmed text.

## Design Decisions

**Decision**: The public link renders only when `hit.publicRoute` is a non-empty string; the `href` prop is always passed through, independent of `publicRoute`.
**Rationale**: A hit with no public route has no public page to link to, and `href` may still be a well-formed string even when there is no route — checking `publicRoute` rather than `href` avoids rendering a link to nowhere.
**Approved**: pending

**Decision**: The kind badge and optional extra section are sourced from the `kindRendererFor` per-kind renderer map rather than branched inline in this component.
**Rationale**: A new kind can be added with a single map entry, without editing this component; unknown kinds fall back to a neutral default renderer so an unexpected value degrades gracefully.
**Approved**: pending

**Decision**: "Untitled" is rendered whenever `hit.title` is falsy (empty, null, or undefined), via a falsy check rather than a trim.
**Rationale**: Ensures the header always displays a title, improving the experience when metadata is incomplete.
**Approved**: pending

**Decision**: `displayName` is preferred over `slug` for author attribution; `slug` (with an `@` prefix) is used only when `displayName` is absent or empty after trimming.
**Rationale**: A display name is more readable than a slug; the `@`-prefixed slug is a familiar fallback convention when no display name is available.
**Approved**: pending

**Decision**: The summary is trimmed and excluded when whitespace-only.
**Rationale**: Prevents an empty or blank-looking summary paragraph from rendering.
**Approved**: pending

**Decision**: The public link uses `focus-visible` rather than `:focus` for its focus ring.
**Rationale**: Shows the focus ring only on keyboard navigation, not on mouse click, following web accessibility best practice.
**Approved**: pending

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| [screen-reader-support](agenticdevelopercookbook://compliance/accessibility#screen-reader-support) | passed | Accessibility |
| [keyboard-navigable](agenticdevelopercookbook://compliance/accessibility#keyboard-navigable) | passed | Accessibility |
| [semantic-markup](agenticdevelopercookbook://compliance/accessibility#semantic-markup) | passed | Accessibility |
| [contrast-ratio](agenticdevelopercookbook://compliance/accessibility#contrast-ratio) | partial | Accessibility |
| [dynamic-type-support](agenticdevelopercookbook://compliance/accessibility#dynamic-type-support) | partial | Accessibility |
| [string-externalization](agenticdevelopercookbook://compliance/internationalization#string-externalization) | failed | Internationalization |
| [no-hardcoded-strings](agenticdevelopercookbook://compliance/internationalization#no-hardcoded-strings) | failed | Internationalization |
| [locale-aware-formatting](agenticdevelopercookbook://compliance/internationalization#locale-aware-formatting) | failed | Internationalization |
| [unicode-support](agenticdevelopercookbook://compliance/internationalization#unicode-support) | passed | Internationalization |
| [rtl-layout-support](agenticdevelopercookbook://compliance/internationalization#rtl-layout-support) | partial | Internationalization |
| [text-expansion-tolerance](agenticdevelopercookbook://compliance/internationalization#text-expansion-tolerance) | partial | Internationalization |

Passed/failed statuses rest on the source's native semantic elements (`h3`, `<a>`, `<p>`) and design-token-based colors for accessibility, and on the hardcoded `en-US` locale in the shared `formatDate` helper plus literal English strings in the JSX ("Untitled", "by", "Summary: ", "View full paper") for internationalization; contrast, dynamic-type, RTL, and text-expansion statuses are partial because the token values and layout behavior aren't verifiable from this component's source alone.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.1.0 | 2026-09-22 | Mike Fullerton | Lint pass: renamed all requirements to subject-only kebab-case; corrected public-link/title-fallback/date-locale behavior against the source; added summary-label and metadata-row-order requirements plus missing test vectors; replaced the compliance section with a checked table; reformatted design decisions to Decision/Rationale/Approved; rewrote appearance in semantic tokens and moved Tailwind specifics to the platform note; fixed the SwiftUI (computed properties, not @State) and AppKit/UIKit (attributed-string link, Foundation type) platform notes; added badge to depends-on and markdown-preview to related; unified frontmatter date formatting |
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
