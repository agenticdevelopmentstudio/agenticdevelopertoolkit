---
id: 53a37583-e86d-41ca-8dd2-8394ba530091
title: Shot
domain: agenticdevelopercookbook://ingredients/shot
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A macOS window frame wrapper that displays screenshots, clips, or a visually
  distinct placeholder.
platforms:
- typescript
- web
tags:
- layout
- screenshot
- frame
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Shot

## Overview

Shot renders a macOS window frame around visual content—screenshots, video clips, or images. When media is not provided, it displays an obviously unfinished placeholder with optional status text and a caption, designed to prevent accidental shipment of unfinished frames. The component applies no transformation to the media; it renders exactly what the host provides.

## Behavioral Requirements

- **must-render-frame**: Component MUST render a macOS window frame with a title bar containing three traffic light dots and a window title.
- **must-render-title-in-bar**: Component MUST display the `title` prop text in the frame's title bar.
- **must-render-media-as-given**: When `media` is provided, component MUST render it exactly as passed with no transformation, processing, or motion handling.
- **must-render-placeholder-when-no-media**: When `media` prop is absent, component MUST render an obviously unfinished placeholder frame.
- **must-render-caption-in-placeholder**: Component MUST render the `caption` prop as text content in the placeholder.
- **must-render-pending-label-optionally**: When `pendingLabel` prop is provided, component MUST render it above the caption in the placeholder; when omitted, placeholder displays only caption.
- **must-render-pending-label-as-given**: Component MUST render `pendingLabel` exactly as passed without transformation.

## Appearance

- **Frame background**: Dark (matches macOS window chrome)
- **Title bar**: Horizontal bar at top with three colored dots (traffic lights) on left, title text on right
- **Dots**: Three small circles—red, yellow, green—positioned at top-left of title bar
- **Title text**: Centered or right-aligned in title bar
- **Placeholder**: Visually distinct cross-hatched or textured background to signal incompleteness
- **Placeholder text**: Caption rendered in bold within placeholder
- **Pending label**: Optional status text above caption in smaller font weight

## States

Not applicable: Shot is a presentational container with no interactive states. It does not respond to user input, maintain focus, or occupy pressed, disabled, or focused states.

## Accessibility

- **Role**: Structural container; no interactive role required
- **Label**: The `title` prop semantically labels the framed content
- **Alt text**: Host is responsible for adding alt text to any `<img>` or `<video>` elements passed via the `media` prop; Shot renders media without modification
- **Placeholder accessibility**: When placeholder is rendered (media absent), it is visually obvious and does not mislead assistive technology users; caption text provides semantic information
- **Touch target**: Not applicable; Shot contains no interactive elements

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| shot-001 | must-render-frame | title="My App" | Renders macOS window frame with title bar and three dots |
| shot-002 | must-render-title-in-bar | title="MyWindow" | "MyWindow" appears in the title bar |
| shot-003 | must-render-media-as-given | media={<img src="x.png" />} | Renders the `<img>` element exactly; no CSS applied, no wrapping |
| shot-004 | must-render-placeholder-when-no-media | media undefined | Placeholder frame displays with hatching or texture |
| shot-005 | must-render-caption-in-placeholder | caption="Screenshot pending" | Placeholder contains bold text "Screenshot pending" |
| shot-006 | must-render-pending-label-optionally | pendingLabel="Capture in progress" | Pending label appears above caption in placeholder |
| shot-007 | must-render-pending-label-optionally | pendingLabel undefined | Placeholder displays only caption, no status line |
| shot-008 | must-render-pending-label-as-given | pendingLabel={<span className="custom">Loading</span>} | Renders the `<span>` with its class unmodified |

## Edge Cases

- **Media is null/undefined**: Placeholder renders; this is the design's primary state until a capture exists.
- **Caption is empty string**: Placeholder still renders with empty caption area.
- **PendingLabel is empty string or falsy**: Treated as absent; placeholder shows only caption (equivalent to undefined).
- **Title is empty string**: Renders with empty title bar; frame still displays.
- **Media is a complex nested component tree**: Rendered as-is without interaction or state management by Shot.
- **Media is a video element without preload/autoplay attributes**: Shot does not apply Reduce Motion behavior; host or a wrapper component (e.g., Clip from the same package) must handle motion preferences.

## Configuration

