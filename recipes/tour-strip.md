---
id: 1d701cc5-5822-4465-8ad5-413e6b0c31fc
title: Tour Strip
domain: agenticdevelopercookbook://ingredients/tour-strip
type: ingredient
version: 1.0.0
status: review
language: en
created: 2026-09-22
modified: '2026-09-22'
author: Mike Fullerton
copyright: 2026 Mike Fullerton
license: MIT
summary: Full-viewport screen opening a guided tour stop with navigation and optional
  pillar content.
platforms:
- web
tags:
- tour
- navigation
- landing
depends-on: []
related: []
references: []
approved-by: ''
approved-date: ''
---

# Tour Strip

## Overview

The Tour Strip is a full-viewport screen component that introduces a single stop within a guided tour. It displays a header identifying the tour step, a primary promise or headline, optional multi-column pillar content (title and body), and conditional back/next navigation links. The component is positioned as the first screen on a tour page, before any hero or other content, to immediately orient readers arriving mid-tour.

## Behavioral Requirements

- **must-render-eyebrow**: Component MUST render an eyebrow text containing the step number, total steps, and eyebrow label in the format `Step {step} of {total} · {eyebrow}`.
- **must-render-promise**: Component MUST render the promise content as a paragraph element.
- **must-position-as-first-screen**: Component MUST render as a full-viewport `Screen` with id `tour` and class `lp-tour`, positioned before any following content.
- **must-render-pillars-when-provided**: When `pillars` array is provided and non-empty, component MUST render each pillar with title and body in a dedicated card element.
- **must-render-back-navigation**: When `back` step is provided, component MUST render a link containing the step label and optional note, with a left arrow indicator.
- **must-render-next-navigation**: When `next` step is provided, component MUST render a link containing the step label and optional note, with a right arrow indicator.
- **must-not-render-navigation-when-absent**: Component MUST NOT render back navigation link when `back` prop is undefined; MUST NOT render next navigation link when `next` prop is undefined.
- **must-hide-arrow-from-assistive-tech**: Component MUST mark arrow indicators as decorative with `aria-hidden="true"`.
- **must-accept-react-node-promise**: The `promise` prop MUST accept any valid React node to allow composition of complex headline content.
- **must-accept-note-on-navigation-steps**: Both `back` and `next` step objects MUST accept an optional `note` property to display explanatory text below the step label.

## Appearance

- **Layout**: Full viewport, wrapped in `Screen` and `Wrap` components for consistent site layout
- **Eyebrow**: Renders with class `lp-eyebrow`; inherits color and typography from eyebrow styling
- **Promise paragraph**: Renders with class `lp-tour__promise`; serves as primary visual hierarchy element
- **Pillar cards**: Each renders with class `lp-card` containing `<h3>` title and `<p>` body; organized in grid under class `lp-tour__pillars`
- **Navigation steps container**: Renders with class `lp-tour__steps`
- **Navigation links**: Each renders with class `lp-tour__step` plus direction modifier (`lp-tour__step--back` or `lp-tour__step--next`)
- **Arrow indicators**: Render with class `lp-tour__arrow` using Unicode arrows (← for back, → for next)
- **Typography in navigation**: Step label renders in `<b>` (bold); optional note renders in `<em>` (emphasis)

## States

| State | Condition |
|-------|-----------|
| Default | Both back and next navigation present |
| First step | No back navigation; next navigation present |
| Last step | Back navigation present; no next navigation |
| Single step | Neither back nor next navigation present |
| No pillars | Pillars array absent or empty |
| With pillars | Pillars array provided with one or more items |

## Accessibility

- **Screen landmark**: Component renders within a `Screen` element with `id="tour"` to establish a page region
- **Semantic navigation**: Navigation links use standard `<a>` elements with `href` attributes; not marked as buttons
- **Arrow decorative status**: Left and right arrow characters are marked `aria-hidden="true"` as they are visual indicators duplicating semantic link content
- **Label clarity**: Navigation step labels (the `<b>` text) provide clear, concise descriptions of destination
- **Note clarification**: Optional note text in `<em>` provides clarification of what the reader gains by following the link
- **Pillar structure**: Pillar cards render with semantic heading (`<h3>`) and paragraph (`<p>`) to convey structure to assistive technology
- **Eyebrow context**: Eyebrow text provides step progress context to all users
- **No text links exempt note**: Inline text links in the promise content inherit no special touch-target minimum; semantic links in navigation regions have platform-appropriate spacing

