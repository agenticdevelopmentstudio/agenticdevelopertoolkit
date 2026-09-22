---
id: a70a5906-e2c2-4e15-8b2c-913453ff3714
title: Reorder Control
domain: agenticdevelopertoolkit://recipes/reorder-control
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A pair of arrow buttons to move items up and down within a list, always visible
  with disabled state at boundaries.
platforms:
- typescript
- web
tags:
- ui
- reorder
- list
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Reorder Control

## Overview

A pair of arrow buttons (↑/↓) that enable users to move items up or down within a list. Unlike controls that hide on hover, this component is always visible, with disabled state used to indicate the boundaries (first and last item) rather than removing the button. The component accepts a subject string to personalize button labels, supports a busy state to indicate in-flight moves, and uses arrow icons (not chevrons) to distinguish reordering from disclosure actions.

## Behavioral Requirements

- **must-render-up-button**: Component MUST render an "up" button that, when clicked and not busy, calls the onMoveUp callback.
- **must-render-down-button**: Component MUST render a "down" button that, when clicked and not busy, calls the onMoveDown callback.
- **must-disable-up-button-when-cannot-move-up**: Component MUST set the up button's disabled attribute when canMoveUp is false.
- **must-disable-down-button-when-cannot-move-down**: Component MUST set the down button's disabled attribute when canMoveDown is false.
- **must-not-remove-buttons-at-boundaries**: Component MUST NOT remove buttons when canMoveUp or canMoveDown is false; it MUST display them in disabled state.
- **must-use-arrow-icons**: Component MUST use arrow-shaped icons to represent move direction (up and down), not chevrons or other shapes.
- **must-render-group-role**: Component MUST wrap both buttons in a container with role="group" to semantically group them.
- **must-provide-group-aria-label**: Component MUST provide an aria-label to the group container that includes the text "Reorder" and optionally the subject.
- **must-provide-button-aria-labels**: Each button MUST have an aria-label describing the action ("Move up" or "Move down") and optionally the subject.
- **must-provide-button-titles**: Each button MUST have a title attribute matching its aria-label for tooltip display.
- **should-support-custom-subject**: Component SHOULD append a subject string to button and group labels when the subject prop is provided.
- **must-handle-busy-state**: When busy is true, component MUST reduce opacity to 60% and set aria-disabled on both buttons and the group.
- **must-use-aria-disabled-not-disabled-when-busy**: Component MUST use aria-disabled (not the disabled HTML attribute) when busy to preserve keyboard focus.
- **must-guard-click-handlers-when-busy**: Click handlers for onMoveUp and onMoveDown MUST NOT fire when busy is true, even if the button is clicked.
- **must-render-decorative-icons**: Component MUST mark arrow icons as aria-hidden="true" because they are decorative (the aria-label conveys the meaning).
- **must-use-ghost-button-variant**: Component MUST use the ghost button variant, which provides transparent background styling.
- **must-use-icon-sm-size**: Component MUST use the icon-sm size variant for buttons, appropriate for inline icon buttons.
- **may-accept-custom-className**: Component MAY accept a custom className prop for additional styling applied to the outer container.

## Appearance

- **Corner radius**: 0 (inherited from ghost Button variant, no border radius)
- **Padding**: Gap between buttons is 0.5 (8px in Tailwind spacing scale)
- **Font**: Inherited from Button component (not directly styled)
- **Background**: Transparent (ghost variant)
- **Foreground/Text**: text-apt-text-muted (muted color applied to icons)
- **Border**: None (ghost variant)
- **Shadow**: None
- **Min/Max size**: Determined by icon-sm Button variant (typically 32×32px or smaller for inline use)

## States

| State | Appearance change |
|-------|-------------------|
| Default | Both buttons fully opaque, interactive if not at boundary |
| Up button at boundary (canMoveUp=false) | Up button appears disabled (reduced opacity, pointer events disabled), down button unaffected |
| Down button at boundary (canMoveDown=false) | Down button appears disabled (reduced opacity, pointer events disabled), up button unaffected |
| Busy/In-flight (busy=true) | Both buttons dimmed to opacity 60%, aria-disabled set on group and both buttons, click handlers guarded |
| Focused button | Standard focus styling from Button component (outline/ring) |

