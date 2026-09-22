---
id: 44544cfb-39e5-419d-81b9-8e1c504c6e64
title: WindowFooterContentViewController
domain: agenticdevelopercookbook://recipes/macos/window-footer-content-view-controller
type: ingredient
version: 1.0.0
status: review
language: en
created: 2026-09-22
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: An AppKit container that stacks a content view controller above a fixed footer
  bar for window layouts.
platforms:
- swift
- macos
tags:
- window-chrome
- view-controller
- layout
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# WindowFooterContentViewController

## Overview

A view controller that composes an arbitrary content view controller with a fixed footer bar (`WindowFooterBar`) at the bottom of a window. The footer remains visible and stationary while the content fills the remaining space. This container allows windows to gain a footer without restructuring their content hierarchy—the content view controller is adopted as a child and participates in the responder chain and appearance inheritance as if the window contained it directly.

## Behavioral Requirements

- **must-adopt-content-child**: The container MUST adopt the provided `contentViewController` as a child view controller, ensuring it participates in the responder chain and inherits appearance settings from the parent window.
- **must-stack-layout**: The container MUST position the content view controller's view above the `WindowFooterBar` in the view hierarchy, with the footer anchored to the bottom.
- **must-fill-content-space**: The content view controller's view MUST expand to fill all available space in the container except the space occupied by the footer bar.
- **must-position-footer-bottom**: The `WindowFooterBar` MUST be anchored to the bottom edge of the container and stretch to the full width.
- **must-forward-status**: The `status` property MUST forward all getter and setter calls to the footer's `status` property, allowing callers to set the footer's leading status text through a single reference.
- **must-require-accessibility-prefix**: The initializer MUST require an `accessibilityPrefix` parameter (no default) to namespace the footer's accessibility controls, ensuring that multiple windows with footers do not share accessibility identifiers.
- **must-prevent-nscoder-init**: Initialization from an `NSCoder` (e.g., from Interface Builder) MUST not be supported and MUST raise a fatal error if attempted.

## Appearance

- **Layout**: Vertical stack with content above, footer below. No intermediate spacing.
- **Footer height**: Defined by `WindowFooterBar`; not customizable in this container.
- **Border, shadow, background**: None at the container level; appearance is determined by the content view controller and footer.
- **Content view frame**: Fills the container's bounds minus the footer's height.

## States

| State | Behavior |
|-------|----------|
| Initialized | Content and footer are laid out; container ready to receive view updates. |

## Accessibility

- **Accessibility inheritance**: The content view controller's accessibility hierarchy is preserved; elements in the content remain discoverable with their original accessibility attributes.
- **Footer accessibility namespacing**: The `accessibilityPrefix` parameter MUST be passed to `WindowFooterBar` to ensure its controls are named under a namespace unique to this window instance (e.g., `project.footer.button`). This prevents conflicts when multiple windows with footers exist in the application.
- **Example prefix usage**: If `accessibilityPrefix` is `"project.footer"`, the footer's controls receive accessibility identifiers rooted at `project.footer.*`.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| cvc-001 | must-adopt-content-child | Create with valid content VC and prefix | `contentViewController` is accessible; VC is a child of the container |
| cvc-002 | must-stack-layout | Render container with content and footer | Content view's top is at container's top; footer view's bottom is at container's bottom |
| cvc-003 | must-fill-content-space | Set container's frame to 400×300; footer height is 40px | Content view occupies 400×260; footer occupies 400×40 |
| cvc-004 | must-position-footer-bottom | Render and check constraints | Footer's leading and trailing anchors equal container's; footer's bottom anchor equals container's bottom |
| cvc-005 | must-forward-status | Set `container.status = "Ready"` | `container.footer.status` equals `"Ready"` |
| cvc-006 | must-forward-status | Read `container.status` when footer's status is `"Idle"` | Getter returns `"Idle"` |
| cvc-007 | must-require-accessibility-prefix | Initialize with two parameters: content VC and prefix `"test.footer"` | Initialization succeeds; `container.footer` receives prefix `"test.footer"` |
| cvc-008 | must-prevent-nscoder-init | Attempt `init(coder:)` via archival or Interface Builder | Fatal error is raised; application terminates |

## Edge Cases

