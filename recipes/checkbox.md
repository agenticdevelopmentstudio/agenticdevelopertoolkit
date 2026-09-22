---
id: a105b6cf-307d-4156-8b73-468f627f3c9b
title: Checkbox
domain: agenticdevelopercookbook://ingredients/checkbox
type: ingredient
version: 1.1.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A controllable checkbox or switch input supporting labeled form fields with
  hints and visual state feedback.
platforms:
- web
tags:
- form
- input
- checkbox
depends-on: []
related: []
references: []
---

# Checkbox

## Overview

A controlled checkbox input component available in two visual modes: checkbox or switch toggle. The component supports optional label and hint text, disabled state, and keyboard focus management. Built for use in forms where binary (true/false) choices are needed.

## Behavioral Requirements

- **must-support-controlled-value**: The component MUST accept a `value` prop of type boolean that reflects the current checked state (line 920, Checkbox.tsx).
- **must-accept-on-change**: The component MUST accept an `onChange` callback that is invoked with the new boolean value when the user toggles the input (line 921, Checkbox.tsx; line 959, Checkbox.tsx).
- **must-support-switch-appearance**: The component MUST support an `appearance` prop set to `'switch'` to render a switch-mode toggle with `role="switch"` on the input (line 922, Checkbox.tsx; line 955, Checkbox.tsx).
- **must-support-check-appearance**: The component MUST support an `appearance` prop set to `'check'` to render a checkbox-mode input without the switch role (line 922, Checkbox.tsx; line 955, Checkbox.tsx).
- **must-default-to-switch-appearance**: The component MUST default the `appearance` prop to `'switch'` when not specified (line 923, Checkbox.tsx).
- **must-support-disabled-state**: The component MUST accept a `disabled` prop that prevents user interaction when true (line 923, Checkbox.tsx; line 958, Checkbox.tsx).
- **must-render-optional-label**: The component MUST conditionally render a label element when the `label` prop is provided as a ReactNode (line 962, Checkbox.tsx; line 918-919, Checkbox.tsx).
- **must-render-optional-hint**: The component MUST conditionally render a hint element when the `hint` prop is provided as a ReactNode (line 964, Checkbox.tsx; line 919, Checkbox.tsx).
- **must-associate-label-with-input**: The component MUST use a `htmlFor` attribute on the label element to associate it with the input's `id`, generating a unique ID when no explicit `id` is provided (line 939, Checkbox.tsx; line 951, Checkbox.tsx).
- **must-render-visual-indicator**: The component MUST render a visual checkmark indicator that appears only when the checkbox is checked (line 1002-1007, checkbox.tsx; line 961, Checkbox.tsx).
- **must-signal-checked-without-color**: The component MUST signal the checked state by the checkmark glyph in addition to the `apt-gold` fill, so the state is distinguishable without relying on color alone (line 996, line 1006, checkbox.tsx).
- **must-support-focus-ring**: The component MUST display a visible focus ring when the input receives keyboard focus, using 2px ring width with 25% opacity (line 995, checkbox.tsx).
- **must-apply-custom-classname**: The component MUST accept a `className` prop and apply it to the root container (line 924, Checkbox.tsx; line 993-999, checkbox.tsx).
- **must-accept-custom-id**: The component MUST accept an `id` prop that is passed to the input element for label association (line 925, Checkbox.tsx; line 939, Checkbox.tsx).
- **must-support-controlled-and-uncontrolled**: The component MUST accept `checked` and `onCheckedChange` props for controlled mode, or `defaultChecked` for uncontrolled mode (line 989-990, checkbox.tsx per @base-ui/react/checkbox API).

## Appearance

