---
id: 3562bffe-c137-4f4e-91da-f9ef27a5b712
title: Markdown Theme Switcher
domain: agenticdevelopertoolkit://recipes/markdown-theme-switcher
type: ingredient
version: 1.0.0
status: review
language: en
created: 2026-09-22
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A dropdown selector for choosing between predefined markdown viewing themes.
platforms:
- typescript
- web
tags:
- theme-selection
- dropdown
- markdown-viewer
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Markdown Theme Switcher

## Overview

The Markdown Theme Switcher is a theme picker component for the MarkdownViewer. It renders as a labeled dropdown (native `<select>`) that allows users to switch between available reading themes. The component is self-contained and emits a callback when the user selects a different theme.

## Behavioral Requirements

- **must-accept-active-theme-id**: Component MUST accept a `activeThemeId` prop (string) identifying the currently selected theme.
- **must-emit-theme-change**: Component MUST call the `onThemeChange` callback with the selected theme's id (string) when the user picks a different theme from the dropdown.
- **must-render-themed-options**: Component MUST render an `<option>` element for each theme in the available theme registry, with the theme's id as the `value` and the theme's label as the displayed text.
- **must-mark-active-option**: Component MUST set the `<select>` element's `value` attribute to match the current `activeThemeId`, displaying the active theme as selected in the dropdown.
- **must-use-unique-ids**: Component MUST generate a unique id for the `<select>` element using `useId()` to ensure no collisions when multiple instances render on the same page.
- **must-label-select**: Component MUST render a `<label>` element associated with the `<select>` via `htmlFor` attribute, using the generated id.
- **must-group-elements**: Component MUST render the label and select within a container with `role="group"` to indicate semantic association.
- **must-provide-accessible-label**: Component MUST set `aria-label="Select reading theme"` on the select element for screen reader users.

## Appearance

- **Layout**: Flex row, centered vertically, gap of 2 units between label and select
- **Label styling**: Whitespace no-wrap, text size extra-small (xs), text color dimmed (apt-text-dim)
- **Select styling**: Height 8 units, width auto (minimum 28 units), padding vertical 0, text size extra-small (xs)
- **Background**: Inherits from Select primitive
- **Border**: Inherits from Select primitive

## States

| State | Appearance change |
|-------|------------------|
| Default | Select shows the active theme label; dropdown is closed |
| Open (focused) | Select expands to show all available options |
| Option highlighted | Hovering or keyboard-navigating to an option highlights it (browser default) |
| Disabled | Not implemented in source; would inherit from Select primitive's disabled state |

## Accessibility

- **Role**: The native `<select>` element exposes the `listbox` role; no additional ARIA needed beyond `aria-label`
- **Label requirement**: Both a visual `<label>` element (via `htmlFor`) and an `aria-label` on the select provide redundant accessible names
- **Keyboard navigation**: The native select supports standard keyboard interaction (arrow keys, Enter/Space to open, arrow keys to navigate options, Enter to select)
- **Screen reader**: Screen readers announce the select's accessible name ("Select reading theme") and the option text when navigating
- **Touch/click target**: The select element is at least 32×32px (browser default); the label is adjacent and can be clicked to focus the select

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| theme-001 | must-accept-active-theme-id | `activeThemeId="dark"` and three themes in registry (light, dark, high-contrast) | Select element has `value="dark"` |
| theme-002 | must-mark-active-option | User renders component with `activeThemeId="light"` then changes to `activeThemeId="high-contrast"` | The selected option in the dropdown visibly changes to "high-contrast" |
| theme-003 | must-emit-theme-change | User selects a different theme from the dropdown | `onThemeChange` callback is invoked with the selected theme's id string |
| theme-004 | must-render-themed-options | Registry contains three themes: `{id: "light", label: "Light"}`, `{id: "dark", label: "Dark"}`, `{id: "hc", label: "High Contrast"}` | Three `<option>` elements render with matching id values and label text |
| theme-005 | must-use-unique-ids | Two instances of the component render on the same page | Each has a distinct `selectId` value; no duplicate `id` attributes in the DOM |
| theme-006 | must-label-select | Component renders | A `<label>` with `htmlFor={selectId}` is present and associated with the select |
| theme-007 | must-provide-accessible-label | Component renders | Select element has `aria-label="Select reading theme"` |
| theme-008 | must-group-elements | Component renders | The wrapper div has `role="group"` |

## Edge Cases

- **Empty theme registry**: If `VIEWER_THEMES` is empty, the select renders with no options. No error is thrown; the select is functional but offers no choices. Behavior: Acceptable (the source does not guard against this).
- **Invalid activeThemeId**: If `activeThemeId` does not match any theme's id in the registry, the select has no matching option and displays with no value selected. Behavior: The select is still interactive; selecting any option will trigger the callback. This is a configuration error, not a component error.
- **Theme id or label mutation**: If a theme object in the registry is mutated after render (e.g., `theme.label` changes), the component does not re-render. The label text in the dropdown will not update. Behavior: SHOULD re-render when the registry changes; the source is not immune to stale references.
- **Rapid onThemeChange calls**: Calling `onThemeChange` in rapid succession (e.g., user clicking multiple options quickly) will trigger multiple callbacks. No debouncing or rate-limiting is applied. Behavior: All callbacks are emitted; the parent must handle multiple rapid changes.
- **Focus loss on theme change**: Selecting a new theme does not retain focus on the select element. The select returns to the default focus state (browser behavior). Behavior: Acceptable; users can re-focus to make another choice.

