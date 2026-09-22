---
id: ee901ea5-cf3e-4276-8367-0693911bc02e
title: Markdown Reading Palette
domain: agenticdevelopercookbook://ingredients/markdown-reading-palette
type: ingredient
version: 1.0.0
status: review
language: en
created: 2026-09-22
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Server-safe wrapper that applies a reading theme palette to markdown content.
platforms:
- typescript
- web
tags:
- markdown
- theming
- styling
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Markdown Reading Palette

## Overview

A server-safe React wrapper component that applies a reading theme palette to markdown content. The component sets theme-aware CSS custom properties (`--mdv-*`), data attributes for theme identification, and layout classes on a container around markdown children. It is designed to be used within async React Server Components without converting them to Client Components.

## Behavioral Requirements

- **must-render-children**: Component MUST render `children` prop without modification or transformation.
- **must-apply-theme-data-attributes**: Component MUST set `data-mdv-theme` attribute to the theme's ID and `data-mdv-shiki-variant` attribute to the theme's syntax highlighting variant.
- **must-apply-theme-palette-style**: Component MUST apply the theme's color palette as inline CSS custom properties via the `style` prop.
- **must-apply-content-class**: Component MUST apply the `adh-mv-content` class to the wrapper element. This class provides load-bearing styles for background color, text color, padding, and overflow behavior that enable markdown content to be readable within its host context.
- **must-merge-classname**: Component MUST merge the `className` prop with `adh-mv-content` using the `cn` utility function, preserving both the theme-driven layout classes and any caller-supplied layout classes (e.g., sizing, borders, rounding).
- **should-accept-theme-id**: Component SHOULD accept an optional `themeId` prop. When provided, the component MUST use that theme ID; when omitted, the component MUST default to `DEFAULT_THEME_ID`.
- **should-accept-data-slot**: Component SHOULD accept an optional `data-slot` prop to enable callers to set a DOM identity marker for testing, styling, or selection purposes. When provided, this prop MUST be forwarded directly to the wrapper element's `data-slot` attribute.
- **must-be-server-safe**: Component MUST be server-safe, with no React hooks, no client-only APIs (e.g., browser globals, event handlers), and no "use client" directive. The component MUST be compatible with async React Server Components.

## Appearance

Not applicable: MarkdownReadingPalette is a wrapper component that does not define specific visual dimensions, spacing, or appearance values. Visual appearance is entirely driven by the applied theme's palette and the `adh-mv-content` class, both of which are determined at runtime based on the selected theme.

## States

Not applicable: MarkdownReadingPalette is a static, non-interactive wrapper component with no stateful behaviors (no pressed, focused, disabled, or loading states).

## Accessibility

Not applicable: MarkdownReadingPalette is a non-interactive wrapper component with no accessible interactive elements, form fields, or user actions. Accessibility concerns are the responsibility of the markdown renderer (e.g., MarkdownRenderer) and its semantic HTML output, not this wrapper.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| palette-001 | must-render-children | `<MarkdownReadingPalette><div>Hello</div></MarkdownReadingPalette>` | Rendered output includes `<div>Hello</div>` unchanged |
| palette-002 | must-apply-theme-data-attributes | `themeId="dark"`, theme has `shikiVariant="github-dark"` | Rendered div has `data-mdv-theme="dark"` and `data-mdv-shiki-variant="github-dark"` |
| palette-003 | must-apply-theme-palette-style | Theme has palette `{ "--mdv-text": "#ffffff", "--mdv-bg": "#1e1e1e" }` | Rendered div `style` prop includes `"--mdv-text": "#ffffff", "--mdv-bg": "#1e1e1e"` |
| palette-004 | must-apply-content-class | No className prop supplied | Rendered div has class `adh-mv-content` |
| palette-005 | must-merge-classname | `className="border rounded"` | Rendered div class attribute includes both `adh-mv-content` and `border rounded` |
| palette-006 | should-accept-theme-id, should-accept-data-slot | `themeId="light"`, `data-slot="markdown-preview"` | Rendered div has `data-mdv-theme="light"` and `data-slot="markdown-preview"` |
| palette-007 | should-accept-theme-id | No `themeId` prop supplied | Rendered div uses `DEFAULT_THEME_ID` theme |
| palette-008 | must-be-server-safe | Component rendered as child of async RSC | Component does not throw, no client-side hydration issues, no "use client" directive in bundle |

## Edge Cases

- **Null or empty children**: When children is `null`, `undefined`, or an empty array, the component MUST render the wrapper div with the theme applied. The wrapper div renders but contains no child content.
- **No themeId provided**: When no `themeId` prop is supplied, the component MUST use the `DEFAULT_THEME_ID` constant from the themes registry.
- **Invalid themeId**: When a `themeId` is provided but does not exist in the themes registry, the behavior depends on the `getThemeById` function's error handling. If `getThemeById` throws, the component will propagate that error. If `getThemeById` returns a fallback theme, the component will apply that fallback theme.
- **Empty or whitespace-only className**: When `className` is an empty string or contains only whitespace, `cn('adh-mv-content', className)` MUST return just `'adh-mv-content'`.
- **Multiple class names in className prop**: When `className` contains multiple classes (e.g., `"border rounded-lg shadow"`), all classes MUST be preserved in the merged output via `cn`.