- **Checkbox Size**: 16px (size-4 in Tailwind: 1rem). The indicator spans the full size with centered content (line 994, checkbox.tsx).
- **Border**: 1px solid, color `apt-border` in default state; changes to `apt-gold` when checked (line 994, line 996, checkbox.tsx).
- **Background Color**: `apt-bg` in default state; changes to `apt-gold` when checked (line 994, line 996, checkbox.tsx).
- **Corner Radius**: `rounded` (typically 4px) (line 994, checkbox.tsx).
- **Checkmark Icon**: Lucide React `Check` icon, size 3 (12px / 0.75rem), stroke width 3 (line 1006, checkbox.tsx).
- **Checkmark Color**: Initially `text-apt-bg` (background color), then `text-current` (inherits text color, typically white/light on gold background) when checked (line 1004-1005, checkbox.tsx).
- **Focus Ring**: 2px ring with `apt-gold/25` color, visible on focus (line 995, checkbox.tsx).
- **Transition**: `transition-colors` only — border and background color changes are animated; no size, position, or opacity motion is animated (line 994, checkbox.tsx).
- **Label Styling**: Applied via `aws-checkbox__label` class in form field, or via passed ReactNode; font and size determined by label text type (line 962, Checkbox.tsx).
- **Hint Styling**: Applied via `aws-field__hint` class; appears below the checkbox with paragraph styling (line 964, Checkbox.tsx).

## States

| State | Appearance Change |
|-------|------------------|
| Default | Border `apt-border`, background `apt-bg`, checkmark hidden |
| Checked | Border `apt-gold`, background `apt-gold`, checkmark visible with `text-current` (white/light) |
| Focused | 2px ring with `apt-gold/25` opacity around the checkbox |
| Disabled | 50% opacity applied, cursor changes to `not-allowed`, pointer events disabled |
| Switch Mode | Input role set to `switch` instead of `checkbox`; visual appearance unchanged |
| Check Mode | Input role remains implicit checkbox; visual appearance unchanged |

## Accessibility

- **Role**: The input element MUST have `role="switch"` when `appearance='switch'`, or implicit `role="checkbox"` when `appearance='check'` (line 955, Checkbox.tsx).
- **Label Association**: The label MUST be associated with the input via `htmlFor` attribute matching the input's `id` (line 951, Checkbox.tsx).
- **Disabled Announcement**: The `disabled` attribute on the input element signals disabled state to assistive technologies (line 958, Checkbox.tsx).
- **Focus Indicator**: A visible focus ring (2px, `apt-gold/25`) MUST appear on keyboard focus to aid keyboard navigation (line 995, checkbox.tsx).
- **State Changes**: The checked state is communicated to assistive technology by the native `checked` attribute on the input (line 959, Checkbox.tsx) and visually by the `Check` glyph rendered inside the indicator (line 1006, checkbox.tsx). The glyph is present in addition to the `apt-gold` fill, so the state does not depend on color perception alone.
- **Minimum Touch Target**: The primitive's hit area is the 16px `size-4` box (line 994, checkbox.tsx); the form-field wrapper's `<label>` also carries the click target for the whole row (line 951, Checkbox.tsx), but the label's size is set by stylesheet rules outside these two files. NEEDS REVIEW: Whether the effective target meets the 44×44pt (Apple HIG) / 24×24 CSS px (WCAG 2.2 AA) minimum cannot be decided from the component source — it depends on the padding and line-height the `aws-checkbox` and `aws-field--checkbox` rules apply. The computed box of the rendered `<label>`, measured in the app stylesheet or a browser inspection of a live instance, would settle it.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| checkbox-001 | must-support-controlled-value | `value={true}`, no change | Checkbox renders checked (checkmark visible) |
| checkbox-002 | must-support-controlled-value | `value={false}`, no change | Checkbox renders unchecked (checkmark hidden) |
| checkbox-003 | must-accept-on-change | User clicks checkbox, `value={false}` | `onChange(true)` is called with new value |
| checkbox-004 | must-accept-on-change | User clicks checkbox, `value={true}` | `onChange(false)` is called with new value |
| checkbox-005 | must-support-switch-appearance | `appearance='switch'`, `value={false}` | Input has `role="switch"` and renders as switch toggle |
| checkbox-006 | must-support-check-appearance | `appearance='check'`, `value={false}` | Input has implicit checkbox role and renders as checkbox |
| checkbox-007 | must-default-to-switch-appearance | No `appearance` prop specified | Component renders with switch appearance (role="switch") |
| checkbox-008 | must-support-disabled-state | `disabled={true}`, user attempts click | User interaction is prevented; `onChange` is not called |
| checkbox-009 | must-render-optional-label | `label="Agree to terms"` | Label text renders adjacent to checkbox, associated via htmlFor |
| checkbox-010 | must-render-optional-label | No `label` prop | Label text does not render |
| checkbox-011 | must-render-optional-hint | `hint="Required to proceed"` | Hint text renders below checkbox in paragraph element |
| checkbox-012 | must-render-optional-hint | No `hint` prop | Hint text does not render |
| checkbox-013 | must-associate-label-with-input | User clicks on label text | Input receives focus and toggles (checked state changes) |
| checkbox-014 | must-render-visual-indicator | `value={true}` | Checkmark icon is visible inside checkbox |
| checkbox-015 | must-render-visual-indicator | `value={false}` | Checkmark icon is hidden |
| checkbox-016 | must-support-focus-ring | User tabs to checkbox | Keyboard focus ring (2px, `apt-gold/25`) is visible |
| checkbox-017 | must-apply-custom-classname | `className="my-custom-class"` | Custom class is added to root container |
| checkbox-018 | must-accept-custom-id | `id="my-checkbox"` | Input element has `id="my-checkbox"` and label references it |
| checkbox-019 | must-signal-checked-without-color | `checked` primitive rendered with color rendering suppressed (greyscale) | The `Check` glyph is present in the checked box and absent in the unchecked box |

