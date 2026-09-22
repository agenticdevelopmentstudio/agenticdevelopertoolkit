---
id: 054522c7-53c8-45e4-9003-8c317a93b674
title: Document Identity Field
domain: agenticdevelopercookbook://ingredients/document-identity-field
type: ingredient
version: 1.0.0
status: review
language: en
created: '2026-09-22'
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Text inputs for document title and slug with optional availability checking.
platforms:
- typescript
- web
tags:
- form
- input
- document-metadata
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Document Identity Field

## Overview

A compound field that captures the two values that identify a document: its human-readable title and its URL-safe slug. The slug initially tracks title edits through a user-supplied slugify function; once the user manually edits the slug, it decouples and stays as edited. An optional availability checker reports whether the current slug is free, in progress, or taken.

## Behavioral Requirements

- **must-render-two-inputs**: Component MUST render two text inputs, one for title and one for slug.
- **must-render-title-label**: Component MUST render a label for the title input (default text "Title", customizable via `titleLabel` prop).
- **must-render-slug-label**: Component MUST render a label for the slug input (default text "Slug", customizable via `slugLabel` prop).
- **must-accept-title-prop**: Component MUST accept `title` string prop and display it in the title input.
- **must-accept-slug-prop**: Component MUST accept `slug` string prop and display it in the slug input.
- **must-call-onTitleChange**: Component MUST call `onTitleChange` callback with new string when user edits title input.
- **must-call-onSlugChange**: Component MUST call `onSlugChange` callback with new string when user edits slug input.
- **must-call-onSlugChange-when-title-changes**: Component MUST call `onSlugChange` callback when user edits title, passing the result of applying the `slugify` function to the new title, if slug has not been manually edited.
- **must-stop-auto-slugify-after-manual-edit**: Component MUST stop auto-generating slug from title once the user has manually edited the slug; on subsequent title edits, slug remains unchanged until the component is remounted or explicitly reset.
- **must-accept-slugify-function**: Component MUST accept `slugify` function prop that takes a title string and returns a slug string, used to derive slug from title edits.
- **must-accept-verdict**: Component MUST accept optional `verdict` prop (SlugVerdict type) with properties `status` ("idle" | "checking" | "available" | "unavailable") and `reason` (string or null).
- **must-display-status-message**: Component MUST display a status message corresponding to verdict status: null for "idle", "Checking…" for "checking", "Available" for "available", "Unavailable" for "unavailable".
- **must-display-verdict-reason**: Component MUST display `verdict.reason` when present and non-null, replacing the default status message; reason is displayed for all non-idle statuses.
- **must-announce-status-changes**: Component MUST announce verdict status changes and reason text to assistive technology using an `aria-live="polite"` region.
- **must-accept-disabled-prop**: Component MUST accept optional `disabled` boolean prop (default false); when true, both inputs MUST be disabled.
- **must-apply-className-prop**: Component MUST accept optional `className` string prop and apply it to the container element.
- **must-position-status-in-slug-row**: Component MUST render status message as a sibling element to the slug input within the same row, not below or above it.
- **must-use-monospace-slug-font**: Component MUST render slug input text in monospace font (font-family: monospace) at a smaller size (0.8rem) than the title input.

## Appearance

- **Container**: Flex column, gap 3 (12px), width full, part of field label group layout
- **Row layout**: Each input row uses inline field layout with right-aligned label
- **Title input**: Text input, inherits platform defaults for height, padding, border, font
- **Slug input**: Text input with monospace font at 0.8rem, inherits platform defaults for height, padding, border
- **Status message**: Text, font size 0.75rem (xs), color determined by tone (muted, success, or error), positioned to right of slug input with 8px gap
- **Gap between rows**: 12px (gap-3 on container)

## States

