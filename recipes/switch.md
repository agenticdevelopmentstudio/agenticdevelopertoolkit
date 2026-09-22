---
id: 951b86ac-cf75-46ec-9746-d15fcb4618b4
title: Switch
domain: agenticdevelopercookbook://ingredients/switch
type: ingredient
version: 1.1.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A binary toggle control that displays on/off state with animated visual feedback.
platforms:
- typescript
- web
tags:
- form-control
- toggle
- interactive
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Switch

## Overview

A Switch is a binary toggle control that allows users to turn a setting on or off. The component displays its current state through color and animated position changes, with clear visual feedback for checked, unchecked, disabled, and focused states. It supports both controlled and uncontrolled usage patterns.

## Behavioral Requirements

- **must-toggle-on-click**: The Switch MUST change its checked state when the user clicks or taps it.
- **must-support-controlled**: The Switch MUST support controlled mode via `checked` prop combined with `onCheckedChange` callback.
- **must-support-uncontrolled**: The Switch MUST support uncontrolled mode via `defaultChecked` prop.
- **must-respect-disabled-state**: The Switch MUST prevent state changes when the `disabled` prop is `true`.
- **must-animate-position**: The Switch thumb MUST animate its horizontal position when transitioning between checked and unchecked states.
- **must-animate-colors**: The Switch MUST animate color changes when transitioning between checked and unchecked states.
- **must-render-inline**: The Switch MUST render as an inline-flex element for use within text or form layouts.
- **must-accept-class-prop**: The Switch MUST accept a `className` prop and merge it with internal styles.

## Appearance

