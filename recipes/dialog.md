---
id: 972be0d0-a9f5-45cd-a23b-c8329410b3d1
title: Dialog
domain: agenticdevelopercookbook://recipes/dialog
type: ingredient
version: 1.0.1
status: review
language: en
created: '2026-06-26'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Centered modal Dialog (Base UI) themed with apt-* tokens; backdrop dismissal off by default. Composes Trigger/Content/Header/Footer/Title/Description.
platforms:
  - typescript
  - web
tags:
  - dialog
  - modal
  - overlay
  - base-ui
depends-on: []
related:
  - agenticdevelopercookbook://recipes/alert-and-dialog
references: []
approved-by: ''
approved-date: ''
---

# Dialog

## Overview

**Dialog** is the shared centered-modal primitive, built on `@base-ui/react/dialog`
and themed with the family `apt-*` tokens. It is composed from parts —
`Dialog` (root), `DialogTrigger`, `DialogContent`, `DialogHeader`, `DialogFooter`,
`DialogTitle`, `DialogDescription`, and `DialogClose` — and is the base every
larger overlay (AlertModal, the invitation and add-users modals) is built on.

## Behavioral Requirements

- **must-center-modal**: `DialogContent` MUST render a centered, portalled popup over a dimmed, blurred backdrop.
- **must-not-dismiss-on-backdrop**: By default the dialog MUST NOT close on a backdrop or outside click (`disablePointerDismissal`); a caller MAY re-enable it with `disablePointerDismissal={false}`.
- **must-close-on-escape**: Escape MUST close the dialog, unless a composing component's keyboard policy overrides it.
- **must-render-close-affordance**: `DialogContent` MUST render a labelled `×` close button by default; `showClose={false}` MUST hide it.
- **must-trap-focus**: While open, focus MUST be trapped within the dialog and restored to the opener on close.
- **must-label-dialog**: The dialog MUST be labelled by `DialogTitle` and described by `DialogDescription` for assistive technology.

## Appearance

- **Backdrop**: `fixed inset-0` positioning, `bg-black/30` overlay (30% black opacity), `backdrop-blur-sm` blur effect, `z-50` stacking.
- **Popup container**: Centered at `top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2`, width `w-[calc(100%-2rem)]` (100% minus 16px side margins), max-width `max-w-md` (448px), `rounded-xl` corner radius (12px), `border` 1px `border-apt-border`, background `bg-apt-surface`, text color `text-apt-text`, padding `p-5` (20px all sides), `shadow-xl` shadow effect, `z-50` stacking.
- **Close button (×)**: Positioned `absolute top-3.5 right-3.5`, icon size `size-4` (16px × 16px), rounding `rounded`, default text color `text-apt-text-muted`, hover state transitions to `text-apt-text`, focus ring `ring-2 ring-apt-gold/40`, no outline.
- **DialogHeader**: Flex layout `flex-col`, vertical gap `gap-1.5` (6px).
- **DialogFooter**: Flex layout with `items-center justify-end`, horizontal gap `gap-3` (12px).
- **DialogTitle**: Font size `text-base` (16px), weight `font-semibold` (600), text color `text-apt-text`.
- **DialogDescription**: Font size `text-sm` (14px), text color `text-apt-text-muted`.
- **Constraint**: No raw hex color values; no `!important` declarations.

## States

| State | Appearance change |
|---|---|
| closed | Portal empty — nothing rendered |
| open | Dimmed/blurred backdrop visible + centered popup visible |
| close button hover | `×` text color shifts from `text-apt-text-muted` to `text-apt-text` |
| close button focus | `×` displays focus ring `ring-2 ring-apt-gold/40` |

## Accessibility

- **Role and properties**: `role="dialog"` with `aria-modal="true"` (set by Base UI); dialog is labelled by `DialogTitle` (via `aria-labelledby`) and described by `DialogDescription` (via `aria-describedby`).
- **Focus management**: Focus is trapped within the dialog while open and restored to the triggering element on close (Base UI handles this).
- **Keyboard**: Escape closes the dialog; Tab and Shift+Tab cycle focus within trapped set.
- **Close affordance**: The close button (`×`) carries `aria-label="Close"` to announce its purpose.
- **Target size**: Close button minimum touch target is 16px × 16px (icon) + padding, meeting 44×44pt platform guidance when padded by surrounding space.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|---|---|---|---|
| T1 | must-center-modal | Open the dialog with `<DialogTrigger>` | Popup appears centered on screen with dimmed, blurred backdrop behind it |
| T2 | must-not-dismiss-on-backdrop | Click the backdrop area while dialog is open | Dialog remains open |
| T3 | must-close-on-escape | Press Escape key while dialog is open and focused | Dialog closes |
| T4 | must-render-close-affordance (default) | Render `<DialogContent>` without `showClose` prop | Close button (×) is rendered in top-right corner |
| T5 | must-render-close-affordance (hidden) | Render `<DialogContent showClose={false}>` | Close button is not rendered |
| T6 | must-trap-focus | Tab through dialog, close it | Focus stays within dialog; on close, focus returns to the trigger element |
| T7 | must-label-dialog | Render with `<DialogTitle>` and `<DialogDescription>` | Assistive technology announces title and description |
| T8 | must-not-dismiss-on-backdrop (opt-in) | Set `disablePointerDismissal={false}` and click backdrop | Dialog closes on backdrop click |

