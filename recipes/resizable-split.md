---
id: c21473ee-a075-4800-96db-ff3de0888515
title: "ResizableSplit"
domain: agenticdevelopercookbook://recipes/resizable-split
type: ingredient
version: 2.1.0
status: review
language: en
created: 2026-06-26
modified: 2026-09-22
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: "A vertical two-pane split with a draggable divider (1px grip seam, or a header bar for the bottom pane), animated collapse, reveal-to-fit, and optional persisted ratio."
platforms:
  - typescript
  - web
tags:
  - component
  - layout
  - split
  - ui
depends-on: []
related: []
references: []
---

# ResizableSplit

## Overview

A vertical (top/bottom) split with a draggable divider and a collapse toggle for the bottom pane, in `@agenticdevelopertoolkit/ui`. It lays out two stacked panes — PEERS in the column; the bottom never overlays the top — whose split ratio the user drags; the bottom pane can be collapsed/expanded via a chevron on the divider, with an animated boundary. It offers controlled collapse plus an optional persisted ratio, and is otherwise self-contained.

The divider has two forms:

- **seam** (default): a 1px connected boundary with a visible centered grip pill and a generous 24px transparent grab band; the collapse chevron sits at the right edge.
- **header bar** (`header`/`headerActions` set): the divider IS the bottom pane's header — a real strip with the pane's title left, optional actions and the disclosure chevron at the far right. The whole bar is a drag target, and the bar stays visible while the pane is hidden (it is the collapsed remnant).

It adapts the hand-rolled divider in `status-backend`'s `Dashboard.tsx` (ratio state, `row-resize`, clamp, localStorage persistence) into a reusable, token-styled component. It is used by `ListWithDetailsPane` (table over details).

## Behavioral Requirements

- **drag-captures-pointer**: On pointer-down on the divider, the component MUST capture the pointer via `setPointerCapture()`.
- **drag-maps-to-ratio**: On pointer-move while captured, the component MUST map `clientY` within the container bounding rect to a top-pane ratio (`(clientY - rect.top) / rect.height`).
- **drag-clamps-ratio**: The component MUST clamp the ratio to `[minRatio, maxRatio]`.
- **drag-releases-on-pointerup**: On pointer-up, the component MUST release the pointer capture via `releasePointerCapture()`.
- **drag-cursor-and-no-select**: While dragging, the component MUST show `cursor: row-resize` and MUST suppress text selection via `touchAction: "none"`.
- **persist-ratio-when-keyed**: When `storageKey` is set, the component MUST write the ratio to `localStorage[storageKey]` on drag release and MUST restore it on mount, guarded for SSR contexts and parse errors.
- **collapse-toggles-bottom**: Activating the divider chevron MUST toggle `collapsed`; collapsed MUST give the bottom pane height 0 via `flex-basis`, let the top fill, and flip the chevron icon.
- **collapse-remembers-ratio**: The component MUST remember the last drag ratio (stored in `latest.current`) while collapsed and restore it on expand.
- **collapse-controlled-or-internal**: When `collapsed`/`onCollapsedChange` are provided the component MUST be controlled; otherwise collapse state MUST be internal (managed via `internalCollapsed`).
- **keyboard-nudges-ratio**: When the divider handle is focused and receives keyboard input, ↑/↓ MUST nudge the ratio by 0.03 (3%), clamped to `[minRatio, maxRatio]`, and MUST persist on release.
- **keyboard-toggles-collapse**: Enter/Space on the chevron button MUST toggle collapse (handled via native button behavior).
- **header-bar-variant**: When `header` (or `headerActions`) is set, the divider MUST render as a header bar: `header` content left-aligned in a truncated flex column, `headerActions` then the disclosure chevron at the far right.
- **header-bar-always-visible**: The header bar MUST stay visible while the bottom pane is collapsed — only the bar remains (the bar has no `inert` wrapper).
- **header-bar-drag-anywhere**: Pointer-down anywhere on the header bar EXCEPT on its interactive controls (buttons, links, inputs, selects, textareas, or `[data-no-drag]` elements) MUST start a resize drag; while expanded the bar MUST show `cursor: row-resize`.
- **toggle-animates**: Collapse/expand MUST animate the shared boundary for 0.3s (ease-in-out) via `flex-basis` transition. It MUST NOT animate when the app-level appearance setting `html[data-reduce-motion="on"]` is active. Drags are direct manipulation and MUST never animate.
- **expand-to-content**: With `expandToContent` (default on for the header-bar variant), expanding from collapsed MUST open the bottom pane exactly far enough to show ALL its content (via `scrollHeight`), clamped to `[minRatio, maxRatio]`; when the container/content can't be measured it MUST fall back to the last drag ratio.
- **bottom-stays-mounted**: The bottom pane MUST stay mounted while collapsed (height 0 via flex-basis, clipped by `overflow-hidden`, marked `inert`) so its state survives a hide/show cycle and reveal-to-fit can measure the hidden content.

