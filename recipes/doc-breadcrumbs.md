---
id: c9c48e65-6905-4035-b8e1-e053219599f1
title: DocBreadcrumbs
domain: agenticdevelopercookbook://ingredients/doc-breadcrumbs
type: ingredient
version: 1.2.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Semantic breadcrumb trail for documentation navigation, always with home
  crumb first.
platforms:
- web
tags:
- navigation
- breadcrumb
- documentation
depends-on: []
related: []
references: []
---

# DocBreadcrumbs

## Overview

DocBreadcrumbs renders a semantic breadcrumb trail for document navigation. It always includes a home crumb and an ancestor trail, with the current page (last crumb) rendered as plain text rather than a link. When the component is at the root (no ancestors), it renders nothing to avoid showing a redundant "Home" link pointing to the current page.

## Behavioral Requirements

- **must-render-navigation-element**: Component MUST render a `<nav>` element with `aria-label="Breadcrumb"`.
- **must-include-home-crumb**: Component MUST always include a home crumb as the first item, rendered as a link to `homeHref` (default `"/"`).
- **must-render-crumbs-list**: Component MUST render crumbs as an ordered list (`<ol>`) with each crumb as a list item (`<li>`).
- **must-render-current-as-text**: Component MUST render the last crumb (current page) as plain text, not a link.
- **must-render-ancestors-as-links**: Component MUST render all crumbs except the last as links to their `path` values.
- **must-separate-crumbs**: Component MUST visually separate crumbs with a "/" character.
- **must-render-nothing-at-root**: Component MUST return `null` when `crumbs` array is empty (no ancestors).
- **must-accept-custom-link-component**: Component MUST accept an optional `LinkComponent` prop and use it for all links instead of plain `<a>` elements.
- **must-accept-custom-home-label**: Component MUST accept an optional `homeLabel` prop to override the default "Home" label.
- **must-accept-custom-home-href**: Component MUST accept an optional `homeHref` prop to override the default "/" destination for the home crumb.
- **must-accept-crumbs-array**: Component MUST accept a required `crumbs` prop containing an array of objects with `label` (string) and `path` (string) properties, ordered root-first.
- **must-forward-html-attributes**: Component MUST accept and forward remaining HTMLAttributes to the `<nav>` element.

## Appearance

- **Font family**: monospace (font-mono)
- **Font size**: extra-small (text-xs)
- **Text color**: dim secondary color (`var(--color-text-dim)`)
- **Link hover color**: secondary color (`var(--color-text-secondary)`)
- **Separator color**: border color (`var(--color-border)`)
- **Margin**: 4 units bottom (mb-4)
- **Gap between items**: 1 unit (gap-1)
- **Crumb layout**: horizontal flex with centered items

## States

| State | Appearance change |
|-------|------------------|
| Default | Text in dim color; home link underline on hover |
| Root | Component does not render (returns null) |
| Link hover | Link text changes to secondary color |

## Accessibility