## Edge Cases

- **Backdrop dismissal is off by default** for modals/alerts — users opt back in with `disablePointerDismissal={false}`.
- **Content width**: Dialog caps at `max-w-md` (448px); composing dialogs widen it via className override (e.g., `sm:max-w-2xl`).
- **Close button hide**: `showClose={false}` hides the affordance for dialogs whose footer buttons are the only dismissal path (e.g., a busy/loading state that blocks Escape and other dismissals).
- **Responsive behavior**: `w-[calc(100%-2rem)]` preserves 16px side margins on small screens; margins prevent edge-touching on mobile.
- **Escape override**: A composing component's keyboard policy may override Escape-to-close (e.g., for a search input within the dialog that captures Escape for its own purposes).

## Configuration

Subcomponents and their key props:
- **Dialog** (root): `disablePointerDismissal` (bool, default `true`), `open` (bool), `onOpenChange` (callback).
- **DialogTrigger**: Forwards Base UI Trigger props; typically wraps an action button.
- **DialogClose**: Forwards Base UI Close props; used in footer buttons or standalone.
- **DialogContent**: `showClose` (bool, default `true`), `className` (string for overrides); forwards Base UI Popup props.
- **DialogHeader**: `className` override; forwards div props.
- **DialogFooter**: `className` override; forwards div props.
- **DialogTitle**: Forwards Base UI Title props.
- **DialogDescription**: Forwards Base UI Description props.

## Deep Linking

Not applicable: Dialog is a primitive component without its own navigation path. Deep linking to dialog state belongs to the parent page or application that hosts the dialog.

## Localization

Not applicable: Dialog contains no user-facing strings except the built-in close button aria-label (`"Close"`), which Base UI provides in English. Composing components add their own translatable titles and descriptions via `DialogTitle` and `DialogDescription`.

## Accessibility Options

Not applicable: Dialog has no animations to reduce (Reduce Motion), does not use color alone to convey information (Differentiate Without Color), and inherits text color contrast from the `apt-*` token family (Increase Contrast).

## Feature Flags

Not applicable: Dialog is a primitive component without feature flags. Feature gate decisions belong to composing components.

## Analytics

Not applicable: Dialog is a presentational primitive. Composing components and parent pages own open/close analytics; if needed, wrap the dialog's `onOpenChange` callback to emit events.

## Privacy

Not applicable: Dialog collects no data.

## Logging

None — a presentational primitive. Callers own open/close analytics.

## Platform Notes

- **React / Web (TypeScript)**: Implemented in `packages/web/packages/ui/src/components/dialog.tsx`. Built on `@base-ui/react/dialog`. Marked `"use client"` for Next.js. Responsive behavior verified via Playwright (ui-showcase) at 375px, 768px, and 1440px viewport widths.
- **SwiftUI**: Not applicable — web-only shared component. A SwiftUI-native equivalent would use `sheet` or custom overlay modifiers.
- **Kotlin Compose**: Not applicable — web-only shared component. A Compose equivalent would use `Dialog` composable from Material Design 3.
- **AppKit / UIKit**: Not applicable — web-only shared component. iOS native equivalent uses `UIAlertController` with `preferredStyle: .alert` or a custom `UIViewController` modal presentation.
- **WinUI 3**: A WinUI equivalent would use `ContentDialog` control with `IsPrimaryButtonEnabled`, `IsSecondaryButtonEnabled` for actions. Set `CloseButtonVisibility="Visible"` to show a close button. Apply theme colors via `Application.Current.Resources` for dark/light mode token equivalents. Backdrop is handled via `AcrylicBrush` with `TintOpacity: 0.3` to approximate the `bg-black/30` effect.

## Design Decisions

- **Backdrop dismissal disabled by default.** Modals and alerts dismiss only via a button (per [[alert-and-dialog]] §6), preventing accidental data loss and clarifying intent. Pointer dismissal is opt-in for advanced use cases.
- **Built on Base UI.** Inherits focus trapping, portalling, and assistive technology support rather than hand-rolling them, reducing maintenance burden and ensuring standards compliance.
- **30% backdrop opacity.** A 30% black overlay with blur keeps the underlying page legible and subordinate while preserving context, unlike the harder 60% opacity that obscures the page entirely.
- **apt-* tokens.** All colors and spacing use the design system token family, ensuring consistent theming across the product without raw hex values or !important overrides.

## Compliance

| Check | Status | Category |
|---|---|---|
| Artifact formatting (ingredient) | passed | artifact-formatting |
| UI guidelines — `apt-*` tokens, no raw hex, no `!important` | passed | adh-ui-guidelines |

## Change History

| Version | Date | Author | Summary |
|---|---|---|---|
| 1.0.1 | 2026-09-22 | Claude Haiku 4.5 | Correct backdrop opacity from bg-black/60 to bg-black/30 per source; structure Appearance section; fix domain URI from hub to cookbook; expand Accessibility, Edge Cases, and Platform Notes; upgrade status from draft to review |
| 1.0.0 | 2026-06-26 | Mike Fullerton | Initial draft |
