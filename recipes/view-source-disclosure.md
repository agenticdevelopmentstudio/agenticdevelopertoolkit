---
id: 16e99364-8af3-40cb-beaf-d5a66a2fa2c0
title: View Source Disclosure
domain: agenticdevelopertoolkit://recipes/view-source-disclosure
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Collapsible disclosure component that reveals raw document source text on
  demand.
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

# View Source Disclosure

## Overview

A footer disclosure component that permits readers to view and copy the raw source of a document without parsing or transformation. The disclosure is deliberately understated—rendered as quiet chrome at the document's end—designed for readers actively seeking the markdown, not a feature meant to catch attention. The component is uncontrolled; once opened by the reader, state remains under the reader's control.

## Behavioral Requirements

- **must-render-trigger-button**: Component MUST render a button element that acts as the disclosure trigger.
- **must-render-label**: The trigger MUST render the provided `label` prop (defaults to "View source").
- **must-render-chevron-icon**: The trigger MUST render a chevron-right icon that visually indicates the disclosure state.
- **must-toggle-on-click**: Clicking the trigger MUST toggle the disclosure between open and closed states.
- **must-start-closed-by-default**: The disclosure MUST start in the closed state unless the `defaultOpen` prop is explicitly set to `true`.
- **must-render-source-verbatim**: When open, the component MUST render the `source` prop text exactly as provided, without parsing or transformation.
- **must-not-parse-markdown**: The component MUST NOT interpret, parse, or render the source text as markdown or any other format.
- **must-render-source-in-pre-tag**: The source text MUST be rendered within a `<pre>` element to preserve whitespace and line breaks.
- **must-rotate-chevron-on-open**: The chevron icon MUST rotate 90 degrees when the disclosure is open and return to its default angle when closed.
- **must-wrap-text-not-truncate**: Text in the revealed source MUST wrap to the container width rather than truncate.
- **must-scroll-horizontally-for-long-lines**: When a single unbreakable token (long URL, table rule) exceeds the container width, the source area MUST scroll horizontally without wrapping that token.
- **must-accept-className-prop**: The component MUST accept and apply a `className` prop to customize styling.
- **must-accept-html-attributes**: The component MUST accept and pass through standard HTML `div` attributes (via spread `...rest`).
- **must-set-aria-expanded**: The trigger button MUST set `aria-expanded` to `true` when open and `false` when closed.
- **must-conditionally-set-aria-controls**: When the disclosure is open, the trigger MUST set `aria-controls` to the panel's ID; when closed, `aria-controls` MUST NOT be set.

## Appearance

- **Container margin**: Top margin of 8 units, top border as a hairline rule in subtle border color, padding-top of 4 units
- **Container border**: Top border only; width 1px; color `var(--color-border-subtle)`
- **Trigger styling**: Inline flex layout, items centered, gap of 1.5 units; monospace font, font-size extra small (xs), text color `var(--color-text-dim)` at default, `var(--color-text-secondary)` on hover
- **Trigger button type**: `type="button"` (not submit or reset)
- **Chevron icon size**: 3 units × 3 units (h-3 w-3)
- **Chevron stroke width**: 2.5 units
- **Chevron rotation**: 90 degrees when open; transition duration 150ms
- **Source panel styling**: Top margin 3 units, padding 4 units, border-radius medium (md), background `var(--color-surface-raised)`, border 1px `var(--color-border-subtle)`, font monospace, font-size extra small, text color `var(--color-text-secondary)`, line-height relaxed
- **Source panel overflow**: Horizontal scroll when needed (`overflow-x-auto`), text wraps by default (`whitespace-pre-wrap`)

## States

| State | Appearance change |
|-------|------------------|
| Default (closed) | Chevron points right (0°), source panel not rendered |
| Open | Chevron rotates 90° to point down, source panel visible below trigger |
| Hover (on trigger) | Trigger text color changes from dim to secondary |

## Accessibility

