---
id: f09feb7c-6778-445a-8a68-863c5d60b5cc
title: CollapseToggle
domain: agenticdevelopercookbook://ingredients/collapse-toggle
type: ingredient
version: 1.1.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A simple toggle button for collapsible sections using directional glyphs
  (» / «) to indicate state.
platforms:
- typescript
- web
tags:
- ui
- button
- disclosure
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# CollapseToggle

## Overview

A minimal toggle control that switches between expanded and collapsed states of a region or list. The component displays a directional glyph (» when collapsed, « when expanded) and is intended for use in layouts where custom collapsible behavior is desired — such as rail navigation, side panels, or column lists. It is not a full disclosure component; it provides only the toggle mechanism and leaves layout decisions to the caller.

## Behavioral Requirements

- **must-toggle-state-on-click**: Clicking the button MUST invoke the `onToggle` callback with the click event.
- **must-forward-event**: The `onToggle` callback MUST receive the React `MouseEvent` so the caller can inspect modifier keys (Ctrl/⌘-click).
- **must-render-glyph-collapsed**: When `collapsed` is `true`, the button MUST display the «»» (right-pointing chevron, U+00BB) glyph.
- **must-render-glyph-expanded**: When `collapsed` is `false`, the button MUST display the ««» (left-pointing chevron, U+00AB) glyph.
- **must-set-aria-label**: The button's `aria-label` MUST be set to "Collapse {label}" when `collapsed` is `false`, and "Expand {label}" when `collapsed` is `true`, where `{label}` is the value of the `label` prop.
- **must-set-aria-expanded**: The button's `aria-expanded` attribute MUST be set to `true` when `collapsed` is `false`, and `false` when `collapsed` is `true`.
- **must-set-title-attribute**: The button's `title` attribute MUST match the `aria-label` value to provide tooltip text.
- **must-be-button-type**: The button element MUST have `type="button"` to prevent form submission.
- **should-set-aria-controls**: If the `controls` prop is provided, the button's `aria-controls` attribute SHOULD be set to that value to indicate the region being toggled.
- **must-accept-className**: The component MUST accept an optional `className` prop and apply it to the button element via a class-merging utility.

## Appearance

- **Corner radius**: Rounded corners (`rounded` in Tailwind, approximately 0.375rem or 6px)
- **Padding**: `px-1` (0.25rem horizontal, no explicit vertical padding)
- **Font**: Monospace weight, proportional size (inherits from parent; uses `font-mono`)
- **Background**: Transparent (no background color specified)
- **Foreground/Text**: Muted text color by default (`text-apt-text-muted`), changes to primary text color on hover (`hover:text-apt-text`)
- **Border**: None specified
- **Shadow**: None
- **Min/Max size**: No explicit constraints; size is determined by font size and padding

## States

| State | Appearance change |
|-------|------------------|
| Default | Muted text color, no outline |
| Hover | Text color changes to primary (`text-apt-text`) |
| Focus-visible | Blue ring outline (`focus-visible:ring-2 focus-visible:ring-apt-gold/40`) with 40% opacity gold color |
| Collapsed | Displays «»» glyph |
| Expanded | Displays ««» glyph |

## Accessibility

- **Role**: Button (semantic `<button>` element)
- **Label requirements**: The `aria-label` is always present and dynamically set based on state. The label MUST include the region name from the `label` prop so users understand what is being toggled.
- **State announcement**: The `aria-expanded` attribute indicates the expanded/collapsed state to assistive technologies.
- **Region association**: When `controls` is provided, `aria-controls` links the button to the region it controls, allowing assistive technology users to navigate directly to that region.
- **Keyboard navigation**: The button is keyboard-accessible via the standard HTML button element; keyboard focus is visible via the `focus-visible:ring` style.
- **Minimum tap target**: The source applies `px-1` (0.25rem horizontal padding) and no width, height, or minimum-size rule, so the hit area is exactly the inherited `font-mono` glyph box plus that padding — at a typical 14px rail font this lands well under the 44×44pt target the ingredient template names. NEEDS REVIEW: whether an under-44×44pt target is acceptable for this control is a decision the source cannot make. What is missing is a ruling on the minimum hit area; measuring the rendered button at its two call sites (the TopicDetail rail and the theme-editor column list) against the 44×44pt floor, plus a decision on whether to pad the button itself or enlarge the surrounding row's hit area, would settle it.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| collapse-toggle-001 | must-render-glyph-collapsed | `collapsed={true}, label="Topic List"` | Button displays «»» glyph |
| collapse-toggle-002 | must-render-glyph-expanded | `collapsed={false}, label="Topic List"` | Button displays ««» glyph |
| collapse-toggle-003 | must-set-aria-label-collapsed | `collapsed={true}, label="Topic List"` | `aria-label="Expand Topic List"` |
| collapse-toggle-004 | must-set-aria-label-expanded | `collapsed={false}, label="Topic List"` | `aria-label="Collapse Topic List"` |
| collapse-toggle-005 | must-set-aria-expanded-collapsed | `collapsed={true}` | `aria-expanded="false"` |
| collapse-toggle-006 | must-set-aria-expanded-expanded | `collapsed={false}` | `aria-expanded="true"` |
| collapse-toggle-007 | must-set-title-attribute | `collapsed={true}, label="Items"` | `title="Expand Items"` |
| collapse-toggle-008 | must-be-button-type | Any props | `type="button"` on element |
| collapse-toggle-009 | must-toggle-state-on-click | User clicks button | `onToggle` callback invoked with click event |
| collapse-toggle-010 | must-forward-event | User Ctrl+clicks button | `onToggle` callback receives event with `ctrlKey=true` |
| collapse-toggle-011 | should-set-aria-controls | `controls="item-list"` | `aria-controls="item-list"` |
| collapse-toggle-012 | should-set-aria-controls-optional | `controls` not provided | `aria-controls` attribute absent or empty |
| collapse-toggle-013 | must-accept-className | `className="custom-class"` | Custom class appears in rendered button className |