- **Empty accessibility prefix**: A prefix of empty string (`""`) is syntactically valid but results in footer controls being named with empty namespaces. This behavior is not prevented by the component but SHOULD NOT be used in practice. Recommendation: Always provide a non-empty, unique prefix.
- **Content view controller with existing parent**: If the passed `contentViewController` is already a child of another view controller, Swift's view controller hierarchy rules apply; the operation may fail or produce undefined behavior. This MUST be prevented at the call site by the caller.
- **Footer state changes**: The footer (`WindowFooterBar`) may have its own internal state (e.g., button presses, text updates). This container does not modify or constrain the footer's behavior; it only manages layout. Any footer state changes propagate normally through the footer's own interface.
- **Responder chain during initialization**: During `loadView()`, the content view controller's view is added to the hierarchy and the child relationship is established. The responder chain is set up by AppKit's standard view controller adoption mechanics; this container does not alter that flow.

## Configuration

Not applicable. This component has no configuration options; all parameters are required at initialization.

## Deep Linking

Not applicable. This component is a view controller container, not a URL-routable endpoint.

## Localization

Not applicable. This component contains no user-facing strings; localization is handled by the content view controller and `WindowFooterBar` separately.

## Accessibility Options

- **Reduce Motion**: Inherited from the content view controller and footer; this container does not add animations.
- **Increase Contrast**: Inherited from child views; this container does not set colors.
- **Differentiate Without Color**: Inherited from child views; this container is transparent to color-based distinctions.

## Feature Flags

Not applicable. This component is always enabled.

## Analytics

Not applicable. This component performs no analytics tracking.

## Privacy

Not applicable. This component collects no user data.

## Logging

Not applicable. This component performs no logging.

## Platform Notes

- **Swift**: Reference implementation. Located in `SourcesUI/macOS/Chrome/WindowFooterContentViewController.swift` in AgenticDeveloperToolkit. Uses `NSViewController` adoption via `addChild(_:)` and Auto Layout with `NSLayoutConstraint`. The `@MainActor` annotation ensures thread-safe access to AppKit objects.
- **SwiftUI**: Wrap this `NSViewController` in a `NSViewControllerRepresentable` conformer to use in SwiftUI views. Bind the `status` property to SwiftUI state if dynamic updates are needed. The content view controller's view will be rendered within the SwiftUI view hierarchy.
- **Compose**: Create a vertical `Column` with `Modifier.weight(1f)` on the content area and a fixed-height footer below. The `Column` layout primitive maps to the vertical stacking behavior. Pass a `modifier` through composition to configure namespacing if an accessibility equivalent exists.
- **React/Web**: Use a vertical flexbox container (`display: flex; flex-direction: column`). Set `flex: 1` on the content element so it expands; set a fixed `height` on the footer. Use a `ref` or state callback to forward a `status` prop to the footer component, mimicking the property forwarding behavior.
- **WinUI 3**: Use a `Grid` with two `RowDefinition` entries: one with `Height="*"` (star sizing) for content and one with a fixed height for the footer. Place the content in row 0, footer in row 1. Use `Grid.Row="0"` and `Grid.Row="1"` attached properties to assign views to rows. A `StackPanel` with `Orientation="Vertical"` provides an alternative if automatic row sizing is preferred.

## Design Decisions

- **Child adoption over containment**: The component adopts `contentViewController` as a child rather than simply adding its view. This preserves the content controller's participation in the responder chain and appearance propagation, allowing it to behave as if the window contained it directly. This is a separation of concerns: the window does not know about the footer; the footer is added transparently.
- **Explicit accessibility prefix**: The `accessibilityPrefix` parameter is required (not defaulted) because multiple windows with footers in the same app would otherwise share accessibility identifiers, breaking UI testing and assistive technology. Explicit naming requires developers to think about uniqueness.
- **No NSCoder support**: Initialization from `NSCoder` is explicitly forbidden because the component cannot be configured via Interface Builder (requires a content view controller reference at runtime, not at build time). A fatal error is more transparent than a silent failure.
- **Status forwarding**: The `status` property is exposed on the container itself so callers hold a single reference rather than reaching through two layers (`container.footer.status`). This reduces coupling and makes the interface simpler.

## Compliance

Not applicable.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
