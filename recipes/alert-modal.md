---
id: e26e765d-2caa-40f8-a668-661ed2b0632c
title: AlertModal
domain: agenticdevelopercookbook://recipes/alert-modal
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Controlled alert/confirm modal on Dialog — tone icon, one- or two-button
  footer, busy spinner, configurable dismissal and keyboard policy, destructive mode.
platforms:
- typescript
- web
tags:
- dialog
- alert
- confirm
- modal
- overlay
- base-ui
depends-on:
- agenticdevelopercookbook://recipes/dialog
- agenticdevelopercookbook://recipes/dialog-actions
- agenticdevelopercookbook://recipes/button
related:
- agenticdevelopercookbook://recipes/dialog
- agenticdevelopercookbook://recipes/dialog-actions
- agenticdevelopercookbook://recipes/alert-and-dialog
references: []
approved-by: ''
approved-date: ''
---

# AlertModal

## Overview

`AlertModal` (`packages/web/packages/ui/src/components/alert-modal.tsx`) is a
generalized, centered modal alert/confirm built on the shared `Dialog`
primitive. It renders one primary button (**alert mode**) when no
`cancelLabel` is supplied, or a primary + secondary pair via `DialogActions`
(**confirm mode**) when `cancelLabel` is supplied. Visibility is fully
controlled by the parent through the `open` prop. A leading tone icon
(`info`/`success`/`error`) can be shown in the title, the footer can be
replaced by a busy spinner, dismissal (backdrop/Escape/✕) can be disabled
entirely, and the keyboard shortcut policy (`Enter`/`Escape`) is configurable
per instance, including a `destructive` mode that forces the error tone and
disables keyboard shortcuts.

## Behavioral Requirements

