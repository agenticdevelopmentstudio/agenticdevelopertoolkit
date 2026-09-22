---
id: 0fe9833b-2a5c-47d5-a455-87e00d3797cf
title: DocLink
domain: agenticdevelopertoolkit://recipes/doc-link
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Injectable link component that renders an anchor element with customizable
  destination path.
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

# DocLink

## Overview

DocLink is a simple, injectable link component that wraps an HTML anchor element. It accepts a `to` prop for the destination path instead of the standard `href` attribute, allowing hosts to inject custom link behavior through a router adapter. This component serves as the default fallback for environments without a router (plain React apps, tests, Storybook stories), while router-aware applications (such as Next.js) can provide their own adapter via component injection.

## Behavioral Requirements

- **must-render-as-anchor**: The component MUST render as an HTML `<a>` element.
- **must-accept-to-prop**: The component MUST accept a `to` prop (string) specifying the destination path.
- **must-pass-to-href**: The component MUST pass the `to` prop value to the `href` attribute of the rendered anchor element.
- **must-accept-children**: The component MUST accept `children` (ReactNode) as the link text content.
- **must-render-children**: The component MUST render `children` inside the anchor element.
- **must-accept-and-spread-attributes**: The component MUST accept additional HTML anchor attributes (via `Omit<AnchorHTMLAttributes, "href">`) and pass them through to the rendered anchor element without modification.

## Appearance

- **Styling**: The component applies no visual styling; it renders an unstyled HTML anchor that inherits browser default link appearance (typically blue text with underline on hover).
- **Text rendering**: Link text from `children` is rendered as provided; the component does not transform, truncate, or modify content.

## States

Not applicable — the component is stateless and renders a passive link with no internal state management or interactive states beyond the browser's native anchor element behavior (source: no useState calls, no conditional rendering).

## Accessibility

- **Role**: The component renders a native HTML anchor element, which has an implicit link role in assistive technologies.
- **Label**: Link text from `children` serves as the accessible label; no additional `aria-label` is required for links with visible text.
- **Focus**: The anchor element receives keyboard focus by default in all browsers.
- **Keyboard navigation**: The link is keyboard-navigable via the Enter key following native anchor behavior (source: native `<a>` element).

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| doc-link-001 | must-render-as-anchor | `<DefaultDocLink to="/docs">Link</DefaultDocLink>` | Renders as `<a href="/docs">Link</a>` in the DOM |
| doc-link-002 | must-accept-to-prop, must-pass-to-href | `to="/about"` | `href` attribute equals `/about` |
| doc-link-003 | must-accept-children, must-render-children | `children="Home"` | Link text displays as "Home" inside the anchor |
| doc-link-004 | must-accept-children, must-render-children | Multiple child elements (text + JSX) | All children render inside the anchor element |
| doc-link-005 | must-accept-and-spread-attributes | `className="nav-link"` and `data-testid="home-link"` | Both attributes present on the rendered anchor element |
| doc-link-006 | must-accept-and-spread-attributes | `onClick={handler}` passed as a prop | Handler is called when the link is clicked |
| doc-link-007 | must-pass-to-href, must-render-children | `to="/docs"` and `children="Read Docs"` | Renders as `<a href="/docs">Read Docs</a>` |

## Edge Cases

- **Empty `to` prop**: If `to` is an empty string, the anchor renders with `href=""`, which navigates to the current page (browser default behavior).
- **Missing `to` prop**: The prop is required by the TypeScript interface; calling without it produces a type error. At runtime, if undefined is passed, `href="undefined"` is rendered, which is not a valid URL.
- **Null or undefined `children`**: If `children` is null or undefined, the anchor renders as an empty element (`<a href="/path"></a>`). The link remains focusable and keyboard-navigable but has no visible text.
- **No path validation**: The component does not validate the destination path; any value passed to `to` is rendered directly as `href`. Validation is the caller's responsibility.

## Configuration

Not applicable — the component accepts only React props (`to`, `children`, and HTML anchor attributes); no external configuration mechanism is available (source: functional component with prop-based parameters only).

## Deep Linking

Not applicable — this component is a rendering primitive for constructing links, not an app entry point; deep linking behavior is determined by the application's router implementation and how it handles the `to` value (source: component accepts any path without validation or routing logic).

## Localization

Not applicable — the component contains no hardcoded strings; all text content comes from the `children` prop, making localization the caller's responsibility (source: no string literals in the component body).

## Accessibility Options

Not applicable — this component responds only to browser-level accessibility features (high contrast mode, prefers-reduced-motion) through inherited CSS and the native anchor element; it defines no custom responses to accessibility display options (source: no accessibility-specific conditional logic).

## Feature Flags

Not applicable — the component has no conditional behavior or feature-gated code paths; it always renders the same way regardless of any flags (source: single unconditional render path).

## Analytics

Not applicable — this component does not emit tracking events; analytics is handled by the application's router or by click handlers passed via props (source: no analytics calls in the component).

## Privacy

Not applicable — this component does not collect, store, or transmit user data (source: no data handling).

## Logging

Not applicable — this component does not emit log messages (source: no logging calls).

## Platform Notes

- **SwiftUI**: Start from `Link` or `NavigationLink` wrapping a label. Differs: SwiftUI's declarative navigation model does not support the component-injection pattern; adapt using a protocol-based router abstraction instead.
- **Compose**: Start from `ClickableText` or `Text` composed with `Modifier.clickable()`. Differs: Compose requires imperative navigation handlers passed as callbacks rather than injected components.
- **React/Web**: `packages/web/packages/ui/src/blocks/doc-link.tsx` — wraps an HTML `<a>` element and accepts a `to` prop (not `href`) to enable router adapter injection at runtime (e.g., Next.js Link). Specific to web due to native anchor element and href semantics.
- **AppKit / UIKit**: Start from `NSButton` with `.link` button type (AppKit) or `UIButton` with `.linkStyle()` (UIKit). Differs: native link buttons require explicit target-action or closure handlers; implement the adapter pattern by passing navigation callbacks instead of injected components.
- **WinUI 3**: Start from `HyperlinkButton` XAML element with `NavigateUri` property binding the destination path. Differs: XAML's declarative navigation model does not support component injection; for custom routing, use a `Button` with a `Click` event handler and pass navigation logic through a callback.

## Design Decisions

- **Props naming**: Uses `to` instead of `href` to match the `DocLinkComponent` interface contract, enabling a consistent component signature across platforms and supporting router abstraction layers.
- **No internal validation**: The component trusts the caller to provide a valid destination path. URL validation and routing logic are the responsibility of the host application.
- **No styling**: The component applies no visual styling, delegating all appearance to CSS and browser defaults. This enables composition into different UI contexts (breadcrumbs, navigation trees, etc.) without tight coupling to a specific design system.
- **Props spreading**: The component spreads remaining props to the anchor element, allowing callers to apply arbitrary HTML attributes, event handlers, and styling without modifying the component.

## Compliance

Not applicable — this component is a low-level rendering primitive with no security, privacy, or regulatory surface beyond the underlying HTML anchor element (source: no data handling, no security-sensitive logic).

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
