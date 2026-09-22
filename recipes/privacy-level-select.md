---
id: d0cf136a-26ed-4a69-a440-4d056795601e
title: Privacy Level Select
domain: agenticdevelopercookbook://ingredients/privacy-level-select
type: ingredient
version: 1.0.0
status: review
language: en
created: 2026-09-22
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Controlled dropdown component for selecting privacy level (only-me, hub,
  or public) with keyboard navigation and popover UI.
platforms:
- web
tags:
- privacy
- select
- dropdown
- popover
- listbox
depends-on: []
related: []
references: []
---

# Privacy Level Select

## Overview

Privacy Level Select is a controlled form component that allows users to choose a privacy level from three options: "Only me" (private to user), "Hub members" (visible to organization members), or "Public" (visible to internet). The component renders a button trigger displaying the current selection and icon, with a popover menu containing the full list. A fourth disabled option ("Team / Org") signals upcoming functionality. The component manages keyboard navigation internally and requires the parent to handle privacy persistence via the `onChange` callback.

## Behavioral Requirements

- **must-render-trigger-with-current-level**: Component MUST display a button trigger showing the current privacy level's label and icon.
- **must-render-chevron-icon**: Component MUST display a chevrons-up-down icon (14px) in the trigger, right-aligned, to indicate expandable state.
- **must-open-popover-on-trigger-click**: Component MUST open the popover menu when the user clicks the trigger button.
- **must-close-popover-on-selection**: Component MUST close the popover and call `onChange` with the selected level when the user clicks or activates an option.
- **must-close-popover-on-escape**: Component MUST close the popover when the user presses the Escape key while focused on the listbox.
- **must-navigate-with-arrow-keys**: Component MUST move focus through options when the user presses ArrowUp or ArrowDown while the popover is open.
- **must-clamp-navigation-at-bounds**: Component MUST prevent cursor movement beyond the first and last navigable option (only-me, hub, public); the disabled "Team / Org" option MUST NOT be reachable via arrow keys.
- **must-select-with-enter-or-space**: Component MUST select the currently highlighted option when the user presses Enter or Space while the popover is open.
- **must-open-popover-with-trigger-keys**: Component MUST open the popover when the user presses ArrowDown, Enter, or Space while focused on the trigger and the popover is closed.
- **must-display-all-three-enabled-options**: Component MUST render exactly three selectable options: "Only me" (Lock icon), "Hub members" (Users icon), and "Public" (Globe icon), each with a label and description.
- **must-show-check-on-selected-option**: Component MUST display a gold check mark icon (14px) only on the currently selected option.
- **must-display-disabled-coming-soon-option**: Component MUST display a fourth option "Team / Org" marked as disabled and visually distinct (40% opacity), with a "Coming soon" badge and description "Visible to members of your organization".
- **must-highlight-hovered-option**: Component MUST apply a background highlight when the user hovers over an option.
- **must-highlight-keyboard-focused-option**: Component MUST apply a background highlight to the option currently pointed to by keyboard navigation (cursor state).
- **must-respect-disabled-prop**: Component MUST prevent opening the popover and make the trigger non-interactive when `disabled={true}`.
- **must-apply-disabled-styling**: Component MUST render the trigger with reduced opacity (50%) and a `not-allowed` cursor when disabled.
- **must-focus-listbox-on-open**: Component MUST move focus to the internal listbox surface when the popover opens (via requestAnimationFrame).
- **must-reset-cursor-to-value-on-open**: Component MUST set the keyboard cursor to the currently selected level when the popover opens.
- **must-handle-null-cursor-gracefully**: Component MUST initialize keyboard navigation to the first option when cursor is null and the user navigates.
- **must-read-value-prop**: Component MUST use the `value` prop to determine the current selection and update all visual and focus indicators when `value` changes.
- **must-call-onChange-with-selected-level**: Component MUST call the `onChange` callback with a `PrivacyLevel` value ('only-me', 'hub', or 'public') when the user commits a selection.
- **must-support-aria-label**: Component MUST accept an `ariaLabel` prop and apply it to the trigger and listbox for accessible naming.
- **must-apply-aria-haspopup**: Component MUST set `aria-haspopup="listbox"` on the trigger to indicate a listbox menu is available.
- **must-apply-aria-expanded**: Component MUST set `aria-expanded` to `true` on the trigger when the popover is open and `false` when closed.
- **must-apply-aria-activedescendant**: Component MUST set `aria-activedescendant` on the listbox to the ID of the currently highlighted option when the popover is open.
- **must-apply-role-listbox**: Component MUST set `role="listbox"` on the popover surface to identify it as a listbox container.
- **must-apply-role-option-to-entries**: Component MUST set `role="option"` on each option (both enabled and disabled) to identify them as listbox options.
- **must-set-aria-selected**: Component MUST set `aria-selected="true"` on the currently selected option and `aria-selected="false"` on all others.
- **must-set-aria-disabled-on-coming-soon**: Component MUST set `aria-disabled="true"` on the disabled "Team / Org" option.
- **must-support-custom-class-name**: Component MUST accept a `className` prop and merge it with the default trigger classes using `cn` utility.
- **must-prevent-default-on-trigger-keys**: Component MUST call `e.preventDefault()` when opening the popover with trigger keys to prevent browser default behavior.
- **must-prevent-default-on-navigation-keys**: Component MUST call `e.preventDefault()` on ArrowUp, ArrowDown, Enter, Space, and Escape keydown events to prevent browser defaults while the popover is open.
- **must-use-unique-option-ids**: Component MUST generate unique HTML IDs for each option using `React.useId()` and the option value to ensure proper ARIA linking.
- **must-truncate-trigger-text**: Component MUST truncate the trigger text (label + icon) to prevent horizontal overflow, with the icon remaining visible.

