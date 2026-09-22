---
id: e6c9f895-888f-4984-8fe1-ba86cc855613
title: Rich Content
domain: agenticdevelopertoolkit://recipes/rich-content
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Renders linked and embedded media content from structured data with built-in
  security filtering.
platforms:
- typescript
- web
tags:
- content-rendering
- media
- links
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Rich Content

## Overview

The Rich Content component renders a sequence of content items — hyperlinks and images — supplied as structured data. It is designed for displaying formatted responses from language models or other structured content sources where links and embedded media come from untrusted origins. The component applies protocol filtering to all hyperlinks to prevent prompt-injection attacks and lazy-loads images to avoid loading incomplete or malicious URLs.

## Behavioral Requirements

- **must-render-items-in-order**: The component MUST render content items in the order they appear in the input array.
- **must-filter-link-protocols**: The component MUST accept only hyperlinks with the following protocols: `http:`, `https:`, `mailto:`, `tel:`. Links with any other protocol (including `javascript:`, `data:`, `vbscript:`) MUST render as inert text, not as clickable links.
- **must-handle-malformed-urls**: The component MUST treat malformed or unparseable URLs as unsafe and render them as inert text, not as clickable links.
- **must-use-safe-link-text**: The component MUST display either the link's label or, if no label is provided, the URL itself as the visible text. Links MUST NOT render blank.
- **must-open-links-in-new-context**: The component MUST open all hyperlinks in a new tab or window (platform-appropriate) with cross-origin isolation (`noopener noreferrer` on web; platform equivalent on native).
- **must-lazy-load-images**: The component MUST not display images until they have successfully loaded. Images MUST remain hidden until the image load event fires or an error occurs.
- **must-handle-image-errors**: The component MUST handle image load errors gracefully. If an image fails to load, it MUST reveal the space to prevent layout shift and preserve page flow.
- **must-provide-image-alt-text**: The component MUST render alt text on images when provided. If no alt text is supplied, the component MUST use an empty string as the fallback.
- **should-skip-unknown-items**: The component SHOULD silently omit content items of unknown types. Unknown item types MUST NOT cause rendering errors or break the display of subsequent items.

## Appearance

- **Spacing**: No built-in padding or margins; layout is determined by container and parent context.
- **Link text decoration**: Links SHOULD be visually distinct (underlined or styled) to indicate interactivity; exact styling is platform-dependent.
- **Image display**: Images MUST scale to fit their container context. Platform-specific sizing constraints apply.
- **Background**: Transparent; no background color imposed.
- **Typography**: Inherits from parent context; no font size or weight imposed.

## States

| State | Appearance change |
|-------|------------------|
| Default (link) | Styled as a hyperlink; user can perceive it as interactive |
| Hovered (link) | Platform-specific hover styling (underline emphasis, color change) |
| Focused (link) | Platform-specific focus indicator (outline, highlight) |
| Active/Pressed (link) | Platform-specific pressed state |
| Image loading | Image hidden; space reserved or not displayed depending on CSS |
| Image loaded | Image displayed |
| Image error | Image space visible but no image rendered |

## Accessibility

