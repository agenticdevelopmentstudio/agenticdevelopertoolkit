---
id: d7a2af70-0812-4360-afa7-02be1a44e7b8
title: Resource Card
domain: agenticdevelopercookbook://ingredients/resource-card
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A content card for displaying a resource with title, optional identifier,
  description, and metadata in a navigational or interactive context.
platforms:
- typescript
- web
tags:
- card
- resource
- navigation
- interactive
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Resource Card

## Overview

ResourceCard is a flexible card component for displaying a resource (application, ecosystem entry, persona) with a title, optional reverse-domain identifier, optional description, and optional metadata chips. It serves three interactive modes: navigational (anchors to a URL via LinkComponent or native `<a>`), interactive (executes an onClick handler with role="button"), or inert (static content). The component prioritizes semantic HTML and browser affordances — when navigation is intended, it uses a real anchor rather than a simulated link, enabling middle-click, keyboard shortcuts, history, and status bar preview. It supports custom routing libraries through the LinkComponent prop and applies interactive styling (hover state, focus outline, cursor) only when interactive.

## Behavioral Requirements

- **must-render-title**: Component MUST render the `title` prop as the primary heading of the card.
- **must-accept-href**: Component MUST accept an `href` prop and, when provided, render as an anchor element with the destination URL.
- **must-accept-onclick**: Component MUST accept an `onClick` prop and, when provided and `href` is not set, render as a button-role div with keyboard activation (Enter or Space key).
- **must-prioritize-href-over-onclick**: When both `href` and `onClick` are provided, the component MUST render as an anchor, execute the `onClick` handler before navigation, and allow the navigation to proceed.
- **must-use-link-component**: When `href` is provided and `LinkComponent` prop is supplied, the component MUST use LinkComponent to render the anchor rather than a native `<a>` element, passing the destination as the `to` prop.
- **must-render-fallback-link-component**: When `href` is provided and `LinkComponent` is not supplied, the component MUST render a native `<a>` element.
- **must-support-keyboard-activation**: When `onClick` is provided without `href`, the component MUST respond to Enter and Space keys by invoking `onClick`.
- **must-support-optional-identifier**: Component MUST render the `identifier` prop as monospace text below the title when provided; it MUST NOT render if `identifier` is undefined or null.
- **must-support-optional-description**: Component MUST render the `description` prop as paragraph text below the identifier (or title if no identifier) when provided; it MUST NOT render if `description` is undefined or null.
- **must-support-optional-meta**: Component MUST render the `meta` prop as a flex-wrapped row of chips below the description when provided; it MUST NOT render if `meta` is undefined or null.
- **must-apply-interactive-styling**: When `href` or `onClick` is provided, the component MUST apply cursor-pointer, a hover state (stronger border and different background color), and a focus-visible state (gold-tinted border).
- **must-support-classname**: Component MUST accept a `className` prop and apply it to the outermost element, merging it with the default classes.
- **must-be-left-aligned**: Component MUST use text-left alignment for all text content.

## Appearance

- **Corner radius**: `rounded-xl` (border-radius 0.75rem)
- **Padding**: 5 (1.25rem on all sides)
- **Gap between sections**: 2 (0.5rem between title/identifier area, description, and meta)
- **Font (title)**: font-medium (500 weight), text color `apt-text`
- **Font (identifier)**: font-mono, text-xs (0.75rem), text color `apt-text-muted`
- **Font (description)**: text-sm (0.875rem), text color `apt-text-muted`, line-clamped to 3 lines
- **Font (meta)**: font-mono, text-xs (0.75rem), text color `apt-text-dim`, flex-wrapped with gap-x-4 (1rem) and gap-y-1 (0.25rem)
- **Border**: 1px solid `apt-border`
- **Background**: `apt-surface`
- **Layout**: flex column, full width, with transition-colors animation
- **Interactive hover**: border color changes to `apt-border-strong`, background changes to `apt-surface-2`
- **Interactive focus-visible**: border color changes to `apt-gold/60` (60% opacity gold)
- **Interactive cursor**: pointer

## States

| State | Appearance Change |
|-------|------------------|
| Default | Static card with apt-surface background and apt-border border. |
| Hover (interactive only) | Border color strengthens to apt-border-strong; background becomes apt-surface-2. |
| Focus (interactive only) | Border color becomes apt-gold/60; outline is visible via focus-visible pseudo-class. |

## Accessibility