## Accessibility

- **Role/trait**: The outer container uses role="group"; each button is a standard button control.
- **Label requirements**: The group has an aria-label ("Reorder" or "Reorder subject"); each button has an aria-label with the direction and optional subject; title attributes provide tooltips.
- **Icon semantics**: Arrow icons are marked aria-hidden="true" because their meaning is conveyed by the button's aria-label.
- **State announcement**: aria-disabled on the group and buttons when busy; aria-busy on the group when busy (optional, used for state indication).
- **Disabled state**: When canMoveUp or canMoveDown is false, the button's disabled attribute is set; when busy, aria-disabled is set instead to preserve keyboard focus.
- **Keyboard navigation**: Buttons are fully keyboard accessible; disabled buttons are skipped by tab order; focused buttons can be activated via Enter or Space.
- **Minimum tap target**: Buttons use the icon-sm variant, which meets or approaches platform minimum tap targets (44×44pt iOS, 48×48dp Android, 40×40px web).

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| reorder-control-001 | must-render-up-button | canMoveUp=true, onMoveUp callback | Up button renders; clicking it calls onMoveUp |
| reorder-control-002 | must-render-down-button | canMoveDown=true, onMoveDown callback | Down button renders; clicking it calls onMoveDown |
| reorder-control-003 | must-disable-up-button-when-cannot-move-up | canMoveUp=false | Up button renders with disabled attribute; click does not call onMoveUp |
| reorder-control-004 | must-disable-down-button-when-cannot-move-down | canMoveDown=false | Down button renders with disabled attribute; click does not call onMoveDown |
| reorder-control-005 | must-not-remove-buttons-at-boundaries | canMoveUp=false, canMoveDown=true (first row) | Up button is present but disabled; down button is enabled |
| reorder-control-006 | must-not-remove-buttons-at-boundaries | canMoveUp=true, canMoveDown=false (last row) | Down button is present but disabled; up button is enabled |
| reorder-control-007 | must-use-arrow-icons | default | ArrowUp and ArrowDown icons from lucide-react are rendered |
| reorder-control-008 | must-render-group-role, must-render-group-aria-label | default | Outer span has role="group" and aria-label containing "Reorder" |
| reorder-control-009 | must-provide-button-aria-labels, must-provide-button-titles | default | Both buttons have aria-label and title attributes with "Move up" or "Move down" text |
| reorder-control-010 | should-support-custom-subject | subject="Work item" | Both button aria-labels and group aria-label include "Work item" text |
| reorder-control-011 | must-handle-busy-state | busy=true | Component opacity is 60%; aria-disabled set on group and buttons |
| reorder-control-012 | must-use-aria-disabled-not-disabled-when-busy | busy=true | aria-disabled attribute is set; disabled attribute is not set (buttons remain in tab order) |
| reorder-control-013 | must-guard-click-handlers-when-busy | busy=true, user clicks up or down button | onMoveUp and onMoveDown are not called; component ignores click |
| reorder-control-014 | must-render-decorative-icons | default | Arrow icons have aria-hidden="true" |
| reorder-control-015 | must-use-ghost-button-variant, must-use-icon-sm-size | default | Buttons use variant="ghost" and size="icon-sm" from Button component |
| reorder-control-016 | may-accept-custom-className | className="custom-class" | Custom class is applied to outer container alongside default classes |

## Edge Cases