## Appearance

- **Trigger Button**:
  - Height: 36px (h-9)
  - Width: full parent width
  - Padding: 12px horizontal, vertical centered (px-3)
  - Font: 14px (text-sm), medium weight for label
  - Background: transparent (input base style from `fieldShellClass`)
  - Foreground/Text: `apt-text` (primary text color)
  - Border: 1px solid `apt-border` (from `fieldShellClass`)
  - Hover: border color lightens to `apt-border-strong`
  - Focus-visible: 2px ring of `apt-gold/25` with border color `apt-gold`
  - Disabled: opacity 50%, cursor not-allowed
  - Gap between content: 8px (gap-2)
  
- **Trigger Content Layout**:
  - Left section: icon (14px, `apt-text-muted` color) + label text
  - Right section: chevron icon (14px, `apt-text-muted` color)
  - Content shrinks but does not wrap; icon remains visible on truncate
  
- **Popover**:
  - Width: 288px (w-72)
  - Padding: 4px (p-1) — options define their own padding
  - Align: start (matches trigger left edge)
  - Background: inherits from Popover component
  
- **Option Button**:
  - Height: auto (py-2)
  - Width: full popover width
  - Padding: 8px horizontal, 8px vertical (px-2 py-2)
  - Border-radius: 6px (rounded-md)
  - Font: 14px (text-sm) for label; 12px for description
  - Label font-weight: medium
  - Label color: `apt-text`
  - Description color: `apt-text-dim` (lighter)
  - Gap between icon and content: 8px (gap-2)
  - Highlighted background: `apt-highlight/15` (15% opacity of highlight color)
  - Text alignment: left
  - Cursor: pointer
  
- **Option Icons**:
  - All icons: 14px (size-[14px])
  - Padding-top: 4px (mt-0.5) to optical center align with text baseline
  - Label icon and privacy icon: `apt-text-muted` color
  - Check icon: gold (`apt-gold`) when checked, otherwise opacity-0
  - Coming-soon option: all icons and text at 40% opacity
  
- **Coming Soon Badge**:
  - Variant: blue
  - Rendered inline with "Team / Org" label

## States