- **Root element role**: When `href` is set, a native or LinkComponent-wrapped anchor element (implicit link role). When `onClick` is set without `href`, a div with `role="button"`. When neither is set, a div with no explicit role (content container).
- **Keyboard activation**: When role="button", Enter and Space keys MUST trigger the click handler. Anchor elements receive native browser keyboard support.
- **Focus indicator**: Focus-visible state applies a visible border color change (apt-gold/60), satisfying visibility requirements.
- **Text labels**: Title is rendered as plain text; no aria-label or aria-description attributes are used in the component, so content must be self-describing.
- **Identifier label**: Identifier is rendered in monospace and is visually secondary; implementers should ensure context makes its purpose clear (e.g., via a label above it or in documentation).
- **Touch/click target size**: The entire card is clickable or navigable; the card's padding (1.25rem) provides a touch target of at least 44×44pt on typical layouts, though verify with actual layout measurements.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| resource-card-001 | must-render-title | `title="My App"` | Title "My App" is rendered as plain text in font-medium. |
| resource-card-002 | must-accept-href | `href="/app"` | Root element is an anchor or LinkComponent with href="/app". |
| resource-card-003 | must-accept-onclick | `onClick={handler}` without href | Root element is a div with role="button" and tabIndex=0. |
| resource-card-004 | must-prioritize-href-over-onclick | `href="/app"` and `onClick={handler}` | onClick handler is executed, then navigation to /app proceeds. |
| resource-card-005 | must-use-link-component | `href="/app"` and custom LinkComponent | LinkComponent is rendered with to="/app" prop. |
| resource-card-006 | must-render-fallback-link-component | `href="/app"` without LinkComponent | Native `<a href="/app">` is rendered. |
| resource-card-007 | must-support-keyboard-activation | role="button" and Space key pressed | onClick handler is invoked. |
| resource-card-008 | must-support-keyboard-activation | role="button" and Enter key pressed | onClick handler is invoked. |
| resource-card-009 | must-support-optional-identifier | `identifier="com.example.app"` | Identifier is rendered in monospace, text-xs, below title. |
| resource-card-010 | must-support-optional-identifier | No identifier prop | No identifier text is rendered. |
| resource-card-011 | must-support-optional-description | `description="A great app"` | Description is rendered in text-sm, muted color, clamped to 3 lines. |
| resource-card-012 | must-support-optional-description | No description prop | No description text is rendered. |
| resource-card-013 | must-support-optional-meta | `meta={<span>iOS</span>}` | Meta content is rendered in flex-wrapped row, monospace, text-xs. |
| resource-card-014 | must-support-optional-meta | No meta prop | No meta row is rendered. |
| resource-card-015 | must-apply-interactive-styling | href or onClick provided | Cursor is pointer; hover and focus-visible states are applied. |
| resource-card-016 | must-apply-interactive-styling | Neither href nor onClick provided | Cursor is default (not pointer); hover and focus states are not visible. |
| resource-card-017 | must-support-classname | `className="custom-class"` | Custom class is applied to the outermost element along with defaults. |
| resource-card-018 | must-be-left-aligned | Any props | Text content uses text-left alignment. |

## Edge Cases

- **No props except title**: Card renders as inert div with title only. No errors occur.
- **Very long title**: Title text wraps to multiple lines within the card width. No truncation.
- **Very long identifier**: Identifier may wrap; recommend limiting identifier length in parent or using text-overflow/ellipsis in custom styling.
- **Description exceeds 3 lines**: Description is clamped to 3 lines via line-clamp-3; overflow text is hidden.
- **Meta content overflows horizontally**: Meta row uses flex-wrap to wrap items to the next line with gap-y-1 (0.25rem) between rows.
- **Both href and onClick with navigation**: onClick is synchronous; if it performs async work (e.g., analytics), the link will navigate before completion. Implementers should use preventDefault or return a Promise if needed.
- **LinkComponent not called immediately**: When LinkComponent is used but not rendered until the href is set, the component is inert until both props are provided.
- **Empty or null meta children**: If meta prop is present but contains no children, an empty flex row is rendered; no content or error.

## Configuration

Not applicable: ResourceCard is a presentational component configured entirely through props; it does not accept a separate configuration object or settings interface.

## Deep Linking

Not applicable: ResourceCard itself does not implement deep linking; it delegates navigation to the anchor or LinkComponent, which handle URLs. Parent consumers can wire routes and navigation based on the `href` prop passed to ResourceCard.

## Localization

Not applicable: ResourceCard renders content passed in via props (title, identifier, description, meta); it does not provide built-in localization. All text content is supplied by the parent and should be pre-localized.

## Accessibility Options

Not applicable: ResourceCard does not directly respond to platform accessibility display options (Reduce Motion, Increase Contrast, etc.). The transition-colors class applies a CSS transition; if Reduce Motion is enabled, the browser respects `prefers-reduced-motion` via CSS media queries (assumes Tailwind is configured to respect it). Focus outline styling (apt-gold/60) is always present and is not affected by Increase Contrast or other options.