- **Role**: Navigation landmark (`<nav>` element)
- **Label**: ARIA label "Breadcrumb" identifies the navigation region
- **Semantic structure**: Uses `<ol>` (ordered list) and `<li>` (list items) for proper document outline
- **Current page indicator**: Last crumb is rendered as plain text (not a link) to indicate it is the current page
- **Link semantics**: All ancestor links use the `LinkComponent` to maintain proper link semantics
- **Keyboard navigation**: All links MUST be keyboard accessible (SHOULD be natively tabbable and activatable with Enter)

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| breadcrumb-001 | must-render-navigation-element | `crumbs={[{label:"Docs", path:"/docs"}]}` | Renders `<nav aria-label="Breadcrumb">` |
| breadcrumb-002 | must-include-home-crumb | `crumbs={[{label:"Docs", path:"/docs"}]}` | First item is a link to `/` with label "Home" |
| breadcrumb-003 | must-render-crumbs-list | `crumbs={[{label:"Docs", path:"/docs"}]}` | Uses `<ol>` and `<li>` elements |
| breadcrumb-004 | must-render-current-as-text | `crumbs={[{label:"Docs", path:"/docs"}, {label:"API", path:"/docs/api"}]}` | Last crumb "API" is plain text, not a link |
| breadcrumb-005 | must-render-ancestors-as-links | `crumbs={[{label:"Docs", path:"/docs"}, {label:"API", path:"/docs/api"}]}` | First crumb "Docs" is a link to "/docs" |
| breadcrumb-006 | must-separate-crumbs | `crumbs={[{label:"Docs", path:"/docs"}]}` | "/" character appears between home and first crumb |
| breadcrumb-007 | must-render-nothing-at-root | `crumbs=[]` | Component returns null (renders nothing) |
| breadcrumb-008 | must-accept-custom-link-component | `crumbs={[{label:"Docs", path:"/docs"}]} LinkComponent={CustomLink}` | Uses CustomLink instead of DefaultDocLink |
| breadcrumb-009 | must-accept-custom-home-label | `homeLabel="Dashboard"` | Home link displays "Dashboard" instead of "Home" |
| breadcrumb-010 | must-accept-custom-home-href | `homeHref="/app"` | Home link points to "/app" instead of "/" |
| breadcrumb-011 | must-accept-crumbs-array | `crumbs={[{label:"Docs", path:"/docs"}, {label:"Guides", path:"/docs/guides"}]}` | Both crumbs render in correct order |
| breadcrumb-012 | must-forward-html-attributes | `crumbs={[{label:"Docs", path:"/docs"}]} data-testid="breadcrumb"` | `<nav>` element has `data-testid="breadcrumb"` |

## Edge Cases

- **Empty crumbs array**: When `crumbs.length === 0`, component returns null (no render). This avoids displaying a redundant "Home" link pointing to the current page.
- **Single crumb**: When `crumbs` has exactly one element, it renders as: Home > [CrumbLabel] (where CrumbLabel is plain text).
- **Deeply nested breadcrumbs**: All crumbs except the last are rendered as links; the implementation does not enforce a maximum nesting depth.
- **Missing crumb properties**: The `DocCrumb` interface in `doc-types.ts` declares both fields as required and non-nullable — `label: ReactNode` and `path: string` — so a crumb that omits either field, or supplies `null` for it, is a compile-time type error at the call site and never reaches the component. Callers MUST supply every crumb with both a `label` and a `path`; the component MUST NOT be expected to perform a runtime check, because it performs none and the props type already excludes the case.
- **Empty strings in crumbs**: If a crumb has an empty `label` string, it renders as an empty text node between separators. If `path` is empty, the link's `to` attribute is set to an empty string.
- **Null or undefined crumbs prop**: `DocBreadcrumbsProps` declares `crumbs: DocCrumb[]` as a required, non-optional and non-nullable prop, so `null` or `undefined` is a compile-time type error at the call site. Callers MUST pass an array. The empty array is the one defined "nothing to show" input, and the component MUST treat it as such: `if (crumbs.length === 0) return null` renders no `<nav>`, no home crumb and no separator, so an absent trail collapses to nothing rather than to a bare "Home" link.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `crumbs` | `DocCrumb[]` | (required) | Array of breadcrumb objects with `label` (string) and `path` (string), ordered root-first. Last crumb is the current page. |
| `homeLabel` | `string` | `"Home"` | Label displayed for the always-present first crumb. |
| `homeHref` | `string` | `"/"` | URL destination for the home crumb. |
| `LinkComponent` | `DocLinkComponent` | `DefaultDocLink` | Custom link component to replace the default. Receives `to` (path) and `className` props. |

## Deep Linking

Not applicable: DocBreadcrumbs is a presentational component for documenting the navigation path. Deep linking is handled by the host application's router, not by this component.

## Localization

Not applicable: DocBreadcrumbs is passed localized `label` values in the `crumbs` array and `homeLabel` prop by the caller. The component itself contains no strings to translate.

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | Not applicable: component performs no animations. |
| Increase Contrast | Links respond to the platform's contrast color tokens (`var(--color-text-secondary)` on hover). |
| Differentiate Without Color | Links rely on text-based labels and semantic markup, not color alone, to convey the distinction from plain text. |

## Feature Flags

Not applicable: DocBreadcrumbs contains no feature-gated behavior. The host application MAY conditionally render or hide the entire breadcrumb navigation using its own feature flags.

