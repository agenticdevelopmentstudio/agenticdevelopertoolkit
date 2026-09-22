---
id: 960a1577-bf48-4d56-a93f-aa690853f64f
title: ViewportShell
domain: agenticdevelopercookbook://ingredients/viewport-shell
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Page-level shell that locks viewport and manages keyboard inset for the page.
platforms:
- web
tags:
- viewport
- layout
depends-on: []
related: []
references: []
---

# ViewportShell

## Overview

ViewportShell is a top-level page shell component that locks the document to the visible viewport, preventing page scroll, and mounts the keyboard-inset hook to track and respond to virtual keyboard visibility. It provides a vertical flex container for slotting child components and can optionally allow overflow to hang beyond its boundaries.

## Behavioral Requirements

- **must-lock-page**: Component MUST prevent html and body from scrolling by maintaining `overflow:hidden` on the page itself.
- **must-render-children**: Component MUST render its children prop as the content of a flex container.
- **must-mount-keyboard-hook**: Component MUST call `useKeyboardInset()` on render to establish keyboard inset tracking.
- **must-apply-viewport-shell-class**: Component MUST apply the CSS class `viewport-shell` to its root element.
- **must-support-clip-prop**: Component MUST accept a `clip` boolean prop that defaults to `true` and controls whether the shell clips its own overflow.
- **must-apply-open-class-when-clip-false**: When `clip` prop is `false`, component MUST apply the CSS class `vp-shell--open` to its root element in addition to `viewport-shell`.
- **must-support-classname-prop**: Component MUST accept an optional `className` prop and append it to the root element's class list.
- **must-ignore-null-classname**: When `className` prop is `undefined` or empty string, component MUST not add it to the class list.

## Appearance

- **Container**: Vertical flex container (flex-direction: column implied by usage context)
- **Background**: Transparent (inherits from parent)
- **Overflow behavior**: Controlled by `clip` prop — when `true`, overflow is clipped; when `false`, content may overhang the shell's box
- **Sizing**: Fills available space (positioned to lock to viewport)

## States

| State | Trigger | Appearance Change |
|-------|---------|------------------|
| Clipped (default) | `clip={true}` or prop omitted | CSS class `viewport-shell` applied; overflow hidden |
| Open | `clip={false}` | CSS classes `viewport-shell` and `vp-shell--open` applied; overflow visible |

## Accessibility

Not applicable: ViewportShell is a container component with no direct interactive or textual content. All accessibility concerns are owned by child components.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| viewport-001 | must-render-children | `<ViewportShell><div>Content</div></ViewportShell>` | Rendered div with text "Content" appears in the DOM as a child of the shell |
| viewport-002 | must-apply-viewport-shell-class | `<ViewportShell />` | Root element has class `viewport-shell` |
| viewport-003 | must-apply-open-class-when-clip-false | `<ViewportShell clip={false} />` | Root element has classes `viewport-shell` and `vp-shell--open` |
| viewport-004 | must-support-classname-prop | `<ViewportShell className="custom-class" />` | Root element has classes `viewport-shell` and `custom-class` |
| viewport-005 | must-ignore-null-classname | `<ViewportShell className="" />` | Root element has class `viewport-shell` only; empty string is not added to class list |
| viewport-006 | must-support-clip-prop | `<ViewportShell clip={true} />` | Root element does not have `vp-shell--open` class |
| viewport-007 | must-mount-keyboard-hook | `<ViewportShell />` mounted | `useKeyboardInset()` hook is invoked during render |

## Edge Cases

- **Null children**: When `children` is `null`, component renders an empty div with no content. Behavior is MUST.
- **Empty children array**: When `children` is an empty array, component renders with no child elements. Behavior is MUST.
- **Multiple children**: Component correctly renders all children in the order provided. Behavior is MUST.
- **clip prop is undefined**: When `clip` is not provided, it defaults to `true` and `vp-shell--open` is not applied. Behavior is MUST.
- **className with whitespace**: When `className` contains only whitespace, component filters it out and does not add to class list. Behavior is MUST.
- **Rapid clip prop changes**: When `clip` prop changes between `true` and `false`, component updates class list synchronously; children are preserved. Behavior is MUST.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `children` | ReactNode | (required) | Content to render within the shell |
| `clip` | boolean | `true` | When `false`, allows content to overhang the shell's box (page remains locked regardless) |
| `className` | string | undefined | Additional CSS class names to apply to the root element |

## Deep Linking

Not applicable: ViewportShell is a page-level shell component and does not handle deep linking itself.

## Localization

Not applicable: ViewportShell has no user-facing text and does not perform localization.

## Accessibility Options

Not applicable: ViewportShell is a structural container and does not directly respond to accessibility display options. All accessibility handling is delegated to child components.

## Feature Flags

Not applicable: ViewportShell has no feature flag requirements.

## Analytics

Not applicable: ViewportShell is a foundational container component and does not emit analytics events.

## Privacy

Not applicable: ViewportShell does not collect, store, or transmit any data.

## Logging

Not applicable: ViewportShell has no logging requirements.

## Platform Notes

- **Web (React)**: ViewportShell.tsx uses a `div` with `useKeyboardInset()` hook. Classes are managed via array filtering and join. The component is a simple stateless wrapper around `useKeyboardInset()` and CSS class composition.
- **SwiftUI**: Implement as a `ZStack` or `VStack` that sets `edgesIgnoringSafeArea(.all)` to lock to the viewport. Mount a keyboard-inset observation via `@State` or `@Environment` key path equivalent to trap virtual keyboard visibility and adjust padding on a contained container.
- **Compose**: Use a `Box` modifier with `Modifier.fillMaxSize()` and `Modifier.verticalScroll(rememberScrollState(), enabled = false)` to lock vertical scroll. Observe keyboard visibility via `WindowInsets.ime` and compose the keyboard-inset effect into the layout tree.
- **AppKit / UIKit**: On iOS, use a `UIView` with `autoresizingMaskIntoConstraints` set to fill the safe area or `edgesIgnoringSafeArea()` equivalent. Observe keyboard notifications (`UIKeyboardWillShow`, `UIKeyboardWillHide`) and adjust the view's bottom constraint or padding. On macOS, a `NSView` filling the window's content area is sufficient; keyboard handling is not applicable.
- **WinUI 3**: Implement as a `Grid` with `VerticalAlignment="Stretch"` and `HorizontalAlignment="Stretch"`. Set `Background="{ThemeResource ApplicationPageBackgroundThemeBrush}"` to inherit system colors. Observe `InputPane` events (`InputPane.GetForCurrentView().Showing` and `.Hiding`) to track virtual keyboard state. The `clip` flag controls whether child content is clipped by a `ClipToBounds="True/False"` property or by the Grid's `Clip` setting.

## Design Decisions

The `clip` prop defaults to `true` because most page layouts should constrain overflow to prevent unintended visual overflow and layout shifts. The exception — when content deliberately overhangs (e.g., a corner badge) — is opt-in via `clip={false}`. The page itself remains locked (`overflow:hidden` on html/body) regardless of the `clip` setting to prevent secondary scroll bars at the document level.

The keyboard-inset hook is mounted unconditionally because virtual keyboard tracking is a foundational concern for any page-level shell. Keyboard inset state is managed globally and can be accessed by descendant components via a context or hook without requiring explicit prop threading.

## Compliance

Not applicable: ViewportShell is a foundational component with no compliance-specific requirements beyond rendering children and managing keyboard state.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation |
