---
id: 6ea605aa-9248-46d4-9532-82185388749b
title: Markdown Preview
domain: agenticdevelopercookbook://ingredients/markdown-preview
type: ingredient
version: 1.0.0
status: review
language: en
created: 2026-09-22
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A React component that fetches and renders GitHub-flavored markdown content
  with syntax highlighting, theme support, and timeout-aware error handling.
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

# Markdown Preview

## Overview

Markdown Preview is a presentational component that fetches full markdown content for a document via HTTP, renders it using GitHub-flavored markdown with Shiki syntax highlighting, applies a reading theme palette, and manages loading, empty, and error states. It is designed for integration into a search or discovery interface where users select a document and its content appears in a preview panel.

## Behavioral Requirements

- **must-fetch-content-from-url**: Component MUST construct a full-content URL from the injected `SearchSource` configuration and the provided `PaperSearchHit`, following the template pattern `endpoints.content` (defaulting to `/:slug/:route`) with URL-encoded slug and route placeholders.
- **must-render-markdown-content**: Component MUST render fetched markdown content using `MarkdownRenderer` from `@agenticdevelopertoolkit/markdown` with the same GitHub-flavored, Shiki-highlighted, rehype-sanitized pipeline used across all ADH sites.
- **must-apply-reading-theme**: Component MUST apply the reading theme palette to the rendered content by setting `data-mdv-theme`, `data-mdv-shiki-variant`, and CSS custom properties (computed once at module scope from `getThemeById(DEFAULT_THEME_ID)`).
- **must-show-loading-state**: Component MUST display a loading state with the text "Loading paper…" and MUST mark the state container with `aria-live="polite"` and `aria-busy="true"`.
- **must-show-empty-state**: Component MUST display a distinct empty state (title: "Empty paper", detail: "This paper has no content yet.") when the fetch succeeds but the content body is empty or whitespace-only.
- **must-show-error-state**: Component MUST display an error state (title: "Failed to load paper") with the error message and MUST mark the container with `role="alert"` when the fetch fails.
- **must-handle-timeout**: Component MUST apply an `AbortSignal.timeout()` configured via the `timeoutMs` prop (default 15s) to abort requests that exceed the timeout, transitioning to the error state with a message indicating the timeout duration in seconds.
- **must-provide-retry-capability**: Component MUST include a clickable Retry button in the error state that re-runs the fetch without requiring component remount or prop change.
- **must-abort-on-unmount**: Component MUST abort any in-flight fetch request when the component unmounts or when a different document is selected (change in `hit.author.slug`, `hit.publicRoute`, or `source.baseUrl`).
- **must-distinguish-timeout-from-other-errors**: Component MUST treat `DOMException` with `name === 'TimeoutError'` as a timeout error (separate message) and other errors (HTTP, network, JSON parse) as request errors.
- **must-handle-non-ok-http-status**: Component MUST reject the fetch promise and transition to error state when the HTTP response status is not 2xx, with error message including the status code (e.g., "Failed to load paper (HTTP 404).").
- **must-use-source-ref-for-dependency-stability**: Component MUST read `SearchSource` through a ref in the fetch effect so that inline `source` object creation does not trigger re-fetches; only changes to `slug`, `route`, `baseUrl`, `endpoints.content`, and `timeoutMs` trigger a new fetch.

## Appearance

- **Container**: Root `div` with class `adh-mv-content`, transparent background (content is rendered inside).
- **Reading palette**: Applied via inline `style` attribute with CSS custom properties from `READING_THEME.palette` (colors, spacing, typography defined by theme).
- **State container**: Nested `div` with class `adh-mv-state` or `adh-mv-state--error` (on error), centered or stacked layout.
- **State title**: `p` with class `adh-mv-state-title` (if shown).
- **State detail**: `p` with class `adh-mv-state-detail` (loading, empty, or error message text).
- **Retry button**: Built from `Button` component (variant: "outline", size: "sm"), placed below error detail with `className="mt-3"`.
- **Markdown body**: Rendered by `MarkdownRenderer` (no wrapper div or title; body only).

## States