| State | Appearance change |
|-------|------------------|
| Default | Title and slug inputs render with inherited platform styles; status message is null or not rendered |
| Verdict: checking | Status message displays "Checking…" in muted tone |
| Verdict: available | Status message displays "Available" in success tone |
| Verdict: unavailable | Status message displays the reason (or "Unavailable") in error tone |
| Slug touched | Status message may change on subsequent title changes; slug no longer auto-follows title |
| Disabled | Both inputs are disabled; text is grayed; cursor is not-allowed; user cannot edit |

## Accessibility

- **Role**: Compound form control presenting two text inputs
- **Title input label**: Associated via `<label>` element wrapping caption and input
- **Slug input label**: Associated via `aria-labelledby` pointing to a `<span id>` containing the label text
- **Status announcement**: Rendered in an `aria-live="polite"` region; region is unconditionally mounted in DOM so changes are announced
- **Status as description**: Slug input uses `aria-describedby` pointing to status message element when status is present
- **Minimum tap target**: Both inputs inherit minimum touch target size from Input component (platform default, typically 44×44pt on iOS, 48×48dp on Android)
- **Keyboard navigation**: Both inputs are keyboard accessible; Tab navigates through title → slug → status (if interactive) in document order
- **Focus management**: Each input receives focus independently; focus is not trapped or redirected
- **High contrast**: Status message colors derive from tone tokens (muted, success, error) which meet WCAG AA contrast requirements
- **Color not alone**: Slug status is communicated by text and color; unavailable vs. available is text-differentiated, not color-only

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| doc-id-001 | must-render-two-inputs | Component mounted with title="Test" slug="test" | Title and slug inputs both render |
| doc-id-002 | must-render-title-label, must-render-slug-label | Component with default labels | "Title" label above title input, "Slug" label above slug input |
| doc-id-003 | must-accept-title-prop | title="Custom Title" | Title input value is "Custom Title" |
| doc-id-004 | must-accept-slug-prop | slug="custom-slug" | Slug input value is "custom-slug" |
| doc-id-005 | must-call-onTitleChange | User types "New" in title input | onTitleChange callback fires with new title string on each keystroke |
| doc-id-006 | must-call-onSlugChange | User types "new-slug" in slug input | onSlugChange callback fires with "new-slug" after first keystroke |
| doc-id-007 | must-call-onSlugChange-when-title-changes | title="" slug="" not touched, slugify=(t)=>t.toLowerCase(); user types "Hello World" | onTitleChange and onSlugChange both fire; slug becomes "hello world" |
| doc-id-008 | must-stop-auto-slugify-after-manual-edit | User types "Hello" (slug becomes "hello"), then manually edits slug to "custom", then title changes to "New" | Slug remains "custom", does not become "new" |
| doc-id-009 | must-accept-verdict | verdict={{status:"available", reason:null}} | Status message displays "Available" |
| doc-id-010 | must-display-verdict-reason | verdict={{status:"unavailable", reason:"Already taken"}} | Status message displays "Already taken", not "Unavailable" |
| doc-id-011 | must-announce-status-changes | verdict changes from idle to checking to available | aria-live region content changes, assistive tech announces "Checking…" then "Available" |
| doc-id-012 | must-accept-disabled-prop | disabled=true | Both title and slug inputs have disabled attribute; user cannot edit |
| doc-id-013 | must-position-status-in-slug-row | Component rendered | Status message is horizontally adjacent to slug input (same row), not below it |
| doc-id-014 | must-use-monospace-slug-font | Component rendered | Slug input uses monospace font at 0.8rem size (smaller than title input) |

## Edge Cases

