---
id: 240f8d48-45af-49ea-aebf-95d756d74707
title: SplitDivider
domain: agenticdevelopercookbook://ingredients/split-divider
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A draggable and keyboard-operable separator that splits a container into
  two panes, reporting a ratio of space given to the leading pane.
platforms:
- typescript
- web
tags:
- layout
- divider
- resizable
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# SplitDivider

## Overview

SplitDivider is a bare separator primitive that allows users to resize the space between two panes by dragging a divider or using keyboard controls. It reports a ratio (0–1) representing the fraction of the split given to the leading pane (above for horizontal, left for vertical). The component owns neither the panes nor any collapse state; the caller renders the regions and applies the ratio to layout. It is designed for layouts like search results / preview panes or repository tree / activity log pairs.

## Behavioral Requirements

- **must-render-separator**: Component MUST render an element with `role="separator"`.
- **must-track-ratio**: Component MUST call `onRatioChange` with a new ratio (0–1, clamped to `minRatio` and `maxRatio`) when the user drags or operates keyboard/step controls.
- **must-clamp-ratio**: Component MUST clamp the reported ratio to the range `[minRatio, maxRatio]` before calling `onRatioChange`.
- **must-support-horizontal-orientation**: Component MUST support `orientation="horizontal"` (default), splitting vertical space with a horizontal line and responding to vertical drags and up/down arrow keys.
- **must-support-vertical-orientation**: Component MUST support `orientation="vertical"`, splitting horizontal space with a vertical line and responding to horizontal drags and left/right arrow keys.
- **must-accept-ratio-prop**: Component MUST accept a `ratio` prop (0–1) and use it to set `aria-valuenow` as a percentage (rounded to nearest integer).
- **must-accept-minmax-ratio**: Component MUST accept `minRatio` (default 0.2) and `maxRatio` (default 0.8) props and expose them as `aria-valuemin` and `aria-valuemax` (as percentages).
- **must-accept-container-ref**: Component MUST accept a `containerRef` prop (React.RefObject) pointing to the layout container and use it to measure pointer drag offsets.
- **must-support-drag-resize**: Component MUST support pointer drag to resize; on `pointerdown`, capture the pointer; on `pointermove`, calculate the new ratio from the pointer position relative to the container; on `pointerup` or `pointercancel`, release capture and end the drag.
- **must-end-drag-on-button-release**: Component MUST end the drag if the primary pointer button is released mid-drag (checked via `event.buttons & 1 === 0`).
- **must-ignore-zero-extent**: Component MUST not apply a drag resize if the container extent (height for horizontal, width for vertical) is zero.
- **must-support-keyboard-shrink**: Component MUST decrement the ratio by `step` (default 0.03) on the shrink arrow (up for horizontal, left for vertical) and call `onRatioChange`.
- **must-support-keyboard-grow**: Component MUST increment the ratio by `step` on the grow arrow (down for horizontal, right for vertical) and call `onRatioChange`.
- **must-support-home-key**: Component MUST set the ratio to `minRatio` on Home key press.
- **must-support-end-key**: Component MUST set the ratio to `maxRatio` on End key press.
- **must-render-visual-line**: Component MUST render a thin visual divider line (3px) centered in the 24px grab row/column, colored with `apt-border` and changing to `apt-border-strong` on hover and focus.
- **must-render-step-buttons**: Component MUST render two step buttons (24px × 24px, fully contained within the 24px grab row/column) for incrementing and decrementing the ratio, with aria-labels describing the resize direction.
- **must-apply-grab-cursor**: Component MUST apply `cursor-row-resize` for horizontal orientation and `cursor-col-resize` for vertical orientation.
- **must-size-grab-area-24px**: Component MUST size the root row/column to 24px width (vertical) or height (horizontal) and full length on the opposite axis.
- **must-make-grab-area-focusable**: Component MUST set `tabIndex={0}` on the separator to make it keyboard-operable.
- **must-set-default-label**: Component MUST set `aria-label` to "Resize split" by default (overridable via the `label` prop).
- **must-accept-step-button-labels**: Component MUST accept `growBottomLabel` and `growTopLabel` props for accessible step button labels; if not provided, MUST default to labels like "Grow bottom pane" (horizontal) or "Grow left pane" (vertical).
- **must-apply-focus-ring**: Component MUST show a focus-visible ring (2px, `apt-gold/40`) when the separator receives keyboard focus.
- **must-accept-classname-prop**: Component MUST accept a `className` prop for additional CSS classes on the root element.
- **must-use-touch-none**: Component MUST apply `touch-none` CSS class to prevent the default touch-drag behavior and allow the pointer handler to control resize.
- **must-use-select-none**: Component MUST apply `select-none` CSS class to prevent text selection during drag.

