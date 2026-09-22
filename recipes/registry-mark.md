---
id: f8e3d2a1-4c9b-4d7e-8f2b-a5c3e7b1d4f6
title: Registry Mark
domain: agenticdevelopercookbook://ingredients/registry-mark
type: ingredient
version: 1.0.0
status: review
language: en
created: 2026-09-22
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Credential mark linking a persona to its registry profile, displayed as a
  @ symbol with AI star accent.
platforms:
- web
tags:
- persona
- registry
- credential
depends-on: []
related: []
references: []
---

# Registry Mark

## Overview

The Registry Mark is a visual credential indicator linking a persona chat to its profile on the Agentic Persona Registry. Rendered as a @ symbol with an AI star embedded in its counter, positioned at the top-right corner of a persona chat frame, straddling the frame boundary. The mark tints with inherited color (registry house color or persona hue) and uses ADH gold for the star accent. Optional popover content (e.g., persona bio, link to full profile) displays on hover and focus.

## Behavioral Requirements

- **must-render-link**: Component MUST render as a hyperlink (`<a>`) to the persona's `profileUrl` with `target="_blank"` and `rel="noopener noreferrer"`.
- **must-have-accessible-name**: Component MUST include an `aria-label` prop that is set to the provided `label` string.
- **must-render-at-glyph**: Component MUST render an @ symbol using the JetBrains Mono glyph (weight 400), embedded as SVG path data.
- **must-render-star**: Component MUST render a four-pointed AI star positioned inside the @ counter, filled with hex `#c4a35a`.
- **must-tint-glyph-with-currentcolor**: Component MUST apply `fill="currentColor"` to the @ glyph, allowing ancestor elements to tint the mark via CSS `color` property.
- **must-preserve-anchor-geometry**: Component MUST position the @ glyph so its center anchor point aligns with the host's top-right corner (50% X, -50% Y offset via CSS variables).
- **must-render-optional-popover**: Component MUST conditionally render a popover span when `tip` prop is provided; omit the span when `tip` is undefined.
- **must-hide-svg-from-accessibility-tree**: Component MUST set `aria-hidden="true"` on the SVG element.
- **must-support-classname**: Component MUST accept and apply an optional `className` prop, merging it with the required internal class `pc-registry-mark`.
- **must-memoize-rendering**: Component MUST use React `memo()` to prevent re-renders when props remain unchanged, minimizing re-renders during parent token streaming.

## Appearance

- **Size**: SVG viewBox is 5, 1, 14, 22 (width 14 units, height 22 units). Rendered size is determined by ancestor CSS (e.g., 48×88px for standard density).
- **Glyph**: JetBrains Mono @ (weight 400), embedded as precise SVG path, no live font dependency.
- **Star**: Four-pointed concave star (N/E/S/W points, independent x/y radii rx=4.0, ry=6.6, centered at 14.1, 12.2).
- **Glyph fill**: `currentColor` (inherits tint from ancestor).
- **Star fill**: `#c4a35a` (ADH gold, hex literal, not a theme token).
- **Positioning anchor**: Center point of @ glyph is (12, 12) in viewBox; CSS custom props `--pc-rm-anchor-x: 50%` and `--pc-rm-anchor-y: -50%` place this anchor at host's top-right corner.
- **Popover offset**: Popover (when rendered) displays above the mark, positioned via CSS (not inline).

## States

| State | Appearance change |
|-------|------------------|
| Default | @ glyph and star both visible, normal opacity |
| Hover (link) | Determined by ancestor CSS (no local style applied by component) |
| Focus (link) | Determined by ancestor CSS (no local style applied by component) |
| Focus with popover open | Popover span is visible and keyboard-reachable |

## Accessibility