## Edge Cases

- **No label or hint provided**: The component renders the checkbox without optional elements. The root container still has `aws-field` and `aws-field--checkbox` classes (line 941-945, Checkbox.tsx). MUST render the input and indicator regardless.
- **Very long label text**: No truncation or wrapping specified in source. Text flows according to container width and CSS (label is ReactNode, line 962, Checkbox.tsx). Implementations MUST NOT truncate, since the source applies no truncation.
- **Very long hint text**: No truncation specified. Hint paragraph wraps according to CSS (line 964, Checkbox.tsx). Implementations MUST NOT truncate.
- **Disabled state during user interaction**: The wrapper forwards `disabled` to the native `<input>` (line 958, Checkbox.tsx), so the browser suppresses change events and `onChange` is never invoked. The primitive additionally applies three `disabled:` utilities — `pointer-events-none`, `cursor-not-allowed`, and `opacity-50` (line 997, checkbox.tsx); there are no `data-[disabled]` selectors in either source. Implementations MUST suppress the toggle and MUST render the control at 50% opacity while disabled.
- **Custom className conflicts with aws-field classes**: All classes are joined with filter and space separator; custom className is appended. Last one wins in cascade (line 940-947, Checkbox.tsx). Custom classes MUST be appended after the built-in classes.
- **Missing onChange callback**: `onChange` is a required (non-optional) member of `CheckboxProps` (line 921, Checkbox.tsx), so TypeScript rejects a call site that omits it, and the change handler invokes it unguarded (line 959, Checkbox.tsx). Implementations MUST treat the change callback as a required parameter rather than tolerating its absence.
- **Null or undefined label/hint**: Conditionally rendered via `{label &&` and `{hint &&` checks; no rendering occurs (line 962, line 964, Checkbox.tsx). The component MUST omit the elements entirely rather than rendering empty ones.
- **Rapid toggling**: No debounce or rate-limiting specified. Each toggle invokes onChange immediately (line 959, Checkbox.tsx). Implementations MUST emit one callback per toggle with no coalescing.
- **Concurrent access**: Not applicable: both implementations are React function components that render and dispatch events on the browser's single UI thread; no shared mutable state exists in either file.
- **Error states and offline behavior**: Not applicable: the component performs no I/O — it reads a boolean prop and calls a callback (lines 920-921, 959, Checkbox.tsx) — so there is no dependency that can fail or disconnect.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `value` | boolean | Required | Controlled checked state. MUST be provided. |
| `onChange` | (value: boolean) => void | Required | Callback invoked when user toggles the checkbox. MUST be provided. |
| `appearance` | 'switch' \| 'check' | 'switch' | Visual and semantic mode: switch toggles with switch role, check renders as checkbox. |
| `disabled` | boolean | false | When true, prevents user interaction and applies disabled styling. |
| `label` | ReactNode | undefined | Optional label text rendered adjacent to checkbox with associated htmlFor. |
| `hint` | ReactNode | undefined | Optional hint text rendered below checkbox in a paragraph element. |
| `className` | string | undefined | Custom CSS class(es) appended to the root container. |
| `id` | string | Generated UUID | HTML id attribute for the input element, used for label association. Auto-generated if not provided. |
| `checked` (uncontrolled) | boolean | undefined | For uncontrolled mode: initial checked state. Use with `defaultChecked` instead of `value`. |
| `defaultChecked` (uncontrolled) | boolean | false | For uncontrolled mode: initial checked state. Replaces `value` prop for uncontrolled usage. |

