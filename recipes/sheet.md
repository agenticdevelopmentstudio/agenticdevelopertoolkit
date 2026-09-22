---
id: 10cd0ad8-b7b7-4674-9f8c-80a071fecb6f
title: Sheet
domain: agenticdevelopercookbook://ingredients/sheet
type: ingredient
version: 1.0.1
status: review
language: en
created: 2026-09-22
modified: 2026-09-22
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: A side drawer panel that slides in from a specified edge, used for supplementary
  content or actions without full-screen navigation.
platforms:
- web
tags:
- sheet
- drawer
- modal
- dialog
depends-on: []
related: []
references: []
---

# Sheet

## Overview

Sheet is a compound component that renders a slide-out drawer anchored to one edge of the viewport. It wraps a Base UI Dialog primitive and provides styled, animated panels for supplementary content, settings, or actions. The component supports positioning from top, right, bottom, or left edges and includes an animated backdrop that blocks interaction with underlying content.

## Behavioral Requirements

- **must-render-compound-components**: Component MUST export individual compound parts: Sheet (root), SheetTrigger, SheetClose, SheetPortal, SheetOverlay, SheetContent, SheetHeader, SheetFooter, SheetTitle, and SheetDescription.
- **must-position-by-side**: SheetContent MUST position the drawer based on a `side` prop ("top" | "right" | "bottom" | "left"), with default value "right".
- **must-render-overlay**: Component MUST render an overlay element with semi-transparent dark background that appears behind the drawer.
- **must-apply-backdrop-blur**: Overlay MUST apply a blur effect (backdrop-filter: blur) on supporting browsers.
- **must-render-close-button-by-default**: SheetContent MUST render a close button by default in the top-right corner.
- **must-allow-close-button-control**: SheetContent MUST accept a `showCloseButton` boolean prop (default `true`) to control close button visibility.
- **must-use-xicon-for-close**: Close button MUST render an X icon (XIcon from lucide-react).
- **must-include-screen-reader-text**: Close button MUST include screen reader text ("Close") via `<span className="sr-only">`.
- **must-animate-on-open-close**: Drawer content and overlay MUST animate with a CSS transition on appearance and disappearance.
- **must-apply-animation-scale**: Animation duration MUST be calculated using the CSS custom property `--apt-anim-scale` (default 1), with specific durations: 150ms for overlay, 200ms for drawer.
- **must-constrain-width-on-sides**: When positioned left or right, SheetContent MUST constrain width to 3/4 (75%) of viewport on small+ screens.
- **must-allow-content-composition**: Sheet, SheetTrigger, SheetClose, SheetPortal, and SheetContent MUST accept and spread component props to their underlying Base UI primitives.
- **must-render-header-footer-helper-divs**: SheetHeader and SheetFooter MUST render as semantic divs with predefined padding and flex layout.
- **must-render-title-description**: SheetTitle and SheetDescription MUST wrap Base UI primitives with styled typography.

## Appearance

- **Corner radius**: None (sharp edges, matching popover design token).
- **Padding**: 
  - SheetHeader: 1rem (16px) all sides, with 4px gap between children.
  - SheetFooter: 1rem (16px) all sides, with 8px gap between children.
  - SheetContent: 1rem (16px) gap between top-level children.
- **Font**: 
  - SheetTitle: font-weight 500, size 1rem (16px).
  - SheetDescription: size 0.875rem (14px).
- **Background**: Popover background color (via `bg-popover` token).
- **Foreground/Text**: 
  - Popover foreground for default text (via `text-popover-foreground` token).
  - Muted foreground for SheetDescription (via `text-muted-foreground` token).
  - Foreground color for SheetTitle (via `text-foreground` token).
- **Border**: 1px border using `border-apt-border` token, position varies by side (top, right, bottom, or left as appropriate).
- **Shadow**: Box shadow applied to drawer panel (via `shadow-lg` token).
- **Overlay appearance**: Black with 20% opacity (`bg-black/20`), semi-transparent with backdrop blur.
- **Close button position**: Absolute, top-right corner (16px from edges), size `icon-sm` (smaller than default button).
- **Width constraints**: 
  - Left/right positioning: 3/4 width (75%) on small and larger screens (`sm:max-w-sm`).
  - Top/bottom positioning: full width, height auto.

## States

| State | Appearance change |
|-------|------------------|
| Closed | Drawer is off-screen; overlay is not rendered. |
| Opening | Drawer animates into viewport; overlay fades in. Opacity and transform transition based on `--apt-anim-scale`. |
| Open | Drawer is fully visible at its final position; overlay covers background at full opacity. |
| Closing | Drawer animates out of viewport; overlay fades out. Uses `data-ending-style` for exit transition. |

## Accessibility

- **Role/trait**: Drawer is rendered as a Dialog (via Base UI `Dialog` primitive), which is announced as a dialog by screen readers.
- **Label requirements**: SheetTitle MUST be present and labeled when the drawer contains a meaningful title; Base UI Dialog associates the title automatically.
- **Announce state changes**: Base UI Dialog handles focus management and announces opening/closing to screen readers.
- **Minimum tap target**: Close button MUST meet 44×44pt minimum on touch devices (enforced by Button component's `size="icon-sm"` variant).
- **Keyboard navigation**: Base UI Dialog primitive handles Escape key to close and focus trapping within the drawer. Source code relies on these inherited behaviors.
- **Screen reader text**: Close button includes visible screen-reader-only label ("Close") to identify the button's purpose to assistive technology.

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| sheet-001 | must-render-compound-components | Import Sheet and sub-components | All 10 exports (Sheet, SheetTrigger, SheetClose, SheetPortal, SheetOverlay, SheetContent, SheetHeader, SheetFooter, SheetTitle, SheetDescription) are available and usable. |
| sheet-002 | must-position-by-side | Render SheetContent with `side="left"` | Drawer appears on left edge of viewport with `data-side="left"` attribute. |
| sheet-003 | must-position-by-side | Render SheetContent with `side="bottom"` (no side prop provided) | Drawer appears on right edge (default). |
| sheet-004 | must-render-overlay | Render Sheet with content | Overlay element with `data-slot="sheet-overlay"` appears behind drawer. |
| sheet-005 | must-apply-backdrop-blur | Inspect overlay in browser | `backdrop-filter: blur` is applied (via `supports-backdrop-filter:backdrop-blur-xs` class). |
| sheet-006 | must-render-close-button-by-default | Render SheetContent without `showCloseButton` prop | Close button renders in top-right corner. |
| sheet-007 | must-allow-close-button-control | Render SheetContent with `showCloseButton={false}` | Close button does not render. |
| sheet-008 | must-use-xicon-for-close | Inspect close button HTML | Button contains `XIcon` component. |
| sheet-009 | must-include-screen-reader-text | Render close button and inspect | `<span className="sr-only">Close</span>` is present. |
| sheet-010 | must-animate-on-open-close | Open and close drawer, inspect CSS | Drawer and overlay apply `transition duration-` classes; opacity and transform animate during state change. |
| sheet-011 | must-apply-animation-scale | Open drawer with `--apt-anim-scale` set to 2 | Overlay animation duration is 300ms (150ms × 2); drawer animation is 400ms (200ms × 2). |
| sheet-012 | must-constrain-width-on-sides | Render SheetContent with `side="right"` on small+ viewport | Width is constrained to 3/4 viewport width; `sm:max-w-sm` applies. |
| sheet-013 | must-allow-content-composition | Render SheetContent with additional `className` | Additional class is applied to the drawer element. |
| sheet-014 | must-render-header-footer-helper-divs | Render SheetHeader and SheetFooter | Both render as divs with padding (`p-4`) and flex layout. |
| sheet-015 | must-render-title-description | Render SheetTitle and SheetDescription | Title renders with `font-medium`, description with muted foreground color. |

## Edge Cases

- **Null/empty content**: If SheetContent is rendered with no children, drawer is still visible but empty. No error is thrown.
- **Overlay interaction**: Overlay is clickable and closing the dialog via overlay click is handled by the Base UI Dialog primitive (not explicitly implemented in source).
- **Multiple sheets**: Rendering multiple Sheet components simultaneously may result in stacking context issues; only one should be open at a time per design pattern.
- **Animation interruption**: If the drawer is opened and closed rapidly, transitions may stack or produce unexpected visual effects due to CSS animation overlap.
- **Side boundary**: On mobile with `side="left"` or `side="right"`, the 3/4 width constraint may leave insufficient space; width calculations use viewport units without media-query safety checks for very narrow viewports.
- **Custom animation scale**: If `--apt-anim-scale` is set to 0 or negative, animation behavior is undefined; no guards prevent invalid values.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `side` | "top" \| "right" \| "bottom" \| "left" | "right" | Specifies which edge the drawer slides in from. |
| `showCloseButton` | boolean | `true` | Controls whether the close button is rendered in the top-right corner. |

## Deep Linking

Not applicable: Sheet is a modal overlay component with no navigation entry point or URL routing integration in the source.

## Localization

Not applicable: Sheet contains no user-visible text strings beyond the hardcoded "Close" label for the close button, which is screen-reader-only and not localized in the source.

## Accessibility Options

| Option | Behavior |
|--------|----------|
| Reduce Motion | Sheet respects the `--apt-anim-scale` custom property, which can be set to 0 by the application to disable animations for users who prefer reduced motion. |
| Increase Contrast | Overlay opacity (`bg-black/20`) and text contrast rely on the underlying design token system; no component-level contrast override is implemented. |
| Differentiate Without Color | Component does not rely on color alone to communicate state; positional and structural changes are visible independently of color. |

## Feature Flags

Not applicable: Sheet has no conditional behavior or feature flag integration in the source.

## Analytics

Not applicable: Sheet contains no analytics event tracking or data collection in the source.

## Privacy

- **Data collected**: None. Sheet does not collect, store, or transmit user data.
- **Storage**: No local storage or session storage is used.
- **Transmission**: No network requests are made.
- **Retention**: Not applicable.

## Logging

Not applicable: Sheet has no logging or debugging output in the source.

## Platform Notes

- **SwiftUI**: No SwiftUI version exists. A port would use a `.sheet()` or `.presentationDetents()` modifier for a bottom sheet, or a custom `.offset()` + `.transition()` for side drawers. Positioning logic would need manual implementation.
- **Compose**: No Compose version exists. A port would use a `ModalBottomSheet` or a custom `Box` with `animateAsState()` and `.offset()` for side-drawer behavior. The four-side positioning would require custom composition logic.
- **React/Web**: This is the React/Web version. It uses Base UI Dialog as the foundational primitive, Tailwind CSS for styling, and CSS custom properties for animation scaling.
- **AppKit / UIKit**: No AppKit or UIKit version exists. A port would use `NSPanel` on macOS or `UIViewController` with `.modalPresentationStyle = .custom` on iOS, with custom transition controller for slide-in behavior.
- **WinUI 3**: No WinUI 3 version exists. A port would use `ContentDialog` or a custom `Grid` with `ThicknessTransition` animations. Positioning to specific edges requires custom layout logic; WinUI 3 has no built-in side-drawer component. Side constraints would use `ColumnDefinition` widths or `RelativePanel` for left/right sides.

## Design Decisions

- **Compound component pattern**: Sheet is implemented as a series of composed sub-components (Header, Footer, Title, Description) rather than a monolithic component. This allows flexibility in content structure and reuse of individual parts. The pattern matches the shadcn/ui design philosophy.
- **Base UI Dialog foundation**: The component wraps Base UI's Dialog primitive, which provides keyboard handling (Escape to close), focus management, and ARIA attributes automatically. This offloads accessibility complexity to a vetted foundation.
- **Animation scale via CSS custom property**: Animation durations are calculated using `calc()` with a `--apt-anim-scale` custom property. This allows global animation control (e.g., for reduced motion) without changing component code.
- **Close button defaulting to visible**: The `showCloseButton` prop defaults to `true`, providing an always-available close affordance. Users can disable it if a custom close mechanism is preferred.
- **3/4 width constraint for side drawers**: Left and right drawers are constrained to 75% viewport width on small+ screens, leaving 25% of the underlying content visible. This preserves context and allows custom overflow behavior.
- **Overlay blur effect**: The backdrop includes a blur effect (via `supports-backdrop-filter:backdrop-blur-xs`) to create visual separation. This is a visual preference; the blur is optional on unsupporting browsers.

## Compliance

Sheet's wrapper component inherits focus management, Escape key handling, and ARIA modal dialog attributes from Base UI Dialog. The following compliance requirements are satisfied through this inheritance:

- **Focus management** (WCAG 2.1 2.4.3): Base UI Dialog automatically traps focus within the modal when open and restores focus to the triggering element when closed.
- **Keyboard dismissal** (WCAG 2.1 2.1.1): Base UI Dialog provides built-in keyboard support for the Escape key to close the modal.
- **Modal role and ARIA attributes** (WCAG 2.1 4.1.2): Base UI Dialog applies the `role="dialog"` attribute, `aria-modal="true"`, and `aria-labelledby` when a title is present.
- **Close button accessibility** (WCAG 2.1 1.3.1): Close button includes screen-reader-only text ("Close") via the `sr-only` class to provide accessible identification.

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.1 | 2026-09-22 | Mike Fullerton | Remove review marker from Compliance section; state Base UI Dialog inheritance as fact and list satisfied WCAG compliance items |
| 1.0.0 | 2026-09-22 | | Initial creation |