- **Empty or undefined subject**: When subject is not provided or is an empty string, component MUST render button labels and group aria-label without a trailing subject suffix (e.g., "Move up" instead of "Move up "). Component MUST handle this gracefully without extra whitespace.
- **Rapid clicks while busy**: If the user clicks a button multiple times while busy is true, onMoveUp and onMoveDown MUST NOT be called; the click handler's busy guard prevents all invocations.
- **Both moves disabled (boundary edge case)**: If both canMoveUp and canMoveDown are false (hypothetically, in a single-item list), both buttons MUST render as disabled. Component MUST not error.
- **Transition from busy to not busy**: When busy transitions from true to false, component MUST restore full opacity and re-enable interaction; aria-disabled and aria-busy MUST be removed or set to undefined.
- **Very long subject text**: If subject is a long string, component MUST not truncate or wrap it in the aria-label; the full text is included in the label (truncation is the consuming component's responsibility if needed).

## Configuration

Not applicable: This component has no configuration options beyond React props (onMoveUp, onMoveDown, canMoveUp, canMoveDown, busy, subject, className). Styling is controlled by the Button component and the className override.

## Deep Linking

Not applicable: This component is a UI control within a list context and does not represent a navigable route or deep-linkable resource.

## Localization

Not applicable: The component's button labels are hardcoded English strings ("Move up", "Move down", "Reorder"). Localization would require passing localized strings as props or consuming from a locale provider, neither of which the source implements.

## Accessibility Options

Not applicable: The component has no animations or motion, so Reduce Motion does not apply. Increase Contrast and Differentiate Without Color can be handled via className overrides at the consuming level, as the component uses arrow icons (directional, not color-based) and relies on the Button component's contrast behavior.

## Feature Flags

Not applicable: This component is a basic UI primitive with no feature-flag gating in the source code.

## Analytics

Not applicable: The component has no built-in event tracking. Analytics instrumentation is the responsibility of the consuming component, which can instrument the onMoveUp and onMoveDown callbacks as needed.

## Privacy

Not applicable: This component does not collect, transmit, or store any user data beyond the immediate interaction state.

## Logging

Not applicable: The component has no internal logging or diagnostic output. Debugging and logging would be handled at the consumer level.

## Platform Notes

- **React/Web**: Implemented as a functional component using the Button component from the same UI library, Tailwind CSS classes (cn utility for class merging, gap-0.5, opacity-60, inline-flex, items-center, text-apt-text-muted), and Lucide React icons (ArrowUp, ArrowDown). The component is self-contained with minimal dependencies. Focus on the source files: packages/web/packages/ui/src/components/reorder-control.tsx and its Button dependency.
- **SwiftUI**: A SwiftUI port would use an HStack containing two Button views with SF Symbol arrows (arrowshape.up.fill and arrowshape.down.fill or arrowshape.up and arrowshape.down). Disabled state is managed via the button's disabled modifier. Busy state is shown by wrapping the HStack in an opacity modifier (.opacity(busy ? 0.6 : 1.0)) and using a .disabled modifier alongside the aria-disabled behavior simulation.
- **Compose**: A Jetpack Compose port would use a Row with two IconButton composables, leveraging Material Design Icons (Icons.Filled.ArrowUpward and Icons.Filled.ArrowDownward). Disabled state is managed via the button's enabled parameter. Busy state is applied via a graphicsLayer modifier for opacity and a clickable modifier guard similar to the source.
- **AppKit / UIKit**: On AppKit, use NSStackView (Orientation=Horizontal) with two NSButton instances styled as icon-only with arrow template images. On UIKit, use UIStackView with two UIButton instances configured as system buttons with SF Symbol images. Disable state via the isEnabled property. Busy state via alphaValue (AppKit) or alpha (UIKit) and interaction guarding in the action target.
- **WinUI 3**: A WinUI 3 port would use a StackPanel (Orientation=Horizontal) containing two Button controls. Disable state is managed via IsEnabled binding. Busy state is applied via an Opacity binding to 0.6 and by guarding the Click event handler. The button's AllowFocusOnInteraction property should be managed to allow focus during the busy state while preventing clicks (equivalent to aria-disabled behavior).

## Design Decisions

The component deliberately renders disabled buttons at boundaries (first and last item) rather than removing them. This design keeps the column width stable, preventing visual shift when navigating a list, and signals to users that the list has an order even when the current row cannot move. The use of arrow icons (not chevrons) is a deliberate departure from sibling controls like InlineCommitControl; the distinction prevents semantic confusion in rows that can both expand (disclosure) and reorder, where two different metaphors would otherwise map to similar visual shapes. The aria-disabled approach (not the HTML disabled attribute) during the busy state is borrowed from InlineCommitControl and preserves keyboard focus for users navigating via keyboard, allowing them to remain in the control sequence during an in-flight request without losing their place.

## Compliance

Not applicable: This component does not directly interact with regulatory, security, or compliance requirements. Compliance obligations belong to the consuming application and context.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
