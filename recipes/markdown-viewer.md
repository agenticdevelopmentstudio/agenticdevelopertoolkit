---
id: 8f2e1c9d-7a4b-4c2e-9d8e-5f6c7d8e9f0a
title: Markdown Viewer
domain: agenticdevelopercookbook://ingredients/markdown-viewer
type: ingredient
version: 1.0.0
status: review
language: en
created: 2026-09-22
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Read-only markdown viewer with theme persistence and syntax highlighting.
platforms:
- web
- swift
tags: []
depends-on: []
related: []
references: []
---

# Markdown Viewer

## Overview

A read-only markdown document viewer with theme persistence and syntax-highlighted code blocks. The component fetches formatted markdown content by document ID, renders it as sanitized HTML, and applies a persisted reading theme via a palette system. Used to display pre-formatted documentation, guides, or user-generated content without requiring editor capabilities.

## Behavioral Requirements

- **must-fetch-document-by-id**: Component MUST fetch markdown content by document `id` via the configured fetcher.
- **must-support-timeout**: Fetch operation MUST abort if it exceeds the configured `timeoutMs` (default 15000ms).
- **must-handle-fetch-errors**: Component MUST display an error state with the error message if the fetch fails.
- **must-render-as-sanitized-html**: Markdown content MUST be rendered as sanitized HTML (no arbitrary script injection).
- **must-highlight-code-syntax**: Code blocks in markdown MUST receive syntax highlighting via the configured highlighter.
- **must-persist-theme-selection**: Selected theme ID MUST be persisted to storage (localStorage on web, Preferences on Apple) so it survives app restarts.
- **must-apply-theme-palette**: Active theme palette MUST be applied to all rendered content (text colors, backgrounds, code highlighting).
- **must-display-toolbar**: Component MUST render a toolbar containing the document title and a theme switcher control.
- **must-display-document-title**: Toolbar MUST display the document's title (or empty string if not yet loaded).
- **must-show-loading-state**: While fetch is in progress, component MUST display a loading indicator with live region announcement.
- **must-show-idle-state**: Before any document is requested, component MUST display an idle message ("No document selected").
- **must-show-empty-state**: If document fetches successfully but content is empty or whitespace-only, component MUST display an empty state message.
- **should-apply-no-flash-theme-on-web**: On web with SSR, a pre-hydration bootstrap script SHOULD apply the persisted theme before React hydration to prevent flash of default theme.

## Appearance

- **Container**: Rounded corners (12px), border (1px), semi-transparent background. On web: `border border-apt-border bg-apt-bg rounded-xl`.
- **Toolbar**: Horizontal bar with title and theme switcher. Background: `bg-apt-surface`. Text: `text-apt-text`, `text-sm`, `font-medium`. Padding: 3 (12px vertical × 16px horizontal on web).
- **Content area**: Scrollable region carrying viewer-owned `--mdv-*` CSS custom properties (web) or applied palette (Apple). Background, text, and code colors are theme-dependent.
- **Loading spinner**: Centered icon with "Loading…" text. Color: currentColor (inherits from content root).
- **Error state**: Centered alert icon with title "Failed to load document" and error detail text. Title color matches alert semantic (typically red/orange).
- **Empty state**: Centered document icon with "Empty document" title and "This document has no content yet" detail.

## States

| State | Appearance change |
|-------|------------------|
| Idle | "No document selected" centered message. |
| Loading | Spinner icon, "Loading…" title, `aria-live="polite"` and `aria-busy="true"`. |
| Error | Alert icon (red/orange), "Failed to load document" title, error detail text below, `role="alert"`. |
| Success | Rendered markdown content in active theme palette; toolbar displays document title. |
| Success–Empty | Document icon, "Empty document" title, detail message (same as idle but after fetch). |

## Accessibility