## Appearance

- **Width/Height**: 24px (6 units with `h-6` / `w-6` in Tailwind), full length on the opposite axis (full width for horizontal, full height for vertical).
- **Visual line**: 3px wide (horizontal) or 3px tall (vertical), `apt-border` color, centered in the 24px grab area.
- **Line hover state**: `apt-border-strong` color on hover.
- **Line focus state**: `apt-border-strong` color on focus.
- **Focus ring**: 2px solid ring, color `apt-gold/40`, visible only on keyboard focus (`:focus-visible`).
- **Step button size**: 24px × 24px, positioned absolutely within the grab area.
- **Step button colors**: `text-apt-text-muted` (default), `text-apt-text` on hover.
- **Step button icons**: Unicode arrow glyphs (▲/▼ for horizontal, ◀/▶ for vertical).
- **Corner radius**: 4px (`rounded-sm`) on the separator; 4px on step buttons.
- **Cursor**: `cursor-row-resize` for horizontal, `cursor-col-resize` for vertical.
- **Background**: Transparent (no explicit background color set).

## States

| State | Appearance change |
|-------|------------------|
| Default | Visual line is `apt-border`; step buttons are `text-apt-text-muted` |
| Hover | Visual line is `apt-border-strong`; step buttons are `text-apt-text` on hover |
| Keyboard focus | Visual line is `apt-border-strong`; 2px `apt-gold/40` focus ring visible |
| Dragging | (visual line color unchanged; internal state tracking) |

## Accessibility

- **Role**: `role="separator"` per ARIA authoring practices for resizable panes.
- **Orientation**: `aria-orientation` matches the `orientation` prop (`horizontal` or `vertical`).
- **Value**: `aria-valuenow` (current ratio as percentage, 0–100), `aria-valuemin` (minimum ratio as percentage), `aria-valuemax` (maximum ratio as percentage), all rounded to the nearest integer.
- **Label**: `aria-label` provided for the separator (default "Resize split", overridable). Step buttons each have an `aria-label` (defaults: "Grow top pane" and "Grow bottom pane" for horizontal, "Grow left pane" and "Grow right pane" for vertical).
- **Keyboard navigation**: Component is focusable (`tabIndex={0}`) and supports keyboard resize: arrow keys (up/down for horizontal, left/right for vertical) adjust by `step`, Home sets to `minRatio`, End sets to `maxRatio`.
- **Dragging alternative**: WCAG 2.2 SC 2.5.7 (Dragging Movements) — step buttons provide a single-pointer, non-drag resize alternative for users who cannot perform sustained drags.
- **Target size**: The 24px grab area (including both the visual line and step buttons) meets WCAG 2.2 SC 2.5.8 (Target Size, Minimum) of at least 24×24px. No target bleeds into adjacent panes.
- **Hidden elements**: `aria-hidden="true"` is applied to the visual line and step button icons, as they are decorative and their roles are expressed via ARIA properties and labels.
- **Focus visible**: Focus ring is only shown on keyboard focus (`:focus-visible`), not on pointer focus, to avoid visual clutter during drag.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| split-divider-001 | must-render-separator | Component rendered | Element with `role="separator"` is in the DOM |
| split-divider-002 | must-track-ratio | User drags the separator vertically by 50px; container is 200px tall | `onRatioChange` is called with ratio ≈ 0.25 (50/200) |
| split-divider-003 | must-clamp-ratio | `minRatio=0.2, maxRatio=0.8`; user drags to ratio 0.05 | `onRatioChange` is called with 0.2 (clamped to minRatio) |
| split-divider-004 | must-clamp-ratio | `minRatio=0.2, maxRatio=0.8`; user drags to ratio 0.95 | `onRatioChange` is called with 0.8 (clamped to maxRatio) |
| split-divider-005 | must-support-horizontal-orientation | `orientation="horizontal"` (default); component rendered | Separator renders as a horizontal line; `aria-orientation="horizontal"` is set; vertical drag is tracked |
| split-divider-006 | must-support-vertical-orientation | `orientation="vertical"`; component rendered | Separator renders as a vertical line; `aria-orientation="vertical"` is set; horizontal drag is tracked |
| split-divider-007 | must-accept-ratio-prop | `ratio=0.5`; component rendered | `aria-valuenow="50"` (50% of the split) |
| split-divider-008 | must-accept-minmax-ratio | `minRatio=0.1, maxRatio=0.9`; component rendered | `aria-valuemin="10"`, `aria-valuemax="90"` |
| split-divider-009 | must-support-drag-resize, must-end-drag-on-button-release | User drags the separator and releases the mouse mid-drag | Drag ends; ratio stops updating after release |
| split-divider-010 | must-end-drag-on-button-release | User drags the separator, then the primary button is released while `pointermove` events continue | Drag ends immediately; subsequent `pointermove` events do not resize |
| split-divider-011 | must-ignore-zero-extent | `containerRef` points to a container with zero height; user attempts to drag | `onRatioChange` is not called; the ratio remains unchanged |
| split-divider-012 | must-support-keyboard-shrink | Component is focused; user presses ArrowUp (horizontal) | `onRatioChange` is called with `ratio - step` |
| split-divider-013 | must-support-keyboard-shrink | `orientation="vertical"`; component is focused; user presses ArrowLeft | `onRatioChange` is called with `ratio - step` |
| split-divider-014 | must-support-keyboard-grow | Component is focused; user presses ArrowDown (horizontal) | `onRatioChange` is called with `ratio + step` |
| split-divider-015 | must-support-keyboard-grow | `orientation="vertical"`; component is focused; user presses ArrowRight | `onRatioChange` is called with `ratio + step` |
| split-divider-016 | must-support-home-key | Component is focused; user presses Home | `onRatioChange` is called with `minRatio` |
| split-divider-017 | must-support-end-key | Component is focused; user presses End | `onRatioChange` is called with `maxRatio` |
| split-divider-018 | must-render-visual-line | Component rendered | A 3px line is visible, centered in the 24px grab area, with color `apt-border` |
| split-divider-019 | must-render-step-buttons | Component rendered | Two 24px × 24px buttons are rendered and are clickable |
| split-divider-020 | must-apply-grab-cursor | `orientation="horizontal"`; component rendered | Cursor is `cursor-row-resize` over the separator |
| split-divider-021 | must-apply-grab-cursor | `orientation="vertical"`; component rendered | Cursor is `cursor-col-resize` over the separator |
| split-divider-022 | must-size-grab-area-24px | Component rendered with `orientation="horizontal"` | Root element has `height=24px` and `width=100%` of its container |
| split-divider-023 | must-size-grab-area-24px | Component rendered with `orientation="vertical"` | Root element has `width=24px` and `height=100%` of its container |
| split-divider-024 | must-make-grab-area-focusable | Component rendered | Separator is focusable via Tab key |
| split-divider-025 | must-set-default-label | Component rendered without `label` prop | `aria-label="Resize split"` is set |
| split-divider-026 | must-set-default-label | `label="Custom Resize"`; component rendered | `aria-label="Custom Resize"` is set |
| split-divider-027 | must-accept-step-button-labels | Component rendered with `orientation="horizontal"` and no custom labels | Step button labels are "Grow top pane" and "Grow bottom pane" (defaults) |
| split-divider-028 | must-accept-step-button-labels | `orientation="vertical"`, `growTopLabel="Expand left"`, `growBottomLabel="Expand right"`; component rendered | Step buttons have the custom labels |
| split-divider-029 | must-apply-focus-ring | Component is focused via keyboard; component rendered | A 2px `apt-gold/40` focus ring is visible around the separator |
| split-divider-030 | must-accept-classname-prop | `className="custom-class"`; component rendered | Root element has class `custom-class` applied |

## Edge Cases

- **Zero container extent**: If the container has zero height (horizontal) or zero width (vertical), drag calculations divide by zero. The component detects this and ignores the drag; the ratio remains unchanged until the container is resized.
- **Pointer cancel / lost capture**: If a gesture is cancelled (touch scroll takeover, window blur) or pointer capture is lost, the component ends the drag. Subsequent `pointermove` events do not resize.
- **Extreme ratios**: If `minRatio = 0` and `maxRatio = 1` (range 0–1), the entire spectrum of split sizes is allowed. If `minRatio = maxRatio`, the split is fixed and resize operations will always clamp to that single value.
- **Very large step**: If `step = 0.5`, each keyboard press moves the split by 50% of the container. The clamping logic ensures the ratio never exceeds `[minRatio, maxRatio]`.
- **Rapid key presses**: Repeated arrow key presses (e.g., held down) will call `onRatioChange` once per `onKeyDown` event, applying step adjustments in sequence. No debouncing is applied; all calls are clamped independently.
- **Simultaneous drag and key input**: If the user holds down an arrow key while dragging, both `pointermove` and `onKeyDown` will call `onRatioChange`. The component does not prevent this, and the ratio will be set by whichever input fired last.
- **Step button during drag**: If the user clicks a step button while a drag is in progress, the step button's `onClick` will fire after the drag ends. The behavior depends on the order of pointer events; this is expected React behavior and not guarded against.

## Configuration

Not applicable: The component has no configuration beyond its required and optional props. All behavior is controlled via props (`ratio`, `onRatioChange`, `minRatio`, `maxRatio`, `step`, `containerRef`, `orientation`, `label`, `growBottomLabel`, `growTopLabel`, `className`). There are no configuration files, environment variables, or runtime settings to manage.

## Deep Linking

Not applicable: SplitDivider is a layout primitive with no navigation or routing concerns. It does not emit navigable URLs, query parameters, or deep-link states. Deep linking responsibility belongs to the caller's container and routing system.

## Localization

Not applicable: The component accepts all user-facing strings via props (`label`, `growBottomLabel`, `growTopLabel`), leaving localization entirely to the caller. No hardcoded strings are embedded in the component beyond default aria-labels ("Resize split", "Grow top/bottom pane", "Grow left/right pane"). The caller is responsible for providing localized labels.

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | Not implemented in source. The component uses `transition-colors` on the visual line but does not respond to `prefers-reduced-motion` media query. Callers SHOULD override the transition via CSS if reduced motion is required. |
| Increase Contrast | Not implemented in source. The component uses `apt-border` and `apt-border-strong` tokens, which are defined by the design system. Callers relying on increased contrast SHOULD provide theme overrides or use high-contrast token values. |
| Differentiate Without Color | The component distinguishes state primarily by visual cues: the thin line's color/position changes on hover and focus, and the step buttons display directional glyphs (▲/▼, ◀/▶) that persist regardless of color. The visual and icon cues provide non-color differentiation sufficient to comply with WCAG 2.1 SC 1.4.11 (Non-text Contrast). |

## Feature Flags

Not applicable: The component has no feature flags, runtime toggles, or conditional behavior paths. All functionality is enabled by default and controlled via props. Feature gating is the caller's responsibility if needed.

## Analytics

Not applicable: The component does not emit analytics events, telemetry, or usage tracking. Event emission (e.g., "split_resized") is the caller's responsibility via callbacks passed to `onRatioChange`.

## Privacy

Not applicable: The component does not collect, store, or transmit personal data. The `ratio` value is layout state provided by the caller and does not represent personally identifiable information. All data flows through callbacks (`onRatioChange`) provided by the caller.

## Logging

Not applicable: The component does not emit log entries, diagnostics, or debugging output. Callers MAY add logging in their `onRatioChange` callback if needed for debugging or monitoring.

## Platform Notes