| State | Appearance change |
|-------|------------------|
| Default | Trigger shows current selection with icon, chevron; popover closed |
| Hover (trigger) | Border color lightens to `apt-border-strong`; cursor pointer |
| Focus (trigger) | 2px ring of `apt-gold/25`, border turns `apt-gold` |
| Open | Popover displayed; trigger `aria-expanded="true"` |
| Keyboard-highlighted option | Option background: `apt-highlight/15`; `aria-activedescendant` points to option ID |
| Hovered option | Option background: `apt-highlight/15` (same as keyboard highlight) |
| Selected option | Check mark visible and gold; icon color `apt-gold` on check |
| Disabled (component) | Trigger opacity 50%, cursor not-allowed, popover will not open |
| Disabled option (Team/Org) | Entire option row at 40% opacity, not keyboard-navigable, `aria-disabled="true"` |

## Accessibility

- **Role**: The trigger is a button with `aria-haspopup="listbox"` and `aria-expanded` state. The popover surface is a `role="listbox"`. Each option is `role="option"`.
- **Labeling**: The component accepts `ariaLabel` (default: "Privacy level") applied to both trigger and listbox. Required for screen reader users to understand the control's purpose.
- **Keyboard navigation**: Full keyboard support via Arrow Up/Down (navigate), Enter/Space (select), Escape (close). Disabled options are skipped by arrow key navigation. Trigger keys (Arrow Down, Enter, Space) open the menu from closed state.
- **Focus management**: Focus moves to the listbox surface when the popover opens; keyboard cursor initializes to the current value. Focused option receives `aria-activedescendant` linking. On selection, popover closes and focus returns to trigger (handled by Popover component).
- **Visual indicators**: Selected option shows a check mark. Highlighted/hovered option shows background color change. Disabled state uses opacity and cursor styling. Focus ring on trigger uses a 2px gold ring. Min touch target for options: implicitly met by 36px height + 8px padding (total 44px+ touch height per option row).
- **Screen reader announcements**: Check mark is `aria-hidden="true"` (visual only). All icons are `aria-hidden="true"`. Option descriptions are visible text (not hidden). Disabled affordance is a `div` with `role="option"` and `aria-disabled="true"` so it is announced as disabled and not keyboard-reachable.
- **Color contrast**: Icon colors (`apt-text-muted`) are muted; descriptions use `apt-text-dim` (dimmer). The component relies on the design system token values to meet WCAG AA contrast. Check icon uses `apt-gold` which should contrast against `apt-highlight/15` background.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| privacy-001 | must-render-trigger-with-current-level | value="only-me" | Trigger displays "Only me" text |
| privacy-002 | must-render-chevron-icon | Component mounted | Trigger displays chevrons-up-down icon (14px, right-aligned) |
| privacy-003 | must-open-popover-on-trigger-click | User clicks trigger, popover closed | Popover opens; aria-expanded="true" on trigger |
| privacy-004 | must-close-popover-on-selection | User clicks "Hub members" option, popover open | Popover closes; onChange called with "hub"; aria-expanded="false" on trigger |
| privacy-005 | must-close-popover-on-escape | Popover open, user presses Escape | Popover closes; aria-expanded="false" |
| privacy-006 | must-navigate-with-arrow-keys | Popover open, cursor on "hub", user presses ArrowDown | Cursor moves to "public"; aria-activedescendant updates to "public" option ID |
| privacy-007 | must-clamp-navigation-at-bounds | Popover open, cursor on "public", user presses ArrowDown | Cursor stays on "public"; does not move to disabled "Team / Org" option |
| privacy-008 | must-select-with-enter-or-space | Popover open, cursor on "only-me", user presses Enter | Popover closes; onChange called with "only-me"; value updates |
| privacy-009 | must-open-popover-with-trigger-keys | Trigger focused, popover closed, user presses Space | Popover opens; aria-expanded="true"; cursor initializes to current value |
| privacy-010 | must-display-all-three-enabled-options | Popover open | Three clickable options rendered: "Only me", "Hub members", "Public" |
| privacy-011 | must-show-check-on-selected-option | value="hub", popover open | Check icon (gold, 14px) visible only on "Hub members" option |
| privacy-012 | must-display-disabled-coming-soon-option | Popover open | "Team / Org" option rendered with 40% opacity and "Coming soon" badge |
| privacy-013 | must-highlight-hovered-option | Popover open, user hovers on "public" option | Option background changes to `apt-highlight/15` |
| privacy-014 | must-highlight-keyboard-focused-option | Popover open, cursor on "hub" via arrow navigation | Option background changes to `apt-highlight/15` |
| privacy-015 | must-respect-disabled-prop | disabled={true}, user clicks trigger | Popover does not open; onChange is not called |
| privacy-016 | must-apply-disabled-styling | disabled={true} | Trigger renders with opacity 50%, cursor not-allowed |
| privacy-017 | must-focus-listbox-on-open | User opens popover via trigger click | Listbox surface receives focus (can accept keyboard input immediately) |
| privacy-018 | must-reset-cursor-to-value-on-open | value="public", user clicks trigger to open | Cursor initializes to "public" option (keyboard can select immediately without navigation) |
| privacy-019 | must-handle-null-cursor-gracefully | Popover open, cursor not set, user presses ArrowDown | Navigation works; cursor moves to first option without error |
| privacy-020 | must-read-value-prop | value prop changes from "only-me" to "public" externally | Trigger updates to show "Public"; all visual indicators update |
| privacy-021 | must-call-onChange-with-selected-level | User clicks "hub" option | onChange callback invoked with argument "hub" (string, not object) |
| privacy-022 | must-support-aria-label | ariaLabel="Profile visibility", rendered | Trigger and listbox both have aria-label="Profile visibility" |
| privacy-023 | must-apply-aria-haspopup | Component rendered | Trigger element has aria-haspopup="listbox" |
| privacy-024 | must-apply-aria-expanded | Popover open | Trigger has aria-expanded="true"; when closed, aria-expanded="false" |
| privacy-025 | must-apply-aria-activedescendant | Popover open, cursor on "hub" | Listbox has aria-activedescendant set to ID of "hub" option |
| privacy-026 | must-apply-role-listbox | Popover open | Listbox surface has role="listbox" |
| privacy-027 | must-apply-role-option-to-entries | Popover open | All four options (three enabled + "Team / Org") have role="option" |
| privacy-028 | must-set-aria-selected | value="only-me", popover open | "Only me" option has aria-selected="true"; others have aria-selected="false" |
| privacy-029 | must-set-aria-disabled-on-coming-soon | Popover open | "Team / Org" option has aria-disabled="true" |
| privacy-030 | must-support-custom-class-name | className="custom-class" prop passed | Trigger element includes custom-class in its className |
| privacy-031 | must-prevent-default-on-trigger-keys | Trigger focused, user presses ArrowDown to open | Browser default behavior is prevented; page does not scroll |
| privacy-032 | must-prevent-default-on-navigation-keys | Popover open, user presses ArrowUp | Browser default behavior is prevented; page does not scroll |
| privacy-033 | must-use-unique-option-ids | Component renders multiple times in a page | Each option ID is unique across all component instances (uses React.useId) |
| privacy-034 | must-truncate-trigger-text | Trigger width constrained, long label text | Text truncates with ellipsis; icon remains visible and non-truncated |

## Edge Cases

- **Null/undefined value**: The component assumes `value` is always a valid `PrivacyLevel` ('only-me', 'hub', or 'public'). No guard against undefined or invalid values is present; the caller MUST provide a valid initial value.
- **Rapid onChange calls**: If parent rapidly updates `value` while the popover is open, the component updates the cursor and trigger display immediately without additional validation.
- **Disabled to enabled transition**: When `disabled` prop changes from `true` to `false`, the component becomes interactive immediately; the popover will open on next trigger click without resetting internal state.
- **Rapid open/close**: If the user rapidly toggles the popover (click trigger, click again), state changes propagate correctly; cursor is reset to current value each time the popover opens.
- **Focus loss before commit**: If the user navigates with arrow keys, then clicks outside the popover before selecting an option, the popover closes without calling `onChange` and the cursor state is discarded.
- **ArrowDown on trigger with closed popover**: User presses ArrowDown on trigger button — popover opens (does not scroll page). Same for Space and Enter.
- **Empty string or whitespace ariaLabel**: If `ariaLabel` is an empty string or whitespace, it is used as-is (no fallback validation); the component will render with that empty/whitespace label.
- **Multiple instances on same page**: Each instance uses `React.useId()` to generate unique IDs; options from different instances will not conflict in ARIA linkage or in the DOM.
- **Disabled option interaction**: The "Team / Org" option is not keyboard-navigable (arrow keys skip it) and has `role="option"` + `aria-disabled="true"` but is a `<div>`, not a button, so it is not clickable (no onClick handler, no pointer events enabled).
- **Hover during keyboard navigation**: If the user navigates with arrow keys while hovering, the highlight state is shared (same `apt-highlight/15` background); the visual result is the same whether cursor or hover caused it.
- **Window resize during popover open**: The Popover component (not this component) handles repositioning; this component makes no special handling.
- **Keyboard navigation null cursor recovery**: If cursor is null and user presses ArrowDown, the `move` function initializes to index 0 (first option). If user presses ArrowUp with null cursor, it also initializes to index 0, not the last option.