## Appearance

```
seam (default):
┌───────────────────────────────┐
│  top                          │  flex: 0 1 ratio%
├────────── ▬▬ ──────────── ⌄ ──┤  1px seam + centered grip pill + 24px grab band
│  bottom                       │  flex: 1
└───────────────────────────────┘
header bar:
┌───────────────────────────────┐
│  top                          │  flex: 0 1 ratio%
├ Details ────────── [actions] ⌄┤  the bar IS the divider (drag anywhere on it)
│  bottom                       │  flex: 1
└───────────────────────────────┘
collapsed (either form):
┌───────────────────────────────┐
│  top (fills)                  │
├ Details ─────────────────── ⌃ ┤  only the divider/bar remains; bottom stays
└───────────────────────────────┘  mounted at height 0 (clipped, inert)
```

- **Container**: `flex flex-col min-h-0`. Panes: `min-h-0 overflow-auto` (bottom wrapped in `overflow-hidden` so the collapse animation never exposes a scrollbar).
- **Seam**: 1px `bg-apt-border`, hover `bg-apt-border-strong`; centered grip pill (`bg-apt-border-strong`, `rounded-full`, 10px × 4px); invisible 24px grab band centered on seam carries the drag; `cursor: row-resize`; chevron right-aligned, `text-apt-text-muted` on idle, `text-apt-text` on hover.
- **Header bar**: `border-y border-apt-border bg-apt-surface`, mono muted title left (`font-mono text-[11px] tracking-wide text-apt-text-muted`), actions + chevron right; `cursor: row-resize` across the bar (default cursor on its controls and while collapsed).
- **No raw hex**; no `!important`.

## States

| State | Appearance change |
|---|---|
| Idle | divider `bg-apt-border` |
| Divider hover | seam `bg-apt-border-strong`; grip pill opacity 100% |
| Dragging | `cursor: row-resize`; text selection suppressed; no animation (direct manipulation) |
| Handle focused | divider receives `tabIndex=0`; browser focus ring |
| Expanded | bottom pane visible at the current ratio; chevron icon `ChevronDown` |
| Collapsed | bottom pane height 0 (still mounted, `inert`); top fills; chevron icon `ChevronUp`; header bar (if any) stays visible |
| Toggling | boundary animates 0.3s ease-in-out via `flex-basis` transition; skipped under `html[data-reduce-motion="on"]` |

## Accessibility

