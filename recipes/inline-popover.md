---
id: a7e2f9d1-4c8a-4b9e-8f3d-2c5b7e1a9d4f
title: "Inline Popover"
domain: agenticdevelopertoolkit://recipes/inline-popover
type: ingredient
version: 1.0.0
status: review
language: en
created: 2026-09-22
modified: 2026-09-22
author: Claude Haiku 4.5
copyright: 2026 Mike Fullerton
license: MIT
summary: "Collapsible disclosure component that toggles visibility of supplemental content with title, description, and optional links."
platforms:
- typescript
- web
tags:
  - disclosure
  - popover
  - collapsible
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Inline Popover

## Overview

The Inline Popover is a collapsible disclosure control that manages the visibility of supplemental content. It renders a toggle button with an optional arrow indicator and title, followed by a body section containing optional description text and a collection of links. The component maintains open/closed state internally and allows users to toggle visibility by clicking the toggle button.

## Behavioral Requirements

- **must-render-toggle-button**: Component MUST render a clickable button element with aria-label="Toggle details".
- **must-toggle-visibility-on-click**: Component MUST toggle the open state when the toggle button is clicked.
- **must-initialize-with-default-open**: Component MUST initialize with the open state set to the value of the `defaultOpen` prop, which defaults to `true`.
- **must-render-title-when-provided**: Component MUST render the title text from `data.title` only if the property is truthy.
- **must-render-arrow-indicator**: Component MUST render an arrow span element as a visual indicator within the toggle button.
- **must-render-description-when-provided**: Component MUST render the description from `data.description` only if the property is truthy.
- **must-render-links-collection**: Component MUST render the links collection from `data.links` only if the property is truthy and has length greater than 0.
- **must-render-each-link-with-label**: Component MUST render each link with either its `label` property or fall back to its `url` property as the displayed text.
- **must-open-links-in-new-tab**: Component MUST open links in a new browser tab by setting `target="_blank"` and `rel="noopener noreferrer"` on each link element.
- **must-set-aria-hidden-attribute**: Component MUST set `aria-hidden="true"` on the root element when open state is `false` and `aria-hidden="false"` when open state is `true`.
- **must-add-open-class-when-open**: Component MUST add the CSS class `pc-popover-open` to the root element when the open state is `true`.

## Appearance

- **Root container**: Rendered as a `div` with class `pc-popover`, conditionally includes `pc-popover-open` class
- **Toggle button**: Rendered as a `button` element with class `pc-popover-toggle`
- **Arrow indicator**: Rendered as a `span` element with class `pc-popover-arrow`
- **Title**: Rendered as a `span` element with class `pc-popover-title`, optional
- **Body container**: Rendered as a `div` element with class `pc-popover-body`
- **Description**: Rendered as a `div` element with class `pc-popover-desc`, optional
- **Links container**: Rendered as a `div` element with class `pc-popover-links`, optional
- **Individual link**: Rendered as an `a` element with class `pc-popover-link`

All visual styling (colors, spacing, sizing, shadows, hover states, transitions) is controlled via CSS classes. The component itself does not define appearance values.

## States

| State | Appearance change | Trigger |
|-------|------------------|---------|
| Open | `pc-popover-open` class added, `aria-hidden="false"` | User clicks toggle button or `defaultOpen` is `true` |
| Closed | `pc-popover-open` class removed, `aria-hidden="true"` | User clicks toggle button or `defaultOpen` is `false` |

## Accessibility

- **Toggle button role**: The toggle button element is a native `button`, which provides standard keyboard and screen reader semantics.
- **Toggle button label**: The toggle button MUST have `aria-label="Toggle details"` to communicate its purpose to assistive technology.
- **Root visibility**: The root element MUST use `aria-hidden` to communicate to screen readers whether the popover content is visible. When `aria-hidden="true"`, the content is hidden from assistive technology; when `aria-hidden="false"`, it is exposed.
- **Link text**: Each link element's text content is provided by the `label` property or falls back to the `url`, ensuring all interactive elements have accessible text.
- **Minimum touch target**: Ensure the toggle button meets platform-specific minimum touch target size requirements (44×44pt on iOS, 48×48dp on Android, 44×44px on web).

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| inline-popover-001 | must-initialize-with-default-open | `defaultOpen={true}` | Component renders with `pc-popover-open` class on root and `aria-hidden="false"` |
| inline-popover-002 | must-initialize-with-default-open | `defaultOpen={false}` | Component renders without `pc-popover-open` class and `aria-hidden="true"` |
| inline-popover-003 | must-toggle-visibility-on-click | User clicks toggle button when open | Component renders with `aria-hidden="true"` and `pc-popover-open` class removed |
| inline-popover-004 | must-toggle-visibility-on-click | User clicks toggle button when closed | Component renders with `aria-hidden="false"` and `pc-popover-open` class added |
| inline-popover-005 | must-render-title-when-provided | `data={{ title: "Test Title" }}` | Title text appears in a `span` with class `pc-popover-title` |
| inline-popover-006 | must-render-title-when-provided | `data={{ title: "" }}` or `data={{ }}` | No title element is rendered |
| inline-popover-007 | must-render-description-when-provided | `data={{ description: "Test Description" }}` | Description text appears in a `div` with class `pc-popover-desc` |
| inline-popover-008 | must-render-description-when-provided | `data={{ description: null }}` or `data={{ }}` | No description element is rendered |
| inline-popover-009 | must-render-links-collection | `data={{ links: [{ url: "https://example.com", label: "Example" }] }}` | Links container div is rendered with class `pc-popover-links` containing one link element |
| inline-popover-010 | must-render-links-collection | `data={{ links: [] }}` or `data={{ links: null }}` or `data={{ }}` | No links container is rendered |
| inline-popover-011 | must-render-each-link-with-label | `data={{ links: [{ url: "https://example.com", label: "Click here" }] }}` | Link element displays text "Click here" |
| inline-popover-012 | must-render-each-link-with-label | `data={{ links: [{ url: "https://example.com" }] }}` | Link element displays text "https://example.com" as fallback |
| inline-popover-013 | must-open-links-in-new-tab | `data={{ links: [{ url: "https://example.com" }] }}` | Link element has `target="_blank"` and `rel="noopener noreferrer"` attributes |
| inline-popover-014 | must-render-arrow-indicator | Any valid data | Arrow span element with class `pc-popover-arrow` is always present in toggle button |
| inline-popover-015 | must-set-aria-hidden-attribute | `defaultOpen={true}` | Root element has `aria-hidden="false"` |
| inline-popover-016 | must-set-aria-hidden-attribute | `defaultOpen={false}` | Root element has `aria-hidden="true"` |

## Edge Cases

- **Empty data object**: When `data` is passed as an empty object `{}`, no title, description, or links are rendered. The component still renders the toggle button and body container. Expected behavior: component renders with button and empty body.
- **Null or undefined data properties**: When `data.title`, `data.description`, or `data.links` are null, undefined, or empty string, those content sections are not rendered. Expected behavior: component skips rendering that section.
- **Empty links array**: When `data.links` is an empty array `[]`, the links container div is not rendered. Expected behavior: component does not render the links section.
- **Multiple rapid toggles**: When a user clicks the toggle button multiple times in rapid succession, each click toggles the state immediately. Expected behavior: state always reflects the most recent click.
- **Link with missing label**: When a link in `data.links` has no `label` property, the component falls back to displaying the `url` as the link text. Expected behavior: link is always clickable and has visible text.
- **defaultOpen not specified**: When the `defaultOpen` prop is not provided, the component defaults to `true` and renders in the open state. Expected behavior: component opens by default.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `data` | `PopoverData` | required | Object containing `title`, `description`, and `links` properties |
| `data.title` | `string \| undefined` | undefined | Optional title text displayed in the toggle button |
| `data.description` | `string \| undefined` | undefined | Optional description text displayed in the popover body |
| `data.links` | `Array<{ url: string; label?: string }> \| undefined` | undefined | Optional array of link objects with required `url` and optional `label` |
| `defaultOpen` | `boolean` | `true` | Initial open/closed state of the popover |

## Deep Linking

