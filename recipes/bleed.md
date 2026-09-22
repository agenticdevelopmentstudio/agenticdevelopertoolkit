---
id: feee183a-6488-489e-8e20-c7150bb3e914
title: Bleed
domain: agenticdevelopertoolkit://recipes/bleed
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Layout component that extends a child element past the content column toward
  one page edge, creating a visual crop effect.
platforms:
- typescript
- web
tags:
- layout
- positioning
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Bleed

## Overview

Bleed extends a child element past the content column boundary toward one page edge, creating the visual effect of the element being cropped by the viewport rather than sitting politely inside the measure. This produces a "window onto something larger" visual metaphor: a frame with air on both sides reads as a picture of an app, while a frame the page edge cuts reads as the app itself. The component uses margin (not transform) to achieve this, forcing the neighboring column to surrender space. It is only meaningful when used inside a container with `overflow-x: clip` to prevent the overhang from widening the document.

## Behavioral Requirements

- **must-render-div**: Component MUST render a single `div` element.
- **must-accept-children**: Component MUST render all content passed via the `children` prop into the `div`.
- **must-accept-side-prop**: Component MUST accept a `side` prop with string values `"left"` or `"right"`, defaulting to `"right"`.
- **must-apply-base-class**: Component MUST apply the class `lp-bleed` to the rendered `div`.
- **must-apply-side-class**: Component MUST apply a class `lp-bleed--{side}` to the rendered `div`, where `{side}` is the value of the `side` prop.
- **must-accept-className-prop**: Component MUST accept an optional `className` prop and append it to the rendered `div`.
- **must-filter-falsy-classes**: Component MUST not output empty strings or undefined values in the class list; falsy class names MUST be filtered before joining.

## Appearance

Not applicable: Bleed is a layout wrapper and does not define visual styling. All appearance comes from CSS classes applied to the rendered `div`. The component is responsible only for structure and class application.

## States

Not applicable: Bleed is a static layout component with no interactive states (pressed, focused, disabled, etc.). It does not respond to user input or change state based on application logic.

## Accessibility

Not applicable: Bleed is a transparent layout wrapper. It renders a generic `div` with no semantic role and does not create interactive elements. Accessibility properties (labels, roles, announcements) are determined by the content passed via `children` and do not apply to the Bleed wrapper itself.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| bleed-001 | must-render-div | `<Bleed>Content</Bleed>` | Renders a `div` element containing "Content" |
| bleed-002 | must-apply-base-class | `<Bleed>Content</Bleed>` | Rendered `div` has class `lp-bleed` |
| bleed-003 | must-apply-side-class, must-accept-side-prop | `<Bleed side="left">Content</Bleed>` | Rendered `div` has class `lp-bleed--left` |
| bleed-004 | must-apply-side-class, must-accept-side-prop | `<Bleed side="right">Content</Bleed>` | Rendered `div` has class `lp-bleed--right` |
| bleed-005 | must-accept-side-prop | `<Bleed>Content</Bleed>` (no side prop) | Rendered `div` has class `lp-bleed--right` (default) |
| bleed-006 | must-accept-className-prop | `<Bleed className="custom">Content</Bleed>` | Rendered `div` has classes `lp-bleed`, `lp-bleed--right`, `custom` |
| bleed-007 | must-filter-falsy-classes, must-accept-className-prop | `<Bleed className="">Content</Bleed>` | Rendered `div` has classes `lp-bleed`, `lp-bleed--right` (empty className excluded) |
| bleed-008 | must-accept-children | `<Bleed><span>Text</span><button>Click</button></Bleed>` | Rendered `div` contains both `span` and `button` elements |
| bleed-009 | must-accept-children | `<Bleed>null</Bleed>` | Renders successfully with `null` child |

## Edge Cases

- **Empty children**: Rendering `<Bleed />` with no children produces a rendered `div` with no content. Behavior is a MUST.
- **Null or undefined className**: When `className` is `undefined` or `null`, the component MUST not add empty class names to the output. Falsy values MUST be filtered before joining class strings.
- **Invalid side values**: The component source only handles `"left"` and `"right"` values. If an invalid value is passed, the component MUST render with a class name `lp-bleed--{value}` as passed (e.g., `lp-bleed--center`). Validation of the `side` prop is the responsibility of the caller, not the component. Behavior is a MUST.
- **Multiple class names in className prop**: When `className` contains multiple space-separated class names (e.g., `"custom-one custom-two"`), the component MUST append them as-is to the class list without modification. Behavior is a MUST.
- **React.Fragment as child**: Rendering `<Bleed><>Content</></Bleed>` is valid; the fragment is rendered as children inside the `div`.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `side` | `'left' \| 'right'` | `'right'` | Direction toward which to extend the child element past the content column |
| `children` | `ReactNode` | — | Required. Child content to render inside the bleed container |
| `className` | `string` | `undefined` | Optional. Additional CSS class names to apply to the rendered `div` |