## Deep Linking

Not applicable: This component is a form input, not a routable page or section. Deep linking is the responsibility of the containing page or form.

## Localization

Not applicable: The component's label, hint, and any ARIA attributes are provided as ReactNode props by the caller and are not hardcoded in the component. Localization is handled at the call site.

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | No motion is animated. The only transition in the source is `transition-colors` on the primitive root (line 994, checkbox.tsx), which animates border and background color; neither source file queries `prefers-reduced-motion`. There is nothing to disable under Reduce Motion. |
| Increase Contrast | All colors resolve from the `apt-border`, `apt-bg`, and `apt-gold` design tokens (line 994, line 996, checkbox.tsx); the component hardcodes no color value, so implementations MUST use those tokens and any high-contrast theme variant carries through automatically. NEEDS REVIEW: Neither source file defines the tokens, so whether a high-contrast variant exists and whether the checked fill meets WCAG 2.1 AA (4.5:1 for the checkmark on `apt-gold`, 3:1 for the `apt-border` outline on `apt-bg`) cannot be determined here. The stylesheet or theme file that defines the `apt-*` custom properties, run through a contrast checker, would settle it. |
| Differentiate Without Color | Satisfied. The checked state is signalled by two independent channels: the `apt-gold` border and fill (line 996, checkbox.tsx) and the `Check` glyph rendered by the indicator (line 1006, checkbox.tsx), which is absent when unchecked. In switch appearance the input also carries `role="switch"` (line 955, Checkbox.tsx), so assistive technology announces on/off independently of appearance. Implementations MUST keep the glyph, not color alone, as the checked indicator. |

## Feature Flags

Not applicable: No feature flags or conditional compilation logic appear in the source code. The component is always enabled.

## Analytics

Not applicable: The component source contains no event tracking, logging, or analytics instrumentation. Analytics integration is the responsibility of the containing form or application.

## Privacy

Not applicable: The component does not collect, store, or transmit user data beyond the boolean checked state passed to the `onChange` callback. No sensitive information is handled by the component itself.

## Logging

Not applicable: No logging or debugging output is present in the component source. Logging is the responsibility of the containing application or the `onChange` callback handler.

## Platform Notes