## Configuration

Not applicable: The component accepts only two required props (`activeThemeId` and `onThemeChange`); there are no optional configuration options.

## Deep Linking

Not applicable: This is a local theme switcher UI element with no associated URL or deep-link pattern. Theme selection may affect the MarkdownViewer's display, but no separate deep-link path is defined for the switcher itself.

## Localization

Not applicable: The only user-facing string is "Theme" (the label text), which is hardcoded in the component. To localize this string, the component would need a prop or context-based label key, which is not implemented in the source.

## Accessibility Options

Not applicable: The component does not respond to platform accessibility settings (Reduce Motion, Increase Contrast, Differentiate Without Color). It uses the native select element, which inherits the browser's default accessibility behavior but does not explicitly adapt to these display modes.

## Feature Flags

Not applicable: The component has no feature flag gating; it is always enabled when imported and rendered.

## Analytics

Not applicable: The component does not emit any analytics events. Parent components may wrap the `onThemeChange` callback to log theme selections.

## Privacy

Not applicable: The component does not collect, store, or transmit any user data. Theme selection is a local UI action.

## Logging

Not applicable: The component does not emit any log messages. Debugging theme changes would require inspecting the `onThemeChange` callback invocations at the parent level.

## Platform Notes

- **React/Web**: Component imports `useId` from React and the `Select` primitive from the ATK UI package. It renders a flex-layout group containing a label and a native `<select>` element. Each theme from `VIEWER_THEMES` renders as an option with its id and label. The select's `onChange` event reads the new value from `e.currentTarget.value` and passes it to the `onThemeChange` callback.
- **SwiftUI**: Implement as a `Picker` control with a `Menu` or `.segmented` style (depending on the number of themes), wrapped in an `HStack` with a label. Bind the `selection` parameter to the active theme id. Emit the selected theme id through a closure callback or environment-driven state binding. Apply `.accessibilityLabel()` with "Select reading theme".
- **Compose**: Implement as an `ExposedDropdownMenuBox` or `DropdownMenu` containing the list of available themes. Use `LazyColumn` or a simple list to render theme options. Bind the selected theme to the `onDismissRequest` callback and emit the selected theme id to the parent. Apply `Modifier.semantics { contentDescription = "Select reading theme" }` for accessibility.
- **AppKit / UIKit**: On macOS, use `NSPopUpButton` or `NSSegmentedControl` (if the theme count is small) to render theme options. On iOS, use `UIPickerView` in a modal or `UISegmentedControl` inline. Bind the selected theme to the control's target-action callback and invoke the theme-change handler with the selected theme's id. Set an accessibility label on the control with `UIAccessibilityLabel("Select reading theme")`.
- **WinUI 3**: Implement as a `ComboBox` control within a `StackPanel` (Horizontal orientation) with a `TextBlock` label. Set `ComboBox.ItemsSource` to the list of themes. Bind `ComboBox.SelectedValuePath` to the theme id and bind `ComboBox.SelectionChanged` to emit the selected theme id. Set `AutomationProperties.Name` to "Select reading theme" for screen reader support. Apply `ComboBox.IsEditable="False"` to enforce selection from the predefined list only.

## Design Decisions

**Use of native `<select>` instead of custom dropdown**: The component reuses the ATK UI Select primitive, which wraps the native HTML `<select>` element. This ensures cross-browser consistency and automatic accessibility features (ARIA roles, keyboard navigation) without custom implementation. A custom dropdown would offer more visual control but at the cost of re-implementing accessibility and keyboard behavior.

**Hardcoded "Theme" label text**: The label is not localized. This is intentional for a component in an English-primary environment, but limits reuse in multilingual contexts. Localization would require accepting a label prop or deriving it from context.

**No debouncing or deduplication of onThemeChange**: Rapid theme selections trigger multiple callbacks. This design choice allows the parent to handle rapid changes as needed (e.g., for analytics or throttling), rather than constraining the behavior in the component. If rapid changes should be rejected, the parent should implement debouncing in the callback handler.

**useId for select id generation**: Using React's `useId()` ensures unique ids without requiring external coordination or props. This is crucial for multiple instances on the same page (e.g., multiple MarkdownViewer + MarkdownThemeSwitcher pairs). The approach is sound for SSR and client-side hydration.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| [WCAG 2.1 Form Labels](agenticdevelopercookbook://compliance/a11y#form-labels) | passed | Accessibility |
| [WCAG 2.1 Keyboard Accessible](agenticdevelopercookbook://compliance/a11y#keyboard-accessible) | passed | Accessibility |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation |
