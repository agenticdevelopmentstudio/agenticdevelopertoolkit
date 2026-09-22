---
id: f86178c6-4255-4d66-86e7-0b3b5a2e00c0
title: Source Code Panel
domain: agenticdevelopertoolkit://recipes/source-code-panel
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A syntax-highlighted code display component with optional copy and filename
  display.
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

# Source Code Panel

## Overview

The Source Code Panel displays syntax-highlighted source code with optional header containing filename and copy-to-clipboard button. It accepts code as a string, specifies the language for highlighting, and renders using Shiki syntax highlighter with theme support from toolkit-controlled CSS or explicit prop.

## Behavioral Requirements

- **must-render-code**: Component MUST display the provided code string.
- **must-accept-language**: Component MUST accept a `lang` prop specifying the language; defaults to `'tsx'` if unspecified.
- **must-support-shiki-highlighting**: Component MUST attempt to syntax-highlight code using Shiki, applying the resolved theme.
- **must-resolve-theme-from-prop**: Component MUST use the `theme` prop if provided; theme prop takes precedence over CSS-derived theme.
- **must-resolve-theme-from-css**: Component MUST read `--scp-shiki-theme` CSS custom property from the panel root element; property value is treated as a quoted string and quotes are stripped.
- **must-fallback-theme**: Component MUST use `'github-dark'` as the fallback theme when `theme` prop is not provided and `--scp-shiki-theme` is not set or empty.
- **must-watch-theme-changes**: Component MUST observe mutations to the `agentic-toolkit-theme` style element and re-read the theme CSS property when it changes, provided `theme` prop is not set.
- **must-show-header-when-content**: Component MUST display a header when filename is provided OR showCopy is true.
- **must-display-filename**: Component MUST display the filename in the header if provided; if filename is not provided, display the language code instead.
- **must-show-copy-button**: Component MUST display a "Copy" button when `showCopy` is true.
- **must-copy-on-click**: Component MUST copy the code string to clipboard when the copy button is clicked, using `navigator.clipboard.writeText`.
- **must-show-copied-state**: Component MUST display "Copied" text in the button for 1200ms after a successful copy operation.
- **must-reset-copied-state**: Component MUST return the button text to "Copy" after 1200ms in the copied state.
- **must-handle-copy-failure**: Component MUST silently no-op if clipboard access is denied or unavailable; no error message or state change occurs.
- **must-render-highlighted-html**: Component MUST render the Shiki-generated HTML directly into the DOM when highlighting succeeds.
- **must-fallback-to-preformatted**: Component MUST render code in a `<pre><code>` element with the plain code string when highlighting fails.
- **must-show-loading-state**: Component MUST display the plain `<pre><code>` fallback with `aria-busy="true"` attribute while highlighting is in progress.
- **must-remove-aria-busy**: Component MUST remove the `aria-busy` attribute from the fallback when highlighting completes.
- **must-support-maxheight**: Component MUST accept a `maxHeight` prop and apply it as inline CSS `max-height` style on the body container if provided.
- **must-support-classname**: Component MUST accept a `className` prop and apply it to the root div; root element always has `scp-root` class, and provided className is appended.

## Appearance

- **Container**: Root div with class `scp-root`
- **Header**: Optional header element with class `scp-header`, displays only when filename or showCopy is true
- **Filename/Language span**: Class `scp-filename`, displays filename or language code
- **Copy button**: Class `scp-copy`, type="button", displays "Copy" or "Copied"
- **Body container**: Div with class `scp-body`, contains highlighted code or fallback
- **Highlighted code**: Div with class `scp-shiki`, receives Shiki-generated HTML
- **Fallback code**: `<pre>` with class `scp-fallback`, contains `<code>` child with plain text; may have `aria-busy` attribute during loading
- **Custom className**: Appended to root after `scp-root` if provided
- **Max height**: Applied as inline `max-height` CSS on body container if maxHeight prop is provided
- **Font**: Shiki theme controls font rendering in highlighted code; fallback uses browser default monospace
- **Colors**: Shiki theme controls syntax highlighting colors; fallback text color follows default foreground

## States

