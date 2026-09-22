---
id: e16d896e-9318-48ac-bf1e-b48ef648d73c
title: DeckScript
domain: agenticdevelopercookbook://ingredients/deck-script
type: ingredient
version: 1.0.0
status: review
language: en
created: 2026-09-22
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Renders critical initialization scripts that must run before first paint
  to control scroll behavior and viewport settings.
platforms:
- typescript
- web
tags:
- scroll
- initialization
- performance
- viewport
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# DeckScript

## Overview

DeckScript is a React component that renders inline scripts executed before page hydration to initialize scroll behavior, scroll snapping, smooth scroll easing, and iOS viewport zoom constraints. All four behaviors are optional and default to enabled. The component exports both a function that returns the script as a string and a React component that renders it. Must be placed first inside `<body>`, not `<head>`, to ensure the viewport meta tag is already parsed.

## Behavioral Requirements

- **must-render-script-element**: Component MUST render a `<script>` element with `dangerouslySetInnerHTML` containing the generated inline script body.
- **must-execute-before-hydration**: The rendered script MUST execute as a literal inline `<script>` tag before React hydration begins; it MUST NOT be wrapped in a client component or effect.
- **must-support-open-at-top**: When `openAtTop` is `true` (default), the script MUST set `history.scrollRestoration` to `"manual"` to force every load to start at the top.
- **must-support-arm-snapping**: When `armSnapping` is `true` (default), the script MUST attach listeners to the first occurrence of `pointerdown`, `wheel`, or `keydown` events, and on first fire MUST set a `data-snap` attribute on `document.documentElement` exactly once.
- **must-support-arm-smooth**: When `armSmooth` is `true` (default), the script MUST attach listeners to `pointerdown`, `wheel`, and `keydown` events to set a `data-smooth` attribute on `document.documentElement` with no `once` limit, and MUST remove the `data-smooth` attribute on every `popstate` event.
- **must-support-restore-zoom**: When `restoreZoomOffIos` is `true` (default), the script MUST detect iOS Safari (iPhone, iPad, or iPod in user agent) and Mac with touch (MacIntel with maxTouchPoints > 1), and on non-iOS platforms MUST strip any `maximum-scale` constraint from the viewport meta tag at parse time and again at `load` event.
- **must-allow-partial-disabling**: Each of the four behaviors (openAtTop, armSnapping, armSmooth, restoreZoomOffIos) MUST be independently disableable via the options object passed to the component or function.
- **must-compose-into-single-string**: The `deckScript()` function MUST concatenate enabled script segments into a single string; the component MUST pass this string to `dangerouslySetInnerHTML.__html`.
- **must-use-passive-listeners**: When attaching event listeners in `armSnapping` and `armSmooth`, the script MUST use `{passive:true}` option; `armSnapping` MUST also use `{once:true}`.
- **must-target-root-element**: All attribute mutations (data-snap, data-smooth) MUST target `document.documentElement`, not any other element.

## Appearance

Not applicable: DeckScript is a script element that does not render visible content. It contains only JavaScript code that initializes page behavior.

## States

Not applicable: DeckScript is an initialization script with no interactive states. It executes once at page load and operates via side effects on document attributes.

## Accessibility

Not applicable: DeckScript operates at the initialization layer and does not directly interact with accessibility APIs. The scroll behavior it enables (scroll snapping, smooth easing) SHOULD be handled by platform-level CSS (e.g., `scroll-snap-type`, `scroll-behavior`) which already carries accessibility implications in both browsers and assistive technologies. Users who disable smooth scrolling via system preferences SHOULD disable it via `arm-smooth=false` when composing the page.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| deck-script-001 | must-render-script-element | `<DeckScript />` rendered in JSX | A `<script>` element with non-empty `dangerouslySetInnerHTML` property appears in the rendered output |
| deck-script-002 | must-support-open-at-top | `deckScript({ openAtTop: true })` | Returned string contains `history.scrollRestoration="manual"` |
| deck-script-003 | must-support-open-at-top | `deckScript({ openAtTop: false })` | Returned string does NOT contain `history.scrollRestoration` |
| deck-script-004 | must-support-arm-snapping | `deckScript({ armSnapping: true })` | Returned string contains `addEventListener` calls for `pointerdown`, `wheel`, `keydown` and sets `data-snap` attribute |
| deck-script-005 | must-support-arm-snapping | `deckScript({ armSnapping: false })` | Returned string does NOT contain `data-snap` attribute code |
| deck-script-006 | must-support-arm-smooth | `deckScript({ armSmooth: true })` | Returned string contains listeners for smooth scroll and `popstate` removal of `data-smooth` |
| deck-script-007 | must-support-arm-smooth | `deckScript({ armSmooth: false })` | Returned string does NOT contain `data-smooth` attribute code |
| deck-script-008 | must-support-restore-zoom | `deckScript({ restoreZoomOffIos: true })` on non-iOS | Returned string contains code that strips `maximum-scale` from viewport meta tag |
| deck-script-009 | must-support-restore-zoom | `deckScript({ restoreZoomOffIos: false })` | Returned string does NOT contain viewport meta modification code |
| deck-script-010 | must-allow-partial-disabling | `deckScript({ openAtTop: true, armSnapping: false, armSmooth: true, restoreZoomOffIos: true })` | Returned string contains only the three enabled segments; total length is shorter than all-enabled |
| deck-script-011 | must-use-passive-listeners | `deckScript({ armSnapping: true })` | Returned string contains `{once:true,passive:true}` for snapping listeners |
| deck-script-012 | must-use-passive-listeners | `deckScript({ armSmooth: true })` | Returned string contains `{passive:true}` for smooth listeners without `once` |
| deck-script-013 | must-target-root-element | `deckScript({ armSnapping: true, armSmooth: true })` | Returned string calls `setAttribute` and `removeAttribute` only on `document.documentElement` (or variable referencing it) |

## Edge Cases

- **Empty options object**: When `deckScript({})` is called, all four defaults (true) MUST be applied, returning the full script string.
- **Undefined options parameter**: When `deckScript()` is called with no arguments, defaults MUST be applied identically to `deckScript({})`.
- **Disabled all behaviors**: When `deckScript({ openAtTop: false, armSnapping: false, armSmooth: false, restoreZoomOffIos: false })` is called, the function MUST return an empty string.
- **Viewport meta tag missing at parse time**: When `restoreZoomOffIos` runs and no viewport meta tag exists, the code MUST not throw; it MUST await the `load` event and retry the query.
- **Multiple DeckScript renders**: Only one `<DeckScript />` instance SHOULD be rendered per page; if multiple instances are rendered, each will inject its own script block. The behavior is undefined and likely duplicative. Applications MUST render exactly one instance.
- **DeckScript rendered in <head>**: The component SHOULD be placed first in `<body>` as documented; if placed in `<head>`, the viewport meta tag may not yet be parsed and `restoreZoomOffIos` behavior is degraded to only the `load` event fallback.
- **pointerdown/wheel/keydown event firing before arm-snapping first listener attached**: This condition cannot occur; the script attaches listeners synchronously before any user input can fire.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `openAtTop` | boolean | `true` | Scroll to top on every page load by setting `history.scrollRestoration` to `"manual"` |
| `armSnapping` | boolean | `true` | Enable scroll snapping on `document.documentElement` after first user input (pointerdown, wheel, or keydown) |
| `armSmooth` | boolean | `true` | Enable smooth scrolling easing on first input; disable on browser back/forward (popstate event) |
| `restoreZoomOffIos` | boolean | `true` | Remove `maximum-scale` viewport meta constraint on non-iOS platforms to re-enable pinch-zoom |

## Deep Linking

Not applicable: DeckScript is an initialization script and does not handle deep linking or URL routing.

## Localization

Not applicable: DeckScript contains only JavaScript logic and inline HTML attribute operations; it generates no user-facing text.

## Accessibility Options

Not applicable: DeckScript operates at the initialization layer. Scroll behavior preferences (Reduce Motion) SHOULD be implemented by disabling `armSmooth` and configuring CSS `scroll-behavior` appropriately; this is the caller's responsibility, not DeckScript's.

## Feature Flags

Not applicable: DeckScript is a low-level initialization primitive with no feature flag interface. Enable or disable each behavior via the configuration options passed to the function or component.

## Analytics

Not applicable: DeckScript performs no analytics event tracking. It operates before page hydration and user interaction begins.

## Privacy

Not applicable: DeckScript performs no data collection, storage, or transmission. It reads and writes only to the DOM and performs user-agent sniffing locally.

## Logging

Not applicable: DeckScript does not emit log messages. It performs silent initialization; any errors encountered (e.g., missing viewport meta tag) are handled gracefully with fallbacks and no reporting.

## Platform Notes

- **TypeScript/Web**: Source files are `packages/web/packages/landing/src/deck/DeckScript.tsx`. The component exports both `deckScript(options)` (string generator) and `DeckScript` (React component). Render first inside `<body>`. Relies on CSS rules in `base.css` for `html[data-smooth]` (smooth scroll) and `html[data-snap]` (scroll snap) activation.

- **SwiftUI**: Equivalent functionality would require wrapping a `WKWebView` with `WKWebViewConfiguration` that injects JavaScript at document start time. Create a WKUserScript with injectionTime `.atDocumentStart` and mainFrameOnly `true`, then add it to `WKWebViewConfiguration.userContentController`. Each behavior maps to a discrete script segment that can be conditionally included in the source string passed to WKUserScript. SwiftUI views wrapping the web view would need to expose configuration properties corresponding to the four boolean options.

- **Compose**: Equivalent functionality requires embedding a `WebView` with JavaScript injection via `WebViewClient.onPageStarted()` or by using `JavaScriptInterface` to inject scripts before the page renders. Android's WebView does not have a direct "before first paint" hook like `WKUserScript.injectionTime.atDocumentStart`, so inject the script in `onPageStarted()` (after `onPageFinished()` is called) and rely on fast injection before user interaction. Alternatively, embed the script in the HTML template served to the WebView. Conditional segments follow the same pattern as TypeScript.

- **AppKit / UIKit**: Use `WKWebView` with `WKUserScript` injected at `WKUserScriptInjectionTime.atDocumentStart` into `WKWebViewConfiguration.userContentController`, identical to SwiftUI. On iOS, the script runs before any user interaction, ensuring scroll restoration and snapping arm before the first input. UIViewController subclasses would configure the WKWebView and build the script string from the same four boolean flags.

- **WinUI 3**: Embed a `WebView2` control and use `CoreWebView2.AddScriptToExecuteOnDocumentCreatedAsync()` to inject the JavaScript. Call this method before navigating to the page. The script executes at document creation time, before rendering. Use `CoreWebView2.ExecuteScriptAsync()` only for post-load scripts; for pre-paint initialization, `AddScriptToExecuteOnDocumentCreatedAsync()` is the only reliable method. Compose the script string conditionally from the four options, then pass the complete string to `AddScriptToExecuteOnDocumentCreatedAsync()`.

## Design Decisions

- **Four independent behaviors, not one**: The component does not force all behaviors on or off together. Each behavior (scroll to top, snap arming, smooth easing, iOS zoom restoration) addresses a distinct UX concern (pull-to-refresh parity, preventing mid-load snap, respecting history traversal, accessibility), and disabling one does not require disabling others.
- **Event listener attachment timing**: Snapping and smooth scroll arm on *first input*, not on page load or after a delay. This avoids the "mid-load snap" problem: if scroll snap were active during the initial layout pass while section heights are still settling, the snap engine would pick a snap point at an intermediate height, leaving the reader between two screens. Arming on first input guarantees the page is at rest when the property activates.
- **PopState handling for smooth scroll**: Smooth scroll must be re-armed after history traversal because the browser's own scroll restoration uses `scroll-behavior: smooth` (from base.css), which would animate the reader to their previous scroll offset and create the false impression of travel. Clearing `data-smooth` on `popstate` removes easing from the restoration scroll, then the next input re-arms it. This is why `popstate` handling does *not* use `{once:true}`.
- **Viewport meta modification on non-iOS only**: The `maximum-scale=1` constraint is necessary on iOS Safari to prevent zoom-on-focus of form fields, but it also disables pinch-zoom entirely—an accessibility regression on platforms where accidental zoom is not a concern. Stripping it on non-iOS restores user control while preserving iOS accessibility for form interaction.
- **Inline script, not effect**: This must be a literal `<script>` tag rendered by the component, not an effect. By the time React effects fire (after hydration), scroll restoration and user input may have already occurred. The script must run before any React lifecycle.
- **Placement in <body>, not <head>**: The `restoreZoomOffIos` segment calls `document.querySelector('meta[name=viewport]')` immediately. In `<head>`, the viewport meta tag may not yet be parsed (depending on framework render order). Placing the script first inside `<body>` guarantees the meta tag is already behind it in the DOM.

## Compliance

Not applicable: DeckScript is a low-level initialization primitive and does not directly invoke platform compliance checks. Applications using DeckScript should separately verify that their viewport meta settings and scroll behavior comply with WCAG 2.1 and platform accessibility guidelines.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | | Initial creation |