## Configuration

Not applicable: the component has no configuration options beyond its props (`value`, `onChange`, `ariaLabel`, `disabled`, `className`). All options, labels, descriptions, and icons are hardcoded.

## Deep Linking

Not applicable: the component is a form control, not a navigable view. Deep linking to privacy levels is the responsibility of the parent page or app.

## Localization

Not applicable: all text is hardcoded in English ("Only me", "Hub members", "Public", etc.). The component does not accept label or description props to customize text per locale. Localization would require forking the component or refactoring to accept dynamic labels.

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | Not implemented in source. The component uses no animations; transitions are applied by the Popover component (not in scope here). |
| Increase Contrast | Component relies on design system tokens (`apt-gold`, `apt-highlight`, `apt-text`, etc.) for contrast. If the design system provides high-contrast token overrides, the component will inherit them. No explicit contrast adjustments are coded in the component. |
| Differentiate Without Color | The selected state is indicated by a check mark icon (shape-based, not color-only) and position in the list. The disabled state uses opacity + text styling. Color is not the sole differentiator for any state. |

## Feature Flags

Not applicable: the component has no feature flags. All functionality (three privacy levels, keyboard navigation, popover) is always active when the component is mounted.

## Analytics

Not applicable: the component does not emit analytics events. Event tracking (selection changes, open/close) is the responsibility of the parent component's `onChange` handler and any custom event listeners attached by the consuming application.

## Privacy

- **Data collected**: None. The component does not collect, store, or transmit user data.
- **Storage**: No local storage, cookies, or session storage is used by this component.
- **Transmission**: No network requests or data transmission occurs. The component is purely presentational; the parent is responsible for transmitting the selected value to the backend via `PRIVACY_AUDIENCE_MASK` mapping.
- **Retention**: No data is retained by the component beyond the component's lifecycle.

## Logging

Not applicable: the component has no logging. Console or error tracking is the responsibility of the parent application.

## Platform Notes

- **React/Web**: Source files are in `packages/web/packages/ui/src/components/privacy-level-select.tsx`. The component is a controlled React component using `React.useState` for internal state (`open`, `cursor`), `React.useRef` for focus management, and `React.useId` for ARIA ID generation. It delegates to a `Popover` component (not in scope) and uses icons from `lucide-react`. Text truncation is handled via Tailwind `truncate` utility on the trigger content span.
- **Kotlin/Android**: A native Android implementation would start from `Material Design 3` Select / Dropdown component. Key differences: Material 3 menus do not have a separate "listbox" accessibility role (uses platform-native Jetpack Compose selection handling); keyboard navigation uses Material's default Up/Down/Left/Right convention. The disabled "coming soon" affordance is non-standard and would require a custom `DropdownMenuItem` with `enabled=false` styling.
- **Swift/iOS**: A native iOS implementation would use `UIMenu` (if popover-free) or `UIPickerView` / custom view controller for modal presentation. Key differences: iOS does not use ARIA roles; accessibility is handled via `UIAccessibility` APIs and Voice Over rotor settings. A picker design might use a SegmentedControl or a custom modal picker. The keyboard navigation pattern (arrow keys) is specific to web/desktop and does not apply to iOS touch interaction.
- **AppKit/macOS**: A native macOS implementation would use `NSPopUpButton` or a custom view with `NSMenu`. Key differences: Menu keyboard navigation is automatic (arrow keys, space/return to select). The component could present the "coming soon" option as a disabled menu item natively. Focus ring and highlight states are handled by AppKit's built-in focus rendering.
- **WinUI 3**: A WinUI 3 implementation would use `ComboBox` or `MenuFlyout` with `RadioMenuFlyoutItem` for each privacy level. Key differences: WinUI provides built-in keyboard navigation (Up/Down arrows), automatic focus management, and native disabled state styling. The popover alignment (`align="start"`) maps to `Placement="TopEdgeAlignedLeft"` on the `MenuFlyout`. The "coming soon" option maps to a disabled `MenuFlyoutItem` with `IsEnabled="false"`. The check mark visual (currently an icon) would use WinUI's `RadioMenuFlyoutItem` built-in indicator. Accessibility features (ARIA roles, aria-label, aria-expanded) are mapped to WinUI's native accessibility tree (UIA patterns and properties).