- **Link role**: Each link MUST be rendered as an accessible `<a>` element (web) or platform-equivalent interactive control (native), allowing screen readers to identify it as a link.
- **Link label**: Links MUST have meaningful text content. If no label is provided, the URL itself MUST be announced; neither empty links nor URLs that are non-pronounceable (e.g., base64-encoded data URIs that would have been rendered) are acceptable.
- **Image alt text**: Images MUST be rendered with an `alt` attribute (web) or equivalent accessibility trait. If no alt text is provided, the alt text MUST be an empty string (decorative image) or a brief description of the image source.
- **Keyboard navigation**: Links MUST be reachable by keyboard (Tab key on web; platform equivalent on native) and MUST be activatable by standard keyboard controls (Enter on web; space/enter on native).
- **Focus indicator**: Links MUST have a visible focus indicator meeting platform accessibility standards (minimum 2px outline, high contrast, WCAG AA 3:1 minimum).
- **Minimum touch target**: On touch platforms, links MUST have a minimum touch target of 44×44pt (iOS) or 48×48dp (Android).

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| rich-content-001 | must-render-items-in-order | items = [{type: 'link', label: 'First', url: 'https://example.com'}, {type: 'link', label: 'Second', url: 'https://example.com'}] | Links render in order: "First" then "Second" |
| rich-content-002 | must-filter-link-protocols | items = [{type: 'link', label: 'Click', url: 'javascript:alert(1)'}] | No href is set; link renders as inert text "Click" |
| rich-content-003 | must-filter-link-protocols | items = [{type: 'link', label: 'Click', url: 'data:text/html,<script>alert(1)</script>'}] | No href is set; link renders as inert text "Click" |
| rich-content-004 | must-filter-link-protocols | items = [{type: 'link', label: 'Email', url: 'mailto:user@example.com'}] | Link has href="mailto:user@example.com"; user can click to open mail client |
| rich-content-005 | must-filter-link-protocols | items = [{type: 'link', label: 'Phone', url: 'tel:+1-555-1234'}] | Link has href="tel:+1-555-1234"; user can click to initiate call |
| rich-content-006 | must-handle-malformed-urls | items = [{type: 'link', label: 'Bad', url: 'ht!tp://invalid'}] | No href is set; link renders as inert text "Bad" |
| rich-content-007 | must-use-safe-link-text | items = [{type: 'link', label: 'Visit Site', url: 'https://example.com'}] | Link text displays as "Visit Site" |
| rich-content-008 | must-use-safe-link-text | items = [{type: 'link', url: 'https://example.com'}] | Link text displays as "https://example.com" |
| rich-content-009 | must-open-links-in-new-context | items = [{type: 'link', label: 'Link', url: 'https://example.com'}] | Link has target="_blank" with rel="noopener noreferrer" (web); native platforms open externally |
| rich-content-010 | must-lazy-load-images | items = [{type: 'image', src: 'https://example.com/image.png', alt: 'Photo'}] | Image element is created but hidden (display: none or visibility: hidden) until onLoad fires |
| rich-content-011 | must-lazy-load-images | items = [{type: 'image', src: 'https://example.com/image.png'}] | Image is shown once load event fires |
| rich-content-012 | must-handle-image-errors | items = [{type: 'image', src: 'https://broken-url.com/image.png'}] | Image space is revealed (display: block or equivalent) when onError fires, preventing layout shift |
| rich-content-013 | must-provide-image-alt-text | items = [{type: 'image', src: 'https://example.com/photo.png', alt: 'Portrait'}] | Image has alt="Portrait" |
| rich-content-014 | must-provide-image-alt-text | items = [{type: 'image', src: 'https://example.com/photo.png'}] | Image has alt="" (empty string, decorative) |
| rich-content-015 | should-skip-unknown-items | items = [{type: 'link', label: 'Link', url: 'https://example.com'}, {type: 'unknown'}, {type: 'link', label: 'Link2', url: 'https://example.com'}] | Two links render; unknown item is skipped silently |

## Edge Cases

- **Empty items array**: If the component receives an empty array, it MUST render nothing and not produce an error or console warning.
- **Relative URLs**: URLs without a scheme (e.g., `/page`, `../sibling`) MUST be treated as unsafe and rendered as inert text because their effective protocol cannot be determined by parsing alone.
- **Null or missing fields**: If a link item has no `url` field or a null URL, the component MUST treat it as unsafe and render the label (or empty text) as inert. If an image item has no `src` field, it MUST not render the image element.
- **Very long URLs**: Long URLs displayed as link text MUST not cause layout breaking; the component SHOULD allow normal text wrapping and overflow behavior.
- **Concurrent load/error events**: If an image fires both an onLoad and onError event in quick succession (e.g., due to network retry), the component MUST handle this gracefully without double-rendering or throwing.
- **XSS injection via alt text**: Alt text provided in image items is trusted from the structured data source (typically an LLM response); no additional escaping is required by the component beyond platform-standard attribute encoding.

## Configuration

Not applicable: This component has no configurable options. It is a stateless presentational component that renders an immutable array of content items.

## Deep Linking

Not applicable: This component renders multiple content items and does not represent a single navigable destination. Deep linking patterns depend on the individual links within the content and the hosting application's URL scheme.