- **Divider handle**: `role="separator"`, `aria-orientation="horizontal"`, `aria-valuenow`/`aria-valuemin`/`aria-valuemax` reflecting the ratio as percentages, `tabIndex=0`.
- **Collapse button**: a real native `<button>` with `aria-expanded` (reflects `!isCollapsed`) and `aria-label` from `bottomLabel` (default "Details").
- **Keyboard support**: ↑/↓ on the focused divider nudges the ratio; Enter/Space on the button toggles collapse (native button behavior).
- **Minimize touch target**: Chevron button is 14px (header bar) or 12px (seam), within the transparent grab band, not a separate target. The 24px grab band centered on the seam is the primary touch target (48×24px on seam, full bar width on header bar).

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|---|---|---|---|
| T1 | drag-clamps-ratio | drag past the minimum (0%) | ratio clamps at `minRatio` (default 0.2) |
| T2 | drag-clamps-ratio | drag past the maximum (100%) | ratio clamps at `maxRatio` (default 0.85) |
| T3 | collapse-toggles-bottom | click the chevron | bottom hidden (height 0); `aria-expanded="false"` |
| T4 | collapse-toggles-bottom | click the chevron again | bottom visible (height restored); `aria-expanded="true"` |
| T5 | persist-ratio-when-keyed | set `storageKey`, drag to 0.5, unmount, remount | ratio restores to 0.5 from `localStorage` |
| T6 | keyboard-nudges-ratio | focus divider, press ↑ | ratio nudges down by 0.03, clamped |
| T7 | keyboard-nudges-ratio | focus divider, press ↓ | ratio nudges up by 0.03, clamped |
| T8 | drag-captures-pointer | pointer-down on divider, move mouse, pointer-up | split ratio follows the pointer throughout; `moved` flag tracks motion |
| T9 | keyboard-toggles-collapse | focus chevron button, press Enter | collapse toggles |
| T10 | keyboard-toggles-collapse | focus chevron button, press Space | collapse toggles |
| T11 | header-bar-variant | render with `header="Details"` | the separator renders as a bar containing the title; chevron is inside, far right |
| T12 | header-bar-always-visible | collapse the header-bar variant | the bar (title + chevron `⌃`) renders; bottom is `inert`, height 0 |
| T13 | header-bar-drag-anywhere | pointer-down on `headerActions` button element | no drag starts; the button's native click fires |
| T14 | expand-to-content | collapsed; content `scrollHeight` 300px in 1000px container (28px bar); expand | top pane ratio ≈ 0.672 = 1 − (300 + 28) / 1000 |
| T15 | bottom-stays-mounted | collapse the component | bottom content remains in the DOM inside an `overflow-hidden` wrapper with `inert` attribute |
| T16 | toggle-animates | set `html[data-reduce-motion="on"]`, toggle collapse | boundary animates with zero duration (no transition style applied) |
| T17 | toggle-animates | toggle collapse with `html[data-reduce-motion]` unset | boundary animates 0.3s ease-in-out |
| T18 | drag-cursor-and-no-select | drag the divider | cursor shows `row-resize`; text selection is suppressed via `touchAction: "none"` |

## Edge Cases

- **localStorage access failure (SSR, sandboxed iframes, disabled storage)**: Wrapped in try-catch; on any error the component silently falls back to `defaultRatio` or the in-memory ratio.
- **Zero-height container or content**: `revealRatioForContent()` guards against `containerH <= 0` or `contentH <= 0` by returning the fallback ratio; prevents NaN.
- **Concurrent collapse requests**: When controlled via `onCollapsedChange`, rapid toggles are handled by React state; internal state uses a single `internalCollapsed` ref, no queue.
- **Drag-over-chevron suppression**: The `moved` flag is reset on any fresh pointer-down (including presses on the chevron), ensuring a short drag over the chevron does not also trigger the click.
- **Animation timer cleanup**: The animation timer is cleared on unmount to prevent dangling timeouts.

## Configuration

