---
id: ca0fb28f-7f22-4fde-a291-ecfde846f5c3
title: Pagination
domain: agenticdevelopercookbook://ingredients/pagination
type: ingredient
version: 1.1.0
status: review
language: en
created: '2026-07-03'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: "The list pager on the shared Button: controlled Prev / Page X of Y / Next in a Pagination nav landmark; renders nothing at one page, disables the edges."
platforms:
- typescript
- web
tags:
- component
- pagination
- pager
- navigation
- ui
depends-on:
- agenticdevelopercookbook://ingredients/button
related: []
references: []
approved-by: ''
approved-date: ''
---

# Pagination

## Overview

The shared `Pagination` in `@agenticdevelopertoolkit/ui` — the list pager used above and below the
paged surfaces across adh. It is a compact `Prev` / "Page X of Y" / `Next` control: a
centered `nav` landmark holding two shared `Button`s (`variant="outline"`,
`size="sm"`) around a mono caption.

It is fully **controlled**: the host owns `page` and `totalPages` and receives
`onPageChange(nextPage)` when a button is clicked — the pager renders the host's truth
and requests a change rather than keeping its own counter. When there is only one page
(`totalPages <= 1`) it renders nothing, so call sites never wrap it in their own
`{totalPages > 1 && …}` conditional. The `Prev` button is disabled on the first page
and `Next` on the last, so an out-of-range request can never be issued from the edges.

A single export ships from `@agenticdevelopertoolkit/ui/components/pagination`: the `Pagination`
component. It carries `"use client"` (it composes the client `Button`) but holds no
internal state — the displayed page is always the `page` prop.

## Behavioral Requirements

- **hides-when-single-page**: When `totalPages` is `<= 1`, the component MUST render nothing.
- **renders-pagination-landmark**: The component MUST render a `nav` element with `aria-label="Pagination"`.
- **shows-page-caption**: The component MUST render a `Page {page} of {totalPages}` caption reflecting the current props.
- **disables-prev-on-first**: When `page <= 1`, the component MUST disable the `Prev` button.
- **disables-next-on-last**: When `page >= totalPages`, the component MUST disable the `Next` button.
- **pages-backward**: Clicking `Prev` MUST call `onPageChange` with `page - 1`.
- **pages-forward**: Clicking `Next` MUST call `onPageChange` with `page + 1`.
- **controlled-page**: The component MUST reflect the `page` prop directly and MUST NOT advance the page on its own — a new page appears only when the host re-renders with a new `page`.
- **forwards-classname**: The component MUST merge a consumer `className` onto the `nav` via `cn()`.

## Appearance

```
[ Prev ]     Page 3 of 5     [ Next ]
 outline      mono, muted      outline
 size sm      xs caption       size sm
```

- Row: `nav` with `flex items-center justify-center gap-2`, centered; extra classes
  merge via `cn()` through `className`.
- `Prev` / `Next`: the shared `Button` with `variant="outline"` and `size="sm"`, plain
  text labels.
- Caption: `<span>` with `px-1 font-mono text-xs text-apt-text-muted`, reading
  `Page {page} of {totalPages}`.
- Disabled edge buttons inherit `Button`'s disabled treatment (`opacity-50`,
  `pointer-events-none`).
- Token-driven (`apt-text-muted`); no raw hex, no `!important`.

## States

| State | Appearance change |
|---|---|
| Single page (`totalPages` ≤ 1) | Renders nothing |
| First page (`page` ≤ 1) | `Prev` disabled (dimmed, non-interactive); `Next` enabled |
| Middle page | Both `Prev` and `Next` enabled |
| Last page (`page` ≥ `totalPages`) | `Next` disabled; `Prev` enabled |
| Hover / focus / pressed | Inherited from `Button` outline (background lift, focus-visible ring, press dip) |

## Accessibility

- The pager is a `<nav aria-label="Pagination">` landmark, so assistive tech can jump
  straight to it and tell it apart from other `nav`s on the page.
- `Prev` and `Next` are real buttons with visible text labels (no icon-only
  ambiguity), disabled through the native `disabled` attribute at the bounds — so AT
  announces them as unavailable and skips them in the focus order.
- The `Page X of Y` caption is visible, textual position that anyone can read; it is
  plain text (not `aria-live`), so a position change is announced when focus or the
  surrounding content updates rather than interrupting.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|---|---|---|---|