## Localization

Not applicable: This component does not generate or display user-facing strings. Content (link labels, image alt text) comes from the data source (LLM or structured input) and is responsibility of that source to localize if needed.

## Accessibility Options

Not applicable: This component does not respond to platform accessibility display options such as Reduce Motion, Increase Contrast, or Differentiate Without Color. It renders text and images in their native form and respects the platform's native font rendering and link styling.

## Feature Flags

Not applicable: This component has no feature flags or conditional behavior based on application configuration.

## Analytics

Not applicable: This component does not emit events or track user interactions. Analytics for link clicks and image loads is the responsibility of the parent application or the links themselves (via target=_blank external navigation).

## Privacy

- **Data collected**: None. The component does not collect, log, or transmit any user data.
- **URL handling**: URLs provided in content items are not modified, validated against a server, or transmitted anywhere outside of the component's rendering context. The component does not make network requests beyond the browser's standard image loading for image items.

## Logging

Not applicable: This component does not emit log messages. Errors in URL parsing or image loading are handled silently per the requirements above.

## Platform Notes

- **Web (React)**: Render as a `<div>` container with `<a>` elements for links and `<img>` elements for images. Use the `safeHref()` function to validate link protocols against the allowlist before setting the href attribute. Gate images with `display: none` until the onLoad event fires, then remove the style to reveal. Handle onError by setting `display: block` or removing the style to reveal the space. Use `target="_blank" rel="noopener noreferrer"` on all links to prevent window opener attacks.
- **SwiftUI**: Use Text views for link labels inside NavigationLink containers; apply URL validation before constructing the NavigationLink. For mailto: and tel: links, use `Link(destination:)` to construct the appropriate system URL scheme (use URL(string:) with the validated scheme). Render images using AsyncImage with the validated image URL; phase-based rendering shows a placeholder or hides the container until the .success phase, then displays the image.
- **Compose**: Use Text composables for link labels inside clickable() modifiers; apply URL validation before constructing the Intent or system action. For email and phone links, use Intent.ACTION_SENDTO and Intent.ACTION_DIAL. Render images using Coil's AsyncImage or Glide with image loading state management; hide images by setting alpha = 0 or Modifier.size(0) until the image loads, then reveal.
- **AppKit / UIKit**: Use NSTextField (macOS) or UILabel (iOS) for link labels inside NSButton or UIButton containers; apply URL validation before setting the button's target action or URL property. For mailto: and tel: links, construct URLs using NSURL(string:) with the appropriate scheme and open via NSWorkspace or UIApplication.shared.open(). Render images using NSImageView (macOS) or UIImageView (iOS); initially set image = nil or isHidden = true, then load via URLSession or SDWebImage and update the view once the image data arrives.
- **WinUI 3**: Use HyperlinkButton for links with the NavigateUri property set to the validated URL; for mailto: and tel: schemes, use HyperlinkButton as well since Windows handles these schemes at the OS level. Render images using the Image control with Source set to a BitmapImage or WebViewImage; bind the image source to a viewmodel that handles loading and error states, initially setting the source to null and updating once the image completes loading. Use VisualStateManager to define a "Loading" state where the image is hidden and a "Loaded" state where it is visible.

## Design Decisions

**Protocol filtering**: Only http, https, mailto, and tel schemes are safe because they perform navigational actions or invoke system services. All other schemes (javascript, data, vbscript) can execute arbitrary code in the page's security context and are rejected unconditionally. This is a security requirement, not a feature choice.

**Lazy image loading**: Images are hidden until onLoad fires to prevent layout shift from unexpected image sizes and to avoid rendering incomplete or placeholder image data. On error, images are revealed to preserve layout flow and prevent the component from collapsing.

**Open in new context**: Links always open in a new tab/window to prevent the application context from being lost when the user navigates away. The use of `noopener noreferrer` prevents the linked page from accessing the opener's window object and referrer header.

**Fail-safe for unknown content types**: Unknown item types are silently skipped. This allows the component to handle schema evolution gracefully without crashing if new content types are introduced in the data source before the component is updated.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| [XSS prevention via URL filtering](agenticdevelopercookbook://compliance/security#xss-prevention) | passed | Security |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation |
