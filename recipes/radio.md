---
id: 3b509297-83b2-4a5b-a331-56d0d4be548d
title: Radio
domain: agenticdevelopercookbook://ingredients/radio
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Single-selection control in a group where users pick one option from multiple
  mutually exclusive choices.
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

# Radio

## Overview

A radio button is a single-selection control used within a radio group to allow users to select exactly one option from a set of mutually exclusive choices. The component consists of a RadioGroup container that manages the group's state and RadioGroupItem elements representing individual options. Built on Base UI radio primitives with theme tokens for styling.

## Behavioral Requirements

- **must-render-in-group**: RadioGroupItem MUST only function as part of a RadioGroup container.
- **must-indicate-selection**: RadioGroupItem MUST display a visual indicator (filled dot) when selected.
- **must-hide-indicator-when-unselected**: The inner indicator MUST NOT be visible when the radio button is unselected.
- **must-support-disabled-state**: RadioGroupItem MUST be disableable, preventing user interaction and reducing opacity when disabled.
- **must-support-focus-visible**: RadioGroupItem MUST display a focus-visible border and ring styling when focused via keyboard navigation.
- **must-apply-theme-tokens**: RadioGroupItem MUST use theme tokens (`apt-border`, `apt-bg`, `apt-gold`) for styling.
- **must-transition-colors**: RadioGroupItem MUST smoothly transition color changes when state changes occur.
- **must-group-spacing**: RadioGroup MUST apply consistent spacing between radio items (2.5 units vertically and horizontally).

## Appearance

- **Size**: 16×16px (size-4 in Tailwind)
- **Corner radius**: Fully rounded (50% / `rounded-full`)
- **Padding**: None (control is sizing-based)
- **Font**: N/A (no text in the control itself; label text is external)
- **Background**: `apt-bg` (theme token for default state background)
- **Border**: 1px solid `apt-border` (default state); 1px solid `apt-gold` when checked or focused
- **Indicator**: 8×8px inner circle, `apt-gold` when checked; hidden when unchecked
- **Shadow**: None
- **Min/Max size**: Fixed at 16×16px; shrink-0 prevents size changes due to flex containers
- **Transition**: All color changes transition smoothly via CSS transitions

## States

| State | Appearance change |
|-------|------------------|
| Default | 16×16px circle, `apt-border` border, `apt-bg` background, no indicator |
| Checked | Border changes to `apt-gold`, inner `apt-gold` dot appears (8×8px) |
| Focused | Border and ring added with `apt-gold`, ring opacity set to 25% |
| Disabled | Opacity reduced to 50%, pointer events disabled, cursor changes to not-allowed |
| Checked + Disabled | Checked appearance combined with disabled opacity |

## Accessibility

- **Role/trait**: Radio button (native semantic role via Base UI RadioPrimitive.Root)
- **Label requirements**: Labels are external to the RadioGroupItem; the form must associate labels via standard form patterns (e.g., `<label htmlFor="radio-id">` or wrapping)
- **Announce state changes**: Checked/unchecked state is automatically announced by assistive technology via the semantic radio role
- **Minimum tap target**: 16×16px (below WCAG minimum of 44×44px; container layout or wrapper should ensure adequate spacing)
- **Keyboard navigation**: MUST support arrow key navigation between options within the radio group (provided by Base UI RadioGroup)
- **Focus indicator**: Visible focus ring (gold border and ring) provides keyboard focus indication

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| radio-001 | must-indicate-selection | RadioGroupItem with checked state | Filled `apt-gold` dot visible inside the 16×16px circle |
| radio-002 | must-hide-indicator-when-unselected | RadioGroupItem with unchecked state | No indicator dot visible |
| radio-003 | must-support-disabled-state | RadioGroupItem with disabled prop | Opacity 50%, pointer-events-none, cursor-not-allowed |
| radio-004 | must-support-focus-visible | RadioGroupItem with keyboard focus | `apt-gold` border and ring with 25% opacity visible |
| radio-005 | must-group-spacing | RadioGroup with multiple RadioGroupItems | 2.5 unit (10px) gap between items vertically and horizontally |
| radio-006 | must-apply-theme-tokens | RadioGroupItem in default state | Border color is `apt-border`, background is `apt-bg` |
| radio-007 | must-transition-colors | RadioGroupItem state change from unchecked to checked | Color change animates smoothly via CSS transition |

## Edge Cases

- **Null/empty input**: RadioGroup with no children renders as an empty grid; RadioGroupItem requires a parent RadioGroup for proper functionality.
- **Boundary values**: Size is fixed at 16×16px; no resizing or scaling is applied. Disabled state always reduces opacity to exactly 50%.
- **Concurrent access**: Not applicable; the component is a single-threaded UI control managed by React on the main thread.
- **Error states**: RadioGroupItem has no error state defined in the source. Errors are handled at the form level, not the component level.
- **Offline/disconnected state**: Not applicable; the component is a client-side UI primitive with no network behavior.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `className` | string | `undefined` | Additional CSS classes to apply to RadioGroupItem or RadioGroup for customization |
| `disabled` | boolean | `false` | Disables the radio button, preventing interaction |
| `checked` | boolean | `false` | Sets the radio button to checked state (typically managed by RadioGroup) |
| `data-slot` | string | `"radio-group"` or `"radio-group-item"` | Data attribute for identifying component hierarchy |