- **React/Web**: The source platform. Two files implement it. `packages/web/packages/controls/src/user-settings/components/Checkbox.tsx` is the form-field wrapper: a `<div class="aws-field aws-field--checkbox aws-field--checkbox-{appearance}">` containing a `<label htmlFor>` that wraps a native `<input type="checkbox">`, a `<span class="aws-checkbox__indicator">`, and the optional label span, with the hint as a sibling `<p class="aws-field__hint">`. `packages/web/packages/ui/src/components/checkbox.tsx` is the styled primitive: a thin wrapper over `@base-ui/react/checkbox` with `apt-*` Tailwind tokens and a Lucide `Check` glyph in the indicator slot. Specific to web: `useId()` for the generated field id, the `role="switch"` override on a native checkbox input, and the fact that all visual states are expressed as CSS selectors (`focus-visible:`, `data-[checked]`, `disabled:`) rather than as code branches.

- **SwiftUI**: Start from `Toggle(isOn:)` — `.toggleStyle(.switch)` for `appearance == 'switch'`, and a custom `ToggleStyle` drawing a 16pt `RoundedRectangle(cornerRadius: 4)` with an `Image(systemName: "checkmark")` overlay for `appearance == 'check'`, since SwiftUI ships no checkbox style on iOS (`.checkbox` exists on macOS only). Bind the `value`/`onChange` pair to a single `Binding<Bool>`; SwiftUI has no separate change callback. The hint becomes the `Toggle`'s second label line or a `Text` below with `.font(.caption)`. `.disabled(true)` replaces the `disabled` prop and dims the control automatically, so the explicit 50% opacity rule is redundant. Focus ring is system-drawn via `.focusable()`; do not reimplement it.

- **Compose**: Use `Switch(checked:onCheckedChange:)` for switch appearance and `Checkbox(checked:onCheckedChange:)` for check appearance — Material 3 treats them as distinct controls, so branch on `appearance` at the call site rather than styling one into the other. Wrap the control and label in a `Row(verticalAlignment = Alignment.CenterVertically)` with `Modifier.toggleable(value, role = Role.Checkbox, onValueChange = ...)` on the row so tapping the label toggles, which is what the web `<label htmlFor>` provides for free. Colors come from `CheckboxDefaults.colors(checkedColor = ...)` mapped to the `apt-gold`/`apt-border`/`apt-bg` tokens. Material's default 48dp minimum touch target already exceeds the web component's 16px box.

- **AppKit / UIKit**: On macOS, use `NSButton(checkboxWithTitle:target:action:)` for check appearance (its `title` carries the label, replacing the separate span) and `NSSwitch` plus an `NSTextField` label for switch appearance; read and write `state` as `.on`/`.off`. On iOS, use `UISwitch` for switch appearance and a `UIButton` with `UIButton.Configuration` plus `UIImage(systemName: "checkmark.square.fill")` / `"square"` for check appearance, since UIKit has no checkbox control. Wire `.valueChanged` (or the button action) to the change callback. The hint is a second `UILabel`/`NSTextField` with a secondary text color beneath the control. Set `isEnabled = false` for the disabled state; unlike the web source, neither framework dims a disabled custom button automatically, so apply `alpha = 0.5` to match.