| State | Appearance change | Trigger |
|-------|------------------|---------|
| Loading | State container shown with "Loading paper…" text, aria-busy="true" | Initial mount or refetch |
| Ready | Markdown content rendered via MarkdownRenderer | Content fetch succeeds and body is non-empty |
| Empty | State container shown with "Empty paper" title and detail text | Content fetch succeeds but body is empty or whitespace-only |
| Error | State container shown with error title, error message, and Retry button with role="alert" | Fetch fails (timeout, HTTP error, network error, JSON parse error) |

## Accessibility

- **Role**: The component itself is a region; the error state container is marked with `role="alert"` to announce failures to screen readers.
- **Live region**: The loading state container is marked with `aria-live="polite"` and `aria-busy="true"` to announce the loading phase.
- **Label**: The error detail text serves as the accessible error message; the Retry button is labeled "Retry".
- **Markdown rendering**: Content is rendered by `MarkdownRenderer` which applies semantic HTML (headings, lists, code blocks) and ensures proper color contrast via the theme palette.
- **Keyboard interaction**: The Retry button is keyboard-accessible (Tab, Enter/Space to activate).
- **Minimum tap target**: Retry button follows `Button` component's sizing (48×48dp minimum per Material Design 3).

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|----|----|----|
| mp-001 | must-fetch-content-from-url, must-use-source-ref-for-dependency-stability | hit with slug="alice-wonder", publicRoute="paper-001", source with endpoints.content="/:slug/:route" and baseUrl="https://api.example.com" | Fetch request to `https://api.example.com/alice-wonder/paper-001` (URL-encoded); slug and route are percent-encoded if they contain special characters |
| mp-002 | must-render-markdown-content | Fetched JSON response `{ "content": "# Title\n\nBody text." }` | MarkdownRenderer is called with content "# Title\n\nBody text."; rendered output appears in DOM |
| mp-003 | must-apply-reading-theme | Component mounted with MarkdownRenderer output | Root div has data-mdv-theme, data-mdv-shiki-variant attributes; CSS custom properties from READING_THEME.palette are applied as inline style |
| mp-004 | must-show-loading-state | Initial render before fetch completes | Div with class "adh-mv-state" is visible, contains p with text "Loading paper…", aria-live="polite" and aria-busy="true" are set |
| mp-005 | must-show-empty-state | Fetch returns `{ "content": "" }` or `{ "content": "   " }` | Div with class "adh-mv-state" shows title "Empty paper" and detail "This paper has no content yet." |
| mp-006 | must-show-error-state | Fetch fails with HTTP 404 | Div with class "adh-mv-state adh-mv-state--error" is visible with role="alert", title "Failed to load paper", detail "Failed to load paper (HTTP 404)." |
| mp-007 | must-handle-timeout | timeoutMs=100, fetch stalls > 100ms | AbortSignal.timeout(100) aborts the request; component shows error state with message "Timed out loading paper after 0s." (or "1s" if >= 500ms) |
| mp-008 | must-distinguish-timeout-from-other-errors | timeoutMs=100, fetch stalls > 100ms | Error message includes "Timed out loading paper after Xs." (duration in seconds, rounded); non-timeout errors show different message |
| mp-009 | must-provide-retry-capability | Component in error state, user clicks Retry button | reloadToken state is incremented; fetch effect re-runs for the same hit and source; component returns to loading state |
| mp-010 | must-abort-on-unmount | hit.author.slug changes from "alice" to "bob" during error state | In-flight fetch is aborted (if any); new fetch is initiated for the new slug; component transitions through loading state for the new document |
| mp-011 | must-handle-non-ok-http-status | Fetch returns HTTP 500 | res.ok is false; error is thrown with message "Failed to load paper (HTTP 500)."; error state is shown with this message |
| mp-012 | must-use-source-ref-for-dependency-stability | source prop is recreated each render (new object, same values); hit stays the same | Fetch does not re-run; sourceRef.current is updated but the effect dependencies (slug, route, baseUrl, contentTemplate, timeoutMs) do not change |

## Edge Cases