- **must-render-title**: The component MUST render the `title` prop inside the dialog's `DialogTitle`.
- **must-render-description-when-provided**: The component MUST render `description` inside a `DialogDescription` when `description` is not `null`/`undefined`.
- **must-omit-description-when-absent**: The component MUST NOT render a `DialogDescription` element when `description` is `null` or `undefined`.
- **must-show-tone-icon-by-default**: The component MUST render the tone icon leading the title when `showIcon` is `true`, which is the default.
- **must-hide-tone-icon-when-disabled**: The component MUST omit the tone icon when `showIcon` is `false`.
- **must-mark-tone-icon-decorative**: The component MUST render the tone icon with `aria-hidden`.
- **must-map-tone-to-icon-and-color**: The component MUST render the `Info` icon with `text-apt-blue` for `tone="info"`, the `CheckCircle2` icon with `text-apt-green` for `tone="success"`, and the `TriangleAlert` icon with `text-apt-red` for `tone="error"`.
- **must-force-error-tone-when-destructive**: The component MUST use the `"error"` tone's icon and color whenever `destructive` is `true`, regardless of the value of the `tone` prop.
- **must-render-alert-mode-when-no-cancel-label**: The component MUST render a single, full-width confirm button in the footer (alert mode) whenever `cancelLabel` is `null` or `undefined`.
- **must-render-confirm-mode-when-cancel-label-set**: The component MUST render `DialogActions`, with both a cancel and a confirm button, whenever `cancelLabel` is not `null`/`undefined`.
- **must-invoke-onconfirm-on-confirm-click**: Activating the confirm button MUST call `onConfirm` exactly once.
- **must-invoke-oncancel-on-cancel-click**: In confirm mode, activating the cancel button MUST call `onCancel` exactly once.
- **must-default-confirm-label-ok**: The component MUST default the confirm button's label to `"OK"` when `confirmLabel` is not provided.
- **must-style-confirm-destructive-in-alert-mode**: In alert mode, the component MUST render the confirm button with the `"destructive"` variant when `destructive` is `true`.
- **must-apply-confirm-variant-in-alert-mode**: In alert mode, when `destructive` is `false`, the component MUST render the confirm button with `confirmVariant` if provided, and with the `"default"` variant otherwise.
- **must-show-busy-spinner-in-alert-mode**: In alert mode, when `busy` is `true`, the component MUST replace the confirm button with a spinner element exposing `role="status"` and `aria-label="Working…"`.
- **must-forward-busy-to-dialog-actions**: In confirm mode, the component MUST forward the `busy` prop to `DialogActions`.
- **must-forward-destructive-to-dialog-actions**: In confirm mode, the component MUST forward the `destructive` prop to `DialogActions`.
- **must-set-initial-focus-by-destructiveness**: In confirm mode, the component MUST set `DialogActions`' `initialFocus` to `"cancel"` when `destructive` is `true`, and to `"confirm"` otherwise.
- **must-hide-close-affordance-when-busy-or-non-dismissible**: The component MUST hide `DialogContent`'s `×` close affordance (`showClose`) whenever `busy` is `true` or `dismissible` is `false`.
- **must-default-dismissible-true**: The component MUST treat the dialog as dismissible by default (`dismissible` defaults to `true`).
- **must-block-dismissal-when-busy**: The component MUST block every dismissal path (Escape, backdrop, ✕, programmatic close) while `busy` is `true`.
- **must-block-dismissal-when-non-dismissible**: The component MUST block every dismissal path while `dismissible` is `false`.
- **must-route-escape-to-cancel-in-confirm-mode**: When keyboard shortcuts are enabled and the dialog is not blocked from closing, an Escape-driven close (Base UI close reason `"escape-key"`) MUST call `onCancel` in confirm mode.
- **must-route-escape-to-confirm-in-alert-mode**: When keyboard shortcuts are enabled and the dialog is not blocked from closing, an Escape-driven close MUST call `onConfirm` in alert mode.
- **must-block-escape-when-keyboard-disabled**: The component MUST NOT call `onConfirm` or `onCancel` for an Escape-driven close when `keyboard` is `"none"` or `destructive` is `true`.
- **must-route-pointer-dismissal-regardless-of-keyboard-policy**: A non-Escape close (backdrop click, ✕, programmatic close) MUST call `onCancel` in confirm mode or `onConfirm` in alert mode whenever the dialog is not busy and is dismissible, regardless of the `keyboard` policy's value.
- **must-invoke-confirm-on-enter-under-default-keyboard**: Under `keyboard="default"` (and `destructive` `false`), pressing `Enter` MUST call `onConfirm` exactly once and MUST call `preventDefault` on the triggering event.
- **must-ignore-all-keys-when-keyboard-none**: When `keyboard` is `"none"`, the window keydown listener MUST NOT invoke `onConfirm` or `onCancel` for any key.
- **must-force-keyboard-none-when-destructive**: The component MUST treat keyboard shortcuts as disabled whenever `destructive` is `true`, regardless of the value of the `keyboard` prop.
- **must-honor-explicit-keyboard-map**: When `keyboard` is an explicit key→action map and `destructive` is `false`, pressing a key present in the map MUST invoke the mapped action (`"confirm"` → `onConfirm`, `"cancel"` → `onCancel`).
- **must-ignore-unmapped-keys-in-explicit-map**: When `keyboard` is an explicit key→action map, pressing a key absent from the map MUST NOT invoke `onConfirm` or `onCancel`.
- **must-scope-keydown-listener-to-open-and-not-busy**: The window `keydown` listener MUST be attached only while `open` is `true` and `busy` is `false`, and MUST be removed otherwise.
- **must-forward-open-state-to-dialog**: The component MUST forward the `open` prop to the underlying `Dialog` root.
- **must-forward-content-class-name**: The component MUST forward `contentClassName` to `DialogContent`'s `className`.

## Appearance

