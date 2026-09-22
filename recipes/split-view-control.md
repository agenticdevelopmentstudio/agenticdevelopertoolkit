---
id: 6e0e27bf-5f7d-46bf-85d0-fb5bdf5dab8a
title: Split View Control
domain: agenticdevelopertoolkit://recipes/split-view-control
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A control that toggles between tabbed and split layout views, collapsing
  to tabbed on narrow viewports.
platforms:
- typescript
- web
tags:
- layout
- view-switcher
- responsive
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Split View Control

## Overview

The Split View Control is a pair of toggle groups that manages layout preference (tabbed vs. split) and pane selection (edit vs. preview) in responsive interfaces. On wide viewports (64rem minimum), users can choose between a split layout (two panes side by side) or a tabbed layout (one pane at a time). On narrow viewports, only the tabbed layout is available, though the user's split preference is remembered and restored when the viewport widens. The control is rendered left-aligned below the surface's header rather than within it, as it belongs to the body content it controls.

## Behavioral Requirements

- **must-render-layout-toggle-on-wide-viewport**: On viewports wider than 64rem, the control MUST render a layout toggle group with two options: tabbed (single pane) and split (side by side).
- **must-not-render-layout-toggle-on-narrow-viewport**: On viewports 64rem or narrower, the control MUST NOT render the layout toggle group.
- **must-render-separator-in-tabbed-mode**: When the layout toggle is rendered AND the effective layout is tabbed, the control MUST render a vertical separator (1px, `bg-apt-border` color) between the layout toggle and the pane toggle.
- **must-not-render-separator-in-split-mode**: When the effective layout is split, the control MUST NOT render a separator.
- **must-render-pane-toggle-only-in-tabbed-layout**: The pane toggle group (edit/preview) MUST render only when the effective layout is tabbed.
- **must-not-render-pane-toggle-in-split-layout**: When the effective layout is split, the pane toggle MUST NOT render (both panes are already visible).
- **must-preserve-layout-preference-across-viewport-changes**: The user's layout preference MUST be retained when the viewport narrows below 64rem and restored when widening above 64rem.
- **must-demote-effective-layout-on-narrow-viewport**: On narrow viewports, the effective layout MUST be "tabbed" regardless of the stored layout preference.
- **must-support-customizable-edit-label**: The edit toggle label MUST be customizable via the `editLabel` prop, defaulting to "Edit".
- **must-support-customizable-preview-label**: The preview toggle label MUST be customizable via the `previewLabel` prop, defaulting to "Preview".
- **must-render-flex-row-layout**: The control MUST render as a flex row with items center-aligned and 0.75rem (gap-3) spacing between children.
- **must-ignore-empty-toggle-selection**: When a user clicks a toggle group item that is already selected, the toggle group hands back an empty array; the control MUST ignore this event and retain the current selection.
- **must-provide-aria-label-for-layout-toggle**: The layout toggle group MUST have an `aria-label` that reads `"${subject} layout"` where `subject` is the component-provided context string.
- **must-provide-aria-label-for-pane-toggle**: The pane toggle group MUST have an `aria-label` that reads `"${subject} pane"`.
- **must-connect-pane-toggle-to-pane-container**: Each pane toggle item MUST have an `aria-controls` attribute pointing to the ID (`panesId`) of the pane container element (placed on the container, not on individual hidden panes).
- **must-add-title-attribute-to-layout-toggles**: The layout toggle items MUST have `title` attributes: "Single tabbed view" for tabbed, "Side by side view" for split.
- **must-render-tabbed-icon-as-square**: The tabbed layout toggle MUST display a Square icon.
- **must-render-split-icon-as-columns**: The split layout toggle MUST display a Columns2 icon.
- **must-render-edit-icon-as-pencil**: The edit pane toggle MUST display a Pencil icon before its label.
- **must-render-preview-icon-as-eye**: The preview pane toggle MUST display an Eye icon before its label.

## Appearance

- **Layout**: Flex row, `items-center` (vertical center alignment), `gap-3` (0.75rem spacing)
- **Toggle groups**: Uses shared ToggleGroup component for both layout and pane toggles
- **Separator**: 1px width, `bg-apt-border` color, height 1.25rem (h-5), only rendered in tabbed mode when layout toggle is visible
- **Icons**: Lucide React icons (Square, Columns2, Pencil, Eye)
- **Responsive**: No visual changes between tabbed and split layouts; layout toggle visibility alone changes based on viewport
- **Custom className**: The component MUST accept an optional `className` prop and merge it with the base flex layout using `cn()` utility