| State | Appearance change |
|-------|------------------|
| Default | Code is displayed with syntax highlighting applied or fallback `<pre><code>` if highlight pending |
| Copy button: "Copy" | Button text displays "Copy" |
| Copy button: "Copied" | Button text displays "Copied" for 1200ms after successful copy |
| Loading | Fallback `<pre><code>` renders with `aria-busy="true"` |
| Error (highlight failed) | Fallback `<pre><code>` renders without `aria-busy` |
| Hidden header | Header not rendered when both filename is falsy and showCopy is false |

## Accessibility

- **Role**: Container with code content; use `<pre>` and `<code>` for fallback to provide semantic meaning
- **Copy button**: Semantic `<button type="button">` element with text content ("Copy" or "Copied")
- **Loading indicator**: When loading, fallback `<pre>` element has `aria-busy="true"` to announce in-progress state
- **Code representation**: Fallback uses plain `<pre><code>` structure; Shiki HTML is injected as-is without additional ARIA labels
- **Minimum touch target**: Copy button SHOULD be at least 44×44pt; not verified in source code

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| scp-001 | must-render-code | code="const x = 1" | Code string appears in rendered output |
| scp-002 | must-accept-language | lang="python" | Shiki receives "python" as language identifier |
| scp-003 | must-resolve-theme-from-prop | theme="nord" | Component uses "nord" theme, ignoring CSS property |
| scp-004 | must-resolve-theme-from-css | theme not provided, --scp-shiki-theme set to 'github-light' | Component uses "github-light" theme (quotes stripped) |
| scp-005 | must-fallback-theme | theme not provided, --scp-shiki-theme not set | Component uses "github-dark" as fallback |
| scp-006 | must-watch-theme-changes | theme not provided, --scp-shiki-theme mutates | Component re-reads CSS property and updates highlighted output |
| scp-007 | must-show-header-when-content | filename provided | Header renders with filename |
| scp-008 | must-show-header-when-content | filename not provided, showCopy=true | Header renders with copy button |
| scp-009 | must-display-filename | filename="App.tsx" | Header displays "App.tsx" |
| scp-010 | must-display-filename | filename not provided, lang="jsx" | Header displays "jsx" |
| scp-011 | must-show-copy-button | showCopy=true | "Copy" button is visible and clickable |
| scp-012 | must-copy-on-click | showCopy=true, code="test" | Clicking "Copy" button copies "test" to clipboard |
| scp-013 | must-show-copied-state | Copy succeeds | Button text changes to "Copied" |
| scp-014 | must-reset-copied-state | "Copied" state active for 1200ms | Button text returns to "Copy" after 1200ms |
| scp-015 | must-handle-copy-failure | clipboard access denied | No error state or message; component continues functioning |
| scp-016 | must-render-highlighted-html | Shiki highlight succeeds | Shiki HTML renders in `.scp-shiki` div |
| scp-017 | must-fallback-to-preformatted | Shiki highlight fails | Code renders in `<pre><code>` with class `scp-fallback` |
| scp-018 | must-show-loading-state | Highlighting in progress | Fallback `<pre>` renders with `aria-busy="true"` |
| scp-019 | must-remove-aria-busy | Highlighting completes | `aria-busy` attribute is not present on fallback |
| scp-020 | must-support-maxheight | maxHeight="400px" | Body container has inline style `max-height: 400px` |
| scp-021 | must-support-classname | className="custom-theme" | Root div has class `scp-root custom-theme` |

## Edge Cases

- **Empty code string**: Component accepts empty string and renders empty or blank output; Shiki may return empty HTML.
- **Null or undefined lang**: Component defaults to `'tsx'` when lang is undefined; null is treated as provided value (behavior undefined).
- **Invalid language identifier**: Shiki receives identifier; behavior on unknown language is determined by Shiki (may render plain text or error).
- **Clipboard API unavailable**: Copy button click is silently no-op; no error state, no console message.
- **Missing agentic-toolkit-theme element**: Theme observer skips setup; component uses fallback or prop theme without mutation watching.
- **Very long code string**: Component renders full string; maxHeight prop constrains visual container with overflow scroll if needed.
- **Rapid theme changes**: MutationObserver triggers on each mutation; rapid CSS updates result in rapid re-reads and re-renders.
- **showCopy=false and no filename**: Header element does not render; code is displayed without header.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| code | string | required | Source code to display |
| lang | string | 'tsx' | Language identifier for Shiki syntax highlighting |
| theme | string | undefined | Explicit Shiki theme name; if set, overrides CSS-derived theme |
| showCopy | boolean | true | Show copy-to-clipboard button in header |
| filename | string | undefined | Filename to display in header; if not provided, language code is shown |
| className | string | undefined | Additional CSS class to append to root element |
| maxHeight | string or number | undefined | Max height for code body container; applied as inline style |

