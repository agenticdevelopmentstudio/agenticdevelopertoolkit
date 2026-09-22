---
id: 8c5e2f9b-7d3a-4a1c-b8e4-9f2d1c5a7b3e
title: Contact
domain: agenticdevelopertoolkit://recipes/contact
type: ingredient
version: 1.0.0
status: review
language: en
created: 2026-09-22
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A closing section component that composes a title, body content, mailto link,
  and optional colophon.
platforms:
- typescript
- web
tags:
- contact
- footer
- closing
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Contact

## Overview

The Contact component renders a page closing section that wraps a Closer component and adds a mailto link and optional colophon paragraph. It is used as the final element of a landing page, providing contact information and optional attribution or supplementary text.

## Behavioral Requirements

- **must-accept-title**: Component MUST accept a `title` prop of type `ReactNode`.
- **must-accept-children**: Component MUST accept a `children` prop of type `ReactNode`.
- **must-accept-mail**: Component MUST accept a `mail` prop with `href` (string) and `label` (ReactNode) properties.
- **must-render-mail-link**: Component MUST render an anchor element with `href` attribute matching `mail.href` and text content matching `mail.label`.
- **must-accept-optional-colophon**: Component MUST accept an optional `colophon` prop of type `ReactNode`.
- **should-render-colophon**: Component SHOULD render a paragraph element with colophon content when `colophon` is defined.
- **must-compose-closer**: Component MUST compose the `Closer` component rather than duplicating its markup, passing `title` and `children` through to `Closer`.
- **must-apply-css-classes**: Component MUST apply the class `lp-contact` to the composed `Closer` element, `lp-mail` to the mailto link, and `lp-colophon` to the optional colophon paragraph.

## Appearance

Styling is provided via external CSS rules (`.lp-contact`, `.lp-mail`, `.lp-colophon` selectors in `css/blocks.css`). The component renders semantic HTML elements without inline styles.

## States

| State | Appearance change |
|-------|------------------|
| Default | Standard link appearance from `.lp-mail` CSS class |
| Hover | Hover state defined by `.lp-mail:hover` CSS rule |
| Visited | Visited state defined by `.lp-mail:visited` CSS rule |
| Focus | Focus state defined by `.lp-mail:focus` CSS rule |
| Active | Active state defined by `.lp-mail:active` CSS rule |

## Accessibility

- **must-use-semantic-link**: The mailto link MUST be rendered as an `<a>` element with a valid `href` attribute (`mailto:...`).
- **must-provide-link-label**: The link MUST contain visible text (from `mail.label`) that describes the contact action.
- **should-support-keyboard**: The link SHOULD be keyboard-accessible via standard browser link navigation (Tab key, Enter to activate).

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| contact-001 | must-render-mail-link | `mail: { href: "mailto:test@example.com", label: "Email us" }` | Rendered `<a href="mailto:test@example.com">Email us</a>` element |
| contact-002 | must-apply-css-classes | Any valid props | Closer element has class `lp-contact`, link has class `lp-mail` |
| contact-003 | should-render-colophon | `colophon: "© 2026 Example"` | Rendered `<p class="lp-colophon">© 2026 Example</p>` |
| contact-004 | must-compose-closer | `title: "Get in Touch"`, `children: <p>We'd love to hear from you</p>` | Closer receives `title` and `children` props unchanged |
| contact-005 | should-render-colophon | `colophon: undefined` | No colophon paragraph rendered |

## Edge Cases

- **Null or empty mail.label**: If `mail.label` is an empty string or null, the link renders with no visible text. The anchor element still exists and is focusable; this may create an accessibility issue.
- **Invalid mail.href**: If `mail.href` is not a valid URL string (e.g., missing `mailto:` scheme), the link renders but may not function as expected when clicked. This is a source fidelity gap: validation is not performed.
- **Empty colophon**: If `colophon` is an empty string, the paragraph still renders (because the check is for `undefined`, not falsy values). An empty paragraph is rendered to the DOM.
- **Children prop omitted**: If `children` is not provided, React will pass `undefined` to the Closer component. Closer's handling of missing children determines the outcome; the Contact component does not validate.
- **Title prop omitted**: If `title` is not provided, React will pass `undefined` to Closer. Closer's handling of missing title determines the outcome.