Not applicable: Shot accepts only props and has no configuration options, feature flags, or environment variables.

## Deep Linking

Not applicable: Shot is a presentational layout component without navigation or routing responsibilities.

## Localization

Not applicable: Shot renders only props provided by the host. All text (title, caption, pendingLabel) originates from the host and is the host's responsibility to localize.

## Accessibility Options

Not applicable: Shot is static and contains no interactive controls or responsive text scaling.

## Feature Flags

Not applicable: Shot has no conditional behavior or feature flags.

## Analytics

Not applicable: Shot is a presentational container with no user interaction and generates no events.

## Privacy

Not applicable: Shot does not collect, store, or transmit data.

## Logging

Not applicable: Shot performs no operations requiring diagnostic logging.

## Platform Notes

- **TypeScript/Web**: Component defined in `packages/web/packages/landing/src/blocks/Shot.tsx`. Renders a `<div>` with class `.lp-shot` containing a title bar (`.lp-shot__bar`) with three dots (`.lp-shot__dot`) and title text (`.lp-shot__name`). Placeholder is a `.lp-shot__placeholder` div. Media is rendered as a sibling div or directly as the child. Styles are external CSS; Shot applies no inline styles. For autoplaying video or motion-sensitive content, host should use the `Clip` component (from `@agenticdevelopertoolkit/landing/client`) or the `usePrefersReducedMotion` hook to respect `prefers-reduced-motion`.
- **SwiftUI**: Use a `VStack` or `ZStack` wrapping a custom overlay view that draws the macOS window chrome (title bar with traffic light dots, title text). Place the content view (or a placeholder image with hatching pattern) in the main body. Bind the optional `media` property to conditional rendering of content vs. placeholder. Title and caption are `String` properties; optional label is a generic `View`. Apply system fonts and colors for macOS chrome appearance.
- **Compose**: Build with `Column` or `Box` containing a header composable that renders the title bar (horizontal row of three colored `Surface` circles and `Text` for the title) and a content area. Placeholder is a `Box` with a `Pattern` drawable or `Modifier.background(SurfacePattern)`. Media is a nullable slot. Caption and pendingLabel are optional `@Composable` parameters. Use Material 3 color tokens for macOS-like chrome (dark surface, text on surface).
- **AppKit / UIKit**: On macOS, wrap the content in a custom `NSView` that draws the window chrome (frame border, title bar with traffic lights, title text) using `NSBezierPath` and `CAShapeLayer`. On iOS, Shot would be less applicable (iOS does not feature window frames), but if adapted, use a rounded `UIView` or `SwiftUI.Image` of a window mockup as the outer frame. Placeholder is a `UIView` with a pattern or cross-hatched texture (Core Graphics or a pattern image). Media is a `UIView` or `UIImage` placeholder.
- **WinUI 3**: Implement using a `Grid` with two rows: title bar (top) and content area (bottom). Title bar is a `StackPanel` with three `Ellipse` shapes (red, yellow, green; colors from `Application.Current.Resources` or hardcoded system chrome colors) and a `TextBlock` for the title. Content area uses a `ContentControl` or `Grid` to switch between placeholder (a `Rectangle` with a pattern brush—cross-hatch or texture—and overlay `TextBlock` for caption and pendingLabel) and media. Set `Background="{StaticResource SystemChromeLow}"` or a dark brush for the title bar to match Windows system chrome aesthetic. Use conditional binding or `VisualStateManager` to toggle placeholder vs. media state.

## Design Decisions

- **No media processing**: Shot renders media exactly as passed because the host (landing or feature page) owns the content strategy. The host is responsible for optimizing images, deferring video load, and handling accessibility. Shot's responsibility is framing, not transformation.
- **Placeholder is mandatory visual state**: The placeholder is not optional; when media is absent, an obviously unfinished frame (hatching, cross-hatch, or texture) must be rendered to prevent accidental shipping of incomplete captures. This design principle is documented in the source JSDoc.
- **Motion not handled by Shot**: For autoplaying video or clips that respect `prefers-reduced-motion`, Shot delegates to a wrapper component (Clip) or the host to apply the `usePrefersReducedMotion` hook. This separation of concerns allows Shot to remain simple while supporting motion-aware hosts.

## Compliance

Not applicable: Shot contains no interactive controls, network requests, or security-sensitive operations that would require compliance checks.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation from Shot.tsx source |