## Deep Linking

Not applicable: Source Code Panel is a stateless display component with no internal navigation or deep-linkable state.

## Localization

Not applicable: Component displays user-provided code and button labels ("Copy" / "Copied"). No translatable strings are defined in the component source; localization would require wrapping or prop-based labels.

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | Component does not animate state changes; respecting prefers-reduced-motion is not implemented in source |
| Increase Contrast | Shiki theme determines contrast; toolkit theme controls which Shiki theme is active |
| Differentiate Without Color | Shiki syntax highlighting relies on color differentiation; no fallback is provided in source |

## Feature Flags

Not applicable: Component has no feature flag logic; all functionality is controlled by props.

## Analytics

Not applicable: Component emits no events or analytics; copy action triggers no telemetry or logging.

## Privacy

Not applicable: Component accepts code string as input and displays it; clipboard write is user-initiated and platform-managed.

## Logging

Not applicable: Component performs no logging; errors in Shiki highlighting or clipboard access are silently caught.

## Platform Notes

- **SwiftUI**: SwiftUI has no direct Shiki integration. Use a `WebView` or equivalent to render HTML; inject Shiki CSS and the generated HTML from the equivalent React implementation. Detect theme changes via SwiftUI environment and pass as prop.
- **Compose**: Use `AndroidView` wrapping a web view, or compose a native Kotlin/Android equivalent using a syntax highlighting library like Highlight.js or Prism. Theme detection maps to system theme or explicit theme param. Button copy uses Compose's `Clipboard` or system clipboard API.
- **React/Web**: Source implementation. Use `SourceCodePanel` component directly; props match source signature. Theme resolution reads `--scp-shiki-theme` from DOM and respects explicit `theme` prop. Shiki version and available themes are fixed by the toolkit build.
- **AppKit / UIKit**: Use `WKWebView` or equivalent; serve the React component as a web page or embed pre-rendered HTML. Detect app theme via `NSAppearance` (macOS) or `UITraitCollection` (iOS) and inject theme as prop. Implement copy via `NSPasteboard` (macOS) or `UIPasteboard` (iOS).
- **WinUI 3**: Implement using `WebView2` control to host Shiki rendering. Resolve theme from `Application.Current.RequestedTheme` (Light/Dark) and map to Shiki theme names (e.g., Dark → "github-dark", Light → "github-light"). Implement copy button using `Windows.ApplicationModel.DataTransfer.Clipboard`. Handle missing clipboard gracefully with fallback or disabled state.

## Design Decisions

- **Shiki over Highlight.js / Prism**: Source uses Shiki, which provides higher fidelity syntax highlighting. Implementations MUST use equivalent capability (Shiki on other web platforms, native syntax highlighters on native platforms).
- **CSS theme prop, not React context**: Theme is resolved from CSS custom property to allow toolkit-wide theme synchronization. Explicit `theme` prop bypasses CSS detection for cases where prop control is needed.
- **Silent clipboard failure**: Clipboard errors are caught without user notification. This is appropriate for an optional copy feature; if clipboard becomes essential, error handling SHOULD be added.
- **1200ms copied state duration**: Hard-coded duration to show visual feedback. No configuration provided; implementations SHOULD match this timing.
- **Fallback to plain `<pre><code>`**: When Shiki fails, component degrades to plain text in semantic HTML. No error message is shown; degradation is silent.
- **MutationObserver for theme watching**: Uses native DOM API to detect stylesheet changes. Implementations on other platforms SHOULD detect theme changes similarly (system theme callbacks, CSS-in-JS observer, equivalent platform theme listener).

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| requires-form-semantic | passed | Not applicable; component is read-only display |
| requires-error-display | passed | Component silently handles errors (Shiki failure, clipboard denied) without error state |
| requires-loading-indicator | passed | Loading state indicated via aria-busy on fallback element |
| requires-keyboard-interaction | passed | Copy button is keyboard-accessible as semantic `<button>` |
| requires-touch-target | passed | Copy button touch target size not verified in source; SHOULD be ≥44×44pt per platform guidelines |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation from web source |
