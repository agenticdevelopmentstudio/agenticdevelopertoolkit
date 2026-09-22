---
id: 00f63479-58b8-47e3-9ac7-7f1b944a5007
title: Permission Toggles
domain: agenticdevelopercookbook://ingredients/permission-toggles
type: ingredient
version: 1.0.1
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Four-button toggle group for CRUD permissions, respecting parent capability
  ceilings.
platforms:
- typescript
- web
tags:
- permissions
- crud
- toggle-group
depends-on: []
related: []
references: []
---

# Permission Toggles

## Overview

A toggle button group for managing CRUD (Create, Read, Update, Delete) permissions. The component renders four independent toggle buttons, one for each permission type. When a parent permission context is provided, capabilities forbidden by the parent are rendered disabled and visually suppressed, preventing child permissions from exceeding parent permissions. The component emits permission changes via callback, with values automatically clamped to parent constraints.

## Behavioral Requirements

- **must-render-four-buttons**: The component MUST render exactly four toggle buttons, one for each CRUD capability (Create, Read, Update, Delete).
- **must-enforce-parent-ceiling**: When a `parent` Crud value is provided, the component MUST prevent toggling any capability that the parent disallows. The button for that capability MUST be rendered in a disabled state.
- **must-clamp-emitted-values**: The `onChange` callback MUST never receive a Crud value that violates parent permissions. If a parent disallows a capability, that capability's value in the emitted object MUST be false, even if the user's action would enable it.
- **must-not-toggle-when-disabled**: When the `disabled` prop is true, toggling any button MUST have no effect.
- **must-suppress-blocked-capability-visual**: When a capability is blocked by parent permissions, the button MUST be rendered in a visually disabled state (cursor-not-allowed, reduced opacity).
- **must-toggle-on-click**: Clicking an enabled button MUST invert the corresponding capability in the Crud value.
- **must-announce-pressed-state**: Each button MUST have an `aria-pressed` attribute that reflects whether the capability is currently enabled (true) or disabled (false).
- **must-provide-title-text**: Each button MUST have a title attribute describing its action. When blocked by parent, the title MUST read "${KEY} is not permitted by the parent". When not blocked, the title MUST read "Enable ${KEY}" or "Disable ${KEY}" based on current state.
- **must-group-buttons**: The container MUST have `role="group"` and `aria-label="CRUD permissions"` to announce the collection as a unified control group.
- **must-label-buttons**: Each button MUST display the single-letter label for its capability: C for Create, R for Read, U for Update, D for Delete.

## Appearance

- **Container**: Flex layout with horizontal direction, centered vertical alignment, 4px gap between buttons.
- **Button size**: 28×28px (7 rem units at 4px base).
- **Border radius**: 6px (rounded-md).
- **Border width**: 1px.
- **Font**: weight 600 (semibold), size 12px (text-xs).
- **Padding**: Flexbox centering with justify-center and items-center.
- **Transition**: color changes animate with CSS transitions.

### Default (off) state colors:
- **Border**: `apt-border` token.
- **Background**: `apt-bg` token (full opacity).
- **Text**: `apt-text-muted` token.
- **Hover text**: `apt-text` token (brighter on hover).

### Enabled (on) state colors:
- **Border**: `apt-gold` token.
- **Background**: `apt-gold` token at 20% opacity.
- **Text**: `apt-gold-bright` token.

### Disabled or blocked state:
- **Cursor**: `not-allowed`.
- **Opacity**: 40% (0.4).
- **Hover text**: `apt-text-muted` (suppressed hover effect).

## States

| State | Appearance Change |
|-------|------------------|
| Off (default) | Muted text, neutral border and background. Hovering brightens text unless disabled. |
| On (enabled) | Gold border and semi-transparent gold background, bright gold text. |
| Disabled (global) | Reduced opacity (0.4), cursor-not-allowed. Hover effect suppressed. |
| Blocked by parent | Reduced opacity (0.4), cursor-not-allowed. Hover effect suppressed. Appears visually off regardless of value. |
| Focused | Receives focus via keyboard navigation. No special visual indicator in source; platform focus styles apply. |

## Accessibility