- **Role and structure**: Markdown is rendered with semantic HTML headings, lists, and emphasis. The viewer itself is a region containing document content.
- **Live regions**: Loading state uses `aria-live="polite"` and `aria-busy="true"` to announce fetch progress.
- **Error alerts**: Error state uses `role="alert"` so assistive technology announces failures immediately.
- **Color not sole differentiator**: Error state icon is distinct from idle/loading icons (different shapes, not color alone).
- **Keyboard navigation**: Content is readable via keyboard; links and interactive elements in rendered markdown are tab-navigable.
- **Minimum touch target**: Toolbar theme switcher control MUST have a tap target of at least 44×44pt (iOS) / 48×48dp (Android).
- **Labels**: All interactive controls (theme switcher) have accessible labels via `aria-label` or visible text.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| mdv-001 | must-fetch-document-by-id | `id="abc123"` | Fetcher is called with id `"abc123"`. |
| mdv-002 | must-fetch-document-by-id | `id=undefined` | Component enters idle state; no fetch occurs. |
| mdv-003 | must-support-timeout | `timeoutMs=5000`, fetch hangs >5s | Fetch is aborted; error state shown. |
| mdv-004 | must-handle-fetch-errors | Fetcher returns error with message | Error state displays error message in detail text. |
| mdv-005 | must-render-as-sanitized-html | Markdown with `<script>alert('xss')</script>` | Script tag is removed; no script executes. |
| mdv-006 | must-highlight-code-syntax | Markdown with ` ```js\nvar x=1;\n``` ` | Code block is highlighted with JavaScript syntax colors. |
| mdv-007 | must-persist-theme-selection | User selects theme "dark"; app restarts | On restart, "dark" theme is still active. |
| mdv-008 | must-apply-theme-palette | Active palette has text-color="#fff" | Rendered text appears in white (or theme's text color). |
| mdv-009 | must-display-toolbar | Component renders | Toolbar is visible with title and theme switcher. |
| mdv-010 | must-display-document-title | `title="My Doc"` in fetched content | Toolbar displays "My Doc". |
| mdv-011 | must-show-loading-state | Fetch is in progress | Spinner icon and "Loading…" text are visible. |
| mdv-012 | must-show-idle-state | Component renders before `id` is set | "No document selected" message is shown. |
| mdv-013 | must-show-empty-state | Content is `""` or whitespace-only | "Empty document" icon and message are shown. |
| mdv-014 | should-apply-no-flash-theme-on-web | (Web SSR) User has persisted theme "dark" | Dark theme is applied before first paint (no visible theme flash). |

## Edge Cases

- **Null/undefined id**: Component enters idle state; no fetch is triggered. MUST not error.
- **Stale theme ID in storage**: If stored theme ID is no longer in the valid registry, MUST fall back to the default theme without error.
- **Storage quota exceeded or unavailable**: Theme selection still works live; persistence just fails silently. User's session theme remains active until app restart.
- **CSP blocks bootstrap script (web)**: No-flash protection is disabled; SSR paint uses default theme, then hydration applies persisted theme (visible flash). Component still functions.
- **Fetch timeout with no timeout configured**: Uses default timeout (15000ms).
- **Very large markdown content**: Component renders all content; SHOULD NOT paginate or truncate.
- **Markdown with deeply nested lists or tables**: MUST render all nesting levels.
- **Empty string title**: Toolbar displays empty title (no text, but toolbar remains present).
- **Network error with no message**: MUST show error state with a generic error message (e.g., "Failed to load document").

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `id` | `string \| undefined` | `undefined` | Document ID to fetch. If undefined, component shows idle state. |
| `fetcher` | `MarkdownFetcher` | API forwarder | Optional custom fetcher function; used for testing. Production uses the real API. |
| `timeoutMs` | `number` | `15000` | Fetch timeout in milliseconds. |
| `className` | `string` | `undefined` | (Web only) CSS class to forward to the root container element. |
| `nonce` | `string` | `undefined` | (Web only) CSP nonce for the pre-hydration bootstrap script. Required if host app enforces strict CSP. |
| `palette` | `SemanticPalette` | N/A | (Apple only) Semantic color palette to apply to rendered content. |
| `highlighter` | `CodeHighlighter` | Default | (Apple only) Optional custom code syntax highlighter; uses default if omitted. |

## Deep Linking

Not applicable: Component fetches by document ID; deep linking to a specific document would be implemented by the host app's URL router passing an `id` prop to the component.

## Localization

Not applicable: UI displays only state messages ("Loading…", "Failed to load document", "Empty document", "No document selected") which are hardcoded. Markdown content itself is localized by the backend providing the content; the component renders it as-is.

## Accessibility Options

Not applicable: Component renders markdown content with the active palette; it does not respond to system-level accessibility options (e.g., Reduce Motion, Increase Contrast) independently. The host app and palette system determine theme behavior in response to accessibility preferences.

## Feature Flags

Not applicable: No feature flags implemented in source. Component is always enabled; feature control would be implemented by the host app if needed.

## Analytics

Not applicable: No analytics instrumentation in source. Host app or a wrapper can emit analytics events based on user interactions (e.g., theme selection, document loads).

## Privacy

**Data collected**: Theme preference (ID string, e.g., "dark" or "light"). No sensitive user data is collected or transmitted.

**Storage**: Theme ID is persisted to localStorage (web) or Preferences (Apple). It is local-only; not sent to a server.

**Transmission**: No data is transmitted to analytics or telemetry services by the component.

**Retention**: Theme preference persists until the user clears storage or selects a different theme. No expiry or automatic cleanup.

## Logging

Not applicable: No logging instrumented in source. Host app can log component lifecycle events if needed (e.g., fetch start/end, errors).

## Platform Notes

- **SwiftUI**: Component is MarkdownViewerController (extends PlatformViewController). Holds a MarkdownTextPane and MarkdownDocumentRenderer. Re-renders AttributedText on palette change (does not cache) to keep theming synchronized. Palette is a property; assign a new palette to trigger refresh. Use optional CodeHighlighter for syntax highlighting support.

- **Compose**: Start with a Column in a scrollable Box for the toolbar and content area. Toolbar uses Row with title Text and a theme switcher Button. Content is rendered as composable markdown blocks with theme colors applied via CompositionLocal. Consider LazyColumn for very large documents. Apply theme palette via Material theme or custom color scheme.

- **React/Web**: File: MarkdownViewer.tsx. Client component that fetches via useMarkdownDocument hook, renders MarkdownRenderer output. Pre-hydration bootstrap script applies persisted theme to document root before React hydration (prevents no-flash). Toolbar uses APT design tokens (apt-* classes). Theme ID persisted to localStorage; stale IDs validated against registry. Palette applied as inline CSS custom properties (--mdv-*) on content root.

- **AppKit / UIKit**: Parallel to SwiftUI; use NSTextView (macOS) or UITextView (iOS) with attributed markdown. Create a view controller that holds toolbar (NSView/UIView with title label and theme switcher) and text view. Apply theme by regenerating AttributedString on palette change (similar to SwiftUI). Manage theme persistence via UserDefaults.

- **WinUI 3**: Use RichTextBlock (read-only, formatted text) or RichEditBox (editable, but configure as read-only). Toolbar is a Grid with title TextBlock and ComboBox for theme selection. Theme colors are applied via resource dictionary with semantic color keys. Handle theme changes by updating all relevant brushes and re-applying to the text block. Persist theme selection to ApplicationData.Current.LocalSettings.

## Design Decisions

- **No-flash theme on web**: Pre-hydration bootstrap script runs synchronously before React hydration so the persisted theme is applied before first paint. Prevents the visual jarring of loading in the default theme and then switching. The script targets its own parent element to isolate the scope.

- **No AttributedString caching on Apple**: Rendered markdown is stored as source text, not cached as an AttributedString. Re-rendering on palette change is cheap enough that caching adds unnecessary complexity and divergence risk. This ensures the rendered output stays synchronized with the active palette.

- **Per-instance theme state, not backend-tracked**: Theme selection is persisted locally (localStorage/Preferences) and not synchronized to a backend user preference. This allows independent theme choices across multiple app instances and respects local-first behavior. If backend tracking is desired, the host app can implement it separately.

- **Fetch timeout is per-instance**: Different use cases may require different timeout values (e.g., a quick preview vs. a long-form document). Timeouts are configured per component instance, not globally, to maximize flexibility.

- **Storage errors are silent**: If theme persistence fails (quota exceeded, permissions denied, private mode), the operation is logged but the component continues working with the theme in memory. The user retains the theme for the session, and it is not persisted.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| [wcag-2.1-aa](agenticdevelopercookbook://compliance/accessibility#wcag-2.1-aa) | passed | Accessibility |
| [platform-design-language](agenticdevelopercookbook://compliance/design#platform-design-language) | passed | Design |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation from web (React/TypeScript) and Apple (Swift) sources. |