## Configuration

Not applicable: MarkdownReadingPalette does not expose configuration options beyond its props interface (themeId, className, data-slot).

## Deep Linking

Not applicable: MarkdownReadingPalette is a non-interactive wrapper component with no navigation, routing, or deep linking behavior.

## Localization

Not applicable: MarkdownReadingPalette contains no user-facing text strings, labels, or messages requiring localization.

## Accessibility Options

Not applicable: MarkdownReadingPalette is a non-interactive wrapper component that does not respond to platform accessibility display settings (reduce motion, increase contrast, differentiate without color). Accessibility concerns are handled by the markdown renderer and the host application's theme selection.

## Feature Flags

Not applicable: MarkdownReadingPalette has no feature flags; it is always enabled when imported.

## Analytics

Not applicable: MarkdownReadingPalette is a non-interactive wrapper component with no user actions or events to track. Analytics instrumentation, if needed, belongs in the host component that uses this wrapper or in the markdown renderer.

## Privacy

Not applicable: MarkdownReadingPalette does not collect, transmit, or store any user data or sensitive information. It is a pure presentational wrapper with no network requests or data handling.

## Logging

Not applicable: MarkdownReadingPalette has no operational logging. Error handling (e.g., invalid theme IDs) is delegated to the `getThemeById` function and theme registry.

## Platform Notes

- **Source (Web/React)**: Exported from `packages/web/packages/markdown/src/components/MarkdownReadingPalette.tsx`. Server-safe by design — no React hooks, no "use client" directive, compatible with async RSCs. Receives theme from the `getThemeById` function in the themes registry. Merges className via `cn` utility from `@agenticdevelopertoolkit/ui/lib/utils`.
- **SwiftUI**: No direct equivalent. SwiftUI view wrapping markdown content would use `Environment` or `@EnvironmentObject` to propagate theme colors via `Color` environment keys, and `.background()` and `.foregroundStyle()` modifiers to apply them. A comparable pattern: a view that reads theme colors from environment and applies them to a markdown rendering view via View composition.
- **Compose**: Android equivalent would wrap markdown content in a `Box` or `Surface` composable, applying theme colors via `MaterialTheme.colorScheme` or a custom `CompositionLocal` for the palette. The wrapper would read the theme from a `CompositionLocal` and apply `backgroundColor` and `contentColor` modifiers to propagate them.
- **AppKit / UIKit**: UIKit version would wrap markdown content (e.g., `UITextView` or custom markdown view) in a `UIView`, applying theme colors via `layer.backgroundColor`, `UIColor` for text, and auto-layout constraints for padding. AppKit equivalent uses `NSView` with `layer.backgroundColor` and text color attributes.
- **WinUI 3**: Windows equivalent would use `Grid` or `StackPanel` as the wrapper, applying theme colors to the panel's `Background` property and text colors to child elements' `Foreground` property. Colors would come from a theme resource dictionary or `ResourceDictionary`, and the palette would be bound via data binding or code-behind property assignment. A `data-mdv-theme` equivalent might be a `x:Name` or `Tag` property set on the panel for testing/selection.

## Design Decisions

1. **Server-safe by design**: The component is deliberately written without hooks or client-only APIs to enable use within async React Server Components. This constraint is a feature, not a limitation — it allows the research site's `PaperRenderer` and similar async components to use this wrapper without client-side hydration overhead. Callers that need client-side behavior should wrap this component in a Client Component of their own.

2. **className merging, not replacement**: The component uses `cn` to merge the caller's `className` with `adh-mv-content`, rather than replacing one or the other. This allows callers to supply layout modifiers (sizing, borders, rounding) while preserving the theme-driven layout class. The `adh-mv-content` class is load-bearing for background, padding, and overflow — removing it would break readability.

3. **data-slot as a prop, not hardcoded**: The component accepts `data-slot` as a prop rather than using a hardcoded value like `"markdown-reading-palette"`. This is intentional: the component is a generic reading surface reused under different names by different hosts (e.g., `MarkdownDocumentEditor`'s preview pane uses `"markdown-preview"`, while a future caller might use something else). Taking the slot as a prop allows each host to name it according to its context.

4. **Theme lookup at render time**: The component calls `getThemeById(themeId)` at render time, enabling dynamic theme switching if the themes registry is updated. This avoids caching theme data in component state or memoization, keeping the component simpler and more predictable.

5. **No error boundary**: The component does not wrap `getThemeById` in try-catch. If a theme ID is invalid, the error propagates to the caller's error boundary (if any). This is intentional — invalid theme IDs are configuration errors, not runtime failures, and should be caught during development/testing.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| No security-sensitive data | passed | security |
| No client-only APIs | passed | server-rendering |
| No user-facing text | passed | i18n |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation from source |