- **Role**: The underlying `<a>` element provides the link role (implicit).
- **Label**: Required `label` prop is set as `aria-label` on the link, providing an accessible name (e.g., "Visit X's profile on the registry").
- **SVG accessibility**: SVG has `aria-hidden="true"` to remove it from the accessibility tree; the link's accessible name suffices.
- **Keyboard navigation**: Link is keyboard-reachable; focus is managed by the browser.
- **Popover keyboard access**: When `tip` content is provided, it contains interactive elements (links); focus management is delegated to the popover's internal implementation (component does not manage focus).
- **Minimum touch target**: Parent container should ensure the link is at least 44×44pt (this is a constraint on the host layout, not enforced by the component).

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| registry-mark-001 | must-render-link | `profileUrl="https://registry.example.com/user/alice"` | Link href is `https://registry.example.com/user/alice`, target is `_blank`, rel includes `noopener noreferrer` |
| registry-mark-002 | must-have-accessible-name | `label="Visit Alice's profile"` | Link has `aria-label="Visit Alice's profile"` |
| registry-mark-003 | must-render-at-glyph | Default render | SVG path with d matching AT_GLYPH constant is present in DOM |
| registry-mark-004 | must-render-star | Default render | SVG path with d matching STAR constant is present, filled with `#c4a35a` |
| registry-mark-005 | must-tint-glyph-with-currentcolor | Ancestor has `style="color: #ff0000"` | @ glyph path has `fill="currentColor"`, renders red |
| registry-mark-006 | must-preserve-anchor-geometry | Default render | MARK_STYLE has `--pc-rm-anchor-x: 50%` and `--pc-rm-anchor-y: -50%` |
| registry-mark-007 | must-render-optional-popover | `tip="Bio text here"` | Span with class `pc-rm-tip` containing the tip content is in DOM |
| registry-mark-008 | must-render-optional-popover | `tip={undefined}` | No `pc-rm-tip` span in DOM |
| registry-mark-009 | must-hide-svg-from-accessibility-tree | Default render | SVG has `aria-hidden="true"` |
| registry-mark-010 | must-support-classname | `className="custom-class"` | Root span has both `pc-registry-mark` and `custom-class` classes |
| registry-mark-011 | must-memoize-rendering | Props unchanged between renders | Component does not re-render (React profiler shows no Render phase) |

## Edge Cases

- **Empty or missing label**: If `label` is empty string or undefined, the link will have no accessible name. Implementations SHOULD validate and provide a default or error; this is a source gap.
- **Missing profileUrl**: If `profileUrl` is empty string, the link's href will be empty (current: `<a href="">`). Clicking navigates to the current page. Implementations SHOULD reject empty or invalid URLs.
- **Long tip content**: If `tip` contains very long text or many nested elements, the popover may exceed viewport bounds. CSS in host's popover-bloom styling SHOULD include overflow handling (this component does not constrain tip size).
- **Tip contains interactive content**: If `tip` contains links or buttons, the popover MUST remain open while focus is within those elements; the component does not manage focus, delegating to the host's popover implementation.
- **Ancestor overflow:hidden**: If the mark is rendered inside a container with `overflow: hidden`, the popover will be clipped. The source comment notes this: the mark MUST be rendered as a sibling outside `.persona-chat` or the host's `ViewportShell` must set `clip={false}`.
- **Ancestor with no position context**: The mark's CSS positioning relies on an ancestor with `position: relative` (per source comment). If missing, the mark will position relative to the nearest positioned ancestor (default browser behavior).
- **Concurrent render streaming**: The component is memoized; if `tip` is an inline JSX expression (not stable), the component re-renders on every parent render despite memoization. Callers MUST pass a stable `tip` constant to avoid re-renders during token streaming.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `profileUrl` | string | (required) | Hyperlink target; persona's profile URL on the registry |
| `label` | string | (required) | Accessible name for the link (e.g., "Visit X's profile on the registry") |
| `tip` | ReactNode | undefined | Optional popover content shown on hover and focus; omit for no popover |
| `className` | string | undefined | Optional CSS class name(s) to merge with internal `pc-registry-mark` class |

## Deep Linking

Not applicable: this component is itself a link, not a deep-link target.

## Localization

| String Key | Default (en) | Context |
|-----------|-------------|---------|
| (none) | (none) | The `label` prop is the only user-facing string, passed by the caller; the component does not define localization strings |

## Accessibility Options

Not applicable: the component has no interactive behaviors that respond to accessibility display options (Reduce Motion, Increase Contrast, Differentiate Without Color).

## Feature Flags

Not applicable: the component has no feature-flag integration.

## Analytics

Not applicable: the component does not emit analytics events. Event tracking is the responsibility of the host or the link's native click behavior.

## Privacy

- **Data collected**: None. The component itself collects no data.
- **Transmission**: When the link is clicked, the browser navigates to `profileUrl` with `target="_blank"`; transmission is handled by the browser and the target server.
- **Retention**: N/A — no data is retained by the component.

## Logging

Not applicable: the component does not emit debug or error logs.

## Platform Notes

- **Source (React/Web)**: Renders in `packages/web/packages/chat/src/components/RegistryMark.tsx`. Props: `profileUrl`, `label`, `tip`, `className`. Memoized export. Styles in companion `css/components/registry-mark.css`.
- **SwiftUI**: Requires a SwiftUI wrapper or custom link component. Center a circular @ symbol (in system font or custom rendering) with a four-pointed star overlay, tinted by environment color (.foregroundColor modifier). Position at top-right corner using offset or alignment. Provide an optional popover or sheet for tip content. SwiftUI's built-in link modifier handles the `profileUrl` and target-new-window behavior.
- **Compose**: Use Compose's Text (or custom Painter) to render the @ glyph; overlay a Path-drawn four-pointed star. Tint the @ with local.contentColor. Position in a Box with Alignment.TopEnd. Wrap in a clickable modifier linking to `profileUrl`. Optional Popup or Dialog for tip content.
- **AppKit / UIKit**: Render the @ glyph and star as a custom NSView (macOS) or UIView (iOS). Use Core Graphics (CGPath) to draw both shapes. Tint the @ with the view's tintColor. Position in the host's top-right using Auto Layout or frame geometry. Wrap in an NSButton or UIButton with target/action linking to `profileUrl`. Optional popover (macOS NSPopover) or UIPopoverPresentationController (iPad) for tip content.
- **WinUI 3**: Render the @ glyph as a Path in XAML (or use a custom control with CompositionVisuals for performance). Overlay a second Path for the four-pointed star, filled with the gold accent color. Tint the @ using the Foreground brush (inherited from ancestor). Position using Grid.Column and VerticalAlignment="Top", HorizontalAlignment="Right" with Margin to half-clip. Wrap in a HyperlinkButton with NavigateUri set to `profileUrl`. Optional Flyout with tip content; use IsOpen binding and Placement="Top".

## Design Decisions

- **Embedded glyph, not live text**: The @ is embedded as an SVG path (the exact JetBrains Mono weight 400 outline) rather than rendered as live `<text>` with a font dependency. This ensures the mark carries its own shape and never depends on the host having the font loaded, guaranteeing consistent rendering across environments.
- **ADH gold as hex literal, not theme token**: The star is filled with `#c4a35a` (hex literal) rather than a CSS variable or theme token. This is intentional: the registry accent must not dissolve into the host skin and must remain recognizable and distinct regardless of the host's color theme.
- **Tint @ via currentColor, not prop**: The @ glyph is tinted by `fill="currentColor"` (inherited from ancestor CSS `color` property), not a dedicated color prop. This allows the mark to adapt to the persona's hue or registry house color without requiring a prop, while keeping the component's prop surface minimal.
- **Memoization for streaming performance**: The component is wrapped in React.memo() because the host chat re-renders on every streamed token, but the mark's props are static after mount. Memoization prevents unnecessary re-renders as long as callers pass a stable `tip` (a module constant, not inline JSX).
- **Four-pointed star geometry**: The star uses independent x/y radii (rx=4.0, ry=6.6) rather than a uniform radius. This lets it fill the @ counter's tall-narrow opening without spilling past the glyph into the ring, maintaining visual balance and legibility.
- **Popover as conditional span, not a separate component**: The `tip` is rendered as a simple span (`.pc-rm-tip`) that the host's CSS or JS can position as a popover. This avoids a hard dependency on a third-party popover library and lets each host apply its own popover styling and behavior.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| [accessible-name](agenticdevelopercookbook://compliance/accessibility#accessible-name) | passed | Accessibility |
| [link-target-security](agenticdevelopercookbook://compliance/security#link-target-security) | passed | Security |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | | Initial creation from source analysis |