## Edge Cases

- **Label contains special characters**: The label is used directly in the aria-label; special characters (quotes, symbols) MUST be handled safely by the framework's label rendering. Behavior: label is rendered as-is into aria-label.
- **Empty or null label**: The source interpolates `label` straight into `${collapsed ? "Expand" : "Collapse"} ${label}` with no guard, trim, or fallback. An empty string therefore produces the verb followed by a trailing space — `aria-label="Expand "` and the same value in `title` — and the button still renders its glyph and still fires `onToggle`. `label` is typed as a required `string`, so `null` or `undefined` is a compile-time error; if one reaches the component at runtime it is interpolated as the literal text `"null"` or `"undefined"`. Implementations MUST reproduce this pass-through behavior and MUST NOT substitute a default region name.
- **Missing `label` prop**: The component requires `label` as a non-optional prop; if not provided, TypeScript will enforce a compile-time error. Runtime behavior: undefined label results in aria-label like "Expand undefined".
- **Multiple rapid clicks**: Each click triggers `onToggle`. The caller is responsible for debouncing or state management; the component renders only the current `collapsed` state.
- **`controls` prop targets non-existent element**: If `aria-controls` points to an element that does not exist, no runtime error occurs; the attribute is still set. Assistive technology behavior is undefined.
- **Dynamic className changes**: If `className` is updated while the button is rendered, the new class is applied immediately via the class-merging utility.
- **Very long label text**: No truncation or overflow handling in the component; label length is unconstrained. The aria-label will be long but valid; visual overflow depends on parent container.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `collapsed` | `boolean` | — | Required. Current collapse state; `true` = collapsed, `false` = expanded. |
| `onToggle` | `(e: MouseEvent<HTMLButtonElement>) => void` | — | Required. Callback invoked when button is clicked. Receives React MouseEvent for modifier key inspection. |
| `label` | `string` | — | Required. Region name for aria-label; appears in accessible label as "Expand {label}" or "Collapse {label}". |
| `controls` | `string \| undefined` | `undefined` | Optional. `id` of the region this button controls; passed to `aria-controls`. |
| `className` | `string \| undefined` | `undefined` | Optional. Additional CSS class(es) merged with component defaults via class utility. |

## Deep Linking

Not applicable: CollapseToggle is a stateless UI primitive without its own route or deep-linking behavior. State (collapsed/expanded) is managed by the parent component, and the button itself has no URI identity.

## Localization

The verbs "Expand" and "Collapse" are hard-coded English string literals inside the component. The source contains no string table, no message catalogue, no locale parameter, and no lookup call — the two words are written directly into the template literal that builds `aria-label` and `title`.

Everything else in the accessible name comes from the caller: `label` is interpolated verbatim, so the caller is the party that supplies a localized region name. A caller passing a localized `label` into this component gets a mixed-language accessible name (for example "Expand Themenliste") until the consuming application localizes the two verbs as well. Implementations that need a fully localized name MUST source the verbs from their own catalogue rather than from this component.

The glyphs `»` and `«` are literal characters in the JSX and are not mirrored, re-selected, or swapped for right-to-left locales.

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | The source declares no `transition-*`, `animate-*`, or duration class; the swap between `»` and `«` and the hover color change are instant re-renders. No transition is applied; nothing to disable under Reduce Motion. |
| Increase Contrast | The source pins the foreground to the `apt-text-muted` token, raises it to `apt-text` on hover, and draws the focus ring as `apt-gold/40`. It declares no high-contrast variant and no `prefers-contrast` query, so the contrast delivered is whatever those tokens resolve to in the active theme. Implementations MUST use the same tokens rather than substituting fixed color values, so a theme that raises contrast raises this control's contrast with it. |
| Differentiate Without Color | Color is never the sole carrier of state. Collapsed versus expanded is carried by the glyph shape (`»` versus `«`), by `aria-expanded`, and by the `aria-label`/`title` text, none of which depend on color. The one color-only change in the source is the `hover:text-apt-text` shift, which signals pointer position rather than component state. |