| T1 | hides-when-single-page | render `<Pagination page={1} totalPages={1} onPageChange={fn} />` | renders nothing (empty container) |
| T2 | renders-pagination-landmark, shows-page-caption | `page={1} totalPages={3}` | a `nav[aria-label="Pagination"]` containing the caption `"Page 1 of 3"` |
| T3 | disables-prev-on-first | `page={1} totalPages={3}` | `Prev` button is disabled |
| T4 | pages-forward | `page={1} totalPages={3}`, click `Next` | `onPageChange` called with `2` |
| T5 | disables-next-on-last, shows-page-caption | `page={3} totalPages={3}` | caption `"Page 3 of 3"`; `Next` button disabled |
| T6 | pages-backward | `page={3} totalPages={3}`, click `Prev` | `onPageChange` called with `2` |
| T7 | controlled-page | rerender from `page={1}` to `page={2}` (`totalPages={3}`) | caption updates to `"Page 2 of 3"`; neither button disabled |
| T8 | forwards-classname | `className="mt-4"` | `nav` element carries the `mt-4` class |

## Edge Cases

- `totalPages` of `1` or `0` collapses the whole pager to `null`; hosts must rely on
  that and not add their own visibility guard.
- At the bounds the edge button is `disabled`, so `onPageChange(0)` or
  `onPageChange(totalPages + 1)` can never fire from a click — the component protects
  the edges by disabling rather than by clamping the emitted number.
- An out-of-range `page` from the host (e.g. `page={5}` with `totalPages={3}`) is
  reflected faithfully: the caption shows `"Page 5 of 3"` and `Next` stays disabled
  (`5 >= 3`); clamping the page into range is the host's responsibility, not the pager's.
- Being controlled, nothing changes visually on click until the host applies the new
  `page` — `onPageChange` is a request, not a self-mutation.

## Configuration

| Option | Type | Default | Description |
|---|---|---|---|
| `page` | `number` | required | Current 1-based page; drives the caption and which edge is disabled. |
| `totalPages` | `number` | required | Total page count; `<= 1` renders nothing. |
| `onPageChange` | `(page: number) => void` | required | Called with the requested page (`page ± 1`) when `Prev`/`Next` is clicked. |
| `className` | `string` | — | Extra classes merged onto the `nav` via `cn()`. |

## Deep Linking

Not applicable: pagination is a presentational control within a list surface and does not represent an independent navigation destination. The host owns the page state and URL routing.

## Localization

Not applicable: the component renders only UI chrome (`"Prev"`, `"Next"`, `"Page"`, `"of"`, and numeric values). These labels are not user-facing content and localization strings belong to the host context, not the component.

## Accessibility Options

Not applicable: the component uses semantic `nav` and `button` elements with standard focus and keyboard interaction. It does not apply transitions, transforms, or animations that would respond to motion-reduction preferences; it does not use color alone to convey state (disabled buttons use the native `disabled` attribute). It does not dynamically adjust contrast based on user preferences (inherited from the family `Button` component).

## Feature Flags

Not applicable: the component has no conditional behavior or experimental features requiring feature flags. The three button states (enabled, disabled at bounds, missing at single page) are all determined by the `page` and `totalPages` props.

## Analytics

Not applicable: `Pagination` is a presentational control; paging semantics, session tracking, and any analytics belong to the host that owns the list and the `page` state, not the pager itself.

## Privacy

Not applicable: the component does not collect, store, or transmit any user data. It receives `page` and `totalPages` as numbers and emits page-change requests; no personal information is processed.

## Logging

No logging. `Pagination` is a presentational control; paging semantics and any event tracking belong to the host that owns the list and the `page` state, not the pager.

## Platform Notes

- **React/Web**: File `packages/web/packages/ui/src/components/pagination.tsx`. Carries `"use client"` because it composes the client `Button` and renders on the browser; holds no internal state. Composes the shared `Button` (outline/sm variant); no bespoke UI chrome. Layout is flexbox (`flex items-center justify-center gap-2`) with Tailwind utilities; token-driven via `apt-text-muted` for the caption. Demo in `ui-showcase` (Composite controls group); `PaginationDemo` component owns the page state.