- **Corner radius**: Not applicable — owned by `DialogContent` via the Dialog recipe (`agenticdevelopercookbook://recipes/dialog`).
- **Padding**: Not applicable — owned by `DialogContent` via the Dialog recipe.
- **Font**: Title weight/size are inherited from `DialogTitle` (unmodified here); `AlertModal` only overrides the title's text color and adds a leading-icon layout (`flex items-center gap-2 text-apt-gold`).
- **Background**: Not applicable — owned by `DialogContent` via the Dialog recipe.
- **Foreground/Text**: Title text is `text-apt-gold`. Tone icon color is `text-apt-blue` (info), `text-apt-green` (success), or `text-apt-red` (error/destructive). Busy spinner (alert mode) is `text-apt-text-muted`.
- **Border**: Not applicable — owned by `DialogContent` via the Dialog recipe.
- **Shadow**: Not applicable — owned by `DialogContent` via the Dialog recipe.
- **Min/Max size**: Not applicable — sizing is owned by `DialogContent` and can be overridden via the `contentClassName` prop.
- **Icon size**: Tone icon is `size-5 shrink-0`; busy spinner (alert mode) is `size-4 animate-spin`.
- **Confirm button (alert mode)**: `size="sm"`, `className="w-full"` (full width of the footer).

## States

| State | Appearance change |
|-------|------------------|
| Alert mode (`cancelLabel` unset) | Single full-width confirm button in the footer |
| Confirm mode (`cancelLabel` set) | `DialogActions` renders cancel + confirm buttons |
| Busy, alert mode | Confirm button replaced by a `role="status"` `Loader2` spinner (`aria-label="Working…"`); dismissal blocked |
| Busy, confirm mode | `busy` forwarded to `DialogActions`, which replaces its own buttons with a status spinner; dismissal blocked |
| `destructive=true` | Tone icon/color forced to error; confirm button (alert mode) renders `"destructive"` variant; keyboard shortcuts forced off; in confirm mode, initial focus defaults to cancel |
| `dismissible=false` | `×` close affordance hidden; Escape/backdrop/✕/programmatic close all blocked |
| `showIcon=false` | Leading tone icon omitted from the title |
| `keyboard="none"` | `Enter` ignored by the keydown listener; Escape-driven close blocked without invoking either callback |

## Accessibility

