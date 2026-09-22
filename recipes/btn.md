---
id: 1675b18e-34d5-4d8e-987f-92697539a5e6
title: Btn
domain: agenticdevelopertoolkit://recipes/btn
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A pill-shaped call-to-action link component with primary and ghost variants.
platforms:
- typescript
- web
tags: []
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Btn

## Overview

A pill-shaped call-to-action link component. The `primary` variant (default) is filled with the accent color token (`--lp-accent`), emphasizing the primary user action. The `ghost` variant is outlined only, for secondary actions.

## Behavioral Requirements

- **must-render-anchor**: Component MUST render as an HTML anchor (`<a>`) element.
- **must-support-href**: Component MUST accept an `href` prop of type `string` and pass it to the anchor element's `href` attribute.
- **must-support-children**: Component MUST render the `children` prop as the link text content.
- **must-support-variant-prop**: Component MUST accept a `variant` prop with values `'primary'` or `'ghost'`.
- **must-default-to-primary**: Component MUST default the `variant` prop to `'primary'` when not specified.
- **must-apply-btn-classes**: Component MUST apply the CSS class `lp-btn` to the anchor element.
- **must-apply-variant-class**: Component MUST apply the CSS class `lp-btn--{variant}` corresponding to the selected variant.

## Appearance

Appearance is defined and applied entirely via external CSS classes (`lp-btn`, `lp-btn--{variant}`), not by component props or inline styles. The component does not define color values, spacing, typography, or border properties directly. Visual styling including corner radius, padding, font size, and visual differences between the primary (filled with `--lp-accent`) and ghost (outlined) variants are controlled by the stylesheet that defines these classes.

## States

The component does not manage application-level states (loading, disabled, error). Link elements have inherent browser and CSS states—unvisited, visited, hover, focus, and active (pressed)—which are styled via CSS rules targeting the anchor element or its variant class selectors. The component passes these states through without modification.

## Accessibility

Component renders as a semantic HTML link element (`<a>`), which is inherently keyboard-accessible (Tab to focus, Enter to activate) and screen-reader-accessible. Link text is provided by the `children` prop; no additional `aria-label` or `aria-labelledby` attribute is applied by the component. If the link text is ambiguous, missing, or not descriptive, the parent code is responsible for providing accessible text via `children`.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| btn-001 | must-render-anchor | `<Btn href="/path">Click</Btn>` | DOM element is an `<a>` tag |
| btn-002 | must-support-href | `href="/signup"` | Rendered `<a>` has `href="/signup"` |
| btn-003 | must-support-children | `children="Sign up now"` | Anchor text content is "Sign up now" |
| btn-004 | must-support-variant-prop, must-apply-variant-class | `variant="ghost"` | Anchor `className` includes `lp-btn--ghost` |
| btn-005 | must-default-to-primary, must-apply-variant-class | No `variant` prop | Anchor `className` includes `lp-btn--primary` |
| btn-006 | must-apply-btn-classes | Any valid props | Anchor `className` includes `lp-btn` |

## Edge Cases

- **Empty or missing children**: If `children` is `null`, `undefined`, or an empty string, the link renders with no visible text. This is not an error condition; the anchor is still navigable but semantically incomplete. Parent code is responsible for ensuring meaningful link text.
- **Missing href prop**: `href` is a required prop per TypeScript. If called without `href`, the type system prevents the call. At runtime, if `href` is `undefined`, the anchor's `href` attribute is `undefined`, resulting in a non-functional link. This is a usage error.
- **Invalid variant value**: `variant` is constrained to `'primary' | 'ghost'` by TypeScript. Passing any other string value triggers a type error. At runtime, an invalid variant string produces a class name like `lp-btn--invalid`, which may not match any CSS rules and the link may lack expected styling. This is a usage error.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `href` | `string` | (required) | Target URL or path for the anchor link |
| `variant` | `'primary' \| 'ghost'` | `'primary'` | Visual variant: `'primary'` for filled (accent background), `'ghost'` for outlined |
| `children` | `ReactNode` | (required) | Link text or content rendered inside the anchor |

## Deep Linking

Not applicable: This component is a link renderer. Deep linking is handled by the browser following the `href` prop; the component does not implement routing or deep linking behavior itself.

## Localization

Not applicable: The component renders the `children` prop directly and does not define or manage localization strings. Parent code is responsible for providing localized text via `children`.

## Accessibility Options

Not applicable: The component is a standard semantic link element and does not respond to or require platform-level accessibility display options (reduce motion, increase contrast, differentiate without color). CSS stylesheets may define such responses via media queries.

## Feature Flags

Not applicable: The source code does not define or reference any feature flags.

## Analytics

Not applicable: The component does not emit analytics events or collect metrics. Event tracking is the responsibility of parent code using click handlers or navigation listeners.

## Privacy

Not applicable: The component does not collect, store, transmit, or process any user data or sensitive information.

## Logging

Not applicable: The component does not emit logs or diagnostic messages.

## Platform Notes

- **React/Web** (`packages/web/packages/landing/src/blocks/Btn.tsx`): Functional component using template literals to construct dynamic class names. The `className` prop joins `'lp-btn'` with the variant class `lp-btn--{variant}` using `.join(' ')`. Styling is external to the component.

- **SwiftUI**: Use `Link` or `NavigationLink` to provide navigation. Render text via a trailing closure or `.label` modifier. Apply `.buttonStyle()` or custom modifiers to achieve primary (filled accent background) and ghost (outlined) appearance distinctions.

- **Compose**: Use `ClickableText` or `Text` with `.clickable()` modifier to create a navigable link. Nest text in `Text` or `Row` composable. Apply background or border styling via `.background()` or `.border()` to distinguish primary (filled) from ghost (outlined).

- **AppKit / UIKit**: Use `NSButton` (macOS) or `UIButton` (iOS) configured as a link-style button. Set button title from text content, configure target and selector for navigation. Use `.bezel`, `.inline`, or custom `.buttonStyle` to render primary (filled) and ghost (outlined) variants.

- **WinUI 3**: Use `HyperlinkButton` control with `NavigateUri` property set from the `href` equivalent. Set `Content` to link text. Apply `Foreground` color (accent for primary) and `BorderBrush`/`BorderThickness` (for ghost outline) via `Style` or inline properties. Use `ControlTemplate` if custom appearance is required beyond standard states.

## Design Decisions

- **Semantic link element**: The component renders a native `<a>` (anchor) element rather than a `<button>` with JavaScript navigation. This preserves built-in browser affordances (context menus, link preview, history, keyboard shortcuts like Ctrl/Cmd+click, ability to copy or open in new tab) and maintains semantic correctness for screen readers and SEO.

- **CSS class-driven styling**: Appearance is entirely managed by CSS classes, not component props. This decouples the component from color tokens, theme values, and spacing constants, keeping the component API minimal and allowing styling to live in centralized stylesheets where it can be updated without changing component code.

- **Required props**: Both `href` and `children` are required, enforced by TypeScript. This ensures every link is functional and has meaningful text, preventing common accessibility and usability mistakes at the type level.

- **Variant constraint**: The `variant` prop is constrained to `'primary' | 'ghost'` by TypeScript. This prevents arbitrary class names and signals the available options clearly to consumers.

## Compliance

Not applicable: No specific compliance checks (WCAG, legal, or regulatory) are defined for this component at the ingredient level. Compliance with applicable standards (WCAG 2.1 AA for web, Apple HIG for native platforms) is assumed at the implementation and stylesheet levels.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