## Design Decisions

- **Three levels hardcoded**: The component defines exactly three selectable privacy levels (only-me, hub, public) and a fourth disabled affordance (Team/Org, coming soon). No attempt is made to accept a dynamic list of options. This design is justified because privacy levels are a fixed, app-wide configuration that is unlikely to change at runtime.
- **Fails closed on wire value conversion**: `PRIVACY_LEVEL_FROM_WIRE` defaults to `'only-me'` for any unrecognized value. This is a deliberate security choice: if the backend sends an unrecognized or future-added privacy level, the component renders as the most restrictive level (private to user only) rather than accidentally exposing data as public.
- **Cursor state separate from value**: The component maintains an internal `cursor` (keyboard navigation focus) distinct from `value` (current selection). This allows the user to navigate to an option without committing the change until Enter or click. Changing the `value` prop externally resets the cursor to that value on the next popover open, ensuring the keyboard starts from a known position.
- **No error handling for disabled state during open**: If the component becomes disabled while the popover is open (e.g., `disabled` prop changes from false to true), the popover remains open. This is the source code's actual behavior; closing the popover on a disabled transition was not implemented and is left to the parent to manage if needed.
- **Shared highlight styling for hover and keyboard**: Both hovered and keyboard-focused options receive the same background style (`apt-highlight/15`). This reduces CSS rules and makes it clear that both interaction modes have the same effect; a user cannot distinguish the source of the highlight visually.
- **ArrowDown initializes cursor when null**: When the user navigates from a null cursor state (e.g., first navigation after popover open, if cursor was not set), pressing ArrowDown goes to index 0 (first option), and pressing ArrowUp also goes to index 0 (no wrap-around). This is the implemented behavior.
- **Popover content width fixed to w-72 (288px)**: The popover is a fixed width and does not respond to trigger width or viewport size. This ensures consistent text wrapping and layout of the option descriptions regardless of where the component is placed.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| [Web Content Accessibility Guidelines 2.1](https://www.w3.org/TR/WCAG21/) | compliant | WCAG 2.1 Level AA—keyboard navigation (arrow keys, enter, escape), focus indicators (gold ring), role and state ARIA attributes present, semantic option elements with role="option" and aria-selected, disabled state announced via aria-disabled, labels present via aria-label | 
| Keyboard navigation | compliant | Full keyboard support for open/close (ArrowDown, Enter, Space from trigger), navigation (ArrowUp/ArrowDown in popover), selection (Enter, Space), and close (Escape) |
| Focus management | compliant | Focus trap behavior managed by Popover component; this component ensures listbox receives focus on open and cursor initializes to current value |
| Disabled affordance | compliant | "Team / Org" option is non-interactive, marked role="option" aria-disabled="true", and visually distinct (40% opacity) |
| Touch target size | compliant | Option elements are 44px+ in height (padding + font + line-height); trigger is 36px height, which is Apple's minimum but below Material 3's 48dp recommendation for mobile contexts. Web-specific context (likely desktop): acceptable. |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | | Initial creation |
