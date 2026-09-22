---
id: c10a6fd9-470a-45a1-a025-3c75554c2a41
title: ViewportComposer
domain: agenticdevelopercookbook://ingredients/viewport-composer
type: ingredient
version: 1.0.0
status: review
language: en
created: 2026-09-22
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Bottom-anchored container that lifts above the on-screen keyboard and respects
  safe-area insets.
platforms:
- typescript
- web
tags:
- viewport
- keyboard
- safe-area
depends-on: []
related: []
references: []
---

# ViewportComposer

## Overview

ViewportComposer is a container component that anchors to the bottom of a ViewportShell, lifting above the on-screen keyboard automatically and respecting platform safe-area insets. It is used to render persistent controls (typically input composition or action buttons) that remain accessible while the keyboard is visible.

## Behavioral Requirements

- **must-render-children**: Component MUST render its children without modification.
- **must-accept-classname**: Component MUST accept an optional `className` prop and apply it alongside the internal `vp-composer` class.
- **must-adjust-bottom-padding**: Component MUST set its bottom padding to `calc(var(--kb-inset) + env(safe-area-inset-bottom))` so that it lifts above the keyboard and respects the home indicator.
- **must-compose-classname**: When `className` is provided, the component MUST render with both `vp-composer` and the provided className in the class attribute, space-separated.

## Appearance

- **Background**: Transparent (inherited from parent or explicit override via className)
- **Padding**: Bottom padding calculated as `calc(var(--kb-inset) + env(safe-area-inset-bottom))`; left and right padding defined by ViewportShell context or className
- **Border**: None by default
- **Width**: 100% (full width of ViewportShell)
- **Height**: Auto (sized by children and padding)

## States

| State | Appearance change |
|-------|------------------|
| Default | Renders at full width, bottom-anchored |
| Keyboard visible | Bottom padding increases by `var(--kb-inset)` |
| Safe area present | Bottom padding includes `env(safe-area-inset-bottom)` |

## Accessibility

- Role: Generic container (`div`)
- Children inherit accessibility semantics from their own markup
- Component itself is transparent to assistive technology; focus moves directly to interactive children
- Keyboard navigation is not blocked by the container

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| vp-composer-001 | must-render-children | `<ViewportComposer><button>Send</button></ViewportComposer>` | Button element renders inside the container |
| vp-composer-002 | must-accept-classname | `<ViewportComposer className="custom-class">Text</ViewportComposer>` | Rendered element has class `vp-composer custom-class` |
| vp-composer-003 | must-compose-classname | `<ViewportComposer className="custom-class">Content</ViewportComposer>` | Both classes appear in the DOM class attribute, space-separated |
| vp-composer-004 | must-adjust-bottom-padding | Render on iOS with keyboard visible | Element CSS bottom padding equals `calc(var(--kb-inset) + env(safe-area-inset-bottom))` |

## Edge Cases

- **No children**: Component renders an empty container; padding is still applied.
- **Multiple className strings**: If `className` contains spaces or multiple class names, all are preserved in the output.
- **No keyboard inset CSS variable**: If `--kb-inset` is undefined, padding calculation uses 0; safe-area-inset-bottom still applies. Behavior is graceful degradation.
- **Safe area not present**: On platforms without safe-area-inset-bottom support, `env()` defaults to 0; component continues to function.
- **Children unmount/remount**: Component preserves its positioning and padding through child updates.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| children | ReactNode | required | Content to render inside the composer |
| className | string | undefined | Additional CSS class names to apply alongside `vp-composer` |

## Deep Linking

Not applicable: ViewportComposer is a layout container with no navigable identity.

## Localization

Not applicable: ViewportComposer has no text content of its own.

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | Inherits from parent or parent animation context; component itself applies no motion |
| Increase Contrast | Inherits from parent styling; component provides no special behavior |
| Differentiate Without Color | Not applicable; component is a structural container with no color semantics |

## Feature Flags

Not applicable: ViewportComposer is a core layout primitive with no feature-gating requirement.

## Analytics

Not applicable: Component is a structural container; analytics events belong to interactive children.

## Privacy

Not applicable: Component stores and transmits no data.

## Logging

Not applicable: Component has no internal state or error conditions requiring logging.

## Platform Notes

- **Web**: Render as a `<div>` with class `vp-composer`. Apply bottom padding via CSS custom property `calc(var(--kb-inset) + env(safe-area-inset-bottom))`. The `--kb-inset` variable MUST be managed by the ViewportShell parent; ViewportComposer reads it but does not set it. Position is `relative` by default unless explicitly overridden.
- **SwiftUI**: Compose using a `ZStack` with `.frame(maxWidth: .infinity, alignment: .bottom)` or a `VStack` with `Spacer()` and bottom padding modifier chained as `.padding(.bottom, keyboardHeight + safeArea.bottom)`. Observe `@Environment(\.keyboardHeight)` to lift the container dynamically above the keyboard.
- **Compose**: Use `Box(Modifier.fillMaxWidth().padding(bottom = keyboardHeight + systemWindowInsetBottom))` or a `Row` with weight 1.0 and `VerticalAlignment.Bottom`. Read keyboard height from `WindowInsets.ime.animationSpec()` or similar IME observer.
- **AppKit**: Build as `NSView` with `translatesAutoresizingMaskIntoConstraints = false`, constrain to bottom of parent with space equal to keyboard height + safe area, and update constraints via `NSResponder.keyboardWillShow()` notifications to animate the lift.
- **WinUI 3**: Use `StackPanel` with `VerticalAlignment="Bottom"` and `Margin` set to `0,0,0,(KeyboardHeight + SafeArea.Bottom)`. Bind bottom margin to an observable keyboard-height property that updates on `InputPane.GetForCurrentView().Showing` and `Hiding` events.

## Design Decisions

The component delegates keyboard height tracking to its parent (ViewportShell) via the `--kb-inset` CSS variable. This allows ViewportComposer to remain a simple, stateless container that responds to external state rather than managing its own keyboard observer. The same pattern applies to safe-area insets, which are read via standard CSS environment variables. This design avoids duplication of keyboard-tracking logic across multiple components and simplifies testing and composition.

## Compliance

Not applicable: ViewportComposer is a layout primitive with no compliance checks beyond standard web component quality (valid HTML, semantics, no console errors).

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation from web source |