## Configuration

Not applicable: This component accepts props (title, children, mail, colophon) but does not support configuration options or environment variables.

## Deep Linking

Not applicable: This is a component, not a page. It does not define URL patterns or deep linking behavior.

## Localization

Not applicable: The component accepts all text content as props (`title`, `children`, `mail.label`, `colophon`) and does not contain hardcoded user-facing strings. Localization is the responsibility of the calling code.

## Accessibility Options

Not applicable: This component does not respond to accessibility display options (e.g., Reduce Motion, Increase Contrast, Differentiate Without Color). Styling applied via CSS may respond to these options if defined in the style rules.

## Feature Flags

Not applicable: This component does not implement feature flag logic or conditional rendering based on feature flags.

## Analytics

Not applicable: This component does not emit analytics events. Event tracking is the responsibility of the calling code or click handlers added to the mail link.

## Privacy

Not applicable: This component does not collect, store, or transmit any data. The `mail.href` is user-provided and may contain a mailto URL; no PII handling occurs within the component.

## Logging

Not applicable: This component does not perform any logging.

## Platform Notes

- **Web (TypeScript/React)**: Implemented in `packages/web/packages/landing/src/blocks/Contact.tsx`. Accepts props for title, children, mail object (with href and label), and optional colophon. Renders as a composition of the `Closer` component with an injected `<a class="lp-mail">` link and conditional `<p class="lp-colophon">` paragraph. CSS classes `lp-contact`, `lp-mail`, and `lp-colophon` are applied for styling via external stylesheet.
- **SwiftUI**: Start from `VStack` to compose the closing section. Wrap the title and content in a container, render a `Link` control pointing to the mail URL (e.g., `mailto:` scheme), and conditionally include a `Text` view for the colophon. Apply custom styling via SwiftUI modifiers (padding, font, foregroundColor) or a dedicated style modifier.
- **Compose**: Start from a `Column` composable to stack vertical elements. Use `Text` for the title and content, render a `ClickableText` or custom `Hyperlink` composable for the mailto action, and conditionally include another `Text` for the colophon. Apply Material Design 3 typography and spacing via `MaterialTheme` and custom theme values.
- **AppKit / UIKit**: Start from `UIView` (iOS) or `NSView` (macOS) subclass or a container view controller. Compose a `UILabel` for the title, a `UITextView` or nested views for body content, a `UIButton` or custom link-styled button for the mail action (configured to open `mailto:` URL), and conditionally add a `UILabel` for the colophon. Apply styling via attributes or a style guide.
- **WinUI 3**: Start from a `StackPanel` with vertical orientation. Add a `TextBlock` for the title, content elements for the body, a `HyperlinkButton` with `NavigateUri` bound to the mail URL (or a `Button` with click handler launching the mail URL), and conditionally include a `TextBlock` for the colophon. Use `Thickness` for padding, `FontFamily` and `FontSize` properties for typography, and theme resources for colors via `{ThemeResource}` syntax.

## Design Decisions

The Contact component composes the `Closer` component rather than duplicating its markup. This ensures that both components share the same styling rules and behavioral semantics. The rendered element carries both `lp-closer` and `lp-contact` CSS classes; this compound selector (defined in `css/blocks.css` as `.lp-closer.lp-contact`) must remain a compound selector rather than being split into separate rules, as documented in the stylesheet comment. This dependency on the compound selector is a source fidelity requirement and MUST be observed in implementations.

## Compliance

Not applicable: This component does not implement security-sensitive operations, special compliance checks, or regulatory requirements.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
