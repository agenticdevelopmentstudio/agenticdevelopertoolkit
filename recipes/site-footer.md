---
id: d80699f9-1020-4f8a-85ce-f6406e765631
title: Site Footer
domain: agenticdevelopertoolkit://recipes/site-footer
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A semantic footer landmark that wraps page footer content in a constrained
  layout column.
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

# Site Footer

## Overview

The Site Footer is a structural footer component that renders a semantic HTML `<footer>` landmark element containing page footer content. It applies a fixed CSS class and optional custom classes, and wraps its content in a layout column (Wrap) to constrain width and maintain consistency with other page sections. The component reserves space for the dock clearance like other band components and is positioned as the last element beneath the dock.

## Behavioral Requirements

- **must-render-footer-landmark**: Component MUST render an HTML `<footer>` element.
- **must-apply-lp-site-foot-class**: Component MUST apply the CSS class `lp-site-foot` to the footer element.
- **must-accept-children**: Component MUST accept and render ReactNode children.
- **must-wrap-children-in-layout-column**: Component MUST wrap children in a Wrap component to provide constrained layout.
- **may-accept-custom-class**: Component MAY accept an optional `className` prop to apply additional CSS classes.
- **must-merge-classes**: When a custom `className` is provided, component MUST apply both `lp-site-foot` and the custom class name to the footer element, separated by space, and MUST filter out falsy values.

## Appearance

- **Corner radius**: None
- **Padding**: Inherited from layout constraints (dock clearance reservation)
- **Font**: Inherited from descendants
- **Background**: Inherited from descendants (component applies no default background)
- **Foreground/Text**: Inherited from descendants
- **Border**: None applied by component
- **Shadow**: None applied by component
- **Min/Max size**: Full width; constrained content width via Wrap component

## States

Not applicable: component is stateless and does not render interactive or state-dependent content.

## Accessibility

- **Role**: Landmark (`<footer>` semantic element)
- **Label requirements**: No explicit ARIA labeling required; the semantic `<footer>` element identifies the landmark to assistive technologies
- **Keyboard navigation**: Not applicable; component is not interactive
- **Touch target size**: Not applicable; component is a container, not an interactive control

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| site-footer-001 | must-render-footer-landmark | Render component with no props | Output contains `<footer>` element |
| site-footer-002 | must-apply-lp-site-foot-class | Render component with no props | Footer element has `class` attribute containing `lp-site-foot` |
| site-footer-003 | must-accept-children | Render with `children="Footer content"` | Footer element contains text "Footer content" |
| site-footer-004 | must-wrap-children-in-layout-column | Render with children | Children are wrapped by Wrap component (verify Wrap component presence in DOM) |
| site-footer-005 | may-accept-custom-class | Render with `className="custom-footer"` | Footer element class attribute contains both `lp-site-foot` and `custom-footer` |
| site-footer-006 | must-merge-classes | Render with `className="custom-footer"` | Class string is `lp-site-foot custom-footer` (no duplicate or falsy values) |
| site-footer-007 | must-merge-classes | Render with `className={undefined}` | Footer element class is exactly `lp-site-foot` (undefined falsy value filtered out) |

## Edge Cases

- **Empty children**: Component MUST render a valid `<footer>` element even when children are empty or null
- **Null className**: When `className` prop is `undefined` or not provided, component MUST apply only `lp-site-foot` class; filtering out the undefined value is required
- **Whitespace-only className**: If `className` is an empty string or whitespace, filtering MUST remove it from the class list

## Configuration

Not applicable: component accepts only React props `children` and optional `className`; no configuration options exist.

## Deep Linking

Not applicable: component is a layout container and does not handle routing or deep link resolution.

## Localization

Not applicable: component renders no user-facing text; all content is provided by children.

## Accessibility Options

Not applicable: component has no interactive states or visual styling that would respond to accessibility display options such as Reduce Motion, Increase Contrast, or Differentiate Without Color.

## Feature Flags

Not applicable: component has no conditional rendering or feature-gated behavior.

## Analytics

Not applicable: component is non-interactive and does not emit user interaction events.

## Privacy

Not applicable: component does not collect, store, or transmit any data.

## Logging

Not applicable: component has no internal operations, async behavior, or error states that would require logging.

## Platform Notes

- **Source (TypeScript/React)**: Implemented in `packages/web/packages/landing/src/flow/SiteFooter.tsx`. Accepts `children` (ReactNode, required) and `className` (string, optional). Returns JSX rendering an HTML `<footer>` element with merged class names and Wrap-wrapped children. The `lp-site-foot` class is the fixed style hook; custom classes are composed via string join filtering falsy values.

- **SwiftUI**: On Apple platforms, implement a footer as a View that conforms to the standard layout rhythm. Use a `VStack` or equivalent container, apply a footer-specific modifier (e.g., `.modifier(SiteFooterStyle())`) to constrain width and apply dock clearance, and use View composition to accept arbitrary content. The semantic equivalent is a View marked with the `.footer` trait or a dedicated footer-layout builder.

- **Compose**: On Android, implement a footer as a Composable that uses `Box` or `Column` with `Modifier.fillMaxWidth()` to span the full width and internal padding to reserve dock clearance. Apply a style via `Modifier` composition (theming, colors, spacing). The content parameter accepts a `@Composable` lambda to render arbitrary children with constrained layout.

- **AppKit / UIKit**: On macOS and iOS, implement a footer as a UIView (iOS) or NSView (macOS) subclass or a SwiftUI wrapper. Add an internal NSStackView or UIStackView to constrain content width and apply edge insets for dock clearance. Use Auto Layout constraints to pin the footer to the safe area bottom and reserve space. The footer container should accept a `UIView` or hosting controller for arbitrary child content.

- **WinUI 3**: On Windows, implement a footer as a `StackPanel` with `Orientation="Vertical"` and `HorizontalAlignment="Stretch"` to span full width. Wrap content in a `Grid` or nested `StackPanel` with a fixed or max width column to constrain layout. Apply a `CornerRadius` resource or `BorderThickness` if a visual treatment is needed. Attach the footer to the bottom of the main window chrome using a `Grid` row assignment or a `DockPanel.Dock="Bottom"` arrangement to reserve dock clearance.

## Design Decisions

The component is purely structural and presentational. It delegates all visual styling to the `lp-site-foot` CSS class and to the Wrap component, which handles layout constraints and dock clearance. The optional `className` prop allows host applications to compose additional styling without modifying the component's core contract. Falsy value filtering in class composition ensures the class string is clean and valid regardless of whether a custom class is provided.

## Compliance

Not applicable: component is a simple layout container with no security, data handling, or complex interaction concerns.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation from source |