- **React/Web** (source platform): The component is a React functional component (`SplitDivider`) defined in `split-divider.tsx`. It uses React hooks (`useRef`, `useCallback`) for state management and pointer/keyboard event handlers. Styling is applied via Tailwind CSS classes and `cn()` utility function (className merging). Colors use design-system tokens (`apt-border`, `apt-border-strong`, `apt-gold`, `apt-text`, `apt-text-muted`).
- **SwiftUI**: Start from SwiftUI's `Divider` or a custom `Gesture.DragGesture` to track pointer drags. Implement `@State` properties for `isDragging` and bind the ratio via `@State`. Use `.onContinuousHover()` for the hover state color change. Keyboard input is handled via `.onKeyPress()` or `NSEvent.LocalEventMonitor` on macOS. Apply a 24pt width (or height for vertical) and show a thin line centered in it.
- **Compose** (Android/Kotlin): Start from a `Divider` composable or a custom `Canvas`-based implementation. Use `Modifier.draggable()` and `Modifier.pointerInput()` to track drag gestures and pointer events. Implement keyboard handling via `Modifier.onKeyEvent()` or `KeyEventFilter`. Maintain the ratio in a `MutableState<Float>`. Apply size constraints (24.dp width/height) and render a thin line in the center.
- **AppKit / UIKit** (macOS / iOS): On macOS, use `NSSplitViewController` or a custom `NSView` with `NSPanGestureRecognizer` for drags and `NSResponder.interpretKeyEvents()` for keyboard input. On iOS, use `UIDragInteraction` or `UIGestureRecognizer` for drags; keyboard input is less common on iOS but can be handled via `UIKeyCommand`. Render a 24pt divider with a thin line and step buttons.
- **WinUI 3** (Windows): Use `GridSplitter` or a custom `Control` with pointer and keyboard event handlers. Bind the ratio to a dependency property (`RatioDependencyProperty`). Implement `OnPointerPressed`, `OnPointerMoved`, `OnPointerReleased` for drag tracking. Use `ProcessKeyboardInput()` for keyboard shortcuts (up/down arrows, Home, End). Apply a 24px width (or height for vertical). Render the divider and step buttons using XAML layouts (`StackPanel` for the row/column). Use WinUI 3 tokens and brushes for colors (`ControlStrokeColorDefault`, `ControlStrokeColorSecondary`, `AccentFillColorDefaultBrush`). Ensure the target size meets Microsoft accessibility standards (minimum 24×24px).

## Design Decisions

- **24px grab area**: WCAG 2.2 SC 2.5.8 (Target Size, Minimum) requires a minimum 24×24px touch target. The entire 24px row/column is the grab target, ensuring accessibility for pointer and touch users while keeping the visual line thin for minimal visual intrusion.
- **Step button alternative to drag**: WCAG 2.2 SC 2.5.7 (Dragging Movements) requires a non-drag alternative for pointer users who cannot perform sustained drags. The step buttons provide this alternative, allowing incremental resize via single clicks/taps.
- **Keyboard navigation (arrow keys, Home, End)**: Arrow keys allow incremental adjustment aligned with the separator's axis (up/down for horizontal, left/right for vertical). Home and End allow jumping to min/max ratios, providing quick access to edge cases.
- **Clamping instead of errors**: The component silently clamps out-of-range ratios to `[minRatio, maxRatio]`. This prevents invalid states and simplifies the caller's logic; no validation error is emitted.
- **Pointer capture**: The component uses `setPointerCapture()` to ensure drags are tracked even if the pointer moves outside the separator. This is standard practice for resizable elements and ensures smooth dragging behavior.
- **No collapse state**: The component itself does not manage a "collapsed" state. Collapse (hiding one pane) is left to the caller, allowing maximum flexibility in how the split is used.
- **Ratio from container extent**: The ratio is calculated by dividing the pointer offset by the container's full extent (height for horizontal, width for vertical). This means the ratio represents the fraction of space given to the leading pane, regardless of the absolute container size.
- **Default step size**: `step = 0.03` (3% per key press) provides responsive keyboard navigation without requiring excessive key presses to traverse the full range. Callers can override this for different responsiveness.
- **Default ratio bounds**: `minRatio = 0.2` and `maxRatio = 0.8` provide sensible defaults (each pane gets at least 20% of space), preventing one pane from becoming too small to be usable. These can be overridden by the caller.

## Compliance

Not applicable: The component itself does not implement compliance checks (e.g., HIPAA, GDPR, PCI-DSS). Compliance responsibility belongs to the caller and their application context. The component does not handle sensitive data and imposes no restrictions on data processed by the caller.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