Not applicable: This component is a presentation element with no deep linking semantics. Deep linking behavior, if needed, is the responsibility of the containing application.

## Localization

Not applicable: The component displays content from the `data` prop, which is provided by the caller. Localization of title, description, and link labels is the responsibility of the data provider.

## Accessibility Options

- **Reduce Motion**: Not implemented in source. Component does not check for `prefers-reduced-motion` and applies no motion-specific behavior changes.
- **Increase Contrast**: Not implemented in source. Contrast is controlled entirely by CSS classes and must be configured at the style layer.
- **Differentiate Without Color**: Not implemented in source. The component relies on CSS styling to differentiate states; if color alone is used, the caller must add shape or text indicators via CSS.

## Feature Flags

Not applicable: Component has no feature flags in source code.

## Analytics

Not applicable: Component does not emit analytics events. Tracking of toggle interaction or link clicks is the responsibility of the containing application.

## Privacy

Not applicable: Component does not collect, store, or transmit any user data. All content is passed via props and displayed directly.

## Logging

Not applicable: Component does not perform logging.

## Platform Notes

- **React/Web**: The source is `packages/web/packages/chat/src/components/InlinePopover.tsx`. State is managed with React's `useState` hook. CSS classes drive appearance, including `pc-popover`, `pc-popover-open`, `pc-popover-toggle`, `pc-popover-arrow`, `pc-popover-title`, `pc-popover-body`, `pc-popover-desc`, `pc-popover-links`, and `pc-popover-link`. Styling is not included in the component; callers must provide matching CSS.
- **SwiftUI**: On iOS, use a disclosure group with a toggle button and a conditional view. Bind the toggle state to a `@State` variable. Place the arrow indicator, title, and optional content inside the disclosure group's label and content closures. Use a NavigationLink or environment-managed state for the links, opening them in a separate view or system browser.
- **Compose**: On Android, use a Column with a Row for the toggle button (a Button with an icon for the arrow). Use a mutableStateOf for the open state. Conditionally render the AnimatedVisibility or if-else branch for the body content. Render links as clickable Text or Button elements that invoke Intent or deep link navigation.
- **AppKit / UIKit**: On macOS and iOS (AppKit), use an NSDisclosureTriangle or NSButton for the toggle. Use an NSStackView or Container view for layout. Manage state with property observers or binding patterns. On UIKit, construct a UIButton with a custom image for the arrow, use a UIStackView for layout, and manage state with a property.
- **WinUI 3**: On Windows, build the component using a Grid for layout. Use a Button for the toggle with a SymbolIcon for the arrow (chevron-down icon from the Fluent icons). Bind the visibility of the body content to a boolean property using a Visibility converter or conditional rendering. Use Hyperlink elements from WinUI for the link collection, setting the NavigateUri property. Add VisualStateManager states for the open and closed appearances, updating background color and the chevron rotation.

## Design Decisions

- **State management with defaultOpen**: The component accepts `defaultOpen` to allow the caller to control the initial state. This supports both controlled and uncontrolled patterns. The default of `true` matches a common UX pattern where disclosure content is visible by default, reducing the need for users to discover the toggle.
- **Aria-hidden attribute**: The popover content is marked `aria-hidden` when closed to prevent screen readers from reading hidden content. This is more user-friendly than relying on CSS `display: none` alone.
- **Links always open in new tab**: Links are always opened with `target="_blank"` and `rel="noopener noreferrer"`. This prevents navigation away from the containing page and prevents the opened page from accessing the `window.opener` property for security reasons. Callers who need different link behavior (same-tab navigation, new window) should handle link clicks at a higher level or wrap the component.
- **Conditional rendering of optional content**: Title, description, and links are only rendered if their data is truthy. This reduces DOM clutter and improves performance when content is not provided.
- **CSS-driven appearance**: The component uses CSS classes (`pc-popover`, `pc-popover-open`, etc.) rather than inline styles. This allows complete separation of presentation logic and gives callers full control over appearance.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| wcag-aria-attribute-usage | passed | Accessibility |
| wcag-keyboard-accessible-button | passed | Accessibility |
| security-link-new-tab-attributes | passed | Security |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation |
