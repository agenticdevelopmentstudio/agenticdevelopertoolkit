---
id: d9b07d1e-b53c-4efa-86f1-82a31ad9f02f
title: Progress Modal
domain: agenticdevelopertoolkit://recipes/progress-modal
type: ingredient
version: 1.1.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Modal dialog displaying real-time progress of a batch operation with error
  handling and decision points.
platforms:
- typescript
- web
tags:
- modal
- progress
- batch-operations
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Progress Modal

## Overview

A modal dialog that displays the real-time progress of a batch operation. It shows a progress bar, the current item being processed, a log of completed items, and handles error states by halting the operation and offering the user a choice to continue or stop. The modal does not close itself—the host owns the operation loop and decides when to dismiss. The modal cannot be dismissed mid-run, preventing accidental loss of visibility into background operations.

## Behavioral Requirements

- **must-render-as-dialog**: Component MUST render as a modal dialog that can be opened and closed via the `open` prop.
- **must-show-progress-bar**: Component MUST display a progress bar whose value is calculated as `(done / total) * 100` when total is greater than zero, or zero when total is zero.
- **must-display-completion-count**: Component MUST display the count as "done of total" in monospace font.
- **must-display-status-or-current-label**: Component MUST display `currentLabel` when provided. When `currentLabel` is omitted and the run is finished, MUST display "Finished". When omitted and the run is halted (error set), MUST display "Paused". When omitted and the run is in progress, MUST display "Working…".
- **must-halt-on-error**: When `error` prop is set and `finished` is false, the component MUST halt the progress display and show an error block.
- **must-show-error-block-when-halted**: When halted, component MUST render an error block containing the error message. If `error.itemLabel` is present, it MUST appear above the error message.
- **must-show-results-log-when-provided**: When `results` array has items, component MUST render them as a scrollable list with maximum height constraint.
- **must-render-result-label-and-status**: Each result item MUST display the result's label followed by a status indicator. For failed results, MUST display the result message or `failedLabel` in red. For successful results, MUST display the result message or `okLabel` in muted text.
- **must-show-continue-and-stop-when-halted**: When halted (error set and not finished), component MUST display Continue and Stop buttons if their respective callbacks are provided.
- **must-show-close-when-finished**: When finished is true, component MUST display a Close button if `onClose` callback is provided.
- **must-hide-buttons-during-progress**: When the run is in progress (no error and not finished), component MUST not display any action buttons.
- **must-prevent-dismiss-mid-run**: When the run is not finished, the component MUST ignore requests to dismiss (via Escape key or close button). Dismiss is only allowed when `finished` is true.
- **must-calculate-percentage-safely**: Component MUST handle zero total by setting percentage to zero instead of NaN.

## Appearance

- **Container**: Dialog with maximum width of 32rem (512px).
- **Progress bar**: Full width, default height per Progress component spec.
- **Status section**: Flex row with baseline alignment, gap of 3 units.
- **Status text**: Extra-small font size, muted text color. Item label truncated on overflow.
- **Count text**: Monospace font, extra-small size, muted text color, no shrink.
- **Error box**: Rounded border, border color red at 40% opacity, background red at 5% opacity, padding 2 units, text extra-small.
- **Error item label**: Medium font weight, normal text color.
- **Error message**: Red text color.
- **Results list**: Scrollable container with maximum height 12rem (192px), rounded border, border color default, padding 2 units, vertical gap 1 unit.
- **Result row**: Extra-small font size.
- **Result label**: Medium font weight, normal text color.
- **Result status**: Muted or red text depending on status, separated by " — " from label.
- **Dialog header**: Displays title and optional description via DialogHeader, DialogTitle, and DialogDescription components.
- **Dialog footer**: Contains action buttons with small size variant.

## States

| State | Appearance change | Behavior |
|-------|-------------------|----------|
| Running | Progress bar animates, status shows "Working…" or current label, no buttons visible | Modal is open, dismiss blocked, progress updates as `done` increases |
| Halted | Progress bar frozen, status shows "Paused", error block visible, Continue and Stop buttons visible | Modal remains open, dismiss blocked, awaiting user decision |
| Finished | Progress bar at 100%, status shows "Finished", results log visible if any, Close button visible | Modal is open, dismiss allowed, user must close via Close button |
| Closed | — | Modal is not rendered (`open` prop is false) |

## Accessibility

Accessibility is delegated to the composed Dialog and Progress components, which are built on Radix UI primitives and implement ARIA roles, keyboard navigation, focus management, and live region announcements for state changes.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| progress-001 | must-show-progress-bar | `open={true}, done={3}, total={10}` | Progress bar shows 30% width |
| progress-002 | must-calculate-percentage-safely | `open={true}, done={0}, total={0}` | Progress bar shows 0%, no NaN displayed |
| progress-003 | must-display-completion-count | `open={true}, done={5}, total={20}` | Text displays "5 of 20" in monospace |
| progress-004 | must-display-status-or-current-label | `open={true}, currentLabel={"Uploading file.txt"}, finished={false}, error={null}` | Status text shows "Uploading file.txt" |
| progress-005 | must-display-status-or-current-label | `open={true}, currentLabel={undefined}, finished={true}` | Status text shows "Finished" |
| progress-006 | must-display-status-or-current-label | `open={true}, currentLabel={undefined}, finished={false}, error={…}` | Status text shows "Paused" |
| progress-007 | must-display-status-or-current-label | `open={true}, currentLabel={undefined}, finished={false}, error={null}` | Status text shows "Working…" |
| progress-008 | must-halt-on-error, must-show-error-block-when-halted | `open={true}, error={message: "Upload failed"}, finished={false}` | Error block visible with message "Upload failed" |
| progress-009 | must-show-error-block-when-halted | `open={true}, error={message: "Failed", itemLabel: "photo.jpg"}, finished={false}` | Error block shows "photo.jpg" above "Failed" message |
| progress-010 | must-show-results-log-when-provided | `open={true}, results=[{id: "1", label: "file1.txt", status: "ok"}]` | Results list renders with one item |
| progress-011 | must-render-result-label-and-status | `open={true}, results=[{id: "1", label: "file.txt", status: "ok", message: "moved"}]` | Result shows "file.txt — moved" in muted text |
| progress-012 | must-render-result-label-and-status | `open={true}, results=[{id: "1", label: "file.txt", status: "failed", message: "Not found"}]` | Result shows "file.txt — Not found" in red text |
| progress-013 | must-render-result-label-and-status | `open={true}, results=[{id: "1", label: "file.txt", status: "ok"}], okLabel={"synced"}` | Result shows "file.txt — synced" (no message provided, uses okLabel) |
| progress-014 | must-show-continue-and-stop-when-halted | `open={true}, error={…}, finished={false}, onContinue={fn}, onStop={fn}` | Continue and Stop buttons are visible and clickable |
| progress-015 | must-show-close-when-finished | `open={true}, finished={true}, onClose={fn}` | Close button is visible and clickable |
| progress-016 | must-hide-buttons-during-progress | `open={true}, finished={false}, error={null}` | No action buttons are visible |
| progress-017 | must-prevent-dismiss-mid-run | `open={true}, finished={false}, onOpenChange={fn} triggered by Escape` | `onOpenChange` receives false but `onClose` is NOT called |
| progress-018 | must-prevent-dismiss-mid-run | `open={true}, finished={true}, onOpenChange={fn} triggered by Escape` | `onOpenChange` receives false and `onClose` IS called |

## Edge Cases

- **Empty batch**: When `total` is zero, percentage calculation produces zero instead of NaN. Progress bar renders at 0%.
- **No results**: When `results` array is empty or undefined, results log section does not render.
- **No error**: When `error` prop is null or undefined, error block does not render.
- **Missing itemLabel in error**: When `error.itemLabel` is null or undefined, only the error message renders in the error block.
- **Missing message in result**: When a result has no `message` property, the component uses `okLabel` (for "ok" status) or `failedLabel` (for "failed" status) as the displayed text.
- **Stop action while processing**: When `onStop` is invoked, the host owns the batch loop and decides when to set `finished={true}`. The modal does not stop the underlying operation.
- **Continue after error**: When `onContinue` is invoked, the host resumes the batch loop. The `error` prop is expected to be cleared by the host in the next render.
- **Dismiss attempt mid-run**: Pressing Escape or clicking the close button while `finished={false}` triggers `onOpenChange(false)` but does not call `onClose`. The modal remains open.

## Configuration

Not applicable: This component receives no user-configurable options beyond its props, which define behavior dynamically per operation instance.

## Deep Linking

Not applicable: This component is a modal overlay managed by its host and is not independently deep-linkable.

## Localization

| String Key | Default (en) | Context |
|-----------|-------------|---------|
| `status.working` | "Working…" | Displayed when run is in progress and no currentLabel is provided |
| `status.paused` | "Paused" | Displayed when run is halted on error and no currentLabel is provided |
| `status.finished` | "Finished" | Displayed when run is complete and no currentLabel is provided |
| `action.continue` | "Continue" | Button label when halted |
| `action.stop` | "Stop" | Button label when halted |
| `action.close` | "Close" | Button label when finished |
| `result.ok` | "done" | Default status text when result status is "ok" and no message provided (customizable via okLabel prop) |
| `result.failed` | "failed" | Default status text when result status is "failed" and no message provided (customizable via failedLabel prop) |