- **Role**: The trigger is a native button element; the source panel is a `<pre>` element (implicit code role).
- **Expanded state**: The button MUST announce expanded/collapsed state via `aria-expanded`.
- **Panel association**: The button MUST associate the panel via `aria-controls` (only when open, per source implementation).
- **Label**: The trigger text serves as the button's accessible label via its text content.
- **Keyboard navigation**: As a native button, the trigger is keyboard accessible; Enter or Space activates it. No custom keyboard handling is required.
- **Assistive technology**: Screen readers will announce "View source, button, expanded" (or "collapsed") and read the panel content when opened.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| disclosure-001 | must-render-trigger-button, must-render-label | No props (defaults) | Trigger button renders with text "View source" |
| disclosure-002 | must-render-chevron-icon | No props | Chevron-right icon renders inside trigger |
| disclosure-003 | must-start-closed-by-default | No props | Disclosure starts closed; source panel is not in DOM |
| disclosure-004 | must-start-closed-by-default, must-render-source-in-pre-tag | `defaultOpen={true}` | Disclosure starts open; source panel is in DOM and visible |
| disclosure-005 | must-toggle-on-click, must-render-source-verbatim, must-not-parse-markdown | Click trigger when closed; `source="# Heading\n\n- List item"` | Panel appears showing raw text "#Heading" and "-List item", not parsed as markdown |
| disclosure-006 | must-toggle-on-click | Click trigger when open | Panel closes and is removed from DOM |
| disclosure-007 | must-rotate-chevron-on-open | Click trigger to open | Chevron rotates to 90° with 150ms transition |
| disclosure-008 | must-rotate-chevron-on-open | Click trigger to close | Chevron rotates back to 0° with 150ms transition |
| disclosure-009 | must-wrap-text-not-truncate | `source="Short line\nVery long line that would exceed container width"` in narrow viewport | Long line wraps to multiple lines within container; does not overflow or truncate |
| disclosure-010 | must-scroll-horizontally-for-long-lines | `source="https://example.com/path/to/very/long/url/that/is/one/unbreakable/token"` in narrow viewport | Source area allows horizontal scroll; the URL does not wrap |
| disclosure-011 | must-accept-className-prop | `className="custom-class"` | Custom class is applied to outer div alongside default classes |
| disclosure-012 | must-accept-html-attributes, must-accept-className-prop | `data-testid="source-disclosure"` | data attribute is present on outer div |
| disclosure-013 | must-set-aria-expanded | Click trigger to open, inspect button | `aria-expanded="true"` on button |
| disclosure-014 | must-set-aria-expanded | Click trigger to close, inspect button | `aria-expanded="false"` on button |
| disclosure-015 | must-conditionally-set-aria-controls | Trigger closed, inspect button | `aria-controls` attribute is absent |
| disclosure-016 | must-conditionally-set-aria-controls | Trigger open, inspect button and panel | `aria-controls` matches the panel's `id` |

## Edge Cases

- **Empty source string**: If `source=""`, the component MUST render an empty `<pre>` element; the button remains functional and toggles the empty panel open/close.
- **Very long source**: If `source` contains many thousands of lines, all must be rendered in the `<pre>` without truncation or lazy loading; scrolling performance depends on browser capability.
- **Whitespace-only source**: If `source` contains only whitespace (spaces, tabs, newlines), it MUST be rendered exactly as provided within the `<pre>`.
- **Special characters in label**: If `label` is a string containing HTML special characters (e.g., `"<test>"`), it MUST be rendered as text, not parsed as HTML.
- **ReactNode label**: If `label` is a ReactNode (e.g., a component), it MUST be rendered as such within the button.
- **Multiple instances**: Multiple ViewSourceDisclosure components on the same page MUST each maintain independent open/close state via their own `useState` hook and `useId` hook for unique panel IDs.
- **State after unmount/remount**: The component is uncontrolled; if unmounted and remounted, it resets to `defaultOpen` state.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `source` | `string` (required) | N/A | Raw document source text to reveal; rendered verbatim in `<pre>` |
| `label` | `ReactNode` | `"View source"` | Text or component rendered as the trigger's label |
| `defaultOpen` | `boolean` | `false` | Whether the disclosure starts open |
| `className` | `string` | `""` | Additional CSS classes to apply to the outer `<div>` |

## Deep Linking

Not applicable: this component is a disclosure toggle for static source content and does not navigate to or expose URLs.

## Localization

| String Key | Default (en) | Context |
|-----------|-------------|---------|
| `view-source-trigger-label` | "View source" | Default trigger label; can be overridden via `label` prop |

## Accessibility Options

- **Reduce Motion**: The chevron rotation transition (150ms) SHOULD respect `prefers-reduced-motion`. When this preference is active, the chevron SHOULD change angle instantly without transition.
- **Increase Contrast**: The component uses `var(--color-text-dim)` and `var(--color-text-secondary)` on hover. These CSS variables SHOULD be defined to meet WCAG AA contrast requirements (4.5:1 for text) even when Increase Contrast is active.
- **Differentiate Without Color**: The component does not rely on color alone to convey state; the chevron's rotation provides a visual indicator independent of color.

## Feature Flags

Not applicable: this component does not implement feature-flagged behavior.

## Analytics

Not applicable: this component does not emit analytics events. Host applications MAY track disclosure open/close events if desired, but the component itself does not.

## Privacy

- **Data collected**: None. The component receives `source` (raw document text) but does not transmit, store, or log it.
- **Storage**: No persistent storage.
- **Transmission**: The source text is never transmitted; it resides on the client.
- **Retention**: No data retention; state is ephemeral and lost on page navigation or refresh.

## Logging

Not applicable: this component does not emit logs.

## Platform Notes

- **React/Web**: Implemented using React hooks (`useState`, `useId`). Uses Lucide icon (`ChevronRight`) for the arrow. Styling via Tailwind utility classes with CSS variable references (`var(--color-*)`) for theme integration. The component is a function component with uncontrolled state.
- **Compose**: On Android, implement using `var Box` for layout, `Button` for the trigger, `Icon` for the chevron, and `Text` for the source. Use a mutable state holder or `remember { mutableStateOf(defaultOpen) }` for open/close state. Use `Modifier.border()`, `Modifier.padding()`, and `Modifier.clip()` to match the appearance. The chevron rotation can be animated with `animateFloatAsState()`.
- **SwiftUI**: On iOS/macOS, implement using `DisclosureGroup` or a custom `VStack` with a `Button` trigger and conditional `Text` or `ScrollView` containing `Text(.monospaced())` for the source. Use `@State` for the open/close binding. Apply frame, padding, and border modifiers to match appearance. Use `scaleEffect()` and `.rotation3DEffect()` or a rotation gesture modifier to animate the chevron.
- **AppKit / UIKit**: On older macOS or iOS targets, implement using `NSButton` (AppKit) or `UIButton` (UIKit) for the trigger, and `NSTextView` (AppKit) or `UITextView` (UIKit) with monospace font for the source display. Manage state with a boolean property and toggle it on button action. Use `CABasicAnimation` or `UIView.animate()` to rotate the chevron icon by 90°. Use `NSStackView` (AppKit) or `UIStackView` (UIKit) to manage layout.
- **WinUI 3**: On Windows, implement using `Button` from the Windows.UI.Xaml.Controls namespace as the trigger, with a `FontIcon` (Segoe MDL2 Assets glyph code U+E70B for chevron-right) rotated via a `RotateTransform`. Use `TextBlock` with `FontFamily="Cascadia Code"` and `FontSize="10"` for monospace source display. Place both in a `StackPanel` with `Orientation="Vertical"`. Use a `VisualState` or `StoryBoard` with a `DoubleAnimation` to animate the chevron's `Angle` property (0° to 90°) over 150ms. Bind the button's `Click` event to toggle `IsOpen`, and conditionally render the `TextBlock` based on that state using a `Visibility` converter.

## Design Decisions

- **No composition of framed `Disclosure` component**: The comment in the source explains that composing a reusable `Disclosure` component (which provides a framed card, rounded border, header styling, chevron styling, and content frame) would require nine visual overrides to suppress its styling to achieve this look. Maintaining two disclosures avoids a standing coupling that could silently break this component if the reusable one is restyled. Source fidelity: this encoding of the decision preserves the separation of concerns.
- **Uncontrolled state**: The component does not accept `open` and `onOpenChange` props; state is managed internally via `useState`. Once opened, the reader owns the state. This design reflects the component's role as a low-priority reader convenience, not a controlled UI element in a host form or flow.
- **Conditional `aria-controls`**: The implementation sets `aria-controls` only when the panel exists (open state) to avoid the axe accessibility violation "aria-valid-attr-value" (a reference to a nonexistent element is an authoring error, not a harmless no-op). `aria-expanded` alone announces the state to assistive technology.
- **Verbatim rendering**: The source text is rendered exactly as provided; no escaping of HTML entities, no markdown parsing, no syntax highlighting. This is intentional: the component is a raw-text viewer, and the host owns syntax highlighting or transformation if needed.
- **Quiet styling**: Deliberately muted colors and small type size position this as chrome, not content. A reader seeking the markdown will look for it; one who doesn't should not notice the disclosure.

## Compliance

Not applicable: this component does not require compliance audit beyond standard accessibility checks (aria-expanded, aria-controls, keyboard navigation, color contrast), which are already defined in the Accessibility section.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