- **Empty content after trim**: If fetched content is all whitespace, `content.trim()` evaluates to falsy; component shows empty state (not error).
- **Fetch succeeds but JSON missing content key**: Response is `{}` or has no `content` field; code defaults to empty string (`body.content ?? ''`); empty state is shown.
- **Network error during fetch**: `.catch()` catches the error; if `!active` is true (unmount race), error is dropped silently; otherwise error state is shown with original error message.
- **Unmount during fetch**: `active` flag is set to false in the cleanup function; `.then()` and `.catch()` check `!active` and drop results silently; no state update occurs after unmount.
- **Re-select same document during error state**: User clicks Retry; `reloadToken` increments, triggering re-fetch; same URL is fetched again.
- **Controller abort vs. timeout abort**: `AbortSignal.any([controller.signal, AbortSignal.timeout(timeoutMs)])` combines both; timeout produces a `DOMException` with `name === 'TimeoutError'`, which is distinct from controller.abort() (checked via `controller.signal.aborted`).
- **Non-JSON response body**: If `res.json()` throws, the promise is rejected; `.catch()` catches it; error state shows "Failed to load paper." (or the specific parse error message).
- **Null or missing hit properties**: Component assumes `hit.author.slug` and `hit.publicRoute` exist and are strings; no null checks are present in source; passing undefined/null will result in invalid URLs or fetch failure.
- **Very large content**: MarkdownRenderer and rehype-sanitize process the full content; no streaming or chunking is performed.
- **Custom endpoint template**: If `source.endpoints.content` is provided, it overrides the default; template must include `:slug` and `:route` placeholders or they will not be replaced.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `hit` | `PaperSearchHit` | — | Required. The selected document metadata including `author.slug` and `publicRoute`. |
| `source` | `SearchSource` | — | Required. Injected scope configuration with `baseUrl`, `endpoints.content`, and `fetchInit`. |
| `timeoutMs` | `number` | `DEFAULT_TIMEOUT_MS` (15000) | Fetch timeout in milliseconds. Passed to `AbortSignal.timeout()`. |

## Deep Linking

Not applicable: This component is a preview body within a search/discovery interface and does not itself handle deep linking. The host application (preview dock or search surface) manages navigation and URL construction.

## Localization

| String Key | Default (en) | Context |
|-----------|-------------|---------|
| (none) | "Loading paper…" | Loading state detail text |
| (none) | "Empty paper" | Empty state title |
| (none) | "This paper has no content yet." | Empty state detail |
| (none) | "Failed to load paper" | Error state title |
| (none) | (dynamic) | Error state detail: either timeout message or error message |
| (none) | "Retry" | Retry button label |

Note: Strings are hardcoded in the component; no i18n framework is integrated. Localization would require extracting strings to a message catalog and applying a translation layer.

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | Not applicable: This component does not animate. The state transitions (loading → ready/empty/error) are instantaneous DOM swaps, not CSS animations or transitions. |
| Increase Contrast | Applied by the reading theme palette (READING_THEME.palette includes contrast-optimized colors); no component-specific handling is needed. |
| Differentiate Without Color | Applied by the reading theme palette and MarkdownRenderer output (semantic HTML markup does not rely on color alone). |

## Feature Flags

Not applicable: No feature flags are defined or checked within this component. The component is always enabled once rendered by its host.

## Analytics

Not applicable: No analytics events are emitted or tracked by this component. Event tracking (if needed) would be implemented by the host search/discovery interface.

## Privacy

- **Data collected**: None. This component does not collect user data.
- **Storage**: None. The fetched content is held in React state for rendering only.
- **Transmission**: The component fetches content via HTTP(S) from the injected `source.baseUrl`. Transmission is governed by the host application's endpoint configuration and network layer (e.g., auth headers in `source.fetchInit`).
- **Retention**: Content is not persisted; it is discarded when the component unmounts or when a different document is selected.

## Logging

Not applicable: No logging or console output is performed by this component. Debug logging (if needed) would be added by wrapping the fetch logic or inspecting browser DevTools.

## Platform Notes