## Analytics

Not applicable: DocBreadcrumbs is a passive presentation layer. The host application's `LinkComponent` implementation owns responsibility for tracking clicks on breadcrumb links.

## Privacy

Not applicable: DocBreadcrumbs renders no sensitive data. It displays only the navigation path provided by the host application.

## Logging

Not applicable: DocBreadcrumbs does not emit any log messages. Debug output is delegated to the `LinkComponent` implementation.

## Platform Notes

- **React/Web**: Source is React 18+ component using hooks. Styled with Tailwind CSS classes and CSS custom properties. Uses semantic HTML `<nav>`, `<ol>`, `<li>` elements and ARIA labels. Accepts `HTMLAttributes<HTMLElement>` for `<nav>` element and custom `LinkComponent` for routing integration. Render conditionally based on router/navigation context via the `crumbs` array passed by the caller.
- **SwiftUI**: Start with SwiftUI's built-in `NavigationStack` or a custom navigation breadcrumb view. Equivalent structure: an HStack containing the home link, then a ForEach loop over ancestors rendering links, with the final element as Text (not a link). Apply SwiftUI's link styling and semantic accessibility modifiers (`.accessibilityElement(children: .combine)`).
- **Compose**: Start with a Row or Modifier applied to Text. Use `ClickableText` or `Text + Modifier` for ancestor links; render the current page as plain Text. Apply Material 3 color tokens for text dimming and hover states. Semantic accessibility requires role assignment to the containing element.
- **AppKit / UIKit**: Implement as a custom NSView or UIView subclass. Use NSAttributedString or UILabel for static current-page text, NSButton or custom tap handler for ancestor links. Wrap in an accessibility container with `.accessibilityElement(children: .combine)` and an appropriate `accessibilityLabel`. Apply platform system colors for text and link states.
- **WinUI 3**: Implement as a UserControl containing a StackPanel (Orientation=Horizontal). Use Hyperlink controls for ancestor crumbs and a TextBlock for the current page. Bind to a backing property for crumbs array and use DataTemplate or ItemsControl for rendering the loop. Apply Fluent 2 color tokens (`var(--color-text-dim)`, `var(--color-text-secondary)`) via ResourceDictionary or XAML inline. Ensure keyboard focus ring is visible and tab order is logical. Use AutomationProperties.AutomationId and AutomationProperties.Name for accessibility labeling.

## Design Decisions

1. **Root renders nothing**: When at the root (empty crumbs), the component returns null rather than showing a single "Home" link. This avoids redundant navigation UI pointing to the current page and keeps the breadcrumb visually useful only when there is an ancestor trail to show.

2. **Current page is text, not link**: The last crumb is always rendered as plain text instead of a link. This follows web breadcrumb conventions (e.g., WAI-ARIA examples) and prevents users from "clicking" to reload the current page.

3. **Crumbs are caller-supplied, not derived from slug**: The component deliberately does not derive breadcrumbs from the URL or page slug. Each site has its own URL structure and labeling convention (e.g., cookbook's `slugToBreadcrumbs` title-cases domain segments; another site might look labels up in a manifest). Deriving them here would bake one site's URL convention into the toolkit. Responsibility for breadcrumb construction belongs to the host application.

4. **Custom LinkComponent for routing flexibility**: The component accepts a `LinkComponent` prop instead of hardcoding native `<a>` elements. This allows host applications to integrate their own router (Next.js Link, React Router, etc.) without the toolkit imposing a routing library dependency.

5. **Semantic markup**: Uses `<nav>`, `<ol>`, and `<li>` elements with ARIA label to ensure breadcrumb navigation is properly announced and indexed by assistive technology and search engines.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| Semantic HTML structure | passed | Accessibility |
| ARIA landmark labeling | passed | Accessibility |
| Keyboard accessibility (delegated to LinkComponent) | passed | Accessibility |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.2.0 | 2026-09-22 | Mike Fullerton | State the crumb shape the props type requires, and the empty-array fallback, as Edge Cases requirements |
| 1.1.0 | 2026-09-22 | Mike Fullerton | Refine open questions on crumb property and type validation |
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