| Option | Type | Default | Description |
|---|---|---|---|
| `top` | `React.ReactNode` | — | Top pane content (required). |
| `bottom` | `React.ReactNode` | — | Bottom pane content (required). |
| `defaultRatio` | `number` | `0.6` | Initial top fraction (0..1), clamped to `[minRatio, maxRatio]`. |
| `minRatio` | `number` | `0.2` | Lower clamp bound (0..1). |
| `maxRatio` | `number` | `0.85` | Upper clamp bound (0..1). |
| `storageKey` | `string` | — | When set, persist the ratio in `localStorage[storageKey]` on drag release; restore on mount. |
| `collapsed` | `boolean` | — | Controlled collapse state of the bottom pane. When omitted, collapse is internal. |
| `onCollapsedChange` | `(collapsed: boolean) => void` | — | Called when collapse state changes (via chevron click). If omitted, collapse is uncontrolled. |
| `bottomLabel` | `string` | `"Details"` | Accessibility label for the chevron button (`aria-label`). |
| `header` | `React.ReactNode` | — | When set, render the divider as the bottom pane's header bar with this left-aligned content; triggers header-bar variant. |
| `headerActions` | `React.ReactNode` | — | Right-aligned interactive controls on the header bar, before the chevron; never drag targets. Setting this also triggers header-bar variant. |
| `expandToContent` | `boolean` | `true` (header bar), `false` (seam) | On expand-from-collapsed, size the bottom pane to show all its content (clamped to `[minRatio, maxRatio]`). |
| `className` | `string` | — | Additional CSS classes applied to the container. |

When `collapsed`/`onCollapsedChange` are omitted, collapse state is internal and managed via `internalCollapsed`. The ratio is always internal, seeded from `storageKey` or `defaultRatio`, and persisted on drag release.

## Deep Linking

Not applicable: ResizableSplit is a layout primitive, not a navigation target or content container that would benefit from deep linking.

## Localization

Not applicable: ResizableSplit contains no user-facing text strings; `bottomLabel` is a prop supplied by the consuming component, and the chevron is a pure icon (no text).

## Accessibility Options

- **Reduce Motion**: The component respects `html[data-reduce-motion="on"]` set by the app-level appearance setting. When active, collapse/expand animations are skipped (no transition style applied). This is distinct from the OS `prefers-reduced-motion` media query.

## Feature Flags

Not applicable: ResizableSplit is a foundational UI primitive with no feature-gated behavior.

## Analytics

Not applicable: ResizableSplit emits no analytics events; it is a presentational layout component.

## Privacy

Not applicable: ResizableSplit collects no personal data. `localStorage` persistence of the ratio is scoped to the consuming page and never transmitted.

## Logging

No logging. ResizableSplit is a presentational layout primitive; it emits no structured log events.

## Platform Notes

- **React/Web** (TypeScript, source platform): Component in `packages/web/packages/ui/src/components/resizable-split.tsx`. Uses Lucide React icons (`ChevronDown`, `ChevronUp`). Flex layout with `flex-basis` for ratio and collapse animation. Pointer events for drag; keyboard handlers for nudge and toggle. `localStorage` for optional persistence, guarded for SSR. The seam variant uses an invisible 24px grab band centered on a 1px seam; the header-bar variant is always-visible and full-width draggable. Demo in `ui-showcase`.
- **SwiftUI**: Use a `VStack` with `Divider` or a custom separator shape; bind the top pane to a `@State` proportion and animate via `.animation()` gated on `@Environment(\.accessibilityReduceMotion)`. Drag gesture on the divider maps `translation.height` to the proportion; keyboard support via `.onKeyPress()` for ↑/↓ nudge and chevron button. Persist via `UserDefaults` on drag release. Header-bar variant renders the divider as the bottom pane's header with drag anywhere (except buttons). Seam variant uses a thin opacity-variable separator with a pill-shaped accent.
- **Kotlin/Compose**: Use `Column` with `weight()` for ratio; `Draggable` modifier on the divider for drag input, map `delta` to proportion. Animate via `.animateTo()` for collapse/expand, respecting `LocalAccessibilityManager.current.isScreenReaderEnabled` or a custom reduce-motion flag. Persist via `DataStore` on drag release. Header-bar variant: compose the divider as a full-width `Row` above the bottom pane. Seam variant: thin `Divider()` with a centered pill accent.
- **Android/Material**: Follow Material Design 3 guidance for draggable surfaces (at least 48×48dp touch target). Use `ConstraintLayout` or `SplitPaneLayout` if available; otherwise `LinearLayout` with dynamic `layoutParams` weight. Handle drag via `OnTouchListener` with motion tracking. Animate via `ObjectAnimator` or `setLayoutParams()` transition. Respect `AccessibilityManager.isEnabled()` for animation gating. Persist via `SharedPreferences`.
- **WinUI 3**: Use `SplitView` control (built-in split pane with divider). Bind pane sizes to a `double` proportion; drag divider to update. `SplitView` handles pointer capture and `row-resize` cursor automatically. Animate the pane width via `Storyboard` or `ThemeTransition`. For the header-bar variant, customize the divider template to render the header content. Collapse toggles the `IsPaneOpen` property. Persist via `ApplicationData.Current.LocalSettings`. Header-bar variant: override the divider template with a full-height `CommandBar` or `StackPanel` containing the title and actions.