## Deep Linking

Not applicable: Radio buttons are form controls within a page context, not independent navigable endpoints.

## Localization

Not applicable: The radio button control itself contains no user-facing text. Labels and option text are provided by the consuming form and are externally localized.

## Accessibility Options

- **Reduce Motion**: The `transition-colors` class applies transitions; components using reduce-motion should override with `transition-none` in their stylesheet.
- **Increase Contrast**: The `apt-gold` and `apt-border` tokens are theme-specific; high-contrast themes should override token values to ensure sufficient contrast ratio (WCAG AA 4.5:1 for UI components).
- **Differentiate Without Color**: Not applicable; the component uses both color (gold vs. border) and shape (dot appears/disappears) to indicate state, providing non-color differentiation.

## Feature Flags

Not applicable: The component is a stable UI primitive with no experimental or feature-flagged behavior in the source.

## Analytics

Not applicable: The component itself emits no analytics events. Event tracking is the responsibility of the form or page consuming the radio group.

## Privacy

- **Data collected**: None; the component does not collect or log user data.
- **Storage**: None; state is ephemeral and managed in memory by React.
- **Transmission**: None; the component does not transmit data.
- **Retention**: Not applicable; no data is retained.

## Logging

Not applicable: The component does not implement logging. Debug logging is the responsibility of the consuming application.

## Platform Notes

- **React/Web**: Source uses Base UI `RadioGroup` and `Radio` primitives via `@base-ui/react/radio-group`. RadioGroup applies grid layout with gap-2.5 (10px) spacing. RadioGroupItem wraps RadioPrimitive.Root with inline styles for focus, checked, and disabled states using Tailwind classes and `data-*` selectors. The Indicator (hidden when unchecked via `data-[unchecked]:hidden`) shows as an 8×8px gold dot when checked. Reference: `/packages/web/packages/ui/src/components/radio.tsx`.
- **SwiftUI**: iOS Radio buttons are typically implemented using `Picker` with `segmentedPickerStyle()` or custom VStack with toggle-style buttons. Base UI's semantic HTML radio behavior maps to SwiftUI's `Picker` selections, with focus ring and color tokens translating to SwiftUI state and appearance modifiers.
- **Compose**: Android Material Design 3 provides `RadioButton` composable. Spacing between options uses Material Design's 16dp vertical spacing. Color tokens (`apt-gold`, `apt-border`) map to Material 3's `colorScheme` and `surfaceColorAtElevation` for semantic theming.
- **AppKit / UIKit**: macOS uses `NSButton(radioButtonWithTitle:)` or custom views. iOS and iPadOS use similar patterns with custom styling or `UISegmentedControl` for single-selection scenarios. Focus and disabled states follow platform HIG conventions.
- **WinUI 3**: Windows uses `RadioButton` control from the WinUI 3 library. Control templates override default appearance to match design tokens. Spacing uses `StackPanel` with Spacing property (typically 10px to match gap-2.5). Focus states are managed via `VisualStateManager` with custom border and shadow brushes bound to color tokens. RadioButton grouping uses XAML `RadioButton` elements within a container, with `GroupName` property for mutual exclusion.

## Design Decisions

- **Size**: The 16×16px dimension is based on Tailwind's `size-4` class and is smaller than the WCAG AA 44×44px minimum tap target. This is acceptable for web components where the containing form or grid provides spacing and can increase the effective touch target. Consumers should ensure adequate padding or wrapper sizing when the component is used on mobile.
- **Color transitions**: Smooth `transition-colors` is applied to all state changes (checked, focused, disabled) to provide visual feedback without jarring state shifts. This follows modern UI conventions and can be disabled globally if `prefers-reduced-motion` is active.
- **Focus ring**: The focus-visible state uses a 2px ring with 25% opacity of `apt-gold`. This provides sufficient visibility without overwhelming the control, balancing accessibility with design aesthetic.
- **Disabled state**: Opacity reduction (50%) is the sole visual indicator for disabled state, combining with `pointer-events-none` and `cursor-not-allowed` to prevent interaction. High-contrast themes may need to override this with additional border or background changes to meet WCAG contrast requirements.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| [focus-visible-indicator](agenticdevelopercookbook://compliance/accessibility#focus-visible-indicator) | passed | Accessibility |
| [semantic-radio-role](agenticdevelopercookbook://compliance/accessibility#semantic-radio-role) | passed | Accessibility |
| [minimum-tap-target](agenticdevelopercookbook://compliance/accessibility#minimum-tap-target) | partial | Accessibility |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation from Base UI radio primitives |