- **WinUI 3**: Use `CheckBox` when `appearance` is `check` and `ToggleSwitch` when it is `switch`; both derive from `ToggleButton`-style semantics and expose the checked state as a two-way bindable property — `CheckBox.IsChecked` (`bool?`, so coerce `null` to `false`, as the source has no indeterminate state) and `ToggleSwitch.IsOn`. Bind with `{x:Bind ViewModel.Value, Mode=TwoWay}` rather than handling `Checked`/`Unchecked` separately, which matches the source's single `onChange(boolean)` callback; if you use events, handle `CheckBox.Checked` *and* `CheckBox.Unchecked` (or `ToggleSwitch.Toggled`) or the false transition is lost. Put the label in `Content` — that makes the label clickable, the equivalent of `<label htmlFor>` — and suppress `ToggleSwitch.OnContent`/`OffContent` (set `OnContent="{x:Null}"`) because the web source renders no on/off text. The hint is a separate `TextBlock` below with `Style="{StaticResource CaptionTextBlockStyle}"` and `Foreground="{ThemeResource TextFillColorSecondaryBrush}"`; wire `AutomationProperties.DescribedBy` to it, since WinUI does not associate it implicitly. Map the `apt-*` tokens to `SolidColorBrush` entries in a `ResourceDictionary` and override `CheckBoxCheckBackgroundFillChecked`/`CheckBoxCheckBackgroundStrokeChecked` (and `ToggleSwitchFillOn`) rather than rewriting the `ControlTemplate`; the default template's `CommonStates`/`CheckStates` `VisualStateGroup`s already cover the Default, Checked, Focused (`FocusVisualPrimaryBrush`, the analogue of the 2px `apt-gold/25` ring) and Disabled states this recipe specifies. `IsEnabled="False"` applies the platform's own disabled dimming and blocks input, so no opacity override is needed. WinUI's default `CheckBox` hit area is 32×32px with the glyph at 14px, already larger than the source's 16px box.

## Design Decisions

1. **Appearance modes (switch vs. check)**: The source provides two distinct visual modes via the `appearance` prop. Switch mode sets `role="switch"` for semantic correctness; check mode uses implicit checkbox role. This aligns with WCAG and platform conventions (Apple HIG distinguishes toggles from checkboxes; Material Design 3 separates Checkbox and Switch as distinct controls).
2. **Default appearance**: Defaulting to 'switch' (line 923, Checkbox.tsx) suggests this component is primarily intended for toggle-like use cases in the form field wrapper; implementors should confirm this is the desired default for their platform.
3. **Required value and onChange props**: Both props are typed as required in `CheckboxProps` interface (lines 920-921, Checkbox.tsx), not optional. This enforces controlled component behavior and prevents accidental uncontrolled usage at the form field level. The underlying Base UI component supports both modes (line 989-990, checkbox.tsx).
4. **No aria-label or aria-describedby on base component**: Accessibility relies on label association via `htmlFor` and the disabled attribute. Additional ARIA attributes (e.g., `aria-describedby` for the hint) are not automatically applied and would need to be added by the wrapper or the caller.
5. **Icon sizing and stroke**: Checkmark is size-3 (12px) with strokeWidth 3 (line 1006, checkbox.tsx). This is smaller than the 16px container to avoid visual clipping; the 3px stroke ensures visibility at this small size.
6. **Color transition only**: The primitive animates `transition-colors` and nothing else (line 994, checkbox.tsx). Because no geometry or opacity is animated, the component has no motion to suppress under Reduce Motion, and the SHOULD-level deviation other components take there does not arise here.
7. **Two independent checked signals**: The checked state changes both the fill/border to `apt-gold` and reveals the `Check` glyph (line 996, line 1006, checkbox.tsx). The glyph is what makes `must-signal-checked-without-color` testable; an implementation that drops it and keeps only the color fill would regress the Differentiate Without Color behavior.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| Keyboard Navigation | Passed | Accessibility (input type="checkbox" supports native keyboard interaction; focus ring visible) |
| Semantic HTML | Passed | Accessibility (role="switch" or implicit checkbox role used; label associated via htmlFor) |
| Focus Management | Passed | Accessibility (focus ring visible on keyboard focus) |
| Differentiate Without Color | Passed | Accessibility (checked state carries the `Check` glyph in addition to the `apt-gold` fill) |
| WCAG 2.1 Color Contrast | Pending | Accessibility (token values are not defined in the component source; see the Increase Contrast gap in Accessibility Options) |
| Touch Target Size | Pending | Accessibility (the 16px primitive box is smaller than the 44×44pt guidance; see the Minimum Touch Target gap in Accessibility) |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.1.0 | 2026-09-22 | Mike Fullerton | Answer source-visible questions in place (disabled selectors, color transition, checked-state signalling, required change callback); add Windows platform guidance; promote to review |
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