## Deep Linking

Not applicable: Bleed is a layout component with no deep-linking behavior or URL state. It is a presentation wrapper, not a navigable destination.

## Localization

Not applicable: Bleed contains no text strings or localizable content. It is a layout wrapper that renders whatever content is passed via `children`.

## Accessibility Options

Not applicable: Bleed is a layout wrapper that does not respond to accessibility display options (e.g., Reduce Motion, Increase Contrast). Any accessibility options affecting the content are handled by the rendered children, not by Bleed itself.

## Feature Flags

Not applicable: The component source contains no feature flag logic or conditional rendering based on configuration flags.

## Analytics

Not applicable: The component source includes no event tracking, analytics collection, or telemetry instrumentation.

## Privacy

Not applicable: Bleed collects no data, stores no state, and transmits no information. It is a stateless layout component.

## Logging

Not applicable: The component source contains no logging or debug output.

## Platform Notes

- **Web (React/TypeScript)**: Source file is `Bleed.tsx` in the landing package. The component renders a `div` with class names joined from `['lp-bleed', `lp-bleed--${side}`, className]` after filtering falsy values. It accepts `side`, `children`, and `className` as props. The component relies on a parent container with `overflow-x: clip` (e.g., `.lp-band`) to prevent the overhang from widening the document.

- **SwiftUI**: On Apple platforms, implement a custom layout container (e.g., a `ZStack` or `GeometryReader` overlay) that positions the child view outside the standard content margin. Use `.offset()` or `.frame(alignment:)` to shift content toward one edge. Apply clipping to the parent container to crop the overhang, equivalent to the CSS `overflow-x: clip`. SwiftUI does not have a native "bleed" layout, so the positioning must be explicit.

- **Compose**: On Android, implement with a `Box` or custom `Layout` composable that positions the child outside the standard content padding. Use `offset()` or `absoluteOffset()` to shift the child toward one edge. Wrap the parent in a `Box(modifier = Modifier.clip(...))` to apply the crop effect. The `side` parameter maps to left or right offset direction.

- **AppKit / UIKit**: On macOS and iOS, implement a custom view (subclass of `NSView` or `UIView`) that applies negative margins or positioning transforms to move the child view outside the content area. Use `NSClipView` or `UIView.clipsToBounds` on the parent to crop the overhang. Layout should be managed via Auto Layout constraints or frame-based positioning, achieving the same visual effect as the web component.

- **WinUI 3**: On Windows, implement using a `Grid` or custom `Panel` with `Margin` adjustments on the child element to extend it past the content area. Set `Clip` on the parent container to `RectangleGeometry` or use `Clipping` to crop the overhang. The `side` parameter maps to positive or negative `Margin.Left` or `Margin.Right`. UWP `Grid.Column` and negative margins provide the equivalent mechanic.

## Design Decisions

- **Margin over transform**: The component uses CSS `margin` rather than CSS `transform` to extend the child element past the content column. This approach forces the neighboring column to surrender space, creating the intended visual hierarchy. A transform would move the element visually without affecting layout, leaving space in the neighboring column and defeating the "crop by viewport" effect.

- **Class filtering**: The component filters out falsy class names (empty strings, `null`, `undefined`) before joining them. This prevents unintended class concatenation (e.g., `"lp-bleed  lp-bleed--right"` with double spaces) and keeps the output clean.

- **No validation of side prop**: The component does not validate that `side` is one of the expected values (`'left'` or `'right'`). Passing an invalid value results in a class like `lp-bleed--invalid`, which is rendered as-is. This delegates validation to the caller and keeps the component simple.

- **Parent container responsibility**: The component assumes it is rendered inside a container with `overflow-x: clip` (e.g., `.lp-band` on the web). Without this clipping, the overhang will widen the document, defeating the visual intent. This constraint is documented in the Overview but not enforced by the component.

## Compliance

Not applicable: Bleed is a layout wrapper with no security, privacy, or compliance concerns. It does not handle sensitive data, authenticate users, or make external requests.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation |
