---
id: 93e8b186-b7a6-41c5-90a8-21b67a47ef72
title: Site Header
domain: agenticdevelopertoolkit://recipes/site-header
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A flow page header with wordmark, optional navigation, and optional call-to-action
  that scrolls away with page content.
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

# Site Header

## Overview

A header component for flow pages that displays a wordmark, optional inline navigation, and optional call-to-action. The header scrolls away with page content, unlike fixed headers. Below a 62rem breakpoint, the inline navigation is hidden and navigation is provided through a drawer. The component manages the state of its drawer child when the viewport crosses the breakpoint.

## Behavioral Requirements

- **must-render-header**: Component MUST render a `<header>` element containing all provided content.
- **must-render-brand**: Component MUST render the `brand` prop as a child of a `.lp-site-brand` div if provided.
- **must-render-bar-links**: Component MUST render navigation links from `barLinks` (or `links` if `barLinks` is not provided) in a `<nav>` element with `aria-label` defaulting to "Site" at viewports wider than 62rem when `bar` is `'nav'`.
- **must-render-action**: Component MUST render the `action` prop in a `.lp-site-action` div if provided.
- **must-hide-bar-nav**: Component MUST not render the inline navigation bar when `bar` is `'drawer'` at any viewport width.
- **must-use-real-anchors**: Component MUST render navigation links as real `<a>` elements with `href` attributes, not as hidden elements with CSS.
- **must-render-drawer**: Component MUST render a `NavChrome` component in a drawer wrapper for all viewport widths.
- **must-omit-brand-from-drawer**: Component MUST NOT pass the `brand` prop to `NavChrome` in the drawer.
- **must-render-drawer-only-at-narrow**: Component MUST hide the drawer wrapper when the viewport width exceeds 62rem and `bar` is `'nav'`.
- **must-reset-drawer-state**: Component MUST remount `NavChrome` when the viewport crosses the 62rem breakpoint to reset its internal state.
- **must-pass-full-links**: Component MUST always pass the complete `links` array to `NavChrome`, regardless of which links are shown in the bar.
- **must-support-bar-prop**: Component MUST accept a `bar` prop that is either `'nav'` (default) or `'drawer'`.

## Appearance

- **Header layout**: Horizontal flexbox row containing brand, navigation, and action.
- **Bar height**: Determined by child component heights (brand, nav links, action).
- **Navigation alignment**: Brand on the left, navigation links in center, action on the right.
- **Link styling**: Inherits from NavChrome or parent styling; no additional styling applied by SiteHeader.
- **Drawer styling**: Inherits from NavChrome.
- **Scrolling**: Header scrolls away with page content (not fixed).
- **Responsive layout**: At 62rem breakpoint, inline navigation is hidden via CSS media query (not removed from DOM under `bar='nav'`).

## States

| State | Appearance change |
|-------|------------------|
| Default | Brand, nav links, action visible at wide viewport; drawer shown at narrow viewport |
| bar='drawer' | Brand visible, nav links never shown, burger always visible |
| Viewport < 62rem | Inline nav bar hidden, drawer visible |
| Viewport ≥ 62rem (bar='nav') | Inline nav bar visible, drawer wrapper hidden |

## Accessibility

- **Header role**: Component renders a semantic `<header>` element.
- **Navigation label**: The `<nav>` element inside the bar MUST have an `aria-label` attribute, defaulting to "Site" unless overridden via `navLabel` prop from `NavChromeProps`.
- **Link announcements**: Navigation links are real `<a>` elements, allowing screen readers to discover them.
- **Duplicate prevention**: Navigation links in the drawer are not duplicated in the bar under `bar='drawer'`, avoiding duplicate link destinations that assistive technology would discover.
- **Drawer management**: Focus trap and `inert` handling are delegated to `NavChrome`.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| site-header-001 | must-render-header | `{ brand: <div>Logo</div>, links: [...], bar: 'nav' }` | Header element renders with brand div visible |
| site-header-002 | must-render-bar-links | `{ barLinks: [{ href: '/', label: 'Home' }], links: [...], bar: 'nav' }` at 62rem+ | Nav element with aria-label="Site" renders with links as anchors |
| site-header-003 | must-render-action | `{ action: <button>Sign up</button>, bar: 'nav' }` at 62rem+ | Action div renders with button visible |
| site-header-004 | must-hide-bar-nav | `{ bar: 'drawer' }` at all widths | Inline nav element does not render; drawer renders at all widths |
| site-header-005 | must-use-real-anchors | `{ barLinks: [{ href: '/about', label: 'About' }] }` | Each link renders as `<a href="/about">About</a>` |
| site-header-006 | must-omit-brand-from-drawer | `{ brand: <div>Logo</div> }` | NavChrome receives no brand prop |
| site-header-007 | must-reset-drawer-state | Viewport resizes from 62rem+ to < 62rem with drawer open | NavChrome remounts, drawer state resets |
| site-header-008 | must-pass-full-links | `{ barLinks: [short links], links: [all links] }` at 62rem+ | NavChrome receives full `links` array; drawer shows all links |
| site-header-009 | must-support-bar-prop | `{ bar: 'drawer' }` | Burger shown, inline nav hidden; `{ bar: 'nav' }` (default) | Inline nav shown at 62rem+ |

## Edge Cases

- **No brand prop**: Component renders header without brand div. Confirmed by conditional render `{brand !== undefined && ...}`.
- **No links provided**: NavChrome and nav bar receive empty array. Component still renders but shows no navigation items.
- **No action prop**: Action div is not rendered. Confirmed by conditional render `{action !== undefined && ...}`.
- **Viewport resize across breakpoint with drawer open**: ResizeObserver detects transition from visible to hidden and remounts NavChrome via generation state increment. Below breakpoint (`bar='nav'`), drawer wrapper is hidden by CSS; remount only fires when transitioning from visible to hidden, not when already hidden.
- **bar='drawer' never hides drawer**: ResizeObserver never triggers remount because wrapper is never hidden (always has display visibility in CSS). This is correct behavior per source comment.
- **barLinks defaults to links**: If `barLinks` is not provided, `barLinks = links` (default parameter), so the same links array is used in both bar and drawer.
- **NavChrome state persistence**: NavChrome owns the open state and has no public API to close it. Remounting is the only way to reset state, which is why generation counter is used.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `brand` | `ReactNode` | `undefined` | Wordmark or branding element rendered in the header bar |
| `links` | `NavChromeProps['links']` | Required | Array of navigation links; always passed to drawer |
| `barLinks` | `NavChromeProps['links']` | `links` | Array of navigation links for the inline bar only (wide viewport); shorter than full list typical |
| `action` | `ReactNode` | `undefined` | Call-to-action element pinned to the right of the bar (wide viewport only) |
| `bar` | `'nav' \| 'drawer'` | `'nav'` | Navigation mode: `'nav'` shows inline links at wide viewport; `'drawer'` keeps burger at all widths |
| `footer` | `NavChromeProps['footer']` | Inherited | Footer content passed to NavChrome drawer |
| `navLabel` | `string` | `'Site'` | aria-label for the inline navigation `<nav>` element |

## Deep Linking

Not applicable: SiteHeader is a container component that does not define deep linking behavior. Deep linking is handled by child components (NavChrome, links) or the page that hosts the header.

## Localization

Not applicable: SiteHeader does not render any text content of its own. All text is provided via props (brand, links, action, navLabel) by the host application.

## Accessibility Options

- **Reduce Motion**: Not applicable; SiteHeader does not animate. Scrolling behavior is provided by the browser. NavChrome handles Reduce Motion for its drawer animations.
- **Increase Contrast**: Not applicable; SiteHeader applies no colors or contrast-dependent styling.
- **Differentiate Without Color**: Not applicable; SiteHeader does not use color as a sole means of conveying information.

## Feature Flags

Not applicable: SiteHeader is a presentation component and does not implement feature flags.

## Analytics

Not applicable: SiteHeader is a container component and does not emit analytics events. Analytics are handled by child components (NavChrome, links) or the page.

## Privacy

Not applicable: SiteHeader does not collect, store, or transmit any personal data.

## Logging

Not applicable: SiteHeader does not emit logs.

## Platform Notes

- **TypeScript/Web**: Source files are `SiteHeader.tsx` and `flow.css`. The breakpoint is 62rem, enforced by CSS media query in `flow.css` (not JavaScript). `ResizeObserver` on the wrapper element observes the CSS display decision rather than duplicating the breakpoint condition in JavaScript. The component renders real `<a>` anchor elements for navigation links to preserve crawler discoverability and assistive technology navigation.
- **SwiftUI**: Requires a native Swift wrapper around the web component or a reimplementation using SwiftUI's NavigationStack and TabView. The header should scroll away with ScrollView content, not be fixed. The breakpoint concept translates to horizontal size classes; use `.horizontalSizeClass` to adapt between nav bar and drawer layouts.
- **Compose**: Map the web layout to a Column with a Row header. Use remember and mutableStateOf to track viewport width (via LocalConfiguration or remeasurement). Conditional rendering of the nav row (using `if (barWidth > 62.rem)`) replaces the CSS media query. The drawer behavior maps to Compose's ModalNavigationDrawer.
- **AppKit / UIKit**: Use NSStackView (macOS) or UIStackView (iOS) for horizontal layout. Embed a WKWebView for the web component, or reimplement the header in native code. On macOS, use NSViewController size class tracking; on iOS, use traitCollectionDidChange to detect orientation changes. Manage drawer state with a property observer or Combine published property that responds to size changes.
- **WinUI 3**: Use a StackPanel with Orientation="Horizontal" for the header row. Responsive layout uses VisualStateManager with a custom breakpoint trigger (e.g., 62rem window width). Bind to Window.Activated to detect size changes via SizeChanged events. The drawer uses NavigationView or a custom UserControl with Popup for modal behavior. Icons for brand can use Symbols; action button uses Button with secondary styling.

## Design Decisions

1. **ScrollY behavior (not fixed)**: The header must scroll away to preserve the diagonal seam geometry in the layout, which is a core visual principle of flow pages. A fixed header would require constant opacity to render over ten different band backgrounds, defeating the seam composition.

2. **ResizeObserver instead of matchMedia in JavaScript**: Observing the wrapper element's bounding box rather than duplicating the 62rem breakpoint in JavaScript ensures the CSS media query is the single source of truth. This prevents maintenance divergence if the breakpoint is updated.

3. **NavChrome remounting via generation counter**: NavChrome owns its open state internally and provides no close API. When the drawer crosses from visible to hidden (narrow to wide viewport on `bar='nav'`), remounting is the only way to reset the drawer state and clear the Tab trap listener.

4. **No brand in drawer**: Rendering the brand twice (in the header and in the drawer's internal bar) creates visual redundancy and duplicate wordmarks. The drawer's bar should be minimal when the header already displays the brand.

5. **Real anchors, not CSS-hidden links**: Navigation links in the bar are real `<a>` elements, not hidden with `display: none`. This allows crawlers to discover all navigation destinations and assistive technology users to navigate via link rotor, not just the drawer.

6. **barLinks optional, defaults to links**: Hosts with few links that fit both the bar and drawer can omit `barLinks`, reusing the full `links` array. Hosts with many sections use `barLinks` to provide a curated subset for the bar while the drawer shows the full list.

## Compliance

Not applicable: SiteHeader is a layout component that delegates compliance concerns to child components (NavChrome, brand content, action content). The host application is responsible for ensuring accessibility of the provided content.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation from SiteHeader.tsx web source |