## Design Decisions

- **Adapted from status-backend.** Generalizes the hand-rolled divider in `Dashboard.tsx` (ratio state, `row-resize`, clamp, localStorage persistence) into a reusable, token-styled primitive rather than re-rolling it per site.
- **Self-contained ratio, optional persistence.** The ratio is internal and seeded from `storageKey` or `defaultRatio`; persistence is opt-in via `storageKey`. This keeps the component simple and avoids prop drilling while supporting stateful use cases.
- **Bottom pane stays mounted while collapsed.** Keeping the pane mounted (with `inert` and `height: 0`) preserves internal state across toggle cycles, enables reveal-to-fit measurement, and simplifies animation (both endpoints of the flex-basis transition are always defined).
- **Header-bar variant.** Two visual modes (seam vs. header bar) support different UX patterns: the seam is minimal and works best as a divider between independent panes; the header bar anchors the bottom pane's identity and always remains visible, making it clear what the collapsed button reveals.
- **Expand-to-content default depends on variant.** Header bar defaults to true because the bar itself occupies space; the pane's content size becomes the secondary question. Seam defaults to false because a user's last manual ratio is the most accurate memory of their preference.
- **Reduce-motion gating on app-level attribute, not OS media query.** The component respects `html[data-reduce-motion="on"]` set by the app theme settings, not the OS `prefers-reduced-motion` media query, because some apps' accessibility.css layers both (media query gates the attribute). This avoids double-gating.
- **Drag-over-chevron suppression via moved flag.** A small accidental drag over the chevron during a click should not toggle the pane; the `moved` flag (reset per pointer-down, set after 3px motion) gates the toggle, avoiding the "dancing divider" UX.

## Compliance

No additional compliance categories apply to this presentational primitive.

## Change History

| Version | Date | Author | Summary |
|---|---|---|---|
| 2.1.0 | 2026-09-22 | Mike Fullerton | Correct domain URI to agenticdevelopercookbook://recipes/resizable-split; add missing template sections (Deep Linking, Localization, Accessibility Options, Feature Flags, Analytics, Privacy) marked not applicable; expand conformance test vectors to 18 (separate keyboard up/down, add drag-over-chevron, reduce-motion with and without); document edge cases including animation timer cleanup; clarify platform notes with specific control names and patterns for SwiftUI, Compose, WinUI 3; strengthen requirements with implementation details (latest.current, scrollHeight, moved flag, flex-basis). |
| 2.0.0 | 2026-07-10 | Mike Fullerton | Header-bar divider variant (always-visible details header, drag anywhere, chevron far right); animated collapse gated on app-level reduce-motion; expand-to-content reveal; bottom pane stays mounted (inert) while collapsed; documented the shipped grip-pill + 24px grab-band seam. |
| 1.0.0 | 2026-06-26 | Mike Fullerton | Initial conversion from legacy UI spec. |