- **Size**: 20px height × 36px width (h-5 w-9 in Tailwind's 4px unit scale)
- **Thumb size**: 16px × 16px (size-4 in Tailwind)
- **Border radius**: Fully rounded (border-radius on outer container and thumb)
- **Border**: 1px transparent border
- **Padding**: 2px horizontal (px-0.5 in Tailwind), 0px vertical
- **Background (unchecked)**: `apt-input` token color
- **Background (checked)**: `apt-gold` token color
- **Thumb color**: `apt-text` token color
- **Shadow**: Small shadow on thumb (shadow-sm)
- **Transition**: All transitions use standard duration (transition-colors on container, transition-transform on thumb)

## States

| State | Appearance change |
|-------|------------------|
| Unchecked (default) | Background uses `apt-input` color; thumb positioned at translate-x-0 (leftmost) |
| Checked | Background uses `apt-gold` color; thumb positioned at translate-x-4 (4px to the right) |
| Disabled | Opacity reduced to 50% (opacity-50); pointer-events disabled; cursor shows not-allowed |
| Focus-visible (keyboard) | 2px ring outline around container using `apt-gold/40` (40% opacity gold) |
| Checked + Disabled | Combines checked appearance with disabled opacity and cursor treatment |

## Accessibility

- **Role**: The underlying base-ui Switch.Root renders as a button element with the appropriate switch/toggle ARIA role.
- **State announcement**: The component exposes checked state via the `aria-checked` attribute, updated when state changes.
- **Keyboard support**: The component MUST be keyboard accessible via Tab navigation and Space/Enter to toggle.
- **Minimum tap target**: The outer container (36px × 20px) MAY not meet the 44×44pt minimum touch target on all platforms; consider wrapping in a larger interactive area for mobile contexts.
- **Disabled communication**: When disabled, the component MUST have `aria-disabled="true"` and the cursor MUST change to not-allowed.
- **Label association**: The component itself has no text content; a label element or aria-label MUST be provided by the consumer.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| switch-001 | must-toggle-on-click | Unchecked Switch, user clicks | State changes to checked; callback fires if controlled |
| switch-002 | must-toggle-on-click | Checked Switch, user clicks | State changes to unchecked; callback fires if controlled |
| switch-003 | must-support-controlled | Controlled Switch with `checked={true}` and `onCheckedChange` handler | Clicking fires callback; state reflects external prop |
| switch-004 | must-support-uncontrolled | Uncontrolled Switch with `defaultChecked={true}` | Clicking toggles visual state without external callback |
| switch-005 | must-respect-disabled-state | Disabled Switch, user clicks | State does not change; pointer-events disabled prevents click handling |
| switch-006 | must-animate-position | Toggle checked → unchecked | Thumb translates from translate-x-4 to translate-x-0 with smooth animation |
| switch-007 | must-animate-colors | Toggle checked → unchecked | Background color transitions from apt-gold to apt-input smoothly |
| switch-008 | must-render-inline | Switch rendered in text flow | Component displays as inline-flex (does not break text flow) |
| switch-009 | must-accept-class-prop | Switch with custom `className="my-custom-class"` | Custom class merges with internal classes; visual result reflects both |
| switch-010 | must-animate-colors | Disabled checked Switch | Background retains apt-gold color at 50% opacity; no animation on state change |

## Edge Cases

- **Rapid clicks**: Clicking or tapping rapidly SHOULD not toggle the state multiple times beyond what the underlying base-ui library debounces; behavior is determined by base-ui's internal event handling.
- **Disabled + controlled**: A controlled Switch with `disabled={true}` and an external prop change MUST reflect the new prop value even though user interaction is blocked.
- **Keyboard navigation in focus**: When focused via Tab, pressing Space or Enter MUST toggle the checked state if not disabled.
- **No label provided**: If the consumer does not provide an associated label or aria-label, the switch will lack semantic meaning for assistive technology; this is a consumer responsibility, not a component defect.
- **Small touch target on mobile**: The 36×20px dimensions may be smaller than touch-friendly targets (44×44pt) on mobile platforms; consumers SHOULD wrap the Switch or increase the interactive area.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `checked` | boolean | undefined | Controlled state; when present, component is controlled mode |
| `onCheckedChange` | function | undefined | Callback fired when user toggles state; signature: `(checked: boolean) => void` |
| `defaultChecked` | boolean | undefined | Initial state for uncontrolled mode |
| `disabled` | boolean | false | Disables user interaction and applies disabled styling |
| `className` | string | "" | Additional CSS class names merged with component's internal styles |

## Deep Linking

Not applicable: Switch is a form control component with no standalone deep-linking behavior. Deep linking is the responsibility of the containing page or application.

## Localization

Not applicable: Switch has no text content or user-facing strings. Labels and descriptions are provided by the consuming application.

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | Transitions are applied (transition-colors on the root, transition-transform on the thumb); the component does not respond to the prefers-reduced-motion media query. NEEDS REVIEW: Implement prefers-reduced-motion support to disable or minimize transitions when active. |
| Increase Contrast | The component uses `apt-gold` token (checked state) and `apt-input` token (unchecked state) from the design system. NEEDS REVIEW: Confirm that these tokens meet WCAG AA contrast ratio requirements (4.5:1 for text-equivalent state change). |
| Differentiate Without Color | The Switch communicates state through both color (apt-gold vs. apt-input) and position change (thumb translates 4px right when checked); the position change provides a non-color indicator for users who cannot distinguish colors. |

## Feature Flags

Not applicable: No feature flags are implemented in the source component. Feature flags, if needed, would be applied at the application or page level, not the component level.

## Analytics

Not applicable: The component does not emit analytics events internally. Event tracking is the responsibility of the consuming application via the `onCheckedChange` callback.

## Privacy

Not applicable: The Switch component does not collect, store, or transmit data. The component accepts and reflects boolean state only.

## Logging

Not applicable: The component does not perform logging. Debugging state changes is handled through React DevTools or the consumer's own logging.

## Platform Notes

- **React/Web**: Component wraps base-ui's `Switch.Root` and `Switch.Thumb`. Styles use Tailwind CSS with `apt-*` design tokens. Controlled via React props (`checked`, `onCheckedChange`, `defaultChecked`). Forward all remaining props to `SwitchPrimitive.Root` via spread operator.
- **SwiftUI**: Use `Toggle` view combined with custom styling to match appearance. Bind to a `@State` variable for controlled behavior. Apply gold and input color tokens conditionally based on toggle state; animate transitions with `.animation(.default)`. Respect `AccessibilityOptions.reduceMotion` to disable or minimize animations when preferred.
- **Compose**: Use `Switch` composable with `checked` and `onCheckedChange` parameters. Style the track and thumb using Material 3 color tokens mapped to apt-gold and apt-input. Apply `Modifier.disabled()` for disabled state. Disable animations when `LocalAccessibilityManager.current.reduceMotion` is true.
- **UIKit / AppKit**: Create a custom UISwitch subclass or compose with `UISwitch` wrapped in a view controller. Apply custom colors via `onTintColor` (checked) and `backgroundColor` (unchecked). Implement target-action for state change notifications. Check `UIAccessibility.isReduceMotionEnabled` to suppress animations when active.
- **WinUI 3**: Use the `ToggleSwitch` control from WinUI 3. Bind `IsOn` to a ViewModel property for controlled behavior. Apply custom colors via `ToggleSwitchOnForeground` and `ToggleSwitchOffForeground` resources; set to apt-gold and apt-input equivalents. Disable via `IsEnabled="false"`. Ensure focus rectangle visibility matches the Ring focus state; use `FocusVisualPrimaryBrush` and `FocusVisualSecondaryBrush` for styling. Check `UISettings.AnimationsEnabled` and suppress animations when false to honor Reduce Motion preferences.

## Design Decisions

- **Inline-flex layout**: The component uses `inline-flex` rather than `flex` to allow it to sit within text and form flows without breaking layout. This matches the source constraint and Web semantic expectations.
- **Transparent border**: A transparent 1px border is included to prevent layout shift when a focus ring is applied.
- **Thumb translation**: The thumb translates 4px (translate-x-4) to the right when checked, providing clear visual feedback without requiring the full container width. The 4px offset is derived from the 2px padding and 16px thumb size within the 36px container.
- **Animation over instant state**: Both color and position transitions animate, providing visual feedback that aligns with modern UI expectations. Animations improve perceived responsiveness.
- **Color token dependency**: The component relies on design system color tokens (apt-gold, apt-input, apt-text) being defined; if these tokens are unavailable, the component will fail to display correctly. This is a consumer responsibility.
- **Controlled + uncontrolled pattern**: The component supports both patterns; consumers choose based on their state management needs. The source does not force one pattern, allowing flexibility.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| Behavioral Requirements | passed | specification |
| Source Fidelity | passed | quality |
| Accessibility (partial) | incomplete | compliance |
| Touch Target Size | warning | accessibility |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.1.0 | 2026-09-22 | Mike Fullerton | Revise Accessibility Options markers: state facts, keep genuine gaps only; update Platform Notes with Reduce Motion guidance |
| 1.0.0 | 2026-09-22 | Generated | Initial creation from base-ui React source |