- **TypeScript/Web (source)**: Implemented in `MarkdownPreview.tsx` using React hooks (`useState`, `useEffect`, `useCallback`, `useRef`). Fetch is performed via the native `fetch` API with `AbortSignal.timeout()` (requires modern browsers). Content rendering delegated to `MarkdownRenderer` component from `@agenticdevelopertoolkit/markdown` (rehype-sanitized GitHub-flavored markdown with Shiki syntax highlighting). State machine (loading → ready/empty/error) is managed via `useState`. Retry is implemented by incrementing a `reloadToken` to force effect re-run.
- **SwiftUI**: Implement as an async view that fetches content via `URLSession` with a timeout `TimeoutError` handler. Use `@State` to manage the four-phase state machine (loading, ready, empty, error). Render markdown via a native markdown view (e.g., `MarkdownUI` package or custom `NSAttributedString` rendering with code highlighting via a syntax highlighter library). Apply theme colors via SwiftUI environment values (`.preferredColorScheme`, custom `EnvironmentKey`). Implement retry via a button that re-triggers the async fetch task.
- **Compose**: Implement as a Composable that manages state via `remember` and collects content via `LaunchedEffect` with `URLConnection` or OkHttp client. Define a timeout via `withTimeoutOrNull()` or HTTP client configuration. Render markdown via a custom Composable using an Android markdown rendering library (e.g., Markwon). Apply Material 3 theme colors via `MaterialTheme.colorScheme`. State transitions (loading ↔ ready/empty/error) via `when` expression.
- **AppKit / UIKit**: Implement as a `UIViewController` (iOS) or `NSViewController` (macOS) that fetches via `URLSession` with `URLSessionConfiguration.default.timeoutIntervalForRequest`. Manage state via `@Published` properties (if using Combine) or properties with KVO. Render markdown via `WKWebView` loaded with an HTML wrapper or a native markdown library. Apply theme colors via `UIAppearance` or `NSAppearance`. Implement retry via a UIButton/NSButton target-action or Combine button publisher.
- **WinUI 3**: Implement as a User Control (`<UserControl>` XAML) with code-behind or `ViewModel` (MVVM). Fetch via `HttpClient` from `System.Net.Http` with `TimeoutInMilliseconds` property. Manage state via `INotifyPropertyChanged` properties (loading, content, empty, error). Render markdown via a `RichTextBlock` or custom markdown parsing to `Run` elements with `TextFormatting` applied (bold, italic, code color). Apply theme colors via `ThemeResource` references to the default Windows theme palette (light/dark mode automatic). Implement retry via a `Button` with `Click` event handler that re-runs the fetch logic.

## Design Decisions

- **Why theme palette is computed at module scope**: The reading theme is static for any given instance of the component and does not depend on props or runtime state. Computing it once at module load time (not in render) avoids redundant theme lookups and `getThemeById()` calls. The theme applies to all future instances of the component in the same session.
- **Why sourceRef is used instead of direct dependency**: If `source` is a new object each render (same values, different reference), a naive effect dependency on `source` would re-fetch on every render. The `sourceRef` workaround reads the latest `source` value inside the effect but only depends on the stable identity of its primitive properties (slug, route, baseUrl, contentTemplate). This is a common React pattern for "read-only" dependencies that should not trigger re-runs.
- **Why unmount and re-select share the same abort path**: Both cases benefit from aborting in-flight requests via the same `controller`. The `active` flag distinguishes them: unmount sets `active = false` and drops results silently; a re-select (different slug/route/baseUrl) triggers a new effect and starts a new fetch. Shared cleanup logic keeps the implementation simple.
- **Why empty state is separate from error**: Empty content (successful fetch, empty body) is distinct from error (failed fetch, network/timeout/server error). This distinction helps users understand whether the paper truly has no content or whether there was a technical problem (recoverable via Retry).
- **Why timeout is parameterized**: The default 15s mirrors the `MarkdownViewer` component's behavior (per source comment). Allowing `timeoutMs` as a prop enables callers to adjust based on network conditions or use-case SLAs without modifying the component.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| WCAG 2.1 AA contrast | passed | Accessibility (theme palette enforces contrast) |
| Keyboard navigation | passed | Accessibility (Retry button is keyboard-accessible) |
| Screen reader support | passed | Accessibility (aria-live, aria-busy, role="alert" inform assistive tech) |
| Semantic HTML | passed | Accessibility (MarkdownRenderer outputs semantic HTML for markdown; state containers use role attributes) |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | | Initial creation |