- **SwiftUI**: Start from a `HStack` containing two `Button` views and a `Text` view. The equivalent structure is a controlled component receiving `page`, `totalPages`, and an `onPageChange` closure. Buttons use the family `Button` style (outline variant, small size) or platform-native styling. Collapse the entire stack to `EmptyView()` when `totalPages <= 1`. Disable the leading (previous) button when `page <= 1` and the trailing (next) button when `page >= totalPages`. The caption displays `"Page \(page) of \(totalPages)"` in a monospace font with muted text color. Use `@Environment(\.dynamicTypeSize)` to detect accessibility settings and scale text appropriately.

- **Compose**: Build from a `Row` composable containing two `Button` composables (using the family Button style or Material Button) and a `Text` displaying the page caption. The pattern is identical to React: fully controlled, host owns state. Return `null` when `totalPages <= 1`. Buttons are disabled based on page bounds (`page <= 1` for back, `page >= totalPages` for forward). Use `Modifier.fillMaxWidth()` and `horizontalArrangement = Arrangement.Center` for centering. Caption uses monospace font (`FontFamily.Monospace`) and muted text color. The `onClick` lambdas call the `onPageChange` callback with `page - 1` or `page + 1` respectively.

- **AppKit / UIKit**: Assemble an `NSStackView` (macOS) or `UIStackView` (iOS) with `axis = .horizontal`, `alignment = .center`, `distribution = .fillProportionally`, and `spacing = 8pt`. Add two `NSButton` / `UIButton` instances styled as outline variants, separated by an `NSTextField` / `UILabel` showing the page caption. The component is fully controlled: update the button `isEnabled` state based on page bounds, hide the entire stack when `totalPages <= 1`, and update the label text when `page` changes. Buttons MUST NOT be styled with custom drawRect; use the platform's button appearance APIs for consistency. The caption uses a monospace system font (e.g., `NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)` on macOS) at 11pt with muted text color.

- **WinUI 3**: Build from a `StackPanel` with `Orientation="Horizontal"` and `HorizontalAlignment="Center"`. Include two `Button` elements (using the Fluent `IconButton` style or standard Button with outline appearance) and a `TextBlock` for the page caption. Bind button `IsEnabled` to computed properties based on page bounds. Use `Visibility.Collapsed` (not removal) when `totalPages <= 1` to preserve layout. Buttons should have `AutomationProperties.Name` set to "Previous page" and "Next page" for accessibility. The caption renders as `"Page {page} of {totalPages}"` using `FontFamily="Courier New"` or `"Cascadia Mono"` at 11pt with a muted text color token from the Fluent 2 palette. Bind `Text` and button states to backing properties so the host can drive page changes through property binding.

## Design Decisions

- **Controlled, host owns the page.** `page`, `totalPages`, and `onPageChange` are all inputs; the pager renders the host's truth and requests a change, so it stays in lockstep with URL/query state the host already tracks instead of forking a second counter.
- **Render null at ≤1 page, not the host.** Collapsing itself when there is a single page means every call site is just `<Pagination …/>` with no surrounding `{totalPages > 1 && …}`, so the visibility rule lives in exactly one place.
- **Disable the edges, don't clamp the number.** `Prev`/`Next` are disabled at the bounds (`page <= 1`, `page >= totalPages`) so an out-of-range request can't be issued; the component trusts the host to keep `page` in range rather than second-guessing it.
- **Prev/Next over a numbered strip.** A two-button pager with a `Page X of Y` caption stays compact and predictable for the list surfaces it serves, avoiding the layout churn of a windowed page-number row.
- **Compose the family Button.** Both controls are the shared `Button` (outline/sm), so the pager inherits the family focus ring, disabled treatment, and press feel for free.

## Compliance

| Check | Status | Category |
|---|---|---|
| No raw hex / arbitrary colors / `!important` | pass | project-guidelines UI |
| Components sourced from `@agenticdevelopertoolkit` (Button; no bespoke UI) | pass | project-guidelines UI |
| Pager wrapped in a `nav` landmark with `aria-label` | pass | accessibility |
| Edge controls disabled via the native `disabled` attribute | pass | accessibility |

## Change History

| Version | Date | Author | Summary |
|---|---|---|---|
| 1.1.0 | 2026-09-22 | Mike Fullerton | Add all required template sections (Deep Linking, Localization, Accessibility Options, Feature Flags, Analytics, Privacy); expand Platform Notes to provide translation guidance for all five platforms (SwiftUI, Compose, React/Web, AppKit/UIKit, WinUI 3); update to review status. |
| 1.0.0 | 2026-07-03 | Mike Fullerton | Initial recipe; documents the controlled Prev/Next Pagination pager on shared Button. |