## Conformance Test Vectors

| ID | Requirements | Input | Expected |
|----|-------------|-------|----------|
| tour-001 | must-render-eyebrow | `eyebrow: "Masterbrand Overview"`, `position: { step: 1, total: 3 }` | Eyebrow text reads "Step 1 of 3 · Masterbrand Overview" |
| tour-002 | must-render-promise | `promise: <h1>Welcome to the tour</h1>` | Promise renders the heading element in a paragraph wrapper with class `lp-tour__promise` |
| tour-003 | must-position-as-first-screen | All required props provided | Component renders within `Screen` with `id="tour"` and class `lp-tour"` |
| tour-004 | must-render-pillars-when-provided | `pillars: [{ title: "Design", body: "..." }, { title: "Code", body: "..." }, { title: "Ship", body: "..." }]` | Three cards render under `lp-tour__pillars` div, each with title in `h3` and body in `p` |
| tour-005 | must-not-render-navigation-when-absent | `back: undefined`, `next: undefined` | No navigation links render; `lp-tour__steps` div is still present but contains no links |
| tour-006 | must-render-back-navigation | `back: { href: "/tour/prev", label: "Previous", note: "See how it started" }` | Link renders with class `lp-tour__step--back`, left arrow with `aria-hidden="true"`, label in `<b>`, note in `<em>` |
| tour-007 | must-render-next-navigation | `next: { href: "/tour/next", label: "Next", note: "Continue deeper" }` | Link renders with class `lp-tour__step--next`, right arrow with `aria-hidden="true"`, label in `<b>`, note in `<em>` |
| tour-008 | must-accept-note-on-navigation-steps | `back: { href: "...", label: "...", note: undefined }` | Note element does not render when `note` is undefined; link still renders with label and arrow |
| tour-009 | must-hide-arrow-from-assistive-tech | Navigation links present | Both arrow `<span>` elements have `aria-hidden="true"` attribute |
| tour-010 | must-accept-react-node-promise | `promise: <>Multiline <strong>promise</strong> with fragments</>` | Fragment and child elements render correctly within promise paragraph |

## Edge Cases

- **Empty pillars array**: When `pillars` is provided but has zero length, the entire pillars section does not render (conditional on `length > 0`).
- **Undefined pillars**: When `pillars` prop is undefined, no pillar rendering occurs and no error is thrown; this is the normal state for leaf sites.
- **Missing navigation**: When both `back` and `next` are undefined (e.g., a single-stop tour or an isolated view), the navigation container still renders but contains no links.
- **Long eyebrow text**: No maximum length is enforced in the component; rendering and wrapping behavior are determined by CSS styling.
- **Long step labels**: Navigation label text length is not constrained; truncation or wrapping is controlled by CSS.
- **Long note text**: Optional note text has no length limit; layout behavior defers to CSS styling for the `<em>` element.
- **Complex promise content**: The `promise` prop accepts any React node; nested components, fragments, or HTML elements render as provided by the caller.
- **Navigation with missing href**: If `back` or `next` object lacks `href`, the link element still renders but the browser may treat it as an invalid anchor.
- **Pillar with missing fields**: If a pillar object lacks `title` or `body`, or either is empty string, those fields render as-is (no fallback text or placeholder).

## Configuration

| Option | Type | Required | Default | Description |
|--------|------|----------|---------|-------------|
| `eyebrow` | string | Yes | — | Text label for the tour step (e.g., "Introduction"). Rendered in step progress header. |
| `promise` | ReactNode | Yes | — | Primary headline or message for this tour stop. Accepts any valid React node for composability. |
| `position` | object | Yes | — | Object with `step` (current step number, 1-indexed) and `total` (total steps in tour). Used for progress display. |
| `pillars` | TourPillar[] | No | undefined | Optional array of pillar cards, each with `title` (string) and `body` (string). Omitted or empty array disables pillar rendering. |
| `back` | TourStep | No | undefined | Optional navigation step for previous tour stop, with `href` (string), `label` (string), and optional `note` (string). When undefined, back link does not render. |
| `next` | TourStep | No | undefined | Optional navigation step for next tour stop, with `href` (string), `label` (string), and optional `note` (string). When undefined, next link does not render. |