## Accessibility Options

Not applicable: This component does not respond to platform-level accessibility display options. Its accessibility behavior is delegated to the Dialog and Progress child components.

## Feature Flags

Not applicable: This component does not check feature flags. Feature gating of the batch operation itself is the responsibility of the host.

## Analytics

Not applicable: This component does not emit analytics events. The host is responsible for tracking batch operation metrics if needed.

## Privacy

Not applicable: This component does not collect, store, or transmit any user data. The `currentLabel`, `results`, and error `message` content is provided by the host and may contain user-facing or sensitive data, which the host is responsible for handling.

## Logging

Not applicable: This component does not perform logging. Debug information about batch progress and errors is the responsibility of the host operation loop.

## Platform Notes

- **React/Web**: Implemented using shadcn/ui `Dialog` and `Progress` components. Dialog is not dismissible mid-run by swallowing dismiss events in `onOpenChange` until `finished` is true. Progress percentage is calculated client-side. Results are rendered as a flex column with overflow constraints.
- **SwiftUI**: Start with a `.sheet()` or `.fullScreenCover()` modifier bound to the `open` state. Use `ProgressView()` for the progress bar. For blocking mid-run dismissal, use `.interactiveDismissDisabled(!finished)`. Render error block conditionally with `if error != nil`. Use a `List` or `ScrollView` for the results log with a frame height constraint.
- **Compose**: Build on `AlertDialog` or `Dialog` composable. Use `LinearProgressIndicator` for the progress bar. Set `onDismissRequest` to a callback that only closes if `finished` is true. Render error and results sections conditionally. Use `LazyColumn` for the scrollable results list.
- **AppKit / UIKit**: For macOS, use `NSAlert` or a custom window controller. For iOS, use `UIAlertController` or a custom view controller. `UIProgressView` (iOS) or `NSProgressIndicator` (macOS) for the progress bar. Prevent dismissal by disabling the close button or intercepting dismissal attempts until `finished` is true. Render error and results in custom views.
- **WinUI 3**: Use `ContentDialog` as the container. `ProgressBar` control for the progress display. Set `IsPrimaryButtonEnabled = false` and `IsSecondaryButtonEnabled = false` during progress, then enable the appropriate buttons (Close, Continue/Stop) based on state. Use a `ScrollViewer` containing an `ItemsControl` or `ListView` for the results log. Prevent dismissal by handling the `Closing` event and only allowing close when operation is finished.

## Design Decisions

1. **Halt on error rather than power through**: The component halts the batch on the first error and requires the user to decide whether to continue or stop, rather than completing all items and presenting a summary at the end. This respects the principle that a failure in one item often indicates all remaining items will fail the same way (e.g., a wrong destination path), so the user should make an informed decision before proceeding.

2. **Component does not dismiss itself**: The modal does not close automatically on completion. Instead, it swaps the action buttons for a Close button, making the user responsible for dismissal. This preserves the record of what happened—the completed results are visible until the user explicitly closes the dialog.

3. **Progress is item-count, not time or bytes**: The progress bar tracks `done / total` items, not elapsed time or bytes transferred. The host controls the loop and reports completion for each discrete operation. This provides accurate progress rather than a guess based on throughput.

4. **Transport-agnostic composition**: The component is intentionally independent of the underlying operation type. It renders state and emits decisions (Continue, Stop, Close) without knowing whether the batch is uploading, deleting, moving, or any other operation. Any host can drive it without specialized knowledge.

5. **Default labels for results**: `okLabel` and `failedLabel` are deliberately generic ("done", "failed") because the component runs any batch. A host with domain-specific knowledge can pass better verbs (e.g., "moved", "deleted") to override the defaults.

6. **Dismiss blocking during progress**: Escape and the × button are swallowed until the run ends because closing the dialog does not stop the background requests. A dialog that vanishes on a stray keystroke would leave the batch running invisibly, losing visibility into the operation.

## Compliance

Not applicable: This component does not involve authentication, authorization, sensitive data transmission, network requests, or data persistence—these are concerns of the host operation loop. No compliance checks are defined at the component level.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.1.0 | 2026-09-22 | Claude Haiku 4.5 | Revise accessibility section: document delegation to composed components rather than mark as unimplemented |
| 1.0.0 | 2026-09-22 | Claude Haiku 4.5 | Initial creation from source code analysis |