- Dialog role, `aria-modal`, focus trap, and focus restoration to the opener are inherited unchanged from the `Dialog` primitive (`agenticdevelopercookbook://recipes/dialog`); `AlertModal` does not re-derive or override them.
- The dialog MUST be labelled by `title` (via `DialogTitle`) and, when provided, described by `description` (via `DialogDescription`).
- The tone icon is decorative: it is rendered with `aria-hidden` and never substitutes for a text label.
- The alert-mode busy spinner exposes `role="status"` and `aria-label="Working…"`; confirm-mode busy is forwarded to `DialogActions`, which applies the identical `role="status"` / `aria-label="Working…"` treatment (`agenticdevelopercookbook://recipes/dialog-actions`).
- Both footer buttons are the shared `Button` component, which renders a real, focusable `<button>` — keyboard activation (Space/Enter) is native (`agenticdevelopercookbook://recipes/button`).
- Minimum touch/click target size, minimum contrast ratio, and other platform-specific accessibility requirements are inherited from the `Button` component and the shared design-token stylesheet; see `agenticdevelopercookbook://recipes/button` and the WCAG 2.1 AA reference in `agenticdevelopercookbook://guidelines/cookbook/ui/platform-design-languages`.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| T1 | must-render-title | `title="Delete file?"` | `DialogTitle` contains "Delete file?" |
| T2 | must-render-description-when-provided | `description="This cannot be undone."` | `DialogDescription` renders the text |
| T3 | must-omit-description-when-absent | `description` omitted | no `DialogDescription` in the DOM |
| T4 | must-show-tone-icon-by-default | `showIcon` omitted | tone icon renders next to the title |
| T5 | must-hide-tone-icon-when-disabled | `showIcon={false}` | no tone icon in the DOM |
| T6 | must-mark-tone-icon-decorative | any tone, icon shown | icon element has `aria-hidden` |
| T7 | must-map-tone-to-icon-and-color | `tone="success"` | `CheckCircle2` renders with `text-apt-green` |
| T8 | must-force-error-tone-when-destructive | `tone="info"`, `destructive={true}` | `TriangleAlert` renders with `text-apt-red`, not the info icon |
| T9 | must-render-alert-mode-when-no-cancel-label | `cancelLabel` omitted | one full-width confirm button, no cancel button |
| T10 | must-render-confirm-mode-when-cancel-label-set | `cancelLabel="Cancel"` | `DialogActions` renders cancel + confirm |
| T11 | must-invoke-onconfirm-on-confirm-click | click confirm | `onConfirm` called once |
| T12 | must-invoke-oncancel-on-cancel-click | confirm mode, click cancel | `onCancel` called once |
| T13 | must-default-confirm-label-ok | `confirmLabel` omitted | confirm button text is "OK" |
| T14 | must-style-confirm-destructive-in-alert-mode | alert mode, `destructive={true}` | confirm button uses `"destructive"` variant |
| T15 | must-apply-confirm-variant-in-alert-mode | alert mode, `destructive={false}`, `confirmVariant="outline"` | confirm button uses `"outline"` variant |
| T16 | must-show-busy-spinner-in-alert-mode | alert mode, `busy={true}` | confirm button absent; `role="status"` spinner with `aria-label="Working…"` present |
| T17 | must-forward-busy-to-dialog-actions | confirm mode, `busy={true}` | `DialogActions` receives `busy={true}` |
| T18 | must-forward-destructive-to-dialog-actions | confirm mode, `destructive={true}` | `DialogActions` receives `destructive={true}` |
| T19 | must-set-initial-focus-by-destructiveness | confirm mode, `destructive={true}` | `DialogActions` receives `initialFocus="cancel"` |
| T20 | must-hide-close-affordance-when-busy-or-non-dismissible | `dismissible={false}` | `DialogContent` receives `showClose={false}` |
| T21 | must-default-dismissible-true | `dismissible` omitted | `×` close affordance present (not busy) |
| T22 | must-block-dismissal-when-busy | `busy={true}`, press Escape | dialog stays open; neither callback called |
| T23 | must-block-dismissal-when-non-dismissible | `dismissible={false}`, click backdrop | dialog stays open; neither callback called |
| T24 | must-route-escape-to-cancel-in-confirm-mode | confirm mode, `keyboard="default"`, press Escape | `onCancel` called once |
| T25 | must-route-escape-to-confirm-in-alert-mode | alert mode, `keyboard="default"`, press Escape | `onConfirm` called once |
| T26 | must-block-escape-when-keyboard-disabled | `keyboard="none"`, press Escape | neither callback called; dialog stays open |
| T27 | must-route-pointer-dismissal-regardless-of-keyboard-policy | `keyboard="none"`, confirm mode, click backdrop | `onCancel` called once |
| T28 | must-invoke-confirm-on-enter-under-default-keyboard | `keyboard="default"`, press Enter | `onConfirm` called once; event `preventDefault` called |
| T29 | must-ignore-all-keys-when-keyboard-none | `keyboard="none"`, press Enter | neither callback called |
| T30 | must-force-keyboard-none-when-destructive | `destructive={true}`, `keyboard="default"`, press Enter | `onConfirm` not called via the keydown listener |
| T31 | must-honor-explicit-keyboard-map | `keyboard={{ k: "confirm" }}`, press `k` | `onConfirm` called once |
| T32 | must-ignore-unmapped-keys-in-explicit-map | `keyboard={{ k: "confirm" }}`, press `j` | neither callback called |
| T33 | must-scope-keydown-listener-to-open-and-not-busy | `open={false}`, press Enter | neither callback called (listener not attached) |
| T34 | must-forward-open-state-to-dialog | `open={true}` | `Dialog` root receives `open={true}` |
| T35 | must-forward-content-class-name | `contentClassName="sm:max-w-lg"` | `DialogContent` receives that `className` |

## Edge Cases

- **Null/empty `title`**: `title=""` renders an empty `DialogTitle` node; the source performs no fallback or validation. MUST behave this way (no guard exists).
- **Empty-string `cancelLabel`**: `isConfirm` is computed as `cancelLabel != null`, a loose-equality check that excludes only `null`/`undefined`. `cancelLabel=""` is not `null`, so it MUST trigger confirm mode and render a cancel button with a blank label — this is a boundary case a naive reader would expect to fall back to alert mode, and it does not.
- **`keyboard` object containing an `"Escape"` entry**: an explicit key→action map is used verbatim by the keydown listener (it is not restricted to `Enter`). If the caller's map includes `Escape`, that keypress MUST invoke the mapped action from the window listener AND separately reach Base UI's `onOpenChange` with reason `"escape-key"`, which also routes to `onCancel`/`onConfirm`. The two paths MUST both fire for the same keypress. See Design Decisions.
- **Concurrent access**: Not applicable — `AlertModal` is a client-side, single-render UI component; all state (`open`, `busy`, etc.) is owned by the parent and passed down as props.
- **Error states**: the source does not catch or otherwise handle exceptions thrown by `onConfirm` or `onCancel`. Such an exception MUST propagate uncaught out of the event handler to the caller's own error boundary; `AlertModal` performs no retry, logging, or user-facing error display of its own.
- **Offline/disconnected state**: Not applicable — `AlertModal` makes no network requests itself; any network operation lives in the caller-supplied `onConfirm`/`onCancel` handlers, outside this component's scope.
- **`busy` and `dismissible={false}` combined**: both flags independently block dismissal (`handleOpenChange` returns early on `busy || !dismissible`); the two conditions are redundant, not additive, and produce identical blocked behavior.
- **`destructive={true}` with an explicit `keyboard` map**: `destructive` forces `keyboardEnabled` to `false` regardless of the map, so `must-force-keyboard-none-when-destructive` MUST take precedence over `must-honor-explicit-keyboard-map`.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `open` | `boolean` | — (required) | Controlled visibility, owned by the parent. |
| `title` | `string` | — (required) | Heading line. |
| `description` | `React.ReactNode` | — | Body copy; omitted renders no `DialogDescription`. |
| `tone` | `"info" \| "success" \| "error"` | `"info"` | Sets the leading icon + accent color. |
| `confirmLabel` | `string` | `"OK"` | Primary button label. |
| `confirmVariant` | `Button["variant"]` | `undefined` (→ Button's `"default"`) | Visual variant of the primary button in alert mode when not destructive. |
| `onConfirm` | `() => void` | — (required) | Primary action; also the effective dismiss action in alert mode. |
| `cancelLabel` | `string` | — | Presence switches the component to confirm mode. |
| `onCancel` | `() => void` | — | Cancel action; also the effective dismiss action in confirm mode. |
| `busy` | `boolean` | `false` | Replaces the action buttons with a spinner and blocks dismissal. |
| `dismissible` | `boolean` | `true` | Whether backdrop/Escape/✕ may close the modal. |
| `keyboard` | `"default" \| "none" \| Partial<Record<string, "confirm" \| "cancel">>` | `"default"` | Keyboard shortcut policy. |
| `destructive` | `boolean` | `false` | Forces the error tone visual and forces `keyboard` to behave as `"none"`. |
| `contentClassName` | `string` | `undefined` | Forwarded to `DialogContent` for width/size overrides. |
| `showIcon` | `boolean` | `true` | Whether to show the tone icon in the title. |

## Deep Linking

Not applicable — `AlertModal` is a presentational modal component with no deep-linkable state of its own.

## Localization

The strings `"OK"` (default confirm label) and `"Working…"` (busy spinner label) are hardcoded in English in `alert-modal.tsx` with no i18n key lookup. The `title`, `description`, `confirmLabel`, and `cancelLabel` props accept caller-supplied strings, permitting localization at the call site. A full i18n framework integration would require centralizing string keys and moving them to a shared resource file.

## Accessibility Options

Not applicable — `AlertModal` is a presentational component that inherits behavior from `Dialog`, which does not expose per-instance configuration for platform accessibility features such as Reduce Motion, Increase Contrast, or Differentiate Without Color. Implementations MUST rely on platform-level media query support (e.g., `prefers-reduced-motion`) and shared CSS utilities in the Button and Dialog recipes.

## Feature Flags

Not applicable — `AlertModal` contains no feature flag logic. Feature gating (if needed) belongs in the caller's decision to render the component.

## Analytics

Not applicable — `AlertModal` is a presentational component. Any success/failure telemetry for the actions invoked by `onConfirm` or `onCancel` belongs in the caller's handlers, not in the component itself.

## Privacy

- **Data collected**: None. `alert-modal.tsx` contains no data collection, storage, or transmission code.
- **Storage**: Not applicable — the component holds no persistent state.
- **Transmission**: Not applicable — the component makes no network calls.
- **Retention**: Not applicable.

## Logging

Not applicable — `AlertModal` is a presentational component and issues no log calls in this source. Any success/error telemetry belongs to the caller's `onConfirm`/`onCancel` handlers.

## Platform Notes

- **SwiftUI**: Not applicable — no SwiftUI implementation is in scope for this recipe.
- **Compose**: Not applicable — no Compose implementation is in scope for this recipe.
- **React/Web**: `packages/web/packages/ui/src/components/alert-modal.tsx`, `"use client"`, built on `@base-ui/react/dialog` via the shared `Dialog` primitive (`agenticdevelopercookbook://recipes/dialog`). Renders `DialogActions` (agenticdevelopercookbook://recipes/dialog-actions`) in confirm mode and the shared `Button` (`agenticdevelopercookbook://recipes/button`) in alert mode.
- **AppKit / UIKit**: Not applicable — no AppKit/UIKit implementation is in scope for this recipe.
- **WinUI 3**: Start from `ContentDialog` (Fluent 2's modal primitive). In alert mode, render a single `PrimaryButtonText` button; in confirm mode, add `SecondaryButtonText` and set `SecondaryButtonClick` to invoke cancel. Replace buttons with a custom busy `Content` template (a `ProgressRing` inside a `StackPanel`) when busy. The `dismissible` and `busy` flags block light-dismiss behavior via `IsPrimaryButtonEnabled` (set to `false` when `busy` or `!dismissible`; hide the close button via a custom template override). For keyboard policy: `ContentDialog` has no built-in per-instance `Escape`/`Enter` remapping, so attach a `KeyDown` handler to the dialog when `keyboard` is an explicit map or `"none"`; when `keyboard="default"`, defer to the default behavior (Enter → `PrimaryButton`, Escape → cancel/dismiss). The `destructive` flag changes the primary button's styling to danger/red and forces the keyboard handler to block all key actions.

## Design Decisions

- **Escape double-fire with an explicit keyboard map.** The component's own doc comment states "The window keydown listener handles Enter only, so there is no double-fire path," but that is only true for `keyboard="default"`. When `keyboard` is an explicit object, the returned `keyMap` is that object verbatim, and the keydown listener dispatches on *any* key present in it — including `"Escape"`, if the caller included it. Base UI's `onOpenChange` independently routes reason `"escape-key"` to the same cancel/confirm call. A caller-supplied map containing `Escape` will therefore invoke the mapped callback twice for one keypress. This is documented here as a discrepancy between the source's own comment and its actual behavior, not as a guaranteed contract — see `must-honor-explicit-keyboard-map` and the matching Edge Cases entry.
- **`destructive` bundles two independent effects.** Setting `destructive={true}` simultaneously forces the error tone (icon + color) and forces the keyboard policy to behave as `"none"`, from a single boolean. A caller cannot get one effect without the other (e.g., a red action button that still accepts Enter).
- **Busy-state spinner is implemented twice.** In alert mode, `AlertModal` renders its own inline `Loader2` with `role="status"` / `aria-label="Working…"`. In confirm mode, the identical treatment is delegated to `DialogActions` (`agenticdeveloperhub://recipes/dialog-actions`) via the forwarded `busy` prop. The visual/accessible output is the same, but it is produced by two separate code paths rather than one shared one.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| Artifact formatting (ingredient) | passed | artifact-formatting |
| UI guidelines — `apt-*` tokens only, no raw hex, no `!important` (as observed in `alert-modal.tsx`) | passed | adh-ui-guidelines |
| Keyboard operability (Enter/Escape policy present and testable) | passed | accessibility |
| Minimum contrast ratio / touch target size verified against WCAG 2.1 AA | needs-review | accessibility |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial recipe extracted from `packages/web/packages/ui/src/components/alert-modal.tsx`. |