- **Empty title, slug not touched**: If title is empty string and slugify returns empty, slug input value is empty and no verdict is triggered (checking does not occur when slug is empty).
- **Null or undefined slug in verdict**: If verdict.reason is not present or is null, status message displays the default text for the status (e.g., "Available"), not null or "undefined".
- **Verdict for stale slug**: If verdict status is computed for an earlier slug value and user has since changed the slug, the component MUST discard that verdict and wait for a new one. Stale verdicts do not block save or affect display (this is the responsibility of the useSlugAvailability hook caller; the component itself receives the verdict and does not know age).
- **Checker throws**: If the slug availability checker (passed via useSlugAvailability opts) throws an exception, verdict reverts to idle; component does not display an error state.
- **Remount with same document ID, different slug**: If the component is remounted (key changes), the touched state resets to false and slug begins following title again.
- **Title and slug both disabled**: Inputs remain readable; their values are displayed but not editable.
- **Verdict arrives after user stops editing slug**: Status message updates to reflect new verdict even after user moves focus away; aria-live region ensures announcement.
- **Very long title**: Slug input is flex-1, so it grows to fill available space; title input grows equally. Very long titles are not truncated by the component itself (handled by input or container constraints).
- **Verdict reason longer than status slot**: Reason text is displayed in full without truncation; overflow behavior is inherited from container (may wrap or scroll, depending on layout).

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `title` | string | (required) | Current title value |
| `onTitleChange` | (title: string) => void | (required) | Callback fired when user edits title |
| `slug` | string | (required) | Current slug value |
| `onSlugChange` | (slug: string) => void | (required) | Callback fired when user edits slug |
| `slugify` | (title: string) => string | (required) | Function to derive slug from title on title changes |
| `verdict` | SlugVerdict | `{ status: "idle", reason: null }` | Availability status for current slug, with optional reason text |
| `titleLabel` | string | "Title" | Label text for title input |
| `slugLabel` | string | "Slug" | Label text for slug input |
| `disabled` | boolean | false | If true, both inputs are disabled |
| `className` | string | undefined | Additional CSS class applied to container element |

## Deep Linking

Not applicable: This component is a form control, not a routable page or screen. Deep linking is the responsibility of the host application.

## Localization

| String Key | Default (en) | Context |
|-----------|-------------|---------|
| `titleLabel` | "Title" | Label for title input, passed as prop |
| `slugLabel` | "Slug" | Label for slug input, passed as prop |
| `statusText.checking` | "Checking…" | Verdict status while availability check is in progress |
| `statusText.available` | "Available" | Verdict status when slug is available |
| `statusText.unavailable` | "Unavailable" | Verdict status when slug is unavailable; overridden by verdict.reason if present |

These strings are either props or inline; the component does not load a translation table. Callers MUST provide localized strings as props and as verdict.reason.

## Accessibility Options

- **Reduce Motion**: Not applicable: Component has no animations.
- **Increase Contrast**: Slug status message colors (success, error, muted) inherit from tone tokens, which adjust for high-contrast mode in the design system.
- **Differentiate Without Color**: Slug status is communicated by text content ("Checking…", "Available", verdict.reason) in addition to color; verdict text is sufficient to convey status without color.

## Feature Flags

Not applicable: Component is always rendered when mounted; no feature flag controls its visibility or behavior.

## Analytics

Not applicable: Component does not generate analytics events. Host application SHOULD track user edits (onTitleChange, onSlugChange) and verdict changes (verdict prop updates) as needed for application analytics.

## Privacy

Not applicable: Component handles no sensitive data. Title and slug values are application data passed by the host; component does not encrypt, persist, or transmit them.

## Logging

Subsystem: `packages/web/packages/ui/blocks` | Category: `DocumentIdentityField`

| Event | Level | Message |
|-------|-------|---------|
| Verdict change | debug | `DocumentIdentityField: slug verdict changed to "${verdict.status}"` |

No logging is implemented in the source code; this table is provided for implementors on other platforms.

## Platform Notes

- **React/Web**: Implemented in `packages/web/packages/ui/src/blocks/document-identity-field.tsx`. Exports `DocumentIdentityField` component and `useSlugAvailability` hook. Uses Field layout="inline" for label alignment and Input component for text fields. Slug availability hook manages debouncing (default 350ms) and stale verdict dismissal. Component uses Tailwind utilities (cn, toneTextClass) for styling.

- **SwiftUI**: Start from a VStack containing two Form sections, each with a Label and TextField pair. Title field has keyboard type .default; slug field has keyboard type .default with monospace font (Font.system(.body, design: .monospaced)). Use @State to track touched (slug manually edited). On title change, if not touched, call slugify and update slug. Render status text conditionally based on verdict status in an HStack after the slug field; use .accessibilityElement(children: .combine) and .accessibilityLiveRegion(.polite) for the status region.

- **Compose**: Start from a Column with two Row elements for field layout. Use TextField for both inputs; slug field has fontFamily set to FontFamily.Monospace. Manage touched state with remember { mutableStateOf(false) }. On title change, if not touched, call slugify. Render status text after slug input using Text with appropriate color from the tone system; wrap status in LazyColumn with contentDescription for accessibility announcements.

- **AppKit / UIKit**: On iOS, use a UIStackView (axis: .vertical) containing two rows (each a UIStackView axis: .horizontal). Use UILabel for labels, UITextField for inputs. Title field has font .systemFont(ofSize: UIFont.labelFontSize); slug field has font .monospacedSystemFont(ofSize: 0.8 * UIFont.labelFontSize, weight: .regular). Add gestureRecognizer to slug field to set touched. On title change, if not touched, call slugify. Render status in a UILabel positioned to the right of slug input; set accessibilityLiveRegion to .polite and accessibilityLabel to the status text.

- **WinUI 3**: Use a StackPanel (Orientation="Vertical", Spacing=12). Render two rows, each with a Grid (ColumnDefinitions: auto, *) for label-input pairs. Title input: TextBox with FontSize inherited. Slug input: TextBox with FontFamily="Consolas" (or system monospace), FontSize=10. Manage input.Tag = bool for touched state; on TextChanged, if not touched, call slugify. For status message, use a TextBlock positioned in the slug row (Grid.Column=1, horizontally aligned right); set AccessibilityLive to Polite, Foreground color bound to verdict status (SolidColorBrush of success/error/muted tokens).

## Design Decisions

**Slug follows title until touched, then stays put.** The component uses session state (touched) to track whether the user has manually edited the slug. This allows auto-generation from title edits to stop once the user takes control, preserving intentional slug customization across title rewrites. Touched state does not persist across remount; opening a new document (different key) resets the behavior. This matches the use case where documents are opened/closed in a session and users expect slug to start fresh for each document.

**Availability verdict is injected, not owned.** The component receives verdict as a prop rather than owning the slug checking logic. This allows the host to manage checker (API call), debouncing, and stale-verdict dismissal, separating concerns and enabling shared truth: the host's Save button and the field's display both read the same verdict. The useSlugAvailability hook is exported for convenience, but the component does not require its use; hosts may provide verdicts computed any way they choose.

**Slug status is announcement-friendly.** The status message is rendered unconditionally in the DOM (even when null) as an aria-live region. This ensures the region exists before content changes, so assistive technology receives the first verdict update (often "Unavailable", the one most critical to hear). Status text prioritizes the reason over the default status label, so implementors can provide detailed feedback without duplicating the word "Unavailable".

**Monospace slug font signals machine-readability.** The slug input uses a smaller, monospace font to visually distinguish it from the human-readable title. This reinforces that slug is a technical identifier (e.g., URL path component) and may not match the title exactly.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| [keyboard-navigation](agenticdevelopercookbook://compliance/accessibility#keyboard-navigation) | passed | Accessibility |
| [touch-target-size](agenticdevelopercookbook://compliance/accessibility#touch-target-size) | passed | Accessibility |
| [aria-live-region](agenticdevelopercookbook://compliance/accessibility#aria-live-region) | passed | Accessibility |
| [contrast-ratio](agenticdevelopercookbook://compliance/accessibility#contrast-ratio) | passed | Accessibility |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | Mike Fullerton | Initial creation |