The component also inherits the platform's focus-visible behavior: the `focus-visible:ring-2` style paints only when the browser judges focus to be keyboard-driven.

## Feature Flags

Not applicable: CollapseToggle is a stateless primitive with no feature-flag control. Feature flags (if needed) would be the responsibility of the consuming component.

## Analytics

Not applicable: The component does not emit analytics events. Analytics tracking (if desired) would be the caller's responsibility in the `onToggle` callback.

## Privacy

Not applicable: CollapseToggle collects no data, stores no state persistently, and transmits nothing. All state is ephemeral and managed by the parent component.

## Logging

Not applicable: The component has no built-in logging or diagnostic output.

## Platform Notes

- **React/Web (source)**: The component is defined in `packages/web/packages/ui/src/components/collapse-toggle.tsx`. It uses React hooks conventions (functional component), standard HTML button element with ARIA attributes, and Tailwind CSS for styling via a `cn()` utility function. The click handler is a React `MouseEvent<HTMLButtonElement>`.
- **SwiftUI**: No direct equivalent in SwiftUI's component library. A developer would build a custom `Button` with a conditional image (SF Symbols `chevron.right` / `chevron.left`) and apply `accessibilityLabel()` and `accessibilityAddTraits()` to replicate the behavior.
- **Compose (Android/Kotlin)**: Use `Button` or `IconButton` with a conditional `Icon` (Material Icons chevron left/right). Apply `contentDescription` with dynamic text matching the React component's aria-label pattern. Use `modifier.semantics { expandedState = ... }` for accessibility.
- **AppKit / UIKit**: On macOS, use `NSButton` with `setButtonType(.momentaryChange)` and toggle images. On iOS, use `UIButton` with `configurationUpdateHandler` to swap images. Set `accessibilityLabel` and `accessibilityHint` to match the ARIA pattern. Assign `accessibilityTraits = .button`.
- **WinUI 3**: Use a `Button` control with a `TextBlock` displaying the «»» or ««» character (U+00BB, U+00AB). Set `AutomationProperties.Name` to the state-dependent label ("Expand {label}" / "Collapse {label}"). Use a `VisualStateManager` state group to apply hover and focus styles. The `Click` event handler receives the click source; detect modifier keys via `CoreWindow.GetForCurrentThread().GetKeyState()` or `InputKeyboardSource` if modifier inspection is needed.

## Design Decisions

1. **Unicode glyphs for state indication**: The component uses «»» (right chevron) for collapsed and ««» (left chevron) for expanded. This is a visual convention for "close" (chevron pointing away) and "open" (chevron pointing inward). This mirrors common UI patterns in mail clients and hierarchical lists. Callers who prefer different glyphs (arrows, +/-, etc.) should fork or extend the component.

2. **event forwarding in onToggle**: The `onToggle` callback receives the full React `MouseEvent` rather than just a boolean. This enables callers to detect Ctrl/⌘-click for hierarchical toggle behavior (noted in the source comment: "apply this toggle to every list"). This trades callback simplicity for power; callers uninterested in modifiers ignore the event parameter.

3. **aria-expanded always inverted from collapsed**: The `aria-expanded` attribute is set to `!collapsed` (the opposite of the `collapsed` prop). This ensures the accessible state always reflects the logical expanded state of the controlled region: when `collapsed=true` (user sees the "expand" label and «»» glyph), `aria-expanded=false` signals the region is not yet expanded. This is the correct ARIA mapping.

4. **No size constraints**: The button's size is determined entirely by the inherited font size plus the `px-1` padding; the source sets no width, height, or minimum. This is a deliberate trade for placement flexibility — the same control sits in a narrow rail beside TopicDetail and in the theme-editor's column headers — and it moves responsibility for the hit area onto the caller's layout. The Accessibility section records the open question of what minimum that layout has to guarantee.

5. **Title attribute mirrors aria-label**: The `title` attribute is set to the same text as `aria-label`. This provides a tooltip for mouse users without duplicating logic; however, it means the tooltip also says "Expand {label}" or "Collapse {label}", which is self-evident to sighted users and potentially redundant.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| Touch target minimum size | Not verified | Accessibility |
| Keyboard navigation support | Passed | Accessibility |
| ARIA role and attributes | Passed | Accessibility |
| Localization support | Not implemented | Internationalization |
| High contrast mode | Not verified | Accessibility |
| Reduce Motion preference | Not implemented | Accessibility |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.1.0 | 2026-09-22 | Mike Fullerton | Replace unresolved review markers with the source's actual behavior for empty label, localization, and accessibility display options; narrow the open tap-target question to the Accessibility section |
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation from source at packages/web/packages/ui/src/components/collapse-toggle.tsx |