## Deep Linking

| Platform | URL Pattern | Behavior |
|----------|-------------|----------|
| Web | `/tour/{step_id}` | Navigates to a specific tour stop; `back` and `next` props are managed by the routing layer based on the walk order. |

## Localization

| String Key | Default (en) | Context |
|-----------|-------------|---------|
| N/A | "Step {step} of {total}" | Auto-generated step progress text; localization would require wrapping the component or post-render text substitution. |

## Accessibility Options

Not applicable: Component renders static layout and navigation with no motion, audio, or dynamic display options to respond to. Navigation links use standard `<a>` elements which inherit platform focus management; no component-specific accessibility preferences apply.

## Feature Flags

Not applicable: Component has no feature flag gating or conditional rendering controlled by flag state.

## Analytics

Not applicable: Component does not emit analytics events directly. Analytics instrumentation (view, click) is managed by the hosting page or router based on navigation link interactions.

## Privacy

Not applicable: Component does not collect, store, or transmit user data beyond standard navigation tracking inherited from link semantics.

## Logging

Not applicable: Component does not emit log messages or events.

## Platform Notes

- **React/Web**: TourStrip is a functional component receiving props and rendering JSX. Styling is applied via CSS classes (`lp-tour`, `lp-tour__promise`, `lp-tour__pillars`, `lp-tour__steps`, `lp-tour__step`, `lp-tour__step--back`, `lp-tour__step--next`, `lp-tour__arrow`, `lp-card`, `lp-eyebrow`). Layout is managed by parent `Screen` and `Wrap` components for site-wide consistency. Navigation state (back/next presence) is determined by the router or tour orchestrator; the component is stateless.
- **SwiftUI**: Translate to a full-screen view containing a top section for eyebrow text and promise headline, optional pillar cards in a grid (VStack or LazyVGrid), and bottom navigation buttons (styled as links). Use `NavigationLink` for back/next navigation or delegate to a router abstraction. Conditional rendering (`if back != nil`) handles absent navigation steps.
- **Compose**: Implement as a Composable function receiving the same data model. Use `LazyVerticalGrid` or `Column` for layout; render eyebrow and promise in a top section, pillar `Card` composables in a grid, and `TextButton` or `ClickableText` for navigation links. Platform-appropriate spacing and colors apply. State management (current step, tour walk) is external.
- **AppKit / UIKit**: Build a view controller or view containing a vertical stack with eyebrow label, promise view (UILabel or WKWebView if promise is rich HTML), optional pillar cards in a collection view or table, and bottom navigation buttons (UIButton or UITextView configured as links). Use Auto Layout or SwiftUI (if iOS 13+) for responsive layout. Navigation is managed by the hosting navigation controller or router.
- **WinUI 3**: Implement as a XAML UserControl with a `StackPanel` (vertical) or `Grid` for layout. Eyebrow renders as a `TextBlock`; promise as rich text or `TextBlock`. Pillars render as a `GridView` or `ItemsControl` of cards, each a `Border` with nested `TextBlock` elements. Navigation links are `HyperlinkButton` elements styled to match web appearance (arrow glyphs, underline state). Use `Visibility` binding to show/hide back and next buttons based on props. Apply Fluent 2 motion (if appropriate for the site's design) to entrance animations on scroll or load.

## Design Decisions

The component prioritizes tour orientation over visual hierarchy: the step progress eyebrow renders first, before the promise, so readers arriving mid-tour immediately know where they are in the walk before engaging with the page's pitch. This placement defers secondary content (pillars) and navigation to below the fold, reducing cognitive load on entry. Navigation links are rendered as plain anchors rather than styled buttons to reduce visual weight and integrate with the tour walk as a progression of related pages rather than a panel or modal. Optional pillars are included only on masterbrand tours; leaf sites omit them to keep the tour focused on a single call to action. Notes on navigation steps clarify the destination benefit, reducing cognitive friction when choosing whether to proceed.

## Compliance

| Check | Status | Category |
|-------|--------|----------|
| Semantic landmarks | Passed | Accessibility |
| Link text clarity | Passed | Accessibility |
| Decorative element hiding | Passed | Accessibility |

## Change History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | 2026-09-22 | | Initial creation |
