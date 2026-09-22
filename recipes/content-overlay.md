---
id: bd17a89e-aac9-475d-adcd-98b61d24f941
title: Content Overlay
domain: agenticdevelopertoolkit://recipes/content-overlay
type: ingredient
version: 1.1.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A controlled overlay component that displays content with a customizable
  close button.
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

# Content Overlay

## Overview

ContentOverlay is a controlled React component that conditionally displays content in an overlay structure with a dismissal button. It accepts an `open` boolean to control visibility state, an `onClose` callback for dismissal, a customizable close button label, and child content to render. The component manages CSS classes and layout structure; styling is delegated to an external stylesheet.

## Behavioral Requirements

- **must-render-structure**: The component MUST always render the overlay structure (header, close button, body) regardless of the `open` prop value.
- **must-apply-open-class**: The component MUST apply the `open` CSS class to the root element when the `open` prop is `true`.
- **must-not-apply-open-class**: The component MUST NOT apply the `open` CSS class to the root element when the `open` prop is `false`.
- **must-invoke-onClose**: The component MUST invoke the `onClose` callback function when the close button is clicked.
- **must-render-children**: The component MUST render the `children` prop within the body element.
- **must-display-closeLabel**: The component MUST display the `closeLabel` prop as the close button text when provided.
- **must-use-default-closeLabel**: The component MUST display the string `'← back'` as the close button text when `closeLabel` is not provided.
- **may-apply-custom-className**: The component MAY apply the `className` prop to the root element in addition to base and state CSS classes.

## Appearance

Traced to `packages/web/packages/chat/src/css/components/content-overlay.css`.

- **Corner radius**: None. Root, header, close button, and body are unrounded.
- **Padding**: Header: `10px 12px`. Close button: `6px 0`. Root bottom: `calc(env(safe-area-inset-bottom, 0px) + 44px)`. Body bottom: `env(safe-area-inset-bottom, 0)`.
- **Font**: Close button: `var(--font-mono, ui-monospace, SFMono-Regular, monospace)`, `0.65rem`, `0.06em` letter-spacing.
- **Background**: Root: `rgba(10, 10, 14, 0.3)` with `backdrop-filter: blur(16px)` (`-webkit-backdrop-filter` included for Safari). Header, close button, and body have no background of their own.
- **Foreground/Text**: Close button text: `var(--text-muted, #8a8a9a)` by default, `var(--accent, #c4a35a)` while pressed (`:active`).
- **Border**: Header: `1px solid rgba(42, 42, 54, 0.4)` bottom border. Close button and body have no border.
- **Shadow**: None defined.
- **Min/Max size**: Root fills the viewport (`position: fixed; top/left/right/bottom: 0`). No min/max constraints on header, close button, or body; body uses `flex: 1; min-height: 0` to fill remaining vertical space.
- **Z-index**: Root: `z-index: 1`.
- **Transitions**: Root `opacity` transitions over `0.3s` with `cubic-bezier(0.16, 1, 0.3, 1)`. Close button `color` transitions over `0.15s` (default easing).
- **Layout**: Root is a flex column (`display: flex; flex-direction: column; overflow: hidden`). Header does not shrink (`flex-shrink: 0`). Body is `flex: 1` and is itself a flex column.
- **Responsive**: A `@media (max-width: 768px)` block in the same stylesheet targets classes used by content typically hosted in the body slot (a chat) — `.persona-chat { height: 100dvh !important; }`, `.pc-input { -webkit-appearance: none; border-radius: 0; }`, `.pc-input-area { position: sticky; bottom: 0; z-index: 10; }` — not the `pc-content-overlay` classes themselves.

## States

| State | Appearance change |
|-------|------------------|
| Closed (open=false) | `opacity: 0`, `pointer-events: none` — overlay is invisible and non-interactive |
| Open (open=true) | `opacity: 1`, `pointer-events: auto` — fades in over `0.3s` (`cubic-bezier(0.16, 1, 0.3, 1)`) and becomes interactive |
| Close button — pressed (`:active`) | Text color changes from `var(--text-muted, #8a8a9a)` to `var(--accent, #c4a35a)` |

## Accessibility

- **Role**: The close button is a native HTML `<button>` element, providing automatic semantic button role.
- **Label**: The close button is labeled by its text content: `closeLabel` prop or default `'← back'`.
- **Keyboard support**: Native button element supports keyboard activation (Enter, Space keys) from the platform.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| overlay-001 | must-render-structure | open=true or false | Header, close button, and body elements are in the DOM |
| overlay-002 | must-apply-open-class | open=true | Root div has class `pc-content-overlay open` |
| overlay-003 | must-not-apply-open-class | open=false | Root div has class `pc-content-overlay` (no `open` class) |
| overlay-004 | must-invoke-onClose | User clicks close button; onClose is a spy function | onClose is called exactly once |
| overlay-005 | must-render-children | children="<div>test content</div>", open=true | Text "test content" appears in body element |
| overlay-006 | must-display-closeLabel | closeLabel="Custom Label", open=true | Close button displays "Custom Label" |
| overlay-007 | must-use-default-closeLabel | closeLabel is undefined, open=true | Close button displays "← back" |
| overlay-008 | may-apply-custom-className | className="custom-style", open=true | Root div includes class `custom-style` |

## Edge Cases

- **Null or undefined children**: When children is null or undefined, the body element renders empty. Expected behavior: no error, body is rendered and visible (empty). (MUST render without error)
- **Empty closeLabel**: When closeLabel is an empty string, the close button is rendered with no visible text. Expected behavior: button is present and clickable. (SHOULD allow empty string)
- **Multiple rapid closes**: User clicks close button multiple times in rapid succession. Expected behavior: onClose is invoked once per click; multiple invocations are not merged. (MUST invoke per click)
- **Missing onClose callback**: When onClose is undefined or not provided, clicking the close button does not error. Expected behavior: button click handler attempts to call undefined, resulting in runtime error. (SHOULD require valid onClose)
- **className with special characters**: className contains spaces, hyphens, or other CSS class name characters. Expected behavior: className is concatenated into the class string as-is. (SHOULD preserve className as provided)

## Configuration

Not applicable: The component is configured entirely through its React props (`open`, `onClose`, `closeLabel`, `children`, `className`) and has no separate configuration options.

## Deep Linking

Not applicable: ContentOverlay is a presentation component with no navigation or routing behavior.

## Localization

Not applicable: The only user-facing text is `closeLabel`, which is provided by the calling component and should be localized by the caller, not by ContentOverlay.

## Accessibility Options

Not applicable: The component does not directly respond to system-level accessibility options (Reduce Motion, Increase Contrast, Differentiate Without Color). Such concerns are handled by the accompanying stylesheet and consumed by parent component logic.

## Feature Flags

Not applicable: The component has no feature flag gating or conditional behavior.

## Analytics

Not applicable: The component does not emit analytics events. Event tracking is the responsibility of the calling component.

## Privacy

Not applicable: The component does not collect, store, or transmit any data.

## Logging

Not applicable: The component does not emit log messages.

## Platform Notes

- **React/Web**: Implemented in `packages/web/packages/chat/src/components/ContentOverlay.tsx`. The component is a stateless, controlled component that applies CSS classes based on props. Visibility and styling are delegated to the stylesheet using class names `pc-content-overlay`, `pc-content-overlay-header`, `pc-content-overlay-close`, and `pc-content-overlay-body`.

- **SwiftUI**: Implement as a custom view that manages visibility through `.sheet()` or a custom `.fullScreenCover()` modifier bound to the `open` state. Use a `VStack` to structure the header (with a close button) and content area. The close button should be a `Button` with its action bound to `onClose`, and label customizable via a parameter.

- **Compose**: Use the `Dialog` composable or a custom `Popup` for overlay presentation. The `onDismissRequest` callback should be bound to `onClose`. Structure with a header row containing a `Button` for the close action, and a body area for composable content. Bind the open state to the dialog's visibility.

- **AppKit / UIKit**: On iOS, implement as a modal view controller or custom container view controlled by the open state. On macOS, use a sheet or popover presentation. The close button is a standard `UIButton` (iOS) or `NSButton` (macOS) with its target-action bound to `onClose`. Support customization of button text via a parameter.

- **WinUI 3**: Implement with the `ContentDialog` XAML control. Bind the `open` state to the dialog's visibility (show/hide). Define a custom button in the `CloseButtonContent` or `SecondaryButtonContent` property with its click event bound to `onClose`. Use data binding to set button text from the close label parameter.

## Design Decisions

The component uses fully controlled props rather than internal state, requiring the parent component to manage `open` state and implement the `onClose` dismissal logic. This design enables precise parent control, simplifies testing, and aligns with React controlled component patterns. The default `closeLabel` of `'← back'` provides a sensible default for navigation-oriented overlays while permitting customization for different use cases.

## Compliance

No compliance checks are defined for this component at this time.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.1.0 | 2026-09-22 | Mike Fullerton | Filled Appearance and States from content-overlay.css; dropped the review marker |
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