## Feature Flags

Not applicable: ResourceCard is a presentational component with no feature flags or runtime toggles.

## Analytics

Not applicable: ResourceCard does not emit analytics events. The onClick handler is provided by the parent and may trigger analytics if desired; the component itself performs no event logging.

## Privacy

Not applicable: ResourceCard does not collect, store, or transmit any data. It is a view-layer component that renders content provided by its parent.

## Logging

Not applicable: ResourceCard does not emit log messages or perform diagnostic logging.

## Platform Notes

- **SwiftUI**: SwiftUI has no direct ResourceCard equivalent. Implement with a VStack containing Text (title), optional Text (identifier in monospace), optional Text (description with line limit of 3), and optional HStack (meta chips). Use NavigationLink to wrap the entire stack when navigation is needed, or use onTapGesture and button styling for onClick behavior. Apply Card or custom shadow/border modifiers for appearance. Replicate focus state with focusable() and scaleEffect on focus.

- **Compose**: Android Material Design 3 provides Card composable for layout and styling. Use Card with a clickable modifier for onClick interactivity. For navigation, wrap with a Clickable intent or use a navigation API. Nest a Column for vertical layout (title, identifier, description, meta), each as Text or Row composables. Ripple effect is built into Material 3; apply Modifier.clip and contentColor for theming. Replicate focus state with FocusRequester and Box outline modifiers.

- **React/Web**: This is the reference implementation. Component is exported from `packages/web/packages/ui/src/blocks/resource-card.tsx`. Uses semantic HTML (native `<a>` or LinkComponent-wrapped anchor for navigation, div[role="button"] for onClick interactivity). Styling is driven by Tailwind CSS utility classes and semantic color tokens (apt-* family). Customization via className prop. No additional wrappers or theming layer needed.

- **AppKit / UIKit**: macOS AppKit uses NSView or SwiftUI.VStack; iOS UIKit uses UIStackView or SwiftUI. For navigation, wire NavigationLink in SwiftUI or navigationController.pushViewController in UIKit. For onClick, attach a tap gesture recognizer or button tap handler. Apply NSAppearance (macOS) or UIAppearance (iOS) for styling. Focus and hover states are platform-dependent: macOS supports focus ring via NSView.focusRingType; iOS supports focus on tvOS via canBecomeFocused() and didUpdateFocus. Replicate border and background color transitions via CABasicAnimation or SwiftUI animation modifiers.

- **WinUI 3**: Windows uses Microsoft.UI.Xaml.Controls.Card or a custom UserControl. Wrap content in a StackPanel or Grid for layout. For navigation, use a HyperlinkButton or navigate with Frame.Navigate(); for onClick, attach a Click event handler to the card or a Button within it. Apply VisualStateManager to define visual states for Normal, Hover, Focused, and Pressed. Set Foreground (text color) and Background from theme resources (equivalent to apt-* tokens). Pointer-over state triggers the hover appearance; focus applies a focus rectangle (default behavior in WinUI). Ensure KeyDown handler for Enter/Space keys if using a custom button-like element. Content is defined via Child (single item) or DataTemplate binding.

## Design Decisions

1. **href takes precedence over onClick** — When both props are provided, the component renders as an anchor and executes onClick before navigation. This prioritizes semantic HTML and browser affordances (middle-click, ⌘-click, history, status bar URL preview) while allowing side effects (analytics, state mutation) to occur first.

2. **div[role="button"] for onClick** — The component uses a div with role="button" rather than a native `<button>` because the card's flow content (paragraph `<p>` for description, div for meta) is not valid inside a native button element. A div allows arbitrary children and is semantically correct when paired with role="button" and keyboard handlers.

3. **LinkComponent prop for router integration** — The LinkComponent prop accepts a wrapper component (e.g., Next.js Link or React Router Link) without hard-coding a dependency. The prop follows the `to` naming convention (not `href`) to match the family's single injection pattern across all blocks that accept router components.

4. **Interactive styling only when interactive** — Hover, focus, and cursor-pointer are applied conditionally based on whether href or onClick is provided. This avoids misleading static cards into appearing interactive and prevents unnecessary state management.

5. **No built-in aria-label or aria-description** — The component relies on its rendered content (title, identifier, description) to be self-describing. Implementers should ensure context makes the purpose of each field clear or add aria-attributes at the parent level if more explicit labeling is needed.

## Compliance

Not applicable: ResourceCard does not involve authentication, authorization, sensitive data handling, network requests, data persistence, or other compliance-critical behaviors. Standard web accessibility guidelines (WCAG 2.1 AA) apply to the rendered component; focus visibility and keyboard activation meet baseline requirements.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | (cookbook update) | Initial creation |