- **Role**: Each button is a standard `<button>` element. Container has `role="group"`.
- **Pressed state announcement**: Each button MUST use `aria-pressed` to announce whether the permission is enabled or disabled.
- **Labels**: Each button has a visible single-letter label (C, R, U, D) and a title attribute providing context.
- **Keyboard navigation**: Buttons are focusable and activate on Space or Enter (native button behavior).
- **Group label**: The container's `aria-label="CRUD permissions"` announces the purpose of the group.
- **Disabled state announcement**: When a button is disabled (either globally or by parent), the `disabled` attribute and visual suppression (opacity, cursor) communicate unavailability to assistive technology and keyboard users.
- **Minimum tap target**: Buttons are 28×28px. Per Apple HIG and Material Design 3, touch targets SHOULD be at least 44×44pt; 28×28px falls below this standard. This component prioritizes space efficiency in permission matrices. NEEDS REVIEW: Verify whether 28×28px is acceptable for the target use case (dense forms, permission grids) or whether larger targets are required per accessibility audit.
- **Color dependency**: Enabled and disabled states are distinguished by color change and opacity. Differentiation also includes cursor style and text content, reducing reliance on color alone.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| perm-001 | must-render-four-buttons | `value={c: false, r: false, u: false, d: false}` | Four buttons rendered, labeled C, R, U, D. |
| perm-002 | must-toggle-on-click | `value={c: false, r: false, u: false, d: false}`, user clicks C button | `onChange` called with `{c: true, r: false, u: false, d: false}`. |
| perm-003 | must-announce-pressed-state | C button with `value.c === true` | Button has `aria-pressed="true"`. |
| perm-004 | must-announce-pressed-state | C button with `value.c === false` | Button has `aria-pressed="false"`. |
| perm-005 | must-provide-title-text | C button enabled, `value.c === false` | Title reads "Enable C". |
| perm-006 | must-provide-title-text | C button enabled, `value.c === true` | Title reads "Disable C". |
| perm-007 | must-enforce-parent-ceiling | `parent={c: false, r: true, u: true, d: true}`, user clicks C button | Button is disabled. `onChange` not called. |
| perm-008 | must-clamp-emitted-values | `parent={c: false, r: true, u: true, d: true}`, `value={c: true, r: true, u: true, d: true}` | C button appears off (visually suppressed). Clicking R, U, or D works normally. |
| perm-009 | must-suppress-blocked-capability-visual | `parent={c: false, r: true, u: true, d: true}` | C button has `disabled` attribute and `opacity: 0.4` applied. |
| perm-010 | must-provide-title-text | C button blocked by parent | Title reads "C is not permitted by the parent". |
| perm-011 | must-not-toggle-when-disabled | `disabled={true}`, user clicks any button | No button responds. `onChange` not called. |
| perm-012 | must-group-buttons | Component rendered | Container has `role="group"` and `aria-label="CRUD permissions"`. |
| perm-013 | must-label-buttons | Component rendered | Buttons display text content C, R, U, D. |

## Edge Cases

- **Parent disallows all capabilities**: `parent={c: false, r: false, u: false, d: false}`. All four buttons render disabled. User cannot enable any capability. `onChange` is never called.
- **Value violates parent constraint before mount**: `value={c: true, r: true, u: true, d: true}` but `parent={c: false, r: true, u: true, d: true}`. The component does not correct the value prop; it only prevents further violations via user interaction. The C button appears off due to the condition `on = value[key] && !blockedByParent`. The parent ceiling is enforced on toggle, not retroactively on render.
- **Parent is undefined**: When `parent` is not provided, all capabilities are treated as unrestricted. `blockedByParent` is false for all buttons.
- **Disabled and blocked simultaneously**: When `disabled={true}` and a capability is also `blockedByParent`, both conditions suppress the button. The behavior is identical to either condition alone.
- **Rapid clicks**: Clicking a button invokes `toggle()` synchronously, calling `onChange` immediately. Multiple rapid clicks generate multiple `onChange` calls without debouncing.
- **Unmount during transition**: The transition-colors CSS class applies to color changes. If the component unmounts, the transition is interrupted but causes no error.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `value` | `Crud` (object with `c`, `r`, `u`, `d` boolean keys) | Required | Current CRUD permission state. |
| `parent` | `Crud` (optional) | `undefined` | Parent/ceiling permissions. Capabilities forbidden by parent cannot be toggled on. |
| `disabled` | `boolean` | `false` | When true, all buttons are non-interactive. |
| `onChange` | `(next: Crud) => void` | Required | Callback invoked when user toggles a button. Emitted value is clamped to parent constraints. |

## Deep Linking

Not applicable: This component is a form control, not a navigable page or standalone feature.

## Localization

Not applicable: The component displays single-letter labels (C, R, U, D) that are standard CRUD abbreviations and do not require translation. Title attributes and aria-label are hardcoded in English and are part of the component's internal behavior, not localization strings exposed to applications.

## Accessibility Options

- **Reduce Motion**: The component applies `transition-colors` animation when properties change. NEEDS REVIEW: Should detect and respect `prefers-reduced-motion` media query to conditionally disable the transition class.
- **Increase Contrast**: The default and enabled state colors (`apt-text-muted`, `apt-text`, `apt-gold`, `apt-gold-bright`) are defined by the design system's color tokens. If the design system provides high-contrast variants, the component inherits them via token substitution. The component itself does not implement contrast overrides.
- **Differentiate Without Color**: Enabled vs. disabled state is distinguished by color, opacity, cursor, and text content. Reliance on color alone is mitigated by opacity change and cursor style, but not fully eliminated. An audit of the `apt-gold` vs. neutral color difference is recommended to confirm sufficient contrast and differentiation for users with color blindness.

## Feature Flags

Not implemented in source. The component has no built-in feature flag mechanism.

## Analytics

Not implemented in source. The component does not emit analytics events. Applications using the component SHOULD track `onChange` calls if analytics are needed.

## Privacy

- **Data collected**: None. The component does not collect, transmit, or log any data.
- **Storage**: None. The component does not persist any data.
- **Transmission**: None. No data leaves the component.
- **Retention**: Not applicable.

## Logging

Not implemented in source. The component does not emit console logs or structured logging.

## Platform Notes

- **React/Web**: Source is a functional React component using TypeScript. Uses `cn()` utility for conditional Tailwind class application. Renders a `<div>` container with a `<button>` element for each CRUD capability. Event handling via `onClick` and native button `disabled` attribute. Styling via Tailwind CSS classes with design system color tokens (`apt-gold`, `apt-border`, `apt-bg`, `apt-text-muted`, `apt-text`, `apt-gold-bright`). No external component dependencies beyond the `cn()` utility and the `crud.ts` module that exports `CRUD_KEYS`, `CRUD_LETTER`, and types.

- **SwiftUI**: Start with a `HStack` containing four `Toggle` or `Button` elements arranged horizontally with 4pt spacing. Each button displays a text label and responds to a tap gesture. Use a state variable to track which capabilities are enabled. Parent constraint enforcement requires conditional logic to disable and visually suppress buttons. Use `.disabled()` modifier and opacity control to suppress blocked capabilities.

- **Compose (Android/Kotlin)**: Start with a `Row` containing four `OutlinedButton` or `FilterChip` elements. Use `Modifier.size(28.dp)` for button dimensions. Each button displays a single letter. Parent constraint enforcement requires state management and conditional `enabled` parameter. Use `alpha()` or `GraphicsLayer` to reduce opacity of blocked buttons. Accessibility via `semantics { contentDescription = ... }` and `ToggleableRole` if using FilterChip.

- **AppKit / UIKit**: Use `NSStackView` (macOS) or `UIStackView` (iOS) with `distribution = .fillEqually` and `spacing = 4`. Add four `NSButton` or `UIButton` subviews. Size each button to 28×28pt. Parent constraint enforcement requires delegate or closure callbacks to validate state changes and disable buttons conditionally. Use `isEnabled` and `alphaValue` / `alpha` to reflect disabled/blocked state.

- **WinUI 3**: Start with a `StackPanel` with `Orientation="Horizontal"` and `Spacing="4"`. Add four `ToggleButton` or `Button` elements. Set each button's `Width="28"` and `Height="28"`. Define a `ControlTemplate` or use `VisualStateManager` to apply styling for Off, On, Disabled, and BlockedByParent states. Parent constraint enforcement requires a `Command` or `Click` event handler to validate changes and set `IsEnabled="False"` for blocked buttons. Use `Foreground` and `BorderBrush` bindings to swap color tokens for on/off states.

## Design Decisions

- **Parent ceiling enforcement at interaction time, not at render**: The component does not validate or correct the `value` prop against `parent` on mount. Instead, enforcement occurs only during user interaction via the `toggle()` function. If `value` violates `parent` on initial render, the button will appear off (due to the `on = value[key] && !blockedByParent` calculation) but the component does not emit a corrected value. This design assumes the parent (caller) is responsible for providing a valid initial state. A stricter design would validate on mount and call `onChange` with a corrected value; this design trusts the caller.

- **28×28px button size**: The component prioritizes space efficiency and density in permission matrices or settings panels. 28px falls below the 44×44pt recommended minimum for touch targets per Apple HIG and Material Design 3. This is acceptable in contexts where multiple permission toggles are presented in a compact grid (e.g., a settings table), but not suitable for standalone buttons or contexts where users have dexterity limitations. Implementations should confirm this size against their accessibility audit and use case.

- **Visual suppression of blocked capabilities via opacity and visual state**: Blocked capabilities are rendered disabled and visually suppressed (opacity: 0.4) rather than hidden. This allows users to understand what permissions exist and why they cannot be enabled. Hiding blocked buttons would require less space but would sacrifice discoverability of the permission structure.

- **Synchronous emit on toggle**: The `onChange` callback is invoked synchronously during the click handler. There is no debouncing, throttling, or asynchronous state updates. Rapid clicks generate rapid emissions. Applications that need to batch or debounce permission changes should do so in their own state management.

- **Single-letter labels**: Abbreviating to C, R, U, D minimizes visual space and assumes the user understands CRUD as a standard concept in permission modeling. Full-text labels (Create, Read, Update, Delete) would require more space and are not localized.

## Compliance

Color contrast compliance depends on design system color token values meeting WCAG 2.1 Level AA standards (4.5:1 for text, 3:1 for graphical elements). Touch target sizing compliance requires use-case assessment, as noted in Accessibility section.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.1 | 2026-09-22 | Mike Fullerton | Revision pass: clarify Reduce Motion gap, fold Compliance concerns into earlier sections |
| 1.0.0 | 2026-09-22 | | Initial creation |