## States

| State | Appearance change |
|-------|------------------|
| Wide viewport | Layout toggle and pane toggle both visible if effective layout is tabbed; separator visible between them |
| Narrow viewport | Layout toggle hidden; pane toggle visible (effective layout forced to tabbed) |
| Split layout (wide viewport) | Layout toggle visible; pane toggle hidden (no selection needed when both panes are visible) |
| Tabbed layout (wide viewport) | Layout toggle visible; pane toggle visible; separator visible between them |
| Toggle pressed | The pressed toggle item is visually highlighted by the ToggleGroup component; clicking an already-pressed item is ignored |

## Accessibility

- **Roles**: Each toggle group is a segmented control / buttonset; individual items are toggle buttons
- **Label requirements**: Layout toggle has `aria-label="${subject} layout"`; pane toggle has `aria-label="${subject} pane"`; individual toggle items have `aria-label` and `title` attributes
- **Pane control association**: Pane toggle items have `aria-controls="${panesId}"` pointing to the container element wrapping the two panes (not placed on individual hidden panes)
- **Announce visibility**: The layout toggle is not rendered on narrow viewports, so the control renders a smaller footprint — no aria-hidden needed for the unrendered toggle
- **Title attributes**: Both layout toggle items have `title` attributes for mouse hover: "Single tabbed view" and "Side by side view"
- **Hidden separator**: When the separator is not rendered, it is not in the DOM; no `aria-hidden` needed
- **Minimum touch/click target**: Handled by the ToggleGroup and ToggleGroupItem components; SplitViewControl assumes the underlying component meets platform touch targets (44×44pt minimum on iOS, 48×48dp on Android, 44×44px on web per WCAG)

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| split-view-001 | must-render-layout-toggle-on-wide-viewport | Wide viewport (≥64rem) | Layout toggle group renders with tabbed and split options |
| split-view-002 | must-not-render-layout-toggle-on-narrow-viewport | Narrow viewport (<64rem) | Layout toggle group does not render |
| split-view-003 | must-render-separator-in-tabbed-mode | Wide viewport, effective layout tabbed | Vertical separator (1px, bg-apt-border) renders between layout and pane toggles |
| split-view-004 | must-not-render-separator-in-split-mode | Wide viewport, effective layout split | Separator does not render |
| split-view-005 | must-render-pane-toggle-only-in-tabbed-layout | Effective layout tabbed | Pane toggle group renders with edit and preview options |
| split-view-006 | must-not-render-pane-toggle-in-split-layout | Effective layout split | Pane toggle group does not render |
| split-view-007 | must-preserve-layout-preference-across-viewport-changes | User selects split layout on wide viewport, then resize to narrow (<64rem), then resize back to wide (≥64rem) | Layout preference is "split" before narrow, remains "split" during narrow (though effective is "tabbed"), and effective becomes "split" again when widening |
| split-view-008 | must-demote-effective-layout-on-narrow-viewport | Viewport narrower than 64rem, layout preference is "split" | Effective layout is "tabbed" |
| split-view-009 | must-support-customizable-edit-label | Render with `editLabel="Author"` | Edit toggle label reads "Author" instead of default "Edit" |
| split-view-010 | must-support-customizable-preview-label | Render with `previewLabel="Published"` | Preview toggle label reads "Published" instead of default "Preview" |
| split-view-011 | must-render-flex-row-layout | Render control in any state | Control renders as a flex row with center vertical alignment and consistent horizontal spacing |
| split-view-012 | must-ignore-empty-toggle-selection | Layout toggle shows "split" selected; user clicks the "split" button again | Selection remains "split", no state change triggered |
| split-view-013 | must-provide-aria-label-for-layout-toggle | Render with `subject="Editor"` | Layout toggle group has `aria-label="Editor layout"` |
| split-view-014 | must-provide-aria-label-for-pane-toggle | Render with `subject="Document"` | Pane toggle group has `aria-label="Document pane"` |
| split-view-015 | must-connect-pane-toggle-to-pane-container | Render control | Each pane toggle item has `aria-controls` attribute matching the `panesId` from the view state |
| split-view-016 | must-add-title-attribute-to-layout-toggles | Render layout toggle on wide viewport | Tabbed toggle has `title="Single tabbed view"`; split toggle has `title="Side by side view"` |
| split-view-017 | must-render-tabbed-icon-as-square | Render layout toggle on wide viewport | Tabbed toggle item renders with Square icon |
| split-view-018 | must-render-split-icon-as-columns | Render layout toggle on wide viewport | Split toggle item renders with Columns2 icon |
| split-view-019 | must-render-edit-icon-as-pencil | Render pane toggle in tabbed mode | Edit toggle item renders with Pencil icon before label |
| split-view-020 | must-render-preview-icon-as-eye | Render pane toggle in tabbed mode | Preview toggle item renders with Eye icon before label |

## Edge Cases

- **Empty `subject` string**: If `subject` is an empty string, `aria-label` values will be malformed (e.g., `" layout"`). Behavior is defined: the component will render the malformed label as-is; the host MUST provide a non-empty `subject`.
- **Undefined or null `subject`**: The component expects `subject` to be a string. If undefined or null is passed, string concatenation will produce `"undefined layout"` or `"null layout"`. Behavior is defined; the host MUST provide a string value.
- **Viewport at exactly 64rem**: The media query uses `min-width: 64rem`, so a viewport exactly 64rem wide MUST render the layout toggle.
- **Viewport narrowing mid-selection**: If the user selects "split" layout, then the viewport narrows below 64rem, the layout preference remains "split", but effective becomes "tabbed" and both toggles behave as if the user were in tabbed mode. Widening restores the split.
- **Rapid toggle clicks**: The component uses `onValueChange` from ToggleGroup; if the user clicks toggles rapidly, the state updates follow the ToggleGroup behavior (empty array from re-clicking is ignored, so the selection is sticky).
- **Missing `panesId`**: If the `view.panesId` is not set or is empty string, `aria-controls` values will be invalid. The component renders them as-is; the host MUST generate a valid ID via `useSplitView`.
- **Custom className conflicts**: If the custom `className` includes conflicting Tailwind classes (e.g., `gap-2` when the base is `gap-3`), the specificity and order of classes in the `cn()` call determines the outcome. The behavior follows Tailwind's CSS precedence rules.
- **ToggleGroup with no selection**: The ToggleGroup component always maintains a selection (it does not allow an unselected state). If somehow the underlying state becomes undefined, the component renders without highlighting any item (ToggleGroup behavior).

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `view` | SplitView object | required | State object from `useSplitView()` hook, containing layout, pane, effective, wide, showEditor, showPreview, and panesId |
| `subject` | string | required | Context string describing what is being switched (e.g., "Editor", "Document"), used in aria-labels |
| `editLabel` | string | "Edit" | Label text for the edit toggle item |
| `previewLabel` | string | "Preview" | Label text for the preview toggle item |
| `className` | string | undefined | Optional CSS class name(s) to merge with base flex layout |

## Deep Linking

Not applicable: This component is a control that manages view state within a larger page. It does not itself navigate or respond to deep links; the host page that contains this control responds to deep links and uses the SplitViewControl to switch views.

## Localization

| String Key | Default (en) | Context |
|-----------|-------------|---------|
| `editLabel` prop | "Edit" | Label for the edit pane toggle item; passed as a prop, not a key |
| `previewLabel` prop | "Preview" | Label for the preview pane toggle item; passed as a prop, not a key |
| `layout toggle (tabbed)` | "Single tabbed view" | Title and aria-label for the tabbed layout toggle item (hardcoded) |
| `layout toggle (split)` | "Side by side view" | Title and aria-label for the split layout toggle item (hardcoded) |

## Accessibility Options

Not applicable: This component is a control that displays or hides based on viewport width (media query) and responds to user toggles. It does not implement accessibility display options like Reduce Motion, Increase Contrast, or Differentiate Without Color. Those concerns are owned by the ToggleGroup component and the surface that hosts SplitViewControl; if the ToggleGroup responds to these options, SplitViewControl inherits that behavior.

## Feature Flags

Not applicable: This component is not wrapped in or controlled by a feature flag. The host surface that renders this control may gate it behind a feature flag if desired.

## Analytics

Not applicable: This component does not emit analytics events directly. Event tracking is the responsibility of the host surface that manages the `useSplitView` hook and calls `setLayout` and `setPane`. If the host wants to track layout or pane changes, it wraps those setters with analytics calls.

## Privacy

Not applicable: This component does not collect, store, transmit, or retain any user data beyond the ephemeral state object (layout preference and pane selection) passed to it. Those values are primitives and are not sensitive.

## Logging

Not applicable: This component does not emit log messages or diagnostic output. All state transitions are synchronous and handled by the host.

## Platform Notes

- **React/Web**: The component is implemented in `packages/web/packages/ui/src/blocks/split-view-control.tsx`. It uses React hooks (`useId`, `useState`), the `useMediaQuery` custom hook for viewport detection, and Lucide React icons. The media query is `(min-width: 64rem)`. Both ToggleGroup components expect a `value` array and call `onValueChange` with an array; the component filters empty arrays to implement sticky selection. The separator is a styled div with `h-5 w-px bg-apt-border`.
- **SwiftUI**: A SwiftUI equivalent would use `@Environment(\.horizontalSizeClass)` or a GeometryReader to detect wide viewports. State would be held in a view model or parent view using `@State` for layout and pane selection. The control would conditionally render the layout Picker and separator based on size class. Icons would come from SF Symbols.
- **Compose**: An Android equivalent would use `BoxWithConstraints` or `currentWindowAdaptiveInfo()` to detect viewport width (64rem ≈ 1024dp for baseline density). State would be in a ViewModel using `mutableStateOf`. Both toggle groups would be rendered as Compose segmented controls or custom radio button rows. Lucide icons would need Android equivalents from Material icons or a custom icon library.
- **AppKit / UIKit**: On macOS/iOS, use `NSApplication.shared.keyWindow?.frame.width` or view geometry to detect the wide viewport. State would be managed via a coordinator or reactive binding (Combine, SwiftUI, or property observers). The control would render segmented controls or button groups. On iOS, a narrow viewport would hide the layout toggle. The design language follows Apple's segmented picker conventions.
- **WinUI 3**: A WinUI equivalent would use `Window.Current.Bounds` or adaptive triggers to detect the wide viewport (64rem ≈ 1024px). State would be in a ViewModel using `INotifyPropertyChanged`. Render two ToggleButton groups (or custom SegmentedControl, if available) with RadioButton elements inside. The layout toggle would be hidden on narrow viewports using `Visibility.Collapsed`. Icons would come from the Segoe MDL2 Assets font or a custom icon resource. The vertical separator would be a Border or Line control with `BorderThickness="1,0,0,0"` and `BorderBrush` set to a border token.

## Design Decisions

**Preference vs. effective layout distinction**: The component separates the user's layout preference from the effective layout shown on screen. This allows the user's choice to be remembered and restored when the viewport widens, rather than silently demoting to a one-pane experience and losing the choice. This design reduces cognitive friction: the user doesn't have to re-select split after rotating their device or resizing their window.

**Sticky toggle selection**: The underlying ToggleGroup component emits an empty array when a user clicks an already-selected toggle item. The component explicitly ignores this event by checking `if (picked)` before updating state. This implements a segmented control pattern where selection is always maintained, rather than a toggle pattern where clicking twice returns to a deselected state.

**No control rendering on narrow viewport**: The layout toggle is not rendered at all on narrow viewports (using a conditional `{wide &&}`), rather than rendered and disabled. This follows the principle that an affordance you can see but never use (a disabled button) is worse than no affordance at all. Users on small screens see a smaller, simpler control.

**Separator timing**: The separator appears only when both the layout toggle (wide viewport) and pane toggle (tabbed mode) are visible, visually grouping the two controls. In split mode, no pane toggle is needed, so no separator appears.

**aria-controls on pane toggles, not hidden panes**: Each pane toggle item has `aria-controls` pointing to the container element that wraps both panes, not to the individual pane elements. This is because in tabbed mode, only one pane is mounted at a time; an `aria-controls` reference to the hidden pane would be a dangling reference (ignored by assistive technology). By pointing to the container, the relationship is always valid.

**Subject parameter for aria-labels**: The component requires a `subject` parameter so that accessible names are context-specific (e.g., "Editor layout" vs. "Document layout"). This avoids generic, unhelpful labels when multiple SplitViewControls appear on the same page. The host must provide this context.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| [template-conformance](agenticdevelopercookbook://guidelines/cookbook/recipe-quality/template-conformance) | passed | Recipe Quality |
| [behavioral-requirements](agenticdevelopercookbook://guidelines/cookbook/recipe-quality/behavioral-requirements) | passed | Recipe Quality |
| [source-fidelity](agenticdevelopercookbook://guidelines/cookbook/recipe-quality/source-fidelity) | passed | Recipe Quality |
| [completeness](agenticdevelopercookbook://guidelines/cookbook/recipe-quality/completeness) | passed | Recipe Quality |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | (generated) | Initial creation |
